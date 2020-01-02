//Naresh Kumar  06/18/2014
global without sharing class QuoteApprovalAssignment {

    webservice static String submitQuoteToApproval(String quoteId){
        try{
            //Getting quote approval record
            BigMachines__Quote__c quote = QuoteApprovalUtil.getQuote(quoteId);
            //Quote can't be submitted if status is Quote Approval Pending
            if(quote.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_PENDING)  
                return 'Quote can not be submitted when status is Quote Approval Pending.'; 
            //populates all the step(s) 
            List<Quote_Approval__c> quoteApprovalsToBeInserted = getNextApprovalRecords(quote, 0);
            //quote approvals excluding notification only
            List<Quote_Approval__c> quoteApprovalsWONotificationOnly = new List<Quote_Approval__c>();
            if(quoteApprovalsToBeInserted != null){
            	for(Quote_Approval__c eachQA : quoteApprovalsToBeInserted){
            		if(eachQA.Status__c != QuoteApprovalUtil.STATUS_APPROVER_NOTIFICATION_ONLY)
            			quoteApprovalsWONotificationOnly.add(eachQA);
            	}
            }
            //Approval not required
            if(quoteApprovalsWONotificationOnly.isEmpty()){
                quote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_APPROVED;     
                quote.DAP_Reason__c = null;     
            }
            //Approval required
            else{
                quote.BigMachines__Status__c = QuoteApprovalUtil.QUOTE_STATUS_PENDING;                              
            }
            quote.Approval_Submission_Date__c = System.today();
            if(quote.Explanation_of_price_Discount_request__c != null && !String.isBlank(quote.Explanation_of_price_Discount_request__c)){
                Boolean isDiscountApproval = false;
                for(Quote_Approval__c eachQA : quoteApprovalsToBeInserted){
                    if(eachQA.Reason_Name__c.contains('Discount greater than')){
                        isDiscountApproval = true;
                        break;
                    }
                }
                if(isDiscountApproval){
                    return 'Explanation of Price/Discount Request (under DAP Details) needs to be provided before quote can be submitted for approval.';
                }
            }           
            update quote;           
            if(quoteApprovalsToBeInserted != null && !quoteApprovalsToBeInserted.isEmpty()){
                insert quoteApprovalsToBeInserted;
            }   
            return 'OK';
        }
        catch(Exception ex){
            return 'Error while submitting for approval. Error : ' + ex.getMessage();
        }
        return 'OK';
    }
    
    public static List<Quote_Approval__c> getNextApprovalRecords(BigMachines__Quote__c quote, Integer stepNo){
        //Getting approval submission order
        Decimal submissionCounter = QuoteApprovalUtil.getApprovalSubmission(quote.id, stepNo);
        Set<Id> quoteApprovalConfigIds = new Set<Id>();
        //Will contain ids of already approved records for current step
        Set<Id> setAlreadyApprovedStepDetailsIds = new Set<Id>();
        System.debug('NKC debug submissionCounter ['+submissionCounter+']');
        //Querying records from junction object between quote approval config and approver
        List<Quote_Approval_Step_Details__c> quoteApprovers;
        //Populating all the steps into quote approval object.  
        if(stepNo == 0){
            List<Quote_Approval__c> quoteApprovers1 = QuoteApprovalAssignmentHelper.getQuoteApprovalsIfReviseQuoteIsApplicable(quote, submissionCounter, false);
            if(quoteApprovers1 != null)
                return quoteApprovers1;
            Set<Id> stepIds = new Set<Id>();
            //Getting quote approvals steps
            Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteApprovalSteps = QuoteApprovalUtil.getQuoteApprvalConfigRecords(quote, stepIds);
            //Getting quote approval records
            quoteApprovers = QuoteApprovalUtil.getQuoteApprovalRecords(stepIds, quote);                 
            //Filters quote approval records for current quote
            mapIdVsQuoteApprovalSteps = QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote, quoteApprovers, mapIdVsQuoteApprovalSteps);
            System.debug('NKC debug quoteApprovers [' + quoteApprovers + ']');
            //if there is no qualifying approver, approve record automatically
            if(quoteApprovers.isEmpty())
                return null;
            //If don't resubmit to approved approvers is checked            
            if((quote.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_REJECTED
                && quote.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_REVISION_PENDING) 
                || quote.Don_t_Resubmit_to_Approved_Approvers__c)
                setAlreadyApprovedStepDetailsIds = QuoteApprovalAssignmentHelper.getAlreadyApprovedRecords(quote, submissionCounter);
            //System.debug('NKC debug quoteApproverDetails ['+quoteApprovers+']');
            
            //Get quote approval steps
            List<Quote_Approval__c> quoteApprovalsToBeInserted = new List<Quote_Approval__c>();     
            //Would store first order no
            Decimal firstOrderNo = 0;           
            //Would store unique approvers and their approval record (it will help to populate reason)
            Map<String, Quote_Approval__c> mapApproverIdApproval = new Map<String, Quote_Approval__c>();
            for(Quote_Approval_Step_Details__c eachRecord : quoteApprovers){
                //If record is already approve, don't submit it again.
                if(setAlreadyApprovedStepDetailsIds.contains(eachRecord.id))
                    continue;
                String stepAndApprover = eachRecord.Quote_Approver_Step_Approver_Detail__r.OwnerId + eachRecord.Quote_Approval_Step__r.Name;
                //Skip current record if it's approver is already on the list.
                if(mapApproverIdApproval.containsKey(stepAndApprover)){
                    continue;
                }
                if(firstOrderNo == 0)
                    firstOrderNo = eachRecord.Quote_Approval_Step__r.Order__c;
                //New quote approvals record
                Quote_Approval__c newQuoteApproval = new Quote_Approval__c();
                List<Quote_Approval_Config_And_Steps__c> quoteApprovalConfigAndSteps = mapIdVsQuoteApprovalSteps.get(eachRecord.Quote_Approval_Step__c);    
                //Populating quote approval reason  
                String approvalReason = QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote, eachRecord, quoteApprovalConfigAndSteps, newQuoteApproval.Reason_Name__c);
                newQuoteApproval.Reason_Name__c = approvalReason;               
                //Removes extra comma at the end
                if(newQuoteApproval.Reason_Name__c.lastIndexOf(',') != -1)
                    newQuoteApproval.Reason_Name__c = newQuoteApproval.Reason_Name__c.substring(0, newQuoteApproval.Reason_Name__c.lastIndexOf(','));
                newQuoteApproval.BigMachines_Quote__c = quote.id;
                newQuoteApproval.Submitted_Date__c = System.now();
                newQuoteApproval.Quote_Approval_Step_Details__c = eachRecord.id;
                //Populating Step No
                newQuoteApproval.Step__c = eachRecord.Quote_Approval_Step__r.Order__c;
                //Approver
                newQuoteApproval.ownerId = eachRecord.Quote_Approver_Step_Approver_Detail__r.OwnerId;
                //Update Pending status for only next step
                if(firstOrderNo == eachRecord.Quote_Approval_Step__r.Order__c)
                    newQuoteApproval.Status__c = QuoteApprovalUtil.STATUS_PENDING;
                else
                    newQuoteApproval.Status__c = QuoteApprovalUtil.STATUS_INACTIVE;
                if(eachRecord.Quote_Approver_Step_Approver_Detail__r.Action_Text__c == QuoteApprovalUtil.NOTIFICATION_ONLY){
                    newQuoteApproval.Status__c = QuoteApprovalUtil.STATUS_APPROVER_NOTIFICATION_ONLY;
                    newQuoteApproval.Comments__c = 'No Approval Required.';
                }
                newQuoteApproval.Product_Ids__c = eachRecord.Quote_Approver_Step_Approver_Detail__r.Product_Ids__c;
                newQuoteApproval.Approval_Submission_Counter__c = submissionCounter;
                newQuoteApproval.Product_Manager_Approval_Group__c = eachRecord.Quote_Approver_Step_Approver_Detail__r.PM_Group_Id__c;
                mapApproverIdApproval.put(stepAndApprover, newQuoteApproval);
                quoteApprovalsToBeInserted.add(newQuoteApproval);   
            }
            //return approval steps to quote approval object
            return quoteApprovalsToBeInserted;          
        }
        //Next step
        else{
            //Getting next step items (if any)
            List<Quote_Approval__c> nextStepApprovals = [SELECT Status__c FROM Quote_Approval__c WHERE 
                BigMachines_Quote__c =: quote.id AND Step__c =: stepNo AND Status__c =: QuoteApprovalUtil.STATUS_INACTIVE
                AND Approval_Submission_Counter__c =: submissionCounter];
            //If there is any pending approval items
            if(!nextStepApprovals.isEmpty()){
                for(Quote_Approval__c eachQA : nextStepApprovals){
                    eachQA.Status__c = QuoteApprovalUtil.STATUS_PENDING;
                    eachQA.Submitted_Date__c = System.now();
                }
                update nextStepApprovals;
            }
            return null;
        }
        return null;        
    }
}