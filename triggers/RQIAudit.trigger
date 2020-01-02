trigger RQIAudit on RQI_Audit__c (after insert, after update) {

	   	RQIAuditSharingRules sharingRules = new RQIAuditSharingRules(Trigger.new);
		sharingRules.shareAuditWithAuthor();

}