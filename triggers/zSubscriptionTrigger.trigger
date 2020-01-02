trigger zSubscriptionTrigger on Zuora__Subscription__c (after insert, after update) {
    
    if(Trigger.isAfter)
    {
        if(Trigger.isInsert)
        {
            zSubscriptionManagement.afterInsert(Trigger.New);
        }

        if(Trigger.isUpdate)
        {
            zSubscriptionManagement.afterUpdate(Trigger.New, Trigger.old);
        }
    }
}