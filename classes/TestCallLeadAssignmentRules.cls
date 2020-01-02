@isTest(seeAllData=true)
private class TestCallLeadAssignmentRules {

    static testMethod void testPositiveConditionSingle() {
        /* This code will create one new instance of a lead and set Call_Lead_Assignment__c
        to TRUE in order to test it's functionality.  It references the lead assignment for
        Jeff Saraiva
        
        By: eba
        */
        
        // Used these to instantiate a temp User to avoid dependency on User metadata
        String uUserName = 'test896'+ Math.random().format()+'@genesys.com';
        String uLastname = 'test';
        String uEmail = 'test@genesys.com';
        String uAlias = 'TTT';
        String uCommunityNickname = 'test.test';
        String uTimeZoneSidKey = 'America/Los_Angeles';
        String uLocaleSidKey = 'en_US';
        String uEmailEncodingKey = 'ISO-8859-1';
        String uProfileID = '00eU0000000dWZrIAM';
        String uLanguageLocaleKey = 'en_US';
        
        // temp user instantiation
        User u1 = new User(
        Username = uUserName, 
		LastName = uLastName, 
		Email = uEmail, 
		Alias = uAlias, 
		CommunityNickname = uCommunityNickname, 
		TimeZoneSidKey = uTimeZoneSidKey, 
		LocaleSidKey = uLocaleSidKey, 
		EmailEncodingKey = uEmailEncodingKey, 
		ProfileId = uProfileId,
		EmployeeNumber = 'EMP-'+ Math.random().format(), 
		LanguageLocaleKey = uLanguageLocaleKey);
		
		// running as the temp user
        System.RunAs(u1){
        
            // Assigning values to variables for test
            String leadFirstName = 'Cliff';
            String leadLastName = 'Edddd';
            String leadCompanyName = 'Gengened';
            String leadCountry = 'a06U0000000ugb6IAA';
        
            // Grabbing OwnerID for Jeff Saraiva User
            User correctUser = [SELECT Id FROM User WHERE Alias ='JSA' AND IsActive=TRUE LIMIT 1];
        
            // Creating the test lead with above values as the lead info
            Lead leadTest = new Lead(
            firstname = leadFirstName,
            lastname = leadLastName,
            company = leadCompanyName,
            country__c = leadCountry
            );
        
            insert leadTest;
            
            // Declaring a lead with the original OwnerID for a negative validation.
            Lead mismatchCompare = [SELECT OwnerId, Country__c FROM Lead WHERE Id = :leadTest.Id];
        	
            // test; good practice to use the 'test block' to test governor limits (in case of bulk)
            Test.startTest();
            leadTest.Call_Lead_Assignment__c = True;
            update leadTest;
            Test.stopTest();
        
            // Declaring a lead with the OwnerID we want to compare.
            Lead compareLead = [SELECT OwnerId, Country__c FROM Lead WHERE Id = :leadTest.Id];
        	
        	/* Used this to eyeball results as well.  Instead of trusting the
        	test blindly. */
        	System.debug(mismatchCompare.OwnerId);
        	System.debug(compareLead.OwnerId);
        	System.debug(correctUser.Id);
        	
            //System.assertEquals(correctUser.Id, compareLead.OwnerId);
            //System.assertNotEquals(correctUser.Id, mismatchCompare.OwnerId);
        }
    }
}