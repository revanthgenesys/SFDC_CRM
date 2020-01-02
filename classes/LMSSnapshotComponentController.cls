public class LMSSnapshotComponentController {
    public String endUserAccountId {get; set;}
   	public String[] soldToAccountIds {get; set;}
    public String userType {get; set;}
    public boolean displayHistory {get; set;}
    public boolean displayPopup {get; set;}   
    public String selectedPartNumber {get; set;}
    public List<ContractLineItem> lineItems {get; set;}
    public List<UpgradeRequestWrapper> upgradeRequests {get; set;}
    public Integer totalRecords {get; set;}
     
    public LMSSnapshotComponentController(){
        displayHistory = false;
    }
    
    public boolean getPendingRefresh(){
        Boolean pendingRefresh = false;
        Integer refreshCount = 0;
        if(userType != 'Internal')
            refreshCount = [SELECT count() FROM License_Snapshot_Sold_To_End_User__c WHERE 
                            Sold_To__c  IN :soldToAccountIds AND End_User__c = :endUserAccountId AND
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
    
    public List<SnapshotRecordWrapper> getSnapshotData(){
        List<License_Snapshot__c> snapshotData = new List<License_Snapshot__c>();
        if(userType != 'Internal'){
            snapshotData = [SELECT id, Part_Number__c, Product_Category_Version__c,  Description__c, Perpetual__c, Non_Perpetual__c, Total__c, Change_Date__c, Sold_To__c, Sold_To__r.Name, isMirrored__c,
                            (SELECT id, Change_Date__c, Change_Type__c, Perpetual__c, Non_Perpetual__c FROM License_Snapshot_Changes__r ORDER BY Change_Date__c DESC)
                            FROM License_Snapshot__c 
                            WHERE Sold_To__c IN :soldToAccountIds AND End_User__c = :endUserAccountId AND IsActive__c = true
                            ORDER BY Part_Number__c];
        } else {
            snapshotData = [SELECT id, Part_Number__c, Product_Category_Version__c, Description__c, Perpetual__c, Non_Perpetual__c, Total__c, Change_Date__c, Sold_To__c, Sold_To__r.Name, isMirrored__c,
                            (SELECT id, Change_Date__c, Change_Type__c, Perpetual__c, Non_Perpetual__c FROM License_Snapshot_Changes__r ORDER BY Change_Date__c DESC)
                            FROM License_Snapshot__c 
                            WHERE End_User__c = :endUserAccountId AND IsActive__c = true
                            ORDER BY Part_Number__c];
        }
        
        List<SnapshotRecordWrapper> data = new List<SnapshotRecordWrapper>();
        for(License_Snapshot__c record : snapshotData){
            data.add(new SnapshotRecordWrapper(record));    
        }
        totalRecords = data.size();
        return data;
    }
    
    public void showLineItems(){
        displayPopup = true;
        upgradeRequests = new List<UpgradeRequestWrapper>();
        
        lineItems = new List<ContractLineItem>();
        
        // Check if there are any mirrored items
        List<ContractLineItem> mirroredlineItems = [SELECT Id, LineItemNumber, ServiceContractId, ServiceContract.Name, ServiceContract.Service_Contract_Type__c, 
                                                    	Product2.APN_Number__c, Current_Quantity__c, Maintenance_Start_Date__c, Maintenance_End_Date__c, Non_Billable__c, 
                                                    	Lic_Invoice__c, Original_License_Invoice__c, License_Metric__c 
                                                    FROM ContractLineItem 
                     								WHERE Upgraded_Product__r.APN_Number__c = :selectedPartNumber AND ServiceContract.End_User_Name__c = :endUserAccountId 
                                                    AND ServiceContract.Service_Contract_Type__c = 'Mirror'
                                                    AND (
                                                            (ServiceContract.Agreement_Status__c = 'Active' AND Maintenance_Start_Date__c <: Date.TODAY() AND Maintenance_End_Date__c >: Date.TODAY())
                                                            OR 
                                                            (ServiceContract.Agreement_Status__c = 'In Negotiation' AND ServiceContract.StartDate <: Date.TODAY() AND ServiceContract.EndDate >: Date.TODAY())
                                                        )];
		lineItems.addAll(mirroredlineItems);
        
        if(mirroredlineItems.isEmpty()){
            // Check if there are any items which are not mirrored
            List<ContractLineItem> nonMirroredlineItems = [SELECT Id, LineItemNumber, ServiceContractId, ServiceContract.Name, ServiceContract.Service_Contract_Type__c, 
                                                            	Product2.APN_Number__c, Current_Quantity__c, Maintenance_Start_Date__c, Maintenance_End_Date__c, 
                                                            	Non_Billable__c, Lic_Invoice__c, Original_License_Invoice__c, License_Metric__c 
                                                             FROM ContractLineItem 
                                                             WHERE Upgraded_Product__r.APN_Number__c = :selectedPartNumber AND ServiceContract.End_User_Name__c = :endUserAccountId 
                                                             AND ServiceContract.Service_Contract_Type__c != 'Mirror'
                                                          	AND ServiceContract.Service_Contract_Type__c != 'Hardware'
                                                          	AND (
                                                                (ServiceContract.Agreement_Status__c = 'Active' AND Maintenance_Start_Date__c <: Date.TODAY() AND Maintenance_End_Date__c >: Date.TODAY())
                                                                OR 
                                                                (ServiceContract.Agreement_Status__c = 'In Negotiation' AND ServiceContract.StartDate <: Date.TODAY() AND ServiceContract.EndDate >: Date.TODAY())
                                                            )];
            lineItems.addAll(nonMirroredlineItems);
            
            // Check if any Product Version Upgrades
            List<Pure_Connect_Version_Upgrade__c> pcvuRecords = [SELECT id, Old_Product_APN_Number__c, Old_Part_Name__c, New_Product_APN_Number__c, New_Part_Name__c 
                                                                 FROM Pure_Connect_Version_Upgrade__c WHERE New_Product_APN_Number__c = :selectedPartNumber];
            
            if(!pcvuRecords.isEmpty()){
                Set<String> mappingOldParts = new Set<String>();
                for(Pure_Connect_Version_Upgrade__c pcvuRecord :  pcvuRecords){
                    mappingOldParts.add(pcvuRecord.Old_Product_APN_Number__c);	
                }
                
                // Query Contract Line Items with Old Part Numbers
                List<ContractLineItem> versionUpgradelineItems = [SELECT Id, LineItemNumber, ServiceContractId, ServiceContract.Name, ServiceContract.Service_Contract_Type__c, 
                                                                   Product2.APN_Number__c, Current_Quantity__c, Maintenance_Start_Date__c, Maintenance_End_Date__c, 
                                                                   Non_Billable__c, Lic_Invoice__c, Original_License_Invoice__c, License_Metric__c 
                                                               FROM ContractLineItem 
                                                               WHERE Upgraded_Product__r.APN_Number__c IN :mappingOldParts
                                                               AND ServiceContract.End_User_Name__c = :endUserAccountId 
                                                               AND ServiceContract.Service_Contract_Type__c != 'Mirror'
                                                               AND (
                                                            	(ServiceContract.Agreement_Status__c = 'Active' AND Maintenance_Start_Date__c <: Date.TODAY() AND Maintenance_End_Date__c >: Date.TODAY())
                                                            	OR 
                                                            	(ServiceContract.Agreement_Status__c = 'In Negotiation' AND ServiceContract.StartDate <: Date.TODAY() AND ServiceContract.EndDate >: Date.TODAY())
                                                        		)];
                lineItems.addAll(versionUpgradelineItems);
                
                // Check if there are any Pending Product Upgrade Requests
                List<Product_Upgrade_Request__c> productUpgradeRequests = [SELECT id, Name, Product_APN_Number__c, Quantity__c, CreatedDate 
                                                                           FROM Product_Upgrade_Request__c 
                                                                           WHERE Product_APN_Number__c IN :mappingOldParts 
                                                                           AND Account__c = :endUserAccountId 
                                                                           AND Processed__c = false];
                if(!productUpgradeRequests.isEmpty()){
                    for(Product_Upgrade_Request__c pur: productUpgradeRequests){
                        for(Pure_Connect_Version_Upgrade__c pcvuRecord :  pcvuRecords){
                            if(pur.Product_APN_Number__c == pcvuRecord.Old_Product_APN_Number__c)
                                upgradeRequests.add(new UpgradeRequestWrapper(pcvuRecord.Old_Product_APN_Number__c, pcvuRecord.Old_Part_Name__c, pcvuRecord.New_Product_APN_Number__c,pcvuRecord.New_Part_Name__c, pur.CreatedDate, pur.Quantity__c));	
                        }	
                    }
                }
            } 
            
            // Check for any purchase upgrades
            List<UL_Upsize_Parts__c> ulParts = [SELECT id, Name, Part_To_Be_Decremented__c, Part_To_Be_Incremented__c FROM UL_Upsize_Parts__c WHERE Part_To_Be_Incremented__c = :selectedPartNumber];
            if(!ulParts.isEmpty()){
                // Query Contract Line Items with Old Part Numbers
                List<ContractLineItem> purchaseUpgradelineItems = [SELECT Id, LineItemNumber, ServiceContractId, ServiceContract.Name, ServiceContract.Service_Contract_Type__c, 
                                                                       Product2.APN_Number__c, Current_Quantity__c, Maintenance_Start_Date__c, Maintenance_End_Date__c, 
                                                                       Non_Billable__c, Lic_Invoice__c, Original_License_Invoice__c, License_Metric__c 
                                                                   	FROM ContractLineItem 
                                                                   	WHERE (Upgraded_Product__r.APN_Number__c = :ulParts[0].Part_To_Be_Decremented__c OR Upgraded_Product__r.APN_Number__c = :ulParts[0].Name)
                                                                   	AND ServiceContract.End_User_Name__c = :endUserAccountId 
                                                                   	AND ServiceContract.Service_Contract_Type__c != 'Mirror'
                                                                  	AND (
                                                                        (ServiceContract.Agreement_Status__c = 'Active' AND Maintenance_Start_Date__c <: Date.TODAY() AND Maintenance_End_Date__c >: Date.TODAY())
                                                                        OR 
                                                                        (ServiceContract.Agreement_Status__c = 'In Negotiation' AND ServiceContract.StartDate <: Date.TODAY() AND ServiceContract.EndDate >: Date.TODAY())
                                                                    )];
                lineItems.addAll(purchaseUpgradelineItems);
            }
        }
    }    
    
    public void closeLineItems() {        
        displayPopup = false;
        lineItems = NULL;
    }     
    
    public void showHistory(){
        
    } 
    
    public class UpgradeRequestWrapper {
        public String oldProductAPNNumber {get; set;}
        public String oldPartName {get; set;}
        public String newProductAPNNumber {get; set;}
        public String newPartName {get; set;}
        public DateTime requestedDate {get; set;}
        public Decimal requestedQuantity {get; set;}
        public UpgradeRequestWrapper(String oldProductAPNNumber, String oldPartName, String newProductAPNNumber, String newPartName, DateTime requestedDate, Decimal requestedQuantity){
            this.oldProductAPNNumber = oldProductAPNNumber;
            this.oldPartName = oldPartName;
            this.newProductAPNNumber = newProductAPNNumber;
            this.newPartName = newPartName;
            this.requestedDate = requestedDate;
            this.requestedQuantity = requestedQuantity;
        }
    }
    
    public class SnapshotRecordWrapper {
        public String recordId {get; set;}
        public String partNumber {get; set;}
        public String description {get; set;}
        public String productCategory {get; set;}
        public String soldTo {get; set;}
        public String soldToName {get; set;}
        public String mirrored {get; set;}
        public Decimal perpetual {get; set;}
        public Decimal nonPerpetual {get; set;}
        public Decimal total {get; set;}
        
        public List<SnapshotChangeRecordWrapper> changeRecords {get; set;}
        
        public SnapshotRecordWrapper(License_Snapshot__c record){
            this.recordId = record.Id;
            this.partNumber = record.Part_Number__c;
            this.description = record.Description__c;
            this.productCategory = record.Product_Category_Version__c;
            this.soldTo = record.Sold_To__c;
            this.soldToName = record.Sold_To__r.Name;
            this.mirrored = record.isMirrored__c == true ? 'Yes' : 'No';
            this.perpetual = record.Perpetual__c;
            this.nonPerpetual = record.Non_Perpetual__c;
            this.total = record.Total__c;
            
            changeRecords = new List<SnapshotChangeRecordWrapper>();
            if(record.License_Snapshot_Changes__r != NULL){
                for(License_Snapshot_Change__c changeRecord : record.License_Snapshot_Changes__r){
                    changeRecords.add(new SnapshotChangeRecordWrapper(changeRecord));    
                }
            }
        }
    }
    
    public class SnapshotChangeRecordWrapper {
        public String recordId {get; set;}
        public String changeDate {get; set;}
        public String changeType {get; set;}
        public Decimal perpetual {get; set;}
        public Decimal nonPerpetual {get; set;}
        
        public SnapshotChangeRecordWrapper(License_Snapshot_Change__c record){
            this.recordId = record.Id;
            this.changeDate = record.Change_Date__c.format();
            this.changeType = record.Change_Type__c;
            this.perpetual = record.Perpetual__c;
            this.nonPerpetual = record.Non_Perpetual__c;
        }
    }
}