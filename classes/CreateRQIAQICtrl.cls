public with sharing class CreateRQIAQICtrl {

	public String redirectUrl { get; set; }
	public boolean alreadyExist { get; set; }
	public boolean validRequest { get; set; }
	public String  newAuditId { get; set; }
	public CreateRQIAQICtrl() {
		redirectUrl = 'not set';
		alreadyExist = false;
		validRequest = false;		
	}
	
	
	
	
	public PageReference createAudit(){
    	String idToUse = apexpages.currentpage().getparameters().get('id');
    	String authorIdToUse = apexpages.currentpage().getparameters().get('authorId');
    	String cType = apexpages.currentpage().getparameters().get('casesorarticles');
    	validRequest = true;	
    	if(''.equals(cType) || ''.equals(authorIdToUse) || ''.equals(idToUse) ){
    		validRequest = false;
    	}
    	
    	if(cType.equals('retCases')){
    		
    		
    		List<RQI_Audit__c> audits = [SELECT id FROM RQI_Audit__c where Case__c=:idToUse];
    		
    		
    		if(audits.size()>0){
    			alreadyExist = true;
    			redirectUrl = '/'+ audits[0].Id;
    			return null;
    		}
    		
    		RQI_Audit__c newRQIAudit = new RQI_Audit__c();
    		
    		newRQIAudit.Case__c = idToUse;
    		newRQIAudit.OwnerId = UserInfo.getUserId();
    		newRQIAudit.Author__c = authorIdToUse;
    		newRQIAudit.Status__c = 'New';
    		
    		Case c = [SELECT Id,KCS_Known_vs_New__c FROM Case WHERE Id=:idtoUse LIMIT 1];
    		List<RecordType> recType;
    		if(c.KCS_Known_vs_New__c!=null){
	    		if(c.KCS_Known_vs_New__c.equals('New')){
	    			recType = [SELECT Id FROM RecordType WHERE Name='New Case'];
	    			newRQIAudit.RecordTypeId =recType[0].Id;
	    		}else if(c.KCS_Known_vs_New__c.equals('Known')){
	    			recType = [SELECT Id FROM RecordType WHERE Name='Known Case'];
	    			newRQIAudit.RecordTypeId = recType[0].Id;
	    		}else if(c.KCS_Known_vs_New__c.equals('N/A')){
	    			recType = [SELECT Id FROM RecordType WHERE Name='No Article'];
	    			newRQIAudit.RecordTypeId = recType[0].Id;
	    		}
    		}else{
    			recType = [SELECT Id FROM RecordType WHERE Name='No Article'];
    			newRQIAudit.RecordTypeId = recType[0].Id;
    		}
    		insert newRQIAudit;
    		
    		List<RQI_Related_Article__c> listOfRelatedArticles=new List<RQI_Related_Article__c>();
    		Map<String,String> ArticleCreatedBridge = new Map<String,String>();
    		// query and get the list of related articles follow the logic in the Trigger
    		for(CaseArticle ca: [Select Id, KnowledgeArticleId, CaseId from CaseArticle Where CaseId =: idtoUse]){
	    		ArticleCreatedBridge.put(ca.KnowledgeArticleId,ca.CaseId);
		    }
		    
		    for(KnowledgeArticleVersion kav: [SELECT Id,ArticleType,Title FROM KnowledgeArticleVersion WHERE PublishStatus='Online' AND Language = 'en_US' AND KnowledgeArticleId IN : ArticleCreatedBridge.keySet()]){        
				RQI_Related_Article__c newRQIRelatedArticle = new RQI_Related_Article__c();
				newRQIRelatedArticle.RQI_Audit__c = newRQIAudit.id;
		        newRQIRelatedArticle.Article_ID__c = (String) kav.Id;
		        newRQIRelatedArticle.Article_Title__c = (String)kav.Title;
		        newRQIRelatedArticle.Article_Type__c = (String)kav.ArticleType;
		        listOfRelatedArticles.add(newRQIRelatedArticle);
		    }
		    
		    if(listOfRelatedArticles.size()>0){
		    	insert listOfRelatedArticles;
		    }
    		
		    //get the id of the new audit to redirect the user to it
		    newAuditId=newRQIAudit.Id;
		    redirectUrl = '/'+ newAuditId;
    	}else if (cType.equals('retArticles')){
    		
    		List<AQI_Audit__c> audits = [SELECT id FROM AQI_Audit__c where Article_ID__c=:idToUse];
    		
    		
    		if(audits.size()>0){
    			alreadyExist = true;
    			redirectUrl = '/'+ audits[0].Id;
    			return null;
    		}
    		
    		
    		AQI_Audit__c newAQIAudit = new AQI_Audit__c();
	    	newAQIAudit.Article_Id__c = idToUse;
	    	newAQIAudit.OwnerId = UserInfo.getUserId();
	    	newAQIAudit.Author__c = authorIdToUse;
	        newAQIAudit.Status__c = 'New';
	        SObject kav = [Select Title from KnowledgeArticleVersion Where Id =: idToUse];
	        newAQIAudit.Article_Title__c = (String)kav.get('Title');
	        
		    insert newAQIAudit;
		    
		    //get the id of the new audit to redirect the user to it
		    newAuditId=newAQIAudit.Id;
		    redirectUrl = '/'+ newAuditId;
    	} else {
    		//TODO: can't determine cases or articles reload form alert the user
    	}
    	return null;
    }
	
	
	
	
	
}