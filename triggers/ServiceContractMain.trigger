trigger ServiceContractMain on ServiceContract (after insert, after update, before insert, 
before update) {
    
    // Ashish, 08/03/2018
    // Bypass the trigger if bypass trigger is set on user  
    if (Util.Bypass_Trigger_Chk) 
        return;
        
    if(trigger.isBefore){
        for(ServiceContract eachSC : trigger.new){
            eachSC.AccountId = eachSC.End_User_Name__c;
        }
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    { 
      if(trigger.new[0].Agreement_Status__c != trigger.old[0].Agreement_Status__c) 
        CheckServiceContractAndCloudDeploy.CheckSC(trigger.new[0]);
    }
    
    // Amit Singh, 06/01/2018.
    // Calling helper method to update the Purchase Offering type on Parent Account
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        CheckServiceContractAndCloudDeploy.afterInsertUpdate(trigger.isInsert, trigger.isUpdate, trigger.new, trigger.oldMap);
    }
}