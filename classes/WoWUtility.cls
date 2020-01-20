/*
Created By:     Swastika Rajkhowa
Company:        Rsystems
Description:    To create common functions for WoW request form    
*/
public without sharing class WoWUtility { 
    class MsgInfo{
        string strMsgSub {get;set;}
        string strMsgBody {get;set;}
    } 
    
    //Get WoW request data 
    public static List< Wow_Request_Form__c> GetWoWRequestData(id WowID)
    {
        List<Wow_Request_Form__c> lstWoW=new List<Wow_Request_Form__c>();
        lstWoW=[SELECT SE__c,BC__c,IsBCOwner__c,IsSEOwner__c,FunctionalUseCase__c,ArchitectureBlueprints__c,Internal_Kick_Off_Date__c,Design_End_Date__c FROM Wow_Request_Form__c WHERE Id=:WowID];
        return lstWoW;
    }
     
    //Get all the rows from history based on the wow id and return a list
    public static List< Wow_Request_Form_History__c> GetHistoryData(id WowID)
    {
        List<Wow_Request_Form_History__c> lstWoWHistory=new List<Wow_Request_Form_History__c>();
        lstWoWHistory=[SELECT Action__c,Date__c,UserId__c,User_Type__c,WoW_Status_del__c, attachment_type__c, attachment_sub_type__c,w_o_w_stage__c FROM Wow_Request_Form_History__c WHERE WoW_Request_Id__c=:WowID ORDER BY Date__c DESC];
        return lstWoWHistory;
    }
        
    //Send emails to various peoples based on notification type
    //Renamed by Swastika on 29-12-2015 to send Notification from VF Template
    //Commented by Swastika-Rsystem -use VF template
    /*
    public static String SendEmailNotification_BackUp(string NotificationType, Id WowId){
        string strResult='Failed';
        //String[] toAddresses = new String[]{};
        list<Group> lstGroup=new List<Group>();
        list<GroupMember> lstGroupMem = new list<GroupMember>(); 
        list<User> lstUser=new list<User>();
        String[] aryUser = new String[]{}; 
        string strUserType='';
        list<MsgInfo> lstMsgInfo=new list<MsgInfo>();
        //Find current user and user name
        User Usr = new User();
        Usr = [SELECT Id,Name FROM User WHERE Id = : UserInfo.getUserId()];
        
        //get user type
        strUserType=GetUserType(Usr.Id,WowId,null);
                
        //Find the opportunity region
        list<Wow_Request_Form__c> lstWoW=[SELECT Id,Opportunity_Id__c, Opportunity_Id__r.Region__c,Opportunity_Id__r.Name,Opportunity_Id__r.Owner.Name,Opportunity_Id__r.Owner.Email,Opportunity_Id__r.End_User_Region__c,Lead__c ,Lead__r.Name,Lead__r.Email,Rejected_Status__c,SE__c,SE__r.Name,SE__r.Email,BC__c,BC__r.Name,BC__r.Email,SEM__c,SEM__r.Name,SEM__r.Email,AE__c,AE__r.Name, AE__r.Email,lastModifieddate FROM Wow_Request_Form__c WHERE Id=:WowID]; 
        system.debug('lstWoW '+lstWoW); 
        
        //Find the account Name from opportunity 
        list<Opportunity> lstOpp=[SELECT Account.Name FROM Opportunity WHERE Id=:lstWoW[0].Opportunity_Id__c];
        
        string strQueueName=GetQueueName(lstWoW[0].Opportunity_Id__r.End_User_Region__c);        
        try{ 
                if(NotificationType=='Lead Assigned' || NotificationType=='Lead SLA') //then find the members and their email ids in queue
                {
                    lstGroup=[Select Id from Group where type='Queue' and Name=:strQueueName]; //fetch queue id
                    lstGroupMem =[Select UserOrGroupId From GroupMember where GroupId in:lstGroup]; //fetch User id                   
                    //fetch email of queue users
                    Set<string> objUID=new Set<string>();
                    for(GroupMember obj: lstGroupMem )
                        objUID.Add(obj.UserOrGroupId );
                       
                    lstUser=[SELECT Name,Email FROM User WHERE Id in:objUID];
                } 
                //Find the list of email ids from queue if Notificationtype=Lead
                if(NotificationType=='Lead Assigned'){ 
                    //added user in send to array
                    for(User objUser:lstUser){
                            aryUser.clear(); 
                            lstMsgInfo.clear();
                            aryUser.add(objUser.Email);                          
                            lstMsgInfo=WoWUtility.GetNotificationMessage(NotificationType,Id.valueOf(lstWoW[0].Opportunity_Id__c),'','','','',string.valueof(objUser.Name),'',lstOpp[0].Account.Name,lstWoW[0].Opportunity_Id__r.Name,lstWoW[0].Opportunity_Id__r.Owner.Name,lstWoW[0].SE__r.Name,lstWoW[0].LastModifieddate.format('MM/dd/yyyy'));
                            SendEmail(aryUser,lstMsgInfo[0].strMsgBody,lstMsgInfo[0].strMsgSub);                   
                            }
                     }
                 else if (NotificationType=='Lead Submitted') {
                      aryUser.add(lstWoW[0].Opportunity_Id__r.Owner.Email);
                      lstMsgInfo=WoWUtility.GetNotificationMessage(NotificationType,Id.valueOf(lstWoW[0].Opportunity_Id__c),'','',strUserType,Usr.Name,lstWoW[0].Lead__r.Name,'',lstOpp[0].Account.Name,lstWoW[0].Opportunity_Id__r.Name,lstWoW[0].Opportunity_Id__r.Owner.Name,lstWoW[0].SE__r.Name,lstWoW[0].LastModifieddate.format('MM/dd/yyyy'));
                      SendEmail(aryUser,lstMsgInfo[0].strMsgBody,lstMsgInfo[0].strMsgSub);
                     } 
                 else if (NotificationType=='Lead SLA')//send email to all members in the queue in 24 hours interval
                  {
                      for(User objUser:lstUser)
                          {
                            aryUser.clear(); 
                            lstMsgInfo.clear();
                            aryUser.add(objUser.Email);
                            lstMsgInfo=WoWUtility.GetNotificationMessage(NotificationType,Id.valueOf(lstWoW[0].Opportunity_Id__c),'','',strUserType,Usr.Name,lstWoW[0].Lead__r.Name,'',lstOpp[0].Account.Name,lstWoW[0].Opportunity_Id__r.Name,lstWoW[0].Opportunity_Id__r.Owner.Name,lstWoW[0].SE__r.Name,lstWoW[0].LastModifieddate.format('MM/dd/yyyy'));
                            SendEmail(aryUser,lstMsgInfo[0].strMsgBody,lstMsgInfo[0].strMsgSub);
                          }
                     }
                 else if (NotificationType=='WoW Rejected') {
                      aryUser.add(lstWoW[0].Opportunity_Id__r.Owner.Email);
                      lstMsgInfo=WoWUtility.GetNotificationMessage(NotificationType,Id.valueOf(lstWoW[0].Opportunity_Id__c),'',lstWoW[0].AE__r.Name,'','' ,lstWoW[0].Lead__r.Name,lstWoW[0].Rejected_Status__c,lstOpp[0].Account.Name,lstWoW[0].Opportunity_Id__r.Name,lstWoW[0].Opportunity_Id__r.Owner.Name,lstWoW[0].SE__r.Name,lstWoW[0].LastModifieddate.format('MM/dd/yyyy'));
                      SendEmail(aryUser,lstMsgInfo[0].strMsgBody,lstMsgInfo[0].strMsgSub);
                     }
                 else if (NotificationType=='WoW Accepted') {
                      aryUser.add(lstWoW[0].Opportunity_Id__r.Owner.Email);
                      lstMsgInfo=WoWUtility.GetNotificationMessage(NotificationType,Id.valueOf(lstWoW[0].Opportunity_Id__c),'',lstWoW[0].AE__r.Name,'','' ,lstWoW[0].Lead__r.Name,'',lstOpp[0].Account.Name,lstWoW[0].Opportunity_Id__r.Name,lstWoW[0].Opportunity_Id__r.Owner.Name,lstWoW[0].SE__r.Name,lstWoW[0].LastModifieddate.format('MM/dd/yyyy'));
                      SendEmail(aryUser,lstMsgInfo[0].strMsgBody,lstMsgInfo[0].strMsgSub);
                     }
                 else if (NotificationType=='Lead Completed') {
                      aryUser.add(lstWoW[0].Lead__r.Email);
                      lstMsgInfo=WoWUtility.GetNotificationMessage(NotificationType,Id.valueOf(lstWoW[0].Opportunity_Id__c),'','',strUserType,Usr.Name,lstWoW[0].Lead__r.Name,'',lstOpp[0].Account.Name,lstWoW[0].Opportunity_Id__r.Name,lstWoW[0].Opportunity_Id__r.Owner.Name,lstWoW[0].SE__r.Name,lstWoW[0].LastModifieddate.format('MM/dd/yyyy'));
                      SendEmail(aryUser,lstMsgInfo[0].strMsgBody,lstMsgInfo[0].strMsgSub);
                     } 
                 else if (NotificationType=='AE') {
                      aryUser.add(lstWoW[0].Opportunity_Id__r.Owner.Email);
                      lstMsgInfo=WoWUtility.GetNotificationMessage(NotificationType,Id.valueOf(lstWoW[0].Opportunity_Id__c),'',lstWoW[0].AE__r.Name,'','' ,lstWoW[0].Lead__r.Name,'',lstOpp[0].Account.Name,lstWoW[0].Opportunity_Id__r.Name,lstWoW[0].Opportunity_Id__r.Owner.Name,lstWoW[0].SE__r.Name,lstWoW[0].LastModifieddate.format('MM/dd/yyyy'));
                      SendEmail(aryUser,lstMsgInfo[0].strMsgBody,lstMsgInfo[0].strMsgSub);
                     }                         
                 else if (NotificationType=='Virtual Team')
                     {
                      system.debug('Virtual Team');
                      system.debug('SE__c '+ lstWoW[0].SE__c);
                      system.debug('BC__c'+ lstWoW[0].BC__c); 
                         if(lstWoW[0].SE__c!=null) //if SE assign for the wow by lead
                         {
                         system.debug('SE__c '+ lstWoW[0].SE__c);
                          aryUser.add(lstWoW[0].SE__r.Email);
                          lstMsgInfo=WoWUtility.GetNotificationMessage(NotificationType,Id.valueOf(lstWoW[0].Opportunity_Id__c),lstWoW[0].SE__r.Name,'',GetUserType(lstWoW[0].SE__c,lstWoW[0].Id,null),'','','',lstOpp[0].Account.Name,lstWoW[0].Opportunity_Id__r.Name,lstWoW[0].Opportunity_Id__r.Owner.Name,lstWoW[0].SE__r.Name,lstWoW[0].LastModifieddate.format('MM/dd/yyyy'));
                          SendEmail(aryUser,lstMsgInfo[0].strMsgBody,lstMsgInfo[0].strMsgSub);  
                         }
                         if(lstWoW[0].BC__c!=null) //if BC assign for the wow by lead
                         {
                         system.debug('BC__c'+ lstWoW[0].BC__c); 
                          aryUser.clear(); 
                          lstMsgInfo.clear();                
                          aryUser.add(lstWoW[0].BC__r.Email);
                          lstMsgInfo=WoWUtility.GetNotificationMessage(NotificationType,Id.valueOf(lstWoW[0].Opportunity_Id__c),lstWoW[0].BC__r.Name,'',GetUserType(lstWoW[0].BC__c,lstWoW[0].Id,null),'','','',lstOpp[0].Account.Name,lstWoW[0].Opportunity_Id__r.Name,lstWoW[0].Opportunity_Id__r.Owner.Name,lstWoW[0].SE__r.Name,lstWoW[0].LastModifieddate.format('MM/dd/yyyy'));
                          SendEmail(aryUser,lstMsgInfo[0].strMsgBody,lstMsgInfo[0].strMsgSub);
                         }
                         if(lstWoW[0].SEM__c!=Null) //if SEM assign for the wow by lead
                         {
                          system.debug('SEM__c'+ lstWoW[0].SEM__c); 
                          aryUser.clear();
                          lstMsgInfo.clear();
                          aryUser.add(lstWoW[0].SEM__r.Email);
                          lstMsgInfo=WoWUtility.GetNotificationMessage(NotificationType,Id.valueOf(lstWoW[0].Opportunity_Id__c),lstWoW[0].SEM__r.Name,'',GetUserType(lstWoW[0].SEM__c,lstWoW[0].Id,null),'','','',lstOpp[0].Account.Name,lstWoW[0].Opportunity_Id__r.Name,lstWoW[0].Opportunity_Id__r.Owner.Name,lstWoW[0].SE__r.Name,lstWoW[0].LastModifieddate.format('MM/dd/yyyy'));
                          SendEmail(aryUser,lstMsgInfo[0].strMsgBody,lstMsgInfo[0].strMsgSub);
                         }
                     }
               
              
                  strResult='Successful';   
                  system.debug('lstMsgInfo'+lstMsgInfo);
           }
       catch(exception ex)
           {
               strResult='Failed';
           }           
        return strResult;
    }*/
    
    
    public static string GetWowStage(string WowStage)
    {
        string strWowStage=WowStage;
        
        if(strWowStage=='Lead Assign' || strWowStage=='Lead Completed')
            strWowStage='Leadership Queue';
        
        return strWowStage;
    }

    //Insert the history data for wow request
    public static Void CreateHistory(string Action,string UserId, string UserType, string WowStage,string Status, Id WowId){
        Wow_Request_Form_History__c objWoWHst=new Wow_Request_Form_History__c();
        objWoWHst.Action__c=Action;
        objWoWHst.UserId__c=UserId;
        objWoWHst.Date__c=System.now();
        objWoWHst.User_Type__c=UserType;
        objWoWHst.WoW_Status_del__c =Status;
        objWoWHst.WoW_Request_Id__c=WowId;
        objWoWHst.w_o_w_stage__c=GetWowStage(WowStage);
        insert objWoWHst;
    }

    //Insert the history data for wow request attachments
    public static Void CreateHistory(string Action,string AttachmentType, string AttachmentSubType, string UserId, string UserType, string WowStage,string Status, Id WowId){
        Wow_Request_Form_History__c objWoWHst=new Wow_Request_Form_History__c();
        objWoWHst.Action__c=Action;
        objWoWHst.UserId__c=UserId;
        objWoWHst.Date__c=System.now();
        objWoWHst.User_Type__c=UserType;
        objWoWHst.w_o_w_stage__c=GetWowStage(WowStage);
        objWoWHst.WoW_Status_del__c =Status;
        objWoWHst.WoW_Request_Id__c=WowId;
        objWoWHst.Attachment_Type__c=attachmenttype;
        objWoWHst.Attachment_Sub_Type__c=attachmentsubtype;
        insert objWoWHst;
    }
    
   
   //Get the user type from wow request based on user id
   //Modified by Swastika on 21/12/2015 to consider AssignTo
   public static string GetUserType(id UserID, Id WowID, string Event){
        string strResult='';
        //get profile Id of user
        string sProfileName = WoWUtility.GetProfileName(userinfo.getProfileId());  
        
        List<WoW_Virtual_Users__c>list_WowVUsers = new List<WoW_Virtual_Users__c>();
        list_WowVUsers = [Select id,Virtual_User__c,Virtual_User_type__c,Wow_Request_Form__c from WoW_Virtual_Users__c where Wow_Request_Form__c =: WowID];
        
        /*for(WoW_Virtual_Users__c objW : list_WowVUsers)
        {
          if(objW.Virtual_User__c == UserID)
            strResult = objW.Virtual_User_type__c;
        }*/
        

        
        List<Wow_Request_Form__c> lstWoW=new List<Wow_Request_Form__c>();
        lstWoW=[SELECT AE__c,Lead__c,SE__c,BC__c,SEM__c,Assignto__c,Assign_Queue__c,Opportunity_Id__r.Country_Sub_Region__c,Opportunity_Id__r.End_User_Region__c FROM Wow_Request_Form__c WHERE Id=:WowID];
           
        if(lstWoW.size()>0){ 
            if (lstWoW[0].Assignto__c== 'Lead Assign')
               if(UserID==lstWoW[0].AE__c) 
                    strResult='AE';
                else If (sProfileName=='System Administrator')  
                     strResult='System Administrator';
                else
                   strResult='Other'; 
               
            else if(lstWoW[0].Assignto__c=='AE' )
               //if (CheckLoggedInUserType(lstWoW[0].Assign_Queue__c ,UserID))    
               if(WoWUtility.getSubRegionalUsers(lstWoW[0].Opportunity_Id__r.End_User_Region__c,lstWoW[0].Opportunity_Id__r.Country_Sub_Region__c,UserINfo.getUserName()))
                    strResult='Leadership';
               else if(UserID==lstWoW[0].AE__c) 
                    strResult='AE';
                else If (sProfileName=='System Administrator')  
                     strResult='System Administrator';
                else
                   strResult='Other'; 
                      
            else if (lstWoW[0].Assignto__c=='Virtual Team' && Event== null)
            {
                //If the user not exist in the queue
                 //if (!CheckLoggedInUserType(lstWoW[0].Assign_Queue__c ,UserID))
                  if (!WoWUtility.getSubRegionalUsers(lstWoW[0].Opportunity_Id__r.End_User_Region__c,lstWoW[0].Opportunity_Id__r.Country_Sub_Region__c,UserINfo.getUserName()))
                     {
                         if (sProfileName=='System Administrator')
                              strResult='System Administrator';
                         else
                             strResult='Other';   
                     }
                 else //User Exist in the queue                 
                    if(UserID==lstWoW[0].Lead__c) 
                    strResult='Leadership';   
            }
            else if((lstWoW[0].Assignto__c=='Virtual Team' && Event=='Save') || lstWoW[0].Assignto__c== 'Lead Completed') 
            {
                /*if(UserID==lstWoW[0].SE__c)  
                    strResult='Solution Consultant'; //Modified by Swastika on 2015-12-23 from Engineer to Consultant
                else if(UserID==lstWoW[0].BC__c)  
                    strResult='Business Consultant';  
                else if(UserID==lstWoW[0].SEM__c )  
                    strResult='PS Sales Engagement Manager';
                else if(sProfileName=='System Administrator')  
                    strResult='System Administrator';
                else
                    strResult='Other';*/
                for(WoW_Virtual_Users__c objW : list_WowVUsers)
                {
                  if(objW.Virtual_User__c == UserID)
                    strResult = objW.Virtual_User_type__c;
                }        
            }
        }
        
        return strResult;
   }
   
   //Get the queue name based on oppty region
   public static String GetQueueName(string OpportunityRegion){
        string strQueueName='';
        if(OpportunityRegion=='LATAM'|| OpportunityRegion=='EMEA'||OpportunityRegion=='APAC'||OpportunityRegion=='North America')   {
            strQueueName=OpportunityRegion+' '+'SC Leadership Queue';
        }            
        return  strQueueName;   
    }    
   
    //create message body and subject as per Notification type
    //Commented by Swastika-Rsystems --use VF template
    /*public static List<MsgInfo> GetNotificationMessage(string NotificationType,Id OpptyID,string ConcernName,string strAE,string UserType,string UserName,string LeadName,string RejectedReason,string AccountName,string OpportunityName, string OpportunityOwner, string SEName, string LastModifiedDate){   
        List<MsgInfo> lstMsgInfo=new List<MsgInfo>();
        MsgInfo objMsgInfo=new MsgInfo();
        string strWowRequestURL=string.valueof(URL.getSalesforceBaseUrl().toExternalForm())+'/apex/wow_request_form?id='+OpptyID; 
        if(NotificationType=='Lead Assigned') //Original Notification to Leaders that DSR was submitted (Queue) 
        {
            objMsgInfo.strMsgSub='Wow Engagement DSR Submitted for '+AccountName+' '+OpportunityName;           
            objMsgInfo.strMsgBody='<html><body>Dear ' + LeadName + ',<br><br>A Wow Engagement DSR was submitted by '+ OpportunityOwner +' tied to '+OpportunityName+'. Click <a href='+ strWowRequestURL+'>here</a> to review the DSR as well as approve/reject and re-assign to appropriate Wow Engagement owner. <br><br>Thanks</body></html>';
             system.debug('strMsgBody'+objMsgInfo.strMsgBody);
          }
        else if(NotificationType=='Lead Submitted')//Email notification to AE that Wow Engagement was submitted 
            {
            objMsgInfo.strMsgSub='Wow Engagement DSR Submitted for '+AccountName+' '+OpportunityName;           
            objMsgInfo.strMsgBody='<html><body>Dear ' + OpportunityOwner+ ',<br><br>Your Wow Engagement DSR for '+OpportunityName+' has been submitted successfully. The request is currently awaiting approval and Solution Consultant and or Business Consultant assignment. Please click <a href='+ strWowRequestURL+'>here</a> to approve and reassign. Once the request is approved/rejected you will receive another notification.<br><br>Thanks</body></html>';
             system.debug('strMsgBody'+objMsgInfo.strMsgBody);
          } 
        else if(NotificationType=='Lead SLA')//Email notification that SLA was reached for re-assignment to Leaders 
            {
            objMsgInfo.strMsgSub='Wow Engagement DSR Submitted for '+AccountName+' '+OpportunityName;           
            objMsgInfo.strMsgBody='<html><body>Dear ' + LeadName + ',<br><br>A Wow Engagement DSR was submitted by '+ OpportunityOwner +' tied to '+OpportunityName+'. This DSR has been waiting your approval for 24 hours. Click <a href='+ strWowRequestURL+'>here</a> to review the DSR as well as approve/reject and re-assign to appropriate Wow Engagement owner. If you do not respond to the DSR in 24 hours, you will receive another notification. <br><br>Thanks</body></html>';
             system.debug('strMsgBody'+objMsgInfo.strMsgBody);
          } 
        else if(NotificationType=='WoW Rejected') //Email Notification to AE that Wow Engagement was rejected 
           {
            objMsgInfo.strMsgSub='Wow Engagement DSR Rejected for '+AccountName+' '+OpportunityName;     
            objMsgInfo.strMsgBody='<html><body>Dear ' + OpportunityOwner + ',<br><br>Your Wow Engagement DRS for '+OpportunityName+' has been rejected due to this reason: '+ RejectedReason +'. Please reach out to your regional Solution Consultant and Business Consultant manager with any questions.Click <a href='+ strWowRequestURL+'>here</a> to review leadership notes. <br><br>Thanks</body></html>';
          } 
        else if(NotificationType=='WoW Accepted') //Email Notification to AE that Wow Engagement was accepted 
           {
            objMsgInfo.strMsgSub='Wow Engagement DSR Accepted for '+AccountName+' '+OpportunityName;     
            objMsgInfo.strMsgBody='<html><body>Dear ' + OpportunityOwner + ',<br><br>Your Wow Engagement DSR for '+OpportunityName+' has been accepted and reassigned to '+SEName+'. You will receive a notification when this request has been completed. Please work closely with your assigned contact and click <a href='+ strWowRequestURL+'>here</a> to view where the DSR is in the process. <br><br>Thanks</body></html>';
          } 
        else if(NotificationType=='Lead Completed')
           {
            objMsgInfo.strMsgSub='Wow Engagement DSR is ready for final completion for '+UserName;
            objMsgInfo.strMsgBody='<html><body>Dear ' + LeadName + ',<br><br>A Wow Engagement DSR for '+ OpportunityName +' has been fully completed by '+SEName+' on '+LastModifiedDate+'. Please review finalized engagement by clicking <a href='+ strWowRequestURL+'>here</a> and mark as completed. If it is not complete with all documentation, please have by '+SEName+' review and make necessary changes. <br><br><br><br>Thanks</body></html>';
          }
        else if(NotificationType=='AE') //Email notification to leaders once Wow Engagement activities have been performed 
           {
            objMsgInfo.strMsgSub='Wow Engagement DSR has been fully completed '+AccountName+' '+OpportunityName;
            objMsgInfo.strMsgBody='<html><body>Dear ' + OpportunityOwner + ',<br><br>The Wow Engagement DSR for '+ OpportunityName +' has been fully completed by '+SEName+'. Please keep in contact with both Solution Consultant and PS members in order to make sure transition is done correctly and to full completion. Please click <a href='+ strWowRequestURL+'>here</a> to review full engagement.<br><br>Thanks</body></html>';
          }              
        else if(NotificationType=='Virtual Team')
            {
            objMsgInfo.strMsgSub='Wow Request Form is Assigned';
            objMsgInfo.strMsgBody='<html><body>Dear ' + ConcernName + ',<br><br>Please note you have been assigned as '+ UserType +' to the Wow Request. Please click <a href='+ strWowRequestURL+'>here</a> to review and provide all the required data. Once you are done please submit the page to assign the Lead.<br><br>Thanks</body></html>';
          }
        lstMsgInfo.add(objMsgInfo);
        system.debug('lstMsgInfo '+lstMsgInfo);   
        return  lstMsgInfo;           
    }*/
    
    //Common function to send email
    //Commented by Swastika-Rsystem --use VF template to send mail
     /*public static String SendEmail(String[] toAddresses, String body,string Subject){
          string strResult='Failed';
             try{
                    // Create a new single email message object
                    // that will send out a single email to the addresses in the To, CC & BCC list.
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                  
                    // Assign the addresses for the To and CC lists to the mail object.
                    mail.setToAddresses(toAddresses);
                    //mail.setCcAddresses(ccAddresses);
                    
                    // Specify the address used when the recipients reply to the email. 
                    //mail.setReplyTo('didier.comte@alcatel-lucent.fr');
                    
                    // Specify the name used as the display name.
                    mail.setSenderDisplayName('');
                    
                    // Specify the subject line for your email address.
                    mail.setSubject(Subject);
                    // Set to True if you want to BCC yourself on the email.
                    mail.setBccSender(false);
                    // Optionally append the salesforce.com email signature to the email.
                    // The email address of the user executing the Apex Code will be used.
                    mail.setUseSignature(false);
                    // Specify the text content of the email.            
                    mail.setHtmlBody(body);
                    // Send the email you have created.
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    strResult='Successful';
                    }    
                catch(exception ex)
                    {
                    strResult='Failed';
                    system.debug('ex '+ex.getMessage());
                    } 
             return strResult;        
         }*/
     
    public static string GetProfileName(Id ProfileId)
    {
      String profileName=[Select Id,Name from Profile where Id=:ProfileId].Name;
      return profileName;
    }
   //check the virtual team user as owner
   /*public static boolean GetSubmitStatus(id WoWId,id userid){
       Boolean IsOwner=true;
       List<Wow_Request_Form__c> lstWoWRequest=new List<Wow_Request_Form__c>();
       lstWoWRequest=WoWUtility.GetWoWRequestData(WoWId);
       //if user id is SE and owner is SE       
       if(lstWoWRequest[0].SE__c==userid && lstWoWRequest[0].IsSEOwner__c==true )
           {
               IsOwner=false;
           }
       //if user id is BC and owner is BC 
         if(lstWoWRequest[0].BC__c==userid && lstWoWRequest[0].IsBCOwner__c==true )
           {
               IsOwner=false;
           }  
       return IsOwner;
   }*/
   //get the mandatory error message when Virtual team submit the WoW request
    public static string GetMandatoryMessage(id WoWId)
        {
            string strMsg='';          
            boolean IsRiskAssessment=false;
         
            List< Wow_Request_Form__c> listWoWRequest=new List< Wow_Request_Form__c>();
            listWoWRequest=GetWoWRequestData(WoWId);
            Wow_Request_Form__c  objWoW=new Wow_Request_Form__c();  
            objWoW=listWoWRequest[0];

            List<Wow_Risk_Assessment__c> objWOwRiskAssessment =[select Id FROM wow_risk_assessment__c WHERE wow_request_id__c =:objWoW.Id];
            if(objWOwRiskAssessment != null && objWOwRiskAssessment.size()>0 )
                IsRiskAssessment = true;
            
             
          if(IsRiskAssessment == false) //Risk
             {
                if(strMsg=='') 
                 {
                   strMsg='Please fill Risk Assessment';  
                 }
                else
                  {
                    strMsg=strMsg+',  Risk Assessment'; 
                  }   
            }    
    
          
          if(strMsg!='')      //set full stop                     
              strMsg=strMsg+'.';
          return strMsg;
        }
        
      //After laed assigned to lead and every 24 hours it send a alert message to lead to assign the WoW request  
      /*public static void WoWRequestResponseAlert()
          {
              //Find the WoW reuest records who are in 'Lead Assigned' state and ModifiedDate should be greater than 24 hours
              List<Wow_Request_Form__c> lstWoW=[SELECT Id FROM Wow_Request_Form__c WHERE WoW_Status__c=:'Lead Assigned'];
              
          }*/  
     /* Check LoggedIn user in Queue */
   /*public Static boolean CheckLoggedInUserType(string sQueueName, Id UserId)
   {
     boolean isExist = false;
     // Get id of Queue based of name
     Group objGroup = [Select Id from Group where type=: 'Queue' and Name=: sQueueName];     
     
     //Now use this queue id to get the assigned members
     List<GroupMember>lstQueueUsers = [Select UserOrGroupId From GroupMember where GroupId =: objGroup.id];
     if(lstQueueUsers.size()>0) //Added by Swastika
         //Compare loggedIn user id with Queue's users
         for(GroupMember objGm : lstQueueUsers)
         {
           if(objGm.UserOrGroupId == UserId)
           {
             isExist = true;
           }
         }
     return isExist;
   }*/ 
   //Added by Swastika on 28/12/2015 to send email notification by associated VF Templates
   //Send emails to various peoples based on notification type
     public static String SendEmailNotification(string NotificationType, Id WowId,List<WoW_Virtual_Users__c>NewVT,List<WoW_Virtual_Users__c>OldVT){
        string strResult='Failed';
        //String[] toAddresses = new String[]{};
        list<Group> lstGroup=new List<Group>();
        list<GroupMember> lstGroupMem = new list<GroupMember>(); 
        list<User> lstUser=new list<User>();
        String[] aryUser = new String[]{}; 
        //string strUserType='';
        list<MsgInfo> lstMsgInfo=new list<MsgInfo>();
        list<WoW_Virtual_Users__c> list_OldVT = new  list<WoW_Virtual_Users__c>();
        //Find current user and user name
        User Usr = new User();
        Usr = [SELECT Id,Name FROM User WHERE Id = : UserInfo.getUserId()];
        
        //get user type
        //strUserType=GetUserType(Usr.Id,WowId,null); //not required
                
        //Find the opportunity region
        list<Wow_Request_Form__c> lstWoW=[SELECT Id,Opportunity_Id__c,Opportunity_Id__r.Lines_of_Businesses__c,Opportunity_Id__r.Owner.Segment__C, Opportunity_Id__r.Owner.Id,Opportunity_Id__r.Region__c,Opportunity_Id__r.Name,Opportunity_Id__r.Owner.Name,Opportunity_Id__r.Owner.Owner_Sub_Region__c, Opportunity_Id__r.Owner.Email,Opportunity_Id__r.End_User_Region__c,Opportunity_Id__r.Country_Sub_Region__c,Lead__c ,Lead__r.Name,Lead__r.Email,Rejected_Status__c,SE__c,SE__r.Name,SE__r.Email,BC__c,BC__r.Name,BC__r.Email,SEM__c,SEM__r.Name,SEM__r.Email,AE__c,AE__r.Name, AE__r.Email,lastModifieddate FROM Wow_Request_Form__c WHERE Id=:WowID]; 
        system.debug('lstWoW '+lstWoW); 
        
        //Find the account Name from opportunity 
        list<Opportunity> lstOpp=[SELECT Account.Name FROM Opportunity WHERE Id=:lstWoW[0].Opportunity_Id__c];
        
        string strQueueName=GetQueueName(lstWoW[0].Opportunity_Id__r.End_User_Region__c);        
        try{ 
                if(NotificationType=='Lead Assigned' || NotificationType=='Lead Completed') //then find the members and their email ids in queue
                {
                    //lstGroup=[Select Id from Group where type='Queue' and Name=:strQueueName]; //fetch queue id
                    //lstGroupMem =[Select UserOrGroupId From GroupMember where GroupId in:lstGroup]; //fetch User id                   
                    //fetch email of queue users
                    //Set<string> objUID=new Set<string>();
                    Set<string> set_LeadUserName=new Set<string>();
                    /*for(GroupMember obj: lstGroupMem )
                        objUID.Add(obj.UserOrGroupId );*/
                   
                    //List<string> listLeadUserName=getSubRegionalUsersForSharing(lstWoW[0].Opportunity_Id__r.End_User_Region__c,lstWoW[0].Opportunity_Id__r.Country_Sub_Region__c);
                    List<string> listLeadUserName=getSubRegionalNewUsersForSharing(lstWoW[0].Opportunity_Id__r.Owner.Segment__C,lstWoW[0].Opportunity_Id__r.Owner.Owner_Sub_Region__c, lstWoW[0].Opportunity_Id__r.Lines_of_Businesses__c);
                     
                    //lstUser=[SELECT Name,Email FROM User WHERE Id in:objUID];
                    for(string obj: listLeadUserName)
                        set_LeadUserName.Add(obj);
                        
                    lstUser=[SELECT Name,Email FROM User WHERE username in : set_LeadUserName];
                    system.debug('**lstUser**'+lstUser);
                } 
                //Find the list of email ids from queue if Notificationtype=Lead
                if(NotificationType=='Lead Assigned')
                { 
                    //added user in send to array
                    for(User objUser:lstUser)
                    {
                       aryUser.clear(); 
                       lstMsgInfo.clear();
                       //Update the Temp lead for all queue members for VF email template
                       lstWoW[0].Temp_Lead__c= objUser.Id;
                       Update lstWoW[0];  
                       SendEmailByTemplate(objUser.Id,'Wow Engagement Lead Assigned',lstWoW[0].Id);                                             
                    }                    
                 }
                else if(NotificationType=='Virtual Team Assigned' || NotificationType=='Virtual Team')
                { 
                     system.debug('++++In Wow Utility Virtusal Team+++');
                     system.debug('++++lstWoW[0].SE__c+++'+lstWoW[0].SE__c);
                     system.debug('++++lstWoW[0].BC__c +++'+lstWoW[0].BC__c );
                     system.debug('++++lstWoW[0].SEM__c+++'+lstWoW[0].SEM__c);
                    //Send Email TO SE,BC and SEM
                    Set<Id>set_UId = new Set<Id>();
                    //list_OldVT =[SELECT Virtual_User__c FROM WoW_Virtual_Users__c Where Wow_Request_Form__c =:WowId];
                    system.debug('**NewVT**'+NewVT);
                    system.debug('**list_OldVT**'+list_OldVT);
                    List<WoW_Virtual_Users__c> list_VT=getDiffVTList(NewVT,OldVT);
                    /*List<WoW_Virtual_Users__c> list_VT=[SELECT Virtual_User__c FROM WoW_Virtual_Users__c WHERE Wow_Request_Form__c=:lstWoW[0].Id];*/
                    
                     system.debug('**list_VT-----**'+list_VT);
                    for(WoW_Virtual_Users__c objVTUser : list_VT)
                        set_UId.add(objVTUser.Virtual_User__c);
                    /*if(lstWoW[0].SE__c != null )
                      set_UId.add(lstWoW[0].SE__c);
                    if(lstWoW[0].BC__c != null )
                      set_UId.add(lstWoW[0].BC__c);
                    if(lstWoW[0].SEM__c != null )
                      set_UId.add(lstWoW[0].SEM__c);*/
                          
                    system.debug('++++set_UId+++'+set_UId);
                    List<User>lstUs = [Select id,name,email from User where id IN : set_UId];
                    
                    //Send Email for SE,BC and SEM
                    for(User objU:lstUs)
                    {
                      SendEmailByTemplate(objU.Id,'Wow Engagement Virtual Team Assigned',lstWoW[0].Id);
                    }  
                 }
                 else if (NotificationType=='Lead Submitted') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'Wow Engagement Lead Submitted',lstWoW[0].Id);                     
                 } 
                 else if (NotificationType=='WoW Rejected') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'Wow Engagement Lead Rejected',lstWoW[0].Id);                      
                 }
                 else if (NotificationType=='WoW Accepted') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'Wow Engagement Lead Accepted',lstWoW[0].Id);                     
                 }
                 else if (NotificationType=='Lead Completed') 
                 {
                      //added user in send to array
                    for(User objUser:lstUser)
                    {
                            aryUser.clear(); 
                            lstMsgInfo.clear();
                            //Update the Temp lead for all queue members for VF email template
                            lstWoW[0].Temp_Lead__c= objUser.Id;
                            Update lstWoW[0];  
                            SendEmailByTemplate(objUser.Id,'Wow Engagement Lead Completed',lstWoW[0].Id);                                             
                     }
                      //SendEmailByTemplate(lstWoW[0].Lead__c,'Wow Engagement Lead Completed',lstWoW[0].Id);                     
                 } 
                 else if (NotificationType=='AE') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'Wow Engagement AE',lstWoW[0].Id);                    
                 }                
                  strResult='Successful';   
                  system.debug('lstMsgInfo'+lstMsgInfo);
           }
       catch(exception ex)
           {
               strResult='Failed';
               system.debug('abc1333');
           }           
        return strResult;
    } 
    
    /*public static String SendEmailNotification(string NotificationType, Id WowId){
        string strResult='Failed';
        //String[] toAddresses = new String[]{};
        list<Group> lstGroup=new List<Group>();
        list<GroupMember> lstGroupMem = new list<GroupMember>(); 
        list<User> lstUser=new list<User>();
        String[] aryUser = new String[]{}; 
        //string strUserType='';
        list<MsgInfo> lstMsgInfo=new list<MsgInfo>();
        //Find current user and user name
        User Usr = new User();
        Usr = [SELECT Id,Name FROM User WHERE Id = : UserInfo.getUserId()];
        
        //get user type
        //strUserType=GetUserType(Usr.Id,WowId,null); //not required
                
        //Find the opportunity region
        list<Wow_Request_Form__c> lstWoW=[SELECT Id,Opportunity_Id__c,Opportunity_Id__r.Owner.Id,Opportunity_Id__r.Region__c,Opportunity_Id__r.Name,Opportunity_Id__r.Owner.Name,Opportunity_Id__r.Owner.Email,Opportunity_Id__r.End_User_Region__c,Lead__c ,Lead__r.Name,Lead__r.Email,Rejected_Status__c,SE__c,SE__r.Name,SE__r.Email,BC__c,BC__r.Name,BC__r.Email,SEM__c,SEM__r.Name,SEM__r.Email,AE__c,AE__r.Name, AE__r.Email,lastModifieddate FROM Wow_Request_Form__c WHERE Id=:WowID]; 
        system.debug('lstWoW '+lstWoW); 
        
        //Find the account Name from opportunity 
        list<Opportunity> lstOpp=[SELECT Account.Name FROM Opportunity WHERE Id=:lstWoW[0].Opportunity_Id__c];
        
        string strQueueName=GetQueueName(lstWoW[0].Opportunity_Id__r.End_User_Region__c);        
        try{ 
                if(NotificationType=='Lead Assigned' || NotificationType=='Lead Completed') //then find the members and their email ids in queue
                {
                    lstGroup=[Select Id from Group where type='Queue' and Name=:strQueueName]; //fetch queue id
                    lstGroupMem =[Select UserOrGroupId From GroupMember where GroupId in:lstGroup]; //fetch User id                   
                    //fetch email of queue users
                    Set<string> objUID=new Set<string>();
                    for(GroupMember obj: lstGroupMem )
                        objUID.Add(obj.UserOrGroupId );
                       
                    lstUser=[SELECT Name,Email FROM User WHERE Id in:objUID];
                } 
                //Find the list of email ids from queue if Notificationtype=Lead
                if(NotificationType=='Lead Assigned')
                { 
                    //added user in send to array
                    for(User objUser:lstUser)
                    {
                       aryUser.clear(); 
                       lstMsgInfo.clear();
                       //Update the Temp lead for all queue members for VF email template
                       lstWoW[0].Temp_Lead__c= objUser.Id;
                       Update lstWoW[0];  
                       SendEmailByTemplate(objUser.Id,'Wow Engagement Lead Assigned',lstWoW[0].Id);                                             
                    }                    
                 }
                else if(NotificationType=='Virtual Team Assigned')
                { 
                     system.debug('++++In Wow Utility Virtusal Team+++');
                     system.debug('++++lstWoW[0].SE__c+++'+lstWoW[0].SE__c);
                     system.debug('++++lstWoW[0].BC__c +++'+lstWoW[0].BC__c );
                     system.debug('++++lstWoW[0].SEM__c+++'+lstWoW[0].SEM__c);
                    //Send Email TO SE,BC and SEM
                    Set<Id>set_UId = new Set<Id>();
                    //List<WoW_Virtual_Users__c> list_VT=getDiffVTList(NewVT,OldVT);
                    //List<WoW_Virtual_Users__c> list_VT=[SELECT Virtual_User__c FROM WoW_Virtual_Users__c WHERE Wow_Request_Form__c=:lstWoW[0].Id];
                    
                    if(lstWoW[0].SE__c != null )
                      set_UId.add(lstWoW[0].SE__c);
                    if(lstWoW[0].BC__c != null )
                      set_UId.add(lstWoW[0].BC__c);
                    if(lstWoW[0].SEM__c != null )
                      set_UId.add(lstWoW[0].SEM__c);
                          
                    system.debug('++++set_UId+++'+set_UId);
                    List<User>lstUs = [Select id,name,email from User where id IN : set_UId];
                    
                    //Send Email for SE,BC and SEM
                    for(User objU:lstUs)
                    {
                      SendEmailByTemplate(objU.Id,'Wow Engagement Virtual Team Assigned',lstWoW[0].Id);
                    }  
                 }
                 else if (NotificationType=='Lead Submitted') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'Wow Engagement Lead Submitted',lstWoW[0].Id);                     
                 } 
                 else if (NotificationType=='WoW Rejected') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'Wow Engagement Lead Rejected',lstWoW[0].Id);                      
                 }
                 else if (NotificationType=='WoW Accepted') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'Wow Engagement Lead Accepted',lstWoW[0].Id);                     
                 }
                 else if (NotificationType=='Lead Completed') 
                 {
                      //added user in send to array
                    for(User objUser:lstUser)
                    {
                            aryUser.clear(); 
                            lstMsgInfo.clear();
                            //Update the Temp lead for all queue members for VF email template
                            lstWoW[0].Temp_Lead__c= objUser.Id;
                            Update lstWoW[0];  
                            SendEmailByTemplate(objUser.Id,'Wow Engagement Lead Completed',lstWoW[0].Id);                                             
                     }
                      //SendEmailByTemplate(lstWoW[0].Lead__c,'Wow Engagement Lead Completed',lstWoW[0].Id);                     
                 } 
                 else if (NotificationType=='AE') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'Wow Engagement AE',lstWoW[0].Id);                    
                 }                
                  strResult='Successful';   
                  system.debug('lstMsgInfo'+lstMsgInfo);
           }
       catch(exception ex)
           {
               strResult='Failed';
           }           
        return strResult;
    } */
   //added by swastika on 29/12/2015 to send email from VF template
    public static String SendEmailByTemplate(Id UserId,String strTemplateName, Id WowId){
          string strResult='Failed';
             try{
                    // Create a new single email message object
                    // that will send out a single email to the addresses in the To, CC & BCC list.
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
                    // Specify the name used as the display name.
                    mail.setSenderDisplayName('');                   
                    // Set to True if you want to BCC yourself on the email.
                    mail.setBccSender(false);
                    // Optionally append the salesforce.com email signature to the email.
                    // The email address of the user executing the Apex Code will be used.
                    mail.setUseSignature(false);
                    //Map the VF template
                    mail.setTargetObjectId(UserId); //Mandatory field when use template
                    mail.setWhatId(WowId); //Assign Wow Id
                    mail.setTemplateId([select id from EmailTemplate where Name =: strTemplateName].id);  //Find the template on the basis of name                    
                    // Send the email you have created.
                    mail.SaveAsActivity = false; //Mandatory field when use template
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                    strResult='Successful';
                    }    
                catch(exception ex)
                    {
                    strResult='Failed';
                    system.debug('ex '+ex.getMessage());
                    } 
             return strResult;        
         }   
         
     public static void ShareWowRequest(List<User>list_Users,Wow_Request_Form__c objWow)
     {
         List<Wow_Request_Form__Share> jobShares = new List<Wow_Request_Form__Share>();
        
         for(User objUser : list_Users)
         {
             /** Create a new Wow_Request_Form_Share record to be inserted in to the Test_Share table. **/
             Wow_Request_Form__Share objWowReq = new Wow_Request_Form__Share();
             /** Populate the Test_Share record with the ID of the record to be shared. **/
             objWowReq.ParentId = objWow.Id;
             /* Then, set the ID of user or group being granted access. */
             objWowReq.UserOrGroupId = objUser.id;
             objWowReq.AccessLevel = 'Edit';
             objWowReq.RowCause = Schema.Wow_Request_Form__Share.RowCause.AE__c;
             jobShares.add(objWowReq);
         }
         insert jobShares;
     } 
     
     /*public static void ShareWowRequest(Group objGroup,Wow_Request_Form__c objWow)
     {
         List<Wow_Request_Form__Share> jobShares = new List<Wow_Request_Form__Share>();

         // Create a new Wow_Request_Form_Share record to be inserted in to the Test_Share table.
         Wow_Request_Form__Share objWowReq = new Wow_Request_Form__Share();
         // Populate the Test_Share record with the ID of the record to be shared. 
         objWowReq.ParentId = objWow.Id;
         // Then, set the ID of user or group being granted access. 
         objWowReq.UserOrGroupId = objGroup.id;
         objWowReq.AccessLevel = 'Edit';
         objWowReq.RowCause = Schema.Wow_Request_Form__Share.RowCause.AE__c;
         jobShares.add(objWowReq);

         insert jobShares;
     }*/   
     //the function return userid from custom setting
     public static boolean  getSubRegionalUsers(string Region,string SubRegion,string LogInUser){
         boolean IsExist=false;
         list<string> usersId=new list<string>();
         List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
         if(list_SubRegion.size()>0)
             for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion)
                 {
                 if(objSubRegion.Region__c==Region && objSubRegion.SubRegion__c==SubRegion && objSubRegion.Subregional_Leader__c==LogInUser)
                     IsExist=true;
                 }
         return IsExist;
     }
     public static boolean  getSubRegionalUsersForSC(string LogInUser){
         boolean IsExist=false;
         list<string> usersId=new list<string>();
         List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
         if(list_SubRegion.size()>0)
             for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion)
                 {
                     if(objSubRegion.Subregional_Leader__c==LogInUser)
                       IsExist=true;
                 }
         return IsExist;
     }
     public static List<string> getSubRegionalUsersForSharing(string Region,string SubRegion){
         
         List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
         List<string> list_FinalSubRegion=new List<string>();
         if(list_SubRegion.size()>0 && (SubRegion != '' && SubRegion != null)){
             for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
               if(objSubRegion.Region__c==Region && objSubRegion.SubRegion__c==SubRegion)
                 list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
             }
             
             //if no leader exist then pick all admin
            if(list_FinalSubRegion.size()<=0){
                for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                   if(objSubRegion.SubRegion__c == null)
                    list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
                } 
            } 
         }
         else {
            for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
              if(objSubRegion.SubRegion__c == null)
                 list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
            }
         }       
        return list_FinalSubRegion;
     }
     // Method added By RSystems 23-08-2017 as per Debora Email
     public static List<string> getSubRegionalNewUsersForSharing(String segment,String SubRegion, String offeringtype){
         
         List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
         List<string> list_FinalSubRegion=new List<string>();
         
         if(list_SubRegion.size() > 0 && (( segment != '' && SubRegion != null ) || offeringtype == 'PureCloud' ) ){
             for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                 
                if(objSubRegion.Offering_Type__c == offeringtype){
                    list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
                }
                else if(objSubRegion.Segment__c == segment && objSubRegion.SubRegion__c == SubRegion){
                    list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
                }
             }
             
             //if no leader exist then pick all admin
            if(list_FinalSubRegion.size()<=0){
                for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                   if(objSubRegion.Is_Admin__c)
                    list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
                } 
            } 
         }
         else {
            for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
              if(objSubRegion.Is_Admin__c)
                 list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
            }
         }       
        system.debug('##list_FinalSubRegion--'+list_FinalSubRegion);
        return list_FinalSubRegion;
     }
     
     
     public static List<string> getSubRegionalUsersForSharing(){
         
         List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
         List<string> list_FinalSubRegion=new List<string>();
         if(list_SubRegion.size()>0)
         {

             for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion)
             {
               list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
             }
             
             //if no leader exist then pick all admin
            if(list_FinalSubRegion.size()<=0)
            {
                for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion)
                {
                   if(objSubRegion.SubRegion__c == null)
                    list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
                } 
            } 
         }
         else
         {
            for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion)
            {
              if(objSubRegion.SubRegion__c == null)
                 list_FinalSubRegion.add(objSubRegion.Subregional_Leader__c);
            }
         }       
        return list_FinalSubRegion;
     }

     public static List<WoW_Virtual_Users__c> getDiffVTList(List<WoW_Virtual_Users__c> newVTlist,List<WoW_Virtual_Users__c> oldVTlist)
     {
         List<WoW_Virtual_Users__c> listDiffVT =new List<WoW_Virtual_Users__c>();
         boolean flag=false;
         if(oldVTlist!=null){
            for(WoW_Virtual_Users__c objNew : newVTlist)
                {
                flag=false;
                for(WoW_Virtual_Users__c objOld : oldVTlist)
                    {
                        if(objNew.Virtual_User__c==objOld.Virtual_User__c)
                           flag=true; 
                    }
                   if(flag==false) 
                      listDiffVT.add(objNew);
                }
         return listDiffVT;
         }
         else
          return newVTlist;
         
     }
     
    public static boolean IsVirtualTeamExist(string WowId,string LogInUser){
         boolean IsExist=false;         
         List<WoW_Virtual_Users__c> list_VT= [SELECT Virtual_User__c FROM WoW_Virtual_Users__c WHERE Wow_Request_Form__c=:WowId AND Virtual_User__c=:LogInUser];
         if(list_VT.size()>0)
            IsExist=true;           
         return IsExist;
     } 
    
    public static string VirtualTeamNames(string WowId){
         string VTNames='';                 
         List<WoW_Virtual_Users__c> List_VT= [SELECT Virtual_User__c,Virtual_User__r.Name FROM WoW_Virtual_Users__c WHERE Wow_Request_Form__c=:WowId];
         if(List_VT.size()>0)
            for(WoW_Virtual_Users__c objVT:List_VT)     
               VTNames=VTNames+objVT.Virtual_User__r.Name+',';  
         if(VTNames!='')
            VTNames=VTNames.Substring(0,VTNames.length()-1);           
         return VTNames;
     }     
    /*public static void DeleteWowAttachment(Id WowId,string type)
    {
        List<Wow_Attachments__c> list_wowAttachment=[SELECT Id FROM Wow_Attachments__c WHERE Wow_Request_Form__c=:WowId AND Type__c=:type];
        if(list_wowAttachment!=null && list_wowAttachment.size()>0)
            delete list_wowAttachment;
            
         List<Attachment> List_Attachment= [Select id,Description,name from Attachment where Parentid =:WowId AND Description=:type];    
             if(List_Attachment!=null && List_Attachment.size()>0) 
                 delete List_Attachment;
    }*/
    public static List<Wow_Sub_Regional_Users__c> getSubRegionalUsersName(string Region,string SubRegion){
        List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
        List<Wow_Sub_Regional_Users__c> list_FinalSubRegion=new List<Wow_Sub_Regional_Users__c>();
        if(list_SubRegion.size()>0 && (SubRegion != '' && SubRegion != null)){
       
            for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                if(objSubRegion.Region__c==Region && objSubRegion.SubRegion__c==SubRegion)
                    list_FinalSubRegion.add(objSubRegion);
            }
        
            //if no leader exist then pick all admin
            if(list_FinalSubRegion.size()<=0){
                for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                   if(objSubRegion.SubRegion__c == null)
                    list_FinalSubRegion.add(objSubRegion);
                } 
            }    
        }
        else{
            for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                if(objSubRegion.SubRegion__c == null)
                    list_FinalSubRegion.add(objSubRegion);
            }
        }        
        return list_FinalSubRegion;
     }
     
     // Method added by Rsystems 23-08-2017 as per Debora Email
     
     public static List<Wow_Sub_Regional_Users__c> getSubRegionalNewUsersName(String segment,String SubRegion, String offeringtype){
         system.debug('Entering into Method @@@@@@@@@getSubRegionalNewUsersName');
        List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
        List<Wow_Sub_Regional_Users__c> list_FinalSubRegion=new List<Wow_Sub_Regional_Users__c>();
       
        if(list_SubRegion.size() > 0 && (( String.isNotBlank(segment) && String.isNotBlank(SubRegion) ) || String.isNotBlank(offeringtype))){ //KK 19/12       
            for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                                if((String.isNotBlank(objSubRegion.Offering_Type__c))){ //KK 19/12

                if(objSubRegion.Offering_Type__c == offeringtype){
                    list_FinalSubRegion.add(objSubRegion);
                }
                                }
              if(String.isNotBlank(objSubRegion.Segment__c) && String.isNotBlank(objSubRegion.SubRegion__c )){ //KK 19/12                 
              if(objSubRegion.Segment__c == segment && objSubRegion.SubRegion__c == SubRegion){
                  system.debug('Segment##'+objSubRegion.Segment__c+'AND'+'Sub Region@@@'+objSubRegion.SubRegion__c);
                    list_FinalSubRegion.add(objSubRegion);
                }
            }
            }
            //if no leader exist then pick all admin
           /* if(list_FinalSubRegion.size() <= 0){
                for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                   if(objSubRegion.Is_Admin__c)
                    list_FinalSubRegion.add(objSubRegion);
                } 
            } */   
        }
        else{
            for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion){
                if(objSubRegion.Is_Admin__c)
                    list_FinalSubRegion.add(objSubRegion);
            }
        }        
        return list_FinalSubRegion;
     }
     
     
     //added by Swastika on 26-Oct-2016 to insert Subregional Leaders on insertion of SC <start>
     /*public static void InsertSCSubregionalUser(list<user> list_user, Id WowID)
     {
         list<SC_Engagement_Subregional_Leaders__c> list_SC_Subregioal= new list<SC_Engagement_Subregional_Leaders__c>();
         for(user objUser:list_user)
         {
            SC_Engagement_Subregional_Leaders__c objSC_Subregioal= new SC_Engagement_Subregional_Leaders__c();
            objSC_Subregioal.Subregional_Leader__c=objUser.Id;
            objSC_Subregioal.SC_Engagement_Form__c= WowID; 
            list_SC_Subregioal.add(objSC_Subregioal);
         }
         insert list_SC_Subregioal;
     }*/
      //added by Swastika on 26-Oct-2016 to insert Subregional Leaders on insertion of SC <end>
      //Added by Swastika on 26-Oct-2016 to find the subregional users <start>
     /* public static List<user> getSubRegionalUsersForReport(string Region,string SubRegion){
         
         List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
         List<user> list_FinalSubRegionalUser=new List<user>();
         if(list_SubRegion.size()>0 && (SubRegion != '' && SubRegion != null))
         {
             for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion)
             {
               if(objSubRegion.Region__c==Region && objSubRegion.SubRegion__c==SubRegion)
                 {
                 user objUser= [select Id FROM user where Username=:objSubRegion.Subregional_Leader__c];
                 if (objUser!=null)
                  list_FinalSubRegionalUser.add(objUser);   
                 }
             }
             
             //if no leader exist then pick all admin
            if(list_FinalSubRegionalUser.size()<=0)
            {
                for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion)
                {
                   if(objSubRegion.SubRegion__c == null)
                   {
                    user objUser= [select Id FROM user where Username=:objSubRegion.Subregional_Leader__c];
                    if (objUser!=null)
                      list_FinalSubRegionalUser.add(objUser);
                   } 
                } 
            } 
         }
         else
         {
            for(Wow_Sub_Regional_Users__c objSubRegion:list_SubRegion)
            {
              if(objSubRegion.SubRegion__c == null)
                  {
                    user objUser= [select Id FROM user where Username=:objSubRegion.Subregional_Leader__c];
                    if (objUser!=null)
                        list_FinalSubRegionalUser.add(objUser);
                }
            }
         }       
        return list_FinalSubRegionalUser;
     }*/
     //Added by Swastika on 26-Oct-2016 to find the subregional users <end>
     //Added by Swastika on 15-Feb-2017 to check whether the profile has read access <start>
      public static boolean  HasReadAccessibility(Id ProfileId){
         boolean hasAccess = false;
         List<WowAdminAccess__c> list_Access= WowAdminAccess__c.getall().values();
         List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:ProfileId LIMIT 1];
         String profileName = PROFILE[0].Name;
         if(list_Access.size()>0)
             for(WowAdminAccess__c objAccess : list_Access)
                 {
                 if(objAccess.Profile_Name__c==profileName && objAccess.IsAccessible__c == true)
                     hasAccess = true;
                 }
         return hasAccess;
     }
    //Added by Swastika on 15-Feb-2017 to check whether the profile has read access <end>
    
    public static boolean GlobalUser(string uId)
   {
     boolean blnIsGlobal = false; 
     Group objGroup = [Select Id from Group where type=: 'Regular' and Name=: 'Wow Admin Group'];
     List<GroupMember> list_GroupMem = new List<GroupMember>(); 
     list_GroupMem =[Select UserOrGroupId From GroupMember where GroupId =: objGroup.id];                   
     Set<string> objUID=new Set<string>();
     for(GroupMember obj: list_GroupMem)
     {
       objUID.Add(obj.UserOrGroupId );
       if(obj.UserOrGroupId == uId)
         blnIsGlobal = true;
     } 
     return blnIsGlobal;   
   }
}