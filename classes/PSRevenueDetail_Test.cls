//Nik Mills - 24-Apr-2019
//For code coverage and testing of the PS Revenue Details object trigger (linked to PS Opportunities for RevPro)
@IsTest(SeeAllData=true)
public class PSRevenueDetail_Test
{
    static Opportunity testOpp;
    
    static testMethod void TestPSRevenueDetailNoLink()
    {
        List<Opportunity> allOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
        PageReference testPageRefReturn;
       
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
    
        PS_Revenue_Detail__c psRevDets = new PS_Revenue_Detail__c(Opportunity__c=testOpp.Id, Master_Opportunity__c=testOpp.Id, Quantity__c=8,Total_Amount__c=1600,Revenue_Type__c='Time');
    
        Test.StartTest();
        insert oli1;
        insert oli2;

        insert psRevDets;
        
        Test.StopTest();
    }

    static testMethod void TestPSRevenueDetailWithLink()
    {
        List<Opportunity> allOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
        PageReference testPageRefReturn;
       
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
    
        insert oli1;
        insert oli2;    
    
        PS_Revenue_Detail__c psRevDets = new PS_Revenue_Detail__c(Opportunity__c=testOpp.Id, Master_Opportunity__c=testOpp.Id, Quantity__c=8,Total_Amount__c=1600,Revenue_Type__c='Time',Associated_Opportunity_Product_ID__c=oli1.Id);
    
        Test.StartTest();

        insert psRevDets;
        
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