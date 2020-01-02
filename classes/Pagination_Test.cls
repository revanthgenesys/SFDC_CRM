@isTest(seeAllData = true)
private class Pagination_Test {
    static testMethod void myUnitTest() {
        Pagination objController = new Pagination('SELECT id FROM Account limit 100', 10);
        objController.first();
        objController.last();
        objController.previous();
        objController.next();        
    }
}