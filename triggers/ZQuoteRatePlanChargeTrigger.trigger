trigger ZQuoteRatePlanChargeTrigger on zqu__QuoteRatePlanCharge__c (before insert, before update, after insert, after update, after delete)  
{
    Custom_Access_Settings__c access = Custom_Access_Settings__c.getInstance(UserInfo.getProfileId());
    if(access.Can_Bypass_Triggers__c) return;
    
    if (Trigger.IsBefore)
    {
        if (Trigger.isInsert)
        {
            //system.debug('ZQuoteRatePlanChargeTrigger.Before.Insert');
            ZQuoteRatePlanChargeManagment.BeforeInsert(Trigger.New);
            ZQuoteProductValidation.BeforeInsert(Trigger.New);
        }  
        else if (Trigger.isUpdate)
        {
            //system.debug('ZQuoteRatePlanChargeTrigger.Before.Update');
            ZQuoteRatePlanChargeManagment.BeforeUpdate(Trigger.NewMap, Trigger.Old);
        }
    }
    else if (Trigger.IsAfter)
    {
        if (Trigger.isDelete)
        {
            ZQuoteRatePlanChargeManagment.updateQuoteTerms(Trigger.old[0].QuoteId__c);
        }
        else
        {
            ZQuoteRatePlanChargeManagment.updateQuoteTerms(Trigger.new[0].QuoteId__c);
        }
    }
}