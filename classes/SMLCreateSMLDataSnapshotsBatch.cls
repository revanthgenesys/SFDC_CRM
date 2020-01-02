//Naresh Kumar  07/18/2016
global class SMLCreateSMLDataSnapshotsBatch implements Database.Batchable<sObject>{
    global final String Query;
    global final Boolean doDeleteAll;
    global SMLCreateSMLDataSnapshotsBatch(String q, Boolean doDeleteAll){
        this.query = q; 
        this.doDeleteAll = doDeleteAll;
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);     
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account> accounts = new List<Account>();
        for(SObject eachRecord : scope){
            SMLCreateSMLDataSnapshots.createSnapshotDataForAccount(eachRecord.id, doDeleteAll);
        }        
    }
    global void finish(Database.BatchableContext BC){}
}