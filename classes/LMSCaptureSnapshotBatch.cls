/*
 * Class            : LMSCaptureSnapshotBatch
 * Description      : Batch Class to capture LMS Summary for all EU ST Combinations.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Jan 5, 2018
 * Test Class       : LicenseSnapshotTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Modified BY    Modified Date    Changes/ Notes
 * ----------------------------------------------------------------------------------------------
 *
 */ 
 global class LMSCaptureSnapshotBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT Id, Sold_To__c, End_User__c, Last_Processed_Date__c, Snapshot_Generated__c, Regenerate_Snapshot__c, Snapshot_Reason__c '
            		 + 'FROM License_Snapshot_Sold_To_End_User__c WHERE Snapshot_Generated__c = false OR Regenerate_Snapshot__c = true';
        if(Test.isRunningTest())
            query = query + ' LIMIT 1'; 
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<License_Snapshot_Sold_To_End_User__c> scope){
        List<License_Snapshot__c> snapshotRecordsNEW = new List<License_Snapshot__c>();
        for(License_Snapshot_Sold_To_End_User__c lssSoldToEndUser : scope){
        	
        	snapshotRecordsNEW.addAll(LicenseSnapshotUtil.generateSnapshotRecords( (String)lssSoldToEndUser.Sold_To__c, (String)lssSoldToEndUser.End_User__c));

            // InActive all existing records first
            List<License_Snapshot__c> existingSnapShotData = [SELECT id, IsActive__c FROM License_Snapshot__c WHERE Sold_To__c = :lssSoldToEndUser.Sold_To__c AND End_User__c = :lssSoldToEndUser.End_User__c];
            for(License_Snapshot__c lp : existingSnapShotData){
                lp.IsActive__c = false;
            }
            Database.update(existingSnapShotData);
			
            lssSoldToEndUser.Last_Processed_Date__c = Date.today();
            lssSoldToEndUser.Snapshot_Generated__c = true;
            lssSoldToEndUser.Regenerate_Snapshot__c = false;
            lssSoldToEndUser.Snapshot_Reason__c = '';
        }  
        if(snapshotRecordsNEW.size() > 0)
        	Database.upsert(snapshotRecordsNEW, Schema.License_Snapshot__c.Sold_To_End_User_Part_Number__c, false);
        // Handle Purchase Upgrades for LMS ...
        for(License_Snapshot_Sold_To_End_User__c lssSoldToEndUser : scope){
        	LicenseSnapshotUtil.performPurchaseUpgrades((String)lssSoldToEndUser.End_User__c);
	        // LicenseSnapshotUtil.addFreeParts((String)lssSoldToEndUser.End_User__c);
        }
        Database.update(scope);
    }
    
    global void finish(Database.BatchableContext bc){
    
    }
}