/*
Created By:    Swastika Rajkhowa(28/Mar/2017)
Function:      Test Class for Class  PartnerUserRequestEmailCapturer
*/
@isTest(seealldata=true)
public class PartnerUserRequestEmailCapturer_test{
 public static testmethod void testmethodPartnerUserRequestEmailCapturer1(){
    Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];   
    User adminUser = [select id,name,email from User where ProfileId =: partnerProfile.id and ManagerId !=NULL AND isActive = TRUE limit 1];   
    Test.startTest();        
    System.runAs(adminUser){
        Partner_User_Request__c objPartner_User_Request = new Partner_User_Request__c();
        insert objPartner_User_Request;
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        email.subject = 'test';
        email.htmlBody= 'Approve <br/> This is comment <br/><br/><br/><br/>';
        email.htmlBody+= 'ref:'+ objPartner_User_Request.id +':ref';
                
        env.fromAddress = adminUser.email;
        String[] toAddresses = new String[] {'user@test.com'};        
        email.ToAddresses = new String[] {'jsmith@test.com'};
        email.CcAddresses = new String[] {'jsmith@test.com'};
        
        // add an Binary attachment        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('my attachment text');
        attachment.fileName = 'textfileone.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };        
        
        // add an Text atatchment        
        Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
        attachmenttext.body = 'my attachment text';
        attachmenttext.fileName = 'textfiletwo3.txt';
        attachmenttext.mimeTypeSubType = 'texttwo/plain';
        email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };
        
        PartnerUserRequestEmailCapturer objPartnerUserRequestEmailCapturer = new PartnerUserRequestEmailCapturer();
        objPartnerUserRequestEmailCapturer.handleInboundEmail(email, env);
    }
    Test.stopTest();
 }
 }