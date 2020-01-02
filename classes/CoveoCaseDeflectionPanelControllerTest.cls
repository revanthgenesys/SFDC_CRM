@isTest(seeAllData = true)
public class CoveoCaseDeflectionPanelControllerTest {
    static testMethod void myTest() {
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        
        RecordType rt = [select Id from RecordType where Name = 'Enterprise - Business Partner'];
        Country__c Ctry = [select Id, Region__c from Country__c where Name = 'United States'];
        testAccount.Country__c = Ctry.Id;
        testAccount.recordTypeId = rt.Id;
        testAccount.Status__c = 'Active';
        testAccount.Account_Status__c = 'Active';  
        testAccount.Partner_Program_Status__c = 'Active';
        testAccount.Partner_Tier__c = 'Bronze';
        testAccount.PartnerType__c = 'VAR;Specialized Reseller;Cloud Reseller;Managed Services Provider;Contract Reseller';  
        insert testAccount;
        
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Partner Community Login New' LIMIT 1];
        Profile potenPartnerProfile = [SELECT id FROM Profile WHERE Name = 'Custom Potential Partner User' LIMIT 1];
        
        User testUser = TestCommon.createUser('t0233', 'testGenUser0233@test132.com.test', 'testGenUserfname0233', 'testGenUserlname0233', partnerProfile.id, false);      
        testUser.ContactId = testContact.id;
        insert testUser; 
        
        List<Support_Product__c> prod = TestUtil.createSupportProducts(3, true);
        
        System.runAs(testUser){
	        Test.startTest();
            PageReference pageRef = Page.PortalNewFRCase;
            Test.setCurrentPage(pageRef);
	        CoveoCaseDeflectionPanelController ctrl = new CoveoCaseDeflectionPanelController();

            ApexPages.currentPage().getParameters().put('cm', prod[0].Id);
	        ctrl = new CoveoCaseDeflectionPanelController();
            System.assert(String.isNotEmpty(ctrl.coveoComponentName) );
            
            ApexPages.currentPage().getParameters().put('sp', prod[1].Id);
	        ctrl = new CoveoCaseDeflectionPanelController();
            System.assert(String.isNotEmpty(ctrl.coveoProductName) );

            ApexPages.currentPage().getParameters().put('pl', prod[2].Id);
	        ctrl = new CoveoCaseDeflectionPanelController();
            System.assert(String.isNotEmpty(ctrl.coveoProductLineName) );

            ApexPages.currentPage().getParameters().put('sto', testAccount.Id);
	        ctrl = new CoveoCaseDeflectionPanelController();
            System.assert(String.isNotEmpty(ctrl.coveoSoldToName) );

            Test.stopTest();    
        }
        
        
    }
    
}