/*
 * Class            : PartnerDealRegDeleteSharingBatch
 * Description      : A Batch class to clean up sharing for the Deal Registrations for a given contacts.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Aug 01, 2017
 * Test Class       : PartnerPortalCustomSharingTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
global class PartnerDealRegDeleteSharingBatch implements Database.Batchable<SObject>{

    global List<String> contactIds {get; set;}
    
    global PartnerDealRegDeleteSharingBatch(List<String> contactsToProcess){
    	contactIds = contactsToProcess;	
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
    	Set<String> accountIds = new Set<String>();
		for(User u : [SELECT Id, ContactId, Contact.AccountId FROM User WHERE ContactId IN :contactIds]){
			accountIds.add(u.Contact.AccountId);
		} 
        return Database.getQueryLocator([SELECT Id, Account__c FROM Partner_Portal_Prospect__c WHERE Account__c IN :accountIds]);
    }
    
    global void execute(Database.BatchableContext bc, List<Partner_Portal_Prospect__c> scope){
    	PartnerPortalCustomSharing.cleanupDealRegistrationSharing(contactIds, scope);
    }
    
    global void finish(Database.BatchableContext BC){
        // Sharing Deletion completed for given contacts ...
    }
}