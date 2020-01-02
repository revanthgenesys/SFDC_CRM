/*
 * Class            : ShareOpportunityRelatedObjectsToOTMBatch
 * Description      : A Batch class to share Partner Opportunity related objects with given contacts - ONE TIME BATCH.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Aug 01, 2017
 * Test Class       : PartnerPortalCustomSharingTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */

global class ShareOpportunityRelatedObjectsToOTMBatch implements Database.Batchable<SObject>{
   
    global Database.QueryLocator start(Database.BatchableContext bc){
    	
    	Id partnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
    	String query = 'SELECT Id, Name, AccountId, BusinessPartner__c FROM Opportunity WHERE Lines_of_Businesses__c IN (\'PureCloud\', \'PureConnect\') AND BusinessPartner__c != NULL AND '
    				 + ' BusinessPartner__r.RecordTypeId = \''+partnerRecordTypeId+'\' '
    				 + ' AND BusinessPartner__r.Status__c = \'Active\' AND BusinessPartner__r.ININ_ID__c != NULL ';
    	if(Test.isRunningTest())
    		query = query + ' LIMIT 5';
	    return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Opportunity> scope){

    	Set<String> opportunityIds = new Set<String>();
		for(Opportunity o : scope){
			opportunityIds.add(o.Id);
		}

		PartnerPortalCustomSharing.shareRelatedObjectsWithOpportunityTeam(opportunityIds);
    }
    
    global void finish(Database.BatchableContext BC){
        // Sharing completed
    }
}