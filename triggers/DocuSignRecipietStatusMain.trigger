//Naresh Kumar
trigger DocuSignRecipietStatusMain on dsfs__DocuSign_Recipient_Status__c (after update) {

	DocuSignRecipietStatusMainHelper.updateGCRStatus(trigger.new, trigger.oldMap);
}