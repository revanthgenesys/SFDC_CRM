// Test Classes: PartnerPortalReferralsExpirationTest, PartnerPortalOpportunityAutoSubmitTest
trigger PartnerPortalOpportunityRegistration_After on partner_portal_prospect__c (after insert, after update) {
    if(Util.Bypass_Trigger_Chk) 
        return;   
 
    if(Trigger.isAfter && Trigger.isInsert) {
        PartnerPortalCustomSharing.shareDealRegistrationWithDesignatedContacts(Trigger.NEW);
    }  
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
        List<Id> recordIdsForApprovalProcess = new List<Id>();
        for(partner_portal_prospect__c record : Trigger.NEW){
            if(record.Status__c == 'Request Submitted' && record.Opportunity_Channel_Manager__c != NULL && record.LastModifiedById == Label.Zinfi_Integration_User){
                recordIdsForApprovalProcess.add(record.Id);   
            }    
        }
        if(recordIdsForApprovalProcess.size() > 0){
            PartnerPortalOpportunityAutoSubmit.autoSubmitPartnerPortalOpportunity(recordIdsForApprovalProcess);    
        }
    }
    
    // INC0305051
	
    if(Trigger.isAfter && Trigger.isUpdate){
        for(partner_portal_prospect__c record : Trigger.NEW){
            if(Trigger.OldMap.get(record.Id).Opportunity__c != null && record.Opportunity__c != null && record.Opportunity__c != Trigger.OldMap.get(record.Id).Opportunity__c){
                Opportunity relatedOpp = [SELECT id, Partner_Opportunity_Registration__c FROM Opportunity WHERE Id = :record.Opportunity__c];
                if(relatedOpp.Partner_Opportunity_Registration__c != NULL){
                    record.addError('Selected Opportunity is already associated with a different Deal Registration.');      
                }
            }
        } 
    }
}