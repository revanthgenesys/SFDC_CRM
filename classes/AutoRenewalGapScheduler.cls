/*
 * Class            : AutoRenewalGapScheduler
 * Description      : Scheduler Class for all invoking AutoRenewalGapQuotesBatch.
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
global with sharing class AutoRenewalGapScheduler implements Schedulable {
	global void execute(SchedulableContext schedulableContext) {
		Database.executeBatch(new AutoRenewalGapQuotesBatch(), 1);   
	}
}