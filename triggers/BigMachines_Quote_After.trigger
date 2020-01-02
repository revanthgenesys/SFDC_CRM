trigger BigMachines_Quote_After on BigMachines__Quote__c (after Update,after delete, after insert, after undelete) 
{
    if(Util.Bypass_Trigger_Chk)
        return;
    
    Set<Id> oppIds = new Set<Id>();
    if(trigger.isInsert || trigger.isUnDelete)
    {
        for( BigMachines__Quote__c quote : trigger.new)
        {
            // Only add vaild Oppty ids
            if(quote.BigMachines__Opportunity__c != null)
                oppIds.add(quote.BigMachines__Opportunity__c);
        }
        if(Trigger.isInsert && Trigger.isAfter){
            DefaultQuoteServiceContracts.addDefaultQuoteServiceContractsRecord(Trigger.new);
            DefaultQuoteServiceContracts.populateLookupsOnInsert(Trigger.new);
            QuoteFieldMappings.populateFieldsOnInsert(Trigger.new);
            OppQuoteOrderStatusHandler.updateOpportunityStatus(Trigger.new, null);
        }
    }
    
    if(trigger.isDelete){
        for( BigMachines__Quote__c quote : trigger.old)
        {
            // Only add vaild Oppty ids
            if(quote.BigMachines__Opportunity__c != null)
                oppIds.add(quote.BigMachines__Opportunity__c);
        }
    }
    if(!oppIds.isEmpty()){
        QuoteProductUtil.updateNoOfQuotesOnOpp( oppIds );
    }   
    System.debug('NKC debug TriggerFlowManager.QUOTE_AFTER_UPDATE_TRIGGER ['+TriggerFlowManager.QUOTE_AFTER_UPDATE_TRIGGER+']');
    if(trigger.isUpdate && TriggerFlowManager.QUOTE_AFTER_UPDATE_TRIGGER) {
        
        if(Trigger.isAfter){            
            DefaultQuoteServiceContracts.populateLookupsOnUpdate(Trigger.New, Trigger.oldMap);
            QuoteFieldMappings.populateFieldsOnUpdate(Trigger.New, Trigger.oldMap);
            QuoteFieldMappings.populateGenesysCare(Trigger.New, Trigger.oldMap);            
        }
        System.debug('NKC debug TriggerFlowManager.QUOTE_AFTER_UPDATE_TRIGGER ['+TriggerFlowManager.QUOTE_AFTER_UPDATE_TRIGGER+']');
        System.debug('NKC debug trigger.new[0].BigMachines__Status__c ['+trigger.new[0].BigMachines__Status__c+']');
        if(!System.isFuture()){
            if(trigger.new[0].BigMachines__Status__c =='Quote Approved' || trigger.new[0].BigMachines__Status__c == 'Pending Approval')    
                QuoteSplitDrop.createDropSplit(trigger.new[0].id,'Split');
            
            // The following condition has been moved to QuoteFieldMappings.createDropDownsizeShelvedSCsOnOrderComplete by RAO 
            // In order for DROP, DOWNSIZE and Shelved to be created only after the Order is Completed
            /* if(trigger.new[0].BigMachines__Status__c =='Order Submitted' || trigger.new[0].BigMachines__Status__c == 'Pending Approval'){  
                QuoteSplitDrop.createDropSplit(trigger.new[0].id,'Drop');
                QuoteSplitDrop.createDropSplit(trigger.new[0].id,'Shelved');
                QuoteSplitDrop.createDropSplit(trigger.new[0].id,'Downsize');
            } */
        }
        TriggerFlowManager.QUOTE_AFTER_UPDATE_TRIGGER = false;
        
    }
    if(trigger.isUpdate && TriggerFlowManager.QUOTE_STATUS_TO_OPP_STATUS_POPULATION && 
       (trigger.new[0].BigMachines__Status__c != trigger.old[0].BigMachines__Status__c|| trigger.new[0].Sent_to_Customer__c != trigger.old[0].Sent_to_Customer__c 
       || (trigger.new[0].BigMachines__Is_Primary__c != trigger.old[0].BigMachines__Is_Primary__c && trigger.old[0].BigMachines__Is_Primary__c !=true))){
        OppQuoteOrderStatusHandler.updateOpportunityStatus(Trigger.new, Trigger.oldMap);
    }
    if(trigger.isUpdate && TriggerFlowManager.QUOTE_SENT_TO_CUSTOMER_POPULATION){
        OppQuoteOrderStatusHandler.updateSentToCustomerStatus(Trigger.new, Trigger.oldMap);
    }   
}