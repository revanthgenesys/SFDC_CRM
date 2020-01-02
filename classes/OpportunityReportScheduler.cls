global class OpportunityReportScheduler implements Schedulable{
     
    /**    
    * @Description: execute method is overridden from Schedulable Interface. Gets invoked when scheduler invokes the class at defined time.
    * @Param: Scheduler Context
    * @Return: void
    */
    global void execute(SchedulableContext SC) {
        sendEmail();        
    }
    
     
    /**    
    * @Description: Method gets invoked from execute method and used to prepare email to be sent. getting the receipients and template and finally sending an email
    * @Param: none
    * @Return: void
    */
    public void sendEmail(){
        
        
        //Set email ids
        List<String> emails=new List<String>();
        
        Dynamic_Query__c defaultDynamicQueryRecord;
        List<Dynamic_Query__c> dynamicQueryList = [Select Process_Name__c,Emails__c,
                                                    Query_Name__c,Query_type__c,Report_Name__c,
                                                    Template_Name__c,From_Email__c from Dynamic_Query__c where is_active__c = true];
                                                    
        System.debug('dynamicQueryList ' +dynamicQueryList);                                            
        
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        
        //Picking Default Record
        for(Dynamic_Query__c dynamicQueryObj : dynamicQueryList){
            if(dynamicQueryObj.Process_Name__c == 'Default'){
                defaultDynamicQueryRecord = dynamicQueryObj;
            }
        } 
        
        //System.debug('defaultDynamicQueryRecord ' + defaultDynamicQueryRecord);
        
        //emails = getNotificationEmailID('OPP_Order_Report');
        
        System.debug('emails ' + emails);
         string batchId;
         
        //Iterating Records
        for(Dynamic_Query__c dynamicQueryObj : dynamicQueryList){
            if(dynamicQueryObj.Process_Name__c != 'Default'){
            
            if(dynamicQueryObj.Emails__c != null && dynamicQueryObj.Emails__c != '')
                emails = dynamicQueryObj.Emails__c.split(';');
            
            
            
            //EmailTemplate template = [SELECT id,HtmlValue,Body FROM EmailTemplate WHERE DeveloperName = :dynamicQueryObj.Template_Name__c LIMIT 1];
            
            system.debug('Query Object ' + dynamicQueryObj);
            //system.debug('Template ID ' + template.id);
            
            system.debug('emails ' + emails);
            
            
            batchClassSendOPPReport obj = new batchClassSendOPPReport(dynamicQueryObj,emails);
            batchId = Database.executebatch(obj,1);  
            }
        }                            
    }
    
  
    /*public string[] getNotificationEmailID(string Key)
     {
         EmailNotifications__c email = EmailNotifications__c.getValues(Key);
         string[] emails = email.emails__c.split(';');
         
         return emails;
     }*/
    
}