@isTest
private class DQSubApprovalEmailApprovalTest {
    
@istest

public static void handleInboundEmailtest(){

Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
User u = new User(Alias = 'test1', Email='testdev@genesys.com',FirstName = 'Test', 
            EmailEncodingKey='UTF-8', LastName='Testlast', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testdev@genesys.com');
            insert u;
    
         Deal_Qualification__c testRec = new Deal_Qualification__c();
         testRec.Order_Mgmt_Billing_approval__c='Pending';
         testRec.Req_Order_Mgmt_Billing_approval__c=true;
         testRec.Status__c = 'Approval Pending';
         testRec.Req_Legal_approval__c = true;
         testRec.Legal_approval__c = 'Pending';
         testRec.Req_Credit_Collections_approval__c= true;
         testRec.Credit_and_Collections_approval__c='Pending';
         testRec.Req_Revenue_Approval__c=true;
         testRec.Revenue_approval__c = 'Pending';
       testRec.Revenue_Comments__c = 'Approved';
       testRec.Legal_Comments__c = 'Approved';
       testRec.Credit_Collections_Comments__c = 'Approved';
       testRec.Order_Management_Billing_Comments__c = 'Rejected';   
         insert testRec;

    System.runAs(u){
    
     // create a new email and envelope object
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEmail email2 = new Messaging.InboundEmail() ;
       Messaging.InboundEmail email3 = new Messaging.InboundEmail() ;
       Messaging.InboundEmail email4 = new Messaging.InboundEmail() ;
       Messaging.InboundEmail email5 = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
       
       // setup the data for the email
      email.subject = 'Revenue';
      email.fromAddress = 'testdev@genesys.com';
      email.htmlBody = testRec.Id+' Approved';
      
      email2.subject = 'Legal';
      email2.fromAddress = 'testdev@genesys.com';
      email2.htmlBody = testRec.Id+' Approved';
        
      email3.subject = 'CreditCollection';
      email3.fromAddress = 'testdev@genesys.com';
      email3.htmlBody = testRec.Id+' Approved';
      
      email4.subject = 'Order Management Billing';
      email4.fromAddress = 'testdev@genesys.com';
      email4.htmlBody = testRec.Id+' Rejected';
        
      email5.subject = 'Order Management Billing';
      email5.htmlBody = testRec.Id+' Rejected';
      
      
     
      
      // call the email service class and test it with the data in the testMethod
      DQSubApprovalEmailApproval  DQSubApproval=new DQSubApprovalEmailApproval ();
    test.startTest();
      DQSubApproval.handleInboundEmail(email, env);
      DQSubApproval.handleInboundEmail(email2, env);
      DQSubApproval.handleInboundEmail(email3, env);
      DQSubApproval.handleInboundEmail(email4, env);
      DQSubApproval.handleInboundEmail(email5, env);
    test.stopTest();
    
     
    }
    
}
}