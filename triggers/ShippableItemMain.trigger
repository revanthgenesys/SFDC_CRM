//Naresh Kumar  0707/2015
trigger ShippableItemMain on Shippable_Item__c (after update) {
    if(Util.Bypass_Trigger_Chk)
        return;
    APN_ECCN_GenerationHelper.reCalculateECCN(trigger.new, trigger.oldMap);
}