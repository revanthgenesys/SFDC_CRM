public class QuoteBundleUtil {
    
    // ECD Oct 2019 Harmonization
    // Get a single decimal price for a Product Group, summing the child Product Group Item prices from the Pricebook
    public static Decimal getProductGroupPrice(Product_Group__c objProductGroup, String strPricebookFieldName) {
        Decimal decPrice = 0;
        System.Debug('QuoteCloudUtil.getProductGroupPrice: Pricing for ' + strPricebookFieldName);
        for (Product_Group_Item__c objProductGroupItem : objProductGroup.Product_Group_Items__r) {
            System.Debug('QuoteCloudUtil.getProductGroupPrice: objProductGroupItem ' + objProductGroupItem);
            Decimal decPriceTmp = (Decimal)objProductGroupItem.Product__r.get(strPricebookFieldName);
            System.Debug('QuoteCloudUtil.getProductGroupPrice: Adding price ' + decPriceTmp + ' from Product Group Item ' + objProductGroupItem);
            decPrice += decPriceTmp;
        }
        return decPrice;
    }
    // ECD Oct 2019 Harmonization
    // Map a list of child Quote Products with the key being the Product Group parent product Id
    public static void addBundleChildToParentMap(Map<Id, List<BigMachines__Quote_Product__c>> mapBundleParentToChildQuoteProducts, BigMachines__Quote_Product__c objChildQuoteProduct) {
        // Quote Product not part of a Bundle.
        if (objChildQuoteProduct.Bundle_Line__c == null) {
            return;
        }
        // Store the Child Record in a list of Quote Products that are associated with the Quote Product
        if (mapBundleParentToChildQuoteProducts.containsKey(objChildQuoteProduct.Bundle_Line__c)) {
            mapBundleParentToChildQuoteProducts.get(objChildQuoteProduct.Bundle_Line__c).add(objChildQuoteProduct);
        } else {
            List<BigMachines__Quote_Product__c> listQP = new List<BigMachines__Quote_Product__c>();
            listQp.add(objChildQuoteProduct);
            mapBundleParentToChildQuoteProducts.put(objChildQuoteProduct.Bundle_Line__c, listQP);                    
        }
    }
    // ECD Oct 2019 Harmonization
    // After loading Quote Products in a Quopting tool, sum each of the pricing fields from the child quote products.
    // If using this Util, make sure NOT to save the parent Quote products as it will double the sum of the Parent Quote Product for the Bundle
    public static void sumChildProductsToParentPricing(Map<Id, List<BigMachines__Quote_Product__c>> mapBundleParentToChildQuoteProducts, List<QuoteProductWrapper> listParentProductWrappers) {
        for (QuoteProductWrapper objQPW : listParentProductWrappers) {
            System.Debug('QuoteCloudUtil.sumChildProductsToParentPricing Finding child records for objQPW ' + objQPW);
            List<BigMachines__Quote_Product__c> listChildQP = mapBundleParentToChildQuoteProducts.get(objQPW.record.Id);
            if (listChildQP != null) {
                for (BigMachines__Quote_Product__c objChildQP : listChildQP) {
                    System.Debug('QuoteCloudUtil.sumChildProductsToParentPricing Examine child record for objQPW.record.Id ' + objQPW.record.Id + ' objQPW.record.Ext_List__c ' + objQPW.record.Ext_List__c + ' objChildQP.Ext_List__c ' + objChildQP.Ext_List__c);
                    objQPW.record.List_Price__c = objQPW.record.List_Price__c == null ? objChildQP.List_Price__c : objQPW.record.List_Price__c + objChildQP.List_Price__c;
                    objQPW.record.Ext_List__c = objQPW.record.Ext_List__c == null ? objChildQP.Ext_List__c : objQPW.record.Ext_List__c + objChildQP.Ext_List__c;
                    objQPW.record.Net_Unit_Price__c = objQPW.record.Net_Unit_Price__c == null ? objChildQP.Net_Unit_Price__c : objQPW.record.Net_Unit_Price__c + objChildQP.Net_Unit_Price__c;
                    objQPW.record.Ext_Net_Price__c = objQPW.record.Ext_Net_Price__c == null ? objChildQP.Ext_Net_Price__c : objQPW.record.Ext_Net_Price__c + objChildQP.Ext_Net_Price__c;
                    /*
objQPW.decListPrice += objChildQP.List_Price__c; 
objQPW.decExtListPrice += objChildQP.Ext_List__c; 
objQPW.decNetUnitPrice += objChildQP.Net_Unit_Price__c; 
objQPW.decExtNetPricePrice += objChildQP.Ext_Net_Price__c;
*/
                }
            }
        }
    }
    // ECD Oct 2019 Harmonization
    // Loop through listParentProductWrappers to see if any child quote product quantities do not match the quantity entered from the UI.
    // If they differ, update the quantity in the child quote product
    public static void updateQuantityChildProductsToParentQuantity(Map<Id, List<BigMachines__Quote_Product__c>> mapBundleParentToChildQuoteProducts, List<QuoteProductWrapper> listParentProductWrappers) {
        for (QuoteProductWrapper objQPW : listParentProductWrappers) {
            System.Debug('QuoteCloudUtil.updateQuantityChildProductsToParentQuantity Finding child records for objQPW ' + objQPW);
            List<BigMachines__Quote_Product__c> listChildQP = mapBundleParentToChildQuoteProducts.get(objQPW.record.Id);
            if (listChildQP != null) {
                for (BigMachines__Quote_Product__c objChildQP : listChildQP) {
                    if (objChildQP.Quantity__c != objQPW.record.Quantity__c) {
                        objChildQP.Quantity__c = objQPW.record.Quantity__c;
                        System.Debug('QuoteCloudUtil.updateQuantityChildProductsToParentQuantity Changing child quantity to parent quantity Quantity__c ' + objChildQP.Quantity__c +
                                     ' for objChildQP ' + objChildQP);
                    } else {
                        System.Debug('QuoteCloudUtil.updateQuantityChildProductsToParentQuantity No need to change child quantity for objChildQP ' + objChildQP);
                    }
                }
            }
        }
    }
    
    // ECD Oct 2019 Harmonization
    // Set all meaningful price fields to zero
    public static void revertPricingToZeroForBundleParent(BigMachines__Quote_Product__c objQP) {
        objQP.Extended_Price_Per_Month__c = 0;
        objQP.Net_Unit_Price__c = 0;
        objQP.List_Price__c = 0;
        objQP.Ext_Net_Price__c = 0;
        objQP.Ext_List__c = 0;
        objQP.BigMachines__Sales_Price__c  = 0;
    }
    
    public static void debugQPLines(List<BigMachines__Quote_Product__c> list_QuoteProductRecords) {
        for(BigMachines__Quote_Product__c objQP : list_QuoteProductRecords) {
            System.Debug('debugQPLines ECD objQP ' + objQP.Name +
                         ' List ' + objQP.List_Price__c +
                         ' Sales ' + objQP.BigMachines__Sales_Price__c +
                         ' Ext Net ' + objQP.Ext_Net_Price__c);
        }
    }
}