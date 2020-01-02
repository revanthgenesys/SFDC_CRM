global class BatchDeleteExpiredSupAccsessSchedulable implements Schedulable {
	
	global static void execute(SchedulableContext schedulableContext) {
       	Database.executeBatch( new BatchDeleteExpiredSupportAccess() );
    }  
}