public without sharing class clsWowRequestData{

  public string sOppId{get;set;}
  public Opportunity objOpportunity{get;set;}
  public string sUserType;
  public boolean blnMain{get;set;}
  public boolean blnShowErrorMsg{get;set;}
  public string sAttachmentId{get;set;}
  public boolean blnCreateHistory{get;set;}
  public string OppRoleHieUser{get;set;}
  public boolean blnSubmit{get;set;}
  public boolean blnErrorMsRequFld{get;set;}
  public string sIsreadonly{get;set;}
  
  public boolean blnIsVision{get;set;}
  public boolean blnIsDiscovery{get;set;}
  public boolean blnIsDesign{get;set;} 
  
  public boolean blnIsVisionAttachment{get;set;}
  public boolean blnIsDiscAttachment{get;set;}
  public boolean blnIsDesignAttachment{get;set;}
  public boolean blnIsFnUseCaseAttach{get;set;}
  public boolean blnIsBluePrintAttach{get;set;}
  public boolean blnIsDelivFindingAttach{get;set;}
  public boolean blnIsVTListExist{get;set;}
  public boolean blnIsExistAssessmnt{get;set;}
  public boolean blnIsDiscovPlan{get;set;}
  public boolean blnIsDesignPlan {get;set;}
  public boolean blnIsSCToolKit{get;set;}
  public boolean blnIsMaturity{get;set;}  //Phase III Changes: Added by Swastika on 01-Nov-2016 to show store attachment for Maturity and Benefits
  public boolean blnIsServicesTransition{get;set;} 
  public boolean blnIsRFP{get;set;} 
  public boolean blnIsFnUseCase{get;set;}
  //Added and commented by Swastika<start>
  public Wow_Request_Form__c objWowReqFrm{get;set;}  
   //Added and commented by Swastika<End>
   
  public string SelectedStatusType{get;set;}
  public string RAssessment{get;set;}
  
  /*List for All attachment sections*/
  public List<Attachment>list_AttachDiscoveryPlan{get;set;}
  public List<Attachment>list_AttachDiscoveryFinding{get;set;}
  public List<Attachment>list_AttachDesignPlan{get;set;}
  public List<Attachment>list_AttachDesignFinding{get;set;}
  //public List<Attachment>list_AttachSEToolkit{get;set;}
  public List<Attachment>list_AttachArchiBluePrint{get;set;}
  public List<Attachment>list_AttachDeliveryFinding{get;set;}
  public List<Attachment>list_AttachCustomUseCase{get;set;}
  public List<Attachment>list_AttachRFP{get;set;}
  
  public List<Attachment>list_AttachVision{get;set;}  
  public List<Wow_Attachments__c>list_WowVisionLinks{get;set;}
  //public List<Wow_Attachments__c>list_WowDiscoveryLinks{get;set;}
  
  public List<Attachment>list_AttachMaturity{get;set;}//Phase III Changes: Added by Swastika on 01-Nov-2016 to show store attachment for Maturity and Benefits
  public List<Attachment>list_AttachROICalculation{get;set;}//Phase III Changes: Added by Swastika on 02-Nov-2016 to show store attachment for ROI Calculation
  public List<Attachment>list_AttachBillMaterial{get;set;}//Phase III Changes: Added by Swastika on 02-Nov-2016 to show store attachment for Bill of Material
  public List<Attachment>list_AttachProSizing{get;set;}//Phase III Changes: Added by Swastika on 02-Nov-2016 to show store attachment for Proposed sizing
 
  /* File attachment section*/
  public string fileName{get;set;}   
  public transient Blob fileBody{get;set;}
  public string BaseURL{get;set;}
  public string FileDescType{get;set;}
  
  /*Wow History */
  public List<Wow_Request_Form_History__c>list_WowHistory{get;set;}
  
  /*Object to prepare Opportunity data */
  public clsWrapperWowDeatils objWrapWow{get;set;}
  
  /*Sections visibility*/
  public boolean AESection{get;set;}
  public boolean LeadSection{get;set;}
  public boolean VTSection{get;set;}
  public boolean StatusSection{get;set;}
  public boolean btnSave{get;set;}
  public boolean btnSubmit{get;set;}
  public boolean blnShowAssementLink{get;set;}
  public boolean blnLeadApproveReject{get;set;}
  /*Sections ReadOnly*/
  public boolean AESection_RO{get;set;}
  public boolean LeadSection_RO{get;set;}
  public boolean VTSection_RO{get;set;}
  public boolean StatusSection_RO{get;set;}
  public boolean EngFeedSection{get;set;}
   public boolean EngFeedSection_RO{get;set;}
   public boolean blnIsArchi {get;set;}
   public boolean blnIsDemo {get;set;}
  /*when Lead submitted to AE*/
  public string sAssignTo{get;set;}
  public string sWowStatus{get;set;}
  /*Risk Assessment*/
  public WoW_Risk_Assessment__c objRiskAssessment{get;set;}
  /*Wow Rejected History details*/
  public List<Wow_Request_Form_History__c> list_WowRejectHistryDtls{get;set;}
  
  public WoW_Virtual_Users__c objWowVT{get;set;} 
    public WoW_Virtual_Users__c objWowSCVT{get;set;} 
    public WoW_Virtual_Users__c objWowBCVT{get;set;}
    public WoW_Virtual_Users__c objWowPSVT{get;set;} 
    public WoW_Virtual_Users__c objWowSLVT{get;set;}  
    public List<WoW_Virtual_Users__c> list_VTUserList{get;set;}
   
    public string VirtualTeamType {get;set;} 
    public string CurrentVT{get;set;}
    public string CurrentVTType{get;set;} 
    
    public string CurrentFunUseCase{get;set;}
    public string FunUseCaseId{get;set;}

    public string CurrentBlePrint{get;set;}
    public string BpId{get;set;}    
    public List<Wow_Attachments__c>list_WowVision{get;set;}
    public List<Wow_Attachments__c>list_WowAttachmentsFnUseCase{get;set;}
    public List<Wow_Attachments__c>list_WowAttachmentsBluePrint{get;set;}
    public List<Wow_Attachments__c>list_WowAttachmentsDemo{get;set;}
    public List<Wow_Attachments__c>list_WowAttachmentsServiceTran{get;set;}    
    public List<WoW_Virtual_Users__c> list_WowExistVT {get;set;}
    public List<Wow_Sub_Regional_Users__c> list_AssignedLeaders {get;set;}
    public boolean blnShowCancel{get;set;}
    public boolean blnPrimarySCAdd{get;set;}
    //Phase III Changes: Added by Swastika on 01-Nov-2016 to show technical profile Id and Primary Quote 
    public string strTechProfileId {get;set;}
    public string strPrimaryQuoteId {get;set;}
    public List<BigMachines__Quote__c>list_BigMachineQuote{get;set;}
    public string CurrentVision{get;set;}
    public string VisionId{get;set;}
    public string CurrentDiscovery{get;set;}
    public string DiscoveryId{get;set;}
    public string CurrentDemo{get;set;}
    public string DemoId{get;set;}
    public string CurrentServTran{get;set;}
    public string ServTranId{get;set;} 
    public integer RowNumber{get;set;}
    public list<attachment> list_VisionActivityAttachment{get;set;}
    public List<Wow_Attachments__c>list_WowDiscovery{get;set;}
    public list<attachment> list_DiscoveryActivityAttachment{get;set;}
    public list<Solution_Design__c> list_SolutionDesign {get;set;}   //Temporarily comment solution design by swastika 
  /* Constructor */
  public clsWowRequestData()
  { 
    try
    {            
        string sOId = ApexPages.CurrentPage().getParameters().get('id');
        if(sOId == '')
        {
          blnShowErrorMsg = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'SC Engagement request can not be submitted from Account.'));
          return;
        }
        list_VTUserList = new List<WoW_Virtual_Users__c>(); 
        
        objWowVT=new WoW_Virtual_Users__c();      
        objWowSCVT=new WoW_Virtual_Users__c();
        objWowBCVT=new WoW_Virtual_Users__c();
        objWowPSVT=new WoW_Virtual_Users__c();
        objWowSLVT=new WoW_Virtual_Users__c();
        
        list_WowVision =new list<Wow_Attachments__c>();
        list_WowAttachmentsFnUseCase =new list<Wow_Attachments__c>();
        list_WowAttachmentsBluePrint  =new list<Wow_Attachments__c>();
        list_WowVisionLinks = new List<Wow_Attachments__c>();
        list_WowAttachmentsDemo = new List<Wow_Attachments__c>();
        list_WowAttachmentsServiceTran = new List<Wow_Attachments__c>();    
        list_VisionActivityAttachment =new list<attachment>();   
        list_WowAttachmentsServiceTran = new List<Wow_Attachments__c>();    
        list_DiscoveryActivityAttachment =new list<attachment>(); 
        list_WowDiscovery = new list<Wow_Attachments__c>();
        list_DiscoveryActivityAttachment = new list<attachment>();
        //list_WowDiscoveryLinks = new List<Wow_Attachments__c>();
        list_SolutionDesign  = new list<Solution_Design__c>(); //Temporarily comment solution design by swastika
        system.debug('swas');
             
        CommonMethod(null);
        /*Check Wow Page accessibility for LoggedIn user*/
         //LoggedUserPageAccessibility();
         //InitializeVT();   
        /* Get LoggedIn user Type*/  
         //sUserType = WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.id,null);
    
         if(!blnMain)
         {
          blnShowErrorMsg = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'You are not authorized to access to this page.'));
         }
      }
      catch(Exception ex)   
      {
        blnShowErrorMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }
  }
  
  public void CommonMethod(string strMessage)
  {
    blnCreateHistory=true;
    blnShowErrorMsg = false;
    AESection = false;
    LeadSection = false;
    VTSection = false;
    StatusSection=false;
    EngFeedSection = false;
    EngFeedSection_RO = false;

    AESection_RO = false;
    LeadSection_RO = false;
    VTSection_RO = false;
    StatusSection_RO =false;
    blnSubmit=true;
    
    blnIsVisionAttachment = false;
    blnIsFnUseCase = false;
    blnIsDiscAttachment = false;
    blnIsDesignAttachment = false;
    blnIsFnUseCaseAttach = false;
    blnIsBluePrintAttach = false;
    blnIsDelivFindingAttach = false;
    blnLeadApproveReject = false;
    blnIsVTListExist = false;
    blnIsExistAssessmnt = false;
    blnIsDiscovPlan = false;
    blnIsDesignPlan  = false;
    blnIsSCToolKit = false;
    blnShowCancel = false;
    blnPrimarySCAdd = false;
    blnIsMaturity = false;
    blnIsRFP = false;
    blnIsServicesTransition = null;
    blnIsArchi = false;
    blnIsDemo = false;
    
    list_AttachDiscoveryPlan = null;
    list_AttachDiscoveryFinding = null;
    list_AttachDesignPlan = null;
    list_AttachDesignFinding = null;
    //list_AttachSEToolkit = null;
    list_AttachArchiBluePrint = null;
    list_AttachVision = null;
    list_AttachDeliveryFinding = null;
    list_AttachCustomUseCase = null;
    list_AttachMaturity = null;     
    strTechProfileId = null;
    strPrimaryQuoteId = null;
    list_AttachROICalculation = null;
    list_AttachBillMaterial = null;
    list_AttachProSizing =null;
    list_BigMachineQuote = null;
    list_AttachRFP = null;
    //objWowReqFrm=null; //Added by swastika 
    /* Get Opportunity Details*/
    
     System.debug(LoggingLevel.INFO,'11');
     
    OppRoleHieUser=ApexPages.CurrentPage().getParameters().get('idu');
    sOppId = ApexPages.CurrentPage().getParameters().get('id');
    
    

    objWowReqFrm=new  Wow_Request_Form__c();
    /* To get the Opportunity and Wow Request Data*/
    GetOpportunityDetails(sOppId);
     list_AssignedLeaders =  WoWUtility.getSubRegionalNewUsersName(objOpportunity.Owner.Segment__c ,objOpportunity.Owner.Owner_Sub_Region__c, objOpportunity.Lines_of_Businesses__c);
     //list_AssignedLeaders = WoWUtility.getSubRegionalUsersName(string.valueof(objOpportunity.End_User_Region__c),string.valueof(objOpportunity.Country_Sub_Region__c));

     System.debug(LoggingLevel.INFO,'22');
    GetWowFunctionalAndBlueprint();
     System.debug(LoggingLevel.INFO,'33');
    GetVisionLinks(); 
     System.debug(LoggingLevel.INFO,'44');
    //GetDiscoveryLinks();
     /*Bind Attachments for all sections*/
     GetAttachmentsWow();
      System.debug(LoggingLevel.INFO,'55');
     /*Get Base URL*/
     BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());
      System.debug(LoggingLevel.INFO,'66');
     /*Get Wow History*/
     //GetWowHistoryDetails();
     
     /*Get Wow Rejected History Details*/
     //list_WowRejectHistryDtls=null;
     GetWowRejectedHistory();
     System.debug(LoggingLevel.INFO,'77');
     /*Check LoggedIn user Type*/
     //boolean blnUserExist = CheckLoggedInUserType(objOpportunity.End_User_Region__c);

     SetVisibility();
     //SetReadOnly();
     
     list_WowHistory=null;
     if(objWowReqFrm.Id <> null)
         GetWowRequestHistory(objWowReqFrm.Id);
          System.debug(LoggingLevel.INFO,'88');
         
     if(strMessage <> null)
     {
         blnShowErrorMsg = true; 
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,strMessage ));
     }    
     
     /*Check status for Virtual Team*/    
     if(objWowReqFrm.WoW_Status__c == 'Rejected')
       SelectedStatusType = 'Reject';
     else  
       SelectedStatusType = 'Approve';
       
     /*Get Risk Assessment*/  
     GetRiskAssessment();
      System.debug(LoggingLevel.INFO,'99');
      list_SolutionDesign  = GetSolutionDesign(objWowReqFrm.Id);   //Temporarily comment solution design by swastika 
  }
  
  public void GetVisionLinks()
  {
    list_WowVisionLinks = [Select id,Wow_Request_Form__c,Type__c,Link_URL__c from Wow_Attachments__c where Wow_Request_Form__c =: objWowReqFrm.id and Type__c =: 'Vision'];
    /*if(list_WowVisionLinks.size()<=0)
     {
       list_WowVisionLinks = new List<Wow_Attachments__c>();
       Wow_Attachments__c obj = new Wow_Attachments__c();
       obj.Wow_Request_Form__c = objWowReqFrm.id;
       obj.Type__c = 'Vision';
       //obj.Link_URL__c='';
       list_WowVisionLinks.add(obj);
     }*/
  }
   
  /*public void GetDiscoveryLinks()
  {
    list_WowDiscoveryLinks = [Select id,Wow_Request_Form__c,Type__c,Link_URL__c from Wow_Attachments__c where Wow_Request_Form__c =: objWowReqFrm.id and Type__c =: 'Discovery Finding'];
     if(list_WowDiscoveryLinks.size()<=0)
     {
       Wow_Attachments__c obj = new Wow_Attachments__c();
       obj.Wow_Request_Form__c = objWowReqFrm.id;
       obj.Type__c = 'Discovery Finding';
       list_WowDiscoveryLinks.add(obj);
     }
  }*/
  
  public void GetWowFunctionalAndBlueprint()
  {
     list_WowAttachmentsFnUseCase = [Select Id,Functional_Use_Case__c,Fit__c,Description__c,Wow_Request_Form__c,Type__c,Row_Number__c,Functional_Usecases_Numbers__c  from Wow_Attachments__c where Wow_Request_Form__c =: objWowReqFrm.id and Type__c =: 'Functional Use Case'];
     if(list_WowAttachmentsFnUseCase.size()<=0)
     {
       list_WowAttachmentsFnUseCase = new List<Wow_Attachments__c>();
       Wow_Attachments__c objWowAttFn = new Wow_Attachments__c();
       objWowAttFn.Wow_Request_Form__c = objWowReqFrm.id;
       objWowAttFn.Type__c = 'Functional Use Case';
       //objWowAttFn.Functional_Usecases_Numbers__c = 'CE' + 1;
       list_WowAttachmentsFnUseCase.add(objWowAttFn);
     }
     system.debug('list_WowAttachmentsFnUseCase'+list_WowAttachmentsFnUseCase);
     list_WowAttachmentsBluePrint = [Select id,ArchitectureBlueprints__c,Fit__c,Description__c,Wow_Request_Form__c,Type__c,Row_Number__c,Functional_Usecases_Numbers__c  from Wow_Attachments__c where Wow_Request_Form__c =: objWowReqFrm.id and Type__c =: 'Architectural Blueprint'];
     if(list_WowAttachmentsBluePrint.size()<=0)
     {
       list_WowAttachmentsBluePrint = new List<Wow_Attachments__c>();
       Wow_Attachments__c objWowAttFn = new Wow_Attachments__c();
       objWowAttFn.Wow_Request_Form__c = objWowReqFrm.id;
       objWowAttFn.Type__c = 'Architectural Blueprint';
       list_WowAttachmentsBluePrint.add(objWowAttFn);
     }
     
     list_WowAttachmentsDemo = [Select id,Demo__c,Date__c,Description__c,Wow_Request_Form__c,Type__c,Row_Number__c  from Wow_Attachments__c where Wow_Request_Form__c =: objWowReqFrm.id and Type__c =: 'Demo'];
     if(list_WowAttachmentsDemo.size()<=0)
     {
       list_WowAttachmentsDemo = new List<Wow_Attachments__c>();
       Wow_Attachments__c objWowAttFn = new Wow_Attachments__c();
       objWowAttFn.Wow_Request_Form__c = objWowReqFrm.id;
       objWowAttFn.Type__c = 'Demo';
       list_WowAttachmentsDemo.add(objWowAttFn);
     }
     list_WowAttachmentsServiceTran = [Select id,Services_Transition__c,Date__c,Description__c,Wow_Request_Form__c,Type__c,Row_Number__c  from Wow_Attachments__c where Wow_Request_Form__c =: objWowReqFrm.id and Type__c =: 'Services Transition'];
     if(list_WowAttachmentsServiceTran.size()<=0)
     {
       list_WowAttachmentsServiceTran = new List<Wow_Attachments__c>();
       Wow_Attachments__c objWowAttFn = new Wow_Attachments__c();
       objWowAttFn.Wow_Request_Form__c = objWowReqFrm.id;
       objWowAttFn.Type__c = 'Services Transition';
       list_WowAttachmentsServiceTran.add(objWowAttFn);
     }
     system.debug(LoggingLevel.info,'***list_WowVision1**'+list_WowVision);
     
     list_WowVision = [Select id,Vision_Activity__c,Date__c,Description__c,Wow_Request_Form__c,Type__c,Row_Number__c,(select Id, name from Attachments)  from Wow_Attachments__c where Wow_Request_Form__c =: objWowReqFrm.id and Type__c =: 'Vision Activity'];
     if(list_WowVision.size() <= 0)
     {          
       list_WowVision = new List<Wow_Attachments__c>();
       Wow_Attachments__c objWowAttFn = new Wow_Attachments__c();
       objWowAttFn.Wow_Request_Form__c = objWowReqFrm.id;
       objWowAttFn.Type__c = 'Vision Activity';
       objWowAttFn.Row_Number__c=  1;     
       list_WowVision.add(objWowAttFn);
       system.debug(LoggingLevel.info,'***list_WowVision**'+list_WowVision);
     } 
       
     list_WowDiscovery= [Select id,Discovery_Activity__c,Date__c,Description__c,Wow_Request_Form__c,Type__c,Row_Number__c,(select Id, name from Attachments)  from Wow_Attachments__c where Wow_Request_Form__c =: objWowReqFrm.id and Type__c =: 'Discovery'];
     if(list_WowDiscovery.size() <= 0)
     {          
       list_WowDiscovery = new List<Wow_Attachments__c>();
       Wow_Attachments__c objWowAttFn = new Wow_Attachments__c();
       objWowAttFn.Wow_Request_Form__c = objWowReqFrm.id;
       objWowAttFn.Type__c = 'Discovery';
       objWowAttFn.Row_Number__c=  1;     
       list_WowDiscovery.add(objWowAttFn);       
     }  
  }
  
  public void GetOpportunityDetails(string SOppId)
  {
    system.debug('SOppId'+SOppId);
    //Added by Swastika on 10-Oct-2016 get the Primary Solution Consultant from Account
    objOpportunity = [Select id,FunctionalUsecasesNumbers__c,Account.Account_Segmentation__c,SMART_Opportunity__c,name,Owner.Name,Owner.Id, industry__c,AE_Name__r.name,AE_Name__c,StageName,Amount,Primary_Line_of_Business__c,Account.name,Primary_Solution_Category__c,End_User_Region__c,BusinessPartner__r.Name,CloseDate,Key_Business_Objective__c,Term_License__c,Term_License_Amount_TCV__c ,License_Amount__c,Hardware_Total__c,Professional_Service_Amount_RDP__c,Genesys_Care_Amount__c,License_Equivalency__c,Annual_Contract_Value_new__c,Annual_Contract_Value__c,Total_PS_Support__c,Monthly_Commitment__c,Estimated_Usage_Agreements_EUA__c,Potential_Pipeline__c,Total_Annual_Contract_Value__c,CurrencyIsoCode,Country_Sub_Region__c, account.Primary_Solution_Consultant__c,Primary_Quote__c,Primary_Quote__r.Id,Lines_of_Businesses__c,Owner.Segment__c , Owner.Owner_Sub_Region__c from  Opportunity where id=: SOppId];
    system.debug('objOpportunity '+ objOpportunity);
    
    //Primary Quote from Big Machine Quote
    list_BigMachineQuote = [SELECT Id,BigMachines__Opportunity__c, BigMachines__Is_Primary__c FROM BigMachines__Quote__c where BigMachines__Opportunity__c =:objOpportunity.Id and BigMachines__Is_Primary__c =:true limit 1];
    
     system.debug(LoggingLevel.info,'***objOpportunity.Account.Id**'+objOpportunity.Account.Id);
    //Phase III Changes: Added by Swastika on 01-Nov-2016 
    if(objOpportunity !=null)
        {
        List<Technical_Profile__c> list_TechProfile= [SELECT Id FROM Technical_Profile__c Where Account__c=:objOpportunity.Account.Id ORDER BY LastModifiedDate DESC LIMIT 1];
        system.debug(LoggingLevel.info,'***objTechProfile.size**'+list_TechProfile.size());
        if(list_TechProfile.size()>0)
             strTechProfileId =  string.valueof(list_TechProfile[0].Id);
         //Phase III Changes: Added by Swastika on 03-Nov-2016 to show Primary Quote
        if(list_BigMachineQuote.size()>0)
            strPrimaryQuoteId =  string.valueof(list_BigMachineQuote[0].Id);     
        }       
           
    //Added and commented by Swastika
    List<Wow_Request_Form__c> objWow= [Select id,name,Data_Migration__c,Opportunity_Id__r.Account.Account_Segmentation__c,Opportunity_Id__r.Owner.Segment__c,Opportunity_Id__r.Lines_of_Businesses__c,Opportunity_Id__r.Name,Opportunity_Id__r.Account.name,SMART_Opportunity__c,Opportunity_Stage__c,High_Level_Request_details__c ,BC__c,industry__c,total_amount__c,CurrencyIsoCode,Expected_Discovery_Start__c,Opportunity_Id__c,Opportunity_Id__r.Key_Business_Objective__c,Primary_Business_Objectives__c,Rejected_Status__c,SE__c,SEM__c,WoW_Status__c,Discovery_Start_Date__c,Discovery_End_Date__c,Design_Start_Date__c,Design_End_Date__c,Internal_Kick_Off_Date__c,AssignTo__c,Assign_Queue__c,FunctionalUseCase__c,ArchitectureBlueprints__c,AE_Name__c,Opportunity_Name__c,Stage__c,Platform_Type__c,Customer_Name__c,Business_Partner__c,Primary_Solution__c,Expected_Closed_Date__c,IsSEOwner__c,IsBCOwner__c,AE__c,Lead__c,Opp_Annual_Contract_Value__c,Opp_Annual_Contract_Value_new__c,Opp_Monthly_Commitment__c,Opp_Estimated_Usage_Agreements_EUA__c,Opp_Genesys_Care_Amount__c,Opp_Hardware_Total__c,Opp_License_Amount__c,Opp_License_Equivalency__c,Opp_Potential_Pipeline__c,Opp_Professional_Service_Amount_RDP__c,Opp_Total_PS_Support__c,Opp_Term_License__c,Opp_Term_License_Amount_TCV__c,Opp_Total_Annual_Contract_Value__c,Vision_Activity__c,Vision_Stage_Activities__c,Vision_Start_Date__c,Discovery_Activities__c,Design_Activities__c,Custom_Use_Case__c,Custom_Architecture__c,Who_Provides_Design__c,Deployment_Topology__c,Partner_Customer_Aware_Design__c,Impact_SC_Engagement__c,Lessons_Learned_Feedback__c,Opportunity_Id__r.Country_Sub_Region__c
      ,Type_of_Discovery__c,Type_of_Design__c,PS_PM__c,URL_Webnier__c,PS_transition__c,Demo_Performed__c,RFP__c,RFP_Completed_Date__c,RFP_Due_Date__c,RFP_Received_Date__c,Short_Description_of_RFP__c,Is_Functional_Use_Case__c,Predefined_Architecture__c,VisionStartDate__c,Transition_End_Date__c from Wow_Request_Form__c where Opportunity_Id__c =: SOppId AND WoW_Status__c!='Rejected' LIMIT 1];
    if(objWow != null && objWow.size()>0)
    {
        objWowReqFrm=objWow[0];
        /*Populate Wow Status and AssignTO  when Lead submit to AE*/
        sAssignTo = objWowReqFrm.AssignTo__c;      
        sWowStatus = objWowReqFrm.WoW_Status__c;
        blnIsVision = objWowReqFrm.Vision_Stage_Activities__c;
        blnIsDiscovery = objWowReqFrm.Discovery_Activities__c;
        blnIsDesign = objWowReqFrm.Design_Activities__c;
        blnIsServicesTransition = objWowReqFrm.PS_transition__c;
        blnIsFnUseCase = objWowReqFrm.Is_Functional_Use_Case__c;
        blnIsArchi = objWowReqFrm.Predefined_Architecture__c;
        blnIsDemo = objWowReqFrm.Demo_Performed__c;
    }
    else
    {
       if(objOpportunity.Key_Business_Objective__c <> null)
        objWowReqFrm.Primary_Business_Objectives__c=objOpportunity.Key_Business_Objective__c; 
       
       if(objOpportunity.BusinessPartner__r <> null) 
         objWowReqFrm.Business_Partner__c = objOpportunity.BusinessPartner__r.Name;
         
       if(objOpportunity.Annual_Contract_Value__c <> null) 
         objWowReqFrm.Opp_Annual_Contract_Value__c = objOpportunity.Annual_Contract_Value__c; 
       
       if(objOpportunity.Annual_Contract_Value_new__c<> null) 
         objWowReqFrm.Opp_Annual_Contract_Value_new__c = objOpportunity.Annual_Contract_Value_new__c; 
       
       if(objOpportunity.Monthly_Commitment__c<> null) 
         objWowReqFrm.Opp_Monthly_Commitment__c= objOpportunity.Monthly_Commitment__c; 
       
       if(objOpportunity.Estimated_Usage_Agreements_EUA__c<> null) 
         objWowReqFrm.Opp_Estimated_Usage_Agreements_EUA__c = objOpportunity.Estimated_Usage_Agreements_EUA__c; 
       
       if(objOpportunity.Genesys_Care_Amount__c<> null) 
         objWowReqFrm.Opp_Genesys_Care_Amount__c= objOpportunity.Genesys_Care_Amount__c; 
       
       if(objOpportunity.Hardware_Total__c<> null) 
         objWowReqFrm.Opp_Hardware_Total__c = objOpportunity.Hardware_Total__c; 
       
       if(objOpportunity.License_Amount__c <> null) 
         objWowReqFrm.Opp_License_Amount__c= objOpportunity.License_Amount__c; 
       
       if(objOpportunity.License_Equivalency__c <> null) 
         objWowReqFrm.Opp_License_Equivalency__c = objOpportunity.License_Equivalency__c; 
       
       if(objOpportunity.Potential_Pipeline__c<> null) 
         objWowReqFrm.Opp_Potential_Pipeline__c = objOpportunity.Potential_Pipeline__c; 
       
       if(objOpportunity.Professional_Service_Amount_RDP__c <> null) 
         objWowReqFrm.Opp_Professional_Service_Amount_RDP__c= objOpportunity.Professional_Service_Amount_RDP__c; 
       
       if(objOpportunity.Total_PS_Support__c <> null) 
         objWowReqFrm.Opp_Total_PS_Support__c = objOpportunity.Total_PS_Support__c; 
       
       if(objOpportunity.Term_License__c <> null) 
         objWowReqFrm.Opp_Term_License__c= objOpportunity.Term_License__c; 
       
       if(objOpportunity.Term_License_Amount_TCV__c <> null) 
         objWowReqFrm.Opp_Term_License_Amount_TCV__c = objOpportunity.Term_License_Amount_TCV__c; 
       
       if(objOpportunity.Total_Annual_Contract_Value__c <> null) 
         objWowReqFrm.Opp_Total_Annual_Contract_Value__c= objOpportunity.Total_Annual_Contract_Value__c; 
         
       if(objOpportunity.Industry__c <> null) 
         objWowReqFrm.Industry__c = objOpportunity.Industry__c ; 
    }   

  //Modified by swastika<start>
   if(objWowReqFrm.id != null)
    {
      objWrapWow = new clsWrapperWowDeatils(objWowReqFrm); 
      List<WoW_Virtual_Users__c> List_VTAllUsers=[SELECT Virtual_User__c,Virtual_User__r.name,Virtual_User_type__c FROM WoW_Virtual_Users__c WHERE   Wow_Request_Form__c=:objWowReqFrm.id];
      
      //Added by Swastika on 10-Oct-2016 to assign primary consultant from account as virtual team member <start>
              
              if(objOpportunity.account.Primary_Solution_Consultant__c!=null && List_VTAllUsers.size() ==0 && objWowReqFrm.AssignTo__c =='Lead Assign')
                {        
                 WoW_Virtual_Users__c objAccountVT= new WoW_Virtual_Users__c();
                 objAccountVT.Virtual_User__c=objOpportunity.account.Primary_Solution_Consultant__c;
                 objAccountVT.Virtual_User_type__c='Solution Consultant';
                 objAccountVT.Wow_Request_Form__c= objWowReqFrm.Id; 
                 List_VTAllUsers.add(objAccountVT);
                 //blnPrimarySCAdd = true;
                }
              //Added by Swastika on 10-Oct-2016 to assign primary consultant from account as virtual team member <End> 
      
      list_VTUserList=new List <WoW_Virtual_Users__c>();
      if(List_VTAllUsers.size()>0 && list_VTUserList.size()<=0)
      {
          For(WoW_Virtual_Users__c objVT: List_VTAllUsers){
              WoW_Virtual_Users__c objTemp=new WoW_Virtual_Users__c();
              objTemp.Virtual_User__c=objVT.Virtual_User__c;
              objTemp.Virtual_User_type__c =objVT.Virtual_User_type__c;
              objTemp.Wow_Request_Form__c= objWowReqFrm.id;
              objTemp.Id=null;
              list_VTUserList.add(objTemp);
             }
         if(list_VTUserList.size()>0)  
           blnIsVTListExist = true;  
       } 
           
     //Functional use case
     /*List<Wow_Attachments__c> List_FunUseAllUsers=[SELECT Id,Type__c, Functional_Use_Case__c,Description__c from Wow_Attachments__c WHERE Wow_Request_Form__c =: objWowReqFrm.id AND Type__c=:'Functional Use Case'];
      list_WowAttachmentsFnUseCase=new List <Wow_Attachments__c>();
      if(List_FunUseAllUsers.size()>0 && list_WowAttachmentsFnUseCase.size()<=0)
      {
          For(Wow_Attachments__c objFun: List_FunUseAllUsers){
              Wow_Attachments__c objTemp=new Wow_Attachments__c();
              objTemp.Type__c=objFun.Type__c;
              objTemp.Functional_Use_Case__c =objFun.Functional_Use_Case__c;
              objTemp.Description__c =objFun.Description__c;
              objTemp.Wow_Request_Form__c= objWowReqFrm.id;
              objTemp.Id=null;
              list_WowAttachmentsFnUseCase.add(objTemp);
             }         
       } */ 
    }
    else
    {
      system.debug('Test');
      objWrapWow =null;  //Added by swastika
      objWrapWow = new clsWrapperWowDeatils(objOpportunity);
      RAssessment='aAf/e';
    }
   
  }

  public void GetRiskAssessment()
  {
  //Modified by Swastika to show Risk Scores<start>
   List<WoW_Risk_Assessment__c> list_RiskAssessment = [SELECT  LastModifiedDate, Owner.Name, CreatedDate,id,Business_Score_Value__c,Business_Score_Text__c,Technology_Score_Value__c,Technology_Score_Text__c,Deployment_Score_Value__c,Deployment_Score_Text__c,Support_Score_Value__c,Support_Score_Text__c FROM WoW_Risk_Assessment__c  where WoW_Request_Id__c =: objWowReqFrm.id];
   //List<WoW_Risk_Assessment__c> list_RiskAssessment = [SELECT  LastModifiedDate, Owner.Name, CreatedDate,id FROM WoW_Risk_Assessment__c  where WoW_Request_Id__c =: objWowReqFrm.id];
    //Modified by Swastika to show Risk Scores<End> 
   objRiskAssessment = new WoW_Risk_Assessment__c();
   if(list_RiskAssessment != null && list_RiskAssessment.size()>0)
   {
    objRiskAssessment = list_RiskAssessment[0];
    blnIsExistAssessmnt = true;
   } 
  }
  
  public void DeleteAttachment()
  {
    Attachment objATT = [Select id,Description,name from Attachment where id =:sAttachmentId];
    
    string sAttType='';
    string sAttSubType='';
    string sType = objATT.Description;
        
    if(sType  == 'Discovery Plan' || sType  =='Discovery Finding' || sType =='Design Plan' || sType =='Design Finding' || sType =='Delivery Findings' || sType =='Architectural BluePrint' || sType =='SCToolkit' || sType =='Vision Document' || sType =='Delivery Findings' || sType =='Custom Use Case' ||sType == 'Maturity and Benefits Model')
    {
      if(sType == 'Discovery Plan')
      {
       sAttType = 'Discovery';
       sAttSubType =sType ;
      }
      if(sType == 'Discovery Finding')
      {
       sAttType = 'Discovery';
       sAttSubType = FileDescType;
      }
      if(FileDescType == 'Design Plan')
      {
       sAttType = 'Design';
       sAttSubType = sType ;
      }
      if(sType == 'Design Finding')
      {
       sAttType = 'Design';
       sAttSubType = sType ;
      }
      if(sType == 'Delivery Findings')
      {
       sAttType = 'Delivery Findings';
       sAttSubType = sType ;
      }
      if(sType == 'Architectural BluePrint')
      {
       sAttType = 'Architectural BluePrint';
       sAttSubType = 'Architectural BluePrint';
      }
      if(sType == 'SCToolkit')
      {
       sAttType = 'SCToolkit';
       sAttSubType = 'SCToolkit';
      }
      if(sType == 'Vision Document')
      {
       sAttType = 'Vision';
       sAttSubType = 'Vision Document';
      }
      if(sType == 'Delivery Findings')
      {
       sAttType = 'Delivery Findings';
       sAttSubType = 'Delivery Findings';
      }
      if(sType == 'Custom Use Case')
      {
       sAttType = 'Custom Use Case';
       sAttSubType = 'Custom Use Case';
      }
     if(sType == 'Maturity and Benefits Model')
      {
       sAttType = 'Discovery';
       sAttSubType = 'Maturity and Benefits Model';
      } 
     if(sType == 'ROI Calculation')
      {
       sAttType = 'Design';
       sAttSubType = 'ROI Calculation';
      }
       if(sType == 'Bill of Materials')
      {
       sAttType = 'Design';
       sAttSubType = 'Bill of Materials';
      }
      if(sType == 'Proposed Sizing')
      {
       sAttType = 'Architectural BluePrint';
       sAttSubType = 'Proposed Sizing';
      }
       
    }
    else
    {
      string[]arrType = sType .split(':');
      sAttType = arrType[0];
      sAttSubType = arrType[1];
      //sFileDesc = sAttType ;
    }

    WoWUtility.CreateHistory('Document deleted to SC Engagement ('+objATT.Name+')' ,sAttType , sAttSubType  ,UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,'Save'),objWowReqFrm.AssignTo__c,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
    delete objATT;
    
    CommonMethod(null);
  }
  
  /* Checks the Logged In user accessibility.If Logged IN user is either 
  AE,SE,BC,Lead,SEM then user can access Wow Request Form*/
  /*public void LoggedUserPageAccessibility()
  {
    boolean blnExist = false;
    if(objWowReqFrm.AE__c == UserInfo.getUserId())
    {
      blnExist = true;
    }
    if(objWowReqFrm.Lead__c == UserInfo.getUserId())
    {
      blnExist = true;
    }
    if(objWowReqFrm.SE__c == UserInfo.getUserId())
    {
      blnExist = true;
    }
    if(objWowReqFrm.BC__c == UserInfo.getUserId())
    {
      blnExist = true;
    }
    if(objWowReqFrm.SEM__c == UserInfo.getUserId())
    {
      blnExist = true;
    }
  }*/

  //public void SetVisibility(boolean blnExist)
  public void SetVisibility()
  {
        system.debug('#role '+OppRoleHieUser);
        boolean blnAE=false;
        boolean blnLead=false;
        boolean blnVirtualTeam=false;
        blnMain=false;
        
        btnSave=true;
        btnSubmit=true;

       /*Get LoggedIn user profile name*/
       string sProfileName = WoWUtility.GetProfileName(userinfo.getProfileId());
       
       //if record exist in WoW request form
       if(objWowReqFrm!=null)  
       {
         //string sQueueName = WowUtility.GetQueueName(objOpportunity.End_User_Region__c);
         //system.debug('#Quename'+sQueueName+'------'+objOpportunity.End_User_Region__c);
        // blnLead = CheckLoggedInUserType(sQueueName);
        
        
         
         /* Custom setting  WowAdminAccess__c*/
         List<WowAdminAccess__c> lstCstSetting = WowAdminAccess__c.getall().values(); 
         WowAdminAccess__c adminAccessibility= WowAdminAccess__c.getInstance('System Administrator');
          /* check loggedin as Global user or not */
         boolean blnIsGlobal = false;
         blnIsGlobal = WoWUtility.GlobalUser(UserINfo.getUserId());
         if(blnIsGlobal)
           sProfileName = 'System Administrator';
          system.debug(LoggingLevel.info,'***objWowReqFrm.AssignTo__c**'+objWowReqFrm.AssignTo__c);
          system.debug(LoggingLevel.info,'***objOpportunity.Country_Sub_Region__c**'+objOpportunity.Country_Sub_Region__c);
          system.debug(LoggingLevel.info,'***UserINfo.getUserName()**'+UserINfo.getUserName());
         
         //if(sProfileName =='System Administrator' && lstCstSetting[0].IsAccessible__c == true)
         if(sProfileName =='System Administrator' && adminAccessibility.IsAccessible__c== true)
         {
            blnLead  = true;
            blnVirtualTeam=true;
            blnAE=true;
            system.debug('***gggg');
          /* if(objWowReqFrm.AssignTo__c != 'AE') 
           {
            blnLead  = true;
            blnVirtualTeam=true;
            blnAE=true;
            system.debug('***gggg');
            
             AESection = true;
             LeadSection = true;
             VTSection = true;
             StatusSection=true;
             btnSave=true;
             btnSubmit=true;
            }
            else
            {
              AESection = false;
             LeadSection = false;
             VTSection = false;
             StatusSection=false;
             btnSave=false;
             btnSubmit=false;
            } */
         }
         //else if(CheckLoggedInUserType(sQueueName ))
        
         //else if(WoWUtility.getSubRegionalUsers(string.valueof(objOpportunity.End_User_Region__c),string.valueof(objOpportunity.Country_Sub_Region__c),UserINfo.getUserName())){         
         else if(WoWUtility.getSubRegionalUsersForSC(UserINfo.getUserName())){        
            blnLead=true;  
           system.debug('***blnLead**'+blnLead);
           }
         //else if(UserINfo.getUserId()==objWowReqFrm.SE__c || UserINfo.getUserId()==objWowReqFrm.BC__c || UserINfo.getUserId()==objWowReqFrm.SEM__c || (sProfileName =='System Administrator' && lstCstSetting[0].IsAccessible__c == true))
         else if((WoWUtility.IsVirtualTeamExist(string.valueof(objWowReqFrm.Id),UserINfo.getUserId()) && objWowReqFrm.Id != null)|| (sProfileName =='System Administrator' && adminAccessibility.IsAccessible__c == true))
         {
           
           blnVirtualTeam=true;
           system.debug(LoggingLevel.Info,'***blnVirtualTeam**'+blnVirtualTeam);
           system.debug(LoggingLevel.Info,'***objWowReqFrm.Id**'+objWowReqFrm.Id);
           system.debug(LoggingLevel.Info,'***UserINfo.getUserId()**'+UserINfo.getUserId());
         }
         //else if(objOpportunity.Owner.Id==UserINfo.getUserId() || OppRoleHieUser==UserINfo.getUserId() || (sProfileName =='System Administrator' && lstCstSetting[0].IsAccessible__c == true))
         else if(objOpportunity.Owner.Id==UserINfo.getUserId() || (sProfileName =='System Administrator' && adminAccessibility.IsAccessible__c == true))
         {
            blnAE=true;
            system.debug(LoggingLevel.Info,'#enter25 ');
         } 
         
         
         //if(blnAE || blnLead || blnVirtualTeam || (sProfileName =='System Administrator' && lstCstSetting[0].IsAccessible__c == true))
         if(blnAE || blnLead || blnVirtualTeam || (sProfileName =='System Administrator' && adminAccessibility.IsAccessible__c == true) || WoWUtility.HasReadAccessibility(UserINfo.getProfileId()))
         {
           blnMain=true;
         }
          //if(!blnAE && !blnLead && !blnVirtualTeam && sProfileName !='System Administrator' && WoWUtility.HasReadAccessibility(UserINfo.getProfileId()) && objWowReqFrm.AssignTo__c != '' && objWowReqFrm.AssignTo__c != null){
          if(WoWUtility.HasReadAccessibility(UserINfo.getProfileId()) && objWowReqFrm.AssignTo__c != '' && objWowReqFrm.AssignTo__c != null){
             if(objWowReqFrm.AssignTo__c == 'Lead Assign')
                 {
                 AESection_RO = true;
                 LeadSection_RO = false;
                 VTSection_RO = false;
                 StatusSection_RO =true;
                 }
               else if(objWowReqFrm.AssignTo__c == 'Virtual Team')
               {
                 AESection_RO = true;
                 LeadSection_RO = true;                 
                 VTSection_RO = true;
                 StatusSection_RO =true;
               }
              else if(objWowReqFrm.AssignTo__c == 'Lead Completed' || objWowReqFrm.AssignTo__c == 'Completed')
               {                 
                 AESection_RO = true;
                 LeadSection_RO = true;
                 VTSection_RO = true;
                 StatusSection_RO =true;                 
               } 
              else if(objWowReqFrm.AssignTo__c == 'AE')
               {
                 AESection_RO = true;
                 LeadSection_RO = true;
                 VTSection_RO = true;
                 StatusSection_RO =true;
               }                     
                 
          }
            system.debug(LoggingLevel.Info,'#flag '+blnAE +'-----'+blnLead +'-----'+blnVirtualTeam );
             //if(blnExist)
             //{
               /*For AE Section*/
               /*First Time AssignTo wiil be blank and AE can see the record
                 When AE submit the record Assign To become Lead Assign
                 When Lead submit the record Assign To become Virtual Team
                 When Virtual Team submit Assign To become Lead Completed
                 when Wow request completd it will go to AE and Assign To become AE
               */
               
               //blnVirtualTeam=true;
               if((objWowReqFrm.AssignTo__c == '' || objWowReqFrm.AssignTo__c == null) && blnAE)
               {
                 AESection = true;
                 LeadSection = false;
                 VTSection = false;
                 StatusSection=false;
                 btnSave=true;
                 btnSubmit=false;
                 blnShowCancel = true;

                 AESection_RO = false;
                 LeadSection_RO = false;
                 VTSection_RO = false;
                 StatusSection_RO =false;
                 system.debug(LoggingLevel.Info,'++++++objWowReqFrm.AssignTo__c+++++'+objWowReqFrm.AssignTo__c);
               }
               else if(objWowReqFrm.AssignTo__c == 'Lead Assign' && blnLead)               
               {
                 AESection = false;
                 LeadSection = true;
                 VTSection = false;
                 StatusSection=false;
                 btnSave=false;
                 btnSubmit=false;

                 AESection_RO = true;
                 LeadSection_RO = false;
                 VTSection_RO = false;
                 StatusSection_RO =true;
                 blnLeadApproveReject = true;
                 system.debug(LoggingLevel.Info,'++++++$$$$objWowReqFrm.AssignTo__c+++++'+objWowReqFrm.AssignTo__c);
               }
               //Commented by swastika on 28-Sept-2016 subregional leaders can be able to do same activity like virtual team <start>
               //else if(objWowReqFrm.AssignTo__c == 'Virtual Team' && blnLead && sProfileName !='System Administrator')               
               //{
               //  LeadSection = false;                
               //  LeadSection_RO = true;
                 /*AESection_RO = true;
                 LeadSection_RO = true;
                 VTSection_RO = true;
                 StatusSection_RO =true;*/
                 
                 
                 //Added on 28 Sep 2016
                 
                 /*AESection = false;
                 VTSection = true;
                 StatusSection=false;
                 btnSave=false;
                 btnSubmit=false; 
                 AESection_RO = true;
                 VTSection_RO = false;
                 StatusSection_RO =true;*/                 
               //}
               //Commented by swastika on 28-Sept-2016 subregional leaders can be able to do same activity like virtual team <end>

               else if(objWowReqFrm.AssignTo__c == 'Virtual Team' && (blnVirtualTeam || blnLead))
               {
                 //btnSubmit = WoWUtility.GetSubmitStatus(objWowReqFrm.id,UserInfo.GetUserId());
                 
                 AESection = false;
                 //LeadSection = false;
                 LeadSection = true;
                 VTSection = true;
                 StatusSection=false;
                 btnSave=false;
                 btnSubmit=false; //remove comment by swastika temp                

                 AESection_RO = true;
                 LeadSection_RO = false;
                 //LeadSection_RO = true;
                 VTSection_RO = false;//remove comment by swastika temp
                 StatusSection_RO =true;
                 system.debug(LoggingLevel.Info,'++++++$$$$Lead  objWowReqFrm.AssignTo__c+++++'+objWowReqFrm.AssignTo__c);
               }
               //else if((objWowReqFrm.AssignTo__c == 'Lead Completed' || objWowReqFrm.AssignTo__c == 'Completed') && (blnLead || blnVirtualTeam))
               else if((objWowReqFrm.AssignTo__c == 'Lead Completed' || objWowReqFrm.AssignTo__c == 'Completed') && blnLead )
               {
                 AESection = false;
                 LeadSection = false;
                 VTSection = false;
                 StatusSection=true;
                 btnSave=true;
                 btnSubmit=false; // change 23 may

                 AESection_RO = true;
                 LeadSection_RO = true;
                 VTSection_RO = true;
                 StatusSection_RO =false;
                 
               }
               else if(objWowReqFrm.AssignTo__c == 'AE' && blnLead)  // Added on 28 Sep 2016
               {
                system.debug(LoggingLevel.Info,'$$$blnLead$$'+blnLead);
                 AESection = false;
                 LeadSection = false;
                 VTSection = false;
                 StatusSection=true;
                 btnSave=true;
                 btnSubmit=false;

                 AESection_RO = true;
                 LeadSection_RO = true;
                 VTSection_RO = true;
                 StatusSection_RO =false;
               }
               else if(objWowReqFrm.AssignTo__c == 'AE' && blnAE)
               {
                 AESection = false;
                 LeadSection = false;
                 VTSection = false;
                 StatusSection=false;
                 btnSave=true;
                 btnSubmit=true;

                 AESection_RO = true;
                 LeadSection_RO = true;
                 VTSection_RO = true;
                 StatusSection_RO =true;

               }
              
            //}
            system.debug(LoggingLevel.Info,'+++objWowReqFrm.AssignTo__c++++  '+objWowReqFrm.AssignTo__c);
            system.debug(LoggingLevel.Info,'+++blnLead++++  '+blnLead);
            system.debug(LoggingLevel.Info,'+++blnAE++++  '+blnAE);
               if(objWowReqFrm.AssignTo__c == 'Lead Completed' && blnLead)
                 {
                   system.debug(LoggingLevel.Info,'+++Lead Completed+');
                  EngFeedSection = true;
                  EngFeedSection_RO = false;
                 }
                 if((objWowReqFrm.AssignTo__c == 'AE' ||sProfileName =='System Administrator') && !blnAE)
                 {
                   system.debug(LoggingLevel.Info,'+++AE ************+');
                   EngFeedSection = false;
                   EngFeedSection_RO = true;
                 }
                 if(objWowReqFrm.AssignTo__c == 'AE' && (sProfileName =='System Administrator' || blnAE))
                  EngFeedSection_RO = true;
         }
         
        
  }

  /*public void SetReadOnly()
  {
       sIsreadonly = ApexPages.CurrentPage().getParameters().get('view');
       //if record exist in WoW request form
       if(objWowReqFrm!=null && sIsreadonly == null)  
       {
          blnShowAssementLink = true;
          
           if(objWowReqFrm.AssignTo__c == 'Lead Assign')
           {
             AESection_RO = true;
             //LeadSection_RO = false; //24 may
             VTSection_RO = false;
             StatusSection_RO =true;
           }

           else if(objWowReqFrm.AssignTo__c == 'Virtual Team')
           {
             AESection_RO = true;
             //LeadSection_RO = true; //24 may
             if(WoWUtility.HasReadAccessibility(UserINfo.getProfileId()))
                 VTSection_RO = true;
             else    
                 VTSection_RO = false;
             StatusSection_RO =true;
           }
           else if((objWowReqFrm.AssignTo__c == 'Lead Completed' || objWowReqFrm.AssignTo__c == 'Completed'))
           {
             AESection_RO = true;
             //LeadSection_RO = true; // 24 may
             VTSection_RO = true;
             if(WoWUtility.HasReadAccessibility(UserINfo.getProfileId()))
                 StatusSection_RO =true;
             else    
                 StatusSection_RO =false;
           }
           else if(objWowReqFrm.AssignTo__c == 'AE')
           {
             AESection_RO = true;
             //LeadSection_RO = true; // 24 may
             VTSection_RO = true;
             //StatusSection_RO =true; commented by swastika on 10-10-2016 visibility was controled on set visibility function
           }
         }
         //commented by swastika on 10-10-2016 no need to give readonly mode, accessibility will be work on users basis <start>
         //else if(objWowReqFrm!=null && sIsreadonly == 'yes')
         //{
         //     AESection = false;
         //     LeadSection = false;              
         //     VTSection = false;
         //     StatusSection = false; 
              
         //     //btnSave = false;
         //     //btnSubmit = false;

          //    AESection_RO = true;
          //    //LeadSection_RO = true; //24 may
         //     VTSection_RO = true;
         //     StatusSection_RO = true;
              
         //     btnSave = true;
         //     btnSubmit = true;
         //     blnShowAssementLink = false;
         }
        //commented by swastika on 10-10-2016 no need to give readonly mode, accessibility will be work on users basis <end>
  }*/
  
  public void GetWowRequestHistory(string WowID)
  {
    //list_WowHistory = new List<Wow_Request_Form_History__c>();
    if(objWowReqFrm.id!=null)  //Added by Swastika
    { 
       list_WowHistory = WoWUtility.GetHistoryData(WowID);
    }
    else
       list_WowHistory =null;
  }
 
  /*To get all Wow rejected history against the opportunity*/
  public void GetWowRejectedHistory()
  {
    List<Wow_Request_Form__c>list_WowRej = new List<Wow_Request_Form__c>();
    list_WowRej = [Select id,WoW_Status__c,Opportunity_Id__c from Wow_Request_Form__c where Opportunity_Id__c =: objOpportunity.id and WoW_Status__c =: 'Rejected'];
    
    system.debug('++++objOpportunity.id++'+objOpportunity.id);
    List<Wow_Request_Form_History__c > objRejectedH = [Select id,Action__c,UserId__r.name,User_Type__c,W_o_w_Stage__c,WoW_Status_del__c,Date__c,WoW_Request_Id__r.Rejected_Status__c from Wow_Request_Form_History__c where WoW_Request_Id__c IN :list_WowRej];
    if(objRejectedH != null && objRejectedH.size()>0)
    {
       list_WowRejectHistryDtls = new List<Wow_Request_Form_History__c>();
       for(Wow_Request_Form_History__c  obj:objRejectedH )
       {
         if(!obj.action__c.contains('Email Notification :'))
           list_WowRejectHistryDtls.add(obj);
       }
    }  
        system.debug('++++list_WowRejectHistryDtls++'+list_WowRejectHistryDtls);
  }
  

  public void GetAttachmentsWow()
  {
   //if record exist in WoW request form
   if(objWowReqFrm.Id!=null) //Added by Swastika 
   { 
        List<Attachment>list_AllAttach = [Select id,Description,name from Attachment where ParentId =: objWowReqFrm.id];
 system.debug('++++list_AllAttach ++'+list_AllAttach );
        if(list_AllAttach!=null && list_AllAttach.Size()>0)
            for(Attachment objAttach : list_AllAttach)
            {
              if(objAttach.Description == 'Discovery Plan')
                {
                 blnIsDiscovPlan = true;
                 if(list_AttachDiscoveryPlan != null)
                 {
                   list_AttachDiscoveryPlan.add(objAttach);
                 }
                 else
                 {
                   list_AttachDiscoveryPlan = new List<Attachment>();
                   list_AttachDiscoveryPlan.add(objAttach);
                 }   
                }  
              if(objAttach.Description == 'Discovery Finding')
              {
                blnIsDiscAttachment = true;
                if(list_AttachDiscoveryFinding!=null)
                {
                  list_AttachDiscoveryFinding.add(objAttach);
                }
                else
                {
                  list_AttachDiscoveryFinding = new List<Attachment>();
                  list_AttachDiscoveryFinding.add(objAttach);
                }    
              }
              if(objAttach.Description == 'Design Plan')
              {
                blnIsDesignPlan = true;
                if(list_AttachDesignPlan!=null)
                    list_AttachDesignPlan.add(objAttach);
                else
                {
                    list_AttachDesignPlan = new List<Attachment>();
                    list_AttachDesignPlan.add(objAttach);
                    
                }  
              }
              if(objAttach.Description == 'Design Finding')
              {
                blnIsDesignAttachment = true;
                if(list_AttachDesignFinding!=null)
                    list_AttachDesignFinding.add(objAttach);
                else
                {
                    list_AttachDesignFinding = new List<Attachment>();
                    list_AttachDesignFinding.add(objAttach);
                }  
              }
              //if(objAttach.Description == 'SCToolkit:' + objWowReqFrm.FunctionalUseCase__c)
              /*if(objAttach.Description.contains('SCToolkit'))
              {
                blnIsSCToolKit = true;
                if(list_AttachSEToolkit!=null)
                    list_AttachSEToolkit.add(objAttach);
                else
                {
                    list_AttachSEToolkit = new List<Attachment>();
                    list_AttachSEToolkit.add(objAttach);
                }  
              }*/
              //if(objAttach.Description == 'Architectural BluePrint:'+objWowReqFrm.ArchitectureBlueprints__c)
              if(objAttach.Description.contains('Architectural BluePrint'))
              {
                blnIsBluePrintAttach = true;
                if(list_AttachArchiBluePrint!=null)
                    list_AttachArchiBluePrint.add(objAttach);          
                else
                {
                    list_AttachArchiBluePrint = new List<Attachment>();
                    list_AttachArchiBluePrint.add(objAttach);  
                }  
              }  
              if(objAttach.Description.contains('Vision Document'))
              {
                blnIsVisionAttachment = true;
                if(list_AttachVision!=null)
                    list_AttachVision.add(objAttach);          
                else
                {
                    list_AttachVision = new List<Attachment>();
                    list_AttachVision.add(objAttach);  
                }  
              }
              if(objAttach.Description == 'Delivery Findings')
              {
                blnIsDelivFindingAttach = true;
                if(list_AttachDeliveryFinding!=null)
                    list_AttachDeliveryFinding.add(objAttach);
                else
                {
                    list_AttachDeliveryFinding = new List<Attachment>();
                    list_AttachDeliveryFinding.add(objAttach);
                }  
              }
              if(objAttach.Description == 'Custom Use Case')
              {
                blnIsFnUseCaseAttach = true;
                if(list_AttachCustomUseCase!=null)
                    list_AttachCustomUseCase.add(objAttach);
                else
                {
                    list_AttachCustomUseCase= new List<Attachment>();
                    list_AttachCustomUseCase.add(objAttach);
                }  
              }
             //Phase III Changes: Added by Swastika on 01-Nov-2016 to show store attachment for Maturity and Benefits 
             if(objAttach.Description == 'Maturity and Benefits Model')
                {
                 blnIsMaturity = true;
                 if(list_AttachMaturity != null)
                 {
                   list_AttachMaturity.add(objAttach);
                 }
                 else
                 {
                   list_AttachMaturity = new List<Attachment>();
                   list_AttachMaturity.add(objAttach);
                 }   
                }   
               //Phase III Changes: Added by Swastika on 01-Nov-2016 to show store attachment for ROI Calculation
             if(objAttach.Description == 'ROI Calculation')
                {                
                 if(list_AttachROICalculation != null)
                 {
                   list_AttachROICalculation.add(objAttach);
                 }
                 else
                 {
                   list_AttachROICalculation= new List<Attachment>();
                   list_AttachROICalculation.add(objAttach);
                 }   
                }   
                //Phase III Changes: Added by Swastika on 01-Nov-2016 to show store attachment for Bill of Materials
             if(objAttach.Description == 'Bill of Materials')
                {                 
                 if(list_AttachBillMaterial!= null)
                 {
                   list_AttachBillMaterial.add(objAttach);
                 }
                 else
                 {
                   list_AttachBillMaterial= new List<Attachment>();
                   list_AttachBillMaterial.add(objAttach);
                 }   
                }  
              if(objAttach.Description == 'Proposed Sizing')
                {                 
                 if(list_AttachProSizing!= null)
                 {
                   list_AttachProSizing.add(objAttach);
                 }
                 else
                 {
                   list_AttachProSizing = new List<Attachment>();
                   list_AttachProSizing.add(objAttach);
                 }   
                } 
              if(objAttach.Description == 'RFP')
              {  
                blnIsRFP = true;                
                if(list_AttachRFP!=null)
                    list_AttachRFP.add(objAttach);
                else
                {
                    list_AttachRFP = new List<Attachment>();
                    list_AttachRFP.add(objAttach);                    
                }  
              }     
            }
    }
  }
  public void SaveWowDetails()
  {   
     string strHistoryAction='';
     string strWowStage='';
     
     try
     {          
          if(objWowReqFrm.AssignTo__c == '' || objWowReqFrm.AssignTo__c == null )
          {
              objWowReqFrm.AssignTo__c='Lead Assign';
              strWowStage='AE';
              strHistoryAction='Assigned to Lead by AE';
              objWowReqFrm.AE__c=UserInfo.getUserID();
              objWowReqFrm.wow_status__c='Open and Not Assigned';
          }
          else if(objWowReqFrm.AssignTo__c == 'Lead Assign')
          {
               //objWowReqFrm.AssignTo__c='Virtual Team';
               strWowStage='Lead Assign';
               strHistoryAction='SC Engagement Saved by Subregional Leader';
               objWowReqFrm.Lead__c=UserInfo.getUserID();
               if(SelectedStatusType == 'Reject')
                   {
                   blnShowErrorMsg = true;
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select Submit to reject the SC Engagement.'));
                   return;
                   }
               /*if(SelectedStatusType == 'Reject')
                 objWowReqFrm.WoW_Status__c = 'Rejected';
               else
                 objWowReqFrm.wow_status__c='Open and Assigned';*/
           }
           else if(objWowReqFrm.AssignTo__c == 'Virtual Team')
           {
              system.debug('#save_virtual team');
              strHistoryAction='SC Engagement Saved by Virtual Team';
              strWowStage='Virtual Team';
           }
           else if(objWowReqFrm.AssignTo__c == 'Lead Completed' || objWowReqFrm.AssignTo__c == 'Completed')
           {
             system.debug('#save_ae');
             objWowReqFrm.AssignTo__c='AE';
             strWowStage='Virtual Team';
             strHistoryAction='SC Engagement fully completed and AE notified';
           }            
           if(objWowReqFrm.id != null){
              //update objWowReqFrm;
              if(objWowReqFrm.AssignTo__c == 'Virtual Team' || objWowReqFrm.AssignTo__c == 'Lead Assign')
               {
                  //For Virtual team
                 
                  if(objWowReqFrm.AssignTo__c == 'Virtual Team' )
                  {
                      List<WoW_Virtual_Users__c> listVTExist=[SELECT Virtual_User__c,Virtual_User__r.name FROM WoW_Virtual_Users__c Where Wow_Request_Form__c =:objWowReqFrm.id];                      
                      List<WoW_Virtual_Users__c> list_VTDiff= WoWUtility.getDiffVTList(list_VTUserList,listVTExist);
                      system.debug('****list_VTDiff**'+list_VTDiff);
                      if(list_VTDiff.size()>0)
                      {
                        string strResult=WowUtility.SendEmailNotification('Virtual Team Assigned',objWowReqFrm.id,list_VTUserList,null);
                        if(strResult=='Successful')
                            strHistoryAction='Email Notification : to virtual team  that they are assigned as Virtual Team Members on a SC Engagement';
                            //WoWUtility.CreateHistory('Email Notification : to SC_BC_PS SEM  that they are assigned as Virtual Team Members on a SC Engagement',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
                        else
                            strHistoryAction='Email Notification Failed : to virtual team  that they are assigned as Virtual Team Members on a SC Engagement';
                            //WoWUtility.CreateHistory('Email Notification Failed : to SC_BC_PS SEM  that they are assigned as Virtual Team Members on a SC Engagement',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
                      }
                  }
                  //Save virtual users
                   SaveVirtualTeam();
                   objWowReqFrm.VirtualTeamMembers__c=WoWUtility.VirtualTeamNames(objWowReqFrm.Id); 
                   objWowReqFrm.VirtualUserCount__c = list_VTUserList.size(); 
                   /*if(!objWowReqFrm.Vision_Stage_Activities__c)
                   {
                     //Delete All details of vision section 
                     WoWUtility.DeleteWowAttachment(objWowReqFrm.id,'Vision');
                     objWowReqFrm.Vision_Activity__c = null;
                     objWowReqFrm.Vision_Start_Date__c = null;
                   }
                   if(!objWowReqFrm.Discovery_Activities__c)
                   {
                     //Delete All details of discovery section 
                     WoWUtility.DeleteWowAttachment(objWowReqFrm.id,'Discovery Finding');
                     objWowReqFrm.Type_of_Discovery__c = null;
                     objWowReqFrm.Discovery_Start_Date__c = null;
                     objWowReqFrm.Discovery_End_Date__c = null;
                   }
                   if(!objWowReqFrm.Design_Activities__c)
                   {
                     //Delete All details of design section 
                     WoWUtility.DeleteWowAttachment(objWowReqFrm.id,'Design Finding');
                     objWowReqFrm.Type_of_Design__c = null;
                     objWowReqFrm.Design_Start_Date__c = null;
                     objWowReqFrm.Design_End_Date__c = null;
                   }*/
                } 
                 /* string sFnUCase='';
                  if(list_WowAttachmentsFnUseCase != null && list_WowAttachmentsFnUseCase.size()>0)
                  {
                    
                    for(Wow_Attachments__c objWAtt : list_WowAttachmentsFnUseCase)
                    {
                      if(sFnUCase == '')
                        sFnUCase = objWAtt.Functional_Usecases_Numbers__c;
                      else
                        sFnUCase += ',' + objWAtt.Functional_Usecases_Numbers__c;  
                    }
                    objWowReqFrm.FunctionalUsecasesNumbers__c = sFnUCase;
                  }
                  
                  
                 if(sFnUCase != '')
                 {
                   objOpportunity.FunctionalUsecasesNumbers__c = sFnUCase;
                   update objOpportunity;
                 }*/
                
                UpdateFnUseCaseNumbers();
                
                update objWowReqFrm;
              }
           else    
           {
             system.debug('Save3');
             //Assign wrapper class data to wow object add by swastika    
             objWowReqFrm.AE_Name__c=objWrapWow.AEName;
             objWowReqFrm.Opportunity_Name__c=objWrapWow.OpportunityName;
             objWowReqFrm.Stage__c=objWrapWow.Stage;
             objWowReqFrm.Total_Amount__c=objWrapWow.TotalAmount;
             objWowReqFrm.Platform_Type__c=objWrapWow.PlatformType;
             objWowReqFrm.Customer_Name__c=objWrapWow.CustomerName;
             objWowReqFrm.Business_Partner__c=objWrapWow.BusinessPartner;
             objWowReqFrm.Primary_Solution__c=objWrapWow.PrimarySolution;
             objWowReqFrm.Expected_Closed_Date__c=Date.valueOf(objWrapWow.ExpectedClosedDate);
             //Added by swastika
             objWowReqFrm.Opportunity_Id__c=objOpportunity.Id;
             objWowReqFrm.Primary_Business_Objectives__c = objOpportunity.Key_Business_Objective__c;
             objWowReqFrm.CurrencyISOCode=objOpportunity.CurrencyISOCode;
            
              /*string sFnUCase='';
              if(list_WowAttachmentsFnUseCase != null && list_WowAttachmentsFnUseCase.size()>0)
              {
                
                for(Wow_Attachments__c objWAtt : list_WowAttachmentsFnUseCase)
                {
                  if(sFnUCase == '')
                    sFnUCase = objWAtt.Functional_Usecases_Numbers__c;
                  else
                    sFnUCase += ',' + objWAtt.Functional_Usecases_Numbers__c;  
                }
                objWowReqFrm.FunctionalUsecasesNumbers__c = sFnUCase;
              }*/
            //UpdateFnUseCaseNumbers();
             insert objWowReqFrm;
             
             /*Update functional Use cases on Opportunity
             if(sFnUCase != '')
             {
               objOpportunity.FunctionalUsecasesNumbers__c = sFnUCase;
               update objOpportunity;
             }*/
             
            }
            if(list_WowAttachmentsFnUseCase != null && list_WowAttachmentsFnUseCase.size()>0)
            {
               for(integer i=0;i<list_WowAttachmentsFnUseCase.size();i++)
               {
                 if(list_WowAttachmentsFnUseCase[i].Functional_Use_Case__c == null || list_WowAttachmentsFnUseCase[i].Functional_Use_Case__c == '')
                   list_WowAttachmentsFnUseCase.remove(i);
               }
                upsert list_WowAttachmentsFnUseCase;
            }    
            //SaveFunctionalUseCase();
            if(list_WowAttachmentsBluePrint!= null && list_WowAttachmentsBluePrint.size()>0)
                upsert list_WowAttachmentsBluePrint;
            //list<Wow_Attachments__c> list_Link =new List<Wow_Attachments__c>();    
            list_WowVisionLinks= getUpsertVisionLinkList(list_WowVisionLinks);  
            //list_WowVisionLinks = list_Link ;   
            System.debug(LoggingLevel.INFO,'***list_WowVisionLinks**'+list_WowVisionLinks);             
            if(list_WowVisionLinks != null && list_WowVisionLinks.size()>0)
             upsert list_WowVisionLinks;
             if(list_WowAttachmentsDemo != null && list_WowAttachmentsDemo.size()>0)
                upsert list_WowAttachmentsDemo; 
            if(list_WowAttachmentsServiceTran != null && list_WowAttachmentsServiceTran.size()>0)
                upsert list_WowAttachmentsServiceTran; 
            //upsert vision activities with attachment <start>
            if(list_WowVision != null && list_WowVision.size()>0)
                upsert list_WowVision; 
            if(list_WowDiscovery!= null && list_WowDiscovery.size()>0)
                upsert list_WowDiscovery; 
            system.debug(LoggingLevel.Info,'+++++list_WowVision++++'+list_WowVision);
            system.debug(LoggingLevel.Info,'+++++list_VisionActivityAttachment 1++++'+list_VisionActivityAttachment);
            
            //vision attachments      
            for(Wow_Attachments__c objWowV :list_WowVision) 
            {
              for(Attachment objAtt: list_VisionActivityAttachment)
              {
                system.debug(LoggingLevel.Info,'+++++objWowV.Row_Number__c++++'+objWowV.Row_Number__c);
                system.debug(LoggingLevel.Info,'+++++objAtt.Description++++'+objAtt.Description);
                
                if(string.valueof(objWowV.Row_Number__c) == objAtt.Description && objAtt.ParentId == null)
                {
                  objAtt.ParentId = objWowV.id;
                  system.debug(LoggingLevel.Info,'+++++objAtt.ParentId++++'+objAtt.ParentId);
                }     
              }    
            } 
            upsert list_VisionActivityAttachment;
           //discovery attachments 
           for(Wow_Attachments__c objWowD :list_WowDiscovery) 
            {
              for(Attachment objAtt: list_DiscoveryActivityAttachment)
              {               
                if(string.valueof(objWowD .Row_Number__c) == objAtt.Description && objAtt.ParentId == null)
                {
                  objAtt.ParentId = objWowD.id;
                  system.debug(LoggingLevel.Info,'+++++objAtt.ParentId++++'+objAtt.ParentId);
                }     
              }    
            } 
            system.debug(LoggingLevel.Info,'+++++list_VisionActivityAttachment 2++++'+list_VisionActivityAttachment);
            upsert list_DiscoveryActivityAttachment;
             //upsert vision activities with attachment <end>        
            //if(list_WowDiscoveryLinks != null && list_WowDiscoveryLinks.size()>0) 
            // upsert list_WowDiscoveryLinks;           
            if(blnCreateHistory)
                WoWUtility.CreateHistory(strHistoryAction,UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,'Save'),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
            
            CommonMethod(null);
           }    
      catch(Exception ex)   
      {
        blnShowErrorMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
       
      }
           
  }
 
  public PageReference  SubmitWowDetails()
    {    
        PageReference objRef=null;
        blnSubmit=false;
        string sCheckErrMsg='';
        string strHistoryAction='';
        string strWowStage='';
        boolean isLeadComplete = false;
        system.debug('++++objWowReqFrm+++'+objWowReqFrm.id);
       try
       {
            if(objWowReqFrm.AssignTo__c == '' || objWowReqFrm.AssignTo__c == null )
            {
                system.debug('#start');
                objWowReqFrm.AssignTo__c='Lead Assign';
                strWowStage='AE';
    
                objWowReqFrm.AE__c=objOpportunity.Owner.Id;
                objWowReqFrm.wow_status__c='Open and Not Assigned';
                objWowReqFrm.Assign_Queue__c = WowUtility.GetQueueName(objOpportunity.End_User_Region__c);
                objWowReqFrm.Primary_Quote__c = objOpportunity.Primary_Quote__c;  //Phase III Changes: Added by Swastika on 02-Nov-2016 to show store Primary Quote
                strHistoryAction='SC Engagement Request Assigned to Queue : '+WowUtility.GetQueueName(objOpportunity.End_User_Region__c);
                system.debug('++++objOpportunity.End_User_Region__c+++'+objOpportunity.End_User_Region__c);
                system.debug('++++strHistoryAction+++'+strHistoryAction);
                blnSubmit=true;
                /*When AE submit the record .It redirects to opportunity record*/
                objRef = new PageReference('/'+objOpportunity.id);
                objRef.setRedirect(true);
            }
            else if(objWowReqFrm.AssignTo__c == 'Lead Assign')
            {
                system.debug('#lead assign');
                objWowReqFrm.Lead__c=UserInfo.getUserID();
                //objWowReqFrm.Assign_Queue__c = WowUtility.GetQueueName(objOpportunity.End_User_Region__c);
                if(SelectedStatusType == 'Reject')
                {
                    objWowReqFrm.WoW_Status__c = 'Rejected';
                    strHistoryAction='SC DSR Rejected by Leadership';
                    strWowStage='Lead Assign';
                    objWowReqFrm.AssignTo__c='AE';
                }
                else
                {
                    objWowReqFrm.wow_status__c='Open and Assigned';
                    objWowReqFrm.AssignTo__c='Virtual Team';
                    strWowStage='Lead Assign';
                    strHistoryAction='Virtual Team Assigned by Lead';                   
                }
                blnSubmit=true;
                objRef = new PageReference('/apex/wow_request_form?id='+objOpportunity.id);
                objRef.setRedirect(true);
                
              //blnShowErrorMsg = true;
              //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'SC Engagement Form has been submitted successfully.'));
            }
            else if(objWowReqFrm.AssignTo__c == 'Virtual Team')
            {
                /*Save data to update values in object to get updated value to required fields*/
                  /*if(!objWowReqFrm.Vision_Stage_Activities__c)
                   {
                     //Delete All details of vision section 
                     WoWUtility.DeleteWowAttachment(objWowReqFrm.id,'Vision');
                     objWowReqFrm.Vision_Activity__c = null;
                     objWowReqFrm.Vision_Start_Date__c = null;
                   }
                   if(!objWowReqFrm.Discovery_Activities__c)
                   {
                     //Delete All details of discovery section 
                     WoWUtility.DeleteWowAttachment(objWowReqFrm.id,'Discovery Finding');
                     objWowReqFrm.Type_of_Discovery__c = null;
                     objWowReqFrm.Discovery_Start_Date__c = null;
                     objWowReqFrm.Discovery_End_Date__c = null;
                   }
                   if(!objWowReqFrm.Design_Activities__c)
                   {
                     //Delete All details of design section 
                     WoWUtility.DeleteWowAttachment(objWowReqFrm.id,'Design Finding');
                     objWowReqFrm.Type_of_Design__c = null;
                     objWowReqFrm.Design_Start_Date__c = null;
                     objWowReqFrm.Design_End_Date__c = null;
                   }*/
                
                update objWowReqFrm;    
                
                //Added By swastika on 05/25/2017 to update SMART Opportunity 
                if(Schema.sObjectType.Opportunity.isUpdateable()){
                    if(objWowReqFrm.SMART_Opportunity__c <> objOpportunity.SMART_Opportunity__c )
                       {                       
                            objOpportunity.SMART_Opportunity__c = objWowReqFrm.SMART_Opportunity__c;
                            try
                            {
                              update objopportunity;                          
                            }                        
                            catch(Exception ex)
                            {
                              //CommonMethod(null);
                              blnShowErrorMsg = true;
                              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The SMART Opportunity cannot be updated.'));
                               
                             // objRef = null;
                             // return objRef;
                            }
                       }
                  }
                  else
                  {
                  blnShowErrorMsg = true;
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The SMART Opportunity cannot be updated.'));
                  }
                
                system.debug('#virtual team');
               
                strWowStage='Virtual Team';
                //objWowReqFrm.Assign_Queue__c = WowUtility.GetQueueName(objOpportunity.End_User_Region__c);
                strHistoryAction='SC Engagement activities have been performed by Virtual Team';
    
                /* Check All mandatory fields values */
                sCheckErrMsg = WoWUtility.GetMandatoryMessage(objWowReqFrm.id);
                sCheckErrMsg = '';
                if(sCheckErrMsg != '')
                {
                    blnShowErrorMsg = true; 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,sCheckErrMsg));
                    blnSubmit=false;
                    //throw new applicationException(sCheckErrMsg );                    
                    return null;
                }
                else
                {
                    blnSubmit=true;
                    objWowReqFrm.AssignTo__c='Lead Completed';
                    objWowReqFrm.wow_status__c='SC Status Submitted for Completion';
                }
                
                if(list_WowAttachmentsFnUseCase != null && list_WowAttachmentsFnUseCase.size()>0)
                {
                   for(integer i=0;i<list_WowAttachmentsFnUseCase.size();i++)
                   {
                     if(list_WowAttachmentsFnUseCase[i].Functional_Use_Case__c == null || list_WowAttachmentsFnUseCase[i].Functional_Use_Case__c == '')
                       list_WowAttachmentsFnUseCase.remove(i);
                   }
                   upsert list_WowAttachmentsFnUseCase;
                }     
                    //SaveFunctionalUseCase();
                if(list_WowAttachmentsBluePrint!= null && list_WowAttachmentsBluePrint.size()>0)
                    upsert list_WowAttachmentsBluePrint;
                list_WowVisionLinks= getUpsertVisionLinkList(list_WowVisionLinks);      
                if(list_WowVisionLinks != null && list_WowVisionLinks.size()>0)
                 upsert list_WowVisionLinks;
                if(list_WowAttachmentsDemo != null && list_WowAttachmentsDemo.size()>0)
                     upsert list_WowAttachmentsDemo;
                if(list_WowAttachmentsServiceTran != null && list_WowAttachmentsServiceTran.size()>0)
                upsert list_WowAttachmentsServiceTran;                     
                System.debug(LoggingLevel.INFO,'++++list_WowVisionLinks++++ first'+list_WowVisionLinks);  
                
                 //upsert vision activities with attachment <start>
                if(list_WowVision != null && list_WowVision.size()>0)
                    upsert list_WowVision; 
                if(list_WowDiscovery!= null && list_WowDiscovery.size()>0)
                    upsert list_WowDiscovery;     
                for(Wow_Attachments__c objWowV :list_WowVision) 
                {
                  for(Attachment objAtt: list_VisionActivityAttachment)
                  {
                    if(string.valueof(objWowV.Row_Number__c) == objAtt.Description && objAtt.ParentId == null)
                    {
                      objAtt.ParentId = objWowV.id;
                      system.debug(LoggingLevel.Info,'+++++objAtt.ParentId++++'+objAtt.ParentId);
                    }     
                  }    
                }
                upsert list_VisionActivityAttachment;
             //upsert vision activities with attachment <end>  
                
                objRef = null;//new PageReference('/apex/wow_request_form?id='+objOpportunity.id);
                //objRef.setRedirect(true);
                
              // blnShowErrorMsg = true;
              //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'SC Engagement Form has been submitted successfully.')); 
            }
            else if(objWowReqFrm.AssignTo__c == 'Lead Completed' || objWowReqFrm.AssignTo__c == 'Completed')
            {
                isLeadComplete = true;
                system.debug('#ae');
                objWowReqFrm.AssignTo__c='AE';
                strWowStage='Lead Completed';
                //objWowReqFrm.Assign_Queue__c = WowUtility.GetQueueName(objOpportunity.End_User_Region__c);
                strHistoryAction='SC Engagement fully completed and AE notified';
                blnSubmit=true;
                //blnShowErrorMsg = true;
              //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'SC Engagement Form has been submitted successfully.'));
            }
            //added by Swastika on 10-Oct-2016 to reopen close SC
            else if (objWowReqFrm.AssignTo__c == 'AE')
            {
                blnSubmit=true;
                strHistoryAction='SC Engagement status updated to Open and Assigned';
            }
            system.debug(LoggingLevel.INFO,'#objWowReqFrm.AssignTo__c'+objWowReqFrm.AssignTo__c); 
            system.debug('++++update wow1+++');
             system.debug(LoggingLevel.INFO,'#blnSubmit'+blnSubmit);
            if(objWowReqFrm.id != null)
            { 
                if(blnSubmit)
                {                   
                    System.debug(LoggingLevel.INFO,'JL Testing McTesty Testerton');
                    //call before update of wow to execute trigger for apex sharing
                    if(objWowReqFrm.AssignTo__c == 'Lead Assign')
                    {
                      //For Virtual team
                      //SaveVirtualTeam();
                    }
                    //update objWowReqFrm; 
                    if(objWowReqFrm.AssignTo__c == 'Virtual Team' || objWowReqFrm.AssignTo__c == 'Lead Assign' || objWowReqFrm.AssignTo__c == 'Lead Completed')
                    {
                      //For Virtual team
                      SaveVirtualTeam();
                      objWowReqFrm.VirtualTeamMembers__c=WoWUtility.VirtualTeamNames(objWowReqFrm.Id); 
                      objWowReqFrm.VirtualUserCount__c = list_VTUserList.size();                     
                    }
                     System.debug(LoggingLevel.INFO,'++++objWowReqFrm.AssignTo__c first++++'+objWowReqFrm.AssignTo__c);  
                     System.debug(LoggingLevel.INFO,'++++objWowReqFrm.WoW_Status__c++++ first'+objWowReqFrm.WoW_Status__c);  
                     //if(list_VTUserList != null)
                     // objWowReqFrm.VirtualUserCount__c = list_VTUserList.size();
                     UpdateFnUseCaseNumbers();
                     
                     update objWowReqFrm;                     
                     
                }
                
            }      
            else    
            {
               
                system.debug('Save3');
                //Assign wrapper class data to wow object add by swastika    
                objWowReqFrm.AE_Name__c=objWrapWow.AEName;
                objWowReqFrm.Opportunity_Name__c=objWrapWow.OpportunityName;
                objWowReqFrm.Stage__c=objWrapWow.Stage;
                objWowReqFrm.Total_Amount__c=objWrapWow.TotalAmount;
                objWowReqFrm.Platform_Type__c=objWrapWow.PlatformType;
                objWowReqFrm.Customer_Name__c=objWrapWow.CustomerName;
                //objWowReqFrm.Business_Partner__c=objWrapWow.BusinessPartner;
                objWowReqFrm.Primary_Solution__c=objWrapWow.PrimarySolution;
                objWowReqFrm.Expected_Closed_Date__c=Date.valueOf(objWrapWow.ExpectedClosedDate);
                //objWowReqFrm.Primary_Business_Objectives__c=objWrapWow.PrimaryBusinessObjective;
                //Added by swastika
                objWowReqFrm.Opportunity_Id__c=objOpportunity.Id;
                objWowReqFrm.CurrencyISOCode=objWrapWow.CurrencyCode;
                objWowReqFrm.VirtualUserCount__c = 0;
    
                //UpdateFnUseCaseNumbers();
                insert objWowReqFrm;           
                WoWUtility.CreateHistory('SC Request Submitted by AE',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
                //shifted the code in below
                /*if(objWowReqFrm.Primary_Business_Objectives__c <> objOpportunity.Key_Business_Objective__c)
                {
                    objOpportunity.Key_Business_Objective__c=objWowReqFrm.Primary_Business_Objectives__c;
                    try
                    {
                      update objopportunity;
                    }
                    catch(Exception ex)
                    {
                      blnShowErrorMsg = true;
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Accessibility problem. Please contact system administrator.'));
                      objRef = null;
                      return objRef;
                    }
                }*/
                //WoWUtility.CreateHistory('SC Request Submitted by AE',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
            }
           
            System.debug(LoggingLevel.INFO,'++++create history++++');
            if(blnSubmit)
            {
                System.debug(LoggingLevel.INFO,'++++CommonMethod 2222++++');
                WoWUtility.CreateHistory(strHistoryAction,UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
                
                System.debug(LoggingLevel.INFO,'++++CommonMethod++++');
            }    
            
    
            if(objWowReqFrm.AssignTo__c == 'Lead Assign')
            {
                //Send email notification to leads
               
                string strResult=WowUtility.SendEmailNotification('Lead Assigned',objWowReqFrm.id,null,null);
                if(strResult=='Successful')
                    WoWUtility.CreateHistory('Email Notification : Original Notification to Leaders that DSR was submitted',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
                else
                    WoWUtility.CreateHistory('Email Notification Failed : Original Notification to Leaders that DSR was submitted',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
    
                //Send email notification to AE the wow is submitted
                strResult='';
                strResult=WowUtility.SendEmailNotification('Lead Submitted',objWowReqFrm.id,null,null);
                if(strResult=='Successful')
                    WoWUtility.CreateHistory('Email Notification : to AE that SC Engagement was submitted ',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
                else
                    WoWUtility.CreateHistory('Email Notification Failed : to AE that SC Engagement was submitted',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
                //Update opportunity                 
                if(objWowReqFrm.Primary_Business_Objectives__c <> objOpportunity.Key_Business_Objective__c)
                    {
                        objOpportunity.Key_Business_Objective__c = objWowReqFrm.Primary_Business_Objectives__c;                       
                        try
                        {
                          update objopportunity;                          
                        }                        
                        catch(Exception ex)
                        {
                          CommonMethod(null);
                          blnShowErrorMsg = true;
                          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The Opportunity Key Business Objective cannot be updated.'));
                           
                          objRef = null;
                          return objRef;
                        }
                    }    
    
            }
            else if(objWowReqFrm.AssignTo__c == 'Virtual Team' && blnSubmit)
            {
              system.debug('#enter11');
                //Send email notification to AE that Virtual Team is assigned
                string strResult=WowUtility.SendEmailNotification('Wow Accepted',objWowReqFrm.id,null,null);
                if(strResult=='Successful')
                    WoWUtility.CreateHistory('Email Notification : to AE that SC Engagement was accepted',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
                else
                    WoWUtility.CreateHistory('Email Notification Failed : to AE that SC Engagement was accepted',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
    
    
                //Send email notification to AE that Virtual Team is assigned
                system.debug('**list_VTUserList**'+list_VTUserList);
                strResult=WowUtility.SendEmailNotification('Virtual Team Assigned',objWowReqFrm.id,list_VTUserList,null);
                if(strResult=='Successful')
                    WoWUtility.CreateHistory('Email Notification : to virtual team that they are assigned as Virtual Team Members on a SC Engagement',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
                else
                    WoWUtility.CreateHistory('Email Notification Failed : to virtual team  that they are assigned as Virtual Team Members on a SC Engagement',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
                /*if(objWowReqFrm.AssignTo__c == 'Virtual Team' || objWowReqFrm.AssignTo__c == 'Lead Assign')
                    {
                      //For Virtual team
                      SaveVirtualTeam();
                    } */   
            }
            else if(objWowReqFrm.AssignTo__c == 'Lead Completed' || objWowReqFrm.AssignTo__c == 'Completed')
            {
                System.debug(LoggingLevel.INFO,'++++objWowReqFrm.AssignTo__c 1++++'+objWowReqFrm.AssignTo__c);
                //Send email notification to AE that Virtual Team is assigned
                string strResult=WowUtility.SendEmailNotification('Lead Completed',objWowReqFrm.id,null,null);
                if(strResult=='Successful')
                    WoWUtility.CreateHistory('Email Notification : to leaders once SC Engagement activities have been performed',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
                else
                    WoWUtility.CreateHistory('Email Notification Failed : to leaders once SC Engagement activities have been performed',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
            
              System.debug(LoggingLevel.INFO,'++++objWowReqFrm.AssignTo__c 2++++'+objWowReqFrm.AssignTo__c);
            } 
            else if(objWowReqFrm.AssignTo__c == 'AE' && objWowReqFrm.wow_status__c <> 'Rejected' && objWowReqFrm.wow_status__c <>'Open and Assigned')
            {
                //Send email notification to AE that wow engagement is fully completed
                string strResult=WowUtility.SendEmailNotification('AE',objWowReqFrm.id,null,null);
                if(strResult=='Successful')
                    WoWUtility.CreateHistory('Email Notification : to AE that SC Engagement is fully completed',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
                else
                    WoWUtility.CreateHistory('Email Notification Failed : to AE  that SC Engagement is fully completed',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
            } 
            
            if(objWowReqFrm.wow_status__c == 'Rejected')
            {
                //Send email notification to AE that wow engagement is fully completed
                string strResult=WowUtility.SendEmailNotification('Wow Rejected',objWowReqFrm.id,null,null);
                if(strResult=='Successful')
                    WoWUtility.CreateHistory('Email Notification : to AE that SC Engagement was rejected',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
                else
                    WoWUtility.CreateHistory('Email Notification Failed : to AE that SC Engagement was rejected',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
     
              //objWowReqFrm = null;
              //objRef = ApexPages.CurrentPage();
            } 
    
            //if(sCheckErrMsg<>'')
            //    CommonMethod(sCheckErrMsg);
           // else
           // {
            
            // Added on 28 Sep 2016 Reopen Wow Request
            if(objWowReqFrm.AssignTo__c == 'AE' && objWowReqFrm.wow_status__c == 'Open and Assigned')
            {
              objWowReqFrm.AssignTo__c = 'Virtual Team';
              update objWowReqFrm;
              //WoWUtility.CreateHistory('SC Engagement status updated to Open and Assigned',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,null),strWowStage,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
            }
               
              
           System.debug(LoggingLevel.INFO,'++++CommonMethod(null) 2++++');
               
               System.debug(LoggingLevel.INFO,'++++objWowReqFrm.AssignTo__c++++'+objWowReqFrm.AssignTo__c);  
                System.debug(LoggingLevel.INFO,'++++objWowReqFrm.WoW_Status__c++++'+objWowReqFrm.WoW_Status__c);  
             
             CommonMethod(null);
             
              //if(objWowReqFrm.AssignTo__c != '')
              if(objWowReqFrm.AssignTo__c == 'AE')
              {
                blnShowErrorMsg = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'SC Engagement Request has been submitted successfully.')); 
              }
              System.debug(LoggingLevel.INFO,'++++objWowReqFrm.AssignTo__c for Lead++++  '+objWowReqFrm.AssignTo__c); 
              if(objWowReqFrm.AssignTo__c == 'Lead Completed')
              {
                blnShowErrorMsg = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Closing this DSR indicates that no future presales work is required on this opportunity.')); 
              } 
          //}
      }
      catch(DMLException ex)   
      {
        //CommonMethod(null); 
        if(isLeadComplete) 
          objWowReqFrm.AssignTo__c='Lead Completed';
        blnShowErrorMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getDmlMessage(0)));
        
        
      }         
      return objRef;    
  }
  
  private void UpdateFnUseCaseNumbers()
  {
    string sFnUCase='';    
    
      if(list_WowAttachmentsFnUseCase != null && list_WowAttachmentsFnUseCase.size()>0)
      {
        integer UseCase = 0;      
        for(Wow_Attachments__c objWAtt : list_WowAttachmentsFnUseCase)
        {
         if(objWAtt.Functional_Use_Case__c!='' && objWAtt.Functional_Use_Case__c!=null){
           UseCase =objWAtt.Functional_Use_Case__c.indexOf(': ')+1;
           system.debug('**UseCase ***'+UseCase);
          //if(objWAtt.Functional_Usecases_Numbers__c !=null && objWAtt.Functional_Use_Case__c != null) {
            if(sFnUCase == '' )
              sFnUCase = objWAtt.Functional_Use_Case__c.substring(UseCase,UseCase+5);              
             else
              sFnUCase += ',' + objWAtt.Functional_Use_Case__c.substring(UseCase ,UseCase+5);  
              
          //}
          }
        }
        //if(sFnUCase != '')
        objWowReqFrm.FunctionalUsecasesNumbers__c = sFnUCase;
      }
      system.debug('sFnUCase ** '+sFnUCase);      
      /*Update functional Use cases on Opportunity*/
     //if(sFnUCase != '')
     //{
       objOpportunity.FunctionalUsecasesNumbers__c = sFnUCase;
       if(!Test.isRunningTest())
         update objOpportunity;
     //}
  }
    
  public List<SelectOption> getStatusTypes() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('Approve','Approve'));
    options.add(new SelectOption('Reject','Reject'));
    return options;
  }
   public System.PageReference UploadFile()  
   {  
      try
      { 
        System.debug(LoggingLevel.INFO,'++++fileName ++++'+fileName );  
        if(fileBody == null || fileName == '') 
        {       
          blnShowErrorMsg = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select the '+FileDescType+' file.'));
          //return null;
        }  
        
        blnCreateHistory=false;
        
         System.debug(LoggingLevel.INFO,'++++FileDescType ++++'+FileDescType );  
         
        if(FileDescType == 'Vision Activity')
         AddVisionAttachment();
        if(FileDescType == 'Discovery Activity')
         AddDiscoveryAttachment(); 
        
        SaveWowDetails();

        string sAttType='';
        string sAttSubType='';
        system.debug('**FileDescType **'+FileDescType );
        if(FileDescType == 'Discovery Plan' || FileDescType =='Discovery Finding' || FileDescType =='Design Plan' || FileDescType =='Design Finding' || FileDescType =='Vision Document' || FileDescType =='Delivery Findings' || FileDescType =='Architectural BluePrint' || FileDescType =='SCToolkit' || FileDescType =='Custom Use Case' || FileDescType =='Maturity and Benefits Model' || FileDescType =='ROI Calculation' || FileDescType =='Bill of Materials' || FileDescType =='Proposed Sizing' || FileDescType =='RFP')
        {
          
          if(FileDescType == 'Discovery Plan')
          {
           sAttType = 'Discovery';
           sAttSubType = FileDescType;
          }
          if(FileDescType == 'Discovery Finding')
          {
           sAttType = 'Discovery';
           sAttSubType = FileDescType;
          }
          if(FileDescType == 'Design Plan')
          {
           sAttType = 'Design';
           sAttSubType = FileDescType;
          }
          if(FileDescType == 'Design Finding')
          {
           sAttType = 'Design';
           sAttSubType = FileDescType;
          }
          if(FileDescType == 'Vision Document')
          {
           sAttType = 'Vision';
           sAttSubType = FileDescType;
          }
          if(FileDescType == 'Delivery Findings')
          {
           sAttType = 'Delivery Findings';
           sAttSubType = FileDescType;
          }
          //sFileDesc = FileDescType;
          if(FileDescType == 'Architectural BluePrint')
          {
           sAttType = 'Architectural BluePrint';
           sAttSubType = 'Architectural BluePrint';
          }
          if(FileDescType == 'SCToolkit')
          {
           sAttType = 'SCToolkit';
           sAttSubType = 'SCToolkit';
          }
          if(FileDescType == 'Custom Use Case')
          {
           sAttType = 'Custom Use Case';
           sAttSubType = 'Custom Use Case';
          }
          if(FileDescType == 'Maturity and Benefits Model')
          {
           sAttType = 'Discovery';
           sAttSubType = FileDescType;
          }
           if(FileDescType == 'ROI Calculation')
          {
           sAttType = 'Design';
           sAttSubType = FileDescType;
          }
           if(FileDescType == 'Bill of Materials')
          {
           sAttType = 'Design';
           sAttSubType = FileDescType;
          }
          if(FileDescType == 'Proposed Sizing')
          {
           sAttType = 'Architectural BluePrint';
           sAttSubType = FileDescType;
          }
           if(FileDescType == 'Proposed Sizing')
          {
           sAttType = 'RFP';
           sAttSubType = FileDescType;
          }          
        }
        /*else
        {
          string[]arrType = FileDescType.split(':');
          sAttType = arrType[0];
          sAttSubType = arrType[1];
          //sFileDesc = sAttType ;
        } */       
        
        if(FileDescType != 'Vision Activity' || FileDescType != 'Discovery Activity')
        {
            Attachment obj = new Attachment();
            obj.Body = fileBody;
            obj.Name = fileName;       
            obj.ParentId = objWowReqFrm.id;       
            obj.Description = FileDescType ;
            insert obj;
            PageReference objRef = new PageReference('/apex/wow_request_form?id='+objOpportunity.id);
            objRef.setRedirect(true);
            return objRef;
        }
            
        //WoWUtility.CreateHistory('Attachment - ' + FileDescType,UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id),objWowReqFrm.AssignTo__c,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
        WoWUtility.CreateHistory('Document attached to SC Engagement',sAttType , sAttSubType  ,UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,'Save'),objWowReqFrm.AssignTo__c,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
        CommonMethod(null);

        PageReference objRef = new PageReference('/apex/wow_request_form?id='+objOpportunity.id);
        objRef.setRedirect(true);
        return objRef;
       //return pr;
      }
      catch(Exception ex)   
      {
        blnShowErrorMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage())); 
        return null;       
      } 
   }
    
   public PageReference  FileDescription()
   {
      return null;
   }
   public void GetWowHistoryDetails()
   {
      //if record exist in WoW request form
       if(objWowReqFrm.id!=null)  //Added by Swastika
           { 
             list_WowHistory = new List<Wow_Request_Form_History__c>();
             list_WowHistory = [select id,WoW_Request_Id__c,Action__c,Date__c,User__c,User_Type__c,WoW_Status_del__c from Wow_Request_Form_History__c where WoW_Request_Id__c =: objWowReqFrm.id];
           }
       else
           list_WowHistory =null;    
   }
   
   /* Check LoggedIn user in Queue */
   /*public boolean CheckLoggedInUserType(string sRegionName)
   {
     boolean isExist = false;
     // Get id of Queue based of name
     Group objGroup = [Select Id from Group where type=: 'Queue' and Name=: sRegionName];
     //Group objGroup = [Select Id from Group where type=: 'Queue' and Name =: sRegionName];
     
     //Now use this queue id to get the assigned members
     List<GroupMember>lstQueueUsers = [Select UserOrGroupId From GroupMember where GroupId =: objGroup.id];
     if(lstQueueUsers.size()>0) //Added by Swastika
         //Compare loggedIn user id with Queue's users
         for(GroupMember objGm : lstQueueUsers)
         {
           if(objGm.UserOrGroupId == UserInfo.getUserId())
           {
             isExist = true;
           }
         }
     return isExist;
   }*/
   
   public void AddFunctionUseCase()
   {
     //integer iLastNumb = CheckLastNumber(list_WowAttachmentsFnUseCase);
     //system.debug('****iLastNumb**'+iLastNumb);
     Wow_Attachments__c objWowAtt = new Wow_Attachments__c();
     objWowAtt.Wow_Request_Form__c = objWowReqFrm.id;
     objWowAtt.Type__c = 'Functional Use Case';
     //objWowAtt.Row_Number__c = iLastNumb + 1 ;//list_WowAttachmentsFnUseCase.size() + 1;
     //objWowAtt.Functional_Usecases_Numbers__c = 'CE' + (iLastNumb + 1);     
     
     list_WowAttachmentsFnUseCase.add(objWowAtt);
     system.debug('****list_WowAttachmentsFnUseCase**'+list_WowAttachmentsFnUseCase);
   }
   
   /*private integer CheckLastNumber(List<Wow_Attachments__c>lst)
   {
      integer iLastNumb=0;
     for(Wow_Attachments__c obj :lst)
     {
       if(obj.Functional_Usecases_Numbers__c!=null && obj.Functional_Usecases_Numbers__c!='')
        if(integer.valueof(obj.Functional_Usecases_Numbers__c.substring(2)) > iLastNumb)
         iLastNumb = integer.valueof(obj.Functional_Usecases_Numbers__c.substring(2));
     }
    return  iLastNumb;
   }*/
    public void AddVision()
   {   
     Wow_Attachments__c objWowAtt = new Wow_Attachments__c();
     objWowAtt.Wow_Request_Form__c = objWowReqFrm.id;
     objWowAtt.Type__c = 'Vision Activity';
     objWowAtt.Row_Number__c = getMaxRowNo(list_WowVision)+1;//list_WowVision.size() + 1;     
     list_WowVision.add(objWowAtt);   
     System.debug(LoggingLevel.INFO,'++++objWowAtt.Row_Number__c ++++'+objWowAtt.Row_Number__c);     
   }
   public void AddDiscovery()
   {   
     Wow_Attachments__c objWowAtt = new Wow_Attachments__c();
     objWowAtt.Wow_Request_Form__c = objWowReqFrm.id;
     objWowAtt.Type__c = 'Discovery';
     objWowAtt.Row_Number__c = getMaxRowNo(list_WowDiscovery)+1;
     list_WowDiscovery.add(objWowAtt);
   }
   public void AddDemo()
   {
     Wow_Attachments__c objWowAtt = new Wow_Attachments__c();
     objWowAtt.Wow_Request_Form__c = objWowReqFrm.id;
     objWowAtt.Type__c = 'Demo';
     objWowAtt.Row_Number__c = list_WowAttachmentsDemo.size() + 1;     
     list_WowAttachmentsDemo.add(objWowAtt);
   }
    public void AddServiceTran()
   {
     Wow_Attachments__c objWowAtt = new Wow_Attachments__c();
     objWowAtt.Wow_Request_Form__c = objWowReqFrm.id;
     objWowAtt.Type__c = 'Services Transition';
     objWowAtt.Row_Number__c = list_WowAttachmentsServiceTran.size() + 1;
     list_WowAttachmentsServiceTran.add(objWowAtt);
   }
   public void AddVisionAttachment()
   { 
       Attachment obj = new Attachment();
        obj.Body = fileBody;
        obj.Name = fileName;       
        system.debug('***RowNumber**'+  RowNumber);           
        obj.Description = string.valueof(RowNumber);
        list_VisionActivityAttachment.add(obj);
        system.debug('list_VisionActivityAttachment'+  list_VisionActivityAttachment); 
   }
   public void AddDiscoveryAttachment()
   { 
       Attachment obj = new Attachment();
        obj.Body = fileBody;
        obj.Name = fileName;  
        obj.Description = string.valueof(RowNumber);
        list_DiscoveryActivityAttachment.add(obj);       
   }
   public PageReference RemoveVisionActivity()
   { 
      PageReference objRef=null;
       Id wowVisionId=null;      
       system.debug(LoggingLevel.info,'++++++CurrentVision +++++'+CurrentVision ); 
       system.debug(LoggingLevel.info,'++++++visionId+++++'+visionId);  
      if(list_WowVision.size() > 0)
      {   
         if(CurrentVision != '' && CurrentVision != null) 
         {
           integer Idx = 0;
           integer removeIndex; 
           for(Wow_Attachments__c objW2 : list_WowVision)
           {
             if(objW2.Row_Number__c == integer.valueof(CurrentVision))
             {
               removeIndex = Idx ;
               wowVisionId= objW2.Id;
             } 
             Idx += 1;  
           }
           
           list_WowVision.Remove(removeIndex); 
           system.debug(LoggingLevel.info,'++++++RemoveVisionActivity list_WowVision+++++'+list_WowVision); 
           system.debug(LoggingLevel.info,'++++++wowVisionId+++++'+wowVisionId); 
           
           list<attachment> list_attach= [select Id from attachment where parentId=: wowVisionId];
           delete list_attach;
           
           List<Wow_Attachments__c> objWowAtch = [Select id from Wow_Attachments__c where id =: wowVisionId];
           delete objWowAtch;          
           if(list_WowVision.size()<=0)
             AddVision();         
          }
       }  
       else
       {
         list_WowVision= new List<Wow_Attachments__c>();
         AddVision();
       }            
       /* if(VisionId != '' && VisionId != null)
        {
          list<attachment> list_attach= [select Id from attachment where parentId=: VisionId];
          delete list_attach;  
          List<Wow_Attachments__c> objWowAtch = [Select id from Wow_Attachments__c where id =: VisionId];
          delete objWowAtch;          
          if(list_WowVision.size()<=0)
           AddVision();
        } */
        objRef = new PageReference('/apex/wow_request_form?id='+objOpportunity.id);
        objRef.setRedirect(true);
        return objRef; 
    }   
    public PageReference RemoveDiscoveryActivity()
   { 
      PageReference objRef=null;
       Id wowDiscoveryId=null;      
       system.debug(LoggingLevel.info,'++++++CurrentDiscovery +++++'+CurrentDiscovery ); 
       system.debug(LoggingLevel.info,'++++++DiscoveryId+++++'+DiscoveryId);  
      if(list_WowDiscovery.size() > 0)
      {   
         if(CurrentDiscovery!= '' && CurrentDiscovery!= null) 
         {
           integer Idx = 0;
           integer removeIndex; 
           for(Wow_Attachments__c objW2 : list_WowDiscovery)
           {
             if(objW2.Row_Number__c == integer.valueof(CurrentDiscovery))
             {
               removeIndex = Idx ;
               wowDiscoveryId= objW2.Id;
             } 
             Idx += 1;  
           }
           
           list_WowDiscovery.Remove(removeIndex); 
           system.debug(LoggingLevel.info,'++++++list_WowDiscovery+++++'+list_WowDiscovery); 
           system.debug(LoggingLevel.info,'++++++wowDiscoveryId+++++'+wowDiscoveryId); 
           
           list<attachment> list_attach= [select Id from attachment where parentId=: wowDiscoveryId];
           delete list_attach;
           
           List<Wow_Attachments__c> objWowAtch = [Select id from Wow_Attachments__c where id =: wowDiscoveryId];
           delete objWowAtch;          
           if(list_WowDiscovery.size()<=0)
             AddVision();         
          }
       }  
       else
       {
         list_WowDiscovery= new List<Wow_Attachments__c>();
         AddVision();
       }            
        objRef = new PageReference('/apex/wow_request_form?id='+objOpportunity.id);
        objRef.setRedirect(true);
        return objRef; 
    }   
   public void RemoveFunctionalUseCase()
   {
        System.debug(LoggingLevel.Info, 'CurrentFunUseCase'+CurrentFunUseCase);
        System.debug(LoggingLevel.Info, 'list_WowAttachmentsFnUseCase'+list_WowAttachmentsFnUseCase);
        
      if(list_WowAttachmentsFnUseCase.size() > 1)
      {   
         if(CurrentFunUseCase != '' && CurrentFunUseCase != null) 
         {
           integer Idx = 0;
           integer removeIndex; 
           for(Wow_Attachments__c objW2 : list_WowAttachmentsFnUseCase)
           {
             if(objW2.Row_Number__c == integer.valueof(CurrentFunUseCase))
             {
               removeIndex = Idx ;
             }  
               
             Idx += 1;  
           }
           list_WowAttachmentsFnUseCase.Remove(removeIndex);
           //system.debug('++list_VTUserList++'+list_VTUserList);
           //if(list_VTUserList.size()>0)
            //  blnIsVTListExist =true;
           //else    
            // blnIsVTListExist =false;
            System.debug(LoggingLevel.Info, 'FunUseCaseId '+FunUseCaseId );
          }
       }  
       else
       {
         list_WowAttachmentsFnUseCase = new List<Wow_Attachments__c>();
         AddFunctionUseCase();
       }            
            if(FunUseCaseId != '' && FunUseCaseId != null)
            {
              UpdateFnUseCaseNumbers();
              List<Wow_Attachments__c> objWowAtch = [Select id from Wow_Attachments__c where id =: FunUseCaseId];
              delete objWowAtch;
              
              if(list_WowAttachmentsFnUseCase .size()<=0)
               AddFunctionUseCase();
            }  
            
            CommonMethod(null);
            
    } 
   public void RemoveBluePrint()
   {

          if(list_WowAttachmentsBluePrint.size() > 1)
          {
            if(CurrentBlePrint != '' && CurrentBlePrint != null)
            {
               integer Idx = 0;
               integer removeIndex; 
               for(Wow_Attachments__c objW2 : list_WowAttachmentsBluePrint)
               {
                 if(objW2.Row_Number__c == integer.valueof(CurrentBlePrint))
                 {
                   removeIndex = Idx ;
                 }  
                   
                 Idx += 1;  
               }
               list_WowAttachmentsBluePrint.Remove(removeIndex);
             }  
           }
           else
           {
             list_WowAttachmentsBluePrint = new List<Wow_Attachments__c>();
             AddBluePrint();
           }
            if(BpId != '' && BpId != null)
            {
              List<Wow_Attachments__c> objWowAtch = [Select id from Wow_Attachments__c where id =: BpId];
              delete objWowAtch;
              
              if(list_WowAttachmentsBluePrint.size()<=0)
              AddBluePrint();
            }  
         
   
    }  
   public void RemoveDemoActivity()
   {       
      if(list_WowAttachmentsDemo.size() > 1)
      {   
         if(CurrentDemo != '' && CurrentDemo != null) 
         {
           integer Idx = 0;
           integer removeIndex; 
           for(Wow_Attachments__c objW2 : list_WowAttachmentsDemo)
           {
             if(objW2.Row_Number__c == integer.valueof(CurrentDemo))
             {
               removeIndex = Idx ;
             }  
               
             Idx += 1;  
           }
           list_WowAttachmentsDemo.Remove(removeIndex);           
          }
       }  
       else
       {
         list_WowAttachmentsDemo= new List<Wow_Attachments__c>();
         AddVision();
       }            
        if(DemoId != '' && DemoId != null)
        {
          List<Wow_Attachments__c> objWowAtch = [Select id from Wow_Attachments__c where id =: DemoId];
          delete objWowAtch;
          
          if(list_WowAttachmentsDemo.size()<=0)
           AddVision();
        }  
            
    }  
   public void RemoveServiceTranActivity()
   {       
      if(list_WowAttachmentsServiceTran.size() > 1)
      {   
         if(CurrentServTran != '' && CurrentServTran != null) 
         {
           integer Idx = 0;
           integer removeIndex; 
           for(Wow_Attachments__c objW2 : list_WowAttachmentsServiceTran)
           {
             if(objW2.Row_Number__c == integer.valueof(CurrentServTran))
             {
               removeIndex = Idx ;    
             }  
               
             Idx += 1;  
           }
           list_WowAttachmentsServiceTran.Remove(removeIndex);           
          }
       }  
       else
       {
         list_WowAttachmentsServiceTran= new List<Wow_Attachments__c>();
         AddServiceTran();
       }            
        if(ServTranId != '' && ServTranId != null)
        {
          List<Wow_Attachments__c> objWowAtch = [Select id from Wow_Attachments__c where id =: ServTranId];
          delete objWowAtch;
          
          if(list_WowAttachmentsServiceTran.size()<=0)
           AddServiceTran();
        }  
            
    }       
   public void AddBluePrint()
   {
     Wow_Attachments__c objWowAtt = new Wow_Attachments__c();
     objWowAtt.Wow_Request_Form__c = objWowReqFrm.id;
     objWowAtt.Type__c = 'Architectural Blueprint';
     objWowAtt.Row_Number__c = list_WowAttachmentsBluePrint.size() + 1;
     list_WowAttachmentsBluePrint.add(objWowAtt);
   }
   public void AddVisionLink()
   {
     Wow_Attachments__c objWowAtt = new Wow_Attachments__c();
     objWowAtt.Wow_Request_Form__c = objWowReqFrm.id;
     objWowAtt.Type__c = 'Vision';     
     list_WowVisionLinks.add(objWowAtt);
   }
   /*public void AddDiscoveryLink()
   {
     Wow_Attachments__c objWowAtt = new Wow_Attachments__c();
     objWowAtt.Wow_Request_Form__c = objWowReqFrm.id;
     objWowAtt.Type__c = 'Discovery Finding';
     
     list_WowDiscoveryLinks.add(objWowAtt);
   }*/
   public void RemoveVTUser()
   {      
       WoW_Virtual_Users__c objWowNewVT= new WoW_Virtual_Users__c();
       for(Integer i = list_VTUserList.size() - 1; i >= 0 ; --i)
           {
               if(list_VTUserList.get(i).get('Virtual_User__c')==CurrentVT && list_VTUserList.get(i).get('Virtual_User_type__c')==CurrentVTType)
                  list_VTUserList.Remove(i); 
           }
        objWowReqFrm.VirtualUserCount__c = list_VTUserList.size();
           
           system.debug('++list_VTUserList++'+list_VTUserList);
           if(list_VTUserList.size()>0)
              blnIsVTListExist =true;
           else    
             blnIsVTListExist =false;
    }
   public void GetVTUserList()
   {   
         WoW_Virtual_Users__c objWowNewVT= new WoW_Virtual_Users__c();
          objWowNewVT.Wow_Request_Form__c=objWowReqFrm.Id;
          objWowNewVT.Virtual_User_type__c = objWowVT.Virtual_User_type__c; 
          objWowNewVT.Virtual_User__c = objWowVT.Virtual_User__c; 
         
          objWowNewVT.Id=null;
          list_VTUserList.add(objWowNewVT); 
          
          objWowReqFrm.VirtualUserCount__c = list_VTUserList.size();         
          
          objWowVT.Virtual_User_type__c=null;
          objWowVT.Virtual_User__c=null;
          //objWowVT=null;         
       system.debug('list_VTUserList '+list_VTUserList);
      if(list_VTUserList.size()>0)
          blnIsVTListExist =true;
      
   }
   /*public void InitializeVT()
   { 
      if(list_VTSCList.size()==0)
          {
          WoW_Virtual_Users__c objSCVT = new WoW_Virtual_Users__c();     
          objSCVT.Wow_Request_Form__c=objWowReqFrm.Id;
          objSCVT.Virtual_User_type__c='Solution Consultant';
          list_VTSCList.add(objSCVT); 
          }
      if(list_VTBCList.size()==0)
          {
           WoW_Virtual_Users__c objBCVT = new WoW_Virtual_Users__c();     
          objBCVT.Wow_Request_Form__c=objWowReqFrm.Id;
          objBCVT.Virtual_User_type__c='Business Consultant';
          list_VTBCList.add(objBCVT); 
          }
      if(list_VTPSList.size()==0){
           WoW_Virtual_Users__c objPSVT = new WoW_Virtual_Users__c();     
          objPSVT.Wow_Request_Form__c=objWowReqFrm.Id;
          objPSVT.Virtual_User_type__c='PS Consulting Sales Director';
          list_VTPSList.add(objPSVT);
      } 
      if(list_VTSLList.size()==0){
          WoW_Virtual_Users__c objSLVT = new WoW_Virtual_Users__c();     
          objSLVT.Wow_Request_Form__c=objWowReqFrm.Id;
          objSLVT.Virtual_User_type__c='Solution Lead';
          list_VTSLList.add(objSLVT);
      } 
   }*/
   
   public class clsWrapperWowDeatils
   {
      public string AEName{get;set;}
      public string OpportunityName{get;set;}
      public string Stage{get;set;}
      public decimal TotalAmount{get;set;}
      public string PlatformType{get;set;}
      public string CustomerName{get;set;}
      public string BusinessPartner{get;set;}
      public string PrimarySolution{get;set;}
      public string ExpectedClosedDate{get;set;}
      public string PrimaryBusinessObjective{get;set;}
      public string CurrencyCode{get;set;}
      public string Industry{get;set;}
      public string OpportunityStage{get;set;}
      public string OfferingType{get;set;}
      public string Segment{get;set;}
      public string AccSegment{get;set;}      
      public clsWrapperWowDeatils(Opportunity objOpp)
      {      
        //AEName = objOpp.AE_Name__r.name;
        system.debug('objOpp.Owner.Name '+objOpp.Owner.Name);
        AEName = objOpp.Owner.Name;        
        OpportunityName = objOpp.name;
        Stage = objOpp.StageName;
        TotalAmount = objOpp.Amount;
        PlatformType = objOpp.Primary_Line_of_Business__c;
        CustomerName = objOpp.Account.name;
        BusinessPartner = objOpp.BusinessPartner__r.Name;
        PrimarySolution = objOpp.Primary_Solution_Category__c;
        ExpectedClosedDate = string.valueof(objOpp.CloseDate);
        CurrencyCode = objOpp.CurrencyISOCode; 
        Industry = objOpp.Industry__c; 
        //PrimaryBusinessObjective = objOpp.Key_Business_Objective__c; 
        OpportunityStage = objOpp.StageName;
        OfferingType = objOpp.Lines_of_Businesses__c;
        Segment = objOpp.Owner.Segment__c;
        AccSegment =  objOpp.Account.Account_Segmentation__c;    
      }
      public clsWrapperWowDeatils(Wow_Request_Form__c objWow)
      {
        //Assign data from wow object
        AEName = objWow.AE_Name__c;
        OpportunityName = objWow.Opportunity_Name__c;
        Stage = objWow.Stage__c;
        TotalAmount = objWow.Total_Amount__c;
        PlatformType = objWow.Platform_Type__c;
        CustomerName = objWow.Customer_Name__c;
        BusinessPartner = objWow.Business_Partner__c;
        PrimarySolution = objWow.Primary_Solution__c;
        ExpectedClosedDate = string.valueof(objWow.Expected_Closed_Date__c);
        PrimaryBusinessObjective = objWow.Primary_Business_Objectives__c;
        CurrencyCode=objWow.CurrencyISOCode;
        Industry=objWow.Industry__c;
        OpportunityStage = objWow.Opportunity_Stage__c;
        OfferingType = objWow.Opportunity_Id__r.Lines_of_Businesses__c;
        Segment = objWow.Opportunity_Id__r.Owner.Segment__c;
        AccSegment = objWow.Opportunity_Id__r.Account.Account_Segmentation__c;
      }
   }  
   private void SaveVirtualTeam(){
       System.debug(LoggingLevel.INFO,'SaveVirtualTeam-Start'); 
        list_WowExistVT=new list<WoW_Virtual_Users__c>();      
         
            list_WowExistVT=[SELECT Id,Virtual_User__c,Virtual_User_type__c FROM WoW_Virtual_Users__c WHERE Wow_Request_Form__c=:objWowReqFrm.id ]; 
            if(list_WowExistVT!=null && list_WowExistVT.size()>0)
                delete list_WowExistVT;
                system.debug('list_VTUserList-save'+list_VTUserList);
         if(list_VTUserList.size()>0)
         {    
            insert list_VTUserList; 
            System.debug(LoggingLevel.INFO,'SaveVirtualTeam-insert'); 
            blnIsVTListExist =true;          
         }
          System.debug(LoggingLevel.INFO,'SaveVirtualTeam-End'); 
   }
   /*private void SaveFunctionalUseCase(){       
        list<Wow_Attachments__c> list_FunUseExist=new list<Wow_Attachments__c>();
            list_FunUseExist=[SELECT Type__c, Functional_Use_Case__c,Description__c from Wow_Attachments__c WHERE Wow_Request_Form__c =: objWowReqFrm.id AND Type__c=:'Functional Use Case']; 
            if(list_FunUseExist!=null && list_FunUseExist.size()>0)
                delete list_FunUseExist;               
         if(list_WowAttachmentsFnUseCase.size()>0)
         {    
            insert list_WowAttachmentsFnUseCase;                     
         }          
   }*/
  private integer getMaxRowNo(List<Wow_Attachments__c> lis)
  {
      integer MaxRowNo=0;
      for(Wow_Attachments__c objwow: lis)
          if (MaxRowNo < integer.valueof(objwow.Row_number__c))
              MaxRowNo = integer.valueof(objwow.Row_number__c);
       return  MaxRowNo;      
  }
  public void DeleteVirtualUsers()
  {
    List<WoW_Virtual_Users__c> List_VTAllUsers=[SELECT Virtual_User__c,Virtual_User_type__c FROM WoW_Virtual_Users__c WHERE   Wow_Request_Form__c=:objWowReqFrm.id];
    //delete List_VTAllUsers;
    list_VTUserList=new List <WoW_Virtual_Users__c>();
  }
 public list<Wow_Attachments__c> getUpsertVisionLinkList(list<Wow_Attachments__c> list_VisionLinks){
    List<Wow_Attachments__c> list_LinkTodelete =new List<Wow_Attachments__c>();   
    
     if(list_VisionLinks!= null && list_VisionLinks.size()>0)
        for(Wow_Attachments__c objVisionLink: list_VisionLinks)
            if(objVisionLink.Id!=null && (objVisionLink.Link_URL__c==null || objVisionLink.Link_URL__c==''))                                         
                     list_LinkTodelete.add(objVisionLink); 
    Integer j = 0;
    while (j < list_VisionLinks.size())    {
      if(list_VisionLinks.get(j).Link_URL__c== '' || list_VisionLinks.get(j).Link_URL__c== null)
      {
        System.debug(LoggingLevel.INFO,'***j**'+j);   
        list_VisionLinks.remove(j);
      }
      else
      {
         j++;
      }
    } 
        if(list_LinkTodelete.size()>0)
            delete list_LinkTodelete;
        return list_VisionLinks;
        }
  //Temporarilty commented the solution design to delay deployment <start>      
    
    public list<Solution_Design__c> GetSolutionDesign(ID SCEngagementId)
  {
    list<Solution_Design__c > list_SolDesign = new List<Solution_Design__c>();
    list_SolDesign = [Select Id, Name, Product_Type__c,Primary_Design__c from Solution_Design__c where Sc_Engagement__c =: SCEngagementId];
    return list_SolDesign;
  }

  public Pagereference pageredirSolDesgn(){ 
     Pagereference newpage;
     string strRecordType = '';
     if (objWowReqFrm.Opportunity_Id__r.Lines_of_Businesses__c!='' && objWowReqFrm.Opportunity_Id__r.Lines_of_Businesses__c!=null)
         if(objWowReqFrm.Opportunity_Id__r.Lines_of_Businesses__c== 'PureCloud')
             strRecordType = 'PureCloud';
          else 
             strRecordType = 'PureConnect';    
      else 
           strRecordType = 'PureConnect';
     RecordType objRecordType= [SELECT Id, Name, DeveloperName FROM RecordType WHERE DeveloperName=: strRecordType AND sobjecttype ='Solution_Design__c' limit 1]; 
     string strRecordTypeId= objRecordType.Id;
     //newpage = new Pagereference ('/aIi/e?retURL=%2FaIi%2Fo&ent=Solution_Design&CF00Nn0000000wLJP='+objWowReqFrm.Name+'&CF00Nn0000000vodX='+objWowReqFrm.Opportunity_Id__r.Name+'&CF00Nn0000000vocY='+objWowReqFrm.Opportunity_Id__r.Account.name+'&retURL='+);
     //newpage = new Pagereference ('/aIi/e?ent=Solution_Design&CF00Nn0000000wLJP='+objWowReqFrm.Name+'&CF00Nn0000000vodX='+objWowReqFrm.Opportunity_Id__r.Name+'&CF00Nn0000000vocY='+objWowReqFrm.Opportunity_Id__r.Account.name+'&RecordType='+strRecordTypeId +'&retURL=/apex/wow_request_form?id='+objWowReqFrm.Opportunity_Id__c+'&saveURL=/apex/wow_request_form?id='+objWowReqFrm.Opportunity_Id__c);     
     newpage = new Pagereference ('/'+System.Label.SDO_Object_Id+'/e?ent=Solution_Design&'+System.Label.SC_Engagement_Name+'='+objWowReqFrm.Name+'&'+System.Label.Opportunity_Name+'='+EncodingUtil.URLEncode(objWowReqFrm.Opportunity_Id__r.Name,'UTF-8')+'&'+System.Label.Account_Name+'='+EncodingUtil.URLEncode(objWowReqFrm.Opportunity_Id__r.Account.name,'UTF-8')+'&RecordType='+strRecordTypeId +'&retURL=/apex/wow_request_form?id='+objWowReqFrm.Opportunity_Id__c+'&saveURL=/apex/wow_request_form?id='+objWowReqFrm.Opportunity_Id__c);     
     newpage.setRedirect(true); 
     return newpage;
}
  //Temporarilty commented the solution design to delay deployment <end>
   
}