public with sharing class FeedBackCommunication {
    

  public string sTo{get;set;}
  public string sFrom{get;set;}
  public string sSubject{get;set;}
  public string sBody{get;set;}
  public string sOrgWideId{get;set;}
  public boolean blnShowErrorMsg{get;set;}
  public Deal_Support__c objUser{get;set;}
  
  public string sCc{get;set;}
  //public transient List<Attachment>list_AllAttach{get;set;}
  public string BaseURL{get;set;}
  public List<id>list_AttachIds{get;set;}
  
  public List<Attachment>list_Attachmnet{get;set;}
  
  public string DSId;
  public  Deal_Support__c objDealSupport;
  public SMART_Feedback__c objFeedBackSupport;
  public boolean isRequester;
  public string fileName{get;set;}   
  public Blob fileBody{get;set;}
  public PageReference objRef;  
  public string sUsersIds{get;set;}
  public string sContactsIds{get;set;}
  String[] ccAddresses{get;set;}
  public static Feedback__c objDSC; 
  
  public static String FedObjId;

  public FeedBackCommunication() 
  {
    Init();     
  }

  public void Init()
  { 
    DSId = Apexpages.CurrentPage().getParameters().get('id'); 

    list_Attachmnet = new List<Attachment>(); 
    list_AttachIds = new List<id>();
    objUser=new Deal_Support__c();
    blnShowErrorMsg = false;
    isRequester = false;
    sCc='';
    ccAddresses=new String[0];
    /*Get Base URL*/
     BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());
     
    objFeedBackSupport = [select id,name,Assigned_To__c, Assigned_To__r.email, RecordType.Name, Use_Case_Feedback_Type__c, Focus_Area__c, 
                           Use_Case_Id__c,Use_Case_Name__c, Feedback_Sent_To__c, Attachment_Id__c, Sold_To_Account__r.Name, Opportunity__r.Name, Owner.Email, 
                           Product_Feedback_Type__c, 
                           Submitter__r.Name, Submitter__r.email from SMART_Feedback__c where id =:DSId];
      
      if(objFeedBackSupport.Assigned_To__r.Email!=null)  {
        sFrom = objFeedBackSupport.Assigned_To__r.Email;
      }else{
        sFrom = objFeedBackSupport.Assigned_To__r.Email;
      }
       
      if(objFeedBackSupport.Submitter__r.email!=null)  {
        if(objFeedBackSupport.Feedback_Sent_To__c!=null)
        sTo   = objFeedBackSupport.Feedback_Sent_To__c; //objFeedBackSupport.Submitter__r.email;
        else
        sTo   = objFeedBackSupport.Owner.Email;
      }else{
        sTo   = objFeedBackSupport.Owner.Email;
      }
        isRequester = true;
      
    //Setting the subject
    WowBaseURL__c objWOW = WowBaseURL__c.getOrgDefaults();
    
    if(objFeedBackSupport.RecordType.Name=='Use Case'){
      sSubject = 'With regard to Use Case Feedback Item  ' +objFeedBackSupport.name;
      sBody = 'Hi '+ objFeedBackSupport.Submitter__r.Name +',</b><br/>'+'</b><br/> In relation to your Use Case Feedback item  <a href="'+objWOW.BaseURL__c +'/'+ objFeedBackSupport.Id+'">'+ objFeedBackSupport.Name +'</a></b><br/> </b><br/> </b><br/> </b><br/>' +
                     +' Thanks, </b><br/> </b><br/>' +
                     +'Reference Information:</b><br/>';
                     if(objFeedBackSupport.Use_Case_Feedback_Type__c!=null)
      sBody =sBody  +'<b>Feedback Type     : '+  objFeedBackSupport.Use_Case_Feedback_Type__c +'</b><br/>';
                     if(objFeedBackSupport.Focus_Area__c!=null)
      sBody =sBody  +'<b>Focus Area        : '+  objFeedBackSupport.Focus_Area__c +'</b><br/>';
                     if(objFeedBackSupport.Use_Case_Id__c!=null)
       sBody =sBody +'<b>Ref               : '+  objFeedBackSupport.Use_Case_Id__c +'</b><br/>';
                     if(objFeedBackSupport.Use_Case_Name__c!=null)
       sBody =sBody +'<b>Use Case Name     : '+  objFeedBackSupport.Use_Case_Name__c +'</b><br/>';
                     if(objFeedBackSupport.Sold_To_Account__r.Name!=null)
      sBody =sBody +'<b>Account             : <a href="'+objWOW.BaseURL__c +'/'+ objFeedBackSupport.Sold_To_Account__c+'">'+  objFeedBackSupport.Sold_To_Account__r.Name +'</a></b><br/>';
                     if(objFeedBackSupport.Opportunity__r.Name!=null)
      sBody =sBody +'<b>Opportunity         : <a href="'+objWOW.BaseURL__c +'/'+ objFeedBackSupport.Opportunity__c+'">'+  objFeedBackSupport.Opportunity__r.Name +'</a></b><br/>';
    }
   
    if(objFeedBackSupport.RecordType.Name=='Product'){
      sSubject = 'With regard to Product Feedback Item  ' +objFeedBackSupport.name;
      sBody = 'Hi '+ objFeedBackSupport.Submitter__r.Name +',</b><br/>'+'</b><br/> In relation to your Product Feedback item  <a href="'+objWOW.BaseURL__c +'/'+ objFeedBackSupport.Id+'">'+ objFeedBackSupport.Name +'</a></b><br/> </b><br/> </b><br/> </b><br/>' +
                     +' Thanks, </b><br/> </b><br/>' +
                     +'Reference Information:';
                     if(objFeedBackSupport.Product_Feedback_Type__c!=null)
      sBody =sBody  +'<b>Feedback Type      : '+  objFeedBackSupport.Product_Feedback_Type__c +'</b><br/>';
                     if(objFeedBackSupport.Focus_Area__c!=null)
      sBody =sBody  +'<b>Feedback Category  : '+  objFeedBackSupport.Focus_Area__c +'</b><br/>';
                     if(objFeedBackSupport.Sold_To_Account__r.Name!=null)
      sBody =sBody +'<b>Account             : <a href="'+objWOW.BaseURL__c +'/'+ objFeedBackSupport.Sold_To_Account__c+'">'+  objFeedBackSupport.Sold_To_Account__r.Name +'</a></b><br/>';
                     if(objFeedBackSupport.Opportunity__r.Name!=null)
      sBody =sBody +'<b>Opportunity         : <a href="'+objWOW.BaseURL__c +'/'+ objFeedBackSupport.Opportunity__c+'">'+  objFeedBackSupport.Opportunity__r.Name +'</a></b><br/>';
    }
   
  }
  
  public void SendEmail()
  {
    try
    {   
       string[]arrUser     = sUsersIds.split(',');
       string[]arrContacts = sContactsIds.split(',');
      
       List<string>list_UserCc = new List<string>();
       List<string>list_ContactCc = new List<string>();
      
       for(integer i =0;i<arrUser.size();i++){
         list_UserCc.add(arrUser[i]);
       }
       for(integer i=0; i<arrContacts.size();i++){
         list_ContactCc.add(arrContacts[i]);
       }
      
       List<User> list_Users_Cc = [Select id,Email from User where id IN : list_UserCc];
       List<Contact> list_Contacts_Cc = [Select id,Email from Contact where id IN : list_ContactCc];
        
        for(User objUser:list_Users_Cc )
            if(objUser.Email!=null)
               ccAddresses.add(objUser.Email);
               
        for(Contact objUser:list_Contacts_Cc)
            if(objUser.Email!=null)
               ccAddresses.add(objUser.Email);
           
        sBody = sBody + '<br></br><br></br><br></br><br></br>ref:'+objFeedBackSupport.id+':ref';
        
        List<Messaging.EmailFileAttachment> efa = BindAttachment();
        User objU                               = new User(id=UserInfo.getUserId());
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
        string[] arrToAddress = new string[1];
        arrToAddress[0] = sTo;//'amit.singh@rsystems.com';//
        
        if(isRequester)
        mail.setOrgWideEmailAddressId(sOrgWideId);
        mail.setToAddresses(arrToAddress);
        system.debug('ccAddresses '+ccAddresses);
        mail.setCcAddresses(ccAddresses);        
        //mail.setWhatId(objFeedBackSupport.id);
        mail.setSaveAsActivity(true);
        //mail.setPlainTextBody(sBody);
        mail.setHtmlBody(sBody);        
        mail.setSubject(sSubject);
        mail.setFileAttachments(efa);
        //mail.setCcAddresses(new string[] {'test_deal_support_email_service@w-30cm1vb9t3ejyikkcj4pwnpfugtbk4x9o4o9v60o1sikoy80zz.z-mjsbwman.cs11.apex.sandbox.salesforce.com'});
        Messaging.SingleEmailMessage[] emailList = new Messaging.SingleEmailMessage[] {mail};
        

        Messaging.SendEmailResult [] r = Messaging.sendEmail(emailList);

        List<Feedback__c> ff = new List<Feedback__c>([select Id, Feedback_Loop__c,Subject__c,Email_Body__c, To__c, From__c from Feedback__c where id=:objFeedBackSupport.Attachment_Id__c limit 1]);
        if(ff.size()>0) 
        objDSC = ff[0]; 
        else {
          objDSC   = new Feedback__c();
          objDSC.Feedback_Loop__c = objFeedBackSupport.Id;
        }
        objDSC.Subject__c = emailList[0].getSubject();
        objDSC.Email_Body__c =emailList[0].getHtmlBody();
        objDSC.To__c = (emailList[0].getToAddresses())[0];
        objDSC.From__c = sFrom;
        upsert objDSC;
                

        for(Messaging.SendEmailResult rr:r){
            //System.debug('Email result ' + rr.IsSuccess());
            if(rr.IsSuccess())
            {
               //Clear subject and body
                //sBody = '';
                //sSubject = '';
                
                //Delete attachment
                //delete list_Attachmnet;
                
                /* Common method */
                //Init();
                
               blnShowErrorMsg = true;
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Email has been sent.'));
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
     List<Messaging.EmailFileAttachment> list_FileAttachment = new List<Messaging.EmailFileAttachment>();
     
     list_Attachmnet = [Select id,Description,name,body from Attachment where ParentId =: objFeedBackSupport.Attachment_Id__c];
     
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
     
     if(fileBody == null || fileName == ''){       
       blnShowErrorMsg = true;
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select the file.'));
       return null;
     }  
     
     system.debug('++++fileBody+++'+fileBody);
     system.debug('++++fileName+++'+Apexpages.CurrentPage().getParameters().get('id'));

     System.debug('>>>'+objDSC);

     if(objDSC==null)
     {
       objDSC = new Feedback__c();
       objDSC.Feedback_Loop__c = objFeedBackSupport.Id;
       insert objDSC;
     }

      Attachment obj = new Attachment();
      obj.Body = fileBody;
      obj.Name = 'FileAttachment:'+fileName;
      obj.ParentId = objDSC.Id;
      obj.Description = 'File Attachment' ;
      insert obj;
     // Attachement Save under the Feedback Communication. 
     System.debug('>>>' + obj.id);
     
     if(objDSC!=null){
       objFeedBackSupport.Attachment_Id__c = objDSC.id;
       update objFeedBackSupport;
     }

     list_AttachIds.add(obj.id);
     GetAttachments();

     /*Clear variables*/
     fileBody =null;
     fileName = '';
     FedObjId= objDSC.Id;

     return null;
   }

   public void GetAttachments()
   {

        list_Attachmnet = [Select id,Description,name,body from Attachment where Id IN :list_AttachIds];
        system.debug('++++list_Attachmnet +++'+list_Attachmnet );
   }
   
   public Boolean getIsPartnerUser(){
      return (UserInfo.getUserType() == 'PowerPartner');
   }
}