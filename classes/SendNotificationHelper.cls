public class SendNotificationHelper {
    
    
    public static void sendEmail(List<Dynamic_Query__c> dynamicQueryList){
        
           Dynamic_Query__c objDefault = null;
           
           if(dynamicQueryList.size() > 0){
               
               objDefault = dynamicQueryList[0];
               
               
           }
            
            if(objDefault != null && objDefault.is_active__c && objDefault.Process_Name__c == 'Default'){   
                                          
                    System.debug('objDefault ' + objDefault);  
                    
                    String orgWideEmail  = objDefault.From_Email__c;  
                    
                    //Set email ids
                    List<String> emails=new List<String>(); 
                    
                    if(objDefault.Emails__c != null && objDefault.Emails__c != '')
                        emails = objDefault.Emails__c.split(';');                                
                    
                    EmailTemplate template = [SELECT id,HtmlValue FROM EmailTemplate WHERE DeveloperName = :objDefault.Template_Name__c LIMIT 1];
                    
                    System.debug(' Report_Name__c' + objDefault.Report_Name__c);
                    
                    System.debug(' Template_Name__c ' + objDefault.Template_Name__c);
                    
                    System.debug(' Query_type__c ' + objDefault.Query_type__c);
                    
                    System.debug('emails ' + emails);
                    
                    //System.debug('Under Finish template ' + template.HtmlValue);
                    
                    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                    
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
                    mail.setToAddresses(emails);
                    
                    
                    //Setting Org Wide Email
                    if(orgWideEmail != null && orgWideEmail != ''){
                        
                        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = :orgWideEmail];
                        if ( owea.size() > 0 ) {
                            mail.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        
                        
                    }else{
                        // Specify the name used as the display name.
                        mail.setSenderDisplayName(''); 
                        
                    }
                    // Set to True if you want to BCC yourself on the email.
                    mail.setBccSender(false);
                    // Optionally append the salesforce.com email signature to the email.
                    // The email address of the user executing the Apex Code will be used.
                    mail.setUseSignature(false);
                    //Map the VF template
                    mail.setTargetObjectId(userinfo.getuseriD()); //Mandatory field when use template
                    
                    mail.setTreatTargetObjectAsRecipient(false);
                    
                    //mail.setWhatId(objDSRwithoutDesign.Opportunity_ID__c); //Assign Wow Id
                    mail.setTemplateId(template.Id);                    
                    // Send the email you have created.
                    mail.SaveAsActivity = false; //Mandatory field when use template
                    //Setting Subject as ReportName 
                    //mail.setSubject(dynamicQueryObj.Query_Name__c);
                    //string abc = template.HtmlValue;
                    //mail.setHtmlBody(abc);
                    //mail.setPlainTextBody(template.Body);
                    //System.debug('HTML Body ' + abc);
                    mails.add(mail);
                    
                    //Sending Single email as facing issue in content overwriting
                    if(!Test.isRunningTest())
                        Messaging.sendEmail(mails);
                
            }
        
        
        
        
    }

}