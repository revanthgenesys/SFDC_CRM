global class BatchReRateUsageData implements Database.Batchable<SObject>, Database.Stateful
{    
    // Range Start Date for re-rating
    public final Date dtStart;
    // Range End Date for re-rating
    public final Date dtEnd;
    // Account Id : To specify account across which re-rating needs to occur
    public final String strAccountId;
    // Log Record for this job
    public Cloud_Billing_Log__c objJobLog;
    
    // *** constructor ***
    public BatchReRateUsageData(Date StartDate,Date EndDate,String accountId)
    {         
        dtStart = StartDate;
        dtEnd = EndDate;
        strAccountId = accountId;
    }

    // *** Start Method : Querying unprocessed Rolled Up Usage records ***
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {  
        String strSOQL;            
        if(objJobLog == null) {
            System.debug('objJobLog is null, create one');
            objJobLog = new Cloud_Billing_Log__c(Type__c = 'Re-Rate',Time__c = DateTime.now(), Status__c = 'Submitted',
                              Start_Date__c = dtStart,End_Date__c = dtEnd,Account__c = strAccountId);
        } else {
            System.debug('objJobLog exists is ' + objJobLog);
        }
        
        objJobLog.Exceptions__c = (objJobLog.Exceptions__c == null) ? '':objJobLog.Exceptions__c;
        System.debug('ReRating dtStart ' + dtStart + ' dtEnd ' + dtEnd + ' for strAccountId ' + strAccountId);

        // This will pick up both current and soft deleted tier sets for rerating
        strSOQL = 'SELECT Id, Rolled_Up_Usage_Data__c, Contract_Tier_Set_Month__c, ' + 
                  '(SELECT Id, Rolled_Up_Usage_Data__c from Service_Usage_Taxes__r) ' +
                  'FROM Service_Usage__c WHERE Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Contract__r.Account_Name__c = :strAccountId '
                   + ' AND Start_Time__c >= :dtStart AND Start_Time__c < :dtEnd';
        System.debug('strSOQL: ' + strSOQL);
      	return Database.getQueryLocator(strSOQL);
    }
    
    // *** Execute Method : Processing roll up records in batches (default batch size = 200) ***
    global void execute(Database.BatchableContext BC, List<SObject> sObjects) 
    {
        // DB Save-point
        Savepoint objSP = Database.setSavepoint();
        try 
        {           
            // Storing Service Usage records to be processed in current batch
            List<Service_Usage__c> list_ServiceUsage = (List<Service_Usage__c>)sObjects;
            System.debug('Deleting List Size of ' + list_ServiceUsage.size());
            // Set of Rollup Ids
            Set<String> set_RollUpIds = new Set<String>();
//            Set<String> setServiceUsageIds = new Set<String>();
            Set<String> set_ContractTierSetMonthIds = new Set<String>();

            List<Service_Usage_Tax__c> list_ServiceUsageTaxToDelete = new List<Service_Usage_Tax__c>();
            List<Service_Usage_Tax__c> list_ServiceUsageTaxToKeep = new List<Service_Usage_Tax__c>();
            for(Service_Usage__c objServiceUsage : list_ServiceUsage) {
//                setServiceUsageIds.add(objServiceUsage.Id);
                set_RollUpIds.add(objServiceUsage.Rolled_Up_Usage_Data__c);
                set_ContractTierSetMonthIds.add(objServiceUsage.Contract_Tier_Set_Month__c);
                for (Service_Usage_Tax__c objServiceUsageTax : objServiceUsage.Service_Usage_Taxes__r) {
                    // SFDC created this data, not brought in by ETL. Just delete it.
                    if (objServiceUsageTax.Rolled_Up_Usage_Data__c == null) {
                        list_ServiceUsageTaxToDelete.add(objServiceUsageTax);
                    } else {
                        // Rolled Up Usage Data originally had this data. Remove the link to the Service Usage, but do not delete
                        objServiceUsageTax.Service_Usage__c = null;
                        list_ServiceUsageTaxToKeep.add(objServiceUsageTax);
                    }
                }
            }
            delete list_ServiceUsageTaxToDelete;
            update list_ServiceUsageTaxToKeep;

            List<Contract_Tier_Set_Month_Charges__c> list_ContractTierSetMonthCharges = [select Id from Contract_Tier_Set_Month_Charges__c
                                                                                         where Contract_Tier_Set_Month__c in :set_ContractTierSetMonthIds];
            System.Debug('list_ContractTierSetMonthCharges to delete size ' + list_ContractTierSetMonthCharges.size());
			delete list_ContractTierSetMonthCharges;
            
            // Remove Service Usage records
            delete list_ServiceUsage;
            
            List<Rolled_Up_Usage_Data__c> list_RolledUpUsageData = [SELECT Id,(SELECT Id FROM Cloud_Billing_Exceptions__r) 
                                        FROM Rolled_Up_Usage_Data__c WHERE Id IN :set_RollUpIds AND Processed__c = true];
System.debug('list_RolledUpUsageData ' + list_RolledUpUsageData );
            List<Cloud_Billing_Exception__c> list_BillingExceptionsToDelete = new List<Cloud_Billing_Exception__c>();
            
            // Reset Rollup records
            for(Rolled_Up_Usage_Data__c objRollUpData : list_RolledUpUsageData)
            {
                objRollUpData.Processed__c = false;
                objRollUpData.Last_Processed_Time__c = null;
                objRollUpData.Exception_Type__c = null;
                objRollUpData.Contract_Id_Service_Identifier__c = null;
                objRollUpData.Contract_Id_Service_Identifier_Default__c = null;
                // CRMBILL-85 Now we store the contract tier set information on the Service Usage Record, not RUUD
                
                if(!objRollUpData.Cloud_Billing_Exceptions__r.isEmpty())
                    list_BillingExceptionsToDelete.addAll(objRollUpData.Cloud_Billing_Exceptions__r);
            }
            
            // Remove Billing Exceptions records
            if(!list_BillingExceptionsToDelete.isEmpty())
                delete list_BillingExceptionsToDelete;
            
            // Update Roll Up Usage records
            if(!list_RolledUpUsageData.isEmpty())
                update list_RolledUpUsageData;
        }
        catch(Exception e) 
        {
            System.debug('Exception <<<< ' + e.getMessage());
            // Record exception in Log
            objJobLog.Exceptions__c += e.getMessage() + '\n';
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
    }
    
    global void finish(Database.BatchableContext BC) 
    {
        if(objJobLog != null) {
            objJobLog.Status__c = 'Completed';
            upsert objJobLog;
        }
		
        // Commented by Vijay - CRMBILL- 104
        /*
        Cloud_Billing_Log__c objLog = CloudBillingUtil.createNewCloudBillingLog('Rating', 'Submitted');
        insert objLog;
        System.debug('BatchReRateUsageData.finish objLog.Id ' + objLog.Id);
        // Invoke batch Job to process Usage Data
        BatchRateCloudUsageData objBatch = new BatchRateCloudUsageData();
        objBatch.objJobLog = objLog;
        Id idRatingJob = Database.executeBatch(objBatch,1000); 
        
        objLog.AsyncApexJob_Id__c = idRatingJob;
		objLog.Parent_Cloud_Billing_Log__c = objJobLog.Id;
        update objLog;
		*/
    }
}