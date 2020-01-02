// Naresh Kumar  10/31/2017 
public without sharing class ConfigurationControllerSubscription
{
    // List of 
    public List<String> list_Categories {get; private set;}
    // List of Taxonomy solutions 
    public List<String> listOfTaxonomySolutions {get; private set;}
    // List of Taxonomy solutions
    public List<String> listOfProductFinancials {get; private set;}
    // Map of Category to List of Building Blocks
    public Map<String,List<String>> map_CategoryToBuildingBlocks {get; private set;}
    // Map of Category to List of Taxonomy Categories
    public Map<String,List<String>> mapOfTaxonomyCategories {get; private set;}
    // Map of Product Financials
    public Map<String, List<String>> mapOfTaxonomyProductFinancial {get; private set;}    
    // Map of Building Blocks to List of Base Items/Products
    public Map<String,List<ProductWrapper>> map_BuildingBlockToProducts {get; set;}
    // Map of Versions available string and list of drop-down options for main Configurator
    public Map<String,List<SelectOption>> map_VersionsToSelectOptions {get; private set;}
    // Map of Quantities available string and list of drop-down options for main Configurator (Audio Codes)
    public Map<String,List<SelectOption>> map_QuantitiesToSelectOptions {get; private set;}
    // Quote Products on right hand panel which will be created on 'save'
    public List<BigMachines__Quote_Product__c> list_QuoteProductsToBeCreated {get; set;}
      public integer intLineNumber; //-Navaneetha Nov 28th 2019 - Used to track the line number for the quote product level- 
    // Category selected (All Products tab)
    public String strSelectedCategory {get; set;}
    // Taxonomy Category selected (All Products tab)
    public String strSelectedTaxonomyCategory {get; set;}
    public string strSelectedBuildingBlock {get;set;}
    // Taxonomy Category Solution
    public String strSelectedTaxonomyCategorySolution {get; set;}
    // Product financials
    public String strProductFinancial {get; set;}
    // Bundles on right hand panel which will be created on 'save'
    public List<Product_Group__c> list_BundlesToBeSaved {get; set;}
    public List<Product_Group__c> list_PureSuccessToBeSaved {get; set;}
    public List<Product2> list_OfAlaCarteToBeSaved {get; set;}
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
    public String strPricebookFieldName {get; private set;}
    // Name of Applicatble field
    @TestVisible public String priceBookFieldName {get; private set;}    
    // Option/tab selected in Configurator
    public String strMainOption {get; private set;}
    // Index of Product/Bundle being removed from right hand panel
    public String strProdIndex {get; set;}
    // To indicate if a favourite is being created. Show save and cancel buttons
    public Boolean blnShowFavSaveOptions {get; private set;}
    // Favourite being created
    public Product_Group__c objFavToBeSaved {get; set;}
    @TestVisible public Boolean blnIsGuideAdded {get; private set;}
     @TestVisible public Boolean blnIsDriveAdded {get; private set;}    
    // Product Search query string
    String strProductSearchQuery;
    transient String strQuoteId;
    transient String strLandingTab;
    // Multiplier for different pricing models
    Decimal decPricingMultiplier = 1;
    
    // List of Bundle Types
    public List<String> list_UseCases {get; private set;}
    public List<String> list_PureSuccess {get; private set;}
    public List<String> list_AlCarte {get; private set;}
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
    public List<Product_Group_Item__c> list_OfAlaCarte {get; set;}
    public String strProductType {get; set;}
    public String strALaCarte {get; set;}
    
    // To indicate if quote is locked or not
    public Boolean blnIsQuoteUnLocked {get; private set;}
    // The product object for all search fields on Product Search
    public Product2 objSearchProduct {get; set;}
    // The search results being currently displayed
    public List<Product2> list_SearchProducts {get; set;}
    public String searchProductStr {get; set;}
    
    // **** For Pagination ****   
    @testVisible public Integer intPageNum {get; private set;}
    public Integer intPageSize {get; private set;}
    public Integer intTotalNoOfRecords {get; private set;}
    
    //*** Sorting related data for product search results ***
    public String strSortField {get; private set;}
    public String strSortFieldSelected {get; set;}
    public String strSortOrder {get; private set;}
    
    // Product Types excluded from Product Search
    final Set<String> set_ExcludedTypes = new Set<String>{'Fees','Flex Care','Genesys Care'};
        // Favourites of the running user
        public List<FavoriteWrapper> list_Favourites {get; private set;}
    // To store id of favourite being expanded/collapsed and being deleted
    public String strFavId {get; set;}
    //To store selected base item (on which version changed)
    public String selectedBaseItemId {get;set;}
    //To store selected version 
    public String selectedVersion {get;set;}
    //To store selected version 
    public String defaultVersion {get;set;}
    //To help Skip version reloading 
    //Map will hold maturity values for all product versions
    public Map<String, String> mapOfBaseVersionVsMaturity {get;set;}
    //For showing EMEA training unit error when quote is mixed with license products.
    public boolean show_emea_training_error{get;set;}
    // ECD March 2019 Dynamic display of decimal precision based on product setting
    public Map<Id, Integer> mapProductIdToDecimalPrecision {get; private set;}
    
    // To indicate whether this quote use old or new pricing
    public Boolean blnIsNewPricing {get; private set;}
    // Products with notification messages to be shown on click of save button
    public List<ConfirmationWrapper> list_NotificationProducts {get; private set;}
    
    public static final Decimal PRICE_MULTIPLIER = 1;
     public static Decimal partnerDiscountY1 {get; private set;}
     public static Decimal partnerDiscountY2 {get; private set;}
    public Boolean blnShowBaseAndPureSuccessPackage {get; private set;}
    public Boolean isSmallMediumCenter {get; private set;}
    
    //To load/unload the product table 
    // Added by Ashish (18/07/2018)
    
    //Stores pricing model
    public String selectedPricingModel {get;set;} 
    public List<String> list_BundleTypes {get; private set;}
    public Map<String, Boolean> map_CampaignsIdProductLoad {get; private set;}
    public Map<String, Boolean> map_CampaignsIdProductSubLoad {get; private set;}
    public Map<String, Boolean> map_CampaignsIdProductLABLoad {get; private set;}
    public Map<String, Boolean> map_CampaignsIdProductHALoad {get; private set;}
    public Map<String, Boolean> map_CampaignsIdProductOptLoad {get; private set;}
    
    //Added by Anshul
    public map<id,boolean> errormap{get;set;}
    public map<id,string> errormessage{get;set;}
    public Boolean errorFlag{get;set;}
    public string ChkMapKey{get;set;}
    public Map<String, String> map_ProductGrpIdPlayOffer;
    public set<Id> ProductId_set {get; set;}
     
    public Map<String, List<PlayOfferWrapper>> map_PlayCategoryListPlayOffer {get; set;}
    public List<String> list_PlayCategory {get; set;}
    // Wrapper class for each Notification Message
    public class ConfirmationWrapper
    {
        public Boolean blnIsSelected {get; set;}
        public Product2 objProd {get; private set;}
        public ConfirmationWrapper()
        {
            blnIsSelected = false;
        }
    }
    String strBundleOnlyProduct;
    List<CurrencyType> currentCurreny;
    Set<Id> productGroupIds {get;set;}
    // Wrapper class for each Favourite line
    public class FavoriteWrapper
    {
        public Boolean blnIsSelected {get; set;}
        public Product_Group__c objFavorite {get; private set;}
        public Boolean blnShowItems {get; private set;}
        public List<Product_Group_Item__c> list_Bundles {get; private set;}
        public List<Product_Group_Item__c> list_Products {get; private set;}
        //public List<Product_Group_Item__c> list_Campaigns {get;private set;}
        public FavoriteWrapper()
        {
            blnIsSelected = blnShowItems = false;
        }
    }
    
      
    // To indicate if save was successful or there was some error
    public String strIsSaveSuccessful {get; set;}
    public Boolean blnShowConfirmPanel {get; private set;}
    
    // *** Constructor ***
    public ConfigurationControllerSubscription()
    {
        strQuoteId = ApexPages.currentPage().getParameters().get('id');
        strLandingTab = ApexPages.currentPage().getParameters().get('tab');
        
        // Added by Ashish (18/07/2018)
        map_CampaignsIdProductLoad = new Map<String, Boolean>();
        map_CampaignsIdProductSubLoad = new Map<String, Boolean>();
        map_CampaignsIdProductLABLoad = new Map<String, Boolean>();
        map_CampaignsIdProductHALoad = new Map<String, Boolean>();
        map_CampaignsIdProductOptLoad = new Map<String, Boolean>();
        ProductId_set = new set<Id>();
        list_PlayCategory = new List<String>();
        initializeData();
    }
    
    // *** To initialize data for the Configurator ***
    void initializeData()
    {
        blnShowBaseAndPureSuccessPackage = true;
        objQuote = new BigMachines__Quote__c();
        list_QuoteProductsToBeCreated = new List<BigMachines__Quote_Product__c>();
        list_BundlesToBeSaved = new List<Product_Group__c>();     
        list_PureSuccessToBeSaved = new List<Product_Group__c>();
        list_OfAlaCarteToBeSaved = new List<Product2>();
        list_CampaignsToBeSaved = new List<BigMachines__Quote_Product__c>();
        map_campaigntomainproduct = new Map<id,BigMachines__Quote_Product__c>();
        //  Bundle_Product_Approval = Item can only be sold as part of a bundle
        strBundleOnlyProduct = Label.Bundle_Product_Approval;
        strPricebookFieldName = '';
        isSmallMediumCenter = false;
        objSearchProduct = new Product2(RecordTypeId=(Id)Label.Base_Item_RecordTypeId);
        currentCurreny = [SELECT ConversionRate FROM CurrencyType WHERE ISOCode =: objQuote.currencyIsoCode];
        // Setting default page size to 30 for search results
        intPageSize = 30;
        strSortField = 'Name';
        strSortOrder = 'ASC';
        blnShowFavSaveOptions = blnIsQuoteUnLocked = blnIsNewPricing = blnShowConfirmPanel = false;
        mapProductIdToDecimalPrecision = new Map<Id, Integer>();

        // Added by Ashish (18/07/2018)
        selectedPricingModel = 'All';
        
        // Fetching Quote
        List<BigMachines__Quote__c> list_Temp = [SELECT Id,Top_Play__c,Offer__c,Name,New_Price_Book__c,Pricing_Model__c,BigMachines__Status__c,Show_Genesys_Care_Tab__c,
                                                 Sold_To_Name__r.Country__r.PSRDP_Region__c,CurrencyISOCode,Quote_Opportunity_Type__c,Sold_To_Region__c,
                                                 BigMachines__Opportunity__r.BusinessPartner__r.Partner_Tier__c, Offering_Type__c, Keep_the_existing_estate_on_Perpetual__c,
                                                 BigMachines__Opportunity__r.Type, BigMachines__Opportunity__r.Direct_Indirect_Sale__c, Multi_Year_Quote__c,
                                                 Product_Version__c, End_User_ID__c, Amendment_For__r.PureSuccess_Offer__c, Offering_Feature__c 
                                                 FROM BigMachines__Quote__c WHERE Id = :strQuoteId];
        system.debug('navanee&&&'+ list_Temp);
        
        if(list_Temp.size() > 0)
        {
            objQuote = list_Temp[0];
                        
            //if(objQuote.Quote_Opportunity_Type__c == 'New Pricing')
                blnIsNewPricing = true;
            
            isSmallMediumCenter = list_Temp[0].Offering_Feature__c != null && list_Temp[0].Offering_Feature__c.contains('PureConnect Small Medium') ? true : false;

            blnIsQuoteUnLocked = isQuoteUnLocked(objQuote.BigMachines__Status__c);
             intLineNumber = [select count() from BigMachines__Quote_Product__c where BigMachines__Quote__c = :strQuoteId and Line_Number__c not in (0,100,9999) ];
        if(String.isNotBlank(objQuote.New_Price_Book__c))
            {                
                strPricebookFieldName = objQuote.New_Price_Book__c + '_Price__c';
                // Fetching Pricing Multiplier from Custom Settings based on Pricing Model
                /*
                if(objQuote.Pricing_Model__c == 'Concurrent')
                    decPricingMultiplier = Global_Configuration_Settings__c.getOrgDefaults().Concurrent_Pricebook_Multiplier__c;
                else if(objQuote.Pricing_Model__c == 'Named User Pricing')
                    decPricingMultiplier = Global_Configuration_Settings__c.getOrgDefaults().Named_User_Pricing_Multiplier__c;
                else if(objQuote.Pricing_Model__c == 'Branch Office')
                    decPricingMultiplier = Global_Configuration_Settings__c.getOrgDefaults().Branch_Office_Multiplier__c;
                */
            }   
            if(objQuote.Multi_Year_Quote__c){
                List<Partner_Discount__c> listOfPartnerDiscounts = [SELECT Discount__c FROM Partner_Discount__c WHERE
                                                               Account__c =: objQuote.Sold_To_Name__c AND Type__c =: objQuote.Offering_Type__c]; 
                if(!listOfPartnerDiscounts.isEmpty()){
                     partnerDiscountY1 = listOfPartnerDiscounts[0].Discount__c;
                    if(listOfPartnerDiscounts.size() > 1)
                        partnerDiscountY2 = listOfPartnerDiscounts[1].Discount__c;
                }
                
            }
        }
        // Land on Product Search if landing tab is specified as 'Search' in URL
        if(String.isNotBlank(strLandingTab) && strLandingTab == 'search')
            productSearchOptionHandler();
        else
        {
            // Default landing option should be All products
            Option2();
        }        
        if((objQuote.BigMachines__Opportunity__r.Type == 'Existing Business - Cross Sell' 
            || objQuote.BigMachines__Opportunity__r.Type == 'Existing Business - Expansion') && !objQuote.Keep_the_existing_estate_on_Perpetual__c)
            blnShowBaseAndPureSuccessPackage = false;
        else
            blnShowBaseAndPureSuccessPackage = true;
        
        if(objQuote.Amendment_For__r.PureSuccess_Offer__c == 'Drive' || objQuote.Amendment_For__r.PureSuccess_Offer__c == 'Equip'
           || objQuote.Amendment_For__r.PureSuccess_Offer__c == 'Guide' || objQuote.Amendment_For__r.PureSuccess_Offer__c == 'Partner PureSuccess')
            blnShowBaseAndPureSuccessPackage = true;    
    }

    public static Double convertAndUpdatePrice(Decimal price, BigMachines__Quote__c quote, Product2 product, List<CurrencyType> currentCurreny){
        String productType = product.Type__c;        
        Double updatedPrice = price;
        System.debug('NKC debug updatedPrice ['+ updatedPrice +']');
        
        if(!currentCurreny.isEmpty()){
            updatedPrice = updatedPrice * currentCurreny[0].ConversionRate;     
        }        
        System.debug('NKC debug updatedPrice ['+ updatedPrice +']');
        /*
        Decimal percentage = 100;
        if(productType != null && productType == 'Product'){
            percentage = Decimal.valueOf(Label.PPU_Product_Type_Percentage.split(';')[0]);
        }        
        else if(productType != null && productType == 'HA'){
            percentage = Decimal.valueOf(Label.PPU_Product_Type_Percentage.split(';')[1]);
        }        
        else if(productType != null && productType == 'LAB'){
            percentage = Decimal.valueOf(Label.PPU_Product_Type_Percentage.split(';')[2]);
        }        
        System.debug('NKC debug percentage ['+ percentage +']');
        updatedPrice = (updatedPrice * percentage) / 100;
        System.debug('NKC debug updatedPrice ['+ updatedPrice +']');
        */
        return updatedPrice;
    }
    
    // *** To initialize all collections as necessary to keep view state light ***
    private void initializeCollections()
    {
        // All Products
        map_CategoryToBuildingBlocks = new Map<String,List<String>>();
        mapOfTaxonomyCategories = new Map<String,List<String>>();
        
        map_BuildingBlockToProducts = new Map<String,List<ProductWrapper>>();
        mapOfTaxonomyProductFinancial = new Map<String, List<String>>();
        list_Categories = new List<String>();
        listOfTaxonomySolutions = new List<String>();
        listOfProductFinancials = new List<String>();
        map_VersionsToSelectOptions = new Map<String,List<SelectOption>>();
        //map_VersionsToSelectOptions_old = new Map<String,List<SelectOption>>();
        map_QuantitiesToSelectOptions = new Map<String,List<SelectOption>>();
        
        // Bundles
        list_BundleTypes = new List<String>();
        list_UseCases = new List<String>();
        list_PureSuccess = new List<String>();
        list_AlCarte = new List<String>();
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
        list_OfAlaCarte = new List<Product_Group_Item__c>();
        
        // Product Search
        list_SearchProducts = new List<Product2>();
        
        // Favourites
        list_Favourites = new List<FavoriteWrapper>();
    }
    
    // *** To load Product Categories and Building blocks from Custom Settings ***
    public void loadCategoriesAndBlocks()
    {
        /*if(blnIsNewPricing)
{*/
        List<Category_Building_Block_Mapping__c> list_Settings = Category_Building_Block_Mapping__c.getAll().values();
        // Sorting Categories based on Sort Order specified in Settings. Names are 001,002.. etc to ensure correct sort.
        list_Settings.sort();
        for(Category_Building_Block_Mapping__c objSetting : list_Settings)
        {
          if(objQuote.Quote_Opportunity_Type__c == 'Old Pricing' && objSetting.Category__c != null 
            && objSetting.Category__c.contains('Branch Office'))
            continue;
            list_Categories.add(objSetting.Category__c);
            List<String> list_BuildingBlocks = objSetting.Building_Blocks__c.split(';');
            list_BuildingBlocks.sort();           
            map_CategoryToBuildingBlocks.put(objSetting.Category__c,list_BuildingBlocks);
        }
                /*}
        else
        {
        List<Tab_Section_Mapping__c> list_Settings = Tab_Section_Mapping__c.getAll().values();
        // Sorting Tabs based on Sort Order specified in Settings. Names are 001,002.. etc to ensure correct sort.
        list_Settings.sort();
        for(Tab_Section_Mapping__c objSetting : list_Settings)
        {
        list_Categories.add(objSetting.Tab__c);
        List<String> list_BuildingBlocks = objSetting.Sections__c.split(';');
        list_BuildingBlocks.sort();
        map_CategoryToBuildingBlocks.put(objSetting.Tab__c,list_BuildingBlocks);
        }
        }*/
    }
    
    // *** 'All Products' option in tab panel ***
    public void Option2()
    {
        strMainOption = 'Option2';
        initializeCollections();
        //loadCategoriesAndBlocks();
        loadTaxonomySolCategoryAndSol();
        strSelectedCategory = list_Categories[0];
        changeCategory();
    }
    
    // *** To handle change of category under 'All Products' ***
    public void changeCategory()
    {
        if(strSelectedTaxonomyCategorySolution== 'All')
            strSelectedTaxonomyCategory = 'All';
        else
            strSelectedTaxonomyCategorySolution = mapOfTaxonomyCategories.get(strSelectedCategory)[0];        
       
    }
    
    private void loadTaxonomySolCategoryAndSol(){
        list_Categories.clear();    
        if(objQuote.Offering_Type__c == 'PureEngage Subscription'){
            List<Taxonomy_Sol_Category_And_Taxonomy_Sol__c> listOfCategories = Taxonomy_Sol_Category_And_Taxonomy_Sol__c.getAll().values();
            listOfCategories.sort();
            for(Taxonomy_Sol_Category_And_Taxonomy_Sol__c eachRecord : listOfCategories){
                list_Categories.add(eachRecord.Name);
                List<String> listOfTaxonomySolutionsCategories = eachRecord.Taxonomy_Solution__c.split(';');
                listOfTaxonomySolutionsCategories.sort();
                mapOfTaxonomyCategories.put(eachRecord.Name, listOfTaxonomySolutionsCategories);
            }
        }
        //PureConnect Subscription
        else{
            List<OnPremise_CIC_Category_and_Subcategory__c> listOfCategories = OnPremise_CIC_Category_and_Subcategory__c.getAll().values();
            listOfCategories.sort();
            for(OnPremise_CIC_Category_and_Subcategory__c eachRecord : listOfCategories){
                list_Categories.add(eachRecord.Name);
                if(eachRecord.Sub_Category__c == null)
                    continue;
                List<String> listOfTaxonomySolutionsCategories = eachRecord.Sub_Category__c.split(';');
                listOfTaxonomySolutionsCategories.sort();
                mapOfTaxonomyCategories.put(eachRecord.Name, listOfTaxonomySolutionsCategories);
            }
        }
        if(!list_Categories.isEmpty()){
            strSelectedTaxonomyCategory = list_Categories[0];
            showTaxonomySolutions();
            if(!listOfTaxonomySolutions.isEmpty()){
                strSelectedTaxonomyCategorySolution = listOfTaxonomySolutions[0];
                showProductFinancials();
                if(!listOfProductFinancials.isEmpty()){
                    strProductFinancial = listOfProductFinancials[0];
                    changeTaxonomyCategory();
                }
            }
        }
        
    }
    
    
    public void showTaxonomySolutions(){
        listOfTaxonomySolutions = mapOfTaxonomyCategories.get(strSelectedTaxonomyCategory);
        if(strSelectedTaxonomyCategory == 'All'){
             strSelectedTaxonomyCategorySolution = 'All';
             showProductFinancials();
        }
        else{
            listOfProductFinancials.clear();        
            clearProductMap();
            strSelectedTaxonomyCategorySolution = null;
            strProductFinancial  = null;
            if(!listOfTaxonomySolutions.isEmpty()){
                strSelectedTaxonomyCategorySolution = listOfTaxonomySolutions[0];
                showProductFinancials();
                if(!listOfProductFinancials.isEmpty()){
                    strProductFinancial = listOfProductFinancials[0];
                    changeTaxonomyCategory();
                }
            }
        }
    } 
    
    public void showProductFinancials(){
        listOfProductFinancials.clear();
        clearProductMap();        
        strProductFinancial = null;     
        mapOfTaxonomyProductFinancial.clear();           
        //mapOfTaxonomyCategories.clear();
        if(objQuote.Offering_Type__c == 'PureEngage Subscription'){
            if(strSelectedTaxonomyCategorySolution == 'All'){
                strProductFinancial = 'All';
                List<String> taxonomySolutions;
                if(strSelectedTaxonomyCategory == 'All'){
                    List<Taxonomy_Sol_Category_And_Taxonomy_Sol__c> taxonomySolutionCategories = Taxonomy_Sol_Category_And_Taxonomy_Sol__c.getAll().values();
                    taxonomySolutions = new List<String>();
                    for(Taxonomy_Sol_Category_And_Taxonomy_Sol__c eachCategorySolution : taxonomySolutionCategories){
                        List<String> eachTaxonomySolutions = eachCategorySolution.Taxonomy_Solution__c.split(';');
                        taxonomySolutions.addAll(eachTaxonomySolutions);
                    }
                }
                else{
                    Taxonomy_Sol_Category_And_Taxonomy_Sol__c taxonomySolutionCategory = Taxonomy_Sol_Category_And_Taxonomy_Sol__c.getAll().get(strSelectedTaxonomyCategory);
                    taxonomySolutions = taxonomySolutionCategory.Taxonomy_Solution__c.split(';');
                }
                System.debug('NKC debug taxonomySolutions [' + taxonomySolutions + ']'); 
                //List<Taxonomy_Sol_and_Product_Financial__c> allProductFinancials = Taxonomy_Sol_and_Product_Financial__c.getAll().values();
                //for(Taxonomy_Sol_and_Product_Financial__c productFinancial : allProductFinancials){
                for(String eachTaxonomySolution : taxonomySolutions){
                    System.debug('NKC debug eachTaxonomySolution [' + eachTaxonomySolution + ']');
                    Taxonomy_Sol_and_Product_Financial__c productFinancial = Taxonomy_Sol_and_Product_Financial__c.getAll().get(eachTaxonomySolution);
                    if(productFinancial != null){                   
                        List<String> productFinancialValues = productFinancial.Product_Financial__c.split(';');
                        productFinancialValues.sort();
                        System.debug('NKC debug productFinancialValues [' + productFinancialValues + ']');
                        listOfProductFinancials.addAll(productFinancialValues);
                        mapOfTaxonomyProductFinancial.put(productFinancial.Name, productFinancialValues);
                    }    
                }
                changeTaxonomyCategory();
            }
            else{
                Taxonomy_Sol_and_Product_Financial__c productFinancial = Taxonomy_Sol_and_Product_Financial__c.getAll().get(strSelectedTaxonomyCategorySolution);
                if(productFinancial != null){
                    List<String> productFinancialValues = productFinancial.Product_Financial__c.split(';');
                    productFinancialValues.sort();
                    listOfProductFinancials.addAll(productFinancialValues);
                    mapOfTaxonomyProductFinancial.put(productFinancial.Name, productFinancialValues);
                }            
            }
        }
        //PureConnect Subscription
        else{
            if(strSelectedTaxonomyCategorySolution == 'All'){
                strProductFinancial = 'All';
                List<String> taxonomySolutions;
                if(strSelectedTaxonomyCategory == 'All'){
                    List<OnPremise_CIC_Category_and_Subcategory__c> taxonomySolutionCategories = OnPremise_CIC_Category_and_Subcategory__c.getAll().values();
                    taxonomySolutions = new List<String>();
                    for(OnPremise_CIC_Category_and_Subcategory__c eachCategorySolution : taxonomySolutionCategories){
                        List<String> eachTaxonomySolutions = eachCategorySolution.Sub_Category__c.split(';');
                        taxonomySolutions.addAll(eachTaxonomySolutions);
                    }
                }
                else{
                    OnPremise_CIC_Category_and_Subcategory__c taxonomySolutionCategory = OnPremise_CIC_Category_and_Subcategory__c.getAll().get(strSelectedTaxonomyCategory);
                    taxonomySolutions = taxonomySolutionCategory.Sub_Category__c.split(';');
                }
                System.debug('NKC debug taxonomySolutions [' + taxonomySolutions + ']'); 
                for(String eachTaxonomySolution : taxonomySolutions){
                    System.debug('NKC debug eachTaxonomySolution [' + eachTaxonomySolution + ']');
                    OnPremiseCIC_Category_and_Building_Block__c productFinancial = OnPremiseCIC_Category_and_Building_Block__c.getAll().get(eachTaxonomySolution);
                    if(productFinancial != null){                   
                        List<String> productFinancialValues = productFinancial.Building_Block__c.split(';');
                        //MS
                        if ( productFinancial.Building_Block2__c != null )
                            productFinancialValues.addAll( productFinancial.Building_Block2__c.split(';') );

                        productFinancialValues.sort();
                        System.debug('NKC debug productFinancialValues [' + productFinancialValues + ']');
                        listOfProductFinancials.addAll(productFinancialValues);
                        mapOfTaxonomyProductFinancial.put(productFinancial.Name, productFinancialValues);
                    }    
                }
                changeTaxonomyCategory();
            }
            else{
                OnPremiseCIC_Category_and_Building_Block__c productFinancial = OnPremiseCIC_Category_and_Building_Block__c.getAll().get(strSelectedTaxonomyCategorySolution);
                if(productFinancial != null){
                    List<String> productFinancialValues = productFinancial.Building_Block__c.split(';');
                    //MS
                    if ( productFinancial.Building_Block2__c != null )
                         productFinancialValues.addAll( productFinancial.Building_Block2__c.split(';') );

                    productFinancialValues.sort();
                    listOfProductFinancials.addAll(productFinancialValues);
                    mapOfTaxonomyProductFinancial.put(productFinancial.Name, productFinancialValues);
                }            
            }
        }
    }
    
    public void changeTaxonomyCategory(){
        //strSelectedTaxonomyCategorySolution    
         showProducts();
    }
    
    // *** 'Product Search' option in tab panel ***
    public void productSearchOptionHandler()
    {
        strMainOption = 'Product Search';
        initializeCollections();
        searchBtnHandler();
    }
    
    // *** 'Bundles' option in tab panel ***
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
        
        map_PlayCategoryListPlayOffer = new Map<String, List<PlayOfferWrapper>>();
        list_PlayCategory.clear();
        String playOfferCondition = '';
        List<String> listOfGroupTypes = new List<String>{'Use Case'};
            //String strOfferingType = 'PureConnect Premise';
            String strOfferingType = '';
            if(objQuote.Offering_Type__c =='PureConnect Subscription')
                strOfferingType = 'PureConnect Premise Subscription';
            else
                strOfferingType = 'PureEngage Premise Subscription';
                
        System.debug('--string offfering type--'+strOfferingType);   
        
        for(Play_Offer__mdt playOffer : [SELECT Offering_Type__c, Plat_Category__c, Play_O__c FROM Play_Offer__mdt WHERE Offering_Type__c =: strOfferingType ]){
            playOfferCondition = playOfferCondition + 'Play_Offer__c INCLUDES (\'' + playOffer.Play_O__c + '\') OR ';
            list_PlayCategory.add(playOffer.Play_O__c);
        }        
        playOfferCondition = playOfferCondition.removeEnd('OR ');
        if(playOfferCondition != ''){
            List<String> list_Temp = new List<String>();
            //strOfferingType = 'PureConnect On Premise';
            //List<Product_Group__c> list_PG = getProductGroup(listOfGroupTypes, strOfferingType, QuoteUtil.getPriceBookForCICCaas(objQuote.CurrencyIsoCode), playOfferCondition);
            List<Product_Group__c> list_PG = getProductGroup(listOfGroupTypes, objQuote.Offering_Type__c, QuoteUtil.getPriceBookForCICCaas(objQuote.CurrencyIsoCode), playOfferCondition);
            System.debug('--list_PG--'+list_PG);
            for(String playOffer : list_PlayCategory){
                for(Product_Group__c prodGrp : list_PG){
                    if(prodGrp.Play_Offer__c.contains(playOffer)){
                        if(!map_PlayCategoryListPlayOffer.containsKey(playOffer)){
                            map_PlayCategoryListPlayOffer.put(playOffer, new List<PlayOfferWrapper>());
                            list_Temp.add(playOffer);
                        }
                        map_PlayCategoryListPlayOffer.get(playOffer).add(new PlayOfferWrapper(prodGrp));                      
                    }
                }
            }
            list_PlayCategory.clear();
            list_PlayCategory.addAll(list_Temp);
        }
        
        list_PlayCategory.add('Other Use Cases');
        map_PlayCategoryListPlayOffer.put('Other Use Cases', new List<PlayOfferWrapper>());
        for(Product_Group__c prodGrp : getProductGroup(listOfGroupTypes, strOfferingType, QuoteUtil.getPriceBookForCICCaas(objQuote.CurrencyIsoCode))){
            map_PlayCategoryListPlayOffer.get('Other Use Cases').add(new PlayOfferWrapper(prodGrp));
        }
        
        system.debug(list_PlayCategory);
        system.debug(map_PlayCategoryListPlayOffer);
    }
    
    // *** 'Bundles' option in tab panel ***
    public void pureSuccessOptionHandler()
    {
        strMainOption = 'PureSuccess';
        initializeCollections();
        List<BigMachines__Quote_Product__c> list_OfQuoteProducts = [SELECT Bundle__r.Name FROM BigMachines__Quote_Product__c 
            WHERE BigMachines__Quote__c =: objQuote.id AND Bundle__c != null and Bundle_Line__c = null];
        
        // Fetching Bundles 
        for(Product_Group__c objProductPureSuccess : Database.query(createBundleQueryString('PureSuccess'))){  
            //We do not need to show Equip and Partner package
            if(objProductPureSuccess.Name != null 
               && (objProductPureSuccess.Name.containsIgnoreCase('Equip') && objQuote.Multi_Year_Quote__c) 
                    || (objProductPureSuccess.Name.containsIgnoreCase('Partner') && !objQuote.Multi_Year_Quote__c)
                    || (objQuote.Multi_Year_Quote__c && !objProductPureSuccess.Name.containsIgnoreCase('Partner')) )
                continue;               
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
                    }
                    else if(eachQP.Bundle__r.Name != null && eachQP.Bundle__r.Name.containsIgnoreCase('Guide') && objProductPureSuccess.Name != null && objProductPureSuccess.Name.containsIgnoreCase('Guide')){
                        objProductPureSuccess.Active__c = false;
                        objProductPureSuccess.Selected__c = true;
                    }
                    else if(eachQP.Bundle__r.Name != null && eachQP.Bundle__r.Name.containsIgnoreCase('Drive') && objProductPureSuccess.Name != null && objProductPureSuccess.Name.containsIgnoreCase('Drive')){
                        objProductPureSuccess.Active__c = false;
                        objProductPureSuccess.Selected__c = true;
                    }
                    else if(eachQP.Bundle__r.Name != null && eachQP.Bundle__r.Name.containsIgnoreCase('Partner PureSuccess') && objProductPureSuccess.Name != null && objProductPureSuccess.Name.containsIgnoreCase('Partner PureSuccess')){
                        objProductPureSuccess.Active__c = false;
                        objProductPureSuccess.Selected__c = true;
                    }                    
                }
            } 
        }
        
        strALaCarte = 'A la Carte';
        if(objQuote.Multi_Year_Quote__c){
            strALaCarte = 'A la Carte Partner';
        }
        //A la Carte items.
        for(Product_Group__c objProductAlaCarte : Database.query(createBundleQueryString(strALaCarte))){ 
            list_OfAlaCarte.addAll(objProductAlaCarte.Product_Group_Items__r);
        }
    }
    
    // *** 'Favourites' option in tab panel ***
    public void favouritesOptionHandler()
    {
        strMainOption = 'Favourites';
        initializeCollections();
        // fetch all favourites of running user
        for(Product_Group__c objFav : [SELECT Id,Name FROM Product_Group__c WHERE 
                                       User__c = :UserInfo.getUserId() AND Group_Type__c = 'Favorite' ORDER BY Name])
        {
            FavoriteWrapper objFavWrapper = new FavoriteWrapper();
            objFavWrapper.objFavorite = objFav;
            list_Favourites.add(objFavWrapper);
        }
    }
    
    // *** 'Dynamic Bundles/Campaigns' option in tab panel ***
    public void CampaignsOptionHandler() 
    {
        strMainOption = 'Campaigns';
        initializeCollections();
        
        
        // Fetching Campaigns
        for(Product_Group__c objProductBundle : Database.query(createCampaingsQueryString()))
        {  
            map_CampaignsIdToShowProductsChoice.put(objProductBundle.Id,false);
            
            objProductBundle.Price__c = 0;
            for(Product_Group_Item__c objPGI : objProductBundle.Product_Group_Items__r)
            {
  
                system.debug('navaneeBuilding_Block__c'+ objPGI.Product__r.Building_Block__c);
                 system.debug('navaneeBuilding_Block__c'+objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c);
                // For PS RDP products fetch price from Custom Settings based on region and product
                if(objPGI.Product__r.Building_Block__c == 'PS Rapid Deployment Packages' && 
                   String.isNotBlank(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c))
                {
                    PSRDP_Pricing__c objPriceSettings = PSRDP_Pricing__c.getInstance(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c + '##' + objPGI.Product__c);
                    if(objPriceSettings != null)
                        objPGI.getSObject('Product__r').put(strPricebookFieldName,objPriceSettings.Price__c);
                }
                Decimal decLinePrice = (Decimal)objPGI.getSObject('Product__r').get(strPricebookFieldName) * 
                    (objPGI.Quantity__c != null ? objPGI.Quantity__c : 1);
                
                // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objPGI.Product__r.Pricing_Model__c)
                   && objPGI.Product__r.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                    decLinePrice *= decPricingMultiplier;
                
                objProductBundle.Price__c += decLinePrice;
            }
            
            if(objProductBundle.Price__c == null || objProductBundle.Price__c < 0)
                continue;
            
            // Group Bundles according to Bundle Type like Add-Ons, Stand-alone etc
            if(map_CampaignsTypesToBundles .containsKey(objProductBundle.Type__c))
                map_CampaignsTypesToBundles.get(objProductBundle.Type__c).add(objProductBundle);
            
            else
            {
                list_CampaignsTypes.add(objProductBundle.Type__c);
                map_CampaignsTypesToBundles.put(objProductBundle.Type__c,new List<Product_Group__c>{objProductBundle});
            }
        }
    }
    
    private void clearProductMap(){
        Set<String> productFinancials = map_BuildingBlockToProducts.keyset();
        for(String eachFinancial : productFinancials){
            map_BuildingBlockToProducts.put(eachFinancial, new List<ProductWrapper>());   
        }
    }
    
    
    // *** To show products under 'All Products' based on current Category and Building Block selection ***
    public void showProducts()
    {
        System.debug('NKC debug strSelectedCategory ['+strSelectedCategory+']');
        System.debug('NKC debug strSelectedTaxonomyCategorySolution ['+strSelectedTaxonomyCategorySolution+']');
        
        // Storing building blocks in the map in case there are no products for a building block (to prevent run time exceptions)        
        if(strProductFinancial == 'All'){
            for(List<String> listOfProductFinancials : mapOfTaxonomyProductFinancial.values()){
                for(String eachProductFinancial : listOfProductFinancials)
                    map_BuildingBlockToProducts.put(eachProductFinancial,  new List<ProductWrapper>());
            }
        }        
        else                
            map_BuildingBlockToProducts.put(strProductFinancial,  new List<ProductWrapper>());         
        
        String strCategoryFieldName = 'Taxonomy_Solution_Category__c';
        String subCategoryFieldName = 'Taxonomy_Solution__c';
        String productFinancialFieldName = 'Building_Block__c';      
        mapOfBaseVersionVsMaturity = new Map<String, String>();
        
        Set<Id> setOfBaseItemIds = new Set<Id>();
        system.debug('Database query'+Database.query(createBaseProductQueryString() ));
        for(Product2 objBaseProduct : Database.query(createBaseProductQueryString()))
        {
            QuoteUtil.addProductPrecisionToMap(objBaseProduct, mapProductIdToDecimalPrecision);
            // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
           
            if(objQuote.Pricing_Model__c != null && objQuote.Pricing_Model__c != 'Enabled' && String.IsNotBlank(objBaseProduct.Pricing_Model__c)
               && objBaseProduct.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                objBaseProduct.put(strPricebookFieldName,((Decimal)objBaseProduct.get(strPricebookFieldName)) * decPricingMultiplier);
            
            objBaseProduct.put(strPricebookFieldName, convertAndUpdatePrice(((Decimal)objBaseProduct.get(strPricebookFieldName)), objQuote, objBaseProduct, currentCurreny));
            
        
            String productFinancial = (String)objBaseProduct.get(productFinancialFieldName);
            ProductWrapper objProductWrapper = populateWrapper(objBaseProduct);
            System.debug('NKC debug productFinancial [' + productFinancial + ']');
            System.debug('NKC debug objBaseProduct.id ['+ objBaseProduct.id +']');
            // Grouping base items according to Building blocks
            if(map_BuildingBlockToProducts.containsKey(productFinancial))
            {
                System.debug('NKC debug productFinancial [' + map_BuildingBlockToProducts.containsKey(productFinancial) + ']');
                
                map_BuildingBlockToProducts.get(productFinancial).add(objProductWrapper);
                objBaseProduct.SI_Version_Number__c = objBaseProduct.Latest_Version__c;
                handleVersionsAvailable(objBaseProduct);
                handleQuantitiesAvailable(objBaseProduct);
                String key = objBaseProduct.id + objBaseProduct.Latest_Version__c; 
                objBaseProduct.Maturity__c = objBaseProduct.Maturity__c == null ? '' : objBaseProduct.Maturity__c;
                mapOfBaseVersionVsMaturity.put(key, objBaseProduct.Maturity__c);
                setOfBaseItemIds.add(objBaseProduct.id);
                System.debug('NKC debug objBaseProduct.id ['+objBaseProduct.id+']');
                // Adding child base items like Lab and HA etc (Ensures parent and children are grouped together)
                if(objBaseProduct.Products__r.size() > 0)
                {
                    
                    for(Product2 objBaseChildProduct : objBaseProduct.Products__r)
                    {
                      System.debug('NKC debug objBaseChildProduct.id ['+objBaseChildProduct.id+']');
                        objProductWrapper = populateWrapper(objBaseChildProduct);
                        map_BuildingBlockToProducts.get(productFinancial).add(objProductWrapper);
                        objBaseChildProduct.SI_Version_Number__c = objBaseChildProduct.Latest_Version__c;
                        handleVersionsAvailable(objBaseChildProduct);
                        handleQuantitiesAvailable(objBaseChildProduct);
                        key = objBaseChildProduct.id + objBaseChildProduct.SI_Version_Number__c; 
                        objBaseChildProduct.Maturity__c = objBaseChildProduct.Maturity__c == null ? '' : objBaseChildProduct.Maturity__c;
                        mapOfBaseVersionVsMaturity.put(key, objBaseChildProduct.Maturity__c);
                        setOfBaseItemIds.add(objBaseChildProduct.id);
                    }
                }
            }
        }
        loadMapWithChildItems(setOfBaseItemIds);        
    }
    
    private void loadMapWithChildItems(Set<Id> setOfBaseItemIds){
      List<Product2> childProducts = [SELECT Base_Item_Lookup__c, SI_Version_Number__c, Maturity__c, Tier_Pricing_Decimal_Precision__c FROM Product2 
        WHERE Base_Item_Lookup__c IN : setOfBaseItemIds ORDER BY SI_Version_Number__c DESC];
      QuoteUtil.addProductPrecisionToMap(childProducts, mapProductIdToDecimalPrecision); // Tier_Pricing_Decimal_Precision__c
      Integer index = 0;
        for(Product2 eachProduct : childProducts){
          if(index == 0)
            defaultVersion = eachProduct.SI_Version_Number__c;
          String key = eachProduct.Base_Item_Lookup__c + eachProduct.SI_Version_Number__c; 
            eachProduct.Maturity__c = eachProduct.Maturity__c == null ? '' : eachProduct.Maturity__c;
            mapOfBaseVersionVsMaturity.put(key, eachProduct.Maturity__c);
            index ++;  
        }
    }
    
    // *** To create version drop downs ***
    private void handleVersionsAvailable(Product2 objBaseProduct)
    {
        // Creating version drop-downs
        if(blnIsNewPricing){  
            if(String.isNotBlank(objBaseProduct.Versions_Available__c))
            {
                if(!map_VersionsToSelectOptions.containsKey(objBaseProduct.Versions_Available__c))
                {
                    List<SelectOption> list_Options = new List<SelectOption>();
                    for(String strVersion : objBaseProduct.Versions_Available__c.split(';'))
                        list_Options.add(new SelectOption(strVersion,strVersion));
                    map_VersionsToSelectOptions.put(objBaseProduct.Versions_Available__c,list_Options);
                }
            }
        } else if(String.isNotBlank(objBaseProduct.Version_Available_For_old__c)){
            if(!map_VersionsToSelectOptions.containsKey(objBaseProduct.Version_Available_For_old__c))
            {
                List<SelectOption> list_Options = new List<SelectOption>();
                for(String strVersion : objBaseProduct.Version_Available_For_old__c.split(';'))
                    list_Options.add(new SelectOption(strVersion,strVersion));
                map_VersionsToSelectOptions.put(objBaseProduct.Version_Available_For_old__c,list_Options);
            }
            
            
        }
    }
    
    public void refresh(){
      Set<Id> setOfBaseItemIds = new Set<Id>();
      setOfBaseItemIds.add(selectedBaseItemId);
      loadMapWithChildItems(setOfBaseItemIds);
      System.debug('NKC debug selectedBaseItemId ['+selectedBaseItemId+']');
      System.debug('NKC debug selectedVersion ['+selectedVersion+']');       
      System.debug('NKC debug defaultVersion ['+defaultVersion+']');      
      String maturity = mapOfBaseVersionVsMaturity.get(selectedBaseItemId + selectedVersion);
      mapOfBaseVersionVsMaturity.put(selectedBaseItemId + defaultVersion, maturity);
      System.debug('NKC debug maturity ['+maturity+']');
    }
    
    
    // *** To create quantity drop downs ***
    private void handleQuantitiesAvailable(Product2 objBaseProduct)
    {
        // Creating quantity drop-downs
        system.debug('objprodquantities'+objBaseProduct.Quantities_Available__c );
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
    
    // *** To show Supporting Info in Product Search ***
    public void showProductInfo()
    {
        blnShowSupportingInfo = true;
        strProductInfo = '';
        // Fetching Support Information
        List<Product2> list_Temp = [SELECT Support_Information__c, Tier_Pricing_Decimal_Precision__c FROM Product2 WHERE Id = :strProductIdForInfo];
        QuoteUtil.addProductPrecisionToMap(list_Temp, mapProductIdToDecimalPrecision); // Tier_Pricing_Decimal_Precision__c
        if(list_Temp.size() > 0)
            strProductInfo = list_Temp[0].Support_Information__c;
    }
    
    // *** To show Supporting Info in 'All Products' ***
    public void showProductInfoFromBaseItem()
    {
        blnShowSupportingInfo = true;
        strProductInfo = '';
        // Fetching Support Information from Sell-able item based on Base Item and version selected
        List<Product2> list_Temp = [SELECT Support_Information__c, Tier_Pricing_Decimal_Precision__c FROM Product2 
                                    WHERE Base_Item_Lookup__c = :strProductIdForInfo AND SI_Version_Number__c = :strVersionForInfo];
        QuoteUtil.addProductPrecisionToMap(list_Temp, mapProductIdToDecimalPrecision); // Tier_Pricing_Decimal_Precision__c
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
    {
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
                                                             Product__r.Unit_of_Measure__c FROM Product_Group_Item__c WHERE Product_Group__c = :strGroupId
                                                             ORDER BY Product__r.Description]);
            }
            map_BundleIdToShowProductsChoice.put(null,false);
            map_BundleIdToBundleProducts.put(null, null);
        }
    }
    
    public void showHideCampaignsProducts()
    {
        map_CampaignsIdProductLoad.put(strGroupId, false);
        map_CampaignsIdProductOptLoad.put(strGroupId, false);
        map_CampaignsIdProductLABLoad.put(strGroupId, false);
        map_CampaignsIdProductHALoad.put(strGroupId, false);
        map_CampaignsIdProductSubLoad.put(strGroupId, false);
        
        list_CampaignsProductTypes.add('Mandatory'); 
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
                
                
                string query = 'SELECT Product__c,Product__r.Description,Quantity__c,Product_Type__c,GroupID__c,Select__c,Product__r.Product_Specific_Discount__c,'
                    +'Product__r.Pricing_Model__c,Product__r.APN_Number__c,Product__r.Building_Block__c,Product__r.PPU_Product_Specific_Discount__c,Product__r.Product_Manager_Approval_Group__r.Name,Product__r.Third_Party__c,Product__r.Third_Party_GC__c, Product__r.Name,'
                    
                    //Added by Anshul on 07/19/18 
                    +'Minimum_Substitutable_Count__c,Product_Name__c,Substitutable_Product_Group_Item__c,'
                    
                    +'Product__r.Unit_of_Measure__c,Product__r.' + strPricebookFieldName +' FROM Product_Group_Item__c WHERE Product_Group__c =\''+ strGroupId+'\'' ;
                
                System.debug(query+ '\' and product_type__c=\'Mandatory\' ORDER BY Product__r.Description');
                map_CampaignsIdToBundleProducts.put(strGroupId,Database.query(query+ ' and product_type__c=\'Mandatory\' and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1 ORDER BY Product__r.Description')); 
                map_CampaignsIdToBundleProducts_Opt.put(strGroupId,Database.query(query+ ' and product_type__c=\'Optional\' and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1  ORDER BY Product__r.Description')); 
                map_CampaignsIdToBundleProducts_LAB.put(strGroupId,Database.query(query+ ' and product_type__c=\'LAB\' and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1 ORDER BY Product__r.Description')); 
                map_CampaignsIdToBundleProducts_HA.put(strGroupId,Database.query(query+ ' and product_type__c=\'HA\' and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1 ORDER BY Product__r.Description')); 
                map_CampaignsIdToBundleProducts_Sub.put(strGroupId,Database.query(query+ ' and (product_type__c=\'Substitutable\' OR product_type__c=\'Mandatory Substitutable\') and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1 ORDER BY GroupID__c,Product_Type__c')); 
                
                if(map_CampaignsIdToBundleProducts.get(strGroupId).size() > 0){
                    map_CampaignsIdProductLoad.put(strGroupId, true);
                }
                if(map_CampaignsIdToBundleProducts_Opt.get(strGroupId).size() > 0){
                    map_CampaignsIdProductOptLoad.put(strGroupId, true);
                }
                if(map_CampaignsIdToBundleProducts_LAB.get(strGroupId).size() > 0){
                    map_CampaignsIdProductLABLoad.put(strGroupId, true);
                }
                if(map_CampaignsIdToBundleProducts_HA.get(strGroupId).size() > 0){
                    map_CampaignsIdProductHALoad.put(strGroupId, true);
                }
                if(map_CampaignsIdToBundleProducts_Sub.get(strGroupId).size() > 0){
                    map_CampaignsIdProductSubLoad.put(strGroupId, true);
                }
            }
        }
    }
    
    
    // *** To show/hide Items in Favourites ***
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
                //objFavWrapper.list_Campaigns.clear();
            }
            else
            {
                list_Favourites[intIndex].blnShowItems = true;
                objFavWrapper.list_Bundles = new List<Product_Group_Item__c>();
                objFavWrapper.list_Products = new List<Product_Group_Item__c>();
                //objFavWrapper.list_Campaigns = new List<Product_Group_Item__c>();
                
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
                        //if(objPGI.Bundle__r.Group_Type__c != 'Campaigns')
                        objFavWrapper.list_Bundles.add(objPGI);
                        //else
                        // objFavWrapper.list_Campaigns.add(objPGI);
                    }   
                    else if(objPGI.Product__c != null)
                        objFavWrapper.list_Products.add(objPGI);
                }
            }
        }
        strFavId = null;
    }
    
    // *** To delete a favourite ***
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
            List<Product2> list_ProductsToAdd = new List<Product2>();
            Set<String> set_Versions = new Set<String>();
            for(List<ProductWrapper> list_OfProductWrapper : map_BuildingBlockToProducts.values())
            {
                for(ProductWrapper objEachProductWrapper : list_OfProductWrapper)
                {
                    Product2 objProduct = populateProduct2FromDummy(objEachProductWrapper.objDummy, objEachProductWrapper.objProduct);
                    if(String.isNotBlank(objProduct.Product_Name__c) || 
                       (objProduct.Quantity__c != null && objProduct.Quantity__c != 0))
                    {
                        list_ProductsToAdd.add(objProduct);
                        set_Versions.add(objProduct.SI_Version_Number__c);  
                        objEachProductWrapper.objDummy.Quantity__c = null;
                    }
                }
            }
            
            Map<String,Product2> map_BaseItemIdAndVersionToProduct = new Map<String,Product2>();
            //show_emea_training_error =true;
            for(Product2 objSellableProduct : Database.query(createAddedProductsQueryString(list_ProductsToAdd,set_Versions)))
            {       
                QuoteUtil.addProductPrecisionToMap(objSellableProduct, mapProductIdToDecimalPrecision);
                System.debug('NKC debug objSellableProduct.PPU_Product_Specific_Discount__c ['+objSellableProduct.PPU_Product_Specific_Discount__c+']');
                map_BaseItemIdAndVersionToProduct.put(objSellableProduct.Base_Item_Lookup__c + objSellableProduct.SI_Version_Number__c,objSellableProduct);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'this is test'));
                //return;
                
            }
            
            Set<String> set_APNnumbers = new Set<String>();
            for(Product2 objBaseProduct : list_ProductsToAdd)
            {
                String strKey = objBaseProduct.Id + objBaseProduct.SI_Version_Number__c;
                Decimal decPrice = null;
                if(map_BaseItemIdAndVersionToProduct.containskey(strKey))
                {
                    Product2 objSellableProduct = map_BaseItemIdAndVersionToProduct.get(strKey);
                    
                    // PSRDP Recommendations
                    if(PSRDP_Recommendations__c.getInstance(objSellableProduct.APN_Number__c) != null)
                        set_APNnumbers.add(PSRDP_Recommendations__c.getInstance(objSellableProduct.APN_Number__c).PSRDP_Training_Unit_Part__c);
                    
                    // if any recommended product is already added by user : remove it from APN numbers to be added             
                    if(set_APNnumbers.contains(objSellableProduct.APN_Number__c))
                        set_APNnumbers.remove(objSellableProduct.APN_Number__c);
                    
                    // For PS RDP products fetch price from Custom Settings based on region and product
                    if(objBaseProduct.Building_Block__c == 'PS Rapid Deployment Packages' && 
                       String.isNotBlank(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c))
                    {
                        PSRDP_Pricing__c objPriceSettings = PSRDP_Pricing__c.getInstance(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c + '##' + objSellableProduct.Id);
                        if(objPriceSettings != null)
                            decPrice = objPriceSettings.Price__c;
                    }
                    System.debug('NKC debug decPrice ['+ decPrice +']');
                    if(decPrice == null){
                        if(isThirdPartyProduct(objSellableProduct))
                            decPrice = (Decimal)objSellableProduct.get(strPricebookFieldName);
                        else
                            decPrice = (Decimal)objSellableProduct.get(strPricebookFieldName);
                    }    
                    System.debug('NKC debug decPrice ['+ decPrice +']');
                    
                    // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                    if(objQuote.Pricing_Model__c != null && objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objSellableProduct.Pricing_Model__c)
                       && objSellableProduct.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                        decPrice *= decPricingMultiplier;
                    decPrice *= PRICE_MULTIPLIER;
                    System.debug('NKC debug decPrice ['+ decPrice +']');
                    if(!ProductId_set.contains(objSellableProduct.id)){
                        BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                        objQP.Name = objSellableProduct.Name;
                        objQP.BigMachines__Quote__c = objQuote.Id;
                        objQP.Play__c = objQuote.Top_Play__c;
                        // objQP.Offer__c = objQuote.Offer__c;
                        objQP.BigMachines__Product__c = objSellableProduct.Id;
                        if(objSellableProduct.Description != null)
                            objQP.Product__c = (objSellableProduct.Description.length() > 255 ? objSellableProduct.Description.left(255) : objSellableProduct.Description);
                        objQP.APN_Number__c = objSellableProduct.APN_Number__c;
                        objQP.Product_Specific_Discount__c = objSellableProduct.PPU_Product_Specific_Discount__c;
                        System.debug('NKC debug objSellableProduct.PPU_Product_Specific_Discount__c ['+objSellableProduct.PPU_Product_Specific_Discount__c+']');
                        objQP.Pm_Approver__c = objSellableProduct.Product_Manager_Approval_Group__r.Name;
                        objQP.Third_Party__c = objSellableProduct.Third_Party__c;
                        objQP.Third_Party_GC__c = objSellableProduct.Third_Party_GC__c;
                        objQP.Original_Third_Party_GC__c = objSellableProduct.Third_Party_GC__c;
                        objQP.List_Price__c = decPrice;
                        objQP.Line_Number__c = 100;
                        if(String.isNotBlank(objBaseProduct.Product_Name__c))
                        {
                            // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
                            objQP.Quantity__c = Decimal.valueOf(objBaseProduct.Product_Name__c);
                            objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                            objQP.Build_Type__c = objBaseProduct.Name;
                            // Fetching AudioCodes prices from custom settings based on Base Item name and quantity selected
                            AudioCodes__c objAudioCodeSettings = AudioCodes__c.getInstance(objBaseProduct.Name + objBaseProduct.Product_Name__c);
                            if(objAudioCodeSettings != null)
                                objQP.List_Price__c *= objAudioCodeSettings.Volume_Break_Multiplier__c;
                        }
                        else
                        {
                            // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
                            objQP.Quantity__c = objBaseProduct.Quantity__c;
                            objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                        } 
                        
                        // EMEA Volume Discount for old pricing
                        if(!blnIsNewPricing && strPricebookFieldName.containsIgnoreCase('EMEA') && objSellableProduct.EMEA_Volume_Discount_Eligible__c)
                        {
                            for(EMEA_Volume_Discounts__c objEMEADiscount : EMEA_Volume_Discounts__c.getall().values())
                            {
                                if(objQP.Quantity__c >= objEMEADiscount.Range_Start__c && objQP.Quantity__c <= objEMEADiscount.Range_End__c)
                                {
                                    objQP.EMEA_Volume_Discount__c = objEMEADiscount.Discount__c;
                                    objQP.List_Price__c -= (objQP.List_Price__c * objQP.EMEA_Volume_Discount__c/100);
                                    break;
                                }
                            }
                        }
                        
                        objQP.Unit_of_Measure__c = objSellableProduct.Unit_of_Measure__c;
                        objQP.BigMachines__Sales_Price__c = 0;
                        objQP.or_Amount__c = '%';
                        objQP.Disc__c = objBaseProduct.Discount__c;
                        objQP.List_Price__c = convertAndUpdatePrice(objQP.List_Price__c, objQuote, objSellableProduct, currentCurreny);
                        list_QuoteProductsToBeCreated.add(objQP);
                        //ProductId_set.add(objSellableProduct.id);
                    }
                }
                objBaseProduct.Quantity__c = null;
                objBaseProduct.Discount__c = null;
                objBaseProduct.Product_Name__c = null;
                objBaseProduct.SI_Version_Number__c = objBaseProduct.Latest_Version__c;
            }
        
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }        
    } ///end addProductsBtnHandler()
    
    // *** To Add Products from 'All Products' to the quote ***
    public void addProductsBtnHandlerPureConnect()
    {
        try
        {
            List<Product2> list_ProductsToAdd = new List<Product2>();
            for(List<ProductWrapper> list_OfProductWrapper : map_BuildingBlockToProducts.values())
            {
                for(ProductWrapper objEachProductWrapper : list_OfProductWrapper)
                {                  
                    Product2 objProduct = populateProduct2FromDummy(objEachProductWrapper.objDummy, objEachProductWrapper.objProduct);  
 
                    objEachProductWrapper.objDummy.Quantity__c = null;                    
                    if(String.isNotBlank(objProduct.Name) && (objProduct.Quantity__c != null && objProduct.Quantity__c != 0))
                        list_ProductsToAdd.add(objProduct);
                }
            }
              List<Product2> list_SelectedProducts = Database.query(createAddedProductsQueryString(list_ProductsToAdd));
              Map<Id,Product2> map_Products = new Map<Id,Product2>(list_SelectedProducts);
            
            Set<String> set_APNnumbers = new Set<String>();
            for(Product2 objProduct : list_ProductsToAdd)
            {
                Product2 objAddionalInfoProd = map_Products.get(objProduct.Id);
        
        Decimal decPrice = null;
        
        // PSRDP Recommendations
        if(PSRDP_Recommendations__c.getInstance(objProduct.APN_Number__c) != null)
          set_APNnumbers.add(PSRDP_Recommendations__c.getInstance(objProduct.APN_Number__c).PSRDP_Training_Unit_Part__c);
        
        // if any recommended product is already added by user : remove it from APN numbers to be added             
        if(set_APNnumbers.contains(objProduct.APN_Number__c))
          set_APNnumbers.remove(objProduct.APN_Number__c);
        
        System.debug('decPrice == ' + decPrice);
        System.debug('strPricebookFieldName == ' + strPricebookFieldName);
        // Fetching Tier Pricing if applicable
        if(objAddionalInfoProd.Price_Type__c == 'Range')
          decPrice = QuoteUtil.getProductTierPricing(objAddionalInfoProd.Product_Tier_Pricings__r, objProduct.Quantity__c, decPrice, strPricebookFieldName);
        
        System.debug('decPrice == ' + decPrice);
        if(decPrice == null)
          decPrice = (Decimal)objProduct.get(strPricebookFieldName);
        
        // Quote Pricing Model is Concurrent and product has the concurrent pricing model, price is multiplied by pricing multiplier
        if(objQuote.Pricing_Model__c == 'Concurrent' && objProduct.Is_Concurrent__c == 'Yes')
          decPrice *= decPricingMultiplier;
        if(!ProductId_set.contains(objProduct.id)){
        BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
        objQP.Name = objProduct.Name;
        objQP.Play__c = objQuote.Top_Play__c;
        // objQP.Offer__c = objQuote.Offer__c;
        objQP.BigMachines__Quote__c = objQuote.Id;
        objQP.BigMachines__Product__c = objProduct.Id;
        objQP.APN_Number__c = objProduct.APN_Number__c;
        objQP.Product_Specific_Discount__c = objAddionalInfoProd.Product_Specific_Discount__c;
        objQP.Pm_Approver__c = objAddionalInfoProd.Product_Manager_Approval_Group__r.Name;
        objQP.Third_Party__c = objAddionalInfoProd.Third_Party__c;
        objQP.Third_Party_GC__c = objAddionalInfoProd.Third_Party_GC__c;
        objQP.Original_Third_Party_GC__c = objAddionalInfoProd.Third_Party_GC__c;
        objQP.Line_Number__c = ++intLineNumber;//-Rony Joseph - June 6th 2019 - Used to track the line number for the quote product level- 
                objQP.Pass_Through__c = objProduct.Pass_Through__c;
        objQP.List_Price__c = decPrice;
        
        /*if(String.isNotBlank(objProduct.Product_Name__c))
        {
          // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
          //commented by ankit on 6_14_2016 
                    //objQP.Quantity__c = Decimal.valueOf(objProduct.Product_Name__c);
          
                    objQP.Quantity__c = objProduct.Quantity__c;
                    objQP.BigMachines__Quantity__c = objQP.Quantity__c;
          objQP.Build_Type__c = objProduct.Name;
          // Fetching AudioCodes prices from custom settings based on Base Item name and quantity selected
          AudioCodes__c objAudioCodeSettings = AudioCodes__c.getInstance(objProduct.Name);
          if(objAudioCodeSettings != null)
            objQP.List_Price__c *= objAudioCodeSettings.Volume_Break_Multiplier__c;
        }
        else
        {*/
          // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
          objQP.Quantity__c = objProduct.Quantity__c;
          objQP.BigMachines__Quantity__c = objQP.Quantity__c;
        /*}*/
        
                objQP.Partner_Price__c = objQP.List_Price__c;
                // getting partner margin discounts if any                    
                //if(objQuote.Sold_To_Name__c != null && objQuote.End_User_ID__c != objQuote.Sold_To_Name__c)
                //  objQP.Partner_Price__c = QuoteUtil.getPartnerMargin(objQP.Partner_Price__c, objProduct, objQuote)[0];
        
        objQP.Unit_of_Measure__c = objProduct.Unit_of_Measure__c;
        objQP.BigMachines__Sales_Price__c = 0;
        list_QuoteProductsToBeCreated.add(objQP);
        //ProductId_set.add(objProduct.id);
        }
                objProduct.Quantity__c = null;
                objProduct.Product_Name__c = null;
            }
        
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
        
    }
    
    // *** To Add Bundles to the quote ***
    public void addBundlesBtnHandler()
    {
        map_ProductGrpIdPlayOffer = new Map<String, String>();
        productGroupIds = new Set<Id>();
        Set<Id> set_ExistingDisplayedProds = new Set<Id>();
        Set<Id> set_ProductIdsToAdd = new Set<Id>();
        List<Product_Group__c> tempList = new List<Product_Group__c>();
        boolean isDuplicate = false;
        
        for(BigMachines__Quote_Product__c objQP : [SELECT Id, BigMachines__Product__c, Hide_Record__c, Is_Overage__c, bundle__c
                                                   FROM BigMachines__Quote_Product__c 
                                                   WHERE BigMachines__Quote__c = :objQuote.Id
                                                   AND bundle__r.Group_Type__c = 'Use Case']) 
        {
           set_ExistingDisplayedProds.add(objQP.bundle__c);
        }
        
        for(String playOffer : map_PlayCategoryListPlayOffer.keySet()){
            for(PlayOfferWrapper objProductBundle : map_PlayCategoryListPlayOffer.get(playOffer)){
        //for(List<PlayOfferWrapper> list_Bundles : map_PlayCategoryListPlayOffer.values()){
            //for(PlayOfferWrapper objProductBundle : list_Bundles){
                System.debug('--objProductBundle--'+objProductBundle+'--set_ProductIdsToAdd---'+set_ProductIdsToAdd+'---isDuplicate--'+isDuplicate);
                if(objProductBundle.isSelected) {
                    if(!set_ExistingDisplayedProds.contains(objProductBundle.prdGrp.id)){
                        if(!set_ProductIdsToAdd.contains(objProductBundle.prdGrp.id)){
                            Product_Group__c objBundleTemp = objProductBundle.prdGrp.clone(true,true);
                            tempList.add(objBundleTemp);
                            set_ProductIdsToAdd.add(objProductBundle.prdGrp.id);
                            map_ProductGrpIdPlayOffer.put(objProductBundle.prdGrp.id, playOffer);
                        }else{
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Use Cases can only be selected once, please remove any duplicate selections.'));
                            isDuplicate = true;
                            break;
                        }
                    }else{
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'This use case cannot be added, as it is already part of the quote/subscription.'));
                        isDuplicate = true;
                        break;
                    }
                }
                objProductBundle.prdGrp.Quantity__c = null;
                objProductBundle.prdGrp.Additional_Discount__c = null;
            }
        }      
        if(!isDuplicate){
            productGroupIds.addAll(set_ProductIdsToAdd);
            list_BundlesToBeSaved.addAll(tempList);     
        }        
    }
    
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
                                                   Name = eachAlaCarteItem.Product__r.Name);
                list_OfAlaCarteToBeSaved.add(newProduct);
            }
        }
    }
    
    
    private static Boolean isThirdPartyProduct(Product2 productRecord){
        if(productRecord.Third_Party__c != null && productRecord.Third_Party__c.toUpperCase() == 'TRUE')
            return true;
        else 
            return false;   
    }
    
    // *** To Add Products from 'Product Search' to the quote ***
    public void addProductsFromSearch()
    {
        try
        {
            Set<String> set_APNnumbers = new Set<String>();
            for(Product2 objSearchProd : list_SearchProducts)
            {
              if((String.isNotBlank(objSearchProd.Quantities_Available__c) && String.isNotBlank(objSearchProd.Product_Name__c))|| 
                  (objSearchProd.Quantity__c != null && objSearchProd.Quantity__c != 0))
                {
                    Decimal decPrice;
                    System.debug('NKC debug objSearchProd [' + objSearchProd + ']');
                    if(isThirdPartyProduct(objSearchProd))
                        decPrice = (Decimal)objSearchProd.get(strPricebookFieldName);
                    else
                        decPrice = (Decimal)objSearchProd.get(strPricebookFieldName);
      
                    if(decPrice != null && decPrice != -1) {
                        // PSRDP Recommendations
                        if(PSRDP_Recommendations__c.getInstance(objSearchProd.APN_Number__c) != null)
                            set_APNnumbers.add(PSRDP_Recommendations__c.getInstance(objSearchProd.APN_Number__c).PSRDP_Training_Unit_Part__c);
                        
                        // if any recommended product is already added by user : remove it from APN numbers to be added             
                        if(set_APNnumbers.contains(objSearchProd.APN_Number__c))
                            set_APNnumbers.remove(objSearchProd.APN_Number__c);
                        decPrice *= PRICE_MULTIPLIER;
                        if(!ProductId_set.contains(objSearchProd.id)){
                        BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                        objQP.Name = objSearchProd.Name;
                        objQP.Play__c = objQuote.Top_Play__c;
                        //objQP.Offer__c = objQuote.Offer__c;
                        objQP.BigMachines__Quote__c = objQuote.Id;
                        objQP.BigMachines__Product__c = objSearchProd.Id;
                        if(objSearchProd.Description != null)
                            objQP.Product__c = (objSearchProd.Description.length() > 255 ? objSearchProd.Description.left(255) : objSearchProd.Description);
                        objQP.APN_Number__c = objSearchProd.APN_Number__c;
                        objQP.Product_Specific_Discount__c = objSearchProd.PPU_Product_Specific_Discount__c;
                        objQP.Pm_Approver__c = objSearchProd.Product_Manager_Approval_Group__r.Name;
                        objQP.Third_Party__c = objSearchProd.Third_Party__c;
                        objQP.Third_Party_GC__c = objSearchProd.Third_Party_GC__c;
                        objQP.Original_Third_Party_GC__c = objSearchProd.Third_Party_GC__c;
                        objQP.Unit_of_Measure__c = objSearchProd.Unit_of_Measure__c;
                        objQP.List_Price__c = decPrice;
            objQP.Line_Number__c = ++intLineNumber;//-Navaneetha nov 28th 2019 - Used to track the line number for the quote product level- 
                                     // objQP.Line_Number__c = 100; commented by navaneetha
                        if(String.isNotBlank(objSearchProd.Quantities_Available__c) && 
                           String.isNotBlank(objSearchProd.Product_Name__c))
                        {
                            // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
                            objQP.Quantity__c = Decimal.valueOf(objSearchProd.Product_Name__c);
                            objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                            objQP.Build_Type__c = objSearchProd.Base_Item_Lookup__r.Name;
                            // Fetching AudioCodes prices from custom settings based on Base Item name and quantity selected
                            AudioCodes__c objAudioCodeSettings = AudioCodes__c.getInstance(objSearchProd.Base_Item_Lookup__r.Name + objSearchProd.Product_Name__c);
                            if(objAudioCodeSettings != null)
                                objQP.List_Price__c *= objAudioCodeSettings.Volume_Break_Multiplier__c;
                        }
                        else
                        {
                            // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
                            objQP.Quantity__c = objSearchProd.Quantity__c;
                            objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                        }
                        
                        // EMEA Volume Discount for old pricing
                        if(!blnIsNewPricing && strPricebookFieldName.containsIgnoreCase('EMEA') && objSearchProd.EMEA_Volume_Discount_Eligible__c)
                        {
                            for(EMEA_Volume_Discounts__c objEMEADiscount : EMEA_Volume_Discounts__c.getall().values())
                            {
                                if(objQP.Quantity__c >= objEMEADiscount.Range_Start__c && objQP.Quantity__c <= objEMEADiscount.Range_End__c)
                                {
                                    objQP.EMEA_Volume_Discount__c = objEMEADiscount.Discount__c;
                                    objQP.List_Price__c -= (objQP.List_Price__c * objQP.EMEA_Volume_Discount__c/100);
                                    break;
                                }
                            }
                        }
                        
                        objQP.BigMachines__Sales_Price__c = 0;
                        objQP.or_Amount__c = '%';
                        objQP.Disc__c = objSearchProd.Discount__c;
                        list_QuoteProductsToBeCreated.add(objQP);
                        //ProductId_set.add(objSearchProd.id);
                        }
                    }
                    objSearchProd.Quantity__c = null;
                    objSearchProd.Product_Name__c = null;
                    objSearchProd.Discount__c = null;
                }
            } 
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
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
    
    
    public void removeAlaCarteItem(){
        Integer intRow = Integer.valueOf(strProdIndex);
        if(!list_OfAlaCarteToBeSaved.isEmpty()){
            if(intRow >= 0 && intRow < list_OfAlaCarteToBeSaved.size()){
                list_OfAlaCarteToBeSaved.remove(intRow);
            }    
        }
    }
    
    // *** To remove all products and bundles from right side panel ***
    public void removeAllBtnHandler()
    {
        list_QuoteProductsToBeCreated = new List<BigMachines__Quote_Product__c>();
        list_BundlesToBeSaved = new List<Product_Group__c>();
        list_CampaignsToBeSaved  = new List<BigMachines__Quote_Product__c>();
    }
    
    // *** Handler for 'Mark Favourite' button ***
    public void markFavBtnHandler()
    {
        blnShowFavSaveOptions = true;
        objFavToBeSaved = new Product_Group__c();
    }
    
    // *** Handler for 'Save Favourite' button ***
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
            objFavToBeSaved.User__c = UserInfo.getUserId();
            insert objFavToBeSaved;
            
            // Adding the products and bundles in the right side panel to the Favourite
            List<Product_Group_Item__c> list_FavItemsToInsert = new List<Product_Group_Item__c>();
            // Adding Bundles
            for(Product_Group__c objSavedBundle : list_BundlesToBeSaved)
            {
                Product_Group_Item__c objFavItem = new Product_Group_Item__c(Product_Group__c = objFavToBeSaved.Id);
                objFavItem.Quantity__c = objSavedBundle.Quantity__c != null ? objSavedBundle.Quantity__c : 1;
                objFavItem.Bundle__c = objSavedBundle.Id;
                list_FavItemsToInsert.add(objFavItem);
            }
            // Adding Sell-able Products
            for(BigMachines__Quote_Product__c objQP: list_QuoteProductsToBeCreated)
            {
                Product_Group_Item__c objFavItem = new Product_Group_Item__c(Product_Group__c = objFavToBeSaved.Id);
                objFavItem.Quantity__c = objQP.Quantity__c != null ? objQP.Quantity__c : 1;
                objFavItem.Product__c = objQP.BigMachines__Product__c;
                list_FavItemsToInsert.add(objFavItem);
            }
            
            //Adding Campaigns Or Dynamic Bundles
            /* for(BigMachines__Quote_Product__c objQP: list_CampaignsToBeSaved)
            {
            Product_Group_Item__c objFavItem = new Product_Group_Item__c(Product_Group__c = objFavToBeSaved.Id);
            objFavItem.Quantity__c = objQP.Quantity__c != null ? objQP.Quantity__c : 1;
            objFavItem.Product__c = objQP.BigMachines__Product__c;
            list_FavItemsToInsert.add(objFavItem);
            }*/
            
            // Insert Favourite items
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
    
    // *** Handler for 'Cancel' (cancelling creation of Favourite) button ***
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
        
        for(BigMachines__Quote_Product__c objQP : list_CampaignsToBeSaved){
            set_ProductIds.add(objQP.BigMachines__Product__c);            
        }
        
        if(productGroupIds != null){
            List<Product_Group_Item__c> groupItems = [SELECT Product__c FROM Product_Group_Item__c WHERE Product_Group__c IN : productGroupIds];
            for(Product_Group_Item__c eachGI : groupItems){
                set_ProductIds.add(eachGI.Product__c);            
            }
        }
        list_NotificationProducts = new List<ConfirmationWrapper>();
        /*  EOL_Value = Product has prerequisites or limited compatibility or is headed towards EOL
      Restrictions_Value = New product with limited functionality or other restrictions
      Expansion_Only_Value = Product available for expansion only */
        for(Product2 objProduct : [SELECT Id, Name, Description, Notification_Message__c, EOL_Announced_Date__c, Tier_Pricing_Decimal_Precision__c FROM Product2 
                                   WHERE Id IN :set_ProductIds AND (Shipment_Approval__c = :Label.EOL_Value OR Shipment_Approval__c = :Label.Restrictions_Value OR
                                                                    Shipment_Approval__c = :Label.Expansion_Only_Value OR (EOL_Announced_Date__c != NULL AND EOL_Announced_Date__c < TODAY)) ORDER BY Name]){
                                                                        
                QuoteUtil.addProductPrecisionToMap(objProduct, mapProductIdToDecimalPrecision); // Tier_Pricing_Decimal_Precision__c
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
                System.debug('>>> ' + objConf.objProd.Id);
                System.debug('>>> ' + objQP.BigMachines__Product__c);
                System.debug('>>> ' + objQP.quantity__c);
                if(objConf.objProd.Id == objQP.BigMachines__Product__c)
                {
                    System.debug('>>> inside if');
                    objQP.Confirmation__c = true;
                    break;
                }
            }
        }
        blnShowConfirmPanel = false;
        list_NotificationProducts.clear();
        saveLogic();
    }
    
    public boolean Check_GU_EMEA_Quote(){
        if(objQuote.Sold_To_Region__c == 'EMEA'){
            //Check if it already contains GU items
            Set<Id> set_ProductIds = new Set<Id>();
            for(BigMachines__Quote_Product__c objQP : list_QuoteProductsToBeCreated)
                set_ProductIds.add(objQP.BigMachines__Product__c);
            
            integer existing_trng_cnt = [select count() from product2 where id in (select BigMachines__Product__c from BigMachines__Quote_Product__c where BigMachines__Quote__c=:objQuote.id) and (building_block__c ='Training Unit' or building_block__c = 'PS RDP Training Packages')];
            integer existing_non_trng_cnt = [select count() from product2 where id in (select BigMachines__Product__c from BigMachines__Quote_Product__c where BigMachines__Quote__c=:objQuote.id) and building_block__c not in ('Training Unit','PS RDP Training Packages','Business Care')];
            
            // Check if GU items and license items are mixed together
            integer trng_unitcnt = [select count() from product2 where id in:set_ProductIds and (building_block__c ='Training Unit' or building_block__c = 'PS RDP Training Packages')];
            integer non_trng_unt_cnt = [select count() from product2 where id in:set_ProductIds and (building_block__c <> 'Training Unit' and building_block__c <> 'PS RDP Training Packages')]; 
            /*if(trng_unitcnt + existing_trng_cnt > 0 && existing_non_trng_cnt == 0 && non_trng_unt_cnt == 0){
        objQuote.Is_GU_EMEA__c = true;
        update objQuote;
      }   */
            if(trng_unitcnt + existing_trng_cnt >0 && existing_non_trng_cnt + non_trng_unt_cnt>0)
                return true;
        }
        return false;
    }
    
    // *** Handler for 'Save' button on right side panel ***
    public void saveBtnHandler()
    {
        
        strIsSaveSuccessful = 'No';
        if(list_QuoteProductsToBeCreated.size() > 0 || productGroupIds != null || list_PureSuccessToBeSaved.size()>0 || list_CampaignsToBeSaved.size()>0)
        {
            checkForRequiredConfirmations();
            if(blnShowConfirmPanel)
                return;
        }
        saveLogic();
    }
    
    public void saveLogic()
    {
        Savepoint objSP = Database.setSavepoint();
        try
        {
            String strType = '';
            List<BigMachines__Quote_Product__c> list_ToInsert = new List<BigMachines__Quote_Product__c>();
            
            List<BigMachines__Quote_Product__c> list_BundlesToInsert = new List<BigMachines__Quote_Product__c>();
            List<List<BigMachines__Quote_Product__c>> list_RelatedSellableItemLines = new List<List<BigMachines__Quote_Product__c>>();                      
            List<BigMachines__Quote_Product__c> list_Campaign_update = new List<BigMachines__Quote_Product__c>();
            if(!list_PureSuccessToBeSaved.isEmpty()){
                list_BundlesToBeSaved.addAll(list_PureSuccessToBeSaved);
                strType = 'PureSuccess';
            }
            
            // Modified by Ashish (02/19/2019)
            // Added base package and puresuccess condition
            for(BigMachines__Quote_Product__c qtProd : [SELECT BigMachines__Product__c FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c =:objQuote.id 
                                                        AND Bundle__r.Group_Type__c != 'Base Package' AND Bundle__r.Group_Type__c != 'PureSuccess' 
                                    //MS-duplicate prod
                                    AND BigMachines__Product__r.Allow_Duplicate_Parts_for_Product__c = false] )  {

                ProductId_set.add(qtProd.BigMachines__Product__c);
            }
            for(BigMachines__Quote_Product__c bqp :  list_QuoteProductsToBeCreated){
                if(ProductId_set.size() == 0 || !ProductId_set.contains(bqp.BigMachines__Product__c))
                    list_ToInsert.add(bqp);
            }
            //list_ToInsert.addAll(list_QuoteProductsToBeCreated);
            if(!list_UseCases.isEmpty())
                strType = 'Use Case';
            System.debug('NKC debug list_PureSuccessToBeSaved [' + list_PureSuccessToBeSaved + ']');
            System.debug('NKC debug list_BundlesToBeSaved [' + list_BundlesToBeSaved + ']');
            if(String.isNotBlank(strPricebookFieldName))
            {
                String strBundleQuery = 'SELECT Id,Product__r.' + strPricebookFieldName;    
                strBundleQuery += ',(SELECT Product__c,Product__r.Description,Product__r.PPU_Product_Specific_Discount__c,Product__r.APN_Number__c,Product__r.Building_Block__c';
                strBundleQuery += ',Product__r.' + strPricebookFieldName;
                if(objQuote.Pricing_Model__c != 'Enabled')
                    strBundleQuery += ',Product__r.Pricing_Model__c';
                strBundleQuery += ',Product__r.Product_Manager_Approval_Group__r.Name,Product__r.Name,Product__r.Third_Party__c,Product__r.Third_Party_GC__c,Product__r.Unit_of_Measure__c,Quantity__c FROM Product_Group_Items__r)';
                strBundleQuery += ' FROM Product_Group__c WHERE Id IN :list_BundlesToBeSaved';
                
                Set<Id> setOfProductIds = new Set<Id>();
                //Querying and adding Base Package products do dedup the use case lines.
                for(BigMachines__Quote_Product__c eachQP : [SELECT BigMachines__Product__c FROM BigMachines__Quote_Product__c
                                                            WHERE BigMachines__Quote__c =:objQuote.id]){
                    setOfProductIds.add(eachQP.BigMachines__Product__c);                                                
                }
                
                System.debug('>>>>strBundleQuery'+ strBundleQuery);
                Map<Id,Product_Group__c> map_Bundles = new Map<Id,Product_Group__c>((List<Product_Group__c>)Database.query(strBundleQuery));
                System.debug('>>>>>>>map_Bundles'+ map_Bundles.size());
                for(Product_Group__c objSavedBundle : list_BundlesToBeSaved)
                {
                    Product_Group__c objQueriedBundle = map_Bundles.get(objSavedBundle.Id);
                    if(!ProductId_set.contains(objQueriedBundle.Product__c)){
                        BigMachines__Quote_Product__c objBundleQP = new BigMachines__Quote_Product__c();
                        objBundleQP.Name = objSavedBundle.Name;
                        if(!String.isBlank(objSavedBundle.Play_Offer__c)){
                            if(map_ProductGrpIdPlayOffer.containsKey(objSavedBundle.Id)){
                                    String playOffer = map_ProductGrpIdPlayOffer.get(objSavedBundle.Id);
                                    objBundleQP.Offer__c = playOffer;
                                    objBundleQP.Play__c = (playOffer).split('-')[0];
                                    //if(objBundleQP.Play__c.contains('PureBridge'))objBundleQP.Play__c = objBundleQP.Play__c +' 3.0';
                                }
                        }else{
                            objBundleQP.Play__c = objQuote.Top_Play__c;
                        }                            
                        objBundleQP.BigMachines__Quote__c = objQuote.Id;
                        objBundleQP.BigMachines__Product__c = objSavedBundle.Product__c;
                        objBundleQP.Unit_of_Measure__c = 'Seat';
                        // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
                        System.debug('>>>>objSavedBundle.Quantity__c'+ objSavedBundle.Quantity__c);
                        System.debug('>>>>objBundleQP.Quantity__c'+ objBundleQP.Quantity__c);
                        objBundleQP.Quantity__c = objSavedBundle.Quantity__c;
                        objBundleQP.BigMachines__Quantity__c = objBundleQP.Quantity__c;
                        objBundleQP.List_Price__c = objSavedBundle.Price__c;
                        objBundleQP.BigMachines__Sales_Price__c = 0;
                        objBundleQP.or_Amount__c = '%';
                        objBundleQP.Disc__c = objSavedBundle.Additional_Discount__c;
                        objBundleQP.Bundle_Discount__c = objSavedBundle.Discount__c;
                        objBundleQP.Bundle__c = objSavedBundle.Id;
                        //Added by Ashish (24/01), to hide the product record on commerce page.
                        objBundleQP.APN_Number__c = objSavedBundle.Product__r.APN_Number__c;
                        objBundleQP.Hide_Record__c = true;
                        objBundleQP.Line_Number__c = 100;
                        if(strType == 'PureSuccess' || strType == 'Use Case'){ 
                            objBundleQP.Quantity__c = 1;
                            objBundleQP.BigMachines__Quantity__c = 1;
                            objBundleQP.Line_Number__c = 9999;                        
                            System.debug('NKC debug strPricebookFieldName [' + strPricebookFieldName + ']');
                            if(objQueriedBundle.Product__c != null){
                                Decimal decPrice = (Decimal)objQueriedBundle.getSObject('Product__r').get(strPricebookFieldName);
                                objBundleQP.List_Price__c = decPrice;
                            }
                            list_BundlesToInsert.add(objBundleQP);
                            //ProductId_set.add(objQueriedBundle.Product__c);
                        }
                    }
                    List<BigMachines__Quote_Product__c> list_SellableItemLines = new List<BigMachines__Quote_Product__c>();
                    for(Product_Group_Item__c objGroupItem : objQueriedBundle.getSObjects('Product_Group_Items__r'))
                    {
                        Product2 objProduct = (Product2)objGroupItem.getSObject('Product__r');
                        if(strType == 'Use Case'){
                            if(!setOfProductIds.contains(objProduct.id)){
                                setOfProductIds.add(objProduct.id);    
                            }
                            else 
                                continue;
                        }
                        
                        System.debug('++++++objProduct' +objProduct);
                        Decimal decPrice;
                        // For PS RDP products fetch price from Custom Settings based on region and product
                        if(objProduct.Building_Block__c == 'PS Rapid Deployment Packages' && 
                           String.isNotBlank(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c))
                        {
                            PSRDP_Pricing__c objPriceSettings = PSRDP_Pricing__c.getInstance(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c + '##' + objGroupItem.Product__c);
                            if(objPriceSettings != null)
                                decPrice = objPriceSettings.Price__c;
                        }
                        else
                            decPrice = (Decimal)objProduct.get(strPricebookFieldName);
                        if(decPrice == null)
                            decPrice = 0;
                        if(decPrice != null && decPrice != -1)
                        {
                            decPrice *= PRICE_MULTIPLIER;
                            if(!ProductId_set.contains(objProduct.id)){
                            BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                            objQP.Name = objProduct.Name;
                            if(!String.isBlank(objSavedBundle.Play_Offer__c)){
                                if(map_ProductGrpIdPlayOffer.containsKey(objSavedBundle.Id)){
                                String playOffer = map_ProductGrpIdPlayOffer.get(objSavedBundle.Id);
                                objQP.Offer__c = playOffer;
                                objQP.Play__c = (playOffer).split('-')[0];
                                //if(objQP.Play__c.contains('PureBridge'))objQP.Play__c = objQP.Play__c +' 3.0';
                            }
                            }else{
                                // objQP.Offer__c = objQuote.Offer__c;
                                objQP.Play__c = objQuote.Top_Play__c;
                            }                           
                            objQP.BigMachines__Quote__c = objQuote.Id;
                            objQP.BigMachines__Product__c = objGroupItem.Product__c;
                            if(objProduct.Description != null)
                                objQP.Product__c = (objProduct.Description.length() > 255 ? objProduct.Description.left(255) : objProduct.Description);
                            objQP.APN_Number__c = objProduct.APN_Number__c;
                            objQP.Product_Specific_Discount__c = objProduct.PPU_Product_Specific_Discount__c;
                            objQP.Pm_Approver__c = objProduct.Product_Manager_Approval_Group__r.Name;
                            objQP.Unit_of_Measure__c = objProduct.Unit_of_Measure__c;
                            objQP.Third_Party__c = objProduct.Third_Party__c;
                            objQP.Third_Party_GC__c = objProduct.Third_Party_GC__c;
                            objQP.Original_Third_Party_GC__c = objProduct.Third_Party_GC__c;
                            // Committed Quantity stores the quantity of the product in the bundle
                            //objQP.Committed_Quantity__c = (objGroupItem.Quantity__c != null ? objGroupItem.Quantity__c : 1);
                            // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
                            objQP.Quantity__c = 1;
                            objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                            objQP.Line_Number__c = ++intLineNumber;//-Navaneetha Nov -28th 2019 - Used to track the line number for the quote product level- 
                            objQP.List_Price__c = decPrice;
                            
                            // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                            if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objProduct.Pricing_Model__c)
                               && objProduct.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                                objQP.List_Price__c *= decPricingMultiplier;
                            
                            objQP.BigMachines__Sales_Price__c = 0;
                            //objQP.or_Amount__c = '%';
                            //objQP.Disc__c = objSavedBundle.Additional_Discount__c;
                            objQP.Bundle_Discount__c = objSavedBundle.Discount__c;
                            objQP.Bundle__c = objSavedBundle.Id;
                            objQP.Line_Number__c = 100;
                            if(strType == 'PureSuccess'){ 
                                objQP.List_Price__c = 0;
                                objQP.Line_Number__c = 9999;
                            }
                            list_ToInsert.add(objQP);
                            ProductId_set.add(objProduct.id);
                            }
                        }
                    }
                    list_RelatedSellableItemLines.add(list_ToInsert);
                }
            }
            
            // Savepoint before DML
            //objSP = Database.setSavepoint();
            // Skip Triggers
            Util.Bypass_Trigger_Chk = true;
            
            //Deleting existing PureSuccess Bundle before adding the new one.
            if(strType == 'PureSuccess'){
                List<BigMachines__Quote_Product__c> listOfQuoteProducts = [SELECT id FROM BigMachines__Quote_Product__c
                    WHERE BigMachines__Quote__c =: objQuote.id AND Bundle__r.Group_Type__c = 'PureSuccess'];
                if(!listOfQuoteProducts.isEmpty())
                    delete listOfQuoteProducts;            
            }
            
            if(!list_BundlesToInsert.isEmpty())
            {
                insert list_BundlesToInsert;
                //8365 EMEA Entity
                if(Check_GU_EMEA_Quote() == true){
                    // Roll back changes in case of DML failure
                    Database.rollback(objSP);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please note it is not permitted to sell Training and license products together in EMEA. You would be required to create seperate quote for each one'));
                    return;
                }    
                if(strType == 'PureSuccess'){
                    for(Integer i=0; i< list_BundlesToInsert.size() ; i++){
                        for(BigMachines__Quote_Product__c objQP : list_RelatedSellableItemLines[i]){
                            objQP.Bundle_Line__c = list_BundlesToInsert[i].Id;
                            System.debug('NKC debug objQP.Bundle_Line__c [' + objQP.Bundle_Line__c +']');
                        }
                    }               
                }
            }
            Util.Bypass_Trigger_Chk = true;
            
            if(!list_ToInsert.isEmpty()){
                insert list_ToInsert;
            }
            
            //Added by JJ for dynamic bundle
            if(list_CampaignsToBeSaved.size()>0){
                
                insert list_CampaignsToBeSaved; 
                for(string campaignid:map_campaigntomainproduct.keySet()){
                    BigMachines__Quote_Product__c QPMain = map_campaigntomainproduct.get(campaignid);
                    insert QPMain;
                    for(BigMachines__Quote_Product__c qp:list_CampaignsToBeSaved){
                        if(qp.Bundle__c == campaignid){
                            qp.Bundle_Line__c = QPMain.id;
                            //qp.Committed_Quantity__c = 1;
                            list_Campaign_update.add(qp);
                        }
                    }
                    update  list_Campaign_update;
                }
            }    
            
            
            //Saving A la Carte 
            saveAlaCarteItems();

            //Bursting. Add burst products
            (new SubscriptionBurstTerm()).addMissingBurstProdsToQuote(objQuote.id);
            
            strIsSaveSuccessful = 'Yes';
          
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
        
    } //END SsaveLogic()
    
    private void saveAlaCarteItems(){
        List<Product_Group__c> listProductGroup = [SELECT id FROM Product_Group__c WHERE Type__c = 'A la Carte' AND Active__c = true
                AND Offering_Type__c INCLUDES (:objQuote.Offering_Type__c)];
        Map<Id, Product2> mapOfProductIdVsProducts = new Map<Id, Product2>();
        for(Product2 eachProduct : list_OfAlaCarteToBeSaved){
            mapOfProductIdVsProducts.put(eachProduct.id, eachProduct);
        }
        Set<Id> setOfProductIds = mapOfProductIdVsProducts.keyset();
        String strProduct2Query = 'SELECT Id, Description, Product_Specific_Discount__c, PPU_Product_Specific_Discount__c, APN_Number__c, Building_Block__c,' + strPricebookFieldName;
        if(objQuote.Pricing_Model__c != 'Enabled')
        strProduct2Query += ',Pricing_Model__c';
        strProduct2Query += ',Product_Manager_Approval_Group__r.Name,Name,Third_Party__c,Third_Party_GC__c,Unit_of_Measure__c,Quantity__c,Tier_Pricing_Decimal_Precision__c';
        strProduct2Query += ' FROM Product2 WHERE id IN : setOfProductIds';
        System.debug('NKC debug strProduct2Query ['+ strProduct2Query + ']');
        List<Product2> listOfProducts  = (List<Product2>)Database.query(strProduct2Query);
        QuoteUtil.addProductPrecisionToMap(listOfProducts, mapProductIdToDecimalPrecision); // Tier_Pricing_Decimal_Precision__c
        
        List<BigMachines__Quote_Product__c> listOfQPToBeInserted = new List<BigMachines__Quote_Product__c>();
        for(Product2 objProduct : listOfProducts){
            Decimal decPrice;
            decPrice = (Decimal)objProduct.get(strPricebookFieldName);

           if(decPrice != null && decPrice != -1 && !ProductId_set.contains(objProduct.id)){
                decPrice *= PRICE_MULTIPLIER;
                BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                objQP.Name = objProduct.Name;
                objQP.Play__c = objQuote.Top_Play__c;
                //objQP.Offer__c = objQuote.Offer__c;
                objQP.BigMachines__Quote__c = objQuote.Id;
                objQP.BigMachines__Product__c = objProduct.id;
                if(objProduct.Description != null)
                    objQP.Product__c = (objProduct.Description.length() > 255 ? objProduct.Description.left(255) : objProduct.Description);
                objQP.APN_Number__c = objProduct.APN_Number__c;
                objQP.Product_Specific_Discount__c = objProduct.PPU_Product_Specific_Discount__c;
                objQP.Pm_Approver__c = objProduct.Product_Manager_Approval_Group__r.Name;
                objQP.Unit_of_Measure__c = objProduct.Unit_of_Measure__c;
                objQP.Third_Party__c = objProduct.Third_Party__c;
                objQP.Third_Party_GC__c = objProduct.Third_Party_GC__c;
                objQP.Original_Third_Party_GC__c = objProduct.Third_Party_GC__c;
                objQP.Quantity__c = mapOfProductIdVsProducts.get(objProduct.id).Quantity__c;
                if(!listProductGroup.isEmpty())
                    objQP.Bundle__c = listProductGroup[0].id;
                objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                objQP.List_Price__c = decPrice;

                objQP.Line_Number__c = 100;
                // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objProduct.Pricing_Model__c)
                    && objProduct.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                    objQP.List_Price__c *= decPricingMultiplier;
                objQP.BigMachines__Sales_Price__c = 0;                          
                listOfQPToBeInserted.add(objQP);
                ProductId_set.add(objProduct.id);
            }
        }
        if(!listOfQPToBeInserted.isEmpty())
            insert listOfQPToBeInserted;
    }
    
    // *** Handler for 'Search' button in Product Search ***
    public void searchBtnHandler()
    {
        //8365 EMEA Entity
        if(Check_GU_EMEA_Quote() == true){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please note it is not permitted to sell Training and license products together in EMEA. You would be required to create seperate quote for each one'));
            return;
        }
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
    {
        list_SearchProducts = Database.query(strProductSearchQuery + ' OFFSET ' + String.valueOf((intPageNum - 1) * intPageSize));
        QuoteUtil.addProductPrecisionToMap(list_SearchProducts, mapProductIdToDecimalPrecision);
        for(Product2 objSearchResult : list_SearchProducts)
        {
            // For PS RDP products fetch price from Custom Settings based on region and product            
            if(objSearchResult.Building_Block__c == 'PS Rapid Deployment Packages' && String.isNotBlank(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c))
            {
                PSRDP_Pricing__c objPriceSettings = PSRDP_Pricing__c.getInstance(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c + '##' + objSearchResult.Id);
                if(objPriceSettings != null)
                    objSearchResult.put(strPricebookFieldName,objPriceSettings.Price__c);
            }
            // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
            if(objQuote.Pricing_Model__c != null && objQuote.Pricing_Model__c != 'Enabled' && objSearchResult.Pricing_Model__c != null
               && objSearchResult.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                objSearchResult.put(strPricebookFieldName,((Decimal)objSearchResult.get(strPricebookFieldName)) * decPricingMultiplier);
            
            
            objSearchResult.put(strPricebookFieldName, convertAndUpdatePrice(((Decimal)objSearchResult.get(strPricebookFieldName)), objQuote, objSearchResult, currentCurreny));
            
            if(String.isNotBlank(objSearchResult.Quantities_Available__c))
            {
                if(!map_QuantitiesToSelectOptions.containsKey(objSearchResult.Quantities_Available__c))
                {
                    List<SelectOption> list_Options = new List<SelectOption>();
                    for(String strQuantity : objSearchResult.Quantities_Available__c.split(';'))
                        list_Options.add(new SelectOption(strQuantity,strQuantity));
                    map_QuantitiesToSelectOptions.put(objSearchResult.Quantities_Available__c,list_Options);
                }
            }            
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
    
    // *** Create query string for PS RDP Recommendation products based on APN Numbers ***
    /****************Commented by Priyank on 21-Aug-2018***********************************************
    Description:- As discussed with Naresh, this method is not in use and effecting the code coverage.
    Commented from line number 2157 to 2172
    ***************************************************************************************************
    private String createPSRDPRecommendationsQueryString(Set<String> set_APNnumbers)
    {
        String strPSRDPTrainingProductQuery = 'SELECT Id,Name,Description,Third_Party_GC__c,APN_Number__c,';
        strPSRDPTrainingProductQuery += 'PPU_Product_Specific_Discount__c,Third_Party__c,Unit_of_Measure__c,Pricing_Model__c,Product_Manager_Approval_Group__r.Name';           
        
        if(String.isNotBlank(strPricebookFieldName))
            strPSRDPTrainingProductQuery += ',' + strPricebookFieldName;
        
        strPSRDPTrainingProductQuery += ' FROM Product2 WHERE APN_Number__c IN :set_APNnumbers';
        
        if(String.isNotBlank(strPricebookFieldName))
            strPSRDPTrainingProductQuery += ' AND ' + strPricebookFieldName + ' != null AND ' + strPricebookFieldName + ' != -1';
        
        System.debug(strPSRDPTrainingProductQuery);
        return strPSRDPTrainingProductQuery;
    } */
    
    // *** Create query string for Base Products based on Category and Building Block ***
    private String createBaseProductQueryString()
    {
        if(objQuote.Offering_Type__c == 'PureEngage Subscription'){
            String taxonomyCategoryFieldName = 'Taxonomy_Category__c';
            String taxonomySubCategoryFieldName = 'Taxonomy_Sub_Category__c';
            String productFinancialFieldName = 'Building_Block__c';
            
            String strBaseProdQuery = 'SELECT Id,Name,Quantity__c,Discount__c,Unit_of_Measure__c,Show_New__c,SI_Version_Number__c,Maturity__c,ProductId_And_Version_Key__c, ';
            strBaseProdQuery += 'Versions_Available__c,Latest_Version__c,Quantities_Available__c,Product_Name__c,Version_Available_For_old__c,Type__c,Third_Party__c,NG1_PPU_Gold_USD__c,NG1_PPU_Silver_USD__c,';
            strBaseProdQuery += taxonomyCategoryFieldName;
            strBaseProdQuery += ',' + taxonomySubCategoryFieldName;
            strBaseProdQuery += ',' + productFinancialFieldName;
            
            if(String.isNotBlank(strPricebookFieldName))
                strBaseProdQuery += ',' + strPricebookFieldName;
            
            if(objQuote.Pricing_Model__c != 'Enabled')
                strBaseProdQuery += ',Pricing_Model__c';
            
            strBaseProdQuery += ',Show_In_BEP__c';
            
            strBaseProdQuery += ',(SELECT Id,Name,Unit_of_Measure__c,Quantity__c,Discount__c,Show_New__c,SI_Version_Number__c, Maturity__c,ProductId_And_Version_Key__c,';
            strBaseProdQuery += ' Versions_Available__c,Latest_Version__c,Quantities_Available__c,Product_Name__c,Version_Available_For_old__c,Third_Party__c,NG1_PPU_Gold_USD__c,NG1_PPU_Silver_USD__c';
            if(String.isNotBlank(strPricebookFieldName))
                strBaseProdQuery += ',' + strPricebookFieldName;
            if(objQuote.Pricing_Model__c != 'Enabled')
                strBaseProdQuery += ',Pricing_Model__c';
            strBaseProdQuery += ' FROM Products__r WHERE Show_Base_Item__c = true AND OfferingType__c INCLUDES (\'' + objQuote.Offering_Type__c + '\')';
            // AND Shipment_Approval__c != :strBundleOnlyProduct';
            if(!objQuote.Show_Genesys_Care_Tab__c){
                strBaseProdQuery += ' AND zqu__Category__c != \'Base Products\'';  
            }
            if(String.isNotBlank(strPricebookFieldName))
                strBaseProdQuery += ' AND ' + strPricebookFieldName + ' != null AND ' + strPricebookFieldName + ' != -1';
            strBaseProdQuery += ' ORDER BY Name)';
            
            strBaseProdQuery += ',Tier_Pricing_Decimal_Precision__c';
            strBaseProdQuery += ' FROM Product2 WHERE Show_Base_Item__c = true';
            strBaseProdQuery += ' AND Parent_Product_lookup__c = null  AND OfferingType__c INCLUDES (\'' + objQuote.Offering_Type__c + '\')';
            // AND Shipment_Approval__c != :strBundleOnlyProduct';
            /*
            if(strProductFinancial != 'All')
            {
                strBaseProdQuery += ' AND ( ' + productFinancialFieldName + ' = :strProductFinancial)';            
            }
            */
            if(String.isNotBlank(strPricebookFieldName))
                strBaseProdQuery += ' AND ' + strPricebookFieldName + ' != null AND ' + strPricebookFieldName + ' != -1';           
            if(!objQuote.Show_Genesys_Care_Tab__c){
                strBaseProdQuery += ' AND zqu__Category__c != \'Base Products\'';  
            }
            strBaseProdQuery += ' ORDER BY Anchor_Product__c DESC, Name ';
            System.debug('NKC debug strBaseProdQuery ['+strBaseProdQuery+']');
            return strBaseProdQuery;
        }
        else{
            String strBuildingBlockFieldName = 'Building_Block__c';
            String strBaseProdQuery = 'SELECT Id,Name,Quantity__c,Discount__c,Unit_of_Measure__c,Show_New__c,SI_Version_Number__c,Maturity__c,ProductId_And_Version_Key__c,Partner_Margin_Category__c,';
            strBaseProdQuery += 'Versions_Available__c,Latest_Version__c,Quantities_Available__c,Product_Name__c,Version_Available_For_old__c,Type__c,Third_Party__c,Price_Type__c,';
            strBaseProdQuery += 'Is_Concurrent__c,APN_Number__c,Pass_Through__c,Pricing_Model__c';
            strBaseProdQuery += ',' + strBuildingBlockFieldName;
            
            if(String.isNotBlank(strPricebookFieldName))
                strBaseProdQuery += ',' + strPricebookFieldName;

            strBaseProdQuery += ',Tier_Pricing_Decimal_Precision__c';

            //MS strBaseProdQuery += ' FROM Product2 WHERE OfferingType__c INCLUDES (\'' + objQuote.Offering_Type__c + '\')';
           //strBaseProdQuery += ' FROM Product2 WHERE (OfferingType__c INCLUDES (\'' + objQuote.Offering_Type__c + '\') OR OfferingType__c INCLUDES (\'' + objQuote.Offering_Feature__c + '\'))';
            if (objQuote.Offering_Type__c == 'PureConnect Subscription' && objQuote.Offering_Feature__c != null )          
                strBaseProdQuery += ' FROM Product2 WHERE OfferingType__c INCLUDES (\'' + objQuote.Offering_Feature__c + '\')';
            else 
               strBaseProdQuery += ' FROM Product2 WHERE OfferingType__c INCLUDES (\'' + objQuote.Offering_Type__c + '\')'; 
            
            strBaseProdQuery += ' AND Shipment_Approval__c != :strBundleOnlyProduct AND Show_In_Quoting__c = true';
            strBaseProdQuery += ' AND APN_Number__c != null';
            if(String.isNotBlank(strPricebookFieldName))
                    strBaseProdQuery += ' AND ' + strPricebookFieldName + ' != null AND ' + strPricebookFieldName + ' != -1';           
                //Changed from Part_Version__c to Product_Version__c
                strBaseProdQuery += ' AND Product_Version__c INCLUDES (\''+ objQuote.Product_Version__c +'\')';
                //if(selectedPricingModel != ''){
                //    strBaseProdQuery += ' AND Pricing_Model__c =:selectedPricingModel';     
                //}
            System.debug('NKC debug strProductFinancial [' + strProductFinancial + ']');
                if(strProductFinancial != 'All')
                  strBaseProdQuery += ' AND Building_Block__c =:strProductFinancial ';
                
                strBaseProdQuery += ' ORDER BY Name';
            
            System.debug(strBaseProdQuery);
            return strBaseProdQuery;
        }
    }
    
    // *** Create query string for products to be added from All Products ***
    private String createAddedProductsQueryString(List<Product2> list_ProductsToAdd)
    {
        String strSellableProdQuery = 'SELECT Id,SI_Version_Number__c,Third_Party_GC__c,Product_Specific_Discount__c,Third_Party__c,Product_Manager_Approval_Group__r.Name,';
        strSellableProdQuery += 'Price_Type__c, Pass_Through__c, Tier_Pricing_Decimal_Precision__c, (SELECT Range_From__c, Range_To__c, NG1_APAC_ANZ_AUD_Price__c, NG2_BRAZIL_BRL_Price__c, NG3_EMEA_EUR_Price__c,'; 
        strSellableProdQuery += 'NG3_EMEA_GBP_Price__c, NG4_APAC_JAPAN_YEN_Price__c, NG5_NA_USD_Price__c, NG5_ZAR_Price__c FROM Product_Tier_Pricings__r ORDER BY Range_From__c)';
        strSellableProdQuery += ' FROM Product2 WHERE Id IN :list_ProductsToAdd';
        
        System.debug(strSellableProdQuery);
        return strSellableProdQuery;
    }
    
    // *** Create query string for products to be added from Base Items ***
    private String createAddedProductsQueryString(List<Product2> list_ProductsToAdd,Set<String> set_Versions)
    {
        //modified by ankit
        String strSellableProdQuery = 'SELECT Id,Base_Item_Lookup__c,SI_Version_Number__c,Name,Description,Third_Party_GC__c,APN_Number__c,building_block__c,Type__c,';
        strSellableProdQuery += 'PPU_Product_Specific_Discount__c,Third_Party__c,Unit_of_Measure__c,Pricing_Model__c,Product_Manager_Approval_Group__r.Name,NG1_PPU_Silver_USD__c,NG1_PPU_Gold_USD__c';
        
        if(String.isNotBlank(strPricebookFieldName))
        {
            strSellableProdQuery += ',' + strPricebookFieldName;
            if(!blnIsNewPricing && strPricebookFieldName.containsIgnoreCase('EMEA'))
                strSellableProdQuery += ',EMEA_Volume_Discount_Eligible__c';
        }
        
        strSellableProdQuery += ',Tier_Pricing_Decimal_Precision__c';
        strSellableProdQuery += ' FROM Product2 WHERE Base_Item_Lookup__c IN :list_ProductsToAdd AND SI_Version_Number__c IN :set_Versions';
        
        if(String.isNotBlank(strPricebookFieldName))
            strSellableProdQuery += ' AND ' + strPricebookFieldName + ' != null AND ' + strPricebookFieldName + ' != -1';
            strSellableProdQuery += ' AND OfferingType__c INCLUDES (\'' + objQuote.Offering_Type__c + '\')';
  
        System.debug('NKC debug strSellableProdQuery [ ' + strSellableProdQuery + ']');
        return strSellableProdQuery;
    }
    
    // *** Create query string for products to be added based on favourites selected ***
    /****************Commented by Priyank on 21-Aug-2018***********************************************
    Description:- As discussed with Naresh, this method is not in use and effecting the code coverage.
    Commented from Line 2303 to 2339.
    ***************************************************************************************************
    private String createAddedFavoritesQueryString(Set<Id> set_FavIds)
    {
        String strGroupItemQuery = 'SELECT Quantity__c,Bundle__c,Product__c,Product__r.Quantities_Available__c,Product__r.Base_Item_Lookup__r.Name,Product__r.APN_Number__c';
        strGroupItemQuery += ',Product__r.' + strPricebookFieldName;
        strGroupItemQuery += ',Product__r.Third_Party__c,Product__r.Unit_of_Measure__c,Product__r.Third_Party_GC__c,Product__r.Product_Manager_Approval_Group__r.Name';
        
        if(objQuote.Pricing_Model__c != 'Enabled')
            strGroupItemQuery += ',Product__r.Pricing_Model__c';
        
        if(!blnIsNewPricing && strPricebookFieldName.containsIgnoreCase('EMEA'))
            strGroupItemQuery += ',Product__r.EMEA_Volume_Discount_Eligible__c';
        
        strGroupItemQuery += ',Product__r.PPU_Product_Specific_Discount__c,Product__r.Name,Product__r.Description,Product__r.Building_Block__c';
        strGroupItemQuery += ' FROM Product_Group_Item__c WHERE Product_Group__c IN :set_FavIds AND Quantity__c != null AND Quantity__c > 0';
        strGroupItemQuery += ' AND Product__r.Shipment_Approval__c != :strBundleOnlyProduct  AND OfferingType__c INCLUDES (\'' + objQuote.Offering_Type__c + '\')';
        
        if(!blnIsNewPricing)
            strGroupItemQuery += ' AND Bundle__c = null';
        
        System.debug(strGroupItemQuery);
        return strGroupItemQuery;
    }
    
    // *** Create query string for bundles to be added from favourites being added ***
        private String createSelectedBundleQueryString(Set<Id> set_BundleIds)
    {
        String strBundleQuery = 'SELECT Id,Name,Discount__c,Product__c';
        strBundleQuery += ',(SELECT Product__c,Product__r.APN_Number__c,Product__r.Building_Block__c,Product__r.' + strPricebookFieldName;
        
        if(objQuote.Pricing_Model__c != 'Enabled')
            strBundleQuery += ',Product__r.Pricing_Model__c';
        
        strBundleQuery += ' FROM Product_Group_Items__r WHERE Product__r.' + strPricebookFieldName + ' != null)';
        strBundleQuery += ' FROM Product_Group__c WHERE Active__c = true AND Id IN :set_BundleIds';
        System.debug(strBundleQuery);
        return strBundleQuery;
    }*/
    
    // *** Create query string to fetch bundles when 'Bundles' option is slected from the tab panel ***
    private String createBundleQueryString(String groupType)
    {
        String strBundleQuery = 'SELECT Id,Name, Category__c, Active__c, Description__c,Type__c,Quantity__c,Discount__c,Additional_Discount__c,Price__c,Product__c,Selected__c';
        
        if(String.isNotBlank(strPricebookFieldName))
        {
            strBundleQuery += ',(SELECT Product__r.Name, Product__r.Quantity__c, Product__r.Description__c, Product__r.Description, Quantity__c,Product__r.Building_Block__c,Product__r.APN_Number__c,Product__r.' + strPricebookFieldName;
            if(objQuote.Pricing_Model__c != 'Enabled')
                strBundleQuery += ',Product__r.Pricing_Model__c, Product_Group__c ';
            strBundleQuery += ' FROM Product_Group_Items__r WHERE Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1)';
        }
        strBundleQuery += ' FROM Product_Group__c WHERE Group_Type__c = \'' + groupType +'\' AND Active__c = true AND Offering_Type__c INCLUDES (\'' + objQuote.Offering_Type__c + '\')';
        if(groupType == 'Use Case')
            strBundleQuery += ' ORDER BY Category__c, Name';
        else
            strBundleQuery += ' ORDER BY Order__c, Name';
        System.debug(strBundleQuery);
        return strBundleQuery;
    }
    
    
    // *** Create query string to fetch Campaings when 'Campaings ' option is slected from the tab panel ***
    private String createCampaingsQueryString()
    {
        String strCampaingsQuery = 'SELECT Id,Play_Offer__c,Name,Description__c,Type__c,Quantity__c,Discount__c,Additional_Discount__c,Price__c,Product__c';
        strCampaingsQuery += ',Product__r.Id,Product__r.Name,Product__r.Description,Product__r.SI_Version_Number__c,Product__r.Unit_of_Measure__c';
        strCampaingsQuery += ',Product__r.Quantity__c,Product__r.Discount__c,Product__r.Product_Name__c,Product__r.Third_Party_GC__c';
        strCampaingsQuery += ',Product__r.PPU_Product_Specific_Discount__c,Product__r.Third_Party__c,Product__r.Building_Block__c,Product__r.Show_New__c';
        strCampaingsQuery += ',Product__r.Quantities_Available__c,Product__r.Base_Item_Lookup__r.Name';
        strCampaingsQuery += ',Product__r.Product_Manager_Approval_Group__r.Name';  
        if(String.isNotBlank(strPricebookFieldName))
        {
            strCampaingsQuery += ',(SELECT Quantity__c,Product_Type__c,Product__r.Building_Block__c,Product__r.APN_Number__c,Product__r.' + strPricebookFieldName;
           
            if(objQuote.Pricing_Model__c != 'Enabled')
                strCampaingsQuery += ',Product__r.Pricing_Model__c';
            
            strCampaingsQuery += ' FROM Product_Group_Items__r WHERE Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1)';
        }
        strCampaingsQuery += ' FROM Product_Group__c WHERE Group_Type__c = \'Campaigns\' AND Type__c != null AND Active__c = true';
        strCampaingsQuery += ' AND Pricing_Model__c INCLUDES (\'' + objQuote.Pricing_Model__c + '\')';

        //Offering Type Condition Added by JJ on 07/18/18 as requested by Ankit
        //Changed by Anshul replaced = by include on 07/19/18
        //strCampaingsQuery += ' AND Offering_Type__c =  \'' + objQuote.Offering_Type__c + '\'';
        strCampaingsQuery += ' AND Offering_Type__c INCLUDES (\'' + objQuote.Offering_Type__c + '\')';
        
        strCampaingsQuery += ' ORDER BY Type__c,Name';
        System.debug(strCampaingsQuery);
        return strCampaingsQuery;
        
        
    }
    
    // *** Create query string for product search ***
    private String createSearchQueryString(Boolean blnIsCountQuery)
    {
        String strSearchQuery;
        if(!blnIsCountQuery)
        {
            strSearchQuery = 'SELECT Id,Name,Description,SI_Version_Number__c,Unit_of_Measure__c,Quantity__c,Discount__c,Product_Name__c,Maturity__c,ProductId_And_Version_Key__c,';
            strSearchQuery += 'PPU_Product_Specific_Discount__c,Third_Party__c,Show_New__c,Quantities_Available__c,Base_Item_Lookup__r.Name,NG1_PPU_Gold_USD__c,NG1_PPU_Silver_USD__c,';
            strSearchQuery += 'Product_Manager_Approval_Group__r.Name,APN_Number__c,Third_Party_GC__c,Building_Block__c,Type__c, Taxonomy_Solution_Category__c, Taxonomy_Solution__c,';
            strSearchQuery += 'Tier_Pricing_Decimal_Precision__c';

            if(!blnIsNewPricing)
            {
                //strSearchQuery += ',Section__c';
                if(strPricebookFieldName.containsIgnoreCase('EMEA'))
                    strSearchQuery += ',EMEA_Volume_Discount_Eligible__c';
            }
            
            if(String.isNotBlank(strPricebookFieldName))
                strSearchQuery += ',' + strPricebookFieldName;
            
            if(objQuote.Pricing_Model__c != 'Enabled')
                strSearchQuery += ',Pricing_Model__c';
        }
        else
            strSearchQuery = 'SELECT count()';
        
        strSearchQuery += ' FROM Product2 WHERE RecordType.Name != \'Base Item\' AND Type__c NOT IN :set_ExcludedTypes';
        strSearchQuery += ' AND Dont_Publish_In_Quote__c = false AND (Price_Effective_Date__c = null OR Price_Effective_Date__c <= TODAY)';
        strSearchQuery += ' AND Restricted_Product__c = false AND IsActive = true AND Shipment_Approval__c != :strBundleOnlyProduct';
        strSearchQuery += ' AND (Last_Order_Date__c = null OR Last_Order_Date__c >= TODAY)';
        strSearchQuery += ' AND (EOM_Date__c = null OR EOM_Date__c >= TODAY)';
        strSearchQuery += ' AND (End_Of_Support_Date__c = null OR End_Of_Support_Date__c >= TODAY)';

        //MS strSearchQuery += ' AND OfferingType__c INCLUDES (\'' + objQuote.Offering_Type__c + '\')';      
       // strSearchQuery += ' AND (OfferingType__c INCLUDES (\'' + objQuote.Offering_Type__c + '\') OR OfferingType__c INCLUDES (\'' + objQuote.Offering_Feature__c + '\'))';
        if (objQuote.Offering_Type__c == 'PureConnect Subscription' && objQuote.Offering_Feature__c != null )          
            strSearchQuery += ' AND OfferingType__c INCLUDES (\'' + objQuote.Offering_Feature__c + '\')';
        else 
            strSearchQuery += ' AND OfferingType__c INCLUDES (\'' + objQuote.Offering_Type__c + '\')'; 

        if ( searchProductStr != null && !String.isBlank(searchProductStr)) 
             strSearchQuery += ' AND (Name LIKE \'%' + searchProductStr + '%\' OR APN_Number__c LIKE \'%' + searchProductStr + '%\' OR Description LIKE \'%' + searchProductStr + '%\')' ;
                                     
/* //MS search 9/5/2019
        if(objQuote.Offering_Type__c == 'PureEngage Subscription'){        
            if(String.isNotBlank(objSearchProduct.Name))
                strSearchQuery += ' AND Name LIKE \'' + objSearchProduct.Name + '%\'';
            
            if(String.isNotBlank(objSearchProduct.Description__c))
                strSearchQuery += ' AND Description_Formula__c LIKE \'%' + objSearchProduct.Description__c + '%\'';         
        }
        else{
            if(String.isNotBlank(objSearchProduct.Name))
                strSearchQuery += ' AND APN_Number__c LIKE \'' + objSearchProduct.Name + '%\'';
            
            if(String.isNotBlank(objSearchProduct.Description__c))
                strSearchQuery += ' AND Name LIKE \'%' + objSearchProduct.Description__c + '%\'';      
        }
 */

        if(String.isNotBlank(objSearchProduct.Taxonomy_Solution_Category__c))
            strSearchQuery += ' AND Taxonomy_Solution_Category__c = \'' + objSearchProduct.Taxonomy_Solution_Category__c + '\'';
        
        if(String.isNotBlank(objSearchProduct.Taxonomy_Solution__c))
            strSearchQuery += ' AND Taxonomy_Solution__c = \'' + objSearchProduct.Taxonomy_Solution__c + '\'';
 
        if(String.isNotBlank(objSearchProduct.SI_Version_Number__c))
            strSearchQuery += ' AND SI_Version_Number__c = \'' + objSearchProduct.SI_Version_Number__c + '\'';
        
 //// MS - REMOVE -1 HERE for credits
        if(String.isNotBlank(strPricebookFieldName))
           strSearchQuery += ' AND ' + strPricebookFieldName + ' != null AND ' + strPricebookFieldName + ' != -1';
          // strSearchQuery += ' AND ' + strPricebookFieldName + ' != null AND (' + strPricebookFieldName + ' != -1 OR Type__c LIKE \'%Credit%\') ';

        strSearchQuery += ' AND IsActive = true ';
        if(!blnIsCountQuery)
        {
            strSearchQuery += ' ORDER BY ' + strSortField + ' ' + strSortOrder + ' NULLS LAST';
            strSearchQuery += ' LIMIT ' + String.valueOf(intPageSize);
        }
        else
            strSearchQuery += ' LIMIT 1500';
        
        System.debug('querystring***'+ strSearchQuery);
        return strSearchQuery;
    }
    // populates wrapper object/class
    private static ProductWrapper populateWrapper(Product2 objProduct2){
        Admin_Dummy__c objDummy = new Admin_Dummy__c(); 
        Product2 objProduct = objProduct2.clone(true, true);
        //objDummy.Name = objProduct.Product_Name__c;
        objDummy.Quantity__c = objProduct2.Quantity__c;
        //objDummy.Discount__c = objProduct2.Discount__c;
        //objDummy.SI_Version_No__c = objProduct2.SI_Version_Number__c;
        //objDummy.Versions_Available__c = objProduct.Versions_Available__c;
        ProductWrapper objProductWrapper = new ProductWrapper(objProduct, objDummy);
        //objDummy.Quantities_Available__c = objProduct.Quantities_Available__c;
        return objProductWrapper;
    }
    // populate info back to product2 object from dummy object
    private static Product2 populateProduct2FromDummy(Admin_Dummy__c objDummy, Product2 objProduct){
        //objProduct.Product_Name__c = objDummy.Name;
        objProduct.Quantity__c = objDummy.Quantity__c;
        //objProduct.Discount__c = objDummy.Discount__c;
        //objProduct.Versions_Available__c = objDummy.Versions_Available__c;
        //objProduct.SI_Version_Number__c = objDummy.SI_Version_No__c;
        //objProduct.Quantities_Available__c = objDummy.Quantities_Available__c;
        return objProduct;
    }
    // wrapper class having dummy and product2 object   
    public class ProductWrapper{
        public Product2 objProduct {get; set;}
        public Admin_Dummy__c objDummy {get;set;}
        public ProductWrapper(Product2 objProduct, Admin_Dummy__c objDummy){
            this.objProduct = objProduct;
            this.objDummy = objDummy;
        }
    }   
    // **************************** End : Dynamic Query Strings ********************
    
    // *** To Add Campaigns/Dynamic Bundles to the quote ***
    public PageReference addCampaignssBtnHandler() {
        
       
       //Added By Anshul on 07/19/2018 Substitutable Validation - Start
                    
           
            //Initializing
            errormap = new Map<id,boolean>();
            errormessage = new Map<id,string>();
            errorFlag = false;
                    
           
            for(string campaigntypeselected : list_CampaignsTypes){
            List<Product_Group__c>  objcampaign_list = map_CampaignsTypesToBundles.get(campaigntypeselected);
            //Loop through campaigns within campaigntypes
            for(Product_Group__c objcampaign:objcampaign_list){                
                    
                if(objcampaign.Quantity__c !=null){
                    
                    String productError = 'Please Select at least ';
                    
                    
                    
                    
                    //If users have not click on show products then return back
                    if(map_CampaignsIdToBundleProducts.get(objcampaign.Id)== null)
                        return null;
                    
                    Map<ID,String> idToManProductNameMap = new Map<ID,String>(); 
                    
                    //Mandatory to Substitutable Product Count
                    Map<String,Integer> mandatPrdToSubCountMap = new Map<String,Integer>();
                    
                    //Mandatory to Selected Substitutable Product Count
                    Map<String,Integer> mandatPrdToSubSelectedCountMap = new Map<String,Integer>();
                    
                    for(Product_Group_Item__c objcampaign_itemM:map_CampaignsIdToBundleProducts_Sub.get(objcampaign.Id)){
                        
                        if(objcampaign_itemM.Product_Type__c=='Mandatory Substitutable'){
                            
                             idToManProductNameMap.put(objcampaign_itemM.id,objcampaign_itemM.Product_Name__c);      
                            
                        }
                    }
                    
                    System.debug('@idToManProductNameMap ' + idToManProductNameMap);
                    
                    
                            
                            for(Product_Group_Item__c objcampaign_itemS:map_CampaignsIdToBundleProducts_Sub.get(objcampaign.Id)){
                                
                                System.debug('@objcampaign_itemS ' + objcampaign_itemS.Product_Type__c);
                                
                                if(objcampaign_itemS.Product_Type__c=='Substitutable' && objcampaign_itemS.select__c){
                                    
                                    System.debug('@objcampaign_itemS.Substitutable_Product_Group_Item__c ' + objcampaign_itemS.Substitutable_Product_Group_Item__c);
                                    
                                       if(objcampaign_itemS.Substitutable_Product_Group_Item__c != null){
                                           
                                           String mandatoryProductName;
                                           
                                           if(!idToManProductNameMap.isEmpty()){
                                               
                                               mandatoryProductName = idToManProductNameMap.get(objcampaign_itemS.Substitutable_Product_Group_Item__c);
                                               
                                           }
                                           
                                           System.debug('@mandatoryProductName ' + mandatoryProductName);
                                           
                                           //Creating Map that will contain Mandatory to Substitutable Product Selected Count
                                           if(!mandatPrdToSubSelectedCountMap.isEmpty()){
               
                                               //If Map contains Product_Name__c
                                               if(mandatPrdToSubSelectedCountMap.containsKey(mandatoryProductName)){
                                                   
                                                   Integer count = mandatPrdToSubSelectedCountMap.get(mandatoryProductName);
                                                   
                                                   
                                                   mandatPrdToSubSelectedCountMap.put(mandatoryProductName,count+1);
                                                   
                                                   
                                               }else{
                                                   //If Map don't have Product_Name__c
                                                   mandatPrdToSubSelectedCountMap.put(mandatoryProductName,1);
                                                   
                                                   
                                               }
                                               
                                           
                                           }else{
                                               //Handling first element
                                               mandatPrdToSubSelectedCountMap.put(mandatoryProductName,1);
                                               
                                               
                                           }
                                           
                                       }
                                       
                                       
                                    
                                } 
                                
                                if(objcampaign_itemS.Product_Type__c=='Substitutable'){ //Creating map for Mandatory to Substitutable count 
                                    
                                    if(objcampaign_itemS.Substitutable_Product_Group_Item__c != null){
                                           
                                           String mandatoryProductName;
                                           
                                           if(!idToManProductNameMap.isEmpty()){
                                               
                                               mandatoryProductName = idToManProductNameMap.get(objcampaign_itemS.Substitutable_Product_Group_Item__c);
                                               
                                               
                                           }
                                           
                                           if(mandatoryProductName != null){
                                           
                                               //Creating Map that will contain Mandatory to Substitutable Product Count
                                               if(!mandatPrdToSubCountMap.isEmpty()){
                   
                                                   //If Map contains Product_Name__c
                                                   if(mandatPrdToSubCountMap.containsKey(mandatoryProductName)){
                                                       
                                                       Integer count = mandatPrdToSubCountMap.get(mandatoryProductName);
                                                       
                                                       
                                                       mandatPrdToSubCountMap.put(mandatoryProductName,count+1);
                                                       
                                                       
                                                   }else{
                                                       //If Map don't have Product_Name__c
                                                       mandatPrdToSubCountMap.put(mandatoryProductName,1);
                                                       
                                                       
                                                   }
                                                   
                                               
                                               }else{
                                                   //Handling first element
                                                   mandatPrdToSubCountMap.put(mandatoryProductName,1);
                                                   
                                                   
                                               }
                                           
                                           }
                                    
                                    }
                                    
                                    
                                }   
                            
                            }    
                            
                            
                            
             
                    System.debug('@mandatPrdToSubSelectedCountMap ' + mandatPrdToSubSelectedCountMap);
                    
                    System.debug('@mandatPrdToSubCountMap ' + mandatPrdToSubCountMap);
                    
                    
                    //Added by Anshul for fetching custom setting Substitutable Products Validation 
                    Integer minSubstitutableCountFromCS;
                    Business_Rules__c businessRulesCS = Business_Rules__c.getValues('Default Substitutable Count');
                    if(businessRulesCS.IsActive__c && businessRulesCS.Process__c == 'Dynamic Bundle'){
                        
                        if(businessRulesCS.Value__c != null)
                            minSubstitutableCountFromCS = Integer.valueOf(businessRulesCS.Value__c);
                        
                    }
                    
                    
                    
                    for(Product_Group_Item__c objcampaign_item:map_CampaignsIdToBundleProducts_Sub.get(objcampaign.Id)){
                       
                        if(objcampaign_item.Product_Type__c=='Mandatory Substitutable'){
                            
                            if(!objcampaign_item.select__c){
                                
                                Integer minSubCount;
                                
                                if(objcampaign_item.Minimum_Substitutable_Count__c != null){
                                    
                                    minSubCount = Integer.valueOf(objcampaign_item.Minimum_Substitutable_Count__c);
                                    
                                }else{
                                    
                                    
                                    minSubCount = minSubstitutableCountFromCS;
                                }
                                
                                System.debug('@objcampaign_item.Product_Name__c - before' + objcampaign_item.Product_Name__c);
                                if(minSubCount != null && minSubCount != 0){
                                    
                                    Integer mandToSubCount;
                                    
                                    if(!mandatPrdToSubCountMap.isEmpty() ){
                                        mandToSubCount = mandatPrdToSubCountMap.get(objcampaign_item.Product_Name__c);
                                        
                                    }     
                                    
                                    System.debug('@objcampaign_item.Product_Name__c ' + objcampaign_item.Product_Name__c);
                                    System.debug('@mandToSubCount ' + mandToSubCount);
                                    System.debug('@minSubCount ' + minSubCount);
                                    
                                   
                                    //Checking Mandatory to Selected substitutable                                   
                                    if(!mandatPrdToSubSelectedCountMap.isEmpty()){
                                        
                                        if(mandatPrdToSubSelectedCountMap.get(objcampaign_item.Product_Name__c) != null){
                                        
                                            if(mandToSubCount < minSubCount){ //mandatory to substitutable count is less
    
                                                if(mandatPrdToSubSelectedCountMap.get(objcampaign_item.Product_Name__c) < mandToSubCount){
                                                    
                                                    productError = 'Please Select at least ' +  mandToSubCount + ' Substitutable Products under '+ objcampaign_item.Product_Name__c; 
                                                    errorFlag = true;
                                                    errormessage.put(objcampaign_item.id,productError);
                                                    errormap.put(objcampaign_item.id,true);
                                                    
                                            
                                                }
                                            }else{
                                            
                                                if(mandatPrdToSubSelectedCountMap.get(objcampaign_item.Product_Name__c) < minSubCount){
                                                    
                                                    productError = 'Please Select at least ' +  minSubCount + ' Substitutable Products under '+ objcampaign_item.Product_Name__c; 
                                                    errorFlag = true;
                                                    errormessage.put(objcampaign_item.id,productError);
                                                    errormap.put(objcampaign_item.id,true);
                                            
                                                }
                                            
                                            
                                            
                                            
                                            }
                                            
                                            
                                           
                                        
                                        }else{//If 0 Substitutable not selected
                                            
                                            System.debug('Inside else');
                                            
                                            if(mandToSubCount < minSubCount){
                                                
                                                productError = 'Please Select at least ' +  mandToSubCount + ' Substitutable Products under '+ objcampaign_item.Product_Name__c;      
                                                
                                                
                                            }else{
                                                
                                                productError = 'Please Select at least ' +  minSubCount + ' Substitutable Products under '+ objcampaign_item.Product_Name__c;      
                                                
                                            }
                                            
                                            errormessage.put(objcampaign_item.id,productError);
                                            errormap.put(objcampaign_item.id,true);
                                            errorFlag = true;
                                            
                                            
                                        }
                                        
                                    }else{ //Nothing is selected
                                        
                                        
                                         if(mandToSubCount < minSubCount){
                                                
                                                productError = 'Please Select at least ' +  mandToSubCount + ' Substitutable Products under '+ objcampaign_item.Product_Name__c;      
                                                
                                         }else{
                                                
                                                productError = 'Please Select at least ' +  minSubCount + ' Substitutable Products under '+ objcampaign_item.Product_Name__c;      
                                                
                                         }
                                         
                                         errormessage.put(objcampaign_item.id,productError);
                                         errormap.put(objcampaign_item.id,true);   
                                         errorFlag = true;
                                        
                                        
                                        
                                    }
                                
                                }
                                
                                
                            } 
                            
                            
                            
                        }
                            
                    }
                    
                    System.debug('@productError ' + productError);
                    
                    //productError = productError.subString(0,productError.length() - 2);
              
                    
                    
                     if(errorFlag){
                          //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, productError));
                          
                          ChkMapKey = string.valueof(errormap.keyset()).replace('{', '').replace('{', '');
                          
                     }
                    
                }  
             } 
            
           }   
       
       
       
           
       
       if(errorFlag){
          //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, productError));
          
       }
       //Added By Anshul on 07/19/2018 Substitutable Validation - END
       //Existing Logic
       else{
        
        
        
            Decimal decLinePrice;
            Decimal total;
            //map_campaigntomainproduct = new Map<id,BigMachines__Quote_Product__c>();
            //Loop through campaign types
            for(string campaigntypeselected : list_CampaignsTypes){
                system.debug('++++ campaigntypeselected' + campaigntypeselected);
                List<Product_Group__c>  objcampaign_list = map_CampaignsTypesToBundles.get(campaigntypeselected);
                system.debug('++++ objcampaign_list' + objcampaign_list);
                total=0;
                //Loop through campaigns within campaigntypes
                for(Product_Group__c objcampaign:objcampaign_list){
                    if(objcampaign.Quantity__c !=null){
                        //If users have not click on show products then return back
                        if(map_CampaignsIdToBundleProducts.get(objcampaign.Id)== null)
                            return null;
                    
                        //Traverse through the products with in that campaign
                        for(Product_Group_Item__c objcampaign_item:map_CampaignsIdToBundleProducts.get(objcampaign.Id)){
                          
                            Product2 objProd = (Product2)objcampaign_item.getSObject('Product__r'); 
                            
                            // For PS RDP products fetch price from Custom Settings based on region and product
                            if(objcampaign_item.Product__r.Building_Block__c == 'PS Rapid Deployment Packages' && 
                               String.isNotBlank(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c))
                            {
                                PSRDP_Pricing__c objPriceSettings = PSRDP_Pricing__c.getInstance(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c + '##' + objcampaign_item.Product__c);
                                if(objPriceSettings != null)
                                    decLinePrice = objPriceSettings.Price__c;
                            }
                            else
                                decLinePrice = (Decimal)objcampaign_item.getSObject('Product__r').get(strPricebookFieldName);
                            
                            
                            
                            // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                            if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objcampaign_item.product__r.Pricing_Model__c)
                               && objcampaign_item.product__r.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                                decLinePrice *= decPricingMultiplier;               
                            
                            if(objcampaign.Discount__c != null)
                                decLinePrice= decLinePrice*((100-objcampaign.Discount__c)/100);
                            
                            //total +=decLinePrice;
                            if(!ProductId_set.contains(objProd.id)){
                            BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                            objQP.Name = objcampaign_item.Product__r.APN_Number__c;
                            objQP.BigMachines__Quote__c = objQuote.Id;
                            objQP.Play__c = objQuote.Top_Play__c;
                                                       
                            objQP.BigMachines__Product__c = objcampaign_item.Product__c;
                            if(objProd.Description != null && objProd.Description.length() > 255)
                              objQP.Product__c = objProd.Description.Left(255);
                            else
                              objQP.Product__c = objProd.Description;
                            objQP.APN_Number__c = objcampaign_item.Product__r.APN_Number__c;
                            objQP.Product_Specific_Discount__c = objProd.Product_Specific_Discount__c;
                            objQP.Pm_Approver__c = objProd.Product_Manager_Approval_Group__r.Name;
                            objQP.Third_Party__c = objProd.Third_Party__c;
                            objQP.Third_Party_GC__c = objProd.Third_Party_GC__c;
                            objQP.Unit_of_Measure__c = objProd.Unit_of_Measure__c;
                            objQP.BigMachines__Sales_Price__c = 0;
                            objQP.or_Amount__c = '%';
                            objQP.List_Price__c = decLinePrice;
                            objQP.Disc__c = objcampaign.Additional_Discount__c;
                            //objQP.Disc__c = objBaseProduct.Discount__c;
                            objQP.Quantity__c = (objcampaign_item.Quantity__c*objcampaign.Quantity__c).round(System.RoundingMode.CEILING);
                            objQP.BigMachines__Quantity__c= (objcampaign_item.Quantity__c*objcampaign.Quantity__c).round(System.RoundingMode.CEILING);
                            total +=(decLinePrice*objQP.BigMachines__Quantity__c);
                            System.debug('+++++++quantity'+objQP.BigMachines__Quantity__c);
                            System.debug('+++++++total'+total);
                            objQP.Build_Type__c = campaigntypeselected;
                            objQP.Bundle_Discount__c = objcampaign.Discount__c;
                            objQP.Bundle__c = objcampaign.Id;
                            objQP.Campaign_Product_Type__c = 'Mandatory';
                            list_CampaignsToBeSaved.add(objQP);  
                            ProductId_set.add(objProd.id);
                            }
                            
                        }
                        
                        for(Product_Group_Item__c objcampaign_item:map_CampaignsIdToBundleProducts_lab.get(objcampaign.Id)){
                            
                            if(objcampaign_item.Quantity__c!=null){
                                Product2 objProd = (Product2)objcampaign_item.getSObject('Product__r'); 
                                
                                // For PS RDP products fetch price from Custom Settings based on region and product
                                if(objcampaign_item.Product__r.Building_Block__c == 'PS Rapid Deployment Packages' && 
                                   String.isNotBlank(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c))
                                {
                                    PSRDP_Pricing__c objPriceSettings = PSRDP_Pricing__c.getInstance(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c + '##' + objcampaign_item.Product__c);
                                    if(objPriceSettings != null)
                                        decLinePrice = objPriceSettings.Price__c;
                                }
                                else
                                    decLinePrice = (Decimal)objcampaign_item.getSObject('Product__r').get(strPricebookFieldName);
                                
                                // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                                if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objcampaign_item.product__r.Pricing_Model__c)
                                   && objcampaign_item.product__r.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                                    decLinePrice *= decPricingMultiplier;           
                                
                                if(objcampaign.Discount__c != null)
                                    decLinePrice= decLinePrice*((100-objcampaign.Discount__c)/100);
                                
                                //total +=decLinePrice;
                                if(!ProductId_set.contains(objProd.id)){
                                BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                                objQP.Name = objcampaign_item.Product__r.APN_Number__c;
                                objQP.BigMachines__Quote__c = objQuote.Id;                                                           
                                objQP.BigMachines__Product__c = objcampaign_item.Product__c;
                                if(objProd.Description != null && objProd.Description.length() > 255)
                                    objQP.Product__c = objProd.Description.Left(255);
                                else
                                    objQP.Product__c = objProd.Description;
                                objQP.APN_Number__c = objcampaign_item.Product__r.APN_Number__c;
                                objQP.Product_Specific_Discount__c = objProd.Product_Specific_Discount__c;
                                objQP.Pm_Approver__c = objProd.Product_Manager_Approval_Group__r.Name;
                                objQP.Third_Party__c = objProd.Third_Party__c;
                                objQP.Third_Party_GC__c = objProd.Third_Party_GC__c;
                                objQP.Unit_of_Measure__c = objProd.Unit_of_Measure__c;
                                objQP.BigMachines__Sales_Price__c = 0;
                                objQP.or_Amount__c = '%';
                                objQP.List_Price__c = decLinePrice;
                                //objQP.Disc__c = objBaseProduct.Discount__c;
                                objQP.Quantity__c = objcampaign_item.Quantity__c;
                                objQP.BigMachines__Quantity__c= objcampaign_item.Quantity__c;
                                
                                total +=(decLinePrice*objQP.BigMachines__Quantity__c);
                                System.debug('+++++++quantity'+objQP.BigMachines__Quantity__c);
                                System.debug('+++++++total'+total);
                                objQP.Build_Type__c = campaigntypeselected;
                                objQP.Bundle_Discount__c = objcampaign.Discount__c;
                                objQP.Bundle__c = objcampaign.Id;
                                objQP.Disc__c = objcampaign.Additional_Discount__c;
                                objQP.Campaign_Product_Type__c = 'Lab';
                                list_CampaignsToBeSaved.add(objQP);   
                                ProductId_set.add(objProd.id);
                                }
                            }
                        }
                        
                        for(Product_Group_Item__c objcampaign_item:map_CampaignsIdToBundleProducts_HA.get(objcampaign.Id)){
                            
                            if(objcampaign_item.Quantity__c!=null){
                                Product2 objProd = (Product2)objcampaign_item.getSObject('Product__r'); 
                                
                                // For PS RDP products fetch price from Custom Settings based on region and product
                                if(objcampaign_item.Product__r.Building_Block__c == 'PS Rapid Deployment Packages' && 
                                   String.isNotBlank(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c))
                                {
                                    PSRDP_Pricing__c objPriceSettings = PSRDP_Pricing__c.getInstance(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c + '##' + objcampaign_item.Product__c);
                                    if(objPriceSettings != null)
                                        decLinePrice = objPriceSettings.Price__c;
                                }
                                else
                                    decLinePrice = (Decimal)objcampaign_item.getSObject('Product__r').get(strPricebookFieldName);
                                
                                // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                                if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objcampaign_item.product__r.Pricing_Model__c)
                                   && objcampaign_item.product__r.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                                    decLinePrice *= decPricingMultiplier;           
                                
                                if(objcampaign.Discount__c != null)
                                    decLinePrice= decLinePrice*((100-objcampaign.Discount__c)/100);
                                
                                //total +=decLinePrice;
                                if(!ProductId_set.contains(objProd.id)){
                                BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                                objQP.Name = objcampaign_item.Product__r.APN_Number__c;
                                objQP.BigMachines__Quote__c = objQuote.Id;
                                objQP.BigMachines__Product__c = objcampaign_item.Product__c;
                                if(objProd.Description != null && objProd.Description.length() > 255)
                                    objQP.Product__c = objProd.Description.Left(255);
                                else
                                    objQP.Product__c = objProd.Description;
                                objQP.APN_Number__c = objcampaign_item.Product__r.APN_Number__c;
                                objQP.Product_Specific_Discount__c = objProd.Product_Specific_Discount__c;
                                objQP.Pm_Approver__c = objProd.Product_Manager_Approval_Group__r.Name;
                                objQP.Third_Party__c = objProd.Third_Party__c;
                                objQP.Third_Party_GC__c = objProd.Third_Party_GC__c;
                                objQP.Unit_of_Measure__c = objProd.Unit_of_Measure__c;
                                objQP.BigMachines__Sales_Price__c = 0;
                                objQP.or_Amount__c = '%';
                                objQP.List_Price__c = decLinePrice;
                                objQP.Quantity__c = objcampaign_item.Quantity__c;
                                objQP.BigMachines__Quantity__c= objcampaign_item.Quantity__c;   
                                
                              total +=(decLinePrice*objQP.BigMachines__Quantity__c);
                                System.debug('+++++++quantity'+objQP.BigMachines__Quantity__c);
                                System.debug('+++++++total'+total);
                                objQP.Build_Type__c = campaigntypeselected;
                                objQP.Bundle_Discount__c = objcampaign.Discount__c;
                                objQP.Bundle__c = objcampaign.Id;
                                objQP.Disc__c = objcampaign.Additional_Discount__c;
                                objQP.Campaign_Product_Type__c = 'HA';
                                list_CampaignsToBeSaved.add(objQP);  
                                ProductId_set.add(objProd.id);
                                }
                                
                            }
                        }
                        
                        for(Product_Group_Item__c objcampaign_item:map_CampaignsIdToBundleProducts_opt.get(objcampaign.Id)){
                            
                            if(objcampaign_item.Quantity__c!=null){
                                Product2 objProd = (Product2)objcampaign_item.getSObject('Product__r'); 
                                
                                // For PS RDP products fetch price from Custom Settings based on region and product
                                if(objcampaign_item.Product__r.Building_Block__c == 'PS Rapid Deployment Packages' && 
                                   String.isNotBlank(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c))
                                {
                                    PSRDP_Pricing__c objPriceSettings = PSRDP_Pricing__c.getInstance(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c + '##' + objcampaign_item.Product__c);
                                    if(objPriceSettings != null)
                                        decLinePrice = objPriceSettings.Price__c;
                                }
                                else
                                    decLinePrice = (Decimal)objcampaign_item.getSObject('Product__r').get(strPricebookFieldName);
                                
                                // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                                if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objcampaign_item.product__r.Pricing_Model__c)
                                   && objcampaign_item.product__r.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                                    decLinePrice *= decPricingMultiplier;           
                                
                                if(objcampaign.Discount__c != null)
                                    decLinePrice= decLinePrice*((100-objcampaign.Discount__c)/100);
                                
                                //total +=decLinePrice;
                                if(!ProductId_set.contains(objProd.id)){
                                BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                                objQP.Name = objcampaign_item.Product__r.APN_Number__c;
                                objQP.BigMachines__Quote__c = objQuote.Id;
                                objQP.BigMachines__Product__c = objcampaign_item.Product__c;
                                if(objProd.Description != null && objProd.Description.length() > 255)
                                    objQP.Product__c = objProd.Description.Left(255);
                                else
                                    objQP.Product__c = objProd.Description;
                                objQP.APN_Number__c = objcampaign_item.Product__r.APN_Number__c;
                                objQP.Product_Specific_Discount__c = objProd.Product_Specific_Discount__c;
                                objQP.Pm_Approver__c = objProd.Product_Manager_Approval_Group__r.Name;
                                objQP.Third_Party__c = objProd.Third_Party__c;
                                objQP.Third_Party_GC__c = objProd.Third_Party_GC__c;
                                objQP.Unit_of_Measure__c = objProd.Unit_of_Measure__c;
                                objQP.BigMachines__Sales_Price__c = 0;
                                objQP.or_Amount__c = '%';
                                objQP.List_Price__c = decLinePrice;
                                //objQP.Disc__c = objBaseProduct.Discount__c;
                                objQP.Quantity__c = objcampaign_item.Quantity__c;
                                objQP.BigMachines__Quantity__c= objcampaign_item.Quantity__c;   
                                
                                 total +=(decLinePrice*objQP.BigMachines__Quantity__c);
                                System.debug('+++++++quantity'+objQP.BigMachines__Quantity__c);
                                System.debug('+++++++total'+total);
                                objQP.Build_Type__c = campaigntypeselected;
                                objQP.Bundle_Discount__c = objcampaign.Discount__c;
                                objQP.Bundle__c = objcampaign.Id;
                                objQP.Disc__c = objcampaign.Additional_Discount__c;
                                objQP.Campaign_Product_Type__c = 'Optional';
                                list_CampaignsToBeSaved.add(objQP);
                                ProductId_set.add(objProd.id);
                                }
                                
                            }
                        }
                        
                        
                        
                        integer groupid=0;
                        integer groupid_s=0;
                        set<decimal> groupid_set = new set<decimal>();
                        set<decimal> groupid_mand_set = new set<decimal>();
                        for(Product_Group_Item__c objcampaign_item:map_CampaignsIdToBundleProducts_Sub.get(objcampaign.Id)){
                            groupid_set.add(objcampaign_item.GroupID__c);
                            if(objcampaign_item.select__c && objcampaign_item.Product_Type__c=='Mandatory Substitutable')
                                groupid_mand_set.add(objcampaign_item.GroupID__c);   
                        }
                        groupid_set.removeAll(groupid_mand_set);
                        for(Product_Group_Item__c objcampaign_item:map_CampaignsIdToBundleProducts_Sub.get(objcampaign.Id)){
                            if(objcampaign_item.Product_Type__c=='Substitutable' && 
                               groupid_set.contains(objcampaign_item.GroupID__c) &&
                               objcampaign_item.select__c){
                                   groupid_set.remove(objcampaign_item.GroupID__c);
                               }
                            
                        }
                        for(Product_Group_Item__c objcampaign_item:map_CampaignsIdToBundleProducts_Sub.get(objcampaign.Id)){
                            if(groupid_set.contains(objcampaign_item.GroupID__c) && objcampaign_item.Product_Type__c=='Mandatory Substitutable'){
                                
                                //Commented by Anshul Jain on 07/23/2018 for disallowing mandatory product selection
                                //objcampaign_item.select__c =true;
                            }
                            
                            if(objcampaign_item.select__c){
                                Product2 objProd = (Product2)objcampaign_item.getSObject('Product__r'); 
                                
                                // For PS RDP products fetch price from Custom Settings based on region and product
                                if(objcampaign_item.Product__r.Building_Block__c == 'PS Rapid Deployment Packages' && 
                                   String.isNotBlank(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c))
                                {
                                    PSRDP_Pricing__c objPriceSettings = PSRDP_Pricing__c.getInstance(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c + '##' + objcampaign_item.Product__c);
                                    if(objPriceSettings != null)
                                        decLinePrice = objPriceSettings.Price__c;
                                }
                                else
                                    decLinePrice = (Decimal)objcampaign_item.getSObject('Product__r').get(strPricebookFieldName);
                                
                                // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                                if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objcampaign_item.product__r.Pricing_Model__c)
                                   && objcampaign_item.product__r.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                                    decLinePrice *= decPricingMultiplier;           
                                
                                if(objcampaign.Discount__c != null)
                                    decLinePrice= decLinePrice*((100-objcampaign.Discount__c)/100);
                                
                                //total +=decLinePrice;
                                if(!ProductId_set.contains(objProd.id)){
                                BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                                objQP.Name = objcampaign_item.Product__r.APN_Number__c;
                                objQP.BigMachines__Quote__c = objQuote.Id;
                                objQP.Play__c = objQuote.Top_Play__c;
                                objQP.BigMachines__Product__c = objcampaign_item.Product__c;
                                if(objProd.Description != null && objProd.Description.length() > 255)
                                    objQP.Product__c = objProd.Description.Left(255);
                                else
                                    objQP.Product__c = objProd.Description;
                                objQP.APN_Number__c = objcampaign_item.Product__r.APN_Number__c;
                                objQP.Product_Specific_Discount__c = objProd.Product_Specific_Discount__c;
                                objQP.Pm_Approver__c = objProd.Product_Manager_Approval_Group__r.Name;
                                objQP.Third_Party__c = objProd.Third_Party__c;
                                objQP.Third_Party_GC__c = objProd.Third_Party_GC__c;
                                objQP.Unit_of_Measure__c = objProd.Unit_of_Measure__c;
                                objQP.BigMachines__Sales_Price__c = 0;
                                objQP.or_Amount__c = '%';
                                objQP.List_Price__c = decLinePrice;
                                // objQP.Disc__c = objBaseProduct.Discount__c;
                                // 
                                objQP.Quantity__c = (objcampaign_item.Quantity__c*objcampaign.Quantity__c).round(System.RoundingMode.CEILING);
                                objQP.BigMachines__Quantity__c= (objcampaign_item.Quantity__c*objcampaign.Quantity__c).round(System.RoundingMode.CEILING);
                                
                               total +=(decLinePrice*objQP.BigMachines__Quantity__c);
                               System.debug('+++++++total'+total);
                                
                                objQP.Build_Type__c = campaigntypeselected;
                                objQP.Disc__c = objcampaign.Additional_Discount__c;
                                objQP.Bundle_Discount__c = objcampaign.Discount__c;
                                objQP.Bundle__c = objcampaign.Id;
                                objQP.Campaign_Product_Type__c = 'Substitutable';
                                list_CampaignsToBeSaved.add(objQP);   
                                //list_CampaignProductsToBeCreated.add(objQP);
                                ProductId_set.add(objProd.id);
                                }
                            }
                        }
                        
                        
                        //map_campaigntomainproduct = new Map<id,BigMachines__Quote_Product__c>();
                        BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                        objQP.Name = objcampaign.Product__r.name;
                        objQP.Play__c = objQuote.Top_Play__c;
                        objQP.BigMachines__Product__c = objcampaign.Product__c;
                        objQP.Quantity__c =  objcampaign.Quantity__c;
                        objQP.BigMachines__Quote__c = objQuote.Id;
                        objQP.BigMachines__Sales_Price__c = 0;
                        objQP.BigMachines__Quantity__c= objcampaign.Quantity__c;
                        objQP.Build_Type__c = campaigntypeselected;
                        objQP.Bundle_Discount__c = objcampaign.Discount__c;
                        objQP.Bundle__c = objcampaign.Id;
                        objQP.Product__c = objcampaign.Product__r.name;
                        
                        //Added by Ankit for Avaya on 11/12 
                        //objQP.List_Price__c = total;
                        objQP.Ext_List__c = total;
                        objQP.Ext_Net_Price__c = total;
                        objQP.Disc__c = objcampaign.Additional_Discount__c;
                        objQP.or_Amount__c = '%';
                        //list_QuoteProductsToBeCreated.add(objQP);
                        map_campaigntomainproduct.put(objcampaign.id,objQP);
                        System.debug('++++map_campaigntomainproduct' + map_campaigntomainproduct);
                        objcampaign.Quantity__c =null;
                        objcampaign.Additional_Discount__c= null;
                        
                        
                    }
                }
                
            }
        
        
        }
        
        return null;
    }
    private List<Product_Group__c> getProductGroup(List<String> listOfGroupTypes, String strOfferingType, String strPricebookFieldName){
        strPricebookFieldName = strPricebookFieldName + '_Price__c';
        String strBundleQuery = 'SELECT Id, Name, Category__c, Play_Offer__c, Group_Type__c, Offering_Type__c, Active__c, Pricing_Model__c, Description__c,Type__c,Quantity__c,Discount__c,Additional_Discount__c,Price__c,Product__c,Selected__c';
        strBundleQuery += ' ,Product__r.' + strPricebookFieldName;
        strBundleQuery += ' ,(SELECT Product__r.Name, Product__r.Quantity__c, Product__r.Description, Quantity__c,Product__r.Building_Block__c,Product__r.APN_Number__c,Product__r.' + strPricebookFieldName;
        strBundleQuery += ' ,Product__r.Pricing_Model__c, Product_Group__c ';
        strBundleQuery += ' FROM Product_Group_Items__r) FROM Product_Group__c WHERE Group_Type__c IN: listOfGroupTypes AND Play_Offer__c = null AND Active__c = true AND Offering_Type__c INCLUDES (\'' + strOfferingType + '\')';
        strBundleQuery += ' ORDER BY Order__c, Name';
        System.debug('###BundleQuery'+strBundleQuery);
        List<Product_Group__c> listOfProductGroup = (List<Product_Group__c>)Database.query(strBundleQuery);
        return listOfProductGroup;
    }
    private List<Product_Group__c> getProductGroup(List<String> listOfGroupTypes, String strOfferingType, String strPricebookFieldName, String playOfferCondition){
        strPricebookFieldName = strPricebookFieldName + '_Price__c';
        String strBundleQuery = 'SELECT Id, Name, Category__c, Play_Offer__c, Group_Type__c, Offering_Type__c, Active__c, Pricing_Model__c, Description__c,Type__c,Quantity__c,Discount__c,Additional_Discount__c,Price__c,Product__c,Selected__c';
        strBundleQuery += ' ,Product__r.' + strPricebookFieldName;
        strBundleQuery += ' ,(SELECT Product__r.Name, Product__r.Quantity__c, Product__r.Description, Quantity__c,Product__r.Building_Block__c,Product__r.APN_Number__c,Product__r.' + strPricebookFieldName;
        strBundleQuery += ' ,Product__r.Pricing_Model__c, Product_Group__c ';
        strBundleQuery += ' FROM Product_Group_Items__r) FROM Product_Group__c WHERE Group_Type__c IN: listOfGroupTypes AND Active__c = true AND Offering_Type__c INCLUDES (\'' + strOfferingType + '\') AND ( ' + playOfferCondition + ' )';
        strBundleQuery += ' ORDER BY Order__c, Name';
        System.debug('###BundleQuery'+strBundleQuery);
        List<Product_Group__c> listOfProductGroup = (List<Product_Group__c>)Database.query(strBundleQuery);
        return listOfProductGroup;
    }
     public class PlayOfferWrapper {
        public boolean isSelected {get; set;}
        public Product_Group__c prdGrp {get; set;}
        
        public PlayOfferWrapper(Product_Group__c prdGrp){
            this.prdGrp = prdGrp;
            this.isSelected = false;
        }
    }
}