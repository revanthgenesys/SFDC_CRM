//Naresh Kumar  08/27/2018
trigger BusinessRegionMain on Business_Region__c (before insert, before update) {
    if (Util.Bypass_Trigger_Chk) return;
    
    
    for(Business_Region__c obj : trigger.new)
    {
        obj.Name = obj.Region_ID__c +'-'+ obj.Description__c;
    }
    
    if(Trigger.isBefore){
        if(Trigger.isInsert)
            FinanceMDMTriggerHelper.onBeforeInsertBR(trigger.new); 
        if(Trigger.isUpdate){
            FinanceMDMTriggerHelper.preventRecordFromSameApprover(trigger.newMap);
            FinanceMDMTriggerHelper.onBeforeUpdateBR(trigger.new, trigger.oldMap); 
        }
    }
}