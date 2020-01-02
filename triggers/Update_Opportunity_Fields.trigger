trigger Update_Opportunity_Fields on OpportunityLineItem (after delete, after insert, after update) {
    if(Util.Bypass_Trigger_Chk)return;
    //Setup the array to hold the Id to Iterate through
    Set<Id> CurrentOppId = new Set<Id>();
    if(trigger.isinsert || trigger.isupdate){
    for (OpportunityLineItem OppLnItem : Trigger.new){
            CurrentOppId.add(OppLnItem.OpportunityId);
    }}
    
    if(trigger.isdelete){
    for (OpportunityLineItem OppLnItem : Trigger.old){
            CurrentOppId.add(OppLnItem.OpportunityId);
    }}
    
    // Create List of One Opportunity Id to Update
    List<Opportunity> OppId = [Select o.Id,forecasted_flag__c from Opportunity o where o.Id in: CurrentOppId];
     decimal totalprice=0;
     decimal term_license=0;
    Boolean blnUpdatePrice = false;
    //Iterate through the Opportunity to Update (should be just one record)
    for (Opportunity opp2 : OppId)
    {
        if(opp2.Forecasted_Flag__c==true){
             for(OpportunityLineItem ol:[SELECT totalprice FROM 
                                            OpportunityLineItem where opportunityid=:opp2.id 
                                                and (PricebookEntry.Product2.type__c='product' or PricebookEntry.Product2.type__c='Rental' or  PricebookEntry.Product2.ProductLine__c='LICENSE' or (PricebookEntry.Product2.type__c='Product - Hardware' And PricebookEntry.Product2.Passthrough_SW_Product__c = true))
                                                AND Product_Type__c != 'Cloud']){
                  
                    totalprice = totalprice + ol.totalprice;
                   
                } 
                opp2.license_Amount__c = totalprice;
              
            }
        else {
            for(OpportunityLineItem ol:[SELECT totalprice,PricebookEntry.Product2.type__c FROM 
                                            OpportunityLineItem where opportunityid=:opp2.id 
                                                and PricebookEntry.Product2.Forecasted__c = true AND Product_Type__c != 'Cloud' AND GC_Type__c != 'Cloud']){
                     if(ol.PricebookEntry.Product2.type__c<>'Rental')
                    totalprice = totalprice + ol.totalprice;
                    else
                    term_license = term_license+ol.totalprice;                               
                    blnUpdatePrice = true;
                } 
            if(blnUpdatePrice){
                    opp2.license_Amount__c = totalprice;
                    opp2.term_license__c = term_license;
            }
            }
        update opp2;    
    }
}