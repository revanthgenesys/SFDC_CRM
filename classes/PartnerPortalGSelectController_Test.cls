@isTest(SeeAllData=true)
public class PartnerPortalGSelectController_Test {
  static testMethod void testSearchComponent() {
        Test.startTest();
        Contact testContact;
        Account testAccount;
        User testUser;
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal Partner' LIMIT 1];
        User nonSetupUsr = [Select id from User where profile.name = 'General User Access Group SU' and isactive = true limit 1];
        RecordType rt = [select Id from RecordType where Name = 'Enterprise - Business Partner'];
        System.runAs(nonSetupUsr){
            testAccount = TestUtil.createAccounts(1, false)[0];
            Country__c Ctry = [select Id, Region__c from Country__c where Name = 'United States'];
            testAccount.Country__c = Ctry.Id;
            testAccount.recordTypeId = rt.Id;
            testAccount.Status__c = 'Active';
            testAccount.Account_Status__c = 'Active';
            testAccount.PartnerType__c = 'VAR;Technology Partner;Cloud Partner;Cloud Solution Provider;Cloud Reseller';
            insert testAccount;
            testContact = TestUtil.createContacts(1, testAccount, false)[0];
            testContact.Designated_Partner_Contact__c = true;
            testContact.Business_Consulting_Approved__c = true;
            testContact.SEO_Beta_Program__c = true;
            testContact.G_PS_Approved__c = true;
            insert testContact;
            testUser = TestCommon.createUser('testU', 'testUser139@test139.com.test', 'Test', 'Test', partnerProfile.id, false);        
            testUser.ContactId = testContact.id;
            testUser.UserPermissionsSFContentUser=true;
            insert testUser;
            Test.stopTest();
        }

     
          
        //System.runAs(testUser)
        //{
            //insert Pricing Guide Content
            List<ContentVersion> contentVersionObjList = new List<ContentVersion>();
            ContentVersion contentVersionObj1 = new ContentVersion();
            contentVersionObj1.ContentURL = 'http://www.google.com';
            contentVersionObj1.title = 'Google';
            contentVersionObj1.Content_Type__c  = 'Pricing Guides';
            contentVersionObj1.Internal_and_Partner_Usage__c = 'Partners';
            contentVersionObj1.Account__c = testAccount.Id;
            contentVersionObj1.Region__c = 'North America';
            contentVersionObjList.add(contentVersionObj1);
            
            ContentVersion contentVersionObj2 = new ContentVersion();
            contentVersionObj2.ContentURL = 'http://www.google.com';
            contentVersionObj2.title = 'Google plus';
            contentVersionObj2.Content_Type__c  = 'Pricing Guides';
            contentVersionObj2.Internal_and_Partner_Usage__c = 'Partners';
            contentVersionObj2.Account__c = testAccount.Id;
            contentVersionObj2.Region__c = 'North America';
            contentVersionObjList.add(contentVersionObj2);
            
            ContentVersion contentVersionObj3 = new ContentVersion();
            contentVersionObj3.ContentURL = 'http://www.google.com';
            contentVersionObj3.title = 'Google';
            contentVersionObj3.Content_Type__c  = 'Business Consulting Approved';
            contentVersionObj3.Internal_and_Partner_Usage__c = 'Partners';
            contentVersionObj3.Account__c = testAccount.Id;
            contentVersionObj3.Region__c = 'North America';
            contentVersionObjList.add(contentVersionObj3);
            
            ContentVersion contentVersionObj4 = new ContentVersion();
            contentVersionObj4.ContentURL = 'http://www.google.com';
            contentVersionObj4.title = 'Google';
            contentVersionObj4.Content_Type__c  = 'SEO Beta Program';
            contentVersionObj4.Internal_and_Partner_Usage__c = 'Partners';
            contentVersionObj4.Account__c = testAccount.Id;
            contentVersionObj4.Region__c = 'North America';
            contentVersionObjList.add(contentVersionObj4);
            
            ContentVersion contentVersionObj5 = new ContentVersion();
            contentVersionObj5.ContentURL = 'http://www.google.com';
            contentVersionObj5.title = 'Google';
            contentVersionObj5.Content_Type__c  = 'G-PS Approved';
            contentVersionObj5.Internal_and_Partner_Usage__c = 'Partners';
            contentVersionObj5.Account__c = testAccount.Id;
            contentVersionObj5.Region__c = 'North America';
            contentVersionObjList.add(contentVersionObj5);
            
            ContentVersion contentVersionObj6 = new ContentVersion();
            contentVersionObj6.ContentURL = 'http://www.google.com';
            contentVersionObj6.title = 'Google';
            contentVersionObj6.Content_Type__c  = 'Technology Partner';
            contentVersionObj6.Internal_and_Partner_Usage__c = 'Partners';
            contentVersionObj6.Account__c = testAccount.Id;
            contentVersionObj6.Region__c = 'North America';
            contentVersionObjList.add(contentVersionObj6);
            
            ContentVersion contentVersionObj7 = new ContentVersion();
            contentVersionObj7.ContentURL = 'http://www.google.com';
            contentVersionObj7.title = 'Google';
            contentVersionObj7.Content_Type__c  = 'Cloud Partner';
            contentVersionObj7.Internal_and_Partner_Usage__c = 'Partners';
            contentVersionObj7.Account__c = testAccount.Id;
            contentVersionObj7.Region__c = 'North America';
            contentVersionObjList.add(contentVersionObj7);
            
            ContentVersion contentVersionObj8 = new ContentVersion();
            contentVersionObj8.ContentURL = 'http://www.google.com';
            contentVersionObj8.title = 'Google';
            contentVersionObj8.Content_Type__c  = 'Cloud Solution Provider';
            contentVersionObj8.Internal_and_Partner_Usage__c = 'Partners';
            contentVersionObj8.Account__c = testAccount.Id;
            contentVersionObj8.Region__c = 'North America';
            contentVersionObjList.add(contentVersionObj8);

            ContentVersion contentVersionObj9 = new ContentVersion();
            contentVersionObj9.ContentURL = 'http://www.google.com';
            contentVersionObj9.title = 'Google';
            contentVersionObj9.Content_Type__c  = 'Cloud Reseller';
            contentVersionObj9.Internal_and_Partner_Usage__c = 'Partners';
            contentVersionObj9.Account__c = testAccount.Id;
            contentVersionObj9.Region__c = 'North America';
            contentVersionObjList.add(contentVersionObj9);
            insert contentVersionObjList;
            
          //System.debug('contentVersionObj select-->'+[select Id,title from contentVersion where id=: contentVersionObj.Id]);
            //System.debug('contentVersionObj testuser-->'+[select Id,title,Content_Type__c,Account__c,Region__c from contentVersion where id=: contentVersionObj.Id]);
            System.runAs(testUser){
                PageReference pageRef = Page.GSelect;
                pageRef.getParameters().put('runAs',testUser.id);
                pageRef.getParameters().put('srtColumn','Title');
                pageRef.getParameters().put('srtDir','ASC');
                Test.setCurrentPage(pageRef);            
                PartnerPortalGSelectController ppgsc = new PartnerPortalGSelectController();
                ppgsc.sortByField();
                pageRef.getParameters().put('runAs',testUser.id);
                pageRef.getParameters().put('srtColumn','Author');
                pageRef.getParameters().put('srtDir','ASC');
                ppgsc.sortByField();
                pageRef.getParameters().put('runAs',testUser.id);
                pageRef.getParameters().put('srtColumn','Last Modified');
                pageRef.getParameters().put('srtDir','ASC');
                ppgsc.sortByField();
            }
        //}
    }
}