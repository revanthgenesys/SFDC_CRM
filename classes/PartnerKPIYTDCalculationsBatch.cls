// To calculate KPI Header info for all Partners 
global class PartnerKPIYTDCalculationsBatch implements Database.Batchable<sObject>, Database.Stateful {
    global Set<String> partnerAccountIds;
    global String period;
    global PartnerKPIYTDCalculationsBatch(Set<String> partnerAccountIds, String period){
        this.partnerAccountIds = partnerAccountIds;
        this.period = period;
    }
    
	global Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'SELECT Id, Name, Region__c  FROM Account WHERE Id IN :partnerAccountIds';
        if(Test.isRunningTest())
            query = query + ' LIMIT 1';
        return Database.getQueryLocator(query); 
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(sObject so: scope){
			Account a = (Account)so;            
            if(period == 'All')
        		PartnerKPIManagementUtil.compileKPIInfoForPartner(a.Id);
            else if(String.isNotEmpty(period))
        		PartnerKPIManagementUtil.compileKPIInfoForPartnerPerPeriod(a.Id,period);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        // Finished processing for all Partners
    }
}