@isTest 
public class BatchRateCloudUsageDataTest {
    @isTest(SeeAllData=false)
    static void testContractCreationAndRating() {
        Rolled_Up_Usage_Data__c ruud = CloudBillingTestUtil.insertRolledUpUsageDataInboundUS();
        System.debug('ruud' + ruud);
        List<String> listContractServiceIdentifiers = new List<String>();
        listContractServiceIdentifiers.add(ruud.Service_Identifier__c);
        Map<String, String> map_CarrierDigitsToCarrierName = new Map<String, String>();
        map_CarrierDigitsToCarrierName.put('test', '123');
        List<String> list_carrierIds = BatchRateCloudUsageData.pushCarrierContractServiceIdentifiers(ruud, listContractServiceIdentifiers, map_CarrierDigitsToCarrierName);
        for (String strCarrierId : list_carrierIds) {
            System.debug('strCarrierId ' + strCarrierId);
            System.assertEquals(strCarrierId, '123#' + ruud.Service_Identifier__c);
        }
        //(Rolled_Up_Usage_Data__c objRollUpData, List<String> listContractServiceIdentifiers, Map<String, String> map_CarrierDigitsToCarrierName) {
    }
    /*
     *     private List<String> pushCarrierContractServiceIdentifiers(Rolled_Up_Usage_Data__c objRollUpData, 
     * List<String> listContractServiceIdentifiers, Map<String, String> map_CarrierDigitsToCarrierName) {
        if (map_CarrierDigitsToCarrierName.containsKey(objRollUpData.Destination_Device_Career__c)) {
            List<String> listCarrierContractServiceIdentifiers = new List<String>();
            String strCarrierDigits = map_CarrierDigitsToCarrierName.get(objRollUpData.Destination_Device_Career__c);
            for (String strContractServiceIdentifier : listContractServiceIdentifiers) {
                String strNewContractServiceIdentifier = strCarrierDigits + '#' + strContractServiceIdentifier;
                System.Debug('pushCarrierContractServiceIdentifiers: Adding dynamic carrier contract service identifer ' + strNewContractServiceIdentifier);
                listCarrierContractServiceIdentifiers.add(strNewContractServiceIdentifier);
            }
            return listCarrierContractServiceIdentifiers;
        }
        return null;
    }
     */
    
    // Added by Vijay  - Jul 25th 2017 - Start
    @TestSetup
    static void setupData(){
        Util.Bypass_Trigger_Chk = true;
        SureTax_Settings__c objSureTaxSetting = new SureTax_Settings__c(name = 'SureTaxEnabled' , value__c = 'false');
        insert objSureTaxSetting;
        
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
        
        Cloud_Deployment__c obj_CDs = CloudBillingTestUtil.setupCloudDeploymentPureConnectAndJunction(objContract);
        
        Cloud_Deployment_To_Contract_Junction__c objCDTCJ = setupCloudDeploymentToContractJunction(objContract,obj_CDs);
        
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
    
    
    static testmethod void testBatch1(){
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
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = 200;
        	objRUUD.Service_Type__c = 2;
        }
        update list_RUUDs;
        Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
    }
    
    static testmethod void testBatch9(){
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
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = 200;
        	objRUUD.Service_Type__c = 2;
        }
        update list_RUUDs;
        
        zqu__Quote__c objQuote = [SELECT Id, zqu__Currency__c FROM  zqu__Quote__c LIMIT 1];
        objQuote.zqu__Currency__c = NULL;
        update objQuote;
        Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
    }
    
    static testmethod void testBatch10(){
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
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = 200;
        	objRUUD.Service_Type__c = 2;
        }
        update list_RUUDs;
        
        List<Contract_Tier_Set__c> list_CTS = [SELECT Id, Period_In_Months__c FROM Contract_Tier_Set__c ];
        
        for(Contract_Tier_Set__c obj : list_CTS ){
        	obj.Period_In_Months__c = '1';
        }
        update list_CTS;
        
        Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
    }
    
	static testmethod void testBatch7(){
		SureTax_Settings__c objSureTaxSetting = [SELECT name , Id, value__c FROM SureTax_Settings__c WHERE name = 'SureTaxEnabled'];
	    objSureTaxSetting.value__c = 'true';
	    update objSureTaxSetting;
	    Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
	}
	
	static testmethod void testBatch8(){
		GCR_Content_Document_Detail__c objContract = [SELECT id, Status__c FROM GCR_Content_Document_Detail__c LIMIT 1];
		objContract.Status__c = 'In Progress';
		update objContract;
	    Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
	}
	
	static testmethod void testBatch11(){
		GCR_Content_Document_Detail__c objContract = [SELECT id, Status__c FROM GCR_Content_Document_Detail__c LIMIT 1];
		//objContract.Status__c = 'In Progress';
		delete objContract;
	    Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
	}
	
	static testmethod void testBatch12(){
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
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = 200;
        	objRUUD.Service_Type__c = 2;
        	objRUUD.Source_Name__c = 'PCL';
        }
        update list_RUUDs;
	    Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
	}
	
	static testmethod void testBatch13(){
		List<Rolled_Up_Usage_Data__c> list_RUUDs = [select Source_Name__c, Calling_Rate_Identifier_Inbound__c, 
                                                    Platform_Id__c, Count__c , 
                                                    Service_Type__c, Total_Duration__c, Gigabyte_Count__c, 
                                                    Channel_Type__c, Service_Class__c, Destination_Country_Code__c,
                                                    Billable_6__c, GARN_Account_Code__c,
                                                    Billable_30__c,
                                                    Billable_60__c,
                                                    Start_Time__c,
                                                    Service_Identifier__c, 
                                                    Destination_Device_Career__c, Device_Steering_Digits__c
                                                    from Rolled_Up_Usage_Data__c];
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = 200;
        	objRUUD.Service_Type__c = 2;
        	objRUUD.Device_Steering_Digits__c = 'X';
        	objRUUD.GARN_Account_Code__c = NULL;
        }
        update list_RUUDs;
        GCR_Content_Document_Detail__c objContract = [SELECT id, Status__c FROM GCR_Content_Document_Detail__c LIMIT 1];
		objContract.Status__c = 'In Progress';
		update objContract;
	    Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
	}
	
	static testmethod void testBatch14(){
		List<Rolled_Up_Usage_Data__c> list_RUUDs = [select Source_Name__c, Calling_Rate_Identifier_Inbound__c, 
                                                    Platform_Id__c, Count__c , 
                                                    Service_Type__c, Total_Duration__c, Gigabyte_Count__c, 
                                                    Channel_Type__c, Service_Class__c, Destination_Country_Code__c,
                                                    Billable_6__c, GARN_Account_Code__c,
                                                    Billable_30__c,
                                                    Billable_60__c,
                                                    Start_Time__c,
                                                    Service_Identifier__c, 
                                                    Destination_Device_Career__c, Device_Steering_Digits__c
                                                    from Rolled_Up_Usage_Data__c];
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = 200;
        	objRUUD.Service_Type__c = 2;
        }
        update list_RUUDs;
        GCR_Content_Document_Detail__c objContract = [SELECT id, Status__c FROM GCR_Content_Document_Detail__c LIMIT 1];
		objContract.Pricing_Start_Date__c = list_RUUDs[0].Start_Time__c.date().addDays(5);
		update objContract;
	    Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
	}
	
	static testmethod void testBatch15(){
		List<Rolled_Up_Usage_Data__c> list_RUUDs = [select Source_Name__c, Calling_Rate_Identifier_Inbound__c, 
                                                    Platform_Id__c, Count__c , 
                                                    Service_Type__c, Total_Duration__c, Gigabyte_Count__c, 
                                                    Channel_Type__c, Service_Class__c, Destination_Country_Code__c,
                                                    Billable_6__c, GARN_Account_Code__c,
                                                    Billable_30__c,
                                                    Billable_60__c,
                                                    Start_Time__c,
                                                    Service_Identifier__c, 
                                                    Destination_Device_Career__c, Device_Steering_Digits__c
                                                    from Rolled_Up_Usage_Data__c];
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = 200;
        	objRUUD.Service_Type__c = 2;
        }
        update list_RUUDs;
        GCR_Content_Document_Detail__c objContract = [SELECT id, Status__c FROM GCR_Content_Document_Detail__c LIMIT 1];
		objContract.Pricing_End_Date__c = list_RUUDs[0].Start_Time__c.date().addDays(-5);
		update objContract;
	    Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
	}
	
	static testmethod void testBatch16(){
		List<Rolled_Up_Usage_Data__c> list_RUUDs = [select Source_Name__c, Calling_Rate_Identifier_Inbound__c, 
                                                    Platform_Id__c, Count__c , 
                                                    Service_Type__c, Total_Duration__c, Gigabyte_Count__c, 
                                                    Channel_Type__c, Service_Class__c, Destination_Country_Code__c,
                                                    Billable_6__c, GARN_Account_Code__c,
                                                    Billable_30__c,
                                                    Billable_60__c,
                                                    Start_Time__c,
                                                    Service_Identifier__c, 
                                                    Destination_Device_Career__c, Device_Steering_Digits__c
                                                    from Rolled_Up_Usage_Data__c];
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = null;
        	objRUUD.Service_Type__c = 2;
        }
        update list_RUUDs;
	    Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
	}
	
	static testmethod void testBatch17(){
		List<Rolled_Up_Usage_Data__c> list_RUUDs = [select Source_Name__c, Calling_Rate_Identifier_Inbound__c, 
                                                    Platform_Id__c, Count__c , 
                                                    Service_Type__c, Total_Duration__c, Gigabyte_Count__c, 
                                                    Channel_Type__c, Service_Class__c, Destination_Country_Code__c,
                                                    Billable_6__c, GARN_Account_Code__c,
                                                    Billable_30__c,
                                                    Billable_60__c,
                                                    Start_Time__c,
                                                    Service_Identifier__c, 
                                                    Destination_Device_Career__c, Device_Steering_Digits__c
                                                    from Rolled_Up_Usage_Data__c];
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = 200;
        	objRUUD.Service_Type__c = 1;
        }
        update list_RUUDs;
        List<Service__c> list_Services = [SELECT Id, Service_Type_Value__c, Use_Calling_Rates__c FROM Service__c];
        for(Service__c objService :  list_Services){
        	objService.Service_Type_Value__c = 1;
        	objService.Use_Calling_Rates__c = true;
        }
        update list_Services;
	    Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
	}
	
	static testmethod void testBatch18(){
		List<Rolled_Up_Usage_Data__c> list_RUUDs = [select Source_Name__c, Calling_Rate_Identifier_Inbound__c, 
                                                    Platform_Id__c, Count__c , 
                                                    Service_Type__c, Total_Duration__c, Gigabyte_Count__c, 
                                                    Channel_Type__c, Service_Class__c, Destination_Country_Code__c,
                                                    Billable_6__c, GARN_Account_Code__c,
                                                    Billable_30__c,
                                                    Billable_60__c,
                                                    Start_Time__c,
                                                    Service_Identifier__c, 
                                                    Destination_Device_Career__c, Device_Steering_Digits__c
                                                    from Rolled_Up_Usage_Data__c];
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = 200;
        	objRUUD.Service_Type__c = 1;
        	objRUUD.Device_Steering_Digits__c = 'X';
        }
        update list_RUUDs;
        List<Service__c> list_Services = [SELECT Id, Service_Type_Value__c, Use_Calling_Rates__c FROM Service__c];
        for(Service__c objService :  list_Services){
        	objService.Service_Type_Value__c = 1;
        	objService.Use_Calling_Rates__c = true;
        }
        update list_Services;
	    Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
	}
	
	static testmethod void testBatch19(){
		List<Rolled_Up_Usage_Data__c> list_RUUDs = [select Source_Name__c, Calling_Rate_Identifier_Inbound__c, 
                                                    Platform_Id__c, Count__c , 
                                                    Service_Type__c, Total_Duration__c, Gigabyte_Count__c, 
                                                    Channel_Type__c, Service_Class__c, Destination_Country_Code__c,
                                                    Billable_6__c, GARN_Account_Code__c,
                                                    Billable_30__c,
                                                    Billable_60__c,
                                                    Start_Time__c,
                                                    Service_Identifier__c, 
                                                    Destination_Device_Career__c, Device_Steering_Digits__c
                                                    from Rolled_Up_Usage_Data__c];
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = 200;
        	objRUUD.Service_Type__c = 2;
        }
        update list_RUUDs;
        List<Service__c> list_Services = [SELECT Id, Service_Type_Value__c, Use_Calling_Rates__c FROM Service__c];
        for(Service__c objService :  list_Services){
        	objService.Use_Calling_Rates__c = true;
        }
        update list_Services;
	    Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
	}
	
    static testmethod void testBatch2(){
        List<Calling_Rate__c> list_CallingRates = [SELECT id, Region_Code__c, Destination_Country_Code__c,Destination_Career_Digits__c,
                                                    Destination_Description__c,Rate_Per_Minute__c ,Effective_End_Date__c ,
                                                    Effective_Start_Date__c ,RecordTypeId
                                                  FROM Calling_Rate__c];
        Map<String,List<Calling_Rate__c>> map_CallRating = new Map<String,List<Calling_Rate__c>>{'Test' => list_CallingRates};
        List<Rolled_Up_Usage_Data__c> list_RUUDs = [select Source_Name__c, Calling_Rate_Identifier_Inbound__c, 
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
                                                    Destination_Device_Career__c 
                                                    from Rolled_Up_Usage_Data__c];
        
        List<Inbound_Calling_Rate__c> list_ICRs = [SELECT Id, Effective_Start_Date__c , 
                                                     Effective_End_Date__c ,Rate_Wireline__c , Rate_Wireless__c 
                                                   FROM Inbound_Calling_Rate__c];
        Map<String,List<Inbound_Calling_Rate__c>> map_InboundRateIdentifierToCallingRate = new Map<String,List<Inbound_Calling_Rate__c>>{
                                                                                            list_RUUDs[0].Calling_Rate_Identifier_Inbound__c => list_ICRs
                                                                                        };
        
        list_RUUDs[1].Exception_Type__c = 'Other';
        update list_RUUDs[1];
        Test.startTest();
        BatchRateCloudUsageData objBRCUD = new BatchRateCloudUsageData();
        objBRCUD.concatComment('Test Comment' , 'test String');
        //objBRCUD.isRUUDForSureTax('PCL');
        objBRCUD.getCallingRateFromHash(map_CallRating , 'Test' ,  Date.Today());
        objBRCUD.getInboundCallingRateFromHash(map_InboundRateIdentifierToCallingRate , list_RUUDs[0] , 3);
        objBRCUD.getInboundCallingRateFromHash(map_InboundRateIdentifierToCallingRate , list_RUUDs[0] , 13);
        objBRCUD.createNewBillingException('test desc' , list_RUUDs[1] , null , null);
        Test.stopTest();
    }
    
    static testmethod void testBatch3(){
        List<Rolled_Up_Usage_Data__c> list_RUUDs = [select Source_Name__c, Calling_Rate_Identifier_Inbound__c,
                                                    Activity_Type__c,
                                                    Platform_Id__c, Count__c, 
                                                    Service_Type__c, Total_Duration__c, Gigabyte_Count__c, 
                                                    Channel_Type__c, Service_Class__c, Destination_Country_Code__c,
                                                    Billable_6__c,
                                                    Billable_30__c,
                                                    Billable_60__c,
                                                    Start_Time__c,
                                                    Service_Identifier__c, 
                                                    Destination_Device_Career__c 
                                                    from Rolled_Up_Usage_Data__c];
        Service_Usage__c objServiceUsage = new Service_Usage__c();
        Test.startTest();
        BatchRateCloudUsageData objBRCUD = new BatchRateCloudUsageData();
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , null);
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Messages/Seats/Ports');
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Minutes(12s/message)');
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Minutes(6s ceiling)');
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Minutes(30s ceiling)');
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Minutes(60s ceiling)');
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Minutes(6s/message)');
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Minutes(Actual)');
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Gigabytes');
        list_RUUDs[0].Count__c = 10;
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Messages/Seats/Ports');
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Minutes(12s/message)');
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Minutes(6s/message)');
        list_RUUDs[0].Billable_6__c = 60;
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Minutes(6s ceiling)');
        list_RUUDs[0].Billable_30__c  = 60;
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Minutes(30s ceiling)');
        list_RUUDs[0].Billable_60__c = 60 ;
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Minutes(60s ceiling)');
        list_RUUDs[0].Total_Duration__c = 60 ;
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Minutes(Actual)');
        list_RUUDs[0].Gigabyte_Count__c = 6 ; 
        BatchRateCloudUsageData.populateQuantity(list_RUUDs[0] , objServiceUsage , 'Gigabytes');
        objBRCUD.populateMissingGARNCodes();
        delete list_RUUDs;
        objBRCUD.populateMissingGARNCodes();
    }
    
    static testmethod void testBatch4(){
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
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = 200;
        }
        update list_RUUDs;
        GCR_Content_Document_Detail__c objContract = [SELECT Id , Pricing_Start_Date__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Pricing_Start_Date__c = list_RUUDs[0].Start_Time__c.date().adddays(5);
        Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
		SureTax_Settings__c objSureTaxSetting = [SELECT name , Id, value__c FROM SureTax_Settings__c WHERE name = 'SureTaxEnabled'];
        objSureTaxSetting.value__c = 'true';
        update objSureTaxSetting;
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
    }
    
    static testmethod void testBatch5(){
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
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = 200;
        }
        update list_RUUDs;
        GCR_Content_Document_Detail__c objContract = [SELECT Id , Pricing_End_Date__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Pricing_End_Date__c = list_RUUDs[0].Start_Time__c.date().adddays(-5);
        Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
		SureTax_Settings__c objSureTaxSetting = [SELECT name , Id, value__c FROM SureTax_Settings__c WHERE name = 'SureTaxEnabled'];
        objSureTaxSetting.value__c = 'true';
        update objSureTaxSetting;
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
    }
    
    static testmethod void testBatch6(){
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
        for(Rolled_Up_Usage_Data__c objRUUD :  list_RUUDs ){
        	objRUUD.Count__c = 200;
        	objRUUD.Service_Type__c = 2;
        }
        update list_RUUDs;
        GCR_Content_Document_Detail__c objContract = [SELECT Id , Pricing_End_Date__c FROM GCR_Content_Document_Detail__c LIMIT 1];
        objContract.Pricing_End_Date__c = list_RUUDs[0].Start_Time__c.date().adddays(-5);
        Test.startTest();
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
		SureTax_Settings__c objSureTaxSetting = [SELECT name , Id, value__c FROM SureTax_Settings__c WHERE name = 'SureTaxEnabled'];
        objSureTaxSetting.value__c = 'true';
        update objSureTaxSetting;
        Database.executeBatch(new BatchRateCloudUsageData(), 50);
        Test.stopTest();
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
    	 TestCloudBillingRating.insertServices();
    	 return [SELECT id, Name,
			            Description__c,
			            UID__c,
			            Channel_Type_Value__c,
			            Device_Type_Value__c ,
			            Service_Type_Value__c ,
			            Country_Code__c ,
			            Country_Code_ISO__c ,
			            SubCampaign_Type_Value__c,
			            Service_Class__c ,
			            Active__c  FROM Service__c
	 			];
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
    // Added by Vijay  - Jul 25th 2017 - End
}