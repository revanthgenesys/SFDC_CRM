public with sharing class Order_Quote_Attachment_Class {

    List<Attachment> attachments ;
    private final Order__c order;
    Public Boolean noAtchmnts {get;set;}

    public Order_Quote_Attachment_Class(ApexPages.StandardController controller) {
    attachments = new List<Attachment>();
    this.order = (Order__c)controller.getRecord();    
    }
    
    public Order__c getorder() {
     return order;  
    }
    
    
    public List<Attachment> getAllAtachments()
    {
     Order__c newOrd = [Select Id,Quote__c,Zuora_Quote__c from Order__c where id=:order.Id];
     if(newOrd != null)
     {
         if(newOrd.Quote__c != null) 
         {    
             attachments = [SELECT Name,Description,LastModifiedById FROM Attachment WHERE ParentID =:newOrd.Quote__c];
         }
         else if(newOrd.Zuora_Quote__c != null) 
         {
             attachments = [SELECT Name,Description,LastModifiedById FROM Attachment WHERE ParentID =:newOrd.Zuora_Quote__c];
         }
     }
     return attachments;
    }
}