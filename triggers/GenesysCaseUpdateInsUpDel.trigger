trigger GenesysCaseUpdateInsUpDel on Genesys_Case_Updates__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {

/*
 if(Util.Bypass_Trigger_Chk)return;
    if (Trigger.isInsert) {
            
        if (Trigger.isAfter) {
            // Place holder for after insert trigger
           
            GenesysCaseUpdateUtil.createCaseFeed(trigger.new);             
            CaseSLTHandler.firstResponseProvided(trigger.new);
            
        } else {
              
            // Place holder for before insert trigger
            GenesysCaseUpdateUtil.recordLastUpdate(trigger.new);
        }
            
    }
   
    if (Trigger.isUpdate) {
            
        if (Trigger.isAfter) {
            CaseSLTHandler.firstResponseProvided(trigger.new);
        } else {
           GenesysCaseUpdateUtil.updateMadePublic(trigger.new, trigger.oldMap); 
        }
            
    }
      
    if (Trigger.isDelete) {
            
        if (Trigger.isAfter) {
               // Place holder for after delete trigger
        } else {
               // Place holder for before delete trigger
        }
            
    }
*/
}