@isTest
public class CaseService_Test {
	
	static testMethod void newCase() {
		List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Support_Request'];
        
        String recId = (String) rectp[0].Id;
        Test.startTest();    
        Case cs1 = new CaseService.caseInstance(recId).cs;        
        Case cs2 = new CaseService.caseInstanceRecTypeUpd('toPremise', recId).cs;       
        Case cs3 = new CaseService.caseInstanceRecTypeUpd('toCloud', recId).cs;
        Test.stopTest();   
	}
	
	static testMethod void newCasePortal() {
        TestUtil.setConfigValues();
    	 List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
        System.runAs(runAsUser[0]) {
            TestUtil.setCaseSupportTypesSettings();
        }
		
		Profile prfl = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1]; 
		Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];  	   	
    	User testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prfl.id, false);    	
    	testUser.ContactId = testContact.id;
    	insert testUser;
        
        List<RecordType> rectp = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Cloud_Support_Request'];
               
        String recId = (String) rectp[0].Id;
        Test.startTest();    
    	System.runAs(testUser) {
	        Case cs1 = new CaseService.caseInstance(recId).cs;
	        
	        Case cs2 = new CaseService.caseInstanceRecTypeUpd('toPremise', recId).cs;
    	}
    	Test.stopTest();   
	}
}