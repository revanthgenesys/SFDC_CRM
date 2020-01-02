@isTest
public class PartnerPortalWelcomeVideoController_Test {
	
	static testMethod void testFlagUpdate() {
		
		TestUtil.setConfigValues();
        List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
    	Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	User testUser;

    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);    	
	    testUser.ContactId = testContact.id;
	    insert testUser;
	    
	    Test.startTest();       
     	 System.runAs(testUser) {

			PartnerPortalWelcomeVideoController cntr = new PartnerPortalWelcomeVideoController();
			cntr.updateUser();			
     	}
     	Test.stopTest();
     	
     	User usr = [SELECT Block_Partner_Welcome_Video__c FROM User WHERE Id = :testUser.Id];
			
	    System.assertEquals(usr.Block_Partner_Welcome_Video__c, true) ;   
        	     	
	}

}