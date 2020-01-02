/*
	Naresh Kumar	06/14/2013
	Test class for the main extension class CaseUpdateRelatedListController.
*/
@isTest(seeAllData = true)
private class CaseUpdateRelatedListController_Test {

    static testMethod void myUnitTest() {
        Case testCase = TestUtil.createCases(1, true)[0];
        ApexPages.currentPage().getParameters().put('caseId', testCase.id);        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        CaseUpdateRelatedListController objExtension = new CaseUpdateRelatedListController(stdController);
        objExtension.deleteCaseUpdate();
    }
}