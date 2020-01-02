public with sharing class POCRequestUserAccess
{
  public List<POC_Engagement_Request__c>list_POCReq{get;set;}
  public Integer pageSize {get; set;}
  Public Integer noOfRecords{get; set;} 
  public string BaseURL{get;set;}
  public string sCustomURL{get;set;} 
  public Id UserId {get;set;} 
  
  public POCRequestUserAccess(ApexPages.StandardController ctrl)
  {
    list_POCReq =  new List<POC_Engagement_Request__c>();
    noOfRecords = list_POCReq.size();
    UserId =UserInfo.getUserId();
    FilterUsers();
  }
  public List<POC_Engagement_Request__c> getUserRecords() {
    return (List<POC_Engagement_Request__c>) con.getRecords();
  }
  public void FilterUsers()
  {
    /*
        Who should see what
        AE- Only see the Wow DSR they submitted
        AE Manager – See all Wow DSR requests submitted from their direct reports 
        SC, BC, and their managers– See all requests
        Solution Leads – See all requests
        Upper management/Admins: Se all requests 
    */
    BaseURL = string.valueof(URL.getSalesforceBaseUrl().toExternalForm());

    /* check logged in user */
    Id sLoggedInUserId = UserInfo.getUserId();
    /* Get Profile Name */
    string sProfileId = UserInfo.getProfileId();
    Profile objProfile = [Select Name from Profile where id =: sProfileId];
    //added by Swastika
     list_POCReq = [Select Opportunity_Id__r.Account.id,Opportunity_Id__c,CreatedBy.Name,LastModifiedBy.Name,Id,name,Opportunity_Id__r.Name,Opportunity_Id__r.Account.Name,AssignTo__c,POC_Status__c,AE__r.Name,Lead__r.Name,createddate,lastmodifiedDate from POC_Engagement_Request__c ORDER BY CreatedDate DESC];
     sCustomURL = BaseURL + '/apex/POCEngagementRequest?id=';         
    system.debug('+++custom URl+++'+sCustomURL);
  }

  public ApexPages.StandardSetController con {
    get {
        if(con == null) {
            pageSize = 25;
           
            con = new ApexPages.StandardSetController(list_POCReq);
            
            //Sets the number of records in each page set
            con.setPageSize(pageSize);
        }
        return con;
    }
    set;
  }
 
     // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return con.getHasNext();
        }
        set;
    }
    
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {
            return con.getHasPrevious();
        }
        set;
    }
  
    // returns the page number of the current page set
    public Integer pageNumber {
        get {
            return con.getPageNumber();
        }
        set;
    }
    
    // returns totall number of records
    public Integer resultSize {
        get {
            return con.getresultSize();
        }
        set;
    }
    
    // returns the first page of records
    public void first() {
        con.first();
    }
    
    // returns the last page of records
    public void last() {
        con.last();
    }
  
    // returns the previous page of records
    public void previous() {
        con.previous();
    }
    
    // returns the next page of records
    public void next() {
        con.next();
    }
    /**
    * Method to calculate total number of pages 
    * @return number of page set    
    */
    public Integer getTotalPages() {
        System.debug('resultSize-->'+resultSize);
        System.debug('pageSize-->'+pageSize);
        
        if(math.mod(resultSize, pageSize) > 0) {
            return resultSize/pageSize + 1;
        }
        else {
            return (resultSize/pageSize);
        }
    }
}