@isTest(SeeAllData=true)
private class OrderUtil_test {
    
    static testMethod void OrderUtil_TestMethod() {   
      
        Opportunity testOpp = TestUtil.createOpportunities(1, false)[0];
        testOpp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GEN - Opportunity Record Type').getRecordTypeId();
    testOpp.Gainsight_Relationship_Type__c = 'test it';
        insert testOpp;
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];   
        Test.startTest();
        List<Order__c> ordList = new List<Order__c>();    
        Order__c ord_1 = new Order__c();
        ord_1.Maintenance_Start__c = Date.today();
        ord_1.Maintenance_End__c = Date.today().addYears(1);
        ord_1.Numb_of_Maint_Months__c = 12;
        ord_1.status__c = 'In Progress';
        ord_1.Opportunity__c = testOpp.id;
        ord_1.Quote__c = testQuote.id;
      Id recordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Cloud Billing Master Order').getRecordTypeId();
    ord_1.RecordTypeId = recordTypeId; 
        insert ord_1;
        ordList.add(ord_1);

        Order__c ord_2 = new Order__c(Id=ord_1.id);
        ord_2.Subsidaries__c = 'a24U00000004Xlg';
        ord_2.status__c = 'Approved';
        update ord_2;

        Map<Id, Order__c> oldMap= new Map<Id, Order__c>{ord_1.Id => ord_1};
        Map<Id,Order__c> newMap= new Map<Id,Order__c>{ord_2.Id => ord_2};     

        /*Product2 prod = new Product2();
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        prod.Name = 'Test Prod';
        prod.recordTypeId = rtypes[0].Id;
        prod.Type__c = 'Product';
        insert prod;*/
        
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        Product2 objTestProd1 = new Product2();
        objTestProd1.Name='Test Prod1';
        objTestProd1.recordTypeId = rtypes[0].Id;
        objTestProd1.Type__c = 'Token';
        objTestProd1.End_of_Support__c = String.valueOf(Date.today());
        objTestProd1.IsActive = true;
        objTestProd1.Description = 'test 1';
        objTestProd1.OfferingType__c = 'PureSuccess';
        objTestProd1.APN_Number__c = 'Tokens1';
        objTestProd1.zqu__SKU__c = 'testAshosh';
        insert objTestProd1;
    
    List<Product2> list_Prods = new List<Product2>();
    list_Prods.add(objTestProd1);
        BigMachines__Quote_Product__c testQP = TestUtil.createQuoteProducts(1, true,String.valueof(testQuote.Id))[0]; 
    testQuote.Order__c = ord_1.Id;
    update testQuote;

        List<Order_Line_Item__c> OlList = new List<Order_Line_Item__c>();
        Order_Line_Item__c oline =  new Order_Line_Item__c();
        oline.Order__c = ord_1.Id;
        oline.Product__c = objTestProd1.Id;
        oline.Contract_Line_Update_Status__c = '';
        oline.BigMachines_Quantity__c = 1;
        oline.Sales_Price__c = 10;
        insert oline;
        OlList.add(oline);

        Order_Line_Item__c oline_sec =  new Order_Line_Item__c();
        oline_sec.Order__c = ord_1.Id;
        oline_sec.Product__c = objTestProd1.Id;
        oline_sec.Contract_Line_Update_Status__c = '';
        oline_sec.BigMachines_Quantity__c = 1;
        oline_sec.Sales_Price__c = 10;
        insert oline_sec; 
        OlList.add(oline_sec);

        date dte = Date.today();
        date newdte = dte.addDays(10);
            
        OrderUtil.populateOppFieldsOnOrders(ordList);   
        OrderUtil.populateQuoteFieldsOnOrders(ordList);
    OrderUtil.populateGainsightOnOrder(ordList);
        OrderUtil.populateOrderDates(OlList);
    OrderUtil.populateInfoOnOrderLines(OlList);
    OrderUtil.populateQuoteLineFields(oldMap,OlList);
        OrderUtil.getName('test');
        OrderUtil.isNonRevenueOrder(ordList);
        OrderUtil.populatesFieldsOnOrderLineItems(newmap,oldMap);
        OrderUtil.sendAcknowledgeEmail(newmap,oldMap);
        OrderUtil.calculateLineItemName(OlList);
        OrderUtil.updateOrderStatus(ord_1.id,oline.id);
        OrderUtil.updatePMApprovalStatus(ordList);
        OrderUtil.validateLineItemProducts(OlList);      
        OrderUtil.adjustDatetoStartofMonth(dte);
        OrderUtil.adjustDatetoStartofMonth(newdte);
        OrderUtil.calculateSubscriptionOrderLineDates(System.today(), System.today().addYears(1), 12, 1);
        Test.stopTest();
    }
}