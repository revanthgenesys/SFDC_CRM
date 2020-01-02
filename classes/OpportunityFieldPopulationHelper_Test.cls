//Nik Mills - 25-Oct-2018
//For code coverage and testing of the OpportunityFieldPopulationHelper class, used in association with the Opportunity triggers 
@IsTest(SeeAllData=true)
public class OpportunityFieldPopulationHelper_Test {
    static Opportunity testOpp;
    static Opportunity testParentOpp;
    static BigMachines__Quote__c testQuote;
        
    // test populate fields on insert for renewal opportunity
    static testMethod void Test1_TestRenewalOpptyHelpers() {
        createTestRenewalOpptyData();
        List<Opportunity> AllOpps = new List<Opportunity>();
        AllOpps.add(testOpp);
        Test.startTest();         
        ApexPages.StandardController strCtrl = new ApexPages.StandardController(testOpp);
        OpportunityFieldPopulationHelper.populateFieldsOnInsert(AllOpps);
        Test.stopTest();
    }
    
        //Muthu: Added code for UpdateFCCRClosedLost
    
        static testMethod void updateFCCROnClosedLost_Test() {
        createStandardOpptyTestData();
        testOpp.StageName = '6.Closed';
        testOpp.ForecastStatus__c = '0.Booked';
        testOpp.Type = 'New logo';
        testOpp.Win_Loss_Status__c = 'Lost';
        testOpp.WonLostCancelledComments__c = 'Created for Testing and code coverage validation purposes. This is a test only. This is a test only. This is a test only. Please ignore if not cleared from the system';
        testOpp.Buyer_Interview_Confirm_Primary_Contact__c = 'Unable to confirm Primary Contact at this time';
        testOpp.Primary_Solution__c = 'Digital';
        testOpp.Competitor__c = 'None - Green Field';
        testOpp.Primary_Key_Focus_Area__c = 'Revenue';
        List<Opportunity> AllOpps = new List<Opportunity>();
        
        Contact ctc = new contact();
        ctc.AccountId = testOpp.BusinessPartner__r.id;
        ctc.LastName = 'Tester';
        ctc.Function__c = 'Director';
        ctc.Email = 'aaa@bbb.com.xxx';
        ctc.DecisionRole__c = 'Specifier';
        ctc.FirstName = 'Angela';
        Database.insert(ctc);
        testOpp.Associated_Contact_Record_Id__c = ctc.Id;
        testOpp.Contact__c = ctc.Id;
        
        FR_Commitment__c frc = new FR_Commitment__c();
        frc.Commitment_Progress__c='New';
        frc.Opportunity__c = testOpp.Id;
        insert frc;
        
        AllOpps.add(testOpp);
        

        Test.startTest();
        update testOpp;        
        Test.stopTest();
    }

    
    // test standard helper methods
    static testMethod void Test2_TestStandardOpptyHelpers() {
        createStandardOpptyTestData();
        testOpp.StageName = '6.Closed';
        testOpp.ForecastStatus__c = '0.Booked';
        testOpp.Type = 'New logo';
        testOpp.Win_Loss_Status__c = 'Won';
        testOpp.WonLostCancelledComments__c = 'Created for Testing and code coverage validation purposes. This is a test only. This is a test only. This is a test only. Please ignore if not cleared from the system';
        testOpp.Buyer_Interview_Confirm_Primary_Contact__c = 'Unable to confirm Primary Contact at this time';
        testOpp.Primary_Solution__c = 'Digital';
        testOpp.Competitor__c = 'None - Green Field';
        testOpp.Primary_Key_Focus_Area__c = 'Customer Experience';
        List<Opportunity> AllOpps = new List<Opportunity>();
        
        Contact ctc = new contact();
        ctc.AccountId = testOpp.BusinessPartner__r.id;
        ctc.LastName = 'Tester';
        ctc.Function__c = 'Director';
        ctc.Email = 'aaa@bbb.com.xxx';
        ctc.DecisionRole__c = 'Specifier';
        ctc.FirstName = 'Angela';
        Database.insert(ctc);
        testOpp.Associated_Contact_Record_Id__c = ctc.Id;
        testOpp.Contact__c = ctc.Id;
        
        AllOpps.add(testOpp);
        

        Test.startTest();
        update testOpp;         
        ApexPages.StandardController strCtrl = new ApexPages.StandardController(testOpp);
        OpportunityFieldPopulationHelper.createContactRole(AllOpps);
        //OpportunityFieldPopulationHelper.updateOpportunityTypeOnNewLogoCloseWon(AllOpps, null);
        Test.stopTest();
    }

    // test additional standard opportunity helpers
    static testMethod void Test3_TestAdditionalOpptyHelpers() {
        createStandardOpptyTestData();
        
        List<Opportunity> AllOpps = new List<Opportunity>();
        AllOpps.add(testOpp);

        Test.startTest();         
        ApexPages.StandardController strCtrl = new ApexPages.StandardController(testOpp);
        testOpp.Forecast_Opportunity__c = true;
        update testOpp;
        Test.stopTest();
    }

    // test additional standard opportunity helpers, including quote sharing
    static testMethod void Test4_TestOpptyQuoteHelpers() {
        createOpptyWithQuoteTestData();
        User newOwner = TestUtil.createUsers(1, true)[0];
        
        List<Opportunity> AllOpps = new List<Opportunity>();
        
        AllOpps.add(testOpp);

        Test.startTest();         
        ApexPages.StandardController strCtrl = new ApexPages.StandardController(testOpp);
        OpportunityQuotes objController = new OpportunityQuotes(strCtrl); 
        
        testOpp.Forecast_Opportunity__c = true;
        testOpp.OwnerID = newOwner.Id;
        update testOpp;
        Test.stopTest();
    }

    // test PS/GU related helper methods
    static testMethod void Test5_TestStandalonePSOpptyHelpers() {
        createPSOpptyTestData();
        
        List<Opportunity> AllOpps = new List<Opportunity>();
        AllOpps.add(testOpp);

        Test.startTest();         
        ApexPages.StandardController strCtrl = new ApexPages.StandardController(testOpp);
        OpportunityFieldPopulationHelper.populateParentOppDetails(AllOpps, null);
        Test.stopTest();
    }

    // test PS/GU related helper methods
    static testMethod void Test6_TestIndirectPSOpptyHelpers() {
        createIndirectPSOpptyTestData();
        Account newPartner = TestUtil.createAccounts(1, true)[0];
        
        List<Opportunity> AllOpps = new List<Opportunity>();
        AllOpps.add(testOpp);

        Test.startTest();         
        ApexPages.StandardController strCtrl = new ApexPages.StandardController(testOpp);
        OpportunityFieldPopulationHelper.populateParentOppDetails(AllOpps, null);
        
        // Now test changing the business partner record
        testOpp.BusinessPartner__c = newPartner.Id;
        testOpp.Sold_To_Country__c = null;
        update testOpp;
        
        // Now test changing back to a direct opportunity
        testOpp.Direct_Sales__c = true;
        update testOpp;
        
        Test.stopTest();
    }

    // test PS/GU related helper methods
    static testMethod void Test7_TestLinkedPSOpptyHelpers() {
        createLinkedPSOpptyTestData();
        
        List<Opportunity> AllOpps = new List<Opportunity>();
        AllOpps.add(testOpp);

        Test.startTest();         
        ApexPages.StandardController strCtrl = new ApexPages.StandardController(testOpp);
        OpportunityFieldPopulationHelper.populateParentOppDetails(AllOpps, null);
        Test.stopTest();
    }

    // test PS/GU related helper methods
    static testMethod void Test8_TestEMEA_UK_PSOpptyHelpers() {
        createEMEA_UK_PSOpptyTestData();
        
        List<Opportunity> AllOpps = new List<Opportunity>();
        AllOpps.add(testOpp);

        Test.startTest();         
        ApexPages.StandardController strCtrl = new ApexPages.StandardController(testOpp);
        OpportunityFieldPopulationHelper.populateParentOppDetails(AllOpps, null);
        Test.stopTest();
    }    
    
    
    // test Gainsight relationship updates
    static testMethod void Test9_TestGainsightRelationshipUpdates(){
    
        Util.Bypass_Trigger_Chk = true;
        createStandardOpptyTestData();
        List<Opportunity> AllOpps = new List<Opportunity>();
        AllOpps.add(testOpp);

        Test.startTest();
        testOpp.Primary_Line_of_Business__c = 'Cloud';
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        update testOpp;
        OpportunityFieldPopulationHelper.updateGainsightRelation(AllOpps);

        testOpp.Primary_Line_of_Business__c = 'Cloud';
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        testOpp.Primary_Solution__c = 'Digital';
        update testOpp;
        OpportunityFieldPopulationHelper.updateGainsightRelation(AllOpps);

        testOpp.Primary_Solution__c = 'Outbound';
        update testOpp;
        OpportunityFieldPopulationHelper.updateGainsightRelation(AllOpps);
        
        testOpp.Primary_Line_of_Business__c = 'On Premise';
        testOpp.Lines_of_Businesses__c = 'Premier Edition';
        update testOpp;
        OpportunityFieldPopulationHelper.updateGainsightRelation(AllOpps);

        testOpp.Primary_Line_of_Business__c = 'On Premise';
        testOpp.Lines_of_Businesses__c = 'PureCloud';
        update testOpp;
        OpportunityFieldPopulationHelper.updateGainsightRelation(AllOpps);

        testOpp.Primary_Line_of_Business__c = 'Cloud';
        testOpp.Lines_of_Businesses__c = 'PureConnect';
        update testOpp;
        OpportunityFieldPopulationHelper.updateGainsightRelation(AllOpps);

        testOpp.Primary_Line_of_Business__c = 'On Premise';
        testOpp.Lines_of_Businesses__c = 'PureConnect';
        update testOpp;
        OpportunityFieldPopulationHelper.updateGainsightRelation(AllOpps);
        
        testOpp.Primary_Line_of_Business__c = 'On Premise';
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        update testOpp;
        OpportunityFieldPopulationHelper.updateGainsightRelation(AllOpps);
        
        Test.stopTest();
        Util.Bypass_Trigger_Chk = false;
    }

    //Create a standard test opportunity
    static void createStandardOpptyTestData() {
        Util.Bypass_Trigger_Chk = true;
        testOpp = TestUtil.createOpportunities(1, false)[0];
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        insert testOpp;
       
        Util.Bypass_Trigger_Chk = false;
    }  

    //Create a standard test opportunity
    static void createOpptyWithQuoteTestData() {
        Util.Bypass_Trigger_Chk = true;
        testOpp = TestUtil.createOpportunities(1, false)[0];
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        
        // now create associated quote data
        testQuote = TestUtil.createQuotes(1, false)[0];
        testQuote.BigMachines__Opportunity__c = testOpp.id;
        
        insert testOpp;
        insert testQuote;
       
        Util.Bypass_Trigger_Chk = false;
    }
    
    // Create a PS Specific standalone test opportunity
    static void createPSOpptyTestData() {
        Util.Bypass_Trigger_Chk = true;
        
        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Opportunity'
            and DeveloperName =: 'Professional_Services'
        ];
        
        Account acc = TestUtil.createAccounts(1, true)[0];
        testOpp = new Opportunity( Name='Test Opp', accountId = acc.Id );
        testOpp.RecordTypeId = rtypes[0].Id;
        testOpp.closeDate = Date.today().addMonths(1);
        testOpp.CurrencyIsoCode = 'USD';       
        testOpp.StageName = '1.Recognize Needs';     
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        testOpp.PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
        testOpp.Direct_Sales__c = true;
        
        insert testOpp;
        Util.Bypass_Trigger_Chk = false; 
    }  

    // Create a PS Specific standalone test opportunity
    static void createIndirectPSOpptyTestData() {
        Util.Bypass_Trigger_Chk = true;
        
        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Opportunity'
            and DeveloperName =: 'Professional_Services'
        ];
        
        Account acc = TestUtil.createAccounts(1, true)[0];
        Account partner = TestUtil.createAccounts(1, true)[0];
        testOpp = new Opportunity( Name='Test Opp', accountId = acc.Id );
        testOpp.RecordTypeId = rtypes[0].Id;
        testOpp.closeDate = Date.today().addMonths(1);
        testOpp.CurrencyIsoCode = 'USD';       
        testOpp.StageName = '1.Recognize Needs';     
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        testOpp.PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
        testOpp.Direct_Sales__c = false;
        testOpp.BusinessPartner__c = partner.Id;
        
        insert testOpp;
        Util.Bypass_Trigger_Chk = false; 
    }  


    // Create a PS Specific standalone test opportunity
    static void createEMEA_UK_PSOpptyTestData() {
        Util.Bypass_Trigger_Chk = true;
        
        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Opportunity'
            and DeveloperName =: 'Professional_Services'
        ];
        
        Account acc = TestUtil.createAccounts(1, true)[0];
        acc.Country__c = 'a06U0000000ugdx'; // United Kingdom for specific UK/EMEA PS Oppty testing for subsidiary overrides
        update acc;
        
        testOpp = new Opportunity( Name='Test Opp', accountId = acc.Id );
        testOpp.RecordTypeId = rtypes[0].Id;
        testOpp.closeDate = Date.today().addMonths(1);
        testOpp.CurrencyIsoCode = 'GBP';       
        testOpp.StageName = '1.Recognize Needs';     
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        testOpp.PS_Parent_Opp_Not_Linked_Reason__c = 'Other';
        testOpp.Direct_Sales__c = true;
        
        insert testOpp;
        Util.Bypass_Trigger_Chk = false; 
    }

    // Create a PS Specific linked test opportunity
    static void createLinkedPSOpptyTestData() {
        Util.Bypass_Trigger_Chk = true;
        
        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Opportunity'
            and DeveloperName =: 'Professional_Services'
        ];
        
        Account acc = TestUtil.createAccounts(1, true)[0];
        testParentOpp = new Opportunity( Name='Test Parent opp', accountId = acc.Id );
        testParentOpp.closeDate = Date.today().addMonths(1);
        testParentOpp.CurrencyIsoCode = 'USD';       
        testParentOpp.StageName = '1.Recognize Needs';
        testParentOpp.Direct_Sales__c = true;     
        testParentOpp.Lines_of_Businesses__c = 'PureEngage';
        
        insert testParentOpp;
        
        testOpp = new Opportunity( Name='Test Opp', accountId = acc.Id );
        testOpp.RecordTypeId = rtypes[0].Id;
        testOpp.closeDate = Date.today().addMonths(1);
        testOpp.CurrencyIsoCode = 'USD';       
        testOpp.StageName = '1.Recognize Needs';     
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        testOpp.ParentOpportunity__c = testParentOpp.Id;
        testOpp.Direct_Sales__c = true;
        
        insert testOpp;
        Util.Bypass_Trigger_Chk = false;
    }  

    
    // Create a specific opportunity that is a renewal type for testing
    static void createTestRenewalOpptyData() {
        Util.Bypass_Trigger_Chk = true;
        
        List < RecordType > rtypes = [Select Id from RecordType where SobjectType = 'Opportunity'
            and DeveloperName =: ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME
        ];
        
        Account acc = TestUtil.createAccounts(1, true)[0];
        testOpp = new Opportunity( Name='Test Opp', accountId = acc.Id );
        testOpp.RecordTypeId = rtypes[0].Id;
        testOpp.closeDate = Date.today().addMonths(1);
        testOpp.CurrencyIsoCode = 'USD';       
        testOpp.StageName = '1.Recognize Needs';     
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        
        insert testOpp;
        Util.Bypass_Trigger_Chk = false;
    }  

         
}