global class CaseSurveyRequestsJobSchedulable implements Schedulable {
	
	/* to run every hour execute
	    system.schedule('CaseSurveyRequestJob','0 0 * * * ?', new CaseSurveyRequestsJobSchedulable()); 
	*/
	global void execute(SchedulableContext schedulableContext) {
		
      CaseSurveyRequestJob task = new CaseSurveyRequestJob();
        // only 10 remote calls allowed per batch
      database.executeBatch(task, 10);
	}
}