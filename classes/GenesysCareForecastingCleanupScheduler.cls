/*
 * Class			: GenesysCareForecastingCleanupScheduler
 * Description		: This Scheduler Class invokes the Genesys Care Forecasting Cleanup Batch.
 * Author			: Narasimha "Rao" Tumma
 * Created Date		: Dec 19, 2016
 * Test Class		: GenesysCareForecastingBatchesTest	 
 */
global class GenesysCareForecastingCleanupScheduler implements Schedulable {
	global void execute(SchedulableContext schedulableContext) {
 		Database.executeBatch(new GenesysCareForecastingCleanupBatch(), 5000);
	}
}