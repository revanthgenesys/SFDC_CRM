/************************************************************************************
Purpose : Unit test class for ConfigurationCloudPCController
Written By : Ranjith Punneli
Test Classes : N/A
*************************************************************************************/
@isTest
private class ConfigurationCloudPCControllerTest {
    @isTest(seealldata=true)
    static void intialTest() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        
        //Unit tests for ConfigurationCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.ConfigurationCloudPC')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);        
        ConfigurationCloudPCController objConfigCloudCont = new ConfigurationCloudPCController(); 
        
              
        for(List<Product2> list_Products : objConfigCloudCont.map_BuildingBlockToProducts.values()) {
            for(Integer i=0; i<(list_Products.size()>=5 ? 5 : list_Products.size()); i++) {
                list_Products[i].Quantity__c = 1;
                objConfigCloudCont.strProductIdForInfo = list_Products[i].Id;                
            }
            list_Products[list_Products.size()-1].Product_Name__c='10.0';
        }
        objConfigCloudCont.list_BundlesToBeSaved = [SELECT Id,Name,Quantity__c,Price__c,Additional_Discount__c,Discount__c,Product__r.product_group__c,Product__r.APN_Number__c,Product__r.Unit_of_Measure__c, Product__r.NG5_NA_USD_Price__c,Group_Type__c,Type__c, (SELECT Product__c,Product__r.Product_Specific_Discount__c,Product__r.APN_Number__c,Product__r.Building_Block__c,Product__r.NG5_NA_USD_Price__c,Product__r.Is_Concurrent__c,Product__r.Product_Manager_Approval_Group__r.Name,Product__r.Name,Product__r.Third_Party__c,Product__r.Third_Party_GC__c,Product__r.Unit_of_Measure__c,Quantity__c FROM Product_Group_Items__r Where Product__c != null AND Product_Type__c = 'Mandatory')FROM Product_Group__c Where Id in (Select Product_Group__c from Product_Group_Item__c where Product__c != null) 
                                                    AND Group_Type__c in ('Dependent Products','Use Case')
                                                    AND Active__c = true limit 3];
        objConfigCloudCont.list_BundlesToBeSaved.addAll([SELECT Id,Name,Quantity__c,Price__c,Additional_Discount__c,Discount__c,Product__r.product_group__c,Product__r.APN_Number__c,Product__r.Unit_of_Measure__c, Product__r.NG5_NA_USD_Price__c,Group_Type__c,Type__c,  (SELECT Product__c,Product__r.Product_Specific_Discount__c,Product__r.APN_Number__c,Product__r.Building_Block__c,Product__r.NG5_NA_USD_Price__c,Product__r.Is_Concurrent__c,Product__r.Product_Manager_Approval_Group__r.Name,Product__r.Name,Product__r.Third_Party__c,Product__r.Third_Party_GC__c,Product__r.Unit_of_Measure__c,Quantity__c FROM Product_Group_Items__r Where Product__c != null AND Product_Type__c = 'Mandatory')FROM Product_Group__c Where Id in (Select Product_Group__c from Product_Group_Item__c where Product__c != null) 
                                                         AND Group_Type__c  = 'Use Case'
                                                         AND Active__c = true limit 3]);
        objConfigCloudCont.list_UseCasesToBeSaved.addAll([SELECT Id,Name,Quantity__c,Price__c,Additional_Discount__c,Discount__c,Product__r.product_group__c,Product__r.APN_Number__c,Product__r.Unit_of_Measure__c, Product__r.NG5_NA_USD_Price__c,Group_Type__c,Type__c, (SELECT Product__c,Product__r.Product_Specific_Discount__c,Product__r.APN_Number__c,Product__r.Building_Block__c,Product__r.NG5_NA_USD_Price__c,Product__r.Is_Concurrent__c,Product__r.Product_Manager_Approval_Group__r.Name,Product__r.Name,Product__r.Third_Party__c,Product__r.Third_Party_GC__c,Product__r.Unit_of_Measure__c,Quantity__c FROM Product_Group_Items__r Where Product__c != null AND Product_Type__c = 'Mandatory')FROM Product_Group__c Where Id in (Select Product_Group__c from Product_Group_Item__c where Product__c != null) 
                                                         AND Group_Type__c  = 'Use Case'
                                                         AND Active__c = true limit 3]);
        for(Product_Group__c objGroup : objConfigCloudCont.list_BundlesToBeSaved) {
            objGroup.Quantity__c = 2;
        }
        objConfigCloudCont.addProductsBtnHandler(); 
        objConfigCloudCont.strProdIndex = '0';
        objConfigCloudCont.removeProduct();  
        
        objConfigCloudCont.bundleOptionHandler();
        for(List<Product_Group__c> list_Bundles : objConfigCloudCont.map_BundleTypeToBundles.values()) {
            for(Integer i=0; i<(list_Bundles.size()>=1 ? 1 : list_Bundles.size()); i++) {
                list_Bundles[i].Quantity__c = 1;            
            }
        }
        objConfigCloudCont.addBundlesBtnHandler();
        objConfigCloudCont.strProdIndex = '0';
        objConfigCloudCont.removeProductBundle();
		objConfigCloudCont.useCaseOptionHandler(); 
        objConfigCloudCont.addUseCasesHandler(); 
        objConfigCloudCont.removeUseCases();
        
        objConfigCloudCont.showProductInfo();
        objConfigCloudCont.hideProductInfo();
        objConfigCloudCont.showHideProducts();
        objConfigCloudCont.showHideCampaignsProducts();
        objConfigCloudCont.addCampaignssBtnHandler();
        objConfigCloudCont.CampaignsOptionHandler();
        objConfigCloudCont.removeProductBundle();
        
        objConfigCloudCont.guidedSellingOptionHandler();
        objConfigCloudCont.idFlowStepSelected = objConfigCloudCont.list_GuidedSellingFlows[0].Guided_Selling_Flow_Steps__r[0].Id;
        objConfigCloudCont.showGSFlowStepProducts();
        objConfigCloudCont.nextFlowStepBtnHandler();
        objConfigCloudCont.previousFlowStepBtnHandler();
        
        objConfigCloudCont.checkForRequiredConfirmations();
        objConfigCloudCont.confBoxCancel();
        objConfigCloudCont.confBoxProceed();
        //objConfigCloudCont.saveBtnHandler();
        
        objConfigCloudCont.productSearchOptionHandler(); 
        objConfigCloudCont.objSearchProduct.Name = 'PureCloud 1';        
        objConfigCloudCont.searchBtnHandler();
        objConfigCloudCont.list_SearchProducts[0].Quantity__c = 1;
        objConfigCloudCont.list_SearchProducts[0].Quantities_Available__c = '10.0';
        objConfigCloudCont.list_SearchProducts[0].Product_Name__c = '10.0';
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
        //objConfigCloudCont.showHideFavoriteItems();
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
		objConfigCloudCont.getUseCaseBundles('NG5_NA_USD_Price__c',objConfigCloudCont.list_BundlesToBeSaved);
        objConfigCloudCont.removeAllBtnHandler();
		objConfigCloudCont.addPureSuccessBtnHandler();
        objConfigCloudCont.removeAlaCarteItem();
        objConfigCloudCont.pureSuccessOptionHandler();
        objConfigCloudCont.removePureSuccessBundle();
        Set<Id> set_BundleIds = new Set<Id>();
        Map<Id,Product_Group__c> map_PSBunndles = new Map<Id,Product_Group__c>([select id from Product_Group__c where name like '%PureSuccess%' and Offering_Type__c = 'PureCloud']);
        set_BundleIds.addAll(map_PSBunndles.Keyset());
        objConfigCloudCont.getProductGroupQuery(set_BundleIds,'NG5_NA_USD_Price__c');
        objConfigCloudCont.saveBtnHandler();											  
    }
}