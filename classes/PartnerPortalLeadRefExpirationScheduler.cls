global class PartnerPortalLeadRefExpirationScheduler implements Schedulable {
	global void execute(SchedulableContext schedulableContext) {
 		Database.executeBatch(new PartnerPortalLeadReferralExpiration(), 10);
	}
}