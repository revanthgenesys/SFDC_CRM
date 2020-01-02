public with sharing class AQIAverageCtrl {


	public integer theAverage {get;set;}
	
	
	public AQIAverageCtrl(ApexPages.StandardController stdController){
		
		String auditId = stdController.getId();
		
		List<AQI_Audit__c> audits = [SELECT Author__c FROM AQI_Audit__c where id=:auditId];
    	
    	AggregateResult[] groupedResults = [SELECT AVG(AQI_Score__c) FROM AQI_Audit__c where Author__c=:audits[0].Author__c and  Status__c='Complete' ];
		
		theAverage = integer.valueOf((Decimal)groupedResults[0].get('expr0'));
		
	}
	

}