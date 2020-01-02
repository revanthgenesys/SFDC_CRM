//This batch will update Dynamic Query Default record that will be used in VF template controller
global class batchClassSendOPPReport implements Database.batchable<sObject>{

//Dynamic Query Object for fetching where condition
List<Dynamic_Query__c> objQuery = new List<Dynamic_Query__c>();
//Email list to whom email will be sent
List<string> emails = new List<string>();
//VF Template id
ID tempID;

//Store OWD email address
String orgWideEmail = null;

//Will refer to Dynamic Query Default record
Dynamic_Query__c defaultDynamicQueryObj = null;

/*//Constructor
global batchClassSendOPPReport (Dynamic_Query__c obj, List<string> objemails, ID objID){
        Dynamic_Query__c objNew = new Dynamic_Query__c();
        objNew = obj;
        objQuery.add(objNew);
        emails = objemails;
        tempID = objID;
    }*/
    
    global batchClassSendOPPReport (Dynamic_Query__c obj, List<string> objemails){
        Dynamic_Query__c objNew = new Dynamic_Query__c();
        objNew = obj;
        objQuery.add(objNew);
        emails = objemails;
        //tempID = objID;
    }

//Start method will return Dynamic Query record that contains where that will be used for generating email content
global Iterable<Sobject> Start(Database.BatchableContext bc){
      return objQuery;
   }


//Execute method will update Dynamic Query Default record with passed Dynamic_Query__c record. 
global void execute(Database.BatchableContext info, List<Dynamic_Query__c> scope){

Dynamic_Query__c objDefault = [Select Process_Name__c,Emails__c,
                                                    Query_Name__c,Query_type__c,Report_Name__c,
                                                    Template_Name__c,From_Email__c
                                                    from Dynamic_Query__c 
                                                    where is_active__c = true 
                                                    and Process_Name__c = 'Default' 
                                                    For Update];
       system.debug('Before -'+ objDefault);

       for(Dynamic_Query__c a : scope){
           objDefault.Report_Name__c = a.Report_Name__c;
           objDefault.Query_type__c = a.Query_type__c;
           objDefault.Query_Name__c = a.Query_Name__c;
           objDefault.Template_Name__c  = a.Template_Name__c;
           objDefault.Emails__c  = a.Emails__c;
           objDefault.From_Email__c  = a.From_Email__c;
           orgWideEmail = a.From_Email__c;
           
       }
       try{
            database.update(objDefault,false); 
            defaultDynamicQueryObj = objDefault;
       }catch(DMLException exp){
           
           system.debug('Exception -'+ exp);
       }
       
       
       system.debug('After -'+ objDefault);
   } 

//Finish method will send email to user having content as report data
global void finish(Database.BatchableContext info){ 
                
                /*Dynamic_Query__c objDefault = [Select Process_Name__c,Emails__c,
                                                    Query_Name__c,Query_type__c,Report_Name__c,
                                                    Template_Name__c,From_Email__c
                                                    from Dynamic_Query__c 
                                                    where is_active__c = true and Process_Name__c = 'Default'];
                                                    
                System.debug('objDefault ' + objDefault);                                    
                
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
                    Messaging.sendEmail(mails);*/
   
                //batchClassDeleteDefault obj = new batchClassDeleteDefault(defaultDynamicQueryObj);
                //Database.executebatch(obj,1);  
                
   }





}