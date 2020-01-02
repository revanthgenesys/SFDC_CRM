trigger caseArticleCheck on Case (before update) {

	
	List<User> theCurrentUser;
	if(!test.isRunningTest()){
		theCurrentUser= [select UserPermissionsKnowledgeUser from User where Id=:Userinfo.getUserId()];
	}

	// /!\ NOTE: The BatchKCSJob  BATCH JOB is created to update the cases that were changed by a user not having a knowledge license
	// THe cases changes for user having the knowledge license will be in this trigger.

	if(test.isRunningTest() || (theCurrentUser != null && !theCurrentUser.isEmpty() && theCurrentUser[0].UserPermissionsKnowledgeUser)){
		System.debug(' popopo if' );
	    Map<String,Case> caseMap = new Map<String,Case>();
	    Map<String,Case> noArticlesCase = new Map<String,Case>();
	    
	    for(case c: trigger.new){
	    	if(test.isRunningTest()){
	    		//setting it to true to test the batch job
	    		c.NeedKCSRerun__c = true;
	    	}
	        caseMap.put(c.Id,c);
	        noArticlesCase.put(c.Id,c);
	    }
	    
	    Map<String,Case> casesWithArticles = new Map<String,Case>();
	    Map<String,Case> ArticleCaseBridge = new Map<String,Case>();
	    Map<String,String> ArticleCreatedBridge = new Map<String,String>();
	    Map<String,Case> casesWithAttchResults = new Map<String, Case>();
	    
	    for(CaseArticle ca: [Select KnowledgeArticleId, CaseId, CreatedById from CaseArticle Where CaseId IN : caseMap.keySet()]){
	        casesWithArticles.put(ca.CaseId,caseMap.get(ca.CaseId));
	        ArticleCreatedBridge.put(ca.KnowledgeArticleId,ca.CreatedById);
	        ArticleCaseBridge.put(ca.CreatedById,caseMap.get(ca.CaseId));
	        noArticlesCase.remove(ca.CaseId);
	    }
	    
	    List<Case> SourceCases = new List<Case>();
	    List<Case> CitationCases = new List<Case>();
	    
	    for(KnowledgeArticleVersion kav: [SELECT SourceId, CreatedById, KnowledgeArticleId FROM KnowledgeArticleVersion WHERE PublishStatus='Online' AND Language = 'en_US' AND KnowledgeArticleId IN : ArticleCreatedBridge.keySet()]){        
	        if(kav.CreatedById != ArticleCreatedBridge.get(kav.KnowledgeArticleId)){               
	            CitationCases.add(ArticleCaseBridge.get(ArticleCreatedBridge.get(kav.KnowledgeArticleId)));
	        }
	        if(casesWithArticles.keySet().contains(kav.SourceId)){
	            SourceCases.add(casesWithArticles.get(kav.SourceId));
	            casesWithArticles.remove(kav.SourceId);
	        }
	    }   
	
	    for(Case c: CitationCases){
	        c.KCS_Article_Citation__c = true;
	        if(test.isRunningTest()){
	    		//setting it to true to test the batch job
	    		c.NeedKCSRerun__c = true;
	    	}else{
	    		c.NeedKCSRerun__c = false;
	    	}
	    }
	      
	    for(Case c: SourceCases){
	        c.KCS_Known_Vs_New__c = 'New';
	        c.KCS_Has_Article_Linked__c = true;
	        if(test.isRunningTest()){
	    		//setting it to true to test the batch job
	    		c.NeedKCSRerun__c = true;
	    	}else{
	    		c.NeedKCSRerun__c = false;
	    	}
	    }
	    
	   for(CoveoV2__CoveoCaseAttachedResult__c atres : [Select CoveoV2__case__c, CreatedById from CoveoV2__CoveoCaseAttachedResult__c Where CoveoV2__case__c IN : caseMap.keySet()]) {
	      casesWithAttchResults.put(atres.CoveoV2__case__c, caseMap.get(atres.CoveoV2__case__c));
	   }
	
	   //for(Case c: casesWithArticles.values()){
	   for (Case c : casesWithAttchResults.values()) {
	        c.KCS_Known_Vs_New__c = 'Known';
	        c.KCS_Has_Article_Linked__c = true;
	        noArticlesCase.remove(c.Id);
	        if(test.isRunningTest()){
	    		//setting it to true to test the batch job
	    		c.NeedKCSRerun__c = true;
	    	}else{
	    		c.NeedKCSRerun__c = false;
	    	}
	    }
	    
	    for(Case c: noArticlesCase.values()){
	        c.KCS_Known_vs_New__c = 'N/A';
	        if(test.isRunningTest()){
	    		//setting it to true to test the batch job
	    		c.NeedKCSRerun__c = true;
	    	}else{
	    		c.NeedKCSRerun__c = false;
	    	}
	    }
        	
	} else {
		System.debug(' popopo else' );
		if((theCurrentUser != null && !theCurrentUser.isEmpty() && !theCurrentUser[0].UserPermissionsKnowledgeUser)){
			for(case c: trigger.new){
		        c.NeedKCSRerun__c = true;
		        System.debug(' popopo need?' + c.NeedKCSRerun__c );
		    }
			
		}
	}
	
	if(!test.isRunningTest()){
		System.debug(' popopo ' + theCurrentUser[0].UserPermissionsKnowledgeUser);
	
	}
	
	
}