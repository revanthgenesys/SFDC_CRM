/*
 * Class			: UpdateCasesForGUCertifiedContact1
 * Description		: This Batch Class updates Cases info about whether the case has been logged by GU Certified Contact or not
 * 					  by querying the info from KPI1 Case Details (KPI1_Case_Details__c). 
 * Author			: Narasimha "Rao" Tumma
 * Created Date		: May 26, 2016 
 * Test Class		: 
 * 	
 */
global class UpdateCasesForGUCertifiedContact1 implements Database.Batchable<sObject> {
	global Database.QueryLocator start(Database.BatchableContext BC){
        String queryStr = 'SELECT id, Case_Number__c, Case_Logged_By_GU_Certified_Contact__c FROM KPI1_Case_Details__c';
        if(Test.isRunningTest()){
            queryStr = queryStr + ' LIMIT 10';
        }
        return Database.getQueryLocator(queryStr);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<String, String> kpiCasesMap = new Map<String, String>();
        for(sObject so : scope){
            KPI1_Case_Details__c kpiCase = (KPI1_Case_Details__c)so;
            kpiCasesMap.put(kpiCase.Case_Number__c, kpiCase.Case_Logged_By_GU_Certified_Contact__c);
        }
        
        List<Case> cases = new List<Case>();
        
        for(Case c : [SELECT id, CaseNumber, GU_Certified_Contact__c, Case_Logged_by_GU_Certified_Contact__c FROM Case 
                            WHERE CaseNumber IN :kpiCasesMap.keySet()]){
            if(kpiCasesMap.containsKey(c.CaseNumber)){
                if(kpiCasesMap.get(c.CaseNumber) == 'Yes'){
    	            c.GU_Certified_Contact__c = 'Yes';
                    // c.Case_Logged_by_GU_Certified_Contact__c = 'Yes';
                } else {
                    c.GU_Certified_Contact__c = 'No';
                    // c.Case_Logged_by_GU_Certified_Contact__c = 'No'; 
                }
                cases.add(c);
            }
        }
        if(cases.size() > 0){
            try{
                Database.update(cases);
            } catch(Exception e){
                System.debug('Exception = ' + cases);
            }
        }
        	
    }
	global void finish(Database.BatchableContext BC){
        Database.executeBatch(new UpdateCasesForGUCertifiedContact2());
    }
}