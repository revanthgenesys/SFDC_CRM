/*
 * Class            : GCFScheduler
 * Description      : A Scheduler class to invoke Genesys Care forecasting Batch classes.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : May 19, 2017
 * Test Class       : GCFAllTests   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 global class GCFScheduler implements Schedulable {
	global void execute(SchedulableContext schedulableContext) {
		Database.executeBatch(new GCFDataCleanupBatch(), 2000);   
	}
}