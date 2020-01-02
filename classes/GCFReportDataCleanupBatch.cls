global class GCFReportDataCleanupBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
    	
        String query = 'SELECT id FROM GCF_Report_Data__c ';
        if(GCFUtil.isNetSuiteReportDataImportNeeded() == false)
        	query = query + ' WHERE Revenue_Type__c IN (\'Incremental Revenue\',\'First Year Maintenance\',\'Billing Plan\',\'Total Booking Forecast\') ';
        	
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
        	Database.executeBatch(new GCFCopyReportData(), 500);
        }
    }
}