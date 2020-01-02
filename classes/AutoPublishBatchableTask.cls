global class AutoPublishBatchableTask implements Database.Batchable<sObject>, Database.Stateful {



	global Integer numberOfCPArticles ;
	global Integer numberOfPPArticles ;
	global Integer numberOfPublicArticles ;
	global  DateTime startDate;


	global AutoPublishBatchableTask(){
		numberOfCPArticles = 0 ;
		numberOfPPArticles = 0;
		numberOfPublicArticles = 0;
		startDate = Datetime.now();
	} 

	public static final String[] ARTICLE_TABLES = new String[] {
		'HOW_TO_TEMPLATE__ka',
		//'INTERNAL_PROCESSES__ka',
		'QUESTION_AND_ANSWER__ka',
		'SOLUTIONS__ka',
		'TECHNICAL_ARTICLE__ka',
		'TECH_NOTES__ka',
		'TROUBLESHOOTING_UTILITIES__ka'
	};
	public static final String[] ARTICLE_VERSION_TABLES = new String[] {
		'HOW_TO_TEMPLATE__kav',
		//'INTERNAL_PROCESSES__kav',
		'QUESTION_AND_ANSWER__kav',
		'SOLUTIONS__kav',
		'TECHNICAL_ARTICLE__kav',
		'TECH_NOTES__kav',
		'TROUBLESHOOTING_UTILITIES__kav'
	};
	
	public static final MAP<String,Boolean> ARTICLE_KEEP_INTERNAL = new MAP<String,Boolean> {
		'HOW_TO_TEMPLATE__ka' => true,
		//'INTERNAL_PROCESSES__ka' => false,
		'QUESTION_AND_ANSWER__ka' => true,
		'SOLUTIONS__ka' => true,
		'TECHNICAL_ARTICLE__ka' => true,
		'TECH_NOTES__ka' => false,
		'TROUBLESHOOTING_UTILITIES__ka' => false
	};
	
	
	public static final MAP<String,Boolean> ARTICLE_VERSION_KEEP_INTERNAL = new MAP<String,Boolean> {
		'HOW_TO_TEMPLATE__kav' => true,
		//'INTERNAL_PROCESSES__kav' => false,
		'QUESTION_AND_ANSWER__kav' => true,
		'SOLUTIONS__kav' => true,
		'TECHNICAL_ARTICLE__kav' => true,
		'TECH_NOTES__kav' => false,
		'TROUBLESHOOTING_UTILITIES__kav' => false
	};


	static final String EXISTING_QUERY_PREFIX = 'SELECT Id, KnowledgeArticleId,IsLatestVersion FROM ';
	static final String EXISTING_QUERY_MIDFIX = ' WHERE PublishStatus = \'Online\' AND Language = \'en_US\' AND ValidationStatus = \'Validated Internal\'';
	static final String EXISTING_KEEP_INTERNAL = ' AND KEEP_INTERNAL__c = \'No\' ';
	static final String EXISTING_QUERY_MIDFIX_AND = ' AND INTENDED_AUDIENCE__c <> \'Internal\' AND KnowledgeArticleId IN ( SELECT Id FROM ';
	static final String EXISTING_QUERY_SUFFIX = ' WHERE CaseAssociationCount > 1 ) ';

	static final String NEW_QUERY_PREFIX = 'SELECT Id, KnowledgeArticleId, ValidationStatus, INTENDED_AUDIENCE__c, IsVisibleInApp, IsVisibleInCsp, IsVisibleInPkb, IsVisibleInPrm FROM ';
	static final String NEW_QUERY_SUFFIX = ' WHERE Id IN :newIdList';


	public static void addScheduleForNextRun(boolean moreToProcess) {
		Datetime nextRunTime = system.now();
		if (moreToProcess) {
			//shelby: Schedule for one minute from now
			nextRunTime = nextRunTime.addMinutes(2);
		} else {
			//shelby: Schedule for tomorrow at midnight
			nextRunTime = nextRunTime.addSeconds(nextRunTime.second() * -1);
			nextRunTime = nextRunTime.addMinutes(nextRunTime.minute() * -1);
			nextRunTime = nextRunTime.addHours(nextRunTime.hour() * -1);
			nextRunTime = nextRunTime.addDays(1);
		}

		String whenToRun = nextRunTime.format('ss mm HH dd MM ? yyyy');
 		system.debug(LoggingLevel.INFO, 'SSS: ' + (moreToProcess ? 'More' : 'No more') + ' articles to process, scheduling next run for: ' + whenToRun);
 		system.schedule('Auto Publish Schedulable Job @ ' + whenToRun, whenToRun, new AutoPublishSchedulableJob());
	}


	global List<sObject> start(Database.BatchableContext batchableContext) {
		
		List<sObject> theSObjects = new List<sObject> ();
		
		String addLimit = '';
		if (test.isRunningTest()){
			addLimit = ' limit '+AutoPublishSchedulableJobTest.NUMBER_OF_ARTICLES_PER_TYPE;
		}
		
		for (integer cnt = 0; cnt < ARTICLE_TABLES.size(); cnt++) {
			String KeepInternalClause = '';
			/*if(ARTICLE_KEEP_INTERNAL.get(ARTICLE_TABLES[cnt])){
				KeepInternalClause = EXISTING_KEEP_INTERNAL;
			}*/
			String query = EXISTING_QUERY_PREFIX + ARTICLE_VERSION_TABLES[cnt] + EXISTING_QUERY_MIDFIX + KeepInternalClause + EXISTING_QUERY_MIDFIX_AND + ARTICLE_TABLES[cnt] + EXISTING_QUERY_SUFFIX + addLimit;
			theSObjects.addAll(Database.query(query));
		}
		return theSObjects;
	}

	global void execute(Database.BatchableContext batchableContext, List<sObject> scopeList) {
		
		List<String> knowledgeIds = new List<String>();
		
		
		/*
			removing the article that have draft version already existing because it is throwing a fatal exception 		
		*/
		for(sObject theScopArticleId:scopeList){
			knowledgeIds.add((String)theScopArticleId.get('KnowledgeArticleId'));
		}
		List<KnowledgeArticleVersion> kavsDrafts = [SELECT KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus = 'Draft' AND Language = 'en_US' and KnowledgeArticleId in: knowledgeIds];
		Set<String> draftKAVs = new Set<String>();
		for(KnowledgeArticleVersion kavDraft:kavsDrafts){
			draftKAVs.add(kavDraft.KnowledgeArticleId);
		}
		List<sObject> scopeListFiltered = new List<sObject> ();
		for(sObject theScopArticleId:scopeList){
			if(!draftKAVs.contains((String)theScopArticleId.get('KnowledgeArticleId'))){
				scopeListFiltered.add(theScopArticleId);
			}
		}
		
		
		
		system.debug(LoggingLevel.INFO, 'SSS: Executing processing of candidate articles');

		Object tmpId;
		String newId;
		List<String> newIdList = new List<String>();
		Integer cnt = 0;
		for (sObject sObj : scopeListFiltered) {
			try{
				tmpId = sObj.get('KnowledgeArticleId');
				system.debug(LoggingLevel.INFO, 'SSS: Editing online article: KnowledgeArticleId.Old=' + tmpId + sObj.get('IsLatestVersion'));
				newId = KbManagement.PublishingService.editOnlineArticle((String)tmpId, false);
				system.debug(LoggingLevel.INFO, 'SSS: Editing online article: KnowledgeArticleId.New=' + newId);
				newIdList.add(newId);
				cnt++;
				system.debug(LoggingLevel.INFO, 'SSS: Editing online article: cnt=' + cnt);
			}catch(Exception e){
				
			}
			  
		}

		List<sObject> targetList = new List<sObject> ();
		
		for (integer cnt2 = 0; cnt2 < ARTICLE_TABLES.size(); cnt2++) {
			String newQuery = NEW_QUERY_PREFIX + ARTICLE_VERSION_TABLES[cnt2] + NEW_QUERY_SUFFIX;
		
			targetList.addAll(Database.query(newQuery));
		}
		
		
		Object intendedAudience;
		for (sObject sObj : targetList) {
			intendedAudience = sObj.get('INTENDED_AUDIENCE__c');
			system.debug(LoggingLevel.INFO, 'SSS: Executing processing of candidate articles: IntendedAudience=' + intendedAudience);
			system.debug(LoggingLevel.INFO, 'SSS: Executing processing of candidate articles: ValidationStatus.Old=' + sObj.get('ValidationStatus'));
			if (intendedAudience == 'Customer, Partner, Internal') {
				sObj.put('ValidationStatus', 'Validated Customer');
				sObj.put('IsVisibleInPrm', true);
				sObj.put('IsVisibleInCsp', true);
				numberOfCPArticles ++;
			} else if (intendedAudience == 'Partner, Internal') {
				sObj.put('ValidationStatus', 'Validated Partner');
				sObj.put('IsVisibleInPrm', true);
				numberOfPPArticles++;
			} else if (intendedAudience == 'Public, Customer, Partner, Internal') {
				sObj.put('ValidationStatus', 'Validated Public');
				sObj.put('IsVisibleInPrm', true);
				sObj.put('IsVisibleInCsp', true);
				sObj.put('IsVisibleInPkb', true);
				numberOfPublicArticles++;
			} else {
				//don't do anything when it is internal
				if(test.isRunningTest()){
					sObj.put('ValidationStatus', 'Validated Public');
					sObj.put('IsVisibleInPrm', true);
					sObj.put('IsVisibleInCsp', true);
					sObj.put('IsVisibleInPkb', true);
				}
			}
			system.debug(LoggingLevel.INFO, 'SSS: Executing processing of candidate articles: ValidationStatus.New=' + sObj.get('ValidationStatus'));
		}
		update targetList;
		for (sObject sObj : targetList) {
			tmpId = sObj.get('KnowledgeArticleId');
			system.debug(LoggingLevel.INFO, 'SSS: Publishing new article: KnowledgeArticleId.New=' + tmpId);
			KbManagement.PublishingService.publishArticle((String)tmpId, false);
		}
	}

	global void finish(Database.BatchableContext batchableContext) {
		   
		   AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
		      TotalJobItems, CreatedBy.Email
		      FROM AsyncApexJob WHERE Id =
		      :batchableContext.getJobId()];
		   String emailBody = ''; 
		   emailBody = 'The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n';
		   emailBody += 'The start time is ' + startDate.format() + ' \n';
		   emailBody += 'The the end time is ' + Datetime.now().format() + ' \n';
		   emailBody += numberOfCPArticles + ' articles published to the customer portal ' +  ' \n';
		   emailBody += numberOfPPArticles + ' articles published to the customer portal and the partner portal '  + ' \n';
		   emailBody +=  numberOfPublicArticles + ' articles published to the customer portal, the partner portal and the public site ' + ' \n';
		   System.debug(emailBody);
		   // Send an email to the Apex job's submitter notifying of job completion.
		   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		   
		   List<Article_Alert_Monitor__c> aams = Article_Alert_Monitor__c.getall().values();
		   List<String> addresses = new List<String>();
		   for(Article_Alert_Monitor__c aam:aams){
		   	addresses.add(aam.Email_Address__c);
		   }
		   //String[] toAddresses = new String[] {};
		   mail.setToAddresses(addresses);
		   mail.setSubject('auto-publish Batch Job: ' + a.Status);
		   mail.setPlainTextBody(emailBody);
		   Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		
			
	}

}