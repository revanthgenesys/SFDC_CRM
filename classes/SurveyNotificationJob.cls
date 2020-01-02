/*
     SurveyNotificationJob batch = new SurveyNotificationJob();
     Database.executeBatch(batch, 10);

send notifications on these conditions:  
     if NPS is 7 or 8 AND after 48 hours, then send
     if NPS is < 7 AND after 72 hours, then send
*/

global class SurveyNotificationJob implements Database.Batchable<SObject>, Database.Stateful {
    
    global String ccAPAC;
    global String ccEMEA;
    global String ccLATAM;
    global String ccAmerica;
    global String alwaysCC;
    global String errMsg='';
    global ID fromAddr;
        
    global SurveyNotificationJob() {
        Survey_Notification_Settings__c notifSettings = Survey_Notification_Settings__c.getOrgDefaults();
        this.ccAPAC = notifSettings.APAC__c;
        this.ccEMEA = notifSettings.EMEA__c;
        this.ccLATAM = notifSettings.LATAM__c;
        this.ccAmerica = notifSettings.North_America__c;
        this.alwaysCC = notifSettings.Always_Copy__c;
                    
        List<OrgWideEmailAddress> fromadderLst = [SELECT id FROM OrgWideEmailAddress WHERE Address = 'musa.hanhan@genesys.com'];
        if ( !fromadderLst.isEmpty() )
            this.fromAddr = fromadderLst[0].Id;
        
    }
    
    global Database.Querylocator start(Database.BatchableContext ctx) {
         return Database.getQueryLocator([SELECT Id, Contact__r.Name, Account__r.Owner.Email, Account__r.Owner.Manager.Email,
                                                 Account__r.Name, NPS_Recommend_Rating__c, NPS_Rating__c, CreatedDate,
                                                 Account_Owner_Name__c, Account__r.CSM_Account_Owner__r.Email, Follow_Up_Comments__c,
                                                 Contact__c, Account__r.Country__r.Region__c, Easiness_of_doing_business_with_Genesys__c,
                                                 Verbatim_on_doing_business_with_Genesys__c, End_User_Country__c, Verbatim__c, Partner__c 
                                          FROM Survey_Response__c                                                               
                                          WHERE NPS_Rating__c NOT IN ('9','10')
                                            AND NPS_Rating__c != null
                                            AND Account__c != null
                                            AND NPS_Notification_Sent__c = null
                                            AND CreatedDate > :System.now().addhours(-96)       
                                            AND Survey_Type__c = 'Relationship']); 
    }
    
    global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
        List<Survey_Response__c> responseList = (List<Survey_Response__c>) scope;
        
        List<Messaging.SingleEmailMessage> msgListToSend = new List<Messaging.SingleEmailMessage>();
        List<Survey_Response__c> updateSurveys = new List<Survey_Response__c>();
        
        for ( Survey_Response__c srvResp : responseList ) {
            
            if ( srvResp.NPS_Rating__c < '7' &&  srvResp.CreatedDate > System.now().addhours(-72) )
                 continue;
            
            else if ( (srvResp.NPS_Rating__c == '7' || srvResp.NPS_Rating__c == '8') && srvResp.CreatedDate > System.now().addhours(-48) )
                 continue;
                 
            Messaging.SingleEmailMessage msg = new  Messaging.SingleEmailMessage();
            
            String[] toAddresses = getToAddress(srvResp);
            String[] ccAddresses = getCcAddress(srvResp);
            
            if (fromAddr != null)
               msg.setOrgWideEmailAddressId(fromAddr);
            else
                 msg.setSenderDisplayName('NPS Notifications');          
                                    
            msg.setToAddresses(toAddresses);
            msg.setCcAddresses(ccAddresses);        
            msg.setSubject('NPS response received for your customer.'); 
            msg.setPlainTextBody( getMsgBody(srvResp) ) ;             
            
            msgListToSend.add(msg);
            
            srvResp.NPS_Notification_Sent__c = System.now();
            updateSurveys.add(srvResp);
        }
        
        if ( !msgListToSend.isEmpty() )  {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail( msgListToSend, true );
            
            for (Messaging.SendEmailResult result : results) {
                   if ( ! result.isSuccess()) 
                       errMsg += result.getErrors()[0].getMessage() + '\n';
            }
            
            if ( errMsg == '' ) {
                update updateSurveys;           
            }
        }
    }
    
    global void finish(Database.BatchableContext ctx) {
           AsyncApexJob aJob = [SELECT id, NumberOfErrors
                                FROM AsyncApexJob
                                WHERE id = :ctx.getJobId()];
            
            if ( aJob.NumberOfErrors > 0 || errMsg != '' ) {
                String emailMessage = 'Survey Response Notification Job completed with errors. \n' + 
                                      'Number of process Errors: ' + aJob.numberOfErrors + '.\n' +
                                      errMsg + '  ';
             
                Messaging.SingleEmailMessage mail =
                      new Messaging.SingleEmailMessage();
                String[] toAddresses = new String[] { Label.Notify_On_Errors_Customer_Care };
                mail.setToAddresses(toAddresses);
                mail.setSubject('Survey Response Notification Job completed with errors');
                mail.setPlainTextBody(emailMessage);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]
                                   { mail });
            }       
    }
    
    global String[] getToAddress(Survey_Response__c srv) {
       String owner = srv.Account__r.Owner.Email;
       String mngr = srv.Account__r.Owner.Manager.Email;
       List<String> retValue = new List<String>();
       if(owner != null)
            retValue.add(owner);
       if(mngr != null)
            retValue.add(mngr);
       return retValue;         
    }
    
    global String[] getCcAddress(Survey_Response__c srv) {
        String ccAddr = alwaysCC;

        if ( srv.Account__r.Country__r.Region__c != null && srv.Account__r.Country__r.Region__c == 'APAC' && ccAPAC != null)
                 ccAddr += ', ' + ccAPAC;
        else if ( srv.Account__r.Country__r.Region__c != null && srv.Account__r.Country__r.Region__c == 'EMEA' && ccEMEA != null)
                  ccAddr += ', ' + ccEMEA;
        else if ( srv.Account__r.Country__r.Region__c != null && srv.Account__r.Country__r.Region__c == 'LATAM' && ccLATAM != null)
                  ccAddr += ', ' + ccLATAM;
        else if(ccAmerica != null)
                  ccAddr += ', ' + ccAmerica; 
                  
        if ( srv.Account__r.CSM_Account_Owner__r.Email != null )
                  ccAddr += ', ' + srv.Account__r.CSM_Account_Owner__r.Email;
                   
        List<String> addressList = new List<String>();
        String[] retValue = ccAddr.split(' *, *');
        return retValue;    
    }
    
    global String getMsgBody(Survey_Response__c srv) {
        String body;
        body = 'Dear ' + srv.Account_Owner_Name__c + ',\n\n';
        body += Label.Survey_Notification_Header;
        body += '\n\n';
        body += getFields(srv);     
        body += srv.NPS_Rating__c < '7' ? Label.Survey_Notification_Detractor_Footer : Label.Survey_Notification_Passive_Footer;

        return body;
    }
    
    global String getFields(Survey_Response__c srv)  {
        String retFields;
        
        retFields = 'Contact name: ' + srv.Contact__r.Name + '\n';
        retFields += 'Customer name: ' + srv.Account__r.Name + '\n';
        retFields += 'Country: ' + srv.End_User_Country__c + '\n';
        retFields += 'NPS score: ' + srv.NPS_Rating__c + '\n';
        retFields += 'Verbatim: ' + srv.Verbatim__c + '\n\n';
        retFields += 'Easiness of doing business with Genesys: ' +  srv.Easiness_of_doing_business_with_Genesys__c + '\n\n';
        retFields += 'Verbatim on doing business with Genesys: ' +  srv.Verbatim_on_doing_business_with_Genesys__c + '\n\n';
        retFields += 'NPS rating about Partner: ' + srv.NPS_Recommend_Rating__c + '\n\n';   
        retFields += 'Partner: ' +  srv.Partner__c + '\n\n';
        retFields += 'Follow Up Comments: ' + srv.Follow_Up_Comments__c + '\n\n';
        retFields += 'Survey record: ' + Label.Genesys_Authenticated_Base_URL + srv.id  + '\n\n';
     
        return retFields;
    }

}