//Naresh Kumar	01/14/2017
@isTest(seeAllData=true)
public class CreateQuoteExcelControllerTest {
	
    static testMethod void testCreateQuoteExcelController(){        
        Account testAccount = TestUtil.createAccounts(1, true)[0];        
    	Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, true)[0];
        BigMachines__Quote__c objQuote = TestUtil.createQuotes(1, testOpp.id, true)[0];
        ApexPages.currentPage().getParameters().put('id', objQuote.id);
        CreateQuoteExcelController objController = new CreateQuoteExcelController();        
    }
}