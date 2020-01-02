/*
 * Class            : LMSCaptureSoldToEndUserCombinationBatch
 * Description      : Batch Class to capture all ST EU Combinations for ININ Customers based on Service Contracts.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Jan 5, 2018
 * Test Class       : LicenseSnapshotTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Modified BY    Modified Date    	Changes/ Notes
 * ----------------------------------------------------------------------------------------------
 * RAO TUMMA	  Mar 11, 2018		Modified logic to find all ST EU Combinations	
 */ 
global class LMSCaptureSoldToEndUserCombinationBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT End_User_Name__c FROM ServiceContract WHERE End_User_Name__c != NULL AND Agreement_Status__c IN (\'Active\', \'In Negotiation\') ';
        if(Test.isRunningTest())
            query = query + ' AND (End_User_Name__r.ININ_ID__c != NULL OR Offering_Type__c = \'PureConnect\') LIMIT 5'; 
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<ServiceContract> scope){
        Set<String> scEndUserIds = new Set<String>();
        for(ServiceContract sc : scope){
        	scEndUserIds.add(sc.End_User_Name__c);    
        }
        
        AggregateResult[] groupedResults = [SELECT ServiceContract.End_User_Name__c endUser, ServiceContract.Sold_To_Name__c soldTo, ServiceContract.Name, 
                                            ServiceContract.StartDate scStartDate, ServiceContract.EndDate scEndDate, Count(id) 
                                            FROM ContractLineItem 
                                            WHERE ServiceContract.End_User_Name__c IN :scEndUserIds AND ServiceContract.Agreement_Status__c IN ('Active', 'In Negotiation') AND isPureConnectPrem__c = true 
                                            GROUP BY ServiceContract.End_User_Name__c, ServiceContract.Sold_To_Name__c, ServiceContract.Name, ServiceContract.StartDate, ServiceContract.EndDate  
                                            HAVING Count(id) > 0];
  
        Map<String, License_Snapshot_Sold_To_End_User__c> combinationRecords = new Map<String, License_Snapshot_Sold_To_End_User__c>();
        for (AggregateResult ar : groupedResults)  {
            String soldTo = (String)ar.get('soldTo');
            String endUser = (String)ar.get('endUser');
            Date startDate = (Date)ar.get('scStartDate');
            Date endDate = (Date)ar.get('scEndDate');
            
            Boolean regenerateSnapshot = false;
            String snapshotReason = '';
            if(startDate == Date.today() || endDate < Date.today()){
                regenerateSnapshot = true;
				snapshotReason = 'Service Contract Actived or Closed';                
            }
            
			combinationRecords.put(soldTo + '' + endUser, 
                                   new License_Snapshot_Sold_To_End_User__c(Sold_To__c = soldTo, End_User__c = endUser, Sold_To_End_User__c = soldTo + '' + endUser, Regenerate_Snapshot__c = regenerateSnapshot, Snapshot_Reason__c = snapshotReason));
        }
        Database.upsert(combinationRecords.values(), Schema.License_Snapshot_Sold_To_End_User__c.Sold_To_End_User__c, false);
    }
    
    global void finish(Database.BatchableContext bc){
        // SoldTo EndUser Combination capture completed ...
        // ...
        // Invoke Snapshot capture
        Database.executeBatch(new LMSCaptureSnapshotBatch(), 10);
    }
}