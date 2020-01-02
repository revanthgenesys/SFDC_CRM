global class PartnerKPIYTDCalculationsDailyBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC){
		String supportCaseRecordTypeId = PartnerKPIManagementUtil.getCaseSupportRecordTypeId();
        List<String> supportProductsToExclude = PartnerKPIManagementUtil.getSupportProductsToExclude();
        
        AggregateResult[] groupedResults = [SELECT Sold_To_Account__c, Count(Id) 
                                            FROM CASE WHERE 
                                               (
                                                   RecordTypeId = :supportCaseRecordTypeId  
                                                   AND Sold_To_Account__r.Type = 'Partner' 
                                   				   AND Sold_To_Account__r.Status__c = 'Active'
                                                   AND Status = 'Closed' 
                                                   AND Assignment_Status__c = 'Closure Activities Completed' 
                                                   AND Deployment_Type__c != 'Cloud' 
                                                   AND Origin != 'Alarm' 
                                                   AND Product_Support_Group__c NOT IN ('Custom Applications','CC Tools & Infrastructure') 
                                                   AND Product_Line__c NOT IN :supportProductsToExclude
                                                   AND Sold_To_Account__r.Name != 'Genesys Internal' 
                                                   AND (NOT Contact.Account.Name like '%Genesys%')
                                               )
                                                AND 
                                                ( 
                                                    (
                                                        Closure_Reason_Code__c NOT IN ('Customer requested to Close', 'Closed by Customer - Cancelled', 'Closed by Customer - Resolved') 
                                                        AND Owner.Name = 'Unassigned'
                                                    ) 
                                                    OR Owner.Name != 'Unassigned'
                                                ) AND SystemModStamp >= YESTERDAY 
                                        	GROUP BY Sold_To_Account__c];
        
        Set<String> partnerAccountIds = new Set<String>();
		for (AggregateResult ar : groupedResults)  {
			partnerAccountIds.add((String)ar.get('Sold_To_Account__c'));
		}
        
        String query = 'SELECT Id, Name, Region__c  FROM Account WHERE Id IN :partnerAccountIds';
        if(Test.isRunningTest()){
            query = query + ' LIMIT 1';
        }
        return Database.getQueryLocator(query); 
        
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        String period = PartnerKPIManagementUtil.getCurrentPeriod();
        for(sObject so: scope){
			Account a = (Account)so;            
            PartnerKPIManagementUtil.compileKPIInfoForPartnerPerPeriod(a.Id,period);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        // Finished processing for all Partners
    }
}