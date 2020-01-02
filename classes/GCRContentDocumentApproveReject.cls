//Naresh Kumar  12/05/2014
public with sharing class GCRContentDocumentApproveReject {
  public GCR_Content_Document_Detail_Approval__c documentApproval {get;set;}  
  public Boolean showDetails {get;set;}
  public String approverId {get;set;}
  public Boolean requestInfo {get;set;}
  public String approvalRecordId {get;set;}
  public String mode {get;set;}
  public String gcrDocumentId;
  public String retURL;
    public GCRContentDocumentApproveReject(){
      init();
    }
    
    private void init(){
      showDetails = false;
      gcrDocumentId = ApexPages.currentPage().getParameters().get('id');
      approvalRecordId = ApexPages.currentPage().getParameters().get('approvalRecord');
      mode = ApexPages.currentPage().getParameters().get('mode');
      retURL = ApexPages.currentPage().getParameters().get('retURL');
      
      List<GCR_Content_Document_Detail_Approval__c> documentApprovals = [SELECT id, GCR_Content_Document_Detail__c, 
        GCR_Content_Document_Detail__r.Name,Comments__c,Status__c, Owner.Name, ownerId, Owner.Type,
        GCR_Content_Document_Detail__r.GCR__c FROM GCR_Content_Document_Detail_Approval__c WHERE id =: approvalRecordId];
    if(documentApprovals.isEmpty()){
      documentApproval = new GCR_Content_Document_Detail_Approval__c();      
      ApexPages.Message pMessage = new ApexPages.Message(ApexPages.Severity.INFO, 'This record seems to be deleted already.');
      ApexPages.addMessage(pMessage);
    }
    else{
      showDetails = true;
      documentApproval = documentApprovals[0];      
    }
    }
    
    public pageReference approve(){
      if(approveRejectQuote('Approved')){
        GCR_Content_Document_Detail__c gcrDocument = [SELECT Approval_Status__c FROM GCR_Content_Document_Detail__c WHERE id =: documentApproval.GCR_Content_Document_Detail__c];
        if(gcrDocument.Approval_Status__c == GCRContentDocumentApprovalUtil.STATUS_APPROVED){
          retURL += '&documentApproved=true';
        }
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
      if(documentApproval.Status__c != QuoteApprovalUtil.STATUS_PENDING){
        ApexPages.Message pMessage = new ApexPages.Message(ApexPages.Severity.ERROR, 'Sorry ! This step is already ' + documentApproval.Status__c +'. You can not take any action.');
        ApexPages.addMessage(pMessage);
        showDetails = false;
        return false;
      }
      if(action == QuoteApprovalUtil.STATUS_APPROVED)
        documentApproval.Status__c = QuoteApprovalUtil.STATUS_APPROVED;
      else {
        documentApproval.Status__c = QuoteApprovalUtil.STATUS_REJECTED;
        GCRContentDocumentApprovalsHelper.approvalRejectionActions(documentApproval.GCR_Content_Document_Detail__c);
        System.debug('NKC debug documentApproval.GCR_Content_Document_Detail__r.GCR__c ['+documentApproval.GCR_Content_Document_Detail__r.GCR__c+']');        
      }
      documentApproval.Approved_Rejected_Date__c = System.Today();
      update documentApproval;
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
    if(documentApproval.Owner.Type == 'Queue'){
      List<GroupMember> groupMemberRecord = [SELECT id, UserOrGroupId FROM GroupMember WHERE GroupId =: documentApproval.ownerId];
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
      List<User> delegateApprovers = [SELECT DelegatedApproverId FROM User WHERE id = : documentApproval.ownerId];
      if(documentApproval.ownerId == currentUserId || delegateApprovers[0].DelegatedApproverId == currentUserId)
        return true;    
      else
        return false;    
    }
    
  }
}