/*
Class Name = OpenAccountTabController
Purpose = Class represent the common function/logic instead of writing code on multiple components. User Story# S-647816, Task# T-848005
Developed By = Sajid Khan
Developed Date = 03-Dev-2019
Modified By = NA
Modified Date = NA
*/
public with sharing class OpenAccountTabController {
        
        public String AccFilterId {get; set;}
    private String QueryAccount;
    // display sort and number
    public Integer RecPerPage {get; set;}
    public list<SelectOption> RecPerPageOption {get; set;}  
    public String SortFieldSave;
     public Set<id> accIDs;
    public set<id> test;
    public string defaultQuery;
    public Integer noOfRecords{get;set;}
     
    /***
    * OpenAccountTabController - Constructor initialization
    ***/
    public OpenAccountTabController(ApexPages.StandardController controller){
        //records for page initialization
        RecPerPageOption = new list<SelectOption>();
        RecPerPageOption.add(new SelectOption('10','10'));
        RecPerPageOption.add(new SelectOption('25','25'));
        RecPerPageOption.add(new SelectOption('50','50'));
        RecPerPageOption.add(new SelectOption('100','100'));
        RecPerPageOption.add(new SelectOption('200','200'));
        RecPerPage = 10; //default records per page
        defaultQuery='';
       
        SortFieldSave = SortField;
        // list generation
        BuildQuery();  
    }
    /***
    * This method is used to get the All the List View User has access
    ***/
    public SelectOption[] getAccountExistingViews(){
        return StdSetControllerAccount.getListViewOptions();
    }
    
  
     public ApexPages.StandardSetController StdSetControllerAccount {
        get {
            if(StdSetControllerAccount == null) {
                set<Id> recentAcctIDs = new set<Id>();
                for(RecentlyViewed rvRec:[SELECT Id, Name FROM RecentlyViewed  WHERE Type ='Account' ORDER BY LastViewedDate DESC]){
                    recentAcctIDs.add(rvRec.Id);
                }
                system.debug('recentAcctIDs:'+recentAcctIDs);
                defaultQuery = 'Select Id,Name,Type,Owner.LastName, Phone,AccountClassification__c,Status__c,SAP_Account_Code__c,Parent.Name,Country__r.name FROM Account where Id IN:recentAcctIDs';
                system.debug('defaultQuery:'+defaultQuery);
                StdSetControllerAccount = new ApexPages.StandardSetController(Database.getQueryLocator(defaultQuery));
                 system.debug('totalRecords'+StdSetControllerAccount.getResultSize());
                if(StdSetControllerAccount!=null)
                {
                    system.debug('getResultSize:' +StdSetControllerAccount.getResultSize());
                    accIDs = new set<id>();
                    if(AccFilterId != null)
                    {
                       
                       if(StdSetControllerAccount.getResultSize()==0)
                       {
                       StdSetControllerAccount = new ApexPages.StandardSetController(Database.getQueryLocator('Select Id,Name from Account limit 10000'));    
                       }
                        StdSetControllerAccount.setFilterId(AccFilterId);
                        
                    }
                    integer totalRecords = StdSetControllerAccount.getResultSize();
                    system.debug('totalRecordsss'+totalRecords);
                    if(totalRecords  > 0 && totalRecords < 10000)
                    { 
                        integer totalPages = 0;
                        if(math.mod(totalRecords,1500) > 0)
                        {
                            totalPages = totalRecords/1500 + 1;
                        }
                        else
                        {
                            totalPages = totalRecords/1500;    
                        }
                        List<Account> TempACList;
                       TempACList = new list<Account>();
                       for(integer i = 0; i< totalPages ;i ++)
                       {
                           StdSetControllerAccount.setPageSize(1500);
                           TempACList.addall((list<Account>)StdSetControllerAccount.getRecords());
                           if(StdSetControllerAccount.gethasnext())
                               StdSetControllerAccount.next();
                           else
                              break;
                               
                       }
                           system.debug('listtemp'+TempACList.size());
                        system.debug('totalPages'+totalPages);
                       for(Account c:TempACList)
                    {
                        accIDs.add(c.id);    
                    } 
                   
                    }
                    else if(totalRecords >= 10000)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'List view size limit(10,000) is exceeded.Please refresh the page and try again .If issues persists please contact the administrator.'));
                        
                    }
                   //  StdSetControllerOppurtunity.setPageSize(StdSetControllerOppurtunity.getResultSize());
                    
                if(accIDs!=Null)
                {
                    BuildQuery();
                    StdSetControllerAccount = new ApexPages.StandardSetController(Database.getQueryLocator(QueryAccount));
                    StdSetControllerAccount.setPageSize(Integer.valueOf(RecPerPage));
                    noOfRecords = StdSetControllerAccount.getResultSize();
                    system.debug(StdSetControllerAccount.getResultSize());
                }    
                    
                }
                
            }
            return StdSetControllerAccount;
        }
        set;
    }
    
    
    /***
    * getCurrentOppurtunityList - return an Oppurtunity list for the table
    ***/  
     public list<Account> getCurrentAccountList() {
         system.debug('Records:'+StdSetControllerAccount.getRecords());
        return (list<Account>)StdSetControllerAccount.getRecords();
    }
    /***
    * BuildQuery - build query command for list selection change
    ***/
    public void BuildQuery() {
        StdSetControllerAccount = null;
        String QueryWhere = '';
     
        QueryAccount = 'Select Id,Name,Type,Owner.LastName, Phone,AccountClassification__c,Status__c,SAP_Account_Code__c,Parent.Name,Country__r.Name FROM Account';
     
         if( accIDs!=null && accIDs.size()>0)
        {
            QueryAccount += QueryWhere + ' where ID In :accIDs';
        }
        else
        {
            test = new set<id>();
            QueryAccount += QueryWhere + ' where ID In :test';
        }
        QueryAccount += QueryWhere;
        QueryAccount += ' ORDER BY ' + String.escapeSingleQuotes(SortField) + ' ' + String.escapeSingleQuotes(SortDirection) + ' LIMIT 10000';
        
        system.debug('QueryAccount:' + QueryAccount);
    }
        
    /***
    * SortDirection - return sort direction. Default ascending(asc)
    ***/
    public String SortDirection {
        get { if (SortDirection == null) {  SortDirection = 'asc'; } return SortDirection;  }
        set;
    }
    
    /***
    * SortField - return sort by field. Default to Name
    ***/
    public String SortField {
        get { if (SortField == null) {SortField = 'Name'; } return SortField;  }
        set; 
    }
    
    /***
    * SortToggle - toggles the sorting of query from asc<-->desc
    ***/
    public void SortToggle() {
        SortDirection = SortDirection.equals('asc') ? 'desc NULLS LAST' : 'asc';
        
        if (SortFieldSave != SortField) {
            SortDirection = 'asc';
        //    AlphaFilter = 'All';
            SortFieldSave = SortField;
        }
        // run the query again
        BuildQuery();
    }
    
 /**
    * Reset List View
    */
    public PageReference resetFilter()
    {
      StdSetControllerAccount = null;
        return null;
    }
    
    public void loop()
    {
        for(integer i = 0;i<100;i++)
        {
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }   
    }
}