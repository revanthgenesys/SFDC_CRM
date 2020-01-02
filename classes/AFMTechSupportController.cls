public class AFMTechSupportController {
    public Contact forEndUser {get; set;}
    public List<SelectOption> fromSoldTo {get; set;}
    public string fromSoldToSelected {get; set;}
    
    public Contact toSoldTo {get; set;}
    
    public List<LMS_Install_Site__c> fromInstallSites {get; set;} 
    public string fromInstallSiteSelected {get; set;}
    public List<LMS_Install_Site__c> toInstallSites {get; set;}
    public string toInstallSiteSelected {get; set;}
    
    public List<ServiceContract> contracts {get; set;}
    public List<License_Snapshot_Sold_To_End_User__c> steuCombinations {get; set;}
    public List<ActivationFileCount> activationFileCounts {get; set;}
    
    public AFMTechSupportController(){
        forEndUser = new Contact();
        toSoldTo = new Contact();
        fromSoldTo = new List<SelectOption>();
        
        fromInstallSites = new List<LMS_Install_Site__c>();
        fromInstallSiteSelected = '-- ALL --';
        toInstallSites = new List<LMS_Install_Site__c>();
        toInstallSiteSelected = '-- ALL --';
    }
    
    public void accountSelected(){
        steuCombinations = new List<License_Snapshot_Sold_To_End_User__c>();
        contracts = new List<ServiceContract>();
        activationFileCounts = new List<ActivationFileCount>();
        if(forEndUser.AccountId != NULL){
            steuCombinations = [SELECT id, Name, End_User__c, End_User__r.Name, Sold_To__c, Sold_To__r.Name, Last_Processed_Date__c 
                                FROM License_Snapshot_Sold_To_End_User__c 
                                WHERE End_User__c = :forEndUser.AccountId];  
            contracts = [SELECT id, Name, Service_Contract_Type__c, Agreement_Status__c, StartDate, EndDate, Sold_To_Name__c, End_User_Name__c, Offering_Type__c
                         FROM ServiceContract 
                         WHERE AccountId = :forEndUser.AccountId
                        AND Agreement_Status__c IN ('Active', 'In Negotiation')
                        AND ServiceContract.Service_Contract_Type__c != 'Hardware'];
            
            AggregateResult[] groupedResults  = [SELECT Sold_To__c, Sold_To__r.Name SoldToName, IsActive__c, Count(id) totalFiles 
                                                    FROM License_Request_Log__c 
                                                    WHERE End_User__c = :forEndUser.AccountId 
                                                        GROUP BY Sold_To__c, Sold_To__r.Name, IsActive__c];
            
            Map<String, ActivationFileCount> acfMap = new Map<String, ActivationFileCount>();
            for (AggregateResult ar : groupedResults)  {
                ActivationFileCount afc;
                String accountId = (String)ar.get('Sold_To__c');
                if(acfMap.containsKey(accountId)){
                    afc = acfMap.get(accountId);
                    if((Boolean)ar.get('IsActive__c')){
                        afc.activeFileCount = ar.get('totalFiles') != NULL ? ((Decimal)ar.get('totalFiles')).intValue() : 0;   
                    } else {
                       afc.inactiveFileCount = ar.get('totalFiles') != NULL ? ((Decimal)ar.get('totalFiles')).intValue() : 0; 
                    }
                } else {
                    afc = new ActivationFileCount(); 
                    afc.accountId = accountId;
                    afc.accountName = (String)ar.get('SoldToName');
                    if((Boolean)ar.get('IsActive__c')){
                        afc.activeFileCount = ar.get('totalFiles') != NULL ? ((Decimal)ar.get('totalFiles')).intValue() : 0;   
                    } else {
                       afc.inactiveFileCount = ar.get('totalFiles') != NULL ? ((Decimal)ar.get('totalFiles')).intValue() : 0; 
                    }
                    acfMap.put(accountId, afc);
                }
            }
            activationFileCounts = acfMap.values();
            
            fromSoldTo = new List<SelectOption>();
            for(ActivationFileCount afc : activationFileCounts){
                if(afc.accountId != NULL && afc.accountName != NULL)
                	fromSoldTo.add(new SelectOption(afc.accountId, afc.accountName));     
            }
        } 
    }
    
    public void migrateActivationFiles(){
        String endUserId18Digits = forEndUser.AccountId;
        String soldToId18Digits = toSoldTo.AccountId;
        
        List<License_Request_Log__c> requestLogs = [SELECT Id, Sold_To__c FROM License_Request_Log__c WHERE End_User__c = :endUserId18Digits AND Sold_To__c = :fromSoldToSelected];
        for(License_Request_Log__c rLog : requestLogs){
            rLog.Sold_To__c = soldToId18Digits;
        }
        Database.update(requestLogs);
        License_Snapshot_Sold_To_End_User__c steu = new License_Snapshot_Sold_To_End_User__c(Sold_To__c = soldToId18Digits, End_User__c = endUserId18Digits,  Sold_To_End_User__c = soldToId18Digits+endUserId18Digits, Snapshot_Generated__c = false, Regenerate_Snapshot__c = false, Snapshot_Reason__c = 'Initial Snapshot');
        Database.upsert(steu, Schema.License_Snapshot_Sold_To_End_User__c.Sold_To_End_User__c);
        // call the method once again to query the results
        accountSelected();
    }
    
    public void createCombinations(){
        Map<String, License_Snapshot_Sold_To_End_User__c> snapshotsToUpsert = new Map<String, License_Snapshot_Sold_To_End_User__c>();
        for(ServiceContract sc : contracts){
            String soldToForExtKey = sc.Sold_To_Name__c;
            String endUserForExtKey = sc.End_User_Name__c;
            String extKey = soldToForExtKey + endUserForExtKey;
            snapshotsToUpsert.put(extKey, new License_Snapshot_Sold_To_End_User__c(Sold_To__c = sc.Sold_To_Name__c, End_User__c = sc.End_User_Name__c,  Sold_To_End_User__c = extKey, Snapshot_Generated__c = false, Regenerate_Snapshot__c = false, Snapshot_Reason__c = 'Initial Snapshot'));
        }
        Database.upsert(snapshotsToUpsert.values(), Schema.License_Snapshot_Sold_To_End_User__c.Sold_To_End_User__c);
        // call the method once again to query the results
        accountSelected();
    }
    
    public void cleanUpCombinations(){
    	
    	Database.delete([SELECT id FROM License_Snapshot_Sold_To_End_User__c WHERE End_User__c = :forEndUser.AccountId]);
    	createCombinations();
        // call the method once again to query the results
        accountSelected();
    }
    
    public void refreshSnapshot(){
        // Regenerate Snapshot ...
        List<License_Snapshot_Sold_To_End_User__c> lsseRecords = [SELECT Id, Regenerate_Snapshot__c, Snapshot_Reason__c 
                                                                  FROM License_Snapshot_Sold_To_End_User__c 
                                                                  WHERE End_User__c = :forEndUser.AccountId ];
        for(License_Snapshot_Sold_To_End_User__c lsseRecord : lsseRecords ){
        	lsseRecord.Regenerate_Snapshot__c = true;
            lsseRecord.Snapshot_Reason__c = 'Tech Support Refresh';
        }
        Database.update(lsseRecords);
		Database.delete([SELECT id FROM License_Snapshot__c WHERE End_User__c = :forEndUser.AccountId]);
        LicenseSnapshotUtil.refreshSnapshot(forEndUser.AccountId);
    }
    
    public class ActivationFileCount {
        public string accountId {get; set;}
        public string accountName {get; set;}
        public Integer activeFileCount {get; set;}
        public Integer inactiveFileCount {get; set;}
    }
}