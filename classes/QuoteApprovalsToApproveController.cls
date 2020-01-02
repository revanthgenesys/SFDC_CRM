//Naresh Kumar	07/09/2014
public with sharing class QuoteApprovalsToApproveController {
	public List<Quote_Approval__c> quoteApprovals {get;set;}
	public Boolean showGrid {get;set;}
	public QuoteApprovalsToApproveController(){
		//Would hold all the ids of queues in which current user 
		Set<Id> currentUserIdAndQueues = new Set<Id>();
		//Adding current user to set
		currentUserIdAndQueues.add(UserInfo.getUserId());
		//Querying queues
		List<GroupMember> groupMemberRecord = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId =: UserInfo.getUserId()];
		for(GroupMember eachGM : groupMemberRecord){
			currentUserIdAndQueues.add(eachGM.GroupId);
		}
		//Getting submission counter
		quoteApprovals = [SELECT id, BigMachines_Quote__c, BigMachines_Quote__r.Name, Comments__c, 
			Step_Name__c, Status__c, Owner.Name, ownerId, LastModifiedDate, 
			Quote_Approval_Step_Details__r.Quote_Approver_Step_Approver_Detail__r.Name,
			Approval_Submission_Counter__c, Submitted_Date__c, Deal_Qualification__c, Deal_Qualification__r.Opportunity__r.Name 
			FROM Quote_Approval__c WHERE ownerId IN : currentUserIdAndQueues
			AND Status__c =: QuoteApprovalUtil.STATUS_PENDING   
			AND (BigMachines_Quote__r.BigMachines__Status__c =: QuoteApprovalUtil.QUOTE_STATUS_PENDING
				OR Deal_Qualification__r.Status__c =: DealQualificationApprovalUtil.QUOTE_STATUS_PENDING)
			ORDER BY CreatedDate DESC];
		
		if(quoteApprovals.isEmpty())
			showGrid = false;
		else
			showGrid = true;
	}
}