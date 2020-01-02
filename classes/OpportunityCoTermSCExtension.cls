//Naresh Kumar	06/02/2014
public with sharing class OpportunityCoTermSCExtension {
	public List<Quote_Service_Contracts__c> quoteSC {get;set;}
	public Boolean showGrid {get;set;}
	public OpportunityCoTermSCExtension(ApexPages.StandardController stdCon){
        String oppName = [SELECT Name FROM Opportunity WHERE Id = :stdCon.getId()].Name;
            
		quoteSC = [SELECT Quote__c, Quote__r.Name, Quote__r.BigMachines__Status__c, Service_Contract__c,
		Service_Contract__r.Renewal_Opportunity__r.Name, Service_Contract__r.Renewal_Opportunity__c 
			FROM Quote_Service_Contracts__c WHERE  Service_Contract__r.Renewal_Opportunity__c = :stdCon.getId() AND Quote__c != NULL];
		if(quoteSC.isEmpty() || oppName.startsWith('Downsize') || oppName.startsWith('Drop') )
			showGrid = false;
		else
			showGrid = true;
	}
}