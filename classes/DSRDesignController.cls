/***************************************************************************************************
* 
*  Class Name      :   DSRDesignController
*  Description     :   This class is used to save Design and Design activity in SC Engegement
*  Auther          :   R Systems
* 
****************************************************************************************************/
global class DSRDesignController{

   public string FileDescType{get;set;}
   public DSRDataDefinition__c objDataDefinition{get;set;}
   public DSR_Attachments__c objDSRActivity{get;set;}
   public List<SelectOption>optionList{get;set;}
   public string strSelectedVisionType{get;set;}
   public List<DSR_Attachments__c>list_VisionActivity{get;set;}
   public DSR_SCEngagement__c objSCE{get;set;}
   public user objUsera {get;set;}
   public boolean ipartneruser{get;set;}
   public string strVisionActId{get;set;}
   public string strDesignId{get;set;}
   public boolean blnHasVisionActivity{get;set;}
   global Map<string,string>map_description{get;set;}
   public string strSelectedDesc{get;set;}
   public Opportunity objOpp{get;set;}
   public String HomeURL{get;set;}
   public boolean VTSection_RO{get;set;}
   public boolean VTSection{get;set;}
   public List<SelectOption>optionListAccess{get;set;}
   public List<SelectOption>optionListSource{get;set;}
   public List<SelectOption>optionListOfferType{get;set;}
   public List<SelectOption>optionListPlatformType{get;set;}
   
   public List<SelectOption>optionListOfferPlatformType{get;set;}
   
   public List<SelectOption>optionListHAType{get;set;}
   public List<SelectOption>optionListDataCentre{get;set;}
   
   public string strSelectedAccess{get;set;}
   public string strSelectedSource{get;set;}
   public string strSelectedOffer{get;set;}
   public string strSelectedPlatform{get;set;}
   
   public string strSelectedOfferPlatformType{get;set;}
   
   public List<DSR_SCE_Design__c>list_Designs{get;set;}
   public boolean blnShowErrorMsg_Popup{get;set;}
   public boolean blnShowErrorMsg{get;set;}
   public ID SCEID{get;set;}
   public boolean blnParentDisable{get;set;}
   public DSR_SCE_Design__c objDesign{get;set;}
   public List<SelectOption>optionListPrimaryDesign{get;set;}
   public string strSelectedDesign{get;set;}
   public boolean blnIsSubmitted{get;set;}
   public Map<string,string>map_DesignLinks{get;set;}
   public string strHAType{get;set;}
   public string strDataCentre{get;set;}
   public boolean blnIsEdit{get;set;}
   public string strURLReq{get;set;}
   public boolean checkMandatory{get;set;}//added by priyank 15 Nov 2018
    public string offeringString{get;set;} 
   public DSR_Attachments_Definition__c dataDef {get; set;}
    
   /* constructor */
   public DSRDesignController()
   {
     dataDef = new DSR_Attachments_Definition__c();
     Id SCEID = apexpages.currentpage().getparameters().get('id');
     checkMandatory = false; //added by priyank 15 Nov 2018
     objSCE = new DSR_SCEngagement__c();
     objUsera = new user();
     objSCE = [select id,SC_Engagement_Status__c,AssignTo__c ,Has_Design_Activities__c,Design_Start_Date__c,Design_End_Date__c,Opportunity_ID__c,Is_Partner_DSR__c,Opportunity_ID__r.AccountId,Account_ID__c,name,Design_Notes__c,Opportunity_ID__r.Lines_of_Businesses__c from DSR_SCEngagement__c where id =:SCEID];
     objOpp = [Select id,Primary_Line_of_Business__c,Lines_of_Businesses__c,Stagename,Lead_Offer__c  from Opportunity where id=:objSCE.Opportunity_ID__c];
     objUsera = [SELECT Id,IsPortalEnabled FROM User WHERE Id=:UserInfo.getUserId()];  
     if(objUsera.IsPortalEnabled == true){
     ipartneruser = true; } else{
        ipartneruser = false ;
     }
     
     Init();
     
     if( (objSCE.Is_Partner_DSR__c == false || objSCE.Is_Partner_DSR__c == true )  && objUsera.IsPortalEnabled == false)
        HomeURL = '/apex/SC_Engagement_DSR?id='+SCEID; 
    else                           
        HomeURL = '/partner/SC_EngagementPartner_DSR?id='+SCEID;
   }
   
   private void Init()
   {
     if(DSR_SC_Engage_Utility.checkReadOnly(UserInfo.getUserId(), objSCE.Id, UserInfo.GetUserEmail()) || objSCE.SC_Engagement_Status__c == 'Completed' ||objSCE.SC_Engagement_Status__c == 'Submitted for Completion')
       blnIsSubmitted = true;
     else
       blnIsSubmitted = false; 
       
     strSelectedDesc ='';
     blnHasVisionActivity = false;
     blnShowErrorMsg_Popup =false;
     blnIsEdit = false;
     strURLReq = 'NO';
     objDSRActivity = new DSR_Attachments__c();
     list_VisionActivity = new List<DSR_Attachments__c>();
     objDesign = new DSR_SCE_Design__c();
     list_Designs = new List<DSR_SCE_Design__c>();
     optionListPrimaryDesign = new List<SelectOption>();
     optionListSource = new List<SelectOption>();
     optionListOfferType = new List<SelectOption>();
     optionListPlatformType = new List<SelectOption>();
     
     GetDataDefValues();
     GetVisionActivities();
     GetAllAccess();
     GetAccessAndSource();
     GetAllDesigns();
     //SetprimaryDesignList();
     DSRUtility.SetVisibility(objSCE,objOpp);
     
     VTSection_RO = false;//DSRUtility.VTSection_RO;
     VTSection = true;//DSRUtility.VTSection;
     
   }
   /*private void SetprimaryDesignList()
   {
     optionListPrimaryDesign = new List<SelectOption>();
     //optionListPrimaryDesign.add(new SelectOption('', '- None -')); 
     
     for(DSR_SCE_Design__c obj:list_Designs)
     {
       optionListPrimaryDesign.add(new SelectOption(obj.name,obj.name)); 
     }
   }*/
   private void GetDataDefValues()
   {
     //List<DSR_Attachments_Definition__c>list_AttachDataDef = [select id,OfferPlatformType__c,AttachmentType__c,Description__c,FullDescriptionURL__c,ObjectType__c,OfferingType__c,Platform__c,URLRequired__c from DSR_Attachments_Definition__c where ObjectType__c =: 'Business Design Attachment' and Active__c =: true];
     //List<DSRDataDefinition__c>list_PickListVal = DSRUtility.GetDataDefinition('Design','Design General Background');
     List<DSRDataDefinition__c>list_PickListVal  = [select id,Description__c,DSRType__c,Header__c,Module__c,OfferPlatformType__c,SubModule__c,URL__c from DSRDataDefinition__c where (Module__c =: 'Design' OR (Module__c =: 'Common' and SubModule__c =: 'Offer/Platform Type')) and IsActive__c =: true ];
     List<DSR_Attachments_Definition__c>list_AttachDefinition = [Select id,AttachmentType__c,Description__c from DSR_Attachments_Definition__c where ObjectType__c =: 'Design Activity' and Active__c =: true ORDER BY AttachmentType__c ASC];
     
     map_description = new Map<string,string>();
     map_DesignLinks = new Map<string,string>();
     
     optionList = new List<SelectOption>();
     optionListHAType = new List<SelectOption>();
     optionListDataCentre = new List<SelectOption>();
     optionListOfferPlatformType = new List<SelectOption>();
     
     optionList.add(new SelectOption('', '- None -'));  
     optionListHAType.add(new SelectOption('', '- None -')); 
     optionListDataCentre.add(new SelectOption('', '- None -'));   
     optionListOfferPlatformType.add(new SelectOption('', '- None -'));// added by Priyank 9 Nov 2018   
     
     for(DSR_Attachments_Definition__c obj : list_AttachDefinition)
     {
       optionList.add(new SelectOption(obj.AttachmentType__c,obj.AttachmentType__c)); 
       map_description.put(obj.AttachmentType__c,obj.Description__c);
     }
     system.debug('>>>>>>#####  '+list_PickListVal);
     for(DSRDataDefinition__c obj : list_PickListVal)
     {
       /*if(obj.SubModule__c == 'Design General Background')
       {
         optionList.add(new SelectOption(obj.Header__c,obj.Header__c)); 
         map_description.put(obj.Header__c,obj.Description__c);
       }*/
       
       if(obj.SubModule__c == 'Offer/Platform Type')
       {
         optionListOfferPlatformType.add(new selectOption(obj.Header__c,obj.Header__c));
       }
       if(obj.SubModule__c == 'Design Link')
       {
         map_DesignLinks.put(obj.Header__c,obj.URL__c);
       }
       // added by Priyank 9 Nov 2018 below if condition
       if(obj.OfferPlatformType__c == strSelectedOfferPlatformType){
           //Priyank added obj.OfferPlatformType__c == 'PureCloud' in below condition 1-Nov-2018.
           if(obj.SubModule__c == 'HA Type' && obj.OfferPlatformType__c == 'PureCloud')
           {
             //strHAType = obj.Header__c;
             optionListHAType.add(new SelectOption(obj.Header__c,obj.Header__c)); 
           }
           //Priyank added obj.OfferPlatformType__c == 'PureCloud' in below condition 1-Nov-2018.
           if(obj.SubModule__c == 'Data Centers' && obj.OfferPlatformType__c == 'PureCloud')
           {
             //strDataCentre = obj.Header__c;
             optionListDataCentre.add(new SelectOption(obj.Header__c,obj.Header__c));
           }
        }
     }
     
     system.debug('+++list_PickListVal+++'+list_PickListVal);
     system.debug('+++map_description+++'+map_description);
   }
   
   //Priyank added below method on 1-nov-2018.
   public void onChangePicklistValue(){
       optionListHAType = new List<SelectOption>();
       optionListDataCentre = new List<SelectOption>();
       List<DSRDataDefinition__c>list_PickListVal  = [select id,Description__c,DSRType__c,Header__c,Module__c,OfferPlatformType__c,SubModule__c,URL__c from DSRDataDefinition__c where Module__c =: 'Design' and OfferPlatformType__c =:strSelectedOfferPlatformType and IsActive__c =: true ];
       
       for(DSRDataDefinition__c obj : list_PickListVal){
           if(obj.SubModule__c == 'HA Type' && obj.OfferPlatformType__c == strSelectedOfferPlatformType)
           {
             //strHAType = obj.Header__c;
             optionListHAType.add(new SelectOption(obj.Header__c,obj.Header__c)); 
           }
           if(obj.SubModule__c == 'Data Centers' && obj.OfferPlatformType__c == strSelectedOfferPlatformType )
           {
               system.debug('>>> ####'+ obj);
             //strDataCentre = obj.Header__c;
             optionListDataCentre.add(new SelectOption(obj.Header__c,obj.Header__c));
           }
       }
   }
       
   public void Cancel()
   {
     blnParentDisable = false;
     ClearValues();
     dataDef = new DSR_Attachments_Definition__c();  
   }
   private void ClearValues()
    {
        /*Clear values*/
        strSelectedVisionType = '';
        strSelectedAccess = '';
        strSelectedSource = '';
        strURLReq = '';
    }
   private void GetAllDesigns()
   {
     
     list_Designs = [select id,name,name__c,Notes__c,PrimaryDesign__c,Design_Source__c,DSR_SCEngagement__c,IsPrimary__c,lastmodifieddate,createddate,OfferingPlatformType__c from DSR_SCE_Design__c where DSR_SCEngagement__c =: objSCE.id];
     strSelectedDesign ='';
     for(DSR_SCE_Design__c obj : list_Designs)
     {
       if(obj.IsPrimary__c)
         strSelectedDesign = obj.name__c;
     }
   }
   public void saveVisionActivity()
   {
         system.debug(LoggingLevel.INFO,'+++strSelectedAccess+++'+strSelectedAccess);
         system.debug(LoggingLevel.INFO,'+++strSelectedSource+++'+strSelectedSource);
         if(objDSRActivity.DateofAttachment__c < objSCE.Design_Start_Date__c|| objDSRActivity.DateofAttachment__c > objSCE.Design_End_Date__c){
            //blnShowErrorMsg_Popup = true;
            //blnParentDisable = true;
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Activity date should be between Start and End Date.'));
            blnParentDisable = false;
            blnShowErrorMsg_Popup = false;
            
             if(objDSRActivity.DateofAttachment__c < objSCE.Design_Start_Date__c)
             {
               objSCE.Design_Start_Date__c = objDSRActivity.DateofAttachment__c;
             }
             if(objDSRActivity.DateofAttachment__c > objSCE.Design_End_Date__c)
             {
               objSCE.Design_End_Date__c = objDSRActivity.DateofAttachment__c;
             } 
             update objSCE; 
             InsertVisionActivity();
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
               objSCE.DesignCount__c = list_VisionActivity.size();
             }
             else
               objSCE.DesignCount__c = 0;  
               
             objSCE.Has_Design_Activities__c = blnHasVisionActivity;*/
             // Priyank commented the update command as InsertVisionActivity() method is updating the objSCE in UpdateActivityCount() method.
             //update objSCE;
             Init();  
             dataDef = new DSR_Attachments_Definition__c();
         }       
   }
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
      List<DSR_Attachments_Definition__c> dsrAttacment = [select id,Description__c,AttachmentType__c,FullDescriptionURL__c,ObjectType__c,URLRequired__c, Notes__c from DSR_Attachments_Definition__c where ObjectType__c =: 'Design Activity' and AttachmentType__c =: strSelectedVisionType and Active__c =: true LIMIT 1];
       if(dsrAttacment.size()>0){
           dataDef = dsrAttacment[0];
           if(dsrAttacment[0].URLRequired__c){
               checkMandatory = true;
           }
      }
   }
   public void EditDesign()
   {
      blnParentDisable = true;
      blnIsEdit = true;
      optionListHAType = new List<SelectOption>();
      optionListDataCentre = new List<SelectOption>();
      objDesign = [Select id,name,Notes__c,PrimaryDesign__c,HAType__c,DataCenters__c,Design_Source__c,DSR_SCEngagement__c,IsPrimary__c,lastmodifieddate,createddate,Name__c,OfferingPlatformType__c from DSR_SCE_Design__c where id =: strDesignId];
      strSelectedOfferPlatformType = objDesign.OfferingPlatformType__c;
      strHAType = objDesign.HAType__c;
      strDataCentre = objDesign.DataCenters__c;
      // added by Priyank 9 Nov 2018 added below code.
      List<DSRDataDefinition__c>list_PickListVal  = [select id,Description__c,DSRType__c,Header__c,Module__c,OfferPlatformType__c,SubModule__c,URL__c from DSRDataDefinition__c where Module__c =: 'Design' and OfferPlatformType__c =:strSelectedOfferPlatformType and IsActive__c =: true ];
       system.debug('list_PickListVal ------  '+list_PickListVal  );
       for(DSRDataDefinition__c obj : list_PickListVal){
           if(obj.SubModule__c == 'HA Type' && obj.OfferPlatformType__c == strSelectedOfferPlatformType)
           {
             //strHAType = obj.Header__c;
             optionListHAType.add(new SelectOption(obj.Header__c,obj.Header__c)); 
           }
           if(obj.SubModule__c == 'Data Centers' && obj.OfferPlatformType__c == strSelectedOfferPlatformType )
           {
               system.debug('>>> ####'+ obj);
             //strDataCentre = obj.Header__c;
             optionListDataCentre.add(new SelectOption(obj.Header__c,obj.Header__c));
           }
       }
    //// Ended code by Priyank 9 Nov 2018
   }
   public void SaveAndUpdateDesign()
   {
      if(strHAType == null || strDataCentre == null)
      {

            blnShowErrorMsg_Popup = true;
            blnParentDisable = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please fill mandatory fields.'));
        
      }
      else{
      
              blnParentDisable = false;
              blnShowErrorMsg_Popup = false;
              //objDesign.DSR_SCEngagement__c = objSCE.id;
              objDesign.OfferingPlatformType__c = strSelectedOfferPlatformType;
              
              objDesign.HAType__c = strHAType;
              objDesign.DataCenters__c = strDataCentre;
              
              //upsert objDesign;
              if(objDesign.id == null)
              {
                   objDesign.DSR_SCEngagement__c = objSCE.id;  
                   insert objDesign;
                 
                 /*Create History on Activity Creation*/
                   SCEngagementDSRCtlr.CreateHistory('New Design created',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objSCE.Id,null),objSCE.AssignTo__c,objSCE.SC_Engagement_Status__c,objSCE.Id);
                  
                  blnHasVisionActivity = true;
                   
                   if(list_Designs != null && list_Designs.size()>0)
                     {
                       
                       objSCE.DesignCount__c = list_Designs.size() + 1;
                     }
                     else
                       objSCE.DesignCount__c = 1;  
                       
                     objSCE.Has_Design_Activities__c = blnHasVisionActivity;
                     if(objDesign.IsPrimary__c){
                         objSCE.Primary_Design_ID__c = objDesign.id;
                     }
                     update objSCE;
              }
              else
                update objDesign;
                
              /*Update isPrimary for rest designs*/
              List<DSR_SCE_Design__c>lst_New = new List<DSR_SCE_Design__c>();
              if(objDesign.IsPrimary__c)
              {
                 for(DSR_SCE_Design__c obj : list_Designs)
                 {
                   if(obj.id != objDesign.id)
                   {
                     obj.IsPrimary__c = false;
                     lst_New.add(obj);
                   }
                     
                 }
                 system.debug('+++list_Designs+++'+list_Designs);
                 if(lst_New != null && lst_New.size()>0)
                   update lst_New;
                   
                 /*Update SC Engagement field for Primary Design*/  
                 objSCE.Primary_Design_ID__c = objDesign.id;
                 update objSCE;
              }
              Init();
              
      }
   }
    private void InsertVisionActivity()
    {
        //objDSRActivity.Module__c = 'Design';
        objDSRActivity.ObjectType__c = 'Design Activity';
        objDSRActivity.AttachmentType__c = strSelectedVisionType;
        objDSRActivity.DSRSCEngagement__c = objSCE.id;
        objDSRActivity.Access__c = strSelectedAccess;
        objDSRActivity.Source__c = strSelectedSource;
        //upsert objDSRActivity ;
        if(objDSRActivity.id == null)
        {
           insert objDSRActivity;
           /*Create History on Activity Creation*/
           SCEngagementDSRCtlr.CreateHistory('Activity created on Design',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),objSCE.Id,null),objSCE.AssignTo__c,objSCE.SC_Engagement_Status__c,objSCE.Id);
          
           /*blnHasVisionActivity = true;
           
           if(list_VisionActivity != null && list_VisionActivity.size()>0)
             {
               
               objSCE.DesignCount__c = list_VisionActivity.size() + 1;
             }
             else
               objSCE.DesignCount__c = 1;  
               
             objSCE.Has_Design_Activities__c = blnHasVisionActivity;
             update objSCE;*/
        }
        else
          update objDSRActivity;
        
        //Update Design Activity counts and flag, added by JJ on 03/6/18
        UpdateActivityCount(objSCE.id,'Design Activity');
        
        ClearValues();
    }
   private void GetVisionActivities()
   {
     //list_VisionActivity = [Select id,Header__c,Description__c,AttachmentURL__c,ActivityDate__c,Access__c,Source__c,Notes__c from DSR_Activity__c where Module__c =: 'Design' and SubModule__c =: 'Design Activity' and SCEID__c =:objSCE.id ORDER BY createddate DESC];
     list_VisionActivity = [Select id,Access__c,AttachmentType__c,AttachmentURL__c,DateofAttachment__c,Description__c,DSRSCEngagement__c,ObjectType__c,Source__c,Notes__c  from DSR_Attachments__c where ObjectType__c =: 'Design Activity' and DSRSCEngagement__c =:objSCE.id ORDER BY createddate DESC];
   }
   public void AddAct()
   {
     blnParentDisable = true;
     strURLReq = 'NO';
     objDSRActivity = new DSR_Attachments__c();
   }
   public void AddDesign()
   {
     blnParentDisable = true;
     blnIsEdit = false;
     objDesign = new DSR_SCE_Design__c();
     if(list_Designs == null || list_Designs.size()<=0)
       objDesign.IsPrimary__c = true;
   }
   public void RemoveVisionActivity()
   {
     //DSR_Activity__c obj = [Select id from DSR_Activity__c where id =:strVisionActId];
     DSR_Attachments__c obj = [Select id from DSR_Attachments__c where id =:strVisionActId];
     delete obj;
     
     //Update Design Activity counts and flag, added by JJ on 03/6/18
     UpdateActivityCount(objSCE.id,'Design Activity');
     
     Init();
     
     /*if(list_VisionActivity != null && list_VisionActivity.size()>0)
     {
       blnHasVisionActivity = true;
       objSCE.DesignCount__c = list_VisionActivity.size();
     }
     else
       objSCE.DesignCount__c = 0;  
           
      objSCE.Has_Design_Activities__c= blnHasVisionActivity;
      update objSCE; */
   }
   
   public void RemoveDesign()
   {
     DSR_SCE_Design__c  obj = [Select id from DSR_SCE_Design__c where id =:strDesignId];
     delete obj;
     Init();
     
     if(list_Designs != null && list_Designs.size()>0)
     {
       blnHasVisionActivity = true;
       objSCE.DesignCount__c = list_Designs.size();
     }
     else
       objSCE.DesignCount__c = 0;  
           
      objSCE.Has_Design_Activities__c= blnHasVisionActivity;
      update objSCE;
   }
   public void SaveSCE()
   {
     
     //objSCE.Has_Vision_Activities__c = blnHasVisionActivity;   
    // CheckStartAndEndDate();
     /* If end date and start changes on Vision then checks All activities date .It should be between these date range.*/
     if(list_VisionActivity != null && list_VisionActivity.size()>0)
     {
       for(DSR_Attachments__c obj : list_VisionActivity)
       {
         if(obj.DateofAttachment__c > objSCE.Design_End_Date__c || obj.DateofAttachment__c < objSCE.Design_Start_Date__c){
           blnShowErrorMsg = true;
           ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'All activity date should be between Start and End Date.'));
           return;
         }
       }
     }
     
     if(objSCE.Design_End_Date__c <= objSCE.Design_Start_Date__c){
       blnShowErrorMsg = true;
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'End date should be greater then Start Date.'));
       return;
      }
     
       update objSCE;
   }
    private void CheckStartAndEndDate()
   {
     
     
   }
   private void GetAllAccess()
   {
     List<DSRDataDefinition__c>list_Access = [select id,SubModule__c,Header__c from DSRDataDefinition__c where Module__c =: 'Common' and SubModule__c =: 'Access' and IsActive__c =: true];
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
       //if(!set_access.contains(obj.SubModule__c))
       //{
       //Priyank added below if to check the duplicate value in picklist.
       if(!set_access.contains(obj.header__c )){
           optionListAccess.add(new SelectOption(obj.Header__c,obj.Header__c));
       } 
          /*Bind Offer Type And Platform Type
         if(obj.SubModule__c == 'Offer Type')
           optionListOfferType.add(new SelectOption(obj.Header__c,obj.Header__c));
         if(obj.SubModule__c == 'Platform Type')
           optionListPlatformType.add(new SelectOption(obj.Header__c,obj.Header__c)); */ 
           
        // set_access.add(obj.SubModule__c);
       //}  
     } 
   }
   
   @RemoteAction
   global  static DSR_Attachments_Definition__c GetDescription(string strVisionType)
   {
      //List<DSRDataDefinition__c>list_PickListVal =  [select id,URL__c,Description__c,DSRType__c,Header__c,Module__c,OfferPlatformType__c,SubModule__c,URL_Required__c from DSRDataDefinition__c where Module__c =:'Design'and SubModule__c =: 'Design General Background' and Header__c =: strVisionType and IsActive__c =: true];
      List<DSR_Attachments_Definition__c>list_PickListVal  = [select id,Description__c,Notes__c,AttachmentType__c,FullDescriptionURL__c,ObjectType__c,URLRequired__c from DSR_Attachments_Definition__c where ObjectType__c =: 'Design Activity' and AttachmentType__c =: strVisionType and Active__c =: true];
      return list_PickListVal[0];
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
   
   //Update Design Activity Count on Activity Add/Remove
   public void UpdateActivityCount(id SCEID, string ActivityType)
   {
       //AggregateResult objCount= [select count(id) from DSR_Attachments__C where ObjectType__c =: ActivityType and DSRSCEngagement__c =: SCEID];
       // Priyank commented the above query and below if condition and added new query at Line 516 and if condition at Line 524 to 527.
       Integer objCount= [select count() from DSR_Attachments__C where ObjectType__c =: ActivityType and DSRSCEngagement__c =: SCEID];
       DSR_SCEngagement__c objSCE = [select id, Has_Design_Activities__c, DesignCount__c from DSR_SCEngagement__c where ID =: SCEID];

       /*if(objCount != null)
       {
           objSCE.Has_Design_Activities__c = true;
           objSCE.DesignCount__c = (integer)objCount.get('expr0'); 
       }*/
       if(objCount != null && objCount != 0){
           objSCE.Has_Design_Activities__c = true;
           objSCE.DesignCount__c = objCount;
       }
       else
       {
       
           objSCE.Has_Design_Activities__c = false;
           objSCE.DesignCount__c = 0; 
       } 
       
       update objSCE;   
   }
   
   @RemoteAction
   global static string FileURLinsert( Blob attachmentBody, String attachmentName, String parId){
        
        Attachment atc = new Attachment();
        atc.body = attachmentBody;
        atc.Name = attachmentName;
        atc.ParentId = parId;
        atc.Description = 'Design';
        insert atc;
       
        String URLs = URL.getSalesforceBaseUrl().toExternalForm() + '/partner/servlet/servlet.FileDownload?file=' + atc.Id;
        return URLs;
   }
   
}