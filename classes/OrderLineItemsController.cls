public with sharing class OrderLineItemsController {

      public List<Order_Line_Item__c > results{get;set;} // results
      public Order__c o {get;set;}
      public Boolean isPPUOrder {get;set;}
      public Boolean isTechSprt {get;set;}
      
      public OrderLineItemsController(ApexPages.StandardController controller) {
        
         //o = (Order__c)controller.getrecord();
         o = [SELECT id, RecordType.DeveloperName, NRO_Type__c FROM Order__c WHERE id =: controller.getId()];
         if(o.RecordType.DeveloperName == 'PPU_Order')
             isPPUOrder = true;
         else
             isPPUOrder = false;  
             
         isTechSprt = (o.NRO_Type__c == 'Customer Care') ? true : false;
         
         loadCurrentOrderLineItems(o);
      }
      
      public PageReference newOrderLineItem() {
           pageReference ref = new PageReference('/apex/OrderLineItemEdit?retURL=' + o.id);
          
            ref.setRedirect(true);
            return ref;

      }
       
      private void loadCurrentOrderLineItems(Order__c o) {
        
        results = [select id, Name, Quantity__c,BigMachines_Quantity__c, Product__c,Product__r.name,Product__r.Product_Manager_Approval_Group__r.name,
                          Product__r.Product_Manager_Approval_Group__c, PM_Approval_Required_Product__c,Material_Description__c, Order__c,
                          Ext_List__c, Description__c, Product_Version1__c, Operating_System__c, Language_lk__c, isVersionUntested__c  
                          from Order_Line_Item__c where Order__c = :o.id ];
        
        
      }

}