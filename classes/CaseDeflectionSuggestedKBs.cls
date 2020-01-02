global with sharing class CaseDeflectionSuggestedKBs {


	static Map<String,String> catSyncLabelMap = CategorySyncController.getCategorySyncLabelMap();

	static list<Support_Product__c> prodMap;

	public string supportProduct {get;set;}
	
	public string majorRelease {get;set;}
	
	public string keyWord {get;set;}

	public string selectedCategories ;
	
	
	public string getSelectedCategories(){
			supportProduct = supportProduct.trim();
			majorRelease = majorRelease.trim();
		
			prodMap = [SELECT Id,Product_Name__c FROM Support_Product__c WHERE Id =: supportProduct];
	 		List<String>  supportProductKB ;
			List<String>  majorReleaseKB ;
	 		if(supportProduct != null){   
	            supportProductKB = new List<String>();
	            supportProductKB.add(returnTheKBProduct(supportProduct));
	            supportProductKB = pkb_Controller.getArticleProductCategories(supportProductKB,false);
	            
	        }
	        if(majorRelease!=null){   
	            majorReleaseKB = new List<String>();
	            majorReleaseKB.add(majorRelease);
	            majorReleaseKB = pkb_Controller.getArticleReleaseCategories(majorReleaseKB,false);
	        }
	        
	        
	        selectedCategories = '';
	        
	        if(!supportProductKB.isEmpty()){   
	        	selectedCategories += 'Product:' + supportProductKB.get(0);
	        }
	        
	        if(!majorReleaseKB.isEmpty()){   
	        	if(selectedCategories != ''){
	        		selectedCategories += ',';
	        	}
	        	selectedCategories += 'Release:' + majorReleaseKB.get(0);
	        }
        
        return selectedCategories;
	}
	

	public CaseDeflectionSuggestedKBs(){
	}
	
   public static String returnTheKBProduct(String supportProduct){
   	
   		String prodName = !prodMap.isEmpty() ? prodMap[0].Product_Name__c : supportProduct;
   	
   		return (prodName!='' && catSyncLabelMap.containsKey(prodName)) ? catSyncLabelMap.get(prodName) : prodName;
   	
   }



}