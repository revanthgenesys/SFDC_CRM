/*
	Naresh Kumar	06/14/2013
	Test class for the main controller class CaseDetailController.
*/
@isTest(seeAllData = true)
private class PortalViewCaseController_Test {

    static testMethod void myUnitTest() {
    	Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	User testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);    	
    	testUser.ContactId = testContact.id;
    	insert testUser;
    	System.runAs(testUser){
	        PortalViewCaseController objController = new PortalViewCaseController();
	        objController.myCases = 'MyClosed';
	        objController.getHomePageCases();
	        objController.gtMyCases();
	        PortalViewCaseController.gtEnDUsr();
	        objController.getEUsrList();
	        PortalViewCaseController.gtConId();
	        PortalViewCaseController.gtSoldTo();
	        PortalViewCaseController.getCloudDeplClause();
	        objController.getItems();
	        objController.getCases();
	        objController.lazyLoad();	        
    	}
    }
}