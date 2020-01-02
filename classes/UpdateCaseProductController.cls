/*
	Naresh Kumar
	05/15/2013
*/
public without sharing class UpdateCaseProductController {
	String caseId {get;set;}
	public case currentCase {get;set;}
	public List<SelectOption> prodLines {get;set;}
	public List<SelectOption> prods {get;set;}
	public List<SelectOption> components {get;set;}
	public List<SelectOption> productVersions {get;set;}
	public Boolean showSaveButton {get;set;}	
	public UpdateCaseProductController(ApexPages.StandardController stdController){
		caseId = stdController.getId();
		currentCase = [SELECT id, End_User_Account__c, Sold_To_Account__c, Product_Line__c, Support_Product__c, Component__c,
				Product_Version__c FROM Case WHERE id =: caseId];
		populateProdLines();
		prods = new List<SelectOption>();
		SelectOption item = new SelectOption('', 'None');
		prods.add(item);
		components = new List<SelectOption>();
		components.add(item);
		productVersions = new List<SelectOption>();	
		populatesProds();
		populatesComponents();
		populatesProductVersions();
		showSaveButton = false;
	}
	
	public void populateProdLines(){	
		prodLines = new List<SelectOption>();	
		SelectOption item = new SelectOption('', 'None');
		prodLines.add(item);
		for(Support_Product__c eachSP : [SELECT id, Name FROM Support_Product__c WHERE Product_Type__c = 'Product Line' 
				AND Customer_Available__c = true]){
			item = new SelectOption(eachSP.id, eachSP.Name);
			prodLines.add(item);
		}
	}
	public void populatesProds(){	
		prods = new List<SelectOption>();
		SelectOption item = new SelectOption('', 'None');
		prods.add(item);	
		for(Support_Product__c eachSP : [SELECT id, Name FROM Support_Product__c WHERE Product_Type__c = 'Product' 
				AND Parent_Product__c =: currentCase.Product_Line__c AND Customer_Available__c = true]){
			item = new SelectOption(eachSP.id, eachSP.Name);
			prods.add(item);
		}
		components.clear();
		productVersions.clear();
		item = new SelectOption('', 'None');
		components.add(item);		
		productVersions.add(item);
	}
	public void populatesComponents(){	
		components = new List<SelectOption>();
		SelectOption item = new SelectOption('', 'None');
		components.add(item);	
		for(Support_Product__c eachSP : [SELECT id, Name FROM Support_Product__c WHERE Product_Type__c = 'Component' 
				AND Parent_Product__c =: currentCase.Support_Product__c AND Customer_Available__c = true]){
			item = new SelectOption(eachSP.id, eachSP.Name);
			components.add(item);
		}
		productVersions.clear();		
		item = new SelectOption('', 'None');
		productVersions.add(item);		
	}
	public void populatesProductVersions(){	
		productVersions = new List<SelectOption>();
		SelectOption item = new SelectOption('', 'None');
		productVersions.add(item);		
		for(Product_Version__c eachSP : [SELECT id, Name FROM Product_Version__c WHERE Parent_Product__c =: currentCase.Component__c 
			AND Customer_Available__c = true ORDER BY Name DESC]){
			item = new SelectOption(eachSP.id, eachSP.Name);
			productVersions.add(item);
		}		
	}
	public PageReference next(){
		Set<String> productIds = new Set<String>();
		if(currentCase.Support_Product__c == null || currentCase.Support_Product__c == null ){
			ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Product and Product Line fields are mandatory to select.');
        	ApexPages.addMessage(errorMessage);
        	return null;
		}
		for(Product_Mapping__c eachPM : [SELECT id, Sellable_Item__c FROM Product_Mapping__c WHERE Product__c =: currentCase.Support_Product__c]){
			productIds.add(eachPM.Sellable_Item__c);
		}
		List<ContractLineItem> contractLineItems = [SELECT id FROM ContractLineItem WHERE PriceBookEntry.Product2Id in : productIds AND Service_Contract_Status__c = 'Active'
			AND ServiceContractId in (SELECT id FROM ServiceContract WHERE AccountId =: currentCase.End_User_Account__c OR 
			AccountId =: currentCase.Sold_To_Account__c)];
			
		if(contractLineItems.size() == 0){
			ApexPages.Message errorMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'No active entitlement is found. Please click save if you still wish to save.');
        	ApexPages.addMessage(errorMessage);
        	showSaveButton = true;
        	return null;
		}
		try{
			currentCase.Non_Entitled_Product_Selected__c = false;
			update currentCase;
		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error - '+e.getMessage()));
		}
		return new PageReference('/'+currentCase.id);
	}	
	public PageReference save(){
		try{
			currentCase.Non_Entitled_Product_Selected__c = true;
			update currentCase;
		}
		catch(Exception e){
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error - '+e.getMessage()));
		}
		return new PageReference('/'+currentCase.id);
	}
}