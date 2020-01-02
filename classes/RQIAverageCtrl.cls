public with sharing class RQIAverageCtrl {

	public integer theAverage {get;set;}
	
	
	public RQIAverageCtrl(ApexPages.StandardController stdController){
		
		String auditId = stdController.getId();
		
		List<RQI_Audit__c> audits = [SELECT Author__c FROM RQI_Audit__c where id=:auditId];
    	
    	AggregateResult[] groupedResults = [SELECT AVG(RQI_Score__c) FROM RQI_Audit__c where Author__c=:audits[0].Author__c and  Status__c='Complete' ];
		
		theAverage = integer.valueOf((Decimal)groupedResults[0].get('expr0'));
		
	}

}