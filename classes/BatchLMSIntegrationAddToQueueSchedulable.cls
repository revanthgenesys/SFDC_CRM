global class BatchLMSIntegrationAddToQueueSchedulable implements Schedulable {
	/* runs once a day
	   last successful execution date stored custom setting LMS_Integration_Configuration__c.Last_Successful_AddQ_Run__c 
	*/	
	global void execute(SchedulableContext schedulableContext) {
		
	  BatchLMSIntegrationAddToQueue batch = new BatchLMSIntegrationAddToQueue();
	  Database.executeBatch(batch, 20); 
	}
    
}