trigger SupportAccess_After on Support_Access__c (after delete, after insert, after update) {
	if(Util.Bypass_Trigger_Chk)return;	
	if(trigger.isUpdate || trigger.isDelete){
		SupportAccessUtil.disablePartnerPortal( trigger.old );
		if(trigger.isUpdate){
			SupportAccessUtil.enableDisablePartnerPortalForSuppBlockFlag(Trigger.new, Trigger.oldMap);
		} 
	}
	
}