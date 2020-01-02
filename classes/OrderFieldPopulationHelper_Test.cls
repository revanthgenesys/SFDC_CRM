//Naresh Kumar  09/14/2017
@isTest(seeAllData=true)
private class OrderFieldPopulationHelper_Test {
    
    static testMethod void testOrderFieldPopulationHelper(){
        
        Account testAccount = TestUtil.createAccounts(1, true)[0];        
        
        Order__c testOrder = TestUtil.createOrders(1, false)[0];    
        testOrder.End_User_Name__c = testAccount.id;
        insert testOrder;
        
        Product2 testProduct = TestUtil.createProducts(1, false)[0];
        testProduct.Type__c = 'GU';
        insert testProduct;
        Test.startTest();
        List<Product2> list_ofProduct2 = new List<Product2>();
        list_ofProduct2.add(testProduct);
        
        Order_Line_Item__c testOLI = TestUtil.createOrderLines(list_ofProduct2, testOrder.id, false)[0];
        insert testOLI;
        Test.stopTest();
    }
    
    static testMethod void testPopulateCurrnecyRateLookup(){
        ERP_Currency_Daily_Exchange_Rate__c testRate = new ERP_Currency_Daily_Exchange_Rate__c();
        testRate.Effective_Date__c = System.today().addDays(-1);
        testRate.FROM_CURRENCY_CODE__c = 'CAD';
        testRate.TO_CURRENCY_CODE__c = 'USD';
        Util.Bypass_Trigger_Chk = true;
        insert testRate;
        Util.Bypass_Trigger_Chk = false;
        
        Account testAccount = TestUtil.createAccounts(1, true)[0];        
        Opportunity testOpportunity = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpportunity.CloseDate = System.today().addYears(1);
        testOpportunity.CurrencyIsoCode = 'CAD';
        insert testOpportunity;
        
        Order__c testOrder = TestUtil.createOrders(1, false)[0];    
        testOrder.End_User_Name__c = testAccount.id;
        testOrder.Status__c = 'In Progress';
        testOrder.CurrencyIsoCode = 'CAD';
        testOrder.Invoice_Date__c = System.today();
        testOrder.Opportunity__c = testOpportunity.id;
        insert testOrder;
        
        Test.startTest();
        //testOrder.Status__c = 'Approved';
        //update testOrder;
        testOrder.Status__c = 'Completed';
        TriggerFlowManager.ORDER_BEFORE_UPDATE_TRIGGER = true;
        update testOrder;
        Test.stopTest();
       
    }
    
}