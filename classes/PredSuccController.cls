//Naresh Kumar	01/08/2014	
public with sharing class PredSuccController {
	public List<Product_Predecessor__c> preds {get;set;}
	public List<Product_Successor__c> succ {get;set;}
	public Boolean showPreds {get;set;}
	public Boolean showSucc {get;set;}
	public String prodDesc {get;set;}
	private String productId;
	public PredSuccController(){
		productId = ApexPages.CurrentPage().getparameters().get('pid');
		if(productId == null)
			return;
		showPreds = false;
		showSucc = false;
		preds = new List<Product_Predecessor__c>();
		succ = new List<Product_Successor__c>();		
		populateLists();		 
	}
	
	public void populateLists(){		
		prodDesc = [SELECT Description FROM Product2 WHERE id =: productId LIMIT 1].Description;		
		
		List<Product_Predecessor__c> allPreds = [SELECT id, Product__c, Predecessor__c, Predecessor__r.Description 
			FROM Product_Predecessor__c LIMIT 10000];		
		Map<Id, Product_Predecessor__c> mapProductIdVsPreds= new Map<Id, Product_Predecessor__c>();
		for(Product_Predecessor__c eachPred : allPreds){
			mapProductIdVsPreds.put(eachPred.Product__c, eachPred);	
		}
		
		List<Product_Successor__c> allSucc = [SELECT id, Product__c, Product_Successor__c, Product_Successor__r.Description 
			FROM Product_Successor__c LIMIT 10000];
		Map<Id, Product_Successor__c> mapProductIdVsSuccs= new Map<Id, Product_Successor__c>();
		for(Product_Successor__c eachSucc : allSucc){
			mapProductIdVsSuccs.put(eachSucc.Product__c, eachSucc);	
		}
		
		Id currentProductId = productId;		
		while(1 == 1){			
			if(mapProductIdVsPreds.get(currentProductId) == null 
				|| mapProductIdVsPreds.get(currentProductId).Predecessor__c == currentProductId)
				break;
			Product_Predecessor__c pred = mapProductIdVsPreds.get(currentProductId);
			preds.add(pred);
			currentProductId = pred.Predecessor__c;
		}
		
		currentProductId = productId;		
		while(1 == 1){			
			if(mapProductIdVsSuccs.get(currentProductId) == null 
				|| mapProductIdVsSuccs.get(currentProductId).Product_Successor__c == currentProductId)
				break;
			Product_Successor__c succ1 = mapProductIdVsSuccs.get(currentProductId);
			succ.add(succ1);
			currentProductId = succ1.Product_Successor__c;
		}		
		
		if(preds.size() > 0){
			showPreds = true;			
		}
		if(succ.size() > 0){
			showSucc = true;			
		}
		
	}
}