//Naresh Kumar    11/10/2016
global  without sharing class SMLNBABatchSchedular implements Schedulable {
    global void execute(SchedulableContext schedulableContext) {
        SMLNBABatch smlNBABatch = new SMLNBABatch('SELECT id FROM Account WHERE ID IN (SELECT Account__c FROM SML_Data__c)');
        Database.executebatch(smlNBABatch, 10);        
    }
}