trigger OpportunityTeamMember_After on OpportunityTeamMember (after insert, after update, after delete) {
    if(Util.Bypass_Trigger_Chk)
        return;
	if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
	    if(!(System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled()))
	        PartnerPortalCustomSharing.shareRelatedObjectsWithOpportunityTeam(Trigger.New);
	}
	if(Trigger.isAfter && Trigger.isDelete){
	    if(!(System.isFuture() || System.isBatch() || System.isQueueable() || System.isScheduled())){
	    	Map<String, Set<String>> opportunityIdUserIdsMap = new Map<String, Set<String>>();
	    	for(OpportunityTeamMember otm : Trigger.OLD){
	    		if(opportunityIdUserIdsMap.get(otm.OpportunityId) != NULL){
					opportunityIdUserIdsMap.get(otm.OpportunityId).add(otm.UserId);
				} else {
					opportunityIdUserIdsMap.put(otm.OpportunityId, new Set<String>{otm.UserId});
				}
	    	}
	    	PartnerPortalCustomSharing.cleanupRelatedObjectsSharing(opportunityIdUserIdsMap);	  
	    }
	}
}