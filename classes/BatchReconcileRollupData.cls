global class BatchReconcileRollupData implements Database.Batchable<SObject>, Database.Stateful
{    
    Map<String,Cloud_ETL_Reconciliation__c> map_ReconKeyToReconRecord = new Map<String,Cloud_ETL_Reconciliation__c>();
    // Log Record for this job
    public Cloud_Billing_Log__c objJobLog;

    
	// *** constructor ***
    public BatchReconcileRollupData()
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
        System.Debug('dtTemp ' + dtTemp);
        Date dtLookback = Date.today().addMonths(-1).toStartOfMonth();
        dtLookback = (dtTemp != null && dtTemp < dtLookback) ? dtTemp : dtLookback;
        System.Debug('BatchReconcileRollupData: Reconciling back to date ' + dtLookback);
        objJobLog.Start_Date__c = dtLookback;
		upsert objJobLog;
        String strSOQL = 'SELECT Id,Reconciliation_Key__c,Total_Duration__c,Start_Time__c,Processed__c, Source_Name__c, Platform_Id__c ' +
            'FROM Rolled_Up_Usage_Data__c WHERE Start_Time__c >= :dtLookback';
        return Database.getQueryLocator(strSOQL);
    }

    // *** Execute Method : Processing roll up records in batches (default batch size = 200) ***
    global void execute(Database.BatchableContext BC, List<SObject> sObjects) 
    {
        // Iterating through batch of Roll Up records
        for(Rolled_Up_Usage_Data__c objRollUpData : (List<Rolled_Up_Usage_Data__c>)sObjects)
		{
            String strRecKey = objRollUpData.Reconciliation_Key__c;
            if (strRecKey.startsWith('Angel')) {
                System.debug('Got record with Id ' + objRollUpData.Id + ' has reconciliation key ' + objRollUpData.Reconciliation_Key__c);
            }
			Cloud_ETL_Reconciliation__c objReconciliation;
            // Calculating GMT month and year in code instead of adding in Key formula to prevent timezone problems
			String strMonth = String.valueOf(objRollUpData.Start_Time__c.monthGmt());
            String strYear = String.valueOf(objRollUpData.Start_Time__c.yearGmt());
            String strReconKey = objRollUpData.Reconciliation_Key__c + strMonth + '-' + strYear;
            String strSourceName = objRollUpData.Source_Name__c;
            String strPlatformId = objRollUpData.Platform_Id__c;
                
			if(map_ReconKeyToReconRecord.containsKey(strReconKey))
				objReconciliation = map_ReconKeyToReconRecord.get(strReconKey);
			else
			{
				objReconciliation = new Cloud_ETL_Reconciliation__c(Name=strReconKey,Source_Name__c = strSourceName, Platform_Id__c = strPlatformId,
                                                                    Unique_Id__c = strReconKey,SFDC_RUUD_Count__c = 0,
                                                                    SFDC_RUUD_Unrated_Count__c = 0,SFDC_RUUD_Total_Duration__c = 0,
                                                                    Month__c = strMonth, Year__c = strYear);
				map_ReconKeyToReconRecord.put(strReconKey,objReconciliation);
			}
			Decimal decTotalDuration = 0;
            if (objRollUpData.Total_Duration__c != null) {
                decTotalDuration = objRollUpData.Total_Duration__c;
            }
			objReconciliation.SFDC_RUUD_Total_Duration__c += decTotalDuration;
			
			// Increment counts
			objReconciliation.SFDC_RUUD_Count__c += 1;
			if(!objRollUpData.Processed__c)
				objReconciliation.SFDC_RUUD_Unrated_Count__c += 1;	
		}
    }
    
	// *** Finish Method : Post Processing Logic ***
    global void finish(Database.BatchableContext BC) 
    {
        // Upsert Log record
        if(objJobLog != null) {
            objJobLog.Status__c = 'Completed';
            upsert objJobLog;
        }

        if(!map_ReconKeyToReconRecord.isEmpty())
			upsert map_ReconKeyToReconRecord.values() Unique_Id__c;

        // Release below not hard coded
        populateExpectedFileCountsPureEngage();
        // For DEV testing. No harm but can be removed
        //populateExpectedFileCountsPureEngage(Date.newInstance(2018, 2, 15));

        populateExpectedFileCountsSubscription();

        Cloud_Billing_Log__c objLog = CloudBillingUtil.createNewCloudBillingLog('Reconcile Service Usage', 'Submitted');
        insert objLog;
        
        // Invoke batch Job to process Usage Data
        BatchReconcileServiceUsageData objBatch = new BatchReconcileServiceUsageData();
        objBatch.objJobLog = objLog;
        
        // Invoke here to avoid concurrent attempt to upsert same Unique_Id__c
		Integer intReconcileBatchSize = Integer.valueOf(Label.Billing_Reconcile_Batch_Size);
        Id idRatingJob = Database.executeBatch(objBatch,intReconcileBatchSize);
        objLog.AsyncApexJob_Id__c = idRatingJob;
        update objLog;

    }

    private Date[] getThisMonthLastMonth(Date dtToday) {
        Date[] dtThisMonthLastMonth = new Date[]{dtToday, dtToday.addMonths(-1)};
        return dtThisMonthLastMonth;
    } 

    private Map<String, Cloud_ETL_Reconciliation__c> getMapUniqueIdToCloudEtlReconcile(Date dtToday) {
        Date[] dtThisMonthLastMonth = getThisMonthLastMonth(dtToday);
        String strDateThisMonthQuery = dtThisMonthLastMonth[0].month() + '-' + dtThisMonthLastMonth[0].year();
        String strDateLastMonthQuery = dtThisMonthLastMonth[1].month() + '-' + dtThisMonthLastMonth[1].year();
        
        String strSOQL = 'SELECT Unique_Id__c, Expected_File_Count__c, Account_Name__c FROM Cloud_ETL_Reconciliation__c  WHERE Unique_Id__c like \'%#' + strDateThisMonthQuery + '\'';
        strSOQL += ' OR Unique_Id__c like \'%#' + strDateLastMonthQuery + '\'';
        System.Debug('strSOQL ' + strSOQL);
        List<Cloud_ETL_Reconciliation__c > listExistingReconcileRecords = (List<Cloud_ETL_Reconciliation__c>) Database.query(strSOQL);

        Map<String, Cloud_ETL_Reconciliation__c> map_UniqueIdToCloudEtlReconcile = new Map<String, Cloud_ETL_Reconciliation__c>();
        for (Cloud_ETL_Reconciliation__c objCER : listExistingReconcileRecords) {
            map_UniqueIdToCloudEtlReconcile.put(objCER.Unique_Id__c, objCER);
        }
		return map_UniqueIdToCloudEtlReconcile;
    }

    public void populateExpectedFileCountsPureEngage() {
        populateExpectedFileCountsPureEngage(Date.today());
    }

    public void populateExpectedFileCountsPureEngage(Date dtToday) {

        Date[] dtThisMonthLastMonth = getThisMonthLastMonth(dtToday);
        String strDateThisMonthQuery = dtThisMonthLastMonth[0].month() + '-' + dtThisMonthLastMonth[0].year();
        String strDateLastMonthQuery = dtThisMonthLastMonth[1].month() + '-' + dtThisMonthLastMonth[1].year();
        System.debug('Search for existing Reconcile Records ending in #' + strDateLastMonthQuery + ' and #' + strDateLastMonthQuery);

        // Get any existing Reconcile Records
        String strSOQL = 'SELECT Unique_Id__c, Expected_File_Count__c FROM Cloud_ETL_Reconciliation__c  WHERE Unique_Id__c like \'%#' + strDateThisMonthQuery + '\'';
        strSOQL += ' OR Unique_Id__c like \'%#' + strDateLastMonthQuery + '\'';
        System.Debug('strSOQL ' + strSOQL);
        List<Cloud_ETL_Reconciliation__c > listExistingReconcileRecords = (List<Cloud_ETL_Reconciliation__c>) Database.query(strSOQL);

        Map<String, Cloud_ETL_Reconciliation__c> map_UniqueIdToCloudEtlReconcile = new Map<String, Cloud_ETL_Reconciliation__c>();
        for (Cloud_ETL_Reconciliation__c objCER : listExistingReconcileRecords) {
            map_UniqueIdToCloudEtlReconcile.put(objCER.Unique_Id__c, objCER);
        }

        // Get any existing Reconcile Records
        List<Cloud_Deployment__c> listCloudDeployments = [
            select Tenant_ID__c from Cloud_Deployment__c where Tenant_ID__c != null
        ];
        Set<String> setTenantIds = new Set<String>();
        for (Cloud_Deployment__c objCloudDeplyment : listCloudDeployments) {
            //System.Debug('Need to populate expected for ' + objCloudDeplyment);
            setTenantIds.add(objCloudDeplyment.Tenant_ID__c);
        }

        List<Client_Product_Mapping__c> listClientProductMapping = [
            select Id,
            Agent_Seats_Concurrent__c,
            Agent_Seats_Concurrent_Region_Count__c,
            Agent_Seats__c,
            Agent_Seats_Enabled_Region_Count__c,
            Inbound_Minutes__c,
            Inbound_Minute_Region_Count__c,
            IVR_Port_Excess_Minutes__c,
            IVR_Port_Excess_Region_Count__c,
            IVR_Ports__c,
            IVR_Port_Region_Count__c,
            Outbound_Minutes__c,
            Outbound_Minute_Region_Count__c,
            Port_Minutes__c,
            Port_Minute_Region_Count__c,
            Tenant_Id__c,
            Cloud_Deployment__r.Account__r.Name,
            Cloud_Deployment__r.Account__r.SAP_Account_Code__c,
            Cloud_Deployment__r.Sold_To_Account__r.Name,
            Cloud_Deployment__r.Sold_To_Account__r.SAP_Account_Code__c
            FROM Client_Product_Mapping__c
            WHERE Cloud_Deployment__r.Tenant_ID__c != null
        ];
        
        Map<Id, Client_Product_Mapping__c> mapClientProductMappingToUpdate = new Map<Id, Client_Product_Mapping__c>();
        // Where there are checks but no regions counts, add assumed region count of 1
        for (Client_Product_Mapping__c objClientProductMapping : listClientProductMapping) {
            if (objClientProductMapping.Agent_Seats_Concurrent__c == true && (objClientProductMapping.Agent_Seats_Concurrent_Region_Count__c == null ||
                                                                              objClientProductMapping.Agent_Seats_Concurrent_Region_Count__c == '0')) {
                objClientProductMapping.Agent_Seats_Concurrent_Region_Count__c = '1';
                if (!mapClientProductMappingToUpdate.containsKey(objClientProductMapping.Id))
                    mapClientProductMappingToUpdate.put(objClientProductMapping.Id, objClientProductMapping);
            }
            if (objClientProductMapping.Agent_Seats__c == true && (objClientProductMapping.Agent_Seats_Enabled_Region_Count__c == null ||
                                                                   objClientProductMapping.Agent_Seats_Enabled_Region_Count__c == '0')) {
                objClientProductMapping.Agent_Seats_Enabled_Region_Count__c = '1';
                if (!mapClientProductMappingToUpdate.containsKey(objClientProductMapping.Id))
                    mapClientProductMappingToUpdate.put(objClientProductMapping.Id, objClientProductMapping);
            }
            if (objClientProductMapping.Inbound_Minutes__c == true && (objClientProductMapping.Inbound_Minute_Region_Count__c == null ||
                                                                       objClientProductMapping.Inbound_Minute_Region_Count__c == '0')) {
                objClientProductMapping.Inbound_Minute_Region_Count__c = '1';
                if (!mapClientProductMappingToUpdate.containsKey(objClientProductMapping.Id))
                    mapClientProductMappingToUpdate.put(objClientProductMapping.Id, objClientProductMapping);
            }
            if (objClientProductMapping.IVR_Port_Excess_Minutes__c == true && (objClientProductMapping.IVR_Port_Excess_Region_Count__c == null ||
                                                                               objClientProductMapping.IVR_Port_Excess_Region_Count__c == '0')) {
                objClientProductMapping.IVR_Port_Excess_Region_Count__c = '1';
                if (!mapClientProductMappingToUpdate.containsKey(objClientProductMapping.Id))
                    mapClientProductMappingToUpdate.put(objClientProductMapping.Id, objClientProductMapping);
            }
            if (objClientProductMapping.IVR_Ports__c == true && (objClientProductMapping.IVR_Port_Region_Count__c == null ||
                                                                 objClientProductMapping.IVR_Port_Region_Count__c == '0')) {
                objClientProductMapping.IVR_Port_Region_Count__c = '1';
                if (!mapClientProductMappingToUpdate.containsKey(objClientProductMapping.Id))
                    mapClientProductMappingToUpdate.put(objClientProductMapping.Id, objClientProductMapping);
            }
            if (objClientProductMapping.Outbound_Minutes__c == true && (objClientProductMapping.Outbound_Minute_Region_Count__c == null ||
                                                                        objClientProductMapping.Outbound_Minute_Region_Count__c == '0')) {
                objClientProductMapping.Outbound_Minute_Region_Count__c = '1';
                if (!mapClientProductMappingToUpdate.containsKey(objClientProductMapping.Id))
                    mapClientProductMappingToUpdate.put(objClientProductMapping.Id, objClientProductMapping);
            }
            if (objClientProductMapping.Port_Minutes__c == true && (objClientProductMapping.Port_Minute_Region_Count__c == null ||
                                                                    objClientProductMapping.Port_Minute_Region_Count__c == '0')) {
                objClientProductMapping.Port_Minute_Region_Count__c = '1';
                if (!mapClientProductMappingToUpdate.containsKey(objClientProductMapping.Id))
                    mapClientProductMappingToUpdate.put(objClientProductMapping.Id, objClientProductMapping);
            }
        }
        List<Client_Product_Mapping__c> listClientProductMappingToUpdate = new List<Client_Product_Mapping__c>();
        List<Id> listIdKeys = new List<Id>();
        listIdKeys.addAll(mapClientProductMappingToUpdate.keySet());
        for (Id idKey : listIdKeys) {
            Client_Product_Mapping__c objClientProductMapping = mapClientProductMappingToUpdate.get(idKey);
            listClientProductMappingToUpdate.add(objClientProductMapping);
        }
        update listClientProductMappingToUpdate;

        Map<String, String> mapActivityTypeToReconcileHash = new Map<String, String>{
	            'Agent Seats Concurrent'    => '#5#14#1#19#1#ROLLUP - SUCCESS#',
                'Agent Seats Enabled'       => '#5#14#1#19#2#ROLLUP - SUCCESS#',
                'Inbound Minutes'           => '#0#2#1#0#0#ROLLUP - SUCCESS#',
                'Inbound Minutes Toll Free' => '#0#2#1#2#0#ROLLUP - SUCCESS#',
                'IVR Port Excess Minutes'   => '#0#2#1#20#0#ROLLUP - SUCCESS#',
                'IVR Ports'                 => '#6#19#1#20#1#ROLLUP - SUCCESS#',
                'Outbound Minutes'          => '#0#1#1#0#0#ROLLUP - SUCCESS#',
                'Port Minutes'              => '#0#2#1#21#0#ROLLUP - SUCCESS#'};

        for (Date dt : dtThisMonthLastMonth) {
            Integer intDaysThisMonth = Date.daysInMonth(dt.year(), dt.month());

            String strDateThisMonth = dt.month() + '-' + dt.year();
            for (Client_Product_Mapping__c objClientProductMapping : listClientProductMapping) {
                String strAccountName = objClientProductMapping.Cloud_Deployment__r.Account__r.Name;
                String strGarnCode = objClientProductMapping.Cloud_Deployment__r.Account__r.SAP_Account_Code__c;
                if (objClientProductMapping.Cloud_Deployment__r.Sold_To_Account__r.Name != null) {
                    strAccountName = objClientProductMapping.Cloud_Deployment__r.Sold_To_Account__r.Name;
                    strGarnCode = objClientProductMapping.Cloud_Deployment__r.Account__r.SAP_Account_Code__c;
                }
                System.Debug('Write for objClientProductMapping ' + objClientProductMapping);
                if (objClientProductMapping.Agent_Seats_Concurrent__c == true) {
                    String strHash = objClientProductMapping.Tenant_Id__c + mapActivityTypeToReconcileHash.get('Agent Seats Concurrent');
                    String strHashThisMonth = strHash + strDateThisMonth;
                    //Expect 1 file per region per day
                    Integer intExpectedFilesThisMonth = intDaysThisMonth * getInteger(objClientProductMapping.Agent_Seats_Concurrent_Region_Count__c);
                    updateOrCreateReconcileRecord(strHashThisMonth, intDaysThisMonth, strAccountName, strGarnCode, 'BEEEC', objClientProductMapping.Tenant_Id__c, map_UniqueIdToCloudEtlReconcile);
                }
                if (objClientProductMapping.Agent_Seats__c == true) {
                    String strHash = objClientProductMapping.Tenant_Id__c + mapActivityTypeToReconcileHash.get('Agent Seats Enabled');
                    String strHashThisMonth = strHash + strDateThisMonth;
                    //Expect 1 file per region
                    Integer intExpectedFilesThisMonth = getInteger(objClientProductMapping.Agent_Seats_Enabled_Region_Count__c);
                    updateOrCreateReconcileRecord(strHashThisMonth, intExpectedFilesThisMonth, strAccountName, strGarnCode, 'BEEEC', objClientProductMapping.Tenant_Id__c, map_UniqueIdToCloudEtlReconcile);
                }
                if (objClientProductMapping.Inbound_Minutes__c == true) {
                    {
                    String strHash = objClientProductMapping.Tenant_Id__c + mapActivityTypeToReconcileHash.get('Inbound Minutes');
                    String strHashThisMonth = strHash + strDateThisMonth;
                    //Expect 1 file per region
                    Integer intExpectedFilesThisMonth = intDaysThisMonth * getInteger(objClientProductMapping.Inbound_Minute_Region_Count__c);
                    updateOrCreateReconcileRecord(strHashThisMonth, intExpectedFilesThisMonth, strAccountName, strGarnCode, 'BEEEC', objClientProductMapping.Tenant_Id__c, map_UniqueIdToCloudEtlReconcile);
                    }
                    {
                    // Also include assumption of Toll Free record....
                    String strHash = objClientProductMapping.Tenant_Id__c + mapActivityTypeToReconcileHash.get('Inbound Minutes Toll Free');
                    String strHashThisMonth = strHash + strDateThisMonth;
                    //Expect 1 file per region
                    Integer intExpectedFilesThisMonth = intDaysThisMonth * getInteger(objClientProductMapping.Inbound_Minute_Region_Count__c);
                    updateOrCreateReconcileRecord(strHashThisMonth, intExpectedFilesThisMonth, strAccountName, strGarnCode, 'BEEEC', objClientProductMapping.Tenant_Id__c, map_UniqueIdToCloudEtlReconcile);
                    }
                }
                if (objClientProductMapping.IVR_Port_Excess_Minutes__c == true) {
                    String strHash = objClientProductMapping.Tenant_Id__c + mapActivityTypeToReconcileHash.get('IVR Port Excess Minutes');
                    String strHashThisMonth = strHash + strDateThisMonth;
                    //Expect 1 file per region
                    Integer intExpectedFilesThisMonth = intDaysThisMonth * getInteger(objClientProductMapping.IVR_Port_Excess_Region_Count__c);
                    updateOrCreateReconcileRecord(strHashThisMonth, intExpectedFilesThisMonth, strAccountName, strGarnCode, 'BEEEC', objClientProductMapping.Tenant_Id__c, map_UniqueIdToCloudEtlReconcile);
                }
                if (objClientProductMapping.IVR_Ports__c == true) {
                    String strHash = objClientProductMapping.Tenant_Id__c + mapActivityTypeToReconcileHash.get('IVR Ports');
                    String strHashThisMonth = strHash + strDateThisMonth;
                    //Expect 1 file per region
                    Integer intExpectedFilesThisMonth = intDaysThisMonth * getInteger(objClientProductMapping.IVR_Port_Region_Count__c);
                    updateOrCreateReconcileRecord(strHashThisMonth, intExpectedFilesThisMonth, strAccountName, strGarnCode, 'BEEEC', objClientProductMapping.Tenant_Id__c, map_UniqueIdToCloudEtlReconcile);
                }
                if (objClientProductMapping.Outbound_Minutes__c == true) {
                    String strHash = objClientProductMapping.Tenant_Id__c + mapActivityTypeToReconcileHash.get('Outbound Minutes');
                    String strHashThisMonth = strHash + strDateThisMonth;
                    //Expect 1 file per region
                    Integer intExpectedFilesThisMonth = intDaysThisMonth * getInteger(objClientProductMapping.Outbound_Minute_Region_Count__c);
                    updateOrCreateReconcileRecord(strHashThisMonth, intExpectedFilesThisMonth, strAccountName, strGarnCode, 'BEEEC', objClientProductMapping.Tenant_Id__c, map_UniqueIdToCloudEtlReconcile);
                }
                if (objClientProductMapping.Port_Minutes__c == true) {
                    String strHash = objClientProductMapping.Tenant_Id__c + mapActivityTypeToReconcileHash.get('Port Minutes');
                    String strHashThisMonth = strHash + strDateThisMonth;
                    //Expect 1 file per region
                    Integer intExpectedFilesThisMonth = intDaysThisMonth * getInteger(objClientProductMapping.Port_Minute_Region_Count__c);
                    updateOrCreateReconcileRecord(strHashThisMonth, intExpectedFilesThisMonth, strAccountName, strGarnCode, 'BEEEC', objClientProductMapping.Tenant_Id__c, map_UniqueIdToCloudEtlReconcile);
                }
            }
        }
        List<Cloud_ETL_Reconciliation__c> listCERtoUpsert = new List<Cloud_ETL_Reconciliation__c>();
        Set<String> setHashesNotConfigured = new Set<String>();
        for (String strKeyToUpsert : map_UniqueIdToCloudEtlReconcile.keySet()) {
            Cloud_ETL_Reconciliation__c objReconcile = map_UniqueIdToCloudEtlReconcile.get(strKeyToUpsert);
            listCERtoUpsert.add(objReconcile);

            Boolean blnFoundMatch = false;
            for (String strSubHashValue : mapActivityTypeToReconcileHash.values()) {
                if (strKeyToUpsert.contains(strSubHashValue)) {
                    // Not configured correctly but could be. Update Client Product Mapping
                    //System.debug('strKeyToUpsert ' + strKeyToUpsert + ' has a setting in client mapping for ' + strSubHashValue + ' expected file count is ' + objReconcile.Expected_File_Count__c);
                    blnFoundMatch = true;
                    setHashesNotConfigured.add(strKeyToUpsert);
                    break;
                }
            }
            // Should be in Client Mapping Object but needs to be coded, added to mapActivityTypeToReconcileHash
            if (!blnFoundMatch) System.Debug('Did not find match for strKeyToUpsert ' + strKeyToUpsert + ' expected file count is ' + objReconcile.Expected_File_Count__c);
        }

        if (objJobLog != null) objJobLog.Info__c += setHashesNotConfigured;
        else System.Debug('Need to code setHashesNotConfigured ' + setHashesNotConfigured);

        upsert listCERtoUpsert;
    }
    
    private Cloud_ETL_Reconciliation__c updateOrCreateReconcileRecord(String strHashMonth,
                                                                      Integer intExpectedFileCount,
                                                                      String strAccountName,
                                                                      String strGarnCode,
                                                                      String strSourceName,
                                                                      String strPlatformId,
                                                                      Map<String, Cloud_ETL_Reconciliation__c> map_UniqueIdToCloudEtlReconcile) {
        System.debug('updateOrCreateReconcileRecord: strHashMonth ' + strHashMonth + ' expected ' + intExpectedFileCount);
        Cloud_ETL_Reconciliation__c objCER = map_UniqueIdToCloudEtlReconcile.get(strHashMonth);
        if (objCER != null) {
            System.Debug('updateOrCreateReconcileRecord: Got Reconcile Record to update ' + objCER);
            objCER.Expected_File_Count__c = intExpectedFileCount;
        } else if (intExpectedFileCount > 0) {
            String[] strHashTokens = strHashMonth.split('#');
            String strMonthYear = strHashTokens[strHashTokens.size()-1];
            String strMonth = strMonthYear.split('-')[0];
            String strYear = strMonthYear.split('-')[1];
            System.Debug('updateOrCreateReconcileRecord: Did not Find Reconcile Record for hash ' + strHashMonth + ' creating one for count ' + intExpectedFileCount);
            objCER = new Cloud_ETL_Reconciliation__c(Name=strHashMonth,
                                                     Account_Name__c = strAccountName,
                                                     GARN_Account_Code__c = strGarnCode,
                                                     Source_Name__c = strSourceName,
                                                     Platform_Id__c = strPlatformId,
                                                     Unique_Id__c = strHashMonth,
                                                     Expected_File_Count__c = intExpectedFileCount,
                                                     Month__c = strMonth,
                                                     Year__c = strYear);
            System.Debug('objCER ' + objCER);
            map_UniqueIdToCloudEtlReconcile.put(strHashMonth, objCER);
        }
        return objCER;
    }
    
    private Integer getInteger(String strInteger) {
        if (strInteger == null) return 0;
        return Integer.valueOf(strInteger);
    }
    
    public void populateExpectedFileCountsSubscription() {
        populateExpectedFileCountsSubscription(Date.today());
    }

    public void populateExpectedFileCountsSubscription(Date dtToday) {

        Date[] dtThisMonthLastMonth = getThisMonthLastMonth(dtToday);
        String strDateThisMonthQuery = dtThisMonthLastMonth[0].month() + '-' + dtThisMonthLastMonth[0].year();
        String strDateLastMonthQuery = dtThisMonthLastMonth[1].month() + '-' + dtThisMonthLastMonth[1].year();

        Map<String, Cloud_ETL_Reconciliation__c> map_UniqueIdToCloudEtlReconcile = getMapUniqueIdToCloudEtlReconcile(dtToday);

        List<Contract_Tier_Set__c> listTierSet = [
            SELECT
            Id,
            Name,
            Contract__c,
            Contract__r.Pricing_Start_Day__c,
            Contract__r.Usage_Data_Submission_Method__c,
            (SELECT Service__r.Name, Service__r.Identifier_Hash__c, Service__r.Usage_Type__c, Service__r.Service_Type_Value__c
             FROM Contract_Services__r)
            FROM Contract_Tier_Set__c
            WHERE Contract__r.Quote__r.Offering_Type__c LIKE '%Subscription%'
            AND Contract__r.Status__c = 'Approved'
            AND Files_Expected__c = true
            AND Is_Deleted__c = false
        ];
        Set<Id> setContractIds = new Set<Id>();
        for (Contract_Tier_Set__c objTierSet : listTierSet) {
            setContractIds.add(objTierSet.Contract__c);
        }

        List<Cloud_Deployment_To_Contract_Junction__c> listCloudDeploymentJunction = [
          SELECT
            Contract__c,
            Cloud_Deployment__r.Account__r.Name,
            Cloud_Deployment__r.Account__r.SAP_Account_Code__c,
            Cloud_Deployment__r.Sold_To_Account__r.Name,
            Cloud_Deployment__r.Sold_To_Account__r.SAP_Account_Code__c,
            Cloud_Deployment__r.Billing_Platform_Id__c,
            Cloud_Deployment__r.Billing_Platform_Id_Hash__c
          FROM Cloud_Deployment_To_Contract_Junction__c
          WHERE Contract__c in :setContractIds
          AND Cloud_Deployment__r.Billing_Platform_Id_Hash__c != null
        ];

        Map<Id, List<Cloud_Deployment_To_Contract_Junction__c>> mapContractIdToListCloudDeploymentJunction = new Map<Id, List<Cloud_Deployment_To_Contract_Junction__c>>();
        for (Cloud_Deployment_To_Contract_Junction__c objCloudDeploymentJunction : listCloudDeploymentJunction) {

            System.Debug('objCloudDeploymentJunction ' + objCloudDeploymentJunction);
            if (mapContractIdToListCloudDeploymentJunction.containsKey(objCloudDeploymentJunction.Contract__c)) {
                //System.debug('Exists');
                List<Cloud_Deployment_To_Contract_Junction__c> listCDJunctions = mapContractIdToListCloudDeploymentJunction.get(objCloudDeploymentJunction.Contract__c);
                listCDJunctions.add(objCloudDeploymentJunction);
            } else {
                //System.debug('Create New');
                List<Cloud_Deployment_To_Contract_Junction__c> listCDJunctions = new List<Cloud_Deployment_To_Contract_Junction__c>();
                listCDJunctions.add(objCloudDeploymentJunction);
                mapContractIdToListCloudDeploymentJunction.put(objCloudDeploymentJunction.Contract__c, listCDJunctions);
            }
        }

        for (Contract_Tier_Set__c objTierSet : listTierSet) {
            Decimal decPriceStartDay = objTierSet.Contract__r.Pricing_Start_Day__c;

            System.Debug('Id ' + objTierSet.Id + ' Tier Set ' + objTierSet.Name + ' services count ' + objTierSet.Contract_Services__r.size());
            List<Cloud_Deployment_To_Contract_Junction__c> listCDJunctions = mapContractIdToListCloudDeploymentJunction.get(objTierSet.Contract__c);
            //System.debug('Contract Id ' + objTierSet.Contract__c + ' Got list Id ' + listPlatformIds);
            for (Contract_Service__c objContractService : objTierSet.Contract_Services__r) {
                System.Debug('Service : ' + objContractService);
                if (listCDJunctions == null) {
                    System.Debug(' listCDJunctions is null');
                } else {
                    for (Cloud_Deployment_To_Contract_Junction__c objCDJunction : listCDJunctions) {

                        String strAccountName = objCDJunction.Cloud_Deployment__r.Account__r.Name;
                        String strGarnCode =  objCDJunction.Cloud_Deployment__r.Account__r.SAP_Account_Code__c;
                        if (objCDJunction.Cloud_Deployment__r.Sold_To_Account__r.Name != null) {
                            strAccountName = objCDJunction.Cloud_Deployment__r.Sold_To_Account__r.Name;
                            strGarnCode = objCDJunction.Cloud_Deployment__r.Sold_To_Account__r.SAP_Account_Code__c;
                        }

                        System.debug(objCDJunction + ' objCDJunction.Cloud_Deployment__r.Billing_Platform_Id_Hash__c ' + objCDJunction.Cloud_Deployment__r.Billing_Platform_Id_Hash__c);
                        String[] listHashParts = objCDJunction.Cloud_Deployment__r.Billing_Platform_Id_Hash__c.split('#');
                        String strSourceName  = listHashParts[0];
                        String strPlatformId  = listHashParts[1];

                        if (objCDJunction == null) {
                            System.Debug('objTierSet ' + objTierSet.Id + ' has null');
                            continue;
                        }
                        String strActivityType = '';
                        if (objContractService.Service__r.Service_Type_Value__c == 14) {
                            strActivityType = '5#';
                        } else if (objContractService.Service__r.Service_Type_Value__c == 19) {
                            strActivityType = '6#';
                        } else {
                            System.Debug('Warning Service objContractService.Service__r.Name ' + objContractService.Service__r.Name +
                                         ' did not have an expected Agent Seat or Port Service Type ' + objContractService.Service__r);
                        }
                        String strBaseHash = objCDJunction.Cloud_Deployment__r.Billing_Platform_Id__c + '#' + strActivityType + objContractService.Service__r.Identifier_Hash__c + '#ROLLUP - SUCCESS#' ;
                        System.Debug(' Base hash ' + strBaseHash);
                        for (Date dt : dtThisMonthLastMonth) {
                            Date dtPeriodStart = Date.newInstance(dt.year(), dt.month(), (Integer)decPriceStartDay);
                            Date dtPeriodEnd = dtPeriodStart.addMonths(1).addDays(-1);

                            String strDate = dt.month() + '-' + dt.year();
                            String strFullHash = strBaseHash + strDate;
                            Integer intDaysMonth = Date.daysInMonth(dt.year(), dt.month());
                            System.Debug(' Full hash ' + strFullHash);
                            Cloud_ETL_Reconciliation__c objRecon;
                            if (objContractService.Service__r.Usage_Type__c == 2) {
                                System.Debug('upsert as enabled expected 1');
                                objRecon = updateOrCreateReconcileRecord(strFullHash, 1, strAccountName, strGarnCode, strSourceName, strPlatformId, map_UniqueIdToCloudEtlReconcile);
                            } else { // Will catch Usage Type 1 as well as any service without a Usage Type setting
                                System.Debug('upsert as concurrent expected ' + intDaysMonth);
								objRecon = updateOrCreateReconcileRecord(strFullHash, intDaysMonth, strAccountName, strGarnCode, strSourceName, strPlatformId, map_UniqueIdToCloudEtlReconcile);
                            }
                            if (objRecon != null) {
                                objRecon.Period_Start_Date__c = dtPeriodStart;
                                objRecon.Period_End_Date__c = dtPeriodEnd;
                                objRecon.File_Delivery_Method__c = objTierSet.Contract__r.Usage_Data_Submission_Method__c;
                                objRecon.Tier_Set_Name__c = objTierSet.Name;
                            }
                        }
                    }
                }
                //String strHash = objClientProductMapping.Tenant_Id__c + mapActivityTypeToReconcileHash.get('Agent Seats Concurrent');
            }
        }
        List<Cloud_ETL_Reconciliation__c> listCERtoUpsert = new List<Cloud_ETL_Reconciliation__c>();
        Set<String> setHashesNotConfigured = new Set<String>();
        System.Debug('map_UniqueIdToCloudEtlReconcile size ' + map_UniqueIdToCloudEtlReconcile.size());
        for (String strKeyToUpsert : map_UniqueIdToCloudEtlReconcile.keySet()) {
            Cloud_ETL_Reconciliation__c objReconcile = map_UniqueIdToCloudEtlReconcile.get(strKeyToUpsert);
            listCERtoUpsert.add(objReconcile);
        }
        upsert listCERtoUpsert;
    }


// End Class
}