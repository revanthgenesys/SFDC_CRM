/*
    On opportunity insert and update, populate few fields on opportunity
*/
trigger Opportunity_Before on Opportunity (before insert, before update) {
    if(Util.Bypass_Trigger_Chk)return;
    if(!TriggerFlowManager.OPPORTUNITY_BEFORE_UPDATE_TRIGGER)
        return;
    // code to fire on insert and update
    Set<Id> accountIds = new Set<Id>();
    for(Opportunity opp : trigger.new){
        if(opp.AccountId != null)
        accountIds.add(opp.AccountId);
        if(opp.BusinessPartner__c !=null)
        accountIds.add(opp.BusinessPartner__c);
    }

    Map<Id, Account> accountsMap = new Map<Id, Account>([Select Id, Country__c, Name, Country__r.SubRU__c
                                                             from Account where Id IN : accountIds]);
                                                             
    for(Opportunity opp : trigger.new){
        if(opp.Direct_Sales__c){
            opp.Sold_To_Country__c = opp.Country__c;
            opp.Alternative_Sold_To__c = opp.AccountId;
        }else{
            opp.Sold_To_Country__c = accountsMap.get(opp.BusinessPartner__c) == null? null :accountsMap.get(opp.BusinessPartner__c).Country__c;
           
            opp.Country__c =  accountsMap.get(opp.AccountId) != null ? accountsMap.get(opp.AccountId).Country__c : null;
        }
            
    }
    
    
    // code to fire only on update
    if(trigger.isUpdate){
        for(Opportunity opp : trigger.new){
            Opportunity oldOpp = trigger.oldMap.get(opp.Id);
            if( oldOpp.BusinessPartner__c != opp.BusinessPartner__c || 
                opp.Alternative_Sold_To__c==null ){
                opp.Alternative_Sold_To__c = opp.BusinessPartner__c;
            }
        }
        TriggerFlowManager.OPPORTUNITY_BEFORE_UPDATE_TRIGGER = false;
    }
    
    // code to fire only on update
    if(trigger.isInsert){
        Id rTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Genesys Renewal').getRecordTypeId();
     /* Yuvaraj toomanysoql   List<RecordType> rtypes = [Select Id from RecordType where SobjectType='Opportunity' and DeveloperName =: ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME];*/
        //Set<Id> oppIds = new Set<Id>();
        
        //for(Opportunity opp : trigger.new){
          //      oppIds.add(opp.ParentOpportunity__c);
        //}
      //  Map<Id, Opportunity> opps = new Map<Id, Opportunity>([Select Id, Service_Contract__c, Service_Contract__r.EndDate 
        //                                                      from Opportunity
          //                                                    where Id IN :oppIds]);
        
        
        for(Opportunity opp : trigger.new){
          //  if(rtypes!=null && opp.RecordTypeId != rtypes[0].Id)
          if(rtypeId!=null && opp.RecordTypeId != rtypeId)
                opp.Name = accountsMap.get(opp.AccountId).Name + '-' + opp.Name;
            opp.Original_Sold_To__c = opp.BusinessPartner__c;
            if(opp.Alternative_Sold_To__c==null) 
                opp.Alternative_Sold_To__c = opp.BusinessPartner__c;
          //  if(opps.get(opp.ParentOpportunity__c) != null && opps.get(opp.ParentOpportunity__c).Service_Contract__c != null)
            //  opp.CloseDate = opps.get(opp.ParentOpportunity__c).Service_Contract__r.EndDate;
            // on opp insert, populate the opp sub sub region with accounts country.subRu__c
            opp.Big_Four__c = accountsMap.get(opp.AccountId) != null ? accountsMap.get(opp.AccountId).Country__r.SubRU__c : null;
        }       
           
    }
}