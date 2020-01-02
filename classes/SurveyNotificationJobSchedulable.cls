global class SurveyNotificationJobSchedulable implements Schedulable { 
	
	global void execute(SchedulableContext schedulableContext) {
		SurveyNotificationJob batch = new SurveyNotificationJob();
	 	Database.executeBatch(batch, 10);
	}

}