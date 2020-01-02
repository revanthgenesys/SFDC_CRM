public with sharing class pkb_categorySubscription {

	public String articleTypes { get; set; }
  	public String articleTypeLabels { get; set; }	
  	
  	private final static String KAV_EXTENSION = '__kav';
  	public String kavExtension          { get { return KAV_EXTENSION; } }
   public String categoryGroup1      { get { return 'Product'; } } 
  public String categoryGroup2      { get { return 'Release'; } } 
  public String categoryGroup3      { get { return null; } } 
  public String categoryLabel1      { get { return 'Product'; } }
  public String categoryLabel2      { get { return 'Major Release'; } }
  public String categoryLabel3      { get { return ''; } }
  public String rootCategory1       { get { return 'SG_ROOT'; } }
  public String rootCategory2       { get { return 'UMME_ROOT'; } }
  public String rootCategory3       { get { return ''; } }
  public Boolean displayCategory1 { get { return true; } }
  public Boolean displayCategory2 { get { return true; } }
  public Boolean displayCategory3 { get { return false; } }


	public pkb_categorySubscription() {
    	getUserArticleTypes();
  }

	 /* addsubscribe() - add a subscribe
     */
  	public void addArticleTypesubscribe() {
  		List<recordType> recordTypes = [Select r.SobjectType, r.Name, r.Id From RecordType r where name='Article Type' and SobjectType = 'Solution_Search_Alert__c'];
  		String typeId = ApexPages.currentPage().getParameters().get('typeId');
    	String typeTitle = ApexPages.currentPage().getParameters().get('typeTitle');
    	String ArticlePreference = ApexPages.currentPage().getParameters().get('ArticlePreference');
  		if(!recordTypes.isEmpty()){
	  		Solution_Search_Alert__c newsub = new Solution_Search_Alert__c(
				User__c = userInfo.getUserId(),
				Article_Type_API_Name__c = typeId,
				Article_Type__c = typeTitle,
				Type__c = 'Article Type',
				Solution_Search_Alert_Preference__c = ArticlePreference,
				RecordTypeId = recordTypes[0].Id
			);
			insert newsub;
		}		
	}


	 /* addsubscribe() - add a subscribe
     */
  	public void addCatsubscribe() {
  		List<recordType> recordTypes = [Select r.SobjectType, r.Name, r.Id From RecordType r where name='Category' and SobjectType = 'Solution_Search_Alert__c'];
  		String catJson = ApexPages.currentPage().getParameters().get('catJson');
    	String ArticlePreference = ApexPages.currentPage().getParameters().get('ArticlePreference');
    	
    	List<String> catIds = new List<String>();
    	List<String> catLabels = new List<String>();
			
		
       JSONParser parser = JSON.createParser(catJson);
        Boolean firstParam = true;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
				parser.nextToken();
				system.debug(parser.getCurrentName());
				catIds.add(parser.getText());
			} 
			parser.nextToken();
			 if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
				parser.nextToken();
				system.debug(parser.getCurrentName());
				catLabels.add(parser.getText());
			} 
        }
    	
    	
    	List<Solution_Search_Alert__c> solutionsToInsert = new List<Solution_Search_Alert__c>();
    	Integer count = 0;
    	
  		if(!recordTypes.isEmpty()){
  			
	    	Set<String> existingIds = new Set<String>();
	    	
	    	for(Solution_Search_Alert__c ssalert:[select Category_ID__c from Solution_Search_Alert__c where Type__c = 'Category' and User__c =: userInfo.getUserId()]){
	    		if(ssalert.Category_ID__c != null){
	    			existingIds.add(ssalert.Category_ID__c);
	    		}
	    	}
	    	
  			for(String theCat:catIds){
  				if(!existingIds.contains(theCat)){
			  		Solution_Search_Alert__c newsub = new Solution_Search_Alert__c(
						User__c = userInfo.getUserId(),
						Category_ID__c = theCat,
						Category_Title__c = catLabels.get(count),
						Type__c = 'Category',
						Solution_Search_Alert_Preference__c = ArticlePreference,
						RecordTypeId = recordTypes[0].Id
					);
					solutionsToInsert.add(newsub);
  				}
				count++;
  			}
			
		}	
		
		
		insert solutionsToInsert;	
	}


	public void addCatAndTypesubscribe() {
  		List<recordType> recordTypes = [Select r.SobjectType, r.Name, r.Id From RecordType r where name='Category And Article Type' and SobjectType = 'Solution_Search_Alert__c'];
		
		String typeId = ApexPages.currentPage().getParameters().get('typeId');
    	String typeTitle = ApexPages.currentPage().getParameters().get('typeTitle');
		String catJson = ApexPages.currentPage().getParameters().get('catJson');
    	String ArticlePreference = ApexPages.currentPage().getParameters().get('ArticlePreference');
    	
    	List<String> catIds = new List<String>();
    	List<String> catLabels = new List<String>();
		
       JSONParser parser = JSON.createParser(catJson);
        Boolean firstParam = true;
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
				parser.nextToken();
				system.debug(parser.getCurrentName());
				catIds.add(parser.getText());
			} 
			parser.nextToken();
			 if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
				parser.nextToken();
				system.debug(parser.getCurrentName());
				catLabels.add(parser.getText());
			} 
        }
    	
    	
    	List<Solution_Search_Alert__c> solutionsToInsert = new List<Solution_Search_Alert__c>();
    	Integer count = 0;
    	
  		if(!recordTypes.isEmpty()){
  			
	    	Set<String> existingIds = new Set<String>();
	    	
	    	for(Solution_Search_Alert__c ssalert:[select Category_ID__c,Article_Type_API_Name__c from Solution_Search_Alert__c where Type__c = 'Category And Article Type' and User__c =: userInfo.getUserId()]){
	    		if(ssalert.Category_ID__c != null && ssalert.Article_Type_API_Name__c != null){
	    			existingIds.add(ssalert.Category_ID__c + ssalert.Article_Type_API_Name__c);
	    		}
	    	}
	    	
  			for(String theCat:catIds){
  				if(!existingIds.contains(theCat + typeId)){
			  		Solution_Search_Alert__c newsub = new Solution_Search_Alert__c(
						User__c = userInfo.getUserId(),
						Category_ID__c = theCat,
						Category_Title__c = catLabels.get(count),
						Article_Type_API_Name__c = typeId,
						Article_Type__c = typeTitle,
						Type__c = 'Category And Article Type',
						Solution_Search_Alert_Preference__c = ArticlePreference,
						RecordTypeId = recordTypes[0].Id
					);
					solutionsToInsert.add(newsub);
  				}
				count++;
  			}
			
		}	
		
		
		insert solutionsToInsert;	
	}







	public void getUserArticleTypes() {
	  	String pid = UserInfo.getProfileId();
	  	  	
	  	List<ObjectPermissions> permissions = [SELECT Id, SObjectType, PermissionsRead, PermissionsCreate
	  			FROM ObjectPermissions
	  			WHERE parentid in (select id from permissionset where PermissionSet.Profile.Id = :pid)];
	  	
	  	Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
	
	  	
	  	articleTypes = '';
	  	articleTypeLabels = '';
	  	for( ObjectPermissions op: permissions ) {
	  		if( op.SObjectType.endsWith(KAV_EXTENSION)  ) {
	  			articleTypes += op.SObjectType+',';
	  			articleTypeLabels += schemaMap.get(op.SObjectType).getDescribe().getLabel()+',';
	  		}
	  	}
	
		articleTypes = articleTypes.replaceAll(',$','');
		articleTypeLabels = articleTypeLabels.replaceAll(',$','');
  	}


 // returns true if string is null or empty
  public static Boolean isBlank(String s) {
    return ( s == null || s == '');
  }

}