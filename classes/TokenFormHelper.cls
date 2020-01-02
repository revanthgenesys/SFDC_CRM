public without sharing class TokenFormHelper {
  
    // NOTE: use a helper class 'without sharing' to do privileged operations
    // https://developer.salesforce.com/page/Lightning_Security     
    
    private IEmailSender emailSender;
    
    public TokenFormHelper()
    {
        this(
            new EmailSender() 
        );        
    }
    
    public TokenFormHelper(
        IEmailSender emailSender)
    {
        this.emailSender = emailSender;
    }    
    
    public void buildAndSendEmail(TokenForm tf)
    {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        String toAddress ='';
        
        General_Custom_Settings__c tkfToAddress  = General_Custom_Settings__c.getValues('TokenFormToAddress');

            if (tkfToAddress != null)
            {
                toAddress = tkfToAddress.value__c;
            }
        
        
        if(String.isEmpty(toAddress)){
            System.debug('TokenFormToAddress general custom setting not set.');
            return;
        }
        
        
        String replytoAddress ='';
        
        General_Custom_Settings__c tkfReplyToAddress  = General_Custom_Settings__c.getValues('TokenFormReplyToAddress');

        if (tkfReplyToAddress != null)
            {
                replytoAddress = tkfReplyToAddress.value__c;
            }
        
        String noReplyOrgWideAddressID ='';
        
        General_Custom_Settings__c tkfOrgWideNoReplyAddress  = General_Custom_Settings__c.getValues('NoReplyOrgWideEmailId');

        if (tkfOrgWideNoReplyAddress != null)
            {
                noReplyOrgWideAddressID = tkfOrgWideNoReplyAddress.value__c;
            }
        
        // NikM 16-Feb-2018: External send of email no longer required based on BusReq
        // NikM 22-Mar-2018: Business asked to have sending to purchaser re-enabled (not Contact though)
        List<String> externalToAddresses = new List<String>();
        
        if(!String.isEmpty(tf.purchaserEmail)){        
          externalToAddresses.add(tf.purchaserEmail);
        }
    
        //if(!String.isEmpty(tf.contactEmail)){
        //    externalToAddresses.add(tf.contactEmail);
        //}
        
        
        String subject = tf.getEmailSubject();
        String body = tf.getEmailBody();      
        
        Messaging.SingleEmailMessage internalMail = new Messaging.SingleEmailMessage();        
        internalMail.setOrgWideEmailAddressId(noReplyOrgWideAddressID);        
        internalMail.setToAddresses(toAddress.split(';'));
        internalMail.setSubject(subject);
        internalMail.setHtmlBody(body);
        
        Messaging.SingleEmailMessage externalMail = new Messaging.SingleEmailMessage();
        externalMail.setOrgWideEmailAddressId(noReplyOrgWideAddressID);
        externalMail.setToAddresses(externalToAddresses); 
        externalMail.setSubject(subject);
        externalMail.setHtmlBody(body);
        
        if(!String.isEmpty(replyToAddress)){
            internalMail.setReplyTo(replyToAddress);
            externalMail.setReplyTo(replyToAddress);
        }       
        
        
        mails.add(internalMail);
        mails.add(externalMail);
        
        System.Debug('NikM >> About to send TokenForm emails');
        emailSender.send(mails);
    }
    
    
    public interface IEmailSender{
        void send(List<Messaging.SingleEmailMessage> mails);
    }
    
    public class EmailSender implements IEmailSender{
        public void send(List<Messaging.SingleEmailMessage> mails){ Messaging.sendEmail(mails); }
    }
    
}