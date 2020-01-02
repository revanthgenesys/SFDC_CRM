global with sharing class KCSSchedulableJob implements Schedulable {
    


	public void processCases() {
		BatchKCSJob task = new BatchKCSJob();
        database.executebatch(task,50);
	}

	global void execute(SchedulableContext schedulableContext) {
 		processCases();
	}

}