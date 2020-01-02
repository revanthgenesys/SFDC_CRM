public class archiveArticles{

    Boolean more;
    String whatTOdo;
    String thearticleType;
    
    public Integer recordsNumber {get;set;}

    public void thearchiveArticles(){
    
        whatTOdo = ApexPages.currentPage().getParameters().get('task');
    
    	thearticleType = ApexPages.currentPage().getParameters().get('articleType');
    
    	recordsNumber = 0;
    	
    	more = false;
    	
    	boolean isArchived = false;
    
    	list<KnowledgeArticleVersion> kavs = new list<KnowledgeArticleVersion>();
    
    	if(thearticleType != null && thearticleType != ''){
    
	    	if(whatTOdo == 'Archive'){
	    		recordsNumber =  [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'online' and language='en_US' and articleType = :thearticleType  limit 50000].size();
	    		kavs = [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'online' and language='en_US'  and articleType = :thearticleType limit 150];
	    	}else if(whatTOdo == 'DeleteDraft'){
	    		recordsNumber =  [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'draft' and language='en_US'  and articleType = :thearticleType  limit 50000].size();
	    		kavs = [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'draft' and language='en_US' and articleType = :thearticleType  limit 150];
	    	}else if(whatTOdo == 'DeleteArchived'){
	    		recordsNumber =  [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'archived' and language='en_US' and articleType = :thearticleType  limit 50000].size();
	    		kavs = [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'archived' and language='en_US' and articleType = :thearticleType  limit 150];
	    	}else if(whatTOdo == 'DeleteAll'){
	    		recordsNumber =  [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'draft'  and language='en_US' and articleType = :thearticleType  limit 50000].size();
	    		recordsNumber += [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'archived'  and language='en_US'  and articleType = :thearticleType  limit 50000].size();
	    		kavs = [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'archived' and language='en_US' and articleType = :thearticleType  limit 150];
	    		if(kavs.isEmpty()){
	    			kavs = [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'archived' and language='en_US' and articleType = :thearticleType  limit 150];
	    			isArchived = true;
	    		}
	    	}
    	}else{
    		if(whatTOdo == 'Archive'){
	    		recordsNumber =  [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'online' and language='en_US' limit 50000].size();
	    		kavs = [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'online' and language='en_US' limit 150];
	    	}else if(whatTOdo == 'DeleteDraft'){
	    		recordsNumber =  [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'draft' and language='en_US' limit 50000].size();
	    		kavs = [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'draft' and language='en_US' limit 150];
	    	}else if(whatTOdo == 'DeleteArchived'){
	    		recordsNumber =  [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'archived' and language='en_US' limit 50000].size();
	    		kavs = [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'archived' and language='en_US' limit 150];
	    	}else if(whatTOdo == 'DeleteAll'){
	    		recordsNumber =  [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'draft'  and language='en_US' limit 50000].size();
	    		recordsNumber += [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'archived'  and language='en_US' limit 50000].size();
	    		kavs = [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'archived' and language='en_US' limit 150];
	    		if(kavs.isEmpty()){
	    			kavs = [select knowledgeArticleId from KnowledgeArticleVersion where publishStatus = 'archived' and language='en_US' limit 150];
	    			isArchived = true;
	    		}
    	}
    	}
    
        for(KnowledgeArticleVersion kav:kavs){
            String articleId = kav.knowledgeArticleId;
            Datetime scheduledDate = Datetime.now();
            try{
	            if(whatTOdo == 'Archive'){
		    		KbManagement.PublishingService.archiveOnlineArticle (articleId,scheduledDate);
		    	}else if(whatTOdo == 'DeleteArchived'){
		    		KbManagement.PublishingService.deleteArchivedArticle(articleId);
		    	}else if(whatTOdo == 'DeleteDraft'){
		    		KbManagement.PublishingService.deleteDraftArticle(articleId);
		    	}else if(whatTOdo == 'DeleteAll'){
		    		if(isArchived){
		    			KbManagement.PublishingService.deleteArchivedArticle(articleId);
		    		}else{
		    			KbManagement.PublishingService.deleteDraftArticle(articleId);
		    		}
		    	}
            }catch(Exception e){
            	
            }
        }
    
        if(!kavs.isEmpty()){
            more = true;
        }else{
            more = false;
        }
    
    
    }

    public PageReference reloadIt() {
        
        if(more){
        	
        	String articleType = '';
        	if(thearticleType != null && thearticleType != ''){
        		articleType = '&articleType=' +  thearticleType;
        	}
        	
            PageReference budgetPage = new PageReference('/apex/ArchiveArticles?task=' + whatTOdo+articleType);
            budgetPage.setRedirect(true);
            return budgetPage;
        }else{
            return null;
        }
        
        

         
    }
    
     public static testMethod void testArchive(){
    
    
    	archiveArticles archiveA = new archiveArticles();
    	ApexPages.currentPage().getParameters().put('task','Archive');
    	archiveA.thearchiveArticles();
    	ApexPages.currentPage().getParameters().put('task','DeleteDraft');
    	archiveA.thearchiveArticles();
    	ApexPages.currentPage().getParameters().put('task','DeleteArchived');
    	archiveA.thearchiveArticles();
    
    	archiveA.reloadIt();
    
    
     }




}