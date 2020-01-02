@isTest
public class CloudBillingUtilTest {
    
    
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
    static void testCurrencyConversionFeb2016Old() {
        Date Feb2016 = Date.newInstance(Integer.valueOf('2016'),Integer.valueOf('2'),1);
        System.Debug('Get rates for date ' + Feb2016);
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(Feb2016, false);
        
        // Would like to call this but it causes a null pointer exception when running in test mode
        //Decimal convertedPrice = Util.convertCurrencyCustom('USD', 'EUR', map_ConversionRates, 1.0);
        
        Decimal convertedPrice = returnCurrencyConversion(map_ConversionRates, 'EUR');
        System.assertEquals(convertedPrice, 0.9009);
    }
    
    @isTest(SeeAllData=false)
    static void testCurrencyConversionAprilThree2017New() {
        Date dtStartDt = Date.newInstance(2017,4,3);
        Date dtEndDt = Date.newInstance(2017,5,2);
        Billing_Conversion_Rate__c objRate = new Billing_Conversion_Rate__c(
            To_Currency_Code__c	= 'CAD',
            Average_Conversion_Rate__c = 1.345,
            From_Date__c = dtStartDt,
            To_Date__c = dtEndDt
        );
        insert objRate;
        Date AprilThree2017 = Date.newInstance(2017,4,3);
        System.Debug('Get rates for date ' + AprilThree2017);
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates(AprilThree2017, true);
        
        // Would like to call this but it causes a null pointer exception when running in test mode
        //Decimal convertedPrice = Util.convertCurrencyCustom('USD', 'EUR', map_ConversionRates, 1.0);
        
        Decimal convertedPrice = returnCurrencyConversion(map_ConversionRates, 'CAD');
        System.assertEquals(convertedPrice, 1.345);
    }
    
    
    @isTest(SeeAllData=true)
    static void testCurrencyConversionUS() {
        Map<String,Decimal> map_ConversionRates = CloudBillingUtil.getCurrencyConversionRates();
        
        //US rate should never change and always be the default
        Decimal convertedPrice = returnCurrencyConversion(map_ConversionRates, 'USD');
        System.assertEquals(convertedPrice, 1.0);
    }
    
    // intServiceType 1 = outbound, 2 = inbound
    private static List<Contract_Tier_Set_Month__c> getListTierSetMonth(Integer intServiceType) {
        Contract_Tier_Set_Period__c ctsp1 = new Contract_Tier_Set_Period__c();
        insert ctsp1;
        Contract_Tier_Set_Month__c ctsm1 = new Contract_Tier_Set_Month__c(Contract_Tier_Set_Period__c = ctsp1.Id);
        insert ctsm1;
        Service_Usage__c su1 = new Service_Usage__c(Count__c = 2, Quantity__c = 5, Cost__c = 0.1, Service_Type__c = intServiceType, Region_Code__c = 'US', Contract_Tier_Set_Month__c = ctsm1.Id);
        Service_Usage__c su2 = new Service_Usage__c(Count__c = 5, Quantity__c = 10, Cost__c = 0.2, Service_Type__c = intServiceType, Region_Code__c = 'EU', Contract_Tier_Set_Month__c = ctsm1.Id);
        Service_Usage__c su3 = new Service_Usage__c(Count__c = 3, Quantity__c = 3, Cost__c = 0, Service_Type__c = intServiceType, Region_Code__c = 'AP', Contract_Tier_Set_Month__c = ctsm1.Id);
        insert su1;
        insert su2;
        insert su3;
        
        // Have to get from DB to populate Formula Fields
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth = new List<Contract_Tier_Set_Month__c>();
        Contract_Tier_Set_Month__c ctsm1_fromDB = [select
                                                   Sum_Count__c,
                                                   Max_Usage__c,
                                                   Total_Usage__c,
                                                   Total_Outbound_Calls_Cost__c,
                                                   Total_Inbound_Calls_Cost__c,
                                                   Max_Usage_AP__c, Max_Usage_EU__c, Max_Usage_US__c ,
                                                   Sum_Usage__c 
                                                   from Contract_Tier_Set_Month__c where Id = :ctsm1.Id];
        list_ContractTierSetMonth.add(ctsm1_fromDB);
        System.debug('ctsp1 ' + ctsp1 + ' ctsm1 ' + ctsm1 + ' su1 ' + su1 + ' su2 ' + su2 + ' su3 ' + su3);
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
        System.assertEquals(18.0, q1);
    }
    
    @isTest(SeeAllData=false)
    static void testGetCountStep() {
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth = getListTierSetMonth(1);
        Decimal c1 = CloudBillingUtil.GetCount(list_ContractTierSetMonth);
        System.debug('testGetCountStep: c1 ' + c1);
        System.assertEquals(10, c1);
    }
    
    @isTest(SeeAllData=false)
    static void testQuantityZeroNullTierSetMonth() {
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth = null;
        Decimal c1 = CloudBillingUtil.getTotalQuantity(list_ContractTierSetMonth, 'Step');
        System.debug('testQuantityZeroNullTierSetMonth: c1 ' + c1);
        System.assertEquals(0, c1);
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
    static void testDatesOverLapNullOneEndNullTwoEndTrue() {
        Date oneStart = Date.newInstance(2016, 1, 1);
        Date oneEnd = null;
        Date twoStart = Date.newInstance(2017, 1, 1);
        Date twoEnd = null;
        System.assert(CloudBillingUtil.blnDatesOverlap(oneStart, oneEnd, twoStart, twoEnd));
    }
    
    @isTest(SeeAllData=false)
    static void testDatesOverLapOneEndEarlierOneStart() {
        Date oneStart = Date.newInstance(2017, 1, 1);
        Date oneEnd = Date.newInstance(2016, 1, 1);
        Date twoStart = null;
        Date twoEnd = null;
        System.assert(CloudBillingUtil.blnDatesOverlap(oneStart, oneEnd, twoStart, twoEnd));
    }
    
    @isTest(SeeAllData=false)
    static void testDatesOverLapTwoEndEarlierTwoStart() {
        Date oneStart = null;
        Date oneEnd = null;
        Date twoStart = Date.newInstance(2017, 1, 1);
        Date twoEnd = Date.newInstance(2016, 1, 1);
        System.assert(CloudBillingUtil.blnDatesOverlap(oneStart, oneEnd, twoStart, twoEnd));
    }
    
    
    @isTest(SeeAllData=false)
    static void testDatesOverLapAllNull() {
        //First Set of Dates is the later set. Starts 2016 and is evergreen (no end date)
        Date oneStart = null;
        Date oneEnd = null;
        // Second set of dates is the earlier set. Starts earliest date ending 2017.
        Date twoStart = null;
        Date twoEnd = null;
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
    
    @isTest
    public static void testIsPureCloudVoiceOverrideTrue(){
        Boolean bln = CloudBillingUtil.blnAllowRateOverride('PCC', 'PCL,PCC');
        System.assertEquals(true, bln);
    }
    @isTest
    public static void testIsPureCloudVoiceOverrideFalse(){
        Boolean bln = CloudBillingUtil.blnAllowRateOverride('PCC', 'BEEEC,Angel');
        System.assertEquals(false, bln);
    }
    
    @isTest
    public static void testGetSetOfStringsByCommaSeperated(){
        Set<String> setStrings = CloudBillingUtil.getSetOfStringsByCommaSeperated('PCL');
        System.assert(setStrings.size() == 1, 'Set String Size Not 1');
    }
    
    @isTest
    public static void testformatDateMMDDYYYY(){
        CloudBillingUtil.formatDateMMDDYYYY(Date.newInstance(8,8,2017));
    }
    
    
    private static testmethod void controllerTest7(){
        Test.startTest();
        BillingSearchContractController objBSCC = new BillingSearchContractController();
        objBSCC.objJobLog = new Cloud_Billing_Log__c();
        objBSCC.objJobLog.Month__c = '';
        objBSCC.runReportRequests();
        CloudBillingUtil.createNewCloudBillingLog('Reconcile Rollup Usage', 'Submitted');
        CloudBillingUtil.blnIsRatingJobRunning();
        objBSCC.createBillingContract();
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false)
    static void testGetTotalQuantitySumofMaxPerRegionPerMonth() {
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth = getListTierSetMonth(1);
        Decimal q1 = CloudBillingUtil.getTotalQuantity(list_ContractTierSetMonth, 'Sum of Max Per Region Per Month');
        q1 = CloudBillingUtil.getTotalQuantity(list_ContractTierSetMonth, 'Average');
    }
    
    
    static void setupData(){
        Util.Bypass_Trigger_Chk = true;
        /*
SureTax_Settings__c objSureTaxSetting = new SureTax_Settings__c(name = 'SureTaxEnabled' , value__c = 'false');
insert objSureTaxSetting;
*/
        Country__c objCountry = setupCountry();
        
        List<Account> list_Accounts = TestUtil.createAccounts(1, false);
        list_Accounts[0].SAP_Account_Code__c = 'GARNTest';
        list_Accounts[0].country__c =objCountry.id;
        insert list_Accounts;
        
        
        List<Contact> list_Contacts = TestUtil.createContacts(5, list_Accounts[0], true);
        
        
        
        Opportunity objOpportunity  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
        objOpportunity.StageName = '1.Understand Needs';
        insert objOpportunity;
        /*
SourceOpportunity__c objSO = new SourceOpportunity__c(Business_Champion__c = list_Contacts[0].Id,
Contact_Center_Admin__c = list_Contacts[1].Id,
Customer_Project_Manager__c = list_Contacts[2].Id,
Infrastructure_Expert__c = list_Contacts[3].Id,
PureCloud_Administrator__c = list_Contacts[4].Id,
Enablement_Partner__c = list_Accounts[0].id,
Opportunity__c = objOpportunity.Id);
insert objSO;
*/
        objOpportunity.Lines_of_Businesses__c = 'PureConnect';
        objOpportunity.Country__c = objCountry.Id;
        update objOpportunity;
        
        zqu__Quote__c objQuote = BatchCreateCloudMonthlySalesOrdersTest.setupZuoraQuote(
            'PureCloud Test ZQuote 1', objOpportunity.AccountId ,objOpportunity.id, 24);
        objQuote.zqu__StartDate__c = System.today()- 730; 
        objQuote.zqu__Currency__c = 'USD';
        insert objQuote;
        
        Genesys_Entity__c objGenEntity = BatchCreateCloudMonthlySalesOrdersTest.setupGenesysEntity();
        GCR_Content_Document_Detail__c objContract = BatchCreateCloudMonthlySalesOrdersTest.setupContractsZ(objQuote);
        objContract.Genesys_Entity__c = objGenEntity.id;
        objContract.Status__c = 'Approved';
        
        insert objContract;
        
        List<Product2> list_Products = TestUtil.createProducts(5, false);
        for(integer i = 0 ; i < list_Products.size() ; i++){
            list_Products[i].APN_Number__c = 'APNABC'+i;
            list_Products[i].Unit_of_Measure__c = 'Per Month';
        }
        insert list_Products;
        
        Order__c objOrder = setupOrder(objContract);
        objOrder.Order_Date__c = System.today();
        objOrder.CurrencyIsoCode = 'USD';
        insert objOrder;
        
        List<Contract_Tier_Set__c> list_ContractTS = setupTierSets(objContract.id , list_Products);
        insert list_ContractTS;
        
        List<Service__c> list_services = setupContractServices();
        
        List<Contract_Service__c> list_ContractServices = setupContractServices(list_services,list_ContractTS[0]);
        
        List<Contract_Tier_Set_Period__c> list_CTSP = setupContractTierSetPeriod(list_ContractTS);
        
        Cloud_Deployment__c obj_CdPCC = CloudBillingTestUtil.setupCloudDeploymentPureConnectAndJunction(objContract);
        Cloud_Deployment__c obj_CdPCL = CloudBillingTestUtil.setupCloudDeploymentPureCloudAndJunction(objContract);
        Cloud_Deployment__c obj_CdBEEEC = CloudBillingTestUtil.setupCloudDeploymentPureEngageAndJunction(objContract);
        Cloud_Deployment__c obj_CdPremier = CloudBillingTestUtil.setupCloudDeploymentPremierAndJunction(objContract);
        Cloud_Deployment__c obj_CdPortico = CloudBillingTestUtil.setupCloudDeploymentPorticoAndJunction(objContract);
        
        //Cloud_Deployment_To_Contract_Junction__c objCDTCJ = setupCloudDeploymentToContractJunction(objContract,obj_CDs);
        
        List<Rolled_Up_Usage_Data__c> list_RUUD = new List<Rolled_Up_Usage_Data__c>();
        for(integer i = 0 ; i < 3 ; i++){
            list_RUUD.add(new Rolled_Up_Usage_Data__c (
                Source_Name__c = 'PCC',
                Platform_Id__c = 'Tenant123',
                Rollup_Id__c = 'test-1',
                Channel_Type__c = 1,
                Device_Type__c = 3,
                Destination_Country_Code_ISO__c  = 'US',
                Destination_Country_Code__c = 1,
                Device_Steering_Digits__c = 'test',
                Service_Type__c = 1,
                Service_Class__c = 0,
                Origin_Country_Code__c = 1,
                Billable_6__c = 66,
                Billable_30__c = 90,
                Billable_60__c = 120,
                Start_Time__c = DateTime.newInstance(2017, 1, 1, 12, 0, 0),
                End_Time__c = DateTime.newInstance(2017, 12, 1, 12, 0, 0),
                Inbound_Device__c = 'HAIRPIN',
                GARN_Account_Code__c = 'GARNTest',
                Region_Code__c  = 'US',
                Destination_Device_Career__c = 'test',
                Processed__c = false,
                Rate__c = 12,
                Total_Duration__c = 345.6,
                Usage_Type__c = 3
            ));
        }
        insert list_RUUD;
        
        
        List<Calling_Rate__c> list_CallingRates = new List<Calling_Rate__c>();
        for(integer i = 0 ; i < 3 ; i++){
            list_CallingRates.add(new Calling_Rate__c(
                Region_Code__c = 'US',
                Destination_Country_Code__c = '1',
                Destination_Career_Digits__c = 'test',
                Destination_Description__c = 'United States - Contiguous',
                Rate_Per_Minute__c = 0.0400,
                Effective_End_Date__c = Date.newInstance(2017, 1, 2) ,
                Effective_Start_Date__c = Date.newInstance(2016, 12, 20),
                RecordTypeId = '0120B000000Qwgf' 
            ));
        }
        insert list_CallingRates;
        
        list_CallingRates = new List<Calling_Rate__c>();
        for(integer i = 0 ; i < 3 ; i++){
            list_CallingRates.add(new Calling_Rate__c(
                Region_Code__c = 'US',
                Destination_Country_Code__c = '1',
                Destination_Career_Digits__c = 'test',
                Carrier_Name__c = 'default' ,
                Destination_Description__c = 'United States - Contiguous',
                Rate_Per_Minute__c = 0.0400,
                Effective_End_Date__c = Date.Today().addYears(1),
                Effective_Start_Date__c = Date.Today().addYears(-1),
                RecordTypeId = '0120B000000Qwga' 
            ));
        }
        insert list_CallingRates;
        
        List<Inbound_Calling_Rate__c> list_ICRs = new List<Inbound_Calling_Rate__c>();
        
        for(integer i = 0 ; i<3 ; i++){
            list_ICRs.add(new Inbound_Calling_Rate__c(Effective_Start_Date__c = date.newInstance(2016, 12, 01) , 
                                                      Effective_End_Date__c = date.newInstance(2017, 2, 01) ,
                                                      Rate_Wireline__c = 5 , Rate_Wireless__c = 5 , Flat_Rate__c = 10,
                                                      Account__c = list_Accounts[0].Id , Hairpin_Number__c = 'HAIRPIN',
                                                      Region__c = 'US'));
        }
        insert list_ICRs;
        
        List<id> list_ids = new List<id>();
        for(Contract_Tier_Set__c objCTS : list_ContractTS ){
            list_ids.add(objCTS.id);
            Contract_Tier_Set_Period__c ctsp1 = new Contract_Tier_Set_Period__c();
            insert ctsp1;
            Contract_Tier_Set_Month__c ctsm1 = new Contract_Tier_Set_Month__c(Contract_Tier_Set_Period__c = ctsp1.Id , Contract_Tier_Set__c = objCTS.id, 
                                                                              Month__c = '6' , Year__c = '2017');
            insert ctsm1;
            Service_Usage__c su1 = new Service_Usage__c(Count__c = 2, Quantity__c = 5, Cost__c = 0.1, Service_Type__c = 1, Contract_Tier_Set_Month__c = ctsm1.Id);
            Service_Usage__c su2 = new Service_Usage__c(Count__c = 5, Quantity__c = 10, Cost__c = 0.2, Service_Type__c = 2, Contract_Tier_Set_Month__c = ctsm1.Id);
            insert su1;
            insert su2;
        }
        // Have to get from DB to populate Formula Fields
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonth = [SELECT id,
                                                                      Sum_Count__c,
                                                                      Max_Usage__c,
                                                                      Total_Usage__c,
                                                                      Total_Outbound_Calls_Cost__c,
                                                                      Total_Inbound_Calls_Cost__c, Contract_Tier_Set__c
                                                                      FROM Contract_Tier_Set_Month__c WHERE Contract_Tier_Set__c = :list_ids];
        
        
    }
    @isTest(seeallData=true)
    static void testResetServiceInfoFromQuotePureConnect(){
        //setupData();
        Custom_Access_Settings__c objCustomSetting = new Custom_Access_Settings__c(Id = Custom_Access_Settings__c.getInstance(UserInfo.getProfileId()).Id, 
                                                                                   Can_Bypass_Triggers__c = true);
        update objCustomSetting;
        
        
        List<zqu__QuoteRatePlanCharge__c> list_QRP = [SELECT Id, zqu__QuoteRatePlan__r.zqu__Quote__c
                                                      FROM zqu__QuoteRatePlanCharge__c WHERE  zqu__QuoteRatePlan__r.zqu__Quote__c != NULL LIMIT 5];
        
        Set<Id> set_ZQuoteIds = new Set<ID>();
        
        for(zqu__QuoteRatePlanCharge__c objQP : list_QRP){
            set_ZQuoteIds.add(objQP.zqu__QuoteRatePlan__r.zqu__Quote__c);
        }
        
        List<GCR_Content_Document_Detail__c> listContracts = 
            [SELECT Id, Name, GCR__r.Opportunity__c, Status__c,Outbound_Billing_Type__c, Outbound_Rate_Table_Discount__c, Inbound_Billing_Type__c,
             Expiration_Renewal_Date__c,Genesys_Entity__c,Invoice_Type__c,Invoice_Delivery_Type__c,
             Manual_Review_Required__c,Manual_Review_Reason__c,Approved__c,Sold_To_Name_Formula__c, 
             Product_Group__c,Service_Level_Agreement__c,Pricing_Start_Date__c,Pricing_End_Date__c,Reviewed__c,Status_Notes__c,
             
             Quote__r.Sold_To_Name__c, Quote__r.Sold_To_Name__r.SAP_Account_Code__c,Quote__r.BigMachines__Opportunity__r.Direct_Sales__c,
             Quote__c,Quote__r.BigMachines__Description__c,Quote__r.Special_Offer_Terms__c,Quote__r.Legal_Terms__c,
             Quote__r.Pricing_Model__c,Quote__r.Billing_Period__c,Quote__r.CurrencyISOCode,Quote__r.Order_Payment_Terms__c,
             Quote__r.Opportunity_Offering_Type__c,Quote__r.Offering_Type__c,
             
             
             Zuora_Quote__c, Zuora_Quote__r.zqu__Opportunity__r.BusinessPartner__c, Zuora_Quote__r.zqu__Opportunity__r.BusinessPartner__r.SAP_Account_Code__c, 
             Zuora_Quote__r.zqu__Opportunity__r.Direct_Sales__c, Zuora_Quote__r.CurrencyISOCode, Zuora_Quote__r.Order_Payment_Terms__c,
             Zuora_Quote__r.zqu__PaymentTerm__c,Zuora_Quote__r.zqu__Terms__c,Zuora_Quote__r.zqu__Currency__c,
             Zuora_Quote__r.zqu__Opportunity__r.Lines_of_Businesses__c, Zuora_Quote__r.zqu__Account__c, 
             
             Account_Name__c,Account_Name__r.Name,Account_Name__r.OwnerId,Account_Name__r.Country__r.Region__c, Contract_Type__c,
             Account_Name__r.SAP_Account_Code__c,Account_Name__r.Subsidary__c,Direct_Sales_Rep_Override__c, 
             Override_Invoice_Footer__c,Invoice_Footer_Text__c,Order_Date_Option__c, Net_Days_Override__c,Account_Name_Override__c,
             PO__c,PO_Start_Date__c,PO_End_Date__c,PO_Adjustment_Description__c,PO_Starting_Balance__c,PO_Remaining_Balance__c,   
             Name__c,       
             (SELECT Id FROM Cloud_Billing_Exceptions__r WHERE Resolved__c = false LIMIT 1)
             FROM GCR_Content_Document_Detail__c 
             WHERE  Id in ('a7hU0000000Xa7KIAS', // PureEngage
                           'a7h0B0000008dbhQAA', // PureConnect
                           'a7h0B0000008dvbQAA'  //PureCloud
                          )
             //AND Contract_Type__c != 'Cloud Billing - Telco'
            ];
        
        for (GCR_Content_Document_Detail__c objContract : listContracts) {
            if(objContract.Zuora_Quote__c != NULL ){
                zqu__Quote__c objQuote = [SELECT Id, zqu__Opportunity__r.BusinessPartner__c, zqu__Opportunity__r.BusinessPartner__r.SAP_Account_Code__c
                                          FROM zqu__Quote__c WHERE Id = :objContract.Zuora_Quote__c];
                
                TestDataFactoryForQuoteTool.setupQuoteRatePlanCharges(objQuote, true);
                CloudBillingTestUtil.setupZuoraQuoteChargeDetails(objContract.Zuora_Quote__c);
            }else{
                
            }
            //Test.startTest();
            System.Debug('CloudBillingTest.testResetServiceInfoFromQuote contract ' + objContract);
            CloudBillingUtil.resetServiceInfoFromQuote(objContract,'PureConnect');
            //Test.stopTest();
        }
    }
    
    //
    @isTest(seeallData=true)
    static void testResetServiceInfoFromQuotePureEngageSubscription(){
        //setupData();
        Custom_Access_Settings__c objCustomSetting = new Custom_Access_Settings__c(Id = Custom_Access_Settings__c.getInstance(UserInfo.getProfileId()).Id, 
                                                                                   Can_Bypass_Triggers__c = true);
        update objCustomSetting;
        
        
        List<zqu__QuoteRatePlanCharge__c> list_QRP = [SELECT Id, zqu__QuoteRatePlan__r.zqu__Quote__c
                                                      FROM zqu__QuoteRatePlanCharge__c WHERE  zqu__QuoteRatePlan__r.zqu__Quote__c != NULL LIMIT 5];
        
        Set<Id> set_ZQuoteIds = new Set<ID>();
        
        for(zqu__QuoteRatePlanCharge__c objQP : list_QRP){
            set_ZQuoteIds.add(objQP.zqu__QuoteRatePlan__r.zqu__Quote__c);
        }
        
        List<GCR_Content_Document_Detail__c> listContracts = 
            [SELECT Id, Name, GCR__r.Opportunity__c, Status__c,Outbound_Billing_Type__c, Outbound_Rate_Table_Discount__c, Inbound_Billing_Type__c,
             Expiration_Renewal_Date__c,Genesys_Entity__c,Invoice_Type__c,Invoice_Delivery_Type__c,
             Manual_Review_Required__c,Manual_Review_Reason__c,Approved__c,Sold_To_Name_Formula__c, 
             Product_Group__c,Service_Level_Agreement__c,Pricing_Start_Date__c,Pricing_End_Date__c,Reviewed__c,Status_Notes__c,
             
             Quote__r.Sold_To_Name__c, Quote__r.Sold_To_Name__r.SAP_Account_Code__c,Quote__r.BigMachines__Opportunity__r.Direct_Sales__c,
             Quote__c,Quote__r.BigMachines__Description__c,Quote__r.Special_Offer_Terms__c,Quote__r.Legal_Terms__c,
             Quote__r.Pricing_Model__c,Quote__r.Billing_Period__c,Quote__r.CurrencyISOCode,Quote__r.Order_Payment_Terms__c,
             Quote__r.Opportunity_Offering_Type__c,Quote__r.Offering_Type__c,
             
             
             Zuora_Quote__c, Zuora_Quote__r.zqu__Opportunity__r.BusinessPartner__c, Zuora_Quote__r.zqu__Opportunity__r.BusinessPartner__r.SAP_Account_Code__c, 
             Zuora_Quote__r.zqu__Opportunity__r.Direct_Sales__c, Zuora_Quote__r.CurrencyISOCode, Zuora_Quote__r.Order_Payment_Terms__c,
             Zuora_Quote__r.zqu__PaymentTerm__c,Zuora_Quote__r.zqu__Terms__c,Zuora_Quote__r.zqu__Currency__c,
             Zuora_Quote__r.zqu__Opportunity__r.Lines_of_Businesses__c, Zuora_Quote__r.zqu__Account__c, 
             
             Account_Name__c,Account_Name__r.Name,Account_Name__r.OwnerId,Account_Name__r.Country__r.Region__c, Contract_Type__c,
             Account_Name__r.SAP_Account_Code__c,Account_Name__r.Subsidary__c,Direct_Sales_Rep_Override__c, 
             Override_Invoice_Footer__c,Invoice_Footer_Text__c,Order_Date_Option__c, Net_Days_Override__c,Account_Name_Override__c,
             PO__c,PO_Start_Date__c,PO_End_Date__c,PO_Adjustment_Description__c,PO_Starting_Balance__c,PO_Remaining_Balance__c,   
             Name__c,       
             (SELECT Id FROM Cloud_Billing_Exceptions__r WHERE Resolved__c = false LIMIT 1)
             FROM GCR_Content_Document_Detail__c 
             WHERE  Id in ('a7hU0000000Xa7KIAS', // PureEngage
                           'a7h0B0000008dbhQAA', // PureConnect
                           'a7h0B0000008dvbQAA'  //PureCloud
                          )
             //AND Contract_Type__c != 'Cloud Billing - Telco'
            ];
        
        for (GCR_Content_Document_Detail__c objContract : listContracts) {
            if(objContract.Zuora_Quote__c != NULL ){
                zqu__Quote__c objQuote = [SELECT Id, zqu__Opportunity__r.BusinessPartner__c, zqu__Opportunity__r.BusinessPartner__r.SAP_Account_Code__c
                                          FROM zqu__Quote__c WHERE Id = :objContract.Zuora_Quote__c];
                
                TestDataFactoryForQuoteTool.setupQuoteRatePlanCharges(objQuote, true);
                CloudBillingTestUtil.setupZuoraQuoteChargeDetails(objContract.Zuora_Quote__c);
            }else{
                
            }
            //Test.startTest();
            System.Debug('CloudBillingTest.testResetServiceInfoFromQuote contract ' + objContract);
            CloudBillingUtil.resetServiceInfoFromQuote(objContract,'PureEngage Subscription');
            //Test.stopTest();
        }
    }
    
    @isTest(seeallData=true)
    static void testresetServiceInfoFromZQuoteTelco(){
        //setupData();
        Custom_Access_Settings__c objCustomSetting = new Custom_Access_Settings__c(Id = Custom_Access_Settings__c.getInstance(UserInfo.getProfileId()).Id, 
                                                                                   Can_Bypass_Triggers__c = true);
        update objCustomSetting;
        
        List<zqu__QuoteRatePlanCharge__c> list_QRP = [SELECT Id, zqu__QuoteRatePlan__r.zqu__Quote__c
                                                      FROM zqu__QuoteRatePlanCharge__c WHERE  zqu__QuoteRatePlan__r.zqu__Quote__c != NULL LIMIT 5];
        
        Set<Id> set_ZQuoteIds = new Set<ID>();
        
        for(zqu__QuoteRatePlanCharge__c objQP : list_QRP){
            set_ZQuoteIds.add(objQP.zqu__QuoteRatePlan__r.zqu__Quote__c);
        }
        
        GCR_Content_Document_Detail__c objContract  = 
            [SELECT Id, Name, GCR__r.Opportunity__c, Status__c,Outbound_Billing_Type__c, Outbound_Rate_Table_Discount__c, Inbound_Billing_Type__c,
             Expiration_Renewal_Date__c,Genesys_Entity__c,Invoice_Type__c,Invoice_Delivery_Type__c,
             Manual_Review_Required__c,Manual_Review_Reason__c,Approved__c,Sold_To_Name_Formula__c, 
             Product_Group__c,Service_Level_Agreement__c,Pricing_Start_Date__c,Pricing_End_Date__c,Reviewed__c,Status_Notes__c,
             
             Quote__r.Sold_To_Name__c, Quote__r.Sold_To_Name__r.SAP_Account_Code__c,Quote__r.BigMachines__Opportunity__r.Direct_Sales__c,
             Quote__c,Quote__r.BigMachines__Description__c,Quote__r.Special_Offer_Terms__c,Quote__r.Legal_Terms__c,
             Quote__r.Pricing_Model__c,Quote__r.Billing_Period__c,Quote__r.CurrencyISOCode,Quote__r.Order_Payment_Terms__c,
             Quote__r.Opportunity_Offering_Type__c,Quote__r.Offering_Type__c,
             
             
             Zuora_Quote__c, Zuora_Quote__r.zqu__Opportunity__r.BusinessPartner__c, Zuora_Quote__r.zqu__Opportunity__r.BusinessPartner__r.SAP_Account_Code__c, 
             Zuora_Quote__r.zqu__Opportunity__r.Direct_Sales__c, Zuora_Quote__r.CurrencyISOCode, Zuora_Quote__r.Order_Payment_Terms__c,
             Zuora_Quote__r.zqu__PaymentTerm__c,Zuora_Quote__r.zqu__Terms__c,Zuora_Quote__r.zqu__Currency__c,
             Zuora_Quote__r.zqu__Opportunity__r.Lines_of_Businesses__c, Zuora_Quote__r.zqu__Account__c, 
             
             Account_Name__c,Account_Name__r.Name,Account_Name__r.OwnerId,Account_Name__r.Country__r.Region__c, Contract_Type__c,
             Account_Name__r.SAP_Account_Code__c,Account_Name__r.Subsidary__c,Direct_Sales_Rep_Override__c, 
             Override_Invoice_Footer__c,Invoice_Footer_Text__c,Order_Date_Option__c, Net_Days_Override__c,Account_Name_Override__c,
             PO__c,PO_Start_Date__c,PO_End_Date__c,PO_Adjustment_Description__c,PO_Starting_Balance__c,PO_Remaining_Balance__c,   
             Name__c,       
             (SELECT Id FROM Cloud_Billing_Exceptions__r WHERE Resolved__c = false LIMIT 1)
             FROM GCR_Content_Document_Detail__c 
             WHERE  (Zuora_Quote__c != NULL OR Quote__c != Null)
             AND Contract_Type__c != 'Cloud Billing - Telco' LIMIT 1];
        
        if(objContract.Zuora_Quote__c != NULL ){
            zqu__Quote__c objQuote = [SELECT Id, zqu__Opportunity__r.BusinessPartner__c, zqu__Opportunity__r.BusinessPartner__r.SAP_Account_Code__c
                                      FROM zqu__Quote__c WHERE Id = :objContract.Zuora_Quote__c];
            
            TestDataFactoryForQuoteTool.setupQuoteRatePlanCharges(objQuote, true);
            CloudBillingTestUtil.setupZuoraQuoteChargeDetails(objContract.Zuora_Quote__c);
        }else{
            
        }
        Test.startTest();
        CloudBillingUtil.resetServiceInfoFromQuote(objContract,'PureConnect Cloud');
        Test.stopTest();
    }
    
    @isTest
    static void testSetupContractTierRange(){
        setupData();
        Contract_Tier_Set__c objCTS = [SELECT Id, Contract__c  FROM Contract_Tier_Set__c LIMIT 1];
        GCR_Content_Document_Detail__c objContract = [SELECT Id, Quote__c, Zuora_Quote__c, Zuora_Quote__r.CurrencyISOCode, Quote__r.CurrencyISOCode 
                                                      FROM GCR_Content_Document_Detail__c WHERE Id = :objCTS.Contract__c];
        
        Test.startTest();
        List<Product_Tier_Range__c> list_PTR = new List<Product_Tier_Range__c>();
        Product_Tier_Range__c objPTR = new Product_Tier_Range__c();
        list_PTR.add(objPTR);
        objPTR.From__c = 0 ;
        objPTR.To__c = 20;
        objPTR.Price__c = 10 ;
        
        CloudBillingUtil.setupContractTierRange(list_PTR , objCTS , objContract);
        CloudBillingUtil.setupContractTierRangeForEmpty(objCTS, 0, 999999999.0, 10, 'USD');
        
        Test.stopTest();
    }
    
    
    @isTest
    static void testpopulateGarnCode(){
        setupData();
        List<Rolled_Up_Usage_Data__c> list_RUUDs = [select Source_Name__c, Calling_Rate_Identifier_Inbound__c, 
                                                    Platform_Id__c, Count__c , 
                                                    Service_Type__c, Total_Duration__c, Gigabyte_Count__c, 
                                                    Channel_Type__c, Service_Class__c, Destination_Country_Code__c,
                                                    Billable_6__c,
                                                    Billable_30__c,
                                                    Billable_60__c,
                                                    Start_Time__c,
                                                    Service_Identifier__c, 
                                                    Destination_Device_Career__c 
                                                    from Rolled_Up_Usage_Data__c];
        
        for(Rolled_Up_Usage_Data__c obj : list_RUUDs){
            obj.GARN_Account_Code__c = null;
        }
        
        update list_RUUDs;
        Test.startTest();
        BatchRateCloudUsageData objBRCUD = new BatchRateCloudUsageData();
        objBRCUD.populateMissingGARNCodes();
        
        Set<String> set_PlatformIdHashes = new Set<String>();
        list_RUUDs = [select Source_Name__c, Calling_Rate_Identifier_Inbound__c, 
                      Platform_Id__c, Count__c , 
                      Service_Type__c, Total_Duration__c, Gigabyte_Count__c, 
                      Channel_Type__c, Service_Class__c, Destination_Country_Code__c,
                      Billable_6__c,
                      Billable_30__c,
                      Billable_60__c,
                      Start_Time__c,
                      Service_Identifier__c, 
                      Destination_Device_Career__c , Platform_Id_Hash__c
                      from Rolled_Up_Usage_Data__c];
        for(Rolled_Up_Usage_Data__c objRollUpData : list_RUUDs)
        {
            if (!set_PlatformIdHashes.contains(objRollUpData.Platform_Id_Hash__c)) {
                System.debug('PlatformId Push Hash ' + objRollUpData.Platform_Id_Hash__c);
                set_PlatformIdHashes.add(objRollUpData.Platform_Id_Hash__c);
            }
        }
        // Insert PureCloud Deployment
        set_PlatformIdHashes.add('PCL#PCL123');
        set_PlatformIdHashes.add('Angel#Angel123');
        set_PlatformIdHashes.add('BEEEC#BEEEC123');
        set_PlatformIdHashes.add('Portico#Portico123');
        CloudBillingUtil.getMapCloudDeploymentfromHashes(set_PlatformIdHashes);
        
        Test.stopTest();
    }
    
    @isTest
    public static void setCreateReportRequestAndInstancesAll() {
        CloudBillingData objCB = new CloudBillingData();
        objCB.month = '8';
        objCB.year = '2016';
        CloudBillingTestUtil.insertCloudBillingReportRequest2016();
        // Should create 3 instances
        CloudBillingUtil.runCloudBillingReportRequests(objCB);
        // Call again to try to get to code not creating a 2nd instance for the same request
        CloudBillingUtil.runCloudBillingReportRequests(objCB);
    }
    
    @isTest
    public static void setCreateReportRequestAndInstancesSpecific() {
        CloudBillingTestUtil.insertCloudBillingReportRequest2016();
        CloudBillingData objCB = new CloudBillingData();
        objCB.month = '8';
        objCB.year = '2016';
        
        // fill in non-existant fields to get more coverage but not insert any new instances
        objCB.subsidiary = 'Not A Subsidiary';
        objCB.region = 'Not A Region';
        objCB.edition = 'Not An Edition';
        List<GCR_Content_Document_Detail__c> list_Contracts = [select Id from GCR_Content_Document_Detail__c];
        if (list_Contracts.size() > 0) {
            objCB.contractId = list_Contracts[0].Id;
        }
        //Should not create any instances
        CloudBillingUtil.runCloudBillingReportRequests(objCB);
    }
    
    
    
    public static Country__c setupCountry(){
        Country__c objCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', 
                                               Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                               New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        return objCountry;
    }
    
    public static Order__c setupOrder(GCR_Content_Document_Detail__c objContract){
        Order__c objOrder = new Order__c(Name = 'Test Order');
        objOrder.Contract_Lookup__c = objContract.Id;
        objOrder.Month__c = '6';
        objOrder.Year__c = '2017';
        objOrder.status__c = 'In Progress';
        objOrder.End_User_Name__c = objOrder.Bill_To_Name__c = objOrder.Sold_To_Name__c = objOrder.Ship_To_Name__c = objContract.Account_Name__c ;
        objOrder.Opportunity__c = objContract.Zuora_Quote__r.zqu__Opportunity__c;
        return objOrder;
    }
    
    static List<Contract_Tier_Set__c> setupTierSets(Id contractId , List<Product2> list_Products){
        List<Contract_Tier_Set__c> list_ContractTS = new List<Contract_Tier_Set__c>();
        for(Product2 objProd : list_Products){
            list_ContractTS.add( new Contract_Tier_Set__c(Name = 'Test '+objProd.Name , 
                                                          Product__c = objProd.id ,
                                                          Period_In_Months__c = '6', 
                                                          Contract__c = contractId , Is_Deleted__c = false ,
                                                          Units_Type__c = 'Messages/Seats/Ports') );
        }
        return list_ContractTS;
    }
    
    static List<Service__c> setupContractServices(){
        List<Service__c> list_services = [SELECT id, Name,
                                          Description__c,
                                          UID__c,
                                          Channel_Type_Value__c,
                                          Device_Type_Value__c ,
                                          Service_Type_Value__c ,
                                          Country_Code__c ,
                                          Country_Code_ISO__c ,
                                          SubCampaign_Type_Value__c,
                                          Service_Class__c ,
                                          Active__c  FROM Service__c LIMIT 10
                                         ]; 
        if(list_services == NULL || list_services.size() < 1 )
            TestCloudBillingRating.insertServices();
        list_services = [SELECT id, Name,
                         Description__c,
                         UID__c,
                         Channel_Type_Value__c,
                         Device_Type_Value__c ,
                         Service_Type_Value__c ,
                         Country_Code__c ,
                         Country_Code_ISO__c ,
                         SubCampaign_Type_Value__c,
                         Service_Class__c ,
                         Active__c  FROM Service__c LIMIT 10
                        ]; 
        return list_services;
    }
    
    static List<Contract_Service__c> setupContractServices(List<Service__c> list_services, Contract_Tier_Set__c objContractTierSet ){
        List<Contract_Service__c> list_ContractServices = new List<Contract_Service__c>();
        for (Service__c objService : list_services) {
            Contract_Service__c objContractService = new Contract_Service__c (
                Contract_Tier_Set__c = objContractTierSet.Id,
                Service__c = objService.Id,
                Is_Deleted__c = false
            );
            list_ContractServices.add(objContractService);
        }
        insert list_ContractServices;
        return list_ContractServices;
    }
    
    static Cloud_Deployment__c setupCloudDeployments(GCR_Content_Document_Detail__c objContract){
        Cloud_Deployment__c objCloudDeployment = new Cloud_Deployment__c();
        objCloudDeployment.Account__c = objContract.Account_Name__c;
        objCloudDeployment.Cloud_Platform__c = 'PureCloud';
        objCloudDeployment.PureConnect_Id__c = 'Tenant123' ;
        insert objCloudDeployment;
        return objCloudDeployment;
    }
    
    static Cloud_Deployment_To_Contract_Junction__c setupCloudDeploymentToContractJunction(GCR_Content_Document_Detail__c objContract, 
                                                                                           Cloud_Deployment__c objCD)
    {
        Cloud_Deployment_To_Contract_Junction__c objCDTCJ = new Cloud_Deployment_To_Contract_Junction__c(
            Contract__c = objContract.id, Cloud_Deployment__c  = objCD.id );
        insert objCDTCJ;
        return objCDTCJ;
    }
    
    static List<Contract_Tier_Set_Period__c> setupContractTierSetPeriod(List<Contract_Tier_Set__c> list_ContractTS){
        List<Contract_Tier_Set_Period__c> list_CTSPs = new List<Contract_Tier_Set_Period__c>();
        for(Contract_Tier_Set__c objCTS : list_ContractTS){
            for(integer i = 1 ; i<4 ; i++)
                list_CTSPs.add(new Contract_Tier_Set_Period__c(Name = objCTS.Name+i , Source_Name__c = 'PCC' , Platform_Id__c = 'Tenant123',
                                                               Start_Date__c = Date.newInstance(2017,1,1) , 
                                                               End_Date__c = Date.newInstance(2017,12,1)));
        }
        insert list_CTSPs;
        return list_CTSPs;
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
        //  CloudBillingUtil.buildZuoraQuoteInfo(list_Contracts[0]);
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
    
    
    @isTest
    public static void testGetMapPlatformIdHashToCloudDeployment() {
        Map<String, Cloud_Deployment__c> mapPlatformIdHashToCloudDeployment = CloudBillingTestUtil.getMapPlatformIdHashToCloudDeploymentTenant123();
        Rolled_Up_Usage_Data__c objRUUD = CloudBillingTestUtil.getRolledUpUsageDataPureConnectTenant123();
        CloudBillingUtil.populateListContractIdServiceId(objRUUD, mapPlatformIdHashToCloudDeployment, true);
        
        Rolled_Up_Usage_Data__c objRUUDPCL = CloudBillingTestUtil.getRolledUpUsageDataPureCloud();
        CloudBillingUtil.populateListContractIdServiceId(objRUUDPCL, mapPlatformIdHashToCloudDeployment, true);
    }
    /*
@isTest
public static void testGetSureTaxDescriptionFromResponseCode() {
String strDesc = CloudBillingUtil.getSureTaxDescriptionFromResponseCode('Should Not Exist');
System.debug('strDesc ' + strDesc);

insert SureTaxSettingsFactory.createDefaultSureTaxSettings();
strDesc = CloudBillingUtil.getSureTaxDescriptionFromResponseCode('SureTaxBusinessUnit');
System.debug('strDesc2 ' + strDesc);
}
*/
    
    @isTest
    public static void testGetSureTaxProductAPNFromResponseCode() {
        String str106Response = 'PEC-100-TAX-SL911';
        String str035Response = 'PEC-100-TAX-FUSFC';
        insert SureTaxSettingsFactory.createDefaultSureTaxSettings();
        String strAPN = CloudBillingUtil.getSureTaxProductAPNFromResponseCode('106', 'PEC');
        System.assert(strAPN == str106Response, '106 did not match to ' + str106Response);
        
        strAPN = CloudBillingUtil.getSureTaxProductAPNFromResponseCode('035', 'PEC');
        System.assert(strAPN == str035Response, '035 did not match to ' + str035Response);
    }
    
    @isTest
    public static void testGetMapOfferingPrefixTaxNameToProduct() {
        Product2 objProduct = new Product2(
            Name = 'State and Local 911 Fees',
            APN_Number__c = 'PEC-100-TAX-SL911'
        );
        insert objProduct;
        Product2 objProduct2 = new Product2(
            Name = 'State and Local Taxes',
            APN_Number__c = 'PEC-170-NV-SLTAX'
        );
        insert objProduct2;
        Set<String> setTaxProductAPNNumbers = new Set<String>();
        setTaxProductAPNNumbers.add('PEC-100-TAX-SL911');
        setTaxProductAPNNumbers.add('PEC-170-NV-SLTAX');
        CloudBillingUtil.getMapOfferingAPNNumberToProduct(setTaxProductAPNNumbers);
    }
    
    @isTest
    public static void testPopulateJobLogOptions() {
        CloudBillingUtil.populateJobLogOptions(null);
        CloudBillingData objCloudBillingData = new CloudBillingData();
        objCloudBillingData.contractId = 'no id';
        objCloudBillingData.region = 'region';
        objCloudBillingData.edition = 'edition';
        objCloudBillingData.subsidiary = 'subsidiary';
        
        CloudBillingUtil.populateJobLogOptions(objCloudBillingData);
    }
    
    @isTest
    public static void testcreateBillingContract(){
        Util.Bypass_Trigger_Chk = true;
        TriggerFlowManager.ORDER_BEFORE_INSERT_TRIGGER = false;
        List<Account> list_Accounts = TestUtil.createAccounts(1,false);
        list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
        insert list_Accounts;
        Opportunity objOpportunitySub  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
        objOpportunitySub.Lines_of_Businesses__c = 'PureEngage';
        objOpportunitySub.Primary_Line_of_Business__c = 'On Premise';
        objOpportunitySub.Offering_Detail__c = 'Subscription';
        insert objOpportunitySub;
        BigMachines__Quote__c objQuoteSub = TestUtil.createQuotes(1,objOpportunitySub.id,false)[0];
        objQuoteSub.Offering_Type__c = 'PureEngage Subscription';
        objQuoteSub.BigMachines__Is_Primary__c = true;
        objQuoteSub.Subscription_End_Date__c = system.today()+60;
        objQuoteSub.End_User_ID__c = list_Accounts[0].id;
        objQuoteSub.Pricing_Model__c = 'User';
        objQuoteSub.Usage_Data_Submission_Method__c='Automated';
        insert objQuoteSub;
        MakeQuotePrimary_WS.CorrectTotalCloud(String.valueof(objQuoteSub.id));
        OpportunityQuotes.populateOpportunityProducts(String.valueof(objQuoteSub.id));
        GCR_Content_Document_Detail__c objContractSub = BatchCreateCloudMonthlySalesOrdersTest.setupContractSub(objQuoteSub);
        Genesys_Entity__c objGenEntity1 = BatchCreateCloudMonthlySalesOrdersTest.setupGenesysEntity();
        objContractsub.Genesys_Entity__c = objGenEntity1.id;
        insert objContractSub;
        Order__c objOrder = BatchCreateCloudMonthlySalesOrdersTest.setupOrder(objContractSub);
        objOrder.Order_Date__c = System.today();
        objOrder.CurrencyIsoCode = 'USD';
        objOrder.Quote__c = objQuoteSub.id;
        objOrder.PO_Number__c = 'PONumber';
        insert objOrder;
        objQuoteSub.Order__c = objOrder.id;
        update objQuoteSub;
        
        list<order__c> list_MasterOrderList=  new list<order__c>();
        list_MasterOrderList.add(objOrder);
        Account_Order_Address__c objAccountAddressBillTo =  new Account_Order_Address__c(Address_Type__c = 'Bill To',Account__c=list_Accounts[0].id,GCR_Content_Document_Detail__c	= objContractsub.id,Quote__c = objQuoteSub.id);
        insert objAccountAddressBillTo;
        Test.startTest();
        CloudBillingUtil.createBillingContract(list_MasterOrderList);
        Test.stopTest();
        
    }
    @isTest
    public static void testCreateContractForSubscriptionUser(){
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_Accounts = TestUtil.createAccounts(1,false);
        list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
        insert list_Accounts;
        Opportunity objOpportunitySub  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
        objOpportunitySub.Lines_of_Businesses__c = 'PureEngage';
        objOpportunitySub.Primary_Line_of_Business__c = 'On Premise';
        objOpportunitySub.Offering_Detail__c = 'Subscription';
        insert objOpportunitySub;
        List<Product2> list_Products = TestUtil.createProducts(5, false);
        for(integer i = 0 ; i < list_Products.size() ; i++){
            list_Products[i].APN_Number__c = 'APNABC'+i;
            list_Products[i].Unit_of_Measure__c = 'Per Month';
            list_Products[i].Burstable_or_Non_Burstable__c = true;
            list_Products[i].Pricing_Model__c = 'User';
        }
        insert list_Products;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;
        
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        List<PricebookEntry> pbes = TestUtil.createPriceBookEntries( list_Products, true);
        objOpportunitySub.Pricebook2Id = standardPricebook.id;
        update objOpportunitySub;
        List<Service__c> list_services = setupContractServices();
        for(integer i = 0;i<1;i++ ){
            list_services[i].usage_type__C = 2;
        }
        
        for(integer i =1 ;i<2;i++ ){
            list_services[i].usage_type__C = 1;
        }
        
        for(integer i =2 ;i<list_services.size();i++ ){
            list_services[i].Service_Type_Value__c = 19;
        }
        update  list_services;
        Product_Tier_Set__c objPTS =  new Product_Tier_Set__c(Aggregation_Model__c='Max Per Month',Product__c=list_Products[0].id,Units_Type__c='Messages/Seats/Ports');
        insert objPTS;
        list<Product_Tier_Set_Service__c> list_PTSS = new list<Product_Tier_Set_Service__c>();
        for(integer i = 0;i<list_services.size();i++ ){
            list_PTSS.add( new Product_Tier_Set_Service__c(Product_Tier_Set__c = objPTS.id,Service__c = list_services[i].id ));
        }
        insert list_PTSS;
        BigMachines__Quote__c objQuoteSub = TestUtil.createQuotes(1,objOpportunitySub.id,false)[0];
        objQuoteSub.Offering_Type__c = 'PureEngage Subscription';
        objQuoteSub.BigMachines__Is_Primary__c = true;
        objQuoteSub.Subscription_End_Date__c = system.today()+60;
        objQuoteSub.Pricing_Model__c = 'User';
        objQuoteSub.CurrencyIsoCode = 'USD';
        insert objQuoteSub;
        MakeQuotePrimary_WS.CorrectTotalCloud(String.valueof(objQuoteSub.id));
        //OpportunityQuotesloudBillingU.populateOpportunityProducts(String.valueof(objQuoteSub.id));
        GCR_Content_Document_Detail__c objContractSub = BatchCreateCloudMonthlySalesOrdersTest.setupContractSub(objQuoteSub);
        Genesys_Entity__c objGenEntity1 = BatchCreateCloudMonthlySalesOrdersTest.setupGenesysEntity();
        objContractsub.Genesys_Entity__c = objGenEntity1.id;
        insert objContractSub;
        GCR_Content_Document_Detail__c objContract = [SELECT id , Quote__c,Quote__r.Offering_Type__C,Quote__r.CurrencyIsoCode ,Pricing_Start_Date__c,Product_Group__c,Zuora_Quote__c FROM GCR_Content_Document_Detail__c where 	Product_Group__c like '%Subscription%' LIMIT 1];
        // Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<BigMachines__Quote_Product__c>  list_QuoteProducts = TestUtil.createQuoteProducts(5,false,objQuoteSub.id);
        for(integer i = 0 ;i < list_QuoteProducts.size();i++) {
            list_QuoteProducts[i].BigMachines__Product__c = list_Products[i].id;
            list_QuoteProducts[i].net_unit_price__c = 22.00;
        }
        insert list_QuoteProducts;
        Test.startTest();
        CloudBillingUtil.resetServiceInfoFromQuote(objContract,'PureConnect');
        CloudBillingUtil.createContractForSubscription(objContract);
        Test.stopTest();
        
    }
    @isTest
    public static void testCreateContractForSubscriptionUserNoServiceUsage(){
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_Accounts = TestUtil.createAccounts(1,false);
        list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
        insert list_Accounts;
        Opportunity objOpportunitySub  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
        objOpportunitySub.Lines_of_Businesses__c = 'PureEngage';
        objOpportunitySub.Primary_Line_of_Business__c = 'On Premise';
        objOpportunitySub.Offering_Detail__c = 'Subscription';
        insert objOpportunitySub;
        List<Product2> list_Products = TestUtil.createProducts(5, false);
        for(integer i = 0 ; i < list_Products.size() ; i++){
            list_Products[i].APN_Number__c = 'APNABC'+i;
            list_Products[i].Unit_of_Measure__c = 'Per Month';
            list_Products[i].Burstable_or_Non_Burstable__c = true;
            list_Products[i].Pricing_Model__c = 'User';
        }
        insert list_Products;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;
        
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        List<PricebookEntry> pbes = TestUtil.createPriceBookEntries( list_Products, true);
        objOpportunitySub.Pricebook2Id = standardPricebook.id;
        update objOpportunitySub;
        List<Service__c> list_services = setupContractServices();
        for(integer i = 0;i<1;i++ ){
            list_services[i].usage_type__C = null;
        }
        
        for(integer i =1 ;i<2;i++ ){
            list_services[i].usage_type__C = null;
        }
        
        for(integer i =2 ;i<list_services.size();i++ ){
            list_services[i].Service_Type_Value__c = 19;
        }
        update  list_services;
        List<Product_Tier_Set__c> list_PTS =  new List<Product_Tier_Set__c>();
        for(integer i=0;i<list_Products.size();i++) {
            Product_Tier_Set__c objPTS =  new Product_Tier_Set__c(Aggregation_Model__c='Max Per Month',Product__c=list_Products[i].id,Units_Type__c='Messages/Seats/Ports');
            list_PTS.add(objPTS);}
        insert list_PTS;
        list<Product_Tier_Set_Service__c> list_PTSS = new list<Product_Tier_Set_Service__c>();
        for(Product_Tier_Set__c objPTS:list_PTS){
            for(integer i = 0;i<list_services.size();i++ ){
                list_PTSS.add( new Product_Tier_Set_Service__c(Product_Tier_Set__c = objPTS.id,Service__c = list_services[i].id ));
            }
        }    
        insert list_PTSS;
        BigMachines__Quote__c objQuoteSub = TestUtil.createQuotes(1,objOpportunitySub.id,false)[0];
        objQuoteSub.Offering_Type__c = 'PureEngage Subscription';
        objQuoteSub.BigMachines__Is_Primary__c = true;
        objQuoteSub.Subscription_End_Date__c = system.today()+60;
        objQuoteSub.Pricing_Model__c = 'User';
        objQuoteSub.CurrencyIsoCode = 'USD';
        insert objQuoteSub;
        MakeQuotePrimary_WS.CorrectTotalCloud(String.valueof(objQuoteSub.id));
        //OpportunityQuotesloudBillingU.populateOpportunityProducts(String.valueof(objQuoteSub.id));
        GCR_Content_Document_Detail__c objContractSub = BatchCreateCloudMonthlySalesOrdersTest.setupContractSub(objQuoteSub);
        Genesys_Entity__c objGenEntity1 = BatchCreateCloudMonthlySalesOrdersTest.setupGenesysEntity();
        objContractsub.Genesys_Entity__c = objGenEntity1.id;
        insert objContractSub;
        GCR_Content_Document_Detail__c objContract = [SELECT id , Quote__c,Quote__r.Offering_Type__C,Quote__r.CurrencyIsoCode ,Pricing_Start_Date__c,Product_Group__c,Zuora_Quote__c FROM GCR_Content_Document_Detail__c where 	Product_Group__c like '%Subscription%' LIMIT 1];
        // Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<BigMachines__Quote_Product__c>  list_QuoteProducts = TestUtil.createQuoteProducts(5,false,objQuoteSub.id);
        for(integer i = 0 ;i < list_QuoteProducts.size();i++) {
            list_QuoteProducts[i].BigMachines__Product__c = list_Products[i].id;
            list_QuoteProducts[i].net_unit_price__c = 22.00;
        }
        insert list_QuoteProducts;
        Test.startTest();
        CloudBillingUtil.createContractForSubscription(objContract);
        Test.stopTest();
        
    }
    
    
    @isTest
    public static void testCreateContractForSubscriptionConcurrent(){
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_Accounts = TestUtil.createAccounts(1,false);
        list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
        insert list_Accounts;
        Opportunity objOpportunitySub  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
        objOpportunitySub.Lines_of_Businesses__c = 'PureEngage';
        objOpportunitySub.Primary_Line_of_Business__c = 'On Premise';
        objOpportunitySub.Offering_Detail__c = 'Subscription';
        insert objOpportunitySub;
        List<Product2> list_Products = TestUtil.createProducts(5, false);
        for(integer i = 0 ; i < list_Products.size() ; i++){
            list_Products[i].APN_Number__c = 'APNABC'+i;
            list_Products[i].Unit_of_Measure__c = 'Per Month';
            list_Products[i].Burstable_or_Non_Burstable__c = true;
            list_Products[i].Pricing_Model__c = 'Concurrent';
        }
        insert list_Products;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;
        
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        List<PricebookEntry> pbes = TestUtil.createPriceBookEntries( list_Products, true);
        objOpportunitySub.Pricebook2Id = standardPricebook.id;
        update objOpportunitySub;
        List<Service__c> list_services = setupContractServices();
        for(integer i = 0;i<1;i++ ){
            list_services[i].usage_type__C = 2;
        }
        
        for(integer i = 1;i<2;i++ ){
            list_services[i].usage_type__C = 1;
        }
        
        for(integer i = 2;i<list_services.size();i++ ){
            list_services[i].Service_Type_Value__c = 19;
        }
        update  list_services;
        Product_Tier_Set__c objPTS =  new Product_Tier_Set__c(Aggregation_Model__c='Max Per Month',Product__c=list_Products[0].id,Units_Type__c='Messages/Seats/Ports',name='PureEngage Base Package - Others');
        insert objPTS;
        list<Product_Tier_Set_Service__c> list_PTSS = new list<Product_Tier_Set_Service__c>();
        for(integer i = 0;i<list_services.size();i++ ){
            list_PTSS.add( new Product_Tier_Set_Service__c(Product_Tier_Set__c = objPTS.id,Service__c = list_services[i].id ));
        }
        insert list_PTSS;
        BigMachines__Quote__c objQuoteSub = TestUtil.createQuotes(1,objOpportunitySub.id,false)[0];
        objQuoteSub.Offering_Type__c = 'PureEngage Subscription';
        objQuoteSub.BigMachines__Is_Primary__c = true;
        objQuoteSub.Subscription_End_Date__c = system.today()+60;
        objQuoteSub.Pricing_Model__c = 'Concurrent';
        objQuoteSub.CurrencyIsoCode = 'USD';
        insert objQuoteSub;
        MakeQuotePrimary_WS.CorrectTotalCloud(String.valueof(objQuoteSub.id));
        //OpportunityQuotesloudBillingU.populateOpportunityProducts(String.valueof(objQuoteSub.id));
        GCR_Content_Document_Detail__c objContractSub = BatchCreateCloudMonthlySalesOrdersTest.setupContractSub(objQuoteSub);
        Genesys_Entity__c objGenEntity1 = BatchCreateCloudMonthlySalesOrdersTest.setupGenesysEntity();
        objContractsub.Genesys_Entity__c = objGenEntity1.id;
        insert objContractSub;
        GCR_Content_Document_Detail__c objContract = [SELECT id , Quote__c,Quote__r.Offering_Type__C,Quote__r.CurrencyIsoCode ,Pricing_Start_Date__c,Product_Group__c,Zuora_Quote__c FROM GCR_Content_Document_Detail__c where 	Product_Group__c like '%Subscription%' LIMIT 1];
        // Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<BigMachines__Quote_Product__c>  list_QuoteProducts = TestUtil.createQuoteProducts(5,false,objQuoteSub.id);
        for(integer i = 0 ;i < list_QuoteProducts.size();i++) {
            list_QuoteProducts[i].BigMachines__Product__c = list_Products[i].id;
            list_QuoteProducts[i].net_unit_price__c = 22.00;
        }
        insert list_QuoteProducts;
        Test.startTest();
        CloudBillingUtil.createContractForSubscription(objContract);
        Test.stopTest();
        
    }
    
    @isTest
    public static void testCreateContractForSubscriptionConcurrentNoServiceUsage(){
        Util.Bypass_Trigger_Chk = true;
        List<Account> list_Accounts = TestUtil.createAccounts(1,false);
        list_Accounts[0].SAP_Account_Code__c = 'GARN TEST';
        insert list_Accounts;
        Opportunity objOpportunitySub  = TestUtil.createOpportunities(1,list_Accounts[0].id, false)[0];
        objOpportunitySub.Lines_of_Businesses__c = 'PureEngage';
        objOpportunitySub.Primary_Line_of_Business__c = 'On Premise';
        objOpportunitySub.Offering_Detail__c = 'Subscription';
        insert objOpportunitySub;
        List<Product2> list_Products = TestUtil.createProducts(5, false);
        for(integer i = 0 ; i < list_Products.size() ; i++){
            list_Products[i].APN_Number__c = 'APNABC'+i;
            list_Products[i].Unit_of_Measure__c = 'Per Month';
            list_Products[i].Burstable_or_Non_Burstable__c = true;
            list_Products[i].Pricing_Model__c = 'Concurrent';
        }
        insert list_Products;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        
        update standardPricebook;
        
        standardPricebook = [SELECT IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        List<PricebookEntry> pbes = TestUtil.createPriceBookEntries( list_Products, true);
        objOpportunitySub.Pricebook2Id = standardPricebook.id;
        update objOpportunitySub;
        List<Service__c> list_services = setupContractServices();
        for(integer i = 0;i<1;i++ ){
            list_services[i].usage_type__C = null;
        }
        
        for(integer i = 1;i<2;i++ ){
            list_services[i].usage_type__C = null;
        }
        
        for(integer i = 2;i<list_services.size();i++ ){
            list_services[i].Service_Type_Value__c = 19;
        }
        update  list_services;
        Product_Tier_Set__c objPTS =  new Product_Tier_Set__c(Aggregation_Model__c='Max Per Month',Product__c=list_Products[0].id,Units_Type__c='Messages/Seats/Ports',name='PureEngage Base Package - Others');
        insert objPTS;
        Product_Tier_Set__c objProdTierSetNotBase =  new Product_Tier_Set__c(Aggregation_Model__c='Max Per Month',Product__c=list_Products[0].id,Units_Type__c='Messages/Seats/Ports',name='Not Base Package');
        insert objProdTierSetNotBase;
        list<Product_Tier_Set_Service__c> list_PTSS = new list<Product_Tier_Set_Service__c>();
        for(integer i = 0;i<list_services.size();i++ ){
            list_PTSS.add( new Product_Tier_Set_Service__c(Product_Tier_Set__c = objPTS.id,Service__c = list_services[i].id ));
            list_PTSS.add( new Product_Tier_Set_Service__c(Product_Tier_Set__c = objProdTierSetNotBase.id,Service__c = list_services[i].id ));
        }
        insert list_PTSS;
        BigMachines__Quote__c objQuoteSub = TestUtil.createQuotes(1,objOpportunitySub.id,false)[0];
        objQuoteSub.Offering_Type__c = 'PureEngage Subscription';
        objQuoteSub.BigMachines__Is_Primary__c = true;
        objQuoteSub.Subscription_End_Date__c = system.today()+60;
        objQuoteSub.Pricing_Model__c = 'Concurrent';
        objQuoteSub.CurrencyIsoCode = 'USD';
        insert objQuoteSub;
        MakeQuotePrimary_WS.CorrectTotalCloud(String.valueof(objQuoteSub.id));
        //OpportunityQuotesloudBillingU.populateOpportunityProducts(String.valueof(objQuoteSub.id));
        GCR_Content_Document_Detail__c objContractSub = BatchCreateCloudMonthlySalesOrdersTest.setupContractSub(objQuoteSub);
        Genesys_Entity__c objGenEntity1 = BatchCreateCloudMonthlySalesOrdersTest.setupGenesysEntity();
        objContractsub.Genesys_Entity__c = objGenEntity1.id;
        insert objContractSub;
        GCR_Content_Document_Detail__c objContract = [SELECT id , Quote__c,Quote__r.Offering_Type__C,Quote__r.CurrencyIsoCode ,Pricing_Start_Date__c,Product_Group__c,Zuora_Quote__c FROM GCR_Content_Document_Detail__c where 	Product_Group__c like '%Subscription%' LIMIT 1];
        // Order__c objOrder = [SELECT id, CurrencyISOCode FROM Order__c LIMIT 1];
        List<BigMachines__Quote_Product__c>  list_QuoteProducts = TestUtil.createQuoteProducts(5,false,objQuoteSub.id);
        for(integer i = 0 ;i < list_QuoteProducts.size();i++) {
            list_QuoteProducts[i].BigMachines__Product__c = list_Products[i].id;
            list_QuoteProducts[i].net_unit_price__c = 22.00;
        }
        insert list_QuoteProducts;
        Test.startTest();
        CloudBillingUtil.createContractForSubscription(objContract);
        Test.stopTest();
        
    }
    @isTest
    public static void testIsBillingLastMonth() {
        Boolean blnResult = CloudBillingUtil.isBillingLastMonth('PureEngage');
        System.assert(blnResult == false);
        blnResult = CloudBillingUtil.isBillingLastMonth('PureConnect');
        System.assert(blnResult == true);
    }
    
    @isTest
    public static void testGetLogLastMonth() {
        Cloud_Billing_Log__c objLog = new Cloud_Billing_Log__c(Year__c = '2018', Month__c = '11', Day__c = '6');
        Cloud_Billing_Log__c objLogLastMonth = CloudBillingUtil.getLogLastMonth(objLog);
        System.Assert(objLogLastMonth.Year__c == '2018');
        System.Assert(objLogLastMonth.Month__c == '10');
        System.Assert(objLogLastMonth.Day__c == '6');
    }
    @isTest
    public static void testGetLogLastMonthFlipYear() {
        Cloud_Billing_Log__c objLog = new Cloud_Billing_Log__c(Year__c = '2018', Month__c = '1', Day__c = '6');
        Cloud_Billing_Log__c objLogLastMonth = CloudBillingUtil.getLogLastMonth(objLog);
        System.Assert(objLogLastMonth.Year__c == '2017');
        System.Assert(objLogLastMonth.Month__c == '12');
        System.Assert(objLogLastMonth.Day__c == '6');
    }
    @isTest
    public static void testGetMapMasterOrderIdToActiveSubscription() {
        BatchCreateCloudMonthlySalesOrdersTest.setUpData();
        GCR_Content_Document_Detail__c objContract = [select Quote__r.Order__c, Account_Name__c from GCR_Content_Document_Detail__c WHERE Quote__r.Order__c != null LIMIT 1];
        System.Debug('testGetMapMasterOrderIdToActiveSubscription: objContract ' + objContract);
        Subscription__c objSubscription = new Subscription__c(Start_Date__c = Date.today(),
                                                              Order__c = objContract.Quote__r.Order__c,
                                                              Account__c = objContract.Account_Name__c,
                                                              Subscription_Start_Date__c = Date.today());
        insert objSubscription;
        List<Id> list_masterOrderIds = new List<Id>();
        list_masterOrderIds.add(objContract.Quote__r.Order__c);
        CloudBillingUtil.getMapMasterOrderIdToActiveSubscription(list_masterOrderIds);
    }
}