/*
 * Class			: GenesysCareForecastingScheduler
 * Description		: This Scheduler Class invokes the first batch class for Genesys Care Forecasting Data Generation.
 * Author			: Narasimha "Rao" Tumma
 * Created Date		: Dec 19, 2016
 * Test Class		: GenesysCareForecastingBatchesTest 	 
 */
global class GenesysCareForecastingScheduler implements Schedulable {
	global void execute(SchedulableContext schedulableContext) {
		Database.executeBatch(new GenesysCareForecastingIRBatch(), 1);   
	}
}