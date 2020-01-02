@isTest(SeeAllData=true)
public class SMARTServicesContentControllerTest {
	static testMethod void testSearchComponent() {
        Test.startTest();
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];       
        RecordType rt = [select Id from RecordType where Name = 'Enterprise - Business Partner'];
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        Country__c Ctry = [select Id, Region__c from Country__c where Name = 'United States'];
        testAccount.Country__c = Ctry.Id;
        testAccount.recordTypeId = rt.Id;
        testAccount.Status__c = 'Active';
        testAccount.Account_Status__c = 'Active';
        testAccount.PartnerType__c = 'VAR;Technology Partner;Cloud Partner;Cloud Solution Provider;Cloud Reseller';
        insert testAccount;
        Contact testContact = TestUtil.createContacts(1, testAccount, false)[0];
        testContact.Designated_Partner_Contact__c = true;
        testContact.Business_Consulting_Approved__c = true;
        testContact.SEO_Beta_Program__c = true;
        testContact.G_PS_Approved__c = true;
        testContact.SMART_Certified__c = true;
        insert testContact;
        User testUser;
        Test.stopTest();
        testUser = TestCommon.createUser('testU', 'testUser139@test139.com.test', 'Test', 'Test', partnerProfile.id, false);        
        testUser.ContactId = testContact.id;
        testUser.UserPermissionsSFContentUser=true;
        insert testUser;

        //System.runAs(testUser)
        {
            //insert Pricing Guide Content
            List<ContentVersion> contentVersionObjList = new List<ContentVersion>();
            ContentVersion contentVersionObj1 = new ContentVersion();
            contentVersionObj1.ContentURL = 'http://www.google.com';
            contentVersionObj1.title = 'Google';
            contentVersionObj1.Content_Type__c  = 'SMART Services Content';
            contentVersionObj1.Internal_and_Partner_Usage__c = 'Partners';
            contentVersionObj1.Account__c = testAccount.Id;
            contentVersionObj1.Region__c = 'North America';
            contentVersionObjList.add(contentVersionObj1);
            
			ContentVersion contentVersionObj2 = new ContentVersion();
            contentVersionObj2.ContentURL = 'http://www.google.com';
            contentVersionObj2.title = 'Google plus';
            contentVersionObj2.Content_Type__c  = 'SMART Services Content';
            contentVersionObj2.Internal_and_Partner_Usage__c = 'Partners';
            contentVersionObj2.Account__c = testAccount.Id;
            contentVersionObj2.Region__c = 'North America';
            contentVersionObjList.add(contentVersionObj2);
            
            ContentVersion contentVersionObj3 = new ContentVersion();
            contentVersionObj3.ContentURL = 'http://www.google.com';
            contentVersionObj3.title = 'Google plus plus';
            contentVersionObj3.Content_Type__c  = 'SMART Services Content';
            contentVersionObj3.Internal_and_Partner_Usage__c = 'Partners';
            contentVersionObj3.Account__c = testAccount.Id;
            contentVersionObj3.Region__c = 'North America';
            contentVersionObjList.add(contentVersionObj3);

            insert contentVersionObjList;
            
          //System.debug('contentVersionObj select-->'+[select Id,title from contentVersion where id=: contentVersionObj.Id]);
            //System.debug('contentVersionObj testuser-->'+[select Id,title,Content_Type__c,Account__c,Region__c from contentVersion where id=: contentVersionObj.Id]);
            PageReference pageRef = Page.SMARTServicesContent;
            pageRef.getParameters().put('runAs',testUser.id);
            pageRef.getParameters().put('srtColumn','Title');
            pageRef.getParameters().put('srtDir','ASC');
            Test.setCurrentPage(pageRef);            
            SMARTServicesContentController ppgsc = new SMARTServicesContentController();
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
    }

}