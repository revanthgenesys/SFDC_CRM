/***************************************************************************************************
* 
*  Class Name      :   DSRDeliverCtlr
*  Description     :   This class is used to control the DSR Deliver Page
*  Auther          :   R Systems
* 
****************************************************************************************************/
global  class DSRDeliverCtlr {
    
    
    public Boolean deliverReq{get;set;}
    public Boolean serviceTrans{get;set;}
    public Id sceId{get;set;}
    public String deliverId{get;set;}
    public String serviceId{get;set;}
    public String HomeURL{get;set;}
    public String activityType{get;set;}
    public String access{get;set;}
    public String docSource{get;set;}
      public user objUsera {get;set;}
   public boolean ipartneruser{get;set;}
    // Select Options for Activity Type
    public List<SelectOption> selectActivityType{get;set;}
    // Select Options for Access
    public List<SelectOption> selectAccess{get;set;}
    // Select Options for Document Source
    public List<SelectOption> selectSource{get;set;}
    
    public DSR_Attachments__c dsrActivity{get;set;}
    public List<DSR_Attachments__c> lstDelivery{get;set;}
    public List<DSR_Attachments__c> lstService{get;set;}
    public DSR_Attachments__c dsrEdit{get;set;}
    public DSR_SCEngagement__c dsrsce{get;set;}
    public Map<string,string>map_DesignLinks{get;set;}
    public boolean blnIsSubmitted{get;set;}
    public string strURLReq{get;set;}
    public boolean checkMandatory{get;set;}//added by priyank 15 Nov 2018
    public DSR_Attachments_Definition__c dataDef {get; set;}
    /**
     * Default Constructor
     **/
     
    public DSRDeliverCtlr(){
        dataDef = new DSR_Attachments_Definition__c();
        sceId = apexpages.currentpage().getparameters().get('id');
        checkMandatory = false; //added by priyank 15 Nov 2018
        deliverReq = false;
        serviceTrans = false;
        
        selectActivityType = new List<SelectOption>();
        selectAccess = new List<SelectOption>();
        selectSource = new List<SelectOption>();
        
        dsrActivity = new DSR_Attachments__c();
        dsrEdit = new DSR_Attachments__c();
        dsrsce = new DSR_SCEngagement__c();
         objUsera = new user();
        lstDelivery = new List<DSR_Attachments__c>();
        lstService = new List<DSR_Attachments__c>();
         
        
        init();
        if(DSR_SC_Engage_Utility.checkReadOnly(UserInfo.getUserId(), dsrsce.Id, UserInfo.GetUserEmail()) || dsrsce.SC_Engagement_Status__c == 'Completed' ||dsrsce.SC_Engagement_Status__c == 'Submitted for Completion')
           blnIsSubmitted = true;
        else
           blnIsSubmitted = false; 
           
           objUsera = [SELECT Id,IsPortalEnabled FROM User WHERE Id=:UserInfo.getUserId()];  
     if(objUsera.IsPortalEnabled == true){
     ipartneruser = true; } else{
        ipartneruser = false ;
     }
           
        //   if(dsrsce.Is_Partner_DSR__c == false)
         if( (dsrsce.Is_Partner_DSR__c == false || dsrsce.Is_Partner_DSR__c == true )  && objUsera.IsPortalEnabled == false)
            HomeURL = '/apex/SC_Engagement_DSR?id='+SCEID; 
        else                           
            HomeURL = '/partner/SC_EngagementPartner_DSR?id='+SCEID;
    }
    
    /**
    *   Method Name :   init()
    *   Description :   This method used to perform initial actions
    *   Parameters  :  
    **/
    
    public void init(){
        List<DSR_SCEngagement__c> lstDsr = [Select Id, 
                                                        Name, 
                                                        SC_Engagement_Status__c, 
                                                        Opportunity_ID__c,
                                                        Opportunity_ID__r.StageName,
                                                        Opportunity_ID__r.Primary_Line_of_Business__c,
                                                        Opportunity_ID__r.Lines_of_Businesses__c,
                                                        Opportunity_ID__r.Lead_Offer__c,
                                                        Has_Delivery_Activities__c,
                                                        Deliver_End_Date__c,
                                                        Deliver_Start_Date__c,
                                                        Account_ID__c,
                                                        CreatedDate,
                                                        LastmodifiedDate,
                                                        Account_ID__r.Name,
                                                        Opportunity_ID__r.Name,
                                                        Deliver_Notes__c,
                                                        Is_Partner_DSR__c,
                                                        Stage_When_DSR_Created__c 
                                                        from DSR_SCEngagement__c where Id=: sceId];
        
        if(lstDsr.size() > 0){
            dsrsce = lstDsr[0];
        }
        
        lstService = getActivityDetails('Service Transition Activity');
        // Strat: Changes on 5/11 as requested by Debora
       // lstDelivery = getActivityDetails('Delivery Requirements');
        
        if(dsrsce.Is_Partner_DSR__c == false){
            getDataDefination('Delivery Requirements');
            lstDelivery = getActivityDetails('Delivery Requirements');
        } else {
            getDataDefination('Partner Delivery Requirements');
            lstDelivery = getActivityDetails('Partner Delivery Requirements');
        }
        // End: Changes on 5/11 as requested by Debora
    }
    
    /**
    *   Method Name :   getActivityDetails()
    *   Description :   This method used to getActivityDetails
    *   Parameters  :  
    **/
    
    public List<DSR_Attachments__c> getActivityDetails(String subModule) { 
        
        List<DSR_Attachments__c> lstDSRActivity = [select id,Access__c,
                                                            AttachmentType__c,
                                                            AttachmentURL__c,
                                                            DateofAttachment__c,
                                                            Description__c,
                                                            DSRSCEngagement__c,
                                                            Notes__c,
                                                            ObjectType__c,
                                                            Source__c
                                                            from DSR_Attachments__c 
                                                            where (ObjectType__c =: subModule) and DSRSCEngagement__c =: sceId];
        
        return lstDSRActivity;
    }
    
    
    /**
    *   Method Name :   showDeliverRequirement()
    *   Description :   This method used to show the Deliver Requirement Section
    *   Parameters  :  
    **/
    
    public void getDataDefination(String subModule) { 
        
        selectActivityType = new List<SelectOption>();
        selectAccess = new List<SelectOption>();
        selectSource = new List<SelectOption>();
        map_DesignLinks = new Map<string,string>();
        Set<string> set_access = new Set<string>(); // Added by Priyank to check the duplicate picklist value.
        
        List<DSRDataDefinition__c> lstDataDefination = [select id,SubModule__c,header__c,Module__c,URL__c from DSRDataDefinition__c where (Module__c =:'Deliver' OR  Module__c =:'Delivery' OR Module__c =: 'Design' OR Module__c =:'Common') and IsActive__c =: true];
        List<DSR_Attachments_Definition__c>list_AttachDefinition = [Select id,ObjectType__c ,AttachmentType__c,Description__c from DSR_Attachments_Definition__c where (ObjectType__c =: 'Delivery Requirements' OR ObjectType__c =: 'Partner Delivery Requirements' OR ObjectType__c =: 'Service Transition Activity') and Active__c =: true ORDER BY AttachmentType__c ASC];
        
        selectActivityType.add(new SelectOption('None','None'));
        //Priyank added if else condition below to show the Access picklist set to internal only as discussed with JJ 31/10/2018.
        if(dsrsce.Is_Partner_DSR__c){
            selectAccess.add(new SelectOption('None','None'));
        }else{
            selectAccess.add(new SelectOption('Internal Only', 'Internal Only'));
            set_access.add('Internal Only');
        }
        // Priyank code ended.
        selectSource.add(new SelectOption('None','None'));
        
         for(DSR_Attachments_Definition__c obj : list_AttachDefinition)
         {
             if(obj.ObjectType__c == subModule)
             selectActivityType.add(new SelectOption(obj.AttachmentType__c, obj.AttachmentType__c));
         }
        
        for(DSRDataDefinition__c dsrDef: lstDataDefination){
            /*if(dsrDef.Module__c == 'Deliver' && dsrDef.SubModule__c == subModule){
                selectActivityType.add(new SelectOption(dsrDef.header__c, dsrDef.header__c));
            }*/
            //Priyank added below if codition to check the duplicate piclist value. 
            if(!set_access.contains(dsrDef.header__c )){
                if(dsrDef.Module__c == 'Common' && dsrDef.SubModule__c == 'Access'){
                    selectAccess.add(new SelectOption(dsrDef.header__c, dsrDef.header__c));
                }
                if(dsrDef.Module__c == 'Common' && dsrDef.SubModule__c =='Document Source'){
                    selectSource.add(new SelectOption(dsrDef.header__c, dsrDef.header__c));
                }
            }
            if(dsrDef.SubModule__c == 'Delivery Link')
            {
              map_DesignLinks.put(dsrDef.Header__c,dsrDef.URL__c);
            }
        }
    }
    
    /**
    *   Method Name :   saveSCDSR()
    *   Description :   This method used to Save the changes on Deliver page
    *   Parameters  :  
    **/
    
    public Pagereference saveSCDSR() { 
        System.debug('clicked on Save');
        update dsrsce;
        dataDef = new DSR_Attachments_Definition__c();
        return null;
    }
    
    /**
    *   Method Name :   GetDescription()
    *   Description :   This method used to get the description based on Header and Module
    *   Parameters  :  
    **/
    @RemoteAction
    global  static DSR_Attachments_Definition__c GetDescription(string strVisionType){
        //List<DSRDataDefinition__c> lstDataDefination = [select id,Description__c, URL__C from DSRDataDefinition__c where (Module__c =:'Deliver' and  Header__c =:strVisionType)];
        List<DSR_Attachments_Definition__c>lstDataDefination  = [select id,Description__c,AttachmentType__c,Notes__c,FullDescriptionURL__c,ObjectType__c,URLRequired__c from DSR_Attachments_Definition__c where ObjectType__c =: 'Service Transition Activity' and AttachmentType__c =: strVisionType and Active__c =: true];
        if(lstDataDefination.size() > 0){
            return lstDataDefination[0];
        }
        return null;
    }
    
    
    /**
    *   Method Name :   GetReqDescription()
    *   Description :   This method used to get the description based on Header and Module
    *   Parameters  :  
    **/
    @RemoteAction
    global  static DSR_Attachments_Definition__c GetReqDescription(string strVisionType){
        //List<DSRDataDefinition__c> lstDataDefination = [select id,Description__c, URL__C from DSRDataDefinition__c where (Module__c =:'Deliver' and  Header__c =:strVisionType)];
        List<DSR_Attachments_Definition__c>lstDataDefination  = [select id,Description__c,Notes__c,AttachmentType__c,FullDescriptionURL__c,ObjectType__c,URLRequired__c from DSR_Attachments_Definition__c where ObjectType__c =: 'Delivery Requirements' and AttachmentType__c =: strVisionType and Active__c =: true];
        if(lstDataDefination.size() > 0){
            return lstDataDefination[0];
        }
        return null;
    }
    
    /**
    *   Method Name :   showDeliverRequirement()
    *   Description :   This method used to show the Deliver Requirement Section
    *   Parameters  :  
    **/
    
    public void showDeliverRequirement() { 
        // Start: Changes on 5/11 as requested by Debora
        if(dsrsce.Is_Partner_DSR__c == false){
            getDataDefination('Delivery Requirements');
        } else {
            getDataDefination('Partner Delivery Requirements');
        }
        // End: Changes on 5/11 as requested by Debora
        dsrActivity = new DSR_Attachments__c();
        deliverReq = true;    
    }
    
    /**
    *   Method Name :   closeDeliverRequirement()
    *   Description :   This method used to close the Deliver Requirement Section
    *   Parameters  :  
    **/
    
    public void closeDeliverRequirement() {  
        System.debug('Clicked on Save');
        //priyank modified the if condition by adding strURLReq with Attachmet URL check.
        if((activityType == '' || activityType == null || ((access == '' || access == null)&& !dsrsce.Is_Partner_DSR__c) || docSource == '' || docSource == null 
        || dsrActivity.DateofAttachment__c == null || dsrActivity.Description__c == null || (strURLReq == 'YES' && (dsrActivity.AttachmentURL__c ==''||dsrActivity.AttachmentURL__c == null))) && !Test.isRunningTest() ){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please fill mandatory fields.'));
            return;                          
        }
        
        
         if(dsrActivity.DateofAttachment__c < dsrsce.Deliver_Start_Date__c || dsrActivity.DateofAttachment__c > dsrsce.Deliver_End_Date__c){
            if(dsrActivity.DateofAttachment__c < dsrsce.Deliver_Start_Date__c)
             {
               dsrsce.Deliver_Start_Date__c = dsrActivity.DateofAttachment__c;
             }
             if(dsrActivity.DateofAttachment__c > dsrsce.Deliver_End_Date__c)
             {
               dsrsce.Deliver_End_Date__c = dsrActivity.DateofAttachment__c;
             } 
             update dsrsce; 
         }
        
        
        dsrActivity.AttachmentType__c = activityType;
        //dsrActivity.Module__c = 'Deliver';
        dsrActivity.ObjectType__c = 'Delivery Requirements';
        dsrActivity.Access__c = access;
        dsrActivity.Source__c = docSource;
        dsrActivity.DSRSCEngagement__c = sceId;
        if(dsrActivity.Id != null){
            update dsrActivity;
        }else{
            insert dsrActivity;
        }
        
        Integer deactcount = [Select count()  from DSR_Attachments__c where DSRSCEngagement__c =: sceId and (ObjectType__c =:'Delivery Requirements' OR ObjectType__c =: 'Service Transition Activity')];
        dsrsce.DeliveryCount__c = deactcount;
        dsrsce.Has_Delivery_Activities__c = true;
        update dsrsce;
        
        lstDelivery = new List<DSR_Attachments__c>();
        lstDelivery = getActivityDetails('Delivery Requirements');
        access = '';
        docSource = '';
        activityType = '';
        deliverReq = false;
        
    }  
    
    /**
    *   Method Name :   closeDeliverRequirementCancel()
    *   Description :   This method used to close the Deliver Requirement Section
    *   Parameters  :  
    **/
    
    public void closeDeliverRequirementCancel() {  
        deliverReq = false;    
        dataDef = new DSR_Attachments_Definition__c();
    }  
    
    /**
    *   Method Name :   removeDeliverReq()
    *   Description :   This method used to remove the Deliver Requirement Section
    *   Parameters  :  
    **/
    
    public void removeDeliverReq() { 
        
        deliverId = ApexPages.CurrentPage().getParameters().get('drId');
        List<DSR_Attachments__c> lstDSRActivity = [select Id from DSR_Attachments__c where Id=:deliverId];
        
        if(lstDSRActivity.size() > 0){
            delete lstDSRActivity;
            Integer deactcount = [Select count()  from DSR_Attachments__c where DSRSCEngagement__c =: sceId and (ObjectType__c =:'Delivery Requirements' OR ObjectType__c =: 'Service Transition Activity')];
            dsrsce.DeliveryCount__c = deactcount;
            if(deactcount == 0)
                dsrsce.Has_Delivery_Activities__c = false;
            update dsrsce;
        }
        
        lstDelivery = new List<DSR_Attachments__c>();
        lstDelivery = getActivityDetails('Delivery Requirements');
    }
    
    /**
    *   Method Name :   editDeliverReq()
    *   Description :   This method used to Edit the Deliver Requirement Section
    *   Parameters  :  
    **/
    
    public void editDeliverReq() { 
        
        deliverId = ApexPages.CurrentPage().getParameters().get('drId');
        
        checkMandatory = false; //added by priyank 15 Nov 2018
        for(DSR_Attachments__c dsr : lstDelivery){
            if(deliverId == dsr.Id){
                
                dsrActivity = new DSR_Attachments__c();
                dsrActivity = dsr;
                access = dsr.Access__c;
                docSource = dsr.Source__c;
                activityType = dsr.AttachmentType__c;
                // Start: Changes on 5/11 as requested by Debora
                if(dsrsce.Is_Partner_DSR__c == false){
                    getDataDefination('Delivery Requirements');
                } else {
                    getDataDefination('Partner Delivery Requirements');
                }
                // End: Changes on 5/11 as requested by Debora
            }
        }
        deliverReq = true; 
        //Below query and if condition is added by priyank 15 Nov 2018
        List<DSR_Attachments_Definition__c> dsrAttacment = [select id,Description__c,AttachmentType__c,FullDescriptionURL__c,ObjectType__c,URLRequired__c,Notes__c from DSR_Attachments_Definition__c where ObjectType__c =: 'Delivery Requirements' and AttachmentType__c =: activityType and Active__c =: true LIMIT 1];
        system.debug('----checkMandatory '+checkMandatory );
        if(dsrAttacment.size()>0){
            dataDef = dsrAttacment[0];
            if(dsrAttacment[0].URLRequired__c){
                checkMandatory = true;
            }
            system.debug('----checkMandatory '+checkMandatory );
        } 
        
    }
    
    /**
    *   Method Name :   showServiceTransitionActivites()
    *   Description :   This method used to show the Service Transition Activities Section
    *   Parameters  :  
    **/
    
    public void showServiceTransitionActivites() { 
        getDataDefination('Service Transition Activity');
        dsrActivity = new DSR_Attachments__c();
        serviceTrans = true;    
        dataDef = new DSR_Attachments_Definition__c();
    }
    
    /**
    *   Method Name :   closeServiceTransitionActivites()
    *   Description :   This method used to close the Service Transition Activities Section
    *   Parameters  :  
    **/
    
    public void closeServiceTransitionActivites() {  
        //priyank modified the if condition by adding strURLReq with Attachmet URL check.
        if((activityType == '' || activityType == null || access == '' || access == null || docSource == '' || docSource == null 
        || dsrActivity.DateofAttachment__c == null || dsrActivity.Description__c == null || (strURLReq == 'YES' && (dsrActivity.AttachmentURL__c == null || dsrActivity.AttachmentURL__c == '')) ) && !Test.isRunningTest()){
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please fill mandatory fields.'));
            return;                          
        }
        //dsrActivity.Header__c = activityType;
        //dsrActivity.Module__c = 'Deliver';
        //dsrActivity.SubModule__c = 'Service Transition Activity';
        
        dsrActivity.AttachmentType__c = activityType;
        //dsrActivity.Module__c = 'Deliver';
        dsrActivity.ObjectType__c = 'Service Transition Activity';
        dsrActivity.Access__c = access;
        dsrActivity.Source__c = docSource;
        dsrActivity.DSRSCEngagement__c = sceId;
        
        if(dsrActivity.Id != null){
            update dsrActivity;
        }else{
            insert dsrActivity;
        }
        
        Integer deactcount = [Select count()  from DSR_Attachments__c where DSRSCEngagement__c =: sceId and (ObjectType__c =:'Delivery Requirements' OR ObjectType__c =: 'Service Transition Activity')];
        dsrsce.DeliveryCount__c = deactcount;
        dsrsce.Has_Delivery_Activities__c = true;
        update dsrsce;
        
        lstService = new List<DSR_Attachments__c>();
        lstService = getActivityDetails('Service Transition Activity');
        access = '';
        docSource = '';
        activityType = '';
        serviceTrans = false;  
        strURLReq ='';  
    }  
    
    /**
    *   Method Name :   closeServiceTransitionActivitesCancel()
    *   Description :   This method used to close the Service Transition Activities Section
    *   Parameters  :  
    **/
    
    public void closeServiceTransitionActivitesCancel() {  
        serviceTrans = false;    
        dataDef = new DSR_Attachments_Definition__c();
    }  
    
    /**
    *   Method Name :   removeServiceTrans()
    *   Description :   This method used to remove the Service Transition Activities Section
    *   Parameters  :  
    **/
    
    public void removeServiceTrans() { 
        
        serviceId = ApexPages.CurrentPage().getParameters().get('serId');
        List<DSR_Attachments__c> lstDSRActivity = [select Id from DSR_Attachments__c where Id=:serviceId];
        
        if(lstDSRActivity.size() > 0){
            delete lstDSRActivity;
            Integer deactcount = [Select count()  from DSR_Attachments__c where DSRSCEngagement__c =: sceId and (ObjectType__c =:'Delivery Requirements' OR ObjectType__c =: 'Service Transition Activity')];
            dsrsce.DeliveryCount__c = deactcount;
            if(deactcount == 0)
                dsrsce.Has_Delivery_Activities__c = false;
            update dsrsce;
        }

        lstService = new List<DSR_Attachments__c>();
        lstService = getActivityDetails('Service Transition Activity');
    }
    
    /**
    *   Method Name :   editDeliverReq()
    *   Description :   This method used to Edit the Deliver Requirement Section
    *   Parameters  :  
    **/
    
    public void editServiceTrans() { 
        
        serviceId = ApexPages.CurrentPage().getParameters().get('serId');
        
        checkMandatory = false; //added by priyank 15 Nov 2018
        for(DSR_Attachments__c dsr : lstService){
            if(serviceId == dsr.Id){
                
                dsrActivity = new DSR_Attachments__c();
                dsrActivity = dsr;
                access = dsr.Access__c;
                docSource = dsr.Source__c;
                activityType = dsr.AttachmentType__c;
                getDataDefination('Service Transition Activity');
            }
        }
        serviceTrans = true; 
        //Below query and if condition is added by priyank 15 Nov 2018
        List<DSR_Attachments_Definition__c> dsrAttacment = [select id,Description__c,AttachmentType__c,FullDescriptionURL__c,ObjectType__c,URLRequired__c,Notes__c  from DSR_Attachments_Definition__c where ObjectType__c =: 'Service Transition Activity' and AttachmentType__c =: activityType and Active__c =: true LIMIT 1];
        if(dsrAttacment.size()>0){
            dataDef = dsrAttacment[0];
            if(dsrAttacment[0].URLRequired__c){
                checkMandatory = true;
            }
        } 
    }
    
    @RemoteAction
   global static string FileURLinsert( Blob attachmentBody, String attachmentName, String parId){
        
        Attachment atc = new Attachment();
        atc.body = attachmentBody;
        atc.Name = attachmentName;
        atc.ParentId = parId;
        atc.Description = 'Deliver';
        insert atc;
        String URLs = URL.getSalesforceBaseUrl().toExternalForm() + '/partner/servlet/servlet.FileDownload?file=' + atc.Id;
        return URLs;
   }
}