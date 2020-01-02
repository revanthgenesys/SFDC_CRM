trigger DealSupport_After on Deal_Support__c (after insert) {
	if(Util.Bypass_Trigger_Chk)
        return; 
    if(Trigger.isAfter && Trigger.isInsert)	{
         PartnerPortalCustomSharing.shareDealSupportRequestWithOpportunityTeam(Trigger.NEW);
    }
    
}