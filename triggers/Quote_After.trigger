trigger Quote_After on BigMachines__Quote__c (after insert,after undelete,before delete) {
    if(Util.Bypass_Trigger_Chk)
        return;  
    if(Trigger.isAfter && Trigger.isInsert) {
        PartnerPortalCustomSharing.shareQuoteWithOpportunityTeam(Trigger.NEW);
    }
    //Inserted Hard delete
      if(trigger.isDelete && trigger.isBefore)
     {   
        ID jobID = System.enqueueJob(new DeleteHistoryAsync(Trigger.oldMap,'delete'));
     }
     if(trigger.isUnDelete && trigger.isAfter)
     {   
        ID jobID2 = System.enqueueJob(new DeleteHistoryAsync(Trigger.newMap,'Restore'));
     }
   
}