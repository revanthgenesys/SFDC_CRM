public with sharing class CaseUpdateAddCoveoResults {
	
	 public String caseId  { get;set { 
                                articles = new  List<articleWraper>();
                                findTheArticle(value); 
                                } }
        
    public CaseUpdateAddCoveoResults()  {  
    }

    public List<articleWraper> articles;
    
    public List<articleWraper> getArticles()  {
        return articles;
    }
      
    private void findTheArticle(String theCaseId) {
            list<CoveoV2__CoveoCaseAttachedResult__c> caseKnowledgeArticles = [SELECT Id, CoveoV2__ResultUrl__c, CoveoV2__Source__c, CoveoV2__Title__c
                                                                     		   FROM CoveoV2__CoveoCaseAttachedResult__c 
                                                                     		   WHERE CoveoV2__case__c =: theCaseId
                                                                     		     AND CoveoV2__Source__c NOT IN ('Salesforce - Cases','Salesforce - Knowledge - Knowledge KB')];
                                                                              
            articles = new  List<articleWraper>();
            for(CoveoV2__CoveoCaseAttachedResult__c theKB : caseKnowledgeArticles){
                articles.add(new articleWraper(theKB)); 
            }
    }
    
    public class articleWraper {
        public CoveoV2__CoveoCaseAttachedResult__c theArticle{get;set;}
        public String TheURL { get; set; }
        public String theSource { get; set; }
        public String theLabel {get;set;}
        public Boolean isValidUrl {get; set;}
        
        public articleWraper( CoveoV2__CoveoCaseAttachedResult__c theArticle1 )  {
            theArticle = theArticle1;                         
            theSource = TheArticle.CoveoV2__Source__c;
            theLabel = TheArticle.CoveoV2__Title__c;                        
            String sourceUrl = TheArticle.CoveoV2__ResultUrl__c;
            isValidUrl = true;
            
            if ( theSource == 'Web - docs.genesys.com' ) 
                 TheURL = sourceUrl;
            
            else { 
               String artId = getArticleId(sourceUrl);
               if ( artId == 'Invalid Id')
                   isValidUrl = false;
             /*  
               if ( theSource == 'Salesforce - Knowledge - KB') 
            		TheURL = System.Label.Genesys_Authenticated_Portal_URL + 'pkb_Home?id=' + artId;
            */
            	else if ( theSource == 'Salesforce - Questions' )  
            		TheURL = System.Label.Genesys_Authenticated_Portal_URL + 
            	        'community#!/feedtype=SINGLE_QUESTION_DETAIL&dc=SG_ROOT&criteria=OPENQUESTIONS&id=' + artId;
        	}
     	}
    
	   	 private String getArticleId(String srcUrl) {
	    	Boolean validId = true;
	    	String startStr = srcUrl.substringBeforeLast('/');
	    	String endStr = srcUrl.substringAfterLast('?');
	    	
	    	String strId = srcUrl.removeStart(startStr + '/').removeEnd('?' + endStr);
	    	
	    	try {
	    		ID artId = strId;
	    	}
	    	catch (Exception ex)  {
	    		validId = false;
	    	}
	    	
	    	return validId ? strId : 'Invalid Id';
	    }
    }

}