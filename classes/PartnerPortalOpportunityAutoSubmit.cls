global  class PartnerPortalOpportunityAutoSubmit {
	//@future
    public static void autoSubmitPartnerPortalOpportunity(List<Id> recordIds){
        for(Id recordId : recordIds){
            if(!Approval.isLocked(recordId)){
                
                // Create an approval request 
                Approval.ProcessSubmitRequest approvalRequest = new Approval.ProcessSubmitRequest();
                approvalRequest.setComments('Auto Submitted for approval.');
                approvalRequest.setObjectId(recordId);
                
                // Submit on behalf of a specific submitter
                approvalRequest.setSubmitterId(UserInfo.getUserId()); 
                
                // Submit the record to specific process and skip the criteria evaluation
                approvalRequest.setProcessDefinitionNameOrId('Partner_Portal_Opportunity_3_steps');
                approvalRequest.setSkipEntryCriteria(true);
                
                // Submit the approval request
                Approval.ProcessResult result = Approval.process(approvalRequest);   
                
            }
        }
    }
	
}