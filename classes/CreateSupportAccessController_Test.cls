/*
	Naresh Kumar	06/14/2013
	Test class for the main extension class CreateSupportAccessController.
*/
@isTest(seeAllData = true)
private class CreateSupportAccessController_Test {
    static testMethod void myUnitTest() {
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	CreateSupportAccessController objController = new CreateSupportAccessController();    	
    	objController.showInactive = false;    	
    	objController.existingContact = testContact;
    	objController.findAccessRecords();
    	objController.createAccessRecords();
    	objController.done();
    }
}