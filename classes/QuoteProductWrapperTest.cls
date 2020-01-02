@isTest(seeAlldata = false)
public class QuoteProductWrapperTest {
    
    static testMethod void testAll() {
        QuoteProductWrapper objQuoteProductWrapper = new QuoteProductWrapper();
        objQuoteProductWrapper.record = null;
        objQuoteProductWrapper.decListPrice = 0.0;
        objQuoteProductWrapper.decExtListPrice = 0.0;
        objQuoteProductWrapper.decNetUnitPrice = 0.0;
        objQuoteProductWrapper.decExtNetPricePrice = 0.0;
    }
    
    static testMethod void testConstructor() {
        BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c(
            List_Price__c = 0.0,
            Ext_List__c = 0.0,
            Net_Unit_Price__c = 0.0,
            Ext_Net_Price__c = 0.0
        );
        QuoteProductWrapper objQuoteProductWrapper = new QuoteProductWrapper(objQP);
    }
    
}