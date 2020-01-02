//Naresh Kumar		06/23/2014
public without sharing class QuoteApprovalHistoryController {

	public Id quoteId {get;set;}	
	public Id dqId {get;set;}
	//public transient List<historyWrapper> approvals {get;set;}
	public Boolean showApprovalHistory {get;set;}
	public String overAllStatus {get;set;}
	public String mode {get;set;}
	public Boolean showLastSubmission {get;set;}
    //public List<historyWrapper> Approvals {get; set;}
	public QuoteApprovalHistoryController(){
		//getApprovals();
		showApprovalHistory = true;
	}
	public QuoteApprovalHistoryController(ApexPages.StandardController std){
		showApprovalHistory = true;
		getApprovals();
		getDQApprovals();
	}
	/*
	public QuoteApprovalHistoryController(CreateQuoteOnPremiseController customController){
		showApprovalHistory = true;
		getApprovals();
	}
	*/
	public List<historyWrapper> getDQApprovals(){
		System.debug('NKC debug quoteId ['+quoteId+']');
		//Quote id
		//if(ApexPages.currentPage().getParameters().get('id') != null)
		//	quoteId = ApexPages.currentPage().getParameters().get('id');
		//Whether to show approve/reject button	
		mode = 	ApexPages.currentPage().getParameters().get('mode');
		System.debug('NKC debug dqId ['+dqId+']');
		if(dqId == null)
			return null;
		//Getting quote staus
		Deal_Qualification__c dq = [SELECT Status__c FROM Deal_Qualification__c WHERE id =: dqId];
		if(dq.Status__c == DealQualificationApprovalUtil.QUOTE_STATUS_PENDING)
			overAllStatus = DealQualificationApprovalUtil.STATUS_PENDING;
		else if(dq.Status__c  == DealQualificationApprovalUtil.QUOTE_STATUS_REJECTED)
			overAllStatus = DealQualificationApprovalUtil.STATUS_REJECTED;
		else if(dq.Status__c  == DealQualificationApprovalUtil.QUOTE_STATUS_REVISION_PENDING)
			overAllStatus = DealQualificationApprovalUtil.STATUS_CANCELLED;
		else //if(quote.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_APPROVED)
			overAllStatus = DealQualificationApprovalUtil.STATUS_APPROVED;
		
		//Getting quote approval records with related fields
		List<Quote_Approval__c>  quoteApprovals = [SELECT id, Quote_Approval_Step_Details__c, owner.Name, ownerId, Status__c,
		Quote_Approval_Step_Details__r.Quote_Approval_Step__r.Order__c, Quote_Approval_Step_Details__r.Priority_Sequence__c,
		Step_Name__c, Quote_Approval_Step_Details__r.Quote_Approval_Step__c, Quote_Approval_Step_Details__r.Quote_Approver_Step_Approver_Detail__r.Name,
		CreatedDate, Actual_Approver__r.Name, Comments__c, BigMachines_Quote__r.BigMachines__Status__c, Approval_Submission_Counter__c,
		LastModifiedDate, Step__c, Submitted_Date__c, Quote_Approval_Date__c, Approval_Method__c,Deal_Qualification__r.status__c
		FROM Quote_Approval__c
		WHERE Deal_Qualification__c =: dqId ORDER BY Display_Order__c DESC];
		//Getting Max submission counter
		List<Quote_Approval__c> existingQuoteApprovals = [SELECT Approval_Submission_Counter__c FROM Quote_Approval__c 
			WHERE Deal_Qualification__c =: dqId ORDER BY Approval_Submission_Counter__c DESC LIMIT 1];
		//If quote is already rejected, don't show approve/reject buttons
		if(!quoteApprovals.isEmpty() && quoteApprovals[0].Deal_Qualification__r.status__c == QuoteApprovalUtil.QUOTE_STATUS_REJECTED)
			mode = 'noAction';
			
		//Making sure of hiding section if there is no approval record
		if(quoteApprovals.isEmpty())
			showApprovalHistory = false;
		else
			showApprovalHistory = true;
		//Initializing wrapper list	
		List<historyWrapper> approvals = new List<historyWrapper>();	
		Integer counter = 1;	
		Set<String> setSteps = new Set<String>();
		Set<Decimal> setSubmissions = new Set<Decimal>();
		//How many times quote is submitted to approval
		Decimal submissionCounter = 1;
		if(!existingQuoteApprovals.isEmpty())
			submissionCounter = existingQuoteApprovals[0].Approval_Submission_Counter__c; 
		//Looping over all quote approval record 
		for(Quote_Approval__c eachQuoteApproval : quoteApprovals){
			if(showLastSubmission != null && showLastSubmission 
				&& eachQuoteApproval.Approval_Submission_Counter__c != submissionCounter){
				continue;
			}			 
			//Showing a record for request submission
			if(submissionCounter != eachQuoteApproval.Approval_Submission_Counter__c){
				submissionCounter = eachQuoteApproval.Approval_Submission_Counter__c;
				approvals = addSubmissionRecords(approvals, eachQuoteApproval);
			}	
			//Steps Unique Key
			String key = eachQuoteApproval.Step__c + String.valueOf(eachQuoteApproval.Approval_Submission_Counter__c);
			//Creating step header row			
			if(!setSteps.contains(key)){
				historyWrapper stepHeaderRecord = new historyWrapper();
				stepHeaderRecord.rowType = 'step';
				stepHeaderRecord.actionTitle = 'Step: ' + eachQuoteApproval.Step_Name__c;
				stepHeaderRecord.styleClass = 'stepRow';
				stepHeaderRecord.style= 'color:#ffffff;background-color:#9BC4D7;font-weight:bold;';
				if(counter == 1)
					stepHeaderRecord.showOverallStatus = true;
				else
					stepHeaderRecord.showOverallStatus = false;
				approvals.add(stepHeaderRecord);
			}
			
				
			
			//Adding submission counter to set to determine no of submission
			setSubmissions.add(eachQuoteApproval.Approval_Submission_Counter__c);
			//Set which tells whether there already a step row or not for current approval record
			setSteps.add(key);
			historyWrapper newRecord = new historyWrapper();
			if(eachQuoteApproval.Submitted_Date__c != null)
				newRecord.submittedDate = eachQuoteApproval.Submitted_Date__c.format();
			if(eachQuoteApproval.Quote_Approval_Date__c != null)
				newRecord.approvalRejectDate = eachQuoteApproval.Quote_Approval_Date__c.format();
			newRecord.approvalRecord = eachQuoteApproval; 	
			//Applying css style depending on status
			if(eachQuoteApproval.Status__c == QuoteApprovalUtil.STATUS_APPROVED)
				newRecord.statusClass = 'approved';
			else if(eachQuoteApproval.Status__c == QuoteApprovalUtil.STATUS_REJECTED)
				newRecord.statusClass = 'rejected';
			newRecord.showAction = false;
			newRecord.rowType = 'detail';
			approvals.add(newRecord);
			counter ++;
			//Getting overall status
			/*
			if(overAllStatus != QuoteApprovalUtil.STATUS_REJECTED && newRecord.approvalRecord.Status__c == QuoteApprovalUtil.STATUS_PENDING
				&& newRecord.approvalRecord.Approval_Submission_Counter__c == submissionCounter)
				overAllStatus = QuoteApprovalUtil.STATUS_PENDING;
			if(newRecord.approvalRecord.Status__c == QuoteApprovalUtil.STATUS_REJECTED 
				&& newRecord.approvalRecord.Approval_Submission_Counter__c == submissionCounter)
				overAllStatus = QuoteApprovalUtil.STATUS_REJECTED;
			*/	
			System.debug('NKC debug counter ['+counter+']');
			System.debug('NKC debug quoteApprovals.size() ['+quoteApprovals.size()+']');			
			if(counter - 1 == quoteApprovals.size())
				approvals = addSubmissionRecords(approvals, eachQuoteApproval);	
		}	
		/*
		if(overAllStatus == null)
			overAllStatus = QuoteApprovalUtil.STATUS_APPROVED;	
		*/
		return approvals;
	}
	
	public List<historyWrapper> getApprovals(){
		System.debug('NKC debug quoteId ['+quoteId+']');
		//Quote id
		//if(ApexPages.currentPage().getParameters().get('id') != null)
		//	quoteId = ApexPages.currentPage().getParameters().get('id');
		//Whether to show approve/reject button	
		mode = 	ApexPages.currentPage().getParameters().get('mode');
		System.debug('NKC debug quoteId ['+quoteId+']');
		if(quoteId == null)
			return null;
		//Getting quote staus
		BigMachines__Quote__c quote = [SELECT BigMachines__Status__c FROM BigMachines__Quote__c WHERE id =: quoteId];
		if(quote.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_PENDING)
			overAllStatus = QuoteApprovalUtil.STATUS_PENDING;
		else if(quote.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_REJECTED)
			overAllStatus = QuoteApprovalUtil.STATUS_REJECTED;
		else if(quote.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_REVISION_PENDING)
			overAllStatus = QuoteApprovalUtil.STATUS_CANCELLED;
		else //if(quote.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_APPROVED)
			overAllStatus = QuoteApprovalUtil.STATUS_APPROVED;
		
		//Getting quote approval records with related fields
		List<Quote_Approval__c>  quoteApprovals = [SELECT id, Quote_Approval_Step_Details__c, owner.Name, ownerId, Status__c,
		Quote_Approval_Step_Details__r.Quote_Approval_Step__r.Order__c, Quote_Approval_Step_Details__r.Priority_Sequence__c,
		Step_Name__c, Quote_Approval_Step_Details__r.Quote_Approval_Step__c, Quote_Approval_Step_Details__r.Quote_Approver_Step_Approver_Detail__r.Name,
		CreatedDate, Actual_Approver__r.Name, Comments__c, BigMachines_Quote__r.BigMachines__Status__c, Approval_Submission_Counter__c,
		LastModifiedDate, Step__c, Submitted_Date__c, Quote_Approval_Date__c, Approval_Method__c
		FROM Quote_Approval__c
		WHERE BigMachines_Quote__c =: quoteId ORDER BY Display_Order__c DESC];
		//Getting Max submission counter
		List<Quote_Approval__c> existingQuoteApprovals = [SELECT Approval_Submission_Counter__c FROM Quote_Approval__c 
			WHERE BigMachines_Quote__c =: quoteId ORDER BY Approval_Submission_Counter__c DESC LIMIT 1];
		//If quote is already rejected, don't show approve/reject buttons
		if(!quoteApprovals.isEmpty() && quoteApprovals[0].BigMachines_Quote__r.BigMachines__Status__c == QuoteApprovalUtil.QUOTE_STATUS_REJECTED)
			mode = 'noAction';
			
		//Making sure of hiding section if there is no approval record
		if(quoteApprovals.isEmpty())
			showApprovalHistory = false;
		else
			showApprovalHistory = true;
		//Initializing wrapper list	
		List<historyWrapper> approvals = new List<historyWrapper>();	
		Integer counter = 1;	
		Set<String> setSteps = new Set<String>();
		Set<Decimal> setSubmissions = new Set<Decimal>();
		//How many times quote is submitted to approval
		Decimal submissionCounter = 1;
		if(!existingQuoteApprovals.isEmpty())
			submissionCounter = existingQuoteApprovals[0].Approval_Submission_Counter__c; 
		//Looping over all quote approval record 
		for(Quote_Approval__c eachQuoteApproval : quoteApprovals){
			if(showLastSubmission != null && showLastSubmission 
				&& eachQuoteApproval.Approval_Submission_Counter__c != submissionCounter){
				continue;
			}			 
			//Showing a record for request submission
			if(submissionCounter != eachQuoteApproval.Approval_Submission_Counter__c){
				submissionCounter = eachQuoteApproval.Approval_Submission_Counter__c;
				approvals = addSubmissionRecords(approvals, eachQuoteApproval);
			}	
			//Steps Unique Key
			String key = eachQuoteApproval.Step__c + String.valueOf(eachQuoteApproval.Approval_Submission_Counter__c);
			//Creating step header row			
			if(!setSteps.contains(key)){
				historyWrapper stepHeaderRecord = new historyWrapper();
				stepHeaderRecord.rowType = 'step';
				stepHeaderRecord.actionTitle = 'Step: ' + eachQuoteApproval.Step_Name__c;
				stepHeaderRecord.styleClass = 'stepRow';
				stepHeaderRecord.style= 'color:#ffffff;background-color:#9BC4D7;font-weight:bold;';
				if(counter == 1)
					stepHeaderRecord.showOverallStatus = true;
				else
					stepHeaderRecord.showOverallStatus = false;
				approvals.add(stepHeaderRecord);
			}
			
				
			
			//Adding submission counter to set to determine no of submission
			setSubmissions.add(eachQuoteApproval.Approval_Submission_Counter__c);
			//Set which tells whether there already a step row or not for current approval record
			setSteps.add(key);
			historyWrapper newRecord = new historyWrapper();
			if(eachQuoteApproval.Submitted_Date__c != null)
				newRecord.submittedDate = eachQuoteApproval.Submitted_Date__c.format();
			if(eachQuoteApproval.Quote_Approval_Date__c != null)
				newRecord.approvalRejectDate = eachQuoteApproval.Quote_Approval_Date__c.format();
			newRecord.approvalRecord = eachQuoteApproval; 	
			//Applying css style depending on status
			if(eachQuoteApproval.Status__c == QuoteApprovalUtil.STATUS_APPROVED)
				newRecord.statusClass = 'approved';
			else if(eachQuoteApproval.Status__c == QuoteApprovalUtil.STATUS_REJECTED)
				newRecord.statusClass = 'rejected';
			newRecord.showAction = false;
			newRecord.rowType = 'detail';
			approvals.add(newRecord);
			counter ++;
			//Getting overall status
			/*
			if(overAllStatus != QuoteApprovalUtil.STATUS_REJECTED && newRecord.approvalRecord.Status__c == QuoteApprovalUtil.STATUS_PENDING
				&& newRecord.approvalRecord.Approval_Submission_Counter__c == submissionCounter)
				overAllStatus = QuoteApprovalUtil.STATUS_PENDING;
			if(newRecord.approvalRecord.Status__c == QuoteApprovalUtil.STATUS_REJECTED 
				&& newRecord.approvalRecord.Approval_Submission_Counter__c == submissionCounter)
				overAllStatus = QuoteApprovalUtil.STATUS_REJECTED;
			*/	
			System.debug('NKC debug counter ['+counter+']');
			System.debug('NKC debug quoteApprovals.size() ['+quoteApprovals.size()+']');			
			if(counter - 1 == quoteApprovals.size())
				approvals = addSubmissionRecords(approvals, eachQuoteApproval);	
		}	
		/*
		if(overAllStatus == null)
			overAllStatus = QuoteApprovalUtil.STATUS_APPROVED;	
		*/
		return approvals;
	}
	
	private List<historyWrapper> addSubmissionRecords(List<historyWrapper> approvals, Quote_Approval__c eachQuoteApproval){
		//Request submission header row
		historyWrapper submissionHeaderRecord = new historyWrapper();
		submissionHeaderRecord.rowType = 'step';
		submissionHeaderRecord.actionTitle = 'Approval Request Submitted';
		submissionHeaderRecord.styleClass = 'stepRow';
		submissionHeaderRecord.showOverallStatus = false;
		submissionHeaderRecord.style= 'background-color:#70AAC6;font-weight:bold;color:#ffffff;';
		approvals.add(submissionHeaderRecord);
		//Cloning quote approval record 
		Quote_Approval__c cloneQuoteApproval = eachQuoteApproval.clone(true,false);
		//Request submission details row
		historyWrapper submissionDetailRecord = new historyWrapper();
		submissionDetailRecord.rowType = 'submissionDetail';
		cloneQuoteApproval.Status__c = 'Submitted';	
		cloneQuoteApproval.Actual_Approver__c = null;
		submissionDetailRecord.approvalRecord = cloneQuoteApproval;	
		approvals.add(submissionDetailRecord);
			
		
		return approvals;		
	}
	
	
	public class historyWrapper{
		public transient boolean showAction {get;set;}
		public transient String actionTitle {get;set;}
		public transient Quote_Approval__c approvalRecord {get;set;}
		public transient User actualApprover {get;set;}		
		public transient String rowType {get;set;}
		public transient String stepName {get;set;}
		public transient String styleClass {get;set;}
		public transient String statusClass {get;set;}
		public transient Boolean showOverallStatus {get;set;}
		public transient String submittedDate {get;set;}
		public transient String approvalRejectDate {get;set;}
		public transient String style {get;set;}
	}
}