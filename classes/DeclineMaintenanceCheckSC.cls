public with sharing class DeclineMaintenanceCheckSC {
   ServiceContract currentOrder;  
   boolean flag=false;
   public boolean isDecline {get;set;}
   
   public DeclineMaintenanceCheckSC(ApexPages.StandardController controller) {
    currentOrder = (ServiceContract)controller.getRecord();
     ServiceContract ord = [Select 	Agreement_Status__c from ServiceContract where id =:currentOrder.id];
     
     
        if(ord.Agreement_Status__c == 'Declined'){
          isDecline = true;
        }
        else {
         isDecline = false;
        }
     
    }
   
}