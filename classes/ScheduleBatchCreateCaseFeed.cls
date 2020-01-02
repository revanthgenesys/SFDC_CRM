global class ScheduleBatchCreateCaseFeed implements Schedulable{
	
	global void execute(SchedulableContext sc) {
	    BatchCreateCaseFeed b = new BatchCreateCaseFeed();
	    
	    b.Query = 'SELECT Created_By_Name__c,Case__c,CreatedById,Created_By_Portal_User__c,Id,Posted_to_Case_Feed__c,Type__c,Name FROM Genesys_Case_Updates__c WHERE Created_By_Portal_User__c = True AND Posted_to_Case_Feed__c = False AND CreatedDate = Today';
	    Database.executeBatch(b, 25);
	   // curJobId = sc.getTriggerId();
		//System.abortJob(sc.getTriggerId());	
		/*BatchSchedule__c bs = BatchSchedule__c.getOrgDefaults();
		bs.put('scheduled_id__c',sc.getTriggerId());
		//bs.scheduled_id__c = sc.getTriggerId();
		update bs;*/
    }
    
   
    
    static testmethod void testscheduleBatchAccountAssignEvalContact(){
        Test.startTest();
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        String jobId = System.schedule('testscheduleBatchAccountAssignEvalContact',
                                        CRON_EXP, 
                                        new ScheduleBatchCreateCaseFeed()
                                        );
        Test.stopTest();
                                                
    }
}