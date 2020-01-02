/*
	04/25/2013	Naresh Kumar
	Test Class to test main class OpportunityCloneController
*/
@isTest (seeAllData = true)
private class OpportunityCloneController_Test {
    static testMethod void myTestMethod() {
    	Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
    	ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        OpportunityCloneController objController = new OpportunityCloneController(stdController);
        objController.submit();
    }
}