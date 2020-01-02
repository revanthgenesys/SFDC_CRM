public with sharing class OpenOppurtunityTabController {

   

   public SelectOption[] getOppurtunityExistingViews(){
        return StdSetControllerOppurtunity.getListViewOptions();
    }

	public String OppFilterId {get; set;}

    // selection and filter 
  //  public list<String> AlphaList {get; set;}
 //   public String AlphaFilter {get; set;}
    private String QueryOppurtunity;
    
    // display sort and number
    public Integer RecPerPage {get; set;}
    public list<SelectOption> RecPerPageOption {get; set;}  
    public String SortFieldSave;
     public Set<id> oppIDs;
    public set<id> test;
    public string defaultQuery;
    public Integer noOfRecords{get;set;}
    /***
    * OpenOppurtunityTabController - Constructor initialization
    ***/
    public OpenOppurtunityTabController(ApexPages.StandardController controller){
        //records for page initialization
        RecPerPageOption = new list<SelectOption>();
        RecPerPageOption.add(new SelectOption('10','10'));
        RecPerPageOption.add(new SelectOption('25','25'));
        RecPerPageOption.add(new SelectOption('50','50'));
        RecPerPageOption.add(new SelectOption('100','100'));
        RecPerPageOption.add(new SelectOption('200','200'));
        RecPerPage = 10; //default records per page
        defaultQuery='';
        // initialization alpha list
  //      AlphaList = new list<String> {'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'Other', 'All'};
            SortFieldSave = SortField;
        
        /* alpha filter, use page parameter or set default to all
        if (apexpages.currentpage().getparameters().get('alpha') == null) {
            AlphaFilter = 'All';
        } else {
            AlphaFilter = apexpages.currentpage().getparameters().get('alpha');
        } */
        
        // list generation
        BuildQuery();  
    }
    
     

    
   

    /***
    * StdSetControllerOppurtunity - paging through the Oppurtunity list
    ***/ 
  /*  public ApexPages.StandardSetController StdSetControllerOppurtunity {
        get {
            if(StdSetControllerOppurtunity == null) {
                set<Id> recentOptyIDs = new set<Id>();
                for(RecentlyViewed rvRec:[SELECT Id, Name FROM RecentlyViewed  WHERE Type ='Opportunity' ORDER BY LastViewedDate DESC]){
                    recentOptyIDs.add(rvRec.Id);
                }
                defaultQuery = 'Select Id,Name,Account.Name,StageName,License_Amount__c,ACV_Subscription_Only__c,CloseDate,Type,Owner.LastName,Lines_of_Businesses__c FROM Opportunity where Id IN:recentOptyIDs';
                StdSetControllerOppurtunity = new ApexPages.StandardSetController(Database.getQueryLocator(defaultQuery));
                if(StdSetControllerOppurtunity!=null)
                {
                    system.debug(StdSetControllerOppurtunity.getResultSize());
                    oppIDs = new set<id>();
                    if(OppFilterId != null)
                    {
                        StdSetControllerOppurtunity.setFilterId(OppFilterId);
                    }
                    StdSetControllerOppurtunity.setPageSize(StdSetControllerOppurtunity.getResultSize());
                    for(Opportunity c:(list<Opportunity>)StdSetControllerOppurtunity.getRecords())
                    {
                        oppIDs.add(c.id);    
                    }
                }
                if(oppIDs!=Null)
                {
                    BuildQuery();
                    StdSetControllerOppurtunity = new ApexPages.StandardSetController(Database.getQueryLocator(QueryOppurtunity));
                    StdSetControllerOppurtunity.setPageSize(Integer.valueOf(RecPerPage));
                    noOfRecords = StdSetControllerOppurtunity.getResultSize();
                    system.debug(StdSetControllerOppurtunity.getResultSize());
                }
            }
            return StdSetControllerOppurtunity;
        }
        set;
    } */
    
    
     public ApexPages.StandardSetController StdSetControllerOppurtunity {
        get {
            if(StdSetControllerOppurtunity == null) {
                set<Id> recentOptyIDs = new set<Id>();
                for(RecentlyViewed rvRec:[SELECT Id, Name FROM RecentlyViewed  WHERE Type ='Opportunity' ORDER BY LastViewedDate DESC]){
                    recentOptyIDs.add(rvRec.Id);
                }
                defaultQuery = 'Select Id,Name,CurrencyIsoCode,Account.Name,StageName,License_Amount__c,ACV_Subscription_Only__c,CloseDate,Type,Owner.LastName,Lines_of_Businesses__c FROM Opportunity where Id IN:recentOptyIDs';
                StdSetControllerOppurtunity = new ApexPages.StandardSetController(Database.getQueryLocator(defaultQuery));
                 system.debug('totalRecords'+StdSetControllerOppurtunity.getResultSize());
                if(StdSetControllerOppurtunity!=null)
                {
                    system.debug(StdSetControllerOppurtunity.getResultSize());
                    oppIDs = new set<id>();
                    if(OppFilterId != null)
                    {
                       if(StdSetControllerOppurtunity.getResultSize()==0)
                       {
                       StdSetControllerOppurtunity = new ApexPages.StandardSetController(Database.getQueryLocator('Select Id,Name from opportunity limit 10000'));    
                       }
                        StdSetControllerOppurtunity.setFilterId(OppFilterId);
                        
                    }
                    integer totalRecords = StdSetControllerOppurtunity.getResultSize();
                    system.debug('totalRecords'+totalRecords);
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
                        List<opportunity> TempOPList;
                       TempOPList = new list<Opportunity>();
                       for(integer i = 0; i< totalPages ;i ++)
                       {
                           StdSetControllerOppurtunity.setPageSize(1500);
                           TempOPList.addall((list<Opportunity>)StdSetControllerOppurtunity.getRecords());
                           if(StdSetControllerOppurtunity.gethasnext())
                               StdSetControllerOppurtunity.next();
                           else
                              break;
                               
                       }
                           system.debug('listtemp'+TempOPList.size());
                        system.debug('totalPages'+totalPages);
                       for(Opportunity c:TempOPList)
                    {
                        oppIDs.add(c.id);    
                    } 
                   
                    }
                    else if(totalRecords >= 10000)
                    {
                        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'List view size limit(10,000) is exceeded.Please refresh the page and try again .If issues persists please contact the administrator.'));
                        
                    }
                   //  StdSetControllerOppurtunity.setPageSize(StdSetControllerOppurtunity.getResultSize());
                    
                if(oppIDs!=Null)
                {
                    BuildQuery();
                    StdSetControllerOppurtunity = new ApexPages.StandardSetController(Database.getQueryLocator(QueryOppurtunity));
                    StdSetControllerOppurtunity.setPageSize(Integer.valueOf(RecPerPage));
                    noOfRecords = StdSetControllerOppurtunity.getResultSize();
                    system.debug(StdSetControllerOppurtunity.getResultSize());
                }    
                    
                }
                
            }
            return StdSetControllerOppurtunity;
        }
        set;
    }
    
    
    /***
    * getCurrentOppurtunityList - return an Oppurtunity list for the table
    ***/  
     public list<Opportunity> getCurrentOpportunityList() {
        return (list<Opportunity>)StdSetControllerOppurtunity.getRecords();
    }
  
    
 
    
   
    
    /***
    * BuildQuery - build query command for list selection change
    ***/
    public void BuildQuery() {
        StdSetControllerOppurtunity = null;
        String QueryWhere = '';
        
    /*    if (AlphaFilter == null || AlphaFilter.trim().length() == 0) {
            AlphaFilter = 'All';
        } */
        QueryOppurtunity = 'Select Id,Name,CurrencyIsoCode,Account.Name,StageName,License_Amount__c,ACV_Subscription_Only__c,CloseDate,Type,Owner.LastName,Lines_of_Businesses__c ' +
            ' FROM Opportunity';
        
    /*    if (AlphaFilter == 'Other') {
            QueryWhere = BuildWhere(QueryWhere, '(' + String.escapeSingleQuotes(SortField) + ' < \'A\' OR ' + 
                                    String.escapeSingleQuotes(SortField) + ' > \'Z\') AND (NOT ' + 
                                    String.escapeSingleQuotes(SortField) + ' LIKE \'Z%\') ');
        } else if (AlphaFilter != 'All') {
            QueryWhere = BuildWhere(QueryWhere, '(' + String.escapeSingleQuotes(SortField) + ' LIKE \'' + String.escapeSingleQuotes(AlphaFilter) + '%\')' );
        } */
         if( oppIDs!=null && oppIDs.size()>0)
        {
            QueryOppurtunity += QueryWhere + ' where ID In :oppIDs';
        }
        else
        {
            test = new set<id>();
            QueryOppurtunity += QueryWhere + ' where ID In :test';
        }
        QueryOppurtunity += QueryWhere;
        QueryOppurtunity += ' ORDER BY ' + String.escapeSingleQuotes(SortField) + ' ' + String.escapeSingleQuotes(SortDirection) + ' LIMIT 10000';
        
        system.debug('QueryOppurtunity:' + QueryOppurtunity);
    }
    
    /***
    * BuildWhere - build soql string for where criteria 
    **
    public String BuildWhere(String QW, String Cond) {
        if (QW == '') {
            return ' WHERE ' + Cond;
        } else {
            return QW + ' AND ' + Cond;
        }
    } */
    
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
        // reset alpha filter and sort sequence when sorted field is changed
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
      StdSetControllerOppurtunity = null;
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


/* public class OpenOppurtunityTabController {

    public boolean optyListVisible{get;set;}
    //private list<RecentlyViewed> recentView{get;set;}
    private list<opportunity> recentOpty = new list<opportunity>();
    
    public OpenOppurtunityTabController(ApexPages.StandardSetController controller) {
        optyListVisible = false;
    }
    
    public list<opportunity> getrecentOpty(){
        //recentView = new list<RecentlyViewed>();
        //recentView = [SELECT Id, Name FROM RecentlyViewed  WHERE Type ='Opportunity' ORDER BY LastViewedDate DESC];
        set<Id> recentOptyIDs = new set<Id>();
        for(RecentlyViewed rvRec:[SELECT Id, Name FROM RecentlyViewed  WHERE Type ='Opportunity' ORDER BY LastViewedDate DESC]){
            recentOptyIDs.add(rvRec.Id);
        }
        if(recentOptyIDs.size()>0){
            recentOpty = [Select Id,Name,recordtype.Name,Account.Name,StageName,CloseDate,Type,Owner.LastName from Opportunity where Id IN:recentOptyIDs];
        }
        return recentOpty;
    } 

} */