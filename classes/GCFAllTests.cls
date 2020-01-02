/*
 * Class            : GCFAllTests
 * Description      : A Test class to for all classes of Genesys Care forecasting V2.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : May 19, 2017
 * Test Class       : NA   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */

@isTest
private class GCFAllTests {
	
	@isTest
    static void testGCFUtil(){
        Decimal amountUSD2USD = GCFUtil.convertCurrency(1000, 'USD', 'USD');
        Decimal amountUSD2EUR = GCFUtil.convertCurrency(1000, 'USD', 'EUR');
        Decimal amountEUR2USD = GCFUtil.convertCurrency(1000, 'EUR', 'USD');
        Decimal amountEUR2EUR = GCFUtil.convertCurrency(1000, 'EUR', 'EUR');
        
        String monthName = '';
        monthName = GCFUtil.getMonthName(1);
        monthName = GCFUtil.getMonthName(2);
        monthName = GCFUtil.getMonthName(3);
        monthName = GCFUtil.getMonthName(4);
        monthName = GCFUtil.getMonthName(5);
        monthName = GCFUtil.getMonthName(6);
        monthName = GCFUtil.getMonthName(7);
        monthName = GCFUtil.getMonthName(8);
        monthName = GCFUtil.getMonthName(9);
        monthName = GCFUtil.getMonthName(10);
        monthName = GCFUtil.getMonthName(11);
        monthName = GCFUtil.getMonthName(12);
        
        Integer quarter = 0;
        quarter = GCFUtil.getQuarter(1);
        quarter = GCFUtil.getQuarter(4);
        quarter = GCFUtil.getQuarter(7);
        quarter = GCFUtil.getQuarter(10);
        
        Date quarterStartDate1 = GCFUtil.getQuarterStartDate(1);
		Date quarterStartDate2 = GCFUtil.getQuarterStartDate(4);
		Date quarterStartDate3 = GCFUtil.getQuarterStartDate(7);
		Date quarterStartDate4 = GCFUtil.getQuarterStartDate(10);
		
		String quarterStartDateString1 = GCFUtil.getQuarterStartDateString(1);
		String quarterStartDateString2 = GCFUtil.getQuarterStartDateString(4);
		String quarterStartDateString3 = GCFUtil.getQuarterStartDateString(7);
		String quarterStartDateString4 = GCFUtil.getQuarterStartDateString(10);
        
        Boolean isImportedNeeded;
        isImportedNeeded = GCFUtil.isNetSuiteReportDataImportNeeded();
        setupTestData();
        List<NetSuite_Report_Data_Last_Imported__c> lastImportedDateList = [SELECT id, Name, Imported_Date__c FROM NetSuite_Report_Data_Last_Imported__c];
		lastImportedDateList.add(new NetSuite_Report_Data_Last_Imported__c(Name='LastImported',Imported_Date__c = Date.Today().addDays(-1)));
		Database.upsert(lastImportedDateList);
        isImportedNeeded = GCFUtil.isNetSuiteReportDataImportNeeded();
    }
	
	
    @isTest
    static void testCleanupBatch(){
        setupTestData();
        Database.executeBatch(new GCFDataCleanupBatch(), 2000);
    } 
    
    @isTest
    static void testGCFCopyReportData(){
        setupTestData();
        Database.executeBatch(new GCFCopyReportData(), 500);
    } 
    
    @isTest
    static void testGCFCopyNetSuiteReportData(){
        setupTestData();
        Database.executeBatch(new GCFCopyNetSuiteReportData(), 500);
    } 
    
    @isTest(seeAllData=true)
	static void testIncrementalBatch1(){
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
        
        Database.executeBatch(new GCFIncrementalBatch('Select Id, Name, CloseDate, Opportunity_Status__c, Service_Contract__c, Service_Contract__r.EndDate, Split_Parent_Quote__c, Split_Parent_Quote__r.BigMachines__Is_Primary__c, Lines_of_Businesses__c, Country__r.Name FROM Opportunity WHERE Id IN ('+oppIds+')'));
        GCFIncrementalBatch batch = new GCFIncrementalBatch();
		

		BigMachines__Quote__c quote = [SELECT Id, Name, CurrencyIsoCode, Maintenance_Start_Date__c, Maintenance_End_Date__c, 
                   									Total_Maintenance_Amount_Due_Formula__c, CAS_Maintenance_Due__c, 
            										Order__c, Order__r.Status__c, Order__r.Invoice_Date__c, Sold_To_Name__r.Region__c, 
            										BigMachines__Account__r.Region__c,
            										BigMachines__Opportunity__c, BigMachines__Opportunity__r.PO_Expected_Date__c, BigMachines__Opportunity__r.Lines_of_Businesses__c,
            										BigMachines__Opportunity__r.Forecast_Status__c 
            										FROM BigMachines__Quote__c  LIMIT 1];

		Date cutOffDate = Date.newInstance(2017,1,1);
		Date startDate = Date.newInstance(2017,1,1);						            	
		Date endDate = Date.newInstance(2017,12,1);
		Decimal amountInUSD = 1000.0;
		GCF_Data__c record1 = batch.getGCFRecord(quote, cutOffDate, startDate, endDate, amountInUSD);
        GCF_Data__c record2 = batch.getGCFRecord(quote);
        batch.fakeMethod();
    } 
    
   
    @isTest(seeAllData=true)
	static void testIncrementalBatch2(){
        List<BigMachines__Quote_Product__c> qProducts = [SELECT Id, BigMachines__Quote__r.BigMachines__Opportunity__c 
        													FROM BigMachines__Quote_Product__c 
        													WHERE BigMachines__Quote__r.Quote_Business_Type__c = 'Renewal' AND
        															BigMachines__Quote__r.BigMachines__Is_Primary__c = true 
                                                                     AND Annualized_Maintenance_Due__c != NULL 
                                                                     AND Annualized_Maintenance_Due__c != 0
                                                                     AND Maintenance_Start_Date__c != NULL 
                                                                     AND Maintenance_End_Date__c != NULL
                                                                     AND Maintenance_End_Date__c > TODAY
                                                                     AND (NOT Product_Description__c like 'Custom App%') 
                                                                     AND (NOT Product_Description__c like 'Custom Software%')
                                                                     AND (NOT Product_Description__c like '%Care%')
        													LIMIT 2];
        if(qProducts.size() > 0){
	        Database.executeBatch(new GCFIncrementalBatch('Select Id, Name, CloseDate, Opportunity_Status__c, Service_Contract__c, Service_Contract__r.EndDate, Split_Parent_Quote__c, Split_Parent_Quote__r.BigMachines__Is_Primary__c, Lines_of_Businesses__c, Country__r.Name FROM Opportunity WHERE Id = \''+qProducts[0].BigMachines__Quote__r.BigMachines__Opportunity__c+'\''));
	        GCFIncrementalBatch batch = new GCFIncrementalBatch();
	        BigMachines__Quote__c quote = [SELECT Id, Name, CurrencyIsoCode, Maintenance_Start_Date__c, Maintenance_End_Date__c, 
	                   									Total_Maintenance_Amount_Due_Formula__c, CAS_Maintenance_Due__c, 
	            										Order__c, Order__r.Status__c, Order__r.Invoice_Date__c, Order__r.Net_Suite_Order__c, 
	            										Sold_To_Name__r.Region__c, BigMachines__Account__r.Region__c,
	            										BigMachines__Opportunity__c, BigMachines__Opportunity__r.Service_Contract__c, BigMachines__Opportunity__r.CloseDate, BigMachines__Opportunity__r.PO_Expected_Date__c, 
	            										BigMachines__Opportunity__r.Forecast_Status__c, BigMachines__Opportunity__r.Lines_of_Businesses__c  
            										FROM BigMachines__Quote__c WHERE id = :qProducts[0].BigMachines__Quote__c];

			Date cutOffDate = Date.newInstance(2017,1,1);
			Date startDate = Date.newInstance(2017,1,1);						            	
			Date endDate = Date.newInstance(2017,12,1);
			Decimal amountInUSD = 1000.0;

			GCF_Data__c record1 = batch.getGCFRecord(quote, cutOffDate, startDate, endDate, amountInUSD);
	        GCF_Data__c record2 = batch.getGCFRecord(quote);
	        //List<GCF_Data__c> scGFCData = batch.processServiceContractForGCF(''+quote.BigMachines__Opportunity__r.Service_Contract__c, GCFUtil.getQuarterStartDate(Date.today().month()));
	        //List<GCF_Data__c> qRecord = batch.processQuoteForGCF(quote, GCFUtil.getQuarterStartDate(Date.today().month()), GCFUtil.getQuarterStartDate(Date.today().month()).addMonths(3));
        }
		

		
    } 
    
    
    @isTest(seeAllData=true)
	static void testFYMBatch(){
		GCFFYMBatch batch = new GCFFYMBatch();
		BigMachines__Quote__c quote = [SELECT Id, Name, CurrencyIsoCode, Opportunity_Close_Date__c, Forecast_Maint_End_Date__c, Order_Numb_of_Maint_Months__c, Total_Genesys_Care__c, 
						            	Order__c, Order__r.Status__c, Order__r.Invoice_Date__c, Order__r.Net_Suite_Order__c, Sold_To_Name__r.Region__c, BigMachines__Account__r.Region__c, 
						            	BigMachines__Opportunity__c, BigMachines__Opportunity__r.PO_Expected_Date__c, BigMachines__Opportunity__r.Lines_of_Businesses__c,  
						            	BigMachines__Opportunity__r.Forecast_Status__c, BigMachines__Opportunity__r.ForecastStatus__c 
						            	FROM BigMachines__Quote__c WHERE Opportunity_Close_Date__c != NULL LIMIT 1];
						            	
		Date cutOffDate = Date.newInstance(2017,1,1);
		Date startDate = Date.newInstance(2017,1,1);						            	
		Date endDate = Date.newInstance(2017,12,1);
		Decimal amountInUSD = 1000.0;
		GCF_Data__c record1 = batch.getGCFRecord(quote, cutOffDate, startDate, endDate, amountInUSD);
		GCF_Data__c record2 = batch.getGCFRecord(quote);
		
        Database.executeBatch(new GCFFYMBatch()); 
    }
    
    @isTest(seeAllData=true)
	static void testBillingPlanBatch(){
		GCFBillingPlanBatch batch = new GCFBillingPlanBatch();
		batch.fakeMethod();
        Database.executeBatch(new GCFBillingPlanBatch()); 
    }
    
    @isTest(seeAllData=true)
	static void testGCFTotalBookingForecastBatch(){
		GCFTotalBookingForecastBatch batch = new GCFTotalBookingForecastBatch();
		BigMachines__Quote__c quote = [SELECT Id, Name, CurrencyIsoCode, Opportunity_Close_Date__c, Forecast_Maint_End_Date__c, Order_Numb_of_Maint_Months__c, Total_Genesys_Care__c, 
						            	Order__c, Order__r.Status__c, Order__r.Invoice_Date__c, Sold_To_Name__r.Region__c, BigMachines__Account__r.Region__c, 
						            	BigMachines__Opportunity__c, BigMachines__Opportunity__r.PO_Expected_Date__c, BigMachines__Opportunity__r.Lines_of_Businesses__c 
						            	FROM BigMachines__Quote__c LIMIT 1];
						            	
		Date cutOffDate = Date.newInstance(2017,1,1);
		Date startDate = Date.newInstance(2017,1,1);						            	
		Date endDate = Date.newInstance(2017,12,1);
		Decimal amountInUSD = 1000.0;
		
        GCF_Data__c record1 = batch.getGCFRecord(quote, cutOffDate, startDate, endDate, amountInUSD);
        Database.executeBatch(batch); 
        
    }
    
    @isTest(seeAllData=true)
    static void testReportDataCleanupBatch(){
        setupTestData();
        Database.executeBatch(new GCFReportDataCleanupBatch(), 2000);
    } 
    
    @isTest(seeAllData=true)
	static void testGCFScheduler(){
        String cronExp = '0 0 0 3 9 ? 2022';
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('testScheduler1', cronExp, new GCFScheduler());
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
    static void testGenesysCareForecastingV2Controller(){
        setupTestData();
        
        Test.startTest();
       	PageReference pageRef = Page.GenesysCareForecastingV2;
        Test.setCurrentPageReference(pageRef);
    	GenesysCareForecastingV2Controller controller = new GenesysCareForecastingV2Controller();
		List<SelectOption> regions = controller.getRegions();
		List<SelectOption> years = controller.getYears();
		List<SelectOption> quarters = controller.getQuarters();
		List<SelectOption> currencies = controller.getCurrencies();
        controller.refereshForecastingData();
        controller.getforecastingDataListWithTotals();
        List<List<GenesysCareForecastingV2Controller.ForecastingExportData>> exportData = controller.revenueDataLists;
        Test.stopTest();
    }
    
    static void setupTestData(){
		List<GCF_Data__c> forecastingData = new List<GCF_Data__c>();
		List<GCF_NetSuite_Data__c> forecastingNetSuiteData = new List<GCF_NetSuite_Data__c>();
		List<GCF_Report_Data__c> forecastingReportData = new List<GCF_Report_Data__c>();
		Date dt = Date.newInstance(Date.Today().year(), 1, 1);
		for(integer i=0; i <12; i++){
			Date startDate = dt.addMonths(i);
			forecastingData.add(new GCF_Data__c(CurrencyIsoCode = 'USD',
														Year__c = startDate.year(),
														Year_Text__c = ''+startDate.year(),
														Month__c = startDate.month(),
														Month_Text__c = ''+startDate.month(),
														Quarter__c = GCFUtil.getQuarter(startDate.month()),
														Quarter_Text__c = ''+GCFUtil.getQuarter(startDate.month()),
														Region__c = 'North America',
														Revenue_Type__c = 'Incremental Revenue',
                                                		Offering_Type__c = 'PureEngage',
														Incremental_R__c = 1000.0,
														Incremental_E__c = 1000.0,
			                							Incremental_U__c = 1000.0,
			                							Incremental_TIV__c = 3000.0
														));
			forecastingReportData.add(new GCF_Report_Data__c(CurrencyIsoCode = 'USD',
														Year__c = startDate.year(),
														Year_Text__c = ''+startDate.year(),
														Month__c = startDate.month(),
														Month_Text__c = ''+startDate.month(),
														Quarter__c = GCFUtil.getQuarter(startDate.month()),
														Quarter_Text__c = ''+GCFUtil.getQuarter(startDate.month()),
														Region__c = 'North America',
														Revenue_Type__c = 'Incremental Revenue',
														Offering_Type__c = 'PureEngage',
														Incremental_R__c = 1000.0,
														Incremental_E__c = 1000.0,
			                							Incremental_U__c = 1000.0,
			                							Incremental_TIV__c = 3000.0
														));
			forecastingData.add(new GCF_Data__c(CurrencyIsoCode = 'USD',
														Year__c = startDate.year(),
														Year_Text__c = ''+startDate.year(),
														Month__c = startDate.month(),
														Month_Text__c = ''+startDate.month(),
														Quarter__c = GCFUtil.getQuarter(startDate.month()),
														Quarter_Text__c = ''+GCFUtil.getQuarter(startDate.month()),
														Region__c = 'North America',
														Revenue_Type__c = 'First Year Maintenance',
                                                		Offering_Type__c = 'PureEngage',
														FYM_R__c = 1000.0,
			                							FYM_U__c = 1000.0,
			                							FYM_TIV__c = 3000.0
														));		
			forecastingReportData.add(new GCF_Report_Data__c(CurrencyIsoCode = 'USD',
														Year__c = startDate.year(),
														Year_Text__c = ''+startDate.year(),
														Month__c = startDate.month(),
														Month_Text__c = ''+startDate.month(),
														Quarter__c = GCFUtil.getQuarter(startDate.month()),
														Quarter_Text__c = ''+GCFUtil.getQuarter(startDate.month()),
														Region__c = 'North America',
														Revenue_Type__c = 'First Year Maintenance',
														Offering_Type__c = 'PureEngage',
														FYM_R__c = 1000.0,
			                							FYM_U__c = 1000.0,
			                							FYM_TIV__c = 3000.0
														));																										
			forecastingData.add(new GCF_Data__c(CurrencyIsoCode = 'USD',
														Year__c = startDate.year(),
														Year_Text__c = ''+startDate.year(),
														Month__c = startDate.month(),
														Month_Text__c = ''+startDate.month(),
														Quarter__c = GCFUtil.getQuarter(startDate.month()),
														Quarter_Text__c = ''+GCFUtil.getQuarter(startDate.month()),
														Region__c = 'North America',
														Revenue_Type__c = 'Billing Plan',
                                                		Offering_Type__c = 'PureEngage',
														BillingPlan_R__c = 1000.0,
			                							BillingPlan_E__c = 1000.0,
			                							BillingPlan_TIV__c = 3000.0
														));
			forecastingReportData.add(new GCF_Report_Data__c(CurrencyIsoCode = 'USD',
														Year__c = startDate.year(),
														Year_Text__c = ''+startDate.year(),
														Month__c = startDate.month(),
														Month_Text__c = ''+startDate.month(),
														Quarter__c = GCFUtil.getQuarter(startDate.month()),
														Quarter_Text__c = ''+GCFUtil.getQuarter(startDate.month()),
														Region__c = 'North America',
														Revenue_Type__c = 'Billing Plan',
                                                        Offering_Type__c = 'PureEngage',     
														BillingPlan_R__c = 1000.0,
			                							BillingPlan_E__c = 1000.0,
			                							BillingPlan_TIV__c = 3000.0
														));														
			forecastingData.add(new GCF_Data__c(CurrencyIsoCode = 'USD',
														Year__c = startDate.year(),
														Year_Text__c = ''+startDate.year(),
														Month__c = startDate.month(),
														Month_Text__c = ''+startDate.month(),
														Quarter__c = GCFUtil.getQuarter(startDate.month()),
														Quarter_Text__c = ''+GCFUtil.getQuarter(startDate.month()),
														Region__c = 'North America',
														Revenue_Type__c = 'Total Booking Forecast',
                                                		Offering_Type__c = 'PureEngage',
														Total_Booking_Forecast_E__c = 1000.0,
			                							Total_Booking_Forecast_U__c = 1000.0
														));
			forecastingReportData.add(new GCF_Report_Data__c(CurrencyIsoCode = 'USD',
														Year__c = startDate.year(),
														Year_Text__c = ''+startDate.year(),
														Month__c = startDate.month(),
														Month_Text__c = ''+startDate.month(),
														Quarter__c = GCFUtil.getQuarter(startDate.month()),
														Quarter_Text__c = ''+GCFUtil.getQuarter(startDate.month()),
														Region__c = 'North America',
														Revenue_Type__c = 'Total Booking Forecast',
                                                        Offering_Type__c = 'PureEngage',
														Total_Booking_Forecast_E__c = 1000.0,
			                							Total_Booking_Forecast_U__c = 1000.0
														));														
			forecastingNetSuiteData.add(new GCF_NetSuite_Data__c(
                            	Revenue_Type__c = 'Deferred Revenue', Region__c = 'North America', CurrencyIsoCode = 'USD',
                            	Sold_To_Name__c = 'SOLDTO', Sold_To_GARN_Code__c = 'SOLDTOGARN',
                            	End_User_Name__c = 'ENDUSER', End_User_GARN_Code__c = 'ENDUSERGARN', Offering_Type__c = 'PureEngage',
                            	Posting_Date__c = startDate, Posting_Amount__c = 10000, Posting_Amount_USD__c = 10000, Posting_Amount_EUR__c = 9000, Invoice_Number__c = 'INV-001,INV-002', 
                            	Type__c = 'Invoice', PO_Number__c = 'PONUM', SO_Number__c = 'SONUM', Order_Number__c = 'ORDNUM', Quote_Number__c = 'QUOTE'+i));	
			                            											
			forecastingReportData.add(new GCF_Report_Data__c(CurrencyIsoCode = 'USD',
														Year__c = startDate.year(),
														Year_Text__c = ''+startDate.year(),
														Month__c = startDate.month(),
														Month_Text__c = ''+startDate.month(),
														Quarter__c = GCFUtil.getQuarter(startDate.month()),
														Quarter_Text__c = ''+GCFUtil.getQuarter(startDate.month()),
														Region__c = 'North America',
														Revenue_Type__c = 'Deferred Revenue',
                                                        Offering_Type__c = 'PureEngage',     
														Deferred__c = 1000.0
														));	
			forecastingReportData.add(new GCF_Report_Data__c(CurrencyIsoCode = 'USD',
														Year__c = startDate.year(),
														Year_Text__c = ''+startDate.year(),
														Month__c = startDate.month(),
														Month_Text__c = ''+startDate.month(),
														Quarter__c = GCFUtil.getQuarter(startDate.month()),
														Quarter_Text__c = ''+GCFUtil.getQuarter(startDate.month()),
														Region__c = 'North America',
														Revenue_Type__c = 'Recognized Revenue',
                                                        Offering_Type__c = 'PureEngage',     
														Deferred__c = 1000.0
														));																																												
		}
        Database.insert(forecastingData);
        Database.insert(forecastingNetSuiteData);
        Database.insert(forecastingReportData);
    }
}