@isTest(seeAllData=true)
private class QuoteInfoDisplayController_Test {
    static testMethod void myUnitTest() {
    	Order__c testOrder = TestUtil.createOrders(1, true)[0];
    	ApexPages.StandardController stdController = new ApexPages.StandardController(testOrder);
    	QuoteInfoDisplayController objController = new QuoteInfoDisplayController(stdController);
    	objController.getFields_Quote();
    	objController.getFields_Quote_SalesInfo();
    	//objController.Query_QuoteInfo_Fieldset();
    	//objController.Query_OrderInfo_Fieldset();    	
    }
    static testMethod void myUnitTest1() {
    	Order__c testOrder = TestUtil.createOrders(1, null, null, true)[0];
    	ApexPages.StandardController stdController = new ApexPages.StandardController(testOrder);
    	QuoteInfoDisplayController objController = new QuoteInfoDisplayController(stdController);
    	objController.getFields_Quote();
    	objController.getFields_Quote_SalesInfo();
    	//objController.Query_QuoteInfo_Fieldset();
    	//objController.Query_OrderInfo_Fieldset();    	
    }
}