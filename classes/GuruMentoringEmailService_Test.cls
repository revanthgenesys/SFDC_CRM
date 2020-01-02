@isTest
public class GuruMentoringEmailService_Test {
	
	 public static testmethod void tstUpd(){
	 	
       Guru_Mentoring__c gm = new Guru_Mentoring__c();
        gm.Status__c = 'Open';
        gm.Sub_Status__c = 'New';
        insert gm; 

       test.StartTest();
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.TextAttachment inAtt = new Messaging.InboundEmail.TextAttachment();
         string sBody = 'refer:'+ gm.id+':ref ';
        email.subject = 'test';
        email.plainTextBody = sBody ;
        env.fromAddress = 'user@acme2.com';
        env.toAddress = 'user@acme2.com';
       email.toAddresses = new List<String>{'user@acme.com'};
       email.ccAddresses = new List<String>{'user@acme.com'};
  
        inAtt.body = 'test';
        inAtt.fileName = 'my attachment name';
        inAtt.mimeTypeSubType = 'plain/txt';
 
        email.TextAttachments = new Messaging.inboundEmail.TextAttachment[] {inAtt };
    
        // call the class and test it with the data in the testMethod
        GuruMentoringEmailService emailServiceObj = new GuruMentoringEmailService();
        Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env );
     
        test.StopTest();
     
     }
     
      public static testmethod void tstIns(){
     
      test.StartTest();
    
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        Messaging.InboundEmail.BinaryAttachment inAtt = new Messaging.InboundEmail.BinaryAttachment();
        string sBody = 'test';
        email.subject = 'test';
        email.plainTextBody = sBody ;
        env.fromAddress = 'user@acme2.com';
        env.toAddress = 'user@acme2.com';
        email.toAddresses = new List<String>{'user@acme.com'};
       email.ccAddresses = new List<String>{'user@acme.com'};
         
        inAtt.body = blob.valueOf('test');
        inAtt.fileName = 'my attachment name';
        inAtt.mimeTypeSubType = 'plain/txt';
    
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] {inAtt };
    
        // call the class and test it with the data in the testMethod
        GuruMentoringEmailService emailServiceObj = new GuruMentoringEmailService();
        Messaging.InboundEmailResult result = emailServiceObj.handleInboundEmail(email, env );
     
        test.StopTest();
     
     }
     
     
     
    
}