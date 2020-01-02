/*****************************************************
Class: CreateCustPortalCaseExtnWithoutSharing
Author – Vinay Lakshmeesh
Date – 3/28/2013
Usage : Class for CreateCustomerPortalCaseExtenstion to run with without sharing
Revision History
******************************************************/

public without sharing class CreateCustPortalCaseExtnWithoutSharing {
	
	public static List<ContractLineItem> queryContractLineItem(Set<Id> serviceContractIds){
		return [Select PricebookEntry.Name,PricebookEntry.Product2Id,
					   ServiceContractId 
			    From   ContractLineItem 
			    where  ServiceContractId in :serviceContractIds];
	}
	
	public static List<Product_Mapping__c> queryProductMapping(Set<Id> prodMapKeySet){
		return [Select Id,p.Product__r.Product_Type__c, 
					   p.Product__r.Name, p.Product__c, 
					   p.Name,p.Product__r.Parent_Product_Name__c, 
					   p.Product__r.Parent_Product__c 
			    From   Product_Mapping__c p 
			    where  p.Product__r.Product_Type__c = 'Product' and 
			    	   Sellable_Item__c in: prodMapKeySet ];
	}
	/*
	public static List<Product_Mapping__c> queryProductMappingProLine(Set<Id> prodMapKeySet,Id proLineId){
		return [Select Id,p.Product__r.Product_Type__c, 
					   p.Product__r.Name, p.Product__c, 
					   p.Name,p.Product__r.Parent_Product_Name__c, 
					   p.Product__r.Parent_Product__c 
			    From   Product_Mapping__c p 
			    where  p.Product__r.Product_Type__c = 'Product' and 
			    	   Sellable_Item__c in: prodMapKeySet
			    	   and Product__r.Parent_Product__c =:proLineId];
	}
	
	public static List<Product_Mapping__c> queryProductMappingProd(Set<Id> prodMapKeySet,Id prodId){
		return [Select Id,p.Product__r.Product_Type__c, 
					   p.Product__r.Name, p.Product__c, 
					   p.Name,p.Product__r.Parent_Product_Name__c, 
					   p.Product__r.Parent_Product__c 
			    From   Product_Mapping__c p 
			    where  p.Product__r.Product_Type__c = 'Product' and 
			    	   Sellable_Item__c in: prodMapKeySet
			    	   and Product__c=:prodId];
	}*/
	
	public static List<Product_Mapping__c> queryProductMappingAll(Set<Id> prodMapKeySet,Set<String> prodId,Set<String> proLineId){
		system.debug('--|prodId'+prodId);
		system.debug('--|prodMapKeySet'+prodMapKeySet);
		system.debug('--|proLineId'+proLineId);
		String selectQuery = 'Select Id,Product__r.Product_Type__c, Product__r.Name, Product__c, Name,Product__r.Parent_Product_Name__c, Product__r.Parent_Product__c,Product__r.Customer_Available__c From   Product_Mapping__c  ';
		String WhereClause = ' where Product__r.Product_Type__c = \'Product\' and Sellable_Item__c in: prodMapKeySet and Product__r.Customer_Available__c = true';
		if(prodId!=null && prodId.size()>0){
			 WhereClause =  WhereClause + ' and Product__c in:prodId';
		}
		if(proLineId!=null  && proLineId.size()>0){
			WhereClause =  WhereClause + ' and Product__r.Parent_Product__c in:proLineId';
		}
		String Query;
		Query = selectQuery;
		if(WhereClause!=null){
			Query += WhereClause;
		}
		system.debug('--Query'+Query);
		return database.query(Query);
		/*return [Select Id,p.Product__r.Product_Type__c, 
					   p.Product__r.Name, p.Product__c, 
					   p.Name,p.Product__r.Parent_Product_Name__c, 
					   p.Product__r.Parent_Product__c 
			    From   Product_Mapping__c p 
			    where  p.Product__r.Product_Type__c = 'Product' and 
			    	   Sellable_Item__c in: prodMapKeySet
			    	   and Product__c in:prodId
			    	   and Product__r.Parent_Product__c in:proLineId];*/
	}
	public static List<Support_Product__c> querySupportProduct(List<Id> prodLineId){
		return [SELECT Id,Name,Parent_Product__c,Customer_Available__c 
				FROM   Support_Product__c 
				WHERE  Id IN :prodLineId AND Customer_Available__c =true];
	}
	
	public static List<Support_Product__c> querySupportProdComponent(Set<Id> prodMapkeySet){
		system.debug('--prodMapkeySet'+prodMapkeySet);
		return [SELECT Id,Name,Parent_Product__c,Customer_Available__c 
				FROM   Support_Product__c 
				WHERE  Parent_Product__c in :prodMapkeySet 
					   and Product_Type__c = 'Component' AND Customer_Available__c =true];
	}
	
	public static List<Product_Version__c> queryCompVersion(Id comp){
		return [SELECT Id,Version__c,Name 
		        FROM   Product_Version__c 
		        WHERE Parent_Product__c = :comp AND Customer_Available__c =true ORDER BY Name DESC];
	}
}