@isTest
public class PartnerNRODetailController_Test {
    
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
            
            Account testAccount = TestUtil.createAccounts(1, true)[0];
            TriggerFlowManager.ORDER_BEFORE_INSERT_TRIGGER = false;
            
            Order__c ord_1 = new Order__c();
            ord_1.Maintenance_Start__c = Date.today();
            ord_1.Maintenance_End__c = Date.today().addYears(1);
            ord_1.Numb_of_Maint_Months__c = 12;
            ord_1.End_User_Name__c = testAccount.id;
            ord_1.status__c = 'In Progress';
            insert ord_1;
            
            ApexPages.currentPage().getParameters().put('Id', ord_1.id);
            PartnerNRODetailController cnt = new PartnerNRODetailController();
            cnt.goBack();
            
        }
    }
}