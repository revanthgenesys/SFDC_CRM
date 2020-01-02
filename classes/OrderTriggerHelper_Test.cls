/************************************************************************************
Purpose : This Test class will covrage to trigger written on Order object. 
    Class - OrderTriggerHelper
    
Written By : Pankaj Pandey
Test Classes : OrderTriggerHandler_Test
*************************************************************************************/


//Pankaj Pandey  01/04/2018
@isTest(seeAllData=true)

private class OrderTriggerHelper_Test{ 
  
    static testMethod void test0(){
        List<Account> accounts = TestUtil.createAccounts(1, true);
        Country__c objCountry = setupCountry();
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD';
        opportunities.Country__c = objCountry.Id;
        
        insert opportunities;
        
        ID BaseItemRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();  
        ID CoreProductRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('CORE - Product Record Type').getRecordTypeId();          
        List<Product2> list_ProductsToInsert = new List<Product2>();
        
            
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.zqu__SKU__c ='test1';
        objTestProd1.End_of_Support__c = Date.today().format();
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.Dont_Publish_In_Quote__c = true;
        list_ProductsToInsert.add(objTestProd1);

        insert list_ProductsToInsert;
        Product_Group__c prdgrp = new Product_group__c();
              
        prdgrp.Name = 'Test';
        prdgrp.Group_Type__c = 'PureSuccess';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        //prdgrp.Token_Value__c = 500;
        prdgrp.Type__c = 'A la Carte';

        Insert prdgrp;

        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        //prdgrpItm.Name = 'Test product group Item';
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Lab';
        //prdgrpItm.Token_Value__c = 20;
              
        insert prdgrpItm;
        
        //Test.startTest();
        
        BigMachines__Quote__c objTestQuote = new BigMachines__Quote__c();
        objTestQuote.BigMachines__Opportunity__c = opportunities.Id;
        objTestQuote.Quote_Created_Date__c = System.today();
        objTestQuote.BigMachines__Status__c = 'Quote In Progress';
        objTestQuote.BigMachines__Is_Primary__c = true;
        objTestQuote.Service_Level__c = 'Business';
        objTestQuote.Pricing_Model__c = 'Enabled';
        objTestQuote.Quote_Opportunity_Type__c = 'New Pricing';
        objTestQuote.Duration_Unit__c = 'Months';
        objTestQuote.Order_Numb_of_Maint_Months__c = 12;
        objTestQuote.Order_Type__c = 'Revenue';
        objTestQuote.End_User_ID__c = accounts[0].id;
        objTestQuote.BigMachines__Account__c = accounts[0].id;
        objTestQuote.Sold_To_Name__c = accounts[0].id; 
        objTestQuote.New_Price_Book__c = 'NG5_NA_USD';
        objTestQuote.Support_Owner__c = accounts[0].id;
        objTestQuote.System_Integrator__c = accounts[0].id;
        objTestQuote.CurrencyISOCode = 'USD';
        objTestQuote.Quote_Business_Type__c = 'On Premise';
        objTestQuote.Expiration_Date__c = Date.today().addDays(90);
        objTestQuote.Approval_Submission_Date__c = Date.today();
        objTestQuote.Offering_Type__c = 'PureConnect Subscription';
        insert objTestQuote;
            
        List<BigMachines__Quote_Product__c> list_QPInsert = new List<BigMachines__Quote_Product__c>();           
           
        list_QPInsert.add(new BigMachines__Quote_Product__c(BigMachines__Product__c = objTestProd1.Id,BigMachines__Sales_Price__c = 2,
                            BigMachines__Quote__c = objTestQuote.Id,BigMachines__Quantity__c = 1));
        insert list_QPInsert;
        Test.startTest();
        Order__c ord_1 = new Order__c();
        ord_1.Maintenance_Start__c = Date.today();
        ord_1.Maintenance_End__c = Date.today().addYears(1);
        ord_1.Opportunity__c = opportunities.id;
        ord_1.Numb_of_Maint_Months__c = 12;
        ord_1.End_User_Name__c = accounts[0].id;
        ord_1.Bill_To_Name__c = accounts[0].id;
        ord_1.Sold_To_Name__c = accounts[0].id;
        ord_1.Ship_To_Name__c  = accounts[0].id;
        ord_1.CurrencyIsoCode = 'USD';
        ord_1.NRO_Type__c = 'Service Element Use';
        //ord_1.Order_Category__c = 'PureEngage - Cloud';
        ord_1.Quote__c = objTestQuote.id;
        ord_1.Status__c = 'Approved';
        ord_1.License_FYM_detail__c = 'Subscription Order';
        insert ord_1; 

        Map<Id, Order__c> oldMap = new Map<Id, Order__c>([Select ID,Maintenance_Start__c,Maintenance_End__c,Opportunity__c,Numb_of_Maint_Months__c,Status__c,Opportunity_Account__c from Order__c where ID =: ord_1.Id]);
        ord_1.Status__c = 'Completed';
        update ord_1;
        map<id,order__c> newMap = new map<id,order__c>();
        newMap.put(ord_1.Id,ord_1);
        
        OrderTriggerHelper.InsertPureSuccessPackage(newMap, oldMap);
        Test.stopTest();
    }
    
    static testMethod void test1(){
        List<Account> accounts = TestUtil.createAccounts(1, true);
        Country__c objCountry = setupCountry();
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD';
        opportunities.Country__c = objCountry.Id;
        
        insert opportunities;
        
        ID BaseItemRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();  
        ID CoreProductRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('CORE - Product Record Type').getRecordTypeId();          
        List<Product2> list_ProductsToInsert = new List<Product2>();
        
            
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Bundle';
        objTestProd1.zqu__SKU__c ='test2';
        objTestProd1.End_of_Support__c = Date.today().format();
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.Dont_Publish_In_Quote__c = true;
        list_ProductsToInsert.add(objTestProd1);
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.Name = 'Test Prod1';   
        objTestProd2.zqu__SKU__c ='test3';         
        objTestProd2.Type__c = 'Rental';
        objTestProd2.End_of_Support__c = Date.today().format();
        objTestProd2.IsActive = true;
        objTestProd2.Description = 'test 1';
        objTestProd2.OfferingType__c = 'PureSuccess';
        objTestProd2.APN_Number__c = 'Tokens1';
        objTestProd2.Dont_Publish_In_Quote__c = true;
        list_ProductsToInsert.add(objTestProd2);

        insert list_ProductsToInsert;
        Product_Group__c prdgrp = new Product_group__c();
              
        prdgrp.Name = 'PureSuccess A la Carte';
        prdgrp.Group_Type__c = 'PureSuccess';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        //prdgrp.Token_Value__c = 500;
        prdgrp.Type__c = 'A la Carte';

        Insert prdgrp;
        
        Product_Group__c prdgrp1 = new Product_group__c();
              
        prdgrp1.Name = 'PureSuccess A la Carte';
        prdgrp1.Group_Type__c = 'PureSuccess';
        prdgrp1.Product__c = list_ProductsToInsert[1].id;
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        //prdgrp.Token_Value__c = 500;
        prdgrp1.Type__c = 'A la Carte';

        Insert prdgrp1;

        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        //prdgrpItm.Name = 'Test product group Item';
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Lab';
        //prdgrpItm.Token_Value__c = 20;
              
        insert prdgrpItm;
        
        //Test.startTest();
        
        BigMachines__Quote__c objTestQuote = new BigMachines__Quote__c();
        objTestQuote.BigMachines__Opportunity__c = opportunities.Id;
        objTestQuote.Quote_Created_Date__c = System.today();
        objTestQuote.BigMachines__Status__c = 'Quote In Progress';
        objTestQuote.BigMachines__Is_Primary__c = true;
        objTestQuote.Service_Level__c = 'Business';
        objTestQuote.Token_Value__c =10;
        objTestQuote.Total_Tokens_Change__c = 10;
        objTestQuote.Total_GU_Training_Units__c = 10;
        objTestQuote.Pricing_Model__c = 'Enabled';
        objTestQuote.Quote_Opportunity_Type__c = 'New Pricing';
        objTestQuote.Duration_Unit__c = 'Months';
        objTestQuote.Order_Type__c = 'Amend Subscription';
        objTestQuote.Order_Numb_of_Maint_Months__c = 12;
        objTestQuote.End_User_ID__c = accounts[0].id;
        objTestQuote.BigMachines__Account__c = accounts[0].id;
        objTestQuote.Sold_To_Name__c = accounts[0].id; 
        objTestQuote.New_Price_Book__c = 'NG5_NA_USD';
        objTestQuote.Support_Owner__c = accounts[0].id;
        objTestQuote.System_Integrator__c = accounts[0].id;
        objTestQuote.CurrencyISOCode = 'USD';
        objTestQuote.Quote_Business_Type__c = 'On Premise';
        objTestQuote.Expiration_Date__c = Date.today().addDays(90);
        objTestQuote.Approval_Submission_Date__c = Date.today();
        objTestQuote.Offering_Type__c = 'PureConnect Subscription';
        insert objTestQuote;
            
        List<BigMachines__Quote_Product__c> list_QPInsert = new List<BigMachines__Quote_Product__c>();           
           
        list_QPInsert.add(new BigMachines__Quote_Product__c(BigMachines__Product__c = objTestProd2.Id,BigMachines__Sales_Price__c = 2,Bundle__c=prdgrp1.Id,
                            BigMachines__Quote__c = objTestQuote.Id,BigMachines__Quantity__c = 1,Quantity_Change__c=1));
        insert list_QPInsert;
        Test.startTest();
        Order__c ord_1 = new Order__c();
        ord_1.Maintenance_Start__c = Date.today();
        ord_1.Maintenance_End__c = Date.today().addYears(1);
        ord_1.Opportunity__c = opportunities.id;
        ord_1.Numb_of_Maint_Months__c = 12;
        ord_1.End_User_Name__c = accounts[0].id;
        ord_1.Bill_To_Name__c = accounts[0].id;
        ord_1.Sold_To_Name__c = accounts[0].id;
        ord_1.Ship_To_Name__c  = accounts[0].id;
        ord_1.CurrencyIsoCode = 'USD';
        //ord_1.Order_Category__c = 'PureEngage - Cloud';
        ord_1.Quote__c = objTestQuote.id;
        ord_1.Status__c = 'Approved';
        ord_1.License_FYM_detail__c = 'Subscription Order';
        insert ord_1; 

        Map<Id, Order__c> oldMap = new Map<Id, Order__c>([Select ID,Maintenance_Start__c,Maintenance_End__c,Opportunity__c,Numb_of_Maint_Months__c,Status__c,Opportunity_Account__c from Order__c where ID =: ord_1.Id]);
        ord_1.Status__c = 'Completed';
        update ord_1;
        map<id,order__c> newMap = new map<id,order__c>();
        newMap.put(ord_1.Id,ord_1);
        
        OrderTriggerHelper.InsertPureSuccessPackage(newMap, oldMap);
        Test.stopTest();
    }  
    
    static testMethod void test()
    {
        List<Account> accounts = TestUtil.createAccounts(1, true);
        Country__c objCountry = setupCountry();
        
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD';
        opportunities.Country__c = objCountry.Id;
        
        insert opportunities;
        
        ID BaseItemRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();  
        ID CoreProductRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('CORE - Product Record Type').getRecordTypeId();          
        List<Product2> list_ProductsToInsert = new List<Product2>();
        
            
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'A la Carte';            
        objTestProd1.Type__c = 'Bundle';
        objTestProd1.zqu__SKU__c ='test4';
        objTestProd1.End_of_Support__c = Date.today().format();
        objTestProd1.IsActive = true;
        objTestProd1.Dont_Publish_In_Quote__c= true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        list_ProductsToInsert.add(objTestProd1);

        insert list_ProductsToInsert;
        Product_Group__c prdgrp = new Product_group__c();
              
        prdgrp.Name = 'A la Carte';
        prdgrp.Group_Type__c = 'PureSuccess';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        //prdgrp.Token_Value__c = 500;
        prdgrp.Type__c = 'A la Carte';

        Insert prdgrp;

        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        //prdgrpItm.Name = 'Test product group Item';
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Lab';
        // prdgrpItm.Token_Value__c = 20;

        insert prdgrpItm;
        
        BigMachines__Quote__c objTestQuote = new BigMachines__Quote__c();
        objTestQuote.BigMachines__Opportunity__c = opportunities.Id;
        objTestQuote.Quote_Created_Date__c = System.today();
        objTestQuote.BigMachines__Status__c = 'Quote In Progress';
        objTestQuote.BigMachines__Is_Primary__c = true;
        objTestQuote.Service_Level__c = 'Business';
        objTestQuote.Pricing_Model__c = 'Enabled';
        objTestQuote.Quote_Opportunity_Type__c = 'New Pricing';
        objTestQuote.Duration_Unit__c = 'Months';
        objTestQuote.Order_Numb_of_Maint_Months__c = 12;
        objTestQuote.Order_Type__c = 'Revenue';
        objTestQuote.End_User_ID__c = accounts[0].id;
        objTestQuote.BigMachines__Account__c = accounts[0].id;
        objTestQuote.Sold_To_Name__c = accounts[0].id; 
        objTestQuote.New_Price_Book__c = 'NG5_NA_USD';
        objTestQuote.Support_Owner__c = accounts[0].id;
        objTestQuote.System_Integrator__c = accounts[0].id;
        objTestQuote.CurrencyISOCode = 'USD';
        objTestQuote.Quote_Business_Type__c = 'On Premise';
        objTestQuote.Expiration_Date__c = Date.today().addDays(90);
        objTestQuote.Approval_Submission_Date__c = Date.today();
        objTestQuote.Offering_Type__c = 'PureConnect Subscription';
        insert objTestQuote;
            
        List<BigMachines__Quote_Product__c> list_QPInsert = new List<BigMachines__Quote_Product__c>();
           
           
        list_QPInsert.add(new BigMachines__Quote_Product__c(BigMachines__Product__c = objTestProd1.Id,BigMachines__Sales_Price__c = 2,Bundle__c=prdgrp.Id,
                        BigMachines__Quote__c = objTestQuote.Id,BigMachines__Quantity__c = 1));
        insert list_QPInsert;
        
        Test.startTest();
        Order__c ord_1 = new Order__c();
        ord_1.Maintenance_Start__c = Date.today();
        ord_1.Maintenance_End__c = Date.today().addYears(1);
        ord_1.Opportunity__c = opportunities.id;
        ord_1.Numb_of_Maint_Months__c = 12;
        ord_1.End_User_Name__c = accounts[0].id;
        ord_1.Bill_To_Name__c = accounts[0].id;
        ord_1.Sold_To_Name__c = accounts[0].id;
        ord_1.Ship_To_Name__c  = accounts[0].id;
        ord_1.CurrencyIsoCode = 'USD';
        //ord_1.Order_Category__c = 'PureEngage - Cloud';
        ord_1.Quote__c = objTestQuote.id;
        ord_1.Status__c = 'Approved';
        ord_1.License_FYM_detail__c = 'Subscription Order';
        insert ord_1; 

        ord_1.Status__c = 'Completed';
        update ord_1;
        ord_1.Order_Type__c = 'Amend Subscription';
        update ord_1;
        //OrderTriggerHelper.InsertPureSuccessPackage(newMap, oldMap);              
        Test.stopTest();        
    }
  
/*    static testMethod void test1(){
        // Set up data required
        List<Account> accounts = TestUtil.createAccounts(1, true);
         Country__c objCountry = setupCountry();
        //List<Opportunity> opportunities = TestUtil.createOpportunities(2, accounts[0].Id, true);
        Opportunity opportunities = new Opportunity();
        opportunities.Name = 'Test Opp';
        opportunities.accountid = accounts[0].Id;
        opportunities.closeDate = Date.today().addMonths(1);
        opportunities.StageName = '1.Recognize Needs';
        opportunities.CurrencyIsoCode = 'USD';
        opportunities.Country__c = objCountry.Id;
        
        insert opportunities;
        
        ID BaseItemRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();  
        ID CoreProductRT = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('CORE - Product Record Type').getRecordTypeId();  
        List<BigMachines__Quote__c> quotes = TestUtil.createQuotes(1, opportunities.Id, true);
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(quotes[0].Id);
        //System.assertEquals(list_NewQuoteProds.size(), 2);
        List<Product2> testProducts = new List<Product2>();
        for(Integer i = 1; i <= 10; i ++){
            testProducts.add(new Product2(Name = 'Core Product ' + i, Description = 'Core Product ' + i, Product_Name__c = 'Core Product ' + i, Description__c = 'Core Product ' + i, Base_Item__c = 'Core Product ' + i,
                                            Type__c  = 'Token', RecordTypeId = CoreProductRT,  Gore_Integration_ID__c = '2000' + i, BaseItem_MML_Id__c = '2000' + i,  APN_Number__c = '2000' + i,
                                            Price_Type__c = 'Fixed Price', Product_Option__c = 'Quantity', Availability_Status__c = 'Active', Price_Permission__c = 'Public', Family = '1.0.0', Third_Party__c  = NULL,
                                             Base_Item_Lookup__c = NULL, Care_Rate_Applicable__c = '', IsActive = true,
                                            BRAZIL_R_Price__c = 1000.00, NG1_APAC_ANZ_AUD_Price__c  = 1000.00, G1_APAC_AUD_Price__c = 1000.00,
                                            NG1_APAC_KOREA_SE_ASIA_USD_Price__c = 1000.00, G1_APAC_USD_Price__c = 1000.00, NG1_APAC_USD_Price__c = 1000.00, 
                                            G2_CALA_USD_Price__c = 1000.00, NG2_BRAZIL_BRL_Price__c = 1000.00, G3_EMEA_EUR_Price__c = 1000.00, NG2_CALA_USD_Price__c = 1000.00,
                                            G3_EMEA_GBP_Price__c = 1000.00, NG3_EMEA_EUR_Price__c   = 1000.00, G3_EMEA_USD_Price__c = 1000.00, NG3_EMEA_GBP_Price__c    = 1000.00,
                                            G4_JAPAN_JPY_Price__c = 1000.00, NG3_EMEA_USD_Price__c = 1000.00, G5_NA_CAD_Price__c = 1000.00, NG4_APAC_CHINA_INDIA_USD_Price__c   = 1000.00,
                                            G5_NA_USD_Price__c = 1000.00, NG4_APAC_JAPAN_YEN_Price__c   = 1000.00, NG5_NZD_Price__c = 1000.00, NG5_NA_USD_Price__c  = 1000.00,
                                            NG5_ZAR_Price__c = 1000.00, NG5_NA_CAD_Price__c = 1000.00,
                                            NG1_PPU_Silver_USD__c    = 1000.00, NG1_PPU_USD__c       = 1000.00, NG1_PPU_Gold_USD__c  = 1000.00
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
        
        List<Order__c> orders = TestUtil.createOrders(1, quotes[0].Id, opportunities.Id, true);
        
        
        serviceContracts[0].Renewal_Opportunity__c = opportunities.Id;
        serviceContracts[1].Renewal_Opportunity__c = opportunities.Id;
        serviceContracts[1].Quote_Name__c = quotes[0].id; 
        serviceContracts[0].Order__c = orders[0].Id;
        update serviceContracts;
        
        ID PartnerOpportunityRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Genesys Renewal').getRecordTypeId();
        opportunities.RecordTypeId = PartnerOpportunityRT;
        opportunities.Service_Contract__c = serviceContracts[0].id;
        opportunities.Service_Contract__c = serviceContracts[1].id;
        
        update opportunities;

            
        orders[0].Status__c = 'Submitted';
        update orders;
                                         
        Test.startTest();

        orders[0].Invoiced__c = true;
        orders[0].Invoice_Number__c = 'INV-001';
        Map<Id, Order__c> newMap = new Map<Id, Order__c>([Select ID,Maintenance_Start__c,Maintenance_End__c,Opportunity__c,Numb_of_Maint_Months__c,Status__c,Opportunity_Account__c from Order__c where ID =: orders[0].Id]);
        Map<Id, Order__c> oldMap = new Map<Id, Order__c>();
        oldMap.put(orders[0].Id, new Order__c( Id = orders[0].Id, Quote__c = orders[0].Quote__c,
                                                Maintenance_Start__c =orders[0].Maintenance_Start__c,
                                                Maintenance_End__c = orders[0].Maintenance_End__c,
                                                Opportunity__c = orders[0].Opportunity__c,
                                                Numb_of_Maint_Months__c = orders[0].Numb_of_Maint_Months__c));

        Pure_Success_Package__c purSucc = new Pure_Success_Package__c();
        purSucc.Account__c = accounts[0].Id;
        purSucc.Order__c = orders[0].Id;
        purSucc.Package_Type__c = 'Pure Success';        
        
        insert purSucc;
        
        Package_Services__c pkgSrv = new Package_Services__c();
        pkgSrv.Status__c = 'Allocated';
        pkgSrv.Order__c = orders[0].Id;
        pkgSrv.PureSuccess_Package__c = purSucc.id;
        
        insert pkgSrv;
        
        Token_Allocations__c tka = new Token_Allocations__c();
        
        tka.Account__c = accounts[0].Id;
        tka.Order__c = orders[0].Id;
        tka.Token_Status__c = 'Allocated';
        
        Insert tka;
        String Offeringdetail = 'Pilot/Trial/POC';
        Boolean isCreate = false;
        String ordId = orders[0].Id;
        SourceAccounts__c sacct = new SourceAccounts__c();        
        sacct.Account__c = accounts[0].id; 
        sacct.Type__c = 'PureCloud';
        sacct.Offering_detail__c = 'Pilot/Trial/POC';
        sacct.Opportunity__c = opportunities.id;
        sacct.Trial_Status__c = 'Active';
        //Map <Id, Order__C>
        insert sacct;
        string oppid = opportunities.id;
        orders[0].Status__c = 'Approved';
        update orders;
        OrderTriggerHandler.afterInsertUpdate(newMap, oldMap);
        orders[0].Status__c = 'Completed';
        update orders;
        OrderTriggerHandler.UpdatePackageServiceStatus(ordId);
        OrderTriggerHandler.afterInsertUpdate(newMap, oldMap);
        OrderTriggerHandler.getRecordTypeName('PureCloud');
        OrderTriggerHandler.getRecordTypeName(null);
        OrderTriggerHandler.getRecordTypeId(null,'SourceAccounts__c');
        OrderTriggerHandler.createSourceAccount(newMap.get(orders[0].Id),'PureCloud',Offeringdetail, 'Test Account','Cloud',opportunities.Sold_To_Country__c,oppid);
        Test.stopTest(); 
    }*/
    
    public static Country__c setupCountry(){
        Country__c objCountry = new Country__c(Country__c='United States A', DAP_Region__c='NA', 
                                               Region__c='NA', RU__c='NA', New_DAP_Region__c = 'NA',        
                                               New_Price_Book__c='NG5_NA_USD', Old_Price_Book__c='NG5_NA_USD'); 
        insert objCountry;
        return objCountry;
    }
    
}