//Naresh Kumar  06/26/2015
trigger SellableItemMain on Sellable_Item_Product__c (after insert, after update, before insert, 
before update, before delete) {
    
    if(Util.Bypass_Trigger_Chk)
        return;
    
    if(trigger.isBefore && trigger.isUpdate){
        APN_ECCN_GenerationHelper.generateAPNs(trigger.new);
        //SellableItemBeforeInsertUpdateHandler.updateSellableItemName(trigger.new, trigger.oldMap);
    }
    
    /*if(trigger.isBefore && trigger.isInsert){
        SellableItemBeforeInsertUpdateHandler.updateSellableItemName(trigger.new, null);
    }*/
    
    if(trigger.isBefore && trigger.isDelete){
        SellableItemBeforeInsertUpdateHandler.handleSellableItemDelete(trigger.old);
    }
    
    if(trigger.isAfter){
        if(trigger.isInsert){
            SellableItemHistoryTrackingHelper.populateFieldHistory(trigger.newMap, null);
        }
        else if(trigger.isUpdate){
            SellableItemHistoryTrackingHelper.populateFieldHistory(trigger.newMap, trigger.oldMap);
            SellableItemBeforeInsertUpdateHandler.handleUprevActions(trigger.new, trigger.oldMap);
        }
    }
}