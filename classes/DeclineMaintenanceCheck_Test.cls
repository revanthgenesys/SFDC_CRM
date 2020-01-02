/*
	04/25/2013	Naresh Kumar
	Test Class for the controller class DeclineMaintenanceCheck
*/
@isTest (seeAllData = true)
private class DeclineMaintenanceCheck_Test {
    static testMethod void myTestMethod1() {
    	Order__c testOrder = TestUtil.createOrders(1, true)[0];
        ApexPages.StandardController controller = new ApexPages.StandardController(testOrder);
        DeclineMaintenanceCheck objController = new DeclineMaintenanceCheck(controller);
    }
    static testMethod void myTestMethod2() {
    	Order__c testOrder = TestUtil.createOrders(1, false)[0];
    	testOrder.Decline_Maintenance__c = true;
    	insert testOrder;
        ApexPages.StandardController controller = new ApexPages.StandardController(testOrder);
        DeclineMaintenanceCheck objController = new DeclineMaintenanceCheck(controller);
    }
}