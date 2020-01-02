/*
 * Class            : PartnerDealRegDeleteSharingQueueable
 * Description      : A Queueable class to invoke the clean up batch which deletes sharing for the Deal Registrations for a given contacts.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Aug 01, 2017
 * Test Class       : PartnerPortalCustomSharingTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 global class PartnerDealRegDeleteSharingQueueable implements Queueable {
    global List<String> contactIds;
	
	global PartnerDealRegDeleteSharingQueueable(List<String> scope){
	 	this.contactIds = scope;
	}

    global void execute(QueueableContext context) {
		Database.executeBatch(new PartnerDealRegDeleteSharingBatch(contactIds));
	}
}