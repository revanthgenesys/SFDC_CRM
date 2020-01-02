/*
	Naresh Kumar	06/17/2013
	Test class for the main controller class MergeGroupAccountContacts.
*/
@isTest(seeAllData = true)
private class MergeGroupAccountContacts_Test {
    static testMethod void myUnitTest() {
    	RecordType rType = [SELECT id, Name FROM RecordType WHERE Name = 'Group Account - Customer' LIMIT 1];
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Account testAccount1 = TestUtil.createAccounts(1, false)[0];
    	testAccount1.RecordTypeId = rType.id;
    	testAccount1.Name = 'Test Group Account';
    	testAccount1.Status__c = 'Active';
    	insert testAccount1;
    	List<Contact> testContact = TestUtil.createContacts(2, testAccount, false);
    	testContact[0].Group_Account_Lookup__c = testAccount1.id;
    	testContact[1].Group_Account_Lookup__c = testAccount1.id;    	
    	insert testContact;
    	MergeGroupAccountContacts testController = new MergeGroupAccountContacts();
    	testController.source = testContact[0];
    	testController.target = testContact[1];
    	TestController.updateContacts();
    	Contact testContact1 = TestUtil.createContacts(1, testAccount1, true)[0];
    	testController.updateContacts();
    	testController.back();
    }
}