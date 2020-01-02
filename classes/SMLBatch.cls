//Naresh Kumar  09/26/2015
global class SMLBatch implements Database.Batchable<sObject>{
    global final String Query;

    global SMLBatch (String q){
        this.query = q; 
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);     
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account> accounts = new List<Account>();
        for(SObject eachRecord : scope){
            accounts.add((Account)eachRecord);
        }
        SMLBatchHelper.populateData(accounts);
    }

    global void finish(Database.BatchableContext BC){}
}