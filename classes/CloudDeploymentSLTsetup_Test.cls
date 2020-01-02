@isTest
public class CloudDeploymentSLTsetup_Test {
	
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
		Account testAccount = TestUtil.createAccounts(1, true)[0];
		
		Cloud_Deployment__c depl = new Cloud_Deployment__c();
		depl.Support_Status__c = 'Active';
	   	depl.Cloud_Platform__c = 'Premier Edition';
	   	depl.Account__c = testAccount.id;
	   	depl.Sold_To_Account__c = testAccount.id;
	   	depl.Care_Level__c = 'Care for Cloud';
        insert depl;
        
        List<RecordType> recType = [SELECT Id FROM RecordType 
                            WHERE SobjectType = 'Service_Level_Target__c' AND DeveloperName = 'SLT_Cloud_Master_Definition'];
                                
        Service_Level_Target__c slt = new Service_Level_Target__c (RecordTypeId = recType[0].Id, Cloud_Support_Package__c = 'Care for Cloud');
        insert slt;
        
        Test.startTest(); 
         ApexPages.StandardController sc = new ApexPages.StandardController(depl);
        CloudDeploymentSLTsetup contr = new CloudDeploymentSLTsetup(sc);
        
        contr.currentSltType =  'template';
        contr.addCustomSlt();
        contr.saveCustSlt();
         contr.currentSltType =  'custom';
        contr.removeCustomSlt();
        contr.editCustom();
        contr.actCancel();
        Test.stopTest(); 
        
	}

}