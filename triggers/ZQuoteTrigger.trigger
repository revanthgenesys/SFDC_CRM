trigger ZQuoteTrigger on zqu__Quote__c (before insert, after insert, before update) {
    
    Custom_Access_Settings__c access = Custom_Access_Settings__c.getInstance(UserInfo.getProfileId());
    if (Trigger.isBefore && !access.Can_Bypass_Triggers__c)
    {
        if (Trigger.isInsert)
        {
            ZQuoteManagement.beforeInsert(Trigger.new);
        }
        else if (Trigger.isUpdate)
        {
            ZQuoteManagement.setTermStartDate(Trigger.oldMap, Trigger.new);
        }
    }
}