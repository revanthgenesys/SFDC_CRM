public with sharing class DeclineMaintenanceCheck {
   Order__c currentOrder;  
   boolean flag=false;
   public boolean isDecline {get;set;}
   
   public DeclineMaintenanceCheck(ApexPages.StandardController controller) {
    currentOrder = (Order__c)controller.getRecord();
     Order__c ord = [Select 	Decline_Maintenance__c from Order__c where id =:currentOrder.id];
     
     
        if(ord.Decline_Maintenance__c){
          isDecline = true;
        }
        else {
         isDecline = false;
        }
     
    }
   
}