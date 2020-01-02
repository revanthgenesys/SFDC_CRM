/*
	04/30/2013	Naresh Kumar
	Test Class to test main class BMCoTermController
*/
@isTest
private class BMCoTermController_Test {
	@isTest(seeAllData=true)
    static void testBMCoTermController1(){
    	Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
    	ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
    	BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, true)[0];
    	ApexPages.StandardController stdController = new ApexPages.StandardController(testQuote);
        BMCoTermController objController = new BMCoTermController(stdController);
        objController.getSortDirection();
        objController.findRelatedRecords();
        objController.getselectedWrappers();
        objController.submit();
        objController.cancel();
        objController.includeOpps();
        objController.selectAll();
        objController.removeCoTermedScs();        
    }
    
    @isTest(seeAllData=true)
    static void testBMCoTermController2(){
    	// Set up data required
    	List<Account> accounts = TestUtil.createAccounts(1, true);
    	List<Opportunity> opportunities = TestUtil.createOpportunities(2, accounts[0].Id, true);
    	
    	ID BaseItemRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();  
		ID CoreProductRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('CORE - Product Record Type').getRecordTypeId();  
    	List<Product2> testProducts = new List<Product2>();
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
    	
    	List<PricebookEntry> testPriceBookEntries = new List<PricebookEntry>();
		for(Product2 p : testProducts){
			testPriceBookEntries.add(new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = p.Id, IsActive = true,
														UnitPrice = 1000, UseStandardPrice = false, CurrencyIsoCode = 'USD'));
        }           
		insert testPriceBookEntries;
		
    	List<ServiceContract> serviceContracts = TestUtil.createServiceContracts2(2, true, accounts[0]);
    	List<ContractLineItem> contractLineItems = new List<ContractLineItem>();
        for( Integer i=0; i < 10; i++ ) {
            contractLineItems.add(new ContractLineItem(ServiceContractId = serviceContracts[0].Id, Quantity = 10, UnitPrice = 100, PricebookEntryId = testPriceBookEntries[i].Id));
        }
		insert contractLineItems;    	
    	List<BigMachines__Quote__c> quotes = TestUtil.createQuotes(1, opportunities[0].Id, true);
    	List<BigMachines__Quote_Product__c> quoteProducts = TestUtil.createQuoteProducts(10, true, quotes[0].id);
    	List<Order__c> orders = TestUtil.createOrders(1, quotes[0].Id, opportunities[0].Id, true);
		
		serviceContracts[0].Renewal_Opportunity__c = opportunities[0].Id;
		serviceContracts[1].Renewal_Opportunity__c = opportunities[1].Id;
		serviceContracts[1].Quote_Name__c = quotes[0].id; 
		serviceContracts[0].Order__c = orders[0].Id;
		update serviceContracts;
		
    	ID PartnerOpportunityRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Genesys Renewal').getRecordTypeId();
    	opportunities[0].RecordTypeId = PartnerOpportunityRT;
    	opportunities[0].Service_Contract__c = serviceContracts[0].id;
    	opportunities[1].Service_Contract__c = serviceContracts[1].id;
    	update opportunities;

		for(Integer i=0; i<10; i++){
			quoteProducts[i].Service_Contract_Line__c = contractLineItems[i].id;
			quoteProducts[i].Service_Contract_Line_ID__c = contractLineItems[i].id;
			quoteProducts[i].Contract_Line_Update_Status__c  = 'Reinstate';
			if(i > 5)
				quoteProducts[i].Current_Qty__c = 5;
			else
				quoteProducts[i].Current_Qty__c = 10;	
			contractLineItems[i].Quote_Product__c = quoteProducts[i].Id;
			contractLineItems[i].Revised_Net_License_Value__c = 1000;
			contractLineItems[i].Previous_Line_Maintenance_Value__c = 1000; 
			contractLineItems[i].Maintenance_Amount__c = 1000;
			contractLineItems[i].Current_Quantity__c = 10; 
		}
		update quoteProducts;
		update contractLineItems;

		quotes[0].Is_Business_Primary__c = true;
		quotes[0].Order__c = orders[0].id;
		update quotes;
		
		Quote_Service_Contracts__c qsc = new Quote_Service_Contracts__c(Quote__c = quotes[0].id, Service_Contract__c = serviceContracts[1].Id, Service_Contract_ID__c = serviceContracts[1].Id);
		insert qsc;
				
		Test.startTest();
    	ApexPages.currentPage().getParameters().put('oppId', opportunities[0].id);
    	ApexPages.StandardController stdController = new ApexPages.StandardController(quotes[0]);
        BMCoTermController objController = new BMCoTermController(stdController);
        
        
        objController.getSortDirection();
        objController.findRelatedRecords();
        objController.getselectedWrappers();
        objController.submit();
        objController.cancel();
        objController.includeOpps();
        objController.selectAll();
        objController.removeCoTermedScs();        

		objController.sortExpression = 'name';
		objController.sortExpression = 'id';
		objController.sortExpression = 'name';
		objController.sortExpression = 'name';
		objController.sortExpression = NULL;
		objController.getSortDirection();
		objController.setSortDirection('ASC');
		string fieldsList = objController.fields;
		
        Account endUserAcc = objController.endUserAcc;
        Account soldToAcc = objController.soldToAcc;
		
		/*	
    	orders[0].Status__c = 'Submitted';
    	update orders;

		insert(new Quote_Service_Contracts__c(Quote__c = quotes[0].Id, Service_Contract__c = serviceContracts[1].Id));	        									
    	Test.startTest();

    	Map<Id, BigMachines__Quote__c> oldQuotesMap = new Map<Id, BigMachines__Quote__c>();
    	oldQuotesMap.put(quotes[0].Id, new BigMachines__Quote__c( Id = quotes[0].Id, Name = quotes[0].Name, BigMachines__Opportunity__c= quotes[0].BigMachines__Opportunity__c));
    	
    	quotes[0].Quote_Business_Type__c='Hybrid';
    	QuoteFieldMappings.populateQuoteValues(quotes, oldQuotesMap);

    	quotes[0].Quote_Business_Type__c='On Premise';
    	QuoteFieldMappings.populateQuoteValues(quotes, oldQuotesMap);

    	quotes[0].Quote_Business_Type__c='Cloud';
    	QuoteFieldMappings.populateQuoteValues(quotes, oldQuotesMap);
    	
    	
    	QuoteFieldMappings.populateFieldsOnOrderInsertUpdate(orders, null);
    	orders[0].Invoiced__c = true;
    	orders[0].Invoice_Number__c = 'INV-001';
    	
    	Map<Id, Order__c> oldMap = new Map<Id, Order__c>();
    	oldMap.put(orders[0].Id, new Order__c( Id = orders[0].Id, Quote__c = orders[0].Quote__c,
	        									Maintenance_Start__c =orders[0].Maintenance_Start__c,
	        									Maintenance_End__c = orders[0].Maintenance_End__c,
	        									Opportunity__c = orders[0].Opportunity__c,
	        									Numb_of_Maint_Months__c = orders[0].Numb_of_Maint_Months__c));
    	QuoteFieldMappings.populateFieldsOnOrderInsertUpdate(orders, oldMap);
    	QuoteFieldMappings.populateOrder(orders, oldMap.Values());
    	QuoteFieldMappings.populateAccountInfoFields(orders);
    	
    	orders[0].Status__c = 'Approved';
    	update orders;
    	
    	orders[0].Status__c = 'Completed';
    	update orders;
    	*/
    	Test.stopTest(); 
    }
}