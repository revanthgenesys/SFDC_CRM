public class DealSupportCommunication
{
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
  public boolean isRequester;
  public string fileName{get;set;}   
  public Blob fileBody{get;set;}
  public PageReference objRef;  
  public string sUsersIds{get;set;}
  public string sContactsIds{get;set;}
  String[] ccAddresses{get;set;}
  
  public DealSupportCommunication()
  {
    Init();
  }
  
  public void Init()
  {
    DSId = Apexpages.CurrentPage().getParameters().get('id');
    list_Attachmnet = new List<Attachment>(); 
    list_AttachIds = new List<id>();
    objUser=new Deal_Support__c();
    
    isRequester = false;
    sCc='';
    ccAddresses=new String[0];
    /*Get Base URL*/
     BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());
    objDealSupport = [select id,name,Assigned_To__c,Assigned_To__r.Email,Requester__c,Requester__r.Name,Requester_Email__c,subject__c,Description__c,Account__r.name,Opportunity__r.name,Quote__c from Deal_Support__c where id =:DSId];
      // iTrack 26505: allowing anyone to send email (not just requestor/assignee)
      // so we need to set the from/to if another user is sending email.
      // A. Haun
      if(UserInfo.getUserId() == objDealSupport.Assigned_To__c){
           sTo = objDealSupport.Requester_Email__c;
          //2 lines added by Ankit
          sFrom = objDealSupport.Assigned_To__r.Email;
          isRequester = false;
      } else if(UserInfo.getUserId() == objDealSupport.Requester__c){
          sTo = objDealSupport.Assigned_To__r.Email; 
          //2 lines added by Ankit
          sFrom = objDealSupport.Requester_Email__c;
          isRequester = true;
      } else {
        // someone else is sending the email, set their address as 'from'
        // and set 'to' as the requestor
        sTo = objDealSupport.Requester_Email__c;
        sFrom = UserInfo.getUserEmail();
        isRequester = false;
      } 
    //Setting the subject
    WowBaseURL__c objWOW = WowBaseURL__c.getOrgDefaults();
    
   
    sSubject = objDealSupport.Subject__c;
    sBody = '<b>Details:</b><br/>' +objDealSupport.Description__c +'<br/><br/> <b>Requester:</b> '+objDealSupport.Requester__r.Name+' <br/> <b>DSR URL:</b>  <a href="'+objWOW.BaseURL__c +'/'+ objDealSupport.id+'">'+objDealSupport.name+'</a><br/> <b>Account:</b> ' + (String.isBlank(objDealSupport.Account__r.name)?'':objDealSupport.Account__r.name) +'<br/> <b>Opportunity Name:</b> ' +  (String.isBlank(objDealSupport.Opportunity__r.name)?'':objDealSupport.Opportunity__r.name) +'<br/> <b>Quote Number:</b> ' +  (String.isBlank(objDealSupport.Quote__c)?'':objDealSupport.Quote__c);
    
    /*  Lines comemented by Ankit
    List<OrgWideEmailAddress>list_OWEmail = [select id, Address, DisplayName from OrgWideEmailAddress where Address =: 'jitendra.jain@rsystems.com'];
    
    if(UserInfo.getUserId() == objDealSupport.Requester__c)
    { 
      sFrom = objDealSupport.Requester_Email__c;//list_OWEmail[0].Address;
      sOrgWideId = list_OWEmail[0].id;
      isRequester = true;      
    }  
    else 
    { 
      sFrom = list_OWEmail[0].Address;//UserInfo.getUserEmail();
      sOrgWideId = list_OWEmail[0].id;
    } */
    //GetAttachments();
  }
  
  public void SendEmail()
  {
    try
    {       
       string[]arrUser = sUsersIds.split(',');
       string[]arrContacts = sContactsIds.split(',');
       List<string>list_UserCc = new List<string>();
       List<string>list_ContactCc = new List<string>();
       for(integer i =0;i<arrUser.size();i++)
       {
         list_UserCc.add(arrUser[i]);
       }
       for(integer i=0; i<arrContacts.size();i++)
       {
         list_ContactCc.add(arrContacts[i]);
       }
      
        List<User>list_Users_Cc = [Select id,Email from User where id IN : list_UserCc];
        List<Contact>list_Contacts_Cc = [Select id,Email from Contact where id IN : list_ContactCc];
        
        for(User objUser:list_Users_Cc )
            if(objUser.Email!=null)
               ccAddresses.add(objUser.Email);
               
        for(Contact objUser:list_Contacts_Cc)
            if(objUser.Email!=null)
               ccAddresses.add(objUser.Email);
           
        Config__c conf = Config__c.getValues('DealsupportEmailService');
        //Decimal myDecimal =myCS1.values__c;
        //ccAddresses.add('test_deal_support_email_service@w-30cm1vb9t3ejyikkcj4pwnpfugtbk4x9o4o9v60o1sikoy80zz.z-mjsbwman.cs11.apex.sandbox.salesforce.com'); 
        ccAddresses.add(conf.Value__c);       
        sBody = sBody + '<br></br><br></br><br></br><br></br>ref:'+objDealSupport.id+':ref';
        
        List<Messaging.EmailFileAttachment>efa = BindAttachment();
        
        system.debug('+++objDealSupport.id++'+objDealSupport.id);
        system.debug('+++sSubject++'+sSubject);
        User objU = new User(id=UserInfo.getUserId());
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        //EmailTemplate template = [select Id from EmailTemplate where name =: 'Deal Support Communication'];
        //mail.setTemplateId(template.Id);

        string[] arrToAddress = new string[1];
        arrToAddress[0] = sTo;//'amit.singh@rsystems.com';//
        
        if(isRequester)
        mail.setOrgWideEmailAddressId(sOrgWideId);
        mail.setToAddresses(arrToAddress);
        system.debug('ccAddresses '+ccAddresses);
        mail.setCcAddresses(ccAddresses);        
        mail.setWhatId(objDealSupport.id);
        mail.setSaveAsActivity(true);
        //mail.setPlainTextBody(sBody);
        mail.setHtmlBody(sBody);        
        mail.setSubject(sSubject);
        mail.setFileAttachments(efa);
        //mail.setCcAddresses(new string[] {'test_deal_support_email_service@w-30cm1vb9t3ejyikkcj4pwnpfugtbk4x9o4o9v60o1sikoy80zz.z-mjsbwman.cs11.apex.sandbox.salesforce.com'});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        for(Messaging.SendEmailResult rr:r){
            //System.debug('Email result ' + rr.IsSuccess());
            if(rr.IsSuccess())
            {
               //Clear subject and body
                sBody = '';
                sSubject = '';
                
                //Delete attachment
                delete list_Attachmnet;
                
                /* Common method */
                Init();
                
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
     obj.ParentId = objDealSupport.id;
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

     //if(objDealSupport.Id!=null)
     //{ 
        //list_AllAttach = new List<Attachment>();
        list_Attachmnet = [Select id,Description,name,body from Attachment where Id IN :list_AttachIds];
        system.debug('++++list_Attachmnet +++'+list_Attachmnet );
        
     //}
   }
   
   public Boolean getIsPartnerUser(){
   	  return (UserInfo.getUserType() == 'PowerPartner');
   }
}