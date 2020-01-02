/*
 * Class            : PartnerDealRegistrationSharingQueueable
 * Description      : A Queueable class to invoke Deal Registrations sharing batch.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Aug 01, 2017
 * Test Class       : PartnerPortalCustomSharingTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 global class PartnerDealRegistrationSharingQueueable implements Queueable {
	global List<String> contactIds;
	
	global PartnerDealRegistrationSharingQueueable(List<String> scope){
	 	this.contactIds = scope;
	}
	
    global void execute(QueueableContext context) {
		Database.executeBatch(new PartnerDealRegistrationSharingBatch(contactIds));
	}
}