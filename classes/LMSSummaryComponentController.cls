public class LMSSummaryComponentController {
	public DateTime activationFileLastActivity {get; set;}
   
    public String accountId; //This is used to sense change in account middle of update activity
    public String endUserAccountId {get; 
        set{
            if(accountId <> value){
		        selectedProductLine = '-- ALL --';
		        selectedInstallSite = 'All Install Sites';
                licenseSummaryData = null;
                totalRecords = 0;
	            firstTimeLoaded = false;
            }
            endUserAccountId=value;
            accountId=value;
        }
    }
    public String[] soldToAccountIds {get; set;}
    public String userType {get; set;}
    public String selectedProductLine {get; set;}
    public String selectedInstallSite {get; set;}
    public transient boolean firstTimeLoaded {get; set;}
    public transient List<LicenseSummaryWrapper> licenseSummaryData {get; set;}
    public void getloadsummary(){
        loadLicenseSummaryData();
    }
  /*  public transient List<LicenseSummaryWrapper> licenseSummaryData {
        get{
            DateTime activationFileLastActivityNew = DateTime.now();
            AggregateResult[] groupedResults = [SELECT Max(SystemModStamp) maxTimeStamp FROM License_Request_Log__c WHERE End_User__c = :endUserAccountId];
            if(!groupedResults.isEmpty()){
        		activationFileLastActivityNew = (DateTime)groupedResults[0].get('maxTimeStamp');		        
            } 
		
            if(firstTimeLoaded != true || activationFileLastActivity != activationFileLastActivityNew){
				loadLicenseSummaryData();
                firstTimeLoaded = true;
                activationFileLastActivity = activationFileLastActivityNew;
            }
           
            return licenseSummaryData;
        }
        set;
    }*/
    public Integer totalRecords {get; set;}
    
    public LMSSummaryComponentController(){
        selectedProductLine = '-- ALL --';
        selectedInstallSite = 'All Install Sites';
        licenseSummaryData = null;
        totalRecords = 0;
        firstTimeLoaded = false;
    }
    
    public boolean getPendingRefresh(){
        Boolean pendingRefresh = false;
        Integer refreshCount = 0;
        if(userType != 'Internal')
            refreshCount = [SELECT count() FROM License_Snapshot_Sold_To_End_User__c WHERE 
            	             Sold_To__c IN :soldToAccountIds AND End_User__c = :endUserAccountId AND
                	         (Snapshot_Generated__c = false OR Regenerate_Snapshot__c = true)];
        else
        	refreshCount = [SELECT count() FROM License_Snapshot_Sold_To_End_User__c WHERE 
            	             End_User__c = :endUserAccountId AND
                	         (Snapshot_Generated__c = false OR Regenerate_Snapshot__c = true)];
        if(refreshCount > 0){
        	pendingRefresh = true;    
        }	
        return pendingRefresh;
    }
    
    public void refreshSnapshot(){
    	if(userType != 'Internal')
			LicenseSnapshotUtil.refreshSnapshot(endUserAccountId, soldToAccountIds);
		else	   
			LicenseSnapshotUtil.refreshSnapshot(endUserAccountId);
    }
    
    public List<SelectOption> getProductLines(){
        Set<String> productLines = new  Set<String>();
        for(License_Snapshot__c lsh : [SELECT id, Product_Category_Version__c FROM License_Snapshot__c WHERE End_User__c = :endUserAccountId AND Product_Category_Version__c != 'xIC SOCACD'
                                       ORDER BY Product_Category_Version__c]){
            if(lsh.Product_Category_Version__c != NULL && lsh.Product_Category_Version__c != '')
            	productLines.add(lsh.Product_Category_Version__c);
        }
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('-- ALL --', '-- ALL --'));
        for(String pl : productLines){
	        options.add(new SelectOption(pl, pl));
        }
        return options;
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
    
    //public List<LicenseSummaryWrapper> getLicenseSummaryData(){
    public void loadLicenseSummaryData(){
        
        if(activationFileLastActivity == NULL){
        	AggregateResult[] groupedResults = [SELECT Max(SystemModStamp) maxTimeStamp FROM License_Request_Log__c WHERE End_User__c = :endUserAccountId];
            if(!groupedResults.isEmpty()){
        		activationFileLastActivity = (DateTime)groupedResults[0].get('maxTimeStamp');		        
            } 
        }
        
        List<LicenseSummaryWrapper> licenseSummaryDataList = new List<LicenseSummaryWrapper>();
        Set<String> invalidPartNumber =new Set<String>{'%SOCACD%'};
        
        String snapshotQueryConditions = ' AND End_User__c = \''+endUserAccountId +'\' ';
        if(userType != 'Internal'){
            snapshotQueryConditions = snapshotQueryConditions + ' AND Sold_To__c IN '+ LicenseManagementUtil.convertListToSOQLString(soldToAccountIds) +' ';
        } 
        if(selectedProductLine != '-- ALL --'){
        	snapshotQueryConditions = snapshotQueryConditions + ' AND Product_Category_Version__c = \''+selectedProductLine +'\' ';
        } 
        
        String snapshotQuery = 'SELECT id, Part_Number__c, Description__c, Product_Category_Version__c, Perpetual__c, Non_Perpetual__c, Total__c, '
            				 + 'Change_Date__c, Sold_To__c FROM License_Snapshot__c WHERE IsActive__c = true AND (NOT Part_Number__c like :invalidPartNumber) '  + snapshotQueryConditions + ' ORDER BY Part_Number__c';
        System.debug('snapshotQuery = ' + snapshotQuery);
        List<License_Snapshot__c> licenseSnapShotData = Database.query(snapshotQuery);
		
        String usageQueryConditions = ' AND License_Request_Log__r.End_User__c = \''+endUserAccountId +'\' ';
        if(userType != 'Internal'){
            usageQueryConditions = usageQueryConditions + ' AND License_Request_Log__r.Sold_To__c IN '+ LicenseManagementUtil.convertListToSOQLString(soldToAccountIds) +' ';
        }
        
        System.debug('selectedInstallSite = ' + selectedInstallSite);
        String installSiteQueryConditions = '';
		if(selectedInstallSite != 'All Install Sites'){
            installSiteQueryConditions = installSiteQueryConditions + ' AND License_Request_Log__r.Install_Site__c = \''+selectedInstallSite+'\' ';
        }
        String usageQuery = 'SELECT License_Request_Log__r.Sold_To__c soldTo, Product__r.APN_Number__c productNumber, SUM(Quantity_Used__c) quantity '
				     + 'FROM License_Usage__c WHERE License_Request_Log__r.IsActive__c  = true ' + usageQueryConditions
					 + 'GROUP BY License_Request_Log__r.Sold_To__c, Product__r.APN_Number__c';

        String installSiteUsageQuery = 'SELECT License_Request_Log__r.Sold_To__c soldTo, Product__r.APN_Number__c productNumber, SUM(Quantity_Used__c) quantity '
				     + 'FROM License_Usage__c WHERE License_Request_Log__r.IsActive__c = true ' + usageQueryConditions + installSiteQueryConditions
            		 + 'GROUP BY License_Request_Log__r.Sold_To__c, Product__r.APN_Number__c';
		
		Map<String, Integer> licensesUsed = new Map<String, Integer>();
        Map<String, Integer> installSiteLicensesUsed = new Map<String, Integer>();
        System.debug('endUserAccountId = ' + endUserAccountId);
        AggregateResult[] usageResults = Database.query(usageQuery);
		for (AggregateResult ar : usageResults ) {
        	licensesUsed.put(String.valueOf(ar.get('soldTo')) + '-' + String.valueOf(ar.get('productNumber')), Integer.valueOf(ar.get('quantity')));
        }
        if(selectedInstallSite == 'All Install Sites'){
         	installSiteLicensesUsed = licensesUsed;   
        } else {
	        AggregateResult[] installSiteUsageResults = Database.query(installSiteUsageQuery);
			for (AggregateResult ar : installSiteUsageResults ) {
	        	installSiteLicensesUsed.put(String.valueOf(ar.get('soldTo')) + '-'+ String.valueOf(ar.get('productNumber')), Integer.valueOf(ar.get('quantity')));
	        }
    	}
        Set<String> partNumbers = new Set<String>(); 
        for(License_Snapshot__c lsh : licenseSnapShotData){
            partNumbers.add(lsh.Part_Number__c);
        }

        
        Map<String, List<String>> partNumberKeys = new Map<String, List<String>>();
        List<License_Translations__c> ltRecords = [SELECT Id, Item_Number__c, License_Key__r.Key_Name__c, Multiplier__c, Assigned_Multiplier__c, Show_Assigned_Multiplier__c FROM License_Translations__c WHERE  Item_Number__c IN :partNumbers];
		System.debug('All Queries executed');
        for(License_Translations__c lt : ltRecords){
            String multipliersString = '';
            if(lt.Show_Assigned_Multiplier__c){
                multipliersString = lt.Show_Assigned_Multiplier__c == true ? lt.Assigned_Multiplier__c.intValue() + ' assigned' + ', ' : '';
                multipliersString = multipliersString + lt.Multiplier__c.intValue() + ' pooled';
                multipliersString = ' (' + multipliersString + ') ';
            } else {
                multipliersString = ' (' + multipliersString + (lt.Multiplier__c != NULL ? lt.Multiplier__c.intValue() : 0) + ') ';
            }
            
            if(partNumberKeys.containsKey(lt.Item_Number__c)){
                partNumberKeys.get(lt.Item_Number__c).add(lt.License_Key__r.Key_Name__c + multipliersString);   
            } else {
                partNumberKeys.put(lt.Item_Number__c, new List<String>{lt.License_Key__r.Key_Name__c + multipliersString}) ;   
            }
        }
            
        for(License_Snapshot__c lsh : licenseSnapShotData){
            licenseSummaryDataList.add(new LicenseSummaryWrapper(lsh.Part_Number__c, lsh.Product_Category_Version__c, lsh.Description__c, lsh.Total__c, 
            													licensesUsed.get(lsh.Sold_To__c + '-' + lsh.Part_Number__c) != NULL ? licensesUsed.get(lsh.Sold_To__c + '-' + lsh.Part_Number__c) : 0, 
            													installSiteLicensesUsed.get(lsh.Sold_To__c + '-' + lsh.Part_Number__c) != NULL ? installSiteLicensesUsed.get(lsh.Sold_To__c + '-' + lsh.Part_Number__c) : 0, 
            													partNumberKeys.get(lsh.Part_Number__c)));
        }
        totalRecords = licenseSummaryDataList.size();
        System.debug('Total Records = ' + totalRecords);
        licenseSummaryData = licenseSummaryDataList;
        // return licenseSummaryDataList;
    }
    
    public void clearFilters(){
    	selectedProductLine = '-- ALL --';
        selectedInstallSite = 'All Install Sites';  
        loadLicenseSummaryData();
    }
    
    public class LicenseSummaryWrapper{
        public String partNumber {get; set;}
        public String category {get; set;}
        public String description {get; set;}
        public Decimal total {get; set;}
        public Decimal used {get; set;}
        public Decimal currentUsed {get; set;}
        public Decimal available {get; set;}
        public List<String> partKeys {get; set;}
        
        public LicenseSummaryWrapper(String partNumber, String category, String description, Decimal total, Decimal used, Decimal currentUsed, List<String> partKeys){
            this.partNumber = partNumber;
            this.category = category;
            this.description = description;
            this.total = total;
            this.currentUsed = currentUsed != NULL ? currentUsed : 0;
            this.used = used != NULL ? used : 0;
            this.available = this.total - this.used;
            this.partKeys = new List<String>(); 
            if(partKeys != NULL)
            	this.partKeys = partKeys;
            else 
            	this.partKeys = new List<String>{'This item is legally licensed however no license string appears to \'key\' the item in the product.'};
        }
    }
}