/*
 * Class            : PartnerPortalCustomSharingQueueable
 * Description      : A Queueable class to invoke PartnerPortalCustomSharingBatch.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Aug 01, 2017
 * Test Class       : PartnerPortalCustomSharingTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 global class PartnerPortalCustomSharingQueueable implements Queueable {
	global List<String> contactIds;
	
	global PartnerPortalCustomSharingQueueable(List<String> scope){
	 	this.contactIds = scope;
	}
	
    global void execute(QueueableContext context) {
		Database.executeBatch(new PartnerPortalCustomSharingBatch(contactIds), 10);
	}
}