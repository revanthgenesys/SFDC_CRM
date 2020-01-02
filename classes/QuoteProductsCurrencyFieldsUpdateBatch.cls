global class QuoteProductsCurrencyFieldsUpdateBatch implements Database.Batchable<sObject>{
	
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Name, CurrencyISOCode, Genesys_Care_Amount__c, New_Genesys_Care_Amount_USD__c, '
					+ ' Ext_Net_Price__c, New_Ext_Net_Price_USD__c, Equivalent_Total_New_Price__c, New_Equivalent_Total_New_Price_USD__c, CreatedDate '
					+ ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__r.Quote_Business_Type__c = \'On Premise\' AND '
            		+ ' (Genesys_Care_Amount__c != NULL OR Ext_Net_Price__c != NULL OR Equivalent_Total_New_Price__c != NULL) ';
        if(Test.isRunningTest())
            query = query + ' LIMIT 10';  
        return Database.getQueryLocator(query);
    }
	global void execute(Database.BatchableContext bc, List<BigMachines__Quote_Product__c> scope){
        Util.Bypass_Trigger_Chk = true;
        for(BigMachines__Quote_Product__c quoteProduct : scope){
            quoteProduct.New_Genesys_Care_Amount_USD__c = CurrencyConversionUtil.convertCurrencyToUSD(quoteProduct.Genesys_Care_Amount__c, 
                                                                                                      quoteProduct.CurrencyISOCode, 
                                                                                                      Date.newinstance(quoteProduct.CreatedDate.year(), 
                                                                                                                       quoteProduct.CreatedDate.month(), 
                                                                                                                       quoteProduct.CreatedDate.day())
                                                                                                       );
            quoteProduct.New_Ext_Net_Price_USD__c = CurrencyConversionUtil.convertCurrencyToUSD(quoteProduct.Ext_Net_Price__c, 
                                                                                                      quoteProduct.CurrencyISOCode, 
                                                                                                      Date.newinstance(quoteProduct.CreatedDate.year(), 
                                                                                                                       quoteProduct.CreatedDate.month(), 
                                                                                                                       quoteProduct.CreatedDate.day())
                                                                                                       );
            quoteProduct.New_Equivalent_Total_New_Price_USD__c = CurrencyConversionUtil.convertCurrencyToUSD(quoteProduct.Equivalent_Total_New_Price__c, 
                                                                                                      quoteProduct.CurrencyISOCode, 
                                                                                                      Date.newinstance(quoteProduct.CreatedDate.year(), 
                                                                                                                       quoteProduct.CreatedDate.month(), 
                                                                                                                       quoteProduct.CreatedDate.day())
                                                                                                       );
        }
        Database.Update(scope);
        Util.Bypass_Trigger_Chk = false;
    }
    global void finish(Database.BatchableContext bc){
    }
}