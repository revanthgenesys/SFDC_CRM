//
// Updated : Naresh Kumar	01/28/2016	Branch Office pricing model changes.
public class ConfigurationController1
{
    // List of New Categories
    public List<String> list_Categories {get; private set;}
    // Map of Category to List of Building Blocks
    public Map<String,List<String>> map_CategoryToBuildingBlocks {get; private set;}
    // Map of Building Blocks to List of Base Items/Products
    public Map<String,List<Product2>> map_BuildingBlockToProducts {get; set;}
    // Map of Versions available string and list of drop-down options for main Configurator
    public Map<String,List<SelectOption>> map_VersionsToSelectOptions {get; private set;}
    // Map of Quantities available string and list of drop-down options for main Configurator (Audio Codes)
    public Map<String,List<SelectOption>> map_QuantitiesToSelectOptions {get; private set;}
    // Quote Products on right hand panel which will be created on 'save'
    public List<BigMachines__Quote_Product__c> list_QuoteProductsToBeCreated {get; set;}
    // Category selected (All Products tab)
    public String strSelectedCategory {get; set;}
    // Building Block selected (All Products tab)
    public String strSelectedBuildingBlock {get; set;}
    // Bundles on right hand panel which will be created on 'save'
    public List<Product_Group__c> list_BundlesToBeSaved {get; set;}
    
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
    // Option/tab selected in Configurator
    public String strMainOption {get; private set;}
    // Index of Product/Bundle being removed from right hand panel
    public String strProdIndex {get; set;}
    // To indicate if a favourite is being created. Show save and cancel buttons
    public Boolean blnShowFavSaveOptions {get; private set;}
    // Favourite being created
    public Product_Group__c objFavToBeSaved {get; set;}
    
    // Product Search query string
    String strProductSearchQuery;
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
    
    // To indicate whether this quote use old or new pricing
    public Boolean blnIsNewPricing {get; private set;}
    // Products with notification messages to be shown on click of save button
    public List<ConfirmationWrapper> list_NotificationProducts {get; private set;}
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
    public ConfigurationController1()
    {
        strQuoteId = ApexPages.currentPage().getParameters().get('id');
        strLandingTab = ApexPages.currentPage().getParameters().get('tab');
        initializeData();
    }
    
    // *** To initialize data for the Configurator ***
    void initializeData()
    {
        objQuote = new BigMachines__Quote__c();
        list_QuoteProductsToBeCreated = new List<BigMachines__Quote_Product__c>();
        list_BundlesToBeSaved = new List<Product_Group__c>();
        list_CampaignsToBeSaved = new List<BigMachines__Quote_Product__c>();
        map_campaigntomainproduct = new Map<id,BigMachines__Quote_Product__c>();
        //  Bundle_Product_Approval = Item can only be sold as part of a bundle
        strBundleOnlyProduct = Label.Bundle_Product_Approval;
        strPricebookFieldName = '';
        objSearchProduct = new Product2(RecordTypeId=(Id)Label.Base_Item_RecordTypeId);
        // Setting default page size to 30 for search results
        intPageSize = 30;
        strSortField = 'Name';
        strSortOrder = 'ASC';
        blnShowFavSaveOptions = blnIsQuoteUnLocked = blnIsNewPricing = blnShowConfirmPanel = false;
        
        // Fetching Quote
        List<BigMachines__Quote__c> list_Temp = [SELECT Id,Name,New_Price_Book__c,Pricing_Model__c,BigMachines__Status__c,
                                                 Sold_To_Name__r.Country__r.PSRDP_Region__c,CurrencyISOCode,Quote_Opportunity_Type__c,Sold_To_Region__c
                                                 FROM BigMachines__Quote__c WHERE Id = :strQuoteId];
        
        if(list_Temp.size() > 0)
        {
            objQuote = list_Temp[0];
            
            if(objQuote.Quote_Opportunity_Type__c == 'New Pricing')
                blnIsNewPricing = true;
            
            blnIsQuoteUnLocked = isQuoteUnLocked(objQuote.BigMachines__Status__c);
            
            if(String.isNotBlank(objQuote.New_Price_Book__c))
            {
                strPricebookFieldName = objQuote.New_Price_Book__c + '_Price__c';
                // Fetching Pricing Multiplier from Custom Settings based on Pricing Model
                if(objQuote.Pricing_Model__c == 'Concurrent')
                    decPricingMultiplier = Global_Configuration_Settings__c.getOrgDefaults().Concurrent_Pricebook_Multiplier__c;
                else if(objQuote.Pricing_Model__c == 'Named User Pricing')
                    decPricingMultiplier = Global_Configuration_Settings__c.getOrgDefaults().Named_User_Pricing_Multiplier__c;
                else if(objQuote.Pricing_Model__c == 'Branch Office')
					decPricingMultiplier = Global_Configuration_Settings__c.getOrgDefaults().Branch_Office_Multiplier__c;
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
    }
    
    // *** To initialize all collections as necessary to keep view state light ***
    private void initializeCollections()
    {
        // All Products
        map_CategoryToBuildingBlocks = new Map<String,List<String>>();
        map_BuildingBlockToProducts = new Map<String,List<Product2>>();
        list_Categories = new List<String>();
        map_VersionsToSelectOptions = new Map<String,List<SelectOption>>();
        //map_VersionsToSelectOptions_old = new Map<String,List<SelectOption>>();
        map_QuantitiesToSelectOptions = new Map<String,List<SelectOption>>();
        
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
        
        // Favourites
        list_Favourites = new List<FavoriteWrapper>();
    }
    
    // *** To load Product Categories and Building blocks from Custom Settings ***
    private void loadCategoriesAndBlocks()
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
        loadCategoriesAndBlocks();
        strSelectedCategory = list_Categories[0];
        changeCategory();
    }
    
    // *** To handle change of category under 'All Products' ***
    public void changeCategory()
    {
        if(strSelectedCategory == 'All' || strSelectedCategory == 'Branch Office')
            strSelectedBuildingBlock = 'All';
        else
            strSelectedBuildingBlock = map_CategoryToBuildingBlocks.get(strSelectedCategory)[0];
        
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
    public void bundleOptionHandler()
    {
        strMainOption = 'Bundles';
        initializeCollections();
        
        // Fetching Bundles 
        for(Product_Group__c objProductBundle : Database.query(createBundleQueryString()))
        {   
            map_BundleIdToShowProductsChoice.put(objProductBundle.Id,false);
            
            objProductBundle.Price__c = 0;
            for(Product_Group_Item__c objPGI : objProductBundle.Product_Group_Items__r)
            {
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
            if(map_BundleTypeToBundles.containsKey(objProductBundle.Type__c))
                map_BundleTypeToBundles.get(objProductBundle.Type__c).add(objProductBundle);
            
            else
            {
                list_BundleTypes.add(objProductBundle.Type__c);
                map_BundleTypeToBundles.put(objProductBundle.Type__c,new List<Product_Group__c>{objProductBundle});
            }
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
    
    
    // *** To show products under 'All Products' based on current Category and Building Block selection ***
    public void showProducts()
    {
    	System.debug('NKC debug strSelectedCategory ['+strSelectedCategory+']');
        // Storing building blocks in the map in case there are no products for a building block (to prevent run time exceptions)
        if(strSelectedCategory == 'All' || strSelectedCategory == 'Branch Office')
        {
            for(List<String> list_BuildingBlocks : map_CategoryToBuildingBlocks.values())
            {
                for(String strBuildingBlock : list_BuildingBlocks)
                    map_BuildingBlockToProducts.put(strBuildingBlock,new List<Product2>());
            }
        }
        else if(strSelectedBuildingBlock == 'All')
        {
            List<String> list_BuildingBlocks = map_CategoryToBuildingBlocks.get(strSelectedCategory);
            for(String strBuildingBlock : list_BuildingBlocks)
                map_BuildingBlockToProducts.put(strBuildingBlock,new List<Product2>());
        }
        else
            map_BuildingBlockToProducts.put(strSelectedBuildingBlock,new List<Product2>());         
        
        //String strSubCategoryFieldName = blnIsNewPricing ? 'Building_Block__c' : 'Section__c';
        String strSubCategoryFieldName = 'Building_Block__c';      
        mapOfBaseVersionVsMaturity = new Map<String, String>();  
        Set<Id> setOfBaseItemIds = new Set<Id>();
        for(Product2 objBaseProduct : Database.query(createBaseProductQueryString()))
        {
            // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
            if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objBaseProduct.Pricing_Model__c)
               && objBaseProduct.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                objBaseProduct.put(strPricebookFieldName,((Decimal)objBaseProduct.get(strPricebookFieldName)) * decPricingMultiplier);
            
            // If Genesys Software Block under BEP is to be shown then add base items in which Show BEP checkbox is checked
            if(strSelectedCategory == 'Branch Office' || strSelectedCategory == 'All' || 
               (strSelectedCategory == 'Business Edition Premise' && 
                (strSelectedBuildingBlock == 'Genesys Software' || strSelectedBuildingBlock == 'All')))
            {
                if(strSelectedCategory == 'Branch Office' || objBaseProduct.Show_In_BEP__c && map_BuildingBlockToProducts.containsKey('Genesys Software'))
                {   
                    objBaseProduct.SI_Version_Number__c = objBaseProduct.Latest_Version__c;
                    // Making a deep clone so that same base item can be added to different blocks
                    if(strSelectedCategory == 'Branch Office')
                    	map_BuildingBlockToProducts.get('Branch Office').add(objBaseProduct.clone(true, true));
                    else
                    	map_BuildingBlockToProducts.get('Genesys Software').add(objBaseProduct.clone(true, true));
                    handleVersionsAvailable(objBaseProduct);
                    handleQuantitiesAvailable(objBaseProduct);
                    String key = objBaseProduct.id + objBaseProduct.Latest_Version__c; 
                    objBaseProduct.Maturity__c = objBaseProduct.Maturity__c == null ? '' : objBaseProduct.Maturity__c;
                	mapOfBaseVersionVsMaturity.put(key, objBaseProduct.Maturity__c);
                	setOfBaseItemIds.add(objBaseProduct.id);
                    // Adding child base items like Lab and HA etc (Ensures parent and children are grouped together)
                    if(objBaseProduct.Products__r.size() > 0)
                    {
                        for(Product2 objBaseChildProduct : objBaseProduct.Products__r)
                        {
                        	if(strSelectedCategory == 'Branch Office')
		                    	map_BuildingBlockToProducts.get('Branch Office').add(objBaseChildProduct.clone(true, true));
		                    else
		                    	map_BuildingBlockToProducts.get('Genesys Software').add(objBaseChildProduct.clone(true, true));                            
                            objBaseChildProduct.SI_Version_Number__c = objBaseChildProduct.Latest_Version__c;
                            handleVersionsAvailable(objBaseChildProduct);
                            handleQuantitiesAvailable(objBaseChildProduct);
                            key = objBaseChildProduct.id + objBaseChildProduct.SI_Version_Number__c; 
                            objBaseChildProduct.Maturity__c = objBaseChildProduct.Maturity__c == null ? '' : objBaseChildProduct.Maturity__c;
                            mapOfBaseVersionVsMaturity.put(key, objBaseChildProduct.Maturity__c);
                            setOfBaseItemIds.add(objBaseProduct.id);
                        }
                    }
                }
            }
            String strSubCategory = (String)objBaseProduct.get(strSubCategoryFieldName);
            // Grouping base items according to Building blocks
            if(map_BuildingBlockToProducts.containsKey(strSubCategory))
            {
                map_BuildingBlockToProducts.get(strSubCategory).add(objBaseProduct);
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
                        map_BuildingBlockToProducts.get(strSubCategory).add(objBaseChildProduct);
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
    	List<Product2> childProducts = [SELECT Base_Item_Lookup__c, SI_Version_Number__c, Maturity__c FROM Product2 
    		WHERE Base_Item_Lookup__c IN : setOfBaseItemIds ORDER BY SI_Version_Number__c DESC];
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
        List<Product2> list_Temp = [SELECT Support_Information__c FROM Product2 WHERE Id = :strProductIdForInfo];
        if(list_Temp.size() > 0)
            strProductInfo = list_Temp[0].Support_Information__c;
    }
    
    // *** To show Supporting Info in 'All Products' ***
    public void showProductInfoFromBaseItem()
    {
        blnShowSupportingInfo = true;
        strProductInfo = '';
        // Fetching Support Information from Sell-able item based on Base Item and version selected
        List<Product2> list_Temp = [SELECT Support_Information__c FROM Product2 
                                    WHERE Base_Item_Lookup__c = :strProductIdForInfo AND SI_Version_Number__c = :strVersionForInfo];
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
        }
    }
    
    public void showHideCampaignsProducts()
    {
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
                string query = 'SELECT Product__c,Product__r.Description,Quantity__c,Product_Type__c,GroupID__c,Select__c,'
                    +'Product__r.Pricing_Model__c,Product__r.APN_Number__c,Product__r.Building_Block__c,Product__r.Product_Specific_Discount__c,Product__r.Product_Manager_Approval_Group__r.Name,Product__r.Third_Party__c,Product__r.Third_Party_GC__c,'
                    +'Product__r.Unit_of_Measure__c,Product__r.' + strPricebookFieldName +' FROM Product_Group_Item__c WHERE Product_Group__c =\''+ strGroupId+'\'' ;
                
                System.debug(query+ '\' and product_type__c=\'Mandatory\' ORDER BY Product__r.Description');
                map_CampaignsIdToBundleProducts.put(strGroupId,Database.query(query+ ' and product_type__c=\'Mandatory\' and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1 ORDER BY Product__r.Description')); 
                map_CampaignsIdToBundleProducts_Opt.put(strGroupId,Database.query(query+ ' and product_type__c=\'Optional\' and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1  ORDER BY Product__r.Description')); 
                map_CampaignsIdToBundleProducts_LAB.put(strGroupId,Database.query(query+ ' and product_type__c=\'LAB\' and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1 ORDER BY Product__r.Description')); 
                map_CampaignsIdToBundleProducts_HA.put(strGroupId,Database.query(query+ ' and product_type__c=\'HA\' and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1 ORDER BY Product__r.Description')); 
                map_CampaignsIdToBundleProducts_Sub.put(strGroupId,Database.query(query+ ' and (product_type__c=\'Substitutable\' OR product_type__c=\'Mandatory Substitutable\') and Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1 ORDER BY GroupID__c,Product_Type__c')); 
                
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
            for(List<Product2> list_Products : map_BuildingBlockToProducts.values())
            {
                for(Product2 objProduct : list_Products)
                {
                    if(String.isNotBlank(objProduct.Product_Name__c) || 
                       (objProduct.Quantity__c != null && objProduct.Quantity__c != 0))
                    {
                        list_ProductsToAdd.add(objProduct);
                        set_Versions.add(objProduct.SI_Version_Number__c);
                    }
                }
            }
            
            Map<String,Product2> map_BaseItemIdAndVersionToProduct = new Map<String,Product2>();
            //show_emea_training_error =true;
            for(Product2 objSellableProduct : Database.query(createAddedProductsQueryString(list_ProductsToAdd,set_Versions)))
            {       
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
                    if(decPrice == null)
                        decPrice = (Decimal)objSellableProduct.get(strPricebookFieldName);
                    
                    // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                    if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objSellableProduct.Pricing_Model__c)
                       && objSellableProduct.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                        decPrice *= decPricingMultiplier;
                    
                    BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                    objQP.Name = objSellableProduct.Name;
                    objQP.BigMachines__Quote__c = objQuote.Id;
                    objQP.BigMachines__Product__c = objSellableProduct.Id;
                    objQP.Product__c = objSellableProduct.Description;
                    objQP.APN_Number__c = objSellableProduct.APN_Number__c;
                    objQP.Product_Specific_Discount__c = objSellableProduct.Product_Specific_Discount__c;
                    objQP.Pm_Approver__c = objSellableProduct.Product_Manager_Approval_Group__r.Name;
                    objQP.Third_Party__c = objSellableProduct.Third_Party__c;
                    objQP.Third_Party_GC__c = objSellableProduct.Third_Party_GC__c;
                    objQP.Original_Third_Party_GC__c = objSellableProduct.Third_Party_GC__c;
                    objQP.List_Price__c = decPrice;
                    
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
                    list_QuoteProductsToBeCreated.add(objQP);
                }
                objBaseProduct.Quantity__c = null;
                objBaseProduct.Discount__c = null;
                objBaseProduct.Product_Name__c = null;
                objBaseProduct.SI_Version_Number__c = objBaseProduct.Latest_Version__c;
            }
            if(set_APNnumbers.size() > 0)
                addRecommendationProducts(set_APNnumbers);
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    // *** To Add Bundles to the quote ***
    public void addBundlesBtnHandler()
    {
        productGroupIds = new Set<Id>();
        for(List<Product_Group__c> list_Bundles : map_BundleTypeToBundles.values())
        {
            for(Product_Group__c objProductBundle : list_Bundles)
            {
                if(objProductBundle.Quantity__c != null && objProductBundle.Quantity__c != 0)
                {
                    Product_Group__c objBundleTemp = objProductBundle.clone(true,true);
                    list_BundlesToBeSaved.add(objBundleTemp);
                    productGroupIds.add(objProductBundle.id);
                }
                objProductBundle.Quantity__c = null;
                objProductBundle.Additional_Discount__c = null;
            }
        }
        
    }
    
    // *** To Add Favourite items to the quote ***
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
                Set<Id> set_BundleIds = new Set<Id>();
                Map<Id,Product_Group__c> map_Bundles = new Map<Id,Product_Group__c>();
                for(Product_Group_Item__c objPGI : list_PGI)
                {
                    if(objPGI.Bundle__c != null)
                        set_BundleIds.add(objPGI.Bundle__c);
                }
                if(set_BundleIds.size() > 0)
                {
                    map_Bundles = new Map<Id,Product_Group__c>((List<Product_Group__c>)Database.query(createSelectedBundleQueryString(set_BundleIds)));
                    for(Product_Group__c objProductBundle : map_Bundles.values())
                    {
                        objProductBundle.Price__c = 0;
                        for(Product_Group_Item__c objPGI : objProductBundle.Product_Group_Items__r)
                        {
                            Decimal decLinePrice;
                            // For PS RDP products fetch price from Custom Settings based on region and product
                            if(objPGI.Product__r.Building_Block__c == 'PS Rapid Deployment Packages' && 
                               String.isNotBlank(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c))
                            {
                                PSRDP_Pricing__c objPriceSettings = PSRDP_Pricing__c.getInstance(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c + '##' + objPGI.Product__c);
                                if(objPriceSettings != null)
                                    decLinePrice = objPriceSettings.Price__c;
                            }
                            else
                                decLinePrice = (Decimal)objPGI.getSObject('Product__r').get(strPricebookFieldName);
                            
                            // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                            if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objPGI.Product__r.Pricing_Model__c)
                               && objPGI.Product__r.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                                decLinePrice *= decPricingMultiplier;
                            
                            objProductBundle.Price__c += decLinePrice;
                        }
                    }
                }
                for(Product_Group_Item__c objPGI : list_PGI)
                {
                    if(objPGI.Bundle__c != null)
                    {
                        if(!blnIsNewPricing)
                            continue;
                        
                        if(map_Bundles.containsKey(objPGI.Bundle__c))
                        {
                            Product_Group__c objBundleTemp = map_Bundles.get(objPGI.Bundle__c);
                            objBundleTemp.Quantity__c = objPGI.Quantity__c;
                            list_BundlesToBeSaved.add(objBundleTemp);
                        }
                    }
                    else if(objPGI.Product__c != null)
                    {
                        Product2 objProd = (Product2)objPGI.getSObject('Product__r');
                        Decimal decPrice;
                        // For PS RDP products fetch price from Custom Settings based on region and product
                        if(objPGI.Product__r.Building_Block__c == 'PS Rapid Deployment Packages' && 
                           String.isNotBlank(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c))
                        {
                            PSRDP_Pricing__c objPriceSettings = PSRDP_Pricing__c.getInstance(objQuote.Sold_To_Name__r.Country__r.PSRDP_Region__c + '##' + objPGI.Product__c);
                            if(objPriceSettings != null)
                                decPrice = objPriceSettings.Price__c;
                        }
                        else
                            decPrice = (Decimal)objPGI.getSObject('Product__r').get(strPricebookFieldName);
                        
                        if(decPrice != null && decPrice != -1)
                        {
                            // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                            if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objProd.Pricing_Model__c)
                               && objProd.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                                decPrice *= decPricingMultiplier;
                            
                            BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                            objQP.Name = objProd.Name;
                            objQP.BigMachines__Quote__c = objQuote.Id;
                            objQP.BigMachines__Product__c = objPGI.Product__c;
                            objQP.Product__c = objProd.Description;
                            objQP.APN_Number__c = objProd.APN_Number__c;
                            objQP.Product_Specific_Discount__c = objProd.Product_Specific_Discount__c;
                            objQP.Pm_Approver__c = objProd.Product_Manager_Approval_Group__r.Name;
                            objQP.Third_Party__c = objProd.Third_Party__c;
                            objQP.Third_Party_GC__c = objProd.Third_Party_GC__c;
                            objQP.Original_Third_Party_GC__c = objProd.Third_Party_GC__c;
                            // Using Quantity field instead of BigMachines quantity to remove decimals (keeping values synced)
                            objQP.Quantity__c = objPGI.Quantity__c;
                            objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                            objQP.Unit_of_Measure__c = objProd.Unit_of_Measure__c;
                            objQP.List_Price__c = decPrice;
                            
                            if(String.isNotBlank(objProd.Quantities_Available__c))
                            {
                                // Fetching AudioCodes prices from custom settings based on Base Item name and quantity selected
                                AudioCodes__c objAudioCodeSettings = AudioCodes__c.getInstance(objProd.Base_Item_Lookup__r.Name + String.valueOf(objQP.Quantity__c.intValue()));
                                System.debug('<<< ' + objAudioCodeSettings);
                                if(objAudioCodeSettings != null)
                                {
                                    objQP.List_Price__c *= objAudioCodeSettings.Volume_Break_Multiplier__c;
                                    objQP.Build_Type__c = objProd.Base_Item_Lookup__r.Name;
                                }
                            }
                            
                            // EMEA Volume Discount for old pricing
                            if(!blnIsNewPricing && strPricebookFieldName.containsIgnoreCase('EMEA') && objProd.EMEA_Volume_Discount_Eligible__c)
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
                            list_QuoteProductsToBeCreated.add(objQP);
                        }
                    }
                }
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
            Set<String> set_APNnumbers = new Set<String>();
            for(Product2 objSearchProd : list_SearchProducts)
            {
                if((String.isNotBlank(objSearchProd.Quantities_Available__c) && String.isNotBlank(objSearchProd.Product_Name__c))|| 
                   (objSearchProd.Quantity__c != null && objSearchProd.Quantity__c != 0))
                {
                    Decimal decPrice = (Decimal)objSearchProd.get(strPricebookFieldName);
                    if(decPrice != null && decPrice != -1)
                    {
                        // PSRDP Recommendations
                        if(PSRDP_Recommendations__c.getInstance(objSearchProd.APN_Number__c) != null)
                            set_APNnumbers.add(PSRDP_Recommendations__c.getInstance(objSearchProd.APN_Number__c).PSRDP_Training_Unit_Part__c);
                        
                        // if any recommended product is already added by user : remove it from APN numbers to be added             
                        if(set_APNnumbers.contains(objSearchProd.APN_Number__c))
                            set_APNnumbers.remove(objSearchProd.APN_Number__c);
                        
                        BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                        objQP.Name = objSearchProd.Name;
                        objQP.BigMachines__Quote__c = objQuote.Id;
                        objQP.BigMachines__Product__c = objSearchProd.Id;
                        objQP.Product__c = objSearchProd.Description;
                        objQP.APN_Number__c = objSearchProd.APN_Number__c;
                        objQP.Product_Specific_Discount__c = objSearchProd.Product_Specific_Discount__c;
                        objQP.Pm_Approver__c = objSearchProd.Product_Manager_Approval_Group__r.Name;
                        objQP.Third_Party__c = objSearchProd.Third_Party__c;
                        objQP.Third_Party_GC__c = objSearchProd.Third_Party_GC__c;
                        objQP.Original_Third_Party_GC__c = objSearchProd.Third_Party_GC__c;
                        objQP.Unit_of_Measure__c = objSearchProd.Unit_of_Measure__c;
                        objQP.List_Price__c = decPrice;
                        
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
                    }
                    objSearchProd.Quantity__c = null;
                    objSearchProd.Product_Name__c = null;
                    objSearchProd.Discount__c = null;
                }
            }
            if(set_APNnumbers.size() > 0)
                addRecommendationProducts(set_APNnumbers);  
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
    }
    
    // *** To Add Campaigns/Dynamic Bundles to the quote ***
    public PageReference addCampaignssBtnHandler() {
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
                        
                        BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                        objQP.Name = objcampaign_item.Product__r.APN_Number__c;
                        objQP.BigMachines__Quote__c = objQuote.Id;
                        objQP.BigMachines__Product__c = objcampaign_item.Product__c;
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
                        //objQP.Bundle_Discount__c = objcampaign.Discount__c;
                        objQP.Bundle__c = objcampaign.Id;
                        objQP.Campaign_Product_Type__c = 'Mandatory';
                        list_CampaignsToBeSaved.add(objQP);        
                        
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
                            
                            BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                            objQP.Name = objcampaign_item.Product__r.APN_Number__c;
                            objQP.BigMachines__Quote__c = objQuote.Id;
                            objQP.BigMachines__Product__c = objcampaign_item.Product__c;
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
                            //objQP.Bundle_Discount__c = objcampaign.Discount__c;
                            objQP.Bundle__c = objcampaign.Id;
                            objQP.Disc__c = objcampaign.Additional_Discount__c;
                            objQP.Campaign_Product_Type__c = 'Lab';
                            list_CampaignsToBeSaved.add(objQP);   
                            
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
                            
                            BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                            objQP.Name = objcampaign_item.Product__r.APN_Number__c;
                            objQP.BigMachines__Quote__c = objQuote.Id;
                            objQP.BigMachines__Product__c = objcampaign_item.Product__c;
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
                            //objQP.Bundle_Discount__c = objcampaign.Discount__c;
                            objQP.Bundle__c = objcampaign.Id;
                            objQP.Disc__c = objcampaign.Additional_Discount__c;
                            objQP.Campaign_Product_Type__c = 'HA';
                            list_CampaignsToBeSaved.add(objQP);   
                            
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
                            
                            BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                            objQP.Name = objcampaign_item.Product__r.APN_Number__c;
                            objQP.BigMachines__Quote__c = objQuote.Id;
                            objQP.BigMachines__Product__c = objcampaign_item.Product__c;
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
                            //objQP.Bundle_Discount__c = objcampaign.Discount__c;
                            objQP.Bundle__c = objcampaign.Id;
                            objQP.Disc__c = objcampaign.Additional_Discount__c;
                            objQP.Campaign_Product_Type__c = 'Optional';
                            list_CampaignsToBeSaved.add(objQP);   
                            
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
                            objcampaign_item.select__c =true;
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
                            
                            BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                            objQP.Name = objcampaign_item.Product__r.APN_Number__c;
                            objQP.BigMachines__Quote__c = objQuote.Id;
                            objQP.BigMachines__Product__c = objcampaign_item.Product__c;
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
                            //objQP.Bundle_Discount__c = objcampaign.Discount__c;
                            objQP.Bundle__c = objcampaign.Id;
                            objQP.Campaign_Product_Type__c = 'Substitutable';
                            list_CampaignsToBeSaved.add(objQP);   
                            //list_CampaignProductsToBeCreated.add(objQP);
                        }
                    }
                    
                    
                    //map_campaigntomainproduct = new Map<id,BigMachines__Quote_Product__c>();
                    BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                    objQP.Name = objcampaign.Product__r.name;
                    objQP.BigMachines__Product__c = objcampaign.Product__c;
                    objQP.Quantity__c =  objcampaign.Quantity__c;
                    objQP.BigMachines__Quote__c = objQuote.Id;
                    objQP.BigMachines__Sales_Price__c = 0;
                    objQP.BigMachines__Quantity__c= objcampaign.Quantity__c;
                    objQP.Build_Type__c = campaigntypeselected;
                    //objQP.Bundle_Discount__c = objcampaign.Discount__c;
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
        return null;
    }
    
    // *** To Add Recommendation Training Products for PS RDP Products ***
    private void addRecommendationProducts(Set<String> set_APNnumbers)
    {
        for(Product2 objPSRDPTrainingProduct : Database.query(createPSRDPRecommendationsQueryString(set_APNnumbers)))
        {
            Decimal decPrice = (Decimal)objPSRDPTrainingProduct.get(strPricebookFieldName);
            // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
            if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objPSRDPTrainingProduct.Pricing_Model__c)
               && objPSRDPTrainingProduct.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                decPrice *= decPricingMultiplier;
            
            BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
            objQP.Name = objPSRDPTrainingProduct.Name;
            objQP.BigMachines__Quote__c = objQuote.Id;
            objQP.BigMachines__Product__c = objPSRDPTrainingProduct.Id;
            objQP.Product__c = objPSRDPTrainingProduct.Description;
            objQP.APN_Number__c = objPSRDPTrainingProduct.APN_Number__c;
            objQP.Product_Specific_Discount__c = objPSRDPTrainingProduct.Product_Specific_Discount__c;
            objQP.Pm_Approver__c = objPSRDPTrainingProduct.Product_Manager_Approval_Group__r.Name;
            objQP.Third_Party__c = objPSRDPTrainingProduct.Third_Party__c;
            objQP.Third_Party_GC__c = objPSRDPTrainingProduct.Third_Party_GC__c;
            objQP.Original_Third_Party_GC__c = objPSRDPTrainingProduct.Third_Party_GC__c;
            objQP.List_Price__c = decPrice;
            objQP.Quantity__c = 1;
            objQP.BigMachines__Quantity__c = 1;
            objQP.Unit_of_Measure__c = objPSRDPTrainingProduct.Unit_of_Measure__c;
            objQP.BigMachines__Sales_Price__c = 0;
            objQP.or_Amount__c = '%';
            list_QuoteProductsToBeCreated.add(objQP);
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
        if(intRow >= 0 && intRow < list_BundlesToBeSaved.size())
        {
            list_BundlesToBeSaved.remove(intRow);
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
        
        List<Product_Group_Item__c> groupItems = [SELECT Product__c FROM Product_Group_Item__c WHERE Product_Group__c IN : productGroupIds];
        for(Product_Group_Item__c eachGI : groupItems){
            set_ProductIds.add(eachGI.Product__c);            
        }
        
        list_NotificationProducts = new List<ConfirmationWrapper>();
        /*  EOL_Value = Product has prerequisites or limited compatibility or is headed towards EOL
			Restrictions_Value = New product with limited functionality or other restrictions
			Expansion_Only_Value = Product available for expansion only */
        for(Product2 objProduct : [SELECT Id, Name, Description, Notification_Message__c, EOL_Announced_Date__c FROM Product2 
                                   WHERE Id IN :set_ProductIds AND (Shipment_Approval__c = :Label.EOL_Value OR Shipment_Approval__c = :Label.Restrictions_Value OR
                                                                    Shipment_Approval__c = :Label.Expansion_Only_Value OR (EOL_Announced_Date__c != NULL AND EOL_Announced_Date__c < TODAY)) ORDER BY Name]){
                                                                        
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
        if(list_QuoteProductsToBeCreated.size() > 0 || productGroupIds != null || list_CampaignsToBeSaved.size()>0)
        {
            checkForRequiredConfirmations();
            if(blnShowConfirmPanel)
                return;
        }
        saveLogic();
    }
    
    public void saveLogic()
    {
        Savepoint objSP;
        try
        {
            List<BigMachines__Quote_Product__c> list_ToInsert = new List<BigMachines__Quote_Product__c>();
            list_ToInsert.addAll(list_QuoteProductsToBeCreated);
            List<BigMachines__Quote_Product__c> list_BundlesToInsert = new List<BigMachines__Quote_Product__c>();
            List<List<BigMachines__Quote_Product__c>> list_RelatedSellableItemLines = new List<List<BigMachines__Quote_Product__c>>();                      
            List<BigMachines__Quote_Product__c> list_Campaign_update = new List<BigMachines__Quote_Product__c>();
            
            if(String.isNotBlank(strPricebookFieldName))
            {
                String strBundleQuery = 'SELECT Id,(SELECT Product__c,Product__r.Description,Product__r.Product_Specific_Discount__c,Product__r.APN_Number__c,Product__r.Building_Block__c';
                strBundleQuery += ',Product__r.' + strPricebookFieldName;
                if(objQuote.Pricing_Model__c != 'Enabled')
                    strBundleQuery += ',Product__r.Pricing_Model__c';
                strBundleQuery += ',Product__r.Product_Manager_Approval_Group__r.Name,Product__r.Name,Product__r.Third_Party__c,Product__r.Third_Party_GC__c,Product__r.Unit_of_Measure__c,Quantity__c FROM Product_Group_Items__r)';
                strBundleQuery += ' FROM Product_Group__c WHERE Id IN :list_BundlesToBeSaved';
                
                System.debug('>>>>strBundleQuery'+ strBundleQuery);
                Map<Id,Product_Group__c> map_Bundles = new Map<Id,Product_Group__c>((List<Product_Group__c>)Database.query(strBundleQuery));
                System.debug('>>>>>>>map_Bundles'+ map_Bundles.size());
                for(Product_Group__c objSavedBundle : list_BundlesToBeSaved)
                {
                    Product_Group__c objQueriedBundle = map_Bundles.get(objSavedBundle.Id);
                    BigMachines__Quote_Product__c objBundleQP = new BigMachines__Quote_Product__c();
                    objBundleQP.Name = objSavedBundle.Name;
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
                    list_BundlesToInsert.add(objBundleQP);
                    List<BigMachines__Quote_Product__c> list_SellableItemLines = new List<BigMachines__Quote_Product__c>();
                    for(Product_Group_Item__c objGroupItem : objQueriedBundle.getSObjects('Product_Group_Items__r'))
                    {
                        Product2 objProduct = (Product2)objGroupItem.getSObject('Product__r');
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
                        if(decPrice != null && decPrice != -1)
                        {
                            BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c();
                            objQP.Name = objProduct.Name;
                            objQP.BigMachines__Quote__c = objQuote.Id;
                            objQP.BigMachines__Product__c = objGroupItem.Product__c;
                            objQP.Product__c = objProduct.Description;
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
                            objQP.Quantity__c = objSavedBundle.Quantity__c * objQP.Committed_Quantity__c;
                            objQP.BigMachines__Quantity__c = objQP.Quantity__c;
                            objQP.List_Price__c = decPrice;
                            
                            // Pricing Model is not enabled and product has the current pricing model of the quote, price is multiplied by pricing multiplier
                            if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objProduct.Pricing_Model__c)
                               && objProduct.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                                objQP.List_Price__c *= decPricingMultiplier;
                            
                            objQP.BigMachines__Sales_Price__c = 0;
                            objQP.or_Amount__c = '%';
                            objQP.Disc__c = objSavedBundle.Additional_Discount__c;
                            objQP.Bundle_Discount__c = objSavedBundle.Discount__c;
                            objQP.Bundle__c = objSavedBundle.Id;
                            list_ToInsert.add(objQP);
                            list_SellableItemLines.add(objQP);
                        }
                    }
                    list_RelatedSellableItemLines.add(list_SellableItemLines);
                }
            }
            
            // Savepoint before DML
            objSP = Database.setSavepoint();
            // Skip Triggers
            Util.Bypass_Trigger_Chk = true;
            
            if(list_BundlesToInsert.size() > 0)
            {
                insert list_BundlesToInsert;
                //8365 EMEA Entity
                if(Check_GU_EMEA_Quote() == true){
                    // Roll back changes in case of DML failure
                    Database.rollback(objSP);
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please note it is not permitted to sell Training and license products together in EMEA. You would be required to create seperate quote for each one'));
                    return;
                }
                for(Integer i=0; i< list_BundlesToInsert.size() ; i++)
                {
                    for(BigMachines__Quote_Product__c objQP : list_RelatedSellableItemLines[i])
                        objQP.Bundle_Line__c = list_BundlesToInsert[i].Id;
                }
            }
            
            
            if(list_ToInsert.size() > 0){
                insert list_ToInsert;
            }        
            
           
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
            //8365 EMEA Entity
            if(Check_GU_EMEA_Quote() == true){
                // Roll back changes in case of DML failure
                Database.rollback(objSP);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please note it is not permitted to sell Training and license products together in EMEA. You would be required to create seperate quote for each one'));
                return;
            }
            
            
            
            strIsSaveSuccessful = 'Yes';
            
        }
        catch(Exception ex)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
            // Roll back changes in case of DML failure
            Database.rollback(objSP);
        }
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
            if(objQuote.Pricing_Model__c != 'Enabled' && String.isNotBlank(objSearchResult.Pricing_Model__c)
               && objSearchResult.Pricing_Model__c.containsIgnoreCase(objQuote.Pricing_Model__c))
                objSearchResult.put(strPricebookFieldName,((Decimal)objSearchResult.get(strPricebookFieldName)) * decPricingMultiplier);
            
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
    private String createPSRDPRecommendationsQueryString(Set<String> set_APNnumbers)
    {
        String strPSRDPTrainingProductQuery = 'SELECT Id,Name,Description,Third_Party_GC__c,Original_Third_Party_GC__c,APN_Number__c,';
        strPSRDPTrainingProductQuery += 'Product_Specific_Discount__c,Third_Party__c,Unit_of_Measure__c,Pricing_Model__c,Product_Manager_Approval_Group__r.Name';           
        
        if(String.isNotBlank(strPricebookFieldName))
            strPSRDPTrainingProductQuery += ',' + strPricebookFieldName;
        
        strPSRDPTrainingProductQuery += ' FROM Product2 WHERE APN_Number__c IN :set_APNnumbers';
        
        if(String.isNotBlank(strPricebookFieldName))
            strPSRDPTrainingProductQuery += ' AND ' + strPricebookFieldName + ' != null AND ' + strPricebookFieldName + ' != -1';
        
        System.debug(strPSRDPTrainingProductQuery);
        return strPSRDPTrainingProductQuery;
    }
    
    // *** Create query string for Base Products based on Category and Building Block ***
    private String createBaseProductQueryString()
    {
        /*String strCategoryFieldName = blnIsNewPricing ? 'New_Category__c' : 'Tab__c';
String strSubCategoryFieldName = blnIsNewPricing ? 'Building_Block__c' : 'Section__c';*/
        String strCategoryFieldName = 'New_Category__c';
        String strSubCategoryFieldName = 'Building_Block__c';
        
        String strBaseProdQuery = 'SELECT Id,Name,Quantity__c,Discount__c,Unit_of_Measure__c,Show_New__c,SI_Version_Number__c,Maturity__c,ProductId_And_Version_Key__c, ';
        strBaseProdQuery += 'Versions_Available__c,Latest_Version__c,Quantities_Available__c,Product_Name__c,Version_Available_For_old__c,';
        strBaseProdQuery += strSubCategoryFieldName;
        
        if(String.isNotBlank(strPricebookFieldName))
            strBaseProdQuery += ',' + strPricebookFieldName;
        
        if(objQuote.Pricing_Model__c != 'Enabled')
            strBaseProdQuery += ',Pricing_Model__c';
        
        if(strSelectedCategory == 'All' || 
           (strSelectedCategory == 'Business Edition Premise' && 
            (strSelectedBuildingBlock == 'Genesys Software' || strSelectedBuildingBlock == 'All')))
            strBaseProdQuery += ',Show_In_BEP__c';
        
        strBaseProdQuery += ',(SELECT Id,Name,Unit_of_Measure__c,Quantity__c,Discount__c,Show_New__c,SI_Version_Number__c, Maturity__c,ProductId_And_Version_Key__c,';
        strBaseProdQuery += ' Versions_Available__c,Latest_Version__c,Quantities_Available__c,Product_Name__c,Version_Available_For_old__c';
        if(String.isNotBlank(strPricebookFieldName))
            strBaseProdQuery += ',' + strPricebookFieldName;
        if(objQuote.Pricing_Model__c != 'Enabled')
            strBaseProdQuery += ',Pricing_Model__c';
        strBaseProdQuery += ' FROM Products__r WHERE Show_Base_Item__c = true AND Shipment_Approval__c != :strBundleOnlyProduct';
        if(strSelectedCategory == 'Branch Office')
        {
        	strBaseProdQuery += ' AND Pricing_Model__c INCLUDES (\'Branch Office\')'; 
        }
        if(String.isNotBlank(strPricebookFieldName))
            strBaseProdQuery += ' AND ' + strPricebookFieldName + ' != null AND ' + strPricebookFieldName + ' != -1';
        strBaseProdQuery += ' ORDER BY Name)';
        
        strBaseProdQuery += ' FROM Product2 WHERE Show_Base_Item__c = true';
        strBaseProdQuery += ' AND Parent_Product_lookup__c = null AND Shipment_Approval__c != :strBundleOnlyProduct';
        
        if(strSelectedCategory != 'All' && strSelectedCategory != 'Branch Office')
        {
            strBaseProdQuery += ' AND ( ' + strCategoryFieldName + ' = :strSelectedCategory';
            
            if(strSelectedCategory == 'Business Edition Premise' && 
               (strSelectedBuildingBlock == 'Genesys Software' || strSelectedBuildingBlock == 'All'))
                strBaseProdQuery += ' OR Show_In_BEP__c = true)';
            else
                strBaseProdQuery += ')';
            
            if(strSelectedBuildingBlock != 'All' && strSelectedBuildingBlock != 'Genesys Software')
                strBaseProdQuery += ' AND ' + strSubCategoryFieldName + ' = :strSelectedBuildingBlock';
        }
        else if(strSelectedCategory == 'Branch Office')
        {
        	strBaseProdQuery += ' AND Pricing_Model__c INCLUDES (\'Branch Office\')'; 
        }        
        else 
        	strBaseProdQuery += ' AND ' + strCategoryFieldName + ' IN :list_Categories';
        
        if(String.isNotBlank(strPricebookFieldName))
            strBaseProdQuery += ' AND ' + strPricebookFieldName + ' != null AND ' + strPricebookFieldName + ' != -1';           
        
        strBaseProdQuery += ' ORDER BY Anchor_Product__c DESC,Name';
        System.debug('NKC debug strBaseProdQuery ['+strBaseProdQuery+']');
        return strBaseProdQuery;
    }
    
    // *** Create query string for products to be added from Base Items ***
    private String createAddedProductsQueryString(List<Product2> list_ProductsToAdd,Set<String> set_Versions)
    {
        //modified by ankit
        String strSellableProdQuery = 'SELECT Id,Base_Item_Lookup__c,SI_Version_Number__c,Name,Description,Third_Party_GC__c,APN_Number__c,building_block__c,';
        strSellableProdQuery += 'Product_Specific_Discount__c,Third_Party__c,Unit_of_Measure__c,Pricing_Model__c,Product_Manager_Approval_Group__r.Name';
        
        if(String.isNotBlank(strPricebookFieldName))
        {
            strSellableProdQuery += ',' + strPricebookFieldName;
            if(!blnIsNewPricing && strPricebookFieldName.containsIgnoreCase('EMEA'))
                strSellableProdQuery += ',EMEA_Volume_Discount_Eligible__c';
        }
        
        strSellableProdQuery += ' FROM Product2 WHERE Base_Item_Lookup__c IN :list_ProductsToAdd AND SI_Version_Number__c IN :set_Versions';
        
        if(String.isNotBlank(strPricebookFieldName))
            strSellableProdQuery += ' AND ' + strPricebookFieldName + ' != null AND ' + strPricebookFieldName + ' != -1';
        
        System.debug(strSellableProdQuery);
        return strSellableProdQuery;
    }
    
    // *** Create query string for products to be added based on favourites selected ***
    private String createAddedFavoritesQueryString(Set<Id> set_FavIds)
    {
        String strGroupItemQuery = 'SELECT Quantity__c,Bundle__c,Product__c,Product__r.Quantities_Available__c,Product__r.Base_Item_Lookup__r.Name,Product__r.APN_Number__c';
        strGroupItemQuery += ',Product__r.' + strPricebookFieldName;
        strGroupItemQuery += ',Product__r.Third_Party__c,Product__r.Unit_of_Measure__c,Product__r.Third_Party_GC__c,Product__r.Product_Manager_Approval_Group__r.Name';
        
        if(objQuote.Pricing_Model__c != 'Enabled')
            strGroupItemQuery += ',Product__r.Pricing_Model__c';
        
        if(!blnIsNewPricing && strPricebookFieldName.containsIgnoreCase('EMEA'))
            strGroupItemQuery += ',Product__r.EMEA_Volume_Discount_Eligible__c';
        
        strGroupItemQuery += ',Product__r.Product_Specific_Discount__c,Product__r.Name,Product__r.Description,Product__r.Building_Block__c';
        strGroupItemQuery += ' FROM Product_Group_Item__c WHERE Product_Group__c IN :set_FavIds AND Quantity__c != null AND Quantity__c > 0';
        strGroupItemQuery += ' AND Product__r.Shipment_Approval__c != :strBundleOnlyProduct';
        
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
    }
    
    // *** Create query string to fetch bundles when 'Bundles' option is slected from the tab panel ***
    private String createBundleQueryString()
    {
        String strBundleQuery = 'SELECT Id,Name,Description__c,Type__c,Quantity__c,Discount__c,Additional_Discount__c,Price__c,Product__c';
        
        if(String.isNotBlank(strPricebookFieldName))
        {
            strBundleQuery += ',(SELECT Quantity__c,Product__r.Building_Block__c,Product__r.APN_Number__c,Product__r.' + strPricebookFieldName;
            if(objQuote.Pricing_Model__c != 'Enabled')
                strBundleQuery += ',Product__r.Pricing_Model__c';
            strBundleQuery += ' FROM Product_Group_Items__r WHERE Product__r.' + strPricebookFieldName + ' != null AND Product__r.' + strPricebookFieldName + ' != -1)';
        }
        strBundleQuery += ' FROM Product_Group__c WHERE Group_Type__c = \'Bundle\' AND Type__c != null AND Type__c != \'Partner\' AND Active__c = true';
        strBundleQuery += ' ORDER BY Type__c,Name';
        System.debug(strBundleQuery);
        return strBundleQuery;
    }
    
    
    // *** Create query string to fetch Campaings when 'Campaings ' option is slected from the tab panel ***
    private String createCampaingsQueryString()
    {
        String strCampaingsQuery = 'SELECT Id,Name,Description__c,Type__c,Quantity__c,Discount__c,Additional_Discount__c,Price__c,Product__c';
        strCampaingsQuery += ',Product__r.Id,Product__r.Name,Product__r.Description,Product__r.SI_Version_Number__c,Product__r.Unit_of_Measure__c';
        strCampaingsQuery += ',Product__r.Quantity__c,Product__r.Discount__c,Product__r.Product_Name__c,Product__r.Third_Party_GC__c';
        strCampaingsQuery += ',Product__r.Product_Specific_Discount__c,Product__r.Third_Party__c,Product__r.Building_Block__c,Product__r.Show_New__c';
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
            strSearchQuery += 'Product_Specific_Discount__c,Third_Party__c,Show_New__c,Quantities_Available__c,Base_Item_Lookup__r.Name,';
            strSearchQuery += 'Product_Manager_Approval_Group__r.Name,APN_Number__c,Third_Party_GC__c,Building_Block__c';
            
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
        strSearchQuery += ' AND (Last_Order_Date__c = null OR Last_Order_Date__c >= TODAY) AND OfferingType__c = \'PureEngage On Premise\'';
        strSearchQuery += ' AND (EOM_Date__c = null OR EOM_Date__c >= TODAY)';
        strSearchQuery += ' AND (End_Of_Support_Date__c = null OR End_Of_Support_Date__c >= TODAY)';
        
        if(String.isNotBlank(objSearchProduct.Name))
            strSearchQuery += ' AND Name LIKE \'' + objSearchProduct.Name + '%\'';
        
        if(String.isNotBlank(objSearchProduct.Description__c))
            strSearchQuery += ' AND Description_Formula__c LIKE \'%' + objSearchProduct.Description__c + '%\'';         
        
        /*if(blnIsNewPricing)
{   */
        if(String.isNotBlank(objSearchProduct.New_Category__c))
            strSearchQuery += ' AND New_Category__c = \'' + objSearchProduct.New_Category__c + '\'';
        
        if(String.isNotBlank(objSearchProduct.Building_Block__c))
            strSearchQuery += ' AND Building_Block__c = \'' + objSearchProduct.Building_Block__c + '\'';
        /*}
else
{       
if(String.isNotBlank(objSearchProduct.Tab__c))
strSearchQuery += ' AND Tab__c = \'' + objSearchProduct.Tab__c + '\'';

if(String.isNotBlank(objSearchProduct.Section__c))
strSearchQuery += ' AND Section__c = \'' + objSearchProduct.Section__c + '\'';
}*/
        
        if(String.isNotBlank(objSearchProduct.SI_Version_Number__c))
            strSearchQuery += ' AND SI_Version_Number__c = \'' + objSearchProduct.SI_Version_Number__c + '\'';
        
        if(String.isNotBlank(strPricebookFieldName))
            strSearchQuery += ' AND ' + strPricebookFieldName + ' != null AND ' + strPricebookFieldName + ' != -1';
        
        if(!blnIsCountQuery)
        {
            strSearchQuery += ' ORDER BY ' + strSortField + ' ' + strSortOrder + ' NULLS LAST';
            strSearchQuery += ' LIMIT ' + String.valueOf(intPageSize);
        }
        else
            strSearchQuery += ' LIMIT 1500';
        
        System.debug(strSearchQuery);
        return strSearchQuery;
    }
    
    // **************************** End : Dynamic Query Strings ********************
}