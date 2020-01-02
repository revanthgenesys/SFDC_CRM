//Nik Mills - 30-Apr-2019
//For code coverage and testing of the ProfessionalServicesCASOrderHandler helper class
@IsTest(SeeAllData=true)
public class ProfessionalServicesCASOrderHandler_Test
{
    static Opportunity testPSOpp;
    static Opportunity testCASOpp;
    static Order__c testOrder;
    
    static testMethod void test1TestPSCAS1stYearNoLinks()
    {
        createOrderTestData();
        testOrder.Status__c = 'Cancelled';
        
        Test.StartTest();
        update testOrder;
        
        System.AssertEquals(true, testOrder.Master_Order_Number__c == null, 'testOrder Master Opportunity not null');
        Test.StopTest();
    }

    //static testMethod void TestPSCAS1stYearNoPSOppMasterLink()
    //{
    //    List<Opportunity> AllOpps = new List<Opportunity>();
    //    List<OpportunityLineItem> testOppProds;
    //   
    //    createCASOpptyTestData();
    //    AllOpps.add(testCASOpp);

    //    List<Pricebook2> pBook = [SELECT Id, Name
    //                              FROM Pricebook2
    //                              WHERE Name =: 'Professional Services'];

    //    List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode
    //                                    FROM PriceBookEntry
    //                                    WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'USD'];

    //    Util.Bypass_Trigger_Chk = true;

    //    Product2 testProduct = TestUtil.createProducts(1, false)[0];
    //    testProduct.Type__c = 'Professional Services';
    //    testProduct.zqu__SKU__c = 'OppTest123';
    //    testProduct.Description = 'Custom App Support (Testing)';
    //    insert testProduct;

    //    List<Product2> list_ofProduct2 = new List<Product2>();
    //    list_ofProduct2.add(testProduct);

    //    createOrderTestData();
    //    testOrder.Opportunity__c = testCASOpp.Id;
    //    testOrder.Status__c = 'Submitted';
    //    update testOrder;
        
    //    Util.Bypass_Trigger_Chk = false;
        
    //    Order_Line_Item__c orderli1 = TestUtil.createOrderLines(list_ofProduct2, testOrder.id, false)[0];
    //    orderli1.POB_Type__c = 'PS - CAS';
        
    //    Test.StartTest();

    //    insert orderli1;
    //    testOrder.Special_Instructions__c = 'Testing';
    //    update testOrder;
        
    //    System.AssertEquals(true, testOrder.Master_Order_Number__c == null, 'testOrder Master Opportunity not null');
        
    //    Test.StopTest();
    //}
    
    static testMethod void test2TestPSCAS1stYearFieldUpdates()
    {
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
       
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
        testProduct.Description = 'Custom App Support (Testing)';
        insert testProduct;

        List<Product2> list_ofProduct2 = new List<Product2>();
        list_ofProduct2.add(testProduct);

        testCASOpp.Master_Opportunity__c = testPSOpp.Id;
        update testCASOpp;
        
        createOrderTestData();
        testOrder.Opportunity__c = testCASOpp.Id;
        testOrder.Status__c = 'Submitted';
        update testOrder;
        
        Util.Bypass_Trigger_Chk = false;
        
        Order_Line_Item__c orderli1 = TestUtil.createOrderLines(list_ofProduct2, testOrder.id, false)[0];
        
        orderli1.POB_Type__c = 'PS - CAS';
        
        Test.StartTest();
        insert oli1;
        insert oli2;

        insert orderli1;
        testOrder.Special_Instructions__c = 'Testing';
        update testOrder;
        
        Test.StopTest();

        List<Order__c> orders = [SELECT Id, PS_CAS_Order__c FROM Order__c WHERE Id = :testOrder.Id];

        for (Order__c o : orders)
        {
            System.AssertEquals(true, o.PS_CAS_Order__c == true, 'The value of PS CAS Order was not set to True');
        }
    }

    static testMethod void test3TestPSEASubscriptionFieldUpdates()
    {
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
       
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
        testProduct.zqu__SKU__c = 'OppTest456';
        testProduct.Description = 'Expert App Subscription';
        testProduct.PS_Contract__c = true;
        insert testProduct;

        List<Product2> list_ofProduct2 = new List<Product2>();
        list_ofProduct2.add(testProduct);

        testCASOpp.Master_Opportunity__c = testPSOpp.Id;
        update testCASOpp;
        
        createOrderTestData();
        testOrder.Opportunity__c = testCASOpp.Id;
        testOrder.Status__c = 'Submitted';
        update testOrder;
        
        Util.Bypass_Trigger_Chk = false;
        
        Order_Line_Item__c orderli1 = TestUtil.createOrderLines(list_ofProduct2, testOrder.id, false)[0];
        
        orderli1.POB_Type__c = 'PS - Fixed Fee on Date';
        
        Test.StartTest();
        insert oli1;
        insert oli2;

        insert orderli1;
        testOrder.Special_Instructions__c = 'Testing EA Subscriptions';
        update testOrder;
        
        Test.StopTest();

        List<Order__c> orders = [SELECT Id, PS_Subscription_GC_Order__c FROM Order__c WHERE Id = :testOrder.Id];

        for (Order__c o : orders)
        {
            System.AssertEquals(true, o.PS_Subscription_GC_Order__c == true, 'The value of PS Subscription GC Order was not set to True');
        }
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
        
        insert testCASOpp;
        Util.Bypass_Trigger_Chk = false; 
    }  

    static void createOrderTestData() {
        Util.Bypass_Trigger_Chk = true;
        
        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Order__c'
            and DeveloperName =: 'License_Orders'
        ];
        
        testOrder = TestUtil.createOrders(1, true)[0];
        testOrder.RecordTypeId = rtypes[0].Id;
        
        Util.Bypass_Trigger_Chk = false;
    }

}