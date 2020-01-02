global class BatchReconcileServiceUsageData implements Database.Batchable<SObject>, Database.Stateful
{
    Map<String,Cloud_ETL_Reconciliation__c> map_ReconKeyToReconRecord = new Map<String,Cloud_ETL_Reconciliation__c>();

    // Log Record for this job
    public Cloud_Billing_Log__c objJobLog;

    // *** constructor ***
    public BatchReconcileServiceUsageData()
    {         
        // Initialization Code
    }
    
    // *** Start Method : Querying unprocessed Rolled Up Usage records ***
    global Database.QueryLocator start(Database.BatchableContext BC) 
    {
        System.debug(objJobLog);
        if (objJobLog == null) {
            System.debug('Need to Create new Job Log');
            objJobLog = CloudBillingUtil.createNewCloudBillingLog('Reconcile','Submitted');
        } else {
            System.debug('objJobLog Exists ' + objJobLog);
        }
        Date dtTemp = Global_Configuration_Settings__c.getOrgDefaults().Cloud_Reconciliation_Lookback_Date__c;
        Date dtLookback = Date.today().addMonths(-1).toStartOfMonth();
        dtLookback = (dtTemp != null && dtTemp < dtLookback) ? dtTemp : dtLookback;
		String strSOQL = 'SELECT Id,Rolled_Up_Usage_Data__r.Reconciliation_Key__c,Start_Time__c,Total_Duration__c FROM Service_Usage__c WHERE Start_Time__c >= :dtLookback AND Rolled_Up_Usage_Data__c != null';
        objJobLog.Start_Date__c = dtLookback;
		upsert objJobLog;
        return Database.getQueryLocator(strSOQL);
    }

    // *** Execute Method : Processing roll up records in batches (default batch size = 200) ***
    global void execute(Database.BatchableContext BC, List<SObject> sObjects) 
    {
        // Iterating through batch of Service Usage records
        for(Service_Usage__c objServiceUsage : (List<Service_Usage__c>)sObjects)
		{
			Cloud_ETL_Reconciliation__c objReconciliation;
            // Calculating GMT month and year in code instead of adding in Key formula to prevent timezone problems
			String strMonth = String.valueOf(objServiceUsage.Start_Time__c.monthGmt());
            String strYear = String.valueOf(objServiceUsage.Start_Time__c.yearGmt());
            String strReconKey = objServiceUsage.Rolled_Up_Usage_Data__r.Reconciliation_Key__c + strMonth + '-' + strYear;
            
			if(map_ReconKeyToReconRecord.containsKey(strReconKey))
				objReconciliation = map_ReconKeyToReconRecord.get(strReconKey);
			else
			{
				objReconciliation = new Cloud_ETL_Reconciliation__c(Unique_Id__c = strReconKey,
                     SFDC_SU_Count__c = 0,SFDC_SU_Total_Duration__c = 0,Month__c = strMonth,Year__c = strYear);
				map_ReconKeyToReconRecord.put(strReconKey,objReconciliation);
			}
			
			objReconciliation.SFDC_SU_Total_Duration__c += objServiceUsage.Total_Duration__c;
			objReconciliation.SFDC_SU_Count__c += 1;	
		}
    }
    
	// *** Finish Method : Post Processing Logic ***
    global void finish(Database.BatchableContext BC) 
    {
        // Insert/Update Log record
        if(objJobLog != null) {
            objJobLog.Status__c = 'Completed';
            upsert objJobLog;
        }

		if(!map_ReconKeyToReconRecord.isEmpty())
			upsert map_ReconKeyToReconRecord.values() Unique_Id__c;
    }
}