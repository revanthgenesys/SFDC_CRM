@isTest
public class PartnerNROrderFormController_Test {
	
	 static testMethod void tst() {
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
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        User testUser;
        
	      TriggerFlowManager.ORDER_BEFORE_INSERT_TRIGGER = false;
	      
	      Order__c ord_1 = new Order__c();
	      ord_1.Maintenance_Start__c = Date.today();
	      ord_1.Maintenance_End__c = Date.today().addYears(1);
	      ord_1.Numb_of_Maint_Months__c = 12;
	      ord_1.End_User_Name__c = testAccount.id;
	      ord_1.status__c = 'In Progress';	      
	      insert ord_1;
	        
        testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);        
        testUser.ContactId = testContact.id;
        insert testUser;       
        System.runAs(testUser){
        	PartnerNROrderFormController cnt1 = new PartnerNROrderFormController();
        	cnt1.saveForm();
        	cnt1.cancelForm();
        	
            ApexPages.currentPage().getParameters().put('Id', ord_1.id);
            PartnerNROrderFormController cnt2 = new PartnerNROrderFormController();	 
        }
	 }

}