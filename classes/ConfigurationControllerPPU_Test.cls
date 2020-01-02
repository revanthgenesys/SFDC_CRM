@isTest
public class ConfigurationControllerPPU_Test{

    @isTest
    static void intialTests() { 
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        Set<String> set_APNnumbers = new Set<String>();
        List<Country__c>  testCountries = new List<Country__c>();
        testCountries.add(new Country__c(
        Name = 'United States', Region__c = 'EMEA', PSRDP_Region__c='Australia', DAP_Region__c = 'NA', ISO_Code__c = 'USD',  Country__c = 'USA',
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
        insert testCountries;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        list_NewAccts[0].Country__c = testCountries[0].id;
        update list_NewAccts;
        System.assertEquals(list_NewAccts.size(), 1);
        
        List<Opportunity> list_NewOpps = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.name = 'testopp';
        opp.StageName='1.Recognize Needs';
        opp.CloseDate=System.today().addMonths(1);
        opp.accountId = list_NewAccts[0].id;
        list_NewOpps.add(opp);
        insert list_NewOpps ;
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        list_NewQuotes[0].Multi_Year_Quote__c = true;
        list_NewQuotes[0].Pricing_Model__c = 'Concurrent';
        list_NewQuotes[0].Sold_To_Name__c = list_NewAccts[0].Id;
        list_NewQuotes[0].Quote_Opportunity_Type__c = 'New Pricing';
        list_NewQuotes[0].Offering_Type__c = 'PureEngage Subscription';
        //list_NewQuotes[0].Opp_Sold_To_Country__c = testCountries[0].id;
        update list_NewQuotes;
        System.assertEquals(list_NewQuotes.size(), 1);
        
        List<CurrencyType> curr = new list<CurrencyType>();
        for(CurrencyType c: [SELECT IsoCode,ConversionRate FROM CurrencyType]){
        curr.add(c);
        }
        Global_Configuration_Settings__c settings = Global_Configuration_Settings__c.getOrgDefaults();
        settings.Branch_Office_Multiplier__c = 0.70;
        settings.Named_User_Pricing_Multiplier__c = 1.30;
        settings.Concurrent_Pricebook_Multiplier__c = 2.00;
        upsert settings Branch_Office_Multiplier__c.Id;
        
        Id RecordTypeIdContact = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();
        
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd = new Product2();
        objTestProd.APN_Number__c = 'Tokens1';
        objTestProd.Pricing_Model__c = 'Branch Office';
        objTestProd.Description__c = 'test1';
        objTestProd.PPU_Product__c = true;
        objTestProd.Product_Name__c = 'test';
        objTestProd.SI_Version_Number__c = '8.0';
        objTestProd.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd.Quantity__c = 10;
        objTestProd.Name = 'Test Prod3'; 
        objTestProd.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Taxonomy_Category__c = 'Branch Office';
        objTestProd.RecordTypeId= RecordTypeIdContact;
        objTestProd.Dont_Publish_In_Quote__c = false;
        objTestProd.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd.Price_Permission__c = 'Public';
        objTestProd.Restricted_Product__c =false;
        objTestProd.Versions_Available__c = 'sdfsdf';
        objTestProd.OfferingType__c = 'PureEngage On Premise';
        objTestProd.NG1_PPU_USD__c= 1;
        objTestProd.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd);
        
        Product2 objTestProd7 = new Product2();
        objTestProd7.APN_Number__c = 'Tokens1';
        objTestProd7.PPU_Product__c = true;
        objTestProd7.Pricing_Model__c = 'Branch Office';
        objTestProd7.Description__c = 'test1';
        objTestProd7.Product_Name__c = 'test';
        objTestProd7.SI_Version_Number__c = '8.0';
        objTestProd7.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd7.Quantity__c = 10;
        objTestProd7.Name = 'Test Prod3'; 
        objTestProd7.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd7.End_of_Support__c = String.valueOf(Date.today());
        objTestProd7.IsActive = true;
        objTestProd7.Taxonomy_Category__c = 'Branch Office';
        objTestProd7.RecordTypeId= RecordTypeIdContact;
        objTestProd7.Dont_Publish_In_Quote__c = false;
        objTestProd7.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd7.Price_Permission__c = 'Public';
        objTestProd7.Restricted_Product__c =false;
        objTestProd7.Versions_Available__c = 'sdfsdf';
        objTestProd7.OfferingType__c = 'PureEngage On Premise';
        objTestProd7.NG1_PPU_USD__c= 1;
        objTestProd7.Quantities_Available__c = 'test;test1';
        objTestProd7.Parent_Product_lookup__c = objTestProd.id;
        list_ProductsToInsert.add(objTestProd7);
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.Quantity__c = 10;
        objTestProd2.Pricing_Model__c = 'Branch Office';
        objTestProd2.PPU_Product__c = true;
        objTestProd2.Name = 'Test Prod11';  
        objTestProd2.SI_Version_Number__c = '4.0';        
        objTestProd2.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd2.Type__c = 'Token';
        objTestProd2.End_of_Support__c = String.valueOf(Date.today());
        objTestProd2.IsActive = true;
        objTestProd2.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd2.RecordTypeId= RecordTypeIdContact;
        objTestProd2.Dont_Publish_In_Quote__c = false;
        objTestProd2.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd2.Price_Permission__c = 'Public';
        objTestProd2.Restricted_Product__c =false;
        objTestProd2.Versions_Available__c = 'sdfsdf';
        objTestProd2.OfferingType__c = 'PureEngage On Premise';
        objTestProd2.zqu__Category__c = 'Add On Services';
        objTestProd2.NG1_PPU_USD__c= 1;
        objTestProd2.Description = 'test 1';
        objTestProd2.APN_Number__c = 'Tokens1';
        objTestProd2.Quantities_Available__c = 'test;test1';
        objTestProd2.Parent_Product_lookup__c = objTestProd.id;
        list_ProductsToInsert.add(objTestProd2);
        
        Product2 objTestProd4 = new Product2();
        objTestProd4.APN_Number__c = 'Tokens1';
        objTestProd4.PPU_Product__c = true;
        objTestProd4.SI_Version_Number__c = '8.0';
        objTestProd4.Description__c = 'test3';
        objTestProd4.Name = 'Test Prod2619';
        objTestProd4.Quantity__c = 10;
        objTestProd4.OfferingType__c = 'PureEngage Subscription';
        objTestProd4.NG1_PPU_USD__c= 1;
        list_ProductsToInsert.add(objTestProd4);
        
        Product2 objTestProd3 = new Product2();
        objTestProd3.Pricing_Model__c = 'testing';
        objTestProd3.PPU_Product__c = true;
        objTestProd3.Description__c = '1';
        objTestProd3.SI_Version_Number__c = '8.0';
        objTestProd3.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd3.Quantity__c = 10;
        objTestProd3.Name = 'Test Prod2'; 
        objTestProd3.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd3.End_of_Support__c = String.valueOf(Date.today());
        objTestProd3.IsActive = true;
        objTestProd3.RecordTypeId= RecordTypeIdContact;
        objTestProd3.Dont_Publish_In_Quote__c = false;
        objTestProd3.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd3.Price_Permission__c = 'Public';
        objTestProd3.Restricted_Product__c =false;
        objTestProd3.Versions_Available__c = 'sdfsdf';
        objTestProd3.OfferingType__c = 'PureEngage Subscription';
        objTestProd3.APN_Number__c = 'Tokens1';
        objTestProd3.NG1_PPU_USD__c= 1;
        objTestProd3.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd3);
        
        Product2 objTestProd1 = new Product2();
        objTestProd1.SI_Version_Number__c = '8.0';
        objTestProd1.Quantity__c = 10;
        objTestProd1.PPU_Product__c = true;
        objTestProd1.Pricing_Model__c = 'testing';
        objTestProd1.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd1.Name = 'Test Prod';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd1.RecordTypeId= RecordTypeIdContact;
        objTestProd1.Dont_Publish_In_Quote__c = false;
        objTestProd1.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd1.Price_Permission__c = 'Public';
        objTestProd1.Restricted_Product__c =false;
        objTestProd1.Versions_Available__c = 'sdfsdf';
        objTestProd1.OfferingType__c = 'PureEngage Subscription';
        objTestProd1.zqu__Category__c = 'Add On Services';
        objTestProd1.NG1_PPU_USD__c= 1;
        objTestProd1.Base_Item_Lookup__c = objTestProd4.id;
        objTestProd1.Description = 'test 1';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd1);
        
        insert list_ProductsToInsert;
        Test.startTest();  
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Test';
        prdgrp.Group_Type__c = 'Use Case';
        prdgrp.Active__c = true;
        prdgrp.Play_Offer__c = 'Digital Service - Genesys Service Automation';
        prdgrp.Pricing_Model__c = 'test';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Offering_Type__c = 'PureEngage On Premise';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;
        
        Product_Group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Test';
        prdgrp1.Group_Type__c = 'Bundle';
        prdgrp1.Active__c = true;
        prdgrp1.Pricing_Model__c = 'test';
        prdgrp1.Play_Offer__c = 'Automation at Work - Predictive Performance';
        prdgrp1.Product__c = list_ProductsToInsert[0].id;
        prdgrp1.Offering_Type__c = 'PureEngage On Premise';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;
        
        
        Product_group__c prdgrp21 = new Product_group__c();
        prdgrp21.Name = 'Drive';
        prdgrp21.Group_Type__c = 'Favorite';
        prdgrp21.User__c = UserInfo.getUserId();
        prdgrp21.Pricing_Model__c ='test';
        prdgrp21.Quantity__c = 10;
        prdgrp21.Active__c = true;
        prdgrp21.Play_Offer__c = 'Automation at Work - Predictive Performance';
        prdgrp21.Product__c = list_ProductsToInsert[0].id;
        prdgrp21.Offering_Type__c = 'PureEngage On Premise';
        prdgrp21.Type__c = 'A la Carte ';
        insert prdgrp21;
        
        Product_Group_Item__c prdgrpItm17 = new Product_Group_Item__c();
        prdgrpItm17.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm17.Product_Group__c= prdgrp21.id;
        prdgrpItm17.Bundle__c = prdgrp21.id;
        prdgrpItm17.Product_Type__c = 'Substitutable';
        prdgrpItm17.select__c = true;
        insert prdgrpItm17; 
        
        Product_Group_Item__c prdgrpItm18 = new Product_Group_Item__c();
        prdgrpItm18.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm18.Bundle__c= prdgrp21.id;
        prdgrpItm18.Product_Group__c= prdgrp21.id;
        prdgrpItm18.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm18.select__c = true;
        insert prdgrpItm18;
        
        Product_group__c prdgrp2 = new Product_group__c();
        prdgrp2.Name = 'Drive';
        prdgrp2.Group_Type__c = 'Campaigns';
        prdgrp2.User__c = UserInfo.getUserId();
        prdgrp2.Pricing_Model__c ='Concurrent';
        prdgrp2.Active__c = true;
        prdgrp2.Play_Offer__c = 'Automation at Work - Predictive Performance';
        prdgrp2.Quantity__c = 10;
        prdgrp2.Product__c = list_ProductsToInsert[0].id;
        prdgrp2.Offering_Type__c = 'PureEngage On Premise';
        prdgrp2.Type__c = 'A la Carte ';
        insert prdgrp2;
        
        Product_Group_Item__c prdgrpItm15 = new Product_Group_Item__c();
        prdgrpItm15.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm15.Product_Group__c = prdgrp2.id;
        prdgrpItm15.Product_Type__c = 'Substitutable';
        prdgrpItm15.select__c = true;
        insert prdgrpItm15; 
        
        Product_Group_Item__c prdgrpItm16 = new Product_Group_Item__c();
        prdgrpItm16.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm16.Product_Group__c = prdgrp2.id;
        prdgrpItm16.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm16.select__c = true;
        insert prdgrpItm16;
        
        Product_Group_Item__c prdgrpItm12 = new Product_Group_Item__c();
        prdgrpItm12.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm12.Product_Group__c = prdgrp1.id;
        prdgrpItm12.Product_Type__c = 'Lab';
        prdgrpItm12.Bundle__c = prdgrp1.id;
        insert prdgrpItm12;
        
        Product_Group_Item__c prdgrpItm13 = new Product_Group_Item__c();
        prdgrpItm13.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm13.Product_Group__c = prdgrp1.id;
        prdgrpItm13.Product_Type__c = 'Lab';
        prdgrpItm13.Bundle__c = prdgrp1.id;
        insert prdgrpItm13;
        
        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Mandatory';
        insert prdgrpItm;
        
        Product_Group_Item__c prdgrpItm1 = new Product_Group_Item__c();
        prdgrpItm1.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm1.Product_Group__c = prdgrp.id;
        prdgrpItm1.Product_Type__c = 'LAB';
        insert prdgrpItm1;
        
        Product_Group_Item__c prdgrpItm2 = new Product_Group_Item__c();
        prdgrpItm2.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm2.Product_Group__c = prdgrp.id;
        prdgrpItm2.Product_Type__c = 'Optional';
        insert prdgrpItm2;
        
        Product_Group_Item__c prdgrpItm3 = new Product_Group_Item__c();
        prdgrpItm3.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm3.Product_Group__c = prdgrp.id;
        prdgrpItm3.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm3.Minimum_Substitutable_Count__c = 2;
        insert prdgrpItm3;
        
        Product_Group_Item__c prdgrpItm8 = new Product_Group_Item__c();
        prdgrpItm8.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm8.Product_Group__c = prdgrp.id;
        prdgrpItm8.Product_Type__c = 'Substitutable';
        prdgrpItm8.select__c = true;
        prdgrpItm8.Substitutable_Product_Group_Item__c = prdgrpItm3.id;
        insert prdgrpItm8;
        
        Product_Group_Item__c prdgrpItm11 = new Product_Group_Item__c();
        prdgrpItm11.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm11.Product_Group__c = prdgrp.id;
        prdgrpItm11.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm11.select__c = true;
        insert prdgrpItm11;
        
        Product_Group_Item__c prdgrpItm9 = new Product_Group_Item__c();
        prdgrpItm9.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm9.Product_Group__c = prdgrp.id;
        prdgrpItm9.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm9.select__c = true;
        insert prdgrpItm9;
        
        Product_Group_Item__c prdgrpItm10 = new Product_Group_Item__c();
        prdgrpItm10.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm10.Product_Group__c = prdgrp.id;
        prdgrpItm10.Product_Type__c = 'Substitutable';
        prdgrpItm10.select__c = true;
        prdgrpItm10.Substitutable_Product_Group_Item__c = prdgrpItm9.id;
        insert prdgrpItm10;
        
        Product_Group_Item__c prdgrpItm14 = new Product_Group_Item__c();
        prdgrpItm14.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm14.Product_Group__c = prdgrp.id;
        prdgrpItm14.Product_Type__c = 'Substitutable';
        prdgrpItm14.select__c = true;
        prdgrpItm14.Substitutable_Product_Group_Item__c = prdgrpItm9.id;
        insert prdgrpItm14; 
        
        Product_Group_Item__c prdgrpItm4 = new Product_Group_Item__c();
        prdgrpItm4.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm4.Product_Group__c = prdgrp.id;
        prdgrpItm4.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm4.select__c = true;
        insert prdgrpItm4;
        
        Product_Group_Item__c prdgrpItm6 = new Product_Group_Item__c();
        prdgrpItm6.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm6.Product_Group__c = prdgrp.id;
        prdgrpItm6.Product_Type__c = 'Substitutable';
        prdgrpItm6.select__c = true;
        prdgrpItm6.Substitutable_Product_Group_Item__c = prdgrpItm4.id;
        insert prdgrpItm6;
        
        Product_Group_Item__c prdgrpItm5 = new Product_Group_Item__c();
        prdgrpItm5.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm5.Product_Group__c = prdgrp.id;
        prdgrpItm5.Product_Type__c = 'HA';
        insert prdgrpItm5;
        
        Product2 objTestProd5 = new Product2();
        objTestProd5.PPU_Product__c = true;
        objTestProd5.SI_Version_Number__c = '8.0';
        objTestProd5.Pricing_Model__c = 'test';
        objTestProd5.Quantity__c = 10;
        objTestProd5.APN_Number__c = 'a0b123';
        objTestProd5.EMEA_Volume_Discount_Eligible__c =true;
        objTestProd5.Name = 'Test Pro1619';
        objTestProd5.OfferingType__c = 'PureEngage Subscription';
        objTestProd5.NG1_PPU_USD__c= 1;
        objTestProd5.Base_Item_Lookup__c = objTestProd.id;
        insert objTestProd5;
        
        Product2 objTestProd6 = new Product2();
        objTestProd6.Pricing_Model__c = 'test';
        objTestProd6.PPU_Product__c = true;
        objTestProd6.SI_Version_Number__c = '8.0';
        objTestProd6.Quantity__c = 10;
        objTestProd6.Name = 'Test Pro1619';
        objTestProd6.EMEA_Volume_Discount_Eligible__c =true;
        objTestProd6.OfferingType__c = 'PureEngage Subscription';
        objTestProd6.NG1_PPU_USD__c= 1;
        objTestProd6.Base_Item_Lookup__c = objTestProd3.id;
        insert objTestProd6;
        
        /*BigMachines__Quote_Product__c qp = new BigMachines__Quote_Product__c();       
        qp.BigMachines__Quote__c = list_NewQuotes[0].Id;
        qp.BigMachines__Quantity__c = 10; 
        qp.Bundle__c = prdgrp.id;
        qp.Ext_List__c = 100000;
        qp.BigMachines__Sales_Price__c = 500; 
        qp.List_Price__c = 2;
        qp.Disc__c = 0;
        qp.Quantity__c = 2;
        insert qp;*/
        
        Business_Rules__c businessRulesObj = new Business_Rules__c();
        businessRulesObj.Name = 'Default Substitutable Count';
        businessRulesObj.Value__c = 4;
        businessRulesObj.IsActive__c = true;
        businessRulesObj.Process__c = 'Dynamic Bundle';
        insert businessRulesObj;
        
        Category_Building_Block_Mapping__c categoryBuildinBlock = new Category_Building_Block_Mapping__c();
        categoryBuildinBlock.Name = '001';
        categoryBuildinBlock.Building_Blocks__c  = 'Genesys Software';
        categoryBuildinBlock.Category__c ='Branch Office';
        insert categoryBuildinBlock;
        
        Category_Building_Block_Mapping__c categoryBuildinBlock1 = new Category_Building_Block_Mapping__c();
        categoryBuildinBlock1.Name = '002';
        categoryBuildinBlock1.Building_Blocks__c  = 'Genesys Software';
        categoryBuildinBlock1.Category__c ='Genesys Universities';
        insert categoryBuildinBlock1;
        
        Taxonomy_Sol_Category_And_Taxonomy_Sol__c taxo = new Taxonomy_Sol_Category_And_Taxonomy_Sol__c ();
        taxo.name = 'Branch Office';
        taxo.Taxonomy_Solution__c ='Analytics;Integration;Platform;Workload Management';
        insert taxo;
        
        Taxonomy_Sol_Category_And_Taxonomy_Sol__c taxo1 = new Taxonomy_Sol_Category_And_Taxonomy_Sol__c ();
        taxo1.name = 'All';
        taxo1.Taxonomy_Solution__c ='Digital;Inbound;Outbound;Self Service';
        insert taxo1;
        
        Taxonomy_Sol_and_Product_Financial__c taxoFinancial = new Taxonomy_Sol_and_Product_Financial__c();
        taxoFinancial.name = 'Analytics';
        taxoFinancial.Product_Financial__c = 'Advisor;CX Insights;Info Mart;Interactive Insights;Predictive Routing;PS Rapid Deployment Packages;';
        insert taxoFinancial;
        
        Business_Rules__c business = new Business_Rules__c();
        business.Name = 'Default Substitutable Count';
        business.Process__c = 'Dynamic Bundle';
        business.IsActive__c = true;
        insert business;
        
        PSRDP_Pricing__c psrdp = new PSRDP_Pricing__c();
        psrdp.Name = 'Australia##'+list_ProductsToInsert[0].Id;
        psrdp.Region__c = 'Australia';
        psrdp.Price__c = 100;
        psrdp.Product_Info__c = list_ProductsToInsert[0].Id;
        insert psrdp;
        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id); 
        System.currentPageReference().getParameters().put('tab', 'search');    
        ConfigurationControllerPPU configObj = new ConfigurationControllerPPU();
        configObj.next();
        configObj.previous();
        configObj.getHasPrevious();
        configObj.getHasNext();
        configObj.first();
        configObj.getPageNumStr();
        configObj.numberOfPages();
        configObj.checkForRequiredConfirmations();
        configObj.confBoxProceed();
        configObj.confBoxCancel();
        configObj.deleteFavorite();
    }
    
    @isTest
    static void intialTests1() { 
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        Set<String> set_APNnumbers = new Set<String>();
        List<Country__c>  testCountries = new List<Country__c>();
        testCountries.add(new Country__c(
        Name = 'EMEA', Region__c = 'EMEA', PSRDP_Region__c='Australia', DAP_Region__c = 'NA', ISO_Code__c = 'USD',  Country__c = 'USA',
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
        insert testCountries;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        list_NewAccts[0].Country__c = testCountries[0].id;
        update list_NewAccts;
        System.assertEquals(list_NewAccts.size(), 1);
        
        List<Opportunity> list_NewOpps = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.name = 'testopp';
        opp.StageName='1.Recognize Needs';
        opp.CloseDate=System.today().addMonths(1);
        opp.accountId = list_NewAccts[0].id;
        opp.Country__c = testCountries[0].id;
        list_NewOpps.add(opp);
        insert list_NewOpps ;
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        list_NewQuotes[0].Multi_Year_Quote__c = true;
        list_NewQuotes[0].Pricing_Model__c = 'Concurrent';
        list_NewQuotes[0].Sold_To_Name__c = list_NewAccts[0].Id;
        list_NewQuotes[0].Quote_Opportunity_Type__c = 'New Pricing';
        list_NewQuotes[0].Offering_Type__c = 'PureEngage Subscription';
        update list_NewQuotes;
        System.assertEquals(list_NewQuotes.size(), 1);
        
        List<CurrencyType> curr = new list<CurrencyType>();
        for(CurrencyType c: [SELECT IsoCode,ConversionRate FROM CurrencyType]){
        curr.add(c);
        }
        Global_Configuration_Settings__c settings = Global_Configuration_Settings__c.getOrgDefaults();
        settings.Branch_Office_Multiplier__c = 0.70;
        settings.Named_User_Pricing_Multiplier__c = 1.30;
        settings.Concurrent_Pricebook_Multiplier__c = 2.00;
        upsert settings Branch_Office_Multiplier__c.Id;
        
        Id RecordTypeIdContact = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();
        
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd = new Product2();
        objTestProd.APN_Number__c = 'Tokens1';
        objTestProd.Pricing_Model__c = 'Branch Office';
        objTestProd.Description__c = 'test1';
        objTestProd.PPU_Product__c = true;
        objTestProd.Product_Name__c = 'test';
        objTestProd.SI_Version_Number__c = '8.0';
        objTestProd.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd.Quantity__c = 10;
        objTestProd.Name = 'Test Prod3'; 
        objTestProd.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Taxonomy_Category__c = 'Branch Office';
        objTestProd.RecordTypeId= RecordTypeIdContact;
        objTestProd.Dont_Publish_In_Quote__c = false;
        objTestProd.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd.Price_Permission__c = 'Public';
        objTestProd.Restricted_Product__c =false;
        objTestProd.Versions_Available__c = 'sdfsdf';
        objTestProd.OfferingType__c = 'PureEngage On Premise';
        objTestProd.NG1_PPU_USD__c= 1;
        objTestProd.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd);
        
        Product2 objTestProd7 = new Product2();
        objTestProd7.APN_Number__c = 'Tokens1';
        objTestProd7.Pricing_Model__c = 'Branch Office';
        objTestProd7.Description__c = 'test1';
        objTestProd7.Product_Name__c = 'test';
        objTestProd7.SI_Version_Number__c = '8.0';
        objTestProd7.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd7.Quantity__c = 10;
        objTestProd7.Name = 'Test Prod3'; 
        objTestProd7.PPU_Product__c = true;
        objTestProd7.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd7.End_of_Support__c = String.valueOf(Date.today());
        objTestProd7.IsActive = true;
        objTestProd7.Taxonomy_Category__c = 'Branch Office';
        objTestProd7.RecordTypeId= RecordTypeIdContact;
        objTestProd7.Dont_Publish_In_Quote__c = false;
        objTestProd7.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd7.Price_Permission__c = 'Public';
        objTestProd7.Restricted_Product__c =false;
        objTestProd7.Versions_Available__c = 'sdfsdf';
        objTestProd7.OfferingType__c = 'PureEngage On Premise';
        objTestProd7.NG1_PPU_USD__c= 1;
        objTestProd7.Quantities_Available__c = 'test;test1';
        objTestProd7.Parent_Product_lookup__c = objTestProd.id;
        list_ProductsToInsert.add(objTestProd7);
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.Quantity__c = 10;
        objTestProd2.Pricing_Model__c = 'Branch Office';
        objTestProd2.Name = 'Test Prod11';  
        objTestProd2.PPU_Product__c = true;
        objTestProd2.SI_Version_Number__c = '4.0';        
        objTestProd2.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd2.Type__c = 'Token';
        objTestProd2.End_of_Support__c = String.valueOf(Date.today());
        objTestProd2.IsActive = true;
        objTestProd2.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd2.RecordTypeId= RecordTypeIdContact;
        objTestProd2.Dont_Publish_In_Quote__c = false;
        objTestProd2.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd2.Price_Permission__c = 'Public';
        objTestProd2.Restricted_Product__c =false;
        objTestProd2.Versions_Available__c = 'sdfsdf';
        objTestProd2.OfferingType__c = 'PureEngage On Premise';
        objTestProd2.zqu__Category__c = 'Add On Services';
        objTestProd2.NG1_PPU_USD__c= 1;
        objTestProd2.Description = 'test 1';
        objTestProd2.APN_Number__c = 'Tokens1';
        objTestProd2.Quantities_Available__c = 'test;test1';
        objTestProd2.Parent_Product_lookup__c = objTestProd.id;
        list_ProductsToInsert.add(objTestProd2);
        
        Product2 objTestProd4 = new Product2();
        objTestProd4.APN_Number__c = 'Tokens1';
        objTestProd4.SI_Version_Number__c = '8.0';
        objTestProd4.Description__c = 'test3';
        objTestProd4.Name = 'Test Prod2619';
        objTestProd4.PPU_Product__c = true;
        objTestProd4.Quantity__c = 10;
        objTestProd4.OfferingType__c = 'PureEngage Subscription';
        objTestProd4.NG1_PPU_USD__c= 1;
        list_ProductsToInsert.add(objTestProd4);
        
        Product2 objTestProd3 = new Product2();
        objTestProd3.Pricing_Model__c = 'testing';
        objTestProd3.Description__c = '1';
        objTestProd3.SI_Version_Number__c = '8.0';
        objTestProd3.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd3.Quantity__c = 10;
        objTestProd3.Name = 'Test Prod2'; 
        objTestProd3.PPU_Product__c = true;
        objTestProd3.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd3.End_of_Support__c = String.valueOf(Date.today());
        objTestProd3.IsActive = true;
        objTestProd3.RecordTypeId= RecordTypeIdContact;
        objTestProd3.Dont_Publish_In_Quote__c = false;
        objTestProd3.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd3.Price_Permission__c = 'Public';
        objTestProd3.Restricted_Product__c =false;
        objTestProd3.Versions_Available__c = 'sdfsdf';
        objTestProd3.OfferingType__c = 'PureEngage Subscription';
        objTestProd3.APN_Number__c = 'Tokens1';
        objTestProd3.NG1_PPU_USD__c= 1;
        objTestProd3.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd3);
        
        Product2 objTestProd1 = new Product2();
        objTestProd1.SI_Version_Number__c = '8.0';
        objTestProd1.Quantity__c = 10;
        objTestProd1.Pricing_Model__c = 'testing';
        objTestProd1.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd1.Name = 'Test Prod';        
        objTestProd1.PPU_Product__c = true;    
        objTestProd1.Type__c = 'Token';
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd1.RecordTypeId= RecordTypeIdContact;
        objTestProd1.Dont_Publish_In_Quote__c = false;
        objTestProd1.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd1.Price_Permission__c = 'Public';
        objTestProd1.Restricted_Product__c =false;
        objTestProd1.Versions_Available__c = 'sdfsdf';
        objTestProd1.OfferingType__c = 'PureEngage Subscription';
        objTestProd1.zqu__Category__c = 'Add On Services';
        objTestProd1.NG1_PPU_USD__c= 1;
        objTestProd1.Base_Item_Lookup__c = objTestProd4.id;
        objTestProd1.Description = 'test 1';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd1);
        
        insert list_ProductsToInsert;
        Test.startTest();  
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Test';
        prdgrp.Group_Type__c = 'Use Case';
        prdgrp.Active__c = true;
        prdgrp.Play_Offer__c = 'Digital Service - Genesys Service Automation';
        prdgrp.Pricing_Model__c = 'test';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Offering_Type__c = 'PureEngage On Premise';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;
        
        Product_Group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Test';
        prdgrp1.Group_Type__c = 'Bundle';
        prdgrp1.Active__c = true;
        prdgrp1.Pricing_Model__c = 'test';
        prdgrp1.Play_Offer__c = 'Automation at Work - Predictive Performance';
        prdgrp1.Product__c = list_ProductsToInsert[0].id;
        prdgrp1.Offering_Type__c = 'PureEngage On Premise';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;
        
        
        Product_group__c prdgrp21 = new Product_group__c();
        prdgrp21.Name = 'Drive';
        prdgrp21.Group_Type__c = 'Favorite';
        prdgrp21.User__c = UserInfo.getUserId();
        prdgrp21.Pricing_Model__c ='test';
        prdgrp21.Play_Offer__c = 'Automation at Work - Predictive Performance';
        prdgrp21.Active__c = true;
        prdgrp21.Quantity__c = 10;
        prdgrp21.Product__c = list_ProductsToInsert[0].id;
        prdgrp21.Offering_Type__c = 'PureEngage On Premise';
        prdgrp21.Type__c = 'A la Carte ';
        insert prdgrp21;
        
        Product_Group_Item__c prdgrpItm17 = new Product_Group_Item__c();
        prdgrpItm17.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm17.Product_Group__c= prdgrp21.id;
        prdgrpItm17.Bundle__c = prdgrp21.id;
        prdgrpItm17.Quantity__c = 2;
        prdgrpItm17.Product_Type__c = 'Substitutable';
        prdgrpItm17.select__c = true;
        insert prdgrpItm17; 
        
        Product_Group_Item__c prdgrpItm18 = new Product_Group_Item__c();
        prdgrpItm18.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm18.Bundle__c= prdgrp21.id;
        prdgrpItm18.Product_Group__c= prdgrp21.id;
        prdgrpItm18.Quantity__c = 2;
        prdgrpItm18.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm18.select__c = true;
        insert prdgrpItm18;
        
        Product_group__c prdgrp2 = new Product_group__c();
        prdgrp2.Name = 'Drive';
        prdgrp2.Group_Type__c = 'Campaigns';
        prdgrp2.User__c = UserInfo.getUserId();
        prdgrp2.Play_Offer__c = 'Automation at Work - Predictive Performance';
        prdgrp2.Pricing_Model__c ='Concurrent';
        prdgrp2.Quantity__c = 10;
        prdgrp2.Active__c = true;
        prdgrp2.Product__c = list_ProductsToInsert[0].id;
        prdgrp2.Offering_Type__c = 'PureEngage On Premise';
        prdgrp2.Type__c = 'A la Carte ';
        insert prdgrp2;
        
        Product_Group_Item__c prdgrpItm15 = new Product_Group_Item__c();
        prdgrpItm15.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm15.Product_Group__c = prdgrp2.id;
        prdgrpItm15.Product_Type__c = 'Substitutable';
        prdgrpItm15.select__c = true;
        prdgrpItm15.Quantity__c = 2;
        insert prdgrpItm15; 
        
        Product_Group_Item__c prdgrpItm16 = new Product_Group_Item__c();
        prdgrpItm16.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm16.Product_Group__c = prdgrp2.id;
        prdgrpItm16.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm16.select__c = true;
        prdgrpItm16.Quantity__c = 2;
        insert prdgrpItm16;
        
        Product_Group_Item__c prdgrpItm12 = new Product_Group_Item__c();
        prdgrpItm12.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm12.Product_Group__c = prdgrp1.id;
        prdgrpItm12.Product_Type__c = 'Lab';
        prdgrpItm12.Bundle__c = prdgrp1.id;
        prdgrpItm12.Quantity__c = 2;
        insert prdgrpItm12;
        
        Product_Group_Item__c prdgrpItm13 = new Product_Group_Item__c();
        prdgrpItm13.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm13.Product_Group__c = prdgrp1.id;
        prdgrpItm13.Product_Type__c = 'Lab';
        prdgrpItm13.Bundle__c = prdgrp1.id;
        prdgrpItm13.Quantity__c = 2;
        insert prdgrpItm13;
        
        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Mandatory';
        prdgrpItm.Quantity__c = 2;
        insert prdgrpItm;
        
        Product_Group_Item__c prdgrpItm1 = new Product_Group_Item__c();
        prdgrpItm1.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm1.Product_Group__c = prdgrp.id;
        prdgrpItm1.Product_Type__c = 'LAB';
        prdgrpItm1.Quantity__c = 2;
        insert prdgrpItm1;
        
        Product_Group_Item__c prdgrpItm2 = new Product_Group_Item__c();
        prdgrpItm2.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm2.Product_Group__c = prdgrp.id;
        prdgrpItm2.Product_Type__c = 'Optional';
        prdgrpItm2.Quantity__c = 2;
        insert prdgrpItm2;
        
        Product_Group_Item__c prdgrpItm3 = new Product_Group_Item__c();
        prdgrpItm3.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm3.Product_Group__c = prdgrp.id;
        prdgrpItm3.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm3.Minimum_Substitutable_Count__c = 2;
        prdgrpItm3.Quantity__c = 2;
        insert prdgrpItm3;
        
        Product_Group_Item__c prdgrpItm8 = new Product_Group_Item__c();
        prdgrpItm8.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm8.Product_Group__c = prdgrp.id;
        prdgrpItm8.Product_Type__c = 'Substitutable';
        prdgrpItm8.select__c = true;
        prdgrpItm8.Quantity__c = 2;
        prdgrpItm8.Substitutable_Product_Group_Item__c = prdgrpItm3.id;
        insert prdgrpItm8;
        
        Product_Group_Item__c prdgrpItm11 = new Product_Group_Item__c();
        prdgrpItm11.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm11.Product_Group__c = prdgrp.id;
        prdgrpItm11.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm11.select__c = true;
        prdgrpItm11.Quantity__c = 2;
        insert prdgrpItm11;
        
        Product_Group_Item__c prdgrpItm9 = new Product_Group_Item__c();
        prdgrpItm9.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm9.Product_Group__c = prdgrp.id;
        prdgrpItm9.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm9.select__c = true;
        prdgrpItm9.Quantity__c = 2;
        insert prdgrpItm9;
        
        Product_Group_Item__c prdgrpItm10 = new Product_Group_Item__c();
        prdgrpItm10.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm10.Product_Group__c = prdgrp.id;
        prdgrpItm10.Product_Type__c = 'Substitutable';
        prdgrpItm10.select__c = true;
        prdgrpItm10.Quantity__c = 2;
        prdgrpItm10.Substitutable_Product_Group_Item__c = prdgrpItm9.id;
        insert prdgrpItm10;
        
        Product_Group_Item__c prdgrpItm14 = new Product_Group_Item__c();
        prdgrpItm14.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm14.Product_Group__c = prdgrp.id;
        prdgrpItm14.Product_Type__c = 'Substitutable';
        prdgrpItm14.select__c = true;
        prdgrpItm14.Quantity__c = 2;
        prdgrpItm14.Substitutable_Product_Group_Item__c = prdgrpItm9.id;
        insert prdgrpItm14; 
        
        Product_Group_Item__c prdgrpItm4 = new Product_Group_Item__c();
        prdgrpItm4.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm4.Product_Group__c = prdgrp.id;
        prdgrpItm4.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm4.select__c = true;
        prdgrpItm4.Quantity__c = 2;
        insert prdgrpItm4;
        
        Product_Group_Item__c prdgrpItm6 = new Product_Group_Item__c();
        prdgrpItm6.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm6.Product_Group__c = prdgrp.id;
        prdgrpItm6.Product_Type__c = 'Substitutable';
        prdgrpItm6.select__c = true;
        prdgrpItm6.Quantity__c = 2;
        prdgrpItm6.Substitutable_Product_Group_Item__c = prdgrpItm4.id;
        insert prdgrpItm6;
        
        Product_Group_Item__c prdgrpItm5 = new Product_Group_Item__c();
        prdgrpItm5.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm5.Product_Group__c = prdgrp.id;
        prdgrpItm5.Product_Type__c = 'HA';
        prdgrpItm5.Quantity__c = 2;
        insert prdgrpItm5;
        
        Product2 objTestProd5 = new Product2();
        objTestProd5.SI_Version_Number__c = '8.0';
        objTestProd5.Pricing_Model__c = 'test';
        objTestProd5.Quantity__c = 10;
        objTestProd5.APN_Number__c = 'a0b123';
        objTestProd5.EMEA_Volume_Discount_Eligible__c =true;
        objTestProd5.Name = 'Test Pro1619';
        objTestProd5.OfferingType__c = 'PureEngage Subscription';
        objTestProd5.NG5_NA_USD_Price__c = 1;
        objTestProd5.Base_Item_Lookup__c = objTestProd.id;
        insert objTestProd5;
        
        Product2 objTestProd6 = new Product2();
        objTestProd6.Pricing_Model__c = 'test';
        objTestProd6.SI_Version_Number__c = '8.0';
        objTestProd6.Quantity__c = 10;
        objTestProd6.Name = 'Test Pro1619';
        objTestProd6.EMEA_Volume_Discount_Eligible__c =true;
        objTestProd6.OfferingType__c = 'PureEngage Subscription';
        objTestProd6.NG5_NA_USD_Price__c = 1;
        objTestProd6.Base_Item_Lookup__c = objTestProd3.id;
        insert objTestProd6;
        
        /*BigMachines__Quote_Product__c qp = new BigMachines__Quote_Product__c();       
        qp.BigMachines__Quote__c = list_NewQuotes[0].Id;
        qp.BigMachines__Quantity__c = 10; 
        qp.Bundle__c = prdgrp.id;
        qp.Ext_List__c = 100000;
        qp.BigMachines__Sales_Price__c = 500; 
        qp.List_Price__c = 2;
        qp.Disc__c = 0;
        qp.Quantity__c = 2;
        insert qp;*/
        
        Business_Rules__c businessRulesObj = new Business_Rules__c();
        businessRulesObj.Name = 'Default Substitutable Count';
        businessRulesObj.Value__c = 4;
        businessRulesObj.IsActive__c = true;
        businessRulesObj.Process__c = 'Dynamic Bundle';
        insert businessRulesObj;
        
        Category_Building_Block_Mapping__c categoryBuildinBlock = new Category_Building_Block_Mapping__c();
        categoryBuildinBlock.Name = '001';
        categoryBuildinBlock.Building_Blocks__c  = 'Genesys Software';
        categoryBuildinBlock.Category__c ='Branch Office';
        insert categoryBuildinBlock;
        
        Category_Building_Block_Mapping__c categoryBuildinBlock1 = new Category_Building_Block_Mapping__c();
        categoryBuildinBlock1.Name = '002';
        categoryBuildinBlock1.Building_Blocks__c  = 'Genesys Software';
        categoryBuildinBlock1.Category__c ='Genesys Universities';
        insert categoryBuildinBlock1;
        
        Taxonomy_Sol_Category_And_Taxonomy_Sol__c taxo = new Taxonomy_Sol_Category_And_Taxonomy_Sol__c ();
        taxo.name = 'Branch Office';
        taxo.Taxonomy_Solution__c ='Analytics;Integration;Platform;Workload Management';
        insert taxo;
        
        Taxonomy_Sol_Category_And_Taxonomy_Sol__c taxo1 = new Taxonomy_Sol_Category_And_Taxonomy_Sol__c ();
        taxo1.name = 'All';
        taxo1.Taxonomy_Solution__c ='Digital;Inbound;Outbound;Self Service';
        insert taxo1;
        
        Taxonomy_Sol_and_Product_Financial__c taxoFinancial = new Taxonomy_Sol_and_Product_Financial__c();
        taxoFinancial.name = 'Analytics';
        taxoFinancial.Product_Financial__c = 'Advisor;CX Insights;Info Mart;Interactive Insights;Predictive Routing;PS Rapid Deployment Packages;';
        insert taxoFinancial;
        
        Business_Rules__c business = new Business_Rules__c();
        business.Name = 'Default Substitutable Count';
        business.Process__c = 'Dynamic Bundle';
        business.IsActive__c = true;
        insert business;
        
        PSRDP_Pricing__c psrdp = new PSRDP_Pricing__c();
        psrdp.Name = 'Australia##'+list_ProductsToInsert[0].Id;
        psrdp.Region__c = 'Australia';
        psrdp.Price__c = 100;
        psrdp.Product_Info__c = list_ProductsToInsert[0].Id;
        insert psrdp;
        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);   
        ConfigurationControllerPPU configObj = new ConfigurationControllerPPU();
        configObj.strGroupId = prdgrp1.id;
        configObj.strFavId = prdgrp21.id;
        configObj.strSelectedTaxonomyCategorySolution = 'All';
        configObj.addProductsBtnHandler();
        configObj.bundleOptionHandler();
        configObj.favouritesOptionHandler();
        configObj.list_Favourites[0].blnIsSelected = true;
        configObj.showHideFavoriteItems();
        configObj.deleteFavorite();
        configObj.addFavoritesBtnHandler();
        configObj.CampaignsOptionHandler();
        configObj.refresh();
        configObj.showProductInfo();
        configObj.showProductInfoFromBaseItem();
        configObj.hideProductInfo();
        configObj.showHideProducts();
        configObj.useCaseOptionHandler();
        configObj.addBundlesBtnHandler();
        configObj.saveLogic();
        configObj.addProductsFromSearch();
        //configObj.addCampaignssBtnHandler();
        configObj.markFavBtnHandler();
        configObj.objFavToBeSaved.Name = 'test';
        configObj.saveFavourite();
        configObj.strProdIndex = '1';
        configObj.removeProduct();
        configObj.removeProductBundle();
        configObj.removeAllBtnHandler();
        configObj.cancelMarkFavourite();
        configObj.saveBtnHandler();
    }
    
    @isTest(SeeAllData = true)
    static void otherTest1(){
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        
        List<Opportunity> list_NewOpps = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.name = 'testopp';
        opp.StageName='1.Recognize Needs';
        opp.CloseDate=System.today().addMonths(1);
        opp.accountId = list_NewAccts[0].id;
        list_NewOpps.add(opp);
        insert list_NewOpps ;
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        list_NewQuotes[0].Multi_Year_Quote__c = true;
        list_NewQuotes[0].Pricing_Model__c = 'Concurrent';
        list_NewQuotes[0].Sold_To_Name__c = list_NewAccts[0].Id;
        list_NewQuotes[0].Quote_Opportunity_Type__c = 'New Pricing';
        list_NewQuotes[0].Offering_Type__c = 'PureEngage Subscription';
        //list_NewQuotes[0].Opp_Sold_To_Country__c = testCountries[0].id;
        update list_NewQuotes;
        System.assertEquals(list_NewQuotes.size(), 1);
        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);   
        ConfigurationControllerPPU configObj = new ConfigurationControllerPPU();
        configObj.strSelectedTaxonomyCategorySolution = 'All';
        //configObj.addProductsBtnHandler();
        configObj.bundleOptionHandler();
        configObj.useCaseOptionHandler();
        configObj.addBundlesBtnHandler();
        configObj.favouritesOptionHandler();
        configObj.addFavoritesBtnHandler();
        configObj.showHideFavoriteItems();
        configObj.CampaignsOptionHandler();
        configObj.refresh();
        configObj.showProductInfo();
        configObj.showProductInfoFromBaseItem();
        configObj.showHideProducts();
        configObj.hideProductInfo();
        configObj.addProductsFromSearch();
        //configObj.addCampaignssBtnHandler();
        configObj.markFavBtnHandler();
        configObj.saveFavourite();
        configObj.cancelMarkFavourite();
        configObj.saveBtnHandler();
        configObj.deleteFavorite();
    }
    
    static testmethod void intialTests2() { 
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        Set<String> set_APNnumbers = new Set<String>();
        List<Country__c>  testCountries = new List<Country__c>();
        testCountries.add(new Country__c(
        Name = 'United States', Region__c = 'EMEA', PSRDP_Region__c='Australia', DAP_Region__c = 'NA', ISO_Code__c = 'USD',  Country__c = 'USA',
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
        insert testCountries;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        list_NewAccts[0].Country__c = testCountries[0].id;
        update list_NewAccts;
        System.assertEquals(list_NewAccts.size(), 1);
        
        List<Opportunity> list_NewOpps = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.name = 'testopp';
        opp.StageName='1.Recognize Needs';
        opp.CloseDate=System.today().addMonths(1);
        opp.accountId = list_NewAccts[0].id;
        list_NewOpps.add(opp);
        insert list_NewOpps ;
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        list_NewQuotes[0].Multi_Year_Quote__c = true;
        list_NewQuotes[0].Pricing_Model__c = 'Concurrent';
        list_NewQuotes[0].Sold_To_Name__c = list_NewAccts[0].Id;
        list_NewQuotes[0].Quote_Opportunity_Type__c = 'New Pricing';
        list_NewQuotes[0].Offering_Type__c = 'PureEngage Subscription';
        //list_NewQuotes[0].Opp_Sold_To_Country__c = testCountries[0].id;
        update list_NewQuotes;
        System.assertEquals(list_NewQuotes.size(), 1);
        
        List<CurrencyType> curr = new list<CurrencyType>();
        for(CurrencyType c: [SELECT IsoCode,ConversionRate FROM CurrencyType]){
        curr.add(c);
        }
        Global_Configuration_Settings__c settings = Global_Configuration_Settings__c.getOrgDefaults();
        settings.Branch_Office_Multiplier__c = 0.70;
        settings.Named_User_Pricing_Multiplier__c = 1.30;
        settings.Concurrent_Pricebook_Multiplier__c = 2.00;
        upsert settings Branch_Office_Multiplier__c.Id;
        
        Id RecordTypeIdContact = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();
        
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd = new Product2();
        objTestProd.APN_Number__c = 'Tokens1';
        objTestProd.Pricing_Model__c = 'Branch Office';
        objTestProd.Description__c = 'test1';
        objTestProd.PPU_Product__c = true;
        objTestProd.Product_Name__c = 'test';
        objTestProd.SI_Version_Number__c = '8.0';
        objTestProd.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd.Quantity__c = 10;
        objTestProd.Name = 'Test Prod3'; 
        objTestProd.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Taxonomy_Category__c = 'Branch Office';
        objTestProd.RecordTypeId= RecordTypeIdContact;
        objTestProd.Dont_Publish_In_Quote__c = false;
        objTestProd.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd.Price_Permission__c = 'Public';
        objTestProd.Restricted_Product__c =false;
        objTestProd.Versions_Available__c = 'sdfsdf';
        objTestProd.OfferingType__c = 'PureEngage On Premise';
        objTestProd.NG1_PPU_USD__c= 1;
        objTestProd.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd);
        
        Product2 objTestProd7 = new Product2();
        objTestProd7.APN_Number__c = 'Tokens1';
        objTestProd7.Pricing_Model__c = 'Branch Office';
        objTestProd7.Description__c = 'test1';
        objTestProd7.Product_Name__c = 'test';
        objTestProd7.SI_Version_Number__c = '8.0';
        objTestProd7.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd7.Quantity__c = 10;
        objTestProd7.Name = 'Test Prod3'; 
        objTestProd7.PPU_Product__c = true;
        objTestProd7.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd7.End_of_Support__c = String.valueOf(Date.today());
        objTestProd7.IsActive = true;
        objTestProd7.Taxonomy_Category__c = 'Branch Office';
        objTestProd7.RecordTypeId= RecordTypeIdContact;
        objTestProd7.Dont_Publish_In_Quote__c = false;
        objTestProd7.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd7.Price_Permission__c = 'Public';
        objTestProd7.Restricted_Product__c =false;
        objTestProd7.Versions_Available__c = 'sdfsdf';
        objTestProd7.OfferingType__c = 'PureEngage On Premise';
        objTestProd7.NG1_PPU_USD__c= 1;
        objTestProd7.Quantities_Available__c = 'test;test1';
        objTestProd7.Parent_Product_lookup__c = objTestProd.id;
        list_ProductsToInsert.add(objTestProd7);
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.Quantity__c = 10;
        objTestProd2.Pricing_Model__c = 'Branch Office';
        objTestProd2.Name = 'Test Prod11';  
        objTestProd2.PPU_Product__c = true;
        objTestProd2.SI_Version_Number__c = '4.0';        
        objTestProd2.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd2.Type__c = 'Token';
        objTestProd2.End_of_Support__c = String.valueOf(Date.today());
        objTestProd2.IsActive = true;
        objTestProd2.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd2.RecordTypeId= RecordTypeIdContact;
        objTestProd2.Dont_Publish_In_Quote__c = false;
        objTestProd2.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd2.Price_Permission__c = 'Public';
        objTestProd2.Restricted_Product__c =false;
        objTestProd2.Versions_Available__c = 'sdfsdf';
        objTestProd2.OfferingType__c = 'PureEngage On Premise';
        objTestProd2.zqu__Category__c = 'Add On Services';
        objTestProd2.NG1_PPU_USD__c= 1;
        objTestProd2.Description = 'test 1';
        objTestProd2.APN_Number__c = 'Tokens1';
        objTestProd2.Quantities_Available__c = 'test;test1';
        objTestProd2.Parent_Product_lookup__c = objTestProd.id;
        list_ProductsToInsert.add(objTestProd2);
        
        Product2 objTestProd4 = new Product2();
        objTestProd4.APN_Number__c = 'Tokens1';
        objTestProd4.SI_Version_Number__c = '8.0';
        objTestProd4.Description__c = 'test3';
        objTestProd4.Name = 'Test Prod2619';
        objTestProd4.PPU_Product__c = true;
        objTestProd4.Quantity__c = 10;
        objTestProd4.OfferingType__c = 'PureEngage Subscription';
        objTestProd4.NG1_PPU_USD__c= 1;
        list_ProductsToInsert.add(objTestProd4);
        
        Product2 objTestProd3 = new Product2();
        objTestProd3.Pricing_Model__c = 'testing';
        objTestProd3.Description__c = '1';
        objTestProd3.SI_Version_Number__c = '8.0';
        objTestProd3.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd3.Quantity__c = 10;
        objTestProd3.Name = 'Test Prod2'; 
        objTestProd3.PPU_Product__c = true;
        objTestProd3.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd3.End_of_Support__c = String.valueOf(Date.today());
        objTestProd3.IsActive = true;
        objTestProd3.RecordTypeId= RecordTypeIdContact;
        objTestProd3.Dont_Publish_In_Quote__c = false;
        objTestProd3.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd3.Price_Permission__c = 'Public';
        objTestProd3.Restricted_Product__c =false;
        objTestProd3.Versions_Available__c = 'sdfsdf';
        objTestProd3.OfferingType__c = 'PureEngage Subscription';
        objTestProd3.APN_Number__c = 'Tokens1';
        objTestProd3.NG1_PPU_USD__c= 1;
        objTestProd3.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd3);
        
        Product2 objTestProd1 = new Product2();
        objTestProd1.SI_Version_Number__c = '8.0';
        objTestProd1.Quantity__c = 10;
        objTestProd1.Pricing_Model__c = 'testing';
        objTestProd1.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd1.Name = 'Test Prod';        
        objTestProd1.PPU_Product__c = true;    
        objTestProd1.Type__c = 'Token';
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd1.RecordTypeId= RecordTypeIdContact;
        objTestProd1.Dont_Publish_In_Quote__c = false;
        objTestProd1.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd1.Price_Permission__c = 'Public';
        objTestProd1.Restricted_Product__c =false;
        objTestProd1.Versions_Available__c = 'sdfsdf';
        objTestProd1.OfferingType__c = 'PureEngage Subscription';
        objTestProd1.zqu__Category__c = 'Add On Services';
        objTestProd1.NG1_PPU_USD__c= 1;
        objTestProd1.Base_Item_Lookup__c = objTestProd4.id;
        objTestProd1.Description = 'test 1';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd1);
        
        insert list_ProductsToInsert;
        Test.startTest();  
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Test';
        prdgrp.Group_Type__c = 'Use Case';
        prdgrp.Active__c = true;
        prdgrp.Play_Offer__c = 'Digital Service - Genesys Service Automation';
        prdgrp.Pricing_Model__c = 'test';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Offering_Type__c = 'PureEngage On Premise';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;
        
        Product_Group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Test';
        prdgrp1.Group_Type__c = 'Bundle';
        prdgrp1.Active__c = true;
        prdgrp1.Pricing_Model__c = 'test';
        prdgrp1.Play_Offer__c = 'Automation at Work - Predictive Performance';
        prdgrp1.Product__c = list_ProductsToInsert[0].id;
        prdgrp1.Offering_Type__c = 'PureEngage On Premise';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;
        
        
        Product_group__c prdgrp21 = new Product_group__c();
        prdgrp21.Name = 'Drive';
        prdgrp21.Group_Type__c = 'Favorite';
        prdgrp21.User__c = UserInfo.getUserId();
        prdgrp21.Pricing_Model__c ='test';
        prdgrp21.Active__c = true;
        prdgrp21.Play_Offer__c = 'Automation at Work - Predictive Performance';
        prdgrp21.Quantity__c = 10;
        prdgrp21.Product__c = list_ProductsToInsert[0].id;
        prdgrp21.Offering_Type__c = 'PureEngage On Premise';
        prdgrp21.Type__c = 'A la Carte ';
        insert prdgrp21;
        
        Product_Group_Item__c prdgrpItm17 = new Product_Group_Item__c();
        prdgrpItm17.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm17.Product_Group__c= prdgrp21.id;
        prdgrpItm17.Bundle__c = prdgrp21.id;
        prdgrpItm17.Product_Type__c = 'Substitutable';
        prdgrpItm17.select__c = true;
        insert prdgrpItm17; 
        
        Product_Group_Item__c prdgrpItm18 = new Product_Group_Item__c();
        prdgrpItm18.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm18.Bundle__c= prdgrp21.id;
        prdgrpItm18.Product_Group__c= prdgrp21.id;
        prdgrpItm18.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm18.select__c = true;
        insert prdgrpItm18;
        
        Product_group__c prdgrp2 = new Product_group__c();
        prdgrp2.Name = 'Drive';
        prdgrp2.Group_Type__c = 'Campaigns';
        prdgrp2.User__c = UserInfo.getUserId();
        prdgrp2.Pricing_Model__c ='Concurrent';
        prdgrp2.Quantity__c = 10;
        prdgrp2.Play_Offer__c = 'Automation at Work - Predictive Performance';
        prdgrp2.Active__c = true;
        prdgrp2.Product__c = list_ProductsToInsert[0].id;
        prdgrp2.Offering_Type__c = 'PureEngage On Premise';
        prdgrp2.Type__c = 'A la Carte ';
        insert prdgrp2;
        
        Product_Group_Item__c prdgrpItm15 = new Product_Group_Item__c();
        prdgrpItm15.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm15.Product_Group__c = prdgrp2.id;
        prdgrpItm15.Product_Type__c = 'Substitutable';
        prdgrpItm15.select__c = true;
        insert prdgrpItm15; 
        
        Product_Group_Item__c prdgrpItm16 = new Product_Group_Item__c();
        prdgrpItm16.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm16.Product_Group__c = prdgrp2.id;
        prdgrpItm16.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm16.select__c = true;
        insert prdgrpItm16;
        
        Product_Group_Item__c prdgrpItm12 = new Product_Group_Item__c();
        prdgrpItm12.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm12.Product_Group__c = prdgrp1.id;
        prdgrpItm12.Product_Type__c = 'Lab';
        prdgrpItm12.Bundle__c = prdgrp1.id;
        insert prdgrpItm12;
        
        Product_Group_Item__c prdgrpItm13 = new Product_Group_Item__c();
        prdgrpItm13.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm13.Product_Group__c = prdgrp1.id;
        prdgrpItm13.Product_Type__c = 'Lab';
        prdgrpItm13.Bundle__c = prdgrp1.id;
        insert prdgrpItm13;
        
        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Mandatory';
        insert prdgrpItm;
        
        Product_Group_Item__c prdgrpItm1 = new Product_Group_Item__c();
        prdgrpItm1.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm1.Product_Group__c = prdgrp.id;
        prdgrpItm1.Product_Type__c = 'LAB';
        insert prdgrpItm1;
        
        Product_Group_Item__c prdgrpItm2 = new Product_Group_Item__c();
        prdgrpItm2.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm2.Product_Group__c = prdgrp.id;
        prdgrpItm2.Product_Type__c = 'Optional';
        insert prdgrpItm2;
        
        Product_Group_Item__c prdgrpItm3 = new Product_Group_Item__c();
        prdgrpItm3.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm3.Product_Group__c = prdgrp.id;
        prdgrpItm3.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm3.Minimum_Substitutable_Count__c = 2;
        insert prdgrpItm3;
        
        Product_Group_Item__c prdgrpItm8 = new Product_Group_Item__c();
        prdgrpItm8.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm8.Product_Group__c = prdgrp.id;
        prdgrpItm8.Product_Type__c = 'Substitutable';
        prdgrpItm8.select__c = true;
        prdgrpItm8.Substitutable_Product_Group_Item__c = prdgrpItm3.id;
        insert prdgrpItm8;
        
        Product_Group_Item__c prdgrpItm11 = new Product_Group_Item__c();
        prdgrpItm11.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm11.Product_Group__c = prdgrp.id;
        prdgrpItm11.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm11.select__c = true;
        insert prdgrpItm11;
        
        Product_Group_Item__c prdgrpItm9 = new Product_Group_Item__c();
        prdgrpItm9.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm9.Product_Group__c = prdgrp.id;
        prdgrpItm9.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm9.select__c = true;
        insert prdgrpItm9;
        
        Product_Group_Item__c prdgrpItm10 = new Product_Group_Item__c();
        prdgrpItm10.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm10.Product_Group__c = prdgrp.id;
        prdgrpItm10.Product_Type__c = 'Substitutable';
        prdgrpItm10.select__c = true;
        prdgrpItm10.Substitutable_Product_Group_Item__c = prdgrpItm9.id;
        insert prdgrpItm10;
        
        Product_Group_Item__c prdgrpItm14 = new Product_Group_Item__c();
        prdgrpItm14.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm14.Product_Group__c = prdgrp.id;
        prdgrpItm14.Product_Type__c = 'Substitutable';
        prdgrpItm14.select__c = true;
        prdgrpItm14.Substitutable_Product_Group_Item__c = prdgrpItm9.id;
        insert prdgrpItm14; 
        
        Product_Group_Item__c prdgrpItm4 = new Product_Group_Item__c();
        prdgrpItm4.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm4.Product_Group__c = prdgrp.id;
        prdgrpItm4.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm4.select__c = true;
        insert prdgrpItm4;
        
        Product_Group_Item__c prdgrpItm6 = new Product_Group_Item__c();
        prdgrpItm6.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm6.Product_Group__c = prdgrp.id;
        prdgrpItm6.Product_Type__c = 'Substitutable';
        prdgrpItm6.select__c = true;
        prdgrpItm6.Substitutable_Product_Group_Item__c = prdgrpItm4.id;
        insert prdgrpItm6;
        
        Product_Group_Item__c prdgrpItm5 = new Product_Group_Item__c();
        prdgrpItm5.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm5.Product_Group__c = prdgrp.id;
        prdgrpItm5.Product_Type__c = 'HA';
        insert prdgrpItm5;
        
        Product2 objTestProd5 = new Product2();
        objTestProd5.SI_Version_Number__c = '8.0';
        objTestProd5.Pricing_Model__c = 'test';
        objTestProd5.Quantity__c = 10;
        objTestProd5.APN_Number__c = 'a0b123';
        objTestProd5.EMEA_Volume_Discount_Eligible__c =true;
        objTestProd5.Name = 'Test Pro1619';
        objTestProd5.OfferingType__c = 'PureEngage Subscription';
        objTestProd5.NG5_NA_USD_Price__c = 1;
        objTestProd5.Base_Item_Lookup__c = objTestProd.id;
        insert objTestProd5;
        
        Product2 objTestProd6 = new Product2();
        objTestProd6.Pricing_Model__c = 'test';
        objTestProd6.SI_Version_Number__c = '8.0';
        objTestProd6.Quantity__c = 10;
        objTestProd6.Name = 'Test Pro1619';
        objTestProd6.EMEA_Volume_Discount_Eligible__c =true;
        objTestProd6.OfferingType__c = 'PureEngage Subscription';
        objTestProd6.NG5_NA_USD_Price__c = 1;
        objTestProd6.Base_Item_Lookup__c = objTestProd3.id;
        insert objTestProd6;
        
        /*BigMachines__Quote_Product__c qp = new BigMachines__Quote_Product__c();       
        qp.BigMachines__Quote__c = list_NewQuotes[0].Id;
        qp.BigMachines__Quantity__c = 10; 
        qp.Bundle__c = prdgrp.id;
        qp.Ext_List__c = 100000;
        qp.BigMachines__Sales_Price__c = 500; 
        qp.List_Price__c = 2;
        qp.Disc__c = 0;
        qp.Quantity__c = 2;
        insert qp;*/
        
        Business_Rules__c businessRulesObj = new Business_Rules__c();
        businessRulesObj.Name = 'Default Substitutable Count';
        businessRulesObj.Value__c = 4;
        businessRulesObj.IsActive__c = true;
        businessRulesObj.Process__c = 'Dynamic Bundle';
        insert businessRulesObj;
        
        Category_Building_Block_Mapping__c categoryBuildinBlock = new Category_Building_Block_Mapping__c();
        categoryBuildinBlock.Name = '001';
        categoryBuildinBlock.Building_Blocks__c  = 'Genesys Software';
        categoryBuildinBlock.Category__c ='Branch Office';
        insert categoryBuildinBlock;
        
        Category_Building_Block_Mapping__c categoryBuildinBlock1 = new Category_Building_Block_Mapping__c();
        categoryBuildinBlock1.Name = '002';
        categoryBuildinBlock1.Building_Blocks__c  = 'Genesys Software';
        categoryBuildinBlock1.Category__c ='Genesys Universities';
        insert categoryBuildinBlock1;
        
        Taxonomy_Sol_Category_And_Taxonomy_Sol__c taxo = new Taxonomy_Sol_Category_And_Taxonomy_Sol__c ();
        taxo.name = 'Branch Office';
        taxo.Taxonomy_Solution__c ='Analytics;Integration;Platform;Workload Management';
        insert taxo;
        
        Taxonomy_Sol_Category_And_Taxonomy_Sol__c taxo1 = new Taxonomy_Sol_Category_And_Taxonomy_Sol__c ();
        taxo1.name = 'All';
        taxo1.Taxonomy_Solution__c ='Digital;Inbound;Outbound;Self Service';
        insert taxo1;
        
        Taxonomy_Sol_and_Product_Financial__c taxoFinancial = new Taxonomy_Sol_and_Product_Financial__c();
        taxoFinancial.name = 'Analytics';
        taxoFinancial.Product_Financial__c = 'Advisor;CX Insights;Info Mart;Interactive Insights;Predictive Routing;PS Rapid Deployment Packages;';
        insert taxoFinancial;
        
        Business_Rules__c business = new Business_Rules__c();
        business.Name = 'Default Substitutable Count';
        business.Process__c = 'Dynamic Bundle';
        business.IsActive__c = true;
        insert business;
        
        PSRDP_Pricing__c psrdp = new PSRDP_Pricing__c();
        psrdp.Name = 'Australia##'+list_ProductsToInsert[0].Id;
        psrdp.Region__c = 'Australia';
        psrdp.Price__c = 100;
        psrdp.Product_Info__c = list_ProductsToInsert[0].Id;
        insert psrdp;
        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);   
        ConfigurationControllerPPU configObj = new ConfigurationControllerPPU();
        configObj.strGroupId = prdgrp1.id;
        configObj.strFavId = prdgrp21.id;
        configObj.strSelectedTaxonomyCategorySolution = 'All';
        configObj.addProductsBtnHandler();
        configObj.bundleOptionHandler();
        configObj.showHideProducts();
    }
    
    @isTest
    static void intialTests3() { 
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        Set<String> set_APNnumbers = new Set<String>();
        List<Country__c>  testCountries = new List<Country__c>();
        testCountries.add(new Country__c(
        Name = 'United States', Region__c = 'EMEA', PSRDP_Region__c='Australia', DAP_Region__c = 'NA', ISO_Code__c = 'USD',  Country__c = 'USA',
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
        insert testCountries;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        list_NewAccts[0].Country__c = testCountries[0].id;
        update list_NewAccts;
        System.assertEquals(list_NewAccts.size(), 1);
        
        List<Opportunity> list_NewOpps = new List<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.name = 'testopp';
        opp.StageName='1.Recognize Needs';
        opp.CloseDate=System.today().addMonths(1);
        opp.accountId = list_NewAccts[0].id;
        list_NewOpps.add(opp);
        insert list_NewOpps ;
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        list_NewQuotes[0].Multi_Year_Quote__c = true;
        list_NewQuotes[0].Pricing_Model__c = 'Concurrent';
        list_NewQuotes[0].Sold_To_Name__c = list_NewAccts[0].Id;
        list_NewQuotes[0].Quote_Opportunity_Type__c = 'New Pricing';
        list_NewQuotes[0].Offering_Type__c = 'PureEngage Subscription';
        //list_NewQuotes[0].Opp_Sold_To_Country__c = testCountries[0].id;
        update list_NewQuotes;
        System.assertEquals(list_NewQuotes.size(), 1);
        
        List<CurrencyType> curr = new list<CurrencyType>();
        for(CurrencyType c: [SELECT IsoCode,ConversionRate FROM CurrencyType]){
        curr.add(c);
        }
        Global_Configuration_Settings__c settings = Global_Configuration_Settings__c.getOrgDefaults();
        settings.Branch_Office_Multiplier__c = 0.70;
        settings.Named_User_Pricing_Multiplier__c = 1.30;
        settings.Concurrent_Pricebook_Multiplier__c = 2.00;
        upsert settings Branch_Office_Multiplier__c.Id;
        
        Id RecordTypeIdContact = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();
        
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd = new Product2();
        objTestProd.APN_Number__c = '1';
        objTestProd.Pricing_Model__c = 'Branch Office';
        objTestProd.Description__c = 'test1';
        objTestProd.PPU_Product__c = true;
        objTestProd.Product_Name__c = 'test';
        objTestProd.SI_Version_Number__c = '8.0';
        objTestProd.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd.Quantity__c = 10;
        objTestProd.Name = 'Test Prod3'; 
        objTestProd.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.Taxonomy_Category__c = 'Branch Office';
        objTestProd.RecordTypeId= RecordTypeIdContact;
        objTestProd.Dont_Publish_In_Quote__c = false;
        objTestProd.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd.Price_Permission__c = 'Public';
        objTestProd.Restricted_Product__c =false;
        objTestProd.Versions_Available__c = 'sdfsdf';
        objTestProd.OfferingType__c = 'PureEngage On Premise';
        objTestProd.NG1_PPU_USD__c= 1;
        objTestProd.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd);
        
        Product2 objTestProd7 = new Product2();
        objTestProd7.APN_Number__c = '1';
        objTestProd7.Pricing_Model__c = 'Branch Office';
        objTestProd7.Description__c = 'test1';
        objTestProd7.Product_Name__c = 'test';
        objTestProd7.SI_Version_Number__c = '8.0';
        objTestProd7.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd7.Quantity__c = 10;
        objTestProd7.Name = 'Test Prod3'; 
        objTestProd7.PPU_Product__c = true;
        objTestProd7.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd7.End_of_Support__c = String.valueOf(Date.today());
        objTestProd7.IsActive = true;
        objTestProd7.Taxonomy_Category__c = 'Branch Office';
        objTestProd7.RecordTypeId= RecordTypeIdContact;
        objTestProd7.Dont_Publish_In_Quote__c = false;
        objTestProd7.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd7.Price_Permission__c = 'Public';
        objTestProd7.Restricted_Product__c =false;
        objTestProd7.Versions_Available__c = 'sdfsdf';
        objTestProd7.OfferingType__c = 'PureEngage On Premise';
        objTestProd7.NG1_PPU_USD__c= 1;
        objTestProd7.Quantities_Available__c = 'test;test1';
        objTestProd7.Parent_Product_lookup__c = objTestProd.id;
        list_ProductsToInsert.add(objTestProd7);
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.Quantity__c = 10;
        objTestProd2.Pricing_Model__c = 'Branch Office';
        objTestProd2.Name = 'Test Prod11';  
        objTestProd2.PPU_Product__c = true;
        objTestProd2.SI_Version_Number__c = '4.0';        
        objTestProd2.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd2.Type__c = 'Token';
        objTestProd2.End_of_Support__c = String.valueOf(Date.today());
        objTestProd2.IsActive = true;
        objTestProd2.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd2.RecordTypeId= RecordTypeIdContact;
        objTestProd2.Dont_Publish_In_Quote__c = false;
        objTestProd2.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd2.Price_Permission__c = 'Public';
        objTestProd2.Restricted_Product__c =false;
        objTestProd2.Versions_Available__c = 'sdfsdf';
        objTestProd2.OfferingType__c = 'PureEngage On Premise';
        objTestProd2.zqu__Category__c = 'Add On Services';
        objTestProd2.NG1_PPU_USD__c= 1;
        objTestProd2.Description = 'test 1';
        objTestProd2.APN_Number__c = '1';
        objTestProd2.Quantities_Available__c = 'test;test1';
        objTestProd2.Parent_Product_lookup__c = objTestProd.id;
        list_ProductsToInsert.add(objTestProd2);
        
        Product2 objTestProd4 = new Product2();
        objTestProd4.APN_Number__c = '1';
        objTestProd4.SI_Version_Number__c = '8.0';
        objTestProd4.Description__c = 'test3';
        objTestProd4.Name = 'Test Prod2619';
        objTestProd4.PPU_Product__c = true;
        objTestProd4.Quantity__c = 10;
        objTestProd4.OfferingType__c = 'PureEngage Subscription';
        objTestProd4.NG1_PPU_USD__c= 1;
        list_ProductsToInsert.add(objTestProd4);
        
        Product2 objTestProd3 = new Product2();
        objTestProd3.Pricing_Model__c = 'testing';
        objTestProd3.Description__c = '1';
        objTestProd3.SI_Version_Number__c = '8.0';
        objTestProd3.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd3.Quantity__c = 10;
        objTestProd3.Name = 'Test Prod2'; 
        objTestProd3.PPU_Product__c = true;
        objTestProd3.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd3.End_of_Support__c = String.valueOf(Date.today());
        objTestProd3.IsActive = true;
        objTestProd3.RecordTypeId= RecordTypeIdContact;
        objTestProd3.Dont_Publish_In_Quote__c = false;
        objTestProd3.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd3.Price_Permission__c = 'Public';
        objTestProd3.Restricted_Product__c =false;
        objTestProd3.Versions_Available__c = 'sdfsdf';
        objTestProd3.OfferingType__c = 'PureEngage Subscription';
        objTestProd3.APN_Number__c = '1';
        objTestProd3.NG1_PPU_USD__c= 1;
        objTestProd3.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd3);
        
        Product2 objTestProd1 = new Product2();
        objTestProd1.SI_Version_Number__c = '8.0';
        objTestProd1.Quantity__c = 10;
        objTestProd1.Pricing_Model__c = 'testing';
        objTestProd1.Shipment_Approval__c ='Prerequisites Limited Compatibility or Headed Towards EOL - AE Acknowledgment';
        objTestProd1.Name = 'Test Prod';        
        objTestProd1.PPU_Product__c = true;    
        objTestProd1.Type__c = 'Token';
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd1.RecordTypeId= RecordTypeIdContact;
        objTestProd1.Dont_Publish_In_Quote__c = false;
        objTestProd1.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd1.Price_Permission__c = 'Public';
        objTestProd1.Restricted_Product__c =false;
        objTestProd1.Versions_Available__c = 'sdfsdf';
        objTestProd1.OfferingType__c = 'PureEngage Subscription';
        objTestProd1.zqu__Category__c = 'Add On Services';
        objTestProd1.NG1_PPU_USD__c= 1;
        objTestProd1.Base_Item_Lookup__c = objTestProd4.id;
        objTestProd1.Description = 'test 1';
        objTestProd1.APN_Number__c = '1';
        objTestProd1.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd1);
        
        insert list_ProductsToInsert;
        Test.startTest();  
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Test';
        prdgrp.Play_Offer__c = 'Automation at Work - Predictive Performance';
        prdgrp.Group_Type__c = 'Use Case';
        prdgrp.Active__c = true;
        prdgrp.Play_Offer__c = 'Digital Service - Genesys Service Automation';
        prdgrp.Pricing_Model__c = 'test';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Offering_Type__c = 'PureEngage On Premise';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;
        
        Product_Group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Test';
        prdgrp1.Group_Type__c = 'Bundle';
        prdgrp1.Play_Offer__c = 'Automation at Work - Predictive Performance';
        prdgrp1.Active__c = true;
        prdgrp1.Pricing_Model__c = 'test';
        prdgrp1.Product__c = list_ProductsToInsert[0].id;
        prdgrp1.Offering_Type__c = 'PureEngage On Premise';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;
        
        
        Product_group__c prdgrp21 = new Product_group__c();
        prdgrp21.Name = 'Drive';
        prdgrp21.Group_Type__c = 'Favorite';
        prdgrp21.User__c = UserInfo.getUserId();
        prdgrp21.Pricing_Model__c ='test';
        prdgrp21.Active__c = true;
        prdgrp21.Quantity__c = 10;
        prdgrp21.Play_Offer__c = 'Automation at Work - Predictive Performance';
        prdgrp21.Product__c = list_ProductsToInsert[0].id;
        prdgrp21.Offering_Type__c = 'PureEngage On Premise';
        prdgrp21.Type__c = 'A la Carte ';
        insert prdgrp21;
        
        Product_Group_Item__c prdgrpItm17 = new Product_Group_Item__c();
        prdgrpItm17.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm17.Product_Group__c= prdgrp21.id;
        prdgrpItm17.Quantity__c = 2;
        prdgrpItm17.Product_Type__c = 'Substitutable';
        prdgrpItm17.select__c = true;
        insert prdgrpItm17; 
        
        Product_Group_Item__c prdgrpItm18 = new Product_Group_Item__c();
        prdgrpItm18.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm18.Product_Group__c= prdgrp21.id;
        prdgrpItm18.Quantity__c = 2;
        prdgrpItm18.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm18.select__c = true;
        insert prdgrpItm18;
        
        Product_group__c prdgrp2 = new Product_group__c();
        prdgrp2.Name = 'Drive';
        prdgrp2.Group_Type__c = 'Campaigns';
        prdgrp2.User__c = UserInfo.getUserId();
        prdgrp2.Pricing_Model__c ='Concurrent';
        prdgrp2.Quantity__c = 10;
        prdgrp2.Active__c = true;
        prdgrp2.Play_Offer__c = 'Automation at Work - Predictive Performance';
        prdgrp2.Product__c = list_ProductsToInsert[0].id;
        prdgrp2.Offering_Type__c = 'PureEngage On Premise';
        prdgrp2.Type__c = 'A la Carte ';
        insert prdgrp2;
        
        Product_Group_Item__c prdgrpItm15 = new Product_Group_Item__c();
        prdgrpItm15.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm15.Product_Group__c = prdgrp2.id;
        prdgrpItm15.Product_Type__c = 'Substitutable';
        prdgrpItm15.select__c = true;
        prdgrpItm15.Quantity__c = 2;
        insert prdgrpItm15; 
        
        Product_Group_Item__c prdgrpItm16 = new Product_Group_Item__c();
        prdgrpItm16.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm16.Product_Group__c = prdgrp2.id;
        prdgrpItm16.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm16.select__c = true;
        prdgrpItm16.Quantity__c = 2;
        insert prdgrpItm16;
        
        Product_Group_Item__c prdgrpItm12 = new Product_Group_Item__c();
        prdgrpItm12.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm12.Product_Group__c = prdgrp1.id;
        prdgrpItm12.Product_Type__c = 'Lab';
        prdgrpItm12.Quantity__c = 2;
        insert prdgrpItm12;
        
        Product_Group_Item__c prdgrpItm13 = new Product_Group_Item__c();
        prdgrpItm13.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm13.Product_Group__c = prdgrp1.id;
        prdgrpItm13.Product_Type__c = 'Lab';
        prdgrpItm13.Quantity__c = 2;
        insert prdgrpItm13;
        
        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Mandatory';
        prdgrpItm.Quantity__c = 2;
        insert prdgrpItm;
        
        Product_Group_Item__c prdgrpItm1 = new Product_Group_Item__c();
        prdgrpItm1.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm1.Product_Group__c = prdgrp.id;
        prdgrpItm1.Product_Type__c = 'LAB';
        prdgrpItm1.Quantity__c = 2;
        insert prdgrpItm1;
        
        Product_Group_Item__c prdgrpItm2 = new Product_Group_Item__c();
        prdgrpItm2.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm2.Product_Group__c = prdgrp.id;
        prdgrpItm2.Product_Type__c = 'Optional';
        prdgrpItm2.Quantity__c = 2;
        insert prdgrpItm2;
        
        Product_Group_Item__c prdgrpItm3 = new Product_Group_Item__c();
        prdgrpItm3.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm3.Product_Group__c = prdgrp.id;
        prdgrpItm3.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm3.Minimum_Substitutable_Count__c = 2;
        prdgrpItm3.Quantity__c = 2;
        insert prdgrpItm3;
        
        Product_Group_Item__c prdgrpItm8 = new Product_Group_Item__c();
        prdgrpItm8.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm8.Product_Group__c = prdgrp.id;
        prdgrpItm8.Product_Type__c = 'Substitutable';
        prdgrpItm8.select__c = true;
        prdgrpItm8.Quantity__c = 2;
        prdgrpItm8.Substitutable_Product_Group_Item__c = prdgrpItm3.id;
        insert prdgrpItm8;
        
        Product_Group_Item__c prdgrpItm11 = new Product_Group_Item__c();
        prdgrpItm11.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm11.Product_Group__c = prdgrp.id;
        prdgrpItm11.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm11.select__c = true;
        prdgrpItm11.Quantity__c = 2;
        insert prdgrpItm11;
        
        Product_Group_Item__c prdgrpItm9 = new Product_Group_Item__c();
        prdgrpItm9.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm9.Product_Group__c = prdgrp.id;
        prdgrpItm9.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm9.select__c = true;
        prdgrpItm9.Quantity__c = 2;
        insert prdgrpItm9;
        
        Product_Group_Item__c prdgrpItm10 = new Product_Group_Item__c();
        prdgrpItm10.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm10.Product_Group__c = prdgrp.id;
        prdgrpItm10.Product_Type__c = 'Substitutable';
        prdgrpItm10.select__c = true;
        prdgrpItm10.Quantity__c = 2;
        prdgrpItm10.Substitutable_Product_Group_Item__c = prdgrpItm9.id;
        insert prdgrpItm10;
        
        Product_Group_Item__c prdgrpItm14 = new Product_Group_Item__c();
        prdgrpItm14.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm14.Product_Group__c = prdgrp.id;
        prdgrpItm14.Product_Type__c = 'Substitutable';
        prdgrpItm14.select__c = true;
        prdgrpItm14.Quantity__c = 2;
        prdgrpItm14.Substitutable_Product_Group_Item__c = prdgrpItm9.id;
        insert prdgrpItm14; 
        
        Product_Group_Item__c prdgrpItm4 = new Product_Group_Item__c();
        prdgrpItm4.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm4.Product_Group__c = prdgrp.id;
        prdgrpItm4.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm4.select__c = true;
        prdgrpItm4.Quantity__c = 2;
        insert prdgrpItm4;
        
        Product_Group_Item__c prdgrpItm6 = new Product_Group_Item__c();
        prdgrpItm6.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm6.Product_Group__c = prdgrp.id;
        prdgrpItm6.Product_Type__c = 'Substitutable';
        prdgrpItm6.select__c = true;
        prdgrpItm6.Quantity__c = 2;
        prdgrpItm6.Substitutable_Product_Group_Item__c = prdgrpItm4.id;
        insert prdgrpItm6;
        
        Product_Group_Item__c prdgrpItm5 = new Product_Group_Item__c();
        prdgrpItm5.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm5.Product_Group__c = prdgrp.id;
        prdgrpItm5.Product_Type__c = 'HA';
        prdgrpItm5.Quantity__c = 2;
        insert prdgrpItm5;
        
        Product2 objTestProd5 = new Product2();
        objTestProd5.SI_Version_Number__c = '8.0';
        objTestProd5.Pricing_Model__c = 'test';
        objTestProd5.Quantity__c = 10;
        objTestProd5.APN_Number__c = '1';
        objTestProd5.EMEA_Volume_Discount_Eligible__c =true;
        objTestProd5.Name = 'Test Pro1619';
        objTestProd5.OfferingType__c = 'PureEngage Subscription';
        objTestProd5.NG5_NA_USD_Price__c = 1;
        objTestProd5.Base_Item_Lookup__c = objTestProd.id;
        insert objTestProd5;
        
        Product2 objTestProd6 = new Product2();
        objTestProd6.Pricing_Model__c = 'test';
        objTestProd6.SI_Version_Number__c = '8.0';
        objTestProd6.Quantity__c = 10;
        objTestProd6.Name = 'Test Pro1619';
        objTestProd6.EMEA_Volume_Discount_Eligible__c =true;
        objTestProd6.OfferingType__c = 'PureEngage Subscription';
        objTestProd6.NG5_NA_USD_Price__c = 1;
        objTestProd6.Base_Item_Lookup__c = objTestProd3.id;
        insert objTestProd6;
        
        /*BigMachines__Quote_Product__c qp = new BigMachines__Quote_Product__c();       
        qp.BigMachines__Quote__c = list_NewQuotes[0].Id;
        qp.BigMachines__Quantity__c = 10; 
        qp.Bundle__c = prdgrp.id;
        qp.Ext_List__c = 100000;
        qp.BigMachines__Sales_Price__c = 500; 
        qp.List_Price__c = 2;
        qp.Disc__c = 0;
        qp.Quantity__c = 2;
        insert qp;*/
        
        Business_Rules__c businessRulesObj = new Business_Rules__c();
        businessRulesObj.Name = 'Default Substitutable Count';
        businessRulesObj.Value__c = 4;
        businessRulesObj.IsActive__c = true;
        businessRulesObj.Process__c = 'Dynamic Bundle';
        insert businessRulesObj;
        
        Category_Building_Block_Mapping__c categoryBuildinBlock = new Category_Building_Block_Mapping__c();
        categoryBuildinBlock.Name = '001';
        categoryBuildinBlock.Building_Blocks__c  = 'Genesys Software';
        categoryBuildinBlock.Category__c ='Branch Office';
        insert categoryBuildinBlock;
        
        Category_Building_Block_Mapping__c categoryBuildinBlock1 = new Category_Building_Block_Mapping__c();
        categoryBuildinBlock1.Name = '002';
        categoryBuildinBlock1.Building_Blocks__c  = 'Genesys Software';
        categoryBuildinBlock1.Category__c ='Genesys Universities';
        insert categoryBuildinBlock1;
        
        Taxonomy_Sol_Category_And_Taxonomy_Sol__c taxo = new Taxonomy_Sol_Category_And_Taxonomy_Sol__c ();
        taxo.name = 'Branch Office';
        taxo.Taxonomy_Solution__c ='Analytics;Integration;Platform;Workload Management';
        insert taxo;
        
        Taxonomy_Sol_Category_And_Taxonomy_Sol__c taxo1 = new Taxonomy_Sol_Category_And_Taxonomy_Sol__c ();
        taxo1.name = 'All';
        taxo1.Taxonomy_Solution__c ='Digital;Inbound;Outbound;Self Service';
        insert taxo1;
        
        Taxonomy_Sol_and_Product_Financial__c taxoFinancial = new Taxonomy_Sol_and_Product_Financial__c();
        taxoFinancial.name = 'Analytics';
        taxoFinancial.Product_Financial__c = 'Advisor;CX Insights;Info Mart;Interactive Insights;Predictive Routing;PS Rapid Deployment Packages;';
        insert taxoFinancial;
        
        Business_Rules__c business = new Business_Rules__c();
        business.Name = 'Default Substitutable Count';
        business.Process__c = 'Dynamic Bundle';
        business.IsActive__c = true;
        insert business;
        
        PSRDP_Pricing__c psrdp = new PSRDP_Pricing__c();
        psrdp.Name = 'Australia##'+list_ProductsToInsert[0].Id;
        psrdp.Region__c = 'Australia';
        psrdp.Price__c = 100;
        psrdp.Product_Info__c = list_ProductsToInsert[0].Id;
        insert psrdp;
        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);   
        ConfigurationControllerPPU configObj = new ConfigurationControllerPPU();
        configObj.strGroupId = prdgrp1.id;
        configObj.strFavId = prdgrp21.id;
        configObj.strSelectedTaxonomyCategorySolution = 'All';
        configObj.addProductsBtnHandler();
        configObj.bundleOptionHandler();
        configObj.favouritesOptionHandler();
        configObj.list_Favourites[0].blnIsSelected = true;
        configObj.showHideFavoriteItems();
        configObj.deleteFavorite();
        configObj.addFavoritesBtnHandler();
        set<string> abc = new set<string>{'1','2'};
        configObj.createPSRDPRecommendationsQueryString(abc);
        configObj.addRecommendationProducts(abc);
    }
    
}