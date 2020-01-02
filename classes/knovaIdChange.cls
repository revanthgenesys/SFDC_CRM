public with sharing class knovaIdChange {




	boolean hasMore {get;set;}
	
	public Integer theNumber {get;set;}
	
	public Integer updatedArticles {get;set;}

	String isForDraft;

	List<String> ids = new List<String>();
	
	Map<String,String> idsMap = new Map<String,String>();
	
	public String neededIds  {get;set;}
	
	
	public Integer neededIdsInt  {get;set;}

	public knovaIdChange(){
		
		
		
	}
	public void doKnovaIdChange(){
		String articleType = ApexPages.currentPage().getParameters().get('articleType');
		isForDraft = ApexPages.currentPage().getParameters().get('isDraft');
		ids = new List<String>();
		
		neededIds = '';
		
		ids.add('62356935');
		ids.add('62498575');
		ids.add('61868952');
		ids.add('62340205');
		ids.add('62048310');
		ids.add('62285126');
		ids.add('62289298');
		ids.add('62277465');
		ids.add('62841316');
		ids.add('61988209');
		ids.add('62304648');
		ids.add('62241203');
		ids.add('62380063');
		ids.add('61957791');
		ids.add('62256396');
		ids.add('61649159');
		ids.add('61644728');
		ids.add('61617445');
		ids.add('61995460');
		ids.add('62277466');
		ids.add('62027291');
		ids.add('61600944');
		ids.add('61943390');
		ids.add('62408769');
		ids.add('61501892');
		ids.add('62216873');
		ids.add('61853641');
		ids.add('62089114');
		ids.add('61495383');
		ids.add('62137270');
		ids.add('62027289');
		ids.add('62506725');
		ids.add('62278979');
		ids.add('61886425');
		ids.add('61687251');
		ids.add('62030461');
		ids.add('62234939');
		ids.add('62218051');
		ids.add('61562062');
		ids.add('62360258');
		ids.add('62367376');
		ids.add('62306781');
		ids.add('61649143');
		ids.add('61989063');
		ids.add('61559606');
		ids.add('62920991');
		ids.add('61731501');
		ids.add('61616824');
		ids.add('61495439');
		ids.add('62081789');
		ids.add('62075019');
		ids.add('61600943');
		ids.add('62041424');
		ids.add('61908704');
		ids.add('61967403');
		ids.add('61960480');
		ids.add('62537171');
		ids.add('62313370');
		ids.add('61619459');
		ids.add('61644729');
		ids.add('62498576');
		ids.add('61914906');
		
		idsMap = new Map<String,String>();
		
		idsMap.put('62356935', 'Arnaldo Sepulveda-Espinosa');
		idsMap.put('62498575', 'Valdinei De Oliveira');
		idsMap.put('61868952', 'Artem Kobzarenko');
		idsMap.put('62340205', 'Tanya Wright ');
		idsMap.put('62048310', 'Paul Campbell ');
		idsMap.put('62285126', 'Wesley Westhaver ');
		idsMap.put('62289298', 'Michael Murray ');
		idsMap.put('62277465', 'Constantine Panfilov'); 
		idsMap.put('62841316', 'Derek Bonds ');
		idsMap.put('61988209', 'Danylo Bilas ');
		idsMap.put('62304648', 'Semen Fedorenko ');
		idsMap.put('62241203', 'Trevor Armstrong ');
		idsMap.put('62380063', 'Steven Timmons ');
		idsMap.put('61957791', 'Igor Gordienko ');
		idsMap.put('62256396', 'Artem Dyl ');
		idsMap.put('61649159', 'Julian Quintero'); 
		idsMap.put('61644728', 'Peter Clarke ');
		idsMap.put('61617445', 'Vipul Mahadeshwar'); 
		idsMap.put('62418959', 'Christopher McLeod'); 
		idsMap.put('61995460', 'Troy Mortimer ');
		idsMap.put('62277466', 'Sergii Prokhorov ');
		idsMap.put('62027291', 'Alexander Voronkov ');
		idsMap.put('61600944', 'Ariful Hoque ');
		idsMap.put('61943390', 'Alexey Komarchuk'); 
		idsMap.put('62408769', 'Anton Dedyukh');
		idsMap.put('61501892', 'Gagan Gupta');
		idsMap.put('62216873', 'Pawel Nastaj');
		idsMap.put('61853641', 'Phillip Perry');
		idsMap.put('62089114', 'Charlene Mladineo');
		idsMap.put('61495383', 'Vadim Mityanin');
		idsMap.put('62137270', 'Andrey Gnatyuk');
		idsMap.put('62027289', 'Andrii Bezuglov');
		idsMap.put('62506725', 'Iurii Komar');
		idsMap.put('62278979', 'Joel Segura');
		idsMap.put('61886425', 'Carlos Rojas');
		idsMap.put('61687251', 'David Crewe');
		idsMap.put('62030461', 'Brett Dale');
		idsMap.put('62234939', 'James Rocca');
		idsMap.put('62218051', 'Alpana Sawant');
		idsMap.put('61562062', 'Mykyta Volkov');
		idsMap.put('62360258', 'Michael Pougnet');
		idsMap.put('62367376', 'Richard Mayes');
		idsMap.put('62306781', 'Sharavanan V');
		idsMap.put('61649143', 'Hilvar Norena');
		idsMap.put('61989063', 'Kerulkumar Patel');
		idsMap.put('61559606', 'Stanislav Zaletskiy');
		idsMap.put('62920991', 'William Thirion');
		idsMap.put('61731501', 'Adilson Ferreira');
		idsMap.put('61616824', 'Timothy MacTavish');
		idsMap.put('61495439', 'Sergey Svirgunenko');
		idsMap.put('62081789', 'Poras Bharucha');
		idsMap.put('62075019', 'Teena Westhaver');
		idsMap.put('61600943', 'Ryan Wilson');
		idsMap.put('62041424', 'Randy Garland');
		idsMap.put('61908704', 'Surenther Thevendranathan');
		idsMap.put('61967403', 'Palash Verma');
		idsMap.put('61960480', 'Thomas Bateman');
		idsMap.put('62537171', 'Justin Fralic');
		idsMap.put('62313370', 'Antti Kahkonen');
		idsMap.put('61619459', 'Corey MacMichael');
		idsMap.put('61644729', 'Dena Carter');
		idsMap.put('62498576', 'Wesley Dos Santos');
		idsMap.put('61914906', 'Mike Ponting');
		
		
		if(articleType=='SOLUTIONS__kav'){
			changeSolIds();
		}
		if(articleType=='TECH_NOTES__kav'){
			changetechNIds();
		}
		if(articleType=='TECHNICAL_ARTICLE__kav'){
			changetechAIds();
		}
		if(articleType=='TROUBLESHOOTING_UTILITIES__kav'){
			changeTUIds();
		}
		if(articleType=='INTERNAL_PROCESSES__kav'){
			changeISIds();
		}
		if(articleType=='QUESTION_AND_ANSWER__kav'){
			changeQAIds();
		}
		if(articleType=='HOW_TO_TEMPLATE__kav'){
			changeHTIds();
		}
	}




	public void changeSolIds(){
		
		
		
		/**************************************Draft******************/
			if(isForDraft == 'true'){
				List<SOLUTIONS__kav> sols0 = [Select knowledgeArticleId,CreatedBy__c From SOLUTIONS__kav s where  publishStatus='Draft' and language='en_US' and CreatedBy__c in:ids limit 150]; 
				System.debug(' theNumber is ' + sols0.size() );
				integer theCount = 0;
				for(SOLUTIONS__kav sol:sols0 ){
					if(theCount<150){
						String articleId = sol.knowledgeArticleId;
						sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
						update sol;
					}
					theCount++;
				}
				hasmore = (sols0.size()>100);
			theNumber = sols0.size();
			
			updatedArticles = sols0.size();
				return;
			}
			
			/**************************************ONLINE*
			*******************************/
			List<SOLUTIONS__kav> AllDraftsols0 = [Select knowledgeArticleId,CreatedBy__c From SOLUTIONS__kav s where  publishStatus='Draft' and language='en_US' ];
			List<String> kbIds  = new List<String>();
					
					for(SOLUTIONS__kav kb:AllDraftsols0){
						kbIds.add(kb.knowledgeArticleId);
					}
			
			
			List<SOLUTIONS__kav> sols01 = [Select knowledgeArticleId,CreatedBy__c From SOLUTIONS__kav s where  publishStatus='Online' and language='en_US' and CreatedBy__c like '6%'  and knowledgeArticleId not in: kbIds]; 
			//We need to find the other Ids that we don't have
			
			System.debug(' theNumber is ' + sols01.size() );
			set<String> theExtraIds = new set<String>();
			integer theCount = 0;
			List<Id> articleTochange = new List<Id>();
			for(SOLUTIONS__kav sol:sols01 ){
				if(idsMap.containsKey(sol.CreatedBy__c)){
					System.debug(' in the map ' );
					if(theCount<70){
						String articleId = sol.knowledgeArticleId;
						
						sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
						KbManagement.PublishingService.editOnlineArticle (articleId, false);
						articleTochange.add(articleId);
				
					}
					theCount++;
				}else{
					System.debug(' out the map ' );
					theExtraIds.add(sol.CreatedBy__c);
				}
			} 
			
			
			
			List<SOLUTIONS__kav> kavsDraftTochange = [Select CreatedBy__c,knowledgeArticleId from SOLUTIONS__kav where publishStatus = 'Draft' and language='en_US'  and knowledgeArticleId in : articleTochange ] ;
					
					
					for(SOLUTIONS__kav kav:kavsDraftTochange){
						System.debug(' b ************************************** ' + kav.CreatedBy__c );
						kav.CreatedBy__c = idsMap.get(kav.CreatedBy__c);
						System.debug(' a ************************************** ' + kav.CreatedBy__c );
					}
					
					update kavsDraftTochange;
					
					
					for(SOLUTIONS__kav kav:kavsDraftTochange){
					String articleId = kav.knowledgeArticleId;
						KbManagement.PublishingService.publishArticle(articleId,false);
					}
					
					
			for(String theId:theExtraIds){
				neededIds += '<br/>' + theId;
			}
			
			
			neededIdsInt = theExtraIds.size();
			
			hasmore = (sols01.size()>70);
			theNumber = sols01.size();
			
			updatedArticles = kavsDraftTochange.size();
			
	}


	public void changeHTIds(){
		
		
		
		
		/**************************************Draft******************/
		if(isForDraft == 'true'){
			List<HOW_TO_TEMPLATE__kav> sols0 = [Select knowledgeArticleId,CreatedBy__c From HOW_TO_TEMPLATE__kav s where  publishStatus='Draft' and language='en_US' and CreatedBy__c in:ids limit 150]; 
			System.debug(' theNumber is ' + sols0.size() );
			integer theCount = 0;
			for(HOW_TO_TEMPLATE__kav sol:sols0 ){
				if(theCount<150){
					String articleId = sol.knowledgeArticleId;
					sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
					update sol;
				}
				theCount++;
			}
			hasmore = (sols0.size()>100);
			theNumber = sols0.size();
			
			updatedArticles = sols0.size();
			return;
			}
			/**************************************ONLINE*
			*******************************/
			List<HOW_TO_TEMPLATE__kav> AllDraftsols0 = [Select knowledgeArticleId,CreatedBy__c From HOW_TO_TEMPLATE__kav s where  publishStatus='Draft' and language='en_US' ];
			List<String> kbIds  = new List<String>();
					
					for(HOW_TO_TEMPLATE__kav kb:AllDraftsols0){
						kbIds.add(kb.knowledgeArticleId);
					}
			
			
			List<HOW_TO_TEMPLATE__kav> sols01 = [Select knowledgeArticleId,CreatedBy__c From HOW_TO_TEMPLATE__kav s where  publishStatus='Online' and language='en_US' and CreatedBy__c like '6%'  and knowledgeArticleId not in: kbIds]; 
			
			
			System.debug(' theNumber is ' + sols01.size() );
			set<String> theExtraIds = new set<String>();
			integer theCount = 0;
			List<Id> articleTochange = new List<Id>();
			for(HOW_TO_TEMPLATE__kav sol:sols01 ){
				if(idsMap.containsKey(sol.CreatedBy__c)){
				if(theCount<70){
					String articleId = sol.knowledgeArticleId;
					sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
					KbManagement.PublishingService.editOnlineArticle (articleId, false);
					articleTochange.add(articleId);
			
				}
				theCount++;
				}else{
					System.debug(' out the map ' );
					theExtraIds.add(sol.CreatedBy__c);
				}
			}
			
			
			
			List<HOW_TO_TEMPLATE__kav> kavsDraftTochange = [Select CreatedBy__c,knowledgeArticleId from HOW_TO_TEMPLATE__kav where publishStatus = 'Draft' and language='en_US'  and knowledgeArticleId in : articleTochange ] ;
					
					
					for(HOW_TO_TEMPLATE__kav kav:kavsDraftTochange){
						System.debug(' b ************************************** ' + kav.CreatedBy__c );
						kav.CreatedBy__c = idsMap.get(kav.CreatedBy__c);
						System.debug(' a ************************************** ' + kav.CreatedBy__c );
					}
					
					update kavsDraftTochange;
					
					
					for(HOW_TO_TEMPLATE__kav kav:kavsDraftTochange){
					String articleId = kav.knowledgeArticleId;
						
									 
							    	KbManagement.PublishingService.publishArticle(articleId,false);
					           
					
					}
			for(String theId:theExtraIds){
				neededIds += '<br/>' + theId;
			}
			
			
			neededIdsInt = theExtraIds.size();
			
			hasmore = (sols01.size()>70);
			theNumber = sols01.size();
			
			updatedArticles = kavsDraftTochange.size();
	}




	public void changeQAIds(){
		
		
		
		/**************************************Draft******************/
		if(isForDraft == 'true'){
			List<QUESTION_AND_ANSWER__kav> sols0 = [Select knowledgeArticleId,CreatedBy__c From QUESTION_AND_ANSWER__kav s where  publishStatus='Draft' and language='en_US' and CreatedBy__c in:ids limit 150]; 
			System.debug(' theNumber is ' + sols0.size() );
			integer theCount = 0;
			for(QUESTION_AND_ANSWER__kav sol:sols0 ){
				if(theCount<150){
					String articleId = sol.knowledgeArticleId;
					sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
					update sol;
				}
				theCount++;
			}
			hasmore = (sols0.size()>100);
			theNumber = sols0.size();
			
			updatedArticles = sols0.size();
			return;
			}
			/**************************************ONLINE*
			*******************************/
			List<QUESTION_AND_ANSWER__kav> AllDraftsols0 = [Select knowledgeArticleId,CreatedBy__c From QUESTION_AND_ANSWER__kav s where  publishStatus='Draft' and language='en_US' ];
			List<String> kbIds  = new List<String>();
					
					for(QUESTION_AND_ANSWER__kav kb:AllDraftsols0){
						kbIds.add(kb.knowledgeArticleId);
					}
			
			
			List<QUESTION_AND_ANSWER__kav> sols01 = [Select knowledgeArticleId,CreatedBy__c From QUESTION_AND_ANSWER__kav s where  publishStatus='Online' and language='en_US' and CreatedBy__c like '6%'  and knowledgeArticleId not in: kbIds]; 
			
			
			System.debug(' theNumber is ' + sols01.size() );
			set<String> theExtraIds = new set<String>();
			integer theCount = 0;
			List<Id> articleTochange = new List<Id>();
			for(QUESTION_AND_ANSWER__kav sol:sols01 ){
				if(idsMap.containsKey(sol.CreatedBy__c)){
			
				if(theCount<70){
					String articleId = sol.knowledgeArticleId;
					sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
					KbManagement.PublishingService.editOnlineArticle (articleId, false);
					articleTochange.add(articleId);
			
				}
				theCount++;
				}else{
					System.debug(' out the map ' );
					theExtraIds.add(sol.CreatedBy__c);
				}
			}
			
			
			
			List<QUESTION_AND_ANSWER__kav> kavsDraftTochange = [Select CreatedBy__c,knowledgeArticleId from QUESTION_AND_ANSWER__kav where publishStatus = 'Draft' and language='en_US'  and knowledgeArticleId in : articleTochange ] ;
					
					
					for(QUESTION_AND_ANSWER__kav kav:kavsDraftTochange){
						System.debug(' b ************************************** ' + kav.CreatedBy__c );
						kav.CreatedBy__c = idsMap.get(kav.CreatedBy__c);
						System.debug(' a ************************************** ' + kav.CreatedBy__c );
					}
					
					update kavsDraftTochange;
					
					
					for(QUESTION_AND_ANSWER__kav kav:kavsDraftTochange){
					String articleId = kav.knowledgeArticleId;
						
									 
							    KbManagement.PublishingService.publishArticle(articleId,false);
					            
					
					}
			for(String theId:theExtraIds){
				neededIds += '<br/>' + theId;
			}
			
			
			neededIdsInt = theExtraIds.size();
			
			hasmore = (sols01.size()>70);
			theNumber = sols01.size();
			
			updatedArticles = kavsDraftTochange.size();
	}


	public void changeISIds(){
		
		
		
		
		/**************************************Draft******************/
		if(isForDraft == 'true'){
			List<INTERNAL_PROCESSES__kav> sols0 = [Select knowledgeArticleId,CreatedBy__c From INTERNAL_PROCESSES__kav s where  publishStatus='Draft' and language='en_US' and CreatedBy__c in:ids limit 150]; 
			System.debug(' theNumber is ' + sols0.size() );
			integer theCount = 0;
			for(INTERNAL_PROCESSES__kav sol:sols0 ){
				if(theCount<150){
					String articleId = sol.knowledgeArticleId;
					sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
					update sol;
				}
				theCount++;
			}
			hasmore = (sols0.size()>100);
			theNumber = sols0.size();
			
			updatedArticles = sols0.size();
			return;
			}
			/**************************************ONLINE*
			*******************************/
			List<INTERNAL_PROCESSES__kav> AllDraftsols0 = [Select knowledgeArticleId,CreatedBy__c From INTERNAL_PROCESSES__kav s where  publishStatus='Draft' and language='en_US' ];
			List<String> kbIds  = new List<String>();
					
					for(INTERNAL_PROCESSES__kav kb:AllDraftsols0){
						kbIds.add(kb.knowledgeArticleId);
					}
			
			
			List<INTERNAL_PROCESSES__kav> sols01 = [Select knowledgeArticleId,CreatedBy__c From INTERNAL_PROCESSES__kav s where  publishStatus='Online' and language='en_US' and CreatedBy__c like '6%'  and knowledgeArticleId not in: kbIds]; 
			
			
			System.debug(' theNumber is ' + sols01.size() );
			set<String> theExtraIds = new set<String>();
			integer theCount = 0;
			List<Id> articleTochange = new List<Id>();
			for(INTERNAL_PROCESSES__kav sol:sols01 ){
				if(idsMap.containsKey(sol.CreatedBy__c)){
				if(theCount<70){
					String articleId = sol.knowledgeArticleId;
					sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
					KbManagement.PublishingService.editOnlineArticle (articleId, false);
					articleTochange.add(articleId);
			
				}
				theCount++;
				}else{
					System.debug(' out the map ' );
					theExtraIds.add(sol.CreatedBy__c);
				}
			}
			
			
			
			List<INTERNAL_PROCESSES__kav> kavsDraftTochange = [Select CreatedBy__c,knowledgeArticleId from INTERNAL_PROCESSES__kav where publishStatus = 'Draft' and language='en_US'  and knowledgeArticleId in : articleTochange ] ;
					
					
					for(INTERNAL_PROCESSES__kav kav:kavsDraftTochange){
						System.debug(' b ************************************** ' + kav.CreatedBy__c );
						kav.CreatedBy__c = idsMap.get(kav.CreatedBy__c);
						System.debug(' a ************************************** ' + kav.CreatedBy__c );
					}
					
					update kavsDraftTochange;
					
					
					for(INTERNAL_PROCESSES__kav kav:kavsDraftTochange){
					String articleId = kav.knowledgeArticleId;
						
									 
							  KbManagement.PublishingService.publishArticle(articleId,false);
					            
					
					}
			for(String theId:theExtraIds){
				neededIds += '<br/>' + theId;
			}
			
			
			neededIdsInt = theExtraIds.size();
			
			hasmore = (sols01.size()>70);
			theNumber = sols01.size();
			
			updatedArticles = kavsDraftTochange.size();
	}



	public void changeTUIds(){
		
		
		
		
			
		/**************************************Draft******************/
		if(isForDraft == 'true'){
			List<TROUBLESHOOTING_UTILITIES__kav> sols0 = [Select knowledgeArticleId,CreatedBy__c From TROUBLESHOOTING_UTILITIES__kav s where  publishStatus='Draft' and language='en_US' and CreatedBy__c in:ids limit 150]; 
			System.debug(' theNumber is ' + sols0.size() );
			integer theCount = 0;
			for(TROUBLESHOOTING_UTILITIES__kav sol:sols0 ){
				if(theCount<150){
					String articleId = sol.knowledgeArticleId;
					sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
					update sol;
				}
				theCount++;
			}
			hasmore = (sols0.size()>100);
			theNumber = sols0.size();
			
			updatedArticles = sols0.size();
			return;
			}
			/**************************************ONLINE*
			*******************************/
			List<TROUBLESHOOTING_UTILITIES__kav> AllDraftsols0 = [Select knowledgeArticleId,CreatedBy__c From TROUBLESHOOTING_UTILITIES__kav s where  publishStatus='Draft' and language='en_US' ];
			List<String> kbIds  = new List<String>();
					
					for(TROUBLESHOOTING_UTILITIES__kav kb:AllDraftsols0){
						kbIds.add(kb.knowledgeArticleId);
					}
			
			
			List<TROUBLESHOOTING_UTILITIES__kav> sols01 = [Select knowledgeArticleId,CreatedBy__c From TROUBLESHOOTING_UTILITIES__kav s where  publishStatus='Online' and language='en_US' and CreatedBy__c like '6%'  and knowledgeArticleId not in: kbIds]; 
			
			
			System.debug(' theNumber is ' + sols01.size() );
			set<String> theExtraIds = new set<String>();
			integer theCount = 0;
			List<Id> articleTochange = new List<Id>();
			for(TROUBLESHOOTING_UTILITIES__kav sol:sols01 ){
				
				if(idsMap.containsKey(sol.CreatedBy__c)){	
				if(theCount<70){
					String articleId = sol.knowledgeArticleId;
					sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
					KbManagement.PublishingService.editOnlineArticle (articleId, false);
					articleTochange.add(articleId);
			
				}
				theCount++;
				}else{
					System.debug(' out the map ' );
					theExtraIds.add(sol.CreatedBy__c);
				}
			}
			
			
			
			List<TROUBLESHOOTING_UTILITIES__kav> kavsDraftTochange = [Select CreatedBy__c,knowledgeArticleId from TROUBLESHOOTING_UTILITIES__kav where publishStatus = 'Draft' and language='en_US'  and knowledgeArticleId in : articleTochange ] ;
					
					
					for(TROUBLESHOOTING_UTILITIES__kav kav:kavsDraftTochange){
						System.debug(' b ************************************** ' + kav.CreatedBy__c );
						kav.CreatedBy__c = idsMap.get(kav.CreatedBy__c);
						System.debug(' a ************************************** ' + kav.CreatedBy__c );
					}
					
					update kavsDraftTochange;
					
					
					for(TROUBLESHOOTING_UTILITIES__kav kav:kavsDraftTochange){
					String articleId = kav.knowledgeArticleId;
						
									 
							   KbManagement.PublishingService.publishArticle(articleId,false);
					            
					
					}
			for(String theId:theExtraIds){
				neededIds += '<br/>' + theId;
			}
			
			
			neededIdsInt = theExtraIds.size();
			
			hasmore = (sols01.size()>70);
			theNumber = sols01.size();
			
			updatedArticles = kavsDraftTochange.size();
	}


	
	public void changetechAIds(){
		
		
		
		
			
		/**************************************Draft******************/
		if(isForDraft == 'true'){
			List<TECHNICAL_ARTICLE__kav> sols0 = [Select knowledgeArticleId,CreatedBy__c From TECHNICAL_ARTICLE__kav s where  publishStatus='Draft' and language='en_US' and CreatedBy__c in:ids limit 150]; 
			System.debug(' theNumber is ' + sols0.size() );
			integer theCount = 0;
			for(TECHNICAL_ARTICLE__kav sol:sols0 ){
				if(theCount<150){
					String articleId = sol.knowledgeArticleId;
					sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
					update sol;
				}
				theCount++;
			}
			hasmore = (sols0.size()>100);
			theNumber = sols0.size();
			
			updatedArticles = sols0.size();
			return;
			}
			/**************************************ONLINE*
			*******************************/
			List<TECHNICAL_ARTICLE__kav> AllDraftsols0 = [Select knowledgeArticleId,CreatedBy__c From TECHNICAL_ARTICLE__kav s where  publishStatus='Draft' and language='en_US' ];
			List<String> kbIds  = new List<String>();
					
					for(TECHNICAL_ARTICLE__kav kb:AllDraftsols0){
						kbIds.add(kb.knowledgeArticleId);
					}
			
			
			List<TECHNICAL_ARTICLE__kav> sols01 = [Select knowledgeArticleId,CreatedBy__c From TECHNICAL_ARTICLE__kav s where  publishStatus='Online' and language='en_US' and CreatedBy__c like '6%'  and knowledgeArticleId not in: kbIds]; 
			
			
			System.debug(' theNumber is ' + sols01.size() );
			set<String> theExtraIds = new set<String>();
			integer theCount = 0;
			List<Id> articleTochange = new List<Id>();
			for(TECHNICAL_ARTICLE__kav sol:sols01 ){
				
				if(idsMap.containsKey(sol.CreatedBy__c)){	
				if(theCount<70){
					String articleId = sol.knowledgeArticleId;
					sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
					KbManagement.PublishingService.editOnlineArticle (articleId, false);
					articleTochange.add(articleId);
			
				}
				theCount++;
				}else{
					System.debug(' out the map ' );
					theExtraIds.add(sol.CreatedBy__c);
				}
			}
			
			
			
			List<TECHNICAL_ARTICLE__kav> kavsDraftTochange = [Select CreatedBy__c,knowledgeArticleId from TECHNICAL_ARTICLE__kav where publishStatus = 'Draft' and language='en_US'  and knowledgeArticleId in : articleTochange ] ;
					
					
					for(TECHNICAL_ARTICLE__kav kav:kavsDraftTochange){
						System.debug(' b ************************************** ' + kav.CreatedBy__c );
						kav.CreatedBy__c = idsMap.get(kav.CreatedBy__c);
						System.debug(' a ************************************** ' + kav.CreatedBy__c );
					}
					
					update kavsDraftTochange;
					
					
					for(TECHNICAL_ARTICLE__kav kav:kavsDraftTochange){
					String articleId = kav.knowledgeArticleId;
						
									 
							KbManagement.PublishingService.publishArticle(articleId,false);
					            
					
					}
			for(String theId:theExtraIds){
				neededIds += '<br/>' + theId;
			}
			
			
			neededIdsInt = theExtraIds.size();
			
			hasmore = (sols01.size()>70);
			theNumber = sols01.size();
			
			updatedArticles = kavsDraftTochange.size();
	}
	
	
	
	
	public void changetechNIds(){
		
		
		
		
		
			
		/**************************************Draft******************/
		if(isForDraft == 'true'){
			List<TECH_NOTES__kav> sols0 = [Select knowledgeArticleId,CreatedBy__c From TECH_NOTES__kav s where  publishStatus='Draft' and language='en_US' and CreatedBy__c in:ids limit 150]; 
			System.debug(' theNumber is ' + sols0.size() );
			integer theCount = 0;
			for(TECH_NOTES__kav sol:sols0 ){
				if(theCount<100){
					String articleId = sol.knowledgeArticleId;
					sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
					update sol;
				}
				theCount++;
			}
			hasmore = (sols0.size()>100);
			theNumber = sols0.size();
			
			updatedArticles = sols0.size();
			return;
			}
			/**************************************ONLINE*
			*******************************/
			List<TECH_NOTES__kav> AllDraftsols0 = [Select knowledgeArticleId,CreatedBy__c From TECH_NOTES__kav s where  publishStatus='Draft' and language='en_US' ];
			List<String> kbIds  = new List<String>();
					
					for(TECH_NOTES__kav kb:AllDraftsols0){
						kbIds.add(kb.knowledgeArticleId);
					}
			
			
			List<TECH_NOTES__kav> sols01 = [Select knowledgeArticleId,CreatedBy__c From TECH_NOTES__kav s where  publishStatus='Online' and language='en_US' and CreatedBy__c like '6%'  and knowledgeArticleId not in: kbIds]; 
			
			
			System.debug(' theNumber is ' + sols01.size() );
			set<String> theExtraIds = new set<String>();
			integer theCount = 0;
			List<Id> articleTochange = new List<Id>();
			for(TECH_NOTES__kav sol:sols01 ){
				if(idsMap.containsKey(sol.CreatedBy__c)){				
				if(theCount<70){
					String articleId = sol.knowledgeArticleId;
					sol.CreatedBy__c = idsMap.get(sol.CreatedBy__c);
					KbManagement.PublishingService.editOnlineArticle (articleId, false);
					articleTochange.add(articleId);
			
				}
				theCount++;
				}else{
					System.debug(' out the map ' );
					theExtraIds.add(sol.CreatedBy__c);
				}
			}
			
			
			
			List<TECH_NOTES__kav> kavsDraftTochange = [Select CreatedBy__c,knowledgeArticleId from TECH_NOTES__kav where publishStatus = 'Draft' and language='en_US'  and knowledgeArticleId in : articleTochange ] ;
					
					
					for(TECH_NOTES__kav kav:kavsDraftTochange){
						System.debug(' b ************************************** ' + kav.CreatedBy__c );
						kav.CreatedBy__c = idsMap.get(kav.CreatedBy__c);
						System.debug(' a ************************************** ' + kav.CreatedBy__c );
					}
					
					update kavsDraftTochange;
					
					
					for(TECH_NOTES__kav kav:kavsDraftTochange){
					String articleId = kav.knowledgeArticleId;
						
									 
							 	KbManagement.PublishingService.publishArticle(articleId,false);
					           
					
					}
			for(String theId:theExtraIds){
				neededIds += '<br/>' + theId;
			}
			
			
			neededIdsInt = theExtraIds.size();
			
			hasmore = (sols01.size()>70);
			theNumber = sols01.size();
			
			updatedArticles = kavsDraftTochange.size();
	}
	
	
	
	
	public PageReference reloadIt() {
        
        if(hasmore){
        	
        	String articleType = ApexPages.currentPage().getParameters().get('articleType');
        	isForDraft = ApexPages.currentPage().getParameters().get('isDraft');
        	if(articleType != null && articleType != ''){
        		articleType = 'articleType=' +  articleType;
        	}
        	
            PageReference budgetPage = new PageReference('/apex/knovaIdChange?' +articleType + '&isDraft='+isForDraft);
            budgetPage.setRedirect(true);
            return budgetPage;
        }else{
            return null;
        }
        
        

         
    }
    
    
    public static testMethod void testArchive(){
    	knovaIdChange kb = new knovaIdChange();
    	
			kb.changeSolIds();
			kb.changetechNIds();
			kb.changetechAIds();
			kb.changeTUIds();
			kb.changeISIds();
			kb.changeQAIds();
			kb.changeHTIds();
    	
    }

	/*
	
	

	public void changeHTIds(){
		
		
		
		List<HOW_TO_TEMPLATE__kav> kavsDraft = [Select knowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from HOW_TO_TEMPLATE__kav where publishStatus = 'Draft' and language='en_US'  and createdById = '005U0000000gYN0' and createdBy__c != null] ;
		
		List<String> kbIds  = new List<String>();
		
		for(HOW_TO_TEMPLATE__kav kb:kavsDraft){
			kbIds.add(kb.knowledgeArticleId);
		}
		System.debug(kavsDraft.size() );
		
		DateTime theTime = Datetime.now()  - (1/4.8) ;
		
		List<HOW_TO_TEMPLATE__kav> kavsonline = [Select KnowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from HOW_TO_TEMPLATE__kav where publishStatus = 'Online' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId not in: kbIds] ;
		
		
		System.debug(kavsonline.size() );
		
		integer count = 0;
		
		List<Id> articleTochange = new List<Id>();
		
		for(HOW_TO_TEMPLATE__kav kav:kavsonline){
			if(count<71){
		            String articleId = kav.knowledgeArticleId;
		            Datetime scheduledDate = Datetime.now();
		            try{
						 
				    	KbManagement.PublishingService.editOnlineArticle(articleId,false);
				    	articleTochange.add(articleId);	
		            }catch(Exception e){
		            	
		            }
		        }
		            count ++;
		}
		
		List<HOW_TO_TEMPLATE__kav> kavsDraftTochange = [Select knowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from HOW_TO_TEMPLATE__kav where publishStatus = 'Draft' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId in : articleTochange ] ;
		
		
		for(HOW_TO_TEMPLATE__kav kav:kavsDraftTochange){
		
			//kav.SUPPLEMENTAL_INFORMATION__c += '<br/>Knova Id: '  + kav.urlName;
			if(kav.SUPPLEMENTAL_INFORMATION__c != null && kav.SUPPLEMENTAL_INFORMATION__c.length()>4 && kav.SUPPLEMENTAL_INFORMATION__c.substring(0,4) == 'null'){
				kav.SUPPLEMENTAL_INFORMATION__c = kav.SUPPLEMENTAL_INFORMATION__c.substring(4);
			}
			
		
		}
		
		update kavsDraftTochange;
		
		
		for(HOW_TO_TEMPLATE__kav kav:kavsDraftTochange){
		String articleId = kav.knowledgeArticleId;
			try{
						 
				    	KbManagement.PublishingService.publishArticle(articleId,false);
		            }catch(Exception e){
		            	
		            }
		
		}
		
		
		hasmore = (kavsonline.size()>70);
		theNumber = kavsonline.size();
		
		updatedArticles = kavsDraftTochange.size();
	}




	public void changeQAIds(){
		
		
		
		List<QUESTION_AND_ANSWER__kav> kavsDraft = [Select knowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from QUESTION_AND_ANSWER__kav where publishStatus = 'Draft' and language='en_US'  and createdById = '005U0000000gYN0' and createdBy__c != null] ;
		
		List<String> kbIds  = new List<String>();
		
		for(QUESTION_AND_ANSWER__kav kb:kavsDraft){
			kbIds.add(kb.knowledgeArticleId);
		}
		System.debug(kavsDraft.size() );
		DateTime theTime = Datetime.now()  - (1/4.8) ;
		
		List<QUESTION_AND_ANSWER__kav> kavsonline = [Select KnowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from QUESTION_AND_ANSWER__kav where publishStatus = 'Online' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId not in: kbIds] ;
		
		
		System.debug(kavsonline.size() );
		
		integer count = 0;
		
		List<Id> articleTochange = new List<Id>();
		
		for(QUESTION_AND_ANSWER__kav kav:kavsonline){
			if(count<71){
		            String articleId = kav.knowledgeArticleId;
		            Datetime scheduledDate = Datetime.now();
		            try{
						 
				    	KbManagement.PublishingService.editOnlineArticle(articleId,false);
				    	articleTochange.add(articleId);	
		            }catch(Exception e){
		            	
		            }
		        }
		            count ++;
		}
		
		List<QUESTION_AND_ANSWER__kav> kavsDraftTochange = [Select knowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from QUESTION_AND_ANSWER__kav where publishStatus = 'Draft' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId in : articleTochange ] ;
		
		
		for(QUESTION_AND_ANSWER__kav kav:kavsDraftTochange){
		
			//kav.SUPPLEMENTAL_INFORMATION__c += '<br/>Knova Id: '  + kav.urlName;
			if(kav.SUPPLEMENTAL_INFORMATION__c != null && kav.SUPPLEMENTAL_INFORMATION__c.length()>4 && kav.SUPPLEMENTAL_INFORMATION__c.substring(0,4) == 'null'){
				kav.SUPPLEMENTAL_INFORMATION__c = kav.SUPPLEMENTAL_INFORMATION__c.substring(4);
			}
		}
		
		update kavsDraftTochange;
		
		
		for(QUESTION_AND_ANSWER__kav kav:kavsDraftTochange){
		String articleId = kav.knowledgeArticleId;
			try{
						 
				    	KbManagement.PublishingService.publishArticle(articleId,false);
		            }catch(Exception e){
		            	
		            }
		
		}
		
		
		hasmore = (kavsonline.size()>70);
		theNumber = kavsonline.size();
		
		updatedArticles = kavsDraftTochange.size();
	}


	public void changeISIds(){
		
		
		
		List<INTERNAL_PROCESSES__kav> kavsDraft = [Select knowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from INTERNAL_PROCESSES__kav where publishStatus = 'Draft' and language='en_US'  and createdById = '005U0000000gYN0' and createdBy__c != null] ;
		
		List<String> kbIds  = new List<String>();
		
		for(INTERNAL_PROCESSES__kav kb:kavsDraft){
			kbIds.add(kb.knowledgeArticleId);
		}
		System.debug(kavsDraft.size() );
		DateTime theTime = Datetime.now()  - (1/4.8) ;
		
		List<INTERNAL_PROCESSES__kav> kavsonline = [Select KnowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from INTERNAL_PROCESSES__kav where publishStatus = 'Online' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId not in: kbIds] ;
		
		
		System.debug(kavsonline.size() );
		
		integer count = 0;
		
		List<Id> articleTochange = new List<Id>();
		
		for(INTERNAL_PROCESSES__kav kav:kavsonline){
			if(count<71){
		            String articleId = kav.knowledgeArticleId;
		            Datetime scheduledDate = Datetime.now();
		            try{
						 
				    	KbManagement.PublishingService.editOnlineArticle(articleId,false);
				    	articleTochange.add(articleId);	
		            }catch(Exception e){
		            	
		            }
		        }
		            count ++;
		}
		
		List<INTERNAL_PROCESSES__kav> kavsDraftTochange = [Select knowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from INTERNAL_PROCESSES__kav where publishStatus = 'Draft' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId in : articleTochange ] ;
		
		
		for(INTERNAL_PROCESSES__kav kav:kavsDraftTochange){
		
			//kav.SUPPLEMENTAL_INFORMATION__c += '<br/>Knova Id: '  + kav.urlName;
			if(kav.SUPPLEMENTAL_INFORMATION__c != null && kav.SUPPLEMENTAL_INFORMATION__c.length()>4 && kav.SUPPLEMENTAL_INFORMATION__c.substring(0,4) == 'null'){
				kav.SUPPLEMENTAL_INFORMATION__c = kav.SUPPLEMENTAL_INFORMATION__c.substring(4);
			}
		}
		
		update kavsDraftTochange;
		
		
		for(INTERNAL_PROCESSES__kav kav:kavsDraftTochange){
		String articleId = kav.knowledgeArticleId;
			try{
						 
				    	KbManagement.PublishingService.publishArticle(articleId,false);
		            }catch(Exception e){
		            	
		            }
		
		}
		
		
		hasmore = (kavsonline.size()>70);
		theNumber = kavsonline.size();
		
		updatedArticles = kavsDraftTochange.size();
	}



	public void changeTUIds(){
		
		
		
		List<TROUBLESHOOTING_UTILITIES__kav> kavsDraft = [Select knowledgeArticleId,DETAIL__c,urlName from TROUBLESHOOTING_UTILITIES__kav where publishStatus = 'Draft' and language='en_US'  and createdById = '005U0000000gYN0' and createdBy__c != null] ;
		
		List<String> kbIds  = new List<String>();
		
		for(TROUBLESHOOTING_UTILITIES__kav kb:kavsDraft){
			kbIds.add(kb.knowledgeArticleId);
		}
		System.debug(kavsDraft.size() );
		DateTime theTime = Datetime.now()  - (1/4.8) ;
		
		List<TROUBLESHOOTING_UTILITIES__kav> kavsonline = [Select KnowledgeArticleId,DETAIL__c,urlName from TROUBLESHOOTING_UTILITIES__kav where publishStatus = 'Online' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId not in: kbIds] ;
		
		
		System.debug(kavsonline.size() );
		
		integer count = 0;
		
		List<Id> articleTochange = new List<Id>();
		
		for(TROUBLESHOOTING_UTILITIES__kav kav:kavsonline){
			if(count<71){
		            String articleId = kav.knowledgeArticleId;
		            Datetime scheduledDate = Datetime.now();
		            try{
						 
				    	KbManagement.PublishingService.editOnlineArticle(articleId,false);
				    	articleTochange.add(articleId);	
		            }catch(Exception e){
		            	
		            }
		        }
		            count ++;
		}
		
		List<TROUBLESHOOTING_UTILITIES__kav> kavsDraftTochange = [Select knowledgeArticleId,DETAIL__c,urlName from TROUBLESHOOTING_UTILITIES__kav where publishStatus = 'Draft' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId in : articleTochange ] ;
		
		
		for(TROUBLESHOOTING_UTILITIES__kav kav:kavsDraftTochange){
		
			//kav.DETAIL__c += '<br/>Knova Id: '  + kav.urlName;
			if(kav.DETAIL__c != null && kav.DETAIL__c.length()>4 && kav.DETAIL__c.substring(0,4) == 'null'){
				kav.DETAIL__c = kav.DETAIL__c.substring(4);
			}
		}
		
		update kavsDraftTochange;
		
		
		for(TROUBLESHOOTING_UTILITIES__kav kav:kavsDraftTochange){
		String articleId = kav.knowledgeArticleId;
			try{
						 
				    	KbManagement.PublishingService.publishArticle(articleId,false);
		            }catch(Exception e){
		            	
		            }
		
		}
		
		
		hasmore = (kavsonline.size()>70);
		theNumber = kavsonline.size();
		
		updatedArticles = kavsDraftTochange.size();
	}


	public void changeSolIds(){
		
		
		
		List<SOLUTIONS__kav> kavsDraft = [Select knowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from SOLUTIONS__kav where publishStatus = 'Draft' and language='en_US'  and createdById = '005U0000000gYN0' and createdBy__c != null] ;
		
		List<String> kbIds  = new List<String>();
		
		for(SOLUTIONS__kav kb:kavsDraft){
			kbIds.add(kb.knowledgeArticleId);
		}
		System.debug(kavsDraft.size() );
		DateTime theTime = Datetime.now()  - (1/4.8) ;
		
		List<SOLUTIONS__kav> kavsonline = [Select KnowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from SOLUTIONS__kav where publishStatus = 'Online' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId not in: kbIds] ;
		
		
		System.debug(kavsonline.size() );
		
		integer count = 0;
		
		List<Id> articleTochange = new List<Id>();
		
		for(SOLUTIONS__kav kav:kavsonline){
			if(count<71){
		            String articleId = kav.knowledgeArticleId;
		            Datetime scheduledDate = Datetime.now();
		            try{
						 
				    	KbManagement.PublishingService.editOnlineArticle(articleId,false);
				    	articleTochange.add(articleId);	
		            }catch(Exception e){
		            	
		            }
		        }
		            count ++;
		}
		
		List<SOLUTIONS__kav> kavsDraftTochange = [Select knowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from SOLUTIONS__kav where publishStatus = 'Draft' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId in : articleTochange ] ;
		
		
		for(SOLUTIONS__kav kav:kavsDraftTochange){
		
			//kav.SUPPLEMENTAL_INFORMATION__c += '<br/>Knova Id: '  + kav.urlName;
			if(kav.SUPPLEMENTAL_INFORMATION__c != null && kav.SUPPLEMENTAL_INFORMATION__c.length()>4 && kav.SUPPLEMENTAL_INFORMATION__c.substring(0,4) == 'null'){
				kav.SUPPLEMENTAL_INFORMATION__c = kav.SUPPLEMENTAL_INFORMATION__c.substring(4);
			}
		}
		
		update kavsDraftTochange;
		
		
		for(SOLUTIONS__kav kav:kavsDraftTochange){
		String articleId = kav.knowledgeArticleId;
			try{
						 
				    	KbManagement.PublishingService.publishArticle(articleId,false);
		            }catch(Exception e){
		            	
		            }
		
		}
		
		
		hasmore = (kavsonline.size()>70);
		theNumber = kavsonline.size();
		
		updatedArticles = kavsDraftTochange.size();
	}
	
	
	public void changetechAIds(){
		
		
		
		List<TECHNICAL_ARTICLE__kav> kavsDraft = [Select knowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from TECHNICAL_ARTICLE__kav where publishStatus = 'Draft' and language='en_US'  and createdById = '005U0000000gYN0' and createdBy__c != null] ;
		
		List<String> kbIds  = new List<String>();
		
		for(TECHNICAL_ARTICLE__kav kb:kavsDraft){
			kbIds.add(kb.knowledgeArticleId);
		}
		System.debug(kavsDraft.size() );
		DateTime theTime = Datetime.now()  - (1/4.8) ;
		
		List<TECHNICAL_ARTICLE__kav> kavsonline = [Select KnowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from TECHNICAL_ARTICLE__kav where publishStatus = 'Online' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId not in: kbIds] ;
		
		
		System.debug(kavsonline.size() );
		
		integer count = 0;
		
		List<Id> articleTochange = new List<Id>();
		
		for(TECHNICAL_ARTICLE__kav kav:kavsonline){
			if(count<71){
		            String articleId = kav.knowledgeArticleId;
		            Datetime scheduledDate = Datetime.now();
		            try{
						 
				    	KbManagement.PublishingService.editOnlineArticle(articleId,false);
				    	articleTochange.add(articleId);	
		            }catch(Exception e){
		            	
		            }
		        }
		            count ++;
		}
		
		List<TECHNICAL_ARTICLE__kav> kavsDraftTochange = [Select knowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from TECHNICAL_ARTICLE__kav where publishStatus = 'Draft' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId in : articleTochange ] ;
		
		
		for(TECHNICAL_ARTICLE__kav kav:kavsDraftTochange){
		
			//kav.SUPPLEMENTAL_INFORMATION__c += '<br/>Knova Id: '  + kav.urlName;
			if(kav.SUPPLEMENTAL_INFORMATION__c != null && kav.SUPPLEMENTAL_INFORMATION__c.length()>4 && kav.SUPPLEMENTAL_INFORMATION__c.substring(0,4) == 'null'){
				kav.SUPPLEMENTAL_INFORMATION__c = kav.SUPPLEMENTAL_INFORMATION__c.substring(4);
			}
		}
		
		update kavsDraftTochange;
		
		
		for(TECHNICAL_ARTICLE__kav kav:kavsDraftTochange){
		String articleId = kav.knowledgeArticleId;
			try{
						 
				    	KbManagement.PublishingService.publishArticle(articleId,false);
		            }catch(Exception e){
		            	
		            }
		
		}
		
		
		hasmore = (kavsonline.size()>70);
		theNumber = kavsonline.size();
		
		updatedArticles = kavsDraftTochange.size();
	}
	
	
	
	
	public void changetechNIds(){
		
		
		
		List<TECH_NOTES__kav> kavsDraft = [Select knowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from TECH_NOTES__kav where publishStatus = 'Draft' and language='en_US'  and createdById = '005U0000000gYN0' and createdBy__c != null] ;
		
		List<String> kbIds  = new List<String>();
		
		for(TECH_NOTES__kav kb:kavsDraft){
			kbIds.add(kb.knowledgeArticleId);
		}
		System.debug(kavsDraft.size() );
		DateTime theTime = Datetime.now()  - (1/4.8) ;
		
		List<TECH_NOTES__kav> kavsonline = [Select KnowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from TECH_NOTES__kav where publishStatus = 'Online' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId not in: kbIds] ;
		
		
		System.debug(kavsonline.size() );
		
		integer count = 0;
		
		List<Id> articleTochange = new List<Id>();
		
		for(TECH_NOTES__kav kav:kavsonline){
			if(count<71){
		            String articleId = kav.knowledgeArticleId;
		            Datetime scheduledDate = Datetime.now();
		            try{
						 
				    	KbManagement.PublishingService.editOnlineArticle(articleId,false);
				    	articleTochange.add(articleId);	
		            }catch(Exception e){
		            	
		            }
		        }
		            count ++;
		}
		
		List<TECH_NOTES__kav> kavsDraftTochange = [Select knowledgeArticleId,SUPPLEMENTAL_INFORMATION__c,urlName from TECH_NOTES__kav where publishStatus = 'Draft' and language='en_US' and lastModifiedDate < :theTime and createdById = '005U0000000gYN0' and createdBy__c != null and knowledgeArticleId in : articleTochange ] ;
		
		
		for(TECH_NOTES__kav kav:kavsDraftTochange){
		
			//kav.SUPPLEMENTAL_INFORMATION__c += '<br/>Knova Id: '  + kav.urlName;
			if(kav.SUPPLEMENTAL_INFORMATION__c != null && kav.SUPPLEMENTAL_INFORMATION__c.length()>4 && kav.SUPPLEMENTAL_INFORMATION__c.substring(0,4) == 'null'){
				kav.SUPPLEMENTAL_INFORMATION__c = kav.SUPPLEMENTAL_INFORMATION__c.substring(4);
			}
		}
		
		update kavsDraftTochange;
		
		
		for(TECH_NOTES__kav kav:kavsDraftTochange){
		String articleId = kav.knowledgeArticleId;
			try{
						 
				    	KbManagement.PublishingService.publishArticle(articleId,false);
		            }catch(Exception e){
		            	
		            }
		
		}
		
		
		hasmore = (kavsonline.size()>70);
		theNumber = kavsonline.size();
		
		updatedArticles = kavsDraftTochange.size();
	}
	
	*/




}