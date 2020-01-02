//Naresh Kumar	12/06/2014
trigger GCRContentDocumentDetailApprovalMain on GCR_Content_Document_Detail_Approval__c (after insert, after update, before insert, 
before update) {	
	if(trigger.isAfter && trigger.isUpdate){		
		//Assign next step (if any)
		//We are keeping all the approvals parallel so don't need to call below mehtod.
		//GCRContentDocumentApprovalsHelper.assignNextStep(trigger.oldMap, trigger.new);
		//Updates quote status if it needs to be updated after a quote approval record is updated
		GCRContentDocumentApprovalsHelper.gcrDocumentStatusHandler(trigger.oldMap, trigger.new);		
	}
}