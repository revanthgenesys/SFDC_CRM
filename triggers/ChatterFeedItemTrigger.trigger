trigger ChatterFeedItemTrigger on FeedItem (after insert) {
	
	// THIS REGEX IS FOR #flag or #flagit POSTS ON ARTICLES
	Pattern pat = Pattern.compile('#flag(?:it)?\\b');
	// THIS LIST IS FOR #flag or #flagit POST CASE UPDATES
	List<Case> flaggedArticleCaseUpdates = new List<Case>();
	// THIS LIST IS FOR #flag or #flagit POST CASE INSERTIONS
	List<Case> flaggedArticleCaseInserts = new List<Case>();
	// THESE TWO VALUES ARE FOR MATCHING CASES AGAINST FLAGGED ARTICLES
	String flaggedArticleCaseType = 'Problem';
	String flaggedArticleCaseOrigin = 'Web';


    for (FeedItem f : Trigger.new) {
		String parentId = f.parentId;
		// THIS CONDITIONAL IS FOR #flag or #flagit POSTS ON ARTICLES
		if (parentId!=null && f.body!=null && (f.Type.equals('TextPost') || f.Type.equals('ContentPost') || f.Type.equals('LinkPost') )
		    && f.body.toLowerCase().contains('#flag')) {
		    Matcher mat = pat.matcher(f.body.toLowerCase());
		    if (mat.find()) {
		    	List<KnowledgeArticle> parentKAlist = [SELECT Id FROM KnowledgeArticle WHERE Id=:parentId];
				if (parentKAlist.size()>0) {
					List<KnowledgeArticleVersion> parentKAVlist = f.body.toLowerCase().startsWith('Test of #flag chatter Item xx11xx22xx33xx') ?
																	[SELECT Id,Title FROM KnowledgeArticleVersion 
					                                                              WHERE KnowledgeArticleId=:parentId AND PublishStatus='Draft']
					                                               : [SELECT Id,Title FROM KnowledgeArticleVersion 
					                                                              WHERE KnowledgeArticleId=:parentId AND PublishStatus='Online'];
					if (parentKAVlist.size()>0){
						String createdByName = [SELECT Id,Name FROM User WHERE Id=:f.CreatedById LIMIT 1].Name;
		    			String createdTime = f.CreatedDate.format();
						String articleTitle = parentKAVlist[0].Title;
						String newCaseSubject = 'FLAGGED: ' + articleTitle;
						String newCaseDescription = 'Flagged by ' + createdByName + ' at ' + createdTime + ':\n' + f.body.toLowerCase();
						System.debug('XXXXX Article Chatter FLAG TITLE:  ' + articleTitle);
						
						List<Case> priorCases = [SELECT Id,Description FROM Case 
						                                               WHERE Type=:flaggedArticleCaseType	
						                                               		 AND AccountId=null
						                                               		 AND Status!='Closed'
						                                               		 AND Status!='Cancelled'			                                                      
						                                                     AND Flagged_Article_Id__c=:parentId];
						if (priorCases.size()>0) {
							Case priorCase = priorCases[0];
							priorCase.Description = priorCase.Description + '\n- - - - - - - - - - - - - -\n' + newCaseDescription;
							System.debug('XXXXX Prior Case Description is now: ' + priorCase.Description);
							flaggedArticleCaseUpdates.add(priorCase);
						} else {
							Case newCase = new Case();
							
							List<RecordType> rts = [select id from RecordType where Name = 'Admin' and SobjectType = 'Case'];
						    if(!rts.isempty()){
						    	newCase.RecordTypeId = rts[0].id;
						    }
							
							newCase.Origin = flaggedArticleCaseOrigin;
							newCase.Type = flaggedArticleCaseType;
							newCase.Subject = newCaseSubject;
							newCase.Description = newCaseDescription;
							newCase.Flagged_Article_Id__c = parentId;
							newCase.OwnerId = [SELECT Id,Name FROM Group WHERE Name ='Feedback' and Type = 'Queue' limit 1].Id;
							flaggedArticleCaseInserts.add(newCase);
							System.debug('XXXXX Should insert new case');
							System.debug('XXXXX New case subject: ' + newCase.Subject);
							System.debug('XXXXX New case description: ' + newCase.Description);
						}
					}
				}
		    }
		}
		
	}
	if (flaggedArticleCaseUpdates.size()>0) { update flaggedArticleCaseUpdates; }
	if (flaggedArticleCaseInserts.size()>0) { insert flaggedArticleCaseInserts; }
}