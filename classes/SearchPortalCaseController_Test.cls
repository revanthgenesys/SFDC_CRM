/*
	Naresh Kumar	06/15/2013
	Test class for the main extension class SearchPortalCaseController.
*/
@isTest(seeAllData = true)
private class SearchPortalCaseController_Test {

    static testMethod void myUnitTest() {
        SearchPortalCaseController objController = new SearchPortalCaseController();
        objController.searchCases();
    }
}