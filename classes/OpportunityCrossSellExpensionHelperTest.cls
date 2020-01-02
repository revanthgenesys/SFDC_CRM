@isTest (seeAllData = true) 
private class OpportunityCrossSellExpensionHelperTest { 
    static testMethod void testOpportunityCrossSellExpensionHelper1(){ 
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAcc.id, true)[0];
        List<BigMachines__Quote__c> testQuotes = TestUtil.createQuotes(2, testOpp.id, true);
        List<BigMachines__Quote_Product__c> testQuoteProduct1 = createQuoteProducts(2, testQuotes[0].id);
        List<BigMachines__Quote_Product__c> testQuoteProduct2 = createQuoteProducts(2, testQuotes[1].id);        
        testQuotes[0].BigMachines__Status__c = 'Quote Approved';
        testQuotes[1].BigMachines__Status__c = 'Quote Approved';
        update testQuotes;
        OpportunityCrossSellExpensionHelper.populateQuoteSCMapping(testQuotes[0].id, true);
        OpportunityCrossSellExpensionHelper.populateQuoteSCMapping(testQuotes[1].id, false);
        
        OpportunityCrossSellExpensionHelperBatch testBatch = new OpportunityCrossSellExpensionHelperBatch('SELECT id FROM BigMachines__Quote__c WHERE id = \'' + testQuotes[0].id + '\'');
        Database.executeBatch(testBatch);         
    }
    /*
    static testMethod void testOpportunityCrossSellExpensionHelper2(){ 
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAcc.id, true)[0];
        List<BigMachines__Quote__c> testQuotes = TestUtil.createQuotes(2, testOpp.id, true);
        List<BigMachines__Quote_Product__c> testQuoteProduct1 = createQuoteProducts(2, testQuotes[0].id);
        List<BigMachines__Quote_Product__c> testQuoteProduct2 = createQuoteProducts(2, testQuotes[1].id);        
        testQuotes[0].BigMachines__Status__c = 'Quote Approved';
        testQuotes[1].BigMachines__Status__c = 'Quote Approved';
        update testQuotes;
        testQuotes[0].BigMachines__Status__c = 'Order Submitted';
        testQuotes[1].BigMachines__Status__c = 'Order Submitted';
        update testQuotes;
        OpportunityCrossSellExpensionHelper.populateQuoteSCMapping(testQuotes[0].id, true);
        OpportunityCrossSellExpensionHelper.populateQuoteSCMapping(testQuotes[1].id, false);         
    }
    */
    private static List<Product2> createProducts(Integer numToInsert){
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        List<Product2> products = new List<Product2>();
        for(Integer i=0; i< numToInsert-1; i++){
            Product2 prod = new Product2();
            prod.Name = 'Test Prod '+ i;
            prod.recordTypeId = rtypes[0].Id;
            prod.Type__c = 'Product';
            prod.Product_Financial__c = 'Test';
            products.add( prod );
        }        
        products.add(new Product2(Name='Test Prod '+ numToInsert, RecordTypeId = rtypes[0].Id, Type__c=ServiceContractUtil.MAINTENANCE, Product_Financial__c = 'Test'));
        insert products;                                             
        return products;    
    }
    
    private static List<BigMachines__Quote_Product__c> createQuoteProducts(Integer numToInsert, Id quoteId){
    
        List<BigMachines__Quote_Product__c>  quoteProducts = new List<BigMachines__Quote_Product__c> ();
        List<Product2> products = createProducts(numToInsert);
        for( Product2 prod : products ){
            BigMachines__Quote_Product__c qp = new BigMachines__Quote_Product__c();
            qp.Product__c = prod.Id;
            qp.BigMachines__Product__c = prod.Id;            
            qp.BigMachines__Quote__c = quoteId;
            qp.BigMachines__Quantity__c = 10;
            qp.BigMachines__Sales_Price__c = 500;
            quoteProducts.add( qp );    
        }
        insert quoteProducts;
        return quoteProducts;
    }
}