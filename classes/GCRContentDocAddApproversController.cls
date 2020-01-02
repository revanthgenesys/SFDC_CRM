//Naresh Kumar	12/05/2014
public with sharing class GCRContentDocAddApproversController {
	public List<SelectOption> additionalApprovers {get;set;}
	public String selectedApprovers {get;set;}
	private String index;
	private String documentId;
	private String gcrId;
	private String submissionCounter;
	public String approvalReasonRequired {get;set;}
	public GCRContentDocAddApproversController(){
		documentId = ApexPages.currentPage().getParameters().get('id');
		index = ApexPages.currentPage().getParameters().get('index');
		gcrId = ApexPages.currentPage().getParameters().get('gcrId');
		submissionCounter = ApexPages.currentPage().getParameters().get('submissionCounter');
		String approvalRecordId = ApexPages.currentPage().getParameters().get('approvalId');
		
		additionalApprovers = new List<SelectOption>(); 
		List<String> additionApproverIds = Label.GCR_Content_Document_Addititional_Approvers.split(',');
		Set<Id> existingApproverIds = new Set<Id>();
		List<GCR_Content_Document_Detail_Approval__c> existingApprovalRecords = [SELECT OwnerId FROM GCR_Content_Document_Detail_Approval__c
			WHERE GCR_Content_Document_Detail__c =: documentId];
		for(GCR_Content_Document_Detail_Approval__c eachApproval : existingApprovalRecords){
			existingApproverIds.add(eachApproval.ownerId);	
		}	 
		List<User> users = [SELECT id, FirstName, LastName FROM User WHERE id IN : additionApproverIds AND id NOT IN : existingApproverIds];
		for(User eachUser : users){
			SelectOption newOption = new SelectOption(eachUser.id, eachUser.FirstName + ' ' + eachUser.LastName);
			additionalApprovers.add(newOption);
		}
		if(additionalApprovers.isEmpty()){
			SelectOption newOption = new SelectOption('-No Approver Available-', '-No Approver Available-');
			additionalApprovers.add(newOption);
		}
	} 
	
	public pageReference addApprovers(){
		if(selectedApprovers.contains('-No Approver Available-')){
			return null;
		}
		List<String> selectedApproverIds = selectedApprovers.replace('[','').replace(']','').replace(' ','').split(',');
		List<GCR_Content_Document_Detail_Approval__c> approversToBeInserted = new List<GCR_Content_Document_Detail_Approval__c>();
		
		for(String eachId : selectedApproverIds){
			GCR_Content_Document_Detail_Approval__c newApproval = new GCR_Content_Document_Detail_Approval__c();
			newApproval.ownerId = eachId;
			newApproval.Status__c = GCRContentDocumentApprovalUtil.STATUS_PENDING;
			newApproval.GCR_Content_Document_Detail__c = documentId;
			newApproval.Order__c = Integer.valueOf(index) + 1;	
			newApproval.Submitted_Date__c = System.Now();
			newApproval.Allow_Add_Approvers__c = false;
			newApproval.Approval_Submission_Counter__c = Decimal.valueOf(submissionCounter);
			newApproval.Approval_Required_Reason__c = approvalReasonRequired;
			approversToBeInserted.add(newApproval);
		}
		
		insert approversToBeInserted;
		PageReference pRef = new pageReference('/apex/gcrequest?id='+gcrId+'&documentRecordId='+documentId);
		pRef.setRedirect(true);
		return pRef;
	}
	
	public pageReference cancel(){
		PageReference pRef = new pageReference('/apex/gcrequest?id='+gcrId+'&documentRecordId='+documentId);
		pRef.setRedirect(true);
		return pRef;
	}
}