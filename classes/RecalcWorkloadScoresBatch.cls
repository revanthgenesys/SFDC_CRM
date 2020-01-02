global class RecalcWorkloadScoresBatch implements Database.Batchable<sObject>{

   global final String QUERY;

	global RecalcWorkloadScoresBatch(String q){
		this.QUERY=q; 
	}

	global Database.QueryLocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);		
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope){
		
		Set<id> allUserIds = new Set<id>{};
        
        for(sObject so : scope){
        	User u = (User)so;
            allUserIds.add(u.id);
        }
				
		UserWorkload.calculateWorkload(allUserIds);
	}

   	global void finish(Database.BatchableContext BC){}
}