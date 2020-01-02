//Nik Mills - 18-Apr-2019
//For code coverage and testing of the OpportunityRevProFieldCheckerHandler helper class
//28-Nov-2019 : Nik - Added additional coverage for PCR items and Debook mismatch handling
@IsTest(SeeAllData=true)
public class OpptyRevProFieldCheckerHandler_TEST
{
    static Opportunity testOpp;
    static Opportunity testPCROpp;
    
    static testMethod void testOpptyProdLink_Test1_OppNoProductsMissingPSProjStartDate()
    {
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
        PageReference testPageRefReturn;
       
        createPSOpptyTestData();
        AllOpps.add(testOpp);

        testOpp.PS_Product_Line__c = null;
        update testOpp;
        
        Professional_Services_Project__c psProj = new Professional_Services_Project__c(Opportunity__c=testOpp.Id, Project_Start_Date__c=null);
        insert psProj;
        
        Util.Bypass_Trigger_Chk = true;
          
        Test.StartTest();
        
        OpportunityRevProFieldCheckerHandler.CheckOpportunityRevProFields(allOpps, null);
        
        //System.AssertEquals(true, testOpp.RevPro_Required_Data_Missing__c, 'Test 1 required data missing was not updated');
        
        Test.StopTest();
        Util.Bypass_Trigger_Chk = false;
    }
    
    static testMethod void testOpptyProdLink_Test2_OppWithTandMProductComplete()
    {
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
        PageReference testPageRefReturn;
       
        createPSOpptyTestData();
        AllOpps.add(testOpp);

        List<Pricebook2> pBook = [SELECT Id, Name
                                  FROM Pricebook2
                                  WHERE Name =: 'Professional Services'];

        List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode, Product2.Product_Category__c
                                        FROM PriceBookEntry
                                        WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'GBP' AND Product2.Product_Category__c != 'Expense'];
                     
                                                         
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=200, UnitPrice=40000, Description__c='Test OLI Item 1 - T&M', POB_Type__c = 'PS - T&M',
                                                        Professional_Services_Hours__c=200, Professional_Services_Rate__c=200.00,Professional_Services_Resource_Type__c='Regional', Line_Number__c = 1);
       
        Professional_Services_Project__c psProj = new Professional_Services_Project__c(Opportunity__c=testOpp.Id, Project_Start_Date__c=system.today());
        insert psProj;
       
        Util.Bypass_Trigger_Chk = true;
        Test.StartTest();
        insert oli1;
        testOpp.GeneralComments__c = 'Testing';
        Update testOpp;
        
        Util.Bypass_Trigger_Chk = false;
        
        OpportunityRevProFieldCheckerHandler.CheckOpportunityRevProFields(allOpps, null);
        
        //System.AssertEquals(false, testOpp.RevPro_Required_Data_Missing__c, 'Test 2 Missing data: ' + testOpp.RevPro_Missing_Data_Details__c);
        
        Test.StopTest();
    }
    
    static testMethod void testOpptyProdLink_Test3_OppWithProductsMissingData()
    {
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
        PageReference testPageRefReturn;
       
        createPSOpptyTestData();
        AllOpps.add(testOpp);

        List<Pricebook2> pBook = [SELECT Id, Name
                                  FROM Pricebook2
                                  WHERE Name =: 'Professional Services'];

        List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode, Product2.Product_Category__c
                                        FROM PriceBookEntry
                                        WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'GBP' AND Product2.Product_Category__c != 'Expense'];

        List<PriceBookEntry> pbEntryCustBuild = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode, Product2.Product_Category__c
                                        FROM PriceBookEntry
                                        WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'GBP' AND Product2.Name = 'Professional Services - Custom Build'];

        List<PriceBookEntry> pbEntryEASub = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode, Product2.Product_Category__c
                                        FROM PriceBookEntry
                                        WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'GBP' AND Product2.PS_Expert_Apps_Subscription_Item__c = true];                                                                                
                     
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=200, UnitPrice=40000, POB_Type__c = 'PS - T&M');
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=20000, POB_Type__c = 'PS - Fixed Price Percent Complete');
        OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=2500, POB_Type__c = 'PS - Fixed Fee on Date');
        OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=5500, POB_Type__c = 'PS - Expert App');
        OpportunityLineItem oli5 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=1000, POB_Type__c = 'PS - CAS');
        OpportunityLineItem oli6 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=400, POB_Type__c = 'Error');        
        OpportunityLineItem oli7 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=100);
        OpportunityLineItem oli8 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntryEASub[0].Id, Quantity=1, UnitPrice=100, POB_Type__c = 'PS - Fixed Fee on Date');
        OpportunityLineItem oli9 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntryCustBuild[0].Id, Quantity=1, UnitPrice=100, POB_Type__c = 'PS - Fixed Price Percent Complete');
        OpportunityLineItem oli10 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=1, UnitPrice=-800, POB_Type__c = 'PS - T&M');
       
        Util.Bypass_Trigger_Chk = true;
        Test.StartTest();
        insert oli1;
        insert oli2;
        insert oli3;        
        insert oli4;        
        insert oli5;
        insert oli6;
        insert oli7;
        insert oli8;
        insert oli9;
        insert oli10;

        testOpp.GeneralComments__c = 'Testing';
        Update testOpp;
        
        Util.Bypass_Trigger_Chk = false;
        
        OpportunityRevProFieldCheckerHandler.CheckOpportunityRevProFields(allOpps, null);

        //System.AssertEquals(true, testOpp.RevPro_Required_Data_Missing__c, 'Test 3 required data missing was not updated');
        
        Test.StopTest();
    }    

    static testMethod void testOpptyProdLink_Test4_OppWithCASStandaloneComplete()
    {
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
        PageReference testPageRefReturn;
       
        createPSOpptyTestData();
        AllOpps.add(testOpp);

        List<Pricebook2> pBook = [SELECT Id, Name
                                  FROM Pricebook2
                                  WHERE Name =: 'Professional Services'];

        List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode, Product2.Product_Category__c
                                        FROM PriceBookEntry
                                        WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'GBP' AND Product2.Product_Category__c != 'Expense'];
                     
                                                         
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=200, UnitPrice=40000, Description__c='Test OLI Item 1 - CAS', POB_Type__c = 'PS - CAS',
                                                        Professional_Services_Term_Months__c=12);
       
        Professional_Services_Project__c psProj = new Professional_Services_Project__c(Opportunity__c=testOpp.Id, Project_Start_Date__c=system.today());
        insert psProj;
       
        Util.Bypass_Trigger_Chk = true;
        Test.StartTest();
        insert oli1;
        testOpp.GeneralComments__c = 'Testing';
        Update testOpp;
        
        Util.Bypass_Trigger_Chk = false;
        
        OpportunityRevProFieldCheckerHandler.CheckOpportunityRevProFields(allOpps, null);
        
        //System.AssertEquals(false, testOpp.RevPro_Required_Data_Missing__c, 'Test 2 Missing data: ' + testOpp.RevPro_Missing_Data_Details__c);
        
        Test.StopTest();
    }

    static testMethod void testOpptyProdLink_Test5_OppTandMWithPCRMismatch()
    {
        List<Opportunity> AllOpps = new List<Opportunity>();
        List<OpportunityLineItem> testOppProds;
        PageReference testPageRefReturn;
       
        createPSOpptyTestData();
        AllOpps.add(testOpp);
        
        createPSOpptyPCRTestData();
        testPCROpp.Master_Opportunity__c = testOpp.Id;
        testPCROpp.ParentOpportunity__c = testOpp.Id;
        AllOpps.add(testPCROpp);

        List<Pricebook2> pBook = [SELECT Id, Name
                                  FROM Pricebook2
                                  WHERE Name =: 'Professional Services'];

        List<PriceBookEntry> pbEntry = [SELECT Id, Product2Id, PriceBook2.Name, CurrencyIsoCode, Product2.Product_Category__c
                                        FROM PriceBookEntry
                                        WHERE PriceBook2Id =: pBook[0].Id AND IsActive = true AND CurrencyIsoCode =: 'GBP' AND Product2.Product_Category__c != 'Expense'];
                     
                                                         
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId=testOpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=200, UnitPrice=40000, Description__c='Test OLI Item 1 - T&M', POB_Type__c = 'PS - T&M',
                                                        Professional_Services_Hours__c=200, Professional_Services_Rate__c=200.00,Professional_Services_Resource_Type__c='Regional', Line_Number__c = 1);

        OpportunityLineItem oliPCR1 = new OpportunityLineItem(OpportunityId=testPCROpp.Id, PriceBookEntryId=pbEntry[0].Id, Quantity=100, UnitPrice=25000, Description__c='Test PCR OLI Item 1 - T&M', POB_Type__c = 'PS - T&M',
                                                        Professional_Services_Hours__c=100, Professional_Services_Rate__c=250.00,Professional_Services_Resource_Type__c='Regional', Line_Number__c = 1);

       
        Professional_Services_Project__c psProj = new Professional_Services_Project__c(Opportunity__c=testOpp.Id, Project_Start_Date__c=system.today());
        insert psProj;
       
        Util.Bypass_Trigger_Chk = true;
        Test.StartTest();
        insert oli1;
        testOpp.GeneralComments__c = 'Testing';
        Update testOpp;
        insert oliPCR1;
        Update testPCROpp;
        
        Util.Bypass_Trigger_Chk = false;
        
        OpportunityRevProFieldCheckerHandler.CheckOpportunityRevProFields(allOpps, null);
        
        //System.AssertEquals(false, testOpp.RevPro_Required_Data_Missing__c, 'Test 2 Missing data: ' + testOpp.RevPro_Missing_Data_Details__c);
        
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
        testOpp.CurrencyIsoCode = 'GBP';       
        testOpp.StageName = '6.Closed';     
        testOpp.ForecastStatus__c = '0.Booked';
        testOpp.Win_Loss_Status__c = 'Won';
        testOpp.Competitor__c = 'None - Genesys Customer (add-on)';
        testOpp.WonLostCancelledReason__c = 'Existing Business/Add-on';
        testOpp.WonLostCancelledComments__c = 'This is a test opportunity created as part of the apex test class for the OpportunityRevProFieldCheckerHandler functionality for checking PS RevPro SSP data is present';
        testOpp.Who_won_this_Opportunity__c = 'Other Local Vendor';
        testOpp.ALUProbability__c = '100';
        testOpp.PS_Product_Line__c = 'PureEngage Premise';
        testOpp.PS_Region__c = 'EMEA';
        
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        testOpp.PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
        testOpp.Direct_Sales__c = true;
        testOpp.PriceBook2Id = pBook[0].Id;
        
        insert testOpp;
        
        Util.Bypass_Trigger_Chk = false;
    }  

    // Create a PS Specific standalone test opportunity
    static void createPSOpptyPCRTestData() {
        Util.Bypass_Trigger_Chk = true;
        
        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Opportunity'
            and DeveloperName =: 'Professional_Services'
        ];
        List <Pricebook2> pBook = [SELECT Id, Name
                                                FROM Pricebook2
                                                WHERE Name =: 'Professional Services'];
        
        Account acc = new Account(Name='Test PCR Account Diff', Status__c = 'Active');
        insert acc;
        
        testPCROpp = new Opportunity( Name='Test PCR Opp', accountId = acc.Id );
        testPCROpp.RecordTypeId = rtypes[0].Id;
        testPCROpp.closeDate = Date.today().addMonths(1);
        testPCROpp.CurrencyIsoCode = 'GBP';       
        testPCROpp.StageName = '6.Closed';     
        testPCROpp.ForecastStatus__c = '0.Booked';
        testPCROpp.Win_Loss_Status__c = 'Won';
        testPCROpp.Competitor__c = 'None - Genesys Customer (add-on)';
        testPCROpp.WonLostCancelledReason__c = 'Existing Business/Add-on';
        testPCROpp.WonLostCancelledComments__c = 'This is a test PCR opportunity created as part of the apex test class for the OpportunityRevProFieldCheckerHandler functionality for checking PS RevPro SSP data is present';
        testPCROpp.Who_won_this_Opportunity__c = 'Other Local Vendor';
        testPCROpp.ALUProbability__c = '100';
        testPCROpp.PS_Product_Line__c = 'PureEngage Premise';
        testPCROpp.PS_Region__c = 'EMEA';
        testPCROpp.PS_Subsidiary_Override__c = '8375';
        
        testPCROpp.Lines_of_Businesses__c = 'PureEngage';
        testPCROpp.PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
        testPCROpp.Direct_Sales__c = true;
        testPCROpp.PriceBook2Id = pBook[0].Id;
        
        insert testPCROpp;
        
        Util.Bypass_Trigger_Chk = false;
    }  

}