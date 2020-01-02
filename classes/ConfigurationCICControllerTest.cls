@isTest
public class ConfigurationCICControllerTest{

    static testmethod void unitTest(){
         //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        
        
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
        
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        list_NewOpps[0].Sold_To_Country__c = testCountries[0].id;
        update list_NewOpps;
        System.assertEquals(list_NewOpps.size(), 1);
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        list_NewQuotes[0].Multi_Year_Quote__c = true;
        list_NewQuotes[0].Pricing_Model__c = 'testing';
        list_NewQuotes[0].Sold_To_Name__c = list_NewAccts[0].Id;
        list_NewQuotes[0].Quote_Opportunity_Type__c = 'New Pricing';
        list_NewQuotes[0].Offering_Type__c = 'PureEngage Subscription';
        list_NewQuotes[0].Pricing_Model__c = 'test';
        update list_NewQuotes;
        System.assertEquals(list_NewQuotes.size(), 1);
        
        List<CurrencyType> curr = new list<CurrencyType>();
        for(CurrencyType c: [SELECT IsoCode,ConversionRate FROM CurrencyType]){
          curr.add(c);
        }         
        
        Id RecordTypeIdContact = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();

        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd = new Product2();
        objTestProd.APN_Number__c = 'Tokens1';
        objTestProd.Pricing_Model__c = 'test';
        objTestProd.Description__c = 'test1';
        objTestProd.Product_Name__c = 'test';
        objTestProd.SI_Version_Number__c = '8.0';
        objTestProd.Shipment_Approval__c ='Required for New Orders Only';
        objTestProd.Quantity__c = 10;
        objTestProd.Name = 'Test Prod3'; 
        objTestProd.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.RecordTypeId= RecordTypeIdContact;
        objTestProd.Dont_Publish_In_Quote__c = false;
        objTestProd.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd.Price_Permission__c = 'Public';
        objTestProd.Restricted_Product__c =false;
        objTestProd.Versions_Available__c = 'sdfsdf';
        objTestProd.OfferingType__c = 'PureEngage Subscription';
        objTestProd.NG5_NA_USD_Price__c = 1;
        objTestProd.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd);
        
        Product2 objTestProd4 = new Product2();
        objTestProd4.APN_Number__c = 'Tokens1';
        objTestProd4.SI_Version_Number__c = '8.0';
        objTestProd4.Description__c = 'test3';
        objTestProd4.Name = 'Test Prod2619';
        objTestProd4.Quantity__c = 10;
        objTestProd4.OfferingType__c = 'PureEngage Subscription';
        objTestProd4.NG5_NA_USD_Price__c = 1;
        list_ProductsToInsert.add(objTestProd4);
        
        Product2 objTestProd3 = new Product2();
        objTestProd3.Pricing_Model__c = 'test';
        objTestProd3.Product_Name__c = 'test1';
        objTestProd3.Description__c = '1';
        objTestProd3.SI_Version_Number__c = '8.0';
        objTestProd3.Shipment_Approval__c ='Required for New Orders Only';
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
        objTestProd3.NG5_NA_USD_Price__c = 1;
        objTestProd3.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd3);
        
        Product2 objTestProd1 = new Product2();
        objTestProd1.SI_Version_Number__c = '8.0';
        objTestProd1.Product_Name__c = 'test2';
        objTestProd1.Quantity__c = 10;
        objTestProd1.Pricing_Model__c = 'test';
        objTestProd1.Shipment_Approval__c ='Required for New Orders Only';
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
        objTestProd1.NG5_NA_USD_Price__c = 1;
        objTestProd1.Base_Item_Lookup__c = objTestProd4.id;
        objTestProd1.Description = 'test 1';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd1);
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.SI_Version_Number__c = '8.0';
        objTestProd2.Product_Name__c = 'test3';
        objTestProd2.Quantity__c = 10;
        objTestProd2.Pricing_Model__c = 'test';
        objTestProd2.Name = 'Test Prod1';            
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
        objTestProd2.OfferingType__c = 'PureEngage Subscription';
        objTestProd2.zqu__Category__c = 'Add On Services';
        objTestProd2.NG5_NA_USD_Price__c = 1;
        objTestProd2.Description = 'test 1';
        objTestProd2.APN_Number__c = 'Tokens1';
        objTestProd2.Quantities_Available__c = 'test;test1';
        objTestProd2.Parent_Product_lookup__c = objTestProd1.id;
        list_ProductsToInsert.add(objTestProd2);
        insert list_ProductsToInsert;
        Test.startTest();  
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Test';
        prdgrp.Group_Type__c = 'Campaigns';
        prdgrp.Active__c = true;
        prdgrp.Pricing_Model__c = 'test';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Offering_Type__c = 'PureEngage Subscription';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;

        Product_Group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Test';
        prdgrp1.Group_Type__c = 'Favorite';
        prdgrp1.Active__c = true;
        prdgrp1.Pricing_Model__c = 'test';
        prdgrp1.Product__c = list_ProductsToInsert[0].id;
        prdgrp1.Offering_Type__c = 'PureEngage Subscription';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        prdgrp1.User__c = UserInfo.getUserId();
        insert prdgrp1;
        
        Product_Group_Item__c prdgrpItm121 = new Product_Group_Item__c();
        prdgrpItm121.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm121.Product_Type__c = 'Lab';
        prdgrpItm121.Product_Group__c= prdgrp1.id;
        prdgrpItm121.Bundle__c = prdgrp1.id;
        prdgrpItm121.Quantity__c = 1;
        insert prdgrpItm121;
        Product_Group_Item__c prdgrpItm122 = new Product_Group_Item__c();
        prdgrpItm122.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm122.Product_Type__c = 'Lab';
        prdgrpItm122.Product_Group__c= prdgrp1.id;
        prdgrpItm122.Quantity__c = 1;
        insert prdgrpItm122;
        
        Product_group__c prdgrp21 = new Product_group__c();
        prdgrp21.Name = 'Drive';
        prdgrp21.Group_Type__c = 'A la Carte Partner';
        prdgrp21.User__c = UserInfo.getUserId();
        prdgrp21.Pricing_Model__c ='test';
        prdgrp21.Active__c = true;
        prdgrp21.Product__c = list_ProductsToInsert[0].id;
        prdgrp21.Offering_Type__c = 'PureEngage Subscription';
        prdgrp21.Type__c = 'A la Carte ';
        insert prdgrp21;
        
        Product_Group_Item__c prdgrpItm12 = new Product_Group_Item__c();
        prdgrpItm12.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm12.Product_Group__c = prdgrp21.id;
        prdgrpItm12.Product_Type__c = 'Lab';
        prdgrpItm12.Bundle__c = prdgrp21.id;
        prdgrpItm12.Quantity__c = 1;
        insert prdgrpItm12;
        
        
        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Mandatory';
        prdgrpItm.Quantity__c = 1;
        insert prdgrpItm;
        
        Product_Group_Item__c prdgrpItm1 = new Product_Group_Item__c();
        prdgrpItm1.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm1.Product_Group__c = prdgrp.id;
        prdgrpItm1.Product_Type__c = 'LAB';
        prdgrpItm1.Quantity__c = 1;
        insert prdgrpItm1;
        
        Product_Group_Item__c prdgrpItm2 = new Product_Group_Item__c();
        prdgrpItm2.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm2.Product_Group__c = prdgrp.id;
        prdgrpItm2.Product_Type__c = 'Optional';
        prdgrpItm2.Quantity__c = 1;
        insert prdgrpItm2;
        
        Product_Group_Item__c prdgrpItm3 = new Product_Group_Item__c();
        prdgrpItm3.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm3.Product_Group__c = prdgrp.id;
        prdgrpItm3.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm3.Minimum_Substitutable_Count__c = 2;
        prdgrpItm3.Quantity__c = 1;
        insert prdgrpItm3;
        
        Product_Group_Item__c prdgrpItm8 = new Product_Group_Item__c();
        prdgrpItm8.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm8.Product_Group__c = prdgrp.id;
        prdgrpItm8.Product_Type__c = 'Substitutable';
        prdgrpItm8.select__c = true;
        prdgrpItm8.Substitutable_Product_Group_Item__c = prdgrpItm3.id;
        prdgrpItm8.Quantity__c = 1;
        insert prdgrpItm8;
        
        Product_Group_Item__c prdgrpItm11 = new Product_Group_Item__c();
        prdgrpItm11.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm11.Product_Group__c = prdgrp.id;
        prdgrpItm11.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm11.select__c = true;
        prdgrpItm11.Quantity__c = 1;
        insert prdgrpItm11;
        
        Product_Group_Item__c prdgrpItm9 = new Product_Group_Item__c();
        prdgrpItm9.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm9.Product_Group__c = prdgrp.id;
        prdgrpItm9.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm9.select__c = true;
        prdgrpItm9.Quantity__c = 1;
        insert prdgrpItm9;
        
        Product_Group_Item__c prdgrpItm10 = new Product_Group_Item__c();
        prdgrpItm10.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm10.Product_Group__c = prdgrp.id;
        prdgrpItm10.Product_Type__c = 'Substitutable';
        prdgrpItm10.select__c = true;
        prdgrpItm10.Substitutable_Product_Group_Item__c = prdgrpItm9.id;
        prdgrpItm10.Quantity__c = 1;
        insert prdgrpItm10;
        
        Product_Group_Item__c prdgrpItm13 = new Product_Group_Item__c();
        prdgrpItm13.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm13.Product_Group__c = prdgrp.id;
        prdgrpItm13.Product_Type__c = 'Substitutable';
        prdgrpItm13.select__c = true;
        prdgrpItm13.Substitutable_Product_Group_Item__c = prdgrpItm9.id;
        prdgrpItm13.Quantity__c = 1;
        insert prdgrpItm13; 
        
        Product_Group_Item__c prdgrpItm4 = new Product_Group_Item__c();
        prdgrpItm4.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm4.Product_Group__c = prdgrp.id;
        prdgrpItm4.Product_Type__c = 'Mandatory Substitutable';
        prdgrpItm4.select__c = true;
        prdgrpItm4.Quantity__c = 1;
        insert prdgrpItm4;
        
        Product_Group_Item__c prdgrpItm6 = new Product_Group_Item__c();
        prdgrpItm6.Product__c = list_ProductsToInsert[1].Id;
        prdgrpItm6.Product_Group__c = prdgrp.id;
        prdgrpItm6.Product_Type__c = 'Substitutable';
        prdgrpItm6.select__c = true;
        prdgrpItm6.Substitutable_Product_Group_Item__c = prdgrpItm4.id;
        prdgrpItm6.Quantity__c = 1;
        insert prdgrpItm6;
        
        Product_Group_Item__c prdgrpItm5 = new Product_Group_Item__c();
        prdgrpItm5.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm5.Product_Group__c = prdgrp.id;
        prdgrpItm5.Product_Type__c = 'HA';
        prdgrpItm5.Quantity__c = 1;
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
        objTestProd6.Name = 'test';
        objTestProd6.SI_Version_Number__c = '8.0';
        objTestProd6.Quantity__c = 10;
        objTestProd6.Name = 'Test Pro1619';
        objTestProd6.EMEA_Volume_Discount_Eligible__c =true;
        objTestProd6.OfferingType__c = 'PureEngage Subscription';
        objTestProd6.NG5_NA_USD_Price__c = 1;
        objTestProd6.Base_Item_Lookup__c = objTestProd3.id;
        objTestProd6.Pass_Through__c = true;
        insert objTestProd6;
        
        Business_Rules__c businessRulesObj = new Business_Rules__c();
        businessRulesObj.Name = 'Default Substitutable Count';
        businessRulesObj.Value__c = 4;
        businessRulesObj.IsActive__c = true;
        businessRulesObj.Process__c = 'Dynamic Bundle';
        insert businessRulesObj;
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting.Name = 'Documentation';
        onPremiseSetting.Sub_Category__c = 'Documentation';
        insert onPremiseSetting;
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting1 = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting1.Name = 'All';
        onPremiseSetting1.Sub_Category__c = 'Documentation';
        insert onPremiseSetting1;
        
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
        taxo.name = 'All';
        taxo.Taxonomy_Solution__c ='Analytics;Integration;Platform;Workload Management';
        insert taxo;
        
        Taxonomy_Sol_Category_And_Taxonomy_Sol__c taxo1 = new Taxonomy_Sol_Category_And_Taxonomy_Sol__c ();
        taxo1.name = 'Customer Engagement';
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
        
        //Unit tests for ConfigurationCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id); 
        System.currentPageReference().getParameters().put('tab', 'search'); 
        ConfigurationCICController configObj = new ConfigurationCICController();
        configObj.favouritesOptionHandler();
        configObj.showHideFavoriteItems();
        if(configObj.list_Favourites.size() > 0){
            configObj.list_Favourites.get(0).blnIsSelected = true;
            configObj.addFavoritesBtnHandler();
            configObj.markFavBtnHandler();
            configObj.saveFavourite();
        }
        configObj.strGroupId = prdgrp.id;
        configObj.Option2();
        configObj.addProductsBtnHandler();
        configObj.CampaignsOptionHandler();
        configObj.refresh();
        configObj.showProductInfo();
        configObj.showProductInfoFromBaseItem();
        configObj.hideProductInfo();
        configObj.showHideCampaignsProducts();
        configObj.deleteFavorite();
        configObj.addProductsFromSearch();
        configObj.strProdIndex = '1';
        configObj.removeProduct();
        configObj.removeProductBundle();
        configObj.removeAllBtnHandler();
        configObj.cancelMarkFavourite();
        configObj.checkForRequiredConfirmations();
        configObj.confBoxProceed();
        configObj.saveBtnHandler();
        configObj.saveLogic();
        configObj.next();
        configObj.previous();
        configObj.getHasPrevious();
        configObj.getHasNext();
        configObj.first();
        //configObj.last();
        configObj.getPageNumStr();
        configObj.addCampaignssBtnHandler();
        //configObj.changeCategory();
       // configObj.showTaxonomySolutions();
        ConfigurationCICController.ConfirmationWrapper temp = new ConfigurationCICController.ConfirmationWrapper();
        configObj.blnIsNewPricing = false;
        objTestProd2.Version_Available_For_old__c ='tes';
        configObj.handleVersionsAvailable(objTestProd2);
        configObj.favouritesOptionHandler();
        configObj.refresh();
        configObj.useCaseOptionHandler();
        configObj.addBundlesBtnHandler();
        Admin_Dummy__c admdum = new Admin_Dummy__c();
        admdum.Name = 'test';
        admdum.Quantity__c = 10;
        ConfigurationCICController.ProductWrapper ProductWrapper = new ConfigurationCICController.ProductWrapper(objTestProd6, admdum);
        list<ConfigurationCICController.ProductWrapper> ProductWrapperlist = new list<ConfigurationCICController.ProductWrapper>();
        ProductWrapperlist.add(ProductWrapper);
        configObj.map_BuildingBlockToProducts.put('test', ProductWrapperlist);
        configObj.addProductsBtnHandler();
        List<Product2> list_ProductsToAdd = new List<Product2>();
        Set<String> set_Versions = new Set<String>();
        configObj.createAddedProductsQueryString(list_ProductsToAdd, set_Versions);
        
        configObj.objFavToBeSaved.Name = 'test';
        configObj.list_BundlesToBeSaved.add(prdgrp21);
        configObj.saveFavourite();
        configObj.selectedLeafOffer ='test';
        configObj.selectedPlayOffer ='test';
        configObj.ChkMapKey ='test';
        configObj.strSortFieldSelected ='test';
        configObj.strProductType ='test';
        configObj.strSelectedBuildingBlock ='test';
        configObj.show_emea_training_error = true;
        Test.stopTest();    
    }

    static testmethod void unitTest1(){
         //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        List<Country__c>  testCountries = new List<Country__c>();
         testCountries.add(new Country__c(
          Name = 'United States', PSRDP_Region__c='Australia', Region__c = 'North America', DAP_Region__c = 'NA', ISO_Code__c = 'USD',  Country__c = 'USA',
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
         
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        list_NewOpps[0].Sold_To_Country__c = testCountries[0].id;
        update list_NewOpps;
        System.assertEquals(list_NewOpps.size(), 1);
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        list_NewQuotes[0].Multi_Year_Quote__c = false;
        list_NewQuotes[0].Quote_Opportunity_Type__c = 'Old Pricing';
        list_NewQuotes[0].Offering_Type__c = 'PureEngage Subscription';
        list_NewQuotes[0].Pricing_Model__c ='Concurrent';
        update list_NewQuotes;
        System.assertEquals(list_NewQuotes.size(), 1);
        
        List<CurrencyType> curr = new list<CurrencyType>();
        for(CurrencyType c: [SELECT IsoCode,ConversionRate FROM CurrencyType]){
          curr.add(c);
        }         
        
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.SI_Version_Number__c = '8.0';
        objTestProd1.Dont_Publish_In_Quote__c = false;
        objTestProd1.NG5_NA_USD_Price__c = 1;
        objTestProd1.Restricted_Product__c =False;
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.Pricing_Model__c = 'Concurrent';
        list_ProductsToInsert.add(objTestProd1);
        Test.startTest();        
        insert list_ProductsToInsert;
        
        Product2 objTestProd4 = new Product2();
        objTestProd4.Pricing_Model__c = 'test';
        objTestProd4.SI_Version_Number__c = '8.0';
        objTestProd4.Quantity__c = 10;
        objTestProd4.Name = 'Test Prod2'; 
        objTestProd4.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd4.End_of_Support__c = String.valueOf(Date.today());
        objTestProd4.IsActive = true;
        objTestProd4.Dont_Publish_In_Quote__c = false;
        objTestProd4.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd4.Price_Permission__c = 'Public';
        objTestProd4.Restricted_Product__c =false;
        objTestProd4.Versions_Available__c = 'sdfsdf';
        objTestProd4.OfferingType__c = 'PureEngage Subscription';
        objTestProd4.NG5_NA_USD_Price__c = 1;
        objTestProd4.Base_Item_Lookup__c = objTestProd1.id;
        objTestProd4.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd4);
        
        Product_Group__c prdgrp = new Product_group__c();
        objTestProd1.Name = 'Test Prod1';
        prdgrp.Group_Type__c = 'Campaigns';
        prdgrp.Active__c = true;
        prdgrp.Pricing_Model__c = 'test';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Offering_Type__c = 'PureEngage Subscription';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;
        
        Product_Group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Test';
        prdgrp1.Group_Type__c = 'Campaigns';
        prdgrp1.Pricing_Model__c ='test';
        prdgrp1.Active__c = true;
        prdgrp1.Product__c = list_ProductsToInsert[0].id;
        prdgrp1.Offering_Type__c = 'PureEngage Subscription';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;

        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Lab';
        insert prdgrpItm;
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting.Name = 'Documentation';
        onPremiseSetting.Sub_Category__c = 'Documentation';
        insert onPremiseSetting;
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting1 = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting1.Name = 'All';
        onPremiseSetting1.Sub_Category__c = 'Documentation';
        insert onPremiseSetting1;
        
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
        
        Taxonomy_Sol_Category_And_Taxonomy_Sol__c taxo1 = new Taxonomy_Sol_Category_And_Taxonomy_Sol__c ();
        taxo1.name = 'Customer Engagement';
        taxo1.Taxonomy_Solution__c ='Digital;Inbound;Outbound;Self Service';
        insert taxo1;
        
        Taxonomy_Sol_and_Product_Financial__c taxoFinancial = new Taxonomy_Sol_and_Product_Financial__c();
        taxoFinancial.name = 'Analytics';
        taxoFinancial.Product_Financial__c = 'Advisor;CX Insights;Info Mart;Interactive Insights;Predictive Routing;';
        insert taxoFinancial;
        
        PSRDP_Pricing__c psrdp = new PSRDP_Pricing__c();
        psrdp.Name = 'Australia##'+list_ProductsToInsert[0].Id;
        psrdp.Region__c = 'Australia';
        psrdp.Product_Info__c = list_ProductsToInsert[0].Id;
        insert psrdp;
        //Unit tests for ConfigurationCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id); 
        System.currentPageReference().getParameters().put('tab', 'search'); 
        ConfigurationCICController configObj = new ConfigurationCICController();
        configObj.strProductFinancial = 'All';
        configObj.Option2();
        configObj.addProductsBtnHandler();
        configObj.CampaignsOptionHandler();
        configObj.addCampaignssBtnHandler();
        //configObj.refresh();
        configObj.showProductInfo();
        configObj.showProductInfoFromBaseItem();
        configObj.hideProductInfo();
        configObj.showHideProducts();
        configObj.showHideCampaignsProducts();
        configObj.showHideFavoriteItems();
        configObj.deleteFavorite();
        //configObj.addBundlesBtnHandler();
        configObj.addProductsFromSearch();
        configObj.strProdIndex = '1';
        configObj.removeProduct();
        configObj.removeProductBundle();
        configObj.removeAllBtnHandler();
        configObj.markFavBtnHandler();
        configObj.cancelMarkFavourite();
        configObj.checkForRequiredConfirmations();
        configObj.confBoxCancel();
        configObj.confBoxProceed();
        configObj.saveBtnHandler();
        configObj.saveLogic();
        configObj.next();
        configObj.previous();
        configObj.getHasPrevious();
        configObj.getHasNext();
        configObj.first();
        configObj.getPageNumStr();
        //configObj.addCampaignssBtnHandler();
        Test.stopTest();
    }
    
    static testmethod void unitTest2(){
         //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
       
        
         List<Country__c>  testCountries = new List<Country__c>();
         testCountries.add(new Country__c(
          Name = 'United States', Region__c = 'North America', PSRDP_Region__c='Australia', DAP_Region__c = 'NA', ISO_Code__c = 'USD',  Country__c = 'USA',
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
        System.assertEquals(list_NewAccts.size(), 1);
        update list_NewAccts;
        
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        list_NewOpps[0].Sold_To_Country__c = testCountries[0].id;
        update list_NewOpps;
        System.assertEquals(list_NewOpps.size(), 1);
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        list_NewQuotes[0].Multi_Year_Quote__c = false;
        list_NewQuotes[0].Quote_Opportunity_Type__c = 'Old Pricing';
        list_NewQuotes[0].Sold_To_Name__c = list_NewAccts[0].id;
        list_NewQuotes[0].Offering_Type__c = 'PureConnect On Premise';
        list_NewQuotes[0].Pricing_Model__c = 'Named User Pricing';
        update list_NewQuotes;
        System.assertEquals(list_NewQuotes.size(), 1);
        
        List<CurrencyType> curr = new list<CurrencyType>();
        for(CurrencyType c: [SELECT IsoCode,ConversionRate FROM CurrencyType]){
          curr.add(c);
        }         
        
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.Pricing_Model__c = 'Named User Pricing';
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.Shipment_Approval__c = 'Notification Only';
        objTestProd1.Dont_Publish_In_Quote__c = false;
        objTestProd1.Restricted_Product__c = false;
        objTestProd1.IsActive = true;
        objTestProd1.Third_Party__c ='TRUE';
        objTestProd1.Price_Effective_Date__c = Date.Today().addDays(-2);
        objTestProd1.Last_Order_Date__c = Date.Today().addDays(2);
        objTestProd1.EOM_Date__c = Date.Today().addDays(4);
        objTestProd1.End_of_Support__c =  String.Valueof(Date.Today().addDays(4));
        objTestProd1.OfferingType__c = 'PureConnect On Premise';
        objTestProd1.APN_Number__c = 'Tokens1';
        list_ProductsToInsert.add(objTestProd1);
        Test.startTest();        
        insert list_ProductsToInsert;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Equip';
        prdgrp.Selected__c = true;
        prdgrp.Group_Type__c = 'Use Case';
        prdgrp.Active__c = true;
        prdgrp.Pricing_Model__c = 'test';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Offering_Type__c = ' PureConnect On Premise';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;
        
        Product_Group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Test';
        prdgrp1.Selected__c = true;
        prdgrp1.Group_Type__c = 'A la Carte';
        prdgrp1.Active__c = true;
        prdgrp1.Pricing_Model__c = 'testing';
        prdgrp1.Product__c = list_ProductsToInsert[0].id;
        prdgrp1.Offering_Type__c = 'PureConnect On Premise';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;
        
        Product_Group__c prdgrp2 = new Product_group__c();
        prdgrp2.Name = 'Guide';
        prdgrp2.Selected__c = true;
        prdgrp2.Group_Type__c = 'Use Case';
        prdgrp2.Active__c = true;
        prdgrp2.Pricing_Model__c = 'test';
        prdgrp2.Product__c = list_ProductsToInsert[0].id;
        prdgrp2.Offering_Type__c = ' PureConnect On Premise';
        prdgrp2.Order__c = 12;
        prdgrp2.Quantity__c = 10;
        prdgrp2.Type__c = 'A la Carte';
        insert prdgrp2;
        
        Product_Group__c prdgrp3 = new Product_group__c();
        prdgrp3.Name = 'Drive';
        prdgrp3.Selected__c = true;
        prdgrp3.Group_Type__c = 'PureSuccess';
        prdgrp3.Pricing_Model__c ='test1';
        prdgrp3.Active__c = true;
        prdgrp3.Product__c = list_ProductsToInsert[0].id;
        prdgrp3.Offering_Type__c = 'PureConnect On Premise';
        prdgrp3.Order__c = 10;
        prdgrp3.Quantity__c = 10;
        prdgrp3.Type__c = 'A la Carte';
        insert prdgrp3;
        
        Product_Group__c prdgrp4 = new Product_group__c();
        prdgrp4.Name = 'Partner PureSuccess';
        prdgrp4.Selected__c = true;
        prdgrp4.Group_Type__c = 'Favorite';
        prdgrp4.Pricing_Model__c ='test1';
        prdgrp4.Active__c = true;
        prdgrp4.Product__c = list_ProductsToInsert[0].id;
        prdgrp4.Offering_Type__c = 'PureConnect On Premise';
        prdgrp4.Order__c = 10;
        prdgrp4.Quantity__c = 10;
        prdgrp4.Type__c = 'A la Carte';
        insert prdgrp4;
        
        /*List<BigMachines__Quote_Product__c> bmQuoteProduct = new List<BigMachines__Quote_Product__c>();  
        BigMachines__Quote_Product__c qp = new BigMachines__Quote_Product__c();
        qp.Product__c = objTestProd1.Id;            
        qp.BigMachines__Quantity__c = 10;
        qp.Bundle__c = prdgrp.id;
        qp.BigMachines__Sales_Price__c = 500;        
        qp.BigMachines__Quantity__c = 2;        
        qp.Ext_List__c = 10;
        qp.Ext_Net_Price__c = 100;
        qp.CurrencyIsoCode = 'USD';        
        qp.BigMachines__Quote__c = list_NewQuotes[0].Id;
        bmQuoteProduct.add(qp);
        
        BigMachines__Quote_Product__c qp1 = new BigMachines__Quote_Product__c();
        qp1.Product__c = objTestProd1.Id;            
        qp1.BigMachines__Quantity__c = 10;
        qp.Bundle__c = prdgrp1.id;
        qp1.BigMachines__Sales_Price__c = 500;        
        qp1.BigMachines__Quantity__c = 2;        
        qp1.Ext_List__c = 10;
        qp1.Ext_Net_Price__c = 100;
        qp1.CurrencyIsoCode = 'USD';        
        qp1.BigMachines__Quote__c = list_NewQuotes[0].Id;
        
        BigMachines__Quote_Product__c qp2 = new BigMachines__Quote_Product__c();
        qp2.Product__c = objTestProd1.Id;             
        qp2.BigMachines__Quantity__c = 10;
        qp.Bundle__c = prdgrp2.id;
        qp2.BigMachines__Sales_Price__c = 500;        
        qp2.BigMachines__Quantity__c = 2;        
        qp2.Ext_List__c = 10;
        qp2.Ext_Net_Price__c = 100;
        qp2.CurrencyIsoCode = 'USD';        
        qp2.BigMachines__Quote__c = list_NewQuotes[0].Id;
        bmQuoteProduct.add(qp2);
        
        BigMachines__Quote_Product__c qp3 = new BigMachines__Quote_Product__c();
        qp3.Product__c = objTestProd1.Id;             
        qp3.BigMachines__Quantity__c = 10;
        qp.Bundle__c = prdgrp3.id;
        qp3.BigMachines__Sales_Price__c = 500;        
        qp3.BigMachines__Quantity__c = 2;        
        qp3.Ext_List__c = 10;
        qp3.Ext_Net_Price__c = 100;
        qp3.CurrencyIsoCode = 'USD';        
        qp3.BigMachines__Quote__c = list_NewQuotes[0].Id;
        bmQuoteProduct.add(qp3);
         
        insert bmQuoteProduct;*/
        
        Product_group__c prdgrp5 = new Product_group__c();
        prdgrp5.Name = 'Drive';
        prdgrp5.Group_Type__c = 'A la Carte';
        prdgrp5.User__c = UserInfo.getUserId();
        prdgrp5.Pricing_Model__c ='test';
        prdgrp5.Active__c = true;
        prdgrp5.Product__c = list_ProductsToInsert[0].id;
        prdgrp5.Offering_Type__c = 'PureConnect On Premise';
        prdgrp5.Order__c = 12;
        prdgrp5.Quantity__c = 10;
        prdgrp5.Type__c = 'A la Carte';
        insert prdgrp5;
        
        Product_Group_Item__c prdgrpItm1 = new Product_Group_Item__c();
        prdgrpItm1.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm1.Product_Group__c = prdgrp5.id;
        prdgrpItm1.Product_Type__c = 'Lab';
        prdgrpItm1.Bundle__c = prdgrp5.id;
        insert prdgrpItm1;
        
        Product_Group_Item__c prdgrpItm2 = new Product_Group_Item__c();
        prdgrpItm2.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm2.Product_Group__c = prdgrp1.id;
        prdgrpItm2.Product_Type__c = 'Lab';
        insert prdgrpItm2;
        
        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Mandatory Substitutable';
        insert prdgrpItm;
        
        
        Product_Group_Item__c prdgrpItm3 = new Product_Group_Item__c();
        prdgrpItm3.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm3.Product_Group__c = prdgrp.id;
        prdgrpItm3.Product_Type__c = 'Substitutable';
        prdgrpItm3.select__c = true;
        insert prdgrpItm3;
               
        
        Product_Group_Item__c prdgrpItm4 = new Product_Group_Item__c();
        prdgrpItm4.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm4.Product_Group__c = prdgrp.id;
        prdgrpItm4.Product_Type__c = 'Substitutable';
        prdgrpItm4.Substitutable_Product_Group_Item__c = prdgrpItm1.id;
        insert prdgrpItm4;
        
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
        
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting.Name = 'Documentation';
        onPremiseSetting.Sub_Category__c = 'Documentation';
        insert onPremiseSetting;
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting1 = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting1.Name = 'All';
        onPremiseSetting1.Sub_Category__c = 'Documentation';
        insert onPremiseSetting1;
        
        OnPremiseCIC_Category_and_Building_Block__c onpremiseCat = new OnPremiseCIC_Category_and_Building_Block__c();
        onpremiseCat.Name = 'Documentation';
        onpremiseCat.Building_Block__c = 'DR - Nuance Grammars;DR - Nuance Recognizer 10;DR - Nuance Recognizer 9';
        insert onpremiseCat;
        
        //Unit tests for ConfigurationCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id); 
        System.currentPageReference().getParameters().put('tab', 'search'); 
        ConfigurationCICController configObj = new ConfigurationCICController();
        configObj.Option2();
        configObj.strSelectedTaxonomyCategorySolution = 'All';
        configObj.changeCategory();
        if(configObj.list_Favourites.size() > 0){
            configObj.list_Favourites.get(0).blnIsSelected = true;
            configObj.addFavoritesBtnHandler();
        }
        configObj.useCaseOptionHandler();
        configObj.addBundlesBtnHandler();
        configObj.markFavBtnHandler();
        configObj.saveFavourite();
        configObj.addFavoritesBtnHandler();
        configObj.markFavBtnHandler();
        configObj.objFavToBeSaved.Name = 'Test';
        configObj.saveFavourite();
        configObj.saveLogic();
        configObj.strGroupId = prdgrp.id;
        configObj.showHideProducts();
    } 
    
    static testmethod void unitTest3(){
         //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        
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
        insert testCountries;
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        list_NewOpps[0].Sold_To_Country__c = testCountries[0].id;
        update list_NewOpps;
        System.assertEquals(list_NewOpps.size(), 1);
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        list_NewQuotes[0].Multi_Year_Quote__c = false;
        list_NewQuotes[0].Quote_Opportunity_Type__c = 'Old Pricing';
        list_NewQuotes[0].Offering_Type__c = 'PureConnect On Premise';
        update list_NewQuotes;
        System.assertEquals(list_NewQuotes.size(), 1);
        
        List<CurrencyType> curr = new list<CurrencyType>();
        for(CurrencyType c: [SELECT IsoCode,ConversionRate FROM CurrencyType]){
          curr.add(c);
        }         
        
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Shipment_Approval__c ='Required for New Orders Only';
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.NG5_NA_USD_Price__c =1;
        objTestProd1.APN_Number__c = 'Tokens1';
        list_ProductsToInsert.add(objTestProd1);
        Test.startTest();        
        insert list_ProductsToInsert;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Partner PureSuccess';
        prdgrp.Group_Type__c = 'PureSuccess';
        prdgrp.Active__c = true;
        prdgrp.Pricing_Model__c = 'test';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Offering_Type__c = ' PureConnect On Premise';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;
        
        Product_Group__c prdgrp2 = new Product_group__c();
        prdgrp2.Name = 'Equip';
        prdgrp2.Group_Type__c = 'PureSuccess';
        prdgrp2.Active__c = true;
        prdgrp2.Pricing_Model__c = 'test';
        prdgrp2.Product__c = list_ProductsToInsert[0].id;
        prdgrp2.Offering_Type__c = ' PureConnect On Premise';
        prdgrp2.Order__c = 12;
        prdgrp2.Quantity__c = 10;
        prdgrp2.Type__c = 'A la Carte';
        insert prdgrp2;
        
        Product_Group__c prdgrp3 = new Product_group__c();
        prdgrp3.Name = 'Guide';
        prdgrp3.Group_Type__c = 'PureSuccess';
        prdgrp3.Active__c = true;
        prdgrp3.Pricing_Model__c = 'test';
        prdgrp3.Product__c = list_ProductsToInsert[0].id;
        prdgrp3.Offering_Type__c = ' PureConnect On Premise';
        prdgrp3.Order__c = 12;
        prdgrp3.Quantity__c = 10;
        prdgrp3.Type__c = 'A la Carte';
        insert prdgrp3;
        
        Product_group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Drive';
        prdgrp1.Group_Type__c = 'Favorite';
        prdgrp1.User__c = UserInfo.getUserId();
        prdgrp1.Pricing_Model__c ='test';
        prdgrp1.Active__c = true;
        prdgrp1.Product__c = list_ProductsToInsert[0].id;
        prdgrp1.Offering_Type__c = 'PureConnect On Premise';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;
        
        /* BigMachines__1Quote_Product__c objTestQP = new BigMachines__Quote_Product__c(BigMachines__Quote__c = list_NewQuotes[0].Id,
                            BigMachines__Quantity__c = 1,BigMachines__Sales_Price__c = 100,Product_Group__c = 'Workforce Optimization', Bundle__c = prdgrp2.id
                            );
        insert objTestQP;*/
        
        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp1.id;
        prdgrpItm.Product_Type__c = 'Lab';
        prdgrpItm.Bundle__c = prdgrp1.id;
        insert prdgrpItm;
        
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
        
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting.Name = 'Documentation';
        onPremiseSetting.Sub_Category__c = 'Documentation';
        insert onPremiseSetting;
         
        //Unit tests for ConfigurationCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id); 
        System.currentPageReference().getParameters().put('tab', 'search'); 
        ConfigurationCICController configObj = new ConfigurationCICController();
        configObj.Option2();
        configObj.favouritesOptionHandler();
        configObj.strFavId = prdgrp1.id;
        configObj.showHideFavoriteItems();
        configObj.addFavoritesBtnHandler();
        configObj.deleteFavorite();
        Test.stopTest();
    }
    
    static testmethod void unitTest4(){
         //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        
        
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
        
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        list_NewOpps[0].Sold_To_Country__c = testCountries[0].id;
        update list_NewOpps;
        System.assertEquals(list_NewOpps.size(), 1);
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        list_NewQuotes[0].Multi_Year_Quote__c = true;
        list_NewQuotes[0].Pricing_Model__c = 'testing';
        list_NewQuotes[0].Sold_To_Name__c = list_NewAccts[0].Id;
        list_NewQuotes[0].Quote_Opportunity_Type__c = 'Old Pricing';
        list_NewQuotes[0].Offering_Type__c = 'PureEngage Subscription';
        list_NewQuotes[0].Pricing_Model__c = 'test';
        update list_NewQuotes;
        System.assertEquals(list_NewQuotes.size(), 1);
        
        List<CurrencyType> curr = new list<CurrencyType>();
        for(CurrencyType c: [SELECT IsoCode,ConversionRate FROM CurrencyType]){
          curr.add(c);
        }         
        
        Id RecordTypeIdContact = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Base Item').getRecordTypeId();

        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd = new Product2();
        objTestProd.Pricing_Model__c = 'test';
        objTestProd.APN_Number__c = 'testing';
        objTestProd.SI_Version_Number__c = '8.0';
        objTestProd.Quantity__c = 10;
        objTestProd.Name = 'Test Prod3'; 
        objTestProd.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd.End_of_Support__c = String.valueOf(Date.today());
        objTestProd.IsActive = true;
        objTestProd.RecordTypeId= RecordTypeIdContact;
        objTestProd.Dont_Publish_In_Quote__c = false;
        objTestProd.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd.Price_Permission__c = 'Public';
        objTestProd.Restricted_Product__c =false;
        objTestProd.Versions_Available__c = 'sdfsdf';
        objTestProd.OfferingType__c = 'PureEngage Subscription';
        objTestProd.NG5_NA_USD_Price__c = 1;
        objTestProd.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd);
        
        Product2 objTestProd4 = new Product2();
        objTestProd4.Pricing_Model__c = 'test';
        objTestProd4.APN_Number__c = 'testing';
        objTestProd4.SI_Version_Number__c = '8.0';
        objTestProd4.Quantity__c = 10;
        objTestProd4.Name = 'Test Prod2'; 
        objTestProd4.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd4.End_of_Support__c = String.valueOf(Date.today());
        objTestProd4.IsActive = true;
        objTestProd4.RecordTypeId= RecordTypeIdContact;
        objTestProd4.Dont_Publish_In_Quote__c = false;
        objTestProd4.Price_Effective_Date__c = Date.today().addDays(-5);
        objTestProd4.Price_Permission__c = 'Public';
        objTestProd4.Restricted_Product__c =false;
        objTestProd4.Versions_Available__c = 'sdfsdf';
        objTestProd4.OfferingType__c = 'PureEngage Subscription';
        objTestProd4.NG5_NA_USD_Price__c = 1;
        objTestProd4.Base_Item_Lookup__c = objTestProd.id;
        objTestProd4.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd4);
        
        Product2 objTestProd3 = new Product2();
        objTestProd3.Pricing_Model__c = 'test';
        objTestProd3.SI_Version_Number__c = '8.0';
        objTestProd3.APN_Number__c = 'testing';
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
        objTestProd3.NG5_NA_USD_Price__c = 1;
        objTestProd3.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd3);
        
        Product2 objTestProd1 = new Product2();
        objTestProd1.SI_Version_Number__c = '8.0';
        objTestProd1.Quantity__c = 10;
        objTestProd1.Pricing_Model__c = 'test';
        objTestProd1.APN_Number__c = 'testing';
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
        objTestProd1.NG5_NA_USD_Price__c = 1;
        objTestProd1.Description = 'test 1';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.Quantities_Available__c = 'test;test1';
        list_ProductsToInsert.add(objTestProd1);
        
        Product2 objTestProd2 = new Product2();
        objTestProd2.SI_Version_Number__c = '8.0';
        objTestProd2.APN_Number__c = 'testing';
        objTestProd2.Quantity__c = 10;
        objTestProd2.Pricing_Model__c = 'test';
        objTestProd2.Name = 'Test Prod1';            
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
        objTestProd2.OfferingType__c = 'PureEngage Subscription';
        objTestProd2.zqu__Category__c = 'Add On Services';
        objTestProd2.NG5_NA_USD_Price__c = 1;
        objTestProd2.Description = 'test 1';
        objTestProd2.APN_Number__c = 'Tokens1';
        objTestProd2.Quantities_Available__c = 'test;test1';
        objTestProd2.Parent_Product_lookup__c = objTestProd1.id;
        list_ProductsToInsert.add(objTestProd2);
        insert list_ProductsToInsert;
        Test.startTest();  
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Test';
        prdgrp.Group_Type__c = 'Campaigns';
        prdgrp.Active__c = true;
        prdgrp.Pricing_Model__c = 'test';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Offering_Type__c = 'PureEngage Subscription';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;

        Product_Group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Test';
        prdgrp1.Group_Type__c = 'Campaigns';
        prdgrp1.Active__c = true;
        prdgrp1.Pricing_Model__c = 'test';
        prdgrp1.Product__c = list_ProductsToInsert[0].id;
        prdgrp1.Offering_Type__c = 'PureEngage Subscription';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;
        
        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Substitutable';
        insert prdgrpItm;
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting.Name = 'Documentation';
        onPremiseSetting.Sub_Category__c = 'Documentation';
        insert onPremiseSetting;
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting1 = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting1.Name = 'All';
        onPremiseSetting1.Sub_Category__c = 'Documentation';
        insert onPremiseSetting1;
        
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
        taxo.name = 'All';
        taxo.Taxonomy_Solution__c ='Analytics;Integration;Platform;Workload Management';
        insert taxo;
        
        Taxonomy_Sol_Category_And_Taxonomy_Sol__c taxo1 = new Taxonomy_Sol_Category_And_Taxonomy_Sol__c ();
        taxo1.name = 'Customer Engagement';
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
        
        //Unit tests for ConfigurationCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id); 
        System.currentPageReference().getParameters().put('tab', 'search'); 
        ConfigurationCICController configObj = new ConfigurationCICController();
        configObj.strGroupId = prdgrp.id;
        configObj.Option2();
        configObj.addFavoritesBtnHandler();
        Test.StopTest();
    }
    
    static testmethod void unitTest5(){
         //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
       
        
         List<Country__c>  testCountries = new List<Country__c>();
         testCountries.add(new Country__c(
          Name = 'United States', Region__c = 'North America', PSRDP_Region__c='Australia', DAP_Region__c = 'NA', ISO_Code__c = 'USD',  Country__c = 'USA',
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
        System.assertEquals(list_NewAccts.size(), 1);
        update list_NewAccts;
        
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        list_NewOpps[0].Sold_To_Country__c = testCountries[0].id;
        update list_NewOpps;
        System.assertEquals(list_NewOpps.size(), 1);
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        list_NewQuotes[0].Multi_Year_Quote__c = false;
        list_NewQuotes[0].Quote_Opportunity_Type__c = 'Old Pricing';
        list_NewQuotes[0].Sold_To_Name__c = list_NewAccts[0].id;
        list_NewQuotes[0].Offering_Type__c = 'PureConnect On Premise';
        list_NewQuotes[0].Pricing_Model__c = 'Named User Pricing';
        update list_NewQuotes;
        System.assertEquals(list_NewQuotes.size(), 1);
        
        List<CurrencyType> curr = new list<CurrencyType>();
        for(CurrencyType c: [SELECT IsoCode,ConversionRate FROM CurrencyType]){
          curr.add(c);
        }         
        
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.Pricing_Model__c = 'Named User Pricing';
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.Shipment_Approval__c = 'Notification Only';
        objTestProd1.Dont_Publish_In_Quote__c = false;
        objTestProd1.Restricted_Product__c = false;
        objTestProd1.IsActive = true;
        objTestProd1.Third_Party__c ='TRUE';
        objTestProd1.Price_Effective_Date__c = Date.Today().addDays(-2);
        objTestProd1.Last_Order_Date__c = Date.Today().addDays(2);
        objTestProd1.EOM_Date__c = Date.Today().addDays(4);
        objTestProd1.End_of_Support__c =  String.Valueof(Date.Today().addDays(4));
        objTestProd1.OfferingType__c = 'PureConnect On Premise';
        objTestProd1.APN_Number__c = 'Tokens1';
        list_ProductsToInsert.add(objTestProd1);
        Test.startTest();        
        insert list_ProductsToInsert;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Equip';
        prdgrp.Selected__c = true;
        prdgrp.Group_Type__c = 'Use Case';
        prdgrp.Active__c = true;
        prdgrp.Pricing_Model__c = 'test';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Offering_Type__c = ' PureConnect On Premise';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;
        
        Product_Group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Test';
        prdgrp1.Selected__c = true;
        prdgrp1.Group_Type__c = 'A la Carte';
        prdgrp1.Active__c = true;
        prdgrp1.Pricing_Model__c = 'testing';
        prdgrp1.Product__c = list_ProductsToInsert[0].id;
        prdgrp1.Offering_Type__c = 'PureConnect On Premise';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;
        
        Product_Group__c prdgrp2 = new Product_group__c();
        prdgrp2.Name = 'Guide';
        prdgrp2.Selected__c = true;
        prdgrp2.Group_Type__c = 'Use Case';
        prdgrp2.Active__c = true;
        prdgrp2.Pricing_Model__c = 'test';
        prdgrp2.Product__c = list_ProductsToInsert[0].id;
        prdgrp2.Offering_Type__c = ' PureConnect On Premise';
        prdgrp2.Order__c = 12;
        prdgrp2.Quantity__c = 10;
        prdgrp2.Type__c = 'A la Carte';
        insert prdgrp2;
        
        Product_Group__c prdgrp3 = new Product_group__c();
        prdgrp3.Name = 'Drive';
        prdgrp3.Selected__c = true;
        prdgrp3.Group_Type__c = 'A la Carte';
        prdgrp3.Pricing_Model__c ='test1';
        prdgrp3.Active__c = true;
        prdgrp3.Product__c = list_ProductsToInsert[0].id;
        prdgrp3.Offering_Type__c = 'PureConnect On Premise';
        prdgrp3.Order__c = 10;
        prdgrp3.Quantity__c = 10;
        prdgrp3.Type__c = 'A la Carte';
        insert prdgrp3;
        
        Product_Group__c prdgrp4 = new Product_group__c();
        prdgrp4.Name = 'Partner PureSuccess';
        prdgrp4.Selected__c = true;
        prdgrp4.Group_Type__c = 'A la Carte';
        prdgrp4.Pricing_Model__c ='test1';
        prdgrp4.Active__c = true;
        prdgrp4.Product__c = list_ProductsToInsert[0].id;
        prdgrp4.Offering_Type__c = 'PureConnect On Premise';
        prdgrp4.Order__c = 10;
        prdgrp4.Quantity__c = 10;
        prdgrp4.Type__c = 'A la Carte';
        insert prdgrp4;
        
        /*List<BigMachines__Quote_Product__c> bmQuoteProduct = new List<BigMachines__Quote_Product__c>();  
        BigMachines__Quote_Product__c qp = new BigMachines__Quote_Product__c();
        qp.Product__c = objTestProd1.Id;            
        qp.BigMachines__Quantity__c = 10;
        qp.Bundle__c = prdgrp.id;
        qp.BigMachines__Sales_Price__c = 500;        
        qp.BigMachines__Quantity__c = 2;        
        qp.Ext_List__c = 10;
        qp.Ext_Net_Price__c = 100;
        qp.CurrencyIsoCode = 'USD';        
        qp.BigMachines__Quote__c = list_NewQuotes[0].Id;
        bmQuoteProduct.add(qp);
        
        BigMachines__Quote_Product__c qp1 = new BigMachines__Quote_Product__c();
        qp1.Product__c = objTestProd1.Id;            
        qp1.BigMachines__Quantity__c = 10;
        qp.Bundle__c = prdgrp1.id;
        qp1.BigMachines__Sales_Price__c = 500;        
        qp1.BigMachines__Quantity__c = 2;        
        qp1.Ext_List__c = 10;
        qp1.Ext_Net_Price__c = 100;
        qp1.CurrencyIsoCode = 'USD';        
        qp1.BigMachines__Quote__c = list_NewQuotes[0].Id;
        
        BigMachines__Quote_Product__c qp2 = new BigMachines__Quote_Product__c();
        qp2.Product__c = objTestProd1.Id;             
        qp2.BigMachines__Quantity__c = 10;
        qp.Bundle__c = prdgrp2.id;
        qp2.BigMachines__Sales_Price__c = 500;        
        qp2.BigMachines__Quantity__c = 2;        
        qp2.Ext_List__c = 10;
        qp2.Ext_Net_Price__c = 100;
        qp2.CurrencyIsoCode = 'USD';        
        qp2.BigMachines__Quote__c = list_NewQuotes[0].Id;
        bmQuoteProduct.add(qp2);
        
        BigMachines__Quote_Product__c qp3 = new BigMachines__Quote_Product__c();
        qp3.Product__c = objTestProd1.Id;             
        qp3.BigMachines__Quantity__c = 10;
        qp.Bundle__c = prdgrp3.id;
        qp3.BigMachines__Sales_Price__c = 500;        
        qp3.BigMachines__Quantity__c = 2;        
        qp3.Ext_List__c = 10;
        qp3.Ext_Net_Price__c = 100;
        qp3.CurrencyIsoCode = 'USD';        
        qp3.BigMachines__Quote__c = list_NewQuotes[0].Id;
        bmQuoteProduct.add(qp3);
         
        insert bmQuoteProduct;*/
        
        Product_group__c prdgrp5 = new Product_group__c();
        prdgrp5.Name = 'Drive';
        prdgrp5.Group_Type__c = 'A la Carte';
        prdgrp5.User__c = UserInfo.getUserId();
        prdgrp5.Pricing_Model__c ='test';
        prdgrp5.Active__c = true;
        prdgrp5.Product__c = list_ProductsToInsert[0].id;
        prdgrp5.Offering_Type__c = 'PureConnect On Premise';
        prdgrp5.Order__c = 12;
        prdgrp5.Quantity__c = 10;
        prdgrp5.Type__c = 'A la Carte';
        insert prdgrp5;
        
        Product_Group_Item__c prdgrpItm1 = new Product_Group_Item__c();
        prdgrpItm1.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm1.Product_Group__c = prdgrp5.id;
        prdgrpItm1.Product_Type__c = 'Lab';
        prdgrpItm1.Bundle__c = prdgrp5.id;
        insert prdgrpItm1;
        
        Product_Group_Item__c prdgrpItm2 = new Product_Group_Item__c();
        prdgrpItm2.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm2.Product_Group__c = prdgrp1.id;
        prdgrpItm2.Product_Type__c = 'Lab';
        insert prdgrpItm2;
        
        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Mandatory Substitutable';
        insert prdgrpItm;
        
        
        Product_Group_Item__c prdgrpItm3 = new Product_Group_Item__c();
        prdgrpItm3.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm3.Product_Group__c = prdgrp.id;
        prdgrpItm3.Product_Type__c = 'Substitutable';
        prdgrpItm3.select__c = true;
        insert prdgrpItm3;
               
        
        Product_Group_Item__c prdgrpItm4 = new Product_Group_Item__c();
        prdgrpItm4.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm4.Product_Group__c = prdgrp.id;
        prdgrpItm4.Product_Type__c = 'Substitutable';
        prdgrpItm4.Substitutable_Product_Group_Item__c = prdgrpItm1.id;
        insert prdgrpItm4;
        
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
        
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting.Name = 'Documentation';
        onPremiseSetting.Sub_Category__c = 'Documentation';
        insert onPremiseSetting;
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting1 = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting1.Name = 'All';
        onPremiseSetting1.Sub_Category__c = 'Documentation';
        insert onPremiseSetting1;
        
        OnPremiseCIC_Category_and_Building_Block__c onpremiseCat = new OnPremiseCIC_Category_and_Building_Block__c();
        onpremiseCat.Name = 'Documentation';
        onpremiseCat.Building_Block__c = 'DR - Nuance Grammars;DR - Nuance Recognizer 10;DR - Nuance Recognizer 9';
        insert onpremiseCat;
        
        //Unit tests for ConfigurationCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id); 
        System.currentPageReference().getParameters().put('tab', 'search'); 
        ConfigurationCICController configObj = new ConfigurationCICController();
        configObj.Option2();
        configObj.strSelectedTaxonomyCategorySolution = 'All';
        configObj.changeCategory();
        configObj.useCaseOptionHandler();
        configObj.saveLogic();
        configObj.addBundlesBtnHandler();
        configObj.addFavoritesBtnHandler();
        configObj.markFavBtnHandler();
        configObj.objFavToBeSaved.Name = 'Test';
        configObj.saveFavourite();
        configObj.saveLogic();
        configObj.strGroupId = prdgrp.id;
        configObj.showHideProducts();
        Test.stopTest();
    }
    
    @isTest(SeeAllData=true)
    static void unitTest7(){
         //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        update list_NewAccts;
        
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        update list_NewOpps;
        System.assertEquals(list_NewOpps.size(), 1);
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        list_NewQuotes[0].Multi_Year_Quote__c = false;
        list_NewQuotes[0].Quote_Opportunity_Type__c = 'Old Pricing';
        list_NewQuotes[0].Sold_To_Name__c = list_NewAccts[0].id;
        list_NewQuotes[0].Offering_Type__c = 'PureConnect On Premise';
        list_NewQuotes[0].Pricing_Model__c = 'Named User Pricing';
        update list_NewQuotes;
        System.assertEquals(list_NewQuotes.size(), 1);
        
        List<CurrencyType> curr = new list<CurrencyType>();
        for(CurrencyType c: [SELECT IsoCode,ConversionRate FROM CurrencyType]){
          curr.add(c);
        }         
        
        List<Product2> list_ProductsToInsert = new List<Product2>();
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.Pricing_Model__c = 'Named User Pricing';
        objTestProd1.Building_Block__c = 'PS Rapid Deployment Packages';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.Shipment_Approval__c = 'Notification Only';
        objTestProd1.Dont_Publish_In_Quote__c = false;
        objTestProd1.Restricted_Product__c = false;
        objTestProd1.IsActive = true;
        objTestProd1.Third_Party__c ='TRUE';
        objTestProd1.Price_Effective_Date__c = Date.Today().addDays(-2);
        objTestProd1.Last_Order_Date__c = Date.Today().addDays(2);
        objTestProd1.EOM_Date__c = Date.Today().addDays(4);
        objTestProd1.End_of_Support__c =  String.Valueof(Date.Today().addDays(4));
        objTestProd1.OfferingType__c = 'PureConnect On Premise';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'Tokens123';
        list_ProductsToInsert.add(objTestProd1);
        Test.startTest();        
        insert list_ProductsToInsert;
        
        Product_Group__c prdgrp = new Product_group__c();
        prdgrp.Name = 'Equip';
        prdgrp.Selected__c = true;
        prdgrp.Group_Type__c = 'Use Case';
        prdgrp.Active__c = true;
        prdgrp.Pricing_Model__c = 'test';
        prdgrp.Product__c = list_ProductsToInsert[0].id;
        prdgrp.Offering_Type__c = ' PureConnect On Premise';
        prdgrp.Order__c = 12;
        prdgrp.Quantity__c = 10;
        prdgrp.Type__c = 'A la Carte';
        insert prdgrp;
        
        Product_Group__c prdgrp1 = new Product_group__c();
        prdgrp1.Name = 'Test';
        prdgrp1.Selected__c = true;
        prdgrp1.Group_Type__c = 'A la Carte';
        prdgrp1.Active__c = true;
        prdgrp1.Pricing_Model__c = 'testing';
        prdgrp1.Product__c = list_ProductsToInsert[0].id;
        prdgrp1.Offering_Type__c = 'PureConnect On Premise';
        prdgrp1.Order__c = 12;
        prdgrp1.Quantity__c = 10;
        prdgrp1.Type__c = 'A la Carte';
        insert prdgrp1;
        
        Product_Group__c prdgrp2 = new Product_group__c();
        prdgrp2.Name = 'Guide';
        prdgrp2.Selected__c = true;
        prdgrp2.Group_Type__c = 'Use Case';
        prdgrp2.Active__c = true;
        prdgrp2.Pricing_Model__c = 'test';
        prdgrp2.Product__c = list_ProductsToInsert[0].id;
        prdgrp2.Offering_Type__c = ' PureConnect On Premise';
        prdgrp2.Order__c = 12;
        prdgrp2.Quantity__c = 10;
        prdgrp2.Type__c = 'A la Carte';
        insert prdgrp2;
        
        Product_Group__c prdgrp3 = new Product_group__c();
        prdgrp3.Name = 'Drive';
        prdgrp3.Selected__c = true;
        prdgrp3.Group_Type__c = 'PureSuccess';
        prdgrp3.Pricing_Model__c ='test1';
        prdgrp3.Active__c = true;
        prdgrp3.Product__c = list_ProductsToInsert[0].id;
        prdgrp3.Offering_Type__c = 'PureConnect On Premise';
        prdgrp3.Order__c = 10;
        prdgrp3.Quantity__c = 10;
        prdgrp3.Type__c = 'A la Carte';
        insert prdgrp3;
        
        Product_Group__c prdgrp4 = new Product_group__c();
        prdgrp4.Name = 'Partner PureSuccess';
        prdgrp4.Selected__c = true;
        prdgrp4.Group_Type__c = 'PureSuccess';
        prdgrp4.Pricing_Model__c ='test1';
        prdgrp4.Active__c = true;
        prdgrp4.Product__c = list_ProductsToInsert[0].id;
        prdgrp4.Offering_Type__c = 'PureConnect On Premise';
        prdgrp4.Order__c = 10;
        prdgrp4.Quantity__c = 10;
        prdgrp4.Type__c = 'A la Carte';
        insert prdgrp4;
        
        /*List<BigMachines__Quote_Product__c> bmQuoteProduct = new List<BigMachines__Quote_Product__c>();  
        BigMachines__Quote_Product__c qp = new BigMachines__Quote_Product__c();
        qp.Product__c = objTestProd1.Id;            
        qp.BigMachines__Quantity__c = 10;
        qp.Bundle__c = prdgrp.id;
        qp.BigMachines__Sales_Price__c = 500;        
        qp.BigMachines__Quantity__c = 2;        
        qp.Ext_List__c = 10;
        qp.Ext_Net_Price__c = 100;
        qp.CurrencyIsoCode = 'USD';        
        qp.BigMachines__Quote__c = list_NewQuotes[0].Id;
        bmQuoteProduct.add(qp);
        
        BigMachines__Quote_Product__c qp1 = new BigMachines__Quote_Product__c();
        qp1.Product__c = objTestProd1.Id;            
        qp1.BigMachines__Quantity__c = 10;
        qp.Bundle__c = prdgrp1.id;
        qp1.BigMachines__Sales_Price__c = 500;        
        qp1.BigMachines__Quantity__c = 2;        
        qp1.Ext_List__c = 10;
        qp1.Ext_Net_Price__c = 100;
        qp1.CurrencyIsoCode = 'USD';        
        qp1.BigMachines__Quote__c = list_NewQuotes[0].Id;
        
        BigMachines__Quote_Product__c qp2 = new BigMachines__Quote_Product__c();
        qp2.Product__c = objTestProd1.Id;             
        qp2.BigMachines__Quantity__c = 10;
        qp.Bundle__c = prdgrp2.id;
        qp2.BigMachines__Sales_Price__c = 500;        
        qp2.BigMachines__Quantity__c = 2;        
        qp2.Ext_List__c = 10;
        qp2.Ext_Net_Price__c = 100;
        qp2.CurrencyIsoCode = 'USD';        
        qp2.BigMachines__Quote__c = list_NewQuotes[0].Id;
        bmQuoteProduct.add(qp2);
        
        BigMachines__Quote_Product__c qp3 = new BigMachines__Quote_Product__c();
        qp3.Product__c = objTestProd1.Id;             
        qp3.BigMachines__Quantity__c = 10;
        qp.Bundle__c = prdgrp3.id;
        qp3.BigMachines__Sales_Price__c = 500;        
        qp3.BigMachines__Quantity__c = 2;        
        qp3.Ext_List__c = 10;
        qp3.Ext_Net_Price__c = 100;
        qp3.CurrencyIsoCode = 'USD';        
        qp3.BigMachines__Quote__c = list_NewQuotes[0].Id;
        bmQuoteProduct.add(qp3);
         
        insert bmQuoteProduct;*/
        
        Product_group__c prdgrp5 = new Product_group__c();
        prdgrp5.Name = 'Drive';
        prdgrp5.Group_Type__c = 'A la Carte';
        prdgrp5.User__c = UserInfo.getUserId();
        prdgrp5.Pricing_Model__c ='test';
        prdgrp5.Active__c = true;
        prdgrp5.Product__c = list_ProductsToInsert[0].id;
        prdgrp5.Offering_Type__c = 'PureConnect On Premise';
        prdgrp5.Order__c = 12;
        prdgrp5.Quantity__c = 10;
        prdgrp5.Type__c = 'A la Carte';
        insert prdgrp5;
        
        Product_Group_Item__c prdgrpItm1 = new Product_Group_Item__c();
        prdgrpItm1.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm1.Product_Group__c = prdgrp5.id;
        prdgrpItm1.Product_Type__c = 'Lab';
        prdgrpItm1.Bundle__c = prdgrp5.id;
        insert prdgrpItm1;
        
        Product_Group_Item__c prdgrpItm2 = new Product_Group_Item__c();
        prdgrpItm2.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm2.Product_Group__c = prdgrp1.id;
        prdgrpItm2.Product_Type__c = 'Lab';
        insert prdgrpItm2;
        
        Product_Group_Item__c prdgrpItm = new Product_Group_Item__c();
        prdgrpItm.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm.Product_Group__c = prdgrp.id;
        prdgrpItm.Product_Type__c = 'Mandatory Substitutable';
        insert prdgrpItm;
        
        
        Product_Group_Item__c prdgrpItm3 = new Product_Group_Item__c();
        prdgrpItm3.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm3.Product_Group__c = prdgrp.id;
        prdgrpItm3.Product_Type__c = 'Substitutable';
        prdgrpItm3.select__c = true;
        insert prdgrpItm3;
               
        
        Product_Group_Item__c prdgrpItm4 = new Product_Group_Item__c();
        prdgrpItm4.Product__c = list_ProductsToInsert[0].Id;
        prdgrpItm4.Product_Group__c = prdgrp.id;
        prdgrpItm4.Product_Type__c = 'Substitutable';
        prdgrpItm4.Substitutable_Product_Group_Item__c = prdgrpItm1.id;
        insert prdgrpItm4;
        
        //Unit tests for ConfigurationCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id); 
        System.currentPageReference().getParameters().put('tab', 'search'); 
        ConfigurationCICController configObj = new ConfigurationCICController();
        configObj.Option2();
        configObj.createCurrentPageList();
        configObj.addProductsFromSearch();
        configObj.addFavoritesBtnHandler();
        configObj.strSortFieldSelected = 'Name';
        configObj.changeSorting();
    } 
    
    @isTest(SeeAllData=true)
    static void unitTest8(){
         //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        List<Country__c> countryObj = [Select id from Country__c Where PSRDP_Region__c !='' LIMIT 1];
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        list_NewAccts[0].Country__c = countryObj[0].id;
        System.assertEquals(list_NewAccts.size(), 1);
        update list_NewAccts;
        
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        update list_NewOpps;
        System.assertEquals(list_NewOpps.size(), 1);
        
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        list_NewQuotes[0].Multi_Year_Quote__c = false;
        list_NewQuotes[0].Quote_Opportunity_Type__c = 'New Pricing';
        list_NewQuotes[0].Sold_To_Name__c = list_NewAccts[0].id;
        list_NewQuotes[0].Offering_Type__c = 'PureConnect On Premise';
        list_NewQuotes[0].Pricing_Model__c = 'Concurrent';
        list_NewQuotes[0].Product_Version__c = 'CIC 4.0';
        update list_NewQuotes;
        System.assertEquals(list_NewQuotes.size(), 1);
        List<Product2> prod = TestDataFactoryForQuoteTool2.createproducts(2);
        prod[0].NG5_NA_USD_Price__c = 1;
        prod[0].Pricing_Model__c ='Concurrent';
        prod[0].offeringtype__c= 'PureConnect On Premise';
        prod[0].Dont_Publish_In_Quote__c= false;
        prod[0].Restricted_Product__c = false;
        prod[0].Show_In_BEP__c = true;
        prod[0].Product_Name__c = 'test';
        prod[0].IsActive = true;
        prod[0].APN_Number__c = '123';
        prod[0].Product_Version__c ='CIC 4.0';
        prod[0].Versions_Available__c = 'test';
        prod[0].Quantities_Available__c = '1';
        prod[0].Pass_Through__c= true;
        prod[0].Quantity__c = 1;
        update prod;
        prod[1].NG5_NA_USD_Price__c = 1;
        prod[1].Pricing_Model__c ='Concurrent';
        prod[1].offeringtype__c= 'PureConnect On Premise';
        prod[1].Dont_Publish_In_Quote__c= false;
        prod[1].Restricted_Product__c = false;
        prod[1].Show_In_BEP__c = true;
        prod[1].IsActive = true;
        prod[1].Version_Available_For_old__c = 'test';
        prod[1].APN_Number__c = '123';
        prod[1].Product_Version__c ='CIC 4.0';
        prod[1].Product_Name__c = 'test1';
        prod[1].Parent_Product_lookup__c= prod[0].id;
        prod[1].Quantities_Available__c = '1';
        prod[1].Pass_Through__c= true;
        prod[1].Quantity__c = 1;
        update prod;
        List<Product_Group__c> productGroup = TestDataFactoryForQuoteTool2.createprodgrop(2);
        productGroup[0].Product__c = prod[0].id;
        productGroup[0].Group_Type__c = 'Campaigns';
        productGroup[0].Type__c = 'Campaign';
        productGroup[0].Quantity__c = 1;
        productGroup[0].Active__c = true;
        productGroup[0].Name = 'true';
        productGroup[0].Pricing_Model__c = 'Concurrent';
        productGroup[0].Offering_Type__c = 'PureConnect On Premise';
        update productGroup;
        productGroup[1].Product__c = prod[0].id;
        productGroup[1].Group_Type__c = 'Favorite';
        productGroup[1].Type__c = 'Campaign';
        productGroup[1].Quantity__c = 1;
        productGroup[1].Active__c = true;
        productGroup[1].Name = 'true';
        productGroup[1].Pricing_Model__c = 'Concurrent';
        productGroup[1].Offering_Type__c = 'PureConnect On Premise';
        update productGroup;
        
        List<Product_Group_Item__c> productGroupItem = TestDataFactoryForQuoteTool2.createprodgropIt(productGroup[0].id, prod[0].id,5);
        productGroupItem[0].product_type__c ='Mandatory';
        productGroupItem[1].product_type__c ='Optional';
        productGroupItem[2].product_type__c ='LAB';
        productGroupItem[3].product_type__c ='HA';
        productGroupItem[4].product_type__c ='Substitutable';
        productGroupItem[4].Select__c = true;
        update productGroupItem;
        List<BigMachines__Quote_Product__c> quoteProduct = TestDataFactoryForQuoteTool2.createQuoteProducts11(list_NewQuotes[0].id);
        quoteProduct[0].BigMachines__Product__c = prod[0].id;
        quoteProduct[0].Bundle__c = productGroup[0].id;
        update quoteProduct;
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting.Name = 'Branch Office';
        onPremiseSetting.Sub_Category__c = 'Branch Office';
        insert onPremiseSetting;
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting1 = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting1.Name = 'All';
        onPremiseSetting1.Sub_Category__c = 'Documentation';
        insert onPremiseSetting1;
        
        OnPremise_CIC_Category_and_Subcategory__c onPremiseSetting2 = new OnPremise_CIC_Category_and_Subcategory__c();
        onPremiseSetting2.Name = 'test';
        onPremiseSetting2.Sub_Category__c = 'Documentation';
        insert onPremiseSetting2;
        
        //Unit tests for ConfigurationCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id); 
        System.currentPageReference().getParameters().put('tab', 'search'); 
        ConfigurationCICController configObj = new ConfigurationCICController();
        configObj.addProductsBtnHandler();
        configObj.strGroupId = productGroup[0].id;
        configObj.strSelectedCategory = 'All';
        configObj.CampaignsOptionHandler();
        configObj.showHideCampaignsProducts();
        configObj.addCampaignssBtnHandler();
        configObj.Option2();
        configObj.createCurrentPageList();
        configObj.showHideFavoriteItems();
        if(configObj.list_Favourites.size() > 0){
            configObj.list_Favourites.get(0).blnIsSelected = true;
            configObj.addFavoritesBtnHandler();
            configObj.markFavBtnHandler();
            configObj.saveFavourite();
        }
        configObj.addProductsFromSearch();
        configObj.addFavoritesBtnHandler();
        configObj.markFavBtnHandler();
        configObj.objFavToBeSaved.Name = 'Test';
        configObj.saveFavourite();
        configObj.saveLogic();
        configObj.strSortFieldSelected = 'Name';
        configObj.changeSorting();
    } 
    
}