trigger CloudDeploymentTrigger on Cloud_Deployment__c (before delete, before insert, before update,
                                                    after delete, after insert, after update) {
    
    // Ashish, 08/03/2018
    // Bypass the trigger if bypass trigger is set on user  
    if (Util.Bypass_Trigger_Chk) 
        return;
                                                           
     if (Trigger.isBefore) {
            if (Trigger.isDelete) { 
                
                for ( Cloud_Deployment__c cld : Trigger.old ) {
                    if ( cld.Support_Access_Records__c > 0 )
                       cld.addError('Cloud Deployments associated with active Support Access records cannot be deleted.');
                }
                
            }                                                   
     }
     
     
    if(trigger.isAfter && trigger.isUpdate)
    { 
      if(trigger.new[0].Support_Status__c != trigger.old[0].Support_Status__c ) 
        CheckServiceContractAndCloudDeploy.CheckCD(trigger.new[0]);
    }
    
    // Amit Singh, 06/01/2018.
    // Calling helper method to update the Purchase Offering type on Parent Account
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        CheckServiceContractAndCloudDeploy.afterInsertUpdateCloudDeply(trigger.isInsert, trigger.isUpdate, trigger.new, trigger.oldMap);
    }
}