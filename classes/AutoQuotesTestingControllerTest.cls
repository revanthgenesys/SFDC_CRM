/*
 * Class            : AutoQuotesTestingControllerTest
 * Description      : Test Class for AutoQuotesTestingController.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Jul 03, 2017
 * Test Class       : N/A 
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Modified BY		Modified Date		Changes/ Notes
 * ----------------------------------------------------------------------------------------------
 *
 */ 
@isTest
private class AutoQuotesTestingControllerTest {
    
    @isTest
    static void testAutoQuotesTestingController(){
    	setupTestData('PureEngage', 'Customer');
    	Account testAccount = [SELECT id FROM Account LIMIT 1];
    	Test.startTest();
    	Test.setCurrentPageReference(Page.AutoQuotesTesting);
		AutoQuotesTestingController controller = new AutoQuotesTestingController();
		controller.contactObj.AccountId = testAccount.Id;
		controller.refresh();
    	controller.editMode();
    	controller.cancelEdit();
    	Util.Bypass_Trigger_Chk = true;
    	controller.saveAccount();
    	Util.Bypass_Trigger_Chk = false;
    	PageReference pg1 = controller.generateAutoQuotesRegular();
    	PageReference pg2 = controller.generateAutoQuotesGap();
    	controller.deleteQuotes();
    	// controller.lmsSync();
    	Test.stopTest();
    	
    }
    
    
	static void setupTestData(String OfferingType, String accountType){
    	// Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;

		List<Country__c>  testCountries = new List<Country__c>();
		testCountries.add(new Country__c(
	        Name = 'United States', Region__c = 'North America', DAP_Region__c = 'NA', ISO_Code__c = 'USD',  Country__c = 'USA',
	        SW_Download_Site__c = 'Canada', Old_DAP_Region__c = 'NA', Old_Sub_Region__c = 'North America', Old_Sub_Sub_Region__c = 'USA',
	        price_book__c = 'NA-USD', Old_Price_Book__c = 'G5_NA_USD', New_Price_Book__c = 'NG5_NA_USD',
	        Big_Four__c = 'North America', Big_Six__c = 'North America',
	        Basic_Care_New_End_User__c = 18.0, Basic_Care_New_Partner__c = 18.0,
	        Business_Care_New_End_User__c = 18.0, Business_Care_New_Partner__c = 18.0,
	        Premium_Care_New_End_User__c = 18.0, Premium_Care_New_Partner__c = 18.0,
	        Basic_Care_Renewal_End_User__c = 18.0, Basic_Care_Renewal_Partner__c = 18.0,
	        Business_Care_Renewal_End_User__c = 18.0, Business_Care_Renewal_Partner__c = 18.0,
	        Premium_Care_Renewal_End_User__c = 18.0, Premium_Care_Renewal_Partner__c = 18.0,
	        Business_Care_New_End_User_Licensing__c = 18.0, Premium_Care_New_End_User_Licensing__c = 18.0,
	        Business_Care_New_Partner_Licensing__c = 18.0, Premium_Care_New_Partner_Licensing__c = 18.0,
	        Basic_Support__c = 18.0, Standard_Support__c = 18.0, Priority_Support__c = 18.0, VIP_Priority_Support__c = 18.0
        ));
		testCountries.add(new Country__c(
	        Name = 'Canada', Region__c = 'North America', DAP_Region__c = 'NA', ISO_Code__c = 'CAD',  Country__c = 'Canada',
	        SW_Download_Site__c = 'Netherlands', Old_DAP_Region__c = 'NA', Old_Sub_Region__c = 'North America', Old_Sub_Sub_Region__c = 'Canada',
	        price_book__c = 'NA-USD', Old_Price_Book__c = 'G5_NA_USD', New_Price_Book__c = 'NG5_NA_USD',
	        Big_Four__c = 'North America', Big_Six__c = 'North America',
	        Basic_Care_New_End_User__c = 18.0, Basic_Care_New_Partner__c = 18.0,
	        Business_Care_New_End_User__c = 18.0, Business_Care_New_Partner__c = 18.0,
	        Premium_Care_New_End_User__c = 18.0, Premium_Care_New_Partner__c = 18.0,
	        Basic_Care_Renewal_End_User__c = 18.0, Basic_Care_Renewal_Partner__c = 18.0,
	        Business_Care_Renewal_End_User__c = 18.0, Business_Care_Renewal_Partner__c = 18.0,
	        Premium_Care_Renewal_End_User__c = 18.0, Premium_Care_Renewal_Partner__c = 18.0,
	        Business_Care_New_End_User_Licensing__c = 18.0, Premium_Care_New_End_User_Licensing__c = 18.0,
	        Business_Care_New_Partner_Licensing__c = 18.0, Premium_Care_New_Partner_Licensing__c = 18.0,
	        Basic_Support__c = 18.0, Standard_Support__c = 18.0, Priority_Support__c = 18.0, VIP_Priority_Support__c = 18.0
        ));
        insert testCountries;
		
		List<State_Province__c> testStates = new List<State_Province__c>();
		testStates.add(new State_Province__c(Name = 'GA', Country__c = testCountries[0].Id));
		testStates.add(new State_Province__c(Name = 'MI', Country__c = testCountries[0].Id));
		testStates.add(new State_Province__c(Name = 'Alberta', Country__c = testCountries[1].Id));
		testStates.add(new State_Province__c(Name = 'British Columbia', Country__c = testCountries[1].Id));
		insert testStates; 
    	
    	List<Account> testAccounts = new List<Account>(); 
    	testAccounts.add(new Account(Name = 'Customer Account 1', AccountNameNative__c = 'Customer Account 1', Status__c = 'Active', Country__c = testCountries[0].Id, 
									Type = 'Customer', Genesys_Care_specialist__c = UserInfo.getUserId(), Genesys_Care_Ops__c = UserInfo.getUserId(),
									Genesys_Care_Offering__c = 'Business Care-Renewal(End User)', Support_Option__c = 'Basic Support',
									Software_Price_Multiplier__c = 30.0, Education_Price_Multiplier__c = 40.0, 
									Auto_Renew_Eligible__c = true, Auto_Renew_Anniversary__c = Date.Today().addDays(120), Auto_Renew_Contract_Term__c = 24,
									Auto_Renew_Rate__c = 22.0, Increased_Percentage__c = false, Auto_Renew_Contractual_Increase__c = 5.0));
    	testAccounts.add(new Account(Name = 'Partner Account 1', AccountNameNative__c = 'Partner Account 1', Status__c = 'Active', Country__c = testCountries[0].Id, 
									Type = 'Partner', Genesys_Care_specialist__c = UserInfo.getUserId(), Genesys_Care_Ops__c = UserInfo.getUserId(),
									Genesys_Care_Offering__c = 'Business Care-Renewal(End User)', Support_Option__c = 'Basic Support',
									Software_Price_Multiplier__c = 30.0, Education_Price_Multiplier__c = 40.0, 
									Auto_Renew_Eligible__c = true, Auto_Renew_Anniversary__c = Date.Today().addDays(180), Auto_Renew_Contract_Term__c = 24,
									Auto_Renew_Rate__c = 22.0, Increased_Percentage__c = false, Auto_Renew_Contractual_Increase__c = 5.0));
		insert testAccounts; 										 
		
		List<Contact> testContacts = new List<Contact>();
		for( Integer i=0; i < 5; i++ ) {
            testContacts.add(new Contact(FirstName = 'FN' + i, LastName = 'LN' + i, Email = 'test'+i+'@genesys.com', Send_Quote__c = true, accountId = testAccounts[0].id));
        }
        
		for( Integer i=5; i < 10; i++ ) {
            testContacts.add(new Contact(FirstName = 'FN' + i, LastName = 'LN' + i, Email = 'test'+i+'@genesys.com', Send_Quote__c = true, accountId = testAccounts[1].id));
        }
        
		insert testContacts;
				
		ID BaseItemRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();  
		ID CoreProductRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('CORE - Product Record Type').getRecordTypeId();  
		
		List<Product2> testProducts = new List<Product2>();
		// Care Products for Genesys Care 
		testProducts.add(new Product2(Name = 'Business Care-Renewal(End User)', Description = 'Business Care-Renewal(End User)', Product_Name__c = 'Business Care-Renewal(End User)',
										Description__c = 'Business Care-Renewal(End User)', Gore_Integration_ID__c = '10001',  APN_Number__c = '10001',
										RecordTypeId = BaseItemRT, Price_Type__c = 'Fixed Price', Product_Option__c = 'Quantity',
										Base_Item__c = 'Business Care-Renewal(End User)', BaseItem_MML_Id__c = '10001', IsActive = true,
										Availability_Status__c = 'Active', Price_Permission__c = 'Public', Family = '1.0.0', Third_Party__c	= NULL,
										Type__c	 = 'Genesys Care',  Base_Item_Lookup__c = NULL, Care_Rate_Applicable__c = 'Business_Care_Renewal_End_User__c',
										BRAZIL_R_Price__c = -1.00, NG1_APAC_ANZ_AUD_Price__c	= -1.00, G1_APAC_AUD_Price__c = -1.00,
										NG1_APAC_KOREA_SE_ASIA_USD_Price__c = -1.00, G1_APAC_USD_Price__c = -1.00, NG1_APAC_USD_Price__c = -1.00, 
										G2_CALA_USD_Price__c = -1.00, NG2_BRAZIL_BRL_Price__c = -1.00, G3_EMEA_EUR_Price__c	= -1.00, NG2_CALA_USD_Price__c = -1.00,
										G3_EMEA_GBP_Price__c = -1.00, NG3_EMEA_EUR_Price__c	= -1.00, G3_EMEA_USD_Price__c	= -1.00, NG3_EMEA_GBP_Price__c	= -1.00,
										G4_JAPAN_JPY_Price__c = -1.00, NG3_EMEA_USD_Price__c = -1.00, G5_NA_CAD_Price__c = -1.00, NG4_APAC_CHINA_INDIA_USD_Price__c	= -1.00,
										G5_NA_USD_Price__c = -1.00, NG4_APAC_JAPAN_YEN_Price__c	= -1.00, NG5_NZD_Price__c	= -1.00, NG5_NA_USD_Price__c	= -1.00,
										NG5_ZAR_Price__c = -1.00, NG5_NA_CAD_Price__c	= -1.00,
										NG1_PPU_Silver_USD__c	= -1.00, NG1_PPU_USD__c		= -1.00, NG1_PPU_Gold_USD__c	= -1.00
								));
								 
		testProducts.add(new Product2(Name = 'Basic Support',  Description = 'Basic Support', Product_Name__c = 'Basic Support',
										Description__c = 'Basic Support', Gore_Integration_ID__c = '10002', APN_Number__c = '10002',
										RecordTypeId = BaseItemRT, Price_Type__c = 'Fixed Price', Product_Option__c = 'Quantity',
										Base_Item__c = 'Priority Support', BaseItem_MML_Id__c = '10002', IsActive = true,
										Availability_Status__c = 'Active', Price_Permission__c = 'Public', Family = '1.0.0', Third_Party__c	= NULL,
										Type__c	 = 'Genesys Care',  Base_Item_Lookup__c = NULL, Care_Rate_Applicable__c = 'Basic_Support__c',
										BRAZIL_R_Price__c = -1.00, NG1_APAC_ANZ_AUD_Price__c	= -1.00, G1_APAC_AUD_Price__c = -1.00,
										NG1_APAC_KOREA_SE_ASIA_USD_Price__c = -1.00, G1_APAC_USD_Price__c = -1.00, NG1_APAC_USD_Price__c = -1.00, 
										G2_CALA_USD_Price__c = -1.00, NG2_BRAZIL_BRL_Price__c = -1.00, G3_EMEA_EUR_Price__c	= -1.00, NG2_CALA_USD_Price__c = -1.00,
										G3_EMEA_GBP_Price__c = -1.00, NG3_EMEA_EUR_Price__c	= -1.00, G3_EMEA_USD_Price__c	= -1.00, NG3_EMEA_GBP_Price__c	= -1.00,
										G4_JAPAN_JPY_Price__c = -1.00, NG3_EMEA_USD_Price__c = -1.00, G5_NA_CAD_Price__c = -1.00, NG4_APAC_CHINA_INDIA_USD_Price__c	= -1.00,
										G5_NA_USD_Price__c = -1.00, NG4_APAC_JAPAN_YEN_Price__c	= -1.00, NG5_NZD_Price__c	= -1.00, NG5_NA_USD_Price__c	= -1.00,
										NG5_ZAR_Price__c = -1.00, NG5_NA_CAD_Price__c	= -1.00,
										NG1_PPU_Silver_USD__c	= -1.00, NG1_PPU_USD__c		= -1.00, NG1_PPU_Gold_USD__c	= -1.00
								));
		
		testProducts.add(new Product2(Name = 'Custom App Support (Partner)', Description = 'Custom App Support (Partner)', Product_Name__c = 'Custom App Support (Partner)',
										Description__c = 'Custom App Support (Partner)', Gore_Integration_ID__c = '10003', APN_Number__c = '10003', 
										RecordTypeId = BaseItemRT, Price_Type__c = 'Fixed Price', Product_Option__c = 'Quantity',
										Base_Item__c = 'Custom App Support (Partner)', BaseItem_MML_Id__c = '10003', IsActive = true,
										Availability_Status__c = 'Active', Price_Permission__c = 'Public', Family = '1.0.0', Third_Party__c	= NULL,
										Type__c	 = 'PS',  Base_Item_Lookup__c = NULL, Care_Rate_Applicable__c = '',
										BRAZIL_R_Price__c = -1.00, NG1_APAC_ANZ_AUD_Price__c	= -1.00, G1_APAC_AUD_Price__c = -1.00,
										NG1_APAC_KOREA_SE_ASIA_USD_Price__c = -1.00, G1_APAC_USD_Price__c = -1.00, NG1_APAC_USD_Price__c = -1.00, 
										G2_CALA_USD_Price__c = -1.00, NG2_BRAZIL_BRL_Price__c = -1.00, G3_EMEA_EUR_Price__c	= -1.00, NG2_CALA_USD_Price__c = -1.00,
										G3_EMEA_GBP_Price__c = -1.00, NG3_EMEA_EUR_Price__c	= -1.00, G3_EMEA_USD_Price__c	= -1.00, NG3_EMEA_GBP_Price__c	= -1.00,
										G4_JAPAN_JPY_Price__c = -1.00, NG3_EMEA_USD_Price__c = -1.00, G5_NA_CAD_Price__c = -1.00, NG4_APAC_CHINA_INDIA_USD_Price__c	= -1.00,
										G5_NA_USD_Price__c = -1.00, NG4_APAC_JAPAN_YEN_Price__c	= -1.00, NG5_NZD_Price__c	= -1.00, NG5_NA_USD_Price__c	= -1.00,
										NG5_ZAR_Price__c = -1.00, NG5_NA_CAD_Price__c	= -1.00,
										NG1_PPU_Silver_USD__c	= -1.00, NG1_PPU_USD__c		= -1.00, NG1_PPU_Gold_USD__c	= -1.00
								));
		for(Integer i = 1; i <= 10; i ++){
			testProducts.add(new Product2(Name = 'Core Product ' + i, Description = 'Core Product ' + i, Product_Name__c = 'Core Product ' + i, Description__c = 'Core Product ' + i, Base_Item__c = 'Core Product ' + i,
											Type__c	 = 'Product', RecordTypeId = CoreProductRT,  Gore_Integration_ID__c = '2000' + i, BaseItem_MML_Id__c = '2000' + i,  APN_Number__c = '2000' + i,
											Price_Type__c = 'Fixed Price', Product_Option__c = 'Quantity', Availability_Status__c = 'Active', Price_Permission__c = 'Public', Family = '1.0.0', Third_Party__c	= NULL,
											 Base_Item_Lookup__c = NULL, Care_Rate_Applicable__c = '', IsActive = true,
											BRAZIL_R_Price__c = 1000.00, NG1_APAC_ANZ_AUD_Price__c	= 1000.00, G1_APAC_AUD_Price__c = 1000.00,
											NG1_APAC_KOREA_SE_ASIA_USD_Price__c = 1000.00, G1_APAC_USD_Price__c = 1000.00, NG1_APAC_USD_Price__c = 1000.00, 
											G2_CALA_USD_Price__c = 1000.00, NG2_BRAZIL_BRL_Price__c = 1000.00, G3_EMEA_EUR_Price__c	= 1000.00, NG2_CALA_USD_Price__c = 1000.00,
											G3_EMEA_GBP_Price__c = 1000.00, NG3_EMEA_EUR_Price__c	= 1000.00, G3_EMEA_USD_Price__c	= 1000.00, NG3_EMEA_GBP_Price__c	= 1000.00,
											G4_JAPAN_JPY_Price__c = 1000.00, NG3_EMEA_USD_Price__c = 1000.00, G5_NA_CAD_Price__c = 1000.00, NG4_APAC_CHINA_INDIA_USD_Price__c	= 1000.00,
											G5_NA_USD_Price__c = 1000.00, NG4_APAC_JAPAN_YEN_Price__c	= 1000.00, NG5_NZD_Price__c	= 1000.00, NG5_NA_USD_Price__c	= 1000.00,
											NG5_ZAR_Price__c = 1000.00, NG5_NA_CAD_Price__c	= 1000.00,
											NG1_PPU_Silver_USD__c	= 1000.00, NG1_PPU_USD__c		= 1000.00, NG1_PPU_Gold_USD__c	= 1000.00
									));
		}
		insert testProducts;
		
		testProducts[3].Product_Upgrade__c = testProducts[8].id;
		testProducts[4].Product_Upgrade__c = testProducts[9].id;
		//testProducts[5].Product_Upgrade__c = testProducts[10].id;
		// testProducts[6].Product_Upgrade__c = testProducts[11].id;
		// testProducts[7].Product_Upgrade__c = testProducts[12].id;
		update testProducts;
		
		List<PricebookEntry> testPriceBookEntries = new List<PricebookEntry>();
		for(Product2 p : testProducts){
			testPriceBookEntries.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = p.Id, IsActive = true,
														UnitPrice = 1000, UseStandardPrice = false, CurrencyIsoCode = 'USD'));
        }           
		insert testPriceBookEntries;
		
		ID RenewalOppRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Genesys Renewal').getRecordTypeId();
		List<Opportunity> testOpportunities = new List<Opportunity>();
		testOpportunities.add(new Opportunity(Name = 'Regular Opp 1', Opportunity_Status__c = 'In Progress', StageName = '8.Renewal', CurrencyIsoCode = 'USD',
											AccountId = testAccounts[0].Id, BusinessPartner__c = testAccounts[0].Id, CloseDate = Date.Today().addDays(130), 
											Country__c = testCountries[0].Id, Sold_To_Country__c = testCountries[0].Id,
					        				Previous_Maintenance_Rate__c = 18.0, Gene_Care_Specialist__c = UserInfo.getUserId(),
											Lines_of_Businesses__c = OfferingType, RecordTypeId = RenewalOppRT, Pricebook2Id = Test.getStandardPricebookId()));
		testOpportunities.add(new Opportunity(Name = 'Regular Opp 2', Opportunity_Status__c = 'In Progress', StageName = '8.Renewal', CurrencyIsoCode = 'USD',
											AccountId = testAccounts[0].Id, BusinessPartner__c = testAccounts[0].Id, CloseDate = Date.Today().addDays(140), 
											Country__c = testCountries[0].Id, Sold_To_Country__c = testCountries[0].Id,
					        				Previous_Maintenance_Rate__c = 18.0, Gene_Care_Specialist__c = UserInfo.getUserId(),
											Lines_of_Businesses__c = OfferingType, RecordTypeId = RenewalOppRT, Pricebook2Id = Test.getStandardPricebookId()));
		testOpportunities.add(new Opportunity(Name = 'Gap Opp 1', Opportunity_Status__c = 'In Progress', StageName = '8.Renewal', CurrencyIsoCode = 'USD',
											AccountId = testAccounts[0].Id, BusinessPartner__c = testAccounts[0].Id, CloseDate = Date.Today().addDays(110), 
											Country__c = testCountries[0].Id, Sold_To_Country__c = testCountries[0].Id,
					        				Previous_Maintenance_Rate__c = 18.0, Gene_Care_Specialist__c = UserInfo.getUserId(),
											Lines_of_Businesses__c = OfferingType, RecordTypeId = RenewalOppRT, Pricebook2Id = Test.getStandardPricebookId()));
		insert testOpportunities;
		
		List<ServiceContract> testServiceContracts = new List<ServiceContract>();
        for(Integer i=0; i<3; i++) {
            testServiceContracts.add(new ServiceContract( Name = 'Service Contract ' + i, Pricebook2id = Test.getStandardPricebookId(), 
            									CurrencyIsoCode = 'USD', Agreement_Status__c = 'Active', Override_Offering_Type__c = OfferingType,
            									StartDate = testOpportunities[i].CloseDate.addMonths(-24), EndDate = testOpportunities[i].CloseDate.addDays(1), 
								            	Sold_To_Name__c = testAccounts[0].id, End_User_Name__c = testAccounts[0].id, 
								            	AccountId = testAccounts[0].id, Renewal_Opportunity__c = testOpportunities[i].Id
			));
        }           
        insert testServiceContracts;
		
		List<ContractLineItem> listContractLineItems = new List<ContractLineItem>();
		for(Integer i=0; i<3; i++){
			for(integer j=3; j<7; j++){
				listContractLineItems.add(new ContractLineItem(
					ServiceContractId = testServiceContracts[i].id,
					Current_Quantity__c = j+1, 
					Quantity = j+1,
					UnitPrice = 100,
					PricebookEntryId = testPriceBookEntries[j].id,
					Lic_Invoice__c = '1000'+i+j,
					Sales_Order__c = '1000'+i+j,
					Maintenance_Start_Date__c = testOpportunities[i].CloseDate.addMonths(-24),
					Maintenance_End_Date__c = testOpportunities[i].CloseDate.addDays(1)
				));
			}
			listContractLineItems.add(new ContractLineItem(
					ServiceContractId = testServiceContracts[i].id,
					Current_Quantity__c = 10, 
					Quantity = 10,
					UnitPrice = 100,
					PricebookEntryId = testPriceBookEntries[11].id,
					Lic_Invoice__c = '100010',
					Sales_Order__c = '100010',
					Maintenance_Start_Date__c = testOpportunities[i].CloseDate.addMonths(-24),
					Maintenance_End_Date__c = testOpportunities[i].CloseDate.addDays(1)
			));
		}
        insert listContractLineItems;

		for(Integer i=0; i<3; i++) {
		 	testOpportunities[i].Service_Contract__c = testServiceContracts[i].id;
		}
		update testOpportunities;

        
        List<Pure_Connect_Version_Upgrade__c> pureConnectVersionUpgrades = new List<Pure_Connect_Version_Upgrade__c>();
        pureConnectVersionUpgrades.add(new Pure_Connect_Version_Upgrade__c(Mapping_Type__c = '3 --> 7', Multiplier__c = 1, Old_Part_Number__c = testProducts[3].APN_Number__c, New_Part_Number__c = testProducts[7].APN_Number__c));
        pureConnectVersionUpgrades.add(new Pure_Connect_Version_Upgrade__c(Mapping_Type__c = '4 --> 8', Multiplier__c = 1, Old_Part_Number__c = testProducts[4].APN_Number__c, New_Part_Number__c = testProducts[8].APN_Number__c));
        pureConnectVersionUpgrades.add(new Pure_Connect_Version_Upgrade__c(Mapping_Type__c = '5 --> 9', Multiplier__c = 1, Old_Part_Number__c = testProducts[5].APN_Number__c, New_Part_Number__c = testProducts[9].APN_Number__c));
        pureConnectVersionUpgrades.add(new Pure_Connect_Version_Upgrade__c(Mapping_Type__c = '5 --> 10', Multiplier__c = 1, Old_Part_Number__c = testProducts[5].APN_Number__c, New_Part_Number__c = testProducts[10].APN_Number__c));
        insert pureConnectVersionUpgrades;
         
        List<Product_Upgrade_Request__c> versionUpgradeRequests = new List<Product_Upgrade_Request__c>();
        versionUpgradeRequests.add(new Product_Upgrade_Request__c(Account__c = testAccounts[0].id, Product__c = testProducts[3].id, Type__c = 'Version', Processed__c = false));
        versionUpgradeRequests.add(new Product_Upgrade_Request__c(Account__c = testAccounts[0].id, Product__c = testProducts[4].id, Type__c = 'Version', Processed__c = false));
        versionUpgradeRequests.add(new Product_Upgrade_Request__c(Account__c = testAccounts[0].id, Product__c = testProducts[5].id, Type__c = 'Version', Processed__c = false));
        insert versionUpgradeRequests;
        
        List<UL_Upsize_Parts__c> upLiftParts = new List<UL_Upsize_Parts__c>();
        upLiftParts.add(new  UL_Upsize_Parts__c(Name = testProducts[6].APN_Number__c, Part_To_Be_Decremented__c = testProducts[11].APN_Number__c, Part_To_Be_Incremented__c = testProducts[12].APN_Number__c));
        insert upLiftParts;
        Util.Bypass_Trigger_Chk = false;
    }
}