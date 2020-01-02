public without sharing class clsPOCEngagementRequest{

  public string sOppId;
  public Opportunity objOpportunity{get;set;}
  public string sUserType;
  public boolean blnMain{get;set;}
  public boolean blnShowErrorMsg{get;set;}

  public boolean blnCreateHistory{get;set;}
  public string OppRoleHieUser{get;set;}
  public boolean blnSubmit{get;set;}
  public boolean blnErrorMsRequFld{get;set;}
  public string sIsreadonly{get;set;}
  public string BaseURL{get;set;}
  public List<string>list_mainProducts{get;set;}
  
  public POC_Engagement_Request__c objPOCReqFrm{get;set;}  
     
  public string SelectedStatusType{get;set;}

  /*POC History */
  public List<POC_Request_Form_History__c>list_POCHistory{get;set;}
  
  /*Object to prepare Opportunity data */
  public clsWrapperPOCDetails objWrapPOC{get;set;}
  
  /*Sections visibility*/
  public boolean AESection{get;set;}
  public boolean LeadSection{get;set;}  
  public boolean StatusSection{get;set;}
 
  public boolean ApprovalSection{get;set;}
  public boolean ResultSection{get;set;}
  
  public boolean btnSave{get;set;}
  public boolean btnSubmit{get;set;}
  public boolean blnShowAssementLink{get;set;}
  /*Sections ReadOnly*/
  public boolean AESection_RO{get;set;}
  public boolean LeadSection_RO{get;set;}
  public boolean VTSection{get;set;}  
  public boolean StatusSection_RO{get;set;}
  
  public boolean ApprovalSection_RO{get;set;}
  public boolean ResultSection_RO{get;set;}
  
  public boolean blnIsVTListExist{get;set;}
  /*when Lead submitted to AE*/
  public string sAssignTo{get;set;}
  public string sWowStatus{get;set;}
  public string CurrentVT{get;set;}
  public string CurrentVTType{get;set;} 
  public boolean VTSection_RO{get;set;}
  public boolean AttScope{get;set;}
  /*Wow Rejected History details*/
  public POCVirtualUser__c objPOCVT{get;set;}
  public List<POC_Request_Form_History__c> list_POCRejectHistryDtls{get;set;}
  public List<Wow_Request_Form_History__c> list_WowRejectHistryDtls{get;set;}
  
  public List<POCVirtualUser__c> list_VTUserList{get;set;}
  public list<POCVirtualUser__c> list_POCExistVT {get;set;}
  
  
  public List<POC_Solution_Product_Map__c> list_SolProdList{get;set;}
  
  public string sAttachmentId{get;set;}
  public boolean blnIsAttachment{get;set;}
  public List<Attachment>list_AttachScope{get;set;}
  
  //For POC request
  public map<string,list<string>> map_DependentPicVal{get;set;}
  public List<SelectOption>set_PickVal{get;set;}
  public string [] selctedPickValSolution{get;set;}
  public string [] selctedPickValProduct{get;set;}
  public  List<SelectOption>list_ProductsOptions{get;set;}
  public string fileName{get;set;}  
  public transient Blob fileBody{get;set;}
  public string FileDescType{get;set;}
  public boolean blnPOCAttachment{get;set;}
  public string CurrentId{get;set;}
  public string CurrentSolution{get;set;} 
  public string CurrentProduct{get;set;} 
  public List<Wow_Sub_Regional_Users__c> list_AssignedLeaders {get;set;}
  public List<POCFnUseCase__c>list_POCAttachmentsFnUseCase{get;set;}
  public List<Attachment>list_AttachCustomUseCase{get;set;}
  public boolean blnIsFnUseCaseAttach{get;set;}
  public string CurrentFunUseCase{get;set;}
  public string FunUseCaseId{get;set;}
  /* Constructor */  
  public clsPOCEngagementRequest()
  { 
    try
    {
        System.debug(LoggingLevel.Info, 'your logging message here');
        string sOId = ApexPages.CurrentPage().getParameters().get('id');
        if(sOId == '')
        {
          blnShowErrorMsg = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'POC request can not be submitted from Account.'));
          return;
        }
        list_VTUserList = new List<POCVirtualUser__c>(); 
        list_SolProdList = new List<POC_Solution_Product_Map__c>();
        list_mainProducts = new List<string>(); 
        objPOCVT=new POCVirtualUser__c();
        list_POCHistory = new List<POC_Request_Form_History__c>(); 
        list_POCAttachmentsFnUseCase =new list<POCFnUseCase__c>(); 
        objPOCReqFrm =new POC_Engagement_Request__c(); 
        map_DependentPicVal=POCUtility.GetDependentPickListValues('Opportunity','Primary_Solution__c','Products__c');
        set_PickVal = new List<SelectOption>();
        for(string aa : map_DependentPicVal.keySet())
          set_PickVal.add(new SelectOption(aa,aa));
        set_PickVal.sort();  
        CommonMethod(null);
        System.debug(LoggingLevel.Info, 'your logging message here common');
        /*Check POC Page accessibility for LoggedIn user*/
         LoggedUserPageAccessibility();
          System.debug(LoggingLevel.Info, 'your logging message here user access');
        /* Get LoggedIn user Type*/  
         sUserType = WoWUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.id,null);
    
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
  try{
        blnCreateHistory=true;
        blnShowErrorMsg = false;
        AESection = false;
        LeadSection = false;
        VTSection = false;
        StatusSection=false;
        ApprovalSection=false;
        ResultSection=false;
    
        AESection_RO = false;
        LeadSection_RO = false;
        VTSection_RO = false;
        StatusSection_RO =false;
        ApprovalSection_RO=false;
        ResultSection_RO=false;
        blnSubmit=true;   
        blnIsVTListExist = false;
        
        blnIsAttachment = false;
        blnPOCAttachment= false;
        AttScope=false;
        blnIsFnUseCaseAttach = false;
        
        /* Get Opportunity Details*/
        OppRoleHieUser=ApexPages.CurrentPage().getParameters().get('idu');
        sOppId = ApexPages.CurrentPage().getParameters().get('id');
        
    
        objPOCReqFrm=new POC_Engagement_Request__c();
        /* To get the Opportunity and Wow Request Data*/
        System.debug(LoggingLevel.Info, ' sOppId '+sOppId);
        GetOpportunityDetails(sOppId);
        //list_AssignedLeaders=WoWUtility.getSubRegionalUsersName(string.valueof(objOpportunity.End_User_Region__c),string.valueof(objOpportunity.Country_Sub_Region__c));
        
        // Method added by Rsystems 28-09-2017
        list_AssignedLeaders =  POCUtility.getSubRegionalNewUsersName(objOpportunity.Owner.Segment__c ,objOpportunity.Owner.Owner_Sub_Region__c, objOpportunity.Lines_of_Businesses__c);
        list_AttachScope = null;
        list_AttachCustomUseCase = null;
        GetAttachmentsPOC();
        GetPOCFunctionalUseCase();
        
         /*Get Base URL*/
         BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());
         
         
         /*Get Wow Rejected History Details*/
         //list_WowRejectHistryDtls=null;
         GetPOCRejectedHistory();
         System.debug(LoggingLevel.Info, 'your logging message here2');
    
         SetVisibility();
         System.debug(LoggingLevel.Info, 'your logging message here3');
         SetReadOnly();
     
         list_POCHistory=null;
         
         /*Get POC History*/
         GetPOCHistoryDetails();
         System.debug(LoggingLevel.Info, 'your logging message here history');    
         if(strMessage <> null)
         {
          System.debug(LoggingLevel.Info, 'your logging message here4');
             blnShowErrorMsg = true; 
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,strMessage ));
         }    
         
         System.debug(LoggingLevel.Info, 'your logging message here history @@@@@@@@@@@');    
         /*Check status for Virtual Team*/    
         if(objPOCReqFrm.POC_Status__c == 'Rejected')
           SelectedStatusType = 'Reject';
         else  
           SelectedStatusType = 'Approve';    
           
           System.debug(LoggingLevel.Info, 'your logging message here history $$$$$$$$$$$');   
     }
    catch(Exception ex)   
      { 
       System.debug(LoggingLevel.Info, 'your logging message here error');
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      } 
  }
  
  public void GetOpportunityDetails(string SOppId)
  {
    try 
    {  
    system.debug('SOppId'+SOppId);
    System.debug(LoggingLevel.Info, 'objOpportunity1 **'+objOpportunity );
    objOpportunity = [Select Account.Key_Account_Group__c,Lines_of_Businesses__c,Key_Business_Objective__c,id,name,Primary_Solution__c,Owner.Owner_Sub_Region__c, Products__c,Owner.Name,Owner.Segment__c,Owner.Id, industry__c,AE_Name__r.name,AE_Name__c,StageName,Amount,Primary_Line_of_Business__c,Account.name,Primary_Solution_Category__c,End_User_Region__c,BusinessPartner__r.Name,CloseDate,Term_License__c,Term_License_Amount_TCV__c ,License_Amount__c,Hardware_Total__c,Professional_Service_Amount_RDP__c,Genesys_Care_Amount__c,License_Equivalency__c,Annual_Contract_Value_new__c,Annual_Contract_Value__c,Total_PS_Support__c,Monthly_Commitment__c,Estimated_Usage_Agreements_EUA__c,Potential_Pipeline__c,Total_Annual_Contract_Value__c,CurrencyIsoCode,Country_Sub_Region__c  from Opportunity where id=: SOppId];
    //objOpportunity = [Select id,Name,Amount,Owner.Id,Owner.Name,BusinessPartner__r.Name,End_User_Region__c,Key_Business_Objective__c  from Opportunity where id=: SOppId];
   
    System.debug(LoggingLevel.Info, 'objOpportunity2 **'+objOpportunity );
    
    //Added and commented by Swastika
    List<POC_Engagement_Request__c> objPOC= [Select id,TargetedEndDate__c,POCOwner__c,POCFunding__c,Custom_Use_Case__c ,Is_Functional_Use_Case__c ,Primary_Solution_Category__c,Primary_Solution__c,Main_Product__c,POC_Status__c,AE__c,AE_Name__c,Customer_Name__c,Primary_Business_Objectives__c,Opp_Annual_Contract_Value__c,Opp_Annual_Contract_Value_new__c,Business_Partner__c,Comment__c, Opp_Monthly_Commitment__c,Opp_Estimated_Usage_Agreements_EUA__c,  Expected_Closed_Date__c,    Opp_Genesys_Care_Amount__c, Opp_Hardware_Total__c,  Industry__c,    Opp_License_Amount__c,  Opp_License_Equivalency__c,     Opportunity_Id__c,  Opportunity_Name__c,    Platform_Type__c,   POC_Approved__c,   POC_Rejection_Reason__c,     POC_Types__c,   Opp_Potential_Pipeline__c,  Solution_Type__c,    Opp_Professional_Service_Amount_RDP__c, Opp_Total_PS_Support__c,    PS_Billable__c, PS_Involvement_Required__c, Review_POC_Guide__c,  Stage__c,   Success_Criteria_Achived__c,    Opp_Term_License__c,    Opp_Term_License_Amount_TCV__c, Total_Amount__c, Opp_Total_Annual_Contract_Value__c,Expected_Discovery_Start__c  
        ,AssignTo__c,High_Level_Request_details__c from POC_Engagement_Request__c where Opportunity_Id__c =: SOppId AND POC_Status__c!='Rejected' LIMIT 1];
    
    if(objPOC!= null && objPOC.size()>0)
    {
        objPOCReqFrm=objPOC[0];
        //Populate Wow Status and AssignTO  when Lead submit to AE
        sAssignTo = objPOCReqFrm.AssignTo__c;
        sWowStatus = objPOCReqFrm.POC_Status__c;
        list_POCExistVT=[SELECT Solution_Consultant__c,Virtual_User_type__c FROM POCVirtualUser__c WHERE POC_Engagement_Request__c=:objPOCReqFrm.id ];
        
        //Populate selected solution
        /*if(objPOC[0].Primary_Solution__c!=null && objPOC[0].Primary_Solution__c!='')
            {
               string strPrimarySol=objPOC[0].Primary_Solution__c; 
               String[]  strSolutions =  strPrimarySol.split(',');
               selctedPickValSolution= strSolutions;
               
               //find the all product for that selected solution
               GetProducts();
               if(objPOC[0].Main_Product__c!=null && objPOC[0].Main_Product__c!='')
                   {
                   string strMainproduct=objPOC[0].Main_Product__c;
                   String[]  strProducts =  strMainproduct.split(',');
                   selctedPickValProduct=strProducts;
                   }
            }*/
    }
    else
    {
        //data populated from Opportunity
       if(objOpportunity.Amount<> null)
           objPOCReqFrm.Total_Amount__c =objOpportunity.Amount;
           
           
       if(objOpportunity.Key_Business_Objective__c <> null)
         objPOCReqFrm.Primary_Business_Objectives__c=objOpportunity.Key_Business_Objective__c;
       
       if(objOpportunity.BusinessPartner__r <> null) 
         objPOCReqFrm.Business_Partner__c = objOpportunity.BusinessPartner__r.Name;
         
       if(objOpportunity.Annual_Contract_Value__c <> null) 
         objPOCReqFrm.Opp_Annual_Contract_Value__c = objOpportunity.Annual_Contract_Value__c; 
       
       if(objOpportunity.Annual_Contract_Value_new__c<> null) 
         objPOCReqFrm.Opp_Annual_Contract_Value_new__c = objOpportunity.Annual_Contract_Value_new__c; 
       
       if(objOpportunity.Monthly_Commitment__c<> null) 
         objPOCReqFrm.Opp_Monthly_Commitment__c= objOpportunity.Monthly_Commitment__c; 
       
       if(objOpportunity.Estimated_Usage_Agreements_EUA__c<> null) 
         objPOCReqFrm.Opp_Estimated_Usage_Agreements_EUA__c = objOpportunity.Estimated_Usage_Agreements_EUA__c; 
       
       if(objOpportunity.Genesys_Care_Amount__c<> null) 
         objPOCReqFrm.Opp_Genesys_Care_Amount__c= objOpportunity.Genesys_Care_Amount__c; 
       
       if(objOpportunity.Hardware_Total__c<> null) 
         objPOCReqFrm.Opp_Hardware_Total__c = objOpportunity.Hardware_Total__c; 
       
       if(objOpportunity.License_Amount__c <> null) 
         objPOCReqFrm.Opp_License_Amount__c= objOpportunity.License_Amount__c; 
       
       if(objOpportunity.License_Equivalency__c <> null) 
         objPOCReqFrm.Opp_License_Equivalency__c = objOpportunity.License_Equivalency__c; 
       
       if(objOpportunity.Potential_Pipeline__c<> null) 
         objPOCReqFrm.Opp_Potential_Pipeline__c = objOpportunity.Potential_Pipeline__c; 
       
       if(objOpportunity.Professional_Service_Amount_RDP__c <> null) 
         objPOCReqFrm.Opp_Professional_Service_Amount_RDP__c= objOpportunity.Professional_Service_Amount_RDP__c; 
       
       if(objOpportunity.Total_PS_Support__c <> null) 
         objPOCReqFrm.Opp_Total_PS_Support__c = objOpportunity.Total_PS_Support__c; 
       
       if(objOpportunity.Term_License__c <> null) 
         objPOCReqFrm.Opp_Term_License__c= objOpportunity.Term_License__c; 
       
       if(objOpportunity.Term_License_Amount_TCV__c <> null) 
         objPOCReqFrm.Opp_Term_License_Amount_TCV__c = objOpportunity.Term_License_Amount_TCV__c; 
       
       if(objOpportunity.Total_Annual_Contract_Value__c <> null) 
         objPOCReqFrm.Opp_Total_Annual_Contract_Value__c= objOpportunity.Total_Annual_Contract_Value__c; 
         
       if(objOpportunity.Industry__c <> null) 
         objPOCReqFrm.Industry__c = objOpportunity.Industry__c ; 
 
    }   

   if(objPOCReqFrm.id != null)
    {     
      system.debug('enter');
      objWrapPOC = new clsWrapperPOCDetails(objPOCReqFrm);   
      List<POCVirtualUser__c> List_VTAllUsers=[SELECT Solution_Consultant__c,Virtual_User_type__c FROM POCVirtualUser__c WHERE   POC_Engagement_Request__c=:objPOCReqFrm.id];
      list_VTUserList=new List <POCVirtualUser__c>();
      if(List_VTAllUsers.size()>0 && list_VTUserList.size()<=0)
      {
          For(POCVirtualUser__c objVT: List_VTAllUsers){
              POCVirtualUser__c objTemp=new POCVirtualUser__c();
              objTemp.Solution_Consultant__c=objVT.Solution_Consultant__c; 
              objTemp.Virtual_User_type__c=  objVT.Virtual_User_type__c;         
              objTemp.POC_Engagement_Request__c= objPOCReqFrm.id;
              objTemp.Id=null;
              list_VTUserList.add(objTemp);
        }
         if(list_VTUserList.size()>0)  
           blnIsVTListExist = true;  
        }
           if(objPOCReqFrm.AssignTo__c == '' || objPOCReqFrm.AssignTo__c == 'Lead Assign'|| objPOCReqFrm.AssignTo__c == 'Virtual Team' || objPOCReqFrm.AssignTo__c == 'Lead Completed') 
           {
           system.debug(LoggingLevel.Info,'AssignTo__c *** '+objPOCReqFrm.AssignTo__c );
               List<POC_Solution_Product_Map__c> List_SolProdAllUsers=[SELECT Id,POC_Request_Id__c,Primary_Solution__c,Products__c FROM POC_Solution_Product_Map__c WHERE   POC_Request_Id__c=:objPOCReqFrm.id];
               list_SolProdList=new List <POC_Solution_Product_Map__c>();
               list_mainProducts = new List<string>();
                  if(List_SolProdAllUsers.size()>0 && list_SolProdList.size()<=0)
                  {
                      For(POC_Solution_Product_Map__c objSolProd: List_SolProdAllUsers){
                          POC_Solution_Product_Map__c objTemp=new POC_Solution_Product_Map__c();
                          objTemp.Primary_Solution__c=objSolProd.Primary_Solution__c; 
                          objTemp.POC_Request_Id__c=  objSolProd.POC_Request_Id__c;         
                          objTemp.Products__c = objSolProd.Products__c;
                          objTemp.Id= objSolProd.Id;                         
                          list_SolProdList.add(objTemp);
                          list_mainProducts.add(objSolProd.Primary_Solution__c + ';' + objSolProd.Products__c);
                    }
                }
            }   
       } 
    else
      {
      system.debug('Test');
      objWrapPOC =null;
      objWrapPOC = new clsWrapperPOCDetails(objOpportunity);
      } 
      }
      catch(Exception ex)   
      { 
       System.debug(LoggingLevel.Info, 'your logging message here error');       
        blnShowErrorMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }
  }
  
  /* Checks the Logged In user accessibility.If Logged IN user is either 
  AE,SC, Sub regional Lead then user can access POC Request Form*/
  public void LoggedUserPageAccessibility()
  {
      try{
            boolean blnExist = false;
            if(objPOCReqFrm.AE__c == UserInfo.getUserId())
            {
              blnExist = true;
            }
            if(POCUtility.IsVirtualTeamExist(objPOCReqFrm.Id,UserInfo.getUserId()))
            {
              blnExist = true;
            }
             if(WOWUtility.getSubRegionalUsers(string.valueof(objOpportunity.End_User_Region__c),string.valueof(objOpportunity.Country_Sub_Region__c),UserINfo.getUserName()))
            {
              blnExist = true;
            }
    
    }
      catch(Exception ex)   
      { 
       System.debug(LoggingLevel.Info, 'your logging message here error');       
        blnShowErrorMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }
  }

  public void SetVisibility()
  {
        try{
        boolean blnAE=false;
        boolean blnLead=false;
        boolean blnVirtualTeam=false;
        boolean blnResult=false;
        blnMain=false;
        
        btnSave=true;
        btnSubmit=true;

       /*Get LoggedIn user profile name*/
       string sProfileName = WoWUtility.GetProfileName(userinfo.getProfileId());
       
       //if record exist in WoW request form
       if(objPOCReqFrm!=null)  
       {
        
         /* Custom setting  WowAdminAccess__c*/
         List<WowAdminAccess__c> lstCstSetting = WowAdminAccess__c.getall().values();
           
         /* check loggedin as Global user or not */
         boolean blnIsGlobal = false;
         blnIsGlobal = GlobalUser(UserINfo.getUserId());
         if(blnIsGlobal)
           sProfileName = 'System Administrator';
         
         system.debug('***objOpportunity.End_User_Region__c**'+objOpportunity.End_User_Region__c);
         system.debug('***objOpportunity.Country_Sub_Region__c**'+objOpportunity.Country_Sub_Region__c);
         system.debug('***UserINfo.getUserName()**'+UserINfo.getUserName());
         
         if(sProfileName =='System Administrator' && lstCstSetting[0].IsAccessible__c == true)
         {
            blnLead  = true;
            blnVirtualTeam=true;
            blnAE=true;
         }        
         else if (wowUtility.getSubRegionalUsers(string.valueof(objOpportunity.End_User_Region__c),string.valueof(objOpportunity.Country_Sub_Region__c),UserINfo.getUserName()))
             blnLead  = true;
         else if (POCUtility.IsVirtualTeamExist(objPOCReqFrm.Id,UserINfo.getUserId()))
             blnVirtualTeam = true;    
         else if(objOpportunity.Owner.Id==UserINfo.getUserId() || OppRoleHieUser==UserINfo.getUserId() || (sProfileName =='System Administrator' && lstCstSetting[0].IsAccessible__c == true))
         {
            blnAE=true;
            system.debug('#enter25 ');
         } 
         if(blnAE || blnLead || blnVirtualTeam || (sProfileName =='System Administrator' && lstCstSetting[0].IsAccessible__c == true))
         {
           blnMain=true;
         }
          
            system.debug('#flag '+blnAE +'-----'+blnLead +'-----'+blnVirtualTeam );
               /*For AE Section*/
               /*First Time AssignTo wiil be blank and AE can see the record
                 When AE submit the record Assign To become Lead Assign
                 When Lead submit the record Assign To become Virtual Team
                 When Virtual Team submit Assign To become Lead Completed
                 when Wow request completd it will go to AE and Assign To become AE
               */
               if((objPOCReqFrm.AssignTo__c == '' || objPOCReqFrm.AssignTo__c == null) && blnAE)
               {
                 AESection = true;
                 LeadSection = false;
                 VTSection = false;
                 StatusSection=false;
                 btnSave=true;
                 btnSubmit=false;
                 ApprovalSection=false;
                 ResultSection=false;
                    
                 AESection_RO = false;
                 LeadSection_RO = false;
                 VTSection_RO = false;
                 StatusSection_RO =false;
                 ApprovalSection_RO=false;
                 ResultSection_RO=false;
               }
               else if(objPOCReqFrm.AssignTo__c == 'Lead Assign' && blnLead)
               {
                 AESection = false;
                 LeadSection = true;
                 VTSection = false;
                 StatusSection=false;
                 btnSave=false;
                 btnSubmit=false;
                 ApprovalSection=false;
                 ResultSection=false;

                 AESection_RO = true;
                 LeadSection_RO = false;
                 VTSection_RO = false;
                 StatusSection_RO =true;
                 ApprovalSection_RO=false;
                 ResultSection_RO=false;
               }
               
               else if(objPOCReqFrm.AssignTo__c == 'Virtual Team' && blnVirtualTeam)
               //else if(objPOCReqFrm.AssignTo__c == 'Virtual Team')
               {                 
                 btnSubmit =false;
                 //btnSubmit =true;

                 AESection = false;
                 LeadSection = false; 
                 //LeadSection = true;                
                 VTSection = true;
                 StatusSection=false;
                 btnSave=false;
                 ApprovalSection=false;
                 ResultSection=true;

                 AESection_RO = true;
                 LeadSection_RO = true;   
                 //LeadSection_RO = false;               
                 VTSection_RO = false;
                 StatusSection_RO =true;
                 ApprovalSection_RO=false;
                 ResultSection_RO=false;
                 AttScope=true;                 
               }
               else if((objPOCReqFrm.AssignTo__c == 'Lead Completed' || objPOCReqFrm.AssignTo__c == 'Completed') && blnLead)
               {
                 AESection = false;
                 LeadSection = false;
                 VTSection = false;
                 StatusSection=true;
                 btnSave=true;
                 btnSubmit=false;
                 ApprovalSection=true;
                 ResultSection=false;

                 AESection_RO = true;
                 LeadSection_RO = true;
                 VTSection_RO = true;
                 StatusSection_RO =false;
                 ApprovalSection_RO=false;
                 ResultSection_RO=true;
               }
               /*else if(objPOCReqFrm.AssignTo__c == 'Virtual Team for Result' && blnVirtualTeam )
               {
                 AESection = false;
                 LeadSection = false;
                 VTSection = false;
                 StatusSection=false;
                 btnSave=true;
                 btnSubmit=false;
                 ApprovalSection=false;
                 ResultSection=true;
                    
                 AESection_RO = true;
                 LeadSection_RO = true;
                 VTSection_RO = true;
                 StatusSection_RO =true;
                 ApprovalSection_RO=true;
                 ResultSection_RO=false;
               }*/
               else if(objPOCReqFrm.AssignTo__c =='AE')
               {
                AESection = false;
                 LeadSection = false;
                 VTSection = false;
                 StatusSection=false;
                 btnSave=true;
                 btnSubmit=true;
                 ApprovalSection=false;
                 ResultSection=false;
                    
                 AESection_RO = true;
                 LeadSection_RO = true;
                 VTSection_RO = true;
                 StatusSection_RO =true;
                 ApprovalSection_RO=true;
                 ResultSection_RO=true;
               }
         }
      }
      catch(Exception ex)   
      { 
       System.debug(LoggingLevel.Info, 'your logging message here error');       
        blnShowErrorMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }   
  }

  public void SetReadOnly()
  {
       try{
               sIsreadonly = ApexPages.CurrentPage().getParameters().get('view');
               
               //if record exist in POC request form
               if(objPOCReqFrm!=null && sIsreadonly == null)  
               {
                  
                   if(objPOCReqFrm.AssignTo__c == 'Lead Assign')
                   {
                     AESection_RO = true;
                     LeadSection_RO = false;
                     StatusSection_RO =true;
                   }
        
                   else if(objPOCReqFrm.AssignTo__c == 'Virtual Team')
                   {
                     AESection_RO = true;
                     LeadSection_RO = true;
                     //LeadSection_RO = false;
                    
                     StatusSection_RO =true;
                   }
                   else if((objPOCReqFrm.AssignTo__c == 'Lead Completed' || objPOCReqFrm.AssignTo__c == 'Completed'))
                   {
                     AESection_RO = true;
                     LeadSection_RO = true;
                     StatusSection_RO =false;
                     VTSection_RO = true;
                   }
                   /*else if(objPOCReqFrm.AssignTo__c == 'Virtual Team for Result')
                   {
                     AESection_RO = true;
                     LeadSection_RO = true;
                     StatusSection_RO = true;
                     VTSection_RO = true;
                     ApprovalSection_RO=true;
                   }*/
                 }
                 else if(objPOCReqFrm!=null && sIsreadonly == 'yes')
                 {
                      AESection = false;
                      LeadSection = false;
                     
                      StatusSection = false;
                      btnSave = false;
                      btnSubmit = false;
        
                      AESection_RO = true;
                      LeadSection_RO = true;
                     
                      StatusSection_RO = true;
                      VTSection_RO=true;
                      ApprovalSection_RO=true;
                      ResultSection_RO=true;
                      
                      btnSave = true;
                      btnSubmit = true;
                 } 
          }                
         catch(Exception ex)   
          { 
           System.debug(LoggingLevel.Info, 'your logging message here error');       
            blnShowErrorMsg = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
          }        
  }  
   
  /*To get all Wow rejected history against the opportunity*/
  public void GetPOCRejectedHistory()
  {
      try{
            List<POC_Engagement_Request__c>list_POCRej = new List<POC_Engagement_Request__c>();
            list_POCRej = [Select id,POC_Status__c,Opportunity_Id__c,POC_Rejection_Reason__c from POC_Engagement_Request__c where Opportunity_Id__c =: objOpportunity.id and POC_Status__c =: 'Rejected'];
                
            system.debug('++++objOpportunity.id++'+objOpportunity.id);
            List<POC_Request_Form_History__c> objRejectedH = [Select id,Action__c,UserId__r.name,POC_User_Type__c,POC_Stage__c,POC_Engagement_Status__c,Action_Date__c,POC_Request_Id__r.POC_Status__c,POC_Request_Id__r.POC_Rejection_Reason__c from POC_Request_Form_History__c where POC_Request_Id__c IN :list_POCRej order by LastModifiedDate desc];
            if(objRejectedH != null && objRejectedH.size()>0)
            {
               list_POCRejectHistryDtls = new List<POC_Request_Form_History__c>();
               for(POC_Request_Form_History__c  obj:objRejectedH )
               {
                 if(!obj.action__c.contains('Email Notification :'))
                   list_POCRejectHistryDtls .add(obj);
               }
            } 
        }                
     catch(Exception ex)   
      { 
       System.debug(LoggingLevel.Info, 'your logging message here error');       
        blnShowErrorMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }    
        
  }  

  public void SaveWowDetails()
  {   
     string strHistoryAction='';
     string strPOCStage='';     
     try
     {          
          if(objPOCReqFrm.AssignTo__c == '' || objPOCReqFrm.AssignTo__c == null )
          {
              objPOCReqFrm.AssignTo__c='';
              strPOCStage='';
              //strHistoryAction='Assigned to Lead by AE';
              objPOCReqFrm.AE__c=UserInfo.getUserID();
              //objPOCReqFrm.POC_status__c='Open and Not Assigned';              
          }
          else if(objPOCReqFrm.AssignTo__c == 'Lead Assign')
          {
               //objPOCReqFrm.AssignTo__c='Virtual Team';
               strPOCStage='Lead Assign';
               strHistoryAction='POC Engagement Saved by Subregional Leader';
               if(SelectedStatusType == 'Reject')
                   {
                   blnShowErrorMsg = true;
                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select Submit to reject the POC Engagement.'));
                   return;
                   } 
           }
           else if(objPOCReqFrm.AssignTo__c == 'Virtual Team')
           {
              system.debug('#save_virtual team');
              strHistoryAction='POC Engagement Saved by Virtual Team';
              strPOCStage='Virtual Team';
              System.debug(LoggingLevel.Info, '**selctedPickValSolution***'+selctedPickValSolution);
              System.debug(LoggingLevel.Info, '**selctedPickValProduct***'+selctedPickValProduct);
              /*if(selctedPickValSolution.size()>0)
                  objPOCReqFrm.Primary_Solution__c=getArrayData(selctedPickValSolution);
              if(selctedPickValProduct!=null && selctedPickValProduct.size()>0)    
                  objPOCReqFrm.Main_Product__c=getArrayData(selctedPickValProduct);*/
           }
           else if(objPOCReqFrm.AssignTo__c == 'Lead Completed' || objPOCReqFrm.AssignTo__c == 'Completed')
           {
             system.debug('#save_ae');
             objPOCReqFrm.AssignTo__c='Virtual Team for Result';
             strPOCStage='Virtual Team';
             strHistoryAction='POC Engagement fully completed and AE notified';
             
           } 
           /*else if(objPOCReqFrm.AssignTo__c == 'Virtual Team for Result' || objPOCReqFrm.AssignTo__c == 'Completed')
           {
             system.debug('#save_ae');             
             strPOCStage='Virtual Team';
             strHistoryAction='POC Engagement fully completed and AE notified';
           } */
           else if(objPOCReqFrm.AssignTo__c == 'Completed')
           {
             system.debug('#save_ae');             
             strPOCStage='Virtual Team';
             strHistoryAction='POC Engagement fully completed and AE notified';
           } 
           if(objPOCReqFrm.id != null){  
             system.debug('+++list_POCAttachmentsFnUseCase Line No. 736'+list_POCAttachmentsFnUseCase);         
              //update objPOCReqFrm; 
              if(objPOCReqFrm.AssignTo__c == 'Lead Assign' || objPOCReqFrm.AssignTo__c == 'Virtual Team')
                    {
                      //For Virtual team
                      if(objPOCReqFrm.AssignTo__c == 'Virtual Team' )
                          {
                            List<POCVirtualUser__c> list_DiffVT=new List<POCVirtualUser__c>();
                            list_POCExistVT=[SELECT Solution_Consultant__c,Virtual_User_type__c FROM POCVirtualUser__c WHERE POC_Engagement_Request__c=:objPOCReqFrm.id ];
                            list_DiffVT=POCUtility.getDiffVTList(list_VTUserList,list_POCExistVT); 
                            if(list_DiffVT!=null && list_DiffVT.size()>0)
                            {
                                 //Send email notification to Virtual team
                                string strResult=POCUtility.SendEmailNotification('Virtual Team Assigned',objPOCReqFrm.id,list_VTUserList);
                                if(strResult=='Successful')
                                    POCUtility.CreateHistory('Email Notification : to SC that they are assigned as Virtual Team Members on a POC Engagement',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
                                else
                                    POCUtility.CreateHistory('Email Notification Failed : to SC that they are assigned as Virtual Team Members on a POC Engagement',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
                                
                            }   
                          }
                          SaveVirtualTeam();  
                          if(objPOCReqFrm.AssignTo__c == '')
                             SaveSolutionProduct();
                     } 
                     system.debug('+++list_POCAttachmentsFnUseCase Line No. 760'+list_POCAttachmentsFnUseCase);
                     UpdateFnUseCaseNumbers();
                     update objPOCReqFrm; 
              }
           else    
           {
             system.debug('Save3');
             //Assign wrapper class data to wow object add by swastika    
             objPOCReqFrm.AE_Name__c=objWrapPOC.AEName;
             objPOCReqFrm.Opportunity_Name__c=objWrapPOC.OpportunityName;
             objPOCReqFrm.Stage__c=objWrapPOC.Stage;
             objPOCReqFrm.Total_Amount__c=objWrapPOC.TotalAmount;
             objPOCReqFrm.Platform_Type__c=objWrapPOC.PlatformType;
             objPOCReqFrm.Customer_Name__c=objWrapPOC.CustomerName;
             objPOCReqFrm.Business_Partner__c=objWrapPOC.BusinessPartner;             
             objPOCReqFrm.Primary_Solution_Category__c=objWrapPOC.PrimarySolution;             
             objPOCReqFrm.Expected_Closed_Date__c=Date.valueOf(objWrapPOC.ExpectedClosedDate);
             //Added by swastika
             objPOCReqFrm.Opportunity_Id__c=objOpportunity.Id;
             //objPOCReqFrm.Primary_Business_Objectives__c = objOpportunity.Key_Business_Objective__c;
             objPOCReqFrm.CurrencyISOCode=objOpportunity.CurrencyISOCode;
             if(objPOCReqFrm.Primary_Business_Objectives__c <> objOpportunity.Key_Business_Objective__c)
                {
                    objOpportunity.Key_Business_Objective__c=objPOCReqFrm.Primary_Business_Objectives__c;
                    try{
                        update objopportunity;
                        }
                    catch(Exception ex)   
                      {
                       system.debug(LoggingLevel.Info,'ApexPages.Severity.Error,ex.getMessage()** '+ex.getMessage());           
                       blnShowErrorMsg = true;
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
                      }
                }  
                
              UpdateFnUseCaseNumbers(); 
             insert objPOCReqFrm;
             
            
                         
             if(objPOCReqFrm.AssignTo__c == '')
               SaveSolutionProduct();
            }
            
            system.debug('+++list_POCAttachmentsFnUseCase Line No. 806@@@@@@@@@');
            if(list_POCAttachmentsFnUseCase != null && list_POCAttachmentsFnUseCase.size()>0)
            {
               for(integer i=0;i<list_POCAttachmentsFnUseCase.size();i++)
               {
                 if(list_POCAttachmentsFnUseCase[i].FnUseCase__c == null || list_POCAttachmentsFnUseCase[i].FnUseCase__c == '')
                   list_POCAttachmentsFnUseCase.remove(i);
               }
                upsert list_POCAttachmentsFnUseCase;
            } 
            system.debug('+++list_POCAttachmentsFnUseCase Line No. 816@@@@@@@@@@@'+list_POCAttachmentsFnUseCase);
            if(blnCreateHistory)
                POCUtility.CreateHistory(strHistoryAction,UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,'Save'),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
            
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
        string strPOCStage=''; 
        boolean isLeadComplete = false;       
       try
       {
            if(objPOCReqFrm.AssignTo__c == '' || objPOCReqFrm.AssignTo__c == null )
            {
                System.debug(LoggingLevel.Info, 'your logging message here');
                objPOCReqFrm.AssignTo__c='Lead Assign';
                strPOCStage='AE';
    
                objPOCReqFrm.AE__c=objOpportunity.Owner.Id;
                objPOCReqFrm.POC_Status__c='Open and Not Assigned';                
                strHistoryAction='POC Request Assigned to Queue : '+WowUtility.GetQueueName(objOpportunity.End_User_Region__c);                
                blnSubmit=true;
                
                //When AE submit the record .It redirects to opportunity record
                objRef = new PageReference('/'+objOpportunity.id);
                objRef.setRedirect(true);
            }
            else if(objPOCReqFrm.AssignTo__c == 'Lead Assign')
            {
                system.debug('#lead assign');
                
                 if(SelectedStatusType == 'Reject')
                {
                    objPOCReqFrm.AssignTo__c='AE';
                    strPOCStage='Rejected'; 
                    objPOCReqFrm.POC_Approved__c=false;               
                    strHistoryAction='POC Rejected by Leadership';
                    objPOCReqFrm.POC_status__c='Rejected'; 
                    list_SolProdList = new List<POC_Solution_Product_Map__c>();                    
                    //blnSubmit=true;  
                }
                else
                {
                    objPOCReqFrm.POC_status__c='Open and Assigned';
                    objPOCReqFrm.AssignTo__c='Virtual Team';
                    strPOCStage='Lead Assign';
                    strHistoryAction='Virtual Team Assigned by Lead';                
                    objPOCReqFrm.POC_Approved__c=true;
                    //blnSubmit=true;
                    //objRef = new PageReference('/apex/POCEngagementRequest?id='+objOpportunity.id);
                    //objRef.setRedirect(true);     
                }  
               blnSubmit=true;
               objRef = new PageReference('/apex/POCEngagementRequest?id='+objOpportunity.id);
               objRef.setRedirect(true);                  
            }
            else if(objPOCReqFrm.AssignTo__c == 'Virtual Team')
            {
                //Save data to update values in object to get updated value to required fields
                 /*if(selctedPickValSolution.size()>0)
                      objPOCReqFrm.Primary_Solution__c=getArrayData(selctedPickValSolution);
                 if(selctedPickValProduct!=null && selctedPickValProduct.size()>0)    
                      objPOCReqFrm.Main_Product__c=getArrayData(selctedPickValProduct);
                update objPOCReqFrm;*/
                system.debug('#virtual team');
               
                strPOCStage='Virtual Team';              
                strHistoryAction='POC Engagement activities have been performed by Virtual Team';
    
                // Check All mandatory fields values 
                               
                blnSubmit=true;
                objPOCReqFrm.AssignTo__c='Lead Completed';
                objPOCReqFrm.POC_status__c='POC Status Submitted for Completion';   
                
                
                if(list_POCAttachmentsFnUseCase != null && list_POCAttachmentsFnUseCase.size()>0)
                {
                   for(integer i=0;i<list_POCAttachmentsFnUseCase.size();i++)
                   {
                     if(list_POCAttachmentsFnUseCase[i].FnUseCase__c == null || list_POCAttachmentsFnUseCase[i].FnUseCase__c == '')
                       list_POCAttachmentsFnUseCase.remove(i);
                   }
                   upsert list_POCAttachmentsFnUseCase;
                }
                 
             
                objRef = new PageReference('/apex/POCEngagementRequest?id='+objOpportunity.id);
                objRef.setRedirect(true);             
            }
            else if(objPOCReqFrm.AssignTo__c == 'Lead Completed' )
            { 
                isLeadComplete = true;
                system.debug('#ae');
                objPOCReqFrm.AssignTo__c='AE';
                strPOCStage='Lead Completed';                
                strHistoryAction='POC Engagement fully completed and AE notified';
                //objPOCReqFrm.POC_status__c='Completed';    
                blnSubmit=true;   
                objRef = null; 
                /*objPOCReqFrm.AssignTo__c='Completed';
                strPOCStage='Lead Completed';                           
                strHistoryAction='POC Engagement is approved and Virtual team notified';
                objPOCReqFrm.POC_status__c='POC Status Submitted for Completion';    
                blnSubmit=true;            
                if(SelectedStatusType == 'Approve') //if approve
                    {
                    objPOCReqFrm.AssignTo__c='Virtual Team for Result';
                    strPOCStage='Lead Completed'; 
                    objPOCReqFrm.POC_Approved__c=true;               
                    strHistoryAction='POC Engagement is approved and Virtual team notified';
                    objPOCReqFrm.POC_status__c='POC Status Submitted for Completion';    
                    blnSubmit=true;  
                   } 
                 else
                 {
                    objPOCReqFrm.AssignTo__c='AE';
                    strPOCStage='Rejected'; 
                    objPOCReqFrm.POC_Approved__c=false;               
                    strHistoryAction='POC Rejected by Leadership';
                    objPOCReqFrm.POC_status__c='Rejected';    
                    blnSubmit=true;  
                 } */             
            }
           //else if(objPOCReqFrm.AssignTo__c == 'Virtual Team for Result' || objPOCReqFrm.AssignTo__c == 'Completed')
          /* else if(objPOCReqFrm.AssignTo__c == 'Completed')
            {
                system.debug('#ae');
                objPOCReqFrm.AssignTo__c='AE';
                strPOCStage='Lead Completed';                
                strHistoryAction='POC Engagement fully completed and AE notified';
                objPOCReqFrm.POC_status__c='Completed';    
                blnSubmit=true;               
            }*/ 
            
    
            if(objPOCReqFrm.id != null)
            {  
                System.debug(LoggingLevel.Info, 'your logging message here1');
                if(blnSubmit)
                {
                    system.debug('#wrongentry');
                     if(objPOCReqFrm.AssignTo__c == 'Lead Assign' || objPOCReqFrm.AssignTo__c == 'Virtual Team')
                    {
                      
                      //For Virtual team
                      SaveVirtualTeam();
                      if(objPOCReqFrm.AssignTo__c == 'Lead Assign')
                          SaveSolutionProduct();
                     }
                    System.debug(LoggingLevel.Info, 'your logging message here2');
                    update objPOCReqFrm; 
                }
              
                system.debug('++++update POC2+++');
            }      
            else    
            {
               System.debug(LoggingLevel.Info, 'your logging message here3'); 
                system.debug(LoggingLevel.Info,'objOpportunity.Id'+objOpportunity.Id);
                system.debug(LoggingLevel.Info,'objPOCReqFrm1** '+objPOCReqFrm); 
                try{                   
                objPOCReqFrm.AE_Name__c=objWrapPOC.AEName;
                objPOCReqFrm.Opportunity_Name__c=objWrapPOC.OpportunityName;
                objPOCReqFrm.Stage__c=objWrapPOC.Stage;
                objPOCReqFrm.Total_Amount__c=objWrapPOC.TotalAmount;
                objPOCReqFrm.Platform_Type__c=objWrapPOC.PlatformType;    
                objPOCReqFrm.Customer_Name__c=objWrapPOC.CustomerName;
                objPOCReqFrm.Primary_Solution_Category__c=objWrapPOC.PrimarySolution;  
                objPOCReqFrm.Expected_Closed_Date__c=Date.valueOf(objWrapPOC.ExpectedClosedDate);  
                objPOCReqFrm.Opportunity_Id__c=objOpportunity.Id;
                objPOCReqFrm.CurrencyISOCode=objWrapPOC.CurrencyCode; 
                objPOCReqFrm.Lead__c=POCUtility.getSubRegionalUsers(string.valueof(objOpportunity.End_User_Region__c),string.valueof(objOpportunity.Country_Sub_Region__c));
                system.debug(LoggingLevel.Info,'objPOCReqFrm2** '+objPOCReqFrm);                  
                insert objPOCReqFrm;
                if(objPOCReqFrm.AssignTo__c == 'Lead Assign')
                    SaveSolutionProduct();
                }
                catch(Exception ex)   
                  {
                   system.debug(LoggingLevel.Info,'ApexPages.Severity.Error,ex.getMessage()** '+ex.getMessage());           
                    blnShowErrorMsg = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
                  }         
                            
                 system.debug(LoggingLevel.Info,'objPOCReqFrm** '+objPOCReqFrm);   
                if(objPOCReqFrm.Primary_Business_Objectives__c <> objOpportunity.Key_Business_Objective__c)
                {
                    objOpportunity.Key_Business_Objective__c=objPOCReqFrm.Primary_Business_Objectives__c;
                    try{
                        update objopportunity;
                        }
                    catch(Exception ex)   
                      {
                       system.debug(LoggingLevel.Info,'ApexPages.Severity.Error,ex.getMessage()** '+ex.getMessage());           
                       blnShowErrorMsg = true;
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
                      }
                }
                POCUtility.CreateHistory('POC Request Submitted by AE',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
            }
            system.debug('++++create history++++');
            if(blnSubmit)
            {
                POCUtility.CreateHistory(strHistoryAction,UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
                system.debug('++++CommonMethod++++');
            }
            //Email notifications     
             if(objPOCReqFrm.AssignTo__c == 'Lead Assign')
            {
                //Send email notification to leads
                string strResult=POCUtility.SendEmailNotification('Lead Assigned',objPOCReqFrm.id,null);
                if(strResult=='Successful')
                    POCUtility.CreateHistory('Email Notification : Original Notification to Leaders that DSR was submitted',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
                else
                    POCUtility.CreateHistory('Email Notification Failed : Original Notification to Leaders that DSR was submitted',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
    
                //Send email notification to AE the wow is submitted
                strResult='';
                strResult=POCUtility.SendEmailNotification('Lead Submitted',objPOCReqFrm.id,null);
                if(strResult=='Successful')
                    POCUtility.CreateHistory('Email Notification : to AE that POC Engagement was submitted ',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
                else
                    POCUtility.CreateHistory('Email Notification Failed : to AE that POC Engagement was submitted',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
    
            }
           else if(objPOCReqFrm.AssignTo__c == 'Virtual Team' && blnSubmit)
            {                 
                /*List<POCVirtualUser__c> list_DiffVT=new List<POCVirtualUser__c>();
                list_POCExistVT=[SELECT Solution_Consultant__c,Virtual_User_type__c FROM POCVirtualUser__c WHERE POC_Engagement_Request__c=:objPOCReqFrm.id ];
                system.debug(LoggingLevel.Info,'**list_POCExistVT**'+list_POCExistVT); 
                system.debug(LoggingLevel.Info,'**list_VTUserList**'+list_VTUserList);
                list_DiffVT=POCUtility.getDiffVTList(list_VTUserList,list_POCExistVT); 
                system.debug(LoggingLevel.Info,'**list_DiffVT**'+list_DiffVT);               
                if(list_DiffVT!=null && list_DiffVT.size()>0)
                {*/
                    //Send email notification to AE that Virtual Team is assigned
                    System.debug(LoggingLevel.Info, '**list_VTUserList** '+list_VTUserList);
                    string strResult=POCUtility.SendEmailNotification('Virtual Team Assigned',objPOCReqFrm.id,list_VTUserList);
                    if(strResult=='Successful')
                        POCUtility.CreateHistory('Email Notification : to SC that they are assigned as Virtual Team Members on a POC Engagement',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
                    else
                        POCUtility.CreateHistory('Email Notification Failed : to SC that they are assigned as Virtual Team Members on a POC Engagement',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
                //}    
            }
            else if(objPOCReqFrm.AssignTo__c == 'Lead Completed' || objPOCReqFrm.AssignTo__c == 'Completed')
            {
                //virtual team submit POC for approval to Leader
                string strResult=
                POCUtility.SendEmailNotification('Lead Approval',objPOCReqFrm.id,null);
                if(strResult=='Successful')
                    POCUtility.CreateHistory('Email Notification : to leaders once POC Engagement activities have been performed',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
                else
                    POCUtility.CreateHistory('Email Notification Failed : to leaders once POC Engagement activities have been performed',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
            } 
            else if(objPOCReqFrm.AssignTo__c == 'Virtual Team for Result')
            {
                string strResult;
                //inform virtual team to fill result once it is approved
                if(objPOCReqFrm.POC_status__c=='POC Status Submitted for Completion')
                    strResult=POCUtility.SendEmailNotification('Lead Approved',objPOCReqFrm.id,list_VTUserList);
                if(strResult=='Successful')
                    POCUtility.CreateHistory('Email Notification : to Virtual team once POC Engagement approved',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
                else
                    POCUtility.CreateHistory('Email Notification Failed : to Virtual team once POC Engagement approved',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
            }
            else if(objPOCReqFrm.AssignTo__c == 'AE' && objPOCReqFrm.POC_status__c <> 'Rejected')
            {
                //Send email notification to AE that wow engagement is fully completed
                string strResult=POCUtility.SendEmailNotification('Lead Completed',objPOCReqFrm.id,null);
                if(strResult=='Successful')
                    POCUtility.CreateHistory('Email Notification : to AE that POC engagement is fully completed',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
                else
                    POCUtility.CreateHistory('Email Notification Failed : to AE  that POC engagement is fully completed',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
            }             
            if(objPOCReqFrm.POC_status__c == 'Rejected')
            {
               system.debug(LoggingLevel.Info,'objPOCReqFrm.id**tttt '+objPOCReqFrm.id); 
                //Send email notification to AE that wow engagement is fully completed
                string strResult=POCUtility.SendEmailNotification('Lead Rejected',objPOCReqFrm.id,null);
                if(strResult=='Successful')
                    POCUtility.CreateHistory('Email Notification : to AE that POC Engagement was rejected',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
                else
                    POCUtility.CreateHistory('Email Notification Failed : to AE that POC Engagement was rejected',UserInfo.getUserId(),POCUtility.GetUserType(UserInfo.getUserId(),objPOCReqFrm.Id,null),strPOCStage,objPOCReqFrm.POC_Status__c,objPOCReqFrm.Id);
             }     
            //if(sCheckErrMsg<>'')
               // CommonMethod(sCheckErrMsg);
            //else
            //{
               
             CommonMethod(null);
               
                system.debug(LoggingLevel.Info,'objPOCReqFrm.AssignTo__c**!!!!! '+objPOCReqFrm.AssignTo__c);   
              if(objPOCReqFrm.AssignTo__c == 'Lead Completed')
              {
                blnShowErrorMsg = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Closing this DSR indicates that no future presales work is required on this opportunity.')); 
                 objRef=null;
              }     
              else if(objPOCReqFrm.AssignTo__c != '' && objPOCReqFrm.AssignTo__c!='Lead Assign')
              {
                blnShowErrorMsg = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'POC Engagement Form has been submitted successfully.')); 
                objRef=null;
              }
              
              
          //}
      }
      catch(Exception ex)   
      {
       if(isLeadComplete) 
          objPOCReqFrm.AssignTo__c='Lead Completed';
          
        blnShowErrorMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }         
      return objRef;    
      //return null;    
  }
    
  public List<SelectOption> getStatusTypes() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('Approve','Approve'));
    options.add(new SelectOption('Reject','Reject'));
    return options;
  }

   public PageReference  FileDescription()
   {
      return null;
   }
   public void GetPOCHistoryDetails()
   {
       try{
          //if record exist in WoW request form
          system.debug(LoggingLevel.Info,'objPOCReqFrm.id***'+objPOCReqFrm.id); 
           if(objPOCReqFrm.id!=null)  
               { 
                 list_POCHistory = [select id,UserId__c,Action__c,Action_Date__c,Action_Performed_By__c,Attachment_Type__c,POC_Engagement_Status__c,POC_Request_Id__c,POC_Stage__c,POC_User_Type__c from POC_Request_Form_History__c where POC_Request_Id__c=: objPOCReqFrm.id ORDER BY LastModifiedDate desc];
                 if(list_POCHistory .size()<=0)
                     list_POCHistory =null;
               }
           else
               list_POCHistory =null;  
        }                        
     catch(Exception ex)   
      { 
       System.debug(LoggingLevel.Info, 'your logging message here error');       
        blnShowErrorMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }            
   }
    
   private boolean GlobalUser(string uId)
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
  
   /*public void GetProducts()
   {
     try{  
     List<string>list_Prd = new List<string>();
      list_ProductsOptions= new List<SelectOption>();
      //selctedPickVal
       //map_DependentPicVal
       for(string sSln : selctedPickValSolution)
       {
         List<string>list_P = map_DependentPicVal.get(sSln);
         list_Prd.addall(list_P);
       }
       
       for(string p : list_Prd)
        list_ProductsOptions.add(new SelectOption(p,p));
        list_ProductsOptions.sort();
        }                        
     catch(Exception ex)   
      { 
       System.debug(LoggingLevel.Info, 'your logging message here error');       
        blnShowErrorMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }   
   }*/
         
   public class clsWrapperPOCDetails
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
      
      public clsWrapperPOCDetails(Opportunity objOpp)
      {
        try{
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
        }
        catch(Exception ex)   
          { 
           System.debug(LoggingLevel.Info, 'your logging message here error');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
          } 
      }
      public clsWrapperPOCDetails(POC_Engagement_Request__c objPOC)
      {
          try{
            //Assign data from POC object
            AEName = objPOC.AE_Name__c;
            OpportunityName = objPOC.Opportunity_Name__c;
            Stage = objPOC.Stage__c;
            TotalAmount = objPOC.Total_Amount__c;
            PlatformType = objPOC.Platform_Type__c;
            CustomerName = objPOC.Customer_Name__c;
            BusinessPartner = objPOC.Business_Partner__c;
            PrimarySolution = objPOC.Primary_Solution_Category__c;
            ExpectedClosedDate = string.valueof(objPOC.Expected_Closed_Date__c);
            PrimaryBusinessObjective = objPOC.Primary_Business_Objectives__c;
            CurrencyCode=objPOC.CurrencyISOCode;
            Industry=objPOC.Industry__c;
        }
        catch(Exception ex)   
          { 
           System.debug(LoggingLevel.Info, 'your logging message here error');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
          } 
      }
   }
   public void GetVTUserList()
   { 
       try{         
         POCVirtualUser__c objPOCNewVT= new POCVirtualUser__c();
          objPOCNewVT.POC_Engagement_Request__c=objPOCReqFrm.Id;     
          objPOCNewVT.Solution_Consultant__c = objPOCVT.Solution_Consultant__c ; 
          objPOCNewVT.Virtual_User_type__c= objPOCVT.Virtual_User_type__c; 
          objPOCNewVT.Id=null;
          list_VTUserList.add(objPOCNewVT);            
          system.debug('list_VTUserList '+list_VTUserList);
          if(list_VTUserList.size()>0)
              blnIsVTListExist =true;
         }
        catch(Exception ex)   
          { 
           System.debug(LoggingLevel.Info, 'your logging message here error');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
          }            
   }
   public void GetSolutionProductList()
   { 
       try{ 
          if (objPOCReqFrm.Main_Product__c!=null && objPOCReqFrm.Main_Product__c!='') 
              {
                  String[] tmpString = objPOCReqFrm.Main_Product__c.split(';'); 
                  //Check the duplicate validation check 
                  if(checkDuplicateSolProduct(tmpString,objPOCReqFrm.Primary_Solution__c,list_SolProdList))  
                    {
                  for(String s : tmpString){   
                      POC_Solution_Product_Map__c objSolProd= new POC_Solution_Product_Map__c();
                      objSolProd.POC_Request_Id__c=objPOCReqFrm.Id;     
                      objSolProd.Primary_Solution__c = objPOCReqFrm.Primary_Solution__c ; 
                      objSolProd.Products__c= s; 
                      objSolProd.Id=null;
                      list_SolProdList.add(objSolProd);
                      list_mainProducts.add(objSolProd.Primary_Solution__c + ';' + s);
                    }   
                   } 
                   else
                       {
                       blnShowErrorMsg=true;
                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Duplicate combination of Solution Type and Main Product exist.'));
                       return;
                       }          
              }
             else
               {
               blnShowErrorMsg=true;
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select Main Product.'));
               return;
               } 
          }
        catch(Exception ex)   
          { 
           System.debug(LoggingLevel.Info, 'your logging message here error');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
          }   
          
   }
   public boolean checkDuplicateSolProduct(String[] Products,string Solution, list<POC_Solution_Product_Map__c>listSolPrdMap)
       {
           Boolean flag=true;
           String[] tmpString = objPOCReqFrm.Main_Product__c.split(';');   
                  for(String s : tmpString)
                  { 
                      for(POC_Solution_Product_Map__c objMap : listSolPrdMap)
                          {
                              if(objMap.Primary_Solution__c ==Solution && objMap.Products__c==s)
                                  {
                                  flag=false;
                                  return flag;
                                  }
                          }
                  }
            return flag;      
       }
   public void RemoveVTUser()
   {      
       POCVirtualUser__c objPOCNewVT= new POCVirtualUser__c();
       for(Integer i = list_VTUserList.size() - 1; i >= 0 ; --i)
           {
               if(list_VTUserList.get(i).get('Solution_Consultant__c')==CurrentVT && list_VTUserList.get(i).get('Virtual_User_type__c')==CurrentVTType)
                  list_VTUserList.Remove(i); 
           }
           
           system.debug('++list_VTUserList++'+list_VTUserList);
           if(list_VTUserList.size()>0)
              blnIsVTListExist =true;
           else    
             blnIsVTListExist =false;
    }
    //Remove Solution and product mapping from the list if it is stored in object then delete from object
    public void RemoveSolutionProduct()
   {      
       POC_Solution_Product_Map__c objSolutionProd= new POC_Solution_Product_Map__c();
       for(Integer i = list_SolProdList.size() - 1; i >= 0 ; --i)
           {   
               
               if(list_SolProdList.get(i).get('Primary_Solution__c')==CurrentSolution && list_SolProdList.get(i).get('Products__c')==CurrentProduct)
               { 
                  if(list_SolProdList.get(i).get('Id')!=null && CurrentId!=null)  
                      if(list_SolProdList.get(i).get('Id')==CurrentId)
                          {
                           objSolutionProd=[select Id FROM POC_Solution_Product_Map__c where Id=:CurrentId];
                           delete objSolutionProd;
                          }                       
                  list_SolProdList.Remove(i); 
               }
        }
    }
    private void SaveVirtualTeam(){       
        list_POCExistVT=new list<POCVirtualUser__c>(); 
        list_POCExistVT=[SELECT Solution_Consultant__c,Virtual_User_type__c FROM POCVirtualUser__c WHERE POC_Engagement_Request__c=:objPOCReqFrm.id ];          
        if(list_POCExistVT!=null && list_POCExistVT.size()>0)
            delete list_POCExistVT;
            system.debug('list_VTUserList-save'+list_VTUserList);
        
        
        if(list_VTUserList.size()>0)
         {    
            upsert list_VTUserList; 
            System.debug(LoggingLevel.INFO,'SaveVirtualTeam-insert'); 
            blnIsVTListExist =true;          
         }
               
          System.debug(LoggingLevel.INFO,'SaveVirtualTeam-End'); 
   }
   //save solution and product in solution product mapping
    private void SaveSolutionProduct(){       
        if(list_SolProdList!=null)
        for(POC_Solution_Product_Map__c objSolProd: list_SolProdList)
            objSolProd.POC_Request_Id__c= objPOCReqFrm.id;
        upsert list_SolProdList;
   }
   public void GetAttachmentsPOC()
  {
  try{       
       if(objPOCReqFrm.Id!=null)
       {
                    List<Attachment>list_AllAttach = [Select id,Description,name from Attachment where ParentId =: objPOCReqFrm.id];
            
                    if(list_AllAttach!=null && list_AllAttach.Size()>0)
                        blnPOCAttachment = true;
                        for(Attachment objAttach : list_AllAttach)
                        {                      
                          if(objAttach.Description.contains('POC Scope'))
                          {
                            blnIsAttachment = true;
                            if(list_AttachScope!=null)
                                list_AttachScope.add(objAttach);          
                            else
                            {
                                list_AttachScope= new List<Attachment>();
                                list_AttachScope.add(objAttach);  
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
                        }
       }
     }
        catch(Exception ex)   
          { 
           System.debug(LoggingLevel.Info, 'your logging message here error');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
          } 
      }
      
   public void DeleteAttachment()
      {
        Attachment objATT = [Select id,Description,name from Attachment where id =:sAttachmentId];                  
        //WoWUtility.CreateHistory('Document deleted to Wow Engagement ('+objATT.Name+')' ,sAttType , sAttSubType  ,UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,'Save'),objWowReqFrm.AssignTo__c,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
        delete objATT;
        
        CommonMethod(null);
      }
    /*public string getArrayData(string[] arr)
        {
            string datalist='';
            if(arr.size()>0)
                for(integer i=0;i<arr.size(); i++)
                   datalist=datalist+ arr[i]+',';
               
             if(datalist.length()>0)  
                 {
                 datalist=datalist.substring(0,datalist.length()-1);
                 }
             return datalist;  
        }*/
        
 public void UploadFile()  
   {  
      try
      { 
        
        if(fileBody == null || fileName == '') 
        {       
          blnShowErrorMsg = true;
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select the POC Scope file.'));
          return;
        }  
        
        blnCreateHistory=false;
        SaveWowDetails();
        
        string sAttType='';
        string sAttSubType='';
       if(FileDescType == 'POC Scope' || FileDescType  == 'Custom Use Case')
        {          
           sAttType = FileDescType;
        }
        else
        {
          string[]arrType = FileDescType.split(':');
          sAttType = arrType[0];
          sAttSubType = arrType[1];
          }
        system.debug('***objPOCReqFrm.id 111**' +objPOCReqFrm.id);
        
        Attachment obj = new Attachment();
        obj.Body = fileBody;
        obj.Name = fileName;
        obj.ParentId = objPOCReqFrm.id;
        obj.Description = FileDescType ;//sFileDesc 
        insert obj;

        //WoWUtility.CreateHistory('Attachment - ' + FileDescType,UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id),objWowReqFrm.AssignTo__c,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
        system.debug('***sAttSubType 111**' +sAttSubType );       
        //WoWUtility.CreateHistory('Document attached to POC Engagement',sAttType , sAttSubType  ,UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objWowReqFrm.Id,'Save'),objWowReqFrm.AssignTo__c,objWowReqFrm.WoW_Status__c,objWowReqFrm.Id);
        CommonMethod(null);

        /*Clear variables*/
        fileBody =null;
        fileName = '';
        FileDescType = '';
       //return pr;
      }
      catch(Exception ex)   
      {
        blnShowErrorMsg = true;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
      }  
   }
  public void DeleteVirtualUsers()
  {
    List<POCVirtualUser__c> List_VTAllUsers=[SELECT Solution_Consultant__c,Virtual_User_type__c FROM POCVirtualUser__c WHERE POC_Engagement_Request__c=:objPOCReqFrm.id];
    list_VTUserList=new List <POCVirtualUser__c>();
  } 
  public void GetPOCFunctionalUseCase()
  {
     list_POCAttachmentsFnUseCase = [Select Id,FnUseCase__c,Fit__c,Description__c,POCEngagementRequest__c,Row_Number__c,Functional_Usecases_Numbers__c  from POCFnUseCase__c where POCEngagementRequest__c =: objPOCReqFrm.id];
     if(list_POCAttachmentsFnUseCase.size()<=0)
     {
       list_POCAttachmentsFnUseCase = new List<POCFnUseCase__c>();
       POCFnUseCase__c objWowAttFn = new POCFnUseCase__c();
       objWowAttFn.POCEngagementRequest__c = objPOCReqFrm.id;
       //objWowAttFn.Type__c = 'Functional Use Case';
       //objWowAttFn.Functional_Usecases_Numbers__c = 'CE' + 1;
       list_POCAttachmentsFnUseCase.add(objWowAttFn);
     }
     system.debug('list_POCAttachmentsFnUseCase'+list_POCAttachmentsFnUseCase);
       
  }
   public void RemoveFunctionalUseCase()
   {

        
      if(list_POCAttachmentsFnUseCase.size() > 1)
      {   
         if(CurrentFunUseCase != '' && CurrentFunUseCase != null) 
         {
           integer Idx = 0;
           integer removeIndex; 
           for(POCFnUseCase__c objW2 : list_POCAttachmentsFnUseCase)
           {
             if(objW2.Row_Number__c == integer.valueof(CurrentFunUseCase))
             {
               removeIndex = Idx ;
             }  
               
             Idx += 1;  
           }
           list_POCAttachmentsFnUseCase.Remove(removeIndex);

          }
       }  
       else
       {
         list_POCAttachmentsFnUseCase= new List<POCFnUseCase__c>();
         AddFunctionUseCase();
       }            
            if(FunUseCaseId != '' && FunUseCaseId != null)
            {
              List<POCFnUseCase__c> objWowAtch = [Select id from POCFnUseCase__c where id =: FunUseCaseId];
              delete objWowAtch;
              UpdateFnUseCaseNumbers();
              if(list_POCAttachmentsFnUseCase.size()<=0)
               AddFunctionUseCase();
            }  
            
    }
    
   public void AddFunctionUseCase()
   {
     integer iLastNumb = CheckLastNumber(list_POCAttachmentsFnUseCase);
     POCFnUseCase__c objWowAtt = new POCFnUseCase__c();
     objWowAtt.POCEngagementRequest__c = objPOCReqFrm.id;
     //objWowAtt.Type__c = 'Functional Use Case';
     //objWowAtt.Row_Number__c = iLastNumb + 1 ;//list_WowAttachmentsFnUseCase.size() + 1;
     objWowAtt.Functional_Usecases_Numbers__c = 'CE' + (iLastNumb + 1);     
     list_POCAttachmentsFnUseCase.add(objWowAtt);
   }
  private void UpdateFnUseCaseNumbers()
  {
    string sFnUCase='';    
    system.debug('+++list_POCAttachmentsFnUseCase Line No. 1602'+list_POCAttachmentsFnUseCase);
      if(list_POCAttachmentsFnUseCase != null && list_POCAttachmentsFnUseCase.size()>0)
      {
        integer UseCase = 0;      
        for(POCFnUseCase__c objWAtt : list_POCAttachmentsFnUseCase)
        {
         if(objWAtt.FnUseCase__c !='' && objWAtt.FnUseCase__c !=null){
           UseCase =objWAtt.FnUseCase__c.indexOf(': ')+1;
           system.debug('**UseCase ***'+UseCase);
          //if(objWAtt.Functional_Usecases_Numbers__c !=null && objWAtt.Functional_Use_Case__c != null) {
            if(sFnUCase == '' )
              sFnUCase = objWAtt.FnUseCase__c.substring(UseCase,UseCase+5);              
             else
              sFnUCase += ',' + objWAtt.FnUseCase__c.substring(UseCase ,UseCase+5);  
              
          //}
          }
        }
        //if(sFnUCase != '')
        objPOCReqFrm.FunctionalUsecasesNumbers__c = sFnUCase;
      }
      system.debug('sFnUCase ** '+sFnUCase);      
      /*Update functional Use cases on Opportunity*/
     //if(sFnUCase != '')
     //{
       objOpportunity.FunctionalUsecasesNumbers__c = sFnUCase;
       if(!Test.isRunningTest())
         update objOpportunity;
         system.debug('+++objOpportunity.FunctionalUsecasesNumbers__c Line No. 1630'+objOpportunity.FunctionalUsecasesNumbers__c);
     //}
  }
  private integer CheckLastNumber(List<POCFnUseCase__c>lst)
   {
      integer iLastNumb=0;
     for(POCFnUseCase__c  obj :lst)
     {
       if(obj.Functional_Usecases_Numbers__c!=null && obj.Functional_Usecases_Numbers__c!='')
        if(integer.valueof(obj.Functional_Usecases_Numbers__c.substring(2)) > iLastNumb)
         iLastNumb = integer.valueof(obj.Functional_Usecases_Numbers__c.substring(2));
     }
    return  iLastNumb;
   }
}