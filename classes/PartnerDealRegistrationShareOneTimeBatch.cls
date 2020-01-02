/*
 * Class            : PartnerDealRegistrationShareOneTimeBatch
 * Description      : A Batch class to share Deal Registrations for all Designated contacts - One time batch.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Aug 01, 2017
 * Test Class       : PartnerPortalCustomSharingTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 global class PartnerDealRegistrationShareOneTimeBatch implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
    	String query = 'SELECT Id, Name, Account__c FROM Partner_Portal_Prospect__c WHERE Account__c != NULL';
    	if(Test.isRunningTest())
    		query = query + ' LIMIT 10';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Partner_Portal_Prospect__c> scope){
    	PartnerPortalCustomSharing.shareDealRegistrationWithDesignatedContacts(scope);
    }
    
    global void finish(Database.BatchableContext BC){
        // Sharing completed for given contacts ...
    }
}