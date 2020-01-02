//Naresh Kumar  01/08/2014
public with sharing class SendEmail {

  public static void sendSingleEmail(String recipients, String subject, String htmlBody, String senderDisplayName, String cc, String bcc){
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> toAddresses = recipients.split(',');
    List<String> ccAddresses;
    List<String> bccAddresses;
    if(cc != null)
      ccAddresses = cc.split(',');
    if(bcc != null)
      bccAddresses = bcc.split(',');
    mail.setToAddresses(toAddresses);
    if(ccAddresses != null && ccAddresses.size() > 0)
      mail.setCcAddresses(ccAddresses);
    if(bccAddresses != null && bccAddresses.size() > 0)
      mail.setBccAddresses(bccAddresses);      
    mail.setSubject(subject);
    if(senderDisplayName == null){
      List<OrgWideEmailAddress> orgAdd = [SELECT id, Address FROM OrgWideEmailAddress WHERE DisplayName =: 'Genesys Customer Care' OR DisplayName =: 'Customer Care'];
      if(!orgAdd.isEmpty()){
          mail.setOrgWideEmailAddressId(orgAdd[0].id);
        }
    }
    else{
      mail.setSenderDisplayName(senderDisplayName);
    }
    mail.setHtmlBody(htmlBody);
    mails.add(mail);
    Messaging.sendEmail(mails);  
    
  }
  public static void sendSingleEmail(String recipients, String subject, String htmlBody){
    sendSingleEmail(recipients, subject, htmlBody, null);    
  }
  public static void sendSingleEmail(String recipients, String subject, String htmlBody, String senderDisplayName ){
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    List<String> toAddresses = recipients.split(','); 
    mail.setToAddresses(toAddresses);
    mail.setSubject(subject);
    if(senderDisplayName == 'Quote Approvals'){
        List<OrgWideEmailAddress> orgAdd = [SELECT id, Address FROM OrgWideEmailAddress WHERE DisplayName =: 'Quote Approvals'];
        if(!orgAdd.isEmpty()){
            mail.setOrgWideEmailAddressId(orgAdd[0].id);
        }
    }
    if(senderDisplayName == 'Genesys Partner Network Program'){
        List<OrgWideEmailAddress> orgAdd = [SELECT id, Address FROM OrgWideEmailAddress WHERE DisplayName =: 'Genesys Partner Network Program'];
        if(!orgAdd.isEmpty()){
            mail.setOrgWideEmailAddressId(orgAdd[0].id);
        }
    }
    else if(senderDisplayName == null){
      List<OrgWideEmailAddress> orgAdd = [SELECT id, Address FROM OrgWideEmailAddress WHERE DisplayName =: 'Genesys Customer Care' OR DisplayName =: 'Customer Care'];
      if(!orgAdd.isEmpty()){
          mail.setOrgWideEmailAddressId(orgAdd[0].id);
        }
    }
    else{
      mail.setSenderDisplayName(senderDisplayName);
    }
    mail.setHtmlBody(htmlBody);
    mails.add(mail);
    Messaging.sendEmail(mails);  
  }
    public static void sendSingleEmail(String recipients, String subject, String htmlBody, String senderDisplayName, String cc, String bcc, Attachment emailAttachment, String replyToAddress){
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    System.debug('NKC debug recipients ['+recipients+']');
    List<String> toAddresses = recipients.split(',');
    List<String> ccAddresses;
    List<String> bccAddresses;
    if(cc != null && cc != '')
      ccAddresses = cc.split(',');
    if(bcc != null && cc != '')
      bccAddresses = bcc.split(',');
    System.debug('NKC debug toAddresses ['+toAddresses+']');
    mail.setToAddresses(toAddresses);
    if(ccAddresses != null && ccAddresses.size() > 0)
      mail.setCcAddresses(ccAddresses);
    if(bccAddresses != null && bccAddresses.size() > 0)
      mail.setBccAddresses(bccAddresses);      
    mail.setSubject(subject);
    if(senderDisplayName == null){
      List<OrgWideEmailAddress> orgAdd = [SELECT id, Address FROM OrgWideEmailAddress WHERE DisplayName =: 'Genesys Customer Care' OR DisplayName =: 'Customer Care'];
      if(!orgAdd.isEmpty()){
          mail.setOrgWideEmailAddressId(orgAdd[0].id);
        }
    }
    else{
      if(senderDisplayName == 'Partner'){
        List<OrgWideEmailAddress> orgAdd = [SELECT id, Address FROM OrgWideEmailAddress WHERE Address=: 'partners@genesys.com'];
        if(!orgAdd.isEmpty()){
            mail.setOrgWideEmailAddressId(orgAdd[0].id);
        }
      }
      else{
        mail.setSenderDisplayName(senderDisplayName);
      }
    }
    
    if(emailAttachment != null && emailAttachment.body !=null){
        List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();  
        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();  
        efa.setFileName(emailAttachment.Name);  
        efa.setBody(emailAttachment.Body);  
        fileAttachments.add(efa);  
        mail.setFileAttachments(fileAttachments);
    }
    mail.setHtmlBody(htmlBody);
    mail.setReplyTo(replyToAddress);    
    mails.add(mail);
    Messaging.sendEmail(mails);  
    
  }
}