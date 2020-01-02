@isTest(seeAllData = true)
public with sharing class SWDLPortalCustomerHistoryController_Test {
	
	static testMethod void testSwdlHistory() {
	   
        List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
        System.runAs(runAsUser[0]) {
            //TestUtil.setConfigValues();
            //TestUtil.setCaseSupportTypesSettings();
        }              
        Id profileId = [Select Id from profile where name LIKE 'Genesys Portal End User%' LIMIT 1].Id;      
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	User usr = TestCommon.createUser('testU', 'testUser55@test55.com.test', 'Test1', 'Test1', profileId, false);    	
    	usr.ContactId = testContact.Id;
    	insert usr;
    	
    	Support_Access__c supaccs = TestUtil.createSupportAccess(1, true, testContact)[0];
        supaccs.End_User_Account__c = testAccount.Id;
        supaccs.Sold_To_Account__c = testAccount.Id;
        update supaccs;
        
       System.runAs(usr){
				
            Pagereference pg = Page.SWDLPortalCustomerHistoryPage;  
            Test.setCurrentPageReference(pg);  
                
           SWDLPortalCustomerHistoryController hc = new SWDLPortalCustomerHistoryController();		
           hc.getHistory();
           hc.first();
           hc.last();
           hc.next();
           hc.previous();
           hc.getResultSize();
           hc.toggleSort();
       } 
	}   	    
}