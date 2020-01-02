/*
	Naresh Kumar	06/14/2013
	Test Class for the main class AssignCasesController
 */
@isTest(seeAllData = true)
private class AssignCasesController_Test {

    static testMethod void myUnitTest() {
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Project_Management__c testPM = new Project_Management__c();
    	testPM.End_User_Account__c = testAccount.id;
    	insert testPM;
    	Release_Phase__c rPhase = new Release_Phase__c();
    	rPhase.Project_Management__c = testPM.id;
    	insert rPhase;
    	List<Case> testCase = TestUtil.createCases(2, false);
    	testCase[0].Release_Phase__c = null;
    	testCase[0].Status = 'Open';
    	testCase[0].AccountId = testAccount.id;
    	testCase[1].End_User_Account__c = testAccount.id;
    	testCase[1].Parent_Escalation__c = null;
    	testCase[1].Status = 'Open';
    	insert testCase;
    	Apexpages.currentPage().getParameters().put('rphaseId', rPhase.id);
    	Apexpages.currentPage().getParameters().put('caId', testCase[0].id);
    	Apexpages.currentPage().getParameters().put('enUA', testAccount.id);
        AssignCasesController objController = new AssignCasesController();
        objController.cancel();
        objController.cases[0].isSelected = true;
        objController.assignCases();
    }
}