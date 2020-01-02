/*
 * Class			: GenesysCareForecastingUtilTest
 * Description		: A Test Class for GenesysCareForecastingCleanupBatch, GenesysCareForecastingIRBatch, GenesysCareForecastingFYMBatch, GenesysCareForeCastingRollupBatch.
 * Author			: Narasimha "Rao" Tumma
 * Created Date		: Dec 19, 2016
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Harish, 03/21/2017 - Modified setupTestData to add posting_amount_USD for forecasting records.
 * 
 */
@isTest
private class GenesysCareForecastingBatchesTest {

    @isTest
    static void testGenesysCareForecastingCleanupBatchAll(){
        setupTestData();
        Database.executeBatch(new GenesysCareForecastingCleanupBatch(), 5000);
    } 
    
	@isTest
    static void testGenesysCareForecastingCleanupBatch(){
        setupTestData();
        Database.executeBatch(new GenesysCareForecastingCleanupBatch('\'Recognized Revenue\',\'First Year Maintenance\''), 5000);
    } 
    
	@isTest(seeAllData=true)
	static void testGenesysCareForecastingIRBatch(){
        // needs mutiple queries
        String GenesysRenewalRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Genesys Renewal').getRecordTypeId();
        Integer numberOfDays = 90;
        String query = 'SELECT id, Name, Service_Contract__c FROM Opportunity '
                        + ' WHERE RecordTypeId = \''+GenesysRenewalRT+'\'' 
                        + ' AND Opportunity_Status__c = \'In Progress\'';
        
        String opportunityIdForOrderNotCompletedQuote = '';
        String opportunityIdForNoOrderExists = '';
        
        String oppIds = '';
        List<BigMachines__Quote__c> quotesWithOrdersNotCompleted = [SELECT id, name, BigMachines__Opportunity__c 
                                                                    FROM BigMachines__Quote__c  
                                           							WHERE Quote_Business_Type__c = 'Renewal' 
                                                                    AND Order__c != NULL AND Order__r.status__c != 'Completed' LIMIT 1];
        if(quotesWithOrdersNotCompleted.size() > 0){
            oppIds = '\''+quotesWithOrdersNotCompleted[0].BigMachines__Opportunity__c+'\'';
        }
        
        List<BigMachines__Quote__c> quotesWithNoOrders = [SELECT id, name, BigMachines__Opportunity__c 
                                                                    FROM BigMachines__Quote__c  
                                           							WHERE Quote_Business_Type__c = 'Renewal' 
                                                                    AND Order__c = NULL 
                                                                    AND BigMachines__Is_Primary__c = true 
                                                                    LIMIT 1];
        if(quotesWithNoOrders.size() > 0){
            oppIds = oppIds == '' ? '\''+quotesWithNoOrders[0].BigMachines__Opportunity__c+'\'' : oppIds +  ', \''+quotesWithNoOrders[0].BigMachines__Opportunity__c+'\'';
        }

        // Split opportunities with service contract
        for(Opportunity opp : [Select Id 
                                    From Opportunity 
                                        Where RecordTypeId = :GenesysRenewalRT
                                              AND Opportunity_Status__c = :CONSTANTS.OPP_OPPSTATUS_SPLIT
                                              AND Split_Parent_Quote__r.BigMachines__Is_Primary__c = true limit 5]){
            oppIds = oppIds == '' ? '\''+opp.Id+'\'' : oppIds +  ', \''+opp.Id+'\'';   
        }

        // non-split opportunities with no quotes but service contracts
        for(Opportunity opp : [Select Id 
                                    From Opportunity
                                        Where RecordTypeId = :GenesysRenewalRT
                                              AND Opportunity_Status__c != :CONSTANTS.OPP_OPPSTATUS_SPLIT
                                              AND Primary_Quote__c = null limit 10]){
            oppIds = oppIds == '' ? '\''+opp.Id+'\'' : oppIds +  ', \''+opp.Id+'\'';      
        }
        
        Database.executeBatch(new GenesysCareForecastingIRBatch('Select Id, Name, CloseDate, Opportunity_Status__c, Service_Contract__c, Service_Contract__r.EndDate, Split_Parent_Quote__c, Split_Parent_Quote__r.BigMachines__Is_Primary__c FROM Opportunity WHERE Id IN ('+oppIds+')'));
        GenesysCareForecastingIRBatch batch = new GenesysCareForecastingIRBatch();
    } 
	@isTest(seeAllData=true)
	static void testGenesysCareForecastingFYMBatch(){
        Database.executeBatch(new GenesysCareForecastingFYMBatch()); 
    } 
	@isTest
	static void testGenesysCareForeCastingRollupBatch(){
       setupTestData();
       Database.executeBatch(new GenesysCareForeCastingRollupBatch());
    } 
    @isTest
	static void testGenesysCareForecastingCleanupScheduler(){
        String cronExp = '0 0 0 3 9 ? 2022';
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('testScheduler1', cronExp, new GenesysCareForecastingCleanupScheduler());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(cronExp, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    } 
	@isTest
	static void testGenesysCareForecastingScheduler(){
        String cronExp = '0 0 0 3 9 ? 2022';
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('testScheduler2', cronExp, new GenesysCareForecastingScheduler());
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        // Verify the expressions are the same
        System.assertEquals(cronExp, ct.CronExpression);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // Verify the next time the job will run
        System.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
    } 
    
    static void setupTestData(){
        List<Genesys_Care_Forecasting__c> genCareFCList = new List<Genesys_Care_Forecasting__c>();
        List<String> regions = new List<String>{'APAC', 'EMEA','Latin America', 'North America'};
		List<String> revenueTypes = new List<String>{'Billing Schedule', 'Deferred Revenue', 'Incremental Revenue', 'Recognized Revenue','First Year Maintenance'};
        List<String> subCategories = new List<String>{CONSTANTS.GCF_SUBCATEGORY_FYM, CONSTANTS.GCF_SUBCATEGORY_RENEWAL, CONSTANTS.GCF_SUBCATEGORY_EXPECTED, CONSTANTS.GCF_SUBCATEGORY_UPSIDE};
		
        for(String region : regions){
            for(String revenueType : revenueTypes){
                for(String subCategory : subCategories){
    		        Date tempDate = Date.newInstance(Date.today().year()-1, 1, 1); 
                    for(Integer i = 0; i < 36; i++){
                        genCareFCList.add(new Genesys_Care_Forecasting__c(
                            Region__c = region, Revenue_Type__c = revenueType,
                            Sold_To__c = NULL, Sold_To_Name__c = 'SOLDTO', Sold_To_GARN_Code__c = 'SOLDTO', Sold_To_Subsidary_Code__c = 'SOLD',
                            End_User__c = NULL, End_User_Name__c = 'ENDUSER', End_User_GARN_Code__c = 'ENDUSER', End_User_Subsidary_Code__c = 'ENDU',
                            Sub_Region__c = 'Sub Region', Item_Name__c = 'ITEM NAME', Item_Description__c = 'ITEM DESCRIPTION',
                            Maintenance_Start_Date__c = Date.newInstance(Date.today().year()-1, 1, 1),
                            Maintenance_End_Date__c = Date.newInstance(Date.today().year()+1, 12, 31),
                            Posting_Date__c = tempDate.addMonths(i), Posting_Year__c = tempDate.year(), Posting_Month__c = tempDate.month(), Posting_Amount__c = 10000, CurrencyIsoCode = 'USD', 
                            PO_Number__c = 'PONUM', SO_Number__c = 'SONUM', Order_Number__c = 'ORDNUM', Quote_Number__c = 'QUOTENUM',
                        	Posting_Amount_USD__c = 10000, Posting_Amount_EUR__c = 15000, Sub_category__c = subCategory));
                    }
                }
            }
        }
        Database.insert(genCareFCList);
        
        Integer minYear = Date.Today().year() -1;
        Integer maxYear = minYear + 2;
        List<Genesys_Care_Forecasting_Rollup__c> rollupRecords = new List<Genesys_Care_Forecasting_Rollup__c>();
        for(Integer y = minYear; y <=maxYear; y++){
            for(Integer m=1; m<=12; m++){
                rollupRecords.add(new Genesys_Care_Forecasting_Rollup__c(Unique_Id__c = y + '-' + m, 
                                                                         Year__c = y, 
                                                                         Month__c = m, 
                                                                         Quarter__c = GenesysCareForecastingUtil.getQuarter(m),
                                                                         Year_Text__c = ''+y,
                                                                         Month_Text__c = ''+m,
                                                                         Quarter_Text__c = ''+GenesysCareForecastingUtil.getQuarter(m)
                                                                        ));
            }
        }
        Database.insert(rollupRecords);
    }

}