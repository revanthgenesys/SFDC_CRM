public class LicenseManagementController {
    public String selectedTab {get; set;}
    public Contact accountSelection {get; set;}
    public String userType {get; set;}
    public String supportOption {get; set;}
    public String urlPrefix {get; set;}
    public Boolean authorizedUser {get; set;}
    public LicenseManagementUtil.CurrentUserAccessProfile userAccessProfile {get; set;}
    public String selectedEndUserAccountId {get; set;}
    // Following 2 variables to be deleted ...    
    public String soldToAccountId {get; set;}
    public List<String> soldToAccountIds {get; set;}
    public Boolean userSeenMessage {get;set;}
    
    public LicenseManagementController(){
        userAccessProfile = LicenseManagementUtil.getUserAccessProfile(UserInfo.getUserId());
        selectedTab = 'SummaryTab';
        userSeenMessage = false;
        urlPrefix = Site.getPathPrefix() != NULL ? Site.getPathPrefix() : '';
        accountSelection = new Contact();
        userType = userAccessProfile.userType;
        authorizedUser = (userAccessProfile.userType == 'Internal' || userAccessProfile.userAccounts.size() > 0) ? true : false;
        userSeenMessage = authorizedUser;
        
        If(userAccessProfile.userType != 'Internal' && userAccessProfile.userAccounts.size() > 0){
            List<LicenseManagementUtil.AccountIdName> euList = new List<LicenseManagementUtil.AccountIdName>();
            for(LicenseManagementUtil.EndUserSoldToCombination eustAccount : userAccessProfile.userAccounts){
                euList.add(eustAccount.endUserAccount);     
            } 
            euList = LicenseManagementUtil.SortAccountIdNames(euList);
            accountSelection.AccountId = euList[0].accountId;
            selectedEndUserAccountId = euList[0].accountId;
            User usr = [Select Id, Broadcast_Partner_Message__c from User where Id =: userInfo.getUSerId()];
            userSeenMessage = usr.Broadcast_Partner_Message__c;
            goClicked();
        }
            
    }
    
    public void tabClicked(){
       
    }
    
    public void updateUser(){
        LMS_Utility.updateUserMessageSetting(true);
    }
    
    public void goClicked(){
        List<Account> accounts;
        if(userAccessProfile.userType != 'Internal'){
            soldToAccountIds = userAccessProfile.getSoldToAccountIds(selectedEndUserAccountId);
            accountSelection.AccountId = selectedEndUserAccountId;
            accounts = [SELECT id, Name, Support_Option__c, Auto_Renew__c, Auto_Renew_Anniversary__c FROM Account WHERE id = :selectedEndUserAccountId];
        } else {
            soldToAccountIds = new List<String>();
            for(License_Snapshot_Sold_To_End_User__c steu : [SELECT id, Sold_To__c FROM License_Snapshot_Sold_To_End_User__c WHERE End_User__c = :accountSelection.AccountId]){
                soldToAccountIds.add(steu.Sold_To__c);    
            }
            accounts = [SELECT id, Name, Support_Option__c, Auto_Renew__c, Auto_Renew_Anniversary__c FROM Account WHERE id = :accountSelection.AccountId];
        }
        Account selectedAccount;
        if(accounts.size() > 0)
            selectedAccount = accounts[0];
        selectedTab = 'SummaryTab';
        supportOption = (selectedAccount != NULL && selectedAccount.Support_Option__c != NULL) ? selectedAccount.Support_Option__c : 'Unknown';
    }

    public List<SelectOption> getEndUserAccounts() {
        Set<String> snapshotEndUsers = new Set<String>();
        for(AggregateResult ar : [SELECT End_User__c FROM License_Snapshot__c WHERE End_User__c IN :userAccessProfile.getEndUserAccountIds() AND isActive__c = true GROUP BY End_User__c]){
            snapshotEndUsers.add(String.valueOf(ar.get('End_User__c')));    
        }
        
        List<SelectOption> options = new List<SelectOption>(); 
        for(LicenseManagementUtil.EndUserSoldToCombination eustAccount : userAccessProfile.userAccounts){
            //if(snapshotEndUsers.contains(eustAccount.endUserAccount.accountId))
                options.add(new SelectOption(eustAccount.endUserAccount.accountId, eustAccount.endUserAccount.accountName));    
        } 
        return LicenseManagementUtil.SortOptionList(options); 
    }
     public void DummyFunc() {       
    }
}