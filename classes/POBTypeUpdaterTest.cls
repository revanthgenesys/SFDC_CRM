@isTest(SeeAllData=true)
// ------------------------------------------------------------------------------
// TEST: POBTypeUpdaterTest
// PURPOSE: Tests the POB Type Updater class, which updates POB Type value for
//          PS Opportunity Products and Order Line Items.  Used for PS RevPro.
// AUTHOR: A. Haun
// ------------------------------------------------------------------------------
public class POBTypeUpdaterTest {
  private static Set<OpportunityLineItem> setOppLI { set; get; }
  private static Set<Order_Line_Item__c> setOrderLI { set; get; }
  
  // -----------------------------------------------------------------------------
  // SETUP
  static void setup() {
    setOppLI = new Set<OpportunityLineItem>();
    setOrderLI = new Set<Order_Line_Item__c>();
    
    System.debug('###### Creating test records');
    List<RecordType> listProdRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Product2' AND DeveloperName='COREProductRecordType'];

    List<Product2> listProd = new List<Product2>();
    for(Integer i=0; i<3; i++) {
      Product2 prod = new Product2();
      prod.Name = 'TEST POBTypeUpdater Product ' + i;
      prod.recordTypeId = listProdRT[0].Id;
      prod.Type__c = 'PS';
      prod.zqu__SKU__c = 'TESTPROD' + i + 'DELETEPLZ';
      listProd.add(prod);
    }
    // Set mappable values for the first two products (leave the third blank)
    listProd[0].POB_Type__c = 'PS - Variable Model';
    listProd[1].POB_Type__c = 'PS - CAS';
    listProd[2].POB_Type__c = '';
    insert listProd;
    
    List<PricebookEntry> listPBE = TestUtil.createPriceBookEntries(listProd, true);
    System.AssertNotEquals(0, listPBE.size());
    
    List<Opportunity> listOpp = TestUtil.createOpportunities(1, false);
    System.AssertEquals(1, listOpp.size());
    
    List<RecordType> listOppRT = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' AND DeveloperName = 'Professional_Services'];
    listOpp[0].recordTypeId = listOppRT[0].Id;
    listOpp[0].ProjectType__c = 'Expert Apps';
    insert listOpp;
    
    List<OpportunityLineItem> listOLI = TestUtil.createOlis(listPBE, listOpp[0].Id, false);
    System.AssertNotEquals(0, listOLI.size());
    
    for(Integer i=0; i<listOLI.size(); i++) {
      listOLI[i].POB_Type__c = '';
      System.AssertNotEquals(null, listOLI[i].OpportunityId);
      System.AssertNotEquals(null, listOLI[i].PricebookEntryId);
    }
    insert listOLI;
    
    List<BigMachines__Quote__c> listQuote = TestUtil.createQuotes(1, listOpp[0].Id, true);
    List<Order__c> listOrder = TestUtil.createOrders(1, listQuote[0].Id, listOpp[0].Id, true);
    System.AssertNotEquals(null, listOrder[0].Opportunity__c);
    
    List<Order_Line_Item__c> listOrderLI = TestUtil.createOrderLines(listProd, listOrder[0].Id, false);
    System.AssertNotEquals(0, listOrderLI.size());
    
    for(Integer i=0; i<listOrderLI.size(); i++) {
      listOrderLI[i].POB_Type__c = '';
      System.AssertNotEquals(null, listOrderLI[i].Order__c);
    }
    insert listOrderLI;
    
    setOppLI.addAll(listOLI);
    
    Set<Id> setOrderLIID = new Set<Id>();
    for(Integer i=0; i<listOrderLI.size(); i++) {
      setOrderLIID.add(listOrderLI[i].Id);
    }
    System.AssertEquals(setOrderLIID.size(), listOrderLI.size());
    
    setOrderLI.addAll([SELECT Id, Order__c, Order__r.Opportunity__c, POB_Type__c, Product_POB_Type_tmp__c
                       FROM Order_Line_Item__c
                       WHERE Id IN :setOrderLIID]);
  }
  
  // -----------------------------------------------------------------------------
  // TEST METHOD: validateOppLIPOBTypeUpdate
  // PURPOSE: Create test data and updater class.  Call the updater methods to 
  //          update POB Type values and ensure that values were set.
  static testMethod void validateOppLIPOBTypeUpdate() {
    System.debug('###### Validating POB Type updates for PS Opportunity Line Items (Opportunity Products)');
    setup();
  
    // Test start
    Test.startTest();
    POBTypeUpdater Updater = new POBTypeUpdater();
    
    List<OpportunityLineItem> listOppLIRes = Updater.UpdatePSOpportunityLineItemPOBTypes(setOppLI);
    System.AssertEquals(setOppLI.size(), listOppLIRes.size());
    for(Integer i=0; i<listOppLIRes.size(); i++) {
      System.AssertNotEquals('', listOppLIRes[i].POB_Type__c);
    }
    // Test end
    Test.stopTest();
  }
  
  // -----------------------------------------------------------------------------
  // TEST METHOD: validateOrderLIPOBTypeUpdate
  // PURPOSE: Create test data and updater class.  Call the updater methods to 
  //          update POB Type values and ensure that values were set.
  static testMethod void validateOrderLIPOBTypeUpdate() {
    System.debug('###### Validating POB Type updates for PS Order Line Items');
    setup();
  
    // Test start
    Test.startTest();
    POBTypeUpdater Updater = new POBTypeUpdater();
    
    List<Order_Line_Item__c> listOrderLIRes = Updater.UpdatePSOrderLineItemPOBTypes(setOrderLI);
    System.AssertEquals(setOrderLI.size(), listOrderLIRes.size());
    for(Integer i=0; i<listOrderLIRes.size(); i++) {
      System.AssertNotEquals('', listOrderLIRes[i].POB_Type__c);
    }
    // Test end
    Test.stopTest();
  }
}