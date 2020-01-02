public class LMSUpgradeComponentController {
    public String accountId; //This is used to sense change in account middle of update activity
    public String endUserAccountId {get; 
        set{
            if(accountId <> value){
                resetFilters();
            }
            endUserAccountId=value;
            accountId=value;
        }
    }
    public String[] soldToAccountIds {get; set;}
    public String userType {get; set;}
    public List<SelectOption> upgradeOptions {get; set;}
    public String selectedUpgradeOption {get; set;}
    public Integer totalRecords {get; set;}
    public List<MirrorWrapper> mirrorOptions {get; set;}
    
    public String upgradeString {get; set;}
    
    //Upgrade all eligible licenses to:
    public List<PartUpgradeWrapper> availableForUpgrades {
    	get {
    		if(availableForUpgrades == NULL){
    			initialize();	
    		}
    		return availableForUpgrades;
    	} 
    	set;
    }
    public boolean displayAlert {get; set;}
	public LMSUpgradeComponentController(){
        upgradeString = 'Nothing';
        selectedUpgradeOption = '-- ALL --';
        displayAlert = false;
    }
    public void hideAlert(){
        displayAlert = false;    
    }
    public void showAlert(){
        displayAlert = true;    
    }
    public void clearFilters(){
    	selectedUpgradeOption = '-- ALL --';
    }
    
    public void resetFilters(){
     	upgradeString = 'Nothing';
        selectedUpgradeOption = '-- ALL --';
        availableForUpgrades = NULL;
    }
    
    public void initialize(){
        availableForUpgrades = new List<PartUpgradeWrapper>(); 

        List<License_Snapshot__c> licenseSnapShotData;
        Set<String> partNumbers;
        
        String query = 'SELECT id, Part_Number__c, Product_Category_Version__c, Description__c, Total__c, Change_Date__c, Sold_To__c, isMirrored__c, End_User__c '
            		 + 'FROM License_Snapshot__c '
                     + 'WHERE End_User__c = \''+endUserAccountId+'\' ';
        if(userType != 'Internal'){
            query = query + ' AND Sold_To__c IN '+ LicenseManagementUtil.convertListToSOQLString(soldToAccountIds) +' ';
        }
		query = query + ' AND IsActive__c = true ORDER BY Part_Number__c';
        licenseSnapShotData = Database.query(query);
        
        partNumbers = new Set<String>(); 
        for(License_Snapshot__c lsh : licenseSnapShotData){
            partNumbers.add(lsh.Part_Number__c);
        }
        
        Map<String, Pure_Connect_Version_Upgrade__c> upgradeConfigMap = new Map<String, Pure_Connect_Version_Upgrade__c>();
        for(Pure_Connect_Version_Upgrade__c vu: [SELECT Mapping_Type__c, Old_Product__c, Old_Product_APN_Number__c 
                                                 FROM Pure_Connect_Version_Upgrade__c 
                                                 WHERE Old_Product_APN_Number__c IN :partNumbers]){
            upgradeConfigMap.put(vu.Old_Product_APN_Number__c, vu);
        }
        
        Map<String, LMS_Mirror_Config__c> LMSMirrorConfig = LMS_Mirror_Config__c.getAll();
        Set<String> upgradeOptionSet = new Set<String>();
        Set<String> mirrorOptionSet = new Set<String>();
        for(License_Snapshot__c lsh : licenseSnapShotData){
			Boolean mirroringAvailble = false;
            if(lsh.isMirrored__c == false && upgradeConfigMap.keySet().contains(lsh.Part_Number__c) ){
                String currentMappingType = upgradeConfigMap.get(lsh.Part_Number__c).Mapping_Type__c;
                upgradeOptionSet.add(currentMappingType);
                if(selectedUpgradeOption == '-- ALL --' || selectedUpgradeOption == currentMappingType){
                    if(LMSMirrorConfig.keySet().contains(currentMappingType)){
                        mirroringAvailble = true;
                        mirrorOptionSet.add(currentMappingType);
                    }
                    availableForUpgrades.add(new PartUpgradeWrapper(lsh.Sold_To__c, lsh.Part_Number__c, lsh.Product_Category_Version__c, lsh.Description__c, lsh.Total__c, currentMappingType, mirroringAvailble, lsh.End_User__c));
                }
            } 
        }
        
        upgradeOptions = new List<SelectOption>();
        if(upgradeOptionSet.size() == 1){
        	for(String s : upgradeOptionSet){
        		selectedUpgradeOption = s;
        	}
        } else {
        	upgradeOptions.add(new SelectOption('-- ALL --', '-- ALL --'));
        }
        
        for(String s : upgradeOptionSet){
	    	upgradeOptions.add(new SelectOption(s, s));
        }
        
        mirrorOptions = new List<MirrorWrapper>();
        for(String s : mirrorOptionSet){
            mirrorOptions.add(new MirrorWrapper(s));
        }    
        
        totalRecords = availableForUpgrades.size();
    }

	public void dummyAction(){
		
	}
	
	 public List<PartUpgradeWrapper> getNotAvailableForUpgrades(){
        List<PartUpgradeWrapper> notAvailableForUpgrades = new List<PartUpgradeWrapper>();
        List<License_Snapshot__c> licenseSnapShotData;
        Set<String> partNumbers;
        
        String query = 'SELECT id, Part_Number__c, Product_Category_Version__c, Description__c, Total__c, Change_Date__c, Sold_To__c, isMirrored__c, End_User__c '
            		 + 'FROM License_Snapshot__c '
                     + 'WHERE End_User__c = \''+endUserAccountId+'\' ';
        if(userType != 'Internal'){
            query = query + ' AND Sold_To__c IN '+ LicenseManagementUtil.convertListToSOQLString(soldToAccountIds) +' ';
        }
		query = query + ' AND IsActive__c = true ORDER BY Part_Number__c';
        licenseSnapShotData = Database.query(query);
        
        partNumbers = new Set<String>(); 
        for(License_Snapshot__c lsh : licenseSnapShotData){
            partNumbers.add(lsh.Part_Number__c);
        }
        
        Map<String, Pure_Connect_Version_Upgrade__c> upgradeConfigMap = new Map<String, Pure_Connect_Version_Upgrade__c>();
        for(Pure_Connect_Version_Upgrade__c vu: [SELECT Mapping_Type__c, Old_Product__c, Old_Product_APN_Number__c 
                                                 FROM Pure_Connect_Version_Upgrade__c 
                                                 WHERE Old_Product_APN_Number__c IN :partNumbers]){
            upgradeConfigMap.put(vu.Old_Product_APN_Number__c, vu);
        }
        
        Map<String, LMS_Mirror_Config__c> LMSMirrorConfig = LMS_Mirror_Config__c.getAll();
        Set<String> upgradeOptionSet = new Set<String>();
        Set<String> mirrorOptionSet = new Set<String>();
        for(License_Snapshot__c lsh : licenseSnapShotData){
			Boolean mirroringAvailble = false;
            if(lsh.isMirrored__c == false && upgradeConfigMap.keySet().contains(lsh.Part_Number__c) ){
            } else {
            	notAvailableForUpgrades.add(new PartUpgradeWrapper(lsh.Sold_To__c, lsh.Part_Number__c, lsh.Product_Category_Version__c, lsh.Description__c, lsh.Total__c, '', mirroringAvailble, lsh.End_User__c));
            }
        }
        return notAvailableForUpgrades;
	 }
	
	public PageReference performUpgrade(){
        // Validate Mirroring
        if(selectedUpgradeOption != '-- ALL --' && mirrorOptions != NULL && mirrorOptions.size() > 0 && mirrorOptions[0].selected){ 
            for(PartUpgradeWrapper puw : availableForUpgrades){
                if(puw.selected == false){
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'All Parts should be selected for Mirroring'));
                    return null;
                }
            }
        } else { // Validate for Upgrade 
			Boolean atleastOne = false;        
            for(PartUpgradeWrapper puw : availableForUpgrades){
            	System.debug(puw.selected);
                if(puw.selected == true){
					atleastOne = true;
                }
            }
            if(atleastOne == false){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Atleast one Part should be selected for Upgrade'));
                return null;
            }
        }
        
        List<LMSIntegrationProductUpgrade.OrderProduct> orderedProducts = new List<LMSIntegrationProductUpgrade.OrderProduct>();
        Map<String, List<LMSIntegrationMirrorNRO.OrderProduct>> mirroringProducts = new Map<String, List<LMSIntegrationMirrorNRO.OrderProduct>>();
        for(PartUpgradeWrapper puw : availableForUpgrades){
            if(puw.selected){
                LMSIntegrationProductUpgrade.OrderProduct op = new LMSIntegrationProductUpgrade.OrderProduct();
                op.PartNum = puw.partNumber;
                op.Qty = puw.quantity.intValue();
                orderedProducts.add(op);
                System.debug('op.PartNum = ' + op.PartNum + ' | op.Qty = ' + op.Qty);
            }
            if(selectedUpgradeOption != '-- ALL --' && mirrorOptions!= NULL && mirrorOptions.size() > 0 && mirrorOptions[0].selected && puw.selected){
                LMSIntegrationMirrorNRO.OrderProduct mp = new LMSIntegrationMirrorNRO.OrderProduct();
                mp.PartNum = puw.partNumber;
                mp.Qty = puw.quantity.intValue();
				if(mirroringProducts.containsKey(puw.soldTo)){
					 mirroringProducts.get(puw.soldTo).add(mp);	
				} else {
					mirroringProducts.put(puw.soldTo, new List<LMSIntegrationMirrorNRO.OrderProduct>{mp});
				}
                // mirroringProducts.add(mp);
                System.debug('mp.PartNum = ' + mp.PartNum + ' | mp.Qty = ' + mp.Qty);
            }
        }
        // Upgrade ...
        
        String snapshotReason = 'Upgrade Request'; 
        if(orderedProducts.size() > 0){
         	LMSIntegrationProductUpgrade.ResponseStatus uResponse = LMSIntegrationProductUpgrade.LMSIntegrationProductUpgrade(endUserAccountId, orderedProducts);
            //snapshotReason = 'Upgrade Request';
        }
		// Mirroring ...
        if(mirroringProducts.size() > 0){
        	for(String soldTo : mirroringProducts.keySet()){
	         	LMSIntegrationMirrorNRO.ResponseStatus mResponse = LMSIntegrationMirrorNRO.LMSIntegrationMirrorNRO(endUserAccountId, soldTo, 'narasimha.tumma@genesys.com', mirroringProducts.get(soldTo));
        	}
            //snapshotReason = 'Mirror Request';
        }
        
        if(orderedProducts.size() > 0 || mirroringProducts.size() > 0){
	        // Regenerate Snapshot ...
	        List<License_Snapshot_Sold_To_End_User__c> lsseRecords = [SELECT Id, Sold_To__c, End_User__c, Sold_To_End_User__c, Last_Processed_Date__c, Snapshot_Generated__c, Regenerate_Snapshot__c, Snapshot_Reason__c 
                                                                  FROM License_Snapshot_Sold_To_End_User__c 
                                                                  WHERE End_User__c = :endUserAccountId];
            if(userType != 'Internal'){
				LicenseSnapshotUtil.generateSnapshot(soldToAccountIds, endUserAccountId, snapshotReason);
		        LicenseSnapshotUtil.refreshSnapshot(endUserAccountId, soldToAccountIds);
            } else {
				LicenseSnapshotUtil.generateSnapshot(endUserAccountId, snapshotReason);
		        LicenseSnapshotUtil.refreshSnapshot(endUserAccountId);
            }                                                      
	       
        }
        resetFilters();
        initialize();
		displayAlert = false; 
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Selected Parts have been upgarded successfully.'));
		return null;
    }
    
    public class PartUpgradeWrapper{
    	public String soldTo {get; set;}
        public String partNumber {get; set;}
        public String productCategory {get; set;}
        public String description {get; set;}
        public String upgradeOption {get; set;}
        public Decimal quantity {get; set;}
        public Boolean selected {get; set;}
        public Decimal selectedQuantity {get; set;}
        
        // Additional Details to Manage Upgrade Requests
        public String productId {get; set;}
        public String upgradeRequestId {get; set;}
        public String status {get; set;}
        public Boolean mirroringAvailable {get; set;}
        public String endUser {get; set;}
        public PartUpgradeWrapper(String soldTo, String partNumber, String productCategory, String description, Decimal quantity, String upgradeOption, Boolean mirroringAvailable, String endUser){
            this.soldTo = soldTo;
            this.partNumber = partNumber;
            this.productCategory = productCategory;
            this.description = description;
            this.quantity = quantity;
            this.upgradeOption = upgradeOption;
            this.selected = true;
            this.selectedQuantity = quantity;
            this.mirroringAvailable = mirroringAvailable;
            this.endUser = endUser;
        }
    }
    
    public class MirrorWrapper{
        public String mirrorOption {get; set;}
        public boolean selected {get; set;}
        public MirrorWrapper(String mirrorOption){
        	this.mirrorOption = mirrorOption; 
        	this.selected = false;   
        } 
    }
}