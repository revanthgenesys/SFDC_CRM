global class clsPendingUserDeactivationJob implements Database.Batchable<sObject>,Database.Stateful
{
   /* Batch job used to deactivate the user which expiration date has been crossed.
      Batch job runs for single user at a time.It change the owner of records and records will assign to manager 
      of selected user.
   */

   global string UserId{get;set;}
   global string ManagerEmail{get;set;}
   global List<ObjectListDeactivationUser__c> lstObjList{get;set;}
   global boolean isError{get;set;}
  
  global clsPendingUserDeactivationJob (string sUserId,List<ObjectListDeactivationUser__c>lstOLst)
  {
    UserId = sUserId;
    lstObjList = lstOLst;
  }
  
  global Iterable<Sobject> Start(Database.BatchableContext bc)
  {
    List<User>lstUser = [Select id,name,ManagerId,Manager.Email,Manager.Name from User where id =:UserId ];
    return lstUser ;
  }
  
  global void Execute(Database.BatchableContext bc,List<Sobject>scope)
  {
    string sCurrentObjectName;
    string sCurrentUserName;
    string sBaseUrl;
    try{
      
      //Get Instance Base URL
      sBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
      isError = false;
      List<User>lstU = new List<User>();
      for(sObject u : scope)
      {
        User ou = (User)u;
        lstU.add(ou);
      }
      
      string EmailBody,mSubject;
      mSubject = 'Batch Process Status';
      EmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td colspan="6">Hi '+lstU[0].Manager.Name+',</td></tr>';
      EmailBody = EmailBody + '<tr><td colspan=""></td></tr>';
      EmailBody = EmailBody + '<tr><td colspan="">Please note that user <b> '+lstU[0].Name+' </b>is deactivated on dated '+Date.today().format()+'. Find the attached file of records which were owned by this user and now these are assigned to you.</td></tr>';
      EmailBody = EmailBody + '<tr><td colspan=""></td></tr></table>';
      
      //Populate manager email id of selected user
      ManagerEmail = lstU[0].Manager.Email;
      
      sCurrentUserName = lstU[0].Name;
      
      /*Iteration on list returned from custom setting.Custom setting contains the object names. 
      Custom setting name : ObjectListDeactivationUser__c*/
      string Result = '';
      string TotalResult = '';
      for(integer i=0;i<lstObjList.size();i++)
      {
        system.debug('++++lstObjList[i].Object_Name__c++  '+lstObjList[i].Object_Name__c);
        //Enter current object name
        sCurrentObjectName = lstObjList[i].Object_Name__c;
        
        //Fetch the selected user's data 
        List<sObject>lstObject;
        if(lstObjList[i].Query_Condition__c != null && lstObjList[i].Query_Condition__c != '')
          lstObject = Database.query('Select id,OwnerId from '+ lstObjList[i].Object_Name__c +' where OwnerId IN : lstU '+lstObjList[i].Query_Condition__c+''); 
        else 
          lstObject = Database.query('Select id,OwnerId from '+ lstObjList[i].Object_Name__c +' where OwnerId IN : lstU '); 
        system.debug('++++lstObject 11++'+lstObject);
        
        //Create Map
        Map<ID,sObject> mapCuurntObj = new Map<ID,sObject>();
        
        //Replacing owner with their manager
        for(sObject obj : lstObject)
        {
         mapCuurntObj.put(obj.id,obj);
         obj.put('OwnerId',lstU[0].ManagerId);
         //obj.put('OwnerId','');
        }
        
        system.debug('++++lstObject 22++'+lstObject);

        List<Database.SaveResult> updateResultsAcc = Database.update(lstObject , false);
        //Prepare html for email
        Result = ResultData2(updateResultsAcc,lstObjList[i].Object_Name__c,lstU,sBaseUrl,mapCuurntObj,sCurrentUserName );
        //EmailBody = EmailBody + Result;
        if(Result != '')
         TotalResult = TotalResult + Result;
      }
      
      /* Send current batch status to respective manager */
       EmailBody = EmailBody + '</body></html>';
      if(TotalResult != '')
      {
        /* Prepare CSV file and send email to respective manager */
        TotalResult  = 'Object Name' + ',' + 'Record Name' + ',' + 'Old Owner' + ',' + 'Record URL' + '\n' + TotalResult ;
        EmailNotification(EmailBody,mSubject,ManagerEmail,TotalResult );//ManagerEmail);
        system.debug('++++in Result +++');
      } 
      
      /*If any error occurs user record will not update */
      system.debug('++++isError+++'+isError);
      //if(!isError)
      //{
        system.debug('++++in if isError+++'+isError);
        //Deactivate that user
        User objUser = new User();
        objUser.id = lstU[0].id;
        objUser.Deactivation_Date__c = Date.today();
        objUser.Deactivation_By__c = UserInfo.getUserName();
        if(!isError)
         objUser.Is_Ownership_Changed__c = true;
                   
        update objUser;
      //}
    }
    catch(Exception ex)
    {
     string EmailBody,mSubject;
     mSubject = 'Btach Process Status';
     EmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td>Some error is found in batch process</td></tr>';
     EmailBody = EmailBody + '<tr><td>'+ex.getmessage()+'</td></tr></table></body></html>';
     EmailNotification(EmailBody,mSubject,'amit.singh@rsystems.com');//ManagerEmail); 
     
     //Insert Error log 
     Error_Log__c objErr = new Error_Log__c();
     objErr.Error_Description__c = ex.getmessage();
     objErr.Object_Name__c = sCurrentObjectName;
     objErr.User_Name__c = sCurrentUserName;
     objErr.Snippet_name__c = 'User deactivation batch process.';
     insert objErr;
    }
    
  }

  
  
  private string ResultData2(List<Database.SaveResult> lstResult,string ObjectName,List<User>lstU,string sBaseURL,Map<ID,sObject> mapCuurntObj,string sCurrentOwner)
  {
        List<Error_Log__c>lstErrorLog = new List<Error_Log__c>();
        string EmailBody ='';
        string sSuccessIds,sFailedIds;
        //sSuccessIds =  'Object Name' + ',' + 'Record Name' + ',' + 'Old Owner' + ',' + 'Record URL' + '\n';


        boolean isBlank = true;
            for(Integer i=0;i<lstResult.size();i++)
            {
              if (lstResult.get(i).isSuccess())
              {
                Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                Schema.SobjectType oType = gd.get(ObjectName);
                
                /*Get data from Map to bind in CSV file*/
                sobject objCurr = oType.newSObject();
                objCurr = mapCuurntObj.get(lstResult.get(i).getId());
                
                 system.debug('++++isSuccess+++'+lstResult.get(i));
                
                /*For success records*/ 
                if(sSuccessIds == null)
                  sSuccessIds =  ObjectName + ',' + String.valueOf(objCurr.get('Name')) + ',' + sCurrentOwner + ',' + sBaseURL + '/' + lstResult.get(i).getId() + '\n';
                else  
                  sSuccessIds = sSuccessIds + ObjectName + ',' + String.valueOf(objCurr.get('Name')) + ',' + sCurrentOwner + ',' + sBaseURL + '/' + lstResult.get(i).getId() + '\n';
                
                /*To check for any success record*/
                isBlank = false;
              }
             else if (!lstResult.get(i).isSuccess())
             {
                /*DML operation failed*/
                Database.Error error = lstResult.get(i).getErrors().get(0);
                //String failedDML = error.getMessage();
                //lstResult.get(i);//failed record from the list
                /*sFailedIds = sFailedIds + '<tr><td>';
                sFailedIds = sFailedIds + lstResult.get(i) + '   ' +   error.getMessage();
                sFailedIds = sFailedIds + '</td></tr>';*/
                system.debug('++++isFail+++'+error );
                
                //Prepare object for Error log 
                Error_Log__c objErr = new Error_Log__c();
                objErr.Error_Description__c = lstResult.get(i).getId() + '  ' + error.getMessage() + '  ' + lstResult.get(i).getErrors();
                objErr.Object_Name__c = ObjectName;
                objErr.User_Name__c = lstU[0].Name;
                objErr.Snippet_name__c = 'User deactivation batch process.';
                lstErrorLog.add(objErr);
             }
            }
            
            //Insert Error log 
            if(lstErrorLog != null && lstErrorLog.size()>0){
             insert lstErrorLog;
             isError = true;
            }  
            system.debug('++++lstErrorLog +++'+lstErrorLog );
            
            EmailBody = EmailBody + sSuccessIds;
            system.debug('++++isBlank+++'+isBlank);
            if(isBlank)
             EmailBody = '';
             
            system.debug('++++EmailBody +++'+EmailBody );    
          return EmailBody;
  }
  
  /*public string ResultData(List<Database.SaveResult> lstResult,string ObjectName,List<User>lstU,string sBaseURL)
  {

    List<Error_Log__c>lstErrorLog = new List<Error_Log__c>();
    
    //string EmailBody = '<table border="0" cellspacing="0" cellpadding="5"><tr><td>Batch process status of '+ObjectName+' object for all records.</td></tr>';
    string EmailBody ='';
    string sSuccessIds,sFailedIds;
    boolean isBlank = true;
    
    sSuccessIds = '<table>';
    sFailedIds = '<table><tr><td>Failed records</td></tr>';
    
    for(Integer i=0;i<lstResult.size();i++)
    {
      if (lstResult.get(i).isSuccess())
      {
        sSuccessIds = sSuccessIds + '<tr><td> Object : ' + ObjectName + '</td></tr>';
        sSuccessIds = sSuccessIds + '<tr><td><a>' + sBaseURL + '/' + lstResult.get(i).getId() + '</a></td></tr>';
        
        //To check for any success record
        isBlank = false;
      }
     else if (!lstResult.get(i).isSuccess())
     {
        // DML operation failed
        Database.Error error = lstResult.get(i).getErrors().get(0);
        //String failedDML = error.getMessage();
        //lstResult.get(i);//failed record from the list
        sFailedIds = sFailedIds + '<tr><td>';
        sFailedIds = sFailedIds + lstResult.get(i) + '   ' +   error.getMessage();
        sFailedIds = sFailedIds + '</td></tr>';
        
        //Prepare object for Error log 
        Error_Log__c objErr = new Error_Log__c();
        objErr.Error_Description__c = lstResult.get(i).getId() + '  ' + error.getMessage() + '  ' + lstResult.get(i).getErrors();
        objErr.Object_Name__c = ObjectName;
        objErr.User_Name__c = lstU[0].Name;
        objErr.Snippet_name__c = 'User deactivation batch process.';
        lstErrorLog.add(objErr);
     }
    }
    
    //Insert Error log 
    if(lstErrorLog != null && lstErrorLog.size()>0){
     insert lstErrorLog;
     isError = true;
    }  
    
    //Prepare final html
    sSuccessIds = sSuccessIds + '</table>';
    sFailedIds = sFailedIds + '</table>';
    
    //EmailBody = EmailBody + sSuccessIds + sFailedIds + '</table>';
    EmailBody = EmailBody + sSuccessIds;
    if(isBlank)
     EmailBody = '';
    return EmailBody;
  }*/
  
  global void Finish(Database.BatchableContext bc)
  {
    string EmailBody = '';
    string mSubject = 'Batch Process Status';
    string EmailBodyMsg = '';
   try
   {
     
     AsyncApexJob objAsy = [SELECT Status FROM AsyncApexJob WHERE id =: bc.getJobId()];
                             
                             
     if(objAsy != null && objAsy.Status == 'Completed'){
       EmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td> Process has been completed successfully. </td></tr></table></body></html>';
       //EmailNotification(EmailBody,mSubject,ManagerEmail);
     } 
    } 
    catch(Exception ex)
    {
     EmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td> '+ex.getmessage()+' </td></tr></table></body></html>';
     //EmailNotification(EmailBody,mSubject,'amit.singh@rsystems.com'); 
    }  
  }
  
  private void EmailNotification(string mailBody,string mailSubject,string MgrEmail){

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new String[]{MgrEmail};
    mail.setToAddresses(toAddresses);
    mail.setPlainTextBody(mailBody);
    mail.setHtmlBody(mailBody);
    mail.setSubject(mailSubject);
    if(!Test.isRunningTest())
      Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
  }
   private void EmailNotification(string mailBody,string mailSubject,string MgrEmail,string sCSVData){

   Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
   blob csvBlob = Blob.valueOf(sCSVData);
   string csvname= 'OwnerChangeRecords.csv';
   csvAttc.setFileName(csvname);
   csvAttc.setBody(csvBlob);

    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    String[] toAddresses = new String[]{MgrEmail};
    mail.setToAddresses(toAddresses);
    mail.setPlainTextBody(mailBody);
    mail.setHtmlBody(mailBody);
    mail.setSubject(mailSubject);
    mail.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
    if(!Test.isRunningTest())
      Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
  }
}