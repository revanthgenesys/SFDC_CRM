//Nik Mills - 6-Mar-2019
//For code coverage and testing of the OrderLineItemTOOpptyProductLinker controller class (and VF)
@IsTest(SeeAllData=true)
public class OrderLineItemToOpptyProductLinker_TEST
{
    static Opportunity testPSOpp;
    static Opportunity testCASOpp;
    static Order__c testOrder;
    
    static testMethod void TestOrderLineItemToOpptyProdLink_Test1_NewLinks()
    {
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
        PageReference testPageRefReturn;
       
        createPSOpptyTestData();
        createCASOpptyTestData();
        AllOpps.add(testPSOpp);
        AllOpps.add(testCASOpp);

        List<Pricebook2> pBook = [SELECT Id, Name
                                  FROM Pricebook2
                                  WHERE Name =: 'Professional Services'];

        List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode
                                        FROM PriceBookEntry
                                        WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'USD'];

        Util.Bypass_Trigger_Chk = true;
                                                         
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=testPSOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=4000, Description__c='Test OLI Item 1 - CAS');
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=testPSOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=2500, Description__c='Test OLI Item 2 - ExpApp');

        Product2 testProduct = TestUtil.createProducts(1, false)[0];
        testProduct.Type__c = 'Professional Services';
        testProduct.zqu__SKU__c = 'OppTest123';
        insert testProduct;

        List<Product2> list_ofProduct2 = new List<Product2>();
        list_ofProduct2.add(testProduct);
        
        Order__c testOrder = TestUtil.createOrders(1, true)[0];
        testOrder.Opportunity__c = testCASOpp.Id;
        update testOrder;
        
        Order_Line_Item__c orderli1 = TestUtil.createOrderLines(list_ofProduct2, testOrder.id, false)[0];
        
        Test.StartTest();
        insert oli1;
        insert oli2;

        insert orderli1;
        
        PageReference pageRef = Page.OrderLineItemToOpptyProductLinker;
        pageRef.getParameters().put('sourceOrderLineItemId', orderli1.Id);
        Test.setCurrentPage(pageRef);
        
        OrderLineItemToOpptyProductLinker orderLineItemToOpptyProdLink = new OrderLineItemToOpptyProductLinker();
        testOppProds = orderLineItemToOpptyProdLink.getOpptyProducts();
        
        System.AssertNotEquals(false, testOppProds.IsEmpty(), 'Opportunity Products List is not Empty');
        
        // Test linking the OLI items on the PS Oppty now
        orderLineItemToOpptyProdLink.selectedOppProductId = oli1.Id;
        orderLineItemToOpptyProdLink.LinkSelectedRecord();
        
        testPageRefReturn = orderLineItemToOpptyProdLink.Cancel();
        
        Test.StopTest();
        
        Util.Bypass_Trigger_Chk = false;
    }
    
    static testMethod void TestOrderLineItemToOpptyProdLink_Test2_ClearExistingLinks()
    {
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
        PageReference testPageRefReturn;
       
        createPSOpptyTestData();
        createCASOpptyTestData();
        AllOpps.add(testPSOpp);
        AllOpps.add(testCASOpp);

        List<Pricebook2> pBook = [SELECT Id, Name
                                  FROM Pricebook2
                                  WHERE Name =: 'Professional Services'];

        List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode
                                        FROM PriceBookEntry
                                        WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'USD'];
                     
        Util.Bypass_Trigger_Chk = true;                     
                                                         
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=testPSOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=4000, Description__c='Test OLI Item 1 - CAS');
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=testPSOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=2500, Description__c='Test OLI Item 2 - ExpApp');

        Product2 testProduct = TestUtil.createProducts(1, false)[0];
        testProduct.Type__c = 'Professional Services';
        testProduct.zqu__SKU__c = 'OppTest123';
        insert testProduct;

        List<Product2> list_ofProduct2 = new List<Product2>();
        list_ofProduct2.add(testProduct);
        
        Order__c testOrder = TestUtil.createOrders(1, true)[0];
        testOrder.Opportunity__c = testCASOpp.Id;
        update testOrder;
        
        Order_Line_Item__c orderli1 = TestUtil.createOrderLines(list_ofProduct2, testOrder.id, false)[0];
       
        Test.StartTest();
        insert oli1;
        insert oli2;
        insert orderli1;

        orderli1.Associated_Opportunity_Product_ID__c = oli1.Id;
        update orderli1;
        
        PageReference pageRef = Page.OrderLineItemToOpptyProductLinker;
        pageRef.getParameters().put('sourceOrderLineItemId', orderli1.Id);
        Test.setCurrentPage(pageRef);
        
        OrderLineItemToOpptyProductLinker orderLineItemToOpptyProdLink = new OrderLineItemToOpptyProductLinker();
        testOppProds = orderLineItemToOpptyProdLink.getOpptyProducts();
        
        System.AssertNotEquals(false, testOppProds.IsEmpty(), 'Opportunity Products list is not Empty');
        
        // Test unlinking the OLI items now
        orderLineItemToOpptyProdLink.ClearLinkedItem();
        
        Test.StopTest();
        
        Util.Bypass_Trigger_Chk = false;
    }    
    
    // Create a PS Specific standalone test opportunity
    static void createPSOpptyTestData() {
        Util.Bypass_Trigger_Chk = true;
        
        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Opportunity'
            and DeveloperName =: 'Professional_Services'
        ];
        List <Pricebook2> pBook = [SELECT Id, Name
                                                FROM Pricebook2
                                                WHERE Name =: 'Professional Services'];
        
        Account acc = TestUtil.createAccounts(1, true)[0];
        testPSOpp = new Opportunity( Name='Test Opp', accountId = acc.Id );
        testPSOpp.RecordTypeId = rtypes[0].Id;
        testPSOpp.closeDate = Date.today().addMonths(1);
        testPSOpp.CurrencyIsoCode = 'USD';       
        testPSOpp.StageName = '1.Recognize Needs';     
        testPSOpp.Lines_of_Businesses__c = 'PureEngage';
        testPSOpp.PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
        testPSOpp.Direct_Sales__c = true;
        testPSOpp.PriceBook2Id = pBook[0].Id;
        
        insert testPSOpp;
        Util.Bypass_Trigger_Chk = false; 
    }
    
    // Create a CAS Specific standalone test opportunity
    static void createCASOpptyTestData() {
        Util.Bypass_Trigger_Chk = true;
        
        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Opportunity'
            and DeveloperName =: 'Genesys_Renewal'
        ];
        List <Pricebook2> pBook = [SELECT Id, Name
                                                FROM Pricebook2
                                                WHERE Name =: 'Professional Services'];
        
        Account acc = TestUtil.createAccounts(1, true)[0];
        testCASOpp = new Opportunity( Name='Test CAS 1st Year Opp', accountId = acc.Id );
        testCASOpp.RecordTypeId = rtypes[0].Id;
        testCASOpp.closeDate = Date.today().addMonths(1);
        testCASOpp.CurrencyIsoCode = 'USD';       
        testCASOpp.StageName = '1.Recognize Needs';     
        testCASOpp.Lines_of_Businesses__c = 'PureEngage';
        testCASOpp.PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
        testCASOpp.Direct_Sales__c = true;
        testCASOpp.PriceBook2Id = pBook[0].Id;
        testCASOpp.Master_Opportunity__c = testPSOpp.Id;
        
        insert testCASOpp;
        Util.Bypass_Trigger_Chk = false; 
    }  

    static void createOrderTestData() {
        Util.Bypass_Trigger_Chk = true;
        
        testOrder = TestUtil.createOrders(1, true)[0];
        
        insert testOrder;
        Util.Bypass_Trigger_Chk = false;
    }

}