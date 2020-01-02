//Naresh Kumar	07/06/2015
trigger SelleableShippableItemMain on Sellable_Shippable_Items__c (after insert, after update, after delete, before delete, after undelete) {
	
	if(Util.Bypass_Trigger_Chk)
        return;
    
	if(trigger.isInsert || trigger.isUpdate){
		APN_ECCN_GenerationHelper.generateECCN(trigger.new);
	}
	else{
		APN_ECCN_GenerationHelper.generateECCN(trigger.old);
	}
	if(trigger.isDelete && trigger.isBefore){
		SellableItemBeforeInsertUpdateHandler.validateBOMDelete(trigger.old);
	}
}