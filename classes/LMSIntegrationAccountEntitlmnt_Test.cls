@isTest
public class LMSIntegrationAccountEntitlmnt_Test {
	
	 static testMethod void tst() {
	 	
	 	TestUtil.setConfigValues();
		Util.Bypass_Trigger_Chk = true;
		
	 	Account acc = new Account( Name='Account', Status__c = 'Active' );  
	 	insert acc;   
	
	 	LMSIntegrationAccountEntitlmnt.getAccountEntitlmnt(acc.Id);
	 }
    
}