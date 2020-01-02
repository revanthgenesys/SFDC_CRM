/*
 * Class            : AutoRenewalRegularScheduler
 * Description      : Scheduler Class for all invoking AutoRenewalBatch.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Jul 03, 2017
 * Test Class       : AutoRenewalAllTests   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Modified BY		Modified Date		Changes/ Notes
 * ----------------------------------------------------------------------------------------------
 *
 */ 
global with sharing class AutoRenewalRegularScheduler implements Schedulable {
	global void execute(SchedulableContext schedulableContext) {
		Database.executeBatch(new AutoRenewalBatch(), 1);   
	}
}