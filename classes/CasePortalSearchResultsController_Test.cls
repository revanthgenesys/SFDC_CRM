@isTest
public class CasePortalSearchResultsController_Test {
	static Contact testContact;
	static User testUser;
	static Case cs1, cs2;
	static Account testAccount;
	static Support_Product__c prod;
	static Cloud_Deployment__c depl;
	
	static void setUpdata() {
	  TestUtil.setConfigValues();
    	 List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
        System.runAs(runAsUser[0]) {
            TestUtil.setCaseSupportTypesSettings();
        }
		
		Util.Bypass_Trigger_Chk = true;
		Profile prfl = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	testAccount = TestUtil.createAccounts(1, true)[0];
    	testContact = TestUtil.createContacts(1, testAccount, true)[0];
   
        depl = new Cloud_Deployment__c();
		depl.Support_Status__c = 'Active';
	   	depl.Account__c = testAccount.id;
	   	depl.Sold_To_Account__c = testAccount.id;
	   	depl.Cloud_Platform__c = 'Premier Edition';
        insert depl;
        
        Support_Access_Cloud__c sa = new Support_Access_Cloud__c (Contact__c = testContact.Id, Cloud_Deployment__c = depl.Id, Access_Status__c = 'Active', Access_Level__c = 'Read/Write');
        insert sa;
        
         Back_Office_Account__c boa = new Back_Office_Account__c();
	    boa.Sold_To_Account__c = testAccount.Id;
	    boa.End_User_Account__c = testAccount.Id;
	    insert boa;
	    boa.Contract_Status__c = 'Active';
	    update boa;

        Support_Access__c sap = new Support_Access__c(Back_Office_Account__c = boa.Id, SR_Access_Level__c = 'Read/Write',
                                                      Status__c = 'Active', Contact__c = testContact.id, Sold_To_Account__c = testAccount.Id,
                                                      End_User_Account__c = testAccount.Id);
        insert sap;
        
    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prfl.id, false);    	
    	testUser.ContactId = testContact.id;
    	insert testUser;
    	
        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];
        cs1 = new Case(subject='test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rectp[0].id);                        
        insert cs1;
        cs1.Cloud_Deployment__c = depl.Id;
        update cs1;
         cs2 = new Case(subject='test', priority = '4-Low',  ContactId = testContact.Id, recordtypeid = rectp[0].id);                        
        insert cs2;
        cs2.Cloud_Deployment__c = depl.Id;
        update cs2;
    	
	}
	
	static testMethod void searchTst() {
		setUpdata();
		Test.startTest(); 
        System.runAs(testUser) {
			  Apexpages.currentPage().getParameters().put('inp','test');

		      CasePortalSearchResultsController contr = new CasePortalSearchResultsController();
		      contr.sortDir = 'desc';
		      
		      contr.sortField = 'casenum';
		      contr.sortCases();
		      
		      contr.sortField = 'eu';
		      contr.sortCases();
		      contr.sortField = 'prior';
		      contr.sortCases();
		      contr.sortField = 'stat';
		      contr.sortCases();
		      contr.sortField = 'st';
		      contr.sortCases();
		      contr.sortField = 'prod';
		      contr.sortCases();
		      contr.sortField = 'dpl';
		      contr.sortCases();
		      
		      contr.sortField = 'cldsrv';
		      contr.sortCases();
		      contr.sortField = 'cont';
		      contr.sortCases();
        }
        Test.stopTest(); 	
	}	

}