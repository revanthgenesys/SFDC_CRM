trigger UpdateCriticalAccount on Critical_Account_Updates__c (after insert, after update) {
  Critical_Account_Updates__c ca = Trigger.New[0];    
       List<Critical_Account__c> listWO = [Select update__c from Critical_Account__c where id = :ca.Critical_Account__c];                       
            for(Critical_Account__c wo : listWO) {  
               wo.update__c = ca.Update__c ;
             }  
             update listWO;  
      
}