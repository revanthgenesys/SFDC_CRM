@isTest(seeAllData=true)
private class DynamicListController_Test {
    static testMethod void myUnitTest() {
    	DynamicListController objController = new DynamicListController('SELECT id FROM Case');
    	/*
    	objController.nameSearchFld = 'test';
    	objController.search();
    	objController.sort();
    	//objController.getRecords();
    	objController.first();
    	objController.previous();
    	objController.next();
    	objController.last();
    	objController.getHasPrevious();
    	objController.getHasNext();
    	objController.getResultSize();
    	objController.getPageNumber();
    	objController.getPageCount();
    	objController.getRenderResults();
    	objController.save();
    	objController.cancel();
    	*/
    }
}