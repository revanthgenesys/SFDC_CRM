//Naresh Kumar  08/27/2018
trigger BusinessSegment on Business_Segment__c (before insert,  before update) {
    if (Util.Bypass_Trigger_Chk) return;
    
    for(Business_Segment__c obj : trigger.new)
    {
        obj.Name = obj.Business_Segment_ID__c+'-'+ obj.Description__c;
    }
    
    if(Trigger.isBefore){
        if(Trigger.isInsert)
            FinanceMDMTriggerHelper.onBeforeInsertBS(trigger.new); 
        if(Trigger.isUpdate){
            FinanceMDMTriggerHelper.preventRecordFromSameApprover(trigger.newMap);
            FinanceMDMTriggerHelper.onBeforeUpdateBS(trigger.new, trigger.oldMap); 
        }
    }
}