@isTest
public class CaseSelectRecordTypePortal_Test {
	
	static testMethod void tst() {
		Util.Bypass_Trigger_Chk = true; 
		Profile prfl = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	
       Back_Office_Account__c boa = new Back_Office_Account__c();
	    boa.Sold_To_Account__c = testAccount.Id;
	    boa.End_User_Account__c = testAccount.Id;
	    insert boa;

        Support_Access__c sa = new Support_Access__c(Back_Office_Account__c = boa.Id, SR_Access_Level__c = 'Read/Write',
                                                      Status__c = 'Active', Contact__c = testContact.id);
        insert sa;
    	
    	User testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', prfl.id, false);    	
    	testUser.ContactId = testContact.id;
    	insert testUser;
    	
    	Test.startTest();    
    	System.runAs(testUser) {
		
			ApexPages.currentPage().getParameters().put('mode','new');
	        ApexPages.currentPage().getParameters().put('cstp', 'sprt'); 
	        
			CaseSelectRecordTypePortal cntr = new CaseSelectRecordTypePortal();
			cntr.autoRedirect();
			
			cntr.premSupportType();
			cntr.premFRType(); 
			cntr.cloudSupportType();
			cntr.cloudServiceType();
			cntr.cloudFRType();
			cntr.adminType();
			cntr.viewSupportType(); 
			cntr.viewCloudTypes(); 
			cntr.viewAdmin();
			cntr.viewPremFRType();
			cntr.viewCloudFRType();	
			
			ApexPages.currentPage().getParameters().put('mode','mng');
	        ApexPages.currentPage().getParameters().put('cstp', 'sprt');
	        CaseSelectRecordTypePortal cntr1 = new CaseSelectRecordTypePortal();
			cntr1.autoRedirect();
			
			ApexPages.currentPage().getParameters().put('mode','mng');
	        ApexPages.currentPage().getParameters().put('cstp', 'fr');
	        CaseSelectRecordTypePortal cntr2 = new CaseSelectRecordTypePortal();
			cntr2.autoRedirect();
        
    	}
    	Test.stopTest();  	
	}
}