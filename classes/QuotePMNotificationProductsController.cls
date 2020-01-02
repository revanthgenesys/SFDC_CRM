//Naresh Kumar  08/12/2014
public without sharing class QuotePMNotificationProductsController { 
    public Id quoteId {get; set;}
    public String shipAppStatus {get;set;}
    public Boolean showProduct {get;set;}
    public List<BigMachines__Quote_Product__c> getProducts() {
    if(quoteId != null){
        List<BigMachines__Quote_Product__c> quoteProducts;
        if(shipAppStatus == 'All Quote Line Items'){
            quoteProducts = [SELECT Name, Product_Description__c, BigMachines__Product__r.Shipment_Approval__c, Bundle__c, 
            Bundle__r.Name, Quantity__c, List_Price__c, Ext_List__c, BigMachines__Product__r.Notification_Message__c,
            Total_Discount__c, BigMachines__Product__r.Product_Manager_Approval_Group__r.Name, Flavor__c FROM BigMachines__Quote_Product__c
            WHERE BigMachines__Quote__c = :quoteId AND BigMachines__Product__r.Type__c != 'Bundle'];
        }
        else{
            quoteProducts = [SELECT Name, Product_Description__c, BigMachines__Product__r.Shipment_Approval__c, Bundle__c, 
                Bundle__r.Name, Quantity__c, List_Price__c, Ext_List__c, BigMachines__Product__r.Notification_Message__c,
                Total_Discount__c, BigMachines__Product__r.Product_Manager_Approval_Group__r.Name, Flavor__c FROM BigMachines__Quote_Product__c
                WHERE BigMachines__Quote__c = :quoteId AND BigMachines__Product__r.Shipment_Approval__c =: shipAppStatus AND BigMachines__Product__r.Type__c != 'Bundle'];
        }
        if(quoteProducts != null  && !quoteProducts.isEmpty())
            return quoteProducts;        
        }       
        return null;
    }
}