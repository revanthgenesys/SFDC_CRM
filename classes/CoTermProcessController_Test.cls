@isTest(seeAllData = true)
private class CoTermProcessController_Test {
    static testMethod void myUnitTest() {
    	Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
    	CoTermProcessController obController = new CoTermProcessController(stdController);
    	obController.getSortDirection();
    	obController.findRelatedRecords();
    	obController.getselectedWrappers();
    	obController.submit();
    	obController.cancel();
    	obController.includeOpps();
    	obController.selectAll();
    	obController.removeCoTermedScs();
    }
}