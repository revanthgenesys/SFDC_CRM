public class SubscriptionActivityComponentController {
    public String accountId; //This is used to sense change in account middle of update activity
    public Contact accountSelection {get; set;}
    public String selectedProductLine {get; set;}
    public Boolean showResult {get; set;}
    public String endUserAccountId {get; 
        set{
            if(accountId <> value){
                cancel();
                resetFilters();
            }
            endUserAccountId=value;
            accountId=value;
        }
    }
  
    public Integer totalRecords {get; set;}
    public String userType {get;set;}
    public String selectedLicenseRequestId {get; set;}
    public String selectedActiveInactive {get; set;}
    String selectedLicenseRequest;
    Public LicenseRequestWrapper currentRequest;
    
    public String urlPrefix {get; set;}
    public boolean displayAlert {get; set;}
    public boolean records500Plus {get; set;}
    public List<LicenseRequestWrapper> licenseRequestLogs {get; set;}
    
    public SubscriptionActivityComponentController (){
        urlPrefix = Site.getPathPrefix() != NULL ? Site.getPathPrefix() : '';
        accountSelection = new Contact();
        selectedActiveInactive = 'Yes';
        selectedProductLine = '-- ALL --';
        displayAlert = false;
        records500Plus = false; 
       }
    public void goClicked(){
       if(accountSelection.AccountId <> NULL)
           showresult = True;
       else
           showresult = false;    
      system.debug('accountSelection.accountId'+accountSelection.accountId);     
    }
    
    public List<SelectOption> getProductLines(){
        Set<String> productTypes = new Set<String>();
        for (Subscription_Request_Log__c lrr : [SELECT Product_Type__c FROM Subscription_Request_Log__c WHERE End_User__c = :accountSelection.AccountId ORDER BY Product_Type__c]){
            productTypes.add(lrr.Product_Type__c);
        }
        
        List<SelectOption> productLines = new List<SelectOption>();
        productLines.add(new SelectOption('-- ALL --', '-- ALL --'));
        for (String s : productTypes){
            productLines.add(new SelectOption(s, s));
        }
        return productLines;
    }
    
    public List<SelectOption> getActiveInactive(){
        List<SelectOption> activeInactive = new List<SelectOption>();
        activeInactive.add(new SelectOption('-- ALL --', '-- ALL --'));
        activeInactive.add(new SelectOption('Yes', 'Yes')); 
        activeInactive.add(new SelectOption('No', 'No'));   
        return activeInactive;
    }
    
    public void resetFilters(){
        selectedActiveInactive = 'Yes';
        selectedProductLine = '-- ALL --';
        records500Plus = false;     
        licenseRequestLogs = NULL;
    }

    public void clearFilters(){
        resetFilters();
    }
        
    public void cancel() {
      
    }
    public void hideAlert(){
        displayAlert = false;    
    }
    public void showAlert(){
        displayAlert = true;    
    }
    
    public List<LicenseRequestWrapper> getLicenseRequests(){
        initLicenseRequests();
        return licenseRequestLogs;
    }
    
   
    public void initLicenseRequests(){
        Date startDate;
        Date endDate;                   
        String queryConditions = ' WHERE End_User__c = \''+accountSelection.AccountId+'\' ';    
                    system.debug('inside if selectedProductLine:'+selectedProductLine);  
        if(selectedProductLine != '-- ALL --'){
            queryConditions = queryConditions + ' AND Product_Type__c = \''+selectedProductLine+'\' ';
        }                     
        if(selectedActiveInactive == 'Yes'){
            queryConditions = queryConditions + ' AND IsActive__c = true ';
        } else if(selectedActiveInactive == 'No') {
            queryConditions = queryConditions + ' AND IsActive__c = false ';
        }     
        
        String query = 'SELECT Id, Name,Requested_By__c,Requested_By__r.Name,Generation_Date__c, Expiration_Date__c, System_Type__c, '
                     + 'Product_Type__c, Mail_Connector__c, License_Type__c, License_Type__r.Name, Machine_Name__c, MAC_Address__c, '
                     + 'End_User__c, End_User__r.Name, Sold_To__c, Sold_To__r.Name,'
                     + 'Notes__c,IsActive__c FROM Subscription_Request_Log__c  '; 
                  
        Integer recordsCount = Database.countQuery('SELECT Count() FROM Subscription_Request_Log__c ' + queryConditions);
        
        String orderConditions = ' ORDER BY Generation_Date__c DESC';
        String limitConditions = ' LIMIT 500 ';
        
        List<Subscription_Request_Log__c> licenseRequests = new List<Subscription_Request_Log__c>();
        if(recordsCount > 1000){
            records500Plus = true;
            licenseRequests = Database.query(query + queryConditions + orderConditions + limitConditions);
        } else {
            records500Plus = false;
            licenseRequests = Database.query(query + queryConditions + orderConditions);
        }       
        
        licenseRequestLogs = new List<LicenseRequestWrapper>(); 
        for(Subscription_Request_Log__c lrl : licenseRequests){
            licenseRequestLogs.add(new LicenseRequestWrapper(lrl));    
        }
        totalRecords = licenseRequestLogs.size();
        // return licenseRequests;
    }
    
    public void deactivateLicense(){
        if(String.isNotBlank(selectedLicenseRequestId)){
            Subscription_Request_Log__c  rLog = new Subscription_Request_Log__c(Id = selectedLicenseRequestId, IsActive__c = false); 
            database.update(rLog, false);
            selectedLicenseRequestId = null;
        }
        displayAlert = false;  
        //initLicenseRequests();
    }
    
  
    public class LicenseRequestWrapper{
        
        public String id {get; set;}
        public String name {get; set;}
        public String requestedBy {get; set;}
        public String generationDate {get; set;}
        public String expirationDate {get; set;}
        public DateTime generationDateTime {get; set;}
        public DateTime expirationDateTime {get; set;}
        public String systemType {get; set;}
        public String productType {get; set;}
        public String mailConnector {get; set;}
        public String licenseType {get; set;}
        public String machineName {get; set;}
        public String macAddress {get; set;}
        public String endUserId {get; set;}
        public String endUserName {get; set;}
        public String soldToId {get; set;}
        public String soldToName {get; set;}
        public Boolean active {get; set;}
        public String notes {get; set;}
        
        public Boolean certified {get; set;}
        public Boolean canUpdate {get; set;}
        public Boolean canDeactivate {get; set;}

        
        public Boolean expired {get; set;}  
        public List<String> machineNames {
            get{
                String mn = machineName.replace('|',',');
                return mn.split(',');         
            }
            set;
        }
        public Boolean isMultipleMachines {
            get{
                String mn = machineName.replace('|',',');
                List<String> splitMachines = mn.split(',');         
                return (splitMachines.size() > 1) ? true : false; 
            }
            set;
        }
        public LicenseRequestWrapper(Subscription_Request_Log__c requestLog){
            this.certified = false;
            this.canUpdate = false;
            this.canDeactivate = false;
            
            this.id = requestLog.Id;
            this.name = requestLog.Name;
            this.generationDateTime = requestLog.Generation_Date__c;
            this.expirationDateTime = requestLog.Expiration_Date__c;
            this.requestedBy = requestLog.requested_By__r.Name;
            this.generationDate = requestLog.Generation_Date__c.date().format();
            this.expirationDate = requestLog.Expiration_Date__c.date().format();
            this.systemType = requestLog.System_Type__c;
            this.productType = requestLog.Product_Type__c;
            this.mailConnector = requestLog.Mail_Connector__c;
            this.licenseType = requestLog.License_Type__r.Name;
            this.machineName = requestLog.Machine_Name__c;
            this.macAddress = requestLog.MAC_Address__c;
            this.endUserId = requestLog.End_User__c;
            this.endUserName = requestLog.End_User__r.Name;
            this.soldToId = requestLog.Sold_To__c;
            this.soldToName = requestLog.Sold_To__r.Name;
            this.active = requestLog.IsActive__c;
            this.notes = requestLog.Notes__c;
            this.expired = (requestLog.Expiration_Date__c != NULL && Date.Today().daysBetween(requestLog.Expiration_Date__c.date()) < 0) ? true : false;
        }
    }
}