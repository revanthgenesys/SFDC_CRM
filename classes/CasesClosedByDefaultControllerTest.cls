@isTest
private class CasesClosedByDefaultControllerTest {
	@isTest(SeeAllData=true)
    static void TestCasesClosedByDefaultController(){
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile p = [Select Id from Profile where name = 'Genesys Portal End User'];
        recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];

        //Create account
        Account a = new Account (Name = 'Holding Account',RecordTypeId=rc.id,Status__c='Active'); 
        insert a;
        
        //Create contact
        Contact c = new Contact(FirstName = 'Rao', Lastname = 'Tumma', AccountId = a.Id, HomePhone = '1236547890', MobilePhone = '9012345678',
                                MailingStreet = 'xyz', MailingCity = 'CA', MailingState = 'calfornia', MailingPostalCode = '654321', MailingCountry = 'USA',
                                Designated_Partner_Contact__c=true,  Email='raotest@test.com');
        insert c;
        
        User u = new User( ProfileId = p.Id, Username = 'raotest@test.com', Alias = 'Test1', Email='raotest@test.com', EmailEncodingKey='UTF-8', Firstname='Rao', Lastname='Tumma', 
                            LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', ContactId = c.id );
        insert u;

        Test.setCurrentPageReference(Page.CasesClosedByDefaultDetails);
        System.currentPageReference().getParameters().put('period', 'Feb/Mar/Apr 2016');
        System.currentPageReference().getParameters().put('aId', a.Id);
        CasesClosedByDefaultController ccbdController = new CasesClosedByDefaultController();
        ccbdController.CCBDDetails.add(new CasesClosedByDefaultController.CCBDDetail('0000000001', 'Rao Tumma', 'Narasimha Tumma'));
        
    }
}