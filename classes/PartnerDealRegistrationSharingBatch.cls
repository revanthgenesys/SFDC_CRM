/*
 * Class            : PartnerDealRegistrationSharingBatch
 * Description      : A Batch class to share Deal Registrations with given Designated contacts.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Aug 01, 2017
 * Test Class       : PartnerPortalCustomSharingTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 global class PartnerDealRegistrationSharingBatch implements Database.Batchable<SObject>{
    
    global List<String> contactIds {get; set;}
    
    global PartnerDealRegistrationSharingBatch(List<String> contactsToProcess){
    	contactIds = contactsToProcess;	
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
		Set<String> accountIds = new Set<String>();
		for(User u : [SELECT Id, ContactId, Contact.AccountId FROM User WHERE isActive = true AND ContactId IN :contactIds]){
			accountIds.add(u.Contact.AccountId);
		} 
    	
        return Database.getQueryLocator([SELECT Id, Name, Account__c FROM Partner_Portal_Prospect__c WHERE Account__c != NULL AND Account__c IN :accountIds]);
    }
    
    global void execute(Database.BatchableContext bc, List<Partner_Portal_Prospect__c> scope){
    	PartnerPortalCustomSharing.shareDealRegistrationWithDesignatedContacts(contactIds, scope);
    }
    
    global void finish(Database.BatchableContext BC){
        // Sharing completed for given contacts ...
    }
}