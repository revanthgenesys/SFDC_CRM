@isTest
private class ProductPriceReportController_Test{
    static testMethod void testReport(){
        List<Product2> list_ProductsToInsert = new List<Product2>();
        
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name = 'Test Prod1';            
        objTestProd1.Type__c = 'Token';
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureCloud';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'test1';
        objTestProd1.Price_Type__c = 'Rate Plan';
        objTestProd1.Sub_Category__c = 'Test';
        list_ProductsToInsert.add(objTestProd1);  
        
        Product2 objTestProd = new Product2();
        objTestProd.Name = 'Test Prod';            
        objTestProd.Type__c = 'Token';
        objTestProd.IsActive = true;
        objTestProd.Description = 'test 21';
        objTestProd.OfferingType__c = 'PureCloud';
        objTestProd.APN_Number__c = 'Tokens';
        objTestProd.zqu__SKU__c = 'test2';        
        objTestProd.Price_Type__c = 'Fixed Price';
        objTestProd.Sub_Category__c = 'Test';
        list_ProductsToInsert.add(objTestProd); 
        
        Test.startTest();
        insert list_ProductsToInsert;
        Product_Tier_Pricing__c prodPrice = new Product_Tier_Pricing__c();
        prodPrice.Product__c = list_ProductsToInsert.get(0).Id;
        prodPrice.Charge_Type__c = 'Annual M2M';
        insert prodPrice;
        
        ProductPriceReportController contrlr = new ProductPriceReportController();
        Test.stopTest();
    }
}