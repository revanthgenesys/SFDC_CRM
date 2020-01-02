/*
	Naresh Kumar	06/14/2013
	Test class for the main controller class CaseDetailController.
*/
@isTest(seeAllData = true)
private class EnableCustomerPortal_Test {

    static testMethod void myUnitTest() {
    	Test.startTest();
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, false)[0];
        testContact.Email = 'testEmailUnique@tgest.com';
        insert testContact;
        Test.stopTest();
        //Support_Access__c testSA = TestUtil.createSupportAccess(1, true, testContact)[0];
    }
}