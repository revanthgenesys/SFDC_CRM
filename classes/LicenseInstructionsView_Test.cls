@isTest
public class LicenseInstructionsView_Test {
	
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
	
		Util.Bypass_Trigger_Chk = true;
	    License_Request__c licrec = new License_Request__c(Last_Name__c = 'last');
	    insert licrec;
	    
        Test.startTest(); 
         ApexPages.StandardController sc = new ApexPages.StandardController(licrec);
        LicenseInstructionsView contr = new LicenseInstructionsView(sc);
       
        Test.stopTest(); 
       
	 }

}