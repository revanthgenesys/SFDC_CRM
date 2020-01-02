//Naresh Kumar  10/20/2016
global class SMLNBABatch implements Database.Batchable<sObject>{
    global final String Query;

    global SMLNBABatch(String q){
        this.query = q; 
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);     
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account> accounts = new List<Account>();
        for(SObject eachRecord : scope){
            SMLNBABatchHelper.populateNBAStatus(eachRecord.id);
        }

    }

    global void finish(Database.BatchableContext BC){}
}