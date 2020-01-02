/*
 * Class            : AddPartnerContactsToOpportunityTeamBatch
 * Description      : A Batch class to add designated contacts of partner accounts to Opportunity Team.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Aug 01, 2017
 * Test Class       : PartnerPortalCustomSharingTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */

global class AddPartnerContactsToOpportunityTeamBatch implements Database.Batchable<SObject>{
   
    global Database.QueryLocator start(Database.BatchableContext bc){
		Id partnerRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Enterprise - Business Partner').getRecordTypeId();
    	String query = 'SELECT Id, Name, AccountId FROM Contact '
    				 + ' WHERE Contact.Account.RecordTypeId = \''+partnerRecordTypeId+'\'' 
    				 + ' AND Contact.Account.Status__c = \'Active\' AND Contact.Account.ININ_ID__c != NULL '
    				 + ' AND Designated_Partner_Contact__c = true AND Status__c = \'Active\'';
    	if(Test.isRunningTest())
    		query = query + ' LIMIT 5';
	    return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> scope){
		PartnerPortalCustomSharing.manageOpportunityTeamForPartnerContacts(scope);
    }
    
    global void finish(Database.BatchableContext BC){
        Database.executeBatch(new ShareOpportunityRelatedObjectsToOTMBatch(), 10);
    }
}