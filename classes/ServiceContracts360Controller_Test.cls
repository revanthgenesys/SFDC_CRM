/*
    04/29/2013  Naresh Kumar
    Test Class to test main class ServiceContracts360Controller
*/
@isTest (seeAllData = true)
private class ServiceContracts360Controller_Test {
    static testMethod void myTestMethod() {
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];
        Quote_Service_Contracts__c testQuoteSC = TestUtil.createQuoteServiceContracts(testQuote.id, 1, true)[0];
        //ServiceContract testSC = TestUtil.createServiceContracts(1, true)[0];
        //TestUtil.createContractLineItems(testSC.id, 1, true);
        ApexPages.currentPage().getParameters().put('id', testQuoteSC.id);
        ApexPages.StandardController stdController = new ApexPages.StandardController(testQuote);
        ServiceContracts360Controller objController = new ServiceContracts360Controller(stdController);
        ServiceContracts360Controller objController1 = new ServiceContracts360Controller();
        objController.getId();
        objController.getSc();
    }
}