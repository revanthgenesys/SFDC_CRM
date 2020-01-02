@isTest(SeeAllData=true)
private class OrderLineItemsController_Test {
  
  	// Creating Setup()
    private static Order__c order = null;
    private static Product2 prod = null;
    private static Order_Line_Item__c  oline = null;
    private static Order_Line_Item__c  oline_sec = null;    
    private static Pricebook2 pbook = null; 
    private static PricebookEntry pbebtry = null;
    
    static void setup()
    {     
    	  order =  new Order__c();
	      order.Maintenance_Start__c = Date.today();
	      order.Maintenance_End__c = Date.today().addYears(1);
	      order.Numb_of_Maint_Months__c = 12;
	      order.status__c = 'In Progress';
	      order.Approved_By_Manager__c = false;
	      order.RecordTypeId = '012U0000000M2Tw';
	      insert order;
	      
	      prod = new Product2();
	      List<RecordType> rtypes = [Select Id from RecordType where SobjectType = 'Product2' and DeveloperName= 'COREProductRecordType'];
          prod.Name = 'Test Prod';
          prod.recordTypeId = rtypes[0].Id;
          prod.Type__c = 'Product';
          insert prod;
          	      
          oline =  new Order_Line_Item__c();
	      oline.Order__c = order.Id;
	      oline.Product__c = prod.Id;
	      oline.Contract_Line_Update_Status__c = '';
	      oline.BigMachines_Quantity__c = 1;
	      oline.Sales_Price__c = 10;
          insert oline;
          
          oline_sec =  new Order_Line_Item__c();
	      oline_sec.Order__c = order.Id;
	      oline_sec.Product__c = prod.Id;
	      oline_sec.Contract_Line_Update_Status__c = '';
	      oline_sec.BigMachines_Quantity__c = 1;
	      oline_sec.Sales_Price__c = 10;
          insert oline_sec;
          
          pbook = [select id from Pricebook2 where id = '01sU0000000IvD2'];
                    
          pbebtry = new PricebookEntry();
		  pbebtry.Pricebook2Id=pbook.id;
		  pbebtry.Product2Id=prod.id;
	      pbebtry.IsActive=true;
		  pbebtry.UnitPrice=99;
		  insert pbebtry;
   }
	
	static testMethod void test_loadCurrentOrderLineItems() {
		
		Test.startTest();
		setup();
		PageReference pageRef = page.OrderLineItems;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.standardController(order);                
        OrderLineItemsController controller = new OrderLineItemsController(sc); 
        controller.o = order;
        controller.newOrderLineItem();
        controller.results = [Select id from Order_Line_Item__c where Order__c = :order.id];
        Test.stopTest();
	
	}
	
	
 /*	static testMethod void test_loadCurrentOrderLineItems() {
		List<Order__c> testOrderLines = [Select o.Order__c, o.Id From Order__c o limit 1];
		for (Order__c testOrder: testOrderLines) {
			ApexPages.StandardController controller = new ApexPages.StandardController(testOrder);
			OrderLineItemsController orderLineItemsController = new OrderLineItemsController(controller);
			orderLineItemsController.newOrderLineItem();
		}
	}
   */
}