@isTest
public class LicenseEmailReassign_Test {
     
     public static testmethod void reassignTest1() {
        TestUtil.setConfigValues();
        Util.Bypass_Trigger_Chk = true; 
     
        License_Request__c srceLR = new License_Request__c();
        srceLR.Request_Type__c = 'Question';
        srceLR.Status__c = 'Open';
        srceLR.Sub_Status__c = 'New';
        insert srceLR;
        
        License_Request__c trgLR = new License_Request__c();
        trgLR.Request_Type__c = 'Question';
        trgLR.Status__c = 'Open';
        trgLR.Sub_Status__c = 'New';
        insert trgLR;
        
         EmailMessage tsk = new  EmailMessage(RelatedToId = srceLR.Id,  Subject = 'Task');
        insert tsk;
       
        test.StartTest();  
         Util.Bypass_Trigger_Chk = false; // to cover License Request trigger
        ApexPages.StandardController stdController = new ApexPages.StandardController(srceLR);
        LicenseEmailReassign ler = new LicenseEmailReassign(stdController);
       ler.targetId = trgLR.Id;
       ler.targetName = 'Name';       
        ler.saveUpdates();
        
        test.StopTest();
  }
  
  public static testmethod void reassignTest2() {
        TestUtil.setConfigValues();
        Util.Bypass_Trigger_Chk = true; 
     
        License_Request__c srceLR = new License_Request__c();
        srceLR.Request_Type__c = 'Question';
        srceLR.Status__c = 'Open';
        srceLR.Sub_Status__c = 'New';
        insert srceLR;
        
        License_Request__c trgLR = new License_Request__c();
        trgLR.Request_Type__c = 'Question';
        trgLR.Status__c = 'Open';
        trgLR.Sub_Status__c = 'New';
        insert trgLR;
        
         EmailMessage tsk = new  EmailMessage(RelatedToId = srceLR.Id,  Subject = 'Task');
        insert tsk;
       
        test.StartTest();  
         Util.Bypass_Trigger_Chk = false; // to cover License Request trigger
        ApexPages.StandardController stdController = new ApexPages.StandardController(srceLR);
        LicenseEmailReassign ler = new LicenseEmailReassign(stdController);
        ler.saveUpdates();
 
        test.StopTest();
  }
  
   public static testmethod void reassignTest3() {
        TestUtil.setConfigValues();
        Util.Bypass_Trigger_Chk = true; 
     
        License_Request__c srceLR = new License_Request__c();
        srceLR.Request_Type__c = 'Question';
        srceLR.Status__c = 'Open';
        srceLR.Sub_Status__c = 'New';
        insert srceLR;
        
        License_Request__c trgLR = new License_Request__c();
        trgLR.Request_Type__c = 'Question';
        trgLR.Status__c = 'Open';
        trgLR.Sub_Status__c = 'New';
        insert trgLR;
        
         EmailMessage tsk = new  EmailMessage(RelatedToId = srceLR.Id,  Subject = 'Task');
        insert tsk;
       
        test.StartTest();  
         Util.Bypass_Trigger_Chk = false; // to cover License Request trigger
        ApexPages.StandardController stdController = new ApexPages.StandardController(srceLR);
        LicenseEmailReassign ler = new LicenseEmailReassign(stdController);
  
        ler.lrId = null;
        ler.saveUpdates();
               
        test.StopTest();
  }

}