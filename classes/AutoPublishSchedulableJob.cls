global class AutoPublishSchedulableJob implements Schedulable {

	public void processArticles() {
		AutoPublishBatchableTask task = new AutoPublishBatchableTask();
		//we only have 150 DML possible per call and we need 3 DMLs per article, so that's why we slice it 50 by 50
		database.executebatch(task,50);
	}

	global void execute(SchedulableContext schedulableContext) {
 		processArticles();
	}

}