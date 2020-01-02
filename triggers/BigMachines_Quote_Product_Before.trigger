// Test Class: QuoteProductsCurrencyFieldsUpdateTest
trigger BigMachines_Quote_Product_Before on BigMachines__Quote_Product__c (before insert, before update,before delete,after undelete) {
    //if(Util.Bypass_Trigger_Chk) return;
    if((trigger.isBefore)&&(trigger.isInsert||trigger.isUpdate))
    {
    if(QuoteProductsCurrencyFieldsUtil.QuoteProductBI_AlreadyExecuted){
        return;
    } else {
        QuoteProductsCurrencyFieldsUtil.QuoteProductBI_AlreadyExecuted = true;
    }
    
    if(QuoteProductsCurrencyFieldsUtil.QuoteProductBU_AlreadyExecuted){
        return;
    } else {
        QuoteProductsCurrencyFieldsUtil.QuoteProductBU_AlreadyExecuted = true;
    }
    
    Set<String> quoteIds = new Set<String>();
    for(BigMachines__Quote_Product__c quoteProduct : Trigger.NEW){
        quoteIds.add(quoteProduct.BigMachines__Quote__c);   
    }
    
    Map<Id, BigMachines__Quote__c> quotesMap = new Map<Id, BigMachines__Quote__c>([SELECT id, Name, BigMachines__Opportunity__c, 
                                                                                   BigMachines__Opportunity__r.CloseDate, CreatedDate 
                                                                                   FROM BigMachines__Quote__c WHERE Id IN :quoteIds]);
    for(BigMachines__Quote_Product__c quoteProduct : Trigger.NEW){
        Date currencyDate = Date.today();
        
        if(quotesMap.get(quoteProduct.BigMachines__Quote__c) != NULL){
            BigMachines__Quote__c quote = quotesMap.get(quoteProduct.BigMachines__Quote__c);
            if(quote.BigMachines__Opportunity__c != NULL && quote.BigMachines__Opportunity__r.CloseDate != NULL){
                currencyDate = quote.BigMachines__Opportunity__r.CloseDate;   
            } else {
                currencyDate = quote.CreatedDate.date();
            }
        }
        /*
        if(Trigger.isUpdate){
            currencyDate = Date.newinstance(quoteProduct.CreatedDate.year(), quoteProduct.CreatedDate.month(), quoteProduct.CreatedDate.day());    
        }
        */
        CurrencyConversionUtil.updateQuoteProductsCurrencyFields(quoteProduct, currencyDate);    
    }
    }
    //Inserted for Hard delete
     if(trigger.isDelete && trigger.isBefore)
     {   
        ID jobID = System.enqueueJob(new DeleteHistoryAsync(Trigger.oldMap,'delete'));
     }
     
   if(trigger.isUnDelete && trigger.isAfter)
     {   
        ID jobID2 = System.enqueueJob(new DeleteHistoryAsync(Trigger.newMap,'Restore'));
     }
    
}