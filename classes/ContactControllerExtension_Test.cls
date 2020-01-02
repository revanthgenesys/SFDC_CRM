/*
	Naresh Kumar	06/14/2013
	Test class for the main extension class ContactControllerExtension.
*/
@isTest
private class ContactControllerExtension_Test {

    static testMethod void myUnitTest() {
    	Util.Bypass_Trigger_Chk = true;
    	
		Profile prfl = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	
    	User testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prfl.id, false);    	
    	testUser.ContactId = testContact.id;
    	insert testUser;
    	
    	System.runAs(testUser){
        	ContactControllerExtension objExtension = new ContactControllerExtension();
        	objExtension.getContact();
        	objExtension.Cancel();
        	objExtension.manageSub();
        	objExtension.getUser();
        	objExtension.UpdateContactInfo();
        	objExtension.email = 'test12323423@test.com';
        	objExtension.UpdateContactInfo();
        	objExtension.firstName  = '';
        	objExtension.UpdateContactInfo();
        	objExtension.lastname = '';
        	objExtension.UpdateContactInfo();
        	objExtension.email = '';
        	objExtension.UpdateContactInfo();
        	objExtension.emplName = '';
        	objExtension.UpdateContactInfo();
        	
        	ContactControllerExtension objExtension2 = new ContactControllerExtension();
        	objExtension2.firstName  = 'Frst';
        	objExtension2.lastname = 'Last';
        	objExtension2.email = 'test12323423@test.com';
        	objExtension2.emplName = 'Empl';
        	objExtension2.UpdateContactInfo();
    	}

    }
   
}