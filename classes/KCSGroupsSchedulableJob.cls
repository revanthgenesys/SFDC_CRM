global class KCSGroupsSchedulableJob implements Schedulable {

	public void processArticles() {
		BatchKCSGroupsJob task = new BatchKCSGroupsJob();
		//we only have 150 DML possible per call and we need 3 DMLs per article, so that's why we slice it 50 by 50
		database.executebatch(task,1000);
	}

	global void execute(SchedulableContext schedulableContext) {
 		processArticles();
	}

}