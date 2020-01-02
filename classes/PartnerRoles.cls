/*
    Modification Log
    -------------------------------------------------------------------------------------------
    Harish, 03/17/2017 - 'Added Approved Partner Application' link ti QuickLisks on partner community home page.
    -------------------------------------------------------------------------------------------
 */
public class PartnerRoles {

    public boolean displayApprovedApplicationLink {get; set;}
    public String ApprovedApplicationLink {get; set;}
    public boolean showSizeCalc {get;set;}
    public boolean showPureSuccessEntitlement {get;set;}
    public String partnerOfferring {get; set;}
  //  public String partnerOfferring1 {get; set;}
    public boolean HasLDAPLogin {get;set;}
    private string usrAccountId;
    public boolean showDIF{get;set;}
    public PartnerRoles() {
        /*
         * 
            Functionality:
            Display Approved Partner Application link when below conditions are met.
                a. genesys portal partner user, partner community login new, custom gold partner user.
                b. when partner contact is marked as designated partner contact.
                c. when partner account has approved application.
        */
        
        HasLDAPLogin = false;
        
        // query current user, associated partner contact, account and approved applications.
        User currentUser = [SELECT Id, ContactId, profile.Name, profileId, email FROM User where id =:Userinfo.getUserId()];
        
        System.debug('@currentUser' + currentUser);
        
        Contact userContact = [Select AccountId, Has_Ldap_Login__c, Show_Size_Calc__c,Designated_Partner_Contact__c,Self_Service_Elements_Access__c,All_Service_Elements_Access__c,PureSuccess_Main_Contact__c
        from Contact where id =:currentUser.ContactId ];
        
        Account userAcnt = [Select Name,SAP_Account_Code__c,Country__r.Name,Country__r.Region__c,Partner_Tier__c, PartnerType__c, Partner_Offering_Type__c, 
                            (Select Id From Partner_Applications__r Where Status__c = 'Approved')
                            from Account where id=:userContact.AccountId];
        usrAccountId = userContact.AccountId;
        System.Debug('usrAccountId--->'+usrAccountId);
        
        //Check added by Jitendra Jain on 02/09 to show hide PureSuccess Entitlement link
        if(userContact.Self_Service_Elements_Access__c == true || userContact.All_Service_Elements_Access__c == true || userContact.PureSuccess_Main_Contact__c == true)
            showPureSuccessEntitlement = true;
        else
            showPureSuccessEntitlement = false;
         
        
           
        partnerOfferring = userAcnt.Partner_Offering_Type__c != NULL ? userAcnt.Partner_Offering_Type__c : 'NONE';
        HasLDAPLogin = userContact.Has_Ldap_Login__c;
        displayApprovedApplicationLink = false;
        showSizeCalc = false;
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

       if (userContact!= null) {
        showSizeCalc = userContact.Show_Size_Calc__c;
       }
        
        showDIF = false;
        if(!String.isBlank(usrAccountId)){
        showDIF = checkTechPartnerOnly(usrAccountId);}
   
    }
    
    public PartnerRoles(PartnerPortal_PeriodicReview_Class controller) {

    }
    public PartnerRoles(PartnerPortalSearchController sController) {

    }
    
    public Portal_Manager_Roles__c getPMRole(){
       Map<String,Portal_Manager_Roles__c> pMRMap = Portal_Manager_Roles__c.getAll(); 
       String uId = UserInfo.getUserId();
       
       User usr = [SELECT Id,Contact.Designated_Partner_Contact__c,Contact.Account.PartnerType__c FROM User WHERE Id =: uId];
       
       Portal_Manager_Roles__c pMR = new Portal_Manager_Roles__c();
       String designated = usr.Contact.Designated_Partner_Contact__c?'_designated':'';
       if(usr.Contact.Account.PartnerType__c != null){
           
           List<String> partnerTypes = usr.Contact.Account.PartnerType__c.split(';');
           
           for(String pType : partnerTypes){
               Portal_Manager_Roles__c pMRRole = pMRMap.get(pType.trim() + designated);
               if(pMRRole == null)
                    continue;
               pMR.BaseLine_Pricing__c = pMRRole.BaseLine_Pricing__c?pMRRole.BaseLine_Pricing__c:pMR.BaseLine_Pricing__c;
               pMR.Gdemo__c = pMRRole.Gdemo__c?pMRRole.Gdemo__c:pMR.Gdemo__c;
               pMR.GU_Discount__c = pMRRole.GU_Discount__c?pMRRole.GU_Discount__c:pMR.GU_Discount__c;
               pMR.GU_Training__c = pMRRole.GU_Training__c?pMRRole.GU_Training__c:pMR.GU_Training__c;
               pMR.KPI_s__c = pMRRole.KPI_s__c?pMRRole.KPI_s__c:pMR.KPI_s__c;
               pMR.Lab_Software__c = pMRRole.Lab_Software__c?pMRRole.Lab_Software__c:pMR.Lab_Software__c;
               pMR.Lead_Referral__c = pMRRole.Lead_Referral__c?pMRRole.Lead_Referral__c:pMR.Lead_Referral__c;
               pMR.MLB__c = pMRRole.MLB__c?pMRRole.MLB__c:pMR.MLB__c;
               pMR.NPS__c = pMRRole.NPS__c?pMRRole.NPS__c:pMR.NPS__c;
               pMR.Online_Directory__c = pMRRole.Online_Directory__c?pMRRole.Online_Directory__c:pMR.Online_Directory__c;
               pMR.Oppty_Reg__c = pMRRole.Oppty_Reg__c?pMRRole.Oppty_Reg__c:pMR.Oppty_Reg__c;
               pMR.Portal_Access__c = pMRRole.Portal_Access__c?pMRRole.Portal_Access__c:pMR.Portal_Access__c;
               pMR.PS_Discount__c = pMRRole.PS_Discount__c?pMRRole.PS_Discount__c:pMR.PS_Discount__c;
               pMR.Rebate__c = pMRRole.Rebate__c?pMRRole.Rebate__c:pMR.Rebate__c;
               pMR.Revenue_Reporting__c = pMRRole.Revenue_Reporting__c?pMRRole.Revenue_Reporting__c:pMR.Revenue_Reporting__c;
               pMR.RFP_Tool__c = pMRRole.RFP_Tool__c?pMRRole.RFP_Tool__c:pMR.RFP_Tool__c;
               pMR.Sales_U_Training__c = pMRRole.Sales_U_Training__c?pMRRole.Sales_U_Training__c:pMR.Sales_U_Training__c;
               pMR.Program_Guide__c = pMRRole.Program_Guide__c?pMRRole.Program_Guide__c:pMR.Program_Guide__c;
           }
       }
       
       return pMR;
    }
    
    public string getuserAccountId(){
        return usrAccountId;
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