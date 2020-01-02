trigger BigMachines_Quote_Before on BigMachines__Quote__c (before insert, before update) {
    
    //11-12-2019 Yepuri Malavika Sahithi INC0439558-To avoid more than one primary quote for each opportunity
    if(Trigger.isInsert || Trigger.isUpdate)
    {
        Set<Id> oppIdSet = new Set<Id>();
        for(BigMachines__Quote__c q : trigger.new){
            if(q.BigMachines__Opportunity__c != null){
                oppIdSet.add(q.BigMachines__Opportunity__c);
            }
        }
        List<BigMachines__Quote__c> primaryQuoteList = new List<BigMachines__Quote__c>([Select id,BigMachines__Is_Primary__c,BigMachines__Opportunity__c FROM BigMachines__Quote__c WHERE BigMachines__Opportunity__c IN: oppIdSet AND BigMachines__Is_Primary__c = true LIMIT 1]);
        /*if(!primaryQuoteList.isEmpty()){//Commentedby Rony Joseph on December 11th 2019 as it breaking the update functionality for Quotes and Orders
            for(BigMachines__Quote__c q : trigger.new){
                if(q.BigMachines__Is_Primary__c == true){
                    q.addError('Select only one primary quote');
                }
            }   
        }*/
    }
    // Check if Quote is primary before Order can be submitted (Putting this logic ahead of bypass check flag)
    if(Trigger.isInsert || Trigger.isUpdate)
    {
        BigMachines__Quote__c currentQuote = Trigger.new[0];
        String quoteStatus = currentQuote.BigMachines__Status__c;
        if((quoteStatus == 'Order Accepted' || quoteStatus == 'Order Submitted' || quoteStatus == 'Order Approved')
          && !currentQuote.BigMachines__Is_Primary__c)
        {
            if(Trigger.isUpdate && Trigger.oldMap.get(currentQuote.Id).BigMachines__Is_Primary__c)
            {
                currentQuote.addError('Quote ' + currentQuote.Name + ' has to be primary as Order has already been Submitted/Accepted/Approved on it.');
                return;
            }
            currentQuote.addError('Quote has to be primary before Order can be Submitted/Accepted/Approved on it.');
            return;    }
        //Added on 27/12/2019 by Kalyan for Incident-INC0437245 Start.
        /*if(currentQuote.Opportunity_Type__c==ServiceContractUtil.OPP_GEN_NEW_DEV_NAME){
            currentQuote.Maintenance_Start_Date__c=system.today();
            currentQuote.Maintenance_End_Date__c=system.today().addmonths(12);
        }*/
        //Added on 27/12/2019 by Kalyan for Incident-INC0437245 Ends.
    }
    
    if(Util.Bypass_Trigger_Chk)
        return;
    
    // code to execute on insert 
    if(trigger.isInsert){
        // if quote is cancelled, update the opp stages 
        Set<Id> quoteIdsToUpdateOppStages = new Set<Id>();
        for(BigMachines__Quote__c q : trigger.new){
            if(q.Cancellation_Reason__c!= null && q.BigMachines__Opportunity__c != null)
                quoteIdsToUpdateOppStages.add(q.BigMachines__Opportunity__c);
        }
        // update the opp stage as "Closed Quote Cancelled"
        if(!quoteIdsToUpdateOppStages.isEmpty())
            QuoteProductUtil.updateOppStages(quoteIdsToUpdateOppStages);
    }
    
    // code to execute on update 
    if(trigger.isUpdate && TriggerFlowManager.QUOTE_BEFORE_UPDATE_TRIGGER ){
        Set<Id> quoteIdsToUpdateOppStages = new Set<Id>();
        Map<Id, BigMachines__Quote__c> oppIdsToQuotes = new Map<Id, BigMachines__Quote__c>();
        for(BigMachines__Quote__c q : trigger.new){
            BigMachines__Quote__c oldq = trigger.oldMap.get(q.Id);
            // if quote is marked as primary, update the opportunity fields
            if(q.BigMachines__Is_Primary__c && q.BigMachines__Opportunity__c != null ) {
                oppIdsToQuotes.put(q.BigMachines__Opportunity__c, q);
            }
            // if quote is cancelled, update the opp stages
            if(q.Cancellation_Reason__c != oldq.Cancellation_Reason__c && q.Cancellation_Reason__c!= null && q.BigMachines__Opportunity__c != null)
                quoteIdsToUpdateOppStages.add(q.BigMachines__Opportunity__c);
        }
        // update the opp stage as "Closed Quote Cancelled"
        if(!quoteIdsToUpdateOppStages.isEmpty())
            QuoteProductUtil.updateOppStages(quoteIdsToUpdateOppStages);
        // copy fields from primary quote to opp    
        if(!oppIdsToQuotes.isEmpty())
            QuoteProductUtil.updateOpportunities(oppIdsToQuotes);
        
    }
    if(!TriggerFlowManager.QUOTE_BEFORE_UPDATE_TRIGGER)
        return;
    // on both insert and update - for  Quotes from License Opportunity (GEN - Opportunity Record Type )
    Set<Id> oppIds = new Set<Id>();
    for(BigMachines__Quote__c q : trigger.new){
        // get all oppIds from quote
        if(q.BigMachines__Opportunity__c != null && q.Quote_Business_Type__c != 'Renewal')
            oppIds.add(q.BigMachines__Opportunity__c);
    }
    if(!oppIds.isEmpty()){
         Map<Id, Opportunity> oppsMap = new Map<Id, Opportunity>([Select ID 
                                                          from Opportunity 
                                                          where ID IN: oppIds 
                                                                and RecordType.DeveloperName =:ServiceContractUtil.OPP_GEN_NEW_DEV_NAME] );
         for(BigMachines__Quote__c q : trigger.new){
            if(q.BigMachines__Opportunity__c != null && oppsMap.containsKey(q.BigMachines__Opportunity__c))
            {
                if(q.Genesys_Care_Overide__c == null)
                    q.Current_Maint_Rate__c = q.Genesys_Care_Rate__c;
                else 
                    q.Current_Maint_Rate__c = Decimal.valueof(q.Genesys_Care_Overide__c); 
            }
         }
    }
    if(Trigger.isUpdate)
        TriggerFlowManager.QUOTE_BEFORE_UPDATE_TRIGGER = false;
    
}