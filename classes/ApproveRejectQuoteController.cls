//Naresh Kumar		06/24/2014
public without sharing class ApproveRejectQuoteController {
	public Quote_Approval__c quoteApproval {get;set;}	
	public Boolean showDetails {get;set;}
	public String approverId {get;set;}
	public Boolean requestInfo {get;set;}
	public String approvalRecordId {get;set;}
	public String mode {get;set;}
	public String quoteId;
	public String retURL;
    public ApproveRejectQuoteController(){
    	init();
    }
    
    private void init(){
    	showDetails = false;
    	quoteId = ApexPages.currentPage().getParameters().get('id');
    	approvalRecordId = ApexPages.currentPage().getParameters().get('approvalRecord');
    	mode = ApexPages.currentPage().getParameters().get('mode');
    	retURL = ApexPages.currentPage().getParameters().get('retURL');
    	//String query = CloudQuoteUtil.getQuoteForFieldSet('Quote_Approval_Page_Fields','BigMachines__Quote__c');
    	
		//query += ' WHERE id = \'' + quoteId + '\'';
		//query = query.replace('SELECT ', 'SELECT BigMachines__Status__c, Owner.Email, ');
		//System.debug('NKC debug query ['+query+']');
		
		//quote = (BigMachines__Quote__c)Database.query(query);
		List<Quote_Approval__c> quoteApprovals = [SELECT id, BigMachines_Quote__c, BigMachines_Quote__r.Name, Comments__c, Step_Name__c, Status__c, Owner.Name, ownerId, Owner.Type FROM Quote_Approval__c WHERE id =: approvalRecordId];
		if(quoteApprovals.isEmpty()){
			quoteApproval = new Quote_Approval__c();			
			ApexPages.Message pMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'This record seems to be deleted already.');
			ApexPages.addMessage(pMessage);
		}
		else{
			if(quoteApprovals[0].Status__c == QuoteApprovalUtil.STATUS_CANCELLED){
				ApexPages.Message pMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'This quote approval request has been cancelled.');
				ApexPages.addMessage(pMessage);
			}
			else{
				showDetails = true;
				quoteApproval = quoteApprovals[0];
			}
		}
    }
    
    public pageReference approve(){
    	if(approveRejectQuote('Approved')){
	    	PageReference pRef = new pageReference(retURL);
	    	pRef.setRedirect(true);
	    	return pRef;
    	}		    	
    	return null;
    }
    
    public pageReference cancel(){
    	PageReference pRef = new pageReference(retURL);
	    pRef.setRedirect(true);
	    return pRef;
    }
    
    public pageReference reject(){
    	if(approveRejectQuote('Rejected')){    	
	    	PageReference pRef = new pageReference(retURL);
	    	pRef.setRedirect(true);
	    	return pRef;
    	}
    	return null;
    }
    private Boolean approveRejectQuote(String action){
    	Boolean isActionTaken = false;		
		if(compareCurrentUserWithAssignee()){
			if(quoteApproval.Status__c != QuoteApprovalUtil.STATUS_PENDING){
				ApexPages.Message pMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Sorry ! This step is already ' + quoteApproval.Status__c +'. You can not take any action.');
				ApexPages.addMessage(pMessage);
				showDetails = false;
				return false;
			}
			if(action == QuoteApprovalUtil.STATUS_APPROVED)
				quoteApproval.Status__c = QuoteApprovalUtil.STATUS_APPROVED;
			else {
				quoteApproval.Status__c = QuoteApprovalUtil.STATUS_REJECTED;
				QuoteApprovalAssignmentHelper.approvalRejectionActions(quoteApproval.BigMachines_Quote__c);
			}
			quoteApproval.Actual_Approver__c = UserInfo.getUserId();
			quoteApproval.Quote_Approval_Date__c = System.now();
			quoteApproval.Approval_Method__c = 'Logged In';
			update quoteApproval;
			showDetails = false;
			return true;
		}
		else{
			ApexPages.Message pMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Sorry ! You can\'t approve/reject this quote because you are not one of current approver assigned to approve this quote.');
			ApexPages.addMessage(pMessage);
			showDetails = false;
			return false;
		}
		return false;
	}
	
	private Boolean compareCurrentUserWithAssignee(){
		//DelegatedApprover
		Id currentUserId = UserInfo.getUserId();
		if(quoteApproval.Owner.Type == 'Queue'){
			List<GroupMember> groupMemberRecord = [SELECT id, UserOrGroupId FROM GroupMember WHERE GroupId =: quoteApproval.ownerId];
			Set<Id> userIds = new Set<Id>();
			//Looping over each group member record and populating
			for(GroupMember eachGM: groupMemberRecord){				
				userIds.add(eachGM.UserOrGroupId);	
			}
			//Getting Delegate Approvers			
			List<User> delegateApprovers = [SELECT DelegatedApproverId FROM User WHERE id in : userIds AND DelegatedApproverId != null];
			//Looping over each user record and adding it's id to set
			for(User eachUser : delegateApprovers){
				userIds.add(eachUser.DelegatedApproverId);		
			}
			if(userIds.contains(currentUserId))
				return true;
			else
				return false;
		}
		else {
			List<User> delegateApprovers = [SELECT DelegatedApproverId FROM User WHERE id = : quoteApproval.ownerId];
			
			if(quoteApproval.ownerId == currentUserId || delegateApprovers[0].DelegatedApproverId == currentUserId)
				return true;		
			else
				return false;		
		}
		
	}
}