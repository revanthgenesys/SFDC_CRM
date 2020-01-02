public class subscriptionManagementController {
    public String selectedTab {get; set;}
    public Contact accountSelection {get; set;}
    public String userType {get; set;}
    public String urlPrefix {get; set;}
    public String selectedEndUserAccountId {get; set;}
  // Following 2 variables to be deleted ...    
    public String soldToAccountId {get; set;}
    public List<String> soldToAccountIds {get; set;}
    public subscriptionManagementController(){
        selectedTab = 'LicenseActivityTab';
        accountSelection = new Contact();
        urlPrefix = Site.getPathPrefix() != NULL ? Site.getPathPrefix() : '';
        goClicked();
    }
           
    
    
    public void tabClicked(){
       
    }
    
    public void goClicked(){
      List<Account> accounts;
         selectedEndUserAccountId = accountSelection.AccountId;
         accounts = [SELECT id, Name, Support_Option__c, Auto_Renew__c, Auto_Renew_Anniversary__c FROM Account WHERE id = :selectedEndUserAccountId];
        
    }

}