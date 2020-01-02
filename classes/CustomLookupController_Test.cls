/*
	Naresh Kumar	06/14/2013
	Test class for the main extension class CustomLookupController.
*/
@isTest
public class CustomLookupController_Test {
	static testMethod void myUnitTest() {
		
		 Util.Bypass_Trigger_Chk = true;
       
	    Profile prof = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
	    Account accnt = TestUtil.createAccounts(1, true)[0];
	    Contact testContact = TestUtil.createContacts(1, accnt, true)[0];
	    	
	    User testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prof.id, false);    	
		testUser.ContactId = testContact.id;
		insert testUser;

	    Cloud_Deployment__c cldDep = new Cloud_Deployment__c(Name = 'Test2', Account__c = accnt.id, Status__c = 'Production',
	                                                             Support_Status__c = 'Active', Sold_To_Account__c = accnt.id);
	    insert cldDep;
	        
        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = testContact.id, Cloud_Deployment__c = cldDep.Id,
                                          Access_Status__c = 'Active', Access_Level__c = 'Read/Write');
        insert sa;
         
        Back_Office_Account__c boa = new Back_Office_Account__c();
			boa.Sold_To_Account__c = accnt.Id;
			boa.End_User_Account__c = accnt.Id;
			insert boa;
			
	    List<Support_Access__c> saLst = new List<Support_Access__c>();
		Support_Access__c pr = new Support_Access__c(Back_Office_Account__c = boa.Id,
			                                             Contact__c = testContact.id,
			                                 Status__c = 'Active', SR_Access_Level__c = 'Read/Write');
			                                             
		insert pr;   

        Apexpages.currentPage().getParameters().put('obj','Contact');
		Apexpages.currentPage().getParameters().put('contactId', testContact.Id);
		Apexpages.currentPage().getParameters().put('type','test');
		Apexpages.currentPage().getParameters().put('searchText','test');
		
		CustomLookupController objController4 = new CustomLookupController();
		objController4.searchOnlyEmployeeContacts = true;				
		objController4.go();

		Apexpages.currentPage().getParameters().put('obj','Contact');
		Apexpages.currentPage().getParameters().put('contactId', testContact.Id);
		Apexpages.currentPage().getParameters().put('type','test');
		Apexpages.currentPage().getParameters().put('searchText','test');
		Apexpages.currentPage().getParameters().put('dplId', cldDep.Id);
		Apexpages.currentPage().getParameters().put('cloudContacts', '1');
		
		CustomLookupController objController = new CustomLookupController();
		objController.searchOnlyEmployeeContacts = true;				
		objController.go();
		
	    Apexpages.currentPage().getParameters().put('obj','Contact');
	    Apexpages.currentPage().getParameters().put('contactId', testContact.Id);
		Apexpages.currentPage().getParameters().put('type','test');
		Apexpages.currentPage().getParameters().put('searchText','test');
		Apexpages.currentPage().getParameters().put('contactsOnly', '1');
		Apexpages.currentPage().getParameters().put('endUserId', accnt.Id); 
		Apexpages.currentPage().getParameters().put('soldToId', accnt.Id);
		
		CustomLookupController objController1 = new CustomLookupController();
		objController1.searchOnlyEmployeeContacts = false;		
		objController1.go();
		
		objController1.obj = 'CloudDepl';
		objController1.go();
			
		Apexpages.currentPage().getParameters().put('obj','Account');
		Apexpages.currentPage().getParameters().put('type','test');
		Apexpages.currentPage().getParameters().put('searchText','test');
		Apexpages.currentPage().getParameters().put('contactsOnly', '1');

		CustomLookupController objController2 = new CustomLookupController();
		objController2.searchOnlyEmployeeContacts = false;		
		objController2.go();
		
		

	}
}