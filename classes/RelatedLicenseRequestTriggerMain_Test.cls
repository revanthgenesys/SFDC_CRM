@isTest
public class RelatedLicenseRequestTriggerMain_Test {
	
	 public static testmethod void reltest() {
     	TestUtil.setConfigValues();
        Util.Bypass_Trigger_Chk = true; 
     
        License_Request__c lr1 = new License_Request__c();
        lr1.Request_Type__c = 'Question';
        lr1.Status__c = 'Open';
        lr1.Sub_Status__c = 'New';
        insert lr1;
        
        License_Request__c lr2 = new License_Request__c();
        lr2.Request_Type__c = 'Question';
        lr2.Status__c = 'Open';
        lr2.Sub_Status__c = 'New';
        insert lr2;
        
         test.StartTest();  
         Util.Bypass_Trigger_Chk = false;
         
         Related_License_Request__c relins = new Related_License_Request__c();
         relins.AFR_Prnt__c = lr1.Id;
         relins.AFR_Rel__c = lr2.id;
         insert relins;
         
         delete relins;
         
         test.StopTest();
        
	 }
    
}