/*
	Naresh		07/24/2013
*/
public with sharing class SearchAccountAndProduct {
	public String searchStr {get;set;}
	public List<Account> resultAccounts {get;set;}
	public Boolean showResult {get;set;}
	public SearchAccountAndProduct(){
		showResult = false;
	}
	public void doSearch(){
		searchStr = '%' + searchStr + '%';
		Set<String> accIds = new Set<String>();
		for(ContractLineItem clis : [SELECT ServiceContract.End_User_Name__c FROM ContractLineItem WHERE Upgraded_Product_Name__c LIKE : searchStr AND
			ServiceContract.End_User_Name__c != null]){
			accIds.add(clis.ServiceContract.End_User_Name__c);
		}		
		resultAccounts = [SELECT Name, Owner.Name, OwnerId FROM Account WHERE Name LIKE : searchStr OR id IN : accIds ORDER BY Name ASC LIMIT 100] ;
		if(resultAccounts.size() > 0)
			showResult = true;
	}
}