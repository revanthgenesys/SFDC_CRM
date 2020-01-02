trigger zSubscriptionProductChargeTrigger on Zuora__SubscriptionProductCharge__c (after insert, before update, before insert) {

	if(Trigger.IsAfter)
    {
        if(Trigger.IsInsert)
        {
            system.debug('==> TRIGGER: isAfter isInsert');
            system.debug('==> TRIGGER: new: ' + Trigger.newMap);
    		zSubscrProductChargeManagement.AfterInsert(Trigger.newMap);
        }		

    }
	else if(Trigger.IsBefore)	
	{
		if (Trigger.IsInsert || Trigger.IsBefore)
		{
            system.debug('==> TRIGGER: isBefore isInsert');
            system.debug('==> TRIGGER: newMap: ' + Trigger.new);
            zSubscrProductChargeManagement.AttachToProductRatePlanCharge(Trigger.new);
			zSubscrProductChargeManagement.SetProductCategories(Trigger.new);
		}
	}

}