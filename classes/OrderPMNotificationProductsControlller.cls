//Naresh Kumar  04/23/2015
public without sharing class OrderPMNotificationProductsControlller {
  public Id orderId {get; set;}
  public String shipAppStatus {get;set;}
  public Boolean showProduct {get;set;}
    public List<Order_Line_Item__c> getProducts() {
      List<Order_Line_Item__c> orderLines; 
      if(orderId != null){
        if(shipAppStatus == 'Order Lines'){
          orderLines = [SELECT Name, Product__r.Name, Product__r.Description__c, BigMachines_Quantity__c, 
            Acknowledge_Text__c, List_Price__c, Product__r.Product_Manager_Approval_Group__r.Name FROM Order_Line_Item__c WHERE Order__c = :orderId ];
        }
        else {
          orderLines = [SELECT Name, Product__r.Name, Product__r.Description__c, BigMachines_Quantity__c, 
            Acknowledge_Text__c, List_Price__c, Product__r.Product_Manager_Approval_Group__r.Name 
            FROM Order_Line_Item__c WHERE Order__c = :orderId AND Product__r.Shipment_Approval__c =: shipAppStatus];
        }
        if(orderLines != null  && !orderLines.isEmpty()){
          showProduct = true;
            return orderLines;            
        }       
      }
      
      return null;
  }
}