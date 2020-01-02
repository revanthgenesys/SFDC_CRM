//Naresh Kumar  09/27/2016
global class OpportunityCrossSellExpensionHelperBatch implements Database.Batchable<sObject>{
    global final String Query;

    global OpportunityCrossSellExpensionHelperBatch(String q){
        this.query = q; 
    }

    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);     
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        for(SObject eachRecord : scope){
            OpportunityCrossSellExpensionHelper.populateQuoteSCMapping(eachRecord.id, true);
        }        
    }
    global void finish(Database.BatchableContext BC){}
}