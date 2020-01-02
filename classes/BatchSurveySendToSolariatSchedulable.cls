global class BatchSurveySendToSolariatSchedulable implements Schedulable {
	/* to run every hour execute
	    system.schedule('BatchSurveysSendToSolariat','0 0 * * * ?', new BatchSurveySendToSolariatSchedulable()); 
	*/	
	global void execute(SchedulableContext schedulableContext) {
		
	  BatchSurveysSendToSolariat task = new BatchSurveysSendToSolariat();
        // 10 remote calls max per batch, need 2 per record
        // need to run from a "diabled triggers" account
      database.executeBatch(task, 5);
	}

}