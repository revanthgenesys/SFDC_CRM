global class PartnerPortalOppExpirationScheduler implements Schedulable {
	global void execute(SchedulableContext schedulableContext) {
 		Database.executeBatch(new PartnerPortalOpportunityExpiration(), 10);
	}
}