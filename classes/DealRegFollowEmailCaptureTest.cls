/*
Created By: Mukunthan Koothan
Created On: 23-APR-2018
Purpose: Test class for DealRegFollowEmailCapture class
*/

@istest
public class DealRegFollowEmailCaptureTest {
    
   static testMethod void handleInboundEmailTest()
   
   {
        Test.StartTest();
            User currUser = [Select Id, Name, username,Bypass_Triggers__c from User where ID=:userinfo.getuserid()];
            currUser.Bypass_Triggers__c = true;
            System.runAs(currUser){
                partner_portal_prospect__c ppp = new partner_portal_prospect__c();
                ppp.Name = 'TestRec';
                ppp.Status__c = 'Request Submitted';
                //ppp.End_User_Account__c = a1.Id;
                ppp.What_is_the_Expected_Close_Date__c = Date.Today() + 30;
                //ppp.Opportunity_Channel_Manager__c = currUser.Id;
                insert ppp;
                
                Messaging.InboundEmail email = new Messaging.InboundEmail() ;
                Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
              
                  email.subject = '24 HR Follow-up Test';
                  email.fromAddress = 'someaddress@email.com';
                  email.CcAddresses = new String[] {'testccaddress@email.com'};
                  email.toAddresses= new String[] {'testtoaddress@email.com'};
                  email.htmlBody = 'This is a test '+ppp.Id;
                             
                  DealRegFollowEmailCapture  dealEmailCapture =new DealRegFollowEmailCapture();
                  dealEmailCapture.handleInboundEmail(email, env);
              }
        Test.stopTest();
      
   }
}