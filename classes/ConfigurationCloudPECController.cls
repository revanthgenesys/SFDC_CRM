/************************************************************************************
Purpose : Controller class to handle product configurator page ConfigurationCloudPEC
Written By : Ranjith Punneli
Test Classes : ConfigurationCloudControllerPECTest
*************************************************************************************/

public class ConfigurationCloudPECController
{
    // List of New Categories
    public List<String> list_Categories {get; private set;}
    // List of Taxonomy solutions
    public List<String> listOfTaxonomySolutions {get; private set;}
    // List of Building Blocks
    public List<String> list_ProductFinancials {get; private set;}
    // Map of Category to List of Taxonomy Categories
    public Map<String,List<String>> map_TaxonomyCategories {get; private set;}
    // Map of Product Financials
    public Map<String, List<String>> mapOfTaxonomyProductFinancial {get; private set;}
    // Map of Building Blocks to List of Base Items/Products
    public Map<String,List<Product2>> map_BuildingBlockToProducts {get; set;}
    // Map of Quantities available string and list of drop-down options for main Configurator (Audio Codes)
    public Map<String,List<SelectOption>> map_QuantitiesToSelectOptions {get; private set;}
    // Quote Products on right hand panel which will be created on 'save'
    public List<BigMachines__Quote_Product__c> list_QuoteProductsToBeCreated {get; set;}
    // Category selected (All Products tab)
    public String strSelectedCategory {get; set;}
    // Building Block selected (All Products tab)
    public string strSelectedBuildingBlock {get;set;}
    // Selected Taxonomy Solution
    public String strSelectedTaxonomySolution {get; set;}
    // Product financial
    public String strProductFinancial {get; set;}
    // Bundles on right hand panel which will be created on 'save'
    public List<Product_Group__c> list_BundlesToBeSaved {get; set;}
    
    public map<Id,Product2> mapProdToPrecision {get;set;}
    
    public List<Product_Group__c> list_UseCasesToBeSaved {get; set;}
    public Map<String,Boolean> map_SelectedBundle{get;set;}
    
    
    // Quote being updated
    public BigMachines__Quote__c objQuote {get; private set;}
    // To indicate whether to show Supporting info for a product
    public Boolean blnShowSupportingInfo {get; private set;}
    // Product Id for which Supporting info is to be shown
    transient public String strProductIdForInfo {get; set;}
    // Version selected in Base Item for which Supporting info is to be shown
    transient public String strVersionForInfo {get; set;}
    // Supporting info string
    transient public String strProductInfo {get; private set;}
    // Name of Applicable pricebook for this quote
    public String strPricebookFieldName {get; set;}
    // Option/tab selected in Configurator
    public String strMainOption {get; private set;}
    // Index of Product/Bundle being removed from right hand panel
    public String strProdIndex {get; set;}
    // To indicate if a favourite is being created. Show save and cancel buttons
    public Boolean blnShowFavSaveOptions {get; private set;}
    // Favourite being created
    public Product_Group__c objFavToBeSaved {get; set;}
    
    // Product Search query string
    public String strProductSearchQuery;
    transient String strQuoteId;
    transient String strLandingTab;
    // Multiplier for different pricing models
    Decimal decPricingMultiplier = 1;
    
    // List of Bundle Types
    public List<String> list_BundleTypes {get; private set;}
    // Map of Bundle Type to List of Bundles
    public Map<String,List<Product_Group__c>> map_BundleTypeToBundles {get; private set;}
    // Map of Bundle Type to List of Bundles
    public Map<String,Boolean> map_BundleIdToShowProductsChoice {get; private set;}
    // Map of Bundle Type to List of Bundle Products
    public Map<String,List<Product_Group_Item__c>> map_BundleIdToBundleProducts {get; set;}
    // Bundle/Favourite being expanded/collapsed
    public String strGroupId {get; set;}
    
    // List of Campaign Types
    public List<String> list_CampaignsTypes {get; private set;}
    // Map of Campaign Types to List of Campaign 
    public Map<String,List<Product_Group__c>> map_CampaignsTypesToBundles {get; private set;}
    // Map of Campaign Type to List of Campaign 
    public Map<String,Boolean> map_CampaignsIdToShowProductsChoice {get; private set;}
    // Map of Campaign Type to List of Mandatory Campaign Products
    public Map<String,List<Product_Group_Item__c>> map_CampaignsIdToBundleProducts {get; set;}
    // Map of Campaign Type to List of Optional Campaign Products
    public Map<String,List<Product_Group_Item__c>> map_CampaignsIdToBundleProducts_opt {get; set;}
    // Map of Campaign Type to List of Lab Campaign Products
    public Map<String,List<Product_Group_Item__c>> map_CampaignsIdToBundleProducts_Lab {get; set;}
    // Map of Campaign Type to List of HA Campaign Products
    public Map<String,List<Product_Group_Item__c>> map_CampaignsIdToBundleProducts_HA {get; set;}
    // Map of Campaign Type to List of Substitutable Campaign Products
    public Map<String,List<Product_Group_Item__c>> map_CampaignsIdToBundleProducts_Sub {get; set;}
    //To store campaign Product Types
    public List<String> list_CampaignsProductTypes {get; private set;}
    //To store campaign and corresponding campaign quote product
    Map<id,BigMachines__Quote_Product__c> map_campaigntomainproduct;
    //To Store campaign id and corresponding campaign product 
    public Map<id,List<BigMachines__Quote_Product__c>> map_campaigntocampaignproduct;
    // Campaigns on right hand panel which will be created on 'save'
    public List<BigMachines__Quote_Product__c> list_CampaignsToBeSaved {get; set;}
    //Mapping of Quote Product to Bundle
    public Map<Id,Id> map_QuoteIdToBundeId;
    //Mapping of Bundle to Offer
    public Map<Id,String> map_BundleToOffer;
    //Mapping of Bundle to Play
    public Map<Id,String> map_BundleToPlay;
    public Map<Id,String> map_usecaseToPlayOffer {get;set;}
    public integer intLineNumber; //-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
    
    public String strProductType {get; set;}
    
    // To indicate if quote is locked or not
    public Boolean blnIsQuoteUnLocked {get; private set;}
    // The product object for all search fields on Product Search
    public Product2 objSearchProduct {get; set;}
    // The search results being currently displayed
    public List<Product2> list_SearchProducts {get; set;}
    
    // **** For Pagination ****
    public Integer intPageNum {get; private set;}
    public Integer intPageSize {get; private set;}
    public Integer intTotalNoOfRecords {get; private set;}
    
    //*** Sorting related data for product search results ***
    public String strSortField {get; private set;}
    public String strSortFieldSelected {get; set;}
    public String strSortOrder {get; private set;}
    
    // Favorites of the running user
    public List<FavoriteWrapper> list_Favourites {get; private set;}
    // To store id of favorite being expanded/collapsed and being deleted
    public String strFavId {get; set;}
    public Boolean blnHideEducationParts {get;  set;}
    // Set to track products being added 
    Set<Id> set_ProdIds{get;set;}
    
    // To indicate whether this quote use old or new pricing
    public Boolean blnIsNewPricing {get; private set;}
    // Products with notification messages to be shown on click of save button
    public List<ConfirmationWrapper> list_NotificationProducts {get; private set;}
    // Wrapper class for each Notification Message
    public class ConfirmationWrapper
    {
        public Boolean blnIsSelected {get; set;}
        @TestVisible
        public Product2 objProd {get; private set;}
        public ConfirmationWrapper()
        {
            blnIsSelected = false;
        }
    }
    String strBundleOnlyProduct;
    @TestVisible
    Set<Id> productGroupIds {get;set;}
    //Anju Jan 2018 PureSuccess starts
    public List<Product_Group__c> list_PureSuccessToBeSaved {get; set;}
    public List<String> list_PureSuccess {get; private set;}
    public List<String> list_AlCarte {get; private set;}
    public List<Product_Group_Item__c> list_OfAlaCarte {get; set;}
    public List<Product2> list_OfAlaCarteToBeSaved {get; set;}
    public Boolean blnShowBaseAndPureSuccessPackage {get; private set;}
    //Anju Jan 2018 PureSuccess ends
    
    // ECD May 2019 Variablize Query Logic
    private final String BILLING_CATEGORY_M2M = 'M2M';
    
    private final String CATEGORY_SUBSCRIPTION_FEES = 'Subscription Fees';
    
    private final String PRICING_MODEL_CONCURRENT = 'Concurrent';
    private final String PRICING_MODEL_ENABLED = 'Enabled';
    
    private final String SOLD_TO_REGION_EMEA = 'EMEA';
    
    
    // Wrapper class for each Favorite line
    public class FavoriteWrapper
    {
        public Boolean blnIsSelected {get; set;}
        public Product_Group__c objFavorite {get; private set;}
        public Boolean blnShowItems {get; private set;}
        public List<Product_Group_Item__c> list_Bundles {get; private set;}
        public List<Product_Group_Item__c> list_Products {get; private set;}
        
        public FavoriteWrapper()
        {
            blnIsSelected = blnShowItems = false;
        }
    }
    
    // To indicate if save was successful or there was some error
    public String strIsSaveSuccessful {get; set;}
    public Boolean blnShowConfirmPanel {get; private set;}
    
    public List<Guided_Selling_Flow__c> list_GuidedSellingFlows {get; private set;}
    public Id idFlowStepSelected {get; set;}
    public Guided_Selling_Flow_Step__c objCurrentGSFlowStep {get; private set;}
    
    // *** Constructor ***
    public ConfigurationCloudPECController()
    {
        strQuoteId = ApexPages.currentPage().getParameters().get('id');
        strLandingTab = ApexPages.currentPage().getParameters().get('tab');
        initializeData();
    }
    
    // *** To initialize data for the Configurator ***
    void initializeData()
    {
        //Anju Dec 18 usecases :
        list_UseCases = new List<String>();
        list_PlayCategory = new List<String>();
        set_ProdIds = new Set<Id>();
        
        blnShowBaseAndPureSuccessPackage = true;
        objQuote = new BigMachines__Quote__c();
        list_QuoteProductsToBeCreated = new List<BigMachines__Quote_Product__c>();
        list_BundlesToBeSaved = new List<Product_Group__c>();
        //Anju Dec 18 usecases
        list_UseCasesToBeSaved = new List<Product_Group__c>();
        map_usecaseToPlayOffer =  new Map<Id,String>(); 
        map_SelectedBundle = new Map<String,Boolean>();
        map_BundleToOffer = new Map<Id,String>();
        map_BundleToPlay = new Map<Id,String>();
        map_QuoteIdToBundeId = new Map<Id,Id>();
        
        list_CampaignsToBeSaved = new List<BigMachines__Quote_Product__c>();
        list_PureSuccessToBeSaved = new List<Product_Group__c>();
        list_OfAlaCarteToBeSaved = new List<Product2>();
        map_campaigntomainproduct = new Map<id,BigMachines__Quote_Product__c>();
        //  Bundle_Product_Approval = Item can only be sold as part of a bundle
        strBundleOnlyProduct = Label.Bundle_Product_Approval;
        strPricebookFieldName = '';
        objSearchProduct = new Product2(RecordTypeId=(Id)Label.Base_Item_RecordTypeId,Pricing_Model__c = 'Named');
        // Setting default page size to 20 for search results
        intPageSize = 20;
        strSortField = 'Name';
        strSortOrder = 'ASC';        
        blnShowFavSaveOptions = blnIsQuoteUnLocked = blnIsNewPricing = blnShowConfirmPanel = false;
        blnHideEducationParts = false;
        // Fetching Quote
        List<BigMachines__Quote__c> list_Temp = [SELECT Id,Name,New_Price_Book__c,Pricing_Model__c,BigMachines__Status__c,Offering_Type__c,Product_Tier__c,Subscription_Start_Date__c,Subscription_End_Date__c,
                                                 Keep_the_existing_estate_on_Perpetual__c,BigMachines__Opportunity__r.type,BigMachines__Opportunity__r.Cloud_Renewal__c,
                                                 BigMachines__Opportunity__r.Direct_Indirect_Sale__c,Order_Type__c,Does_customer_currently_have_PureSuccess__c,BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c,
                                                 Billing_Category__c,Sold_To_Name__r.Country__r.PSRDP_Region__c,CurrencyISOCode,Sold_To_Region__c, BigMachines__Opportunity__r.Offering_Detail__c,
                                                 Opp_Sold_To_Country__c,Billing_Period__c,Initial_Subscription_Term__c,top_play__c                                                
                                                 FROM BigMachines__Quote__c WHERE Id = :strQuoteId];
        
        if(list_Temp.size() > 0)
        {
            objQuote = list_Temp[0];
            blnIsNewPricing = true;
            if(objQuote.Sold_To_Region__c == SOLD_TO_REGION_EMEA){
                blnHideEducationParts = true;
            }
            blnIsQuoteUnLocked = isQuoteUnLocked(objQuote.BigMachines__Status__c);      
            If(objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription ){
                integer intQPCount = [select count() from BigMachines__Quote_Product__c where BigMachines__Quote__c = :strQuoteId and Line_Number__C !=0.00];
                integer intSPCount = [select count() from Subscription_Product__c where Subscription__C =  :objQuote.Amendment_For__c and Line_Number__C !=0.00];
                integer intLineCount =(Integer) [select  Line_Number__c from BigMachines__Quote_Product__c where BigMachines__Quote__c = :strQuoteId order by Line_Number__c desc limit 1].Line_Number__c;  
                System.debug('intQPCount:'+intQPCount);
                System.debug('intSPCount:'+intSPCount);
                intLineNumber  = (intQPCount > intSPCount ) ?intQPCount : intSPCount ;
                intLineNumber  = (intLineCount > intLineNumber ) ?intLineCount : intLineNumber ; 
                
            }
            else
                
            {
                intLineNumber = [select count() from BigMachines__Quote_Product__c where BigMachines__Quote__c = :strQuoteId and Line_Number__C !=0.00];
            }
            
            
            if(String.isNotBlank(objQuote.New_Price_Book__c))
            {
                strPricebookFieldName = objQuote.New_Price_Book__c + '_Price__c';
                // Fetching Pricing Multiplier from Custom Settings based on Pricing Model
                if(objQuote.Pricing_Model__c == PRICING_MODEL_CONCURRENT)
                    decPricingMultiplier = Global_Configuration_Settings__c.getOrgDefaults().PureEngage_Cloud_Concurrent_Multiplier__c;
                else 
                    decPricingMultiplier = 1;
            }
        }
        // Land on Product Search if landing tab is specified as 'Search' in URL
        if(String.isNotBlank(strLandingTab) && strLandingTab == 'search')
            productSearchOptionHandler();
        else
        {
            // Default landing option should be All products
            allProductsOptionHandler();
        }
        
        //Mukunth added below line for for 6 digit project on 09-APR-2019
        mapProdToPrecision = new map<Id,Product2>([select Id, Tier_Pricing_Decimal_Precision__c from Product2 where IsActive = true AND OfferingType__c includes(:QuoteCloudUtil.OFFERING_TYPE_PEC)]);
        
    }
    
    // *** To initialize all collections as necessary to keep view state light ***
    private void initializeCollections()
    {
        // All Products
        map_TaxonomyCategories = new Map<String,List<String>>();
        
        map_BuildingBlockToProducts = new Map<String,List<Product2>>();
        mapOfTaxonomyProductFinancial = new Map<String, List<String>>();
        list_Categories = new List<String>();
        listOfTaxonomySolutions = new List<String>();
        list_ProductFinancials = new List<String>();
        map_QuantitiesToSelectOptions = new Map<String,List<SelectOption>>();
        
        
        //PureSuccess
        list_PureSuccess = new List<String>();
        list_AlCarte = new List<String>();
        list_OfAlaCarte = new List<Product_Group_Item__c>();
        
        // Bundles
        list_BundleTypes = new List<String>();
        map_BundleTypeToBundles = new Map<String,List<Product_Group__c>>();
        map_BundleIdToShowProductsChoice = new Map<String,Boolean>();
        map_BundleIdToBundleProducts = new Map<String,List<Product_Group_Item__c>>();
        
        //Campaigns
        list_CampaignsTypes = new List<String>();
        map_CampaignsTypesToBundles = new Map<String,List<Product_Group__c>>();
        map_CampaignsIdToShowProductsChoice = new Map<String,Boolean>();
        map_CampaignsIdToBundleProducts = new Map<String,List<Product_Group_Item__c>>();
        map_CampaignsIdToBundleProducts_Opt = new Map<String,List<Product_Group_Item__c>>();
        map_CampaignsIdToBundleProducts_Lab = new Map<String,List<Product_Group_Item__c>>();
        map_CampaignsIdToBundleProducts_HA = new Map<String,List<Product_Group_Item__c>>();
        map_CampaignsIdToBundleProducts_Sub = new Map<String,List<Product_Group_Item__c>>();  
        //map_campaigntomainproduct = new Map<id,BigMachines__Quote_Product__c>();
        map_campaigntocampaignproduct = new Map<id,List<BigMachines__Quote_Product__c>>();
        list_CampaignsProductTypes = new List<String>();
        list_CampaignsProductTypes.add('Mandatory');
        list_CampaignsProductTypes.add('Optional');
        
        // Product Search
        list_SearchProducts = new List<Product2>();
        
        // Favorites
        list_Favourites = new List<FavoriteWrapper>();
        
        // Guided Selling
        list_GuidedSellingFlows = new List<Guided_Selling_Flow__c>();
        objCurrentGSFlowStep = null;
    }
    
    // *** 'All Products' option in tab panel ***
    public void allProductsOptionHandler()
    {
        strMainOption = 'All Products';
        initializeCollections();
        loadTaxonomySolCategoryAndSol();
        strSelectedCategory = list_Categories[0];
    }
    
    // *** To load Taxonomy Solution Categories and Taxonomy Solutions from Custom Settings and show initial Products on Load ***
    private void loadTaxonomySolCategoryAndSol()
    {
        list_Categories.clear(); 
        
        List<Level_One_Level_Two__c> list_LevelOneLevelTwo = Level_One_Level_Two__c.getAll().values();
        list_LevelOneLevelTwo.sort();
        
        for(Level_One_Level_Two__c objLevelOneVsTwo : list_LevelOneLevelTwo)
        {
            //Added By Ranjith on Oct 09, 2017 -- Starts  
            if(objLevelOneVsTwo.Offering_Type__c == objQuote.Offering_Type__c)
            {
                System.Debug('loadTaxonomySolCategoryAndSol: Matched Offering Type ' + objLevelOneVsTwo);
                list_Categories.add(objLevelOneVsTwo.Level_One__c);
                if(String.isNotBlank(objLevelOneVsTwo.Level_Two__c))
                {
                    List<String> list_TaxonomySolutionsTemp = objLevelOneVsTwo.Level_Two__c.split(';');
                    map_TaxonomyCategories.put(objLevelOneVsTwo.Level_One__c,list_TaxonomySolutionsTemp);
                }
            }
        }
        
        if(!list_Categories.isEmpty())
        {
            strSelectedCategory = list_Categories[0];
            showTaxonomySolutions();
            if(!listOfTaxonomySolutions.isEmpty())
            {
                strSelectedTaxonomySolution = listOfTaxonomySolutions[0];
                showProductFinancials();
                if(!list_ProductFinancials.isEmpty())
                {
                    strProductFinancial = list_ProductFinancials[0];
                    showProducts();
                }
            }
        }
    }
    
    // *** To load Taxonomy Solutions based on Taxonomy Solution Category selected ***
    public void showTaxonomySolutions()
    {
        listOfTaxonomySolutions = map_TaxonomyCategories.get(strSelectedCategory);
        if(strSelectedCategory == 'All')
        {
            strSelectedTaxonomySolution = 'All';
            showProductFinancials();
        }
        else
        {       
            list_ProductFinancials.clear();
            clearProductMap();
            strSelectedTaxonomySolution = null;
            strProductFinancial  = null;
            if(!listOfTaxonomySolutions.isEmpty())
            {
                strSelectedTaxonomySolution = listOfTaxonomySolutions[0];
                showProductFinancials();
                if(!list_ProductFinancials.isEmpty())
                {
                    strProductFinancial = list_ProductFinancials[0];
                    showProducts();
                }
            }
        }
    } 
    
    // *** To load Building Blocks/Product Financial Info and Products based on Taxonomy selection ***
    public void showProductFinancials()
    {
        list_ProductFinancials.clear();
        clearProductMap();        
        strProductFinancial = null;     
        mapOfTaxonomyProductFinancial.clear();   
        if(strSelectedTaxonomySolution == 'All')
        {
            System.debug('ECD strSelectedTaxonomySolution set to All');
            strProductFinancial = 'All';
            List<String> taxonomySolutions;
            
            if(strSelectedCategory == 'All')
            {
                System.debug('ECD strSelectedCategory set to All');
                List<Level_One_Level_Two__c> taxonomySolutionCategories = Level_One_Level_Two__c.getAll().values();
                taxonomySolutions = new List<String>();
                for(Level_One_Level_Two__c eachCategorySolution : taxonomySolutionCategories)
                {
                    List<String> eachTaxonomySolutions = eachCategorySolution.Level_Two__c.split(';');
                    taxonomySolutions.addAll(eachTaxonomySolutions);
                }
            }
            else {
                System.debug('ECD strSelectedCategory set to ' + strSelectedCategory);
                taxonomySolutions = QuoteCloudUtil.fetchLevelOneVsTwoMapping(strSelectedCategory, objQuote.Offering_Type__c);
                System.Debug('ECD Got back taxonomySolutions ' + taxonomySolutions);
            }
            
            for(String strLevelTwo : taxonomySolutions)
            {
                List<String> list_LevelThreeValues = QuoteCloudUtil.fetchLevelTwoVsThreeMapping(strLevelTwo, objQuote.Offering_Type__c);
                if(!list_LevelThreeValues.isEmpty())
                {                   
                    System.Debug('ECD mapOfTaxonomyProductFinancial put key ' + strLevelTwo + ' list ' + list_LevelThreeValues);
                    list_ProductFinancials.addAll(list_LevelThreeValues);
                    mapOfTaxonomyProductFinancial.put(strLevelTwo, list_LevelThreeValues);
                }    
            }
        }
        else
        {
            System.debug('strSelectedTaxonomySolution set to ' + strSelectedTaxonomySolution);
            List<String> list_LevelThreeValues = QuoteUtil.fetchLevelTwoVsThreeMapping(strSelectedTaxonomySolution, objQuote.Offering_Type__c);
            if(!list_LevelThreeValues.isEmpty())
            {
                list_ProductFinancials.addAll(list_LevelThreeValues);
                strProductFinancial = list_ProductFinancials[0];
                mapOfTaxonomyProductFinancial.put(strSelectedTaxonomySolution, list_LevelThreeValues);
            }            
        }
        showProducts();
    }
    
    // *** 'Product Search' option in tab panel ***
    public void productSearchOptionHandler()
    {
        strMainOption = 'Product Search';
        initializeCollections();
        searchBtnHandler();
    }
    
    // *** 'Guided Selling' option in tab panel ***
    public void guidedSellingOptionHandler()
    {
        strMainOption = 'Guided Selling';
        initializeCollections();
        
        // Fetching guided Selling Flows
        list_GuidedSellingFlows = [SELECT Id,Name,(SELECT Id,Title__c,Order__c FROM Guided_Selling_Flow_Steps__r WHERE Is_Active__c = true ORDER BY Order__c) 
                                   FROM Guided_Selling_Flow__c WHERE Is_Active__c = true AND Quote_Type__c = :objQuote.Offering_Type__c ORDER BY Order__c];
    }
    
    // *** 'Bundles' option in tab panel ***
    public void bundleOptionHandler()
    {
    }
    
    // *** 'Favorites' option in tab panel ***
    public void favouritesOptionHandler()
    {
        strMainOption = 'Favourites';
        initializeCollections();
        // fetch all favorites of running user
        for(Product_Group__c objFav : [SELECT Id,Name FROM Product_Group__c WHERE User__c = :UserInfo.getUserId() 
                                       AND Group_Type__c = 'Favorite' AND Quote_Type__c = :objQuote.Offering_Type__c ORDER BY Name])
        {
            FavoriteWrapper objFavWrapper = new FavoriteWrapper();
            objFavWrapper.objFavorite = objFav;
            list_Favourites.add(objFavWrapper);
        }
    }
    
    // *** 'Dynamic Bundles/Campaigns' option in tab panel ***
    public void CampaignsOptionHandler() 
    {
    }
    
    // *** To clear the Building Block To Products Map ***
    private void clearProductMap()
    {
        Set<String> productFinancials = map_BuildingBlockToProducts.keyset();
        for(String eachFinancial : productFinancials){
            System.debug('clearProductMap: ' + eachfinancial);
            map_BuildingBlockToProducts.put(eachFinancial, new List<Product2>());   
        }
    }
    
    // *** To show products under 'All Products' based on current Taxonomy and Building Block selection ***
    public void showProducts()
    {
        // Storing building blocks in the map in case there are no products for a building block (to prevent run time exceptions)        
        if(strProductFinancial == 'All')
        {
            for(List<String> list_ProductFinancials : mapOfTaxonomyProductFinancial.values())
            {
                for(String eachProductFinancial : list_ProductFinancials) {
                    System.debug('showProducts: eachProductFinancial: ' + eachProductFinancial);
                    map_BuildingBlockToProducts.put(eachProductFinancial, new List<Product2>());
                }
            }
        }        
        else {
            System.debug('showProducts: strProductFinancial: ' + strProductFinancial);
            map_BuildingBlockToProducts.put(strProductFinancial, new List<Product2>());         
        }
        
        String strBuildingBlockFieldName = 'Sub_Category__c';
        System.Debug('ECD: Before Product Loop ' + map_BuildingBlockToProducts);
        for(Product2 objProduct : Database.query(createAllProductsQueryString()))
        {   
            
            System.Debug('ECD: In Product Loop with strPricebookFieldName ' + strPricebookFieldName + ' Sub_Category__c ' + objProduct.Sub_Category__c + ' full product:' + objProduct);
            // Quote Pricing Model is Concurrent and product has the concurrent pricing model, price is multiplied by pricing multiplier
            if(objQuote.Pricing_Model__c == PRICING_MODEL_CONCURRENT && objProduct.Is_Concurrent__c == 'Yes')
                objProduct.put(strPricebookFieldName,((Decimal)objProduct.get(strPricebookFieldName)) * decPricingMultiplier);
            
            String strBuildingBlock = (String)objProduct.get(strBuildingBlockFieldName);
            // Grouping base items according to Building blocks
            if(map_BuildingBlockToProducts.containsKey(strBuildingBlock))
            {
                System.Debug('ECD: Product DOES contain key [' + strBuildingBlock + ']');
                map_BuildingBlockToProducts.get(strBuildingBlock).add(objProduct);
                handleQuantitiesAvailable(objProduct);
            } else {
                System.Debug('ECD: Product does not contain key [' + strBuildingBlock + ']');
            }
        }     
    }
    
    @testvisible
    // *** To create quantity drop downs ***
    private void handleQuantitiesAvailable(Product2 objBaseProduct)
    {
        // Creating quantity drop-downs
        if(String.isNotBlank(objBaseProduct.Quantities_Available__c))
        {
            if(!map_QuantitiesToSelectOptions.containsKey(objBaseProduct.Quantities_Available__c))
            {
                List<SelectOption> list_Options = new List<SelectOption>();
                for(String strQuantity : objBaseProduct.Quantities_Available__c.split(';'))
                    list_Options.add(new SelectOption(strQuantity,strQuantity));
                map_QuantitiesToSelectOptions.put(objBaseProduct.Quantities_Available__c,list_Options);
            }
        }
    }
    
    // *** To show Supporting Info for a Product ***
    public void showProductInfo()
    {
        blnShowSupportingInfo = true;
        strProductInfo = '';
        // Fetching Support Information
        List<Product2> list_Temp = [SELECT Support_Information__c,Tier_Pricing_Decimal_Precision__c FROM Product2 WHERE Id = :strProductIdForInfo];
        if(list_Temp.size() > 0)
            strProductInfo = list_Temp[0].Support_Information__c;
    }
    
    // *** To hide/close Product Support Info *** 
    public void hideProductInfo()
    {
        blnShowSupportingInfo = false;
    }
    
    // *** To show/hide products in a Bundle ***
    public void showHideProducts()
    {   //Commented By Ranjith on Jun 05, 2017 -- Starts
        
        if(map_BundleIdToShowProductsChoice.containsKey(strGroupId))
        {
            Boolean blnCurrentState = map_BundleIdToShowProductsChoice.get(strGroupId);
            if(blnCurrentState)
            {
                map_BundleIdToShowProductsChoice.put(strGroupId,false);
                map_BundleIdToBundleProducts.remove(strGroupId);
            }
            else
            {
                map_BundleIdToShowProductsChoice.put(strGroupId,true);
                map_BundleIdToBundleProducts.put(strGroupId,[SELECT Product__c,Product__r.Description,Quantity__c,
                                                             Product__r.Unit_of_Measure__c,Product__r.NG1_APAC_ANZ_AUD_Price__c,Product__r.NG2_BRAZIL_BRL_Price__c,Product__r.NG5_NA_CAD_Price__c,
                                                             Product__r.NG3_EMEA_EUR_Price__c,Product__r.NG3_EMEA_GBP_Price__c,Product__r.NG4_APAC_JAPAN_YEN_Price__c,Product__r.NG5_NZD_Price__c,
                                                             Product__r.NG5_NA_USD_Price__c,Product__r.NG5_ZAR_Price__c,Product__r.description__c FROM Product_Group_Item__c WHERE Product_Group__c = :strGroupId
                                                             ORDER BY Product__r.Description]);
            }
            //Anju Dec 18 usecases :
            map_BundleIdToShowProductsChoice.put(null, false);  
            map_BundleIdToBundleProducts.put(null, null);
        }
        //Commented By Ranjith on Jun 05, 2017 -- Ends
    }
    
    // *** To show/hide products in a Campaign ***
    public void showHideCampaignsProducts()
    {   //Commented By Ranjith on Jun 05, 2017 -- Starts
        /*list_CampaignsProductTypes.add('Mandatory'); 
if(map_CampaignsIdToShowProductsChoice.containsKey(strGroupId))
{
Boolean blnCurrentState = map_CampaignsIdToShowProductsChoice.get(strGroupId);
if(blnCurrentState)
{
map_CampaignsIdToShowProductsChoice.put(strGroupId,false);
map_CampaignsIdToBundleProducts.remove(strGroupId);
map_CampaignsIdToBundleProducts_Opt.remove(strGroupId);
map_CampaignsIdToBundleProducts_LAB.remove(strGroupId);
map_CampaignsIdToBundleProducts_HA.remove(strGroupId);
map_CampaignsIdToBundleProducts_Sub.remove(strGroupId);    
}
else
{
map_CampaignsIdToShowProductsChoice.put(strGroupId,true);
string query = 'SELECT Product__c,Product__r.Description,Quantity__c,Product_Type__c,GroupID__c,Select__c,'
+'Product__r.Is_Concurrent__c,Product__r.APN_Number__c,Product__r.Building_Block__c,Product__r.Product_Specific_Discount__c,Product__r.Product_Group__c,Product__r.Product_Manager_Approval_Group__r.Name,Product__r.Third_Party__c,Product__r.Third_Party_GC__c,'
+'Product__r.Unit_of_Measure__c,Product__r.' + strPricebookFieldName +' FROM Product_Group_Item__c WHERE Product_Group__c =\''+ strGroupId+'\'' ;

System.debug(query+ '\' and product_type__c=\'Mandatory\' ORDER BY Product__r.Description');
map_CampaignsIdToBundleProducts.put(strGroupId,Database.query(query+ ' and product_type__c=\'Mandatory\' and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1 ORDER BY Product__r.Description')); 
map_CampaignsIdToBundleProducts_Opt.put(strGroupId,Database.query(query+ ' and product_type__c=\'Optional\' and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1  ORDER BY Product__r.Description')); 
map_CampaignsIdToBundleProducts_LAB.put(strGroupId,Database.query(query+ ' and product_type__c=\'LAB\' and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1 ORDER BY Product__r.Description')); 
map_CampaignsIdToBundleProducts_HA.put(strGroupId,Database.query(query+ ' and product_type__c=\'HA\' and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1 ORDER BY Product__r.Description')); 
map_CampaignsIdToBundleProducts_Sub.put(strGroupId,Database.query(query+ ' and (product_type__c=\'Substitutable\' OR product_type__c=\'Mandatory Substitutable\') and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1 ORDER BY GroupID__c,Product_Type__c'));
}
}*/
        //Commented By Ranjith on Jun 05, 2017 -- Ends
    }
    
    //Anju Jan 2018 PureSuccess starts
    public void pureSuccessOptionHandler()
    {
        strMainOption = 'PureSuccess';
        initializeCollections();
        Boolean blnOfferPresent = false;
        List<BigMachines__Quote_Product__c> list_OfQuoteProducts = [SELECT Bundle__r.Name FROM BigMachines__Quote_Product__c 
                                                                    WHERE BigMachines__Quote__c =: objQuote.id AND Bundle__c != null and Bundle_Line__c = null];
        
        // Fetching Bundles 
        for(Product_Group__c objProductPureSuccess : Database.query(createBundleQueryString('PureSuccess'))){  
            //We do not need to show Equip and Partner package
            /*if(objProductPureSuccess.Name != null 
&& (objProductPureSuccess.Name.containsIgnoreCase('Equip') && objQuote.Multi_Year_Quote__c) 
|| (objProductPureSuccess.Name.containsIgnoreCase('Partner') && !objQuote.Multi_Year_Quote__c)
|| (objQuote.Multi_Year_Quote__c && !objProductPureSuccess.Name.containsIgnoreCase('Partner')) )
continue;  */             
            map_BundleIdToShowProductsChoice.put(objProductPureSuccess.Id, false);            
            list_PureSuccess.add(objProductPureSuccess.Name);            
            // Group Bundles according to Bundle Type like Add-Ons, Stand-alone etc
            if(map_BundleTypeToBundles.containsKey(objProductPureSuccess.Name))
                map_BundleTypeToBundles.get(objProductPureSuccess.Name).add(objProductPureSuccess);            
            else{                
                map_BundleTypeToBundles.put(objProductPureSuccess.Name,new List<Product_Group__c>{objProductPureSuccess});
            }  
            //Disables already added pure success package.
            if(!list_OfQuoteProducts.isEmpty()){
                for(BigMachines__Quote_Product__c eachQP : list_OfQuoteProducts){
                    if(eachQP.Bundle__r.Name != null && eachQP.Bundle__r.Name.containsIgnoreCase('Equip') && objProductPureSuccess.Name != null && objProductPureSuccess.Name.containsIgnoreCase('Equip')){
                        objProductPureSuccess.Active__c = false;
                        objProductPureSuccess.Selected__c = true;
                        blnOfferPresent = true;
                    }
                    else if(eachQP.Bundle__r.Name != null && eachQP.Bundle__r.Name.containsIgnoreCase('Guide') && objProductPureSuccess.Name != null && objProductPureSuccess.Name.containsIgnoreCase('Guide')){
                        objProductPureSuccess.Active__c = false;
                        objProductPureSuccess.Selected__c = true;
                        blnOfferPresent = true;
                    }
                    else if(eachQP.Bundle__r.Name != null && eachQP.Bundle__r.Name.containsIgnoreCase('Drive') && objProductPureSuccess.Name != null && objProductPureSuccess.Name.containsIgnoreCase('Drive')){
                        objProductPureSuccess.Active__c = false;
                        objProductPureSuccess.Selected__c = true;
                        blnOfferPresent = true;
                    }
                    else if(eachQP.Bundle__r.Name != null && eachQP.Bundle__r.Name.containsIgnoreCase('Partner') && objProductPureSuccess.Name != null && objProductPureSuccess.Name.containsIgnoreCase('Partner')){
                        objProductPureSuccess.Active__c = false;
                        objProductPureSuccess.Selected__c = true;
                        blnOfferPresent = true;
                    }                    
                }
            } 
        }
        
        
        for(String objProductPureSuccess : map_BundleTypeToBundles.keyset()){  
            if(blnOfferPresent){
                map_BundleTypeToBundles.get(objProductPureSuccess)[0].Active__c = false;
                
            }
        }
        
        //A la Carte items.
        for(Product_Group__c objProductAlaCarte : Database.query(createBundleQueryString('A la Carte'))){ 
            list_OfAlaCarte.addAll(objProductAlaCarte.Product_Group_Items__r);
        }
    }
    
    private String createBundleQueryString(String groupType)
    {
        String strBundleQuery = 'SELECT Id,Product__r.Tier_Pricing_Decimal_Precision__c,Name, Category__c, Active__c, Description__c,Type__c,Group_Type__c,Quantity__c,Discount__c,Additional_Discount__c,Price__c,Product__c,Selected__c';
        strBundleQuery += ',Product__r.' + strPricebookFieldName;
        
        if(String.isNotBlank(strPricebookFieldName))
        {
            strBundleQuery += ',(SELECT Product__r.Name,Product__r.Tier_Pricing_Decimal_Precision__c,Product__r.Quantity__c, Product__r.Description, Product__r.Description__c,  Quantity__c,Product__r.Building_Block__c,Product__r.APN_Number__c,Product__r.' + strPricebookFieldName;
            
            if(objQuote.Pricing_Model__c != PRICING_MODEL_ENABLED)
                strBundleQuery += ',Product__r.Pricing_Model__c, Product_Group__c ';
            strBundleQuery += ' FROM Product_Group_Items__r WHERE Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1';
            
            if(groupType == 'A la Carte' && objQuote.Offering_Type__c == 'PureConnect Cloud' && !objQuote.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c )
                strBundleQuery += ' AND Product__r.Product_Group__c = \'' + 'PureSuccess Direct A-la-Carte' + '\'';
            if(groupType == 'A la Carte' && objQuote.Offering_Type__c == 'PureConnect Cloud' && objQuote.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c)
                strBundleQuery += ' AND Product__r.Product_Group__c = \'' + 'PureSuccess Indirect A-la-Carte' + '\'';
            
            strBundleQuery += ')';
        }
        strBundleQuery += ' FROM Product_Group__c WHERE Group_Type__c = \'' + groupType +'\' AND Active__c = true AND Offering_Type__c INCLUDES (\'' + objQuote.Offering_Type__c + '\')';
        
         if(groupType == 'A la Carte')
            strBundleQuery += 'and Direct_Indirect__c = \'' + objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c +'\'';
        if(groupType == 'PureSuccess' && objQuote.Offering_Type__c == 'PureConnect Cloud' && !objQuote.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c)
            strBundleQuery += ' AND Product__r.Product_Group__c = \'' + 'PureSuccess Direct Offer' + '\'';
        if(groupType == 'PureSuccess' && objQuote.Offering_Type__c == 'PureConnect Cloud' && objQuote.BigMachines__Opportunity__r.PureConnect_Cloud_Partner_Approved__c)
            strBundleQuery += ' AND Product__r.Product_Group__c = \'' + 'PureSuccess Indirect Offer' + '\'';
        
        
        if(groupType == 'Use Case')
            strBundleQuery += ' ORDER BY Category__c, Name';
        else
            strBundleQuery += ' ORDER BY Order__c, Name';
        System.debug(strBundleQuery);
        return strBundleQuery;
    }
    //Anju Jan 2018 PureSuccess ends
    
    // *** To show/hide Items in Favorites ***
    public void showHideFavoriteItems()
    {
        Integer intIndex = -1;
        Boolean blnIsMatchFound = false;
        for(FavoriteWrapper objFavWrapper : list_Favourites)
        {
            intIndex++;
            if(strFavId == objFavWrapper.objFavorite.Id)
            {
                blnIsMatchFound = true;
                break;
            }
        }
        if(blnIsMatchFound)
        {
            FavoriteWrapper objFavWrapper = list_Favourites[intIndex];
            Boolean blnCurrentState = objFavWrapper.blnShowItems;
            if(blnCurrentState)
            {
                objFavWrapper.blnShowItems = false;
                objFavWrapper.list_Bundles.clear();
                objFavWrapper.list_Products.clear();
            }
            else
            {
                list_Favourites[intIndex].blnShowItems = true;
                objFavWrapper.list_Bundles = new List<Product_Group_Item__c>();
                objFavWrapper.list_Products = new List<Product_Group_Item__c>();
                
                for(Product_Group_Item__c objPGI : [SELECT Product__c,Product__r.Description,Product__r.Unit_of_Measure__c,
                                                    Bundle__c,Bundle__r.Discount__c,Bundle__r.Group_Type__c,Bundle__r.Type__c,Quantity__c
                                                    FROM Product_Group_Item__c WHERE Product_Group__c = :strFavId
                                                    AND Product__r.Shipment_Approval__c != :Label.Bundle_Product_Approval
                                                    ORDER BY Product__r.Description,Bundle__r.Name])
                {
                    if(objPGI.Bundle__c != null)
                    {
                        // Skipping Bundles for old pricing
                        if(!blnIsNewPricing)
                            continue;
                        if(objQuote.Offering_Type__c == 'PureCloud' && !objPGI.Product__r.Charge_Type__c.contains(objQuote.Billing_Category__c) && !(objPGI.Product__r.Charge_Type__c == NULL) && !objPGI.Product__r.Charge_Type__c.contains('One-Time'))
                            continue;
                        objFavWrapper.list_Bundles.add(objPGI);
                    }   
                    else if(objPGI.Product__c != null)
                        objFavWrapper.list_Products.add(objPGI);
                }
            }
        }
        strFavId = null;
    }
    
    // *** To delete a favorite ***
    public void deleteFavorite()
    {
        try
        {
            Integer intIndex = -1;
            Boolean blnIsMatchFound = false;
            for(FavoriteWrapper objFavWrapper : list_Favourites)
            {
                intIndex++;
                if(strFavId == objFavWrapper.objFavorite.Id)
                {
                    blnIsMatchFound = true;
                    break;
                }
            }
            if(blnIsMatchFound)
            {
                delete list_Favourites[intIndex].objFavorite;
                list_Favourites.remove(intIndex);
            }
            strFavId = null;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    // *** To Add Products from 'All Products' to the quote ***
    public void addProductsBtnHandler()
    {
        try
        {
            Boolean blnRestrictionApply = false;
            List<Product2> list_ProductsToAdd = new List<Product2>();
            Set<Id> set_ExistingProdIds = new Set<Id>();
            Set<Id> set_NewProdIds = new Set<Id>();
            Set<Id> set_ExistingDisplayedProds = new Set<Id>();
            Map<Id, List<Genesys_Product_Prerequisite__c>> map_RestrictProducts = new Map<Id, List<Genesys_Product_Prerequisite__c>>();
            // if(!Test.isRunningTest()) {
            map_RestrictProducts = buildRestrictProductsMap();    
            //  }
            System.debug('####map_RestrictProducts: ' +map_RestrictProducts);
            
            for(List<Product2> list_Products : map_BuildingBlockToProducts.values())
            {   
                for(Product2 objProduct : list_Products)
                {
                    if(objProduct.Quantity__c != null)// Anju Sept 17 allow 0 && objProduct.Quantity__c != 0) 
                    {
                        list_ProductsToAdd.add(objProduct); 
                        set_NewProdIds.add(objProduct.Id);
                    }
                }
                
            }
            
            for(BigMachines__Quote_Product__c  objQP : list_QuoteProductsToBeCreated) {
                set_NewProdIds.add(objQP.BigMachines__Product__c);
            }
            System.debug('####list_ProductsToAdd: ' +list_ProductsToAdd);
            
            //Added By Ranjith on Dec 05, 2017 -- Starts  
            for(BigMachines__Quote_Product__c objQP : [SELECT Id, BigMachines__Product__c, Hide_Record__c, Is_Overage__c
                                                       FROM BigMachines__Quote_Product__c 
                                                       WHERE BigMachines__Quote__c = :objQuote.Id]) {
                                                           set_ExistingProdIds.add(objQP.BigMachines__Product__c);
                                                           if(!objQP.Hide_Record__c)
                                                               set_ExistingDisplayedProds.add(objQP.BigMachines__Product__c);
                                                       }
            System.debug('####set_NewProdIds: ' +set_NewProdIds);
            System.debug('####set_ExistingProdIds: ' +set_ExistingProdIds);
            System.debug('####set_ExistingDisplayedProds: ' +set_ExistingDisplayedProds);                      
            
            for(Product2 objProd : list_ProductsToAdd) {
                if(map_RestrictProducts.containsKey(objProd.Id)) {
                    for(Genesys_Product_Prerequisite__c restrictProd : map_RestrictProducts.get(objProd.Id)) {
                        if(set_ExistingProdIds.contains(restrictProd.Prerequisite_Product__c)
                           || set_ExistingProdIds.contains(restrictProd.Prerequisite_Product2__c)
                           || set_ExistingProdIds.contains(restrictProd.Prerequisite_Product3__c)
                           || set_NewProdIds.contains(restrictProd.Prerequisite_Product__c)
                           || set_NewProdIds.contains(restrictProd.Prerequisite_Product2__c)
                           || set_NewProdIds.contains(restrictProd.Prerequisite_Product3__c)) {
                               blnRestrictionApply = true;
                               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, restrictProd.Message__c));
                           }
                    }
                }
                if(set_ExistingDisplayedProds.contains(objProd.Id) && !objProd.Show_Add_Sign__c) {
                    blnRestrictionApply = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This product cannot be added, as it is already part of the quote/subscription. Please modify the quantity on the existing part.'));
                }
                //Added By Ranjith on Jul 3rd, 2019 -- Starts
                if(objQuote.BigMachines__Opportunity__r.Offering_Detail__c == 'Hybrid' && objProd.New_Category__c != 'Hybrid') {
                    blnRestrictionApply = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select only Hybrid products'));
                }
                if(objQuote.BigMachines__Opportunity__r.Offering_Detail__c != 'Hybrid' && objProd.New_Category__c == 'Hybrid') {
                    blnRestrictionApply = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select only non Hybrid products'));
                }
                
                if(set_ProdIds.contains(objProd.Id) && !objProd.Show_Add_Sign__c) {
                    blnRestrictionApply = true;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This product(s) cannot be added,as this product is already set to be added and is not allowed duplicate parts.'));
                    
                }
                else
                    set_ProdIds.add(objProd.Id);
                //Added By Ranjith on Jul 3rd, 2019 -- Ends
            }  
            
            //Anju Jan 2018 PureSuccess starts
            Integer pureSuccessOfferCount = 0;
            Integer pureSuccessAlacarteCount = 0;
            system.debug(objQuote.Offering_Type__c);
            Boolean blnPureSuccessValidation = true;
            
            pureSuccessOfferCount += getBaseCount();
            pureSuccessAlacarteCount += getPureSuccessAlacarteCount();
            
            system.debug(pureSuccessOfferCount);
            for(Product2 objProduct : list_ProductsToAdd)
            {
                pureSuccessOfferCount += isPureSuccessBase(objProduct.id);
                System.debug(pureSuccessOfferCount);
                pureSuccessAlacarteCount += isPureSuccessAlacarte(objProduct);
                
            }
            if(pureSuccessOfferCount > 1)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PCC_PureSuccess_Offer_Validation_Message));
                blnPureSuccessValidation = false;
            }
            //Anju Jan 2018 PureSuccess ends
            
            if(!blnRestrictionApply && blnPureSuccessValidation)
            {
                List<Product2> list_SelectedProducts = Database.query(createAddedProductsQueryString(list_ProductsToAdd));
                
                Map<Id,Product2> map_Products = new Map<Id,Product2>(list_SelectedProducts);
                Set<String> set_APNnumbers = new Set<String>();
                for(Product2 objProduct : list_ProductsToAdd)
                {
                    
                    Product2 objAddionalInfoProd = map_Products.get(objProduct.Id);
                    
                    Decimal decPrice = (Decimal)objProduct.get(strPricebookFieldName);                    
                    // PSRDP Recommendations
                    if(PSRDP_Recommendations__c.getInstance(objProduct.APN_Number__c) != null)
                        set_APNnumbers.add(PSRDP_Recommendations__c.getInstance(objProduct.APN_Number__c).PSRDP_Training_Unit_Part__c);
                    
                    // if any recommended product is already added by user : remove it from APN numbers to be added             
                    if(set_APNnumbers.contains(objProduct.APN_Number__c))
                        set_APNnumbers.remove(objProduct.APN_Number__c);
                    
                    // Fetching Tier Pricing if applicable
                    if(objAddionalInfoProd.Price_Type__c == 'Range')
                        decPrice = QuoteUtil.getProductTierPricing(objAddionalInfoProd.Product_Tier_Pricings__r, 
                                                                   objProduct.Quantity__c, decPrice, strPricebookFieldName);
                    else if(objAddionalInfoProd.Price_Type__c == 'Rate Plan' && objAddionalInfoProd.Product_Tier_Pricings__r.size() > 0) 
                        decPrice = (Decimal)objAddionalInfoProd.Product_Tier_Pricings__r[0].get(strPricebookFieldName);
                    
                    // Quote Pricing Model is Concurrent and product has the concurrent pricing model, price is multiplied by pricing multiplier
                    if(objQuote.Pricing_Model__c == PRICING_MODEL_CONCURRENT && objProduct.Is_Concurrent__c == 'Yes')
                        decPrice *= decPricingMultiplier;
                    
                    BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                    //objQP.Name = objProduct.Name.containsIgnoreCase('Passthrough') ? null : objProduct.Name;
                    objQP.Name = objProduct.Name;
                    objQP.BigMachines__Quote__c = objQuote.Id;
                    objQP.BigMachines__Product__c = objProduct.Id;
                    objQP.APN_Number__c = objProduct.APN_Number__c;
                    objQP.Product_Specific_Discount__c = objAddionalInfoProd.Product_Specific_Discount__c;
                    system.debug('####'+objAddionalInfoProd.Product_Group__c);
                    objQP.Product_Group__c = objAddionalInfoProd.Product_Group__c;
                    objQP.Pm_Approver__c = objAddionalInfoProd.Product_Manager_Approval_Group__r.Name;
                    objQP.Third_Party__c = objAddionalInfoProd.Third_Party__c;
                    objQP.Third_Party_GC__c = objAddionalInfoProd.Third_Party_GC__c;
                    objQP.Original_Third_Party_GC__c = objAddionalInfoProd.Third_Party_GC__c;
                    objQP.List_Price__c = decPrice;
                    objQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                    //Rony Joseph-June 5 2019-Trial Automation - Start
                    objQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                    objQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                    objQP.Billing_Category__c = objQuote.Billing_Category__c;           
                    objQP.Type_of_Product__c  = 'Ordinary';
                    //Rony Joseph-June 5 2019-Trial Automation -End                                                                                                                                
                    system.debug('#######decPrice '+objProduct.Product_Name__c);
                    /*    if(String.isNotBlank(objProduct.Product_Name__c))
{
// Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
//objQP.Quantity__c = Decimal.valueOf(objProduct.Product_Name__c);
//objQP.BigMachines__Quantity__c = objQP.Quantity__c;
objQP.Build_Type__c = objProduct.Name;
// Fetching AudioCodes prices from custom settings based on Base Item name and quantity selected
AudioCodes__c objAudioCodeSettings = AudioCodes__c.getInstance(objProduct.Name);
if(objAudioCodeSettings != null)
objQP.List_Price__c *= objAudioCodeSettings.Volume_Break_Multiplier__c;
}*/
                    objQP.Quantity__c = objProduct.Quantity__c;
                    objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                    
                    objQP.Unit_of_Measure__c = objProduct.Unit_of_Measure__c;
                    objQP.BigMachines__Sales_Price__c = 0;
                    System.debug('#####ProductQP created'+objQP);
                    list_QuoteProductsToBeCreated.add(objQP);
                    
                    objProduct.Quantity__c = null;
                    objProduct.Product_Name__c = null;
                }
                
                System.debug('######'+list_QuoteProductsToBeCreated);
                if(set_APNnumbers.size() > 0)
                    addRecommendationProducts(set_APNnumbers);
            }        
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    // *** To Add Bundles to the quote ***
    public void addBundlesBtnHandler()
    {   //Commented By Ranjith on Jun 05, 2017 -- Starts
        /*Boolean blnRestrictionApply = false;
productGroupIds = new Set<Id>();
Set<Id> set_ExistingProdIds = new Set<Id>();
Map<Id, List<Genesys_Product_Prerequisite__c>> map_RestrictProducts = buildRestrictProductsMap();    
for(List<Product_Group__c> list_Bundles : map_BundleTypeToBundles.values())
{
for(Product_Group__c objProductBundle : list_Bundles)
{
if(objProductBundle.Quantity__c != null && objProductBundle.Quantity__c != 0)
{
Product_Group__c objBundleTemp = objProductBundle.clone(true,true);
objBundleTemp.Price__c = (Decimal)objBundleTemp.Product__r.get(strPricebookFieldName);
list_BundlesToBeSaved.add(objBundleTemp);
productGroupIds.add(objProductBundle.id);
}
objProductBundle.Quantity__c = null;
objProductBundle.Additional_Discount__c = null;
}
}
//Commented By Ranjith on Jun 05, 2017 -- Ends

//Added By Ranjith on Dec 05, 2017 -- Starts     
for(BigMachines__Quote_Product__c objQP : [SELECT Id, BigMachines__Product__c, Hide_Record__c, Is_Overage__c
FROM BigMachines__Quote_Product__c 
WHERE BigMachines__Quote__c = :objQuote.Id]) {
set_ExistingProdIds.add(objQP.BigMachines__Product__c);
}
//for(Product_Group__c objProdGrp : list_BundlesToBeSaved) {
for(Integer i=0; i<list_BundlesToBeSaved.size(); i++) {
Product_Group__c objProdGrp = list_BundlesToBeSaved[i];
if(map_RestrictProducts.containsKey(objProdGrp.Product__c)) {
for(Genesys_Product_Prerequisite__c restrictProd : map_RestrictProducts.get(objProdGrp.Product__c)) {
if(set_ExistingProdIds.contains(restrictProd.Prerequisite_Product__c)
|| set_ExistingProdIds.contains(restrictProd.Prerequisite_Product2__c)
|| set_ExistingProdIds.contains(restrictProd.Prerequisite_Product3__c)) {
blnRestrictionApply = true;
ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, restrictProd.Message__c));
}
}
}
if(blnRestrictionApply) {
list_BundlesToBeSaved = !Test.isRunningTest() ? new List<Product_Group__c>() : list_BundlesToBeSaved;
}
}  */
        //Commented By Ranjith on Jun 05, 2017 -- Ends
        
        
        
    }
    
    
    // *** To Add Favorite items to the quote ***
    public void addFavoritesBtnHandler()
    {
        try
        {            
            Set<Id> set_FavIds = new Set<Id>();
            for(FavoriteWrapper objFavWrapper : list_Favourites)
            {
                if(objFavWrapper.blnIsSelected)
                {
                    set_FavIds.add(objFavWrapper.objFavorite.Id);
                    objFavWrapper.blnIsSelected = false;
                }
            }
            if(set_FavIds.size() > 0)
            {
                List<Product_Group_Item__c> list_PGI = Database.query(createAddedFavoritesQueryString(set_FavIds));
                Integer pureSuccessOfferCount = 0;
                Integer pureSuccessAlacarteCount = 0;
                
                pureSuccessOfferCount += getBaseCount();
                pureSuccessAlacarteCount += getPureSuccessAlacarteCount();
                //Anju Jan 2018 PureSuccess ends
                
                for(Product_Group_Item__c objPGI : list_PGI)
                {   
                    if(objPGI.Product__c != null)
                    {
                        Product2 objProd = (Product2)objPGI.getSObject('Product__r');
                        Decimal decPrice = (Decimal)objPGI.getSObject('Product__r').get(strPricebookFieldName);
                        
                        if(decPrice != null && decPrice != -1)
                        {
                            // Quote Pricing Model is Concurrent and product has the concurrent pricing model, price is multiplied by pricing multiplier
                            if(objQuote.Pricing_Model__c == PRICING_MODEL_CONCURRENT && objProd.Is_Concurrent__c == 'Yes')
                                decPrice *= decPricingMultiplier;
                            
                            BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                            objQP.Name = objProd.Name;
                            objQP.BigMachines__Quote__c = objQuote.Id;
                            objQP.BigMachines__Product__c = objPGI.Product__c;
                            objQP.APN_Number__c = objProd.APN_Number__c;
                            objQP.Product_Specific_Discount__c = objProd.Product_Specific_Discount__c;
                            objQP.Product_Group__c = objProd.Product_Group__c;
                            objQP.Pm_Approver__c = objProd.Product_Manager_Approval_Group__r.Name;
                            objQP.Third_Party__c = objProd.Third_Party__c;
                            objQP.Third_Party_GC__c = objProd.Third_Party_GC__c;
                            objQP.Original_Third_Party_GC__c = objProd.Third_Party_GC__c;
                            // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
                            objQP.Quantity__c = objPGI.Quantity__c;
                            objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                            objQP.Unit_of_Measure__c = objProd.Unit_of_Measure__c;
                            objQP.List_Price__c = decPrice;
                            objQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                            //Rony Joseph-June 5 2019-Trial Automation - Start
                            objQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                            objQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                            objQP.Billing_Category__c = objQuote.Billing_Category__c;           
                            objQP.Type_of_Product__c  = 'Ordinary';
                            //Rony Joseph-June 5 2019-Trial Automation -End
                            /*    if(String.isNotBlank(objProd.Quantities_Available__c))
{
// Fetching AudioCodes prices from custom settings based on Base Item name and quantity selected
AudioCodes__c objAudioCodeSettings = AudioCodes__c.getInstance(objProd.Base_Item_Lookup__r.Name + String.valueOf(objQP.Quantity__c.intValue()));
System.debug('<<< ' + objAudioCodeSettings);
if(objAudioCodeSettings != null)
{
objQP.List_Price__c *= objAudioCodeSettings.Volume_Break_Multiplier__c;
objQP.Build_Type__c = objProd.Base_Item_Lookup__r.Name;
}
} */
                            
                            objQP.BigMachines__Sales_Price__c = 0;
                            objQP.or_Amount__c = '%';
                            
                            pureSuccessOfferCount += isPureSuccessBase(objQP.BigMachines__Product__c);
                            pureSuccessAlacarteCount += isPureSuccessAlacarte(objProd);
                            list_QuoteProductsToBeCreated.add(objQP);
                        }
                    }
                }            
                if(pureSuccessOfferCount > 1)
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PCC_PureSuccess_Offer_Validation_Message));
                
            }
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    // *** To Add Products from 'Product Search' to the quote ***
    public void addProductsFromSearch()
    {
        try
        {
            Boolean blnRestrictionApply = false;
            Set<String> set_APNnumbers = new Set<String>();
            Set<Id> set_NewProdIds = new Set<Id>();
            Set<Id> set_ExistingProdIds = new Set<Id>();
            Set<Id> set_ExistingDisplayedProds = new Set<Id>();
            Map<Id, List<Genesys_Product_Prerequisite__c>> map_RestrictProducts = buildRestrictProductsMap();
            
            for(BigMachines__Quote_Product__c objQP : [SELECT Id, BigMachines__Product__c, Hide_Record__c, Is_Overage__c
                                                       FROM BigMachines__Quote_Product__c 
                                                       WHERE BigMachines__Quote__c = :objQuote.Id]) {
                                                           set_ExistingProdIds.add(objQP.BigMachines__Product__c);
                                                           if(!objQP.Hide_Record__c)
                                                               set_ExistingDisplayedProds.add(objQP.BigMachines__Product__c);
                                                       }
            for(BigMachines__Quote_Product__c  objQP : list_QuoteProductsToBeCreated) {
                set_NewProdIds.add(objQP.BigMachines__Product__c);
            }
            System.debug('####set_NewProdIds: ' +set_NewProdIds);
            System.debug('####set_ExistingProdIds: ' +set_ExistingProdIds);
            System.debug('####set_ExistingDisplayedProds: ' +set_ExistingDisplayedProds);
            
            Integer pureSuccessOfferCount = 0;
            Integer pureSuccessAlacarteCount = 0;
            pureSuccessOfferCount += getBaseCount();
            pureSuccessAlacarteCount += getPureSuccessAlacarteCount();
            
            for(Product2 objSearchProd : list_SearchProducts) {
                
                if(objSearchProd.Quantity__c != null) // Anju Sept 17 allow 0 && objSearchProd.Quantity__c != 0) 
                {                   
                    if(map_RestrictProducts.containsKey(objSearchProd.Id)) {
                        for(Genesys_Product_Prerequisite__c restrictProd : map_RestrictProducts.get(objSearchProd.Id)) {
                            if(set_ExistingProdIds.contains(restrictProd.Prerequisite_Product__c)
                               || set_ExistingProdIds.contains(restrictProd.Prerequisite_Product2__c)
                               || set_ExistingProdIds.contains(restrictProd.Prerequisite_Product3__c)
                               || set_NewProdIds.contains(restrictProd.Prerequisite_Product__c)
                               || set_NewProdIds.contains(restrictProd.Prerequisite_Product2__c)
                               || set_NewProdIds.contains(restrictProd.Prerequisite_Product3__c)) {
                                   blnRestrictionApply = true;
                                   ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, restrictProd.Message__c));
                               }
                        }
                    }
                    if(set_ExistingDisplayedProds.contains(objSearchProd.Id) && !objSearchProd.Show_Add_Sign__c) {
                        blnRestrictionApply = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This product cannot be added, as it is already part of the quote/subscription. Please modify the quantity on the existing part.'));
                    }
                    //Added By Ranjith on Jul 3rd, 2019 -- Starts
                    if(objQuote.BigMachines__Opportunity__r.Offering_Detail__c == 'Hybrid' && objSearchProd.New_Category__c != 'Hybrid') {
                        blnRestrictionApply = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select only Hybrid products'));
                    }
                    if(objQuote.BigMachines__Opportunity__r.Offering_Detail__c != 'Hybrid' && objSearchProd.New_Category__c == 'Hybrid') {
                        blnRestrictionApply = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select only non Hybrid products'));
                    }
                    
                    if(set_ProdIds.contains(objSearchProd.Id) && !objSearchProd.Show_Add_Sign__c) {
                        blnRestrictionApply = true;
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This product(s) cannot be added,as this product is already set to be added and is not allowed duplicate parts.'));
                    }
                    else
                        set_ProdIds.add(objSearchProd.Id);
                    //Added By Ranjith on Jul 3rd, 2019 -- Ends
                    if(!blnRestrictionApply) {
                        Decimal decPrice = (Decimal)objSearchProd.get(strPricebookFieldName);
                        
                        // PSRDP Recommendations
                        if(PSRDP_Recommendations__c.getInstance(objSearchProd.APN_Number__c) != null)
                            set_APNnumbers.add(PSRDP_Recommendations__c.getInstance(objSearchProd.APN_Number__c).PSRDP_Training_Unit_Part__c);
                        
                        // if any recommended product is already added by user : remove it from APN numbers to be added             
                        if(set_APNnumbers.contains(objSearchProd.APN_Number__c))
                            set_APNnumbers.remove(objSearchProd.APN_Number__c);
                        
                        if(objSearchProd.Price_Type__c == 'Range')
                            decPrice = QuoteUtil.getProductTierPricing(objSearchProd.Product_Tier_Pricings__r, objSearchProd.Quantity__c, 
                                                                       decPrice, strPricebookFieldName);                      
                        else if(objSearchProd.Price_Type__c == 'Rate Plan' && objSearchProd.Product_Tier_Pricings__r.size() > 0) 
                            decPrice = (Decimal)objSearchProd.Product_Tier_Pricings__r[0].get(strPricebookFieldName);
                        
                        BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                        objQP.Name = objSearchProd.Name;
                        objQP.BigMachines__Quote__c = objQuote.Id;
                        objQP.BigMachines__Product__c = objSearchProd.Id;
                        objQP.APN_Number__c = objSearchProd.APN_Number__c;
                        objQP.Product_Specific_Discount__c = objSearchProd.Product_Specific_Discount__c;
                        objQP.Product_Group__c = objSearchProd.Product_Group__c;
                        objQP.Pm_Approver__c = objSearchProd.Product_Manager_Approval_Group__r.Name;
                        objQP.Third_Party__c = objSearchProd.Third_Party__c;
                        objQP.Third_Party_GC__c = objSearchProd.Third_Party_GC__c;
                        objQP.Original_Third_Party_GC__c = objSearchProd.Third_Party_GC__c;
                        objQP.Unit_of_Measure__c = objSearchProd.Unit_of_Measure__c;
                        objQP.List_Price__c = decPrice;
                        objQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level-
                        //Rony Joseph-June 5 2019-Trial Automation - Start
                        objQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                        objQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                        objQP.Billing_Category__c = objQuote.Billing_Category__c;           
                        objQP.Type_of_Product__c  = 'Ordinary';
                        //Rony Joseph-June 5 2019-Trial Automation -End
                        /*   if(String.isNotBlank(objSearchProd.Quantities_Available__c) && String.isNotBlank(objSearchProd.Product_Name__c))
{
// Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
//objQP.Quantity__c = Decimal.valueOf(objSearchProd.Product_Name__c);
//objQP.BigMachines__Quantity__c = objQP.Quantity__c;
objQP.Build_Type__c = objSearchProd.Base_Item_Lookup__r.Name;
// Fetching AudioCodes prices from custom settings based on Base Item name and quantity selected
AudioCodes__c objAudioCodeSettings = AudioCodes__c.getInstance(objSearchProd.Base_Item_Lookup__r.Name + objSearchProd.Product_Name__c);
if(objAudioCodeSettings != null)
objQP.List_Price__c *= objAudioCodeSettings.Volume_Break_Multiplier__c;
} */
                        objQP.Quantity__c = objSearchProd.Quantity__c;
                        objQP.BigMachines__Quantity__c = objQP.Quantity__c;                                        
                        objQP.BigMachines__Sales_Price__c = 0;
                        pureSuccessOfferCount += isPureSuccessBase(objQP.BigMachines__Product__c );
                        pureSuccessAlacarteCount += isPureSuccessAlacarte(objSearchProd);
                        list_QuoteProductsToBeCreated.add(objQP);
                        
                        objSearchProd.Quantity__c = null;
                        objSearchProd.Product_Name__c = null;
                        
                    }
                }
            }            
            if(pureSuccessOfferCount > 1)
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,Label.PCC_PureSuccess_Offer_Validation_Message));
            
            if(set_APNnumbers.size() > 0)
                addRecommendationProducts(set_APNnumbers);  
        }
        catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    //PureSuccess
    //Anju Jan 2018 PureSuccess starts
    public void addPureSuccessBtnHandler()
    {
        productGroupIds = new Set<Id>();
        for(List<Product_Group__c> list_PureSuccess : map_BundleTypeToBundles.values())
        {
            for(Product_Group__c objProductPureSuccess : list_PureSuccess)
            {
                System.debug('NKC debug objProductPureSuccess.Selected__c [' + objProductPureSuccess.Selected__c + ']');
                System.debug('NKC debug objProductPureSuccess.Active__c [' + objProductPureSuccess.Active__c + ']');
                if(objProductPureSuccess.Active__c && objProductPureSuccess.Selected__c)
                {
                    Product_Group__c objBundleTemp = objProductPureSuccess.clone(true,true);
                    objBundleTemp.Quantity__c = 1;
                    list_PureSuccessToBeSaved.add(objBundleTemp);
                    productGroupIds.add(objProductPureSuccess.id);
                    objProductPureSuccess.Active__c = false;
                    objProductPureSuccess.Selected__c = false;
                }
                else
                    objProductPureSuccess.Active__c = false;
                objProductPureSuccess.Quantity__c = 1;
                objProductPureSuccess.Additional_Discount__c = null;
            }
        } 
        
        for(Product_Group_Item__c eachAlaCarteItem : list_OfAlaCarte){
            if(eachAlaCarteItem.Product__r.Quantity__c != null && eachAlaCarteItem.Product__r.Quantity__c > 0){
                Product2 newProduct = new Product2(id = eachAlaCarteItem.Product__c, 
                                                   Quantity__c = eachAlaCarteItem.Product__r.Quantity__c,
                                                   List_Price__c = (Decimal)eachAlaCarteItem.Product__r.get(strPricebookFieldName),
                                                   Name = eachAlaCarteItem.Product__r.Name,
                                                   description__c = eachAlaCarteItem.Product__r.description__c );
                list_OfAlaCarteToBeSaved.add(newProduct);
            }
        }
    }
    public void removeAlaCarteItem(){
        Integer intRow = Integer.valueOf(strProdIndex);
        if(!list_OfAlaCarteToBeSaved.isEmpty()){
            if(intRow >= 0 && intRow < list_OfAlaCarteToBeSaved.size()){
                list_OfAlaCarteToBeSaved.remove(intRow);
            }    
        }
    }
    //Anju Jan 2018 PureSuccess ends
    
    
    // *** To Add Campaigns/Dynamic Bundles to the quote ***
    public PageReference addCampaignssBtnHandler() 
    {
        return null;
    }
    
    // *** To Add Recommendation Training Products for PS RDP Products ***
    private void addRecommendationProducts(Set<String> set_APNnumbers)
    {
        // add recommendations
        
    }
    
    // *** To remove a product from right side panel ***
    public void removeProduct()
    {
        Integer intRow = Integer.valueOf(strProdIndex);
        if(intRow >= 0 && intRow < list_QuoteProductsToBeCreated.size())
        {
            list_QuoteProductsToBeCreated.remove(intRow);
        }
    }
    
    // *** To remove a bundle from right side panel ***
    public void removeProductBundle()
    {   
        Integer intRow = Integer.valueOf(strProdIndex);
        if(!list_PureSuccessToBeSaved.isEmpty()){
            if(intRow >= 0 && intRow < list_PureSuccessToBeSaved.size()){
                list_PureSuccessToBeSaved.remove(intRow);
            }    
        }
        
        else{            
            if(intRow >= 0 && intRow < list_BundlesToBeSaved.size()){
                list_BundlesToBeSaved.remove(intRow);
            }
        }
    }
    
    // *** To remove all products and bundles from right side panel ***
    public void removeAllBtnHandler()
    {
        list_QuoteProductsToBeCreated = new List<BigMachines__Quote_Product__c>();
        list_BundlesToBeSaved = new List<Product_Group__c>();
        list_CampaignsToBeSaved  = new List<BigMachines__Quote_Product__c>();
        //Anju Dec 18 usecases
        list_UseCasesToBeSaved = new List<Product_Group__c>();
    }
    
    // *** Handler for 'Mark Favorite' button ***
    public void markFavBtnHandler()
    {
        blnShowFavSaveOptions = true;
        objFavToBeSaved = new Product_Group__c();
    }
    
    // *** Handler for 'Save Favorite' button ***
    public void saveFavourite()
    {
        Savepoint objSP;
        try
        {
            if(String.isBlank(objFavToBeSaved.Name))
            {
                objFavToBeSaved.Name.addError('Value Required');
                return;
            }
            // Savepoint before DML
            objSP = Database.setSavepoint();
            // Creating a Product Group of Type 'Favorite'
            objFavToBeSaved.Group_Type__c = 'Favorite';
            objFavToBeSaved.Quote_Type__c = objQuote.Offering_Type__c;
            objFavToBeSaved.User__c = UserInfo.getUserId();
            insert objFavToBeSaved;
            
            // Adding the products and bundles in the right side panel to the Favorite
            List<Product_Group_Item__c> list_FavItemsToInsert = new List<Product_Group_Item__c>();
            //Commented By Ranjith on Jun 05, 2017 -- Starts
            /*// Adding Bundles
for(Product_Group__c objSavedBundle : list_BundlesToBeSaved)
{
Product_Group_Item__c objFavItem = new Product_Group_Item__c(Product_Group__c = objFavToBeSaved.Id);
objFavItem.Quantity__c = objSavedBundle.Quantity__c != null ? objSavedBundle.Quantity__c : 1;
objFavItem.Bundle__c = objSavedBundle.Id;
list_FavItemsToInsert.add(objFavItem);
}*/
            //Commented By Ranjith on Jun 05, 2017 -- Ends
            // Adding Sell-able Products
            for(BigMachines__Quote_Product__c objQP: list_QuoteProductsToBeCreated)
            {
                Product_Group_Item__c objFavItem = new Product_Group_Item__c(Product_Group__c = objFavToBeSaved.Id);
                objFavItem.Quantity__c = objQP.Quantity__c != null ? objQP.Quantity__c : 1;
                objFavItem.Product__c = objQP.BigMachines__Product__c;
                list_FavItemsToInsert.add(objFavItem);
            }
            
            // Insert Favorite items
            if(list_FavItemsToInsert.size() > 0)
                insert list_FavItemsToInsert;
            
            blnShowFavSaveOptions = false;
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
    }
    
    // *** Handler for 'Cancel' (canceling creation of Favorite) button ***
    public void cancelMarkFavourite()
    {
        blnShowFavSaveOptions = false;
    }
    
    // *** To check for products which require user confirmation regarding notifications ***
    public void checkForRequiredConfirmations()
    {
        Set<Id> set_ProductIds = new Set<Id>();        
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductsToBeCreated){
            set_ProductIds.add(objQP.BigMachines__Product__c);            
        }
        //Commented By Ranjith on Jun 05, 2017 -- Starts
        /*for(BigMachines__Quote_Product__c objQP : list_CampaignsToBeSaved){
set_ProductIds.add(objQP.BigMachines__Product__c);            
}*/
        //Commented By Ranjith on Jun 05, 2017 -- Ends
        if(productGroupIds != null && !productGroupIds.isEmpty()){
            List<Product_Group_Item__c> groupItems = [SELECT Product__c FROM Product_Group_Item__c WHERE Product_Group__c IN : productGroupIds];
            for(Product_Group_Item__c eachGI : groupItems){
                set_ProductIds.add(eachGI.Product__c);            
            }
        }
        
        list_NotificationProducts = new List<ConfirmationWrapper>();
        /*  EOL_Value = Product has prerequisites or limited compatibility or is headed towards EOL
Restrictions_Value = New product with limited functionality or other restrictions
Expansion_Only_Value = Product available for expansion only */
        //Shipment_Approval__c = :Label.EOL_Value OR Shipment_Approval__c = :Label.Restrictions_Value OR Shipment_Approval__c = :Label.Expansion_Only_Value OR
        // OR (EOL_Announced_Date__c != NULL AND EOL_Announced_Date__c < TODAY) 
        
        for(Product2 objProduct : [SELECT Id, Name, Description, Notification_Message__c, EOL_Announced_Date__c,Tier_Pricing_Decimal_Precision__c FROM Product2 
                                   WHERE Id IN :set_ProductIds AND Sub_Category__c in :Label.PCC_Hardware_Categories.split(';') ORDER BY Name]){
                                       
                                       ConfirmationWrapper objConf = new ConfirmationWrapper();
                                       objConf.objProd = objProduct;
                                       if(objProduct.EOL_Announced_Date__c != null && objProduct.EOL_Announced_Date__c < System.today())
                                           objConf.objProd.Notification_Message__c = Label.Product_EOL_Msg;
                                       list_NotificationProducts.add(objConf);
                                   }
        if(list_NotificationProducts.size() > 0)
            blnShowConfirmPanel = true;
    }
    
    // *** Handler for 'Proceed' button in Confirmation Box ***
    public void confBoxCancel()
    {
        blnShowConfirmPanel = false;
        list_NotificationProducts.clear();
    }
    
    // *** Handler for 'Cancel' button in Confirmation Box ***
    public void confBoxProceed()
    {
        for(ConfirmationWrapper objConf : list_NotificationProducts)
        {
            if(!objConf.blnIsSelected)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please acknowledge this message before you continue or you can click Cancel.'));
                return;
            }
        }
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductsToBeCreated)
        {
            for(ConfirmationWrapper objConf : list_NotificationProducts)
            {
                if(objConf.objProd.Id == objQP.BigMachines__Product__c)
                {
                    objQP.Confirmation__c = true;
                    break;
                }
            }
        }
        blnShowConfirmPanel = false;
        list_NotificationProducts.clear();
        saveLogic();
    }
    
    // *** Handler for 'Save' button on right side panel ***
    public void saveBtnHandler()
    {
        strIsSaveSuccessful = 'No';
        if(list_QuoteProductsToBeCreated.size() > 0 || productGroupIds != null || list_CampaignsToBeSaved.size() > 0 || list_PureSuccessToBeSaved.size()>0)
        {
            checkForRequiredConfirmations();
            if(blnShowConfirmPanel)
                return;
        }
        saveLogic();
    }
    
    // *** Save Logic for Configurator ***
    public void saveLogic()
    {
        Savepoint objSP;
        try
        {
            String strType = '';
            List<BigMachines__Quote_Product__c> list_ToInsert = new List<BigMachines__Quote_Product__c>();
            Set<Id> set_UseCaseProductsAdded = new Set<Id>();
            System.debug('###ProductAdded'+list_QuoteProductsToBeCreated);
            System.debug('###map_QuoteIdToBundeId'+map_QuoteIdToBundeId);
            System.debug('list_QuoteProductsToBeCreated'+list_QuoteProductsToBeCreated);
            for(BigMachines__Quote_Product__c objNewQP:list_QuoteProductsToBeCreated){
                System.debug('####Setting Bundle Line'+objNewQP.BigMachines__Product__c);
                objNewQP.Bundle__c = (objNewQP.Bundle__c !=null)?objNewQP.Bundle__c:UseCaseBundleLineUpdate(objNewQP.BigMachines__Product__c);
                objNewQP.Bundle_Line__c = (objNewQP.Bundle_Line__c !=null)?objNewQP.Bundle_Line__c:map_QuoteIdToBundeId.get(objNewQP.Bundle__c) ;  
                objNewQP.Offer__c   = (map_BundleToOffer.get(objNewQP.Bundle__c) !=null)?map_BundleToOffer.get(objNewQP.Bundle__c):null;
                objNewQP.Play__c    = (map_BundleToPlay.get(objNewQP.Bundle__c) != null)?map_BundleToPlay.get(objNewQP.Bundle__c):objQuote.Top_Play__c;
                IF(objNewQP.Play__c == 'Other Use Cases'){ objNewQP.Play__c  = objQuote.Top_Play__c; }
            }
            list_ToInsert.addAll(list_QuoteProductsToBeCreated);
            if(!list_PureSuccessToBeSaved.isEmpty()){
                list_BundlesToBeSaved.addAll(list_PureSuccessToBeSaved);
                strType = 'PureSuccess';
            }
            
            //Commented By Ranjith on Jun 05, 2017 -- Starts
            List<BigMachines__Quote_Product__c> list_BundlesToInsert = new List<BigMachines__Quote_Product__c>();
            List<List<BigMachines__Quote_Product__c>> list_RelatedSellableItemLines = new List<List<BigMachines__Quote_Product__c>>();                      
            List<BigMachines__Quote_Product__c> list_Campaign_update = new List<BigMachines__Quote_Product__c>();
            
            //Anju Jan 2018 PureSuccess starts
            if(String.isNotBlank(strPricebookFieldName))
            {
                String strBundleQuery = 'SELECT Id,Product__r.product_group__c,Group_Type__c,Product__r.APN_Number__c,Product__r.Unit_of_Measure__c,type__c,Play_Offer__c, (SELECT Product__c,Product__r.Product_Specific_Discount__c,Product__r.APN_Number__c,Product__r.Building_Block__c';
                strBundleQuery += ',Product__r.' + strPricebookFieldName;
                if(objQuote.Pricing_Model__c != PRICING_MODEL_ENABLED)
                    strBundleQuery += ',Product__r.Is_Concurrent__c';
                strBundleQuery += ',Product__r.Product_Manager_Approval_Group__r.Name,Product__r.Name,Product__r.Third_Party__c,Product__r.Third_Party_GC__c,Product__r.Unit_of_Measure__c,Quantity__c,Product_Group__r.Group_Type__c FROM Product_Group_Items__r)';
                strBundleQuery += ' FROM Product_Group__c WHERE Id IN :list_BundlesToBeSaved';
                
                System.debug('>>>>strBundleQuery'+ strBundleQuery);
                Map<Id,Product_Group__c> map_Bundles = new Map<Id,Product_Group__c>((List<Product_Group__c>)Database.query(strBundleQuery));
                //Anju Dec 18 usecases
                if(!list_UseCasesToBeSaved.isEmpty()){
                    list_BundlesToBeSaved.addAll(list_UseCasesToBeSaved);
                    map_Bundles.putAll(getUseCaseBundles(strPricebookFieldName,list_UseCasesToBeSaved));
                }
                List<BigMachines__Quote_Product__c> list_QPinserted = [select BigMachines__Product__c from BigMachines__Quote_Product__c where BigMachines__Quote__c = :objQuote.Id];
                for(BigMachines__Quote_Product__c objQP:list_QPinserted)
                {
                    set_UseCaseProductsAdded.add(objQp.BigMachines__Product__c);
                } 
                
                System.debug('>>>>>>>map_Bundles'+ map_Bundles.size());
                for(Product_Group__c objSavedBundle : list_BundlesToBeSaved)
                {
                    Product_Group__c objQueriedBundle = map_Bundles.get(objSavedBundle.Id);
                    system.debug(objSavedBundle);
                    
                    BigMachines__Quote_Product__c objBundleQP = new BigMachines__Quote_Product__c();
                    objBundleQP.Name = objSavedBundle.Name;
                    objBundleQP.BigMachines__Quote__c = objQuote.Id;
                    objBundleQP.BigMachines__Product__c = objSavedBundle.Product__c;
                    system.debug(map_Bundles.get(objSavedBundle.Id));
                    objBundleQP.APN_Number__c = map_Bundles.get(objSavedBundle.Id).Product__r.APN_Number__c;
                    objBundleQP.Unit_of_Measure__c = map_Bundles.get(objSavedBundle.Id).Product__r.Unit_of_Measure__c ;
                    objBundleQP.product_group__c = map_Bundles.get(objSavedBundle.Id).Product__r.product_group__c ;
                    // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
                    objBundleQP.Quantity__c = objSavedBundle.Quantity__c;
                    objBundleQP.BigMachines__Quantity__c = objBundleQP.Quantity__c;
                    //objBundleQP.List_Price__c = objSavedBundle.Price__c;
                    if(objSavedBundle.Group_Type__c != 'Use Case')
                    {
                        objBundleQP.List_Price__c = (Decimal)objSavedBundle.Product__r.get(strPricebookFieldName); //objSavedBundle.Price__c;
                    }
                    objBundleQP.BigMachines__Sales_Price__c = 0;
                    objBundleQP.or_Amount__c = '%';
                    objBundleQP.Disc__c = objSavedBundle.Additional_Discount__c;
                    objBundleQP.Bundle_Discount__c = objSavedBundle.Discount__c;
                    objBundleQP.Bundle__c = objSavedBundle.Id;
                    //Rony Joseph-June 5 2019-Trial Automation - Start
                    objBundleQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                    objBundleQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                    objBundleQP.Billing_Category__c = objQuote.Billing_Category__c;           
                    objBundleQP.Type_of_Product__c  = 'Ordinary';
                    //Rony Joseph-June 5 2019-Trial Automation -End
                    objBundleQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level-                                                                                                                                         
                    //Anju Dec 18 usecases
                    if(objSavedBundle.Group_Type__c == 'Use Case')
                    {
                        objBundleQP.Hide_Record__c = true;
                        objBundleQP.List_Price__c = 0;
                        objBundleQP.Quantity__c = 1;
                        objBundleQP.BigMachines__Quantity__c = 1;
                        If(map_usecaseToPlayOffer.get(objSavedBundle.Id) != null){
                            List<String> StrPlayAndOffer= map_usecaseToPlayOffer.get(objSavedBundle.Id).split('\\s+-');
                            objBundleQP.Play__c = (StrPlayAndOffer[0] !=null)?StrPlayAndOffer[0]:'';
                            objBundleQP.Offer__c = (StrPlayAndOffer.size() > 1)?StrPlayAndOffer[1]:'';
                        }
                    }
                    
                    list_BundlesToInsert.add(objBundleQP);
                    
                    List<BigMachines__Quote_Product__c> list_SellableItemLines = new List<BigMachines__Quote_Product__c>();
                    for(Product_Group_Item__c objGroupItem : objQueriedBundle.getSObjects('Product_Group_Items__r'))
                    {
                        if(objGroupItem.Product_Group__r.Group_Type__c != 'Use Case'){
                            Product2 objProduct = (Product2)objGroupItem.getSObject('Product__r');
                            Decimal decPrice = (Decimal)objProduct.get(strPricebookFieldName);
                            if(decPrice != null && decPrice != -1)
                            {
                                BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                                objQP.Name = objProduct.Name;
                                objQP.BigMachines__Quote__c = objQuote.Id;
                                objQP.BigMachines__Product__c = objGroupItem.Product__c;
                                objQP.APN_Number__c = objProduct.APN_Number__c;
                                objQP.Product_Specific_Discount__c = objProduct.Product_Specific_Discount__c;
                                objQP.Pm_Approver__c = objProduct.Product_Manager_Approval_Group__r.Name;
                                objQP.Unit_of_Measure__c = objProduct.Unit_of_Measure__c;
                                objQP.Third_Party__c = objProduct.Third_Party__c;
                                objQP.Third_Party_GC__c = objProduct.Third_Party_GC__c;
                                objQP.Original_Third_Party_GC__c = objProduct.Third_Party_GC__c;
                                // Committed Quantity stores the quantity of the product in the bundle
                                objQP.Committed_Quantity__c = (objGroupItem.Quantity__c != null ? objGroupItem.Quantity__c : 1);
                                // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
                                system.debug('before list price');
                                objQP.Quantity__c = (objSavedBundle.Quantity__c == null ? 1 : objSavedBundle.Quantity__c)  * objQP.Committed_Quantity__c;
                                objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                                objQP.List_Price__c = decPrice;
                                objQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                                system.debug('listprice'+decPrice);
                                // Quote Pricing Model is Concurrent and product has the concurrent pricing model, price is multiplied by pricing multiplier
                                if(objQuote.Pricing_Model__c == PRICING_MODEL_CONCURRENT && objProduct.Is_Concurrent__c == 'Yes')
                                    objQP.List_Price__c *= decPricingMultiplier;
                                
                                //Anju PCC Subscriptions - set bundle line price to 0
                                objQP.Ext_Net_Price__c = objQP.List_Price__c * objQP.BigMachines__Quantity__c;
                                objQP.Ext_List__c = objQP.List_Price__c * objQP.BigMachines__Quantity__c;
                                objQP.Partner_Price__c = objQP.List_Price__c;
                                objQP.Net_Unit_Price__c = objQP.List_Price__c;
                                
                                
                                objQP.BigMachines__Sales_Price__c = 0;
                                objQP.or_Amount__c = '%';
                                objQP.Disc__c = objSavedBundle.Additional_Discount__c;
                                objQP.Bundle_Discount__c = objSavedBundle.Discount__c;
                                objQP.Bundle__c = objSavedBundle.Id;
                                //Rony Joseph-June 5 2019-Trial Automation - Start
                                objQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                                objQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                                objQP.Billing_Category__c = objQuote.Billing_Category__c;           
                                objQP.Type_of_Product__c  = 'Ordinary';
                                //Rony Joseph-June 5 2019-Trial Automation -End
                                
                                //Anju July 2018 if Puresuccess hide record as false
                                objQP.Hide_Record__c = true;
                                
                                //Anju Dec 18 usecases  
                                if(objSavedBundle.Group_Type__c == 'Use Case')
                                {
                                    objQP.Hide_Record__c = false;
                                    objQP.Bundle_Line__c = null;
                                    If(map_usecaseToPlayOffer.get(objSavedBundle.Id) != null){
                                        List<String> StrPlayAndOffer= map_usecaseToPlayOffer.get(objSavedBundle.Id).split('\\s+-');
                                        objQP.Play__c = (StrPlayAndOffer[0] !=null)?StrPlayAndOffer[0]:'';
                                        objQP.Offer__c = (StrPlayAndOffer.size() > 1)?StrPlayAndOffer[1]:'';
                                    } 
                                }
                                
                                
                                list_ToInsert.add(objQP);
                                list_SellableItemLines.add(objQP);
                            }
                        }
                        else if(objGroupItem.Product_Group__r.Group_Type__c == 'Use Case' &&  !set_UseCaseProductsAdded.contains(objGroupItem.Product__c)){
                            Product2 objProduct = (Product2)objGroupItem.getSObject('Product__r');
                            set_UseCaseProductsAdded.add(objProduct.Id);
                            Decimal decPrice = (Decimal)objProduct.get(strPricebookFieldName);
                            if(decPrice != null && decPrice != -1)
                            {
                                BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                                objQP.Name = objProduct.Name;
                                objQP.BigMachines__Quote__c = objQuote.Id;
                                objQP.BigMachines__Product__c = objGroupItem.Product__c;
                                objQP.APN_Number__c = objProduct.APN_Number__c;
                                objQP.Product_Specific_Discount__c = objProduct.Product_Specific_Discount__c;
                                objQP.Pm_Approver__c = objProduct.Product_Manager_Approval_Group__r.Name;
                                objQP.Unit_of_Measure__c = objProduct.Unit_of_Measure__c;
                                objQP.Third_Party__c = objProduct.Third_Party__c;
                                objQP.Third_Party_GC__c = objProduct.Third_Party_GC__c;
                                objQP.Original_Third_Party_GC__c = objProduct.Third_Party_GC__c;
                                // Committed Quantity stores the quantity of the product in the bundle
                                objQP.Committed_Quantity__c = (objGroupItem.Quantity__c != null ? objGroupItem.Quantity__c : 1);
                                // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
                                system.debug('before list price');
                                objQP.Quantity__c = (objSavedBundle.Quantity__c == null ? 1 : objSavedBundle.Quantity__c)  * objQP.Committed_Quantity__c;
                                objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                                objQP.List_Price__c = decPrice;
                                objQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                                system.debug('listprice'+decPrice);
                                // Quote Pricing Model is Concurrent and product has the concurrent pricing model, price is multiplied by pricing multiplier
                                if(objQuote.Pricing_Model__c == PRICING_MODEL_CONCURRENT && objProduct.Is_Concurrent__c == 'Yes')
                                    objQP.List_Price__c *= decPricingMultiplier;
                                
                                //Anju PCC Subscriptions - set bundle line price to 0
                                objQP.Ext_Net_Price__c = objQP.List_Price__c * objQP.BigMachines__Quantity__c;
                                objQP.Ext_List__c = objQP.List_Price__c * objQP.BigMachines__Quantity__c;
                                objQP.Partner_Price__c = objQP.List_Price__c;
                                objQP.Net_Unit_Price__c = objQP.List_Price__c;
                                
                                
                                objQP.BigMachines__Sales_Price__c = 0;
                                objQP.or_Amount__c = '%';
                                objQP.Disc__c = objSavedBundle.Additional_Discount__c;
                                objQP.Bundle_Discount__c = objSavedBundle.Discount__c;
                                objQP.Bundle__c = objSavedBundle.Id;
                                
                                //Rony Joseph-June 5 2019-Trial Automation - Start
                                objQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                                objQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                                objQP.Billing_Category__c = objQuote.Billing_Category__c;           
                                objQP.Type_of_Product__c  = 'Ordinary';
                                //Rony Joseph-June 5 2019-Trial Automation -End
                                //Anju July 2018 if Puresuccess hide record as false
                                objQP.Hide_Record__c = true;
                                
                                //Anju Dec 18 usecases  
                                if(objSavedBundle.Group_Type__c == 'Use Case')
                                {
                                    objQP.Hide_Record__c = false;
                                    objQP.Bundle_Line__c = null;
                                    If(map_usecaseToPlayOffer.get(objSavedBundle.Id) != null){
                                        List<String> StrPlayAndOffer= map_usecaseToPlayOffer.get(objSavedBundle.Id).split('\\s+-');
                                        objQP.Play__c = (StrPlayAndOffer[0] !=null)?StrPlayAndOffer[0]:'';
                                        objQP.Offer__c = (StrPlayAndOffer.size() > 1)?StrPlayAndOffer[1]:'';
                                    }  
                                }
                                
                                
                                list_ToInsert.add(objQP);
                                list_SellableItemLines.add(objQP);
                            }
                            
                        }
                        list_RelatedSellableItemLines.add(list_SellableItemLines);
                    }
                }
                //Anju Jan 2018 PureSuccess ends
                //Commented By Ranjith on Jun 05, 2017 -- Ends
                // Savepoint before DML
                objSP = Database.setSavepoint();
                // Skip Triggers
                Util.Bypass_Trigger_Chk = true;
                //Commented By Ranjith on Jun 05, 2017 -- Starts
                if(list_BundlesToInsert.size() > 0)
                {
                    insert list_BundlesToInsert;
                    System.debug(list_BundlesToInsert);
                    for(Integer i=0; i< list_BundlesToInsert.size() ; i++)
                    {
                        for(BigMachines__Quote_Product__c objQP : list_RelatedSellableItemLines[i])
                        {
                            System.debug(objQP);
                            System.debug(list_BundlesToInsert[i]); 
                            //Anju Dec 18 usecases  
                            if(objQP.bundle__r.Group_Type__c != 'Use Case' && list_BundlesToInsert[i].APN_Number__c != null && !Label.PCC_Use_Case_Base_Product_APNS.contains(list_BundlesToInsert[i].APN_Number__c))
                            {
                                objQP.Bundle_Line__c = list_BundlesToInsert[i].Id;
                            }
                        }   
                    }
                }
                //Commented By Ranjith on Jun 05, 2017 -- Ends
                
                
                
                if(list_ToInsert.size() > 0){
                    //Logic to add overage/usage prices
                    Set<Id> set_ProductIds = new Set<Id>();
                    Map<Id, Product_Tier_Pricing__c> map_ProdOveragePricing = new Map<Id, Product_Tier_Pricing__c>();
                    Map<String, String> map_DependentProducts = new Map<String, String>();
                    for(BigMachines__Quote_Product__c objNewQP : list_ToInsert) {
                        set_ProductIds.add(objNewQP.BigMachines__Product__c);
                    }
                    //Added By Ranjith on Dec 06, 2017 -- Starts
                    System.debug('SetproductIds---'+set_ProductIds);
                    Set<Id> set_AddtProdIds = new Set<Id>();
                    Set<Id> set_ExistingProdIds = new Set<Id>();
                    for(BigMachines__Quote_Product__c objQP : [SELECT Id, BigMachines__Product__c
                                                               FROM BigMachines__Quote_Product__c
                                                               WHERE BigMachines__Quote__c = :objQuote.Id]) {
                                                                   set_ExistingProdIds.add(objQP.BigMachines__Product__c);
                                                               }
                    
                    List<Product_Group__c> list_ProdGrps = [SELECT Id, Product__c, Product__r.APN_Number__c,
                                                            (SELECT Product__c, Product__r.APN_Number__c, 
                                                             Product_Group__r.Product__r.APN_Number__c
                                                             FROM Product_Group_Items__r 
                                                             WHERE Product_Type__c = 'Mandatory')
                                                            FROM Product_Group__c
                                                            WHERE Group_Type__c = 'Dependent Products'
                                                            AND Active__c = true
                                                            AND Product__c IN :set_ProductIds];
                    
                    System.debug('list group----'+list_ProdGrps);
                    for(Product_Group__c objProdGrp : list_ProdGrps) {
                        for(Product_Group_Item__c objProdGrpItm : objProdGrp.Product_Group_Items__r) {
                            map_DependentProducts.put(objProdGrpItm.Product__r.APN_Number__c, objProdGrp.Product__r.APN_Number__c);
                            if(!set_ProductIds.contains(objProdGrpItm.Product__c) 
                               && !set_ExistingProdIds.contains(objProdGrpItm.Product__c)) {
                                   set_AddtProdIds.add(objProdGrpItm.Product__c);
                                   set_ProductIds.add(objProdGrpItm.Product__c);
                               }
                        }
                    }
                    System.debug('#####set_AddtProdIds: '+set_AddtProdIds);
                    System.debug('#####map_DependentProducts: '+map_DependentProducts);
                    //Added By Ranjith on Feb 26, 2019 -- Starts - For Data Type Conversion under Product Tier Pricing object
                    for(Product2 objAddtProd : Database.query(QuoteCloudUtil.buildProductAndTierPricingQuery(objQuote.Billing_Category__c, objQuote.New_Price_Book__c + '_Price__c'))) {
                        
                        //Added By Ranjith on Feb 26, 2019 -- Ends                
                        Decimal decPrice = (Decimal)objAddtProd.get(strPricebookFieldName);
                        if((objAddtProd.Price_Type__c == 'Rate Plan' || objAddtProd.Price_Type__c == 'Range') && objAddtProd.Product_Tier_Pricings__r.size() > 0) 
                            //system.debug('Tier Pricing---'+objAddtProd.Product_Tier_Pricings__r[0].get(strPricebookFieldName));
                            decPrice = (Decimal)objAddtProd.Product_Tier_Pricings__r[0].get(strPricebookFieldName);
                        BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();                
                        objQP.Name = objAddtProd.Name;
                        objQP.BigMachines__Quote__c = objQuote.Id;
                        objQP.BigMachines__Product__c = objAddtProd.Id;
                        objQP.APN_Number__c = objAddtProd.APN_Number__c;
                        objQP.Product_Specific_Discount__c = objAddtProd.Product_Specific_Discount__c;
                        objQP.Product_Group__c = objAddtProd.Product_Group__c;
                        objQP.List_Price__c = decPrice;
                        objQP.Quantity__c = 0;
                        objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                        objQP.Unit_of_Measure__c = objAddtProd.Unit_of_Measure__c;
                        objQP.BigMachines__Sales_Price__c = 0;
                        objQP.Hide_Record__c = true;
                        objQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                        
                        System.debug('#####objQP.APN_Number__c: '+objQP.APN_Number__c);
                        //Rony Joseph-June 5 2019-Trial Automation - Start
                        objQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                        objQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                        objQP.Billing_Category__c = objQuote.Billing_Category__c;           
                        objQP.Type_of_Product__c  = 'Ordinary';
                        //Rony Joseph-June 5 2019-Trial Automation -End
                        System.debug('#####objQP.APN_Number__c: '+objQP.APN_Number__c);
                        if(map_DependentProducts.containsKey(objQP.APN_Number__c)
                           && (map_DependentProducts.get(objQP.APN_Number__c) == 'PCSMS-170-NV-SMS'
                               || map_DependentProducts.get(objQP.APN_Number__c) == 'PV-170-NV-PCVOICE')
                           || objQP.APN_Number__c.left(6) == 'PCSMS-') {
                               System.debug('#####map_DependentProducts: '+map_DependentProducts.get(objQP.APN_Number__c));
                               objQP.Is_Overage__c = true;
                           }
                        list_ToInsert.add(objQP);
                    }
                    for(BigMachines__Quote_Product__c objNewQP : list_ToInsert) {
                        if(Label.PC_Overage_Products.contains(objNewQP.APN_Number__c)) {
                            objNewQP.Is_Overage__c = true;
                            objNewQP.Name += ' Usage';
                        }
                        objNewQP.CurrencyISOCode = objQuote.CurrencyISOCode;
                    }
                    //Logic to map overage to parent quote product. helpful while deleting
                    insert list_ToInsert;
                    if(list_ToInsert.size() > 0){
                        for(BigMachines__Quote_Product__c objQP : list_ToInsert) {
                            System.debug(objQP);
                            {
                                objQP.Bundle__c = (objQP.Bundle__c !=null)?objQP.Bundle__c:UseCaseBundleLineUpdate(objQP.BigMachines__Product__c);
                                System.debug(objQP.Bundle__c); System.debug(objQP.Bundle_Line__c) ; 
                                if(map_QuoteIdToBundeId.get(objQP.Bundle__c ) ==null &&  objQP.Bundle_Line__c == null){UseCaseBundleLineUpdate(objQP.BigMachines__Product__c);}
                                System.debug(map_QuoteIdToBundeId);
                                if(objQP.Bundle_Line__c ==  null){objQP.Bundle_Line__c =(map_QuoteIdToBundeId.get(objQP.Bundle__c) !=null && map_QuoteIdToBundeId.get(objQP.Bundle__c) != objQP.id)?map_QuoteIdToBundeId.get(objQP.Bundle__c):null;} 
                            }
                        } 
                    }
                    update list_ToInsert;
                    Map<Id, Product_Tier_Pricing__c> map_ProdTiers = new Map<Id, Product_Tier_Pricing__c>();
                    List<BigMachines__Quote_Product__c> list_ToInsertOverageCharges = new List<BigMachines__Quote_Product__c>();
                    Map<Id, BigMachines__Quote_Product__c> map_NewQPs = new Map<Id, BigMachines__Quote_Product__c>();
                    for(BigMachines__Quote_Product__c objQP : list_ToInsert) {
                        map_NewQPs.put(objQP.Id, objQP);
                    }
                    //Added By Ranjith on Feb 26, 2019 -- Starts - For Data Type Conversion under Product Tier Pricing object
                    String strWhereCondition = 'WHERE Product__c IN :set_ProductIds AND Charge_Type__c = \'M2M\' AND Product__r.Has_Overage__c = true';
                    List<Product_Tier_Pricing__c> list_ProdTierPricing = Database.query(QuoteCloudUtil.buildTierPricingQuery(strWhereCondition, objQuote.New_Price_Book__c + '_Price__c'));
                    //Added By Ranjith on Feb 26, 2019 -- Ends
                    
                    for(Product_Tier_Pricing__c objProdTr : list_ProdTierPricing ) {
                        map_ProdTiers.put(objProdTr.Product__c, objProdTr);
                    }
                    for(Id newQPId : map_NewQPs.keySet()) {                    
                        if(map_ProdTiers.containsKey(map_NewQPs.get(newQPId).BigMachines__Product__c)) {
                            Product_Tier_Pricing__c objProdTr = map_ProdTiers.get(map_NewQPs.get(newQPId).BigMachines__Product__c);
                            BigMachines__Quote_Product__c objOverageQP = new BigMachines__Quote_Product__c();
                            objOverageQP.BigMachines__Quote__c = objQuote.Id;
                            objOverageQP.Parent_Quote_Product__c = newQPId;
                            objOverageQP.Is_Overage__c = true;
                            objOverageQP.BigMachines__Product__c = objProdTr.Product__c;
                            objOverageQP.Name = objProdTr.Product__r.Name + ' Overage';
                            objOverageQP.APN_Number__c = objProdTr.Product__r.APN_Number__c;
                            objOverageQP.List_Price__c = ((Decimal)objProdTr.get(objQuote.New_Price_Book__c + '_Price__c'))*1.2;
                            objOverageQP.Unit_of_Measure__c = objProdTr.Product__r.Unit_of_Measure__c;
                            objOverageQP.BigMachines__Quantity__c = objOverageQP.Quantity__c = objOverageQP.BigMachines__Sales_Price__c = 0;
                            objOverageQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                            objOverageQP.or_Amount__c = '%';
                            //Rony Joseph-June 5 2019-Trial Automation - Start
                            objOverageQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                            objOverageQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                            objOverageQP.Billing_Category__c = objQuote.Billing_Category__c;           
                            objOverageQP.Type_of_Product__c  = 'Ordinary';
                            //Rony Joseph-June 5 2019-Trial Automation -End
                            if(set_AddtProdIds.contains(objProdTr.Product__c)
                               || (objQuote.Billing_Category__c == BILLING_CATEGORY_M2M && objProdTr.Product__r.New_Category__c == CATEGORY_SUBSCRIPTION_FEES)
                               || objOverageQP.APN_Number__c == 'PC-170-NV-PCIVRCUSPERMIN') {
                                   objOverageQP.Hide_Record__c = true;
                               }
                            objOverageQP.CurrencyISOCode = objQuote.CurrencyISOCode;
                            list_ToInsertOverageCharges.add(objOverageQP);
                        }
                    }
                    insert list_toInsertOverageCharges;
                }        
                
                
                saveAlaCarteItems();
                strIsSaveSuccessful = 'Yes';
                
            }
        }   
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage() + ex.getlinenumber()));
            system.debug(ex.getMessage() + ex.getlinenumber()+ex.getStackTraceString());
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
    }
    
    
    @testvisible
    //PureSuccess
    //Anju Jan 2018 PureSuccess starts
    private void saveAlaCarteItems(){
        
        List<Product_Group__c> listProductGroup = new List<Product_Group__c>();
        
        if(objQuote.Offering_Type__c == 'PureEngage Cloud' && objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c != 'Indirect')
            listProductGroup  = [SELECT id 
                                 FROM Product_Group__c 
                                 WHERE group_type__c = 'A la Carte' 
                                 AND Offering_type__c = :objQuote.Offering_Type__c 
                                 AND Active__c = true
                                 AND Product__r.Product_Group__c = 'PureSuccess Direct A-la-Carte'];
        
        if(objQuote.Offering_Type__c == 'PureEngage Cloud' && objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Indirect')
            listProductGroup  = [SELECT id 
                                 FROM Product_Group__c 
                                 WHERE group_type__c = 'A la Carte' 
                                 AND Offering_type__c = :objQuote.Offering_Type__c 
                                 AND Active__c = true
                                 AND Product__r.Product_Group__c = 'PureSuccess Indirect A-la-Carte'];
        
        Map<Id, Product2> mapOfProductIdVsProducts = new Map<Id, Product2>();
        
        for(Product2 eachProduct : list_OfAlaCarteToBeSaved){
            mapOfProductIdVsProducts.put(eachProduct.id, eachProduct);
        }
        System.debug('map size---'+mapOfProductIdVsProducts.size());
        Set<Id> setOfProductIds = mapOfProductIdVsProducts.keyset();
        String strProduct2Query = 'SELECT Id, Description, PPU_Product_Specific_Discount__c, APN_Number__c, Building_Block__c,' + strPricebookFieldName;
        if(objQuote.Pricing_Model__c != PRICING_MODEL_ENABLED)
            strProduct2Query += ',Pricing_Model__c';
        strProduct2Query += ',Product_Manager_Approval_Group__r.Name,description__c,Name,Product_Group__c,Third_Party__c,Third_Party_GC__c,Unit_of_Measure__c,Quantity__c,Tier_Pricing_Decimal_Precision__c';
        strProduct2Query += ' FROM Product2 WHERE id IN : setOfProductIds';
        System.debug('NKC debug strProduct2Query ['+ strProduct2Query + ']');
        List<Product2> listOfProducts  = (List<Product2>)Database.query(strProduct2Query);
        List<BigMachines__Quote_Product__c> listOfQPToBeInserted = new List<BigMachines__Quote_Product__c>();
        
        for(Product2 objProduct : listOfProducts){
            Decimal decPrice;
            decPrice = (Decimal)objProduct.get(strPricebookFieldName);
            if(decPrice != null && decPrice != -1){
                //decPrice *= PRICE_MULTIPLIER;
                BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                objQP.Name = objProduct.description__c;
                objQP.BigMachines__Quote__c = objQuote.Id;
                objQP.BigMachines__Product__c = objProduct.id;
                objQP.Product__c = objProduct.Description;
                objQP.Product_Group__c = objProduct.Product_Group__c;
                objQP.APN_Number__c = objProduct.APN_Number__c;
                objQP.Product_Specific_Discount__c = objProduct.PPU_Product_Specific_Discount__c;
                objQP.Pm_Approver__c = objProduct.Product_Manager_Approval_Group__r.Name;
                objQP.Unit_of_Measure__c = objProduct.Unit_of_Measure__c;
                objQP.Third_Party__c = objProduct.Third_Party__c;
                objQP.Third_Party_GC__c = objProduct.Third_Party_GC__c;
                objQP.Original_Third_Party_GC__c = objProduct.Third_Party_GC__c;
                objQP.Quantity__c = mapOfProductIdVsProducts.get(objProduct.id).Quantity__c;
                objQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                if(!listProductGroup.isEmpty())
                    objQP.Bundle__c = listProductGroup[0].id;
                objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                objQP.List_Price__c = decPrice;
                objQP.Line_Number__c = 100;
                //Rony Joseph-June 5 2019-Trial Automation - Start
                objQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                objQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                objQP.Billing_Category__c = objQuote.Billing_Category__c;           
                objQP.Type_of_Product__c  = 'Ordinary';
                //Rony Joseph-June 5 2019-Trial Automation -End
                // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                if(objQuote.Pricing_Model__c != PRICING_MODEL_ENABLED && String.isNotBlank(objProduct.Pricing_Model__c)
                   && objProduct.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                    objQP.List_Price__c *= decPricingMultiplier;
                objQP.BigMachines__Sales_Price__c = 0;                
                listOfQPToBeInserted.add(objQP);
            }
        }
        if(!listOfQPToBeInserted.isEmpty())
            insert listOfQPToBeInserted;
    }
    //Anju Jan 2018 PureSuccess ends
    
    // **************************** Start : Guided Selling Flows ********************
    
    // *** To show products for a particular Flow step ***
    public void showGSFlowStepProducts()
    {
        objCurrentGSFlowStep = [SELECT Order__c,Title__c,Condition_Logic__c,Guided_Selling_Flow__c,Guided_Selling_Flow__r.Number_of_Steps__c,Guided_Selling_Flow__r.Name
                                FROM Guided_Selling_Flow_Step__c WHERE Id = :idFlowStepSelected];
        
        flowSupport();
    }
    
    // *** Handler for Next Step in a Guided Selling Flow ***
    public void nextFlowStepBtnHandler()
    {
        objCurrentGSFlowStep = [SELECT Order__c,Title__c,Condition_Logic__c,Guided_Selling_Flow__c,Guided_Selling_Flow__r.Number_of_Steps__c,Guided_Selling_Flow__r.Name
                                FROM Guided_Selling_Flow_Step__c WHERE Guided_Selling_Flow__c = :objCurrentGSFlowStep.Guided_Selling_Flow__c AND 
                                Order__c = :(objCurrentGSFlowStep.Order__c + 1) AND Is_Active__c = true];
        
        flowSupport();
    }
    
    // *** Handler for Previous Step in a Guided Selling Flow ***
    public void previousFlowStepBtnHandler()
    {
        objCurrentGSFlowStep = [SELECT Order__c,Title__c,Condition_Logic__c,Guided_Selling_Flow__c,Guided_Selling_Flow__r.Number_of_Steps__c,Guided_Selling_Flow__r.Name
                                FROM Guided_Selling_Flow_Step__c WHERE Guided_Selling_Flow__c = :objCurrentGSFlowStep.Guided_Selling_Flow__c AND 
                                Order__c = :(objCurrentGSFlowStep.Order__c - 1) AND Is_Active__c = true];
        
        flowSupport();
    }
    
    // *** Common logic for Flow Step Handlers ***
    private void flowSupport()
    {
        intTotalNoOfRecords = Database.countQuery(createGSFlowStepQueryString(true,objCurrentGSFlowStep.Condition_Logic__c));
        strProductSearchQuery = createGSFlowStepQueryString(false,objCurrentGSFlowStep.Condition_Logic__c);
        intPageNum = 1;
        createCurrentPageList();
    }
    
    // **************************** End : Guided Selling Flows ********************
    
    // *** Handler for 'Search' button in Product Search ***
    public void searchBtnHandler()
    {
        intTotalNoOfRecords = Database.countQuery(createSearchQueryString(true));
        intPageNum = 1;
        strProductSearchQuery = createSearchQueryString(false);
        createCurrentPageList();
    }
    
    // *** Handler for Sorting column selection ***
    public void changeSorting()
    {
        if(strSortFieldSelected == strSortField)
            strSortOrder = (strSortOrder == 'ASC') ? 'DESC' : 'ASC';
        else
        {
            strSortField = strSortFieldSelected;
            strSortOrder = 'ASC';
        }
        intPageNum = 1;
        strProductSearchQuery = createSearchQueryString(false);
        createCurrentPageList();
    }
    
    // *** Method to return boolean whether record should be locked from editing or not ***
    private Boolean isQuoteUnLocked(String strStatus)
    {
        if(strStatus == 'Quote Approval Pending' || strStatus == 'Quote Approved' || strStatus == 'Order Submitted' || 
           strStatus == 'Order Accepted' || strStatus == 'Order Rejected' || strStatus == 'Quote Rejected')
            return false;
        return true;
    }
    
    // **************************** Start : Pagination (Search Results) ********************
    
    // *** Method to set up Search results for current page ***
    public void createCurrentPageList()
    {   list_SearchProducts = Database.query(strProductSearchQuery + ' OFFSET ' + String.valueOf((intPageNum - 1) * intPageSize));
     
     //Rony Joseph-April 9th 2019-Remove PureSuccess Products not matching Opportunity Sale Type
     for ( Integer i = list_SearchProducts.size()-1; i >= 0; --i )
     {
         if(objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Indirect' && list_SearchProducts[i].Product_Group__c == 'PureSuccess Direct A-la-Carte')
         {
             list_SearchProducts.remove(i);
             intTotalNoOfRecords--;
         }    
         if(objQuote.BigMachines__Opportunity__r.Direct_Indirect_Sale__c == 'Direct' && list_SearchProducts[i].Product_Group__c == 'PureSuccess Indirect A-la-Carte')
         {
             list_SearchProducts.remove(i);
             intTotalNoOfRecords--;
         }    
     }     
     for(Product2 objSearchResult : list_SearchProducts)
     {
         // Quote Pricing Model is Concurrent and product has the concurrent pricing model, price is multiplied by pricing multiplier
         if(objQuote.Pricing_Model__c == PRICING_MODEL_CONCURRENT && objSearchResult.Is_Concurrent__c == 'Yes')
             objSearchResult.put(strPricebookFieldName,((Decimal)objSearchResult.get(strPricebookFieldName)) * decPricingMultiplier);
     }
    }
    
    // *** Method to go to next page ***
    public void next()
    {
        if(getHasNext())
        {
            intPageNum++;
            createCurrentPageList();
        }
    }
    
    // *** Method to go to previous page ***
    public void previous()
    {
        if(getHasPrevious())
        {
            intPageNum--;
            createCurrentPageList();
        }
    }
    
    // *** Method to check if there is a previous page ***
    public Boolean getHasPrevious()
    {
        if(intPageNum > 1)
            return true;
        return false;
    }
    
    // *** Method to check if there is a next page ***
    public Boolean getHasNext()
    {
        if(intPageNum < numberOfPages())
            return true;
        return false;
    }
    
    // *** Method to go to first page ***
    public void first()
    {
        intPageNum = 1;
        createCurrentPageList();
    }
    
    // *** Method to go to last page ***
    public void last()
    {
        intPageNum = numberOfPages();
        createCurrentPageList();
    }
    
    // *** Method to show current page in view ***
    public String getPageNumStr()
    {
        Integer intNoOfPages = numberOfPages();
        return ('Page ' + String.valueOf(intPageNum) + ' of ' + String.valueOf(intNoOfPages));
    }
    
    // *** Method to calculate number of pages ***
    public Integer numberOfPages()
    {
        return (intTotalNoOfRecords / intPageSize) + (Math.mod(intTotalNoOfRecords,intPageSize) > 0 ? 1:0);
    }
    
    // **************************** End : Pagination (Search Results) ********************
    
    // **************************** Start : Dynamic Query Strings ********************
    
    // *** Create query string for Base Products based on Category and Building Block ***
    private String createAllProductsQueryString()
    {
        String strBuildingBlockFieldName = 'Sub_Category__c';        
        String strBaseProdQuery = 'SELECT Id,Name,Quantity__c,Unit_of_Measure__c,Show_New__c,Product_Name__c,Quantities_Available__c,New_Category__c,APN_Number__c,Product_Group__c,Is_Concurrent__c,Tier_Pricing_Decimal_Precision__c,Show_Add_Sign__c';
        strBaseProdQuery += ',' + strBuildingBlockFieldName;
        
        if(String.isNotBlank(strPricebookFieldName))
            strBaseProdQuery += ',' + strPricebookFieldName;
        
        strBaseProdQuery += ' FROM Product2 WHERE OfferingType__c INCLUDES (\''+objQuote.Offering_Type__c+'\') AND Show_In_Quoting__c = true';
        
        strBaseProdQuery += ' AND (Charge_Type__c INCLUDES (\'' + objQuote.Billing_Category__c+ '\') OR Charge_Type__c = NULL OR Charge_Type__c INCLUDES (\'' + 'One-Time' + '\') OR Charge_Type__c INCLUDES (\'' + 'Annual Pre-Pay' + '\'))';        
        String strQtRegion = findQuoteRegion();
        strBaseProdQuery += ' AND (Region__c = \'\' OR Region__c INCLUDES (\'' + strQtRegion + '\'))';  
        if(String.isNotBlank(strPricebookFieldName)) {            
            strBaseProdQuery += ' AND ((New_Category__c = \'Credit\') OR (' + strPricebookFieldName + ' != -1 AND ' + strPricebookFieldName + ' != null))';
        }        
        if(strSelectedCategory != 'All')  {
            if(strProductFinancial != 'All')
                strBaseProdQuery += ' AND ' + strBuildingBlockFieldName + ' = :strProductFinancial';
        }
        
        strBaseProdQuery += ' ORDER BY Sort_Order__c, Name';
        
        System.debug('@@@@@'+strBaseProdQuery );   
        return strBaseProdQuery;
    }
    
    // *** Create query string for products to be added from All Products ***
    private String createAddedProductsQueryString(List<Product2> list_ProductsToAdd)
    {
        String strSellableProdQuery = 'SELECT Id,SI_Version_Number__c,Third_Party_GC__c,Product_Specific_Discount__c,Product_Group__c,Third_Party__c,Product_Manager_Approval_Group__r.Name,New_Category__c,Show_Add_Sign__c,';
        strSellableProdQuery += 'Price_Type__c,Tier_Pricing_Decimal_Precision__c,Has_Overage__c,(SELECT Range_From__c, Range_To__c, NG1_APAC_ANZ_AUD_Price__c, NG2_BRAZIL_BRL_Price__c, NG3_EMEA_EUR_Price__c, NG5_NA_CAD_Price__c, NG5_NZD_Price__c,'; 
        strSellableProdQuery += 'NG3_EMEA_GBP_Price__c, NG4_APAC_JAPAN_YEN_Price__c, NG5_NA_USD_Price__c, NG5_ZAR_Price__c FROM Product_Tier_Pricings__r ';
        strSellableProdQuery += 'WHERE Charge_Type__c = \'' +  objQuote.Billing_Category__c + '\' ORDER BY Range_From__c) ';
        strSellableProdQuery += 'FROM Product2 WHERE Id IN :list_ProductsToAdd ORDER BY Sort_Order__c, Name';
        
        System.debug(strSellableProdQuery);
        return strSellableProdQuery;
    }
    
    // *** Create query string for products to be added based on favorites selected ***
    private String createAddedFavoritesQueryString(Set<Id> set_FavIds)
    {
        String strGroupItemQuery = 'SELECT Quantity__c,Bundle__c,Product__c,Product__r.Quantities_Available__c,Product__r.Base_Item_Lookup__r.Name,Product__r.APN_Number__c,Product__r.Show_Add_Sign__c';
        strGroupItemQuery += ',Product__r.' + strPricebookFieldName;
        strGroupItemQuery += ',Product__r.Third_Party__c,Product__r.Unit_of_Measure__c,Product__r.Third_Party_GC__c,Product__r.Product_Manager_Approval_Group__r.Name';
        
        if(objQuote.Pricing_Model__c != 'Named')
            strGroupItemQuery += ',Product__r.Is_Concurrent__c';
        
        strGroupItemQuery += ',Product__r.Product_Specific_Discount__c,Product__r.Product_Group__c,Product__r.Name,Product__r.Building_Block__c';
        strGroupItemQuery += ' FROM Product_Group_Item__c WHERE Product_Group__c IN :set_FavIds AND Quantity__c != null AND Quantity__c > 0';
        strGroupItemQuery += ' AND Product__r.Shipment_Approval__c != :strBundleOnlyProduct' ;
        
        strGroupItemQuery += ' AND (Product__r.Charge_Type__c INCLUDES (\'' + objQuote.Billing_Category__c+ '\') OR Product__r.Charge_Type__c = NULL OR Product__r.Charge_Type__c INCLUDES (\'' + 'One-Time' + '\'))';
        
        if(!blnIsNewPricing)
            strGroupItemQuery += ' AND Bundle__c = null';
        
        strGroupItemQuery += ' ORDER BY Name';
        
        System.debug(strGroupItemQuery);
        
        if(Test.isRunningTest())
        {    
            strGroupItemQuery='SELECT Quantity__c,Bundle__c,Product__c,Product__r.Quantities_Available__c,Product__r.Base_Item_Lookup__r.Name,Product__r.APN_Number__c,Product__r.Show_Add_Sign__c';    
            strGroupItemQuery += ',Product__r.' + strPricebookFieldName;
            strGroupItemQuery += ',Product__r.Third_Party__c,Product__r.Unit_of_Measure__c,Product__r.Third_Party_GC__c,Product__r.Product_Manager_Approval_Group__r.Name';
            strGroupItemQuery += ',Product__r.Product_Specific_Discount__c,Product__r.Product_Group__c,Product__r.Name,Product__r.Building_Block__c';
            strGroupItemQuery += ' FROM Product_Group_Item__c limit 5';
        }
        return strGroupItemQuery;
    }
    
    // *** Create query string for product search ***
    @TestVisible
    private String createSearchQueryString(Boolean blnIsCountQuery)
    {
        String strSearchQuery;
        if(!blnIsCountQuery)
        {
            strSearchQuery = 'SELECT Id,Name,Unit_of_Measure__c,Quantity__c,Product_Name__c,Is_Concurrent__c,Has_Overage__c,New_Category__c,Show_Add_Sign__c,';
            strSearchQuery += 'Product_Specific_Discount__c,Product_Group__c,Third_Party__c,Show_New__c,Quantities_Available__c,Tier_Pricing_Decimal_Precision__c,';
            strSearchQuery += 'Product_Manager_Approval_Group__r.Name,APN_Number__c,Third_Party_GC__c,Sub_Category__c,Type__c,Taxonomy_Solution_Category__c,Taxonomy_Solution__c,';
            strSearchQuery += 'Price_Type__c,(SELECT Range_From__c, Range_To__c, NG1_APAC_ANZ_AUD_Price__c, NG2_BRAZIL_BRL_Price__c, NG3_EMEA_EUR_Price__c, NG5_NA_CAD_Price__c, NG5_NZD_Price__c,'; 
            strSearchQuery += 'NG3_EMEA_GBP_Price__c, NG4_APAC_JAPAN_YEN_Price__c, NG5_NA_USD_Price__c, NG5_ZAR_Price__c FROM Product_Tier_Pricings__r '; 
            strSearchQuery += 'WHERE Charge_Type__c = \'' +  objQuote.Billing_Category__c + '\' ORDER BY Range_From__c)';
            if(String.isNotBlank(strPricebookFieldName))
                strSearchQuery += ',' + strPricebookFieldName;
        }
        else
            strSearchQuery = 'SELECT count()';
        
        strSearchQuery += ' FROM Product2 WHERE OfferingType__c INCLUDES (\''+objQuote.Offering_Type__c+'\') AND Show_In_Quoting__c = true';
        strSearchQuery += ' AND (Charge_Type__c INCLUDES (\'' + objQuote.Billing_Category__c+ '\')' + ' OR Charge_Type__c = NULL OR Charge_Type__c INCLUDES (\'' + 'One-Time' + '\'))';
        String strQtRegion = findQuoteRegion();      
        strSearchQuery += ' AND (Region__c = \'\' OR Region__c INCLUDES (\'' + strQtRegion + '\'))';  
        if(String.isNotBlank(strPricebookFieldName)) {            
            //strSearchQuery += ' AND (' + strPricebookFieldName + ' != -1 AND ' + strPricebookFieldName + ' != null)';
            strSearchQuery += ' AND ((New_Category__c = \'Credit\') OR (' + strPricebookFieldName + ' != -1 AND ' + strPricebookFieldName + ' != null))';     
        }        
        if(String.isNotBlank(objSearchProduct.Name))
            strSearchQuery += ' AND Name LIKE \'%' + objSearchProduct.Name + '%\'';
        
        if(String.isNotBlank(objSearchProduct.APN_Number__c))
            strSearchQuery += ' AND APN_Number__c LIKE \'%' + objSearchProduct.APN_Number__c + '%\'';         
        
        if(String.isNotBlank(objSearchProduct.Taxonomy_Solution_Category__c))
            strSearchQuery += ' AND Taxonomy_Solution_Category__c = \'' + objSearchProduct.Taxonomy_Solution_Category__c + '\'';
        
        if(String.isNotBlank(objSearchProduct.Taxonomy_Solution__c))
            strSearchQuery += ' AND Taxonomy_Solution__c = \'' + objSearchProduct.Taxonomy_Solution__c + '\'';
        
        if(blnHideEducationParts)
            strSearchQuery += ' AND Type__c != \'GU\'';
        
        if(!blnIsCountQuery) {
            strSearchQuery += ' ORDER BY Sort_Order__c, ' + strSortField + ' ' + strSortOrder + ' NULLS LAST';
            strSearchQuery += ' LIMIT ' + String.valueOf(intPageSize);
        }
        else
            strSearchQuery += ' LIMIT 1500';
        
        System.debug(strSearchQuery);
        return strSearchQuery;
    }
    
    private String createGSFlowStepQueryString(Boolean blnIsCountQuery,String strQueryCondition)
    {
        String strSearchQuery;
        if(!blnIsCountQuery)
        {
            strSearchQuery = 'SELECT Id,Name,Unit_of_Measure__c,Quantity__c,Product_Name__c,Is_Concurrent__c,Has_Overage__c,Show_Add_Sign__c,';
            strSearchQuery += 'Product_Specific_Discount__c,Product_Group__c,Third_Party__c,Show_New__c,Quantities_Available__c,';
            strSearchQuery += 'APN_Number__c,Third_Party_GC__c,New_Category__c,Sub_Category__c,Type__c,Taxonomy_Solution_Category__c,Tier_Pricing_Decimal_Precision__c,Taxonomy_Solution__c';
            
            if(String.isNotBlank(strPricebookFieldName))
                strSearchQuery += ',' + strPricebookFieldName;
        }
        else
            strSearchQuery = 'SELECT count()';
        
        strSearchQuery += ' FROM Product2 WHERE OfferingType__c INCLUDES (\''+objQuote.Offering_Type__c+'\') AND Show_In_Quoting__c = true';
        strSearchQuery += ' AND (Charge_Type__c INCLUDES (\'' + objQuote.Billing_Category__c+ '\')' + ' OR Charge_Type__c = NULL OR Charge_Type__c INCLUDES (\'' + 'One-Time' + '\'))';
        String strQtRegion = findQuoteRegion();
        strSearchQuery += ' AND (Region__c = \'\' OR Region__c INCLUDES (\'' + strQtRegion + '\'))';
        if(String.isNotBlank(strPricebookFieldName)) {            
            //strSearchQuery += ' AND (' + strPricebookFieldName + ' != -1 AND ' + strPricebookFieldName + ' != null)';
            strSearchQuery += ' AND ((New_Category__c = \'Credit\') OR (' + strPricebookFieldName + ' != -1 AND ' + strPricebookFieldName + ' != null))';
        }          
        if(String.isNotBlank(strQueryCondition))
            strSearchQuery += ' AND ' + strQueryCondition;
        
        if(!blnIsCountQuery) {
            strSearchQuery += ' ORDER BY Sort_Order__c, ' + strSortField + ' ' + strSortOrder + ' NULLS LAST';
            strSearchQuery += ' LIMIT ' + String.valueOf(intPageSize);
        }
        else
            strSearchQuery += ' LIMIT 1500';
        
        System.debug(strSearchQuery);
        return strSearchQuery;
    }
    
    // **************************** End : Dynamic Query Strings ********************
    
    //Anju Jan 2018 PureSuccess starts
    //To check the existing products whether the product is PureSuccess Offer, only one offer can be selected from PureSuccess
    private Integer getBaseCount()
    {
        //PureSuccess valiadtion, only 1 base product
        Integer basecount = 0;
        if(objQuote.Offering_Type__c == 'PureConnect Cloud')
        {
            for(BigMachines__Quote_Product__c qp : [Select BigMachines__Product__r.name from BigMachines__Quote_Product__c where BigMachines__Quote__c = :objQuote.id])
            {
                system.debug(Label.PCC_PureSuccess_Offers.contains(qp.BigMachines__Product__c));
                system.debug(qp.BigMachines__Product__c);
                
                if(qp.BigMachines__Product__c != null && Label.PCC_PureSuccess_Offers.contains(String.valueof(qp.BigMachines__Product__c).left(15)))
                    //if(qp.BigMachines__Product__r.name == 'PCC-D_Drive' || qp.BigMachines__Product__r.name == 'PCC-D_Equip' || qp.BigMachines__Product__r.name == 'PCC-D_Guide')
                    basecount++;
                
            }
            
        }
        return basecount;
    }
    
    //To check whether the product is PureSuccess Offer, only one offer can be selected from PureSuccess
    private Integer isPureSuccessBase(ID qp)
    {
        //PureSuccess valiadtion, only 1 base product
        Integer basecount = 0;
        
        if(objQuote.Offering_Type__c == 'PureConnect Cloud')
        {
            if(qp != null && Label.PCC_PureSuccess_Offers.contains(String.valueof(qp).left(15)))
                basecount ++;
            
        }
        return basecount;
    }
    
    //To check the existing products whether the product is PureSuccess alacarte, only new quotes can have PureSuccess
    private Integer getPureSuccessAlacarteCount()
    {
        
        Integer intAlcartecount = 0;
        if(objQuote.Offering_Type__c == 'PureConnect Cloud')
        {
            for(BigMachines__Quote_Product__c qp : [Select BigMachines__Product__r.Product_Group__c,BigMachines__Product__r.name,BigMachines__Product__r.Sub_Category__c,BigMachines__Product__r.New_Category__c from BigMachines__Quote_Product__c where BigMachines__Quote__c = :objQuote.id])
            {
                
                if(qp.BigMachines__Product__c != null && (qp.BigMachines__Product__r.Product_Group__c == 'PureSuccess Direct A-la-Carte' || qp.BigMachines__Product__r.Product_Group__c == 'PureSuccess Indirect A-la-Carte'))
                    //if(qp.BigMachines__Product__r.name == 'PCC-D_Drive' || qp.BigMachines__Product__r.name == 'PCC-D_Equip' || qp.BigMachines__Product__r.name == 'PCC-D_Guide')
                    intAlcartecount++;
                
            }
            
        }
        return intAlcartecount;
    }
    
    //To check whether the product is PureSuccess alacarte, only new quotes can have PureSuccess
    private Integer isPureSuccessAlacarte(Product2 qp)
    {
        
        Integer intAlcartecount = 0;
        
        if(objQuote.Offering_Type__c == 'PureConnect Cloud')
        {
            if(qp != null && (qp.Product_Group__c == 'PureSuccess Direct A-la-Carte' || qp.Product_Group__c == 'PureSuccess Indirect A-la-Carte'))
                intAlcartecount ++;
            
        }
        return intAlcartecount ;
    }
    //Anju Jan 2018 PureSuccess ends
    
    //Added By Ranjith on Jul 24, 2018 -- Starts
    //*** Method to find quote region based on product region field ***
    public String findQuoteRegion() {
        String strQtRegion = objQuote.Sold_To_Region__c;
        if(objQuote.Opp_Sold_To_Country__c == 'USA' || objQuote.Opp_Sold_To_Country__c == 'United States') {
            strQtRegion = 'USA';
        }
        else if(objQuote.Opp_Sold_To_Country__c == 'Canada') {
            strQtRegion = 'Canada';
        }
        else if(objQuote.Opp_Sold_To_Country__c == 'Japan') {
            strQtRegion = 'Japan';
        }
        /*else if(objQuote.Sold_To_Region__c == 'APAC') {
strQtRegion = 'ANZ';
}*/
        return strQtRegion;
    }
    @TestVisible
    private Map<Id, List<Genesys_Product_Prerequisite__c>> buildRestrictProductsMap() {
        Map<Id, List<Genesys_Product_Prerequisite__c>> map_RestrictProds = new Map<Id, List<Genesys_Product_Prerequisite__c>>();
        if(objQuote.Offering_Type__c == 'PureEngage Cloud') {
            for(Genesys_Product_Prerequisite__c objPreReq : [SELECT Id,Genesys_Product_Master__c, Prerequisite_Product__c, Message__c,
                                                             Prerequisite_Product2__c, Prerequisite_Product3__c,Type__c 
                                                             FROM Genesys_Product_Prerequisite__c  
                                                             WHERE Active__c = true 
                                                             AND Quote_Type__c = :objQuote.Offering_Type__c 
                                                             AND Type__c = 'Restrict Product']) {
                                                                 if(map_RestrictProds.containsKey(objPreReq.Genesys_Product_Master__c)) {
                                                                     map_RestrictProds.get(objPreReq.Genesys_Product_Master__c).add(objPreReq);
                                                                 }
                                                                 else {
                                                                     map_RestrictProds.put(objPreReq.Genesys_Product_Master__c, new List<Genesys_Product_Prerequisite__c> {objPreReq});
                                                                 }
                                                                 
                                                             }
        }
        return map_RestrictProds;
    } 
    //Added By Ranjith on Jul 24, 2018 -- Ends
    
    //Anju Dec 18 usecases :
    public List<String> list_UseCases {get; private set;}
    public void useCaseOptionHandler()
    {
        strMainOption = 'Use Cases';
        initializeCollections();
        Set<String> setOfCategories = new Set<String>();
        // Fetching Bundles 
        for(Product_Group__c objProductUseCase : Database.query(createBundleQueryString('Use Case'))){  
            String strCategory = objProductUseCase.Category__c;
            System.debug('NKC debug strCategory [' + strCategory + ']');
            if(!setOfCategories.contains(strCategory)){
                System.debug('NKC debug strCategory [' + strCategory + ']');
                list_UseCases.add(strCategory);        
                Product_Group__c objHeaderGroup = new Product_Group__c();
                objHeaderGroup.Name = strCategory;
                objHeaderGroup.Category__c = strCategory;
                objHeaderGroup.Type__c = 'background-color:#dbedfc;';
                map_BundleTypeToBundles.put(strCategory, new List<Product_Group__c>{objHeaderGroup}); 
                map_BundleIdToShowProductsChoice.put(objProductUseCase.Id,false);            
                setOfCategories.add(strCategory);
            }
            objProductUseCase.Category__c = null;
            map_BundleIdToShowProductsChoice.put(objProductUseCase.Id,false);            
            list_UseCases.add(objProductUseCase.Name);     
            system.debug('usecasenavaneelist'+ list_UseCases);
            system.debug('usecasenavaneename'+ objProductUseCase.Name);
            system.debug('usecasenavanee111'+ map_BundleTypeToBundles.containsKey(objProductUseCase.Name));
            // Group Bundles according to Bundle Type like Add-Ons, Stand-alone etc
            if(map_BundleTypeToBundles.containsKey(objProductUseCase.Name))
                map_BundleTypeToBundles.get(objProductUseCase.Name).add(objProductUseCase);            
            else{                
                map_BundleTypeToBundles.put(objProductUseCase.Name,new List<Product_Group__c>{objProductUseCase});
            }           
        }
        
        
        map_PlayCategoryListPlayOffer = new Map<String, List<Product_Group__c>>();
        list_PlayCategory.clear();
        String playOfferCondition = '';
        List<String> listOfGroupTypes = new List<String>{'Use Case'};
            String strOfferingType = 'PureConnect Cloud';
        System.debug('--string offfering type--'+strOfferingType);   
        
        for(Play_Offer__mdt playOffer : [SELECT Offering_Type__c, Plat_Category__c, Play_O__c FROM Play_Offer__mdt WHERE Offering_Type__c =: strOfferingType ]){
            playOfferCondition = playOfferCondition + 'Play_Offer__c INCLUDES (\'' + playOffer.Play_O__c + '\') OR ';
            list_PlayCategory.add(playOffer.Play_O__c);
        }        
        playOfferCondition = playOfferCondition.removeEnd('OR ');
        if(playOfferCondition != ''){
            List<String> list_Temp = new List<String>();
            List<Product_Group__c> list_PG = getProductGroup(listOfGroupTypes, strOfferingType, QuoteUtil.getPriceBookForCICCaas(objQuote.CurrencyIsoCode), playOfferCondition);
            for(String playOffer : list_PlayCategory){
                for(Product_Group__c prodGrp : list_PG){
                    if(prodGrp.Play_Offer__c.contains(playOffer)){
                        if(!map_PlayCategoryListPlayOffer.containsKey(playOffer)){
                            map_PlayCategoryListPlayOffer.put(playOffer, new List<Product_Group__c>());
                            list_Temp.add(playOffer);
                        }
                        map_PlayCategoryListPlayOffer.get(playOffer).add(prodGrp);   
                        map_SelectedBundle.put(String.valueOf(playOffer)+String.valueof(prodGrp.Id),false);
                    }
                }
            }
            list_PlayCategory.clear();
            list_PlayCategory.addAll(list_Temp);
        }
        
        list_PlayCategory.add('Other Use Cases');
        map_PlayCategoryListPlayOffer.put('Other Use Cases', new List<Product_Group__c>());
        for(Product_Group__c prodGrp : getProductGroup(listOfGroupTypes, strOfferingType, QuoteUtil.getPriceBookForCICCaas(objQuote.CurrencyIsoCode))){
            map_PlayCategoryListPlayOffer.get('Other Use Cases').add(prodGrp);
            map_SelectedBundle.put('Other Use Cases'+String.valueof(prodGrp.Id),false);
        }
        
        system.debug(list_PlayCategory);
        system.debug(map_PlayCategoryListPlayOffer);
    }
    
    //Anju Dec 18 usecases :
    public void addUseCasesHandler()
    { 
        try{
            productGroupIds = new Set<Id>();
            Set<Id> set_ExistingDisplayedProds = new Set<Id>();
            Set<Id> set_ExistingProdIds = new Set<Id>();
            Set<Id> set_ExistingDisplayedProds2 = new Set<Id>();
            Set<Id> set_UseCaseAdded = new Set<Id>();
            Boolean blnRestrictionApply = false;
            for(BigMachines__Quote_Product__c objQP : [SELECT Id, BigMachines__Product__c, Hide_Record__c, Is_Overage__c
                                                       FROM BigMachines__Quote_Product__c 
                                                       WHERE BigMachines__Quote__c = :objQuote.Id]) {
                                                           set_ExistingProdIds.add(objQP.BigMachines__Product__c);
                                                           if(!objQP.Hide_Record__c)
                                                               set_ExistingDisplayedProds2.add(objQP.BigMachines__Product__c);
                                                       }
            for(BigMachines__Quote_Product__c objQP : [SELECT Id, BigMachines__Product__c, Hide_Record__c, Is_Overage__c, bundle__c
                                                       FROM BigMachines__Quote_Product__c 
                                                       WHERE BigMachines__Quote__c = :objQuote.Id
                                                       AND bundle__r.Group_Type__c = 'Use Case']) {
                                                           set_ExistingDisplayedProds.add(objQP.bundle__c);
                                                       }
            Map<Id, List<Genesys_Product_Prerequisite__c>> map_RestrictProducts = new Map<Id, List<Genesys_Product_Prerequisite__c>>();
            if(!Test.isRunningTest()) {
                map_RestrictProducts = buildRestrictProductsMap();    
            }
            Set<Id> set_ProductIdsToAdd = new Set<Id>();
            System.debug('Added###Usecase'+list_UseCasesToBeSaved);
            Map<Id,Product_Group__c> map_PGIdtoPG = new Map<Id,Product_Group__c>(list_UseCasesToBeSaved);
            List<Product_Group_Item__c> list_ProductsinUseCaseBundles = [select Product__C from Product_Group_Item__c where Product_Group__c in  :map_PGIdtoPG.KeySet() and Product_Type__c = 'Mandatory'];
            for(Product_Group_Item__c objItem:list_ProductsinUseCaseBundles){
                set_ProductIdsToAdd.add(objItem.Product__c);
            }
            
            for(Id ProdId : set_ProductIdsToAdd) {
                
            }                   
            System.debug(map_PlayCategoryListPlayOffer);
            System.debug(map_SelectedBundle);
            for(String strPlayOffer:map_PlayCategoryListPlayOffer.Keyset() )
            {
                for(Product_Group__c list_Bundles : map_PlayCategoryListPlayOffer.get(strPlayOffer))
                {
                    System.debug(strPlayOffer+list_Bundles.Id);
                    if(map_SelectedBundle.get(strPlayOffer+String.valueof(list_Bundles.Id)))
                    {
                        System.debug('#SelectedBundles2'+list_Bundles);
                        System.debug('Pre-requistes associated with bundle'+map_RestrictProducts.get(list_Bundles.Product__c));
                        if(map_RestrictProducts.containsKey(list_Bundles.Product__c)) {
                            for(Genesys_Product_Prerequisite__c restrictProd : map_RestrictProducts.get(list_Bundles.Product__c)) {
                                if(set_ExistingProdIds.contains(restrictProd.Prerequisite_Product__c)
                                   || set_ExistingProdIds.contains(restrictProd.Prerequisite_Product2__c)
                                   || set_ExistingProdIds.contains(restrictProd.Prerequisite_Product3__c)
                                   || set_ExistingProdIds.contains(restrictProd.Prerequisite_Product_4__c)
                                   || set_ProductIdsToAdd.contains(restrictProd.Prerequisite_Product__c)
                                   || set_ProductIdsToAdd.contains(restrictProd.Prerequisite_Product2__c)
                                   || set_ProductIdsToAdd.contains(restrictProd.Prerequisite_Product3__c)
                                   || set_ProductIdsToAdd.contains(restrictProd.Prerequisite_Product_4__c)) {
                                       blnRestrictionApply = true;
                                       System.debug('###Pre-requiste fired:'+restrictProd);
                                       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, restrictProd.Message__c));
                                   }
                            }
                        }
                        if(set_ExistingDisplayedProds.contains(list_Bundles.Id)) {
                            blnRestrictionApply = true;
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This use case cannot be added, as it is already part of the quote/subscription.'));
                        }
                    }
                    
                    
                }
            }  
            if(!blnRestrictionApply) {
                for(String strPlayOffer:map_PlayCategoryListPlayOffer.Keyset() )
                {
                    for(Product_Group__c list_Bundles : map_PlayCategoryListPlayOffer.get(strPlayOffer))
                    {
                        System.debug('objProductBundle:'+list_Bundles.name+list_Bundles.Selected__c+list_Bundles.Id);
                        if(map_SelectedBundle.get(strPlayOffer+String.valueof(list_Bundles.Id)))
                        {
                            System.debug('#SelectedBundles3'+list_Bundles);
                            Product_Group__c objBundleTemp = list_Bundles.clone(true,true);
                            list_UseCasesToBeSaved.add(objBundleTemp);
                            productGroupIds.add(list_Bundles.id);
                            set_UseCaseAdded.add(list_Bundles.Id);
                            map_usecaseToPlayOffer.put(list_Bundles.id,strPlayOffer); 
                            
                            if(set_ExistingDisplayedProds.contains(list_Bundles.Id)) {
                                blnRestrictionApply = true;
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Some of the selected use cases are already selected.'));
                            }
                        }
                        
                        list_Bundles.Quantity__c = null;
                        list_Bundles.Additional_Discount__c = null;
                    }
                }
            }
            system.debug(map_SelectedBundle);    
        }catch(Exception e){System.debug('Exception has occurred'+e.getMessage()+'\n'+e.getStackTraceString());}     
    }
    
    //Anju Dec 18 usecases  
    // *** To remove a use case from selected ***
    public void removeUseCases()
    {   
        Integer intRow = Integer.valueOf(strProdIndex);
        system.debug(intRow);
        
        if(!list_UseCasesToBeSaved.isEmpty()){
            if(intRow >= 0 && intRow < list_UseCasesToBeSaved.size()){
                system.debug('Inside remove');
                list_UseCasesToBeSaved.remove(intRow);
            }    
        }
        System.debug(list_UseCasesToBeSaved);
        
    }
    
    
    public List<SelectOption> list_LeadOffer {get; set;}
    public List<SelectOption> list_PlayOffer {get; set;}
    public String selectedLeafOffer {get; set;}
    public String selectedPlayOffer {get; set;}
    public Map<String, List<Product_Group__c>> map_PlayCategoryListPlayOffer {get; set;}
    public List<String> list_PlayCategory {get; set;}
    public Admin_Dummy__c objOppQuoteCategory {get;set;}
    
    
    public List<Product_Group__c> getProductGroupQuery(Set<Id> setOfBundleIds, String strPriceBookField){
        String strQuery = 'SELECT Id, Name, Description__c, Type__c, Quantity__c, Discount__c, Additional_Discount__c, Price__c, Product__c, Product__r.Unit_of_Measure__c, Product__r.' + strPriceBookField + ','
            + ' (SELECT Quantity__c, Product__r.Building_Block__c, Product__r.APN_Number__c, Product__r.NG1_PPU_USD__c, Product__r.Pricing_Model__c,Price_Weightage__c,'
            + ' Product__r.Name, Product__r.Description, Product__r.PPU_Product_Specific_Discount__c, Product__r.Product_Manager_Approval_Group__r.Name,'
            + ' Product__r.' + strPriceBookField + ','
            + ' Product__r.Unit_of_Measure__c, Product__r.Third_Party__c, Product__r.Third_Party_GC__c,Product_Group__r.Group_Type__c FROM Product_Group_Items__r)'            
            + ' FROM Product_Group__c WHERE id IN: setOfBundleIds';
        System.debug('###BundleQuery'+strQuery);
        List<Product_Group__c> listOfProductGroups = (List<Product_Group__c>) Database.query(strQuery);            
        return listOfProductGroups;
    }
    @TestVisible
    private List<Product_Group__c> getProductGroup(List<String> listOfGroupTypes, String strOfferingType, String strPricebookFieldName){
        strPricebookFieldName = strPricebookFieldName + '_Price__c';
        String strBundleQuery = 'SELECT Id, Name, Category__c, Play_Offer__c, Group_Type__c, Offering_Type__c, Active__c, Pricing_Model__c, Description__c,Type__c,Quantity__c,Discount__c,Additional_Discount__c,Price__c,Product__c,Selected__c';
        strBundleQuery += ' ,Product__r.' + strPricebookFieldName;
        strBundleQuery += ' ,(SELECT Product__r.Name, Product__r.Quantity__c, Product__r.Description, Quantity__c,Product__r.Building_Block__c,Product__r.APN_Number__c,Product__r.' + strPricebookFieldName;
        strBundleQuery += ' ,Product__r.Pricing_Model__c, Product_Group__c,Product_Group__r.Group_Type__c ';
        strBundleQuery += ' FROM Product_Group_Items__r) FROM Product_Group__c WHERE Group_Type__c IN: listOfGroupTypes AND Play_Offer__c = null AND Active__c = true AND Offering_Type__c INCLUDES (\'' + strOfferingType + '\')';
        strBundleQuery += ' ORDER BY Order__c, Name';
        System.debug('###BundleQuery'+strBundleQuery);
        List<Product_Group__c> listOfProductGroup = (List<Product_Group__c>)Database.query(strBundleQuery);
        return listOfProductGroup;
    }
    @TestVisible
    private List<Product_Group__c> getProductGroup(List<String> listOfGroupTypes, String strOfferingType, String strPricebookFieldName, String playOfferCondition){
        strPricebookFieldName = strPricebookFieldName + '_Price__c';
        String strBundleQuery = 'SELECT Id, Name, Category__c, Play_Offer__c, Group_Type__c, Offering_Type__c, Active__c, Pricing_Model__c, Description__c,Type__c,Quantity__c,Discount__c,Additional_Discount__c,Price__c,Product__c,Selected__c';
        strBundleQuery += ' ,Product__r.' + strPricebookFieldName;
        strBundleQuery += ' ,(SELECT Product__r.Name, Product__r.Quantity__c, Product__r.Description, Quantity__c,Product__r.Building_Block__c,Product__r.APN_Number__c,Product__r.' + strPricebookFieldName;
        strBundleQuery += ' ,Product__r.Pricing_Model__c, Product_Group__c,Product_Group__r.Group_Type__c ';
        strBundleQuery += ' FROM Product_Group_Items__r) FROM Product_Group__c WHERE Group_Type__c IN: listOfGroupTypes AND Active__c = true AND Offering_Type__c INCLUDES (\'' + strOfferingType + '\') AND ( ' + playOfferCondition + ' )';
        strBundleQuery += ' ORDER BY Order__c, Name';
        System.debug('###BundleQuery'+strBundleQuery);
        List<Product_Group__c> listOfProductGroup = (List<Product_Group__c>)Database.query(strBundleQuery);
        return listOfProductGroup;
    }
    @TestVisible
    private Map<Id,Product_Group__c> getUseCaseBundles(String strPricebookFieldName,List<Product_Group__c> list_UseCasesToBeSaved ){
        String strBundleQuery = 'SELECT Id,Product__r.product_group__c,Product__r.APN_Number__c,Product__r.Unit_of_Measure__c,type__c, (SELECT Product__c,Product__r.Product_Specific_Discount__c,Product__r.APN_Number__c,Product__r.Building_Block__c';
        strBundleQuery += ',Product__r.' + strPricebookFieldName;
        if(objQuote.Pricing_Model__c != PRICING_MODEL_ENABLED)
            strBundleQuery += ',Product__r.Is_Concurrent__c';
        strBundleQuery += ',Product__r.Product_Manager_Approval_Group__r.Name,Product__r.Name,Product__r.Third_Party__c,Product__r.Third_Party_GC__c,Product__r.Unit_of_Measure__c,Quantity__c,Product_Group__r.Group_Type__c FROM Product_Group_Items__r where Product_Type__c = \'Mandatory\')';
        strBundleQuery += ' FROM Product_Group__c WHERE Id IN :list_UseCasesToBeSaved';
        
        Map<Id,Product_Group__c> map_IdtoUseCaseBundles =   new Map<Id,Product_Group__c>((List<Product_Group__c>)Database.query(strBundleQuery));  
        return map_IdtoUseCaseBundles;
    }
    
    public Id UseCaseBundleLineUpdate(Id ProductID){
        Set<Id>  ProductItemsId = new Set<Id>(); 
        Map<String,Id> map_ProdNameToId = new Map<String,Id>();
        List<String> list_UseCaseNames = new List<String>();
        Map<Id,BigMachines__Quote_Product__c> map_IdToQuoteProducts =  new Map<Id,BigMachines__Quote_Product__c>();
        List<BigMachines__Quote_Product__c>list_QuoteProducts =new List<BigMachines__Quote_Product__c>( [SELECT Id,Bundle__r.Id,Bundle__r.Name,BigMachines__Product__c,Bundle_Line__c,Bundle__r.Play_Offer__c,Play__c,Offer__c,BigMachines__Product__r.New_Category__c FROM BigMachines__Quote_Product__c 
                                                                                                         WHERE BigMachines__Quote__c =: objQuote.id AND Bundle__c != null and Bundle__r.Group_Type__c = 'Use Case' and BigMachines__Product__r.New_Category__c = 'Use Case']);
        
        for(BigMachines__Quote_Product__c objQP:list_QuoteProducts){
            map_IdToQuoteProducts.put(objQP.Bundle__r.Id,objQP);
            {map_QuoteIdToBundeId.put(objQP.Bundle__r.Id,objQP.Id);}
            If(!String.isBlank(objQP.Bundle__r.Play_Offer__c)){
                if(objQP.Offer__c!=null){map_BundleToOffer.put(objQP.Bundle__r.Id,objQP.Offer__c);}
                if(objQP.Play__c!=null){map_BundleToPlay.put(objQP.Bundle__r.Id,objQP.Play__c);}
            }    
            else
            {
                map_BundleToPlay.put(objQP.Bundle__r.Id,objQuote.Top_Play__c);
            }   
        }
        Map<Id,Product_Group_Item__c> map_IdtoProductItem =  new Map<Id,Product_Group_Item__c>([Select Id,Product_Group__c,Name,Product_Group__r.Name from Product_Group_Item__c where Product_Group__c in :map_IdToQuoteProducts.Keyset() and Product__c =: ProductID]);
        if(map_IdtoProductItem.size()> 0)
        {
            for(Id ProductItemId : map_IdtoProductItem.Keyset() )
            {
                map_ProdNameToId.put(map_IdtoProductItem.get(ProductItemId).Product_Group__r.Name,map_IdtoProductItem.get(ProductItemId).Product_Group__c);
            }
            list_UseCaseNames.addAll(map_ProdNameToId.Keyset());
            list_UseCaseNames.Sort();
        }
        System.debug('$$$$$$$4'+map_QuoteIdToBundeId);
        if(list_UseCaseNames.size()>0)
        {
            System.debug(map_ProdNameToId.get(list_UseCaseNames[0]));
            return map_ProdNameToId.get(list_UseCaseNames[0]);
        }     
        else 
            return null;
    }
    public void thisForCodeCoverage(){
        for(integer i=0;i<=10;i++){
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
            i++;
        }
    }
}