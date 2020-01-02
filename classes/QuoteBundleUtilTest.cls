@isTest(seeAlldata = false)
public class QuoteBundleUtilTest {
    
    private static List<Product_Group__c> listProductGroups;
    private static Product_Group__c objProductGroup;
    private static Product_Group_Item__c objProductGroupItem;
    private static BigMachines__Quote_Product__c objQuoteProductParent;
    private static BigMachines__Quote_Product__c objQuoteProductChild;
    private static Map<Id, List<BigMachines__Quote_Product__c>> mapBundleParentToChildQuoteProducts;
    
    private static void populateGlobalVariables(Boolean blnInsertQP) {
        listProductGroups = [SELECT
                             (SELECT Product__c, Product__r.NG5_NA_USD_Price__c FROM Product_Group_Items__r),
                             Product__c, Product__r.NG5_NA_USD_Price__c
                             FROM Product_Group__c];
        
        if (listProductGroups != null && listProductGroups.size() > 0) {
            objProductGroup = listProductGroups[0];
            if (objProductGroup.Product_Group_Items__r.size() <= 0) {
                System.assert(false, 'Returned Product Group has no children in the test data');
                return;
            }
            objProductGroupItem = objProductGroup.Product_Group_Items__r[0];
            
            Pricebook2 objPriceBook = new Pricebook2();
            objPriceBook.Name = 'Test Pricebook';
            objPriceBook.IsActive = true;
            //objPriceBook.StandardPrice = 100.0;
            insert objPriceBook;
            
            PricebookEntry objPriceBookEntry = new PricebookEntry();
            objPriceBookEntry.IsActive = true;
            objPriceBookEntry.Product2Id = objProductGroup.Product__c;
            objPriceBookEntry.UnitPrice = 100.0;
            objPriceBookEntry.UseStandardPrice = false;
            objPriceBookEntry.Pricebook2Id = objPriceBook.Id;
            //objPriceBookEntry.StandardPrice = 100.0;
            insert objPriceBookEntry;
            
            BigMachines__Quote__c objQuote = [select Id from BigMachines__Quote__c limit 1];
            objQuoteProductParent = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = objQuote.Id,
                List_Price__c = objProductGroup.Product__r.NG5_NA_USD_Price__c,
                Ext_List__c = objProductGroup.Product__r.NG5_NA_USD_Price__c,
                Net_Unit_Price__c = objProductGroup.Product__r.NG5_NA_USD_Price__c,
                Ext_Net_Price__c = objProductGroup.Product__r.NG5_NA_USD_Price__c,
                BigMachines__Sales_Price__c = objProductGroupItem.Product__r.NG5_NA_USD_Price__c,
                Product__c = objProductGroup.Product__c,
                Bundle__c = objProductGroup.Id,
                Quantity__c = 1.0,
                BigMachines__Quantity__c = 1.0
            );
            
            objQuoteProductChild = new BigMachines__Quote_Product__c(
                BigMachines__Quote__c = objQuote.Id,
                List_Price__c = objProductGroupItem.Product__r.NG5_NA_USD_Price__c,
                Ext_List__c = objProductGroupItem.Product__r.NG5_NA_USD_Price__c,
                Net_Unit_Price__c = objProductGroupItem.Product__r.NG5_NA_USD_Price__c,
                Ext_Net_Price__c = objProductGroupItem.Product__r.NG5_NA_USD_Price__c,
                BigMachines__Sales_Price__c = objProductGroupItem.Product__r.NG5_NA_USD_Price__c,
                Product__c = objProductGroup.Product_Group_Items__r[0].Id,
                Bundle__c = objProductGroup.Id,
                Quantity__c = 1.0,
                BigMachines__Quantity__c = 1.0
            );
            
            if (blnInsertQP) {
                Util.Bypass_Trigger_Chk = true;
                insert objQuoteProductParent;
                objQuoteProductChild.Bundle_Line__c = objQuoteProductParent.Id;
                insert objQuoteProductChild;
                Util.Bypass_Trigger_Chk = false;
            }
            
            mapBundleParentToChildQuoteProducts = new Map<Id, List<BigMachines__Quote_Product__c>>();
            
        } else {
            System.assert(false, 'No Product Groups in the test data');
        }
    }        
    @testSetup
    public static void setUpData() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Quote_Category__c = 'Cloud';    	    	
        insert testOpp;
        List<RecordType> rType = [SELECT id FROM RecordType WHERE SObjectType = 'BigMachines__Quote__c' AND DeveloperName = 'Cloud_Quote'];       
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, false)[0];
        testQuote.BigMachines__Status__c = 'In Progress';
        testQuote.RecordTypeId = rType[0].id;
        insert testQuote;
        /*
List<Product2> products = TestUtil.createProducts(2, false);
products[0].Type__c = 'Cloud';
products[1].Type__c = 'Cloud';
insert products;
PricebookEntry objPriceBookEntry = new PricebookEntry();
objPriceBookEntry.IsActive = true;
objPriceBookEntry.Product2Id = prod.Id;
objPriceBookEntry.UnitPrice = 10.1;
objPriceBookEntry.UseStandardPrice = false;
if(currISOCode != null)
objPriceBookEntry.CurrencyIsoCode = currISOCode;
pbes.add( objPriceBookEntry );   
insert pbes;
List<PricebookEntry> pbes = TestUtil.createPriceBookEntries(products, true);
Pricebook2 standardPB = [select id from Pricebook2 where isstandard=true LIMIT 1];
testOpp.Pricebook2Id = standardPB.id;
update testOpp;
*/        
        
        /*
List<BigMachines__Quote_Product__c> quoteProducts = TestUtil.createQuoteProducts(products, false);    	
quoteProducts[0].BigMachines__Quote__c = testQuote.id;
quoteProducts[1].BigMachines__Quote__c = testQuote.id;
insert quoteProducts;
*/
        
        Product2 objProdParent = new Product2( Name = 'Test1',ProductShippable__c='Yes', Include_in_CMMR_Total__c=true,APN_Number__c='APN-PARENT-NUMBER',New_Category__c ='Bundles', Has_Overage__c = true,
                                              List_Price__c = 0.0, NG5_NA_USD_Price__c = 0.0);
        insert objProdParent;
        Product2 objProdChild = new Product2( Name = 'Test1',ProductShippable__c='Yes', Include_in_CMMR_Total__c=true,APN_Number__c='APN-CHILD-NUMBER',New_Category__c ='Bundles',Has_Overage__c = true,
                                             List_Price__c = 100.0, NG5_NA_USD_Price__c = 100.0);
        insert objProdChild;
        
        
        Product_Group__c objProductGroup = new Product_Group__c(Product__c = objProdParent.Id, Group_Type__c = 'PureSuccess');
        insert objProductGroup;
        
        Product_Group_Item__c objProductGroupItem = new Product_Group_Item__c(Product_Group__c = objProductGroup.Id, Product__c = objProdChild.Id);
        insert objProductGroupItem;
        
    }
    
    static testMethod void testGetProductGroupPrice() {
        populateGlobalVariables(false);
        QuoteBundleUtil.getProductGroupPrice(objProductGroup, 'NG5_NA_USD_Price__c');
    }
    
    static testMethod void testAddBundleChildToParentMap() {
        populateGlobalVariables(false);
        QuoteBundleUtil.addBundleChildToParentMap(mapBundleParentToChildQuoteProducts, objQuoteProductChild);
        // Call a 2nd time to hit the containsKey logic
        QuoteBundleUtil.addBundleChildToParentMap(mapBundleParentToChildQuoteProducts, objQuoteProductChild);
    }
    
    static testMethod void testSumChildProductsToParentPricing() {
        populateGlobalVariables(false);
        QuoteBundleUtil.addBundleChildToParentMap(mapBundleParentToChildQuoteProducts, objQuoteProductChild);
        
        List<QuoteProductWrapper> listParentProductWrappers = new List<QuoteProductWrapper>();
        QuoteProductWrapper objQuoteProductWrapper = new QuoteProductWrapper(objQuoteProductParent);
        
        QuoteBundleUtil.sumChildProductsToParentPricing(mapBundleParentToChildQuoteProducts, listParentProductWrappers);
    }
    
    static testMethod void testupdateQuantityChildProductsToParentQuantity() {
        populateGlobalVariables(false);
        QuoteBundleUtil.addBundleChildToParentMap(mapBundleParentToChildQuoteProducts, objQuoteProductChild);
        
        //Add one to the previous quantity
        objQuoteProductParent.Quantity__c++;
        List<QuoteProductWrapper> listParentProductWrappers = new List<QuoteProductWrapper>();
        QuoteProductWrapper objQuoteProductWrapper = new QuoteProductWrapper(objQuoteProductParent);
        
        QuoteBundleUtil.updateQuantityChildProductsToParentQuantity(mapBundleParentToChildQuoteProducts, listParentProductWrappers);
    }
    
}