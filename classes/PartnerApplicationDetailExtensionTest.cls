@isTest(seeAllData=true)
private class PartnerApplicationDetailExtensionTest {
    static testMethod void myUnitTest() {
    	Test.startTest();
    	Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	User testUser;
    	Test.stopTest();
    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);    	
	    testUser.ContactId = testContact.id;
	    insert testUser;
    	System.runAs(testUser){
	    	Partner_Application__c pa = new Partner_Application__c();
	    	pa.Company_Name__c = 'Test Company';
	    	pa.Account__c = testAccount.id;
	    	pa.Contact__c = testContact.id;
            pa.AnnualSalesRevenue_PL__c = 'No';
            pa.Ownership_PL__c = 'No';
            pa.RightToAppointOrDismiss_PL__c = 'No';
            pa.AppointOrDismissMD_PL__c = 'No';
            pa.Government_Veto_PL__c = 'No';
            pa.PublicInternationalOrg_PL__c = 'No';
            pa.Convicted_Executive_PL__c = 'No';
            pa.BannedEmployee_PL__c = 'No';
            pa.ExportEnforcementActivity_PL__c = 'No';
            pa.CountryCurrentlyUnderUS_PL__c = 'No';
            pa.Conflict_of_Interest_PL__c = 'No';
            pa.Current_or_Former_Genesys_Employee_PL__c = 'No';
	    	insert pa;
			PageReference pageRef = Page.Partner_ApplicationDetail;
			Test.setCurrentPage(pageRef);	
	    	ApexPages.currentPage().getParameters().put('id', pa.id);
	    	PartnerApplicationDetailExtension obj = new PartnerApplicationDetailExtension(new ApexPages.StandardController(new Partner_Application__c()));
	    	obj.goToTBusinessTerms();
            try {
  				insert new Account();
            }   catch (Exception ex) {
                obj.callException(ex);
            }
      
                    
            
    	}
    }
    
    static testMethod void myUnitTest1(){
    	Test.StartTest();
		PartnerAppAutoCancellationBatchSchedular.scheduleMe();
		//System.execute(sh1); 
		Test.stopTest(); 
    }
}