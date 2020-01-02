/*
 * Class            : PartnerPortalDeleteSharingBatch
 * Description      : A Batch class to delete the sharing of Partner Opportunity related objects with given contacts.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Aug 01, 2017
 * Test Class       : PartnerPortalCustomSharingTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 global class PartnerPortalDeleteSharingBatch implements Database.Batchable<SObject>{

    global List<String> contactIds {get; set;}
    
    global PartnerPortalDeleteSharingBatch(List<String> contactsToProcess){
    	contactIds = contactsToProcess;	
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
    	Set<String> userIds = new Set<String>();
		for(User u : [SELECT Id, ContactId, Contact.AccountId FROM User WHERE ContactId IN :contactIds]){
			userIds.add(u.Id);
		} 
        return Database.getQueryLocator([SELECT Id, OpportunityId, UserId, TeamMemberRole FROM OpportunityTeamMember WHERE UserId = :userIds]);
    }
    
    global void execute(Database.BatchableContext bc, List<OpportunityTeamMember> scope){
    	Map<String, Set<String>> opportunityIdUserIdsMap = new Map<String, Set<String>>();
    	for(OpportunityTeamMember otm : scope){
    		if(opportunityIdUserIdsMap.get(otm.OpportunityId) != NULL){
				opportunityIdUserIdsMap.get(otm.OpportunityId).add(otm.UserId);
			} else {
				opportunityIdUserIdsMap.put(otm.OpportunityId, new Set<String>{otm.UserId});
			}
    	}

    	PartnerPortalCustomSharing.cleanupRelatedObjectsSharing(opportunityIdUserIdsMap);	  
    	Database.delete(scope, false);	  	
    }
    
    global void finish(Database.BatchableContext BC){
        // Sharing Deletion completed for given contacts ...
    }
}