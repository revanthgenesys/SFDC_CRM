@isTest(SeeAllData=true)
public class PartnerPortalSearchController_Test {
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
        insert testContact;
        User testUser;
        Test.stopTest();
        testUser = TestCommon.createUser('testU', 'testUser139@test139.com.test', 'Test', 'Test', partnerProfile.id, false);        
        testUser.ContactId = testContact.id;
        testUser.UserPermissionsSFContentUser=true;
        insert testUser;
        
        List<ContentVersion> contentVersionObjList = [SELECT id, Title, Description, ContentDocumentId, ContentSize,  Legacy_Author__c, CreatedBy.Name, LastModifiedDate FROM ContentVersion LIMIT 2];
		
        System.runAs(testUser){     
            PageReference pageRef = Page.Partner_Portal_Products_Solutions;
            pageRef.getParameters().put('srtColumn','Title');
            pageRef.getParameters().put('srtDir','ASC');
            Test.setCurrentPage(pageRef);            
            PartnerPortalSearchController ppsc = new PartnerPortalSearchController();
            ppsc.pageId = PartnerPortalSearchController.PRODUCT_SOLUTION_PAGE;
            ppsc.searchFilter = 'test';
            ppsc.productFilter = ppsc.getProductOptions()[0].getvalue();
            ppsc.solutionFilter = ppsc.getSolutionOptions()[0].getvalue();
            ppsc.sortByField();
            ppsc.performSearch();
           // System.assert(ppsc.contentResults != null);
            pageRef = Page.Partner_Portal_Services;
            Test.setCurrentPage(pageRef);
            ppsc.pageId = PartnerPortalSearchController.TRAINING_PAGE;
            ppsc.serviceFilter='Genesys Care';
            ppsc.performSearch();
         //   System.assert(ppsc.contentResults != null);
            pageRef = Page.Partner_Portal_Services;
            Test.setCurrentPage(pageRef);
            ppsc.pageId = PartnerPortalSearchController.SERVICES_PAGE;
            ppsc.contentTypeFilter = 'Partner Program';
            ppsc.performSearch();           
        //    System.assert(ppsc.contentResults != null);
        	
            PartnerPortalSearchController.ContentDocWrapper cWrapper1 = new PartnerPortalSearchController.ContentDocWrapper(contentVersionObjList[0]);
            PartnerPortalSearchController.ContentDocWrapper cWrapper2 = new PartnerPortalSearchController.ContentDocWrapper(contentVersionObjList[1]);
            PartnerPortalSearchController.sortExpression = 'Title';
			PartnerPortalSearchController.sortDirection = 'asc';
            cWrapper1.compareTo(cWrapper2);
            PartnerPortalSearchController.sortExpression = 'Title';
			PartnerPortalSearchController.sortDirection = 'desc';
            cWrapper1.compareTo(cWrapper2);

            PartnerPortalSearchController.sortExpression = 'Author';
			PartnerPortalSearchController.sortDirection = 'asc';
            cWrapper1.compareTo(cWrapper2);
            PartnerPortalSearchController.sortExpression = 'Author';
			PartnerPortalSearchController.sortDirection = 'desc';
            cWrapper1.compareTo(cWrapper2);
            
            PartnerPortalSearchController.sortExpression = 'Last Modified';
			PartnerPortalSearchController.sortDirection = 'asc';
            cWrapper1.compareTo(cWrapper2);
            PartnerPortalSearchController.sortExpression = 'Last Modified';
			PartnerPortalSearchController.sortDirection = 'desc';
            cWrapper1.compareTo(cWrapper2);
        }
    }

}