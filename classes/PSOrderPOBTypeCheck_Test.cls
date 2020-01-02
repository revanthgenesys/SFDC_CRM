//Nik Mills - 09-Sep-2019
//For code coverage and testing of the PSOrderPOBTypeCheck helper class
@IsTest(SeeAllData=true)
public class PSOrderPOBTypeCheck_Test
{
    static Opportunity testPSOpp;
    static Opportunity testCASOpp;
    static Order__c testOrder;
    static Order__c testPSOrder;
    
    static testMethod void testaPSPOBCheckBypassedForCancelled()
    {
        List<Order__c> allOrders = new List<Order__c>();
    
        createOrderTestData();
        testOrder.Status__c = 'Cancelled';
        
        Test.StartTest();
        update testOrder;
        
        allOrders.add(testOrder);
        
        PSOrderPOBTypeCheck.CheckPSOrderPOBTypeMatchesForRevPro(allOrders, null);
        
        System.AssertEquals(true, testOrder.Order_Lines_with_POB_Mismatch__c == false, 'testOrder Order Lines with mismatch is not false');
        
        Test.StopTest();
    }
   
    static testMethod void testbPSOrderPOBTypeMismatched()
    {
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
        List<Order__c> allOrders = new List<Order__c>();
       
        createPSOpptyTestData();
        AllOpps.add(testPSOpp);

        List<Pricebook2> pBook = [SELECT Id, Name
                                  FROM Pricebook2
                                  WHERE Name =: 'Professional Services'];

        List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode
                                        FROM PriceBookEntry
                                        WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'USD'];

        Util.Bypass_Trigger_Chk = true;
                                                         
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=testPSOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=4000, POB_Type__c='PS - T&M', Description__c='Test OLI Item 1 - PS T&M');
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=testPSOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=2500, POB_Type__c='PS - Expert App', Description__c='Test OLI Item 2 - ExpApp');

        insert oli1;
        insert oli2;

        Product2 testProduct = TestUtil.createProducts(1, false)[0];
        testProduct.Type__c = 'Professional Services';
        testProduct.zqu__SKU__c = 'OppTest123';
        testProduct.Description = 'Custom App Support (Testing)';
        testProduct.POB_Type__c = 'PS - CAS';
        insert testProduct;

        List<Product2> list_ofProduct2 = new List<Product2>();
        list_ofProduct2.add(testProduct);

        createPSOrderTestData();
        testPSOrder.Opportunity__c = testPSOpp.Id;
        
        Order_Line_Item__c orderli1 = TestUtil.createOrderLines(list_ofProduct2, testPSOrder.id, false)[0];
        orderli1.POB_Type__c = 'PS - CAS';
        insert orderli1;

        allOrders.add(testPSOrder);

        Util.Bypass_Trigger_Chk = false;
        
        Test.StartTest();

        testPSOrder.Special_Instructions__c = 'Testing';
        update testPSOrder;
        
        PSOrderPOBTypeCheck.CheckPSOrderPOBTypeMatchesForRevPro(allOrders, null);
        
        Test.StopTest();

        //List<Order__c> orders = [SELECT Id, Order_Lines_with_POB_Mismatch__c FROM Order__c WHERE Id = :testPSOrder.Id];

        //for (Order__c o : orders)
        //{
        //    System.AssertEquals(true, o.Order_Lines_with_POB_Mismatch__c == true, 'The value of PS POB Mismatch was not set to True');
        //}
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
        testPSOpp.Finance_Oppty_Approval_Status__c = 'Approved';
        
        insert testPSOpp;
        Util.Bypass_Trigger_Chk = false; 
    }

    static void createOrderTestData() {
        Util.Bypass_Trigger_Chk = true;
        
        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Order__c'
            and DeveloperName =: 'PS_Orders'
        ];
        
        testOrder = TestUtil.createOrders(1, true)[0];
        testOrder.RecordTypeId = rtypes[0].Id;
        
        Util.Bypass_Trigger_Chk = false;
    }

    static void createPSOrderTestData() {
        List<Order__c> orders = new List<Order__c>();
        
        Account acc = TestUtil.createAccounts(1, true)[0];    

        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Order__c'
            and DeveloperName =: 'PS_Orders'
        ];

        testPSOrder = new Order__c();
        testPSOrder.Name = 'PS - TEST Order 1';
        testPSOrder.Order__c = 'PS - Test Order 1';
        testPSOrder.License_FYM_detail__c = 'PS Orders';
        testPSOrder.RecordTypeId = rtypes[0].Id;
        testPSOrder.Status__c = 'Submitted';
        testPSOrder.End_User_Name__c = acc.Id;
        testPSOrder.Sold_To_Name__c = acc.Id;
         
        insert testPSOrder;
    }

}