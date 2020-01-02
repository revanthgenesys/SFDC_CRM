/*
Class	: DownloadsController
Author –  Vinay Lakshmeesh
Date –    3/28/2013
Usage   : Without Sharing class for DownloadsController.
Revision History
*/
public without sharing class DownloadsControllerWithoutSharing {
	
	public static List<ContractLineItem> queryContractLineItem(Set<Id> serviceContractIds){
		return [SELECT PricebookEntry.Name,
       				   PricebookEntry.Product2Id,
       				   ServiceContractId
				FROM ContractLineItem
				WHERE ServiceContractId IN :serviceContractIds];
	}
	
	public static List<Product_Mapping__c> queryProductMapping(Set<Id> productMapKeySet ){
		return [SELECT p.Product__r.Product_Type__c,
				       p.Product__r.Name,
				       p.Product__c,
				       p.Name,
				       p.Product__r.Parent_Product_Name__c,
				       p.Product__r.Parent_Product__c
				FROM Product_Mapping__c p
				WHERE 
				  //p.Product__r.Product_Type__c = 'Product'
				  //AND 
				  Product__r.Customer_Available__c = true and
				  Sellable_Item__c IN: productMapKeySet];
	}
	
	public static List<Support_Product__c> querySupportProd(Set<Id> prodMapkeySet){
		return [SELECT Id,Name,Parent_Product__c 
				FROM   Support_Product__c 
				WHERE  Customer_Available__c =true
				       AND Parent_Product__c in :prodMapkeySet 
					   AND Product_Type__c = 'Component'];
	}
	
}