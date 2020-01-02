trigger trgShareSCE on DSR_Virtual_Team__c (after insert) {
  if(Util.Bypass_Trigger_Chk) 
        return;   
 if(Trigger.isInsert)
 {
    DSRUtility.ShareSCERequest(trigger.new);
 }
}