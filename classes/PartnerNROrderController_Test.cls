@isTest
public class PartnerNROrderController_Test {
    
    static testMethod void tst() {
        List<Partner_Portal_Deal_Registration_Config__c> csPartnerConfig = new List<Partner_Portal_Deal_Registration_Config__c>();
        csPartnerConfig.add(new Partner_Portal_Deal_Registration_Config__c(Name = 'Cloud Partner', Lead_Referral__c = true, Opportunity_Registration__c = true, Pricing_Guides__c = true, Lab_Order__c = true));
        csPartnerConfig.add(new Partner_Portal_Deal_Registration_Config__c(Name = 'Cloud Solution Provider', Lead_Referral__c = true, Opportunity_Registration__c = true, Pricing_Guides__c = true, Lab_Order__c = true));
        csPartnerConfig.add(new Partner_Portal_Deal_Registration_Config__c(Name = 'Cloud Reseller', Lead_Referral__c = true, Opportunity_Registration__c = true, Pricing_Guides__c = true, Lab_Order__c = true));
        insert csPartnerConfig;
        
        TestUtil.setConfigValues();
        List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
        
        System.runAs(runAsUser[0]) {
            TestUtil.setCaseSupportTypesSettings();
        }
        
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];       
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        testAccount.PartnerType__c = 'Cloud Partner;Cloud Solution Provider;Cloud Reseller';
        update testAccount;
        
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        User testUser;
        
        testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);        
        testUser.ContactId = testContact.id;
        insert testUser;       
        
        System.runAs(testUser){
            PartnerNROrderController cnt = new PartnerNROrderController();
            cnt.openRequestForm();
            cnt.showDetails();
            cnt.editRequestForm();
        }
    }
}