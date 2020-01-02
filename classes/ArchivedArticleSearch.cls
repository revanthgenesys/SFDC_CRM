public with sharing class ArchivedArticleSearch {



	public List<PlatformArticleTypes> ptypes {get;set;} 
	
	public List<String> drafts {get;set;} 

	public List<List <kbArticle>> kbArticles;
	
	public boolean canDelete {get;set;}
	public boolean canEdit {get;set;}

	Datetime ArchivedFrom;
	Datetime ArchivedTo;	
	//public Map<String,PlatformArticleTypes> ptypesMap;

	public ArchivedArticleSearch(){
		kbArticles = new List<List <kbArticle>> ();
		drafts = new List<String>();
		inittypes();
		
		List <String> editGroupNames = new List <String>();
		editGroupNames.add('Knowledge-publisher');
		editGroupNames.add('Knowledge-Contributor');
		editGroupNames.add('KCS-Coaches');
		editGroupNames.add('Admin View');
		
		List <String> deleteGroupNames = new List <String>();
		deleteGroupNames.add('Admin View');



		
		List<GroupMember> gmsEdit = [SELECT Id FROM GroupMember where UserOrGroupId = :UserInfo.getUserId() AND group.type = 'Regular' and group.name in:editGroupNames ];
		if(!gmsEdit.isEmpty()){
			canEdit=true;
		}else{
			canEdit = false;
		}
		List<GroupMember> gmsDelete = [SELECT Id FROM GroupMember where UserOrGroupId = :UserInfo.getUserId() AND group.type = 'Regular' and group.name in:deleteGroupNames ];
		if(!gmsDelete.isEmpty()){
			canDelete=true;
		}else{
			canDelete = false;
		}
		
		
	}

	private void inittypes(){
		
		ptypes = new	List<PlatformArticleTypes> ();	
		
		PlatformArticleTypes pt1 = new PlatformArticleTypes();
		pt1.Name = 'TECH_NOTES__kav';
		pt1.DisplayName = 'Tech Notes';
		ptypes.add(pt1);

		PlatformArticleTypes pt12 = new PlatformArticleTypes();
		pt12.Name = 'Product_Manuals_and_Help_Files__kav';
		pt12.DisplayName = 'Product Manuals and Help Files';
		ptypes.add(pt12);

		PlatformArticleTypes pt13 = new PlatformArticleTypes();
		pt13.Name = 'White_Papers__kav';
		pt13.DisplayName = 'White Papers';
		ptypes.add(pt13);

		PlatformArticleTypes pt14 = new PlatformArticleTypes();
		pt14.Name = 'SOLUTIONS__kav';
		pt14.DisplayName = 'Solutions';
		ptypes.add(pt14);
		
		PlatformArticleTypes pt15 = new PlatformArticleTypes();
		pt15.Name = 'TECHNICAL_ARTICLE__kav';
		pt15.DisplayName = 'Technical Article';
		ptypes.add(pt15);

		PlatformArticleTypes pt16 = new PlatformArticleTypes();
		pt16.Name = 'TROUBLESHOOTING_UTILITIES__kav';
		pt16.DisplayName = 'Troubleshooting Utilities';
		ptypes.add(pt16);

		PlatformArticleTypes pt17 = new PlatformArticleTypes();
		pt17.Name = 'INTERNAL_PROCESSES__kav';
		pt17.DisplayName = 'Internal Processes';
		ptypes.add(pt17);

		PlatformArticleTypes pt18 = new PlatformArticleTypes();
		pt18.Name = 'Third_Party_Documentation__kav';
		pt18.DisplayName = 'Third Party Documentation';
		ptypes.add(pt18);

		PlatformArticleTypes pt19 = new PlatformArticleTypes();
		pt19.Name = 'Product_Advisories__kav';
		pt19.DisplayName = 'Product Advisories';
		ptypes.add(pt19);

		PlatformArticleTypes pt2 = new PlatformArticleTypes();
		pt2.Name = 'Release_Advisory__kav';
		pt2.DisplayName = 'Release Advisory';
		ptypes.add(pt2);

		PlatformArticleTypes pt21 = new PlatformArticleTypes();
		pt21.Name = 'Tech_Tutorial__kav';
		pt21.DisplayName = 'Tech Tutorial';
		ptypes.add(pt21);

		PlatformArticleTypes pt22 = new PlatformArticleTypes();
		pt22.Name = 'Release_Notes__kav';
		pt22.DisplayName = 'Release Notes';
		ptypes.add(pt22);

		PlatformArticleTypes pt23 = new PlatformArticleTypes();
		pt23.Name = 'QUESTION_AND_ANSWER__kav';
		pt23.DisplayName = 'QUESTION AND ANSWER';
		ptypes.add(pt23);

		PlatformArticleTypes pt24 = new PlatformArticleTypes();
		pt24.Name = 'Support_Processes__kav';
		pt24.DisplayName = 'Support Processes';
		ptypes.add(pt24);

		PlatformArticleTypes pt25 = new PlatformArticleTypes();
		pt25.Name = 'HOW_TO_TEMPLATE__kav';
		pt25.DisplayName = 'How To';
		ptypes.add(pt25);
		
		//ptypesMap = new Map<String,PlatformArticleTypes>();
		
		
		//for(PlatformArticleTypes ptype:ptypes){
		//	ptypesMap.put(ptype.Name,ptype);
		//}
		
		
	}


	public void deleteArchivedArticles(){
		String kbListToArchive = ApexPages.currentPage().getParameters().get('kbListToArchive');
		List<String> archiveList = kbListToArchive.split(',');
		for(String articleId:archiveList){
			try{
	    		KbManagement.PublishingService.deleteArchivedArticle(articleId);
			}catch(Exception e){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error Deleting Article ---' + articleId + '  ' + e.getMessage()+'. Please check if a draft article related to this archived article already exist.')); 
			}
		}
	}


	public void redraftArchivedArticles(){
		drafts = new List<String>();
		String kbListToDraft = ApexPages.currentPage().getParameters().get('kbListToDraft');
		List<String> draftList = kbListToDraft.split(',');
		for(String articleId:draftList){
	    	try{
	    		KbManagement.PublishingService.editArchivedArticle(articleId);
	    		drafts.add(articleId);
	    	}catch(Exception e){
				ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'Error Creating Draft Article ---' + articleId + '  ' + e.getMessage() +'. Please check if a draft article related to this archived article already exist.')); 
			}
		}
	}



	private  String getPlatformSoql(String searchTerm,String kbFromDate,String kbToDate,String kbArticleType,String kbLimit) {
		String SOSLLimit ='150';
		if(kbLimit!= null && kbLimit != ''){
			SOSLLimit = kbLimit;
		}
		
		String whereClause = '';
		
		if(kbFromDate!= null && kbFromDate != ''){
			 ArchivedFrom= Datetime.newInstance(date.valueOf(kbFromDate), Time.newInstance(0, 0, 0, 0));
			whereClause = ' and ArchivedDate >: ArchivedFrom ';
		}
		
		
		if(kbToDate!= null && kbToDate != ''){
			ArchivedTo = Datetime.newInstance(date.valueOf(kbToDate), Time.newInstance(0, 0, 0, 0));
			whereClause += '  and ArchivedDate <: ArchivedTo ';
		}
		
		
		
    	String Query = '';
		//try{
        	Boolean firstArticle = true;
    		//we had to do the custom setting because the search is failing on in deployment articles.
    		for(PlatformArticleTypes pType : ptypes){
    			if(kbArticleType== null || kbArticleType == '' || (kbArticleType!= null && kbArticleType != '' && pType.Name==kbArticleType)){
		
	    			String commaD = '';
					if(!firstArticle){
	        			commaD = ' , ';
	        		}else{
	        			firstArticle = false;
	        		}
	    			
					Query = Query + commaD + pType.Name + '(IsLatestVersion,Id,KnowledgeArticleId,Title,Summary,PublishStatus,URLName,ArchivedDate where PublishStatus=\'Archived\' and Language=\'en_US\' ' +whereClause+' limit '+SOSLLimit +')';
    			}
    		}
			
			 Query = 'FIND \'' + searchTerm + '*\' IN ALL FIELDS RETURNING ' + Query;
			System.debug(' ++++++++ ' +Query );
		//}catch(Exception e){
	   	//	system.debug(e);
	   	//}
	   	return Query;
	}
	
	
	public List<List <kbArticle>> getArchivedArticles(){
		return kbArticles;
	}
	
	public void searchWithParams(String kbSearchText,String kbFromDate,String kbToDate,String kbArticleType,String kbLimit){
		
		kbArticles = new List<List <kbArticle>> ();
		List<List <sObject>> articleTypesQuery = search.query(getPlatformSoql(String.escapeSingleQuotes(kbSearchText), kbFromDate, kbToDate, kbArticleType, kbLimit));
		for(List<sObject> listS:articleTypesQuery){
			
			List <kbArticle> listKbArticle = new List <kbArticle>();
			
			for(sObject kbObject:listS){
				
				String sObjectTypeLabel = kbObject.getSObjectType().getDescribe().getLabel();
				//kbObject.get(pString)
				kbArticle theKbArticle = new kbArticle();
				theKbArticle.Type = kbObject.getSObjectType().getDescribe().getLabel();
				theKbArticle.kbObjectP = kbObject;
				listKbArticle.add(theKbArticle);
				
			}
			kbArticles.add(listKbArticle);
		}
		
	}
	
	public void doSearch(){
		
		String kbSearchText = ApexPages.currentPage().getParameters().get('kbSearchText');
		String kbFromDate = ApexPages.currentPage().getParameters().get('kbFromDate');
		String kbToDate = ApexPages.currentPage().getParameters().get('kbToDate');
		String kbArticleType = ApexPages.currentPage().getParameters().get('kbArticleType');
		String kbLimit = ApexPages.currentPage().getParameters().get('kbLimit');
		searchWithParams( kbSearchText, kbFromDate, kbToDate, kbArticleType, kbLimit);
	}

	class kbArticle{
		
		public String Type{get;set;} 
		public sObject kbObjectP{get;set;} 
		
	}


	class PlatformArticleTypes{
		
		public String Name{get;set;} 
		public String DisplayName{get;set;} 
		
	}


	public static testMethod void testArchive(){

		ArchivedArticleSearch AAS = new ArchivedArticleSearch();
		ApexPages.currentPage().getParameters().put('kbSearchText','test');
		ApexPages.currentPage().getParameters().put('kbFromDate','2000-01-01');
		ApexPages.currentPage().getParameters().put('kbToDate','2020-01-01');
		ApexPages.currentPage().getParameters().put('kbLimit','50');
		AAS.doSearch();
		
		System.assert(AAS.getArchivedArticles().size() > 0);
		
		
		ApexPages.currentPage().getParameters().put('kbListToArchive','test');
		ApexPages.currentPage().getParameters().put('kbListToDraft','test');
		AAS.deleteArchivedArticles();
		AAS.redraftArchivedArticles();

	}


}