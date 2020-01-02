@isTest
public class ChangeLogExtController_Test {
     
     static testMethod void tstChangeLogExtController() {
        ChangeLogHistory__c logHistory = new ChangeLogHistory__c(Start_Date__c = system.today());
        insert logHistory;
        
        ChangeLogHistory__c logHistory2 = new ChangeLogHistory__c(Start_Date__c = system.today(), body__c = 'test');
        
        
        Change_Log__c cLog = new Change_Log__c(Release_Date__c = system.today());
        insert cLog;
        
        ChangeLogRecipients__c cRecipients = new ChangeLogRecipients__c(name = 'Anju',email__c = 'anjuchacko@qburst.com');
        insert cRecipients;
        
        
        Test.startTest();  
        ApexPages.StandardController standrdcontroller = new ApexPages.StandardController(logHistory2);
        ChangeLogExtController c = new ChangeLogExtController(standrdcontroller);
        c.doSearch();
        c.previewandSend();
        c.sendEmail();
        
        Test.stopTest(); 
     }

}