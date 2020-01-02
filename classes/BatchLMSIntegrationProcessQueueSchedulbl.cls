global class BatchLMSIntegrationProcessQueueSchedulbl implements Schedulable {
	/* runs every hour
	   system.schedule('BatchLMSIntegrationProcessQueue','0 0 * * * ?', new BatchLMSIntegrationProcessQueueSchedulbl());
	*/	
	global void execute(SchedulableContext schedulableContext) {
		
	  BatchLMSIntegrationProcessQueue batch = new BatchLMSIntegrationProcessQueue();
	  Database.executeBatch(batch, 5);
	 
	}
    
}