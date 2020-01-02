global class CaseAutoFollowUpNotificationSchedulable implements Schedulable {
	
	global static void execute(SchedulableContext schedulableContext) {
       	CaseAutoFollowUpNotificationJob batch = new CaseAutoFollowUpNotificationJob();
		Database.executeBatch(batch, 100);  
       //	Database.executeBatch( new CaseAutoFollowUpNotificationJob() );
    }  
}