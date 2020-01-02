public with sharing class CategorySyncController {

    public List<Category_Sync__c> categoryMapList = null;
	
	static public List<Category_Sync__c> getCategorySyncList() {
		return [ SELECT Id, KB_Category_ID__c, KB_Category__c, Support_Product__r.Product_Name__c  
		                          FROM Category_Sync__c  
		     	   			     WHERE KB_Category_ID__c!=NULL AND KB_Category_ID__c!=''
		     	   			     	   AND KB_Category__c!=NULL AND KB_Category__c!='' 
		     	   			           AND Support_Product__c!=NULL ];
	}
	
	// Retrieve a map of KB-Category "Name" to Support Product Name
	static public Map<String,String> getCategorySyncNameMap() {
		List<Category_Sync__c> catSyncList = getCategorySyncList();
		Map<String,String> catSyncNameMap = new Map<String,String>();
		for (Category_Sync__c c : catSyncList) {
			catSyncNameMap.put(c.KB_Category_ID__c, c.Support_Product__r.Product_Name__c);
		}
		return catSyncNameMap;
	}
	
	// Retrieve a map of Product Name to KB Category Label
	static public Map<String,String> getCategorySyncLabelMap() {
		List<Category_Sync__c> catSyncList = getCategorySyncList();
		Map<String,String> catSyncLabelMap = new Map<String,String>();
		for (Category_Sync__c c : catSyncList) {
			catSyncLabelMap.put(c.Support_Product__r.Product_Name__c, c.KB_Category__c);
		}
		return catSyncLabelMap;
	}
	
	public List<Category_Sync__c> getCategoryMapList() {
		if (categoryMapList==null) {
			categoryMapList = getCategorySyncList();
		}						                
		return categoryMapList;
	}
	
	
	/**** TEST STUFF HERE ****/
	static testMethod void testCategorySync() {
		// setup sample products
		Support_Product__c sproduct1 = new Support_Product__c(
			Description__c = 'Test Product Description 1',
			Internal_Name__c = 'Test Internal Name1',
			Product_Name__c = 'Test Product Name 1'
		);
		insert sproduct1;
		Support_Product__c sproduct2 = new Support_Product__c(
			Description__c = 'Test Product Description 2',
			Internal_Name__c = 'Test Internal Name 2',
			Product_Name__c = 'Test Product Name 2'
		);
		insert sproduct2;
		Support_Product__c sproduct3 = new Support_Product__c(
		    Description__c = 'Test Product Description 3',
			Internal_Name__c = 'Test Internal Name 3',
			Product_Name__c = 'Test Product Name 3'
		);
		insert sproduct3;
		sproduct1 = [ SELECT Id,Description__c,Product_Name__c FROM Support_Product__c WHERE Product_Name__c = 'Test Product Name 1' LIMIT 1];
		sproduct2 = [ SELECT Id,Description__c,Product_Name__c FROM Support_Product__c WHERE Product_Name__c = 'Test Product Name 2' LIMIT 1];
		sproduct3 = [ SELECT Id,Description__c,Product_Name__c FROM Support_Product__c WHERE Product_Name__c = 'Test Product Name 3' LIMIT 1];
		// setup sample mappings
		Category_Sync__c catsync1 = new Category_Sync__c(
			KB_Category__c = 'Test KB Category 1',
			KB_Category_ID__c = 'Product:TEST_KB_CAT_1_1',
			Support_Product__c = sproduct1.Id
		);
		insert catsync1;
		Category_Sync__c catsync2 = new Category_Sync__c(
		    KB_Category__c = 'Test KB Category 2',
			KB_Category_ID__c = 'Product:TEST_KB_CAT_2_1',
			Support_Product__c = sproduct2.Id
		);
		insert catsync2;
		// test calls
		Map<String,String> catSyncNameMap = getCategorySyncNameMap();
		Map<String,String> catSyncLabelMap = getCategorySyncLabelMap();
		CategorySyncController csController = new CategorySyncController();
		List<Category_Sync__c> csList = csController.getCategoryMapList();
	}
	
	
	
}