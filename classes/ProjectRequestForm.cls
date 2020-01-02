public class ProjectRequestForm
{
  public Project_Request_Form__c objPrjReqFrm{get;set;}
  
  /* File attachment section*/
  public string fileName{get;set;}   
  public transient Blob fileBody{get;set;}
  public string BaseURL{get;set;}
  public string FileDescType{get;set;}
  public boolean blnShowErrorMsg{get;set;}
  public string sOppId{get;set;}
  public string sAccId{get;set;}
  public Opportunity objOpportunity{get;set;}
  public Account objAccount{get;set;}
  public PageReference objRef;
  public boolean blnIsSubmitted{get;set;}
  public boolean blnIsSubmitted_RO{get;set;}
  public string sAttachmentId{get;set;}
  public string sLoggedUser{get;set;}
  public string sRegion{get;set;}
  public string sStatus{get;set;}
  public boolean blnEnable{get;set;}
  
  /*Attachment List*/
  public List<Attachment>list_StatementOfWork{get;set;}
  public List<Attachment>list_ServiceOrders{get;set;}
  public List<Attachment>list_OppQuoteSheet{get;set;}
  public List<Attachment>list_AttachCallFlowDoc{get;set;}
  
  /* Constructor */
  public ProjectRequestForm()
  {
     CommonMethod();
  }
  
  public void CommonMethod()
  {
     
     blnEnable = false;
     /* Set Default Status*/
     sStatus = 'New';
     
     objPrjReqFrm = new Project_Request_Form__c();
     
     /*Get Base URL*/
     BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());
     
     /* Get Query String*/
     GetQueryString();
     if(sOppId != null)
       GetOpportunity();
     if(sAccId != null)  
       GetAccount();
       
     /* Get Project Request Form data*/  
      GetProjectReqFormData();
       
     /* Get page reference*/  
     GetPageReference();
     
     /* Bind Attachment*/
     GetAttachments();
     
     /* check attachments for all sections */
     string sResult = CheckMandatoryMessageForAttachment();
     if(sResult != '')
       blnEnable = true;
       
     if(objPrjReqFrm.Submitted__c == true)
     {
       blnShowErrorMsg = true;
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Request Submitted('+UserInfo.getUserEmail()+')'));
     }  

  }
  
  public void GetProjectReqFormData()
  {
     List<Project_Request_Form__c>list_ProjReqFrm;
    if(sOppId != null)
      list_ProjReqFrm = [Select Requester__r.Name,id,Submitted__c,Account__c,Any_Customer_Integrations_Included__c,Any_Onsite_Travel_Required__c,Booking_Date__c,Commitments_Been_Made_To_Customer__c,Customer_Location__c,Include_Any_Other_Pertinent__c,Technical_Business_Issues_to_be_solved__c,Critical_Business_Issues_to_be_solved__c,Is_this_a_package__c,Is_VCC_Or_SS_IVR_Project__c,New_CMRR__c,New_Or_Existing_Customer__c,No_Of_SS_IVR_Minutes__c,Number_Of_VCC_Seats__c,Opportunity__c,Pre_Discount_PS_Project_Value__c,Priority__c,Region__c,Requester__c,Request_Type__c,Status__c,Support_Area__c,name,Customer_Success_Manager_CSM__c,Solution_Consultant_SC__c from Project_Request_Form__c where  Opportunity__c =:sOppId ];
    if(sAccId != null)
      list_ProjReqFrm = [Select Requester__r.Name,id,Submitted__c,Account__c,Any_Customer_Integrations_Included__c,Any_Onsite_Travel_Required__c,Booking_Date__c,Commitments_Been_Made_To_Customer__c,Customer_Location__c,Include_Any_Other_Pertinent__c,Technical_Business_Issues_to_be_solved__c,Critical_Business_Issues_to_be_solved__c,Is_this_a_package__c,Is_VCC_Or_SS_IVR_Project__c,New_CMRR__c,New_Or_Existing_Customer__c,No_Of_SS_IVR_Minutes__c,Number_Of_VCC_Seats__c,Opportunity__c,Pre_Discount_PS_Project_Value__c,Priority__c,Region__c,Requester__c,Request_Type__c,Status__c,Support_Area__c,name,Customer_Success_Manager_CSM__c,Solution_Consultant_SC__c from Project_Request_Form__c where Account__c =:sAccId ];  
    
    if(list_ProjReqFrm != null && list_ProjReqFrm.size() >0)
     {
       objPrjReqFrm = list_ProjReqFrm[0];
       sLoggedUser = objPrjReqFrm.Requester__r.Name;
     }  
     else
     {
       sLoggedUser = GetCurrentUserName();
     }  
     
     if(objPrjReqFrm.Submitted__c == true)
     {
       blnIsSubmitted = false;
       blnIsSubmitted_RO = true;
     }  
     else
     {
       blnIsSubmitted = true; 
       blnIsSubmitted_RO = false;
     } 
  }
  public void GetQueryString()
  {
     sOppId = ApexPages.CurrentPage().getParameters().get('Oid');
     sAccId = ApexPages.CurrentPage().getParameters().get('Aid');
  }
  public string GetCurrentUserName()
  {
    User objUser = [Select FirstName,LastName from User where id =: UserInfo.getUserId()];
    return objUser.FirstName + ' ' + objUser.LastName ;
  }
  
  
  
  public void GetOpportunity()
  {
    List<Opportunity>list_Opp = [Select id,name,End_User_Region__c,Account.id,OpportunityNumber__c  from Opportunity where id =: sOppId];
    if(list_Opp != null && list_Opp.size() >0)
    {
      objOpportunity = list_Opp[0];
      sRegion = objOpportunity.End_User_Region__c ;
      
      /* Bind Account details*/
      List<Account>list_Ac = [Select id,name,Region__c from Account where id =: objOpportunity.Account.id];
      if(list_Ac != null && list_Ac.size() >0)
      {
        objAccount = list_Ac[0];
      }
    }
  }
  public void GetAccount()
  {
    List<Account>list_Acc = [Select id,name,Region__c from Account where id =: sAccId];
    if(list_Acc != null && list_Acc.size() >0)
    {
      objAccount = list_Acc[0];
      sRegion = objAccount.Region__c; 
    }
  }
  
  public void GetPageReference()
  {
    string sPageUrl = '';
    sPageUrl = '/apex/Project_Request_Form?';

    if(objAccount != null && objOpportunity == null)
      sPageUrl = sPageUrl + 'Aid=' + objAccount.id + '&';

    if(objOpportunity != null)
      sPageUrl = sPageUrl + 'Oid=' + objOpportunity.id + '&';

    
    system.debug('+++sPageUrl+++'+sPageUrl);
    objRef = new PageReference(sPageUrl); 
  }
  
  /* Save Records in Project Request Form object*/
  public PageReference SaveProjReqForm()
  {
    if(objAccount != null)
      objPrjReqFrm.Account__c = objAccount.id; 
    if(objOpportunity != null)
      objPrjReqFrm.Opportunity__c = objOpportunity.id;   
      
    objPrjReqFrm.Requester__c = UserInfo.getUserId();  
    objPrjReqFrm.Region__c = sRegion;
    objPrjReqFrm.Status__c = sStatus ;

    try {
      if(objPrjReqFrm.id != null)
        update objPrjReqFrm;
      else
        insert objPrjReqFrm;  

      objRef.setRedirect(true);
    } catch (DmlException e) {
      blnShowErrorMsg = true;
      for(Integer i=0; i<e.getNumDml(); i++) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, e.getDmlMessage(i)));
      }
    }
    
    return objRef;
  }
  
  public PageReference  SubmitProjReqForm()
  {

     string sResult = CheckMandatoryMessageForAttachment();
     if(sResult != '')
     {
       blnShowErrorMsg = true;
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,sResult ));
       return null;
       blnEnable = true;
     }
     
        objPrjReqFrm.Submitted__c = true;
        objPrjReqFrm.Requester__c = UserInfo.getUserId();
        objPrjReqFrm.Region__c = sRegion;
        objPrjReqFrm.Status__c = sStatus;
        update objPrjReqFrm;
        
        /* Send Email */
        List<Project_Request_Form_Email_List__c> lstEmail = Project_Request_Form_Email_List__c.getall().values();
        Set<string>set_Email = new Set<string>();
        
        for(integer i=0;i<lstEmail.size();i++)
        {
          set_Email.add(lstEmail[i].email__c);
        }
        
        List<User>list_Users = [Select id from User where email IN : set_Email];
        
        List<Messaging.EmailFileAttachment>efa = BindAttachment();
        
        for(User objU : list_Users){
          SendEmailByTemplate(objU.id ,'PS Project Request', objPrjReqFrm.id,efa);
        }
        
        
      
      GetPageReference();
      objRef.setRedirect(true);
      return objRef;
  }
  
   public PageReference UploadFile()  
   {  
        if(fileBody == null || fileName == '') 
        {       
          blnShowErrorMsg = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select the '+FileDescType+' file.'));
          return null;
        }  
        
        if(objPrjReqFrm.id == null)
        {
         SaveProjReqForm();
        }
        
        System.debug(LoggingLevel.Info, '+++++objPrjReqFrm++++  '+objPrjReqFrm.id);

        Attachment obj = new Attachment();
        obj.Body = fileBody;
        obj.Name = fileName;
        obj.ParentId = objPrjReqFrm.id;
        obj.Description = FileDescType ;
        insert obj;

        /*Clear variables*/
        fileBody =null;
        fileName = '';
        FileDescType = '';
        
        //CommonMethod();
        GetPageReference();
        
        objRef.setRedirect(true);
        return objRef;
   }
   
   /* Bind Attachment for Email */
   public List<Messaging.EmailFileAttachment> BindAttachment()
   {
     system.debug('++++BindAttachment+++');
     List<Messaging.EmailFileAttachment> list_FileAttachment = new List<Messaging.EmailFileAttachment>();
     if(objPrjReqFrm.Id!=null) //Added by Swastika 
     { 
        List<Attachment>list_AllAttach = [Select id,Description,name,body from Attachment where ParentId =: objPrjReqFrm.id];

        if(list_AllAttach!=null && list_AllAttach.Size()>0)
        for(Attachment objAttach : list_AllAttach)
        {
          Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
          if(objAttach.Description != 'Flow Documents')
           efa.setFileName(objAttach.Description + ' - ' +objAttach.name);
          if(objAttach.Description == 'Flow Documents')
           efa.setFileName('Others - ' + objAttach.name); 
           
          efa.setBody(objAttach.body);
          list_FileAttachment.add(efa);
        }
      }
      system.debug('++++list_FileAttachment+++'+list_FileAttachment.size());
      return list_FileAttachment;
   }
   
   /* Get All Attachments*/
   public void GetAttachments()
   {

     if(objPrjReqFrm.Id!=null) //Added by Swastika 
     { 
        List<Attachment>list_AllAttach = [Select id,Description,name from Attachment where ParentId =: objPrjReqFrm.id];

        if(list_AllAttach!=null && list_AllAttach.Size()>0)
            for(Attachment objAttach : list_AllAttach)
            {
              if(objAttach.Description == 'Statement Of Work')
                {
                 if(list_StatementOfWork != null)
                 {
                   list_StatementOfWork.add(objAttach);
                 }
                 else
                 {
                   list_StatementOfWork= new List<Attachment>();
                   list_StatementOfWork.add(objAttach);
                 }   
                }  
              if(objAttach.Description == 'Services Order')
              {
                if(list_ServiceOrders!=null)
                {
                  list_ServiceOrders.add(objAttach);
                }
                else
                {
                  list_ServiceOrders= new List<Attachment>();
                  list_ServiceOrders.add(objAttach);
                }    
              }
              if(objAttach.Description == 'Opportunity Quote Sheets')
              {
                if(list_OppQuoteSheet!=null)
                    list_OppQuoteSheet.add(objAttach);
                else
                {
                    list_OppQuoteSheet= new List<Attachment>();
                    list_OppQuoteSheet.add(objAttach);
                    
                }  
              }
              if(objAttach.Description == 'Flow Documents')
              {
                if(list_AttachCallFlowDoc!=null)
                    list_AttachCallFlowDoc.add(objAttach);
                else
                {
                    list_AttachCallFlowDoc= new List<Attachment>();
                    list_AttachCallFlowDoc.add(objAttach);
                }  
              }
              
            }
    }
   }
   
    public String SendEmailByTemplate(Id UserId,String strTemplateName, Id ProjReqFrmId,List<Messaging.EmailFileAttachment>efa)
    {
      string strResult='Failed';
         try
         {
            //List<Messaging.EmailFileAttachment>efa = BindAttachment();
          
            // Create a new single email message object
            // that will send out a single email to the addresses in the To, CC & BCC list.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
            // Specify the name used as the display name.
            //mail.setToAddresses(toAddresses);
            mail.setSenderDisplayName('');                   
            // Set to True if you want to BCC yourself on the email.
            mail.setBccSender(false);
            // Optionally append the salesforce.com email signature to the email.
            // The email address of the user executing the Apex Code will be used.
            mail.setUseSignature(false);
            //Map the VF template
            mail.setTargetObjectId(UserId); //Mandatory field when use template
            mail.setWhatId(ProjReqFrmId); //Assign Wow Id
            mail.setTemplateId([select id from EmailTemplate where Name =: strTemplateName].id);  //Find the template on the basis of name                    
            // Send the email you have created.
            mail.SaveAsActivity = false; //Mandatory field when use template
            
            mail.setFileAttachments(efa);
            
            //if(objOpportunity != null)
            //  mail.setSubject('Confirmation on New '+objPrjReqFrm.Name+' : Professional Services - '+objOpportunity.name+' (On Premise) - Brazil('+objPrjReqFrm.Region__c+')'); 
            //else
            //  mail.setSubject('Confirmation on New '+objPrjReqFrm.Name+' : Professional Services - '+objAccount.name+' (On Premise) - Brazil('+objPrjReqFrm.Region__c+')'); 
            
            system.debug('++++mail++++'+mail);
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
   
   /*Delete Attachment*/
  public PageReference DeleteAttachment()
  {
    Attachment objATT = [Select id,Description,name from Attachment where id =:sAttachmentId];
    delete objATT;
    //CommonMethod();
    GetPageReference();
        
    objRef.setRedirect(true);
    return objRef;
  }
  
  /* Mandatory check for Attachments*/
  public string CheckMandatoryMessageForAttachment()
  {
        string strMsg='';
        boolean IsStateWork=false; //false means not entered
        boolean IsSerOrder=false;
        boolean IsOppQuote=false; 
        
        
        List<Attachment> lstAttach=[select Id,Name,Description,ParentId FROM Attachment WHERE ParentId=:objPrjReqFrm.Id];
        if(lstAttach.Size()>0)
        for(Attachment objAttach:lstAttach)
        {
            if(objAttach.Description=='Statement Of Work')
                IsStateWork=true;
            if (objAttach.Description=='Services Order')  
                IsSerOrder=true;
            if (objAttach.Description=='Opportunity Quote Sheets')  
                IsOppQuote=true;
        }
      if(IsStateWork ==False) //Statement Of Work is null
         {  
         if(strMsg=='') 
                strMsg='Please insert Statement Of Work'; 
          else
                strMsg=strMsg+', Statement Of Work';                    
         } 
      if(IsSerOrder ==False) //Services Order is null  
         {  
         if(strMsg=='') 
               strMsg='Please insert Services Order';
          else
               strMsg=strMsg+', Services Order'; 
         }            
      if(IsOppQuote==False) //Opportunity Quote Sheets is null  
         {  
         if(strMsg=='')
               strMsg='Please insert Opportunity Quote Sheet'; 
          else
               strMsg=strMsg+', Opportunity Quote Sheet'; 
         } 
    
      if(strMsg!='')      //set full stop 
      {              
        strMsg=strMsg+'.';
        blnShowErrorMsg = true;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,strMsg));
        
      }
       return strMsg;
   }

}