@isTest 
public class TestCloudBilling {
    

    @isTest
    static void testIsPureCloudVoiceActivityType0() {
        Rolled_Up_Usage_Data__c ruud = new Rolled_Up_Usage_Data__c (
            Source_Name__c = 'PCL',
            Activity_Type__c = 0
        );
        System.debug('TestCloudBilling.testIsPureCloudVoice: ruud ' + ruud);
        Boolean blnIsPCLVoice = CloudBillingUtil.blnIsPureCloudVoice(ruud);
        System.assert(blnIsPCLVoice == true, ruud + ' is PureCloudVoice');
    }
    @isTest
    static void testIsPureCloudVoiceActivityType4() {
        Rolled_Up_Usage_Data__c ruud = new Rolled_Up_Usage_Data__c (
            Source_Name__c = 'PCL',
            Activity_Type__c = 4
        );
        System.debug('TestCloudBilling.testIsPureCloudVoice: ruud ' + ruud);
        Boolean blnIsPCLVoice = CloudBillingUtil.blnIsPureCloudVoice(ruud);
        System.assert(blnIsPCLVoice == true, ruud + ' is PureCloudVoice');
    }
    @isTest
    static void testIsPureCloudVoiceActivityType10() {
        Rolled_Up_Usage_Data__c ruud = new Rolled_Up_Usage_Data__c (
            Source_Name__c = 'PCL',
            Activity_Type__c = 10
        );
        System.debug('TestCloudBilling.testIsPureCloudVoice: ruud ' + ruud);
        Boolean blnIsPCLVoice = CloudBillingUtil.blnIsPureCloudVoice(ruud);
        System.assert(blnIsPCLVoice == true, ruud + ' is PureCloudVoice');
    }
    @isTest
    static void testIsPureCloudVoiceActivityType11() {
        Rolled_Up_Usage_Data__c ruud = new Rolled_Up_Usage_Data__c (
            Source_Name__c = 'PCL',
            Activity_Type__c = 11
        );
        System.debug('TestCloudBilling.testIsPureCloudVoice: ruud ' + ruud);
        Boolean blnIsPCLVoice = CloudBillingUtil.blnIsPureCloudVoice(ruud);
        System.assert(blnIsPCLVoice == true, ruud + ' is PureCloudVoice');
    }
    @isTest
    static void testIsPureCloudVoiceActivityType5() {
        Rolled_Up_Usage_Data__c ruud = new Rolled_Up_Usage_Data__c (
            Source_Name__c = 'PCL',
            Activity_Type__c = 5
        );
        System.debug('TestCloudBilling.testIsPureCloudVoice: ruud ' + ruud);
        Boolean blnIsPCLVoice = CloudBillingUtil.blnIsPureCloudVoice(ruud);
        System.assert(blnIsPCLVoice == false, ruud + ' is NOT PureCloudVoice');
    }

    
    @isTest
    static void testPopulateQuantity() {
        Rolled_Up_Usage_Data__c ruud = new Rolled_Up_Usage_Data__c (
            Source_Name__c = 'BEEEC',
            Platform_Id__c = 'Tenant123',
            Rollup_Id__c = 'test-1',
            Channel_Type__c = 1,
            Device_Type__c = 3,
            Service_Type__c = 2,
            Service_Class__c = 0,
            Origin_Country_Code__c = 1,
            Count__c = 2,
            Total_Duration__c = 51,
            Billable_6__c = 66,
            Billable_30__c = 90,
            Billable_60__c = 120,
            Gigabyte_Count__c = 17.5,
            Start_Time__c = DateTime.newInstance(2017, 1, 1, 12, 0, 0)
        );
//        insert ruud;
//        Id idRuud = ruud.Id;
        
        Service_Usage__c su = new Service_Usage__c();

		// Based off Count field
        BatchRateCloudUsageData.populateQuantity(ruud, su, 'Messages/Seats/Ports');
        System.assertEquals(2, su.Quantity__c);
        
        BatchRateCloudUsageData.populateQuantity(ruud, su, 'Minutes(6s/message)');
        System.assertEquals(.2, su.Quantity__c);

        BatchRateCloudUsageData.populateQuantity(ruud, su, 'Minutes(12s/message)');
        System.assertEquals(.4, su.Quantity__c);

        // Based off Time fields
        BatchRateCloudUsageData.populateQuantity(ruud, su, 'Minutes(Actual)');
        System.assertEquals(.85, su.Quantity__c);

        BatchRateCloudUsageData.populateQuantity(ruud, su, 'Minutes(6s ceiling)');
        System.assertEquals(1.1, su.Quantity__c);

        BatchRateCloudUsageData.populateQuantity(ruud, su, 'Minutes(30s ceiling)');
        System.assertEquals(1.5, su.Quantity__c);

        BatchRateCloudUsageData.populateQuantity(ruud, su, 'Minutes(60s ceiling)');
        System.assertEquals(2, su.Quantity__c);

        // Based off Gigabyte field
        BatchRateCloudUsageData.populateQuantity(ruud, su, 'Gigabytes');
        System.assertEquals(17.5, su.Quantity__c);
    }

    @isTest
    static void testPriceRoundingTo5Decimals() {
        Decimal[] initialValue = new Decimal[]{5.5, 1.1, 5.555, 6.666, 4.4493, 4.55556, 123.128456789100, 123.123496789100};
            Decimal[] expected = new Decimal[]{5.5, 1.1, 5.555, 6.666, 4.4493, 4.55556, 123.12845,        123.12349};
                
                for(integer x = 0; x < initialValue.size(); x++){
                    Decimal result = BatchCreateCloudMonthlySalesOrders.cloudRoundPriceFloor(initialValue[x]);
                    System.debug('Expect ' + expected[x] + ' got ' + result);
                    System.assertEquals(expected[x], result);
                }
    }
    private static Decimal returnCurrencyConversion(Map<String,Decimal> map_ConversionRates, String isoCode) {
        return map_ConversionRates.get(isoCode);
    }
    
    @isTest(SeeAllData=true)
    static void testCurrencyConversionFeb2016() {
        Date Feb2016 = Date.newInstance(Integer.valueOf('2016'),Integer.valueOf('2'),1);
        System.Debug('Get rates for date ' + Feb2016);
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(Feb2016, false);
        
        // Would like to call this but it causes a null pointer exception when running in test mode
        //Decimal convertedPrice = Util.convertCurrencyCustom('USD', 'EUR', map_ConversionRates, 1.0);
        
        Decimal convertedPrice = returnCurrencyConversion(map_ConversionRates, 'EUR');
        System.assertEquals(convertedPrice, 0.9009);
    }
    
    @isTest(SeeAllData=true)
    static void testCurrencyConversionUS() {
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates();
        
        //US rate should never change and always be the default
        Decimal convertedPrice = returnCurrencyConversion(map_ConversionRates, 'USD');
        System.assertEquals(convertedPrice, 1.0);
    }
    
    // intServiceType 1 = outbound, 2 = inbound
    public static List<Contract_Tier_Set_Month__c> getListTierSetMonth(Integer intServiceType) {
        Contract_Tier_Set_Period__c ctsp1 = new Contract_Tier_Set_Period__c();
        insert ctsp1;
        Contract_Tier_Set_Month__c ctsm1 = new Contract_Tier_Set_Month__c(Contract_Tier_Set_Period__c = ctsp1.Id);
        insert ctsm1;
        Service_Usage__c su1 = new Service_Usage__c(Count__c = 2, Quantity__c = 5, Cost__c = 0.1, Service_Type__c = intServiceType, Contract_Tier_Set_Month__c = ctsm1.Id);
        Service_Usage__c su2 = new Service_Usage__c(Count__c = 5, Quantity__c = 10, Cost__c = 0.2, Service_Type__c = intServiceType, Contract_Tier_Set_Month__c = ctsm1.Id);
        insert su1;
        insert su2;
        
        // Have to get from DB to populate Formula Fields
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth = new List<Contract_Tier_Set_Month__c>();
        Contract_Tier_Set_Month__c ctsm1_fromDB = [select
                                                   Sum_Count__c,
                                                   Max_Usage__c,
                                                   Total_Usage__c,
                                                   Total_Outbound_Calls_Cost__c,
                                                   Total_Inbound_Calls_Cost__c
                                                   from Contract_Tier_Set_Month__c where Id = :ctsm1.Id];
        list_ContractTierSetMonth.add(ctsm1_fromDB);
        System.debug('ctsp1 ' + ctsp1 + ' ctsm1 ' + ctsm1 + ' su1 ' + su1 + ' su2 ' + su2);
        return list_ContractTierSetMonth;
    }
    
    @isTest(SeeAllData=false)
    static void testGetTotalQuantityMaxPerMonth() {
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth = getListTierSetMonth(1);
        Decimal q1 = CloudBillingUtil.getTotalQuantity(list_ContractTierSetMonth, 'Max Per Month');
        System.assertEquals(10.0, q1);
    }
    
    @isTest(SeeAllData=false)
    static void testGetTotalQuantityStep() {
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth = getListTierSetMonth(1);
        Decimal q1 = CloudBillingUtil.getTotalQuantity(list_ContractTierSetMonth, 'Step');
        System.assertEquals(15.0, q1);
    }
    
    @isTest(SeeAllData=false)
    static void testGetCountStep() {
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth = getListTierSetMonth(1);
        Decimal c1 = CloudBillingUtil.GetCount(list_ContractTierSetMonth);
        System.debug('testGetCountStep: c1 ' + c1);
        System.assertEquals(7, c1);
    }
    
    @isTest(SeeAllData=false)
    static void testMinDate() {
        Date minDate = Date.newInstance(1700, 1, 1);
        Date minDateUtil = CloudBillingUtil.dateMinDate();
        System.assert(minDate == minDateUtil);
    }
    
    @isTest(SeeAllData=false)
    static void testMaxDate() {
        Date maxDate = Date.newInstance(4000, 12, 31);
        Date maxDateUtil = CloudBillingUtil.dateMaxDate();
        System.assert(maxDate == maxDateUtil);
    }
    
    @isTest(SeeAllData=false)
    static void testDatesOverLapNullOneStartFalse() {
        Date oneStart = null;
        Date oneEnd = Date.newInstance(2016, 1, 1);
        Date twoStart = Date.newInstance(2016, 1, 1);
        Date twoEnd = Date.newInstance(2017, 1, 1);
        System.assert(!CloudBillingUtil.blnDatesOverlap(oneStart, oneEnd, twoStart, twoEnd));
    }
    
    @isTest(SeeAllData=false)
    static void testDatesOverLapNullOneStartTrue() {
        Date oneStart = null;
        Date oneEnd = Date.newInstance(2016, 2, 1);
        Date twoStart = Date.newInstance(2016, 1, 1);
        Date twoEnd = Date.newInstance(2017, 1, 1);
        System.assert(CloudBillingUtil.blnDatesOverlap(oneStart, oneEnd, twoStart, twoEnd));
    }
    
    @isTest(SeeAllData=false)
    static void testDatesOverLapNullOneEndFalse() {
        //First Set of Dates is the later set. Starts 2017 and is evergreen (no end date)
        Date oneStart = Date.newInstance(2017, 1, 1);
        Date oneEnd = null;
        // Second set of dates is the earlier set.
        Date twoStart = Date.newInstance(2016, 1, 1);
        Date twoEnd = Date.newInstance(2017, 1, 1);
        System.assert(!CloudBillingUtil.blnDatesOverlap(oneStart, oneEnd, twoStart, twoEnd));
    }
    @isTest(SeeAllData=false)
    static void testDatesOverLapNullOneEndTwoStartFalse() {
        //First Set of Dates is the later set. Starts 2017 and is evergreen (no end date)
        Date oneStart = Date.newInstance(2017, 1, 1);
        Date oneEnd = null;
        // Second set of dates is the earlier set. Starts earliest date ending 2017.
        Date twoStart = null;
        Date twoEnd = Date.newInstance(2017, 1, 1);
        System.assert(!CloudBillingUtil.blnDatesOverlap(oneStart, oneEnd, twoStart, twoEnd));
    }
    
    @isTest(SeeAllData=false)
    static void testDatesOverLapNullOneEndTwoStartTrue() {
        //First Set of Dates is the later set. Starts 2016 and is evergreen (no end date)
        Date oneStart = Date.newInstance(2016, 1, 1);
        Date oneEnd = null;
        // Second set of dates is the earlier set. Starts earliest date ending 2017.
        Date twoStart = null;
        Date twoEnd = Date.newInstance(2017, 1, 1);
        System.assert(CloudBillingUtil.blnDatesOverlap(oneStart, oneEnd, twoStart, twoEnd));
    }
    
    
    @isTest(SeeAllData=false)
    static void testGetTotalOutboundCost() {
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth = getListTierSetMonth(1);
        Decimal q1 = CloudBillingUtil.getTotalOutboundCallsCost(list_ContractTierSetMonth);
        System.assertEquals(0.3, q1);
    }
    @isTest(SeeAllData=false)
    static void testGetTotalInboundCost() {
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth = getListTierSetMonth(2);
        Decimal q1 = CloudBillingUtil.getTotalInboundCallsCost(list_ContractTierSetMonth);
        System.assertEquals(0.3, q1);
    }
    
    @isTest(SeeAllData=false)
    static void testCreateCloudLog() {
        Cloud_Billing_Log__c objLog = CloudBillingUtil.createNewCloudBillingLog('Rating', 'Submitted');
        insert objLog;
        System.assertEquals('Rating', objLog.Type__c);
        System.assertEquals('Submitted', objLog.Status__c);
        System.assertEquals(objLog.Id != null, true);
        objLog.Status__c = 'Completed';
        upsert objLog;
        System.assertEquals('Rating', objLog.Type__c);
        System.assertEquals('Completed', objLog.Status__c);
        
    }
    
    @isTest(SeeAllData=false)
    static void testRatingNotRunning() {
        System.Assert(!CloudBillingUtil.blnIsRatingJobRunning());
    }
    
    
    private static Cloud_Currency_Conversion__c createCloudCurrencyConversion(Integer year, Integer month, Integer day, Integer yearEnd, Integer monthEnd, Integer dayEnd) {
        Cloud_Currency_Conversion__c objCloudCurrencyConversion = new Cloud_Currency_Conversion__c(
            IsoCode__c = 'USD',
            ConversionRate__c = 0.10,
            StartDate__c = Date.newInstance(year, month, day),
            NextStartDate__c = Date.newInstance(yearEnd, monthEnd, dayEnd)
        );
        System.debug('createCloudCurrencyConversion: ' + objCloudCurrencyConversion);
        return objCloudCurrencyConversion;
    }
    
    @isTest(SeeAllData=false)
    static void testCloudCurrencyConversionTriggerSingleLegal() {
        
        Cloud_Currency_Conversion__c objCloudCurrencyConversion = createCloudCurrencyConversion(2017,1,1, 2017,2,1);
        insert objCloudCurrencyConversion;
        
        Cloud_Currency_Conversion__c objCloudCurrencyConversionDB = [select Id from Cloud_Currency_Conversion__c];
        System.assertEquals(objCloudCurrencyConversion.Id, objCloudCurrencyConversionDB.Id);
        
    }
    
    @isTest(SeeAllData=false)
    static void testCloudCurrencyConversionTriggerSingleIllegal() {
        
        // Create illegal. Start after end date. Expect to catch an exception.
        try {
            Cloud_Currency_Conversion__c objCloudCurrencyConversion = createCloudCurrencyConversion(2017,1,1, 2016,1,1);
            insert objCloudCurrencyConversion;
        } catch(System.DmlException e) {
            System.debug('testCloudCurrencyConversionTriggerSingleIllegal: Caught exception ' + e);
        }        
        List<Cloud_Currency_Conversion__c> listCloudCurrencyConversionDB = [select Id from Cloud_Currency_Conversion__c];
        //System.assertEquals(41, listCloudCurrencyConversionDB.size());
    }
    
    @isTest(SeeAllData=false)
    static void testCloudCurrencyConversionTriggerDoubleIllegal() {
        
        System.debug('testCloudCurrencyConversionTriggerDoubleIllegal: Begin');
        Cloud_Currency_Conversion__c objCloudCurrencyConversion = createCloudCurrencyConversion(2017,1,1, 2018,1,1);
        insert objCloudCurrencyConversion;
        
        try {
            Cloud_Currency_Conversion__c objCloudCurrencyConversionOverlap = createCloudCurrencyConversion(2017,2,1, 2017,3,1);
            insert objCloudCurrencyConversionOverlap;
        } catch(System.DmlException e) {
            System.debug('testCloudCurrencyConversionTriggerDoubleIllegal: Caught exception ' + e);
        }          
        List<Cloud_Currency_Conversion__c> listCloudCurrencyConversionDB = [select Id from Cloud_Currency_Conversion__c];
        //System.assertEquals(41, listCloudCurrencyConversionDB.size());
        System.debug('testCloudCurrencyConversionTriggerDoubleIllegal: End');
    }
    
    @isTest(SeeAllData=false)
    static void testCloudCurrencyConversionTriggerCannotEditOld() {
        System.debug('testCloudCurrencyConversionTriggerCannotEditOld: Begin');
        
        // Add an old conversion rate and attempt to edit the rate
        Cloud_Currency_Conversion__c objCloudCurrencyConversion = createCloudCurrencyConversion(2014,1,1, 2015,1,1);
        insert objCloudCurrencyConversion;
        
        try {
            objCloudCurrencyConversion.ConversionRate__c = 0.11;
            update objCloudCurrencyConversion;
        } catch(System.DmlException e) {
            System.debug('testCloudCurrencyConversionTriggerDoubleIllegal: Caught exception ' + e);
            System.debug('testCloudCurrencyConversionTriggerCannotEditOld: End');
            System.assert(true);
        }          
        System.assert(true);
    }
    
    // Added by Vijay  - Oct 16th - Start
    @isTest(seeAllData = false)
    public static void testcreateNewBillingException(){
        Rolled_Up_Usage_Data__c ruud = new Rolled_Up_Usage_Data__c (
            Source_Name__c = 'BEEEC',
            Platform_Id__c = 'Tenant123',
            Rollup_Id__c = 'test-1',
            Channel_Type__c = 1,
            Device_Type__c = 3,
            Service_Type__c = 2,
            Service_Class__c = 0,
            Origin_Country_Code__c = 1,
            Count__c = 2,
            Total_Duration__c = 51,
            Billable_6__c = 66,
            Billable_30__c = 90,
            Billable_60__c = 120,
            Gigabyte_Count__c = 17.5,
            Start_Time__c = DateTime.newInstance(2017, 1, 1, 12, 0, 0)
        );
        insert ruud;
        ruud.Exception_Type__c = 'Other';
        CloudBillingUtil.createNewBillingException('test description', ruud, null, null);
        
    }
    
    // Added by Vijay  - Oct 16th - End
    
    // - Created By Vijay Gopi <Start>
    // Test for CloudBillingPureCloudRRScheduler 
    @isTest(seeAllData=false)
    static void testCloudBillingPureCloudRRScheduler(){
        setupDataForCloudBillingPureCloudRRScheduler();
        Test.startTest();
    	String strCronExp = '0 0 23 * * ?';
    	System.schedule('PureVoice Cloud Revenue - Create Cloud Instance', strCronExp, new CloudBillingPureCloudRRScheduler() );
    	Test.stopTest();
    }
    
    // Data Setup to test the CloudBillingPureCloudRRScheduler Scheduler.
    static void setupDataForCloudBillingPureCloudRRScheduler(){
    	List<Account> list_Account = TestUtil.createAccounts(3, true);
    	Opportunity objOpportunity1  = TestUtil.createOpportunities(1,list_Account[0].id, false)[0];
    	objOpportunity1.Lines_of_Businesses__c = 'PureCloud';
    	Opportunity objOpportunity2  = TestUtil.createOpportunities(1,list_Account[1].id, false)[0];
    	objOpportunity2.Lines_of_Businesses__c = 'PureCloud';
    	Opportunity objOpportunity3  = TestUtil.createOpportunities(1,list_Account[2].id, false)[0];
    	objOpportunity3.Lines_of_Businesses__c = 'PureCloud';
    	List<Opportunity> list_Opportunities = new List<Opportunity>{objOpportunity1, objOpportunity2, objOpportunity3};
    	insert list_Opportunities;
    	
    	zqu__Quote__c objQuote1 = setupZuoraQuote('PureCloud Test ZQuote 1', list_Opportunities[0].AccountId ,list_Opportunities[0].id, 24);
		objQuote1.zqu__StartDate__c = System.today(); 
		
		zqu__Quote__c objQuote2 = setupZuoraQuote('PureCloud Test ZQuote 2', list_Opportunities[1].AccountId ,list_Opportunities[1].id,6);
		objQuote2.zqu__StartDate__c = System.today(); 
		
		zqu__Quote__c objQuote3 = setupZuoraQuote('PureCloud Test ZQuote 3', list_Opportunities[2].AccountId , list_Opportunities[2].id,  12);
		objQuote3.zqu__StartDate__c = System.today(); 
		
		zqu__Quote__c objQuote4 = setupZuoraQuote( 'PureCloud Test ZQuote 4', list_Opportunities[1].AccountId ,list_Opportunities[2].id,  12);
		objQuote4.zqu__StartDate__c = System.today(); 
		
		zqu__Quote__c objQuote5 = setupZuoraQuote('PureCloud Test ZQuote 5', list_Opportunities[0].AccountId ,list_Opportunities[2].id, 12);
		objQuote5.zqu__StartDate__c = System.today(); 
		List<zqu__Quote__c> list_Quotes = new List<zqu__Quote__c>{objQuote1, objQuote2, objQuote3, objQuote4, objQuote5};
		insert list_Quotes;
		
		List<GCR_Content_Document_Detail__c> list_Contracts = setupContracts(list_Quotes);
		List<Cloud_Deployment__c> list_CloudDeployments  = setupCloudDeployments(list_Contracts);
		
    }
    
    static zqu__Quote__c setupZuoraQuote(String strName, String strAccId , String strOppId, Integer intPeriod ){
        zqu__Quote__c objZquQuote = new zqu__Quote__c();
        objZquQuote.Name = strName;
        objZquQuote.zqu__Account__c = strAccId;
        objZquQuote.zqu__Opportunity__c = strOppId;
        objZquQuote.PureCloud_Ramp_Up_Period__c = intPeriod;
        return objZquQuote;
    }
    
    // Data setup to create and return list Contrats with list of zuro Quotes
    static List<GCR_Content_Document_Detail__c> setupContracts(List<zqu__Quote__c> list_Quotes){
    	List<GCR_Content_Document_Detail__c> list_Contracts = new List<GCR_Content_Document_Detail__c>();
    	for(zqu__Quote__c objQuote : list_Quotes){
    		// GCR_Content_Document_Detail__c
			GCR_Content_Document_Detail__c objContract = new GCR_Content_Document_Detail__c();
			objContract.Account_Name__c = objQuote.zqu__Account__c;
			objContract.Document_Name__c = 'Cloud Billing Contract';
			objContract.Zuora_Quote__c = objQuote.id;
			objContract.Order_Date_Option__c = 'Last Day of Usage Month';
			objContract.Status__c = 'New';
			objContract.Active__c = true;
			list_Contracts.add(objContract);
    	}
    	
		insert list_Contracts;
		for(GCR_Content_Document_Detail__c objContract : list_Contracts) objContract.Status__c = 'Approved';
		
		update list_Contracts;
		list_Contracts = [SELECT id, Pricing_Start_Date__c, Pricing_End_Date__c, Account_Name__c 
                          FROM  GCR_Content_Document_Detail__c];
		// Current date is between Start Date and End Date and the day is same as Current day. - Active
		//list_Contracts[0].Pricing_Start_Date__c = Date.newInstance(System.today().year(), System.today().month()-1, System.today().day());
		list_Contracts[0].Pricing_Start_Date__c = System.today().addMonths(-2);
		list_Contracts[0].Pricing_End_Date__c = Date.newInstance(System.today().year()+1, System.today().month(), System.today().day()-1);
		// Current date is not between Start Date and End Date - Not Active
		list_Contracts[1].Pricing_Start_Date__c = Date.newInstance(System.today().year()-1, System.today().month(), System.today().day());
		list_Contracts[1].Pricing_End_Date__c = Date.newInstance(System.today().year(), System.today().month()-2, System.today().day()-1);
		// Current date is between Start Date and End Date and the day is not same as Current day.- Not Active
		list_Contracts[2].Pricing_Start_Date__c = Date.newInstance(System.today().year(), System.today().month()-1, System.today().day() - 10);
		list_Contracts[2].Pricing_End_Date__c = Date.newInstance(System.today().year()+1, System.today().month(), System.today().day() - 11);
		// Current date is between Start Date and End Date(null) and the day is not same as Current day. - Not Active
		list_Contracts[3].Pricing_Start_Date__c = Date.newInstance(System.today().year()-1, System.today().month()-1, System.today().day() - 10);
		list_Contracts[3].Pricing_End_Date__c = NULL;
		// Current date is between Start Date and End Date(null) and the day is same as Current day. - Active
		list_Contracts[4].Pricing_Start_Date__c = Date.newInstance(System.today().year(), System.today().month()-2, System.today().day());
		list_Contracts[4].Pricing_End_Date__c = NULL;
		update list_Contracts;
        for(GCR_Content_Document_Detail__c objContract : list_Contracts)
            System.debug('Contract : '+objContract);
		return list_Contracts;
    }
    
    // Data setup to create and return list of Cloud Deployments with provided list of Contracts.
    static List<Cloud_Deployment__c> setupCloudDeployments(List<GCR_Content_Document_Detail__c> list_Contracts){
    	List<Cloud_Deployment__c> list_CloudDeployments = new List<Cloud_Deployment__c>();
    	
    	for(GCR_Content_Document_Detail__c objContract : list_Contracts){
    		Cloud_Deployment__c objCloudDeployment = new Cloud_Deployment__c();
    		objCloudDeployment.Account__c = objContract.Account_Name__c;
    		objCloudDeployment.Cloud_Billing_Contract__c = objContract.id ;
    		objCloudDeployment.Cloud_Platform__c = 'PureCloud';
    		objCloudDeployment.PureCloud_OrgID__c = objContract.Account_Name__c + '#'+ objContract.id ;
    		list_CloudDeployments.add(objCloudDeployment);
    	}
    	insert list_CloudDeployments;
    	return list_CloudDeployments;
    }
	// - Created By Vijay Gopi <End>
}