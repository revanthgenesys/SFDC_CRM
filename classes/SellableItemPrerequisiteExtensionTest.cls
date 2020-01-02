@isTest
/* SellableItemPrerequisiteExtensionTest
   A. Haun Dec 2016
   Tests the SellableItemPrerequisiteExtension class.
 */
 private class SellableItemPrerequisiteExtensionTest {
   static SellableItemPrerequisiteExtension ext;
   static Sellable_Item_Product__c masterProd;
   static Sellable_Item_Product__c reqProd;     //required prerequisite product
   static Sellable_Item_Product__c conProd1;    //conditional prerequisite product
   static Sellable_Item_Product__c conProd2;    //conditional prerequisite product
   static PageReference pref;
   static Util ut;
   
   private static void init() { 
     TestUtil.setConfigValues();
     
     masterProd = new Sellable_Item_Product__c(Name='Test Product 1');
     insert masterProd;
     
     reqProd = new Sellable_Item_Product__c(Name='Required Product');
     insert reqProd;
     
     conProd1 = new Sellable_Item_Product__c(Name='Optional Product 1');
     insert conProd1;
     
     conProd2 = new Sellable_Item_Product__c(Name='Optional Product 2');
     insert conProd2;
     
     Sellable_Item_Product_Prerequisite__c reqPrereq = new Sellable_Item_Product_Prerequisite__c(
       Sellable_Item_Product_Master__c=masterProd.id, Mandatory__c=true, Prerequisite_Product__c=reqProd.id);
     insert reqPrereq;
     
     Sellable_Item_Product_Prerequisite__c conPrereq1 = new Sellable_Item_Product_Prerequisite__c(
       Sellable_Item_Product_Master__c=masterProd.id, Mandatory__c=false, Prerequisite_Product__c=conProd1.id);
     insert conPrereq1;
     
     Sellable_Item_Product_Prerequisite__c conPrereq2 = new Sellable_Item_Product_Prerequisite__c(
       Sellable_Item_Product_Master__c=masterProd.id, Mandatory__c=false, Prerequisite_Product__c=conProd2.id);
     insert conPrereq2;
     
     pref = Page.SellableItemPrerequisites;
     pref.getParameters().put('id', masterProd.id);
     Test.setCurrentPage(pref);
     
     ApexPages.StandardController con = new ApexPages.StandardController(masterProd);
     ext = new SellableItemPrerequisiteExtension(con);
   }
   
   static testMethod void validatePrerequisiteExtension() {
     init();
     Test.startTest();
     
     List<Sellable_Item_Product_Prerequisite__c> mpr = ext.getMandatoryPrerequisites();
     System.assertEquals(1, mpr.size());
     
     List<Sellable_Item_Product_Prerequisite__c> cpr = ext.GetConditionalPrerequisites();
     System.assertEquals(2, cpr.size());

     Test.stopTest();
   }
 }