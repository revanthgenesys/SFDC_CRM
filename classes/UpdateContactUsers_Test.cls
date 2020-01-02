/*
	Naresh Kumar	06/15/2013
	Test class for the main controller class UpdateContactUsers.
*/
@isTest(seeAllData = true)
private class UpdateContactUsers_Test {
    static testMethod void myUnitTest() {
    	Account testAccount = TestUtil.createAccounts(1, false)[0];
    	testAccount.Partner_Program_Status__c = 'Active';
    	insert testAccount;
    	
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];
    	User testUser1 = [SELECT id FROM User WHERE Profile.Name LIKE '%System Admin%' AND isActive = true LIMIT 1];
    	User testUser;
    	System.runAs(testUser1){
	    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);    	
	    	testUser.ContactId = testContact.id;
	    	insert testUser;
    	}
    	/*
    	Test.startTest();
    	System.runAs(testUser){
	    	testAccount.Partner_Program_Status__c = 'InActive';
	    	update testAccount;
    	}
    	Test.stopTest();
    	*/
    }    
}