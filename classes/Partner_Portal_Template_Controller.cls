//Test class for this class is PartnerSetupControllerTest 
/*
    Modification Log: 
    Harish, 03/01/2017 - Modified constructor have the display condition for partner application tab.
                       - Partner application to be shown for designated partners and active application exists at parent account.
    Harish, 03/17/2017 - removed display condition for partner application, added a partner application link to QuickLinks.
    Mukunthan Koothan 02/02/2018 - added logic to display PureCloud Partner Tier on Partner Portal side bar.
 */
public without sharing class Partner_Portal_Template_Controller {

    public String name {get;set;}
    public String tier {get;set;}
    public String type {get;set;}
    public String sapCode{get;set;}
    public string pcPartnerTier{get;set;}
    public static Boolean hasContents {get;set;}
    public String gSelectTabId {get;set;} 
    public String LicenseFormTabId {get;set;} 
    public String categ {get;set;} 
    public String offrtype {get;set;}
    public boolean showDIF{get;set;}
    public boolean isPotentialPartner{get;set;}
    public boolean displayApprovedApplicationLink {get; set;}
    public String ApprovedApplicationLink {get; set;}
    public String partnerOfferring {get; set;}
    public boolean showSizeCalc{get;set;}
    public boolean HasLDAPLogin {get;set;}
    public boolean showPureSuccessEntitlement {get;set;}
    
    public User currentUser{get;set;}
    public Contact userContact{get;set;}
    public Account userAcnt{get;set;}
    public Map<String,User> usrHier{get;set;}
    
    public boolean displayTrainingTab {get; set;}
    public String partnerTrainingTab {get; set;}
    
    public boolean displayDealRegistrationTab {get; set;}
    public String dealRegistrationTab {get; set;}
    
    public boolean displaySmartContentTab {get; set;}
    public String smartContentTab {get; set;}

    public boolean displayActivationFileManagementTab {get; set;}
    public String activationFileManagementTab {get; set;}
    
    
    public boolean isOpportunityReferralPartner {get;set;}
    public boolean isLeadReferralPartner {get;set;}     

    public Partner_Portal_Template_Controller(DealRegistrationGraphController controller) {

    }   
    
    public Partner_Portal_Template_Controller(){
        try{
            hasContents = false;
            displaySmartContentTab = false;
            smartContentTab = '';
            
            isOpportunityReferralPartner = isLeadReferralPartner = false;
           
            
            
            PartnerPortalGSelectController obj = new PartnerPortalGSelectController();
            if(obj.contentResults.size() > 0) {
                hasContents = true; 
            } else {
                Partner_Portal_Settings__c settings = Partner_Portal_Settings__c.getInstance('GSelectTabId');
                gSelectTabId = settings.Id_Value__c;
            }
           
            if(!getShowLicenseFormTab()){
                Partner_Portal_Settings__c settings = Partner_Portal_Settings__c.getInstance('LicenseFormTabId');
                LicenseFormTabId = settings.Id_Value__c;
            }
            
            // Update: Harish, 03/01/2017 - Added profile fields.
            currentUser = [SELECT Id, ContactId, profile.Name, profileId, email, Username,Contact.Account.OwnerId,Contact.Account.Owner.ManagerId 
                            FROM User where id =:Userinfo.getUserId()];
                            
            if(currentUser.profile.Name != Label.Partner_Profile_Label){
                
                    isPotentialPartner = (currentUser.profile.Name==Label.Potential_Partner_User_Profile_Name || currentUser.profile.Name==Label.Customer_Portal_EndUser_PP)?true:false;
                    
                    // Update: Harish, 03/01/2017 - Added Designated_Partner_Contact__c field.
                    userContact = [Select AccountId, Account.Name, Has_Ldap_Login__c,Account.RecordType.Name, Designated_Partner_Contact__c, Show_Size_Calc__c,SMART_Certified__c, 
                    Self_Service_Elements_Access__c,All_Service_Elements_Access__c,PureSuccess_Main_Contact__c from Contact where id =:currentUser.ContactId ];
                
                // ********************* Control LMS/ Activation file Management Application Tab *********************
                    displayActivationFileManagementTab = true;
                    Map<String, LMS_Pilot_Users__c> lmsPilotUsers = LMS_Pilot_Users__c.getAll();

                    if(Partner_Portal_Settings__c.getInstance('ActivationFileManagementTab') != null && lmsPilotUsers.size() > 0){
                        displayActivationFileManagementTab = lmsPilotUsers.KeySet().contains(currentUser.Username) ? true : false;
                        activationFileManagementTab = Partner_Portal_Settings__c.getInstance('ActivationFileManagementTab').Id_Value__c; 
                    }  
                
                    // ********************* Control LMS/ Activation file Management Application Tab *********************
                if(userContact.SMART_Certified__c != NULL && userContact.SMART_Certified__c == true)
                  displaySmartContentTab = true;
                  
                    if(Partner_Portal_Settings__c.getInstance('SmartContentTab') != null)
                            smartContentTab = Partner_Portal_Settings__c.getInstance('SmartContentTab').Id_Value__c;
                    
                    // Update: Harish, 03/01/2017 - Added subquery on Partner_Applications.// AND For_User__c = :currentUser.Id
                    userAcnt = [Select Id,Name,SAP_Account_Code__c,Country__r.Name,Country__r.Region__c,Partner_Tier__c, PartnerType__c,
                                        PureCloud_Partner_Tier__c,Partner_Offering_Type__c, Partner_Category__c,
                                        (Select Id From Partner_Applications__r Where Status__c = 'Approved')
                                        from Account where id=:userContact.AccountId];
                
                    // Check whether Deal Registration Tab can be displayed or not in Partner Portal
                    if(userAcnt.PartnerType__c != null) {
                        String partnerType = userAcnt.PartnerType__c;
                        List<Partner_Portal_Deal_Registration_Config__c> dealRegistrationConfig = Partner_Portal_Deal_Registration_Config__c.getall().values();
                        for(Partner_Portal_Deal_Registration_Config__c ppdr: dealRegistrationConfig){
                            if(partnerType.contains(ppdr.Name)){
                                if(ppdr.Opportunity_Registration__c)
                                  isOpportunityReferralPartner = true;
                                if(ppdr.Lead_Referral__c)
                                  isLeadReferralPartner = true;
                            }
                        }
                        displayDealRegistrationTab = false;
                        if(isOpportunityReferralPartner || isLeadReferralPartner)
                            displayDealRegistrationTab = true;
                        if(Partner_Portal_Settings__c.getInstance('DealRegistrationTab') != null)
                            dealRegistrationTab = Partner_Portal_Settings__c.getInstance('DealRegistrationTab').Id_Value__c;    
                    }
                    

                    // Check whether Training Tab can be displayed or not in Partner Portal
                    GUCompliancePartnerInfoController gucPartnerInfoController = new GUCompliancePartnerInfoController(userContact.AccountId);
                    displayTrainingTab = gucPartnerInfoController.displayTrainingTab;
                    if(Partner_Portal_Settings__c.getInstance('PartnerTrainingTab') != null)
                      partnerTrainingTab = Partner_Portal_Settings__c.getInstance('PartnerTrainingTab').Id_Value__c;

                    name = userAcnt.Name;
                    tier = userAcnt.Partner_Tier__c;
                    type = userAcnt.PartnerType__c;
                    sapCode = userAcnt.SAP_Account_Code__c;
                    categ = userAcnt.Partner_Category__c;
                    offrtype = userAcnt.Partner_Offering_Type__c;
                    

                    pcPartnerTier = '';
                    if ( offrtype != null && offrtype.contains('PureCloud') )
                        pcPartnerTier = userAcnt.PureCloud_Partner_Tier__c;
                    
                    usrHier = new Map<String,User>{'Portal User' => currentUser};
                    Map<Id,User> userMap = new Map<Id,User>([SELECT Id,Name,Email,Phone,MobilePhone,FullPhotoUrl,Title 
                                                                FROM User WHERE Id =: currentUser.Contact.Account.OwnerId OR Id =: currentUser.Contact.Account.Owner.ManagerId]);
                    
                    if(userAcnt.PartnerType__c != 'Technology Partner' && userMap.containsKey(currentUser.Contact.Account.OwnerId)){
                        usrHier.put('Channel Manager',userMap.get(currentUser.Contact.Account.OwnerId));

                        ///APAC specific
                        string partnerRegion = userAcnt.Country__r.Region__c!=null?userAcnt.Country__r.Region__c:'';
                        if ( partnerRegion == 'APAC' ) {
                            try {
                                String apacMgrId = Partner_Regional_Channel_Manager__c.getInstance('APAC').Manager_UserId__c;
                                
                                if ( apacMgrId != null ) {
                                    List<User> apacmgr = [SELECT Id,Name,Email,Phone,MobilePhone,FullPhotoUrl,Title FROM User WHERE Id =:apacMgrId];
                                    if ( !apacmgr.isEmpty() ) {
                                       usrHier.put('Regional Channel Manager', apacmgr[0]); 
                                    }
                                }             
                            }
                            catch(Exception ex) {
                                System.Debug('Error--->'+ex.getMessage());
                                System.Debug('ErrorInLine--->'+ex.getLineNumber());
                            }              
                        }
                        else if(userMap.containsKey(currentUser.Contact.Account.Owner.ManagerId)){
                            usrHier.put('Regional Channel Manager',userMap.get(currentUser.Contact.Account.Owner.ManagerId)); 
                        }
                    }
                    else{
                        usrHier.put('Channel Manager',new user());
                        usrHier.put('Regional Channel Manager',new user());
                    }
                    showDIF = false;
                    if(!String.isBlank(userAcnt.Id)){
                    showDIF = checkTechPartnerOnly(userAcnt.Id);}
                    
                    displayApprovedApplicationLink = false;
                    approvedApplicationLink = '';

                    // Hide partner application if profile is 'Genesys Portal End user or Genesys Portal Partner' and not designated user and no approved applications.
                    if( (currentUser.profile.Name == PartnerPortalUtil.PROFILE_GENESYS_PORTAL_PARTNER
                         || currentUser.profile.Name == PartnerPortalUtil.PROFILE_PARTNER_COMMUNITY_LOGIN_NEW
                         || currentUser.profile.Name == PartnerPortalUtil.PROFILE_CUSTOM_GOLD_PARTNER)
                        && (userAcnt != null
                            && !userAcnt.Partner_Applications__r.isEmpty()
                            && userContact != null
                            && userContact.Designated_Partner_Contact__c == true)){
                        displayApprovedApplicationLink = true;
                        approvedApplicationLink = '/partner/Partner_ApplicationDetail?id=' + userAcnt.Partner_Applications__r.get(0).Id;
                    }
                    partnerOfferring = userAcnt.Partner_Offering_Type__c != NULL ? userAcnt.Partner_Offering_Type__c : 'NONE';
                    
                    showSizeCalc = false;
                   if (userContact!= null) {
                    showSizeCalc = userContact.Show_Size_Calc__c;
                   }
                   
                   HasLDAPLogin = false;
                   HasLDAPLogin = userContact.Has_Ldap_Login__c;
                   
                   if(userContact.Self_Service_Elements_Access__c == true || userContact.All_Service_Elements_Access__c == true || userContact.PureSuccess_Main_Contact__c == true)
                        showPureSuccessEntitlement = true;
                   else
                        showPureSuccessEntitlement = false;
                    
            }
        }
        catch(exception e){
            system.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorInLine--->'+e.getLineNumber());
        }
            
    }
    
    public Boolean getShowLicenseFormTab(){
        User currentUser = [SELECT Id, Name, Contact.AccountId, Contact.Account.AppFoundry_Application_Not_Required__c from User where Id = :Userinfo.getUserid()];
        Boolean showTab = false;
        
        if(currentUser.Contact.Account.AppFoundry_Application_Not_Required__c){
            showTab = true;
        } else {
            Integer approvedAppFoundryCount = [select count() from Technology_Market_place_Application__c where Partner_Account__c = :currentUser.Contact.AccountId and Status__c = 'Approved']; 
            if(approvedAppFoundryCount != null && approvedAppFoundryCount > 0){
               showTab = true; 
            }
        }
        return showTab;
    }
    
    public boolean checkTechPartnerOnly(string acctId){
        try{
                Account accnt = [Select Id,PartnerType__c from Account where Id=:acctId];
                list<string> pType = accnt.PartnerType__c.split(';');
                if(pType.size()>1){
                    return true;
                }
                else if(pType.size()==1){
                    if(pType[0] == 'Technology Partner')
                        return false;
                    else
                        return true;
                }
                else{
                    return false;
                }
            }
        catch(exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorLine--->'+e.getLineNumber());
            return false;
        }     
        
    }
    
}