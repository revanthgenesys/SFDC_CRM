@isTest
public class TestCloudBillingRating {

    
    
   
    // Utilising this method in CloudBillingSureTaxTest. Access Specifier should be pulic - Added by Vijay - Jul 13th 2017
    

    private static Rolled_Up_Usage_Data__c insertRolledUpUsageDataOutboundWithTax() {
        Rolled_Up_Usage_Data__c ruud = new Rolled_Up_Usage_Data__c (
            Source_Name__c = 'BEEEC',
            Platform_Id__c = 'Tenant123',
            Rollup_Id__c = 'test-2',
            Channel_Type__c = 1,
            Device_Type__c = 13,
            Service_Type__c = 1,
            Region_Code__c = 'US',
            Origin_Country_Code__c = 1,
            Destination_Country_Code__c = 1,
            Origin_Country_Code_ISO__c = 'US',
            Service_Class__c = 0,
            Billable_6__c = 12600,
            Billable_30__c = 15000,
            Billable_60__c = 18000,
            Start_Time__c = DateTime.newInstance(2017, 1, 1, 12, 0, 0),
            ZIP_Postal_Code__c = '46032'
        );
        insert ruud;
        Id idRuud = ruud.Id;
        
        // Get the Record again so we get the service identifier formula
        ruud = [select 
                Source_Name__c,
                Platform_Id__c,
                Service_Type__c,
                Channel_Type__c,
                Service_Class__c,
                Destination_Country_Code__c,
                Billable_6__c,
                Billable_30__c,
                Billable_60__c,
                Start_Time__c,
                Service_Identifier__c,
                Inbound_Device__c
                from Rolled_Up_Usage_Data__c
                where Id = :idRuud
               ];
        return ruud;
    }


    // Utilising this method in CloudBillingSureTaxTest. Access Specifier should be pulic - Added by Vijay - Jul 13th 2017
    public static void insertServices() {
        Service__c objService11 = new Service__c (
            Name = 'Inbound Wireline (US)',
            Description__c = 'Inbound Wireline (US)',
            UID__c = 11,
            Channel_Type_Value__c = 1,
            Device_Type_Value__c = 3,
            Service_Type_Value__c = 2,
            Country_Code__c = 1,
            Country_Code_ISO__c = 'US',
            SubCampaign_Type_Value__c = 2,
            Service_Class__c = 0,
            Active__c = TRUE
        );
        insert objService11;
        System.Debug('insertServices: Inserted Service ' + objService11.Name + ' Id:' + objService11.Id);
        
        Service__c objService151 = new Service__c (
            Name = 'Wireless Outbound (US)',
            Description__c = 'Wireless Outbound (US)',
            UID__c = 151,
            Channel_Type_Value__c = 1,
            Device_Type_Value__c = 13,
            Service_Type_Value__c = 1,
            Country_Code__c = 1,
            Country_Code_ISO__c = 'US',
            SubCampaign_Type_Value__c = 0,
            Service_Class__c = 0,
            Active__c = TRUE,
            SureTax_Transaction_Type_Code__c = '050104',
            Use_Calling_Rates__c = true
        );
        insert objService151;
        System.Debug('insertServices: Inserted Service ' + objService151.Name + ' Id:' + objService151.Id);
        
        Service__c objService5100151 = new Service__c (
            Name = 'Outbound Use Rate Table',
            Description__c = 'Outbound Use Rate Table',
            UID__c = 5100151,
            Channel_Type_Value__c = 1,
            Device_Type_Value__c = 13,
            Service_Type_Value__c = 1,
            Country_Code__c = 0,
            Country_Code_ISO__c = 'X',
            SubCampaign_Type_Value__c = 0,
            Service_Class__c = 0,
            Active__c = TRUE
        );
        insert objService5100151;
        System.Debug('insertServices: Inserted Service ' + objService5100151.Name + ' Id:' + objService5100151.Id);
        
    }
    
    @isTest(SeeAllData=false)
    static void testContractCreationAndRating() {

        List<SureTax_Settings__c> list_SureTaxSettings = SureTaxSettingsFactory.createDefaultSureTaxSettings();
        for (SureTax_Settings__c objSureTaxSetting : list_SureTaxSettings) {
            if (objSureTaxSetting.Name == 'SureTaxEnabled') {
                objSureTaxSetting.Value__c = 'False';
            }
        }
        insert list_SureTaxSettings;

        insertServices();
        
        List<Rolled_Up_Usage_Data__c> list_ruud = CloudBillingTestUtil.insertRuud();
        System.debug('testContractCreationAndRating.list_ruud: ' + list_ruud);
        
        GCR_Content_Document_Detail__c contract = CloudBillingTestUtil.createAndInsertCloudBillingContract(list_ruud);
        Id acctId = contract.Account_Name__c;

        Cloud_Deployment__c cd = new Cloud_Deployment__c(Account__c = acctId, Tenant_ID__c = 'Tenant123');
        insert cd;
        System.Debug('testContractCreationAndRating: Save of Cloud Deployment ' + cd);
        Cloud_Deployment_To_Contract_Junction__c objCDCJ = new Cloud_Deployment_To_Contract_Junction__c(Contract__c = contract.Id, Cloud_Deployment__c = cd.Id);
        insert objCDCJ;
        System.Debug('testContractCreationAndRating: Save of Cloud Deployment Contract Junction ' + objCDCJ);
        Cloud_Deployment__c cd2 = [select Id, Tenant_ID__c, BE_Tenant_Id_Hash__c from Cloud_Deployment__c where Id = :cd.Id];
        System.assertEquals(cd2.BE_Tenant_Id_Hash__c, 'BEEEC#Tenant123');
        
        Cloud_Billing_Log__c objLog = CloudBillingUtil.createNewCloudBillingLog('Rating', 'Submitted');
        insert objLog;
        System.Debug('testContractCreationAndRating: Insert of Cloud_Billing_Log__c ' + objLog);
        
        // Invoke batch Job to process Usage Data
        Test.startTest();
        BatchRateCloudUsageData objBatch = new BatchRateCloudUsageData();
        objBatch.objJobLog = objLog;
        //***when test class is executed the batch limit should be restricted*/
        Database.executeBatch(objBatch, 200);
        Test.stopTest();
 
        List<Service_Usage__c> list_ServiceUsage = [select
                                                    Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Units_Type__c,
                                                    Quantity__c,
                                                    Rolled_Up_Usage_Data__r.Billable_60__c
                                                    from Service_Usage__c];
        System.debug('testContractCreationAndRating: Got List Size ' + list_ServiceUsage.size());
        // For now we are assuming the tests are set up to correctly rate all RUUD records.
        // This logic would need changing if we intentionally do not rate any number of RUUDs
        System.assertEquals(list_ruud.size(), list_ServiceUsage.size());
        for (Service_Usage__c su : list_ServiceUsage) {
            System.debug('testContractCreationAndRating: Checking Resulting su ' + su);
            if (su.Contract_Tier_Set_Month__r.Contract_Tier_Set__r.Units_Type__c == 'Minutes(60s ceiling)') {
                System.assertEquals(su.Quantity__c*60, su.Rolled_Up_Usage_Data__r.Billable_60__c);
            } else {
                System.assert(false);
            }
        }
/*
        // Added by Vijay - Jul 3rd 2017 - Start
        for (SureTax_Settings__c objSureTaxSetting : list_SureTaxSettings) {
            if (objSureTaxSetting.Name == 'SureTaxEnabled') {
                System.Debug('testContractCreationAndRating: Setting SureTaxEnabled to True');
                objSureTaxSetting.Value__c = 'True';
            }
        }
        update list_SureTaxSettings;
        System.Debug('testContractCreationAndRating: list_SureTaxSettings ' + list_SureTaxSettings);
        
        BatchRateCloudUsageData objBatch2 = new BatchRateCloudUsageData();
        Database.executeBatch(objBatch2, 200);
        // Added by Vijay - Jul 3rd 2017 - End
        Test.stopTest();
*/        
    }
    
    
    @isTest
    public static void testBatchCreatCloudMonthlySalesOrderInfo(){
        BatchCreateCloudMonthlySalesOrdersInfo obj = new BatchCreateCloudMonthlySalesOrdersInfo(false, '8', '2017');
        obj.debug();
    }
    
   
   
    

    // Addedy by Vijay - end

    
    private static void insertCallingRate()
    {
        insert new Calling_Rate__c(
                Region_Code__c = 'US',
                Destination_Country_Code__c = '1',
                Destination_Career_Digits__c = 'default',
                Destination_Description__c = 'United States - Contiguous',
                Rate_Per_Minute__c = 0.0400,
                Effective_End_Date__c = Date.Today().addYears(1),
                Effective_Start_Date__c = Date.Today().addYears(-1),
                RecordTypeId = '0120B000000QwgfQAC'
                );
    }
    
    

}