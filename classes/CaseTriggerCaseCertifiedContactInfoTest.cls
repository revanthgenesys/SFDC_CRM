@isTest
private  class CaseTriggerCaseCertifiedContactInfoTest {
	@isTest(SeeAllData=true)
    static void TestCasesClosedByDefaultController(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        List<Partner_Certifications__c > partnerCerts = [SELECT id, ViewCentral_Contact_ID__c, Test_Date__c, Expiry_Date__c 
                                                         FROM Partner_Certifications__c WHERE Expiry_Date__c  > TODAY LIMIT 2];
        
        Profile p = [Select Id from Profile where name = 'Genesys Portal End User'];
        // Recordtype accountRT = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
		String accountRecordTypeId = Account.SObjectType.getDescribe().getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
	
        //Create account
        Account testAccount = new Account (Name = 'Holding Account', RecordTypeId=accountRecordTypeId,Status__c='Active'); 
        insert testAccount;
        
        //Create contact
        Contact testContact = new Contact(FirstName = 'Rao', Lastname = 'Tumma', AccountId = testAccount.Id, HomePhone = '1236547890', MobilePhone = '9012345678',
                                MailingStreet = 'xyz', MailingCity = 'CA', MailingState = 'calfornia', MailingPostalCode = '654321', MailingCountry = 'USA',
                                Designated_Partner_Contact__c=true,  Email='raotest@test.com', ViewCentral_ID__c = '54321');
        insert testContact;

		// Create User        
        User testUser = new User( ProfileId = p.Id, Username = 'raotest@test.com', Alias = 'Test1', Email='raotest@test.com', EmailEncodingKey='UTF-8', Firstname='Rao', Lastname='Tumma', 
                            LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', ContactId = testContact.id );
        insert testUser;
        
        
		Partner_Certifications__c testCert = new Partner_Certifications__c(Account__c = testAccount.Id, Account_Name__c = testAccount.Name, Country_Code__c = 'USA',
												Test_Date__c = Date.Today().addDays(-90), Expiry_Date__c = Date.Today().addDays(90), First_Name__c = testContact.FirstName,
												Last_Name__c = testContact.LastName, Email__c = testContact.Email, Test_Name__c = 'TESTCODE', Test_Code__c = 'TESTCODE',
												Genesys_Test_Code__c = 'TESTCODE', Legacy__c = true, Pass_Fail__c = 'Pass', 
												ViewCentral_Contact_ID__c = '54321', ViewCentral_ID__c = '54321', Voucher_Code__c = 'VOC');
        insert testCert;
        
        String supportCaseRecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Support').getRecordTypeId();
        // Creare Case
        Case testCase = new Case(Subject='test', Priority = '4-Low', ContactId = testContact.Id, RecordTypeId=supportCaseRecordTypeId);
        insert testCase;
    }
}