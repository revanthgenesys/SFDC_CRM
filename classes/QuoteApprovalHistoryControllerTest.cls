//Naresh Kumar	10/03/2014
@isTest(seeAllData=true)
private class QuoteApprovalHistoryControllerTest {

    static testMethod void testController() {
        //Account
        Account testAccount = TestCommon.createAccount(true);
        //Country
        Country__c testCountry = new Country__c(Country__c = 'United States A');
        testCountry.DAP_Region__c = 'NA';
        testCountry.Region__c = 'NA';
        testCountry.RU__c = 'NA';        
        insert testCountry;
        //Opportunity
        Opportunity testOpp = TestCommon.createOpportunity(testAccount.id);
        //Country
        testOpp.Country__c = testCountry.id;
        update testOpp;
        //Quote
        BigMachines__Quote__c testQuote = new BigMachines__Quote__c();
        testQuote.BigMachines__Opportunity__c = testOpp.id;
        testQuote.ELA__c = true;
        testQuote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_PENDING;
        insert testQuote;
        QuoteApprovalHistoryController objController = new QuoteApprovalHistoryController();
        objController.quoteId = testQuote.id;
        objController.getApprovals();
        
        Quote_Approval__c testQuoteApproval1 = new Quote_Approval__c(BigMachines_Quote__c = testQuote.id);
        testQuoteApproval1.Status__c = QuoteApprovalUtil.STATUS_PENDING;
        testQuoteApproval1.Approval_Submission_Counter__c = 1;
        testQuoteApproval1.Quote_Approval_Id__c = '111222333';
        insert testQuoteApproval1;
        objController.getApprovals();
        
    }
}