public without sharing class TechnologyLicenseFormController {
    public Technology_License_Form__c  licenseForm {get;set;}
    public Integer pageSize {get; set;}
    public List<Technology_License_Form__c> technologyLicenseFormList {get;set;}
    public boolean hasAppFoundryApproved {get;set;}
    public boolean appFoundryApplicationNotRequired {get;set;}
    public Id userAccountId;
    
    public TechnologyLicenseFormController(ApexPages.StandardController stdController) { 
        userAccountId = getUserAccountId(); 

        User currentUser = [SELECT Id, Name, Contact.AccountId, Contact.Account.AppFoundry_Application_Not_Required__c from User where Id = :Userinfo.getUserid()];
        appFoundryApplicationNotRequired = currentUser.Contact.Account.AppFoundry_Application_Not_Required__c;
        
        Integer approvedAppFoundryCount = [select count() from Technology_Market_place_Application__c where Partner_Account__c =: currentUser.Contact.AccountId and Status__c = 'Approved'];
        hasAppFoundryApproved = false;
        if(approvedAppFoundryCount >0 || appFoundryApplicationNotRequired) {
            hasAppFoundryApproved = true;
            technologyLicenseFormList = new List<Technology_License_Form__c>();
            queryTechnologyLicenseForm();
        }
        
    }
    
    public void queryTechnologyLicenseForm() {
        String licenseFormQuery = 'select Id,Product_Sold__c,Number_of_Licenses_sold__c,Sales_price_per_license__c,Customer_Name__c,Total_sale__c,CreatedDate from Technology_License_Form__c where Partner_Account__c =' +'\'' + userAccountId + '\''; 
        technologyLicenseFormList =Database.query(licenseFormQuery);
    }
    
    //Instantiate standardSetController
    public ApexPages.StandardSetController con {
        get {
            if(con == null) {
                pageSize = 10;
                con = new ApexPages.StandardSetController(technologyLicenseFormList);   
                //Sets the number of records in each page set
                con.setPageSize(pageSize);
            }
            return con;
        }
        set;
    } 
    
    public List<Technology_License_Form__c> getTechnologyLicenseForm() {
        queryTechnologyLicenseForm();
        technologyLicenseFormList =con.getRecords();
        System.debug('technologyLicenseFormList-->'+technologyLicenseFormList);
        return technologyLicenseFormList;
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
        if(math.mod(resultSize, pageSize) > 0) {
            return resultSize/pageSize + 1;
        }
        else {
            return (resultSize/pageSize);
        }
    }
    
    public static Id getUserAccountId() {
        List<User> currentUser = [select Contact.AccountId from User where Id =: Userinfo.getUserid()];
        System.debug('currentUser---'+currentUser);
        return currentUser[0].Contact.AccountId;    
    }
    
    
}