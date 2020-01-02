/*
	Naresh Kumar	07/02/2013
*/
global with sharing class UpdateServiceContractBatchSchedular implements Schedulable{
	global void execute(SchedulableContext SC) {
    	UpdateServiceContractBatch objBatch = new UpdateServiceContractBatch();
    	database.executebatch(objBatch, 1); 
    }
}