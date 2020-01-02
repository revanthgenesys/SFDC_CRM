//Naresh Kumar
@IsTest(SeeAllData=true)
private class UpdateTotalsOnOppFromOppProductTest {
    static testMethod void myUnitTest() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, true)[0];
    	List<Product2> products = TestUtil.createProducts(2, false);
    	products[0].Type__c = 'Cloud';
    	products[1].Type__c = 'Cloud';
    	insert products;
    	List<PricebookEntry> pbes = TestUtil.createPriceBookEntries(products, true);
    	List<OpportunityLineItem> oppLines = TestUtil.createOlis(pbes, testOpp.id, true);
    	
    }
}