@isTest(seeAllData=true)
private class Show_Quote_Order_Info_Test {
	static testMethod void myUnitTest() {
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, true)[0];
        Order__c testOrder = TestUtil.createOrders(1, testQuote.id, testOpp.id, false)[0];
        testOrder.License_FYM_detail__c = 'Maintenance Only Order';
        insert testOrder;
        ApexPages.StandardController stdController = new ApexPages.StandardController(testQuote);
        Show_Quote_Order_Info objController = new Show_Quote_Order_Info(stdController);
    }
}