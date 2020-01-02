public class DSRUtility{
  
    public static boolean blnMain; 
    public static boolean btnSave;
    public static boolean btnSubmit;
    public static boolean AESection_RO;
    public static boolean LeadSection_RO;
    public static boolean VTSection_RO;
    public static boolean StatusSection_RO;
    public static boolean EngFeedSection{get;set;}
    public static boolean EngFeedSection_RO{get;set;}
    
    public static boolean AESection;
    public static boolean LeadSection;
    public static boolean VTSection;
    public static boolean StatusSection;
    
    
    public static boolean blnShowCancel{get;set;}
    public static boolean blnShowAssementLink;
    public static boolean blnLeadApproveReject;
    
    public static List<DSRDataDefinition__c> GetDataDefinition(string strModuleName,string strSubModule){
    
        List<DSRDataDefinition__c>list_DataDef = [select id,Description__c,DSRType__c,Header__c,Module__c,OfferPlatformType__c,SubModule__c,URL_Required__c from DSRDataDefinition__c where Module__c =:strModuleName and SubModule__c =: strSubModule and IsActive__c =: true];
       
        return list_DataDef ;
    }
    
    public static string GetProfileName(Id ProfileId){
        String profileName=[Select Id,Name from Profile where Id=:ProfileId].Name;
        return profileName;
    }
    
    public static boolean GlobalUser(string uId){
        boolean blnIsGlobal = false; 
        Group objGroup = [Select Id from Group where type=: 'Regular' and Name=: 'Wow Admin Group'];
        List<GroupMember> list_GroupMem = new List<GroupMember>(); 
        list_GroupMem =[Select UserOrGroupId From GroupMember where GroupId =: objGroup.id];                   
        Set<string> objUID=new Set<string>();
        for(GroupMember obj: list_GroupMem){
            objUID.Add(obj.UserOrGroupId );
            if(obj.UserOrGroupId == uId)
                blnIsGlobal = true;
        } 
        return blnIsGlobal;   
    }
    
    public static boolean  getSubRegionalUsersForSC(string LogInUser, String sceId){
        boolean IsExist=false;
        List<DSR_Virtual_Team__c> dsrVirtualTeam =  [Select Id from DSR_Virtual_Team__c where SCE_ID__c =: sceId and Virtual_User_Role__c =:'Sub Regional Leader' and Virtual_Team_Member_Name__c =:LogInUser];
        if(dsrVirtualTeam.size() > 0){
            IsExist = true;
        }
        return IsExist;
    }
    
    public static boolean IsVirtualTeamExist(string sceId,string LogInUser){
        boolean IsExist=false;         
        List<DSR_Virtual_Team__c> dsrVirtualTeam =  [Select Id from DSR_Virtual_Team__c where SCE_ID__c =: sceId and Virtual_User_Role__c =:'Virtual Team' and Virtual_Team_Member_Name__c =:LogInUser];
        if(dsrVirtualTeam.size() > 0){
            IsExist = true;
        }           
        return IsExist;
    }  
    
    public static boolean  HasReadAccessibility(Id ProfileId){
        boolean hasAccess = false;
        List<WowAdminAccess__c> list_Access= WowAdminAccess__c.getall().values();
        List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id=:ProfileId LIMIT 1];
        String profileName = PROFILE[0].Name;
        if(list_Access.size()>0)
            for(WowAdminAccess__c objAccess : list_Access){
                if(objAccess.Profile_Name__c==profileName && objAccess.IsAccessible__c == true)
                    hasAccess = true;
            }
        return hasAccess;
    }   
    
   
   public static void SetVisibility(DSR_SCEngagement__c objWowReqFrm,Opportunity objOpportunity )
   {}
   
   
   
    /*public static Map<string,boolean> SetVisibility(DSR_SCEngagement__c objWowReqFrm,Opportunity objOpportunity ,string strStatus){
    
        boolean blnAE=false;
        boolean blnLead=false;
        boolean blnVirtualTeam=false;
        blnMain=false;
        
        btnSave=true;
        btnSubmit=true;
        Map<string,boolean>map_Status = new Map<string,boolean>();
        
        
        //Get LoggedIn user profile name
        string sProfileName = GetProfileName(userinfo.getProfileId());
        
        //if record exist in WoW request form
        if(objWowReqFrm!=null)  {
        
            // Custom setting  WowAdminAccess__c//
            List<WowAdminAccess__c> lstCstSetting = WowAdminAccess__c.getall().values(); 
            WowAdminAccess__c adminAccessibility= WowAdminAccess__c.getInstance('System Administrator');
            
            // check loggedin as Global user or not //
            boolean blnIsGlobal = false;
            blnIsGlobal = WoWUtility.GlobalUser(UserINfo.getUserId());
            
            if(blnIsGlobal)
                sProfileName = 'System Administrator';
            
            if(sProfileName =='System Administrator' && adminAccessibility.IsAccessible__c== true){
                blnLead  = true;
                blnVirtualTeam=true;
                blnAE=true;
                system.debug('***gggg');
            
            }else if(getSubRegionalUsersForSC(UserINfo.getUSerId(), objWowReqFrm.Id)){        
                blnLead=true;  
            }else if((IsVirtualTeamExist(objWowReqFrm.Id,UserINfo.getUserId()) && objWowReqFrm.Id != null)|| (sProfileName =='System Administrator' && adminAccessibility.IsAccessible__c == true)){
                blnVirtualTeam=true;
            }else if(objOpportunity.Owner.Id==UserINfo.getUserId() || (sProfileName =='System Administrator' && adminAccessibility.IsAccessible__c == true)){
                blnAE=true;
            } 
            
            if(blnAE || blnLead || blnVirtualTeam || (sProfileName =='System Administrator' && adminAccessibility.IsAccessible__c == true) || WoWUtility.HasReadAccessibility(UserINfo.getProfileId())){
                blnMain=true;
            }
           // if(HasReadAccessibility(UserINfo.getProfileId()) && objWowReqFrm.AssignTo__c != '' && objWowReqFrm.AssignTo__c != null){
            if( objWowReqFrm.AssignTo__c != '' && objWowReqFrm.AssignTo__c != null){
                if(objWowReqFrm.AssignTo__c == 'Lead Assign'){
                    AESection_RO = true;
                    LeadSection_RO = false;
                    VTSection_RO = false;
                    StatusSection_RO =true;
                    
                    map_Status.put('',true);
                    map_Status.put('Lead Assign',true);
                    map_Status.put('Virtual Team',false);
                    map_Status.put('Lead Completed',false);
                    map_Status.put('AE',false); 
                    
                }else if(objWowReqFrm.AssignTo__c == 'Virtual Team'){
                    AESection_RO = true;
                    LeadSection_RO = true;                 
                    VTSection_RO = true;
                    StatusSection_RO =true;
                    
                    map_Status.put('',false);
                    map_Status.put('Lead Assign',false);
                    map_Status.put('Virtual Team',true);
                    map_Status.put('Lead Completed',false);
                    map_Status.put('AE',false);
                    
                }else if(objWowReqFrm.AssignTo__c == 'Lead Completed' || objWowReqFrm.AssignTo__c == 'Completed'){                 
                    AESection_RO = true;
                    LeadSection_RO = true;
                    VTSection_RO = true;
                    StatusSection_RO =true; 
                    map_Status.put('',false);
                    map_Status.put('Lead Assign',false);
                    map_Status.put('Virtual Team',true);
                    map_Status.put('Lead Completed',true);
                    map_Status.put('AE',false);                
                }else if(objWowReqFrm.AssignTo__c == 'AE'){
                    AESection_RO = true;
                    LeadSection_RO = true;
                    VTSection_RO = true;
                    StatusSection_RO =true;
                }       
            }
            
            if((objWowReqFrm.AssignTo__c == '' || objWowReqFrm.AssignTo__c == null) && blnAE){
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
            }else if(objWowReqFrm.AssignTo__c == 'Lead Assign' && blnLead && strStatus == 'Open and Assigned'){
                AESection = false;
                LeadSection = true;
                VTSection = true;
                StatusSection=false;
                btnSave=false;
                btnSubmit=false;
                
                AESection_RO = true;
                LeadSection_RO = false;
                VTSection_RO = false;
                StatusSection_RO =true;
                blnLeadApproveReject = true;
            //}else if(objWowReqFrm.AssignTo__c == 'Virtual Team' && (blnVirtualTeam || blnLead)){
            }else if(objWowReqFrm.AssignTo__c == 'Virtual Team' ){
                map_Status.put('',false);
                map_Status.put('Lead Assign',false);
                map_Status.put('Virtual Team',true);
                map_Status.put('Lead Completed',false);
                map_Status.put('AE',false);
            }else if((objWowReqFrm.AssignTo__c == 'Lead Completed' || objWowReqFrm.AssignTo__c == 'Completed') && blnLead ){
                AESection = false;
                LeadSection = false;
                VTSection = true;
                StatusSection=true;
                btnSave=true;
                btnSubmit=false; // change 23 may
                
                AESection_RO = true;
                LeadSection_RO = true;
                VTSection_RO = true;
                StatusSection_RO =false;
            
            }
            else if(objWowReqFrm.AssignTo__c == 'AE' && blnLead){
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
            }else if(objWowReqFrm.AssignTo__c == 'AE' && blnAE){
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
            
            if(objWowReqFrm.AssignTo__c == 'Lead Completed' && blnLead){
                EngFeedSection = true;
                EngFeedSection_RO = false;
            }
            if((objWowReqFrm.AssignTo__c == 'AE' ||sProfileName =='System Administrator') && !blnAE){
                EngFeedSection = false;
                EngFeedSection_RO = true;
            }
            if(objWowReqFrm.AssignTo__c == 'AE' && (sProfileName =='System Administrator' || blnAE))
                EngFeedSection_RO = true;
        }
        
       return map_Status;
    }*/

     public static Void CreateHistory(string Action,string UserId, string UserType, string WowStage,string Status, Id WowId){
        DSR_SC_Engagement_History__c objWoWHst=new DSR_SC_Engagement_History__c();
        objWoWHst.Action__c=Action;
        objWoWHst.ActionPerformedBy__c=UserId;
        objWoWHst.ActionDate__c=Date.Today();
        objWoWHst.UserType__c=UserType;
        objWoWHst.SCEngagementStatus__c =Status;
        objWoWHst.DSRSCEngagement__c=WowId;
        objWoWHst.SCEngagementStage__c=GetWowStage(WowStage);
        insert objWoWHst;
    }

    
    public static Void CreateHistory(string Action,string AttachmentType, string AttachmentSubType, string UserId, string UserType, string WowStage,string Status, Id WowId){
        DSR_SC_Engagement_History__c objWoWHst=new DSR_SC_Engagement_History__c();
        objWoWHst.Action__c=Action;
        objWoWHst.ActionPerformedBy__c =UserId;
        objWoWHst.ActionDate__c=Date.Today();
        objWoWHst.UserType__c=UserType;
        objWoWHst.SCEngagementStage__c=GetWowStage(WowStage);
        objWoWHst.SCEngagementStatus__c  =Status;
        objWoWHst.DSRSCEngagement__c = WowId;
        objWoWHst.Attachment_Type__c = attachmenttype;
        objWoWHst.Attachment_Sub_Type__c = attachmentsubtype;
        insert objWoWHst;
    }
    public static string GetWowStage(string WowStage)
    {
        string strWowStage=WowStage;
        
        if(strWowStage=='Lead Assign' || strWowStage=='Lead Completed')
            strWowStage='Leadership Queue';
        
        return strWowStage;
    }
    
    public static String SendEmailNotificationDSR(string NotificationType, Id WowId,List<WoW_Virtual_Users__c> list_VT){
        string strResult='Failed';

        list<User> lstUser=new list<User>();
        String[] aryUser = new String[]{}; 
        //string strUserType='';
        //list<MsgInfo> lstMsgInfo=new list<MsgInfo>();
        list<WoW_Virtual_Users__c> list_OldVT = new  list<WoW_Virtual_Users__c>();
        //Find current user and user name
        User Usr = new User();
        Usr = [SELECT Id,Name FROM User WHERE Id = : UserInfo.getUserId()];

        //Find the opportunity region
        list<DSR_SCEngagement__c> lstWoW=[SELECT Id,Opportunity_Id__c,Opportunity_Id__r.Lines_of_Businesses__c,Opportunity_Id__r.Owner.Segment__C, Opportunity_Id__r.Owner.Id,Opportunity_Id__r.Region__c,Opportunity_Id__r.Name,Opportunity_Id__r.Owner.Name,Opportunity_Id__r.Owner.Owner_Sub_Region__c, Opportunity_Id__r.Owner.Email,Opportunity_Id__r.End_User_Region__c,Opportunity_Id__r.Country_Sub_Region__c,lastModifieddate FROM DSR_SCEngagement__c WHERE Id=:WowID]; 
        
        //Find the account Name from opportunity 
        list<Opportunity> lstOpp=[SELECT Account.Name FROM Opportunity WHERE Id=:lstWoW[0].Opportunity_Id__c];
        
        List<DSR_Virtual_Team__c>lst_Leader = new List<DSR_Virtual_Team__c>();
        try{ 
                if(NotificationType=='Lead Assigned' || NotificationType=='Lead Completed') //then find the members and their email ids in queue
                {
                    lst_Leader= [select id,Virtual_Team_Member_Name__c from DSR_Virtual_Team__c where SCE_ID__c =: WowId and Virtual_User_Role__c=:'Sub Regional Leader'];
                    
                 
                    if(NotificationType=='Lead Assigned')
                    { 
                        for(DSR_Virtual_Team__c objUser: lst_Leader)
                        {
                           SendEmailByTemplate(objUser.Virtual_Team_Member_Name__c ,'SCE Lead Assigned',objUser.id);                                             
                        }                    
                     }
                } 
                if(NotificationType=='Virtual Team Assigned' || NotificationType=='Virtual Team')
                { 
                    //Send Email TO SE,BC and SEM
                    Set<Id>set_UId = new Set<Id>();
                    
                    List<DSR_Virtual_Team__c>list_VTUsers = [select id,Virtual_Team_Member_Name__c from DSR_Virtual_Team__c where SCE_ID__c =: WowId and Virtual_User_Role__c =: 'Virtual Team'];
                    //Send Email for SE,BC and SEM
                    for(DSR_Virtual_Team__c objU : list_VTUsers)
                    {
                      SendEmailByTemplate(objU.Virtual_Team_Member_Name__c ,'SCE Virtual Team Assigned',objU.id);
                    }  
                 }
                 if (NotificationType=='Lead Submitted') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'SCE Lead Submitted',lstWoW[0].Id);                     
                 } 
                 if (NotificationType=='WoW Rejected') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'SCE Lead Rejected',lstWoW[0].Id);                      
                 }
                 if (NotificationType=='WoW Accepted') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'SCE Lead Accepted',lstWoW[0].Id);                     
                 }
                 if (NotificationType=='Lead Completed') 
                 {
                      //added user in send to array
                    for(DSR_Virtual_Team__c objUser: lst_Leader)
                    {
                       SendEmailByTemplate(objUser.Virtual_Team_Member_Name__c ,'SCE Lead Completed',objUser.Id);                                             
                    }
                 } 
                 if (NotificationType=='AE') 
                 {
                      SendEmailByTemplate(lstWoW[0].Opportunity_Id__r.Owner.Id,'SCE AE',lstWoW[0].Id);                    
                 }
                 
                 system.debug('+++NotificationType+++'+NotificationType);                
                  strResult='Successful';   
           }
       catch(exception ex)
           {
               strResult='Failed';
           }           
        return strResult;
    } 
    
    public static String SendEmailByTemplate(Id UserId,String strTemplateName, Id WowId){
          string strResult='Failed';
             try{
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
                    mail.setWhatId(WowId); //Assign Wow Id
                    mail.setTemplateId([select id from EmailTemplate where Name =: strTemplateName].id);  //Find the template on the basis of name                    
                    // Send the email you have created.
                    mail.SaveAsActivity = false; //Mandatory field when use template
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
         
    public static void ShareSCERequest(List<DSR_Virtual_Team__c >list_VT)
     {
         List<DSR_SCEngagement__Share> jobShares = new List<DSR_SCEngagement__Share>();
        
         for(DSR_Virtual_Team__c obj :list_VT)
         {
             DSR_SCEngagement__Share objSCEReq = new DSR_SCEngagement__Share();
             objSCEReq.ParentId = obj.SCE_ID__c;
             objSCEReq.UserOrGroupId = obj.Virtual_Team_Member_Name__c;
             objSCEReq.AccessLevel = 'Edit';
             objSCEReq.RowCause = Schema.DSR_SCEngagement__Share.RowCause.SCE__c;
             jobShares.add(objSCEReq);
         }
         insert jobShares;
     }
     
     public static List<DSR_Use_Case_Blueprints__c> GetFnUseCaseAndBluePrints(string strOppId,string OfferingType) 
     {
        system.debug('+++OfferingType+++++   '+OfferingType);
         
        if(OfferingType == 'PureEngage Subscription')
            OfferingType = 'PureEngage On Premise';
        else if(OfferingType == 'PureConnect Subscription')
            OfferingType = 'PureConnect On Premise'; 
         
        system.debug('+++OfferingType+++++   '+OfferingType);
        
        List<DSR_Use_Case_Blueprints__c> list_FnUseCase = new List<DSR_Use_Case_Blueprints__c>();
        List<DSR_Use_Case_Blueprints__c>list_shortCodes = new List<DSR_Use_Case_Blueprints__c>();
        
        /*+++++++++++ Get SC Engagement +++++++++++*/
        /*+++++++++ SC Engagement have lookup of Primary Design +++++++++++ */
        List<DSR_SCEngagement__c> objSCE = [Select id,Opportunity_ID__c,Primary_Design_ID__c from DSR_SCEngagement__c where Opportunity_ID__c =:strOppId]; 
        
        system.debug('+++objSCE +++++   '+objSCE);
        
        if(objSCE.isEmpty())
            return list_shortCodes;    
         
        List<DSR_SCE_Design__c> list_Designs;
        
        /*++++++++ Get Primary Design associated with SCE ++++++*/
        if(objSCE[0].Primary_Design_ID__c != null)
          list_Designs = [Select id,IsPrimary__c from DSR_SCE_Design__c where id =: objSCE[0].Primary_Design_ID__c and OfferingPlatformType__c =: OfferingType];
        
         /*++++++++++++ if primary design does not find than return all non primary designs +++++++++++++++++*/ 
        if(list_Designs == null || list_Designs.size() <= 0)
          list_Designs = [Select id,IsPrimary__c from DSR_SCE_Design__c where DSR_SCEngagement__c =: objSCE[0].id and OfferingPlatformType__c =: OfferingType and IsPrimary__c =: false];
        
        system.debug('+++list_Designs +++++   '+list_Designs );
        
        /* Get Functional Use Case*/
        if(list_Designs.isEmpty())
            return list_shortCodes; 
            
        list_FnUseCase = [select id,ShortCode__c,Name__c from DSR_Use_Case_Blueprints__c where  DSRSCEDesign__c IN: list_Designs and Type__c =:'Use Case' ORDER BY createddate DESC];
        
        system.debug('+++list_FnUseCase +++++++   '+list_FnUseCase);
        
        /*++++++++++ To return distinct Short Code +++++++++++*/
        set<string>set_ShortCode = new Set<string>();
        
        
        for(DSR_Use_Case_Blueprints__c obj : list_FnUseCase)
        {
          if(!set_ShortCode.contains(obj.ShortCode__c))
          {
            list_shortCodes.add(obj);
            set_ShortCode.add(obj.ShortCode__c);
          }
        }
        
        system.debug('+++list_shortCodes'+list_shortCodes);
        return list_shortCodes;
     } 
     
     
      // @Start: Changes on 5/11 as requested by Debora
    // @desc: To update Pre Sales Priority on DSR SC Engagement whenever it's getting update on Opportunity
    
    public static void updateOnSCEngagementToPreSalesPriority(List<Opportunity> oppNewList, Map<Id, Opportunity> oppOldMap){
        Set<Id> opportunityIdSet = new Set<Id>();
        for(Opportunity opp : oppNewList){
            if(opp.Pre_Sales_Priority__c != oppOldMap.get(opp.Id).Pre_Sales_Priority__c){
                opportunityIdSet.add(opp.Id);
            }
        }
        
        if(opportunityIdSet.size() > 0){
            List<DSR_SCEngagement__c> scEngagementList = new List<DSR_SCEngagement__c>();
            for(DSR_SCEngagement__c scEngage : [SELECT Id, Pre_Sales_Priority__c, Opportunity_ID__r.Pre_Sales_Priority__c FROM DSR_SCEngagement__c  WHERE Opportunity_ID__c IN: opportunityIdSet]){
                if(scEngage.Pre_Sales_Priority__c != scEngage.Opportunity_ID__r.Pre_Sales_Priority__c){
                    scEngage.Pre_Sales_Priority__c = scEngage.Opportunity_ID__r.Pre_Sales_Priority__c;
                    scEngagementList.add(scEngage);
                }
            }
            if(scEngagementList.size() > 0){
                update scEngagementList;
            }
        }
    }
    // @End: Changes on 5/11 as requested by Debora    
    
    /*
    * Added By: Ashish Goyal (10/31/2018), on request of Debbie
    * Desc: To send the notification to SC and SRL when opportunity closed with an active DSR
    */
    
    public static void sendNotificationtoSCSRL(Map<Id, Opportunity> newOpptyMap, Map<Id, Opportunity> oldOpptyMap) {
        System.debug('---method called---');
        Set<Id> set_OpptyId = new Set<Id>();
        for(Opportunity opp : newOpptyMap.values()){
            system.debug('>>>>'+opp.StageName+ '######'+ oldOpptyMap.get(opp.Id).StageName);
            if(opp.StageName == '6.Closed' && opp.StageName != oldOpptyMap.get(opp.Id).StageName){
                set_OpptyId.add(opp.Id);
                System.debug('---metyhd called--in if-');
            }
        }
        
        if(set_OpptyId.size() > 0){
            System.debug('---metyhd called- condition--');
            Map<Id, List<String>> map_OpptyIdListUserId = new Map<Id, List<String>>();
            Map<Id, String> map_OpptyIdOwnerName = new Map<Id, String>();
            Map<Id,DSR_SCEngagement__c> map_oppIdDsrObj = new Map<Id,DSR_SCEngagement__c>();
            for(DSR_SCEngagement__c dsr : [SELECT Id, Name, Opportunity_ID__c, Opportunity_ID__r.Owner.Name, (SELECT Virtual_User_Role__c, Virtual_Team_Member_Name__c,IsPrimary__c, Virtual_User_type__c FROM DSR_Virtual_Teams__r) 
                                                FROM DSR_SCEngagement__c WHERE Opportunity_ID__c IN: set_OpptyId AND SC_Engagement_Status__c = 'Open and Assigned']){
                map_oppIdDsrObj.put(dsr.Opportunity_ID__c,dsr);
                List<Id> list_UserId = new List<Id>();
                for(DSR_Virtual_Team__c vTeam : dsr.DSR_Virtual_Teams__r){
                    if((vTeam.Virtual_User_Role__c == 'Virtual Team' && vTeam.Virtual_User_type__c == 'Solution Consultant' && vTeam.IsPrimary__c) || vTeam.Virtual_User_Role__c == 'Sub Regional Leader'){
                        list_UserId.add(vTeam.Virtual_Team_Member_Name__c);
                    }
                }
                if(list_UserId.size() > 0){
                    map_OpptyIdListUserId.put(dsr.Opportunity_ID__c, list_UserId);
                    map_OpptyIdOwnerName.put(dsr.Opportunity_ID__c, dsr.Opportunity_ID__r.Owner.Name);
                }
                System.debug('---metyhd called---inner query');
            }
            
            if(map_OpptyIdListUserId.size() > 0){
                System.debug('---metyhd called--email for-');
                for(Id oppId : map_OpptyIdListUserId.keySet()){
                    Opportunity oppty = newOpptyMap.get(oppId);
                    String emailBody = 'Hello<br /><br />The following Opportunity has been Closed and the corresponding SC Engagement Status is Open and Assigned. Please complete the SC Engagement to Completion. <br/><br />';
                    emailBody += '<table ><tr><td>Opportunity</td><td> : </td><td>' + oppty.Name + '<br />';
                    emailBody += '<tr><td>Stage </td><td> : </td><td> ' + oppty.StageName + '<br />';
                    
                    if(oppty.Win_Loss_Status__c != null){
                        emailBody += '<tr><td>Win/Loss Status </td><td> : </td><td> ' + oppty.Win_Loss_Status__c + '</td></tr>';
                    }else{
                        emailBody += '<tr><td>Win/Loss Status </td><td> : </td><td> &nbsp; </td></tr>';
                    }
                    
                    if(oppty.CloseDate != null){
                        String myDate = oppty.CloseDate.format();
                        emailBody += '<tr><td>Close Date </td><td> : </td><td> ' + myDate + '</td></tr>';
                    }else{
                        emailBody += '<tr><td>Close Date </td><td> : </td><td> &nbsp; </td></tr>';
                    }
                    
                    if(oppty.Type != null){
                        emailBody += '<tr><td>Type </td><td> : </td><td> ' + oppty.Type + '</td></tr>';
                    }else{
                        emailBody += '<tr><td>Type </td><td> : </td><td> &nbsp; </td></tr>';
                    }
                    
                    if(oppty.Lines_of_Businesses__c != null){
                        emailBody += '<tr><td>Offerings Type </td><td> : </td><td> ' + oppty.Lines_of_Businesses__c + '</td></tr>';
                    }else{
                        emailBody += '<tr><td>Offerings Type </td><td> : </td><td> &nbsp; </td></tr>';
                    }
                    
                    if(oppty.Primary_Line_of_Business__c != null){
                        emailBody += '<tr><td>Platform Type </td><td> : </td><td> ' + oppty.Primary_Line_of_Business__c + '</td></tr>';
                    }else{
                        emailBody += '<tr><td>Platform Type </td><td> : </td><td> &nbsp; </td></tr>';
                    }
                    
                    emailBody += '<tr><td>Opportunity Owner </td><td> : </td><td> ' + map_OpptyIdOwnerName.get(oppId) + '</td></tr>';
                    
                    if(oppty.Owner_Segment__c != null){
                        emailBody += '<tr><td>Owner Segment </td><td> : </td><td> ' + oppty.Owner_Segment__c + '</td></tr>';
                    }else{
                        emailBody += '<tr><td>Owner Segment </td><td> : </td><td> &nbsp; </td></tr>';
                    }
                    
                    if(oppty.Country_Region__c != null){
                        emailBody += '<tr><td>Region </td><td> : </td><td> ' + oppty.Country_Region__c + '</td></tr>';
                    }else{
                        emailBody += '<tr><td>Region </td><td> : </td><td> &nbsp; </td></tr>';
                    }
                    
                    if(oppty.Country_Sub_Region__c != null){
                        emailBody += '<tr><td>Sub-Region </td><td> : </td><td> ' +  oppty.Country_Sub_Region__c + '</td></tr>';
                    }else{
                        emailBody += '<tr><td>Sub-Region </td><td> : </td><td> &nbsp;</td></tr>';
                    }
                    
                    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
                    
                    emailBody += '<tr><td>DSR # </td><td> : </td><td> ' +  map_oppIdDsrObj.get(oppty.id).name + '</td></tr>';
                    
                    emailBody += '<tr><td>Link to DSR </td><td> : </td><td> <a href="'+baseUrl+'/'+map_oppIdDsrObj.get(oppty.id).Id+'">'+ baseUrl+'/'+map_oppIdDsrObj.get(oppty.id).Id +'</a></td></tr>';
                    
                    emailBody += '</table>';
                    emailBody += '<br /><br />Thanks!!';
                
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject('Opportunity closed with an Active DSR');
                    email.setHtmlBody(emailBody);                   
                    email.saveAsActivity = false;
                    email.setToAddresses(map_OpptyIdListUserId.get(oppId));
                    List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>{email};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);  
                    System.debug('---metyhd called---email resilts--'+results);             
                }
            }       
        }
    }   
    
     /**
    *   Method Name :   fetchOppIdFromAccount()
    *   Description :   Notification to SRL when Account owners are changed
    *   Added By: Priyank Saxena (04/10/2019), on request of Debbie 
    **/
    public static void fetchOppIdFromAccount(List<Account> lstAcc, Map<Id, Account> map_AccountOld){
        Set<Id> set_AccId = new Set<Id>();
        for(Account accObj : lstAcc){
            if(accObj.OwnerId != map_AccountOld.get(accObj.Id).OwnerId){
                set_AccId.add(accObj.id);
            }
        }
        
        if(set_AccId.size() > 0){           
            Map<Id, List<String>> map_OpptyIdListUserId = new Map<Id, List<String>>();
            Map<Id, String> map_OpptyIdName = new Map<id, String>();
            Map<Id, list<DSR_SCEngagement__c>> map_OpptyDSRVirtualT = new Map<Id, list<DSR_SCEngagement__c>>();
            for(DSR_SCEngagement__c dsr : [SELECT Id, Name, Opportunity_ID__c, Opportunity_ID__r.Name, Opportunity_ID__r.Owner.Name, (SELECT Name,Virtual_User_Role__c, 
                                                    Virtual_Team_Member_Name__c,IsPrimary__c, Virtual_User_type__c FROM DSR_Virtual_Teams__r WHERE Virtual_User_Role__c = 'Sub Regional Leader') 
                                                FROM DSR_SCEngagement__c WHERE Opportunity_ID__r.AccountId IN: set_AccId AND SC_Engagement_Status__c = 'Open and Assigned']){
                map_OpptyIdName.put(dsr.Opportunity_ID__c, dsr.Opportunity_ID__r.Name);
                List<Id> list_UserId = new List<Id>();
                for(DSR_Virtual_Team__c vTeam : dsr.DSR_Virtual_Teams__r){
                    list_UserId.add(vTeam.Virtual_Team_Member_Name__c);
                }
                if(list_UserId.size() > 0){
                    map_OpptyIdListUserId.put(dsr.Opportunity_ID__c, list_UserId);                    
                }
                if(!map_OpptyDSRVirtualT.containsKey(dsr.Opportunity_ID__c)){
                    map_OpptyDSRVirtualT.put(dsr.Opportunity_ID__c, new list<DSR_SCEngagement__c>());
                }
                map_OpptyDSRVirtualT.get(dsr.Opportunity_ID__c).add(dsr);
            }
            String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
            if(map_OpptyIdListUserId.size() > 0){
                List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
                for(Id oppId : map_OpptyIdListUserId.keySet()){
                    String emailBody = 'Dear SC manager,<br /><br />This e-mail is to notify you that the account owner for opportunity <a href="'+baseUrl+'/'+oppId+'">'+map_OpptyIdName.get(oppId)+'</a> has changed. Please verify the Virtual Team for the related DSR.<br/><br />';
                    
                    emailBody += '<table >';
                    for(DSR_SCEngagement__c vTeam :  map_OpptyDSRVirtualT.get(oppId)){
                        emailBody += '<tr><td><a href="'+baseUrl+'/'+vTeam.Id+'">'+vTeam.Name +'</a></td></tr>';
                    }
                    emailBody += '</table>';
                    
                    emailBody += '<br /><br />With best regards';
                
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setSubject('Opportunity Account Owner changed');
                    email.setHtmlBody(emailBody);                   
                    email.saveAsActivity = false;
                    email.setToAddresses(map_OpptyIdListUserId.get(oppId));
                    emailList.add(email);                              
                }
                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
            } 
        }       
    }
}