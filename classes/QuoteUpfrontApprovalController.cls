//Naresh Kumar	07/23/2014
public without sharing class QuoteUpfrontApprovalController {
	public List<approvalWrapper> upfrontApprovals {get;set;}
	public String quoteId {get;set;}
    public String strQuoteName {get; set;}
    public Boolean renderGrid {get;set;}
    public String pricingModel {get;set;}
	public QuoteUpfrontApprovalController(){
		getUpfrontApprovals();		
	}
	
	public List<approvalWrapper> getUpfrontApprovals(){
		//Initializing list
		upfrontApprovals = new List<approvalWrapper>();
		quoteId = ApexPages.currentPage().getParameters().get('id');
		if(quoteId == null || quoteId == ''){
			renderGrid = false;
			return upfrontApprovals;
		}
		//Getting quote approval record
		BigMachines__Quote__c quote = QuoteApprovalUtil.getQuote(quoteId);
        strQuoteName = quote.Name;
        pricingModel = quote.Pricing_Model__c;
        Set<String> setSteps = new Set<String>();
        List<Quote_Approval_Step_Details__c> quoteApprovers1 = QuoteApprovalAssignmentHelper.getQuoteApprovalsIfReviseQuoteIsApplicableUpfront(quote, 0);
        if(quoteApprovers1 != null){
        	for(Quote_Approval_Step_Details__c eachQA : quoteApprovers1){
        		approvalWrapper newRecord = new approvalWrapper();		
        		if(eachQA.Quote_Approver_Step_Approver_Detail__r.Minor_Quote_Change__c == QuoteApprovalUtil.MINOR_QUOTE_CHANGE_ONLY)
	                newRecord.approvalReason  = 'Minor Revision';
	            else
	                newRecord.approvalReason  = 'Minor Revision, Expiration Date';
	            if(!setSteps.contains(eachQA.Quote_Approval_Step__r.Name)){
					newRecord.stepName = eachQA.Quote_Approval_Step__r.Name;
					setSteps.add(eachQA.Quote_Approval_Step__r.Name);
				}				
				newRecord.functionName = eachQA.Quote_Approver_Step_Approver_Detail__r.Name;
				newRecord.actualApprover = eachQA.Quote_Approver_Step_Approver_Detail__r.Actual_Approver__r.Name;
				newRecord.actualApproverEmailId = eachQA.Quote_Approver_Step_Approver_Detail__r.Actual_Approver__r.Email;
				newRecord.approverName = eachQA.Quote_Approver_Step_Approver_Detail__r.Owner.Name;
				//Removes extra comma at the end
				//if(newRecord.approvalReason.lastIndexOf(',') != -1)
				//	newRecord.approvalReason  = newRecord.approvalReason.substring(0, newRecord.approvalReason.lastIndexOf(','));
				//newRecord.approvalReason = QuoteApprovalAssignmentHelper.orderReasons(newRecord.approvalReason);						
				//mapOwnerIdVsQuoteApproval.put(eachQA.Quote_Approval_Step_Details__r.Quote_Approver_Step_Approver_Detail__r.OwnerId, newRecord);	
				upfrontApprovals.add(newRecord);
        	}
        }
        else
		{
	        Set<Id> stepIds = new Set<Id>();
			//Getting quote approvals steps
			Map<String, List<Quote_Approval_Config_And_Steps__c>> mapIdVsQuoteApprovalSteps = QuoteApprovalUtil.getQuoteApprvalConfigRecords(quote, stepIds);		
			//Getting quote approval records		
			List<Quote_Approval_Step_Details__c> quoteApprovers = QuoteApprovalUtil.getQuoteApprovalRecords(stepIds, quote);			
			//Filters quote approval records for current quote
			mapIdVsQuoteApprovalSteps = QuoteApprovalAssignmentHelper.filterQuoteApprovals(quote, quoteApprovers, mapIdVsQuoteApprovalSteps);
			Map<String, approvalWrapper> mapOwnerIdVsQuoteApproval = new Map<String, approvalWrapper>();
			//Looping over 
			for(Quote_Approval_Step_Details__c eachQA : quoteApprovers)
			{
				if(eachQA.Quote_Approver_Step_Approver_Detail__r.Action_Text__c == QuoteApprovalUtil.NOTIFICATION_ONLY)
					continue;
				String stepAndApprover = eachQA.Quote_Approver_Step_Approver_Detail__r.OwnerId + eachQA.Quote_Approval_Step__r.Name;
				if(mapOwnerIdVsQuoteApproval.containsKey(stepAndApprover)){
					continue;
				}
				approvalWrapper newRecord = new approvalWrapper();
				newRecord.functionName = eachQA.Quote_Approver_Step_Approver_Detail__r.Name;
				newRecord.actualApprover = eachQA.Quote_Approver_Step_Approver_Detail__r.Actual_Approver__r.Name;
				newRecord.actualApproverEmailId = eachQA.Quote_Approver_Step_Approver_Detail__r.Actual_Approver__r.Email;
				newRecord.approverName = eachQA.Quote_Approver_Step_Approver_Detail__r.Owner.Name;
				if(!setSteps.contains(eachQA.Quote_Approval_Step__r.Name)){
					newRecord.stepName = eachQA.Quote_Approval_Step__r.Name;
					setSteps.add(eachQA.Quote_Approval_Step__r.Name);
				}
				System.debug('NKC debug mapIdVsQuoteApprovalSteps.keyset() [' + mapIdVsQuoteApprovalSteps.keyset() + ']');
				List<Quote_Approval_Config_And_Steps__c> quoteApprovalConfigAndSteps = mapIdVsQuoteApprovalSteps.get(eachQA.Quote_Approval_Step__c);
				newRecord.approvalReason = QuoteApprovalAssignmentHelper.populateReasonToCurrentApprovalRecord(quote, eachQA, quoteApprovalConfigAndSteps, newRecord.approvalReason);
				//Removes extra comma at the end
				if(newRecord.approvalReason.lastIndexOf(',') != -1)
					newRecord.approvalReason  = newRecord.approvalReason.substring(0, newRecord.approvalReason.lastIndexOf(','));
				//newRecord.approvalReason = QuoteApprovalAssignmentHelper.orderReasons(newRecord.approvalReason);						
				mapOwnerIdVsQuoteApproval.put(stepAndApprover, newRecord);	
				upfrontApprovals.add(newRecord);
			}
        }
		if(upfrontApprovals.isEmpty())
			renderGrid = false;
		else
			renderGrid = true;
		System.debug('NKC debug upfrontApprovals ['+upfrontApprovals+']');
		System.debug('NKC debug renderGrid ['+renderGrid+']');
		return upfrontApprovals;
	}
	
	public class approvalWrapper{
		public String stepName {get;set;}
		public String styleClass {get;set;}
		public String rowType {get;set;}
		public String approvalReason {get;set;}
		public String functionName {get;set;}
		public String actualApprover {get;set;}
		public String approverName {get;set;}
		public String actualApproverEmailId {get;set;}
	}
}