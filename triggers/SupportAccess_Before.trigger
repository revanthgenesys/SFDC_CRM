trigger SupportAccess_Before on Support_Access__c (before insert, before update) {
    if(Util.Bypass_Trigger_Chk)return;  

    TriggerFlowManager.CONTACT_AFTER_ENABLE_PARTNER_PORTAL = false;
    
    SupportAccessUtil.setSupportAccessFields (trigger.new);
          
}