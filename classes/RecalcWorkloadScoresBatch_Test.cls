/*
	Naresh Kumar	06/17/2013
	Test class for the main controller class CaseDetailController.
*/
@isTest(seeAllData = true)
private class RecalcWorkloadScoresBatch_Test {
    static testMethod void myUnitTest() {
    	Test.StartTest();
    	User testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', null, true);
        RecalcWorkloadScoresBatch objController = new RecalcWorkloadScoresBatch('SELECT id FROM User LIMIT 10');// WHERE id = \' ' + testUser.id + '  \' ');
        Database.executeBatch(objController);
        Test.StopTest();
    }
}