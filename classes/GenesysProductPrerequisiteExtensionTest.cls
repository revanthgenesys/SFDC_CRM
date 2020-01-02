@isTest
/* GenesysProductPrerequisiteExtensionTest
   A. Haun Dec 2016
   Tests the GenesysProductPrerequisiteExtension class.
 */
 private class GenesysProductPrerequisiteExtensionTest {
   static GenesysProductPrerequisiteExtension ext;
   static Product2 masterProd;
   static Product2 reqProd;     //required prerequisite product
   static Product2 conProd1;    //conditional prerequisite product
   static Product2 conProd2;    //conditional prerequisite product
   static PageReference pref;
   
   private static void init() {
     TestUtil.setConfigValues();
     
     masterProd = new Product2(Name='Test Product 1');
     insert masterProd;
     
     reqProd = new Product2(Name='Required Product');
     insert reqProd;
     
     conProd1 = new Product2(Name='Optional Product 1');
     insert conProd1;
     
     conProd2 = new Product2(Name='Optional Product 2');
     insert conProd2;
     
     Genesys_Product_Prerequisite__c reqPrereq = new Genesys_Product_Prerequisite__c(
       Name='Test Prereq 1', Mandatory__c=true, Genesys_Product_Master__c=masterProd.id, Prerequisite_Product__c=reqProd.id);
     insert reqPrereq;
     
     Genesys_Product_Prerequisite__c conPrereq1 = new Genesys_Product_Prerequisite__c(
       Name='Test Prereq 2', Mandatory__c=false, Genesys_Product_Master__c=masterProd.id, Prerequisite_Product__c=conProd1.id);
     insert conPrereq1;
     
     Genesys_Product_Prerequisite__c conPrereq2 = new Genesys_Product_Prerequisite__c(
       Name='Test Prereq 3', Mandatory__c=false, Genesys_Product_Master__c=masterProd.id, Prerequisite_Product__c=conProd2.id);
     insert conPrereq2;
     
     pref = Page.GenesysProductPrerequisites;
     pref.getParameters().put('id', masterProd.id);
     Test.setCurrentPage(pref);
     
     ApexPages.StandardController con = new ApexPages.StandardController(masterProd);
     ext = new GenesysProductPrerequisiteExtension(con);
   }
   
   static testMethod void validatePrerequisiteExtension() {
     init();
     Test.startTest();
     
     List<Genesys_Product_Prerequisite__c> mpr = ext.getMandatoryPrerequisites();
     System.assertEquals(1, mpr.size());
     
     List<Genesys_Product_Prerequisite__c> cpr = ext.GetConditionalPrerequisites();
     System.assertEquals(2, cpr.size());

     Test.stopTest();
   }
 }