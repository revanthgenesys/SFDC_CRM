/*Zameer vohra 
* Purpose of this class to trigger email notification to all the records present in Dynamic Query
* when conditons are met is_active__c=true and Process_Name__c = 'Default'
*/

public class DynamicQuery_BulkEmailSend {
    public static Map<string,EmailTemplate> EmailTempaltesMap;
    public static Map<string,OrgWideEmailAddress> OrgEmailsMap;
    public static List<Dynamic_Query__c> lstDynamicQueires;
    public static void SendEmailNotification(){
        EmailTempaltesMap = new Map<String,EmailTemplate>();
        OrgEmailsMap = new Map<String,OrgWideEmailAddress>();
        set<string> lstEmailTemplateNames = new set<string>();
        set<string> lstAddresses = new set<string>();
        List<string> lst = new List<string>{'aO10d000000000A'};
            lstDynamicQueires = [SELECT Process_Name__c,Emails__c,
                                 Query_Name__c,Query_type__c,Report_Name__c,
                                 Template_Name__c,From_Email__c
                                 FROM Dynamic_Query__c 
                                 WHERE ID IN :lst ];
        system.debug('lstDynamicQueires **** '+lstDynamicQueires);
        for(Dynamic_Query__c DQ : lstDynamicQueires){
            lstEmailTemplateNames.add(DQ.Template_Name__c);
            lstAddresses.add(DQ.From_Email__c);
        }
        //WHERE is_active__c = true AND Process_Name__c = 'Default'];
        system.debug('lstEmailTemplateNames **** '+lstEmailTemplateNames);
        system.debug('lstAddresses **** '+lstAddresses);
        List<EmailTemplate> lstEmailTemps = [SELECT Id,name,DeveloperName,htmlValue,body FROM EmailTemplate 
                                             WHERE DeveloperName IN :lstEmailTemplateNames];
        
        for(EmailTemplate ET :lstEmailTemps){
            EmailTempaltesMap.put(ET.DeveloperName,ET);
        }
        List<OrgWideEmailAddress> lstOWDEmail = [SELECT id,Address FROM OrgWideEmailAddress
                                                 WHERE Address IN : lstAddresses];
        for(OrgWideEmailAddress OWE : lstOWDEmail){
            OrgEmailsMap.put(OWE.Address, OWE) ;
        }
        system.debug('EmailTempaltesMap****** '+EmailTempaltesMap);
        system.debug('OrgEmailsMap****** '+OrgEmailsMap);
        //SEND EMAIL
        sendEmailToReceipeint(lstDynamicQueires);
    }
    private static void sendEmailToReceipeint(List<Dynamic_Query__c> records){
        //List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        for(Dynamic_Query__c DQ : records){
            List<String> emails=new List<String>(); 
            if(string.isNotBlank(DQ.Emails__c))
                emails = DQ.Emails__c.split(';');
            
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
            mail.setToAddresses(emails);
            
            EmailTemplate template = EmailTempaltesMap.get(DQ.Template_Name__c);
            system.debug('template**** '+template);
            if(template !=null)
                mail.setTemplateId(template.Id);
            if(OrgEmailsMap.containsKey(DQ.From_Email__c))
                mail.setOrgWideEmailAddressId(OrgEmailsMap.get(DQ.From_Email__c).Id);
            else
                mail.setSenderDisplayName(''); 
            mail.setBccSender(false);
            mail.setUseSignature(false);
            mail.setTargetObjectId(userinfo.getuserId()); 
            mail.setTreatTargetObjectAsRecipient(false);
            //mail.setTemplateId(template.Id);
            mail.SaveAsActivity = false;
           // mail.setHtmlBody(template.Body);
            //system.debug('mail ****** '+mail);
            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {mail};
                system.debug('mail ****** '+messages.size());
                try{
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                    if (results[0].success) {
                        System.debug('The email was sent successfully.');
                    } else {
                        System.debug('The email failed to send: '
                                     + results[0].errors[0].message);
                    }
                }catch(exception ex){
                    system.debug('Exception * '+ex);
                } 
        }
    }
}