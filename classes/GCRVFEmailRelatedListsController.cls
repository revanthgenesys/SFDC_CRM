//Naresh Kumar  01/04/2015
public without sharing class GCRVFEmailRelatedListsController {

  public Boolean showNotes {get;set;}
  public Boolean showAttachments {get;set;}
  public Boolean showDocStatus {get;set;}
  public String gcrId {get;set;}
  public String currentOrgURL {get;set;}
  public Boolean isApprovalTemplate {get;set;}
  public String approvalDocumentId {get;set;}
  public Boolean showApprovalHistory {get;set;}
  List<GCR_Content_Document_Detail__c> lastestDocument;
  public String overAllStatus {get;set;}
  public GCRVFEmailRelatedListsController(){
    showNotes = true;
    showAttachments = true;
    showDocStatus = true;
    showApprovalHistory = true;
    currentOrgURL = URL.getSalesforceBaseUrl().toExternalForm();
  }
  
  public List<Note> getNotes(){
    List<Note> notes = [SELECT id, body, title, createdDate FROM Note WHERE parentId =: gcrId Order BY CreatedDate DESC];
    if(notes.isEmpty())
      showNotes = false;
    return notes;
  }
  
  public List<wrapperDocuments> getDocuments(){
    if(lastestDocument == null)
      lastestDocument = [SELECT id FROM GCR_Content_Document_Detail__c WHERE GCR__c =: gcrId ORDER BY CreatedDate DESC LIMIT 1];
    List<wrapperDocuments> attachments = new List<wrapperDocuments>();
    if(!lastestDocument.isEmpty()){
      Map<Id, dsfs__DocuSign_Status__c> mapIdVsDocusignStatus = new Map<Id, dsfs__DocuSign_Status__c>([SELECT id FROM dsfs__DocuSign_Status__c 
      WHERE GCR_Content_Document__c =: lastestDocument[0].id]); 
      List<Attachment> atts = [SELECT Name, CreatedBy.Name, CreatedDate, parentId FROM Attachment 
        WHERE parentId =: lastestDocument[0].id OR parentId IN : mapIdVsDocusignStatus.keyset()
        ORDER BY CreatedDate DESC];
      Integer counter = 1;
          for(Attachment eachAtt : atts){
              wrapperDocuments newAtt = new wrapperDocuments();
              newAtt.att = eachAtt;
              if(mapIdVsDocusignStatus.keyset().contains(eachAtt.parentId) && counter == 1)
                  newAtt.isFinal = true;
              else
                  newAtt.isFinal = false;         
              attachments.add(newAtt);
              counter ++;
          }          
    }
    if(attachments.isEmpty())
        showAttachments = false;
    return attachments;
  }
  
  public List<dsfs__DocuSign_Recipient_Status__c> getDocusignRecpDisplay() {
    if(lastestDocument == null)
      lastestDocument = [SELECT id FROM GCR_Content_Document_Detail__c WHERE GCR__c =: gcrId ORDER BY CreatedDate DESC LIMIT 1];
    List<dsfs__DocuSign_Recipient_Status__c> docusignRecp  = new List<dsfs__DocuSign_Recipient_Status__c>();
       List <dsfs__DocuSign_Status__c>  docusignStatus = new List <dsfs__DocuSign_Status__c>();
       
       if(!lastestDocument.isEmpty()) {
          docusignStatus = [SELECT id FROM dsfs__DocuSign_Status__c WHERE GCR_Content_Document__c= : lastestDocument[0].id ];
         if( docusignStatus.isEmpty()) {
             showDocStatus = false;    
          }
          else { 
             docusignRecp = [SELECT id,dsfs__DocuSign_Recipient_Email__c,dsfs__Date_Sent__c,dsfs__Date_Delivered__c,
               dsfs__Recipient_Status__c,dsfs__Date_Signed__c FROM dsfs__DocuSign_Recipient_Status__c WHERE dsfs__Parent_Status_Record__c in : docusignStatus];
          }
       }
       if(docusignRecp.isEmpty())
          showDocStatus = false;
       
        return docusignRecp ;
   }
   
   public List<GCRContentDocApprovalHistoryController.historyWrapper> getApprovals(){
     if(approvalDocumentId == null)
       return null;
     GCR_Content_Document_Detail__c gcrDocument = [SELECT Approval_Status__c, GCR__c FROM GCR_Content_Document_Detail__c WHERE id =: approvalDocumentId];
    gcrId = gcrDocument.GCR__c;
    if(gcrDocument.Approval_Status__c == GCRContentDocumentApprovalUtil.STATUS_PENDING)
      overAllStatus = GCRContentDocumentApprovalUtil.STATUS_PENDING;
    else if(gcrDocument.Approval_Status__c == GCRContentDocumentApprovalUtil.STATUS_PENDING)
      overAllStatus = GCRContentDocumentApprovalUtil.STATUS_REJECTED;
    else 
      overAllStatus = GCRContentDocumentApprovalUtil.STATUS_APPROVED;
    
    //Getting quote approval records with related fields
    List<GCR_Content_Document_Detail_Approval__c>  gcrDocumentApprovals = [SELECT id, Status__c, Approved_Rejected_Date__c,
    Comments__c,Owner.Name, GCR_Content_Document_Detail__r.Approval_Status__c, Submitted_Date__c, Order__c,
    Allow_Add_Approvers__c, Approval_Submission_Counter__c  FROM GCR_Content_Document_Detail_Approval__c
    WHERE GCR_Content_Document_Detail__c =: approvalDocumentId ORDER BY Order__c DESC];
    
    //Making sure of hiding section if there is no approval record
    if(gcrDocumentApprovals.isEmpty())
      showApprovalHistory = false;
    else
      showApprovalHistory = true;
    //Initializing wrapper list  
    List<GCRContentDocApprovalHistoryController.historyWrapper> approvals = new List<GCRContentDocApprovalHistoryController.historyWrapper>();  
    Integer counter = 1;  
    //Looping over all quote approval record 
    for(GCR_Content_Document_Detail_Approval__c eachGCRDocumentApproval : gcrDocumentApprovals){      
      GCRContentDocApprovalHistoryController.historyWrapper newRecord = new GCRContentDocApprovalHistoryController.historyWrapper();
      if(eachGCRDocumentApproval.Submitted_Date__c != null)
        newRecord.submittedDate = eachGCRDocumentApproval.Submitted_Date__c.format();
      if(eachGCRDocumentApproval.Approved_Rejected_Date__c != null)
        newRecord.approvalRejectDate = eachGCRDocumentApproval.Approved_Rejected_Date__c.format();
      newRecord.approvalRecord = eachGCRDocumentApproval;   
      //Applying css style depending on status
      if(eachGCRDocumentApproval.Status__c == GCRContentDocumentApprovalUtil.STATUS_APPROVED)
        newRecord.statusClass = 'approved';
      else if(eachGCRDocumentApproval.Status__c == GCRContentDocumentApprovalUtil.STATUS_REJECTED)
        newRecord.statusClass = 'rejected';
      newRecord.showAction = false;
      newRecord.rowType = 'detail';
      approvals.add(newRecord);
      counter ++;
    }  
    /*
    if(overAllStatus == null)
      overAllStatus = GCRContentDocumentApprovalUtil.STATUS_APPROVED;  
    */
    return approvals;
   }
   
   
  
  public class wrapperDocuments {
    public Attachment att {get;set;}
    public Boolean isFinal {get;set;}  
  }
}