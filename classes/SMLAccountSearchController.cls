//Naresh Kumar
public with sharing class SMLAccountSearchController{
    public List<wrapperAccount> searchedAccounts {get;set;}
    public String accountName {get;set;}
    public Boolean showRecords {get;set;}
    public List<SelectOption> userViews {get;set;}
    public String selectedView {get;set;}
    public Boolean showPopup {get;set;}
    public String newViewName {get;set;}
    public SMLAccountSearchController(){
        init();
    }
    
    private void init(){
        showRecords = false;
        showPopup = false;
        populateViews();
        loadView();
    }
    
    private void populateViews(){
        List<SML_Search_View__c> smlSearchViews = [SELECT id, Name FROM SML_Search_View__c WHERE ownerId =: UserInfo.getUserId() ORDER BY CreatedDate DESC];
        userViews = new List<SelectOption>();
        SelectOption newOption = new SelectOption('', '--Select--');
        userViews.add(newOption);    
        for(SML_Search_View__c eachView : smlSearchViews){
            if(selectedView == null)
                selectedView = eachView.id;
            newOption = new SelectOption(eachView.id, eachView.Name);
            userViews.add(newOption);    
        }
    }

    // 26-Jul-2016: NM: Removed Inactive from the query string so that the inactive accounts can be included in the EngMap now (iTrack# 28470)
    public void search(){
        String query = 'SELECT id, Name, Parent_Account__c, Parent_Account__r.Name, Region__c,' 
            + ' Country__r.Name FROM Account WHERE  Status__c NOT IN (\'Merged\')' 
            + ' AND RecordType.Name != \'Enterprise - Business Partner\' AND id IN (SELECT Account__c FROM SML_Data__c) ';
        if(accountName != '' && accountName != 'null' && accountName != null)
            query += ' AND Name LIKE \'%' + accountName + '%\'';

        searchedAccounts = new List<wrapperAccount>();
        List<Account> accounts = (List<Account>)Database.query(query);
        //Looping over each account
        for(Account eachAccount : accounts){
            wrapperAccount newAccount = new wrapperAccount(eachAccount, false);
            searchedAccounts.add(newAccount);    
        }
        if(!searchedAccounts.isEmpty())
            showRecords = true;
    }
    
    public void loadView(){
        if(selectedView == null || selectedView == '')
            return;
        showRecords = false;
        searchedAccounts = new List<wrapperAccount>();
        List<Account> accounts = [SELECT id, Name, Parent_Account__c, Parent_Account__r.Name, Region__c, 
            Country__r.Name FROM Account WHERE id IN (SELECT Account__c FROM SML_Search_View_Account__c 
            WHERE SML_Search_View__c  =: selectedView)];
        //Looping over each account
        for(Account eachAccount : accounts){
            wrapperAccount newAccount = new wrapperAccount(eachAccount, false);
            searchedAccounts.add(newAccount);    
        }
        if(!searchedAccounts.isEmpty())
            showRecords = true;
    }
    
    public void showPopup(){
        showPopup = true;
    }
    
    public void hidePopup(){
        showPopup = false;
        SML_Search_View__c newView = new SML_Search_View__c();
        newView.Name = newViewName;
        insert newView; 
        populateViews();
        selectedView = newViewName;
    }
    
    public void deleteView(){
        SML_Search_View__c recordToBeDeleted = new SML_Search_View__c( id = selectedView);
        delete recordToBeDeleted;
        populateViews();
    }
    
    public void saveSelectedInView(){
        List<SML_Search_View_Account__c> existingRecords = [SELECT Account__c FROM SML_Search_View_Account__c 
            WHERE SML_Search_View__c =: selectedView];
        Set<Id> setOfAccount = new Set<Id>();
        for(SML_Search_View_Account__c eachRecord : existingRecords){
            setOfAccount.add(eachRecord.Account__c);
        }
        List<SML_Search_View_Account__c> listOViewAccounts = new List<SML_Search_View_Account__c>();
        //Looping over each record
        for(wrapperAccount eachRecord : searchedAccounts){
            if(eachRecord.selected && !setOfAccount.contains(eachRecord.account.id)){
                SML_Search_View_Account__c newViewAccount = new SML_Search_View_Account__c();
                newViewAccount.Account__c = eachRecord.account.id;
                newViewAccount.SML_Search_View__c = selectedView;           
                listOViewAccounts.add(newViewAccount);
            }
        }
        if(!listOViewAccounts.isEmpty())
            insert listOViewAccounts; 
    }
    
    public void removeSelectedInView(){
        Set<Id> setOfAccountIds = new Set<Id>();
        //Looping over each record
        for(wrapperAccount eachRecord : searchedAccounts){
            if(eachRecord.selected){
                setOfAccountIds.add(eachRecord.account.id);
            }
        }
        List<SML_Search_View_Account__c> listOViewAccountsToBeDeleted = [SELECT id FROM SML_Search_View_Account__c 
            WHERE Account__c IN : setOfAccountIds AND SML_Search_View__c  =: selectedView];

        if(!listOViewAccountsToBeDeleted.isEmpty())
            delete listOViewAccountsToBeDeleted;
        loadView();
    }
    
    public PageReference goToSML(){          
        PageReference newPF = new PageReference('/apex/SML1?viewId=' + selectedView );      
        newPF.setRedirect(true);
        return newPF; 
    }
    
    public class wrapperAccount{
        public Boolean selected {get;set;}
        public Account account {get;set;}
        public wrapperAccount(Account acc, Boolean selected){
            this.account = acc;
            this.selected = selected;
        }        
    }
}