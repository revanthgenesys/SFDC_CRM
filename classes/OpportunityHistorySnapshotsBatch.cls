//Naresh Kumar  09/23/2016
global class OpportunityHistorySnapshotsBatch implements Database.Batchable<sObject>{
    global final String Query;
    global final Boolean doDeleteAll;
    global OpportunityHistorySnapshotsBatch(String q, Boolean doDeleteAll){
        this.query = q; 
        this.doDeleteAll = doDeleteAll;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);     
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(SObject eachRecord : scope){
            OpportunityHistorySnapshots.createSnapshotDataForOpportunity(eachRecord.id, doDeleteAll);
        }        
    }
    global void finish(Database.BatchableContext BC){}
}