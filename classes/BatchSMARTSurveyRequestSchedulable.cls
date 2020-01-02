global class BatchSMARTSurveyRequestSchedulable  implements Schedulable {
	
	global void execute(SchedulableContext schedulableContext) {		
	  BatchSMARTSurveyRequest task = new BatchSMARTSurveyRequest();
      database.executeBatch(task, 5);
	}
    
}