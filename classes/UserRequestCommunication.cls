public class UserRequestCommunication
{
  public string sTo{get;set;}
  public string sFrom{get;set;}
  public string sSubject{get;set;}
  public string sBody{get;set;}
  public string sOrgWideId{get;set;}
  public boolean blnShowErrorMsg{get;set;}
  public Partner_User_Request__c objUser{get;set;}
  
  public string sCc{get;set;}
  //public transient List<Attachment>list_AllAttach{get;set;}
  public string BaseURL{get;set;}
  public List<id>list_AttachIds{get;set;}
  
  public List<Attachment>list_Attachmnet{get;set;}
  
  public string DSId;
  public  Partner_User_Request__c objUserRequest;
  public boolean isRequester;
  public string fileName{get;set;}   
  public Blob fileBody{get;set;}
  public PageReference objRef;  
  public string sUsersIds{get;set;}
  String[] ccAddresses{get;set;}
  public string sEmailAdd;
  
  public UserRequestCommunication()
  {
    Init();
  }
  
  public void Init()
  {
    DSId = Apexpages.CurrentPage().getParameters().get('id');
    list_Attachmnet = new List<Attachment>(); 
    list_AttachIds = new List<id>();
    objUser=new Partner_User_Request__c();
    
    isRequester = false;
    sCc='';
    ccAddresses=new String[0];
    /*Get Base URL*/
     BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());
    //objUserRequest = [select id,Assigned_To__c,Assigned_To__r.Email,Requester__c,Requester_Email__c,subject__c,Description__c,Account__r.name,Opportunity__r.name,Quote__c from Partner_User_Request__c where id =:DSId];
    objUserRequest = [select id,name,Partner_Type__c,Assigned_To__c,Requester_Email__c,Assigned_To__r.Email,Requester__c,subject__c,Description__c,Account_Name__r.name,Company_Name__c,Country__r.name,Contact_Name__r.name,Email__c from Partner_User_Request__c where id =:DSId];
      // iTrack 26505: allowing anyone to send email (not just requestor/assignee)
      // so we need to set the from/to if another user is sending email.
      // A. Haun
      
      /*if(UserInfo.getUserId() == objUserRequest.Assigned_To__c){
           sTo = objUserRequest.Requester_Email__c;
          sFrom = objUserRequest.Assigned_To__r.Email;
          isRequester = false;
      } else if(UserInfo.getUserId() == objUserRequest.Requester__c){
          sTo = objUserRequest.Assigned_To__r.Email; 
          sFrom = objUserRequest.Requester_Email__c;
          isRequester = true;
      } else {
        sTo = objUserRequest.Requester_Email__c;
        sFrom = UserInfo.getUserEmail();
        isRequester = false;
      }*/
      
    //Setting the subject
    //sSubject = objUserRequest.Subject__c;
    sFrom = UserInfo.getUserEmail();
    sBody = '<b >Request Details </b><br/> <br/><b>Partner Request Number: </b>' +objUserRequest.Name +'<br/><b>Company Name:</b> ' + objUserRequest.Company_Name__c +'<br/><b>Partner Type: </b>' +objUserRequest.Partner_Type__c+'<br/><b>Country:</b> ' + objUserRequest.Country__r.name +'<br/><b>Contact Name:</b> ' + objUserRequest.Contact_Name__r.name +'<br/><b>Email:</b> ' + objUserRequest.Email__c +'<br/>';

  }
  
  public void SendEmail()
  {
    try
    {       
       string[]arrUser = sUsersIds.split(',');
       List<string>list_UserCc = new List<string>();
       for(integer i =0;i<arrUser.size();i++)
       {
         list_UserCc.add(arrUser[i]);
       }
      
        List<User>list_Users_Cc = [Select id,Email from User where id IN : list_UserCc];
        
        for(User objUser:list_Users_Cc )
            if(objUser.Email!=null)
            {
               ccAddresses.add(objUser.Email);
               if(sEmailAdd != null)
                 sEmailAdd +=  ',' +objUser.Email;
               else
                 sEmailAdd = objUser.Email; 
            }
        Config__c conf = Config__c.getValues('Partner User Request Email Service');
        ccAddresses.add(conf.Value__c);     
          
        sBody = sBody + '<br></br><br></br><br></br><br></br>ref:'+objUserRequest.id+':ref';
        
        List<Messaging.EmailFileAttachment>efa = BindAttachment();
        
        system.debug('+++objUserRequest.id++'+objUserRequest.id);
        system.debug('+++sSubject++'+sSubject);
        User objU = new User(id=UserInfo.getUserId());
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

        string[] arrToAddress = new string[1];
        arrToAddress[0] = sTo;//'amit.singh@rsystems.com';//
        
        if(isRequester)
        mail.setOrgWideEmailAddressId(sOrgWideId);
        mail.setToAddresses(arrToAddress);
        system.debug('ccAddresses '+ccAddresses);
        mail.setCcAddresses(ccAddresses);        
        mail.setWhatId(objUserRequest.id);
        mail.setSaveAsActivity(true);
        //mail.setPlainTextBody(sBody);
        mail.setHtmlBody(sBody);        
        mail.setSubject(sSubject);
        mail.setFileAttachments(efa);
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        for(Messaging.SendEmailResult rr:r){
            //System.debug('Email result ' + rr.IsSuccess());
            if(rr.IsSuccess())
            {
               blnShowErrorMsg = true;
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Email has been sent.'));
               //Create record for Communication
               if(blnShowErrorMsg)
               {
                 system.debug('+++++sSubject+++'+sSubject);
                  Communication__c objComm = new Communication__c();
                  objComm.To__c = sTo;
                  objComm.Cc__c = sEmailAdd;
                  objComm.From__c = sFrom;
                  objComm.Subject__c = sSubject;
                  objComm.Email_Body__c = sBody;
                  objComm.Partner_User_Request__c = DSId;
                  insert objComm;
               }
               
               //Clear subject and body
                sBody = '';
                sSubject = '';
                
                //Delete attachment
                delete list_Attachmnet;
               /* Common method */
                Init();
            }
        }
    }
    catch(Exception ex)
    {
      blnShowErrorMsg = true;
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
    }
  }
   /* Bind Attachment for Email */
   public List<Messaging.EmailFileAttachment> BindAttachment()
   {
     system.debug('++++BindAttachment+++');
     List<Messaging.EmailFileAttachment> list_FileAttachment = new List<Messaging.EmailFileAttachment>();
     
     list_Attachmnet = [Select id,Description,name,body from Attachment where Id IN : list_AttachIds];
     if(list_Attachmnet!=null && list_Attachmnet.Size()>0)
         for(Attachment objAttach : list_Attachmnet)
         {
           Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
           efa.setFileName(objAttach.name);
           efa.setBody(objAttach.body);
           list_FileAttachment.add(efa);
         }
     return list_FileAttachment;
   }
  public PageReference UploadFile()  
  {  
     if(fileBody == null || fileName == '') 
     {       
       blnShowErrorMsg = true;
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select the file.'));
       return null;
     }  
     
     system.debug('++++fileBody+++'+fileBody);
     system.debug('++++fileName+++'+fileName);
     Attachment obj = new Attachment();
     obj.Body = fileBody;
     obj.Name = 'FileAttachment:'+fileName;
     obj.ParentId = objUserRequest.id;
     obj.Description = '' ;
     insert obj;

     /* Add in the list*/
     //if(list_Attachmnet == null)
     //  list_Attachmnet = new List<Attachment>();
     
     //list_Attachmnet.add(obj);
     list_AttachIds.add(obj.id);
     GetAttachments();

     /*Clear variables*/
     fileBody =null;
     fileName = '';
     return objRef;
   }
   public void GetAttachments()
   {

     //if(objUserRequest.Id!=null)
     //{ 
        //list_AllAttach = new List<Attachment>();
        list_Attachmnet = [Select id,Description,name,body from Attachment where Id IN :list_AttachIds];
        system.debug('++++list_Attachmnet +++'+list_Attachmnet );
        
     //}
   }
   
}