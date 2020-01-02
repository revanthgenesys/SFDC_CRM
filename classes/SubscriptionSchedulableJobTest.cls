@IsTest
public with sharing class SubscriptionSchedulableJobTest {

static WeeklySubscriptionSchedulableJob weeklyJob = new WeeklySubscriptionSchedulableJob();
static DailySubscriptionSchedulableJob dailyJob = new DailySubscriptionSchedulableJob();
static String jobId;



	static void setupArticles() {
		pkb_test.setupSubscriptionData();
		pkb_test.setupSubscriptionCatData();
	}


	static void executeJob() {
		weeklyJob.processSubscriptions();
		dailyJob.processSubscriptions();
	}
	
	
	
	static void assertResults() {
		system.assert([select Last_Run_Date__c from Solution_Search_Alert__c][0].Last_Run_Date__c >(Datetime.now() -1));
	}


	static testMethod void testExecute() {
	       
		try{        
			Test.startTest();
	
			setupArticles();
	
			executeJob();
			
			Test.stopTest();
	
			assertResults();
	    
		}catch(Exception e){
		
		}
	    
	}
}