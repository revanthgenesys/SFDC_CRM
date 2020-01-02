/*
 * Class            : LMSCaptureSTEUCombinationScheduler
 * Description      : Scheduler Class to invoke batch class that captures all ST EU Combinations 
 * 					  for ININ Customers based on Service Contracts.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Mar 11, 2018
 * Test Class       : LicenseSnapshotTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Modified BY    Modified Date    	Changes/ Notes
 * ----------------------------------------------------------------------------------------------
 * 	
 */ 
global class LMSCaptureSTEUCombinationScheduler implements Schedulable {
	global void execute(SchedulableContext schedulableContext) {
		Database.executeBatch(new LMSCaptureSoldToEndUserCombinationBatch(), 10);   
	}
}