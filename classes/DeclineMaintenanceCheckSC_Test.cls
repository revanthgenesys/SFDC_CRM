/*
	04/25/2013	Naresh Kumar
	Test Class for the controller class DeclineMaintenanceCheckSC
*/
@isTest (seeAllData = true)
private class DeclineMaintenanceCheckSC_Test {

    static testMethod void myUnitTest1() {
        ServiceContract testSC = TestUtil.createServiceContracts(1, true)[0];
        ApexPages.StandardController controller = new ApexPages.StandardController(testSC);
        DeclineMaintenanceCheckSC objController = new DeclineMaintenanceCheckSC(controller);
    }
    static testMethod void myUnitTest2() {
        ServiceContract testSC = TestUtil.createServiceContracts(1, false)[0];
        testSC.Agreement_Status__c = 'Declined';
        insert testSC;
        ApexPages.StandardController controller = new ApexPages.StandardController(testSC);
        DeclineMaintenanceCheckSC objController = new DeclineMaintenanceCheckSC(controller);
    }
}