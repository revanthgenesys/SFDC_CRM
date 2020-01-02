/***************************************************************************************************
* 
*  Class Name      :   SCEngagementPartnerDSRCtlr
*  Description     :   This class is used to control the SC Engegement Page
*  Auther          :   R Systems
* 
****************************************************************************************************/
public without sharing class SCEngagementPartnerDSRCtlr{
    
    public boolean displaySubRegionalLeader {get; set;}
    public boolean displayVirtualTeam {get; set;}
    public Boolean displayVirtualTeamEdit{get;set;}
    public String OppId{get;set;}
    public String sceId{get;set;}
    public Boolean isCreate{get;set;}
    public Opportunity opp{get;set;}
    private ApexPages.StandardController stdCtrl;
    public boolean fromDSRpg{get;set;}
    
    public DSR_SCEngagement__c dsrEngagement{get;set;}
    
    
    public string SelectedStatusType{get;set;}
    public string strSmartOpp{get;set;}
    /*
    public string strSmartOpp
    {
       get
       {
         if(opp.SMART_Opportunity__c)
           strSmartOpp = 'Yes';
         else  
           strSmartOpp = 'No';
           return strSmartOpp ;
       }
       set;
    }
    */                           
    public boolean blnMsg{get;set;}
    
    // Wrapper Class Initilaztion
    public clsWrapperWowDeatils clswrapper{get;set;}
    
    
    /**
     * Default Constructor
     **/
     
    public SCEngagementPartnerDSRCtlr(ApexPages.StandardController stdController){
        try{
                // Get Opportunity Id from URL
                OppId = ApexPages.CurrentPage().getParameters().get('oppid');
                
                sceId = ApexPages.CurrentPage().getParameters().get('id');
                isCreate = false;
                fromDSRpg = false;
                stdCtrl = stdController;
                dsrEngagement = new DSR_SCEngagement__c();
                opp = new Opportunity();
                clswrapper = new clsWrapperWowDeatils();
                //if(sceId == null)
                //  strSmartOpp = 'Yes';
                
                // Call Initial  method
                System.Debug('OppId--->'+OppId);
                System.Debug('sceId--->'+sceId);
                if(OppId != null && OppId != ''){
                    System.Debug('OptyIf--->');
                    isCreate = false;
                    init();
                }else{
                    fromDSRpg = true;
                    System.Debug('else--->');
                    List<DSR_SCEngagement__c> lstDsr = [Select Id, 
                                                                Name, 
                                                                SC_Engagement_Status__c, 
                                                                Opportunity_ID__c,
                                                                Technical_Profile_ID__c,
                                                                Technical_Profile_ID__r.Name,
                                                                AssignTo__c,
                                                                SMART_Opportunity__c,
                                                                Smart_Opportunity_Intent_Use__c,
                                                                DiscoveryCount__c,
                                                                DesignCount__c,
                                                                DeliveryCount__c,
                                                                Lessons_Learned_Feedback__c,
                                                                Impact_on_Deal__c,
                                                                VisionActivityCount__c,
                                                                High_Level_Details_of_Your_Request__c,
                                                                Expected_Start_Date__c,
                                                                Is_ReOpen__c,
                                                                Is_Engagement_Feedback__c,
                                                                Rejected_Reason__c,
                                                                Stage_When_DSR_Created__c,
                                                                Pre_Sales_Priority__c                                                       
                                                                from DSR_SCEngagement__c where Id=: sceId and Is_Partner_DSR__c =: true];
                    System.Debug('lstDsr--->'+lstDsr);
                    if(lstDsr.size() > 0){
                        isCreate = true;
                        fromDSRpg = false;
                        dsrEngagement = lstDsr[0];
                        OppId = lstDsr[0].Opportunity_ID__c;
                        if(dsrEngagement.SC_Engagement_Status__c != 'Open and Not Assigned'){
                            if(dsrEngagement.SC_Engagement_Status__c != 'Rejected'){
                                SelectedStatusType = 'Approve';
                            }else{
                                SelectedStatusType = 'Reject';
                            }
                        }
                        init();
                    }
                }
        }
        catch(exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorInLine--->'+e.getLineNumber());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
    
    /**
    *   Method Name :   init()
    *   Description :   This method used to perform initial actions
    *   Parameters  :  
    **/
    
    public void init(){
        
        blnMsg = false;
        System.Debug('OppIdInit--->'+OppId);
        System.Debug('dsrEngagement--->'+dsrEngagement.SC_Engagement_Status__c);
        // Call getOppDetails method
        opp = getOppDetails();
        // Get wrapper details
        clswrapper = getWrapper();
        if(isCreate){
            clswrapper.scName = dsrEngagement.Name;
            clswrapper.scStatus = dsrEngagement.SC_Engagement_Status__c;
            clswrapper.technicalLink = dsrEngagement.Technical_Profile_ID__r.Name;
            clswrapper.technicalLinkId = dsrEngagement.Technical_Profile_ID__c;
            //clswrapper.SmartOpportunity = dsrEngagement.SMART_Opportunity__c;
            strSmartOpp = dsrEngagement.Smart_Opportunity_Intent_Use__c;
        }
        if(!isCreate){
            if(opp.Stagename == '6.Closed'){
                clswrapper.scStatus = 'Completed';
            }else{
                clswrapper.scStatus = 'Open and Not Assigned';
            }
            dsrEngagement.Pre_Sales_Priority__c = opp.Pre_Sales_Priority__c;
        }
        
    }
    
     /**
    *   Method Name :   getOppDetails()
    *   Description :   This method used to get related Opportunity Details
    *   Parameters  :  
    **/
    
    public Opportunity getOppDetails(){
        List<Opportunity> lstOpp = [Select  Id,
                                            Account.Account_Segmentation__c,
                                            SMART_Opportunity__c,
                                            Name,
                                            Industry__c,
                                            Account.name,
                                            Owner.Segment__c,
                                            Owner.Owner_Sub_Region__c,
                                            CloseDate,
                                            Primary_Line_of_Business__c,
                                            Lines_of_Businesses__c,
                                            Stagename, 
                                            AccountId,
                                            Pre_Sales_Priority__c ,
                                            Lead_Offer__c
                                            from  Opportunity 
                                            where id=: OppId];
        if(lstOpp.size() > 0){
            return lstOpp[0];
        }else{
            return null;
        }
    }
    
    /**
    *   Method Name :   getWrapper()
    *   Description :   This method used to prepare the Wrapper Class
    *   Parameters  :  
    **/
    
    public clsWrapperWowDeatils getWrapper(){
        
        List<Technical_Profile__c> list_TechProfile= [SELECT Id, Name FROM Technical_Profile__c Where Account__c=:opp.AccountId ORDER BY LastModifiedDate DESC LIMIT 1];
        
        clsWrapperWowDeatils clswrap = new clsWrapperWowDeatils();
        
        clswrap.AccountName          = opp.Account.Name;
        clswrap.OpportunityName      = opp.Name;
        clswrap.Industry             = opp.Industry__c;
        clswrap.AccSegment           = opp.Account.Account_Segmentation__c;
        clswrap.PlatformType         = opp.Primary_Line_of_Business__c;
        clswrap.ExpectedClosedDate   = opp.CloseDate;
        clswrap.OfferingType         = opp.Lines_of_Businesses__c;
        clswrap.currentStage         = opp.Stagename;
        clswrap.SmartOpportunity     = opp.SMART_Opportunity__c;
        clswrap.accntId              = opp.AccountId;
        clswrap.oppId                = opp.Id;
        clswrap.LeadOffer            = opp.Lead_Offer__c; 
        if(list_TechProfile.size() > 0){
            clswrap.technicalLinkId = list_TechProfile[0].id;
            clswrap.technicalLink = list_TechProfile[0].Name;
        }
        //clswrapper.AccountName          = opp.Account.Name;
        
        return clswrap;
    }
    
    public void fetchOppId(){
        DSR_SCEngagement__c oppIdStr = (DSR_SCEngagement__c)stdCtrl.getRecord();
        System.Debug('oppIdStr--->'+oppIdStr);
        OppId = oppIdStr.Opportunity_ID__c;
        System.Debug('EngStatus--->'+OppId);
        fromDSRpg = true;
        if(!string.isBlank(OppId)){
            init();
        }
    }
    
   
    
    public Pagereference submitDetails(){
        system.debug('ClsWrapper = '+clswrapper);
        system.debug('#Enter Submit');
        Id dsrId;
        
        fromDSRpg = false;
        
        if(!isCreate){
            system.debug('#Enter in this condition');
            if(clswrapper.currentStage == '6.Closed'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Opportunity is Closed, Smart DSR Submission is not allowed'));
                return null;
            }
            // First Time Submit by AE
            /*if((dsrEngagement.High_Level_Details_of_Your_Request__c == null || dsrEngagement.Expected_Start_Date__c == null ) && !Test.isRunningTest()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill all mandatory fields.'));
                return null;
            }*/

            DSR_SCEngagement__c dsr = new DSR_SCEngagement__c();
            dsr.Account_ID__c = clswrapper.accntId;
            dsr.Opportunity_ID__c = clswrapper.oppId;
            if(clswrapper.currentStage == '6.Closed'){
                dsr.SC_Engagement_Status__c = 'Completed';
            }else{
                dsr.SC_Engagement_Status__c = 'Open and Assigned';
            }
            dsr.Technical_Profile_ID__c = clswrapper.technicalLinkId;
            dsr.Is_Partner_DSR__c = true;
            dsr.SMART_Opportunity__c = clswrapper.SmartOpportunity;
            dsr.AE_Name__c = UserInfo.getUserId();
            dsr.AssignTo__c = 'Lead Assign';
            dsr.Stage_When_DSR_Created__c=clswrapper.currentStage;
            //dsr.Smart_Opportunity_Intent_Use__c = 'Yes';
            dsr.Smart_Opportunity_Intent_Use__c = strSmartOpp;
            dsr.High_Level_Details_of_Your_Request__c = dsrEngagement.High_Level_Details_of_Your_Request__c;
            dsr.Expected_Start_Date__c = dsrEngagement.Expected_Start_Date__c;
            dsr.Pre_Sales_Priority__c = dsrEngagement.Pre_Sales_Priority__c;
            insert dsr;
            
            dsrId = dsr.Id;
            
            /*/*Check for rejected DSR record if any record exist update new DSR id in rejected DSR record*/
            /*List<DSR_SCEngagement__c> lstDsr = [Select Id,SC_Engagement_Status__c,New_DSR_Id__c from DSR_SCEngagement__c where Opportunity_ID__c =:clswrapper.oppId and SC_Engagement_Status__c =: 'Rejected' ORDER BY createddate DESC];
            if(lstDsr != null && lstDsr.size() >0)
            {
               DSR_SCEngagement__c objDS = lstDsr[0];
               objDS.New_DSR_Id__c = dsr.id;
               update objDS;
            }*/
            
            // Create History
            
            CreateHistory('SC Request Submitted by AE',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),dsr.Id,null),dsr.AssignTo__c,dsr.SC_Engagement_Status__c,dsr.Id);
        }else{
            
            dsrId = dsrEngagement.Id;
            dsrEngagement.Smart_Opportunity_Intent_Use__c = strSmartOpp;
            update dsrEngagement;
        }
        
        if(opp.StageName != '6.Closed' && dsrEngagement.Pre_Sales_Priority__c != opp.Pre_Sales_Priority__c){
            opp.Pre_Sales_Priority__c = dsrEngagement.Pre_Sales_Priority__c;
            update opp;
        }
        
        
        //SendEmailNotification('Virtual Team');
        Pagereference pg = new Pagereference('/apex/SC_EngagementPartner_DSR?id='+dsrId);
        pg.setRedirect(true);
        return pg;
        
    }
    
    
    /**
    *   Class Name  :   openVision()
    *   Description :   This method is used to call the Vision Page
    *   Parameters  :  
    **/
    public Pagereference openVision(){
        Pagereference pg = new Pagereference('/apex/SC_Engagement_Vision?id='+sceId);
        pg.setRedirect(true);
        
        //if(dsrEngagement.Smart_Opportunity_Intent_Use__c == null)
        // pg = null;
        return pg;
    }
    
    /**
    *   Class Name  :   openDiscovery()
    *   Description :   This method is used to call the Discovery Page.
    *   Parameters  :  
    **/
    public Pagereference openDiscovery(){
        Pagereference pg = new Pagereference('/apex/SC_Engagement_Discovery?id='+sceId);
        pg.setRedirect(true);
        
        //if(dsrEngagement.Smart_Opportunity_Intent_Use__c == null)
        // pg = null;
        return pg;
    }
    
    /**
    *   Class Name  :   OpenHistory()
    *   Description :   This method is used to call the history Page.
    *   Parameters  :  
    **/
    public Pagereference OpenHistory(){
        Pagereference pg = new Pagereference('/apex/DSRSCEngagementHistory?id='+sceId);
        pg.setRedirect(true);
        return pg;
    }
    
    /**
    *   Class Name  :   OpenDesign()
    *   Description :   This method is used to Design Page
    *   Parameters  :  
    **/
    public Pagereference OpenDesign(){
        Pagereference pg = new Pagereference('/apex/SC_Engagement_Design?id='+sceId);
        pg.setRedirect(true);
        
        //if(dsrEngagement.Smart_Opportunity_Intent_Use__c == null)
        // pg = null;
        return pg;
    }
    
     /**
    *   Class Name  :   OpenDeliver()
    *   Description :   This method is used to Deliver Page
    *   Parameters  :  
    **/
    public Pagereference OpenDeliver(){
        Pagereference pg = new Pagereference('/apex/DSR_Deliver?id='+sceId);
        pg.setRedirect(true);
        
        //if(dsrEngagement.Smart_Opportunity_Intent_Use__c == null)
        // pg = null;
        return pg;
    }
    
    /**
    *   Class Name  :   OpenSolutionOverview()
    *   Description :   This method is used to Soution Overview Page
    *   Parameters  :  
    **/
    public Pagereference OpenSolutionOverview(){
        Pagereference pg = new Pagereference('/apex/DSR_Solution_Overview?id='+sceId);
        pg.setRedirect(true);
        
        //if(dsrEngagement.Smart_Opportunity_Intent_Use__c == null)
        // pg = null;
        return pg;
    }
    
    /**
    *   Class Name  :   GetWowStage()
    *   Description :   This method is used to create the history
    *   Parameters  :  
    **/
    public static string GetWowStage(String WowStage){
        
        string strWowStage=WowStage;
        
        if(strWowStage=='Lead Assign' || strWowStage=='Lead Completed'){
            strWowStage='Leadership Queue';
        }
        
        return strWowStage;
    }
    
    /**
    *   Class Name  :   CreateHistory()
    *   Description :   This method is used to create the history
    *   Parameters  :  
    **/
    public static Void CreateHistory(string Action,string UserId, string UserType, string WowStage,string Status, Id WowId){
        DSR_SC_Engagement_History__c objWoWHst = new DSR_SC_Engagement_History__c();
        objWoWHst.Action__c = Action;
        objWoWHst.User__c = UserId;
        objWoWHst.ActionDate__c = Date.today();
        objWoWHst.UserType__c = UserType;
        objWoWHst.SCEngagementStatus__c = Status;
        objWoWHst.DSRSCEngagement__c = WowId;
        objWoWHst.SCEngagementStage__c = GetWowStage(WowStage);
        objWoWHst.ActionPerformedBy__c = userinfo.getUserid();
        insert objWoWHst;
    }
    

    
    /**
    *   Class Name  :   clsWrapperWowDeatils()
    *   Description :   This class is used to show the data on page.
    *   Parameters  :  
    **/
    public class clsWrapperWowDeatils{
        public String scStatus{get;set;}
        public String scName{get;set;}
        public string AccountName{get;set;}
        public Boolean SmartOpportunity{get;set;}
        public string OpportunityName{get;set;}
        public string PlatformType{get;set;}
        public Date ExpectedClosedDate{get;set;}
        public string technicalLink{get;set;}
        public string technicalLinkId{get;set;}
        public string currentStage{get;set;}
        public string Industry{get;set;}
        public string OfferingType{get;set;}
        public string AccSegment{get;set;}     
        public string accntId{get;set;}
        public string oppId{get;set;}
        public string LeadOffer{get;set;}
        public List<SelectOption>optionListSmartOpp{get;set;}
        
        public clsWrapperWowDeatils()
        {
          //Smart Opportunity
         optionListSmartOpp = new List<SelectOption>();
         optionListSmartOpp.add(new SelectOption('--None--','--None--')); 
         optionListSmartOpp.add(new SelectOption('Yes','Yes')); 
         optionListSmartOpp.add(new SelectOption('No','No')); 
        }
    }
    
    
}