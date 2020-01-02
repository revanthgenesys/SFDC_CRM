/*
	04/29/2013	Naresh Kumar
	Test Class to test main class ServiceContractsCoTermController
*/
@isTest (seeAllData = true)
private class ServiceContractsCoTermController_Test {
    static testMethod void myTestMethod() {
    	Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
    	BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, false)[0];
    	testQuote.BigMachines__Is_Primary__c = true;
    	insert testQuote;
    	ServiceContract testSC = TestUtil.createServiceContracts(1, true)[0];    	
    	Quote_Service_Contracts__c testQuoteSC = TestUtil.createQuoteServiceContracts(testQuote.id, 1, false)[0];
    	testQuoteSC.Service_Contract__c = testSC.id;
    	insert testQuoteSC;    	
    	ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        ServiceContractsCoTermController objController = new ServiceContractsCoTermController(stdController);
        objController.getSclines();
    }
}