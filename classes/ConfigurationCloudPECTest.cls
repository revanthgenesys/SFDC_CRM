@isTest(seealldata=true)
private class ConfigurationCloudPECTest {
    @isTest
    static void intialTest() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        
        //Unit tests for ConfigurationCloudPECController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);        
        ConfigurationCloudPECController objConfigCloudCont = new ConfigurationCloudPECController(); 
        List<Product2> list_products1 = [Select Id, Name ,  Quantity__c
                                         FROM Product2 Limit 5];
        Product2 objPRod = [select Id,Name, Quantity__c from Product2 where APN_Number__c = 'CS-012-NV-PCCAF'];
        list_products1.add(objPRod);
        objConfigCloudCont.map_BuildingBlockToProducts.put('Monthly Contact Center Agent Fees',list_products1);
        System.debug('productmap'+objConfigCloudCont.map_BuildingBlockToProducts);
        
        for(List<Product2> list_Products : objConfigCloudCont.map_BuildingBlockToProducts.values()) {
            for(Integer i=0; i<(list_Products.size()>=5 ? 5 : list_Products.size()); i++) {
                list_Products[i].Quantity__c = 1;
                objConfigCloudCont.strProductIdForInfo = list_Products[i].Id;                
            }
            //list_Products[list_Products.size()-1].Product_Name__c='10.0';
        }
        
        objConfigCloudCont.addProductsBtnHandler(); 
        objConfigCloudCont.strProdIndex = '0';
        objConfigCloudCont.removeProduct();  
        
        objConfigCloudCont.productSearchOptionHandler();
        
        
        objConfigCloudCont.guidedSellingOptionHandler();
        objConfigCloudCont.idFlowStepSelected = objConfigCloudCont.list_GuidedSellingFlows[0].Guided_Selling_Flow_Steps__r[0].Id;
        objConfigCloudCont.showGSFlowStepProducts();
        objConfigCloudCont.nextFlowStepBtnHandler();
        objConfigCloudCont.previousFlowStepBtnHandler();
        
        objConfigCloudCont.bundleOptionHandler();
        objConfigCloudCont.useCaseOptionHandler(); 
        objConfigCloudCont.addUseCasesHandler(); 
        objConfigCloudCont.removeUseCases();
        
        objConfigCloudCont.showProductInfo();
        objConfigCloudCont.hideProductInfo();
        objConfigCloudCont.showHideProducts();
        objConfigCloudCont.showHideCampaignsProducts();
        
        objConfigCloudCont.addBundlesBtnHandler();
        
        objConfigCloudCont.addCampaignssBtnHandler();
        objConfigCloudCont.CampaignsOptionHandler();
        objConfigCloudCont.removeProductBundle();
        
        objConfigCloudCont.checkForRequiredConfirmations();
        objConfigCloudCont.confBoxCancel();
        objConfigCloudCont.confBoxProceed();
        objConfigCloudCont.saveBtnHandler();
        objConfigCloudCont.saveLogic();
        
        objConfigCloudCont.objSearchProduct.Name = 'Interaction';
        objConfigCloudCont.searchBtnHandler();
        objConfigCloudCont.list_SearchProducts[0].Quantity__c = 1;
        objConfigCloudCont.addProductsFromSearch();
        //objConfigCloudCont.changeSorting();
        
        objConfigCloudCont.markFavBtnHandler();
        objConfigCloudCont.saveFavourite();
        objConfigCloudCont.objFavToBeSaved.Name = 'TestFavourite';
        objConfigCloudCont.saveFavourite();
        objConfigCloudCont.cancelMarkFavourite();
        objConfigCloudCont.favouritesOptionHandler();
        objConfigCloudCont.list_Favourites[0].blnIsSelected = true;
        objConfigCloudCont.addFavoritesBtnHandler();
        objConfigCloudCont.strFavId = objConfigCloudCont.list_Favourites[0].objFavorite.Id;
        objConfigCloudCont.showHideFavoriteItems();
        objConfigCloudCont.deleteFavorite(); 
        
        objConfigCloudCont.next();
        objConfigCloudCont.previous(); 
        objConfigCloudCont.getHasPrevious();
        objConfigCloudCont.getHasNext();
        objConfigCloudCont.first();
        objConfigCloudCont.last();
        objConfigCloudCont.getPageNumStr();
        objConfigCloudCont.numberOfPages();        
        
        objConfigCloudCont.strSelectedTaxonomySolution='All';
        objConfigCloudCont.showProductFinancials();        
        
        objConfigCloudCont.strSelectedCategory='All';        
        objConfigCloudCont.showProductFinancials();
        objConfigCloudCont.showTaxonomySolutions();
        
        objConfigCloudCont.strProductFinancial='All';
        objConfigCloudCont.showProducts();
        
        objConfigCloudCont.removeAllBtnHandler();
        
        objConfigCloudCont.pureSuccessOptionHandler();
        //objConfigCloudCont.createBundleQueryString('PureSuccess');
        objConfigCloudCont.addPureSuccessBtnHandler();
        objConfigCloudCont.removeAlaCarteItem();
    }
    
    @isTest
    static void handleQuantitiesAvailable () {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        List<BigMachines__Quote_Product__c>list_ObjQP = TestDataFactoryForQuoteTool.createQuoteProducts4(list_NewQuotes[0].Id);
        //Unit tests for ConfigurationCloudPECController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);        
        ConfigurationCloudPECController objConfigCloudCont = new ConfigurationCloudPECController(); 
        List<Product2> list_products1 = [Select Id, Name 
                                         FROM Product2 Limit 5];
        objConfigCloudCont.map_BuildingBlockToProducts.put('Monthly Contact Center Agent Fees',list_products1);
        System.debug('productmap'+objConfigCloudCont.map_BuildingBlockToProducts);
        
        for(List<Product2> list_Products : objConfigCloudCont.map_BuildingBlockToProducts.values()) {
            for(Integer i=0; i<(list_Products.size()>=5 ? 5 : list_Products.size()); i++) {
                list_Products[i].Quantity__c = 1;
                objConfigCloudCont.strProductIdForInfo = list_Products[i].Id;                
            }
            //list_Products[list_Products.size()-1].Product_Name__c='10.0';
        }
        
        objConfigCloudCont.handleQuantitiesAvailable([SELECT Id,Name, Quantities_Available__c 
                                                      FROM Product2
                                                      WHERE Quantities_Available__c != null limit 1 ]);
        List<Product_Group__c> list_ProductGroup = [SELECT Id,Name
                                                    FROM Product_Group__c Limit 2];
        objConfigCloudCont.map_BundleIdToShowProductsChoice.put(list_ProductGroup[0].Id,true);
        objConfigCloudCont.map_BundleIdToShowProductsChoice.put(list_ProductGroup[1].Id,false);
        
        objConfigCloudCont.strGroupId = list_ProductGroup[0].Id;
        objConfigCloudCont.showHideProducts();
        objConfigCloudCont.strGroupId = list_ProductGroup[1].Id;
        objConfigCloudCont.showHideProducts();
        objConfigCloudCont.pureSuccessOptionHandler();
        
        
        
    }
    
    @isTest
    static void testPrerequisite () {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        List<BigMachines__Quote_Product__c>list_ObjQP = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        //Unit tests for ConfigurationCloudPECController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);        
        ConfigurationCloudPECController objConfigCloudCont = new ConfigurationCloudPECController(); 
        List<Product2> list_products1 = [Select Id, Name 
                                         FROM Product2 Limit 5];
        objConfigCloudCont.map_BuildingBlockToProducts.put('Monthly Contact Center Agent Fees',list_products1);
        System.debug('productmap'+objConfigCloudCont.map_BuildingBlockToProducts);
        
        for(List<Product2> list_Products : objConfigCloudCont.map_BuildingBlockToProducts.values()) {
            for(Integer i=0; i<(list_Products.size()>=5 ? 5 : list_Products.size()); i++) {
                list_Products[i].Quantity__c = 1;
                objConfigCloudCont.strProductIdForInfo = list_Products[i].Id;                
            }
            //list_Products[list_Products.size()-1].Product_Name__c='10.0';
        }
        objConfigCloudCont.list_QuoteProductsToBeCreated = TestDataFactoryForQuoteTool.createPCQuoteProducts2(list_NewQuotes[0].Id);
        objConfigCloudCont.addProductsFromSearch();
        
    }
    
    @isTest
    static void testSaveLogic() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        User objUser = [SELECT BypassValidationRules__c,Bypass_Triggers__c FROM User WHERE Id =: userinfo.getUserId()];
        objuser.BypassValidationRules__c = true;
        objuser.Bypass_Triggers__c = true;
        update objUser;   
        
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        List<BigMachines__Quote_Product__c>list_ObjQP = TestDataFactoryForQuoteTool.createPECQuoteProducts(list_NewQuotes[0].Id);
        //Unit tests for ConfigurationCloudPECController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloudPEC')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);        
        ConfigurationCloudPECController objConfigCloudCont = new ConfigurationCloudPECController(); 
        List<Product2> list_products1 = [Select Id, Name 
                                         FROM Product2 Limit 5];
        objConfigCloudCont.map_BuildingBlockToProducts.put('Monthly Contact Center Agent Fees',list_products1);
        System.debug('productmap'+objConfigCloudCont.map_BuildingBlockToProducts);
        
        for(List<Product2> list_Products : objConfigCloudCont.map_BuildingBlockToProducts.values()) {
            for(Integer i=0; i<(list_Products.size()>=5 ? 5 : list_Products.size()); i++) {
                list_Products[i].Quantity__c = 1;
                objConfigCloudCont.strProductIdForInfo = list_Products[i].Id;                
            }
            //list_Products[list_Products.size()-1].Product_Name__c='10.0';
        }
        objConfigCloudCont.list_BundlesToBeSaved = [SELECT Id,Name,Quantity__c,Price__c,Additional_Discount__c,Group_Type__c,Discount__c,Product__r.product_group__c,Product__r.APN_Number__c,Product__r.Unit_of_Measure__c, Product__r.NG5_NA_USD_Price__c, (SELECT Product__c,Product__r.Product_Specific_Discount__c,Product__r.APN_Number__c,Product__r.Building_Block__c,Product__r.NG5_NA_USD_Price__c,Product__r.Is_Concurrent__c,Product__r.Product_Manager_Approval_Group__r.Name,Product__r.Name,Product__r.Third_Party__c,Product__r.Third_Party_GC__c,Product__r.Unit_of_Measure__c,Quantity__c FROM Product_Group_Items__r Where Product__c != null AND Product_Type__c = 'Mandatory')FROM Product_Group__c Where Id in (Select Product_Group__c from Product_Group_Item__c where Product__c != null) 
                                                    AND Group_Type__c in ('Dependent Products','Use Case')
                                                    AND Active__c = true limit 3];// AND Offering_Type__c = 'PureConnect Cloud' limit 10];
        objConfigCloudCont.list_BundlesToBeSaved.addAll([SELECT Id,Name,Quantity__c,Price__c,Group_Type__c,Additional_Discount__c,Discount__c,Product__r.product_group__c,Product__r.APN_Number__c,Product__r.Unit_of_Measure__c, Product__r.NG5_NA_USD_Price__c, (SELECT Product__c,Product__r.Product_Specific_Discount__c,Product__r.APN_Number__c,Product__r.Building_Block__c,Product__r.NG5_NA_USD_Price__c,Product__r.Is_Concurrent__c,Product__r.Product_Manager_Approval_Group__r.Name,Product__r.Name,Product__r.Third_Party__c,Product__r.Third_Party_GC__c,Product__r.Unit_of_Measure__c,Quantity__c FROM Product_Group_Items__r Where Product__c != null AND Product_Type__c = 'Mandatory')FROM Product_Group__c Where Id in (Select Product_Group__c from Product_Group_Item__c where Product__c != null) 
                                                    AND Group_Type__c  = 'Use Case'
                                                    AND Active__c = true limit 3]);
        for(Product_Group__c objGroup : objConfigCloudCont.list_BundlesToBeSaved) {
            objGroup.Quantity__c = 2;
            system.debug('coming');
        }
        Test.startTest();
        objConfigCloudCont.saveLogic();
        objConfigCloudCont.getUseCaseBundles('NG5_NA_USD_Price__c',objConfigCloudCont.list_BundlesToBeSaved);
        Test.stopTest();
        objuser.BypassValidationRules__c = false;
        objuser.Bypass_Triggers__c = false;
        update objUser;   
        
    }
    
    @isTest
    static void testsaveAlaCarteItems() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        List<BigMachines__Quote_Product__c>list_ObjQP = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        //Unit tests for ConfigurationCloudPECController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);        
        ConfigurationCloudPECController objConfigCloudCont = new ConfigurationCloudPECController(); 
        List<Product2> list_products1 = [Select Id, Name 
                                         FROM Product2 Limit 5];
        objConfigCloudCont.map_BuildingBlockToProducts.put('Monthly Contact Center Agent Fees',list_products1);
        System.debug('productmap'+objConfigCloudCont.map_BuildingBlockToProducts);
        
        for(List<Product2> list_Products : objConfigCloudCont.map_BuildingBlockToProducts.values()) {
            for(Integer i=0; i<(list_Products.size()>=5 ? 5 : list_Products.size()); i++) {
                list_Products[i].Quantity__c = 1;
                objConfigCloudCont.strProductIdForInfo = list_Products[i].Id;                
            }
            //list_Products[list_Products.size()-1].Product_Name__c='10.0';
        }
        objConfigCloudCont.list_OfAlaCarteToBeSaved = [SELECT Id,Name,Quantity__c,NG5_NA_USD_Price__c From Product2 where Quantity__c != null and NG5_NA_USD_Price__c != null limit 10 ];
        objConfigCloudCont.saveAlaCarteItems();
        objConfigCloudCont.thisForCodeCoverage();
    }
    
    
}