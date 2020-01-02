@isTest(SeeAllData=true)
private class TestCreateRQIAQICtrl {

    static testMethod void testRQIAQICtrl() {
        CreateRQIAQICtrl CRAC = new CreateRQIAQICtrl();
        
        List<case> needOneCase = [select id from case limit 1];
        
        //Case Testing
        //test already audited case
        ApexPages.currentPage().getParameters().put('id',needOneCase[0].id);
    	ApexPages.currentPage().getParameters().put('authorId',TestAQIRQIUtils.createTestAgent(UserInfo.getUserID()).Id);
    	ApexPages.currentPage().getParameters().put('casesorarticles','retCases');
    	CRAC.createAudit(); 
        
        //test new Case w/o related articles
    	ApexPages.currentPage().getParameters().put('id',needOneCase[0].id);
    	ApexPages.currentPage().getParameters().put('authorId',TestAQIRQIUtils.createTestAgent(UserInfo.getUserID()).Id);
    	ApexPages.currentPage().getParameters().put('casesorarticles','retCases');
    	CRAC.createAudit();   
    	
    	
    	//test case KCS known vs new
    		//test KCS known
    	/*	Case caseObj = [
	            SELECT Id,KCS_Known_vs_New__c,OwnerId
	            FROM Case
	            WHERE KCS_Known_vs_New__c='Known'
	            AND Id NOT IN (SELECT Case__c FROM RQI_Audit__c)
	            LIMIT 1
	        ];
	        ApexPages.currentPage().getParameters().put('id',caseObj.Id);
	    	ApexPages.currentPage().getParameters().put('authorId',caseObj.OwnerId);
	    	ApexPages.currentPage().getParameters().put('casesorarticles','retCases');
	    	CRAC.createAudit(); 
    		//test KCS new
	    		caseObj = [
	            SELECT Id,KCS_Known_vs_New__c,OwnerId
	            FROM Case
	            WHERE KCS_Known_vs_New__c='New'
	            AND Id NOT IN (SELECT Case__c FROM RQI_Audit__c)
	            LIMIT 1
	        ];
	        ApexPages.currentPage().getParameters().put('id',caseObj.Id);
	    	ApexPages.currentPage().getParameters().put('authorId',caseObj.OwnerId);
	    	ApexPages.currentPage().getParameters().put('casesorarticles','retCases');
	    	CRAC.createAudit(); 
    		//test KCS N/A
    		caseObj = [
	            SELECT Id,KCS_Known_vs_New__c,OwnerId
	            FROM Case
	            WHERE KCS_Known_vs_New__c='N/A'
	            AND Id NOT IN (SELECT Case__c FROM RQI_Audit__c)
	            LIMIT 1
	        ];
	        ApexPages.currentPage().getParameters().put('id',caseObj.Id);
	    	ApexPages.currentPage().getParameters().put('authorId',caseObj.OwnerId);
	    	ApexPages.currentPage().getParameters().put('casesorarticles','retCases');
	    	CRAC.createAudit(); 
	    	*/
		//test a case with related articles
    	//-----
    	
    	//Article Testing
    	//test new Article
    	
    	List<KnowledgeArticleVersion> kavs = [Select Title from KnowledgeArticleVersion where Publishstatus = 'online' and language = 'en_US' limit 1];
    	if(!kavs.isEmpty()){
	    	ApexPages.currentPage().getParameters().put('id',kavs[0].id);
	    	ApexPages.currentPage().getParameters().put('authorId',TestAQIRQIUtils.createTestAgent(UserInfo.getUserID()).Id);
	    	ApexPages.currentPage().getParameters().put('casesorarticles','retArticles');
	    	CRAC.createAudit(); 
    	}
    	
    	
    	
    	//test for neither case or article
    	ApexPages.currentPage().getParameters().put('casesorarticles','');
    	CRAC.createAudit(); 
    }
}