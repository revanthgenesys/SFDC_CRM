//Naresh Kumar
@IsTest(SeeAllData=true)
private class CloudQuoteUtilTest {
	static testMethod void myUnitTest() {
		Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
    	testOpp.Quote_Category__c = 'Cloud';    	    	
        insert testOpp;
        List<RecordType> rType = [SELECT id FROM RecordType WHERE SObjectType = 'BigMachines__Quote__c' AND DeveloperName = 'Cloud_Quote'];       
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, false)[0];
        testQuote.BigMachines__Status__c = 'In Progress';
        testQuote.RecordTypeId = rType[0].id;
        insert testQuote;
        List<Product2> products = TestUtil.createProducts(2, false);
    	products[0].Type__c = 'Cloud';
    	products[1].Type__c = 'Cloud';
    	insert products;
    	List<PricebookEntry> pbes = TestUtil.createPriceBookEntries(products, true);
    	Pricebook2 standardPB = [select id from Pricebook2 where isstandard=true LIMIT 1];
    	testOpp.Pricebook2Id = standardPB.id;
    	update testOpp;
    	List<BigMachines__Quote_Product__c> quoteProducts = TestUtil.createQuoteProducts(products, false);    	
    	quoteProducts[0].BigMachines__Quote__c = testQuote.id;
    	quoteProducts[1].BigMachines__Quote__c = testQuote.id;
    	insert quoteProducts;
    	
    	testQuote.BigMachines__Status__c = 'Quote Approved';
    	update testQuote;
    	Set<Id> quoteIds = new Set<Id>();
    	quoteIds.add(testQuote.id);
    	CloudQuoteUtil.createServiceContract(quoteIds);    	
	}
	
	static testMethod void myUnitTest1() {
		Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
    	testOpp.Quote_Category__c = 'Cloud';    	    	
        insert testOpp;
        List<RecordType> rType = [SELECT id FROM RecordType WHERE SObjectType = 'BigMachines__Quote__c' AND DeveloperName = 'Cloud_Quote'];       
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, false)[0];
        testQuote.BigMachines__Status__c = 'In Progress';
        testQuote.RecordTypeId = rType[0].id;
        insert testQuote;
        List<Product2> products = TestUtil.createProducts(2, false);
    	products[0].Type__c = 'Cloud';
    	products[1].Type__c = 'Cloud';
    	insert products;
    	List<PricebookEntry> pbes = TestUtil.createPriceBookEntries(products, true);
    	Pricebook2 standardPB = [select id from Pricebook2 where isstandard=true LIMIT 1];
    	testOpp.Pricebook2Id = standardPB.id;
    	update testOpp;
    	List<BigMachines__Quote_Product__c> quoteProducts = TestUtil.createQuoteProducts(products, false);    	
    	quoteProducts[0].BigMachines__Quote__c = testQuote.id;
    	quoteProducts[1].BigMachines__Quote__c = testQuote.id;
    	insert quoteProducts;
    	
    	testQuote.BigMachines__Status__c = 'Quote Approved';
    	update testQuote;
    	testOpp.StageName = '6.Closed';
    	testOpp.Win_Loss_Status__c = 'Won';
    	testOpp.Direct_Sales__c = true;
    	update testOpp;
    	
    	 	
	}
}