/************************************************************************************
** Purpose: Unit test class for PSOrder_BeforeApproval_ValidateSubsidiaryValues 
**          trigger.
**
** Project: PS RevPro
** Author: Alex H
** Date: 28-Oct-2019
**
** Scenario 1) PS Opp - Sold To Subsidiary 8100, Subsidiary Override null
**             PS Order - Sold To Subsidiary 8100
**             Validation should allow approval
** Scenario 2) PS Opp - Sold To Subsidiary 8100, Subsidiary Override 8400
**             PS Order - Sold To Subsidiary 8400
**             Validation should allow approval
** Scenario 3) PS Opp - Sold To Subsidiary 8100, Subsidiary Override null
**             PS Order - Sold To Subsidiary 8400
**             Validation should prevent approval
** Scenario 4) PS Opp - Sold To Subsidiary 8100, Subsidiary Override 8400
**             PS Order - Sold To Subsidiary 8100
**             Validation should prevent approval
**
*************************************************************************************/
@isTest(seealldata=true)
private class Order_ValidateSubsidiaryValsTriggerTest {
  static List<Opportunity> listOpps = new List<Opportunity>();
  static List<Order__c> listOrders = new List<Order__c>();

  @isTest
  static void testTrigger() 
  {
    initialize();
    
    Util.Bypass_Trigger_Chk = false;
    Test.startTest();
    // set the order to approved
    
    // scenario 1
    listOrders[0].status__c = 'Approved';
    update listOrders[0];
    System.assertEquals('Approved', listOrders[0].status__c, 'Error: order 1 should have been approved.');
    
    // scenario 2
    listOrders[1].status__c = 'Approved';
    update listOrders[1];
    System.assertEquals('Approved', listOrders[1].status__c, 'Error: order 2 should have been approved.');
    
    // scenario 3
    listOrders[2].status__c = 'Approved';
    try
    {
      update listOrders[2];
      // we don't expect to land here as the trigger should prevent the record from being updated
      System.assert(false, 'Error: order 3 should NOT have been approved.');
    }
    catch(DMLException e)
    {
      // we expect to land here as the trigger should prevent the record from being updated
      System.assert(true, 'Success: order 3 successfully prevented from being approved.');
    }
    
    // scenario 4
    listOrders[3].status__c = 'Approved';
    try
    {
      update listOrders[3];
      // we don't expect to land here as the trigger should prevent the record from being updated
      System.assert(false, 'Error: order 4 should NOT have been approved.');
    }
    catch(DMLException e)
    {
      // we expect to land here as the trigger should prevent the record from being updated
      System.assert(true, 'Success: order 4 successfully prevented from being approved.');
    }
    
    Test.stopTest();
  }
  
  
  private static void initialize()
  {
    // prevent other triggers from firing temporarily
    Util.Bypass_Trigger_Chk = true;
    
    // Create account, sold to, and subsidiary
    List<Account> listAccounts = TestDataFactoryForQuoteTool.createAccounts(1);
    System.assertEquals(listAccounts.size(), 1);
    
    List<Account> listSoldTo = TestDataFactoryForQuoteTool.createAccounts(2);
    System.assertEquals(listSoldTo.size(), 2);
    
    Id idSubsidiary1 = [select id from Subsidary__c where Name = '8100'][0].id;
    Id idSubsidiary2 = [select id from Subsidary__c where Name = '8400'][0].id;
    
    listSoldTo[0].Subsidary__c = idSubsidiary1;
    listSoldTo[1].Subsidary__c = idSubsidiary2;
    update listSoldTo;
    System.assertNotEquals(null, listSoldTo[0].Subsidary__c, 'Error: Sold To 1 Subsidiary was not properly initialized for test.');
    System.assertNotEquals(null, listSoldTo[1].Subsidary__c, 'Error: Sold To 2 Subsidiary was not properly initialized for test.');
    
    // Create opportunity
    listOpps = TestDataFactoryForQuoteTool.createOpportunties(listAccounts[0].Id, 2);
    System.assertEquals(listOpps.size(), 2);
    
    list<RecordType> rtList = [Select id From RecordType 
                               Where sObjectType = 'Opportunity' and RecordType.Name = 'Professional Services'];
    
    // Create Opportunity Products
    List<Pricebook2> pBook = [SELECT Id, Name FROM Pricebook2
                              WHERE Name =: 'Professional Services'];

    List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode FROM PriceBookEntry
                                    WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'USD'];
    
    OpportunityLineItem op1 = new OpportunityLineItem(OpportunityId=listOpps[0].Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=1000, POB_Type__c='PS - CAS', Description__c='Test CAS Item 1');
    OpportunityLineItem op2 = new OpportunityLineItem(OpportunityId=listOpps[1].Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=2000, POB_Type__c='PS - CAS', Description__c='Test CAS Item 2');
    insert op1;
    insert op2;
    
    Product2 testProd1 = TestUtil.createProducts(1, false)[0];
    testProd1.Type__c = 'Professional Services';
    testProd1.zqu__SKU__c = 'TestOpp - 123';
    testProd1.Description = 'CAS (Test)';
    testProd1.POB_Type__c = 'PS - CAS';
    insert testProd1;
    
    Product2 testProd2 = TestUtil.createProducts(1, false)[0];
    testProd2.Type__c = 'Professional Services';
    testProd2.zqu__SKU__c = 'TestOpp - 456';
    testProd2.Description = 'CAS (Test)';
    testProd2.POB_Type__c = 'PS - CAS';
    insert testProd2;
    
    List<Product2> listProd1 = new List<Product2>();
    listProd1.add(testProd1);
    List<Product2> listProd2 = new List<Product2>();
    listProd2.add(testProd2);
    
    listOpps[0].recordtypeid = rtList[0].id;
    listOpps[0].BusinessPartner__c = listSoldTo[0].Id;
    listOpps[0].PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
    listOpps[0].Finance_Oppty_Approval_Status__c = 'Approved';
    listOpps[1].recordtypeid = rtList[0].id;
    listOpps[1].BusinessPartner__c = listSoldTo[0].Id;
    listOpps[1].PS_Subsidiary_Override__c = '8400';
    listOpps[1].PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
    listOpps[1].Finance_Oppty_Approval_Status__c = 'Approved';
    update listOpps;
    System.assertNotEquals(null, listOpps[0].BusinessPartner__c, 'Error: Order 1 Sold To/Business Partner was not properly initialized for test.');
    System.assertNotEquals(null, listOpps[1].BusinessPartner__c, 'Error: Order 2 Sold To/Business Partner was not properly initialized for test.');
    System.assertNotEquals(null, listOpps[1].PS_Subsidiary_Override__c, 'Error: Order 2 PS Subsidiary Override was not properly initialized for test.');
    
    List<BigMachines__Quote__c> listQuotes = 
                                  TestDataFactoryForQuoteTool.createQuotes(listOpps[0].Id, listAccounts[0].Id, 2, 'Professional Services');
    System.assertEquals(listQuotes.size(), 2);
    
    listOpps[0].Primary_Quote__c = listQuotes[0].Id;
    listOpps[1].Primary_Quote__c = listQuotes[1].Id;
    update listOpps;

    // Create orders
    listOrders = TestDataFactoryForQuoteTool.createOrders(listQuotes[0].Id, listOpps[0].Id, 1);
    listOrders.add(TestDataFactoryForQuoteTool.createOrders(listQuotes[0].Id, listOpps[0].Id, 1)[0]);
    listOrders.add(TestDataFactoryForQuoteTool.createOrders(listQuotes[1].Id, listOpps[1].Id, 1)[0]);
    listOrders.add(TestDataFactoryForQuoteTool.createOrders(listQuotes[1].Id, listOpps[1].Id, 1)[0]);
    System.assertEquals(listOrders.size(), 4);
    
    list<RecordType> rList = [Select id From RecordType 
                              Where sObjectType = 'Order__c'and RecordType.Name = 'PS Orders'];
    
    listOrders[0].recordtypeid = rList[0].id;
    listOrders[0].License_FYM_detail__c = 'PS Orders';
    listOrders[0].status__c = 'In Progress';
    listOrders[0].Opportunity__c = listOpps[0].Id;    // 8100 - null
    listOrders[0].Sold_To_Name__c = listSoldTo[0].Id; // 8100
    
    listOrders[1].recordtypeid = rList[0].id;
    listOrders[1].License_FYM_detail__c = 'PS Orders';
    listOrders[1].status__c = 'In Progress';
    listOrders[1].Opportunity__c = listOpps[1].Id;    // 8100 - 8400
    listOrders[1].Sold_To_Name__c = listSoldTo[1].Id; // 8400
    
    listOrders[2].recordtypeid = rList[0].id;
    listOrders[2].License_FYM_detail__c = 'PS Orders';
    listOrders[2].status__c = 'In Progress';
    listOrders[2].Opportunity__c = listOpps[0].Id;    // 8100 - null
    listOrders[2].Sold_To_Name__c = listSoldTo[1].Id; // 8400
    
    listOrders[3].recordtypeid = rList[0].id;
    listOrders[3].License_FYM_detail__c = 'PS Orders';
    listOrders[3].status__c = 'In Progress';
    listOrders[3].Opportunity__c = listOpps[1].Id;    // 8100 - 8400
    listOrders[3].Sold_To_Name__c = listSoldTo[0].Id; // 8100
    update listOrders;
    
    // Create Order Line Items
    Order_Line_Item__c oli1 = TestUtil.createOrderLines(listProd1, listOrders[0].Id, false)[0];
    oli1.POB_Type__c = 'PS - CAS';
    oli1.Associated_Opportunity_Product_ID__c = testProd1.id;
    insert oli1;
    
    Order_Line_Item__c oli2 = TestUtil.createOrderLines(listProd2, listOrders[1].Id, false)[0];
    oli2.POB_Type__c = 'PS - CAS';
    oli2.Associated_Opportunity_Product_ID__c = testProd2.id;
    insert oli2;
    
    Order_Line_Item__c oli3 = TestUtil.createOrderLines(listProd1, listOrders[2].Id, false)[0];
    oli3.POB_Type__c = 'PS - CAS';
    oli3.Associated_Opportunity_Product_ID__c = testProd1.id;
    insert oli3;
    
    Order_Line_Item__c oli4 = TestUtil.createOrderLines(listProd2, listOrders[3].Id, false)[0];
    oli4.POB_Type__c = 'PS - CAS';
    oli4.Associated_Opportunity_Product_ID__c = testProd2.id;
    insert oli4;
    
    // allow triggers to fire now
    Util.Bypass_Trigger_Chk = false;
  }
}