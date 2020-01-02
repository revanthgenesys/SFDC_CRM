/***************************************************************************************************
* 
*  Class Name      :   SCEngagementDSRCtlr
*  Description     :   This class is used to control the SC Engegement Page
*  Auther          :   R Systems
* 
****************************************************************************************************/
public without sharing class SCEngagementDSRCtlr{
    
    public boolean displaySubRegionalLeader {get; set;}
    public boolean displayVirtualTeam {get; set;}
    public Boolean displayVirtualTeamEdit{get;set;}
    public String OppId{get;set;}
    public String sceId{get;set;}
    public Boolean isCreate{get;set;}
    public Opportunity opp{get;set;}
    
    public DSR_Virtual_Team__c dsrVirtualTeam{get;set;}
    public DSR_Virtual_Team__c dsrVirtualTeamEdit{get;set;}
    public DSR_SCEngagement__c dsrEngagement{get;set;}
    
    public string uIdSubRegion{get;set;}
    public string uIdVirtual{get;set;}
    public string uIdVTEdit{get;set;}
    
    public Boolean isSubRegional{get;set;}
    public Boolean isVirtualUser{get;set;}
    public Boolean isAEUser{get;set;}
    public Boolean isAdminUser{get;set;}
    public Boolean isAdminalsoAE{get;set;}
    public Boolean isSalesCOE{get;set;}
    public Boolean isSC{get;set;}//added by priyank on 16 Nov 2018.
    public Boolean isReadOnly{get;set;}
    public Boolean isDuplicate{get;set;}// to check duplicate 
    
    public string SelectedStatusType{get;set;}
    public string strSmartOpp{get;set;}
    public boolean blnMsg{get;set;}
    public boolean blnSCRequiredMsj;//priyank added variable for error message. Date 1-Nov-2018
    public boolean blnSCRequiredMsj1;//priyank added variable for error message. Date 1-Nov-2018
    public string nextStepOldValue;// priyank added variable to capture old value of Next Step. Date 2-Nov-2018
    
    // Wrapper Class Initilaztion
    public clsWrapperWowDeatils clswrapper{get;set;}
    public List<clsWrapperSubRegionalLeaders> lstclsWrapperSubRegionalLeaders {get;set;}
    public List<clsWrappervirtualTeam> lstclsWrappervirtualTeam{get;set;}
    public List<clsWrapperSubRegionalLeadersall> lstclsWrapperSubRegionalLeadersall{get;set;}
    public List<clsWrappervirtualTeam> lstOldCancel;
    public clsWrappervirtualTeam clsOld;
    
    // Added by Ashish (11/21/18), copy DSR functionality
    public boolean displayCopyDSRPopUP {get; set;}
    public CopyDSR copyDSRObj {get; set;}
    
    /**
     * Default Constructor
     **/
     
    public SCEngagementDSRCtlr(ApexPages.StandardController stdController){
        isDuplicate = false;
        isSubRegional = false;
        isVirtualUser = false;
        isAEUser = false;
        isAdminUser = false;
        isAdminalsoAE = false;
        isSalesCOE = false;
        isReadOnly = false;
        blnSCRequiredMsj = false;
        blnSCRequiredMsj1 = false;
        displayCopyDSRPopUP = false;
        isSC = false; //added by priyank on 16 Nov 2018.
        displayCopyDSRPopUP = false;
        
        dsrVirtualTeam = new DSR_Virtual_Team__c();
        // Get Opportunity Id from URL
        OppId = ApexPages.CurrentPage().getParameters().get('oppid');
        
        sceId = ApexPages.CurrentPage().getParameters().get('id');
        system.debug('OppId'+ OppId);
        system.debug('sceId'+ sceId);
        dsrEngagement = new DSR_SCEngagement__c();
        dsrVirtualTeamEdit = new DSR_Virtual_Team__c();
        opp = new Opportunity();
        clswrapper = new clsWrapperWowDeatils();
        lstclsWrapperSubRegionalLeaders = new List<clsWrapperSubRegionalLeaders>();
        lstclsWrappervirtualTeam = new list<clsWrappervirtualTeam>();
        lstclsWrapperSubRegionalLeadersall = new List<clsWrapperSubRegionalLeadersall>();
        lstOldCancel = new List<clsWrappervirtualTeam>();
        
        // Call Initial  method
        if(OppId != null && OppId != ''){
            
            isCreate = false;
            init();
            checkDuplicate();
        }else if (sceId != null && sceId != ''){
         system.debug('sceId'+ sceId);
            // Strat: Changes on 5/11 as requested by Debora
            // Added Pre_Sales_Priority__c in the query
            // End: Changes on 5/11 as requested by Debora
            List<DSR_SCEngagement__c> lstDsr = [Select Id, 
                                                        Name, 
                                                        SC_Engagement_Status__c, 
                                                        Opportunity_ID__c,
                                                        Technical_Profile_ID__c,
                                                        Technical_Profile_ID__r.Name,
                                                        AssignTo__c,
                                                        SMART_Opportunity__c,
                                                        Smart_Flag_Explanation__c,//added by priyank
                                                        Next_Step__c,//added by Priyank Date 2-Nov-2018
                                                        Next_Step_Modified_By__c,//added by Priyank Date 2-Nov-2018
                                                        Next_Step_Modified_Date__c,//added by Priyank Date 2-Nov-2018
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
                                                        Stage_When_DSR_Created__c ,
                                                        Pre_Sales_Priority__c,
                                                        Pre_Sales_Involvement__c,                       // Added By Ashish (12/13/2018), on Request of Debbie.
                                                        Opportunity_ID__r.Direct_Indirect_Sale__c,      // Added By Ashish (12/13/2018), on Request of Debbie.
                                                        Opportunity_ID__r.Sold_To_Country__r.Name,      // Added By Ashish (12/13/2018), on Request of Debbie.
                                                        On_Hold__c                 // Added By Ashish (10/31/2018), on Request of Debbie. To Add the 'On Hold section'    
                                                        from DSR_SCEngagement__c where Id=: sceId];
                                                        system.debug('lstDsr.size() ' + lstDsr.size() );
                                                        system.debug('lstDsr ' + lstDsr );
            if(lstDsr.size() > 0){
                isCreate = true;
                dsrEngagement = lstDsr[0];
                nextStepOldValue = lstDsr[0].Next_Step__c; //Priyank added line to capture old value of next step. Date 2-Nov-2018
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
        else{
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Create SC DSR From Opportunity'));
         isCreate = false;
        }
       
        if(!isSubRegional && !isVirtualUser && !isAEUser && !isAdminUser && !isSalesCOE && isCreate){
                    isReadOnly = true;
        }
    }
    
     /**
    *   Method Name :   checkDuplicate()
    *   Description :   This method used to check duplicate DSR_SCEngagement
    *   Parameters  :  
    **/
    
    public void checkDuplicate(){
        List<DSR_SCEngagement__c> lstDsr = new List<DSR_SCEngagement__c>();
        lstDsr = [Select Id from DSR_SCEngagement__c where Opportunity_ID__c =: OppId And Is_Partner_DSR__c = false];
        if(lstDsr.size() > 0){
            isDuplicate = true;
             ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'There is an existing DSR on the opportunity. You cannot create new one.'));
        }else 
            isDuplicate = false;
    }
    
    /**
    *   Method Name :   init()
    *   Description :   This method used to perform initial actions
    *   Parameters  :  
    **/
    
    public void init(){
        
        if(isCreate){
            isSubRegional = CheckSubregionalUser(UserInfo.getUserId(), sceId);
            isAdminUser = CheckAdminUser(UserInfo.getUserId(), sceId);
            isAEUser = CheckAEUser(UserInfo.getUserId(), sceId);
            isVirtualUser = CheckVTUser(UserInfo.getUserId(), sceId);
            isSC = CheckScUser(UserInfo.getUserId(), sceId);//added by priyank on 16 Nov 2018.
            
            /*******Requested By Debora Lane 16-April-2018 ******/
            if(!isSubRegional && !isVirtualUser)
              isSalesCOE = CheckSalesCOE(UserInfo.GetUserEmail());
            
            //if(!isSubRegional && !isAdminUser && !isSalesCOE )
            // isVirtualUser = CheckVTUser(UserInfo.getUserId(), sceId);
            
            if(isAdminUser){
                isAdminalsoAE = true;
            }else if(isAdminUser && isAEUser){
                isAdminalsoAE = true;
            }else if(isAdminUser && !isAEUser){
                isAdminalsoAE = true;
            }
        }
        
        blnMsg = false;
        
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
            //Added by JJ 10/24/18
            //Start
            /*isSubRegional = CheckSubregionalUser(UserInfo.getUserId(), sceId);
            isAdminUser = CheckAdminUser(UserInfo.getUserId(), sceId);
            isAEUser = CheckAEUser(UserInfo.getUserId(), sceId);
            isVirtualUser = CheckVTUser(UserInfo.getUserId(), sceId);
            
            
            if(!isSubRegional && !isVirtualUser)
              isSalesCOE = CheckSalesCOE(UserInfo.GetUserEmail());
            
            
            if(isAdminUser){
                isAdminalsoAE = true;
            }else if(isAdminUser && isAEUser){
                isAdminalsoAE = true;
            }else if(isAdminUser && !isAEUser){
                isAdminalsoAE = true;
            }*/
            //End
            clswrapper.scStatus = 'Open and Not Assigned';
            dsrEngagement.Pre_Sales_Priority__c  = opp.Pre_Sales_Priority__c; 
        }
        
        lstclsWrapperSubRegionalLeaders = getWrapperSubRegionalLeaders();
        
        lstclsWrappervirtualTeam = getWrapperVirtualTeam();
        
        system.debug('Init = ' +clswrapper );
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
                                            Pre_Sales_Priority__c,
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
    
    /**
    *   Method Name :   getWrapperSubRegionalLeaders()
    *   Description :   This method used to prepare the Wrapper Class for Sub Regional leaders
    *   Parameters  :  
    **/
    
    public List<clsWrapperSubRegionalLeaders> getWrapperSubRegionalLeaders(){
        system.debug('#Enter in getWrapperSubRegionalLeaders');
        
        List<clsWrapperSubRegionalLeaders> lstclswrap = new List<clsWrapperSubRegionalLeaders>();
        
        if(isCreate){
            List<DSR_Virtual_Team__c> lstDSRVirtualTeam = [Select Id,   Virtual_Team_Member_Name__c,
                                                                        Virtual_Team_Member_Name__r.Name, 
                                                                        Region__c, 
                                                                        Sub_Region__c, 
                                                                        Segment__c,
                                                                        Is_Admin__c,
                                                                        Notes__c
                                                                        from DSR_Virtual_Team__c
                                                                        where SCE_ID__c =:sceId
                                                                        and Virtual_User_Role__c =:'Sub Regional Leader'];
            system.debug(' From DSR Virtual Team '+ lstDSRVirtualTeam.size());
            if(lstDSRVirtualTeam.size() > 0){
                for(DSR_Virtual_Team__c dsr : lstDSRVirtualTeam){
                    clsWrapperSubRegionalLeaders clswrapnew = new clsWrapperSubRegionalLeaders();
                    clswrapnew.leaderName = dsr.Virtual_Team_Member_Name__r.Name;
                    clswrapnew.region = dsr.Region__c;
                    clswrapnew.subregion = dsr.Sub_Region__c;
                    clswrapnew.segment = dsr.Segment__c;
                    clswrapnew.notes = dsr.NOtes__c;
                    clswrapnew.userID = dsr.Virtual_Team_Member_Name__c;
                    clswrapnew.recordId = dsr.Id;
                    clswrapnew.isAdmin =  dsr.Is_Admin__c;
                    clswrapnew.key = clswrapnew.leaderName + ':' + clswrapnew.region + ':' + clswrapnew.subregion + ':' + clswrapnew.segment + ':' + clswrapnew.userID;
                    lstclswrap.add(clswrapnew);
                }
            }
        }else{
            List<Wow_Sub_Regional_Users__c>  lstSubRegionalLeaders = WoWUtility.getSubRegionalNewUsersName(opp.Owner.Segment__c ,opp.Owner.Owner_Sub_Region__c, opp.Lines_of_Businesses__c);
            system.debug(' Sub Regional Leader '+ lstSubRegionalLeaders.size());
            system.debug('#List Details# '+ lstSubRegionalLeaders);
            if(lstSubRegionalLeaders.size() > 0){
                Set<String> setUser = new Set<String>();
                Map<String, Id> mapNametoID = new Map<String, Id>();
                
                for(Wow_Sub_Regional_Users__c dsr : lstSubRegionalLeaders){
                    if(dsr.Subregional_Leader__c != null){
                        setUser.add(dsr.Subregional_Leader__c);
                    }
                }
                
                if(setUser.size() > 0){
                    List<User> lstUser = [Select Id, Email, Name from User where Email In: setUser and Isactive= true];
                
                    for(User u : lstUser){
                        mapNametoID.put(u.Email, U.Id);
                    }
                }
                
                system.debug('#Map# '+mapNametoID);
                
                for(Wow_Sub_Regional_Users__c dsr : lstSubRegionalLeaders){
                    clsWrapperSubRegionalLeaders clswrapnew = new clsWrapperSubRegionalLeaders();
                    clswrapnew.leaderName = dsr.User_Name__c;
                    clswrapnew.region = dsr.Region__c;
                    clswrapnew.subregion = dsr.SubRegion__c;
                    clswrapnew.segment = dsr.Segment__c;
                    clswrapnew.isAdmin = dsr.Is_Admin__c;
                    clswrapnew.key = dsr.User_Name__c + ':'+ dsr.Region__c + ':'+ dsr.SubRegion__c +  ':'+ dsr.Segment__c;
                    if(mapNametoID.containsKey(dsr.Subregional_Leader__c)){
                        clswrapnew.userID = mapNametoID.get(dsr.Subregional_Leader__c);
                        system.debug('#UserID#'+mapNametoID.get(dsr.Subregional_Leader__c));
                    }
                    clswrapnew.key = clswrapnew.key + ':' + clswrapnew.userID;
                    //clswrapnew.notes = dsr.NOte__c;
                    lstclswrap.add(clswrapnew);
                }
            }
        }
        return lstclswrap;
    }
    
    /**
    *   Method Name :   getWrapperVirtualTeam()
    *   Description :   This method used to prepare the Wrapper Class for Virtual Team
    *   Parameters  :  
    **/
    
    public List<clsWrappervirtualTeam> getWrapperVirtualTeam(){
        
        List<clsWrappervirtualTeam> lstclswrap = new List<clsWrappervirtualTeam>();
        
        if(isCreate){
            List<DSR_Virtual_Team__c> lstDSRVirtualTeam = [Select Id,   Virtual_Team_Member_Name__r.Name, 
                                                                        Virtual_Team_Member_Name__c,
                                                                        Notes__c,
                                                                        Virtual_User_type__c,
                                                                        IsPrimary__c
                                                                        from DSR_Virtual_Team__c
                                                                        where SCE_ID__c =:sceId
                                                                        and Virtual_User_Role__c =:'Virtual Team'];
        
            if(lstDSRVirtualTeam.size() > 0 ){
                for(DSR_Virtual_Team__c  dsr : lstDSRVirtualTeam){
                    clsWrappervirtualTeam clsnew = new clsWrappervirtualTeam();
                    clsnew.virtualuser =  dsr.Virtual_Team_Member_Name__r.Name;
                    clsnew.virtualUserType = dsr.Virtual_User_type__c;
                    clsnew.notes = dsr.Notes__c;
                    clsnew.recordId = dsr.Id;
                    clsnew.isPrimary = dsr.IsPrimary__c;
                    clsnew.userID = dsr.Virtual_Team_Member_Name__c;
                    lstclswrap.add(clsnew);
                }
            }
        }
        
        return lstclswrap;
    }
    
    
    /**
    *   Method Name :   showSubRegionalLeaders()
    *   Description :   This method used to show the Sub Reginal Leades Popup
    *   Parameters  :  
    **/
    
    public void showSubRegionalLeaders() { 
        lstclsWrapperSubRegionalLeadersall = getSubRegionleadersall();
        //lstclsWrapperSubRegionalLeadersall.sort();
        displaySubRegionalLeader = true;    
    }
    
    /**
    *   Method Name :   closeSubregionalLeaders()
    *   Description :   This method used to closed the Sub Reginal Leades Popup
    *   Parameters  :  
    **/
    
    public void closeSubregionalLeaders() {  
        
       // List<User> lstUser = [Select Id, Name, Region__c, Sub_Region__c, Segment__c from User where Id=:dsrVirtualTeam.Virtual_Team_Member_Name__c];
        
        if(lstclsWrapperSubRegionalLeadersall.size() > 0) {
            for(clsWrapperSubRegionalLeadersall u : lstclsWrapperSubRegionalLeadersall){
                if(u.addRemove){
                    clsWrapperSubRegionalLeaders clswrapnew = new clsWrapperSubRegionalLeaders();
                    clswrapnew.leaderName = u.leaderName;
                    clswrapnew.region = u.region;
                    clswrapnew.subregion = u.subregion;
                    clswrapnew.segment = u.segment;
                    clswrapnew.userID = u.userID;
                    clswrapnew.isAdmin = u.isAdmin;
                    clswrapnew.key =  u.leaderName + ':'+ u.region +':'+ u.subregion + ':'+ u.segment + ':'+ u.userID;
                    //clswrapnew.notes = dsr.NOtes__c;
                    clswrapnew.isSaved = false;
                    lstclsWrapperSubRegionalLeaders.add(clswrapnew);
                }
                system.debug('lstclsWrapperSubRegionalLeaders' + lstclsWrapperSubRegionalLeaders);
            }
            
        }
        
        
            
        displaySubRegionalLeader = false;    
    }  
    
    public void closeSubregionalLeadersCancel() {  
        displaySubRegionalLeader = false;    
    }  
    
    /**
    *   Method Name :   showVirtualTeamEdit()
    *   Description :   This method used to Edit the Virtul Team
    *   Parameters  :  
    **/
    
    public void showVirtualTeamEdit() {     
        uIdVTEdit = ApexPages.CurrentPage().getParameters().get('uIdVirtual');
        /*List<DSR_Virtual_Team__c> lstDSRVirtualTeam = [Select Id,   Virtual_Team_Member_Name__r.Name, 
                                                                        Virtual_Team_Member_Name__c,
                                                                        Notes__c,
                                                                        Virtual_User_type__c,
                                                                        IsPrimary__c
                                                                        from DSR_Virtual_Team__c
                                                                        where SCE_ID__c =:sceId
                                                                        and Virtual_Team_Member_Name__c =:uIdVTEdit];
        if(lstDSRVirtualTeam.size() > 0){
            dsrVirtualTeamEdit = lstDSRVirtualTeam[0];
        }*/
        
        clsOld = new clsWrappervirtualTeam();
        lstOldCancel = lstclsWrappervirtualTeam;
        for(clsWrappervirtualTeam dsrEdit : lstclsWrappervirtualTeam){
            if(uIdVTEdit == dsrEdit.virtualuser){
                dsrVirtualTeamEdit = new DSR_Virtual_Team__c();
                dsrVirtualTeamEdit.Virtual_User_type__c = dsrEdit.virtualUserType;
                dsrVirtualTeamEdit.Notes__c = dsrEdit.notes;
                dsrVirtualTeamEdit.IsPrimary__c = dsrEdit.isPrimary;
                dsrVirtualTeamEdit.Virtual_Team_Member_Name__c = dsrEdit.userID;
                dsrVirtualTeamEdit.Id = dsrEdit.recordId;
                
                clsOld.virtualuser = dsrEdit.virtualuser;
                clsOld.virtualUserType = dsrEdit.virtualUserType;
                clsOld.userID =  dsrEdit.userID;
                clsOld.isPrimary = dsrEdit.isPrimary;
                clsOld.recordId = dsrEdit.recordId;
            }
        }
        displayVirtualTeamEdit = true;    
        system.debug('<><>  ==2 '+ lstOldCancel);
    }
    
    /**
    *   Method Name :   closeVirtualTeam()
    *   Description :   This method used to closed the Virtul Team
    *   Parameters  :  
    **/
    
    public void closeVirtualTeamEdit() {   
        
        List<User> lstUser = [Select Id, Name, Region__c, Sub_Region__c, Segment__c from User where Id=:dsrVirtualTeamEdit.Virtual_Team_Member_Name__c];
        
        Boolean primary = false;
        Integer SCcount = 0;
        Integer SAcount = 0;
        Integer SLcount = 0;
        Integer BCcount = 0;
        Integer PScount = 0;
        Integer dupCount = 0;
        
        for(clsWrappervirtualTeam clswrap : lstclsWrappervirtualTeam){
            
            system.debug('+++lstUser[0].Name+++'+lstUser[0].Name);
            system.debug('+++uIdVTEdit+++'+uIdVTEdit);
            system.debug('+++clswrap.virtualuser+++'+clswrap.virtualuser);
            
            if(lstUser[0].Name != uIdVTEdit && clswrap.virtualuser == lstUser[0].Name){
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Member already added.'));
                return;
            }
            if(uIdVTEdit == clswrap.virtualuser){
                clswrap.virtualuser =  lstUser[0].Name;
                clswrap.virtualUserType = dsrVirtualTeamEdit.Virtual_User_type__c;
                clswrap.userID =  lstUser[0].Id;
                clswrap.isPrimary = dsrVirtualTeamEdit.IsPrimary__c;
                clswrap.isSaved = false;
            }
        }
        
        for(clsWrappervirtualTeam cls : lstclsWrappervirtualTeam){
            if(cls.isPrimary && cls.virtualUserType == 'Solution Consultant' ){
                SCcount++;
            }
            if(cls.isPrimary && cls.virtualUserType == 'Solution Architect' ){
                SAcount++;
            }
            if(cls.isPrimary && cls.virtualUserType == 'Solution Lead' ){
                SLcount++;
            }
            if(cls.isPrimary && cls.virtualUserType == 'Business Consultant' ){
                BCcount++;
            }
            if(cls.isPrimary && cls.virtualUserType == 'PS Consulting Sales Director' ){
                PScount++;
            }
            if(dsrVirtualTeamEdit.Virtual_Team_Member_Name__c == cls.userID){
                dupCount++;
            }
        }
        if(lstUser.size() > 0){
            if(SCcount > 1 || SAcount > 1 || SLcount > 1 || BCcount > 1 || PScount > 1){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Only one primary Virtual User is allowed of same User Type.'));
                for(clsWrappervirtualTeam clswrap : lstclsWrappervirtualTeam){
                    if(uIdVTEdit == clswrap.virtualuser){
                        clswrap.isPrimary = false;
                    }
                }
                return;
                
            }else{
                displayVirtualTeamEdit = false; 
            }
        }
    } 
    
    /**
    *   Method Name :   closeVirtualTeamEditCancel()
    *   Description :   This method used to closed the Virtul Team
    *   Parameters  :  
    **/
    
    public void closeVirtualTeamEditCancel() {  
        
        displayVirtualTeamEdit = false;    
        lstclsWrappervirtualTeam = new List<clsWrappervirtualTeam>();
        system.debug('>>>> = '+lstOldCancel);
        lstclsWrappervirtualTeam = lstOldCancel;
    } 
    
    /**
    *   Method Name :   showVirtualTeam()
    *   Description :   This method used to show the Virtul Team
    *   Parameters  :  
    **/
    
    public void showVirtualTeam() {     
        dsrVirtualTeam = new DSR_Virtual_Team__c();
        displayVirtualTeam = true;    
    }
    
    /**
    *   Method Name :   closeVirtualTeam()
    *   Description :   This method used to closed the Virtul Team
    *   Parameters  :  
    **/
    
    public void closeVirtualTeam() {   
        
        List<User> lstUser = [Select Id, Name, Region__c, Sub_Region__c, Segment__c from User where Id=:dsrVirtualTeam.Virtual_Team_Member_Name__c];
        
        Boolean primary = false;
        Integer SCcount = 0;
        Integer SAcount = 0;
        Integer SLcount = 0;
        Integer BCcount = 0;
        Integer PScount = 0;
        Boolean dupCheck =false;
        
        if(dsrVirtualTeam.IsPrimary__c && dsrVirtualTeam.Virtual_User_type__c == 'Solution Consultant' ){
            SCcount++;
        }
        if(dsrVirtualTeam.IsPrimary__c && dsrVirtualTeam.Virtual_User_type__c == 'Solution Architect' ){
            SAcount++;
        }
        if(dsrVirtualTeam.IsPrimary__c && dsrVirtualTeam.Virtual_User_type__c == 'Solution Lead' ){
            SLcount++;
        }
        if(dsrVirtualTeam.IsPrimary__c && dsrVirtualTeam.Virtual_User_type__c == 'Business Consultant' ){
            BCcount++;
        }
        if(dsrVirtualTeam.IsPrimary__c && dsrVirtualTeam.Virtual_User_type__c == 'PS Consulting Sales Director' ){
            PScount++;
        }
        for(clsWrappervirtualTeam clswrap : lstclsWrappervirtualTeam){
            if(clswrap.isPrimary && clswrap.virtualUserType == 'Solution Consultant' ){
                SCcount++;
            }
            if(clswrap.isPrimary && clswrap.virtualUserType == 'Solution Architect' ){
                SAcount++;
            }
            if(clswrap.isPrimary && clswrap.virtualUserType == 'Solution Lead' ){
                SLcount++;
            }
            if(clswrap.isPrimary && clswrap.virtualUserType == 'Business Consultant' ){
                BCcount++;
            }
            if(clswrap.isPrimary && clswrap.virtualUserType == 'PS Consulting Sales Director' ){
                PScount++;
            }
            if(dsrVirtualTeam.Virtual_Team_Member_Name__c == clswrap.userID){
                dupCheck = true;
            }
        }
        system.debug('>> SCcount ' + SCcount);
        system.debug('>> SAcount ' + SAcount);
        system.debug('>> SLcount ' + SLcount);
        system.debug('>> BCcount ' + BCcount);
        system.debug('>> PScount ' + PScount);
        if(lstUser.size() > 0){
            if(SCcount > 1 || SAcount > 1 || SLcount > 1 || BCcount > 1 || PScount > 1){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Only one primary Virtual User is allowed of same User Type.'));
            }else if(dupCheck){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Member already added.'));
            }
            else if(dsrVirtualTeam.Virtual_Team_Member_Name__c == null || dsrVirtualTeam.Virtual_User_type__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select mandatory fields.'));
            }
            else{
                clsWrappervirtualTeam clsnew = new clsWrappervirtualTeam();
                clsnew.virtualuser =  lstUser[0].Name;
                clsnew.virtualUserType = dsrVirtualTeam.Virtual_User_type__c;
                clsnew.userID =  lstUser[0].Id;
                clsnew.isPrimary = dsrVirtualTeam.IsPrimary__c;
                clsnew.isSaved = false;
                lstclsWrappervirtualTeam.add(clsnew);
                displayVirtualTeam = false; 
            }
        }
    }   
    
    
    /**
    *   Method Name :   closeVirtualTeam()
    *   Description :   This method used to closed the Virtul Team
    *   Parameters  :  
    **/
    
    public void closeVirtualTeamCancel() {  
        displayVirtualTeam = false;    
    } 
    
    /**
    *   Method Name :   getSubRegionleadersall()
    *   Description :   This method used to get all the Subregional Leaders
    *   Parameters  :  
    **/
    
    public List<clsWrapperSubRegionalLeadersall> getSubRegionleadersall() {   
        List<clsWrapperSubRegionalLeadersall> clswraplst = new List<clsWrapperSubRegionalLeadersall>();
        List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
        
        //For Sorting Start
          List<string>list_LedName = new List<string>();
          Map<string,Wow_Sub_Regional_Users__c>map_UnsortLeader = new Map<string,Wow_Sub_Regional_Users__c>();
        //For Sorting End
        
        
         if(list_SubRegion.size() > 0){
                Set<String> setUser = new Set<String>();
                Map<String, Id> mapNametoID = new Map<String, Id>();
                
                for(Wow_Sub_Regional_Users__c dsr : list_SubRegion){
                    if(dsr.Subregional_Leader__c != null){
                        setUser.add(dsr.Subregional_Leader__c);
                        list_LedName.add(dsr.User_Name__c);
                        map_UnsortLeader.put(dsr.User_Name__c,dsr);
                    }
                }
                
                //For Sorting Start
                  list_LedName.sort();
                  Map<string,Wow_Sub_Regional_Users__c>map_Led = new Map<string,Wow_Sub_Regional_Users__c>();
                  for(string sName : list_LedName)
                  {
                   
                    map_Led.put(sName,map_UnsortLeader.get(sName));
                  }
                //For Sorting End
                
                if(setUser.size() > 0){
                    List<User> lstUser = [Select Id,Email, Name from User where Email In: setUser and IsActive=true];
                
                    //lstUser.sort();
                    for(User u : lstUser){
                        mapNametoID.put(u.Email, U.Id);
                    }
                }
                
                //for(Wow_Sub_Regional_Users__c dsr : list_SubRegion){
                for(string sName : map_Led.keySet()){
                    Wow_Sub_Regional_Users__c dsr = map_Led.get(sName);
                
                    clsWrapperSubRegionalLeadersall clswrapnew = new clsWrapperSubRegionalLeadersall();
                    clswrapnew.leaderName = dsr.User_Name__c;
                    clswrapnew.region = dsr.Region__c;
                    clswrapnew.subregion = dsr.SubRegion__c;
                    clswrapnew.segment = dsr.Segment__c;
                    clswrapnew.isAdmin = dsr.Is_Admin__c;
                    clswrapnew.addRemove = false;
                    clswrapnew.key = dsr.User_Name__c + ':'+ dsr.Region__c + ':'+ dsr.SubRegion__c +  ':'+ dsr.Segment__c;
                    if(mapNametoID.containsKey(dsr.Subregional_Leader__c)){
                        clswrapnew.userID = mapNametoID.get(dsr.Subregional_Leader__c);
                    }
                    clswrapnew.key = clswrapnew.key + ':' + clswrapnew.userID;
                    //clswrapnew.notes = dsr.NOte__c;
                    clswraplst.add(clswrapnew);
                }
            }
            
        return clswraplst;
         
    }   
    
    /**
    *   Class Name  :   removeLeader()
    *   Description :   This class is used to remove the Subregional Leaders
    *   Parameters  :  
    **/
    
    public void removeLeader(){
        uIdSubRegion = ApexPages.CurrentPage().getParameters().get('uId');
        system.debug('--SelectedSRL--'+uIdSubRegion );
        system.debug('--SRL--'+lstclsWrapperSubRegionalLeaders);
        String[] keyValues = uIdSubRegion.split(':');
        string strUserID;
        //system.debug('--UserID-'+ keyValues[4]);
        
        
        List<clsWrapperSubRegionalLeaders> lstOld = lstclsWrapperSubRegionalLeaders;
        lstclsWrapperSubRegionalLeaders  = new List<clsWrapperSubRegionalLeaders>();
        
        for(clsWrapperSubRegionalLeaders dsr : lstOld){
            List<String> lstString = uIdSubRegion.split(':');
            // Need to handle for all keywords
            if( uIdSubRegion == dsr.key){
                // Remove from list
                strUserID = dsr.userID;
                system.debug('-SRLDelete-'+dsr.key);
            }else{
                lstclsWrapperSubRegionalLeaders.add(dsr);
            }
        }
        
        if(lstclsWrapperSubRegionalLeaders.size()>0)
        {
           List<DSR_Virtual_Team__c> lstDelete = [Select Id from DSR_Virtual_Team__c where Virtual_Team_Member_Name__c  =: strUserID  and SCE_ID__c =: sceId and Virtual_User_Role__c = 'Sub Regional Leader'];
           delete lstDelete;

        }
        
        system.debug('--SRLAgain--'+lstclsWrapperSubRegionalLeaders);
    }
    
    /**
    *   Class Name  :   removeVirtualTeam()
    *   Description :   This class is used to remove the Virtual team 
    *   Parameters  :  
    **/
    
    public pageReference removeVirtualTeam(){
       if(lstclsWrappervirtualTeam.size() == 1 && clswrapper.scStatus != 'Open and Not Assigned')
       {
           blnMsg =true;
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You can not remove all Virtaul Team members.'));
           return null;
       }

      
    
        uIdVirtual = ApexPages.CurrentPage().getParameters().get('uIdVirtual');
        
        List<DSR_Virtual_Team__c> lstDelete = [Select Id from DSR_Virtual_Team__c where Virtual_Team_Member_Name__c  =: uIdVirtual and SCE_ID__c =: sceId and Virtual_User_Role__c = 'Virtual Team'];
        delete lstDelete;
        
        List<clsWrappervirtualTeam> lstOld = lstclsWrappervirtualTeam;
        lstclsWrappervirtualTeam  = new List<clsWrappervirtualTeam>();
        
        string strAllVTNames2 = '';
        
        if(lstOld.size()>0)
        {
            integer ctr=0;
        for(clsWrappervirtualTeam dsr : lstOld){
        ctr += 1;
            if(dsr.userId != uIdVirtual){
            
            if(ctr < lstOld.size()-1)
                strAllVTNames2 += dsr.virtualuser+',';
            else
                strAllVTNames2 += dsr.virtualuser;
                                
                
                lstclsWrappervirtualTeam.add(dsr);
            }
           }
        }
        
        /************* update VT memebers Name in SCE *******************/
            
            DSR_SCEngagement__c dsr2 = new DSR_SCEngagement__c();
            dsr2.VirtualTeamNames__c = strAllVTNames2;
            dsr2.id = dsrEngagement.Id;
            update dsr2;
            
        return null;
    }
    
    /**
    *   Class Name  :   getStatusTypes()
    *   Description :   This class is used to get the Status Type
    *   Parameters  :  
    **/
    
    public List<SelectOption> getStatusTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Approve','Approve'));
        options.add(new SelectOption('Reject','Reject'));
        return options;
    }
     
    /**
    *   Class Name  :   clsWrapperWowDeatils()
    *   Description :   This class is used to show the data on page.
    *   Parameters  :  
    **/
    
    public Pagereference submitDetails(){
        system.debug('ClsWrapper = '+clswrapper);
        system.debug('#Enter Submit');
        Id dsrId;
        //Priyank added below two lines
        blnSCRequiredMsj = false;
        blnSCRequiredMsj1 = false;
        
        if(!isCreate){
            system.debug('#Enter in this condition');
            // First Time Submit by AE
            if((dsrEngagement.High_Level_Details_of_Your_Request__c == null || dsrEngagement.Expected_Start_Date__c == null ) && !Test.isRunningTest()){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill all mandatory fields.'));
                return null;
            }

            DSR_SCEngagement__c dsr = new DSR_SCEngagement__c();
            dsr.Account_ID__c = clswrapper.accntId;
            dsr.Opportunity_ID__c = clswrapper.oppId;
            dsr.SC_Engagement_Status__c = 'Open and Not Assigned';
            dsr.Technical_Profile_ID__c = clswrapper.technicalLinkId;
            //dsr.SMART_Opportunity__c = clswrapper.SmartOpportunity;
            dsr.AE_Name__c = UserInfo.getUserId();
            dsr.AssignTo__c = 'Lead Assign';
            dsr.Stage_When_DSR_Created__c=clswrapper.currentStage;
            dsr.High_Level_Details_of_Your_Request__c = dsrEngagement.High_Level_Details_of_Your_Request__c;
            dsr.Expected_Start_Date__c = dsrEngagement.Expected_Start_Date__c;
            dsr.Pre_Sales_Priority__c = dsrEngagement.Pre_Sales_Priority__c;
            insert dsr;
            
            dsrId = dsr.Id;
            
            /*Check for rejected DSR record if any record exist update new DSR id in rejected DSR record*/
            List<DSR_SCEngagement__c> lstDsr = [Select Id,SC_Engagement_Status__c,New_DSR_Id__c from DSR_SCEngagement__c where Opportunity_ID__c =:clswrapper.oppId and SC_Engagement_Status__c =: 'Rejected' ORDER BY createddate DESC];
            if(lstDsr != null && lstDsr.size() >0)
            {
               DSR_SCEngagement__c objDS = lstDsr[0];
               objDS.New_DSR_Id__c = dsr.id;
               update objDS;
            }
            
            // Create History
            
            CreateHistory('SC Request Submitted by AE',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),dsr.Id,null),dsr.AssignTo__c,dsr.SC_Engagement_Status__c,dsr.Id);
        }
        
        List<DSR_Virtual_Team__c> lstDelete = [Select Id from DSR_Virtual_Team__c where SCE_ID__c  =: sceid and Virtual_User_Role__c=:'Sub Regional Leader'];
        
        if(isCreate){
            dsrId = dsrEngagement.Id;
            
            update dsrEngagement;
            delete lstDelete;
        }
        
        List<DSR_Virtual_Team__c> lstdsrRegional = new List<DSR_Virtual_Team__c>();
        List<DSR_Virtual_Team__c> lstdsrVT = new List<DSR_Virtual_Team__c>();
        List<DSR_Virtual_Team__c> lstUdpate = new List<DSR_Virtual_Team__c>();
        
        
        system.debug('#Size# '+lstclsWrapperSubRegionalLeaders.size());
        if(lstclsWrapperSubRegionalLeaders.size() > 0){
        system.debug('#SRL has leaders');
        system.debug(lstclsWrapperSubRegionalLeaders);
        
        system.debug('Select SRL-'+lstclsWrapperSubRegionalLeaders);
        
            for(clsWrapperSubRegionalLeaders sub :lstclsWrapperSubRegionalLeaders){
                if(sub.userID != null){
                    DSR_Virtual_Team__c dsrTean = new DSR_Virtual_Team__c();
                    dsrTean.SCE_ID__c = dsrId;
                    dsrTean.Virtual_Team_Member_Name__c = sub.userID;
                    dsrTean.Virtual_User_Role__c = 'Sub Regional Leader';
                    dsrTean.Assigned_By__c = UserInfo.getUserId();
                    dsrTean.Region__c = sub.region;
                    dsrTean.Sub_Region__c = sub.subregion;
                    dsrTean.Segment__c = sub.segment;
                    dsrTean.Is_Admin__c = sub.isAdmin;
                    lstdsrRegional.add(dsrTean);
                }
            }
        }
        
        string strAllVTNames = '';
        
        if(lstclsWrappervirtualTeam.size() > 0){
            integer ctr=0;
            for(clsWrappervirtualTeam sub :lstclsWrappervirtualTeam){
                //Priyank added the below code on 9/11/2018. to check the primary sol. const.
                if(sub.virtualUserType == 'Solution Consultant'){
                    if(sub.isPrimary== TRUE && sub.virtualUserType== 'Solution Consultant'){
                        blnSCRequiredMsj1 = true;
                    }else{
                        blnSCRequiredMsj = true;
                    }
                }
                //Priyank code end.
                if(sub.userID != null && (sub.recordId == null || sub.recordId == '')){
                    DSR_Virtual_Team__c dsrTean = new DSR_Virtual_Team__c();
                    dsrTean.SCE_ID__c = dsrId;
                    dsrTean.Virtual_Team_Member_Name__c = sub.userID;
                    dsrTean.Virtual_User_Role__c = 'Virtual Team';
                    dsrTean.Assigned_By__c = UserInfo.getUserId();
                    dsrTean.IsPrimary__c =sub.isPrimary;
                    dsrTean.Virtual_User_type__c = sub.virtualUserType;
                    lstdsrVT.add(dsrTean);
                }else if(sub.recordId != null && sub.recordId != ''){
                    DSR_Virtual_Team__c dsrTean = new DSR_Virtual_Team__c();
                    dsrTean.SCE_ID__c = dsrId;
                    dsrTean.Virtual_Team_Member_Name__c = sub.userID;
                    dsrTean.Virtual_User_Role__c = 'Virtual Team';
                    dsrTean.Assigned_By__c = UserInfo.getUserId();
                    dsrTean.IsPrimary__c =sub.isPrimary;
                    dsrTean.Id = sub.recordId;
                    dsrTean.Virtual_User_type__c = sub.virtualUserType;
                    lstUdpate.add(dsrTean);
                }
                
                /************** update VT Name ************/
                //strAllVTNames += ',' + sub.virtualuser;
                
                if(ctr < lstclsWrappervirtualTeam.size()-1)
                  strAllVTNames += sub.virtualuser+',';
                else
                  strAllVTNames += sub.virtualuser;
                  
                ctr += 1;  
            }
        }
        
        system.debug('-SRL-'+lstdsrRegional);
        
        //Priyank added below if condition to show error message 31/10/2018 as discussed with JJ. 
        if(blnSCRequiredMsj && !blnSCRequiredMsj1){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please make at least one Solution Consultant as Primary.'));
            return null;
        }
        // Priyank code end.
        
        if(lstdsrRegional.size() > 0){
            upsert lstdsrRegional;
            
          if(!isCreate)
          {
            //Send Email Notification to AE and All assigned Lead
            DSRUtility.SendEmailNotificationDSR('Lead Assigned',dsrId,null);
            DSRUtility.SendEmailNotificationDSR('Lead Submitted',dsrId,null);
          }  
        }
        
        if(lstdsrVT.size() > 0){
            upsert lstdsrVT;
        }
        
         if(lstUdpate.size() > 0){
            update lstUdpate;
        }
        
        
        // If DSR is submitted by Leadr or Admin 
        if(dsrEngagement.SC_Engagement_Status__c == 'Open and Not Assigned' && ( isSubRegional || isAdminUser )){
            if(SelectedStatusType == null || SelectedStatusType == ''){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please choose Approve or Reject before submitting the DSR.'));
                return null;
            }else  if(lstclsWrappervirtualTeam.size() == 0  && SelectedStatusType == 'Approve'){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please add atleast one Virtual Team Member before Approving the DSR.'));
                return null;
            }else  if(SelectedStatusType == 'Reject'){
                DSR_SCEngagement__c dsr = new DSR_SCEngagement__c();
                dsr.SC_Engagement_Status__c = 'Rejected';
                dsr.AssignTo__c = 'AE';
                dsr.Id= dsrEngagement.Id;
                update dsr;
                CreateHistory('SC Request Rejected by Admin/Leader',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),dsr.Id,null),dsr.AssignTo__c,dsr.SC_Engagement_Status__c,dsr.Id);
            }else if(lstclsWrappervirtualTeam.size() > 0  && SelectedStatusType == 'Approve'){
                DSR_SCEngagement__c dsr = new DSR_SCEngagement__c();
                dsr.SC_Engagement_Status__c = 'Open and Assigned';
                dsr.AssignTo__c = 'Virtual Team';
                dsr.Id= dsrEngagement.Id;
                update dsr;
                CreateHistory('Virtual Team Assigned by Lead',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),dsr.Id,null),dsr.AssignTo__c,dsr.SC_Engagement_Status__c,dsr.Id);
                //Send Email Notification to AE and VT members
                DSRUtility.SendEmailNotificationDSR('Wow Accepted',dsr.id,null);
                DSRUtility.SendEmailNotificationDSR('Virtual Team Assigned',dsr.id,null);
            }
        }
        
        //If DSR submitting from VT
        if(dsrEngagement.SC_Engagement_Status__c == 'Open and Assigned' && isVirtualUser){
            //if((dsrEngagement.Lessons_Learned_Feedback__c == null || dsrEngagement.Impact_on_Deal__c == null) && dsrEngagement.Is_Engagement_Feedback__c){
            if(dsrEngagement.Lessons_Learned_Feedback__c == null || dsrEngagement.Impact_on_Deal__c == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill the engagement feedback.'));
                return null;
            }
            DSR_SCEngagement__c dsr = new DSR_SCEngagement__c();
            dsr.SC_Engagement_Status__c = 'Submitted for Completion';
            dsr.AssignTo__c = 'Lead Completed';
            dsr.Id= dsrEngagement.Id;
            //dsr.Smart_Opportunity_Intent_Use__c = strSmartOpp;
            dsr.VirtualTeamNames__c = strAllVTNames;
            update dsr;
            CreateHistory('Virtual Team submitted for Completion',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),dsr.Id,null),dsr.AssignTo__c,dsr.SC_Engagement_Status__c,dsr.Id);
            //Send Email Notification to all Leads
             DSRUtility.SendEmailNotificationDSR('Lead Completed',dsr.id,null);

        }
        
        //if DSR submitting from Admin or Leader
        if(dsrEngagement.SC_Engagement_Status__c == 'Submitted for Completion' && isSubRegional && isAdminUser){
            
            DSR_SCEngagement__c dsr = new DSR_SCEngagement__c();
            dsr.SC_Engagement_Status__c = 'Completed';
            dsr.AssignTo__c = 'AE';
            dsr.Id= dsrEngagement.Id;
            dsr.VirtualTeamNames__c = strAllVTNames;
            update dsr;
            CreateHistory('SC Engagement completed.',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),dsr.Id,null),dsr.AssignTo__c,dsr.SC_Engagement_Status__c,dsr.Id);
            //Send Email Notification to AE
             DSRUtility.SendEmailNotificationDSR('AE',dsr.id,null);
        }
        
        
         // Strat: Changes on 5/11 as requested by Debora
        // Updating pre-sales priority on Opportunity.
        if(opp.StageName != '6.Closed' && dsrEngagement.Pre_Sales_Priority__c != opp.Pre_Sales_Priority__c){
            opp.Pre_Sales_Priority__c = dsrEngagement.Pre_Sales_Priority__c;
            update opp;
        }    
        
        //SendEmailNotification('Virtual Team');
        Pagereference pg = new Pagereference('/apex/SC_Engagement_DSR?id='+dsrId);
        pg.setRedirect(true);
        return pg;
        
    }
    
    /**
    *   Description :   This method used to save data of SC Engagement.
    **/
    public void SaveSCE()
    {
      blnSCRequiredMsj = false;
      blnSCRequiredMsj1 = false;
      isSC = false;//added by priyank on 16 Nov 2018.
      
      if(dsrEngagement.SC_Engagement_Status__c == 'Open and Assigned'){
        if(strSmartOpp != '--None--')
          dsrEngagement.Smart_Opportunity_Intent_Use__c = strSmartOpp;
        update dsrEngagement;
        
        
         // Strat: Changes on 5/11 as requested by Debora
        // Updating pre-sales priority on Opportunity.
        if(opp.StageName != '6.Closed' && dsrEngagement.Pre_Sales_Priority__c != opp.Pre_Sales_Priority__c){
            opp.Pre_Sales_Priority__c = dsrEngagement.Pre_Sales_Priority__c;
            update opp;
        }
        
        system.debug('++++isVirtualUser+++'+isVirtualUser);
        system.debug('++++isAdminUser+++'+isAdminUser);
        string strAllVTNames2 = '';
        /* if logged in user is not VT then it will be able to save Leader and VT records also.*/
        /* VAT can also add VT member : changes on 3-Jan-18 shared by Debora Lane*/ 
        if(isSubRegional || isAdminUser || isAEUser || isVirtualUser || isSalesCOE){
          
          system.debug('++++isSubRegional+++'+isSubRegional);
          system.debug('++++lstclsWrappervirtualTeam+++'+lstclsWrappervirtualTeam);
          //Save VT members
          
           List<DSR_Virtual_Team__c> lstdsrVT = new List<DSR_Virtual_Team__c>();
           List<DSR_Virtual_Team__c> lstUdpate = new List<DSR_Virtual_Team__c>(); 
           if(lstclsWrappervirtualTeam.size() > 0){
           integer ctr=0;
            for(clsWrappervirtualTeam sub :lstclsWrappervirtualTeam){
                ctr += 1;
                //Priyank added the below code on 31/10/2018. to check the primary sol. const.
                if(sub.virtualUserType == 'Solution Consultant'){
                    if(sub.isPrimary== TRUE && sub.virtualUserType== 'Solution Consultant'){
                        blnSCRequiredMsj1 = true;
                    }else{
                        blnSCRequiredMsj = true;
                    }
                }
                //Priyank code end.
                
                if(sub.userID != null && (sub.recordId == null || sub.recordId == '') && (sub.isSaved != null && !sub.isSaved)){
                    sub.isSaved = true;
                    DSR_Virtual_Team__c dsrTean = new DSR_Virtual_Team__c();
                    dsrTean.SCE_ID__c = dsrEngagement.Id;
                    dsrTean.Virtual_Team_Member_Name__c = sub.userID;
                    dsrTean.Virtual_User_Role__c = 'Virtual Team';
                    dsrTean.Assigned_By__c = UserInfo.getUserId();
                    dsrTean.IsPrimary__c =sub.isPrimary;
                    dsrTean.Virtual_User_type__c = sub.virtualUserType;
                    lstdsrVT.add(dsrTean);
                }
                
                
                  if(sub.userID != null && sub.recordId != null && (sub.isSaved != null && !sub.isSaved)){
                    
                    system.debug('#VT5# Entered');
                    sub.isSaved = true;
                    DSR_Virtual_Team__c dsrTean = new DSR_Virtual_Team__c();
                    dsrTean.id = sub.recordId;
                    dsrTean.SCE_ID__c = dsrEngagement.Id;
                    dsrTean.Virtual_Team_Member_Name__c = sub.userID;
                    dsrTean.Virtual_User_Role__c = 'Virtual Team';
                    dsrTean.Assigned_By__c = UserInfo.getUserId();
                    dsrTean.IsPrimary__c =sub.isPrimary;
                    dsrTean.Virtual_User_type__c = sub.virtualUserType;
                    lstUdpate.add(dsrTean);
                }
                
                /************** update VT Name ************/
                if(ctr < lstclsWrappervirtualTeam.size())
                    strAllVTNames2 += sub.virtualuser+',';
                else
                    strAllVTNames2 += sub.virtualuser;
                
                system.debug('++++strAllVTNames2+++'+strAllVTNames2);
            }
            
        }
        
             //Priyank added below if condition to show error message 31/10/2018 as discussed with JJ. 
             if(blnSCRequiredMsj && !blnSCRequiredMsj1){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please make at least one Solution Consultant as Primary.'));
                return;
             }
             // Priyank code end.
             if(lstdsrVT.size() > 0){
                upsert lstdsrVT;
            }
            
             if(lstUdpate.size() > 0){
                update lstUdpate;
            }
            isSC = CheckScUser(UserInfo.getUserId(), sceId);//added by priyank on 16 Nov 2018.
            
            /************* update VT memebers Name in SCE *******************/
            
            DSR_SCEngagement__c dsr2 = new DSR_SCEngagement__c();
            dsr2.VirtualTeamNames__c = strAllVTNames2;
            dsr2.id = dsrEngagement.Id;
            update dsr2;
          
          //Save Sub Regional Leaders
          //Save Sub Regional Leaders
          List<DSR_Virtual_Team__c> lstdsrRegional = new List<DSR_Virtual_Team__c>();
          if(lstclsWrapperSubRegionalLeaders.size() > 0){
            for(clsWrapperSubRegionalLeaders sub :lstclsWrapperSubRegionalLeaders){
                if(sub.userID != null && sub.isSaved != null && !sub.isSaved){
                    sub.isSaved = true;
                    DSR_Virtual_Team__c dsrTean = new DSR_Virtual_Team__c();
                    dsrTean.SCE_ID__c = dsrEngagement.Id;
                    dsrTean.Virtual_Team_Member_Name__c = sub.userID;
                    dsrTean.Virtual_User_Role__c = 'Sub Regional Leader';
                    dsrTean.Assigned_By__c = UserInfo.getUserId();
                    dsrTean.Region__c = sub.region;
                    dsrTean.Sub_Region__c = sub.subregion;
                    dsrTean.Segment__c = sub.segment;
                    dsrTean.Is_Admin__c = sub.isAdmin;
                    lstdsrRegional.add(dsrTean);
                }
            }
          }
          if(lstdsrRegional.size() > 0){
            insert lstdsrRegional;
          }
          //Priyank added below method to capture the Next step last modified date and User. Date 2-Nov-2018.
          List<DSR_SCEngagement__c> dsrObj = [Select Next_Step__c, Next_Step_Modified_By__c, Next_Step_Modified_Date__c FROM DSR_SCEngagement__c WHERE id=:dsrEngagement.id];
          if(dsrObj[0].Next_Step__c != nextStepOldValue ){
              nextStepOldValue = dsrObj[0].Next_Step__c;
              dsrObj[0].Next_Step_Modified_By__c = UserInfo.getUserId();
              dsrObj[0].Next_Step_Modified_Date__c = Date.Today();
              update dsrObj;
              system.debug('>>>###   '+ dsrObj[0].Next_Step_Modified_By__c + '  '+ dsrObj[0].Next_Step_Modified_Date__c);
          }
          //Priyank code end.
        }
      }
      
    }
    
    /*public String SendEmailNotification(string NotificationType){
        String  strResult='Failed';
        system.debug('111 ' +NotificationType);
         if(NotificationType=='Virtual Team Assigned' || NotificationType=='Virtual Team'){ 
             
            //Send Email TO SE,BC and SEM
            Set<Id> set_UId = new Set<Id>();
            
            List<DSR_Virtual_Team__c> objVTUser = [Select Id, Virtual_Team_Member_Name__c, Is_Notification__c from DSR_Virtual_Team__c where SCE_ID__c=:sceid and Virtual_User_Role__c=:'Virtual Team'];
            for(DSR_Virtual_Team__c vtUser : objVTUser){
                if(!vtUser.Is_Notification__c){
                    set_UId.add(vtUser.Virtual_Team_Member_Name__c);
                }
                vtUser.Is_Notification__c = true;
            }
            
            if(objVTUser.size() > 0){
                update objVTUser;
            }
           system.debug('222 ' +set_UId.size());
            List<User> lstUs = [Select id,name,email from User where id IN : set_UId];
            
            //Send Email for SE,BC and SEM
            for(User objU:lstUs){
                system.debug('3333 ' +objU);
                SendEmailByTemplate(objU.Id,'Wow Engagement Virtual Team Assigned',sceId);
            }  
         }
                
        return strResult;
    } */
    
   /* public  String SendEmailByTemplate(Id UserId,String strTemplateName, Id ids){
        string strResult='Failed';
        // try{
            // Create a new single email message object
            // that will send out a single email to the addresses in the To, CC & BCC list.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
            // Specify the name used as the display name.
            mail.setSenderDisplayName('');                   
            // Set to True if you want to BCC yourself on the email.
            mail.setBccSender(false);
            // Optionally append the salesforce.com email signature to the email.
            // The email address of the user executing the Apex Code will be used.
            mail.setUseSignature(false);
            //Map the VF template
            mail.setTargetObjectId(UserId); //Mandatory field when use template
            mail.setWhatId(ids); //Assign Wow Id
            String mailbody = '<html><body> <br/>Dear Virtual Team member, <br/> <br/>' + 
                            'A SC Engagement Deal Support Request for has been submitted and accepted. <br/>' + 
                            'You are receiving this notification because you have been assigned to the Virtual Team to support this engagement.  <br/>Please view the SC Engagement Request Form.'+
                            '<br/> <br/> Thanks.</body></html>';
                            
            mail.setHtmlBody(mailbody);
            //mail.setTemplateId([select id from EmailTemplate where Name =: strTemplateName].id);  //Find the template on the basis of name                    
            // Send the email you have created.
            mail.SaveAsActivity = false; //Mandatory field when use template
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            strResult='Successful';
       // }    
        //catch(exception ex){
            //strResult='Failed';
           // system.debug('ex '+ex.getMessage());
        //} 
         return strResult;        
     } */  
    
    /**
    *   Class Name  :   CheckSubregionalUser()
    *   Description :   This method is used to check the current user status
    *   Parameters  :  
    **/
    public Boolean CheckSubregionalUser(String userId, String dsrId){
        Boolean isRegional = false;
        Integer count = [Select count() from DSR_Virtual_Team__c where SCE_ID__c=:dsrID and Virtual_Team_Member_Name__c=:userId and Virtual_User_Role__c=:'Sub Regional Leader'];
        
        if(count > 0){
            isRegional = true;
        }
        return isRegional;
    }
    
    /**
    *   Class Name  :   CheckSalesCOE()
    *   Description :   This method is used to check the current user as SalesCOE
    *   Parameters  : 
    *   Requested By : Debora Lane 16/April/2018
    **/
    public Boolean CheckSalesCOE(String userEmail){
        Boolean isCOE = false;
        List<Wow_Sub_Regional_Users__c> list_SubRegion= Wow_Sub_Regional_Users__c.getall().values();
        for(Wow_Sub_Regional_Users__c obj : list_SubRegion)
        {
           if(obj.Subregional_Leader__c == userEmail && obj.Sales_COE__c)
            isCOE = true;
        }
        return isCOE;
    }
    
    
    /**
    *   Method Name :   reOpen()
    *   Description :   This method used to show the Sub Reginal Leades Popup
    *   Parameters  :  
    **/
    
    public Pagereference reOpen() { 
        dsrEngagement.SC_Engagement_Status__c = 'Open and Assigned';
        dsrEngagement.Is_ReOpen__c = true;
        dsrEngagement.AssignTo__c = 'Lead Assign';
        
        update dsrEngagement;
        CreateHistory('SC Engagement Re-opened.',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),dsrEngagement.Id,null),dsrEngagement.AssignTo__c,dsrEngagement.SC_Engagement_Status__c,dsrEngagement.Id);
        
        Pagereference pg = new Pagereference('/apex/SC_Engagement_DSR?id='+dsrEngagement.Id);
        pg.setRedirect(true);
        return pg;
         
    }
    
    /**
    *   Method Name :   CloseDSR()
    *   Description :   This method used to close the DSR 
    *   Parameters  :  
    **/
    
    public Pagereference CloseDSR() { 
    
        Pagereference pg = new Pagereference('/apex/SC_Engagement_DSR?id='+dsrEngagement.Id);
        /*if((dsrEngagement.Impact_on_Deal__c == null || dsrEngagement.Lessons_Learned_Feedback__c == null) || !dsrEngagement.Is_Engagement_Feedback__c)
        {
           ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please fill the engagement feedback.'));
           pg = null;
        }
        else
        {*/
            dsrEngagement.SC_Engagement_Status__c = 'Completed';
            update dsrEngagement;
            
            CreateHistory('SC Engagement completed.',UserInfo.getUserId(),WoWUtility.GetUserType(UserInfo.getUserId(),dsrEngagement.Id,null),dsrEngagement.AssignTo__c,dsrEngagement.SC_Engagement_Status__c,dsrEngagement.Id);
            
            //Send Email Notification to AE
             DSRUtility.SendEmailNotificationDSR('AE',dsrEngagement.id,null);
            
            
            pg.setRedirect(true);
            
        //}
        return pg; 
    }
    
    /**
    *   Class Name  :   CheckVTUser()
    *   Description :   This method is used to check the current user status
    *   Parameters  :  
    **/
    public Boolean CheckVTUser(String userId, String dsrId){
        Boolean isVT = false;
        
        Integer count = [Select count() from DSR_Virtual_Team__c where SCE_ID__c=:dsrID and Virtual_Team_Member_Name__c=:userId and Virtual_User_Role__c=:'Virtual Team'];
        
        if(count > 0){
            isVT = true;
        }
        return isVT;
    }
    
    /** Added bt Priyank
    *   Class Name  :   CheckVTUser()
    *   Description :   This method is used to check the current user status
    *   Parameters  :  
    **/
    public Boolean CheckScUser(String userId, String dsrId){
        Boolean isSC1 = false;
        
        Integer count = [Select count() from DSR_Virtual_Team__c where SCE_ID__c=:dsrID and Virtual_Team_Member_Name__c=:userId and Virtual_User_Role__c = 'Virtual Team' and Virtual_User_type__c  = 'Solution Consultant'];
        
        if(count > 0){
            isSC1 = true;
        }
        return isSC1 ;
    }
    
    
    /**
    *   Class Name  :   CheckAEUser()
    *   Description :   This method is used to check the current user status
    *   Parameters  :  
    **/
    public Boolean CheckAEUser(String userId, String dsrId){
        Boolean isAE = false;
        Integer count = [Select count() from DSR_SCEngagement__c where ID=:dsrID and AE_Name__c=:userId];
        
        if(count > 0){
            isAE = true;
        }
        return isAE;
    }
    
    /**
    *   Class Name  :   CheckAdminUser()
    *   Description :   This method is used to check the current user status
    *   Parameters  :  
    **/
    public Boolean CheckAdminUser(String userId, String dsrId){
        Boolean isAdmin = false;
        
        Integer count = [Select count() from User where Id=:UserId and Profile.Name =: 'System Administrator'];
        if(count > 0){
            isAdmin = true;
        }
        return isAdmin;
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
    *   Added By    :   Amit Singh (05/21/2018)
    *   Class Name  :   CreateHistory()
    *   Description :   This method is used to redirect the user to Partner DSR page if DSR is a partner record.
    *   Parameters  :  NA
    **/
    public Pagereference invokeDSRPage(){
        String dsrSCId = ApexPages.CurrentPage().getParameters().get('id');
        Pagereference pg;
        if(dsrSCId != null){
            List<DSR_SCEngagement__c> lstDsr = [SELECT Id, Is_Partner_DSR__c FROM DSR_SCEngagement__c WHERE Id=: dsrSCId];            
            if(lstDsr.size() > 0 && lstDsr.get(0).Is_Partner_DSR__c){
                if(UserInfo.getUserType() == 'PowerPartner'){
                    pg = new Pagereference('/partner/SC_EngagementPartner_DSR?id='+dsrSCId);
                }
                /*else{
                    pg = new Pagereference('/apex/SC_EngagementPartner_DSR?id='+dsrSCId);
                }*/
            }
        }
        return pg;
    }
    
    
    /**
    *   Added BY    :   Ashish Goyal (11/21/18)
    *   Method Name :   showSubRegionalLeaders()
    *   Description :   This method used to show the Copy DSR Popup
    *   Parameters  :  
    **/
    
    public void showCopyDSRPopup() { 
        copyDSRObj = new CopyDSR();
        displayCopyDSRPopUP = true;    
    }
    
    
    
    /**
    *   Added BY    :   Ashish Goyal (11/21/18)
    *   Method Name :   cancelCopyDSRPopup()
    *   Description :   This method used to show the Copy DSR Popup
    *   Parameters  :  
    **/
    
    public void cancelCopyDSRPopup() {
        displayCopyDSRPopUP = false;    
    }
    
    
    /**
    *   Added BY    :   Ashish Goyal (11/27/18)
    *   Method Name :   enableDesignCopy()
    *   Description :   This method used to cenable the design options
    *   Parameters  :  
    **/
    public void enableDesignCopy(){
        if(copyDSRObj.isPrimaryDesign || copyDSRObj.isAllDesign){
            copyDSRObj.enableDesign = true;
        }else{
            copyDSRObj.enableDesign = false;
        }
    }
    
    
    
    /**
    *   Added BY    :   Ashish Goyal (11/22/18)
    *   Method Name :   copyDSRFromDSR()
    *   Description :   This method used to copy attachments from DSR1 to DSR2.
    *   Parameters  :  
    **/
    public void copyDSRFromDSR(){
        if(copyDSRObj.dsrName != null){
            String dsrName = copyDSRObj.dsrName.trim();
            // fetching the respective SC DSR details
            System.debug('------------------------------------------dsrEngagement.Name-----   '+dsrEngagement.Name);
            System.debug('------------------------------------------dsrNamee-----   '+dsrName);
            List<DSR_SCEngagement__c> list_DSR = new List<DSR_SCEngagement__c>([SELECT Id, Name, SC_Engagement_Status__c,Primary_Design_ID__c , (SELECT Access__c, AttachmentType__c, AttachmentURL__c, DateofAttachment__c, Description__c, DocumentId__c, DSRSCEDesign__c, 
                                                                                    DSRSCEngagement__c, ObjectType__c, Source__c, Notes__c FROM DSR_Attachments__r),
                                                                                    (SELECT Id, BusinessDesignProfile__c, DataCenters__c, HAType__c, Design_Source__c, DSR_SCEngagement__c, IsPrimary__c, Name__c,
                                                                                    OfferingPlatformType__c, PrimaryDesign__c, Notes__c, TechnicalDesignProfile__c FROM DSR_SCE_Designs__r),
                                                                                    (SELECT Id, DSRSCEngagement__c, Fit__c, FitCategory__c, Name__c, Notes__c, ShortChangeDescription__c, ShortCode__c, Type__c, VersionUsed__c, 
                                                                                    DSRSCEDesign__c, DetailedChangeDescription__c FROM DSR_Use_Case_Blueprints__r),
                                                                                    (SELECT Id FROM DSR_Virtual_Teams__r WHERE Virtual_Team_Member_Name__c =: UserInfo.getUserId() AND Virtual_User_Role__c = 'Virtual Team') 
                                                                                    FROM DSR_SCEngagement__c 
                                                                                    WHERE Name =:dsrName]); //AND (SC_Engagement_Status__c = 'Open and Assigned' OR SC_Engagement_Status__c = 'Submitted for Completion' 
                                                                                        //OR SC_Engagement_Status__c = 'Completed')]);
            if(list_DSR.size() > 0 ){
                if(list_DSR.get(0).Name != dsrEngagement.Name){
                    if(list_DSR.get(0).DSR_Virtual_Teams__r.size() > 0){
                        DSR_SCEngagement__c scEngageDSR = list_DSR.get(0);
                        if(scEngageDSR.SC_Engagement_Status__c == 'Open and Assigned' || scEngageDSR.SC_Engagement_Status__c == 'Submitted for Completion' || scEngageDSR.SC_Engagement_Status__c == 'Completed'){                      
                            Map<Id, DSR_SCE_Design__c> map_DesignInsert = new Map<Id, DSR_SCE_Design__c>();
                            List<DSR_Attachments__c> list_AttachmentInsert = new List<DSR_Attachments__c>();
                            List<DSR_Use_Case_Blueprints__c> list_UseCaseBlueprints = new List<DSR_Use_Case_Blueprints__c>();
                            
                            // Initialise the count variable for the SCE DSR
                            
                            Decimal visionCount = dsrEngagement.VisionActivityCount__c != null ? dsrEngagement.VisionActivityCount__c : 0;
                            Decimal deliverCount = dsrEngagement.DeliveryCount__c != null ? dsrEngagement.DeliveryCount__c : 0;
                            Decimal discoveryCount = dsrEngagement.DiscoveryCount__c != null ? dsrEngagement.DiscoveryCount__c : 0;
                            Decimal businessCount = 0;
                            Decimal technicalCount = 0;
                            Decimal designCount = dsrEngagement.DesignCount__c != null ? dsrEngagement.DesignCount__c : 0;
                            
                            List<DSR_SCE_Design__c> list_PrimaryDesign = new List<DSR_SCE_Design__c>([SELECT Id FROM DSR_SCE_Design__c WHERE IsPrimary__c = true AND DSR_SCEngagement__c =: dsrEngagement.Id]);
                            
                            // Iterating the designs and associating with SCE DSR
                            
                            for(DSR_SCE_Design__c scDesign : scEngageDSR.DSR_SCE_Designs__r){
                                System.debug('--copyDSRObj.isPrimaryDesign---'+copyDSRObj.isPrimaryDesign);
                                System.debug('--scDesign.IsPrimary__c---'+scDesign.IsPrimary__c);
                                if((copyDSRObj.isPrimaryDesign && scDesign.IsPrimary__c) || copyDSRObj.isAllDesign){
                                    DSR_SCE_Design__c scDesign2 = scDesign.clone();
                                    scDesign2.DSR_SCEngagement__c = dsrEngagement.Id;
                                    if(list_PrimaryDesign.size() > 0 && scDesign2.IsPrimary__c){
                                        scDesign2.IsPrimary__c = false;
                                    }                       
                                    map_DesignInsert.put(scDesign.Id, scDesign2);
                                    designCount ++;
                                }
                            }
                            if(map_DesignInsert.size() > 0){
                                insert map_DesignInsert.values();
                                for(DSR_SCE_Design__c scDesign : map_DesignInsert.Values()){
                                    if(copyDSRObj.isPrimaryDesign && scDesign.IsPrimary__c){
                                        dsrEngagement.Primary_Design_ID__c = scDesign.id;
                                    }
                                }
                            }
                            
                            // Iterating Activities and associating with SCE DSR
                            
                            for(DSR_Attachments__c dsrAttach : scEngageDSR.DSR_Attachments__r){
                                
                                // If vision activity
                                if(copyDSRObj.isVision && dsrAttach.DSRSCEDesign__c == null && dsrAttach.ObjectType__c == 'Vision Activity'){
                                    DSR_Attachments__c dsrAttach2 = dsrAttach.clone();
                                    dsrAttach2.DSRSCEngagement__c = dsrEngagement.Id;
                                    list_AttachmentInsert.add(dsrAttach2);
                                    visionCount ++;
                                    dsrEngagement.Has_Vision_Activities__c = true;
                                }
                                
                                // If Discovery activity
                                if(copyDSRObj.isDiscovery && dsrAttach.DSRSCEDesign__c == null && dsrAttach.ObjectType__c == 'Discovery Activity'){
                                    DSR_Attachments__c dsrAttach2 = dsrAttach.clone();
                                    dsrAttach2.DSRSCEngagement__c = dsrEngagement.Id;
                                    list_AttachmentInsert.add(dsrAttach2);                      
                                    discoveryCount ++;
                                    dsrEngagement.Has_Discovery_Activities__c = true;
                                    
                                }
                                
                                // If Deliver activity
                                if(copyDSRObj.isDelivery && dsrAttach.DSRSCEDesign__c == null && (dsrAttach.ObjectType__c == 'Delivery Requirements' || dsrAttach.ObjectType__c == 'Service Transition Activity')){
                                    DSR_Attachments__c dsrAttach2 = dsrAttach.clone();
                                    dsrAttach2.DSRSCEngagement__c = dsrEngagement.Id;
                                    list_AttachmentInsert.add(dsrAttach2);  
                                    deliverCount ++;
                                    dsrEngagement.Has_Delivery_Activities__c = true;
                                }
                                
                                // If Business Attachments
                                if(copyDSRObj.isBusiness && dsrAttach.DSRSCEDesign__c != null && dsrAttach.ObjectType__c == 'Business Design Attachment'){
                                    if(map_DesignInsert.containsKey(dsrAttach.DSRSCEDesign__c)){
                                        DSR_Attachments__c dsrAttach2 = dsrAttach.clone();
                                        dsrAttach2.DSRSCEngagement__c = dsrEngagement.Id;
                                        dsrAttach2.DSRSCEDesign__c = map_DesignInsert.get(dsrAttach.DSRSCEDesign__c).Id;
                                        list_AttachmentInsert.add(dsrAttach2);
                                        businessCount ++;
                                    }
                                }
                                
                                // If technical attachments
                                if(copyDSRObj.isTechnical && dsrAttach.DSRSCEDesign__c != null && dsrAttach.ObjectType__c == 'Technical Design Attachment'){
                                    if(map_DesignInsert.containsKey(dsrAttach.DSRSCEDesign__c)){
                                        DSR_Attachments__c dsrAttach2 = dsrAttach.clone();
                                        dsrAttach2.DSRSCEngagement__c = dsrEngagement.Id;
                                        dsrAttach2.DSRSCEDesign__c = map_DesignInsert.get(dsrAttach.DSRSCEDesign__c).Id;
                                        list_AttachmentInsert.add(dsrAttach2);
                                        technicalCount ++;
                                    }
                                }
                                
                                // If Design General Background activity
                                if(dsrAttach.DSRSCEDesign__c == null && dsrAttach.ObjectType__c == 'Design Activity' && (copyDSRObj.isPrimaryDesign || copyDSRObj.isAllDesign)){
                                    DSR_Attachments__c dsrAttach2 = dsrAttach.clone();
                                    dsrAttach2.DSRSCEngagement__c = dsrEngagement.Id;
                                    list_AttachmentInsert.add(dsrAttach2);  
                                    //designCount ++;
                                    dsrEngagement.Has_Design_Activities__c = true;
                                }
                                
                                // Updating DSR details.
                                
                                dsrEngagement.DesignCount__c = designCount;
                                dsrEngagement.DeliveryCount__c = deliverCount;                  
                                dsrEngagement.VisionActivityCount__c = visionCount;                 
                                dsrEngagement.DiscoveryCount__c = discoveryCount;
                            }
                            
                            //Inserting new Activities
                            if(list_AttachmentInsert.size() > 0){
                                insert list_AttachmentInsert;
                            }
                            
                            // Iteraing the Use case and Blueprints
                            if(copyDSRObj.isPrimaryDesign || copyDSRObj.isAllDesign){
                                for(DSR_Use_Case_Blueprints__c useCase : scEngageDSR.DSR_Use_Case_Blueprints__r){
                                    if(map_DesignInsert.containsKey(useCase.DSRSCEDesign__c)){
                                        DSR_Use_Case_Blueprints__c useCase2 = useCase.clone();
                                        if(useCase.Type__c == 'Use Case'){
                                            useCase2.Notes__c = 'Copied use case – please validate: ' + useCase2.Notes__c;
                                        }else{
                                            useCase2.Notes__c = 'Copied blueprint – please validate: ' + useCase2.Notes__c;
                                        }
                                        useCase2.DSRSCEngagement__c = dsrEngagement.Id;
                                        useCase2.DSRSCEDesign__c = map_DesignInsert.get(useCase.DSRSCEDesign__c).Id;
                                        list_UseCaseBlueprints.add(useCase2);
                                    }
                                }
                            }
                            
                            // inserting the Use case and Blueprints
                            if(list_UseCaseBlueprints.size() > 0){
                                insert list_UseCaseBlueprints;
                            }
                            
                            update dsrEngagement;
                            CreateHistory('Content copied from '+dsrName, UserInfo.getUserId(), WoWUtility.GetUserType(UserInfo.getUserId(),dsrEngagement.Id,null), dsrEngagement.AssignTo__c, dsrEngagement.SC_Engagement_Status__c, dsrEngagement.Id);
                        }
                        else{
                            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'DSR status is not valid to copy.'));
                            return;
                        }
                    }
                    else{
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You are not added in Virtul Team to the given DSR.'));
                        return;
                    }
                }
                else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'You can not copy activites from same DSR.'));
                    return;
                }
            }else{
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'This DSR does not exists.'));
                return;
            }
        }
        displayCopyDSRPopUP = false; 
    }
    
    
    /* Added by     :    Priyank
    * Description   :    AutoSearch on Copy DSR Input Field
    **/
    @RemoteAction
    public static List<DSRWrapper> autoSearchDsrList(String value){
        system.debug('---   '+value);
        List<DSRWrapper > lstDSR = new List<DSRWrapper>();
        if(String.isNotBlank(value)){
            value= value+'%';
            system.debug('lstAccount  '+value);
            for(DSR_SCEngagement__c dsrObj : [Select name FROM DSR_SCEngagement__c WHERE name LIKE:value LIMIT 10]){
                lstDSR.add(new DSRWrapper(dsrObj.id,dsrObj.Name));
            }
            system.debug('---   '+lstDSR );
        }
        return lstDSR;
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
        public string smartFlagExplanation{get;set;}
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
    
    /**
    *   Class Name  :   clsWrapperSubRegionalLeaders()
    *   Description :   This class is used to show the Sub Regional Leaders 
    *   Parameters  :  
    **/
    public class clsWrapperSubRegionalLeaders{
        public String leaderName{get;set;}
        public string region{get;set;}
        public String subregion{get;set;}
        public string segment{get;set;}
        public string userID{get;set;}
        public String notes{get;set;}
        public Boolean isAdmin{get;set;}
        public String key{get;set;}
        public String recordId{get;set;}
        public boolean isSaved{get;set;}
        
        
        
    }
    
    /**
    *   Class Name  :   clsWrapperSubRegionalLeadersall()
    *   Description :   This class is used to show the All Custom Setting Sub Regional Leaders 
    *   Parameters  :  
    **/
    public class clsWrapperSubRegionalLeadersall{
        public String leaderName{get;set;}
        public string region{get;set;}
        public String subregion{get;set;}
        public string segment{get;set;}
        public string userID{get;set;}
        public String notes{get;set;}
        public Boolean addRemove{get;set;}
        public Boolean isAdmin{get;set;}
        public String key{get;set;}
        public String recordId{get;set;}
    }
    
    /**
    *   Class Name  :   clsWrappervirtualTeam()
    *   Description :   This class is used to show the Sub Regional Leaders 
    *   Parameters  :  
    **/
    public class clsWrappervirtualTeam{
        public String virtualuser{get;set;}
        public string virtualUserType{get;set;}
        public String notes{get;set;}
        public Boolean isPrimary{get;set;}
        public string useriD{get;set;}
        public String recordId{get;set;}
        public boolean isSaved{get;set;}
    }
    
    
     /**
    *   Added By    :   Ashish Goyal (11/22/18)
    *   Class Name  :   CopyDSR
    *   Description :   This class is used to show the copy DSR options
    *   Parameters  :  
    **/
    public class CopyDSR {
        public String dsrName {get; set;}
        public boolean isVision {get; set;}
        public boolean isDiscovery {get; set;}
        public boolean isDelivery {get; set;}
        public boolean isBusiness {get; set;}
        public boolean isTechnical {get; set;}
        public boolean isPrimaryDesign {get; set;}
        public boolean isAllDesign {get; set;}
        public boolean enableDesign {get; set;}
        
        public CopyDSR(){
            enableDesign = false;
            isVision = false;
            isDiscovery = false;
            isDelivery = false;
            isBusiness = false;
            isTechnical = false;
            isPrimaryDesign = false;
            isAllDesign = false;
        }
    }
    
        
    public class DSRWrapper {
        public String label {get;set;}
        public String value {get;set;}
        
        public DSRWrapper(String value, String label){
            this.label = label;
            this.value = value;  
        }
    }
    
}