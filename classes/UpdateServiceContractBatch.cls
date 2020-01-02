/*
    Naresh Kumar    07/02/2013
*/
global class UpdateServiceContractBatch implements Database.Batchable<sObject>{

   global String query;
   
   	global UpdateServiceContractBatch(){
		query = 'SELECT id, Agreement_Status__c, Sold_To_Name__c, End_User_Name__c FROM ServiceContract WHERE EndDate < TODAY AND (Agreement_Status__c = \'Active\' OR Agreement_Status__c = \'In Negotiation\')  ORDER BY EndDate DESC';
       	if(Test.isRunningTest()){
        	query = query + ' LIMIT 1';		   
       	}
   }
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }
   global void execute(Database.BatchableContext BC, List<ServiceContract> scope){
 	    Map<String, License_Snapshot_Sold_To_End_User__c> lsseRecordsMap = new Map<String, License_Snapshot_Sold_To_End_User__c>();      
		for(ServiceContract eachSC : scope){
            eachSC.Agreement_Status__c = 'Closed';
            eachSC.Is_Batch_Update__c = true;
            String key = eachSC.Sold_To_Name__c + '' + eachSC.End_User_Name__c;
            License_Snapshot_Sold_To_End_User__c lsseRecord = new License_Snapshot_Sold_To_End_User__c(Sold_To__c = eachSC.Sold_To_Name__c, End_User__c = eachSC.End_User_Name__c,
                                                                                                      Sold_To_End_User__c = key, Regenerate_Snapshot__c = true, Snapshot_Reason__c = 'Closed/ Terminated');
        	lsseRecordsMap.put(key, lsseRecord);
        } 
       	Util.Bypass_Trigger_Chk = true;
        update scope;
		Database.upsert(lsseRecordsMap.values(), Schema.License_Snapshot_Sold_To_End_User__c.Sold_To_End_User__c, false);
       	Util.Bypass_Trigger_Chk = false;
   }
   global void finish(Database.BatchableContext BC){
   }
}