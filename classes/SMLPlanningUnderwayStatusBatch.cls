//Naresh Kumar  09/26/2015
global class SMLPlanningUnderwayStatusBatch implements Database.Batchable<sObject>{
    global final String Query;
    //SELECT Status__c, Account__c, Planning_Underway_Date__c  FROM SML_Data__c WHERE Status__c = 'Planning Underway' AND Account__c != null AND Planning_Underway_Date__c < LAST_N_DAYS:180
    global SMLPlanningUnderwayStatusBatch(String q){
        this.query = q; 
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);     
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<SML_Data__c> smlData= new List<SML_Data__c>();
        for(SObject eachRecord : scope){
            smlData.add((SML_Data__c)eachRecord);
        }
        SMLPlanningUnderwayStatusBatchHelper.resetPlanningUnderwayStatus(smlData);
    }

    global void finish(Database.BatchableContext BC){}
}