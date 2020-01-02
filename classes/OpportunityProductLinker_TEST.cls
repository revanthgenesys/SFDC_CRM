//Nik Mills - 27-Nov-2018
//For code coverage and testing of the OpportunityProductLinker controller class (and VF)
@IsTest(SeeAllData=true)
public class OpportunityProductLinker_TEST
{
    static Opportunity testOpp;
    
    static testMethod void TestOpptyProdLink_Test1_NewLinks()
    {
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
        PageReference testPageRefReturn;
       
        createPSOpptyTestData();
        AllOpps.add(testOpp);

        List<Pricebook2> pBook = [SELECT Id, Name
                                  FROM Pricebook2
                                  WHERE Name =: 'Professional Services'];

        List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode
                                        FROM PriceBookEntry
                                        WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'USD'];
                                                         
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=4000, Description__c='Test OLI Item 1');
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=2500, Description__c='Test OLI Item 2');
    
        Test.StartTest();
        insert oli1;
        insert oli2;
        
        PageReference pageRef = Page.OpportunityProductLinker;
        pageRef.getParameters().put('sourceOppProdId', oli1.Id);
        Test.setCurrentPage(pageRef);
        
        OpportunityProductLinker oppProdLink = new OpportunityProductLinker();
        testOppProds = oppProdLink.getopptyProducts();
        
        System.AssertNotEquals(true, testOppProds.IsEmpty(), 'Additional OLI for linking was not found and returned during test');
        
        // Test linking the OLI items now
        oppProdLink.selectedOppProductId = oli2.Id;
        oppProdLink.LinkSelectedRecord();
        
        testPageRefReturn = oppProdLink.Cancel();
        
        Test.StopTest();
    }
    
    static testMethod void TestOpptyProdLink_Test2_ClearExistingLinks()
    {
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
        PageReference testPageRefReturn;
       
        createPSOpptyTestData();
        AllOpps.add(testOpp);

        List<Pricebook2> pBook = [SELECT Id, Name
                                  FROM Pricebook2
                                  WHERE Name =: 'Professional Services'];

        List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode
                                        FROM PriceBookEntry
                                        WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'USD'];
                     
        Util.Bypass_Trigger_Chk = true;                     
                                                         
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=4000, Description__c='Test OLI Item 1');
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=2500, Description__c='Test OLI Item 2');
       
        Test.StartTest();
        insert oli1;
        insert oli2;
        oli1.Linked_Oppty_Product_ID__c = oli2.Id;
        update oli1;
        
        PageReference pageRef = Page.OpportunityProductLinker;
        pageRef.getParameters().put('sourceOppProdId', oli1.Id);
        Test.setCurrentPage(pageRef);
        
        OpportunityProductLinker oppProdLink = new OpportunityProductLinker();
        testOppProds = oppProdLink.getopptyProducts();
        
        System.AssertNotEquals(true, testOppProds.IsEmpty(), 'Additional OLI for linking was not found and returned during test');
        
        // Test unlinking the OLI items now
        oppProdLink.ClearLinkedItem();
        
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
        testOpp = new Opportunity( Name='Test Opp', accountId = acc.Id );
        testOpp.RecordTypeId = rtypes[0].Id;
        testOpp.closeDate = Date.today().addMonths(1);
        testOpp.CurrencyIsoCode = 'USD';       
        testOpp.StageName = '1.Recognize Needs';     
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        testOpp.PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
        testOpp.Direct_Sales__c = true;
        testOpp.PriceBook2Id = pBook[0].Id;
        
        insert testOpp;
        Util.Bypass_Trigger_Chk = false; 
    }  

}