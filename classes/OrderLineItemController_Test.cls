@isTest(SeeAllData=true)
 public class OrderLineItemController_Test { 
 	
 	// Creating Setup()
    private static Order__c order = null;
    private static Product2 prod = null;
    private static Order_Line_Item__c  oline = null;
    private static Order_Line_Item__c  oline_sec = null;    
    private static Pricebook2 pbook = null; 
    private static PricebookEntry pbebtry = null;
     
    static void setup()
    {     
        Util.Bypass_Trigger_Chk = true;
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
	      oline.Name = '1';
          insert oline;
          
          oline_sec =  new Order_Line_Item__c();
	      oline_sec.Order__c = order.Id;
	      oline_sec.Product__c = prod.Id;
	      oline_sec.Contract_Line_Update_Status__c = '';
	      oline_sec.BigMachines_Quantity__c = 1;
	      oline_sec.Sales_Price__c = 10;
	      oline_sec.Name = '1';
	      
          insert oline_sec;
          
          pbook = [select id from Pricebook2 where id = '01sU0000000IvD2'];
                    
          pbebtry = new PricebookEntry();
		  pbebtry.Pricebook2Id=pbook.id;
		  pbebtry.Product2Id=prod.id;
	      pbebtry.IsActive=true;
		  pbebtry.UnitPrice=99;
		  insert pbebtry;
   }
	
	static testMethod void test_Method_1() {
	    Test.startTest();
        setup();
        // Assigning Paramenters    
        ApexPages.currentPage().getParameters().put('Oid',order.Id);
        ApexPages.currentPage().getParameters().put('Olid',oline.Id);
        ApexPages.currentPage().getParameters().put('pg', 'view');	  

        PageReference pageRef = page.OrderLineItemEdit;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.standardController(oline);                
        OrderLineItemController controller = new OrderLineItemController(sc); 
        controller.orderLineItem = oline;
        controller.ordId = order.id;
        controller.olId = oline.id;
        controller.editFn();
		Test.stopTest();
	  }
	
	static testMethod void test_Method_2() {	
	     Test.startTest();
	     setup();
	     
	     // Assigning Paramenters    
         ApexPages.currentPage().getParameters().put('Olid', oline.Id);
         ApexPages.currentPage().getParameters().put('Oid', order.Id);
         ApexPages.currentPage().getParameters().put('pg', 'new');	    
	      
	     PageReference pageRef = page.OrderLineItemEdit;
         Test.setCurrentPage(pageRef);

         ApexPages.StandardController sc = new ApexPages.standardController(oline);                
         OrderLineItemController controller = new OrderLineItemController(sc); 
         
         controller.orderLineItem = oline;
         controller.ordId = order.id;
         controller.olId = oline.id;
         controller.determineOrderLineItemNameValue();
         controller.saveFn();
         controller.saveNewFn();
         controller.backFn();
         controller.deleteFn();  
         controller.confBoxProceed();
         controller.confBoxCancel();
          controller.setCustomerCareDescription();
	     Test.stopTest();	       
	}
    
     static testMethod void testCustomerCareOrder_New() {
         
	     setup();
         order.NRO_Type__c = 'Customer Care';
         update order;
    
	     Test.startTest(); 
   
	     PageReference pageRef = page.OrderLineItemEdit;
         Test.setCurrentPage(pageRef);
       
         ApexPages.currentPage().getParameters().put('Olid', oline.Id);
         ApexPages.currentPage().getParameters().put('Oid', order.Id);
         ApexPages.currentPage().getParameters().put('pg', 'new');
         
         ApexPages.StandardController sc = new ApexPages.standardController(oline);                
         OrderLineItemController controller = new OrderLineItemController(sc); 
         
         controller.orderLineItem = oline;
         controller.ordId = order.id;
         controller.olId = oline.id;
         controller.isTechSprt = true;
         controller.pg = 'new';
         
         controller.determineOrderLineItemNameValue();
         controller.saveFn();    
	     Test.stopTest();	       
         
     }
     
     static testMethod void testCustomerCareOrder_View() {
         
	     setup();
         order.NRO_Type__c = 'Customer Care';
         update order;
    
	     Test.startTest(); 
   
	     PageReference pageRef = page.OrderLineItemEdit;
         Test.setCurrentPage(pageRef);
       
         ApexPages.currentPage().getParameters().put('Olid', oline.Id);
         ApexPages.currentPage().getParameters().put('Oid', order.Id);
         ApexPages.currentPage().getParameters().put('pg', 'view');
         
         ApexPages.StandardController sc = new ApexPages.standardController(oline);                
         OrderLineItemController controller = new OrderLineItemController(sc); 
         
         controller.orderLineItem = oline;
         controller.ordId = order.id;
         controller.olId = oline.id;
         controller.isTechSprt = true;
         controller.pg = 'view';
         
         controller.determineOrderLineItemNameValue();
         controller.saveFn();    
	     Test.stopTest();
     }
     
     static testMethod void testCustomerCareOrder_Edit() {
         
	     setup();
         order.NRO_Type__c = 'Customer Care';
         update order;
    
	     Test.startTest(); 
   
	     PageReference pageRef = page.OrderLineItemEdit;
         Test.setCurrentPage(pageRef);
       
         ApexPages.currentPage().getParameters().put('Olid', oline.Id);
         ApexPages.currentPage().getParameters().put('Oid', order.Id);
         ApexPages.currentPage().getParameters().put('pg', 'edit');
         
         ApexPages.StandardController sc = new ApexPages.standardController(oline);                
         OrderLineItemController controller = new OrderLineItemController(sc); 
         
         controller.orderLineItem = oline;
         controller.ordId = order.id;
         controller.olId = oline.id;
         controller.isTechSprt = true;
         controller.pg = 'edit';
         
         controller.determineOrderLineItemNameValue();
         controller.saveFn();    
	     Test.stopTest();
     }
             
}