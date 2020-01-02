trigger LegalEntityMain on Legal_Entity__c (before insert, before update) {
    if(Util.Bypass_Trigger_Chk) return;
    
    if(Trigger.isUpdate) {
        FinanceMDMTriggerHelper.preventRecordFromSameApprover(trigger.newMap);
    }
    
    FinanceMDMTriggerHelper.checkDuplicateLegalIdOrDescription(trigger.new);

    for(Legal_Entity__c obj : trigger.new)
    {
        obj.Name = obj.Legal_Entity_ID__c +'-'+ obj.Name_No_Hierarchy__c;
    }
      
}