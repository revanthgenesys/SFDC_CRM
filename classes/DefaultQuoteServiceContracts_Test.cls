/*
	04/25/2013	Naresh Kumar
	Test Class to test main class DefaultQuoteServiceContracts	
*/
@isTest (seeAllData = true)
private class DefaultQuoteServiceContracts_Test {

    static testMethod void testMethod1() {
    	Account testAcc = TestUtil.createAccounts(1, true)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, false)[0];
        testQuote.End_User_Company_Name__c = testAcc.Name;        
        insert testQuote;
    }
}