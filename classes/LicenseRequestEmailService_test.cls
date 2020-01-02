@isTest
public class LicenseRequestEmailService_test{

     public static testmethod void LicenseRequest(){
     
     TestUtil.setConfigValues();
     Util.Bypass_Trigger_Chk = true; 
     
        List<Account> accListToInsert=  TestUtil.createAccounts(1, false);
        accListToInsert[0].name='new test accountt';  
        accListToInsert[0].SAP_Account_Code__c = '1234';
        accListToInsert[0].Status__c = 'Active';
        insert accListToInsert;
        
        List<Contact> conListToInsert=  TestUtil.createContacts(1,accListToInsert[0] ,false);
        insert conListToInsert;
        
      test.StartTest();
        License_Request__c objLR=new License_Request__c();
        objLR.First_Name__c = 'Test1';
        objLR.Last_Name__c = 'Test2';
        objLR.Corporate_Email__c = 'abc@abc.com';
        objLR.GARN_Code__c = '1234';
        objLR.Request_Type__c = 'Question';
        objLR.Date_Needed__c = Date.Today();
        objLR.Date_Reasoning__c = 'Test';
        objLR.Status__c = 'Open';
        objLR.Sub_Status__c = 'New';
        insert objLR;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
        string sBody = 'refer:'+objLR.id+':ref ';
        email.subject = 'test';
        email.htmlbody = sBody ;
        email.plainTextBody = sBody ;
       email.fromAddress = 'user@acme.com';
       email.toAddresses = new List<String>{'user@acme.com'};
       email.ccAddresses = new List<String>{'user@acme.com'};
       
        // set the body of the attachment
        
        inAtt.body = blob.valueof('test');
        inAtt.fileName = 'my attachment name';
        inAtt.mimeTypeSubType = 'plain/txt';
    
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt };
    
        // call the class and test it with the data in the testMethod
        LicenseRequestEmailService emailServiceObj = new LicenseRequestEmailService();
        Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env );
              
        test.StopTest();
     
     }
     
     public static testmethod void LicenseRequest2(){
     
       TestUtil.setConfigValues();
     Util.Bypass_Trigger_Chk = true; 
     
        List<Account> accListToInsert=  TestUtil.createAccounts(1, false);
        accListToInsert[0].name='new test accountt';  
        accListToInsert[0].SAP_Account_Code__c = '1234';
        accListToInsert[0].Status__c = 'Active';
        insert accListToInsert;
        
        List<Contact> conListToInsert=  TestUtil.createContacts(1,accListToInsert[0] ,false);
        insert conListToInsert;
        
      test.StartTest();
        License_Request__c objLR=new License_Request__c();
        objLR.First_Name__c = 'Test1';
        objLR.Last_Name__c = 'Test2';
        objLR.Corporate_Email__c = 'abc@abc.com';
        objLR.GARN_Code__c = '1234';
        objLR.Request_Type__c = 'Question';
        objLR.Date_Needed__c = Date.Today();
        objLR.Date_Reasoning__c = 'Test';
        objLR.Status__c = 'Open';
        objLR.Sub_Status__c = 'New';
        insert objLR;

        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.TextAttachment inAtt = new Messaging.InboundEmail.TextAttachment();
        string sBody = 'test:'+objLR.id+':test ';
        email.subject = 'test';
        email.plainTextBody = sBody ;
        env.fromAddress = 'user@acme2.com';
        env.toAddress = 'user@acme2.com';
    
        // set the body of the attachment
        
        inAtt.body = 'test';
        inAtt.fileName = 'my attachment name';
        inAtt.mimeTypeSubType = 'plain/txt';
    
        email.TextAttachments = new Messaging.inboundEmail.TextAttachment[] {inAtt };
    
        // call the class and test it with the data in the testMethod
        LicenseRequestEmailService emailServiceObj = new LicenseRequestEmailService();
        Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env );
        
        
        
        test.StopTest();
     
     }
}