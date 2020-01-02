trigger SendNotification on Dynamic_Query__c (after update) {

           if (Util.Bypass_Trigger_Chk) return;
                
           if(Trigger.isAfter && Trigger.isUpdate){
               
               
               
               SendNotificationHelper.sendEmail(Trigger.new);
               
                /*Dynamic_Query__c objDefault = [Select Process_Name__c,Emails__c,
                                                    Query_Name__c,Query_type__c,Report_Name__c,
                                                    Template_Name__c,From_Email__c
                                                    from Dynamic_Query__c 
                                                    where is_active__c = true and Process_Name__c = 'Default'];
                if(objDefault != null){                                  
                    System.debug('objDefault ' + objDefault);  
                    
                    String orgWideEmail  = objDefault.From_Email__c;  
                    
                    //Set email ids
                    List<String> emails=new List<String>(); 
                    
                    if(objDefault.Emails__c != null && objDefault.Emails__c != '')
                        emails = objDefault.Emails__c.split(';');                                
                    
                    EmailTemplate template = [SELECT id,HtmlValue FROM EmailTemplate WHERE DeveloperName = :objDefault.Template_Name__c LIMIT 1];
                    
                    
                    
                    //System.debug('Under Finish Template_Name__c ' + defaultDynamicQueryObj.Template_Name__c);
                    
                    //System.debug('Under Finish Query_type__c ' + defaultDynamicQueryObj.Query_type__c);
                    
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
                }*/
         }       
}