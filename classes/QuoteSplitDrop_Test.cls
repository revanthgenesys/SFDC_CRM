/*
	04/29/2013	Naresh Kumar
	Test Class to test main class QuoteSplitDrop	
*/
@isTest (seeAllData = true)
private class QuoteSplitDrop_Test {
    static testMethod void testMethod1() {
    	Account testAcc = TestUtil.createAccounts(1, true)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, false)[0];
        testQuote.Split_Status__c = false;
        insert testQuote;
        List<BigMachines__Quote_Product__c> quoteProducts = TestUtil.createQuoteProducts(1, false, testQuote.id);
        quoteProducts[0].Contract_Line_Update_Status__c = 'Split';
        quoteProducts[0].Original_Qty__c = 100;
        quoteProducts[0].Current_Qty__c = 40;
        insert quoteProducts;
        
        //BigMachines__Pricebook_Id__c
        ApexPages.StandardController stdController = new ApexPages.StandardController(testQuote);
        QuoteSplitDrop objController = new QuoteSplitDrop(stdController);
        try{
        	objController.submit();
        }
        catch(Exception ex){}
    }
}