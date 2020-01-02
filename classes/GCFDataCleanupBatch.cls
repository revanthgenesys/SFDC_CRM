/*
 * Class            : GCFDataCleanupBatch
 * Description      : A Batch class to clean up all Genesys Care forecasting Data from GCF_Data__c Object.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : May 19, 2017
 * Test Class       : GCFAllTests   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 global class GCFDataCleanupBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT id FROM GCF_Data__c ';
        if(Test.isRunningTest())
            query = query + ' LIMIT 10';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc , List<sObject> scope){
        delete scope; 
        Database.emptyRecycleBin(scope);
    }
    
    global void finish(Database.BatchableContext bc){
        if(!Test.isRunningTest()){
        	Database.executeBatch(new GCFIncrementalBatch(), 1);
        }
    }
}