global class CloudForecastQuarterClone implements Database.Batchable<sObject>{

    global final String query;
    global final String weekId;
    
    global CloudForecastQuarterClone(String weekIds, String previousWeekId){
        weekId = weekIds;
        String weekString = '';
        String whereClause = 'Cloud_Forecast_Quarter__c = \'' + previousWeekId + '\'';
               //whereClause += ' AND Offering_Type__c = \'' + weekString + '\'';    
        query = CloneUtil.getCreatableFieldsSOQL('Account_Revenue_Forecast__c', whereClause);      
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account_Revenue_Forecast__c> records){
        // process each batch of records
        
        List<Account_Revenue_Forecast__c> clonedRecords = new List<Account_Revenue_Forecast__c>(); 
        //Looping over and cloning records
        for(Account_Revenue_Forecast__c eachARF : records){
            Account_Revenue_Forecast__c newRecord = eachARF.clone(false, true);
            newRecord.Previous_Week__c = eachARF.id;
            newRecord.Cloud_Forecast_Quarter__c = weekId;
            newRecord.Cloned_From__c = eachARF.id;
            clonedRecords.add(newRecord);       
        }
        if(!clonedRecords.isEmpty())
            insert clonedRecords;
    }    

    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    

}