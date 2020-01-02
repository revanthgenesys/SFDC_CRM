public with sharing class articleRedirectController {

	public String redirectUrl { get; set; }
	public boolean validRedirect { get; set; }
	
	public articleRedirectController() {
		redirectUrl = 'not set';
		validRedirect = false;
		
		// get the id from the url
		String id = ApexPages.currentPage().getParameters().get('id');

		Map<String, Document_Link_Map__c> settings = Document_Link_Map__c.getAll();
		String theUrlName = '';
		
		if( settings.containsKey(id) ) {
			
			List<Product_Manuals_and_Help_Files__kav> docsP = new List<Product_Manuals_and_Help_Files__kav>();
			List<Release_Advisory__kav> docsA = new List<Release_Advisory__kav>();
			List<Release_Notes__kav> docsR = new List<Release_Notes__kav>();
			List<Third_Party_Documentation__kav> docsT = new List<Third_Party_Documentation__kav>();
			
			
			docsP = [
				Select a.UrlName From Product_Manuals_and_Help_Files__kav a 
					where a.Title__c = :settings.get(id).Alfresco_DL_Title__c.replaceAll('\\(\\w*\\s\\d*\\)$', '') and 
						  publishstatus = 'online' and 
						  language = 'en_US'
			];
			
			if(docsP.size() == 0){
				docsA = [
				Select a.UrlName From Release_Advisory__kav a 
					where a.Title__c = :settings.get(id).Alfresco_DL_Title__c.replaceAll('\\(\\w*\\s\\d*\\)$', '') and 
						  publishstatus = 'online' and 
						  language = 'en_US'
				];
				if(docsA.size() == 0){
					docsR = [
					Select a.UrlName From Release_Notes__kav	 a 
						where a.Title__c = :settings.get(id).Alfresco_DL_Title__c.replaceAll('\\(\\w*\\s\\d*\\)$', '') and 
							  publishstatus = 'online' and 
							  language = 'en_US'
					];
					if(docsR.size() == 0){
						docsT = [
						Select a.UrlName From Third_Party_Documentation__kav a 
							where a.Title__c = :settings.get(id).Alfresco_DL_Title__c.replaceAll('\\(\\w*\\s\\d*\\)$', '') and 
								  publishstatus = 'online' and 
								  language = 'en_US'
						];
						if(docsT.size() > 0){
							theUrlName = docsT.get(0).UrlName;
						}
						
						
					}else {
					theUrlName = docsR.get(0).UrlName;
					}
				}else {
				theUrlName = docsA.get(0).UrlName;
				}
				
				
			}else {
				theUrlName = docsP.get(0).UrlName;
			}
			
			
		}
		
		if( theUrlName != '') {
			validRedirect = true;
			redirectUrl = '/articles/Alfresco_Document/'+theUrlName;
		} else {
						
			// failover, if it's not an alfresco DL id, see if it's article link
			List<KnowledgeArticleVersion> kavs = [
				Select k.ArticleType From KnowledgeArticleVersion k 
					where k.UrlName = :id and 
						  publishstatus = 'online' and 
						  language = 'en_US'
			];
			
			if( kavs.size() > 0 ) {
				validRedirect = true;
				redirectUrl = '/articles/'+kavs.get(0).ArticleType.replaceAll('__kav$','')+'/'+id;
			}
		}
	}
	
	static testMethod void testRedirects() {
        Test.setCurrentPage(Page.articleRedirect);
		
		// create a knova article to redirect and publish it
		String aDocId = '09876543210987654321';
		String aTitle = 'Unit test alfresco document';
		Third_Party_Documentation__kav aDoc = new Third_Party_Documentation__kav(validationStatus='Work in Progress', UrlName=aDocId, Title__c=aTitle, Title=aTitle);
		insert aDoc;
		Third_Party_Documentation__kav d2 = [ Select a.KnowledgeArticleId From Third_Party_Documentation__kav a where a.id = :aDoc.id and publishstatus = 'draft' and language = 'en_US'];
		KbManagement.PublishingService.publishArticle(d2.KnowledgeArticleId, true);
				
		// map the article w/ custom setting
		String rDocId = 'relationId1234';
		Document_Link_Map__c dlMap = new Document_Link_Map__c(Name=rDocId, Alfresco_DL_Title__c=aTitle);
		insert dlMap;
		
		// create a normal article and publish
		String articleId = '12345678901234567890';
		TECH_NOTES__kav article = new TECH_NOTES__kav(validationStatus='Work in Progress', UrlName=articleId, Title='Unit test tech note');
		insert article;
		TECH_NOTES__kav a2 = [ Select a.KnowledgeArticleId From TECH_NOTES__kav a where a.id = :article.id and publishstatus = 'draft' and language = 'en_US'];
		KbManagement.PublishingService.publishArticle(a2.KnowledgeArticleId, true);
		
		// test redirect to knova article
		ApexPages.currentPage().getParameters().put('id', rDocId);
		articleRedirectController controller = new articleRedirectController();
		System.assertEquals('/articles/Alfresco_Document/'+aDocId, controller.redirectUrl);
		System.assertEquals(true, controller.validRedirect);
		
		
		// test redirect to normal article
		ApexPages.currentPage().getParameters().put('id', articleId);
		controller = new articleRedirectController();
		System.assertEquals('/articles/TECH_NOTES/'+articleId, controller.redirectUrl);
		System.assertEquals(true, controller.validRedirect);
		
	}	
}