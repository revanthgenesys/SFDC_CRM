/***************************************************************************************************
* 
*  Class Name      :   DSRSolutioOverviewCtlr
*  Description     :   This class is used to control the Solution Overview Page
*  Auther          :   R Systems
* 
****************************************************************************************************/
public without sharing class DSRSolutioOverviewCtlr{
    
    public DSR_SCEngagement__c dsrEngagement{get;set;}
    public DSR_SC_Engagement_History__c dsrEngagementSC{get;set;}
    public String sceId{get;set;}
    public List<DSR_Attachments__c> lstDSRActivity{get;set;}
    public Boolean myself{get;set;}
    public Boolean aeUser{get;set;}
    public Boolean leader{get;set;}
    public Boolean VTUser{get;set;}
    public String ownerName{get;set;}
    public String msg{get;set;}
    public Boolean isPrimaryDesign{get;set;}
    public Boolean istemplateAvailable{get;set;}
    
    public List<clsWrapperVisionOptions> lstclsWrapperVisionOptions{get;set;}
    public List<clsWrapperDesignOptions> lstclsWrapperDesignOptions{get;set;}
    public List<clsWrapperDiscoveryOptions> lstclsWrapperDiscoveryOptions{get;set;}
    public List<clsWrapperDeliverOptions> lstclsWrapperDeliverOptions{get;set;}
    public List<DSRDataDefinition__c> lstDefination{get;set;}
    public clsWrapperDesign lstclsWrapperDesign{get;set;}
    public List<DSR_Virtual_Team__c> lstDSRVirtualTeamRegion{get;set;}
    public List<DSR_Virtual_Team__c> lstDSRVirtualTeamVT{get;set;}
    
    // Select Options for Activity Type
    public List<SelectOption> selectRegion{get;set;}
    public List<SelectOption> selectLanguage{get;set;}
    public List<SelectOption> selectGeneration{get;set;}
    public List<SelectOption> selectTemplate{get;set;}
    
    public String region{get;set;}
    public String language{get;set;}
    public String generation{get;set;}
    public String template{get;set;}
    
    Public string resp{get;set;}
    
    public Map<string,string>map_OverviewLinks{get;set;}
    
    /**
     * Default Constructor
     **/
     
    public DSRSolutioOverviewCtlr(){
        
        myself = true;
        aeUser = false;
        leader = false;
        VTUser = false;
        istemplateAvailable = false;
        ownerName = Userinfo.getUserEmail();
        sceId = ApexPages.CurrentPage().getParameters().get('id');
        
        List<DSR_Attachments__c> lstDSRActivity = new List<DSR_Attachments__c>();
        
        lstclsWrapperVisionOptions = new List<clsWrapperVisionOptions>();
        lstclsWrapperDesignOptions = new List<clsWrapperDesignOptions>();
        lstclsWrapperDiscoveryOptions = new List<clsWrapperDiscoveryOptions>();
        lstclsWrapperDeliverOptions = new List<clsWrapperDeliverOptions>();
        lstDefination = new List<DSRDataDefinition__c>();
        lstclsWrapperDesign =  new clsWrapperDesign();
        lstDSRVirtualTeamVT = new List<DSR_Virtual_Team__c>();
        lstDSRVirtualTeamRegion = new List<DSR_Virtual_Team__c>();
        selectRegion = new List<SelectOption>();
        selectLanguage = new List<SelectOption>();
        selectGeneration = new List<SelectOption>();
        selectTemplate = new List<SelectOption>();
        dsrEngagementSC  = new DSR_SC_Engagement_History__c();
        
        init();
    }
    
    /**
    *   Method Name :   init()
    *   Description :   This method used to perform initial actions
    *   Parameters  :  
    **/
    
    public void init(){
        
        List<DSR_SCEngagement__c> lstDsr = [Select Id, 
                                                        Name, 
                                                        AE_Name__r.Email, 
                                                        AE_Name__c,
                                                        AE_Name__r.Name,
                                                        SC_Engagement_Status__c, 
                                                        Opportunity_ID__c,
                                                        Opportunity_ID__r.Name,
                                                        Opportunity_ID__r.StageName
                                                        from DSR_SCEngagement__c where Id=: sceId];
    
        if(lstDsr.size() > 0){
            dsrEngagement = lstDsr[0];
            List<DSR_SC_Engagement_History__c> lstSC = [Select Id, ActionPerformedBy__c from DSR_SC_Engagement_History__c where DSRSCEngagement__c=:sceId limit 1 ];
            if(lstSC.size() > 0){
                dsrEngagementSC = lstSC[0];
            }
            dsrEngagementSC.ActionPerformedBy__c = Userinfo.getUserId();
        }
        
        /*lstDSRActivity  = [Select Id, 
                                Access__c,
                                Header__c,
                                Module__c,
                                SCEID__c    
                                from DSR_Activity__c 
                                where SCEID__c =:sceId];*/
                                
    lstDSRActivity = [Select id,Access__c,AttachmentType__c,AttachmentURL__c,DateofAttachment__c,Description__c,DSRSCEngagement__c,Notes__c,Source__c,ObjectType__c from DSR_Attachments__c where DSRSCEngagement__c =: sceId];                       
        
        for(DSR_Attachments__c dsrAct : lstDSRActivity){
            if(dsrAct.ObjectType__c == 'Vision Activity'){
                clsWrapperVisionOptions clswrap = new clsWrapperVisionOptions();
                clswrap.name = dsrAct.AttachmentType__c;
                clswrap.id = dsrAct.Id;
                lstclsWrapperVisionOptions.add(clswrap);
            }else if(dsrAct.ObjectType__c == 'Delivery Requirements' || dsrAct.ObjectType__c == 'Service Transition Activity'){
                clsWrapperDeliverOptions clswrap = new clsWrapperDeliverOptions();
                clswrap.name = dsrAct.AttachmentType__c;
                clswrap.id = dsrAct.Id;
                lstclsWrapperDeliverOptions.add(clswrap);
            }else if(dsrAct.ObjectType__c == 'Design Activity'){
                clsWrapperDesignOptions clswrap = new clsWrapperDesignOptions();
                clswrap.name = dsrAct.AttachmentType__c;
                clswrap.id = dsrAct.Id;
                lstclsWrapperDesignOptions.add(clswrap);
            }else if(dsrAct.ObjectType__c == 'Discovery Activity'){
                clsWrapperDiscoveryOptions clswrap = new clsWrapperDiscoveryOptions();
                clswrap.name = dsrAct.AttachmentType__c;
                clswrap.id = dsrAct.Id;
                lstclsWrapperDiscoveryOptions.add(clswrap);
            }
        }
        
        
        // Creation Options
        Set<String> setString = new Set<String>();
        setString.add('Language');
        setString.add('Generation Mode');
        setString.add('Template');
        setString.add('Region/Sub Region');
        
        selectLanguage.add(new SelectOption('None','None'));
        selectRegion.add(new SelectOption('None','None'));
        selectGeneration.add(new SelectOption('None','None'));
        selectTemplate.add(new SelectOption('None','None'));
        map_OverviewLinks = new Map<string,string>();
        
        lstDefination = [Select Id, Header__c, Module__c, SubModule__C,URL__c  from DSRDataDefinition__c where (Module__c=:'Common' or Module__c=:'Overview') and (SubModule__c In :setString or SubModule__c =:'Overview Link') ORDER BY CreatedDate ASC];
        
        if(lstDefination.size() > 0){
            
            for(DSRDataDefinition__c dsr : lstDefination){
                if(dsr.SubModule__c == 'Language'){
                    selectLanguage.add(new SelectOption(dsr.Header__c ,dsr.Header__c));
                }else if(dsr.SubModule__c == 'Generation Mode'){
                    selectGeneration.add(new SelectOption(dsr.Header__c,dsr.Header__c));
                }else if(dsr.SubModule__c == 'Template'){
                    //selectTemplate.add(new SelectOption(dsr.Header__c,dsr.Header__c));
                }else if(dsr.SubModule__c == 'Region/Sub Region'){
                    selectRegion.add(new SelectOption(dsr.Header__c,dsr.Header__c));
                }
                
                if(dsr.SubModule__c == 'Overview Link')
                {
                  map_OverviewLinks.put(dsr.Header__c,dsr.URL__c);
                }
            }
        }
        
        // Design Options
        
        List<DSR_SCE_Design__c> lstDesign = [Select Id, Name, Name__c,IsPrimary__c from DSR_SCE_Design__c where IsPrimary__c=:true and DSR_SCEngagement__c =:sceId];
        
        isPrimaryDesign = false;
        for(DSR_SCE_Design__c dsr : lstDesign){
            if(dsr.IsPrimary__c){
                isPrimaryDesign = true;
                lstclsWrapperDesign =  new clsWrapperDesign();
                lstclsWrapperDesign.Name = dsr.Name__c;
                lstclsWrapperDesign.Id = dsr.Id;
                lstclsWrapperDesign.cName = dsr.name;
            }
        }
        

        
        if(!isPrimaryDesign)
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'This DSR does not have a primary design.  In order to create a Solution Overview document, the DSR must have a primary design with identified use cases and architectures!!'));
        
        
        lstDSRVirtualTeamRegion = [Select Id,   Virtual_Team_Member_Name__c,
                                                Virtual_Team_Member_Name__r.Email
                                                from DSR_Virtual_Team__c
                                                where SCE_ID__c =:sceId
                                                and Virtual_User_Role__c =:'Sub Regional Leader'];
                                                
        lstDSRVirtualTeamVT = [Select Id,   Virtual_Team_Member_Name__c,
                                                Virtual_Team_Member_Name__r.Email 
                                                from DSR_Virtual_Team__c
                                                where SCE_ID__c =:sceId
                                                and Virtual_User_Role__c =:'Virtual Team'];
    
      populateTemplate();
    }
    
    /**
    *   Method Name     :   clsWrapperVisionOptions()
    *   Description     :   This class is used to post the solution Overview.
    *   Parameters      :  
    **/
    
    public void populateTemplate(){
        
        List<DSRDataDefinition__c> lstDsrSOAPTEMPLATE = [Select Id, DSRType__c, Header__c, SubModule__c, Module__c from DSRDataDefinition__c where Module__c=:'Common' and SubModule__c=:'SOC Template Name API'];
        
        try{
            if(lstDsrSOAPTEMPLATE.size() > 0 ){
            
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                    gen.writeFieldName('template_options');
                        gen.writeStartObject();
                        gen.writeStringField('template_type', 'solutionoverview');
                    gen.writeEndObject();
                
                    gen.writeFieldName('requester');
                        gen.writeStartObject();
                        gen.writeStringField('application_type', 'scedsr_webform');
                        gen.writeStringField('application_name', 'SCE DSR 2.0 - Salesforce WebForm');
                        gen.writeStringField('fullname', UserInfo.getName());
                        gen.writeStringField('email', UserInfo.getUserEmail());
                    gen.writeEndObject();
                gen.writeEndObject();
                
                String pretty = gen.getAsString();
    
                system.debug('#Pretty -'+pretty);
                resp = pretty;
                
                // Create HTTP call Out
                Http objhttp = new Http();
                // Create HTTP Request
                HttpRequest req = new HttpRequest();
                // Create HTTP Response
                HttpResponse res = new HttpResponse();
                // Set Method
                req.setMethod('POST'); 
                // Set Endpoint
                req.setEndpoint(lstDsrSOAPTEMPLATE[0].Header__c);
                
                req.setHeader('Content-Type', 'application/json');
                // Set request Body
                req.setBody(pretty);
                // Set Timeout
                req.setTimeout(120000);
                
                // Send HTTP Request and get Response
                if(!Test.isRunningTest())
                    res = objhttp.send(req);
                
                system.debug('Resp  =  '+ res.getBody());
                //resp = res.getBody();
                
                fromJSON temp = (fromJSON)JSON.deserialize(res.getBody(), fromJSON.class);
                
                system.debug('temp  =  '+ temp);
                            //selectTemplate = new List<SelectOption>();
                //selectTemplate.add(new SelectOption('None','None'));
                if(temp != null && temp.templates != null && temp.templates.size() > 0){
                    for(cls_templates clstmp : temp.templates){
                        selectTemplate.add(new SelectOption(clstmp.name, clstmp.name));
                    }
                }else{
                     istemplateAvailable =true;
                     ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Templates are not availble.'));
                }
            }
        }catch( exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Templates are not availble.'));
        }
   }
    
    public void postSolutionOverview(){
        
        try{
            List<DSRDataDefinition__c> lstDsrSOAPAPI = [Select Id, DSRType__c, Header__c, SubModule__c, Module__c from DSRDataDefinition__c where Module__c=:'Common' and SubModule__c=:'SOC API'];
            
            List<User> scUser = [Select Firstname, Lastname, Id from User where Id=:dsrEngagementSC.ActionPerformedBy__c];
            
            String scUsername = '';
            
            if(scUser.size() > 0){
                scUsername = scUser[0].Firstname + ' ' +  scUser[0].Lastname ; 
            }
            
            List<User> aeUser = [Select Firstname, Lastname, Id from User where Id=:dsrEngagement.AE_Name__c];
            
            String aeUsername = '';
            
            if(aeUser.size() > 0){
                aeUsername = aeUser[0].Firstname + ' ' +  aeUser[0].Lastname ; 
            }
            
            
            if(template != 'None' && lstDsrSOAPAPI.size() > 0 && generation != 'None' && region != 'None' && language != 'None'){
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                
                    gen.writeFieldName('dsrInfo');
                        gen.writeStartObject();
                        gen.writeStringField('dsrId', dsrEngagement.id);
                        gen.writeStringField('dsrSelectBy', 'dsrById');
                    gen.writeEndObject();
                
                    gen.writeFieldName('requester');
                        gen.writeStartObject();
                        gen.writeStringField('application_type', 'scedsr_webform');
                        gen.writeStringField('application_name', 'SCE DSR 2.0 - Salesforce WebForm');
                        gen.writeStringField('fullname', UserInfo.getName());
                        gen.writeStringField('email', UserInfo.getUserEmail());
                    gen.writeEndObject();
                    
                    gen.writeFieldName('document_options');
                        gen.writeStartObject();
                        gen.writeStringField('generationmode', generation);
                        gen.writeStringField('template', template   );
                        gen.writeStringField('ae_name', aeUsername);
                        gen.writeStringField('sc_name', scUsername );
                        gen.writeStringField('sales_region', region );
                        gen.writeStringField('language', language );
                    gen.writeEndObject();
                    
                
                String pretty = gen.getAsString();
                
                system.debug('pretty  =  '+ pretty);
                
                // Create HTTP call Out
                Http objhttp = new Http();
                // Create HTTP Request
                HttpRequest req = new HttpRequest();
                // Create HTTP Response
                HttpResponse res = new HttpResponse();
                // Set Method
                req.setMethod('POST'); 
                // Set Endpoint
                req.setEndpoint(lstDsrSOAPAPI[0].Header__c);
                
                req.setHeader('Content-Type', 'application/json');
                // Set request Body
                req.setBody(pretty);
                // Set Timeout
                req.setTimeout(120000);
                
                // Send HTTP Request and get Response
                if(!Test.isRunningTest())
                    res = objhttp.send(req);
                if(res.getStatusCode() != 201 ){  
                    errorcls temp = (errorcls)JSON.deserialize(res.getBody(), errorcls.class);
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, temp.error.message));
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Solution Overview is created!!'));
                }
                system.debug('Resp1  =  '+ res.getBody());
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Please fill mandatory fields..'));
            }
        }catch(exception e){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, e.getMessage()));
        }
        
    }
    
    public class errorcls{
       public errormgs error; 
    }
    public class errormgs{
        public string code;
        public string message;
    }
    
    
    public class fromJSON{
        public cls_templates[] templates;
    }
    
    public class cls_templates {
        public String name; 
        
    }
        
    
    
    /**
    *   Class Name  :   jsonClass()
    *   Description :   This class is used prpere the json format
    *   Parameters  :  
    **/
    public class jsonClass{
        public String SC_DSR_RequestID;
        public String RequestorName;
        public String RequestorEmail;
    }
    
    /**
    *   Class Name  :   clsWrapperVisionOptions()
    *   Description :   This class is used to show Vision Options
    *   Parameters  :  
    **/
    public class clsWrapperVisionOptions{
        public String name{get;set;}
        public string id{get;set;}
        public Boolean isSelect{get;set;}
    }
    
    /**
    *   Class Name  :   clsWrapperDesignOptions()
    *   Description :   This class is used to show Design Options
    *   Parameters  :  
    **/
    public class clsWrapperDesignOptions{
        public String name{get;set;}
        public string id{get;set;}
        public Boolean isSelect{get;set;}
    }
    
    /**
    *   Class Name  :   clsWrapperDiscoveryOptions()
    *   Description :   This class is used to show Discovery Options
    *   Parameters  :  
    **/
    public class clsWrapperDiscoveryOptions{
        public String name{get;set;}
        public string id{get;set;}
        public Boolean isSelect{get;set;}
    }
    
    /**
    *   Class Name  :   clsWrapperDeliverOptions()
    *   Description :   This class is used to show Deliver Options
    *   Parameters  :  
    **/
    public class clsWrapperDeliverOptions{
        public String name{get;set;}
        public string id{get;set;}
        public Boolean isSelect{get;set;}
    }
    
    /**
    *   Class Name  :   clsWrapperDesign()
    *   Description :   This class is used to show Vision Options
    *   Parameters  :  
    **/
    public class clsWrapperDesign{
        public String name{get;set;}
        public string id{get;set;}
        public String cName{get;set;}
    }
    
}