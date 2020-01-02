public class LMSInstallSitesComponentController {
	public String endUserAccountId {get; set;}
    public String[] soldToAccountIds {get; set;}
    public String userType {get; set;}
    
    public InstallSiteWrapper installSite {get; set;}
    public Boolean displayPopup {get; set;}
    public String selectedInstallSite {get; set;}
    
    public Integer totalRecords {get; set;}
    public String selectedActiveInactive {get; set;}
    
    public LMSInstallSitesComponentController(){
    	displayPopup = false;
        selectedActiveInactive = '-- ALL --';
    }
    
    public List<SelectOption> getActiveInactive(){
        List<SelectOption> activeInactive = new List<SelectOption>();
        activeInactive.add(new SelectOption('-- ALL --', '-- ALL --'));
        activeInactive.add(new SelectOption('Yes', 'Yes')); 
        activeInactive.add(new SelectOption('No', 'No'));   
        return activeInactive;
    }
    
    public List<InstallSiteWrapper> getInstallSites(){
        String query = 'SELECT Id, Name, AddressLine1__c, AddressLine2__c, AddressLine3__c, City__c, State__c, Country__c, PostalCode__c, '
            		 + 'Account__c, Active__c FROM LMS_Install_Site__c WHERE Account__c = \''+endUserAccountId+'\'';
        if(selectedActiveInactive == 'Yes'){
            query = query + ' AND Active__c = true ';
        } else if(selectedActiveInactive == 'No') {
            query = query + ' AND Active__c = false ';
        }
        query = query + ' ORDER By Name ';
        // 
        List<InstallSiteWrapper> allSites = new List<InstallSiteWrapper>();
        for(LMS_Install_Site__c iSite : Database.query(query)){
            allSites.add(new InstallSiteWrapper(iSite));
        }
        totalRecords = allSites.size(); 
    	return allSites;  
    }
    
    public void addInstallSite(){
    	displayPopup = true;  
        installSite = new InstallSiteWrapper(endUserAccountId); 
    }
    
    public void editInstallSite(){
    	displayPopup = true;  
        LMS_Install_Site__c iSite = [SELECT Id, Name, AddressLine1__c, AddressLine2__c, AddressLine3__c, City__c, State__c, Country__c, PostalCode__c, Account__c, Active__c 
                                            FROM LMS_Install_Site__c WHERE id = :selectedInstallSite]; 
        installSite = new InstallSiteWrapper(iSite); 
    }
    
    public void saveInstallSite(){
    	displayPopup = false;  
        upsert(installSite.getInstallSiteSObject()); 
    }
    
    public void cancelInstallSite(){
       	displayPopup = false;  
    }
    
    public class InstallSiteWrapper {
        public String id {get; set;}
        public String name {get; set;}
        public String addressLine1 {get; set;}
        public String addressLine2 {get; set;}
        public String addressLine3 {get; set;}
        public String city {get; set;}
        public String state {get; set;}
        public String country {get; set;}
		public String postalCode {get; set;}
        public String account {get; set;}
        public Boolean active {get; set;}
        
		public InstallSiteWrapper(String endUserAccountId){
            this.account = endUserAccountId;
            this.name = ' ';
            this.active = true;
        }
        
        public InstallSiteWrapper(LMS_Install_Site__c installSite){
            this.id = installSite.Id;
            this.name = installSite.Name;
            this.addressLine1 = installSite.AddressLine1__c;
            this.addressLine2  = installSite.AddressLine2__c;
            this.addressLine3  = installSite.AddressLine3__c;
            this.city  = installSite.City__c;
            this.state  = installSite.State__c;
            this.country  = installSite.Country__c;
            this.postalCode  = installSite.PostalCode__c;
            this.account  = installSite.Account__c;
            this.active  = installSite.Active__c;    
        }
        
        public LMS_Install_Site__c getInstallSiteSObject(){
            return new LMS_Install_Site__c(
            	id = this.id,
                Name = this.name,
                AddressLine1__c = this.addressLine1,
                AddressLine2__c = this.addressLine2,
                AddressLine3__c = this.addressLine3,
                City__c = this.city,
                State__c = this.state,
                Country__c = this.country,
                PostalCode__c = this.postalCode,
                Account__c = this.account,
                Active__c = this.active
            ); 
        }
    }
}