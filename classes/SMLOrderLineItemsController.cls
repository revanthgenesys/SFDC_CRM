public without sharing class SMLOrderLineItemsController {

      public List<Order_Line_Item__c > results{get;set;} // results
      public Order__c o {get;set;}

      public SMLOrderLineItemsController(ApexPages.StandardController controller) {
         String OrderID = ApexPages.currentPage().getParameters().get('id');
         o = [SELECT id, Name, Owner.Name, RecordType.Name, End_User_Name__r.Name, Sold_to_Name__r.Name, Comments__c, Direct_Sales__c, Year_Created__c,
              Order_Type__c FROM Order__c WHERE id =:OrderID];
             
         loadCurrentOrderLineItems(o);
      }
      
      private void loadCurrentOrderLineItems(Order__c o) {
        results = [select id, Name, Quantity__c, BigMachines_Quantity__c, Product__c,Product__r.name,
                          Total_Price__c, Extended_Net_Price__c, Ext_Net_Price__c, Release_Version__c,
                          Material_Description__c, Order__c, Ext_List__c, Description__c from Order_Line_Item__c 
                   where ( (Order__c = :o.id ) AND
                           Order__r.Bypass_Entitlements__c != true AND Product__r.Type__c !='Genesys Care' AND Order__r.License_FYM_detail__c != 'Maintenance Only Order' 
                           AND Order__r.Opportunity__r.RecordType.id !='012U0000000M1eQ'
                           AND Product__r.Type__c !='3RD PARTY CD' and Product__r.Type__c !='CD/DVD' 
                         ) order by release_version__c desc nulls last];
      }

}