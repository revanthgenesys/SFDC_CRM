global class PartnerKPIYTDCalculationsDailyScheduler implements Schedulable {
	global void execute(SchedulableContext schedulableContext) {
 		Database.executeBatch(new PartnerKPIYTDCalculationsDailyBatch());
	}
}