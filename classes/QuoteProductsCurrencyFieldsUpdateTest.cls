@isTest(seeAllData=true)
private class QuoteProductsCurrencyFieldsUpdateTest {
	@isTest
    static void testQuoteProductsCurrencyFieldsUpdateBatch(){
        Test.startTest();
        Database.executeBatch(new QuoteProductsCurrencyFieldsUpdateBatch());
        Test.stopTest();
    }
    
    @isTest
    static void testTrigger_BigMachines_Quote_Product_Before(){
        Test.startTest();
        List<BigMachines__Quote_Product__c> quoteProducts = [SELECT Id, Name, CurrencyISOCode, Genesys_Care_Amount__c, New_Genesys_Care_Amount_USD__c, 
                        Ext_Net_Price__c, New_Ext_Net_Price_USD__c, Equivalent_Total_New_Price__c, New_Equivalent_Total_New_Price_USD__c, 
						Ext_List__c, New_Ext_List_Price_USD__c, CreatedDate 
						FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__r.Quote_Business_Type__c = 'On Premise' AND 
                        (Genesys_Care_Amount__c != NULL OR Ext_Net_Price__c != NULL OR Equivalent_Total_New_Price__c != NULL)  LIMIT 2];
        Update quoteProducts;
        Test.stopTest();
    }
    
    @isTest
    static void testCurrencyConversionUtil(){
        Test.startTest();
        Decimal amount1 = CurrencyConversionUtil.convertCurrencyToUSD(1000.00, 'EUR' , System.today());
        Decimal amount2 = CurrencyConversionUtil.convertCurrencyToUSD(1000.00, 'USD' , System.today());
        Decimal amount3 = CurrencyConversionUtil.convertCurrencyToUSD(1000.00, 'EUR' , System.today());
        
        Decimal datedAmount1 = CurrencyConversionUtil.convertCurrencyToUSD(1000, 'USD', Date.today());
        Decimal datedAmount2 = CurrencyConversionUtil.convertCurrencyToUSD(1000, 'EUR', Date.today());
        Test.stopTest();
    }
}