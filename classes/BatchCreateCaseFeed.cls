/*
	Class : BatchCreateCaseFeed
	Author : Vinay L 4/1/2013
	Usage : Create case feeds when case update is made on portal

*/
global class  BatchCreateCaseFeed implements Database.Batchable<sObject>{
	
	global String Query;
	global database.querylocator start(Database.BatchableContext BC){
		return Database.getQueryLocator(query);	
	}
	
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<Genesys_Case_Updates__c> updateCurList = new List<Genesys_Case_Updates__c>();
		List<FeedItem> feedItemList = new List<FeedItem>();
		
		for(sObject o : scope){	
	   		Genesys_Case_Updates__c gcu = (Genesys_Case_Updates__c)o;
	   		FeedItem fItem = new FeedItem();				
			fItem.Type = 'LinkPost'; 
			fItem.ParentId = gcu.Case__c; 
			//fItem.RelatedRecordId = genCaseUp.Id;
			fItem.LinkUrl = '/'+gcu.Id;
			fItem.Title  = 'View Case Update';
			fItem.Body =  gcu.Created_By_Name__c +' posted a new '+gcu.Type__c + ' update, subject: '+gcu.Name ;
			//fItem.ParentId = gcu.CreatedById;
			//fItem.CreatedById = gcu.CreatedById;
			feedItemList.add(fItem); 	
	   		gcu.Posted_to_Case_Feed__c = true;
	   		updateCurList.add(gcu);
	   	}
	   	
	   	insert feedItemList;
	   	update updateCurList;
	}
	
	global void finish(Database.BatchableContext BC){
		//Get the ID of the AsyncApexJob representing this batch job 
		 system.abortJob(BC.getJobId());
		 ScheduleBatchCreateCaseFeed scheduleBatch = new ScheduleBatchCreateCaseFeed();     
		 Integer minPlusFive = system.now().minute()+5;
		 String cronexp = '0 '+minPlusFive+' '+system.now().hour()+' '+system.today().day()+' '+system.today().month()+' ? '+system.today().year();
		 //b.scheduled_id__c = system.schedule('Create Feed', cronexp, scheduleBatch);
		 //update b;
		 if (!Test.isRunningTest()) {
			 system.schedule('Create Feed'+system.now().minute(), cronexp, scheduleBatch);
		 }
		 
	}

}