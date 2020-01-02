/*****************************************************
Class: SearchPortalCaseController
Author : Vinay Lakshmeesh   3/19/2013 
This class adds search case functionality on cusotmer portal
Revision History

******************************************************/

public with sharing class SearchPortalCaseController{
	public String searchInput {get;set;}
	//public String searchFiledName {get;set;}
	public SearchPortalCaseController(){
		
	}
	
    public Pagereference searchCases(){
    	Pagereference pg = new Pagereference(URL.getSalesforceBaseUrl().toExternalForm()+'/apex/SearchPortalCaseResults?inp='+searchInput);
    	pg.setRedirect(true);
    	return pg;
    }
}