/************************************************************************************
Purpose : Class to renew the Trial Subscripiton for PureCloud once the trial is over
Written By : Rony Joseph
Test Classes : ConvertPureCloudTrialSubscriptionsTest
*************************************************************************************/
global class  ConvertPureCloudTrialSubscriptions implements Database.Batchable<SObject>, Database.Stateful {
     //string to query  
    public String strQuery;
    //string to store object Name
    public String strObjName;
    //string to store where condition for soql query
    public String strWhereCondition;
    public List<Subscription__c> list_Sourcesubs = new List<Subscription__c>();
    Public List<Errormessage> list_Errormessage= new List<Errormessage>();
     global ConvertPureCloudTrialSubscriptions(String strWhrCond) 
    {
        strWhereCondition = strWhrCond;
    }
    
    // *** Start Method :  ***
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {   
        String strObjName = 'Subscription__c';
        strQuery = CloneUtility.getCreatableFieldsSOQL(strObjName, strWhereCondition);
        System.debug('strQuery'+strQuery);
        return Database.getQueryLocator(strQuery);
    }
    
     // *** Execute Method :***
    global void execute(Database.BatchableContext BC, List<SObject> sObjects) 
    {          
        Subscription__c objSubs = (Subscription__c)sObjects[0];
        try{
        String strResultMessage = CreateTrialRecords.CreateRecordforTrialAutomation(objSubs.Id,null,null,null,null);
        ErrorMessage objErrorMessage = new ErrorMessage();
        objErrorMessage.strSubscriptionId = (string)objSubs.Id;
        objErrorMessage.strErrorMessage = strResultMessage;    
        list_Errormessage.add(objErrorMessage);
        }catch (Exception e) {
            System.debug('Exception has occurred:'+e.getMessage()+'\n'+'Stacktrace:'+e.getStackTraceString());
            list_Sourcesubs.add(objSubs);
           system.debug('list_Sourcesubs' + list_Sourcesubs);
        }      
     
    }
    
    // *** Finish Method : Post Processing Logic ***
    global void finish(Database.BatchableContext BC) 
    {
        string header = 'CCDB/Subscription Id,Message\n';
        string finalstr = header ;
		string recordString;
        for(Errormessage strError : list_Errormessage ){
        recordString = strError.strSubscriptionId+','+strError.strErrorMessage+'\n';
        finalstr = finalstr +recordString;
            
		}

        if(recordString != null){
			Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            blob csvBlob = Blob.valueOf(finalstr);
            string csvname= 'ListofCCDBWithErrorinConversion.csv';
            csvAttc.setFileName(csvname);
            csvAttc.setBody(csvBlob);
            Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
            String[] toAddresses = new list<string> {'Rony.Joseph@genesys.com'};
            String subject ='Error during regulirization of Trial Subcriptions CCDB.';
            email.setSubject(subject);
            email.setToAddresses( toAddresses );
            email.setPlainTextBody('The CCDB listed in the attached has not been converted into regular Subscriptions');
            email.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
        }

    }   
    
    global class Errormessage{
        public string strSubscriptionId = '';
        public string strErrorMessage = '';
        
    }

}