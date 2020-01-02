@IsTest(SeeAllData=true)
public class TestKcsArticleLink {
	public static Integer CASE_ID = 0001269304;

    static testMethod void testKCS() {
    	/*
    	 CaseArticle curCaseArticle;
        List<sObject> articleList;
        List<Case> caseList = [
            SELECT Id,KCS_Known_vs_New__c
            FROM Case
            LIMIT 3
        ];
        System.assertEquals(3, caseList.size());
            
         update caseList;    
          caseList = [
            SELECT Id,KCS_Known_vs_New__c
            FROM Case
            where Id In: caseList
        ];
        
        for (Case c: caseList){
        	System.assertEquals('N/A', c.KCS_Known_vs_New__c);
        }
          
        articleList = Database.query('SELECT Id, KnowledgeArticleId FROM KnowledgeArticleVersion ' +
        'WHERE PublishStatus = \'Online\' AND Language = \'en_US\' LIMIT 3');
        
        List<CaseArticle> caseArticleList = new List<CaseArticle>();
        for (sObject curArticle : articleList) {
            for (Case curCase: caseList) {
                curCaseArticle = new CaseArticle();
                curCaseArticle.CaseId = curCase.Id;
                curCaseArticle.KnowledgeArticleId = (String)curArticle.get('KnowledgeArticleId');
                caseArticleList.add(curCaseArticle);
            }
        }
        insert caseArticleList;
	   
	   update caseList;
	   
	     caseList = [
	        SELECT Id,KCS_Known_vs_New__c
	        FROM Case
	        where Id In: caseList
	    ];
        
        for (Case c: caseList){
        	System.assertEquals('Known', c.KCS_Known_vs_New__c);
        }
        
       SObject kavObj;
	    kavObj = Schema.getGlobalDescribe().get('HOW_TO_TEMPLATE__kav').newSObject();
	    kavObj.put('Title','Foo Foo Foo Subscription!!!');
	    kavObj.put('UrlName', 'foo-foo-foo-Subscription');
	    kavObj.put('Summary', 'This is a summary!!! Foo. Foo. Foo. Subscription');
	    kavObj.put('Language', 'en_US');
	    kavObj.put('SourceId', caseList[0].id);
	    insert kavObj;
		
	    String q = 'select knowledgeArticleId from KnowledgeArticleVersion where Id = \'' +kavObj.get('Id')+  '\' and PublishStatus = \'Draft\'';
	    kavObj = (KnowledgeArticleVersion)Database.query(q);
         
         
        KbManagement.PublishingService.publishArticle((String)kavObj.get('KnowledgeArticleId'),false);
         
         CaseArticle newCaseArticle = new CaseArticle();
         newCaseArticle.CaseId = caseList[0].id;
	     newCaseArticle.KnowledgeArticleId = (String)kavObj.get('KnowledgeArticleId');
	     insert newCaseArticle;
         update caseList;
         
         Case c = [SELECT Id,KCS_Known_vs_New__c
            FROM Case
            where Id =: caseList[0].id];
         
         System.assertEquals('New', c.KCS_Known_vs_New__c);
         
     	KCSSchedulableJob theJob = new KCSSchedulableJob();
     	    
     	   BatchKCSJob task = new BatchKCSJob();
     	   task.queryLimit = 50;
     	   
           database.executebatch(task,50);
           
           
           KCSGroupsSchedulableJob theKCSGroupJob = new KCSGroupsSchedulableJob();
     	    
     	   BatchKCSGroupsJob taskKCSGroup = new BatchKCSGroupsJob();
     	   taskKCSGroup.queryLimit = 50;
           database.executebatch(taskKCSGroup,1000);
     	*/
     	 
    }
    
    
    
    
}