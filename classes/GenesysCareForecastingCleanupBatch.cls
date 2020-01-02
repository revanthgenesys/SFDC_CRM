/*
 * Class			: GenesysCareForecastingCleanupBatch
 * Description		: This Batch Class cleans up any records for Incremental Revenue & First Year Maintenance forecasting types.
 * Author			: Narasimha "Rao" Tumma
 * Created Date		: Dec 19, 2016
 * Test Class		: GenesysCareForecastingBatchesTest	 
 */
global class GenesysCareForecastingCleanupBatch implements Database.Batchable<sObject>{
	
    global String filterCondition; 
    global GenesysCareForecastingCleanupBatch(String revenueTypes){
        filterCondition = revenueTypes != 'All' ? ' WHERE Revenue_Type__c IN (' + revenueTypes + ')'  : '';
    }
    
    global GenesysCareForecastingCleanupBatch(){
		filterCondition = '';	        
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT id  FROM Genesys_Care_Forecasting__c ' + filterCondition;
        if(Test.isRunningTest())
            query = query + ' LIMIT 10';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc , List<sObject> scope){
        delete scope ; 
        Database.emptyRecycleBin(scope);
    }
    
    global void finish(Database.BatchableContext bc){
        if(!Test.isRunningTest())
        	Database.executeBatch(new GenesysCareForecastingIRBatch(), 1);
    }
}