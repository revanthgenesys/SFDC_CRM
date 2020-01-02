@isTest (seeAllData = true)
private class QuoteRevenueMonth_Test {
    static testMethod void testMethod1() {
    	Test.startTest();
        
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, false)[0];
        
        Opportunity testOpp = TestUtil.createOpportunities(1,false)[0];
        testOpp.closeDate = Date.Today();
        insert testOpp;
        
        Opportunity testChildOpp = TestUtil.createOpportunities(1,false)[0];
        testChildOpp.closeDate = Date.Today();
        testChildOpp.ParentOpportunity__c=testOpp.id;
        insert testChildOpp;
        
        
        List<Product2> productTemp = TestUtil.createProducts(1,true);
        List<PricebookEntry> pbTemp =TestUtil.CreatePriceBookEntries(  productTemp, true);
        TestUtil.createOlis( pbTemp, testChildOpp.id, true);
        Test.stopTest();
        
        testQuote.Split_Status__c = false;
        testQuote.BigMachines__Is_Primary__c  = true;
        testQuote.BigMachines__Opportunity__c = testOpp.id;
        insert testQuote;
        
        List<BigMachines__Quote_Product__c> quoteProducts = TestUtil.createQuoteProducts(1, false, testQuote.id);
        quoteProducts[0].Contract_Line_Update_Status__c = 'Split';
        quoteProducts[0].Original_Qty__c = 100;
        quoteProducts[0].Current_Qty__c = 40;
        insert quoteProducts;
        
        
        
        
        //BigMachines__Pricebook_Id__c
       // ApexPages.StandardController stdController = new ApexPages.StandardController(testopp.id);
        Cloud_Billing_Information__c cloudBilling = QuoteRevenueForecastControllerHelper.createCloudBillingRecord(testOpp.id);
        System.debug('cc' + cloudBilling);
        QuoteRevenueForecastControllerHelper.populatePhases(cloudBilling.id, null);
        
        Test.setCurrentPageReference(new PageReference('Page.myPage'));
        System.currentPageReference().getParameters().put('oppId', testOpp.id);
        System.currentPageReference().getParameters().put('mode', 'edit');
        QuoteRevenueMonthForecastController objController = new  QuoteRevenueMonthForecastController();
       
		 
        try{
            //stdController.submit();
        }
        catch(Exception ex){}
    }
}