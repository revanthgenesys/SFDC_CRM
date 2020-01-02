@isTest(seeAllData=true)
private class PartnerPortalLandingControllerTest {

    static testMethod void myUnitTest() {
    	Test.startTest();
    	Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	//User testUser1 = [SELECT id FROM User WHERE IsActive =: true AND profile.Name =: partnerProfile.id LIMIT 1];    	
    	User testUser;
    	Test.stopTest();
    	//System.runAs(testUser1){
	    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);    	
	    	testUser.ContactId = testContact.id;
	    	insert testUser;
    	//} 
 		System.runAs(testUser){
	        PartnerPortalLandingController obj = new PartnerPortalLandingController();
	        obj.forwardToPartnerPortalStart();
 		}
    }
}