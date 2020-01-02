//Naresh Kumar  07/13/2017
@IsTest(SeeAllData=true)
public class OpportunityQuotes_Test {
    static Opportunity testOpp;
    static BigMachines__Quote__c testQuote;
    static zqu__Quote__c testZuoraQuote;
    static testMethod void testMethod1() {
        createTestData();
        Test.startTest();         
        ApexPages.StandardController strCtrl = new ApexPages.StandardController(testOpp);
        OpportunityQuotes objController = new OpportunityQuotes(strCtrl);   
        objController.list_OfQuotes[0].blnIsPrimary = true;
        objController.updateQuote();
        objController.strQuoteIdToBeDeleted = objController.list_OfQuotes[0].strQuoteId;
        objController.blnIsBMQuote = true;
        objController.deleteQuote();
        Test.stopTest();
    }
    
    static testMethod void testMethod2() {
        createTestData();
        testOpp.Lines_of_Businesses__c = 'PureEngage';
        update testOpp;
        Test.startTest();         
        ApexPages.StandardController strCtrl = new ApexPages.StandardController(testOpp);
        OpportunityQuotes objController = new OpportunityQuotes(strCtrl); 
        Test.stopTest();
    }
    
    
    static void createTestData() {
        Util.Bypass_Trigger_Chk = true;
        testOpp = TestUtil.createOpportunities(1, false)[0];
        testOpp.Partner_Opportunity_Status__c = 'Approved';
        testOpp.Lines_of_Businesses__c = 'PureConnect';
        insert testOpp;
        
        testQuote = TestUtil.createQuotes(1, false)[0];
        testQuote.BigMachines__Opportunity__c = testOpp.id;
        insert testQuote;        
    }  
    
    // Added by Vijay  - Jul 29th 2017 - Start
    static testmethod void testMethod3(){
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
    
        Test.startTest();         
        ApexPages.StandardController strCtrl = new ApexPages.StandardController(list_NewOpps[0]);
        OpportunityQuotes objController = new OpportunityQuotes(strCtrl);   
        objController.list_OfQuotes[0].blnIsPrimary = true;
        objController.updateQuote();
    }        
}