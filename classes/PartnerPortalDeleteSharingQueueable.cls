/*
 * Class            : PartnerPortalDeleteSharingQueueable
 * Description      : A Queueable class to invoke the PartnerPortalDeleteSharingBatch.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Aug 01, 2017
 * Test Class       : PartnerPortalCustomSharingTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 global class PartnerPortalDeleteSharingQueueable implements Queueable {
    global List<String> contactIds;
	
	global PartnerPortalDeleteSharingQueueable(List<String> scope){
	 	this.contactIds = scope;
	}

    global void execute(QueueableContext context) {
		Database.executeBatch(new PartnerPortalDeleteSharingBatch(contactIds));
	}
}