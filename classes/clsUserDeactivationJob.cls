global class clsUserDeactivationJob implements Database.Batchable<sObject>,Database.Stateful{

   /* Batch job used to deactivate the user which expiration date has been crossed.
      Batch job runs for single user at a time.It change the owner of records and records will assign to manager 
      of selected user.
   */

    global string UserId{get;set;}
    global string ManagerEmail{get;set;}
    global List<ObjectListDeactivationUser__c> lstObjList{get;set;}
    global boolean isError{get;set;}
    global Map<id,boolean> mapUserStatus{get;set;}
    global string sFailedIds{get;set;}
  
    global clsUserDeactivationJob(string sUserId, List<ObjectListDeactivationUser__c> lstOLst){
        
        UserId = sUserId;
        lstObjList = lstOLst;
        mapUserStatus = new Map<id,boolean>();
        sFailedIds = 'Object Name' + ','  + 'Old Owner' + ',' + 'Record URL' + '\n' ;
    }
  
    global Iterable<Sobject> Start(Database.BatchableContext bc){
    
        List<User> lstUser = [Select id,name,ManagerId,Manager.Email,Manager.Name from User where id =:UserId ];
        return lstUSer;
       // return null ;
    }
  
    global void Execute(Database.BatchableContext bc,List<Sobject>scope){
    
        string sCurrentObjectName;
        string sCurrentUserName;
        string sBaseUrl;
        string sManagerName;

        try{

            //Get Instance Base URL
            sBaseUrl = URL.getSalesforceBaseUrl().toExternalForm();
            isError = false;
            List<User>lstU = new List<User>();
            
            for(sObject u : scope){
                User ou = (User)u;
                lstU.add(ou);
            }
            
            
            string EmailBody,mSubject;
            mSubject = 'Batch Process Status';
            EmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td colspan="6">Hi '+lstU[0].Manager.Name+',</td></tr>';
            EmailBody = EmailBody + '<tr><td colspan=""></td></tr>';
            EmailBody = EmailBody + '<tr><td colspan="">Please note that user <b> '+lstU[0].Name+' </b>has been deactivated on '+Date.today().format()+'. Find the attached file of records which were previously owned by this user. These records are now assigned to you.</td></tr>';
            EmailBody = EmailBody + '<tr><td colspan=""></td></tr></table>';
          
            //Populate manager email id of selected user
            ManagerEmail = lstU[0].Manager.Email;
            sManagerName = lstU[0].Manager.Name;
          
            sCurrentUserName = lstU[0].Name;
          
            
            string Result = '';
            string TotalResult = '';
            List<sObject> lstObject = new List<sObject>();
            
            /*Iteration on list returned from custom setting.Custom setting contains the object names. 
            Custom setting name : ObjectListDeactivationUser__c*/
            for(integer i=0; i < lstObjList.size(); i++){
                
                //Enter current object name
                sCurrentObjectName = lstObjList[i].Object_Name__c;
              
                /* Get custom setting data to maintain success records for current object*/
                boolean blnMaintainRecords = false;
                
                /* Custom setting to maintain the object list for which to ownership and can define the condition on every object to pick the records*/
                List<ObjectListDeactivationUser__c> list_ObjList = ObjectListDeactivationUser__c.getall().values();
                
                for(ObjectListDeactivationUser__c objObjList : list_ObjList){
                    if(objObjList.Object_Name__c == sCurrentObjectName && objObjList.For_Success_Records__c == true){
                        blnMaintainRecords = true;
                    }
                }
            
                //prepare the query to fetch the records for selected user and current object's . 
                string q = 'Select id,OwnerId from '+ lstObjList[i].Object_Name__c +' where OwnerId IN : lstU '+lstObjList[i].Query_Condition__c+'';
               
                
                /* if condtion is defined in custom setting(ObjectListDeactivationUser__c) for selected object then appends that condition with dynamic query */
                if(lstObjList[i].Query_Condition__c != null && lstObjList[i].Query_Condition__c != '')
                    lstObject = Database.query('Select id,OwnerId,name,Owner.Name from '+ lstObjList[i].Object_Name__c +' where OwnerId IN : lstU '+lstObjList[i].Query_Condition__c+' FOR UPDATE'); 
                else 
                    lstObject = Database.query('Select id,OwnerId,name,Owner.Name from '+ lstObjList[i].Object_Name__c +' where OwnerId IN : lstU FOR UPDATE'); 
             
              //Create Map to store the all records for selected object after replace the ownership with their manager
                Map<ID,sObject> mapCuurntObj = new Map<ID,sObject>();
            
                //Replacing owner with their manager
                for(sObject obj : lstObject){
             
                    mapCuurntObj.put(obj.id,obj);
                    obj.put('OwnerId',lstU[0].ManagerId);
                    //obj.put('OwnerId','');
              
                }
                
                /* Update all records */
                List<Database.SaveResult> updateResultsAcc = Database.update(lstObject , false);
                
                // ResultData2() : This method is used to insert success and failed records in separate objects and prepare and return the string of success records to prepare CSV file.
                Result = ResultData2(updateResultsAcc,lstObjList[i].Object_Name__c,lstU,sBaseUrl,mapCuurntObj,sCurrentUserName ,ManagerEmail,sManagerName,blnMaintainRecords );
            
                //EmailBody = EmailBody + Result;
                //For success records
                if(Result != '')
                    TotalResult = TotalResult + Result;

            }
          
           
               EmailBody = EmailBody + '</body></html>';
            system.debug('++++TotalResult  +++'+TotalResult  );
            /* Send current batch status for success records  to their respective manager */            
            //if(TotalResult != ''){
                /* Prepare CSV file and send email to respective manager for success records*/
                
                system.debug('++++TotalResult  +++  '+TotalResult  );
                system.debug('++++ManagerEmail +++  '+ManagerEmail);
                TotalResult  = 'Object Name' + ',' + 'Record Name' + ',' + 'Old Owner' + ',' + 'Record URL' + '\n' + TotalResult ;
                EmailNotification(EmailBody,mSubject,ManagerEmail,TotalResult );//ManagerEmail);
            //}  
            
            /*Email notification for failed records*/
            if(isError ){
                string EmailBody_err,mSubject_err ;
                mSubject_err = 'Failed records status';
                EmailBody_err = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td colspan="6">Hi ,</td></tr>';
                EmailBody_err = EmailBody_err+ '<tr><td colspan=""></td></tr>';
                EmailBody_err = EmailBody_err+ '<tr><td colspan=""> Find the attached file of faield records which were owned by '+sCurrentUserName +' this user.</td></tr>';
                EmailBody_err = EmailBody_err+ '<tr><td colspan=""></td></tr></table></body></html>';
                EmailNotification(EmailBody_err,mSubject_err,ManagerEmail ,sFailedIds);
            }
            
            //Deactivate that user
            
            /*User objUser = new User();
            objUser.id = lstU[0].id;
            objUser.isActive = false;
            objUser.Deactivation_Date__c = Date.today();
            objUser.Deactivation_By__c = UserInfo.getUserName();
            if(!isError)
             objUser.Is_Ownership_Changed__c = true;
            update objUser;*/
            
            /* Add all user in Map */
            /* If there are error during record updation in any record then add this user in map with value true.
               This is used to update the 'Is_Ownership_Changed__c' field on User object . We use this field in filter criteria to pick the user for deactivation. */
            if(!isError){
                mapUserStatus.put(lstU[0].id,false);
                //if(lstU[0].id == '005U0000006ihTQ') 
                //   mapUserStatus.put('aaaaaaaaaaaaaa',false);
                //else 
                //   mapUserStatus.put(lstU[0].id,false);  
            }  
            else  
                mapUserStatus.put(lstU[0].id,true);
          //}
            system.debug('User List >>>> '+mapUserStatus);
       }
        catch(Exception ex){
            
            string EmailBody,mSubject;
            mSubject = 'Batch Process Status';
            string errMsg = 'Message: ' + ex.getMessage() + 'Cause: ' + ex.getCause() + '  Line number: ' + ex.getLineNumber() ;
         
            EmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td>Some error is found in batch process</td></tr>';
            EmailBody = EmailBody + '<tr><td>'+errMsg +'</td></tr></table></body></html>';
            EmailNotification(EmailBody,mSubject,ManagerEmail);//ManagerEmail); 
         
            //Insert Error log 
            Error_Log__c objErr = new Error_Log__c();
            objErr.Error_Description__c = ex.getmessage();
            objErr.Object_Name__c = sCurrentObjectName;
            objErr.User_Name__c = sCurrentUserName;
            objErr.Snippet_name__c = 'User deactivation batch process.';
            insert objErr;
        }
    
    }

  /* Finish method used to Deactivate all user . We can not deactivate User in execute method because SetUp and Non-setup object can not update in same transaction.
     That's why add all users in Map(mapUserStatus) with their status(true/false). 
  */
    global void Finish(Database.BatchableContext bc){
        system.debug('>>>>>>>> Finish '+ mapUserStatus);
        string EmailBody = '';
        string mSubject = 'Batch Process Status !!!!!!';
        string EmailBodyMsg = '';
        List<User>lstusers = new List<User>();
        try{
            /* Deactivate all users */
                
            for(Id uId : mapUserStatus.keySet()){
                User objUser = new User();
                objUser.id = uId;
                objUser.isActive = false;
                objUser.Deactivation_Date__c = Date.today();
                objUser.Deactivation_By__c = UserInfo.getUserName();
                if(!mapUserStatus.get(uId))
                    objUser.Is_Ownership_Changed__c = true;
                else
                    objUser.Is_Ownership_Changed__c = false;
                lstusers.add(objUser);
            }
            
           update lstusers;
           AsyncApexJob objAsy = [SELECT Status FROM AsyncApexJob WHERE id =: bc.getJobId()];
                                 
                                 
            if(objAsy != null && objAsy.Status == 'Completed'){
                EmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td> Process has been completed successfully. </td></tr></table></body></html>';
                //EmailNotification(EmailBody,mSubject,ManagerEmail);
            } 
         }catch(Exception ex) {
             For(Id uid :mapUserStatus.keySet() ){
                 User u = new User();
                 u.Id  = uid ;
                 u.Error_Description__c = ex.getmessage();
                 u.Is_Deactivation_Error__c = true;
                 update u;
             }
         
            EmailBody = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td> '+ex.getmessage()+' </td></tr></table></body></html>';
            Error_Log__c objErr = new Error_Log__c();
            objErr.Error_Description__c = ex.getmessage();
            objErr.Object_Name__c = 'User';
            objErr.User_Name__c = UserId;
            objErr.Snippet_name__c = 'Users';
            //insert objErr;
        }  
    }
    
    private string ResultData2(List<Database.SaveResult> lstResult,string ObjectName,List<User>lstU,string sBaseURL,Map<ID,sObject> mapCuurntObj,string sCurrentOwner,string ManagerEml,string ManagerName,boolean blnIncludeRecords){
        List<Error_Log__c>lstErrorLog = new List<Error_Log__c>();
        string EmailBody ='';
        string sSuccessIds;
        //sSuccessIds =  'Object Name' + ',' + 'Record Name' + ',' + 'Old Owner' + ',' + 'Record URL' + '\n';
        //sFailedIds = 'Object Name' + ','  + 'Old Owner' + ',' + 'Record URL' + '\n' ;

        /* Insert records for success records*/
        List<Deactivation_Record_History__c> list_SuccessRec = new List<Deactivation_Record_History__c>();
        system.debug('++++lstResult++++'+lstResult);
            boolean isBlank = true;
            for(Integer i=0;i<lstResult.size();i++){
               
               /* This if statement is used for successfully updated records and prepare the CSV file for success records.
                   And insert these records in Deactivation_Record_History__c object. */
               if (lstResult.get(i).isSuccess()){
                    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                    Schema.SobjectType oType = gd.get(ObjectName);
                    
                    /*Get data from Map to bind in CSV file*/
                    sobject objCurr = oType.newSObject();
                    objCurr = mapCuurntObj.get(lstResult.get(i).getId());
                    
                    /*For success records*/ 
                    if(sSuccessIds == null)
                      sSuccessIds =  ObjectName + ',' + String.valueOf(objCurr.get('Name')) + ',' + sCurrentOwner + ',' + sBaseURL + '/' + lstResult.get(i).getId() + '\n';
                    else  
                      sSuccessIds = sSuccessIds + ObjectName + ',' + String.valueOf(objCurr.get('Name')) + ',' + sCurrentOwner + ',' + sBaseURL + '/' + lstResult.get(i).getId() + '\n';
                    
                    /* Add success records in list to insert data in Deactivation_Record_History__c object*/
                    if(blnIncludeRecords){
                        Deactivation_Record_History__c objDRH = new Deactivation_Record_History__c();
                        objDRH.New_Owner__c = ManagerName;
                        objDRH.Object_Type__c = ObjectName;
                        objDRH.Old_Owner__c = sCurrentOwner;
                        objDRH.Reassignment_Date__c = Date.today();
                        objDRH.Record_URL__c = sBaseURL + '/' + lstResult.get(i).getId();
                        list_SuccessRec.add(objDRH);
                    }   
                    
                    /*To check for any success record*/
                    isBlank = false;
                }else if (!lstResult.get(i).isSuccess()){  /* This statement is used to check failed records. and maintain the history for failed records with their in Error_Log__c object*/
                
                    
                    /*DML operation failed*/
                    Database.Error error = lstResult.get(i).getErrors().get(0);
                    
                    system.debug('+++error+++'+error);
                    
                    //String failedDML = error.getMessage();
                    //lstResult.get(i);//failed record from the list
                    
                    /*sFailedIds = sFailedIds + '<tr><td>';
                    sFailedIds = sFailedIds + lstResult.get(i) + '   ' +   error.getMessage();
                    sFailedIds = sFailedIds + '</td></tr>';*/
                    
                    //Prepare object for Error log 
                    Error_Log__c objErr = new Error_Log__c();
                    objErr.Error_Description__c = lstResult.get(i).getId() + '  ' + error.getMessage() + '  ' + lstResult.get(i).getErrors();
                    objErr.Object_Name__c = ObjectName;
                    objErr.User_Name__c = lstU[0].Name;
                    objErr.Snippet_name__c = 'User deactivation batch process.';
                    lstErrorLog.add(objErr);
                    
                    /*Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
                    Schema.SobjectType oType = gd.get(ObjectName);
                    //Get data from Map to bind in CSV file
                    sobject objCurr = oType.newSObject();
                    objCurr = mapCuurntObj.get(lstResult.get(i).getId());*/
                    
                    /* Prepare CSV file for failed records and send email to respective manager */
                    if(sFailedIds == null)
                        sFailedIds =  ObjectName + ','  + sCurrentOwner + ',' + sBaseURL + '/' + lstResult.get(i).getId() + '\n';
                    else  
                        sFailedIds = sFailedIds + ObjectName + ',' + sCurrentOwner + ',' + sBaseURL + '/' + lstResult.get(i).getId() + '\n';
                }
            }
            
            //Insert Success records 
            if(list_SuccessRec != null && list_SuccessRec.size() >0)
                insert list_SuccessRec;
            
            //Insert Error log 
            if(lstErrorLog != null && lstErrorLog.size()>0){
                insert lstErrorLog;
              
                /*string EmailBody_err,TotalResult_Err,mSubject_err ;
                mSubject_err = 'Failed records status';
                EmailBody_err = '<html><body><table border="0" cellspacing="0" cellpadding="5"><tr><td colspan="6">Hi ,</td></tr>';
                EmailBody_err = EmailBody_err+ '<tr><td colspan=""></td></tr>';
                EmailBody_err = EmailBody_err+ '<tr><td colspan=""> Find the attached file of faield records which were owned by '+sCurrentOwner+' this user.</td></tr>';
                EmailBody_err = EmailBody_err+ '<tr><td colspan=""></td></tr></table></body></html>';
                EmailNotification(EmailBody_err,mSubject_err,ManagerEml,sFailedIds );*/
            
                isError = true;
            }  
            EmailBody = EmailBody + sSuccessIds;
            system.debug('++++EmailBody +++'+EmailBody);
            if(isBlank)
                EmailBody = '';
            return EmailBody;
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
        //String[] toAddresses = new String[]{MgrEmail};
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