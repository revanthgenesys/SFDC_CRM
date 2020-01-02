@isTest(seeAllData=true)
private class Related_Fields_Class_Test {

    static testMethod void myUnitTest() {
    	Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
    	ServiceContract testSC = TestUtil.createServiceContracts(1, false)[0];
    	BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];
    	testSC.Renewal_Opportunity__c = testOpp.id;
    	testSC.Quote_Name__c = testQuote.id;
    	insert testSC;
    	
        ApexPages.StandardController stdController = new ApexPages.StandardController(testSC);
        Related_Fields_Class objController = new Related_Fields_Class(stdController);
    }
}