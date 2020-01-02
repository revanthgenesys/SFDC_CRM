public class LMSLicenseActivityComponentController {
    public String accountId; //This is used to sense change in account middle of update activity
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
    public Boolean showTemp {get;set;}
    public Boolean refresh {get;set;}
    public String[] soldToAccountIds {get; set;}
    public String userType {get; set;}
    public Boolean showUpdatePanel {get;set;}

    public Integer totalRecords {get; set;}
    public String selectedProductLine {get; set;}
    public String selectedLicenseType {get; set;}
    public String selectedRecordType {get; set;}        
    public String selectedLicenseRequestId {get; set;}
    public String selectedInstallSite {get; set;} 
    public String selectedActiveInactive {get; set;}
    public String searchTextGeneratedBy {get; set;} 
    public String searchTextMachineName {get; set;}
    String selectedLicenseRequest;
    Public LicenseRequestWrapper currentRequest;
    
    public String urlPrefix {get; set;}
    public boolean displayAlert {get; set;}
    public boolean records500Plus {get; set;}
    String lastCheckedRequest;
    
    public License_Snapshot_Change__c startDateObject {get; set;} 
    public License_Snapshot_Change__c endDateObject {get; set;} 
    public transient List<LicenseRequestWrapper> licenseRequestLogs {get; set;}
    
    public LMSLicenseActivityComponentController(){
        urlPrefix = Site.getPathPrefix() != NULL ? Site.getPathPrefix() : '';
        selectedProductLine = '-- ALL --';
        selectedLicenseType = '-- ALL --';
        selectedActiveInactive = 'Yes';
        selectedInstallSite = 'All Install Sites';
        searchTextGeneratedBy = '';
        searchTextMachineName = '';
        showUpdatePanel = false;
        displayAlert = false;
        records500Plus = false; 
        startDateObject = new License_Snapshot_Change__c();
        endDateObject = new License_Snapshot_Change__c();
        showTemp=False;
    }

    public List<SelectOption> getProductLines(){
        Set<String> productTypes = new Set<String>();
        for (License_Request_Log__c lrr : [SELECT Product_Type__c FROM License_Request_Log__c WHERE End_User__c = :endUserAccountId ORDER BY Product_Type__c]){
            productTypes.add(lrr.Product_Type__c);
        }
        
        List<SelectOption> productLines = new List<SelectOption>();
        productLines.add(new SelectOption('-- ALL --', '-- ALL --'));
        for (String s : productTypes){
            productLines.add(new SelectOption(s, s));
        }
        return productLines;
    }
    
    public List<SelectOption> getLicenseTypes(){
        List<SelectOption> licenseTypes = new List<SelectOption>();
        licenseTypes.add(new SelectOption('-- ALL --', '-- ALL --'));
        for (AggregateResult ar : [SELECT License_Type__r.Name ltName FROM License_Request_Log__c WHERE End_User__c = :endUserAccountId GROUP BY License_Type__r.Name]){
            licenseTypes.add(new SelectOption((String)ar.get('ltName'),(String)ar.get('ltName')));
        }
        return licenseTypes;
    }
    
    public List<SelectOption> getInstallSites(){
        List<SelectOption> installSites = new List<SelectOption>();
        installSites.add(new SelectOption('All Install Sites', 'All Install Sites'));
        for (LMS_Install_Site__c iSite : [SELECT Id, Name, Active__c FROM LMS_Install_Site__c WHERE Account__c = :endUserAccountId ORDER BY Name]){
            if(iSite.Active__c == false)
                installSites.add(new SelectOption(iSite.Id, iSite.Name + ' (Inactive)'));
            else
                installSites.add(new SelectOption(iSite.Id, iSite.Name));
        }
        return installSites;
    }
    
    public List<SelectOption> getActiveInactive(){
        List<SelectOption> activeInactive = new List<SelectOption>();
        activeInactive.add(new SelectOption('-- ALL --', '-- ALL --'));
        activeInactive.add(new SelectOption('Yes', 'Yes')); 
        activeInactive.add(new SelectOption('No', 'No'));   
        return activeInactive;
    }
    
    public void resetFilters(){
        selectedProductLine = '-- ALL --';
        selectedLicenseType = '-- ALL --';
        selectedActiveInactive = 'Yes';
        selectedInstallSite = 'All Install Sites';
        searchTextGeneratedBy = '';
        searchTextMachineName = '';
        startDateObject = new License_Snapshot_Change__c();
        endDateObject = new License_Snapshot_Change__c();
        records500Plus = false;     
        licenseRequestLogs = NULL;
    }

    public void clearFilters(){
        resetFilters();
        //initLicenseRequests();
    }
    
    public LicenseRequestWrapper getLicenseRequest() {
         if(currentRequest==NULL || currentRequest.id<>selectedLicenseRequestId){
             for(LicenseRequestWrapper w : getLicenseRequests())
                if(w.id == selectedLicenseRequestId){
                    //currentRequest = new LicenseRequestWrapper();
                    currentRequest = w;
                    return w;
                 }
          }       
          
          return currentRequest;       
    }       
    
    public void cancel() {
        showUpdatePanel = FALSE;
        selectedProductLine ='-- ALL --';
        
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
        if(licenseRequestLogs == NULL && [SELECT Count() FROM License_Request_Log__c WHERE End_User__c = :endUserAccountId AND IsActive__c = true ] > 100){
            startDateObject.Change_Date__c = Date.newInstance(Date.Today().year() - 1, 1, 1);
            endDateObject.Change_Date__c = Date.Today();    
        } 
        
        Date startDate;
        Date endDate;
        List<String> requestType = new List<String>{'Regular','Hybrid','Temporary','Dummy'};                    
        String queryConditions = ' WHERE End_User__c = \''+endUserAccountId+'\' AND Type__c IN: requestType';                     
        if(userType != 'Internal'){           
            queryConditions = queryConditions +  ' AND Sold_To__c IN '+ LicenseManagementUtil.convertListToSOQLString(soldToAccountIds) +' ';
        }
        if(selectedProductLine != '-- ALL --'){
            queryConditions = queryConditions + ' AND Product_Type__c = \''+selectedProductLine+'\' ';
        }
        if(selectedLicenseType != '-- ALL --'){
            queryConditions = queryConditions + ' AND License_Type__r.Name = \''+selectedLicenseType+'\' ';
        }
        if(selectedInstallSite != 'All Install Sites'){
            queryConditions = queryConditions + ' AND Install_Site__c = \''+selectedInstallSite+'\' ';
        }
        if(selectedActiveInactive == 'Yes'){
            queryConditions = queryConditions + ' AND IsActive__c = true ';
        } else if(selectedActiveInactive == 'No') {
            queryConditions = queryConditions + ' AND IsActive__c = false ';
        }
        if(startDateObject.Change_Date__c != NULL){
            startDate = startDateObject.Change_Date__c;
            queryConditions = queryConditions + ' AND Generation_Date__c >= :startDate';   
        }
        if(endDateObject.Change_Date__c != NULL){
            endDate = endDateObject.Change_Date__c + 1;
            queryConditions =  queryConditions + ' AND Generation_Date__c <= :endDate';    
        }
        
        if(!String.isEmpty(searchTextGeneratedBy)){
            queryConditions =  queryConditions + ' AND Generated_By__c LIKE \'%'+searchTextGeneratedBy.trim()+'%\'';    
        }
        if(!String.isEmpty(searchTextMachineName)){
            queryConditions =  queryConditions + ' AND Machine_Name__c LIKE \'%'+searchTextMachineName.trim()+'%\'';    
        }
        
        String query = 'SELECT Id, Name, Requested_By__c, Requested_By__r.Name, Generated_By__c,Generation_Date__c, Expiration_Date__c, SystemType1__c, '
                     + 'Product_Type__c, MailConnector1__c, License_Type__c,Temp_License_type__c, License_Type__r.Name, Machine_Name__c, MAC_Address__c, '
                     + 'End_User__c, End_User__r.Name, Sold_To__c, Sold_To__r.Name, Deactivated_By__c, Deactivated_Date__c, '
                     + 'Install_Site__c, Install_Site__r.Name, IsActive__c, Product_Line__r.SIP_Product__c, Internal__c, Notes__c,Type__c '
                     + 'FROM License_Request_Log__c  '; 
                  
        Integer recordsCount = Database.countQuery('SELECT Count() FROM License_Request_Log__c ' + queryConditions);
        
        String orderConditions = ' ORDER BY Generation_Date__c DESC';
        String limitConditions = ' LIMIT 100 ';
        
        List<License_Request_Log__c> licenseRequests = new List<License_Request_Log__c>();
        if(recordsCount > 100){
            records500Plus = true;
            licenseRequests = Database.query(query + queryConditions + orderConditions + limitConditions);
        } else {
            records500Plus = false;
            licenseRequests = Database.query(query + queryConditions + orderConditions);
        }       
        
        licenseRequestLogs = new List<LicenseRequestWrapper>(); 
        for(License_Request_Log__c lrl : licenseRequests){
            system.debug('inside for loop log:'+lrl);
            licenseRequestLogs.add(new LicenseRequestWrapper(lrl));    
        }
        totalRecords = licenseRequestLogs.size();
        updateCertificationInfo(licenseRequestLogs);
        // return licenseRequests;
    }
    
    public void deactivateLicense(){
        if(String.isNotBlank(selectedLicenseRequestId)){
            License_Request_Log__c  rLog = new License_Request_Log__c(Id = selectedLicenseRequestId, IsActive__c = false, Deactivated_By__c = UserInfo.getUserId(), Deactivated_Date__c = DateTime.now()); 
            database.update(rLog, false);
            selectedLicenseRequestId = null;
        }
        displayAlert = false;  
        //initLicenseRequests();
    }
    
    public void updateLicense(){
        if(lastCheckedRequest == selectedLicenseRequestId){
            if(showUpdatePanel)
                showUpdatePanel = FALSE;
            else
                showUpdatePanel = TRUE;
        }
        else
        {
            lastCheckedRequest = selectedLicenseRequestId;
            showUpdatePanel = TRUE;
        }
    }
    
    public void updateCertificationInfo(List<LicenseRequestWrapper> licenseRequests){
        User u = [SELECT id, ContactId, Contact.AccountId, ProfileId, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
        if(u.ContactId != NULL){
            List<LMS_ProductLine__c> eligibleProductLines = LMS_Utility.fetchEligibleProducts(u.ContactId);
            for(LicenseRequestWrapper lr : licenseRequests){
                lr.certified = false;
                for(LMS_ProductLine__c pLine : eligibleProductLines){
                    if(pLine.Name == lr.productType){
                        lr.certified = true;
                    }
                }
                
                if(userType != 'Internal' && lr.Internal){
                    lr.canDeactivate = False;
                    lr.canUpdate = False;
                }  

                if(userType!='Internal'){
                    if(lr.TempFileType!='' && lr.TempFileType!=NULL )
                showTemp=true;
                }

            }
        } else {
            for(LicenseRequestWrapper lr : licenseRequests){
                lr.certified = true;
                if(lr.TempFileType!='' && lr.TempFileType!=NULL )
                showTemp=true;    
            }
        }
        
        for(LMS_License_Types__c lType : [SELECT id, Name, Can_Deactivate__c, Can_Update__c FROM LMS_License_Types__c]){
            for(LicenseRequestWrapper lr : licenseRequests){
                if(lr.licenseType == lType.Name){
                    
                    lr.canDeactivate = lType.Can_Deactivate__c;
                    lr.canUpdate = lType.Can_Update__c;

                   if(lr.type!='Regular' && userType!='Internal'){
                      lr.canUpdate = false;  
                    }
                }
            }   
        }
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
        public String installSiteId {get; set;}
        public String installSiteName {get; set;}
        public Boolean active {get; set;}
        public String notes {get; set;}
        public Boolean internal {get; set;}
        public String type {get;set;}
        public String TempFileType {get;set;}
        public Boolean certified {get; set;}
        public Boolean canUpdate {get; set;}
        public Boolean canDeactivate {get; set;}
        public Boolean sipProduct {get; set;}
        
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
        public LicenseRequestWrapper(License_Request_Log__c requestLog){
            this.certified = false;
            this.canUpdate = false;
            this.canDeactivate = false;
            
            this.id = requestLog.Id;
            this.name = requestLog.Name;
            //this.requestedBy = requestLog.Requested_By__r.Name;
            this.requestedBy = requestLog.Generated_By__c;
            this.generationDateTime = requestLog.Generation_Date__c;
            this.expirationDateTime = requestLog.Expiration_Date__c;
            system.debug('expiration date: '+requestLog.Id+','+requestLog.Generation_Date__c+','+requestLog.Expiration_Date__c);            
            this.generationDate = requestLog.Generation_Date__c.date().format();
            this.expirationDate = requestLog.Expiration_Date__c.date().format();
            this.systemType = requestLog.SystemType1__c;
            this.productType = requestLog.Product_Type__c;
            this.mailConnector = requestLog.MailConnector1__c;
            this.licenseType = requestLog.License_Type__r.Name;
            this.machineName = requestLog.Machine_Name__c;
            this.macAddress = requestLog.MAC_Address__c;
            this.endUserId = requestLog.End_User__c;
            this.endUserName = requestLog.End_User__r.Name;
            this.soldToId = requestLog.Sold_To__c;
            this.soldToName = requestLog.Sold_To__r.Name;
            this.installSiteId = requestLog.Install_Site__c;
            this.installSiteName = requestLog.Install_Site__r.Name;
            this.active = requestLog.IsActive__c;
            this.sipProduct = requestLog.Product_Line__r.SIP_Product__c; 
            this.expired = (requestLog.Expiration_Date__c != NULL && Date.Today().daysBetween(requestLog.Expiration_Date__c.date()) < 0) ? true : false;
            this.internal = requestLog.Internal__c;
            this.type = requestLog.Type__c;
            this.TempFileType=requestlog.Temp_LIcense_type__c;
            
            this.notes = requestLog.Notes__c;
        }
    }
}