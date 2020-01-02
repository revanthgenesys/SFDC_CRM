//Nik Mills - 24-Apr-2019
//For code coverage and testing of the OpportunityProductLineAssignment helper class
@IsTest(SeeAllData=true)
public class OpportunityProductLineAssignment_Test
{
    static Opportunity testOpp;
    
    static testMethod void TestOpptyProdLineNumberAssign()
    {
        List<Opportunity> allOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds = new List<OpportunityLineItem>();
       
        createPSOpptyTestData();
        allOpps.add(testOpp);

        List<Pricebook2> pBook = [SELECT Id, Name
                                  FROM Pricebook2
                                  WHERE Name =: 'Professional Services'];

        List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode
                                        FROM PriceBookEntry
                                        WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'USD'];
                                                         
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=4000, Description__c='Test OLI Item 1');
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=2500, Description__c='Test OLI Item 2');
    
        testOppProds.add(oli1);
        testOppProds.add(oli2);
    
        Util.Bypass_Trigger_Chk = true;
        insert oli1;
        insert oli2;
        Util.Bypass_Trigger_Chk = false;
    
        Test.StartTest();

        OpportunityProductLineAssignment.AssignProductLineNumbers(testOppProds, null);
        
        System.AssertNotEquals(testOppProds[0].Line_Number__c, null, 'Line number not set');
               
        Test.StopTest();
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