/***************************************************************************************************
* 
*  Class Name      :   DSRDiscoveryController
*  Description     :   This class is used to save Discovery activity in SC Engegement
*  Auther          :   R Systems
* 
****************************************************************************************************/
global class DSRDiscoveryController{

   public string FileDescType{get;set;}
   public DSRDataDefinition__c objDataDefinition{get;set;}
   public DSR_Attachments__c objDSRActivity{get;set;}
   public List<SelectOption>optionList{get;set;}
   public string strSelectedVisionType{get;set;}
   public List<DSR_Attachments__c>list_VisionActivity{get;set;}
   public DSR_SCEngagement__c objSCE{get;set;}
   public string strVisionActId{get;set;}
   public boolean blnHasVisionActivity{get;set;}
   global Map<string,string>map_description{get;set;}
   public string strSelectedDesc{get;set;}
   public Opportunity objOpp{get;set;}
    public String HomeURL{get;set;}
   public user objUsera {get;set;}
     public boolean ipartneruser{get;set;}
   //public boolean VTSection_RO{get;set;}
   //public boolean VTSection{get;set;}
   public List<SelectOption>optionListAccess{get;set;}
   public List<SelectOption>optionListSource{get;set;}
   public string strSelectedAccess{get;set;}
   public string strSelectedSource{get;set;}
   public boolean blnShowErrorMsg{get;set;}
   public boolean blnShowErrorMsg_Popup {get;set;}
   public boolean blnParentDisable {get;set;}
   public boolean blnIsSubmitted{get;set;}
   public boolean checkMandatory{get;set;}//added by priyank 15 Nov 2018
   public DSR_Attachments_Definition__c dataDef {get; set;} 
   
   public Map<string,string>map_DiscoveryLinks{get;set;}
   public string strURLReq{get;set;}
   
   /* constructor */
   public DSRDiscoveryController()
   {
     dataDef = new DSR_Attachments_Definition__c();  
     Id SCEID = apexpages.currentpage().getparameters().get('id');
     checkMandatory = false; //added by priyank 15 Nov 2018
     objSCE = new DSR_SCEngagement__c();
        objUsera = new user();
     objSCE = [select id,SC_Engagement_Status__c ,AssignTo__c ,Has_Vision_Activities__c,Discovery_Start_Date__c,Discovery_End_Date__c,Is_Partner_DSR__c,Opportunity_ID__c,Opportunity_ID__r.AccountId,Account_ID__c,name,Discovery_Notes__c,Opportunity_ID__r.Lines_of_Businesses__c from DSR_SCEngagement__c where id =:SCEID];
     objOpp = [Select id,Primary_Line_of_Business__c,Lines_of_Businesses__c,Stagename,Lead_Offer__c  from Opportunity where id=:objSCE.Opportunity_ID__c];
     
     if(DSR_SC_Engage_Utility.checkReadOnly(UserInfo.getUserId(), objSCE.Id, UserInfo.GetUserEmail()) || objSCE.SC_Engagement_Status__c == 'Completed' ||objSCE.SC_Engagement_Status__c == 'Submitted for Completion')
       blnIsSubmitted = true;
     else
       blnIsSubmitted = false; 
       
        objUsera = [SELECT Id,IsPortalEnabled FROM User WHERE Id=:UserInfo.getUserId()];  
     if(objUsera.IsPortalEnabled == true){
     ipartneruser = true; } else{
        ipartneruser = false ;
     }
     Init();
     
     // if(objSCE.Is_Partner_DSR__c == false)
      if( (objSCE.Is_Partner_DSR__c == false || objSCE.Is_Partner_DSR__c == true )  && objUsera.IsPortalEnabled == false)
        HomeURL = '/apex/SC_Engagement_DSR?id='+SCEID; 
    else                           
        HomeURL = '/partner/SC_EngagementPartner_DSR?id='+SCEID;
   }
   
   private void Init()
   {
     strSelectedDesc ='';
     strURLReq = 'NO';
     blnHasVisionActivity = false;
     objDSRActivity = new DSR_Attachments__c();
     list_VisionActivity = new List<DSR_Attachments__c>();
     optionListSource = new List<SelectOption>();
     GetDataDefValues();
     GetVisionActivities();
     GetAllAccess();
     GetAccessAndSource();
     DSRUtility.SetVisibility(objSCE,objOpp);
     //VTSection_RO = false;//DSRUtility.VTSection_RO;
     //VTSection = true;//DSRUtility.VTSection;
     
   }
   public void AddAct()
   {
     blnParentDisable = true;
     strURLReq = 'NO';
     objDSRActivity = new DSR_Attachments__c();
     ClearValues();
   }
   private void GetDataDefValues()
   {
     //List<DSRDataDefinition__c>list_PickListVal = DSRUtility.GetDataDefinition('Discovery','Discovery Activity');
     List<DSRDataDefinition__c>list_PickListVal  = [select id,Description__c,DSRType__c,Header__c,Module__c,OfferPlatformType__c,SubModule__c,URL__c from DSRDataDefinition__c where Module__c =: 'Discovery' and IsActive__c =: true];
     List<DSR_Attachments_Definition__c>list_AttachDefinition = [Select id,AttachmentType__c,Description__c from DSR_Attachments_Definition__c where ObjectType__c =: 'Discovery Activity' and Active__c =: true ORDER BY AttachmentType__c ASC];
     
     map_description = new Map<string,string>();
     map_DiscoveryLinks = new Map<string,string>();
     
     optionList = new List<SelectOption>();
     optionList.add(new SelectOption('', '- None -'));  
     
     for(DSR_Attachments_Definition__c obj : list_AttachDefinition)
     {
       optionList.add(new SelectOption(obj.AttachmentType__c,obj.AttachmentType__c)); 
       map_description.put(obj.AttachmentType__c,obj.Description__c);
     }
     for(DSRDataDefinition__c obj : list_PickListVal)
     {
       /*if(obj.SubModule__c == 'Discovery Activity')
       {
         optionList.add(new SelectOption(obj.Header__c,obj.Header__c)); 
         map_description.put(obj.Header__c,obj.Description__c);
       }*/
       if(obj.SubModule__c == 'Discovery Link')
       {
         map_DiscoveryLinks.put(obj.Header__c,obj.URL__c);
       }
     }
     
     system.debug('+++list_PickListVal+++'+list_PickListVal);
     system.debug('+++map_description+++'+map_description);
   }
   
   
   
   public void Cancel()
   {
     blnParentDisable = false;
     dataDef = new DSR_Attachments_Definition__c();
     ClearValues();
   }
   
   
   
   public void saveVisionActivity()
   {
    
      system.debug(LoggingLevel.INFO,'+++strSelectedAccess+++'+strSelectedAccess);
         system.debug(LoggingLevel.INFO,'+++strSelectedSource+++'+strSelectedSource);
         if(objDSRActivity.DateofAttachment__c < objSCE.Discovery_Start_Date__c || objDSRActivity.DateofAttachment__c > objSCE.Discovery_End_Date__c){
            blnParentDisable = false;
            blnShowErrorMsg_Popup = false;
            InsertVisionActivity();
             
             if(objDSRActivity.DateofAttachment__c < objSCE.Discovery_Start_Date__c)
             {
               objSCE.Discovery_Start_Date__c= objDSRActivity.DateofAttachment__c;
             }
             if(objDSRActivity.DateofAttachment__c > objSCE.Discovery_End_Date__c)
             {
               objSCE.Discovery_End_Date__c = objDSRActivity.DateofAttachment__c;
             } 
             update objSCE; 
             Init();
         }
         else if((strSelectedAccess == null && !objSCE.Is_Partner_DSR__c) || strSelectedSource == null || strSelectedVisionType == null || objDSRActivity.Description__c == null || objDSRActivity.DateofAttachment__c == null || (strURLReq == 'YES' && objDSRActivity.AttachmentURL__c == null))
         {
            blnShowErrorMsg_Popup = true;
            blnParentDisable = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please fill mandatory fields.'));
         }
         else
         {
            blnParentDisable = false;
            blnShowErrorMsg_Popup = false;
            InsertVisionActivity();
             
             /*if(list_VisionActivity != null && list_VisionActivity.size()>0)
             {
               blnHasVisionActivity = true;
               objSCE.DiscoveryCount__c = list_VisionActivity.size();
             }
             else
               objSCE.DiscoveryCount__c = 0;  
               
             objSCE.Has_Discovery_Activities__c = blnHasVisionActivity;*/
             update objSCE;
             Init();  
         }       
        dataDef = new DSR_Attachments_Definition__c();  
   }
   
   
   
   private void InsertVisionActivity()
    {
        //objDSRActivity.Module__c = 'Discovery';
        objDSRActivity.ObjectType__c = 'Discovery Activity';
        objDSRActivity.AttachmentType__c = strSelectedVisionType;
        objDSRActivity.DSRSCEngagement__c = objSCE.id;
        objDSRActivity.Access__c = strSelectedAccess;
        objDSRActivity.Source__c = strSelectedSource;
        //upsert objDSRActivity ;
        if(objDSRActivity.id == null)
        {
           insert objDSRActivity;
           /*Create History on Activity Creation*/
           SCEngagementDSRCtlr.CreateHistory('Activity created on Discovery',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objSCE.Id,null),objSCE.AssignTo__c,objSCE.SC_Engagement_Status__c,objSCE.Id);
          
           
           blnHasVisionActivity = true;
           
           if(list_VisionActivity != null && list_VisionActivity.size()>0)
             {
               
               objSCE.DiscoveryCount__c = list_VisionActivity.size() + 1;
             }
             else
               objSCE.DiscoveryCount__c = 1;  
               
             objSCE.Has_Discovery_Activities__c = blnHasVisionActivity;
             update objSCE;
        }
        else
          update objDSRActivity;
        
        /*Clear values*/
        ClearValues();
    }
    
    
    private void ClearValues()
    {
        /*Clear values*/
        strSelectedVisionType = '';
        strSelectedAccess = '';
        strSelectedSource = '';
        strURLReq = '';
    }
    
    
   private void GetVisionActivities()
   {
     //list_VisionActivity = [Select id,Header__c,Description__c,AttachmentURL__c,ActivityDate__c,Access__c,Source__c,Notes__c from DSR_Activity__c where Module__c =: 'Discovery' and SCEID__c =:objSCE.id ORDER BY Createddate DESC];
     list_VisionActivity = [Select id,Access__c,AttachmentType__c,AttachmentURL__c,DateofAttachment__c,Description__c,DSRSCEngagement__c,ObjectType__c,Source__c,Notes__c  from DSR_Attachments__c where ObjectType__c =: 'Discovery Activity' and DSRSCEngagement__c =:objSCE.id ORDER BY createddate DESC];
   }
   
   
   public void RemoveVisionActivity()
   {
     //DSR_Activity__c obj = [Select id from DSR_Activity__c where id =:strVisionActId];
     DSR_Attachments__c obj = [Select id from DSR_Attachments__c where id =:strVisionActId];
     delete obj;
     Init();
     
     if(list_VisionActivity != null && list_VisionActivity.size()>0)
     {
       blnHasVisionActivity = true;
       objSCE.DiscoveryCount__c = list_VisionActivity.size();
     }
     else
       objSCE.DiscoveryCount__c = 0;  
           
      objSCE.Has_Discovery_Activities__c  = blnHasVisionActivity;
      update objSCE; 
   }
   
   
   
   public void SaveSCE()
   {
     
     //objSCE.Has_Vision_Activities__c = blnHasVisionActivity; 
     //CheckStartAndEndDate();
     /* If end date and start changes on Vision then checks All activities date .It should be between these date range.*/
     if(list_VisionActivity != null && list_VisionActivity.size()>0)
     {
       for(DSR_Attachments__c obj : list_VisionActivity)
       {
         if(obj.DateofAttachment__c > objSCE.Discovery_End_Date__c || obj.DateofAttachment__c < objSCE.Discovery_Start_Date__c){
           blnShowErrorMsg = true;
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'All activity date should be between Start and End Date.'));
           return;
         }
       }
     }
     
     if(objSCE.Discovery_End_Date__c <= objSCE.Discovery_Start_Date__c){
       blnShowErrorMsg = true;
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'End date should be greater then Start Date.'));
       return;
      }
      
       update objSCE;
   }
   /*private void CheckStartAndEndDate()
   {
     // If end date and start changes on Vision then checks All activities date .It should be between these date range.
     if(list_VisionActivity != null && list_VisionActivity.size()>0)
     {
       for(DSR_Attachments__c obj : list_VisionActivity)
       {
         if(obj.DateofAttachment__c > objSCE.Discovery_End_Date__c || obj.DateofAttachment__c < objSCE.Discovery_Start_Date__c){
           blnShowErrorMsg = true;
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'All activity date should be between Start and End Date.'));
           return;
         }
       }
     }
     
   }*/
   public void EditActivity()
   {
      blnParentDisable = true;
      checkMandatory = false; //added by priyank 15 Nov 2018
      //objDSRActivity = [Select id,Header__c,Description__c,AttachmentURL__c,ActivityDate__c,Access__c,Source__c,Notes__c from DSR_Activity__c where id =: strVisionActId];
      objDSRActivity = [Select id,Access__c,AttachmentType__c,AttachmentURL__c,DateofAttachment__c,Description__c,DSRSCEngagement__c,Notes__c,Source__c from DSR_Attachments__c where id =: strVisionActId];
      strSelectedVisionType = objDSRActivity.AttachmentType__c; 
      strSelectedAccess = objDSRActivity.Access__c; 
      strSelectedSource = objDSRActivity.Source__c;
      //Below query and if condition is added by priyank 15 Nov 2018
      List<DSR_Attachments_Definition__c> dsrAttacment = [select id,Description__c,AttachmentType__c,FullDescriptionURL__c,ObjectType__c,Notes__c, URLRequired__c from DSR_Attachments_Definition__c where ObjectType__c =: 'Discovery Activity' and AttachmentType__c =: strSelectedVisionType and Active__c =: true LIMIT 1];
       if(dsrAttacment.size()>0){
           dataDef = dsrAttacment[0];
           if(dsrAttacment[0].URLRequired__c){
               checkMandatory = true;
           }
      } 
   }
   
   
   
   private void GetAllAccess()
   {
     List<DSRDataDefinition__c>list_Access = [select id,SubModule__c,header__c from DSRDataDefinition__c where Module__c =:'Common' and SubModule__c =: 'Access' and IsActive__c =: true];
     Set<string> set_access = new Set<string>();
     optionListAccess = new List<SelectOption>();
     //Priyank added if else condition below to show the Access picklist set to internal only as discussed with JJ 31/10/2018.
     if(objSCE.Is_Partner_DSR__c){    
         optionListAccess.add(new SelectOption('', '- None -')); 
     }else{
         optionListAccess.add(new SelectOption('Internal Only', 'Internal Only'));
         set_access.add('Internal Only');
     }
     for(DSRDataDefinition__c obj : list_Access)
     {
       if(!set_access.contains(obj.header__c ))
       {
         optionListAccess.add(new SelectOption(obj.header__c ,obj.header__c )); 
         set_access.add(obj.header__c );
       }  
     }
   }
   
   @RemoteAction
   global  static DSR_Attachments_Definition__c GetDescription(string strVisionType)
   {
      // dataDef = new DSR_Attachments_Definition__c(); 
      //List<DSRDataDefinition__c>list_PickListVal  = [select id,Description__c,DSRType__c,Header__c,Module__c,OfferPlatformType__c,SubModule__c,URL_Required__c from DSRDataDefinition__c where Module__c =: 'Discovery' and SubModule__c =: 'Discovery Activity' and Header__c =: strVisionType and IsActive__c =: true];
      List<DSR_Attachments_Definition__c>list_PickListVal  = [select id,Description__c,AttachmentType__c,FullDescriptionURL__c,ObjectType__c,URLRequired__c, Notes__c from DSR_Attachments_Definition__c where ObjectType__c =: 'Discovery Activity' and AttachmentType__c =: strVisionType and Active__c =: true];
      return list_PickListVal[0];
   }
   
   //@RemoteAction
   //global  static List<string> GetAccessAndSource(string strAccess)
   public void GetAccessAndSource()
   {
      //List<DSRDataDefinition__c>list_PickListVal = DSRUtility.GetDataDefinition('Common',strSelectedAccess);
      List<DSRDataDefinition__c>list_PickListVal = [select id,Description__c,DSRType__c,Header__c,Module__c,OfferPlatformType__c,SubModule__c from DSRDataDefinition__c where Module__c =:'Common' and SubModule__c =: 'Document Source' and IsActive__c =: true];
      List<string>list_Source = new List<string>();
      
      optionListSource = new List<SelectOption>();
      optionListSource.add(new SelectOption('', '- None -')); 
      Set<string>set_Source = new Set<string>();
      for(DSRDataDefinition__c obj : list_PickListVal)
      {
        if(!set_Source.contains(obj.Header__c))
        {
          list_Source.add(obj.Header__c);
          optionListSource.add(new SelectOption(obj.Header__c,obj.Header__c)); 
          set_Source.add(obj.Header__c);
        }
      }
      
      
      //return list_Source;
   }
   @RemoteAction
   global static string FileURLinsert( Blob attachmentBody, String attachmentName, String parId){
        
        Attachment atc = new Attachment();
        atc.body = attachmentBody;
        atc.Name = attachmentName;
        atc.ParentId = parId;
        atc.Description = 'Discovery';
        insert atc;
        String URLs = URL.getSalesforceBaseUrl().toExternalForm() + '/partner/servlet/servlet.FileDownload?file=' + atc.Id;
        return URLs;
   }
  /*  @RemoteAction
   global static string FileURLinsert( Blob attachmentBody, String attachmentName)
   {
        system.debug('>>>>> ' + attachmentBody);
        system.debug('>>>>> ' + attachmentName);
        ContentVersion v = new ContentVersion();
        v.versionData = attachmentBody;
        v.title = attachmentName;
        v.pathOnClient = attachmentName;//'/somepath.txt';
        insert v;
        
        List<ContentWorkSpace> CWList = [SELECT Id, Name From ContentWorkspace WHERE Name =: 'SC Engagement'];
        
        v = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :v.Id];
        
        ContentWorkspaceDoc cwd = new ContentWorkspaceDoc();
        cwd.ContentDocumentId = v.ContentDocumentId;
        cwd.ContentWorkspaceId = CWList.get(0).Id;
        insert cwd;
        
        String baseUrl =  URL.getSalesforceBaseUrl().toExternalForm()  + '/' + v.id;
        return baseUrl;
   }*/
   
   /*@RemoteAction
   global static string UploadFileInSharePoint(string fileObj, string url,string token)
   {
        
        //Get Security Token
        string endUrl = 'https://accounts.accesscontrol.windows.net/785ce69c-90cf-4dc7-a882-eaf312d1d15d/tokens/OAuth/2';
        HttpRequest req2 = new HttpRequest();
        req2.setHeader('client_id', '55468c25-899e-48e6-911a-6e859a673169@785ce69c-90cf-4dc7-a882-eaf312d1d15d');
        req2.setHeader('client_secret', 'GmUq8WVKeRZaVBxY+GiRvH0d1WZhTGH6IJFWxQeUsuw=');
        req2.setHeader('resource', '00000003-0000-0ff1-ce00-000000000000/genesyslab.sharepoint.com@785ce69c-90cf-4dc7-a882-eaf312d1d15d');
        req2.setHeader('grant_type', 'client_credentials');
        
        req2.setMethod('POST');
        req2.setEndpoint(endUrl);
        //req.setBody(bodyPayload);
        Http http2 = new Http();
        HTTPResponse res2 = http2.send(req2);
        string strToken = res2.getBody();
        system.debug('+++strtoken+++'+strToken);
        
        
        //Upload File in Sharepoint
        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', token);
        req.setHeader('Accept','application/json;odata=verbose');
        req.setHeader('X-RequestDigest', '');
        
        req.setMethod('POST');
        req.setEndpoint(url);
        req.setBody(fileObj);
        
         
        Http http = new Http();
        HTTPResponse res = http.send(req);
        string result = res.getBody();
        return result;
   }*/
}