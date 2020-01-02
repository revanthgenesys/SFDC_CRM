/***************************************************************************************************
* 
*  Class Name      :   DSRDesignBusinessController
*  Description     :   This class is used to save activity and Functional UseCases in SC Engegement
*  Auther          :   R Systems
* 
****************************************************************************************************/
global class DSRDesignBusinessController{

   public string FileDescType{get;set;}
   public DSRDataDefinition__c objDataDefinition{get;set;}
   public DSR_Attachments__c objDSRActivity{get;set;}
   public List<SelectOption>optionList{get;set;}
   //public string strSelectedVisionType{get;set;}
   public List<DSR_Attachments__c>list_Activity{get;set;}

   
   public List<DSR_Use_Case_Blueprints__c>list_FnUseCase{get;set;}
   
   public DSR_SCE_Design__c objSCE{get;set;}
   public string strVisionActId{get;set;}
   public string strDesignId{get;set;}
   public boolean blnHasVisionActivity{get;set;}
   global Map<string,string>map_description{get;set;}
   public string strSelectedDesc{get;set;}
   public Opportunity objOpp{get;set;}
   
   //public boolean VTSection_RO{get;set;}
   //public boolean VTSection{get;set;}
   public List<SelectOption>optionListAccess{get;set;}
   public List<SelectOption>optionListSource{get;set;}
   public List<SelectOption>optionListOfferType{get;set;}
   public List<SelectOption>optionListPlatformType{get;set;}
   public List<SelectOption>optionListShortCode{get;set;}
   public List<SelectOption>optionListFit{get;set;}
   public List<SelectOption>optionListFitCategory{get;set;}
   public List<SelectOption>optionListAttachmentType{get;set;}
   
   public string strSelectedAccess{get;set;}
   public string strSelectedSource{get;set;}
   public string strSelectedOffer{get;set;}
   public string strSelectedPlatform{get;set;}
   public string strSelectedShortCode{get;set;}
   public string strSelectedFit{get;set;}
   public string strSelectedFitCategory{get;set;}
   public string strSelectedAttachmentType{get;set;}
   
   public List<DSR_SCE_Design__c>list_Designs{get;set;}
   public boolean blnShowErrorMsg_Popup{get;set;}
   public boolean blnShowErrorMsg{get;set;}
   public ID SCEID{get;set;}
   public boolean blnParentDisable{get;set;}
   //public DSR_Activity__c objFnUseCase{get;set;}
   public DSR_Use_Case_Blueprints__c objFnUseCase{get;set;}
   public boolean checkMandatory{get;set;}//added by priyank 15 Nov 2018
   
   public List<SelectOption>optionListPrimaryDesign{get;set;}
   public boolean blnIsSubmitted{get;set;}
   public Map<string,string>map_DesignLinks{get;set;}
   public string strDescription{get;set;}
   public string strBusinessDsgnProfile{get;set;}
   public string strURLReq{get;set;}
   public string strFnId{get;set;}
   public string Version{get;set;}
   
   public blob fileBody{get;set;}
   public string fileName{get;set;}
   public DSR_Attachments_Definition__c dataDef {get; set;}
   public DSR_UseCase_BluePrint_Definition__c ArchBluePrintDef{get; set;}
   public Map<String, String> map_ShortCodeName;
   
   /* constructor */
   public DSRDesignBusinessController()
   {
     dataDef = new DSR_Attachments_Definition__c();
     ArchBluePrintDef = new DSR_UseCase_BluePrint_Definition__c();
     Id SCEID = apexpages.currentpage().getparameters().get('id');
     objSCE = new DSR_SCE_Design__c();
     checkMandatory = false; //added by priyank 15 Nov 2018

     objSCE = [select id,name,HAType__c,DataCenters__c,Design_Source__c,DSR_SCEngagement__r.AssignTo__c,DSR_SCEngagement__c,DSR_SCEngagement__r.SC_Engagement_Status__c ,IsPrimary__c,Name__c,PrimaryDesign__c,DSR_SCEngagement__r.Opportunity_ID__c,DSR_SCEngagement__r.Opportunity_ID__r.AccountId,createddate,lastmodifieddate,createdbyid,lastmodifiedbyid,BusinessDesignProfile__c,OfferingPlatformType__c,Notes__c,DSR_SCEngagement__r.Is_Partner_DSR__c from DSR_SCE_Design__c where id =:SCEID];
     objOpp = [Select id,Lines_of_Businesses__c,Primary_Line_of_Business__c,Stagename,Lead_Offer__c from Opportunity where id=:objSCE.DSR_SCEngagement__r.Opportunity_ID__c];
     
     if(DSR_SC_Engage_Utility.checkReadOnly(UserInfo.getUserId(), objSCE.DSR_SCEngagement__c, UserInfo.GetUserEmail()) || objSCE.DSR_SCEngagement__r.SC_Engagement_Status__c == 'Completed' ||objSCE.DSR_SCEngagement__r.SC_Engagement_Status__c == 'Submitted for Completion')
       blnIsSubmitted = true;
     else
       blnIsSubmitted = false;
     Init();
   }
   
   private void Init()
   {
     strSelectedDesc ='';
     blnHasVisionActivity = false;
     blnShowErrorMsg_Popup =false;
     objDSRActivity = new DSR_Attachments__c();
     list_Activity = new List<DSR_Attachments__c>();
     list_FnUseCase = new List<DSR_Use_Case_Blueprints__c>();
     objFnUseCase = new DSR_Use_Case_Blueprints__c();
     list_Designs = new List<DSR_SCE_Design__c>();
     optionListPrimaryDesign = new List<SelectOption>();
     optionListSource = new List<SelectOption>();
     optionListOfferType = new List<SelectOption>();
     optionListPlatformType = new List<SelectOption>();
     optionListShortCode = new List<SelectOption>();
     optionListFit = new List<SelectOption>();
     optionListFitCategory = new List<SelectOption>();
     optionListAttachmentType = new List<SelectOption>();
     map_ShortCodeName = new Map<String, String>();
     
     GetDataDefValues();
     GetFnUseCase();
     GetAllAccess();
     GetAccessAndSource();
     GetFnUseCaseMetaData();
     GetActivity();
     
     //VTSection_RO = false;//DSRUtility.VTSection_RO;
     //VTSection = true;//DSRUtility.VTSection;
     
   }
   private void GetActivity()
   {
      //list_Activity = [Select id,Header__c,Description__c,AttachmentURL__c,ActivityDate__c,Access__c,Source__c,Notes__c,Version__c,ShortChangeDescription__c  from DSR_Activity__c where Module__c =: 'Design' and SubModule__c =: 'Design Specific Attachment' and DSRSCEDesign__c =:objSCE.id ORDER BY createddate DESC];
      
      list_Activity = [Select id,Description__c,Access__c,AttachmentType__c,AttachmentURL__c,DateofAttachment__c,DSRSCEDesign__c,ObjectType__c,Source__c,Notes__c from DSR_Attachments__c where ObjectType__c =: 'Business Design Attachment' and DSRSCEDesign__c =:objSCE.id ORDER BY createddate DESC];
   }
   private void GetFnUseCaseMetaData()
   {
     string str = ''+objSCE.OfferingPlatformType__c+'';
     List<DSR_UseCase_BluePrint_Definition__c>list_DataDefFnUseCase = [select id,Name,AdditionalURL__c,Dateoflastrevision__c,Maturity_Model__c,Product_Category__c,Description__c,LatestVersion__c,Name__c,PublishedURL__c,ShortCode__c,Type__c,Offer_Platform_Type__c from DSR_UseCase_BluePrint_Definition__c where Type__c =:'Use Case' and Offer_Platform_Type__c includes (:str) and Active__c =: true ORDER BY ShortCode__c ASC];
     
     List<DSRDataDefinition__c>list_shortCode = [Select id,Header__c,SubModule__c,FitCategory__c,OfferPlatformType__c,URL__c  from DSRDataDefinition__c where Module__c =: 'Design' ORDER BY Header__c ASC];
     
     List<DSR_Attachments_Definition__c>list_AttachDataDef = [select id,AttachmentType__c,Description__c,FullDescriptionURL__c,ObjectType__c,URLRequired__c from DSR_Attachments_Definition__c where ObjectType__c =: 'Business Design Attachment' and Active__c =: true  and OfferPlatformType__c includes (:str) ORDER BY AttachmentType__c ASC];
     
     optionListShortCode.add(new SelectOption('', '- None -')); 
     optionListFit.add(new SelectOption('', '- None -')); 
     optionListFitCategory.add(new SelectOption('', '- None -')); 
     optionListAttachmentType.add(new SelectOption('', '- None -')); 
     map_DesignLinks = new Map<string,string>();
     
     //string strCode;
     List<integer>listSCode = new List<integer>();
     for(DSRDataDefinition__c obj:list_shortCode)
     {
       /*if(obj.SubModule__c == 'Functional Use Case'){
         optionListShortCode.add(new SelectOption(obj.Header__c,obj.Header__c)); 
       }*/
       if(obj.SubModule__c == 'Business Design Fit%'){
         //optionListFit.add(new SelectOption(obj.Header__c,obj.Header__c));
         listSCode.add(integer.valueof(obj.Header__c));
          
       }
       if(obj.SubModule__c == 'Business Design Fit Categeory'){
         optionListFitCategory.add(new SelectOption(obj.Header__c,obj.Header__c));   
       }
       
       if(obj.SubModule__c == 'Design Link')
       {
         map_DesignLinks.put(obj.Header__c,obj.URL__c);
       }
       
       
     }
     
     /*Sorting in Short Code*/
     listSCode.sort();
     system.debug('+++listSCode++'+listSCode);
     for(integer a :listSCode)
     {
       optionListFit.add(new SelectOption(string.valueof(a),string.valueof(a)));
     }
     
     
     // From Functional UseCase Data Definition object
     List<SelectOption>list_SShortCodeTemp = new List<SelectOption>();
     SelectOption objOption;
     
     for(DSR_UseCase_BluePrint_Definition__c objDef : list_DataDefFnUseCase)
     {
        /*To put the custom option on top of the list*/
        if(objDef.ShortCode__c != 'Custom'){
            map_ShortCodeName.put(objDef.ShortCode__c, objDef.Name);
            list_SShortCodeTemp.add(new SelectOption(objDef.ShortCode__c,objDef.ShortCode__c+' - '+objDef.Name)); 
        }
        if(objDef.ShortCode__c == 'Custom') 
            objOption = new SelectOption(objDef.ShortCode__c,objDef.ShortCode__c);
     }
     optionListShortCode.add(objOption);
     optionListShortCode.addAll(list_SShortCodeTemp);
     
     
     //From Attachment Data Definition Object
     for(DSR_Attachments_Definition__c objAttachDef : list_AttachDataDef)
     {

          optionListAttachmentType.add(new SelectOption(objAttachDef.AttachmentType__c,objAttachDef.AttachmentType__c));   
 
     }
   }
   private void SetprimaryDesignList()
   {
     optionListPrimaryDesign = new List<SelectOption>();
     //optionListPrimaryDesign.add(new SelectOption('', '- None -')); 
     
     for(DSR_SCE_Design__c obj:list_Designs)
     {
       optionListPrimaryDesign.add(new SelectOption(obj.name,obj.name)); 
     }
   }
   private void GetDataDefValues()
   {
     List<DSRDataDefinition__c>list_PickListVal = DSRUtility.GetDataDefinition('Design','Design General Background');
     map_description = new Map<string,string>();
     
     optionList = new List<SelectOption>();
     optionList.add(new SelectOption('', '- None -'));  
     for(DSRDataDefinition__c obj : list_PickListVal)
     {
       optionList.add(new SelectOption(obj.Header__c,obj.Header__c)); 
       map_description.put(obj.Header__c,obj.Description__c);
     }
     
     system.debug('+++list_PickListVal+++'+list_PickListVal);
     system.debug('+++map_description+++'+map_description);
   }
   public void Cancel()
   {
     blnParentDisable = false;
     ClearValues();
     dataDef = new DSR_Attachments_Definition__c();
     ArchBluePrintDef = new DSR_UseCase_BluePrint_Definition__c();
   }
   private void ClearValues()
    {
        /*Clear values*/
        strSelectedAttachmentType= '';
        strSelectedAccess= '';
        strSelectedSource= '';
        strURLReq = '';
    }
   
   /*public void saveFnUseCase()
   {
            blnParentDisable = false;
            blnShowErrorMsg_Popup = false;
            InsertFnUseCase();
            Init();  
                
   }*/
   public void InsertAndUpdateActivity()
   {
         blnParentDisable = false;
         blnShowErrorMsg_Popup = false;
        
       if(strSelectedAttachmentType == null || objDSRActivity.Description__c == null || objDSRActivity.DateofAttachment__c == null ||  (strSelectedAccess == null && !objSCE.DSR_SCEngagement__r.Is_Partner_DSR__c) || strSelectedSource == null ||(strURLReq == 'YES' && objDSRActivity.AttachmentURL__c == null))
       {
            blnShowErrorMsg_Popup = true;
            blnParentDisable = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please fill mandatory fields.'));
       }
       else
       {  
         
            objDSRActivity.ObjectType__c = 'Business Design Attachment';
            //objDSRActivity.SubModule__c = 'Design Specific Attachment';
            objDSRActivity.AttachmentType__c = strSelectedAttachmentType;
            objDSRActivity.DSRSCEDesign__c = objSCE.id;
            objDSRActivity.Access__c = strSelectedAccess;
            objDSRActivity.Source__c = strSelectedSource;
            objDSRActivity.DSRSCEngagement__c = objSCE.DSR_SCEngagement__c;
            //upsert objDSRActivity ;
            if(objDSRActivity.id == null)
            {
               insert objDSRActivity;
               
               /*Save Detail Change Description*/
               //SaveAttachment();
               
               /*Create History on Activity Creation*/
               SCEngagementDSRCtlr.CreateHistory('New activity created in Business Design',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objSCE.DSR_SCEngagement__c,null),objSCE.DSR_SCEngagement__r.AssignTo__c,objSCE.DSR_SCEngagement__r.SC_Engagement_Status__c,objSCE.DSR_SCEngagement__c);
            }
            else
              update objDSRActivity;
            Init();
            ClearValues();
       }
   }
   private void SaveAttachment()
   {
      if(fileBody != null && fileName != null)
      {
        Attachment obj = new Attachment();
        obj.Body = fileBody;
        obj.Name = fileName;       
        obj.ParentId = objDSRActivity.id;       
        //obj.Description = FileDescType ;
        insert obj;
      }
   }
   public void EditActivity()
   {
      blnParentDisable = true;
      checkMandatory = false; //added by priyank 15 Nov 2018
      //objDSRActivity = [Select id,Header__c,Description__c,AttachmentURL__c,ActivityDate__c,Access__c,Source__c,Notes__c,ShortChangeDescription__c  from DSR_Activity__c where id =: strVisionActId];
      
      objDSRActivity =  [Select id,Description__c,Access__c,AttachmentType__c,AttachmentURL__c,DateofAttachment__c,DSRSCEDesign__c,ObjectType__c,Source__c,Notes__c from DSR_Attachments__c where id =: strVisionActId];
      //strSelectedVisionType = objDSRActivity.Header__c; 
      strSelectedAccess = objDSRActivity.Access__c; 
      strSelectedSource = objDSRActivity.Source__c;
      strSelectedAttachmentType = objDSRActivity.AttachmentType__c;
      //Below query and if condition is added by priyank 15 Nov 2018
      List<DSR_Attachments_Definition__c> dsrAttacment = [select id,Description__c,AttachmentType__c,FullDescriptionURL__c,ObjectType__c,URLRequired__c, Notes__c from DSR_Attachments_Definition__c where ObjectType__c =: 'Business Design Attachment' and AttachmentType__c =: strSelectedAttachmentType and Active__c =: true LIMIT 1];
      if(dsrAttacment.size()>0){
           dataDef = dsrAttacment[0];
           System.debug('dataDef:' +dataDef);
           if(dsrAttacment[0].URLRequired__c){
              checkMandatory = true;
           }
      }
   }
   
   public void EditFnUseCase()
   {
      blnParentDisable = true;
      
      //objFnUseCase = [Select id,Fit__c,FitCategory__c,Header__c,Module__c,Notes__c,Source__c,SubModule__c,ShortCode__c,Description__c ,AttachmentURL__c,Version__c,ShortChangeDescription__c  from DSR_Activity__c where id =: strVisionActId];
      objFnUseCase = [select id,DetailedChangeDescription__c,DSRSCEDesign__c,DSRSCEngagement__c,Fit__c,FitCategory__c,Name__c,Notes__c,ShortChangeDescription__c,ShortCode__c,VersionUsed__c from DSR_Use_Case_Blueprints__c where  id =: strVisionActId];
      strSelectedFit = string.valueof(objFnUseCase.Fit__c);
      strSelectedFitCategory = objFnUseCase.FitCategory__c;
      strSelectedShortCode = objFnUseCase.ShortCode__c;
      strDescription = objFnUseCase.Name__c;
      Version = objFnUseCase.VersionUsed__c;
      List<DSR_UseCase_BluePrint_Definition__c> objArchBluePrintDef = [SELECT PublishedURL__c, AdditionalURL__c,Description__c, LatestVersion__c, Notes__c,
                                                                        Dateoflastrevision__c, Maturity_Model__c, Product_Category__c, ShortCode__c, Active__c FROM DSR_UseCase_BluePrint_Definition__c
                                                                        WHERE ShortCode__c =: strSelectedShortCode AND Type__c='Use Case' AND Active__c=: true LIMIT 1];
      if(objArchBluePrintDef.size()>0){
          ArchBluePrintDef = objArchBluePrintDef[0];
      } 
   }
   public void SaveAndUpdateFnUseCase()
   {
      blnParentDisable = false;
      blnShowErrorMsg_Popup = false;
      if(strSelectedShortCode == null || strSelectedFit == null || strSelectedFitCategory == null || (strSelectedFit != '100' && string.isBlank(objFnUseCase.ShortChangeDescription__c)))
      {
         blnShowErrorMsg_Popup = true;
         blnParentDisable = true;
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please fill mandatory fields.'));
      }
      /********* description field population commented on 27-April-18 shared by Debora Lane ************/
      else if(integer.valueof(strSelectedFit) < 100 && (objFnUseCase.ShortChangeDescription__c == null || objFnUseCase.ShortChangeDescription__c == ''))
      {
         blnShowErrorMsg_Popup = true;
         blnParentDisable = true;
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please fill short change description.'));
      }
      else
      {
          objFnUseCase.Fit__c = integer.valueof(strSelectedFit);
          objFnUseCase.FitCategory__c = strSelectedFitCategory;
          objFnUseCase.ShortCode__c = strSelectedShortCode;
          objFnUseCase.DSRSCEDesign__c = objSCE.id;
          objFnUseCase.DSRSCEngagement__c = objSCE.DSR_SCEngagement__c;
          objFnUseCase.Type__c = 'Use Case';
          objFnUseCase.Name__c = strDescription;
          objFnUseCase.VersionUsed__c = Version;
          if(strSelectedShortCode == 'Custom'){
              objFnUseCase.Name__c = strSelectedShortCode;
          }
          else{
              objFnUseCase.Name__c = map_ShortCodeName.get(strSelectedShortCode);
          }
            
          //upsert objFnUseCase;
          if(objFnUseCase.id == null)
          {
            insert objFnUseCase;
            /*Create History on Activity Creation*/
               SCEngagementDSRCtlr.CreateHistory('New Functional Use Case created',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objSCE.DSR_SCEngagement__c,null),objSCE.DSR_SCEngagement__r.AssignTo__c,objSCE.DSR_SCEngagement__r.SC_Engagement_Status__c,objSCE.DSR_SCEngagement__c);
          }
          else
            update objFnUseCase;
          
          Init();
          /*Update Business Profile*/
          UpdateBusinessProfile();
       }   
   }
   
   private void UpdateBusinessProfile()
   {
      /*Update Design for Business Design Profile*/
          /*Check Business Design Profile*/
             boolean isCustom = false;
             boolean isNonCustom = false;
             string sAllUseCases;
             for(DSR_Use_Case_Blueprints__c obj:list_FnUseCase)
             {
               //strBusinessDsgnProfile
               if(obj.ShortCode__c == 'Custom')
                 isCustom = true;
               if(obj.ShortCode__c != 'Custom')
                 isNonCustom = true; 
                 
                /********* description field population commented on 27-April-18 shared by Debora Lane ************/
               if(!objSCE.DSR_SCEngagement__r.Is_Partner_DSR__c)
               {
                   if(sAllUseCases == null)   
                    sAllUseCases = obj.ShortCode__c;
                   else
                    sAllUseCases += ',' + obj.ShortCode__c;  
               }   
             }
             
             if(isCustom && isNonCustom )
               strBusinessDsgnProfile = 'Hybrid';
             if(isCustom && !isNonCustom )
               strBusinessDsgnProfile = 'Custom';
             if(!isCustom && isNonCustom )
               strBusinessDsgnProfile = 'Smart';  
              
              objSCE.BusinessDesignProfile__c = strBusinessDsgnProfile;
              update objSCE;
              
               /********* description field population commented on 27-April-18 shared by Debora Lane ************/
              /************update all Short code in Opportunity **************/
              if(!objSCE.DSR_SCEngagement__r.Is_Partner_DSR__c && objOpp.StageName != '6.Closed')
              {
                objOpp.FunctionalUsecasesNumbers__c = sAllUseCases;
                update objOpp;
              }
   }
   /* private void InsertFnUseCase()
    {
        objDSRActivity.Module__c = 'Design';
        objDSRActivity.SubModule__c = 'Functional Use Case';
        //objDSRActivity.Header__c = strSelectedVisionType;
        objDSRActivity.DSRSCEDesign__c = objSCE.id;
        //objDSRActivity.Access__c = strSelectedAccess;
        //objDSRActivity.Source__c = strSelectedSource;
        upsert objDSRActivity ;
        
        ClearValues();
    }*/
   private void GetFnUseCase()
   {
     //list_FnUseCase = [Select id,Header__c,Description__c,AttachmentURL__c,ActivityDate__c,Access__c,Source__c,Notes__c,ShortCode__c,Fit__c,FitCategory__c,Version__c,ShortChangeDescription__c   from DSR_Activity__c where Module__c =: 'Design' and SubModule__c =: 'Functional Use Case' and DSRSCEDesign__c =:objSCE.id ORDER BY createddate DESC];
     list_FnUseCase = [select id,DetailedChangeDescription__c,DSRSCEDesign__c,DSRSCEngagement__c,Fit__c,FitCategory__c,Name__c,Notes__c,ShortChangeDescription__c,ShortCode__c,VersionUsed__c from DSR_Use_Case_Blueprints__c where  DSRSCEDesign__c =:objSCE.id  and Type__c =:'Use Case' ORDER BY createddate DESC];
   }
   public void AddAct()
   {
     blnParentDisable = true;
     objDSRActivity = new DSR_Attachments__c();
     objFnUseCase = new DSR_Use_Case_Blueprints__c();
     strSelectedFit = '';
     strSelectedFitCategory ='';
     strSelectedShortCode='';
     ClearValues();
   }
   public void AddDesign()
   {
     blnParentDisable = true;
     objFnUseCase = new DSR_Use_Case_Blueprints__c();
   }
   public void RemoveVisionActivity()
   {
     DSR_Attachments__c obj = [Select id from DSR_Attachments__c where id =:strVisionActId];
     delete obj;
     
     Init();
   }
   public void RemoveFnUseCase()
   {
     DSR_Use_Case_Blueprints__c obj = [Select id from DSR_Use_Case_Blueprints__c where id =:strFnId];
     delete obj;
     
     Init();
     UpdateBusinessProfile();
   }
   
   public void RemoveDesign()
   {
     DSR_SCE_Design__c  obj = [Select id from DSR_SCE_Design__c where id =:strDesignId];
     delete obj;
     Init();
     
   }
   public void SaveSCE()
   {
       update objSCE;
       dataDef = new DSR_Attachments_Definition__c();
   }
  
   private void GetAllAccess()
   {
     List<DSRDataDefinition__c>list_Access = [select id,SubModule__c,Header__c from DSRDataDefinition__c where Module__c =: 'Common' and IsActive__c =: true];
     Set<string> set_access = new Set<string>();
     optionListAccess = new List<SelectOption>();
     //Priyank added if else condition below to show the Access picklist set to internal only as discussed with JJ 31/10/2018.
     if(ObjSCE.DSR_SCEngagement__r.Is_Partner_DSR__c){
         optionListAccess.add(new SelectOption('', '- None -')); 
     }else{
         optionListAccess.add(new SelectOption('Internal Only', 'Internal Only'));
         set_access.add('Internal Only');
     }
     for(DSRDataDefinition__c obj : list_Access)
     {
         // Priyank added !set_access.contains(obj.header__c ) in below if condition to check duplicate value on picklist.
         if(obj.SubModule__c == 'Access' && !set_access.contains(obj.header__c )) 
           optionListAccess.add(new SelectOption(obj.Header__c,obj.Header__c));
        if(!set_access.contains(obj.SubModule__c))
       {  
          /*Bind Offer Type And Platform Type*/
         if(obj.SubModule__c == 'Offer Type')
           optionListOfferType.add(new SelectOption(obj.Header__c,obj.Header__c));
         if(obj.SubModule__c == 'Platform Type')
           optionListPlatformType.add(new SelectOption(obj.Header__c,obj.Header__c));  
         set_access.add(obj.SubModule__c);
       }  
     }
   }
   
   @RemoteAction
   global  static DSR_Attachments_Definition__c GetDescription(string strVisionType)
   {
     
      
      List<DSR_Attachments_Definition__c>list_PickListVal  = [select id,AttachmentType__c,Description__c,FullDescriptionURL__c,ObjectType__c,URLRequired__c,Notes__c from DSR_Attachments_Definition__c where ObjectType__c =: 'Business Design Attachment' and AttachmentType__c =: strVisionType and  Active__c =: true];
      return list_PickListVal[0];
   }
    @RemoteAction
   global static DSR_UseCase_BluePrint_Definition__c GetFitCategoryDtl(string strFitCategory, String offeringType)
   {
      
      //List<DSR_UseCase_BluePrint_Definition__c>list_DataDefFnUseCase = [select id,AdditionalURL__c,Dateoflastrevision__c,Description__c,LatestVersion__c,Name__c,PublishedURL__c,ShortCode__c,Type__c,Notes__c from DSR_UseCase_BluePrint_Definition__c where Type__c =:'Use Case' and ShortCode__c =: strFitCategory ];
      
      //Priyank commented the above query and added new query to check the offering typ as discussed with jj.
      List<DSR_UseCase_BluePrint_Definition__c>list_DataDefFnUseCase = new List<DSR_UseCase_BluePrint_Definition__c>([select id,AdditionalURL__c,Dateoflastrevision__c,Maturity_Model__c,Product_Category__c,Description__c,LatestVersion__c,Name__c,PublishedURL__c,ShortCode__c,Type__c,Notes__c from DSR_UseCase_BluePrint_Definition__c where Type__c =:'Use Case' and ShortCode__c =: strFitCategory AND Offer_Platform_Type__c =: offeringType]);
      //strDescription = list_PickListVal[0].Description__c;
      if(list_DataDefFnUseCase.size() > 0){
        //list_DataDefFnUseCase[0].Notes__c = '';
        return list_DataDefFnUseCase[0];
      }else{
        return new DSR_UseCase_BluePrint_Definition__c();
      }
   }

   public void GetAccessAndSource()
   {
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
   }
   @RemoteAction
   global static string FileURLinsert( Blob attachmentBody, String attachmentName, String parId)
   {
        
        Attachment atc = new Attachment();
        atc.body = attachmentBody;
        atc.Name = attachmentName;
        atc.ParentId = parId;
        atc.Description = 'BusinessDesign';
        insert atc;
        
        String URLs = URL.getSalesforceBaseUrl().toExternalForm() + '/partner/servlet/servlet.FileDownload?file=' + atc.Id;
        return URLs;
        /*system.debug('>>>>> ' + attachmentBody);
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
        return baseUrl;*/
   }
   
   public void UploadFile(){
        
        
        
   }
}