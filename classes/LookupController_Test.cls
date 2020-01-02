/*
	Naresh Kumar	06/17/2013
	Test class for the main controller class LookupController.
*/
@isTest(seeAllData = true)
private class LookupController_Test {

    static testMethod void myUnitTest() {
    	Apexpages.currentPage().getParameters().put('searchText','test');
    	Apexpages.currentPage().getParameters().put('op', '003');
    	Apexpages.currentPage().getParameters().put('fields','Id,Email');
    	Apexpages.currentPage().getParameters().put('role','');
    	Apexpages.currentPage().getParameters().put('query','');
    	LookupController objController = new LookupController();
    	Set<SObject> setRecords = objController.objects;
    }
}