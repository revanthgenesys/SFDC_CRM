@istest(seealldata=true)
public class PartnerRebateControllerTest{
        
    public static testmethod void Method1(){
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile profile1 = [Select Id from Profile where name = 'Genesys Portal End User'];
        
        //Create account
        Account portalAccount1 = new Account();
        portalAccount1.Name = 'TestAccount';
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
        contact1.MailingCountry = 'USA';              
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
        insert PR;
        
        system.runas(portalAccountOwner1){
            
            PartnerPortal_PeriodicReview_Class prtnPrtlPerRevObj = new PartnerPortal_PeriodicReview_Class();
            PartnerRebateController obj1  = new PartnerRebateController(prtnPrtlPerRevObj);
            
            list<recordType> rtList = [SELECT id FROM recordType WHERE name = 'Enterprise - Business Partner'];
            
            //CREATE ACCOUNT
            account actObj = new account();
            actObj.name = 'actTest';
            actObj.Channel_Manager__c = userInfo.getUserId();
            if(rtList.size()> 0) {
                actObj.recordTypeId = rtList[0].id;
            }
            insert actObj;
            
            // CREATE CONTACT
            contact conObj = new contact();
            conObj.lastname = 'test';
            conObj.Designated_Partner_Contact__c = true;
            conObj.AccountId = actObj.id;
            conObj.Email = 'test@yahoo.com';
            insert conObj;
            
            //  CREATE Partner_Rebate__c
            Partner_Rebate__c partRevObj = new Partner_Rebate__c();
            partRevObj.Rebate_Year__c = '2015';
            partRevObj.Rebate_Name__c = 'test';
            partRevObj.Published_to_Partner_Portal__c = true;
            partRevObj.Active_Days__c = 5;
            partRevObj.Publish_Date__c = date.today();
            partRevObj.Partner_Name__c = actObj.id;
 //           insert partRevObj;
           
            
            ApexPages.standardController controller = new ApexPages.StandardController(partRevObj);
            PartnerRebateController obj2  = new PartnerRebateController(controller);
            obj2.saveTermsWithAgree();
            obj2.saveTermsWithDisagree();
            
            obj2.doCancel();
            obj2.isERPublished = true;
            obj2.isExpired = true;
            obj2.FlagYes = true;
        }
    }
}