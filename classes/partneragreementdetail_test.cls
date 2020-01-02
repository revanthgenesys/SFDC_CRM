@isTest(seeAllData=true)
public class partneragreementdetail_test {
   static testMethod void myUnitTest() {
    	Test.startTest();
    	Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];    	
    	Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
    	User testUser;
    	
    	testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);    	
	    testUser.ContactId = testContact.id;
	    insert testUser;
    	System.runAs(testUser){
	    	Partner_Application__c pa = new Partner_Application__c(Company_Name__c = 'Test Company',Account__c = testAccount.id,Contact__c = testContact.id,AnnualSalesRevenue_PL__c = 'No',Ownership_PL__c = 'No');
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
			PageReference pageRef = Page.partneragreement;
			Test.setCurrentPage(pageRef);	
	ID applicationid=ApexPages.currentPage().getParameters().put('appid', pa.id);
    ID accountId =  ApexPages.currentPage().getParameters().put('accid', testAccount.id);
     ID contactId = ApexPages.currentPage().getParameters().put('conid', testContact.id);
	       partneragreementdetail obj=new partneragreementdetail();
       Test.stopTest();
    	}
    }
}