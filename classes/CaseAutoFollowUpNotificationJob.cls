global class CaseAutoFollowUpNotificationJob implements Database.Batchable<SObject>, Database.Stateful {
    String errorMsg;
    static List<String> NOTIFY_ON_ERRORS = new List<String>{'mariya.steason@genesyslab.com'};
    
    global CaseAutoFollowUpNotificationJob() {
        
    }
    
    global Database.Querylocator start(Database.BatchableContext ctx) {
         return Database.getQueryLocator([SELECT id, Status, ContactId, Auto_Follow_up_Start_Date__c, RecordType.DeveloperName,
                                                 Sub_Status__c                                             
                                          FROM Case                
                                          WHERE Status IN ('Awaiting Info','Solution Proposed',
                                                           'Replied','Open - Customer Care', 'Open - Product Management')
                                            AND Do_Not_Auto_Follow_Up__c != true
                                            AND Priority != 'Prod Down'                                  
                                            AND Auto_Follow_up_Start_Date__c != null
                                            AND Auto_Follow_up_Start_Date__c < YESTERDAY]); 
                                    
    }
    
    global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
        List<Case> caseList = (List<Case>) scope;
        List<Case> caseToUpdateList = new List<Case>();
        //List<Genesys_Case_Updates__c> caseUpdateToInsertList = new List<Genesys_Case_Updates__c>();
        List<FeedItem> caseUpdateToInsertList = new List<FeedItem>();
        
        errorMsg = CaseAutoFollowUpNotification.populateTemplateBodyMap();
        if ( String.isNotBlank(errorMsg) ) {
            return;
        }
        
        CaseAutoFollowupNotificationFactory caseAutoFollowupNotificationFactory = new CaseAutoFollowupNotificationFactory();
        for(Case caseToUpd : caseList){
            CaseAutoFollowupNotification caseAutoFollowupNotification = caseAutoFollowupNotificationFactory.createCaseAutoFollowUpNotification(caseToUpd);
            if (caseAutoFollowupNotification != null) {             
                  caseUpdateToInsertList.add(caseAutoFollowupNotification.getCaseUpdate());
                  caseToUpdateList.add(caseAutoFollowupNotification.getUpdatedCase());
            }
        }
        ///Add CaseUpdates
        if (caseUpdateToInsertList.size() > 0) {
            List<Database.SaveResult> dsrs = Database.insert(caseUpdateToInsertList, false);
        }
        
        // Update cases that need updating 
        if (caseToUpdateList.size() > 0) {
            List<Database.SaveResult> dsrs = Database.update(caseToUpdateList, false);
        }          
     } 
    
    global void finish(Database.BatchableContext ctx){
           AsyncApexJob aJob = [SELECT id, NumberOfErrors
                                FROM AsyncApexJob
                                WHERE id = :ctx.getJobId()];
            
            if ( aJob.NumberOfErrors > 0 || errorMsg != '' ) {
                String emailMessage = 'Auto Follow Up process completed with errors. \n' + 
                                      'Number of process Errors: ' + aJob.numberOfErrors + '.\n' +
                                      errorMsg;
             
                Messaging.SingleEmailMessage mail =
                      new Messaging.SingleEmailMessage();
                // String[] toAddresses = new String[] {UserInfo.getUserEmail()};
                mail.setToAddresses(NOTIFY_ON_ERRORS);
                mail.setReplyTo('noreply@genesyslab.com');
                mail.setSubject('Auto Followup Process Completed with Errors');
                mail.setPlainTextBody(emailMessage);
                mail.setHtmlBody(emailMessage);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[]
                                   { mail });
            }
    }
}