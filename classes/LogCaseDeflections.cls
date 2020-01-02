global with sharing class LogCaseDeflections {


	public LogCaseDeflections(){
	}
	

	public LogCaseDeflections(apexPages.standardController std){
	}

		@RemoteAction
	global static String incrementCount(String theContactId){
		
		List<User> theUser = [select contactId from user where Id = :Userinfo.getUserId() ];
		
		
		if(!theUser.isEmpty() && theUser[0].ContactId!=null){
			
			List<Case_Deflection_Article_Clicks__c> clicks = [select id,Click_Count__c from Case_Deflection_Article_Clicks__c where contact__c =: theUser[0].ContactId];
			
			if(!clicks.isEmpty()){
				if(clicks[0].Click_Count__c == null){
					clicks[0].Click_Count__c = 0;
				}
				
				clicks[0].Click_Count__c = clicks[0].Click_Count__c + 1;
				update clicks;
			}else{
				Case_Deflection_Article_Clicks__c clickCounts = new Case_Deflection_Article_Clicks__c();
				clickCounts.contact__c = theUser[0].ContactId;
				clickCounts.Click_Count__c = 1;
				insert clickCounts;
			}
			
			
		}
		
		return '';
		
	}
	
	
	
	public void logDeflection(){
		
		String Subject = ApexPages.currentPage().getParameters().get('Subject');
		String ArticleClicked = ApexPages.currentPage().getParameters().get('articleClicked');
		
		List<User> theUser = [select contactId from user where Id = :Userinfo.getUserId() ];
		
		Map <id,String> createdByIds = new Map <id,String>();
		
		if(!theUser.isEmpty() && theUser[0].ContactId!=null){
		
			
			List<String> ArticleClickedIds = ArticleClicked.split(',');
		
    		List<KnowledgeArticleVersion> kavs = [select knowledgeArticleid,title,ArticleNumber,CreatedById,ArticleType from KnowledgeArticleVersion where  publishStatus='online' and language = 'en_US' and  knowledgeArticleid in: ArticleClickedIds];
			
			
			for(KnowledgeArticleVersion theKAV:kavs ){
				if(theKAV.ArticleType=='SOLUTIONS__kav' || theKAV.ArticleType=='TECH_NOTES__kav' || theKAV.ArticleType=='TECHNICAL_ARTICLE__kav' ||
					theKAV.ArticleType=='TROUBLESHOOTING_UTILITIES__kav' || theKAV.ArticleType=='INTERNAL_PROCESSES__kav' || theKAV.ArticleType=='QUESTION_AND_ANSWER__kav' ||
					theKAV.ArticleType=='HOW_TO_TEMPLATE__kav'){
					
					String q = '';
				    q += 'select CreatedBy__c from '+theKAV.ArticleType;
				    q += ' where PublishStatus = \'online\' and Language = \'en_US\' and KnowledgeArticleId = \''+theKAV.knowledgeArticleid+'\'';
				
				    List<SObject> createdBykavs = (List<SObject>)Database.query(q);
					
					createdByIds.put(theKAV.knowledgeArticleid,(String)createdBykavs[0].get('CreatedBy__c'));
					
				}
				
			}
			
			
			
			Portal_Case_Deflection__c pcd = new Portal_Case_Deflection__c();
			
			pcd.contact__c = theUser[0].ContactId;
			
			pcd.Subject__c = Subject;
			
			insert pcd;
			
			List<Article_Case_Deflection_Article__c> acdas = new List<Article_Case_Deflection_Article__c> ();
			
			for(KnowledgeArticleVersion theKAV:kavs ){
				
				Article_Case_Deflection_Article__c acda = new Article_Case_Deflection_Article__c();
				acda.Article_Case_Deflection__c = pcd.Id;
				acda.Article_ID__c = theKAV.knowledgeArticleid;
				acda.Article_Number__c = theKAV.ArticleNumber;
				acda.Article_Author__c = theKAV.CreatedById;
				acda.Article_Title__c = theKAV.title;
				if(createdByIds.containsKey(theKAV.knowledgeArticleid)){
					acda.Article_Knova_Author__c = createdByIds.get(theKAV.knowledgeArticleid);
				}
				acdas.add(acda);
			}
			
			insert acdas;
			
			
		}
		
	}


}