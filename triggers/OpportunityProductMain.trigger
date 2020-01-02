// Update Opportunity Totals only if there is no primary quote on the Opportunity
trigger OpportunityProductMain on OpportunityLineItem (after insert, after update, before insert, 
before update, before delete, after delete,after undelete) 
{
  if(Util.Bypass_Trigger_Chk)
    return;
    
  if(Trigger.isAfter && !Trigger.isUndelete)
  {
    List<OpportunityLineItem> list_OpptyProducts =  Trigger.isDelete ? Trigger.old : Trigger.new;
        Set<Id> set_OpptyIds = new Set<Id>();
        Map<Id,OpportunityLineItem> map_OpptyProducts = new Map<Id,OpportunityLineItem>();
        
        for(OpportunityLineItem objOLI : list_OpptyProducts)
            set_OpptyIds.add(objOLI.OpportunityId);
        
        Map<Id,Opportunity> map_Oppty = new Map<Id,Opportunity>([SELECT Id,
                                         (SELECT Id FROM BigMachines__BigMachines_Quotes__r WHERE BigMachines__Is_Primary__c = true LIMIT 1) 
                                        FROM Opportunity WHERE Id IN :set_OpptyIds]);
        
        for(OpportunityLineItem objOLI : list_OpptyProducts)
        {
            if(map_Oppty.get(objOLI.OpportunityId).BigMachines__BigMachines_Quotes__r.isEmpty())
                map_OpptyProducts.put(objOLI.Id,objOLI);
        }
        
        if(!map_OpptyProducts.isEmpty())
          UpdateTotalsOnOppFromOpportunityProduct.updateTotalsOnOpp(map_OpptyProducts);
        
        /*if(Trigger.isDelete)
            UpdateTotalsOnOppFromOpportunityProduct.updateTotalsOnOpp(trigger.oldMap);
        else
            UpdateTotalsOnOppFromOpportunityProduct.updateTotalsOnOpp(trigger.newMap);*/   
    } 
    
    if(trigger.isAfter && !trigger.isUnDelete && !System.isFuture() && !System.isBatch() && TriggerFlowManager.OPPORTUNITY_SML_UPDATE){
        TriggerFlowManager.OPPORTUNITY_SML_UPDATE = false;
        if(trigger.isDelete)
            SMLHelperWTS.runSMLUpdateForOpportunity(trigger.old);
        else
            SMLHelperWTS.runSMLUpdateForOpportunity(trigger.new);       
    }

  if(Trigger.isBefore)
  {
    if(Trigger.isUpdate || Trigger.isInsert)
    {
      Set<Id> setOpptIds = new Set<Id>();
      Set<Id> setPBEntryIds = new Set<Id>();
      Set<Id> setProdIds = new Set<Id>();
        
      for(OpportunityLineItem oli : Trigger.new)
      {
        setOpptIds.add(oli.OpportunityId);
        setPBEntryIds.add(oli.PricebookEntryId);
      }
      
      Map<Id,Opportunity> mapOppt = new Map<Id,Opportunity>([SELECT Id, RecordType.DeveloperName, ProjectType__c FROM Opportunity WHERE Id IN :setOpptIds]);
      Map<Id,PricebookEntry> mapPBE = new Map<Id,PricebookEntry>([SELECT Id, Product2Id FROM PricebookEntry WHERE Id IN :setPBEntryIds]);
        
      for(PricebookEntry pbe : mapPBE.values())
      {
        setProdIds.add(pbe.Product2Id);
      }
        
      Map<Id,Product2> mapProd = new Map<Id,Product2>([SELECT Id, POB_Type__c FROM Product2 WHERE Id IN :setProdIds]);

      OpportunityProductHelper helper = new OpportunityProductHelper();
    
      for(OpportunityLineItem oli : Trigger.new)
      {
        //System.debug('####Oli'+Oli);
        Opportunity opp = mapOppt.get(oli.OpportunityId);
        PricebookEntry pbe = mapPBE.get(oli.PricebookEntryId);
        Product2 prod = mapProd.get(pbe.Product2Id);

        System.debug('*** OpportunityProductMain: Check record type.');
        System.debug('*** OpportunityProductMain: record type is ' + opp.RecordType.DeveloperName + '.');
        if(opp.RecordType.DeveloperName == 'Professional_Services')
        {
          System.debug('*** OpportunityProductMain: call Helper.');
          // PS RevPro:
          // For PS Opportunities, we need to set the OLI POB_Type based on the Product POB Type and possibly the
          // Oppt Project Type.  Ignore non-PS Oppts.
          oli.POB_Type__c = helper.MapPOBType(prod.POB_Type__c, opp.ProjectType__c);
          System.debug('*** OpportunityProductMain: pob type is ' + oli.POB_Type__c);
        }
        // Check if there is a linked opportunity product ID for this record now, and if there is then update the linked product name field
        if(oli.Linked_Oppty_Product_ID__c == NULL || oli.Linked_Oppty_Product_ID__c == '')
        {
             // No ID has been specified yet so do nothing at the moment
             //System.Debug('NLM Debug>>>> No Linked Oppty Product ID specified');
        }
        else
        {
            // Need to get the opportunity product (line item) name from the Linked ID
            list<OpportunityLineItem> lstLinkedOppLI = new list<OpportunityLineItem>
                        ([SELECT id, pricebookentry.product2.name FROM OpportunityLineItem WHERE Id =: oli.Linked_Oppty_Product_ID__c]);
          
            if (!lstLinkedOppLI.IsEmpty())
            {
                //System.Debug('NLM Debug>>>> Oppty Product Name is :' + lstLinkedOppLI[0].pricebookentry.product2.name);
                oli.Linked_Oppty_Product_Name__c = lstlinkedOppLI[0].pricebookentry.product2.name;            
            }
            else
            {
                //System.Debug('NLM Debug>>>> Linked Oppty Product Name not found from ID');
            }
        }
      }
      OpportunityProductLineAssignment.AssignProductLineNumbers(Trigger.new, null);
    }
  }
  //Inserted for Hard delete
  if(trigger.isDelete && trigger.isBefore)
     {   
        ID jobID = System.enqueueJob(new DeleteHistoryAsync(Trigger.oldMap,'delete'));
     }
     
   if(trigger.isUnDelete && trigger.isAfter)
     {   
        ID jobID2 = System.enqueueJob(new DeleteHistoryAsync(Trigger.oldMap,'Restore'));
     }
}