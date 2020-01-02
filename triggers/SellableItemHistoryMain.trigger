//Naresh Kumar  07/27/2015
trigger SellableItemHistoryMain on Sellable_Item_History__c (before insert) {
    if(Util.Bypass_Trigger_Chk)
        return;
    SellableItemHistoryTrackingHelper.replaceIdsWithRecordName(trigger.new);
}