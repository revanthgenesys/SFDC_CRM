//Naresh Kumar
trigger QuoteApprovalMain on Quote_Approval__c (after insert, after update, before insert, 
before update) {    
    if(trigger.isAfter && trigger.isUpdate){
        //Assign next step (if any)
        QuoteApprovalMainHelper.assignNextStep(trigger.oldMap, trigger.new);
        //Updates quote status if it needs to be updated after a quote approval record is updated
        QuoteApprovalMainHelper.quoteStatusHandler(trigger.oldMap, trigger.new);    
        //Updates duplicate approver records if any
        //Naresh Kumar  05/08/2017  We need to deactivate auto approvals for now.
        //QuoteApprovalAssignmentHelper.approveDuplicateApproverRecords(trigger.oldMap, trigger.new);   
    }
}