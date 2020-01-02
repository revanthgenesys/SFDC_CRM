@istest(seealldata=true)
public class PartnerRebateTriggerTest{
        
    public static testmethod void Method1(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile profile1 = [Select Id from Profile where name = 'Genesys Portal End User'];
        recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
        //Create account
        Account portalAccount1 = new Account();
        portalAccount1.Name = 'TestAccount';
        portalAccount1.RecordTypeId = rc.id;
        //portalAccount1.OwnerId = portalAccountOwner1.Id;        
        insert portalAccount1;
        
        //Create contact
        Contact contact1 = new Contact( );
        contact1.FirstName = 'Test6';
        contact1.Lastname = 'Test7';        
        contact1.AccountId = portalAccount1.Id;        
        contact1.HomePhone = '1236547890';
        contact1.MobilePhone = '9012345678';
        contact1.MailingStreet = 'xyz';
        contact1.MailingCity = 'CA';
        contact1.MailingState = 'calfornia';
        contact1.MailingPostalCode = '654321';
        contact1.Designated_Partner_Contact__c=true;
        contact1.MailingCountry = 'USA';     
        contact1.Email='test@test.com';      
        insert contact1;
        
        User portalAccountOwner1 = new User();
        //portalAccountOwner1.UserRoleId = portalRole.Id;
        portalAccountOwner1.ProfileId = profile1.Id;
        portalAccountOwner1.Username = 'Sriktest@test.com';
        portalAccountOwner1.Alias = 'Test1';
        portalAccountOwner1.Email='test1@test.com';
        portalAccountOwner1.EmailEncodingKey='UTF-8';
        portalAccountOwner1.Firstname='Test2';
        portalAccountOwner1.Lastname='Test3';
        portalAccountOwner1.LanguageLocaleKey='en_US';
        portalAccountOwner1.LocaleSidKey='en_US';
        portalAccountOwner1.TimeZoneSidKey='America/Chicago';
        portalAccountOwner1.ContactId = contact1.id;
        insert portalAccountOwner1;
        
        Partner_Rebate__c PR = new Partner_Rebate__c();
        PR.Rebate_Name__c= 'TestPR';
        PR.rebate_Year__c='2014';
        PR.Partner_Name__c = portalAccount1.id;
        insert PR;
        
        
        pr.rebate_Year__c='2014';
        update pr;
        
        
        Partner_Rebate__c PR2 = new Partner_Rebate__c();
        PR2.Rebate_Name__c= 'TestPR';
        PR2.Published_to_Partner_Portal__c = true;
        PR2.rebate_Year__c='2015';
        PR2.Partner_Name__c = portalAccount1.id;
        PR2.Publish_Earned_Amounts_to_Partner_Portal__c=true;
        insert PR2;
       
    }
}