/*****************************************************
Class: DisplayGenesysCaseUpdateExtension
Author – Vinay Lakshmeesh
Date – 3/7/2013
Usage : Display only public Genesys Case Updates
Revision History
******************************************************/

public with sharing class DisplayGenesysCaseUpdateExtension {
	private Case ca;
	public string caNum {get;set;}
	public Id casId {get;set;} 
	public List<Genesys_Case_Updates__c> publicCaseCmmntList {get;set;}
	public String caseNumberField {get;set;}
	public displayGenesysCaseUpdateExtension(ApexPages.StandardController stdController) {
	 	
	 	this.ca = (Case)stdController.getRecord();
	 	String casId = ca.id;
	 	casId = stdController.getId();
	 	system.debug('--casId'+casId);
	 	caNum = ca.CaseNumber;
		caseNumberField = Label.Case_Update_CaseNumber_Field;
	 	
	 	Id recId = [SELECT Id,DeveloperName,
	 					   SobjectType 
 					FROM   RecordType 
 					WHERE  DeveloperName = 'Public'][0].Id;
	 	
	 	publicCaseCmmntList = new List<Genesys_Case_Updates__c>();
	 	
	 	publicCaseCmmntList = [SELECT 	Id,CreatedDate,
	 								  	Name 
 							   FROM   	Genesys_Case_Updates__c 
 							   WHERE  	Case__c = :casId AND 
 							   		  	RecordTypeId  = :recId 
 							   order by CreatedDate desc];
	}
	 
}