@isTest(SeeAllData=true)
private class NonRevenueOrderHandler_Test {
	
	static testMethod void testAllMethod(){
		Order__c newOrder = createOrder();
		Order_Line_Item__c newOrderLineItem = createOrderLineItem(newOrder);
		newOrder.Status__c = 'Approved';
		update newOrder;
	}
	
	static Order__c createOrder(){
		List<RecordType> nonRevOrderRecordType = [SELECT id FROM RecordType WHERE DeveloperName =: OrderUtil.NON_REVENUE_ORDER
			AND SobjectType = 'Order__c'];
		Order__c newOrder = new Order__c();
        newOrder.Name = '12345 Test';
       	newOrder.Maintenance_Start__c = Date.today();
        newOrder.Maintenance_End__c = Date.today().addYears(1);
        newOrder.Numb_of_Maint_Months__c = 12;
        newOrder.Status__c = 'Order Submitted';
        if(!nonRevOrderRecordType.isEmpty())
        	newOrder.recordTypeId = nonRevOrderRecordType[0].id;
        insert newOrder; 
        return newOrder;
	}
	
	static Order_Line_Item__c createOrderLineItem(Order__c newOrder){
		Product2 newProduct = new Product2();
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
        newProduct.Name = 'Test Prod';
        newProduct.recordTypeId = rtypes[0].Id;
        newProduct.Type__c = 'Product';
        insert newProduct;
        
        List<Product2> newProductList = new List<Product2>();
        newProductList.add(newProduct);        
        TestUtil.createPriceBookEntries(newProductList, true, 'USD');
          
        Order_Line_Item__c newOrderLineItem =  new Order_Line_Item__c();
        newOrderLineItem.Order__c = newOrder.id;
        newOrderLineItem.Product__c = newProduct.id;
        newOrderLineItem.Contract_Line_Update_Status__c = '';
        newOrderLineItem.BigMachines_Quantity__c = 1;
        newOrderLineItem.Sales_Price__c = 10;
        newOrderLineItem.CurrencyIsoCode = 'USD';
        insert newOrderLineItem;
        return newOrderLineItem;
	}
}