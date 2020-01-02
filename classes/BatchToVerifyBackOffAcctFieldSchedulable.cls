global class BatchToVerifyBackOffAcctFieldSchedulable implements Schedulable { 

/* run as account with bypass triggers and bypass workflows
  
*/	
	global void execute(SchedulableContext schedulableContext) {
		
	  BatchToVerifyBackOfficeAccountFields batch = new BatchToVerifyBackOfficeAccountFields();
	  Database.executeBatch(batch, 50);
	
	}	
}