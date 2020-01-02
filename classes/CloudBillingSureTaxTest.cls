/*
 * Class Name 		: CloudBillingSureTaxTest
 * description 		: Test coverage for Cloud Billing Apex classes with SureTax
 * Classes Covered 	: BatchReRateUsageData, BatchRateCloudUsageData
 */

@isTest
private class CloudBillingSureTaxTest {
/*
    // Addedy by Vijay - start
    // Test For BatchReRateUsageData added by - Vijay - 3rd July 2017
    @isTest
    static void testBatchReRateUsageData(){
        
        List<Rolled_Up_Usage_Data__c> list_ruud = CloudBillingTestUtil.insertRuud();
        System.debug('testContractCreationAndRating.list_ruud: ' + list_ruud);
        
        GCR_Content_Document_Detail__c objContract = CloudBillingTestUtil.createAndInsertCloudBillingContract(list_ruud);
        Id acctId = objContract.Account_Name__c;
        insertServiceUsages(objContract);
        Date dtStart = date.newInstance(System.today().year(), System.today().month(),objContract.Pricing_Start_Date__c.day());
        Date dtEnd = dtStart.addDays(Date.daysInMonth(System.today().year(),System.today().month()));
        
        Cloud_Billing_Log__c objLog = new Cloud_Billing_Log__c(Type__c = 'Re-Rate',Time__c = DateTime.now(), Status__c = 'Submitted',
                              					Start_Date__c = dtStart,End_Date__c = dtEnd,Account__c = acctId);
        
        insert objLog;
        
        // Invoke batch Job to process Usage Data
        Test.startTest();
        BatchReRateUsageData objBatch = new BatchReRateUsageData(dtStart, dtEnd, acctId);
        objBatch.objJobLog = objLog;
        // when test class is executed the batch limit should be restricted
        Database.executeBatch(objBatch, 200);
        Test.stopTest();
    }
    
    @isTest(SeeAllData=false)
    static void testContractCreationAndRating() {
        
        List<SureTax_Settings__c> list_SureTaxSettings = SureTaxSettingsFactory.createDefaultSureTaxSettings();
        for (SureTax_Settings__c objSureTaxSetting : list_SureTaxSettings) {
            if (objSureTaxSetting.Name == 'SureTaxEnabled') {
                objSureTaxSetting.Value__c = 'True';
            }
        }
        insert list_SureTaxSettings;
        
        TestCloudBillingRating.insertServices();
        
        List<Rolled_Up_Usage_Data__c> list_ruud = CloudBillingTestUtil.insertRuud();
        for(Rolled_Up_Usage_Data__c objRuud : list_ruud){
            objRuud.GARN_Account_Code__c = 'GARN123';
        }
        update list_ruud;
        System.debug('testContractCreationAndRating.list_ruud: ' + list_ruud);
        
        GCR_Content_Document_Detail__c objContract = CloudBillingTestUtil.createAndInsertCloudBillingContract(list_ruud);
        List<Service_Usage__c> list_ServiceUsages = insertServiceUsages(objContract);
        for(Service_Usage__c objServiceUsage : list_ServiceUsages){
            objServiceUsage.Tax_Status__c = 'Tax Needed';
        }
        insert list_ServiceUsages;
        Cloud_Billing_Log__c objLog = CloudBillingUtil.createNewCloudBillingLog('Rating', 'Submitted');
        insert objLog;
        System.Debug('testContractCreationAndRating: Insert of Cloud_Billing_Log__c ' + objLog);
        
        System.Debug('testContractCreationAndRating: list_SureTaxSettings ' + list_SureTaxSettings);
        
        // Invoke batch Job to process Usage Data
        Test.startTest();
        BatchRateCloudUsageData objBatch = new BatchRateCloudUsageData();
        objBatch.objJobLog = objLog;
        // when test class is executed the batch limit should be restricted
        Database.executeBatch(objBatch, 200);
        Test.stopTest();
       
    }
    
    private static List<Service_Usage__c> insertServiceUsages(GCR_Content_Document_Detail__c objContract){
        List<Service_Usage__c> list_ServiceUsages = new List<Service_Usage__c>();
        
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonths = insertContractTierSetMonths(objContract);
        
        List<Rolled_Up_Usage_Data__c> list_RolledUpUsageData = new List<Rolled_Up_Usage_Data__c>();
        
        for(integer i = 0; i< 3 ; i++){
            Service_Usage__c objServiceUsage = new Service_Usage__c(Start_Time__c = System.today()-1);
            objServiceUsage.Contract_Tier_Set_Month__c = list_ContractTierSetMonths[i].id;
            
            Rolled_Up_Usage_Data__c objRolledUpUsageData = CloudBillingTestUtil.insertRolledUpUsageDataInboundUS();
            objRolledUpUsageData.Processed__c = true;
            
            objServiceUsage.Rolled_Up_Usage_Data__c = objRolledUpUsageData.Id;
            
            list_RolledUpUsageData.add(objRolledUpUsageData);
            list_ServiceUsages.add(objServiceUsage);
        }
        update list_RolledUpUsageData;

        return list_ServiceUsages;
    }
    
    private static List<Contract_Tier_Set_Month__c> insertContractTierSetMonths(GCR_Content_Document_Detail__c objContract){
        List<Contract_Tier_Set_Month__c> list_ContractTierSetMonths = new List<Contract_Tier_Set_Month__c>();
        List<Contract_Tier_Set__c> list_ContractTierSets = insertContractTierSets(objContract);
        List<Contract_Tier_Set_Period__c> list_ContractTierSetPeriods = insertContractTierSetPeriods(list_ContractTierSets);
        
        for(integer i = 0; i< 3 ; i++){
            Contract_Tier_Set_Month__c objContractTierSetMonth = new Contract_Tier_Set_Month__c();
            objContractTierSetMonth.Contract_Tier_Set__c = list_ContractTierSets[i].id;
            objContractTierSetMonth.Contract_Tier_Set_Period__c = list_ContractTierSetPeriods[i].id;
            list_ContractTierSetMonths.add(objContractTierSetMonth);
        }
        insert list_ContractTierSetMonths;
        
        return list_ContractTierSetMonths;
    }
    
    private static List<Contract_Tier_Set__c> insertContractTierSets(GCR_Content_Document_Detail__c objContract){
        List<Contract_Tier_Set__c> list_ContractTierSets = new List<Contract_Tier_Set__c>();
        
        for(integer i = 0; i< 3 ; i++){
            list_ContractTierSets.add( new Contract_Tier_Set__c(Contract__c = objContract.id));
        }
        insert list_ContractTierSets;
        
        return list_ContractTierSets;
    }
    
    private static List<Contract_Tier_Set_Period__c> insertContractTierSetPeriods(List<Contract_Tier_Set__c> list_ContractTierSets){
        List<Contract_Tier_Set_Period__c> list_ContractTierSetPeriods = new List<Contract_Tier_Set_Period__c>();
        
        for(Contract_Tier_Set__c objContractTierSet : list_ContractTierSets){
            Contract_Tier_Set_Period__c objContractTierSetPeriod = new Contract_Tier_Set_Period__c(); 
            objContractTierSetPeriod.Contract_Tier_Set__c = objContractTierSet.id;
            list_ContractTierSetPeriods.add(objContractTierSetPeriod);
        }
        insert list_ContractTierSetPeriods;
        
        return list_ContractTierSetPeriods;
    }
    // Addedy by Vijay - end
*/
}