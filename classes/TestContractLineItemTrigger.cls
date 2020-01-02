/**
 * Test class for BigMachinesQuote Before and After Trigger
 * Author - Rashmi K (ClearTask) - Mar 27 2013
 */
@isTest(seeAllData=true)
private class TestContractLineItemTrigger {
 /*  Vikram Deploy

    static testMethod void testCreateAssetsAndEntitlements() {
    	RecordType rtype = [Select Id from RecordType where SobjectType='Opportunity' and DeveloperName =:ServiceContractUtil.OPP_GEN_NEW_DEV_NAME];
    	Account testAcc = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAcc.Id, false)[0];
        testOpp.RecordTypeId = rtype.Id;
        insert testOpp;
        
        List<Product2> prods = TestUtil.createProducts(2, true);
        List<PricebookEntry> pbes = TestUtil.createPriceBookEntries(prods, true);
        List<OpportunityLineItem> olis = TestUtil.createOlis(pbes, testOpp.Id, true); 
        BigMachines__Quote__c quote = testUtil.createQuotes(1, testOpp.Id, true)[0];
        Order__c testOrder = TestUtil.createOrders(1, quote.Id, testOpp.Id, true)[0];
        List<Order_Line_Item__c> orderLines = TestUtil.createOrderLines( prods, testOrder.Id, true );
        Test.startTest();
        	testOrder.status__c = 'Approved';
        	testOrder.License_FYM_detail__c = 'Both License & Maintenance Order';	
        	update testOrder;
        Test.stopTest();
        List<Entitlement> entitlements = [ Select Id from Entitlement where AccountId = :testAcc.Id];
        List<Asset> assets = [ Select Id from Asset where AccountId = :testAcc.Id];
        System.assertEquals(1, entitlements.size());
        System.assertEquals(2, assets.size());
    }
 */   
}