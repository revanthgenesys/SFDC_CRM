//Naresh Kumar  12/05/2014
public with sharing class GCRContentDocApprovalHistoryController {
    public Id gcrDocumentId {get;set;}  
    //public transient List<historyWrapper> approvals {get;set;}
    public Boolean showApprovalHistory {get;set;}
    public String mode {get;set;}
    public String overAllStatus {get;set;}
    public String gcrId {get;set;}  
    public GCRContentDocApprovalHistoryController(){
        showApprovalHistory = true;
    }
    
    public List<historyWrapper> getApprovals(){
        if(gcrDocumentId == null)
            return null;
        mode = ApexPages.currentPage().getParameters().get('mode');
        //Getting quote staus
        GCR_Content_Document_Detail__c gcrDocument = [SELECT Approval_Status__c, GCR__c, Contract_Type__c, 
            Account_Name__r.Country__r.Region__c, Genesys_Entity__c,Legal_Approval_Signature_Configuration__c  FROM GCR_Content_Document_Detail__c WHERE id =: gcrDocumentId];
        gcrId = gcrDocument.GCR__c;
        if(gcrDocument.Approval_Status__c == GCRContentDocumentApprovalUtil.STATUS_PENDING)
            overAllStatus = GCRContentDocumentApprovalUtil.STATUS_PENDING;
        else if(gcrDocument.Approval_Status__c == GCRContentDocumentApprovalUtil.STATUS_PENDING)
            overAllStatus = GCRContentDocumentApprovalUtil.STATUS_REJECTED;
        else 
            overAllStatus = GCRContentDocumentApprovalUtil.STATUS_APPROVED;
        
        //Getting quote approval records with related fields
        List<GCR_Content_Document_Detail_Approval__c>  gcrDocumentApprovals = [SELECT id, Status__c, Approved_Rejected_Date__c,
        Comments__c, Owner.Name, GCR_Content_Document_Detail__r.Approval_Status__c, Submitted_Date__c, Order__c,
        Allow_Add_Approvers__c, Approval_Submission_Counter__c  FROM GCR_Content_Document_Detail_Approval__c
        WHERE GCR_Content_Document_Detail__c =: gcrDocumentId ORDER BY Order__c DESC];
        
        //If quote is already rejected, don't show approve/reject buttons
        if(!gcrDocumentApprovals.isEmpty() && gcrDocumentApprovals[0].GCR_Content_Document_Detail__r.Approval_Status__c == GCRContentDocumentApprovalUtil.STATUS_REJECTED)
            mode = 'noAction';
            
        //Making sure of hiding section if there is no approval record
        if(gcrDocumentApprovals.isEmpty())
            showApprovalHistory = false;
        else
            showApprovalHistory = true;
        //Initializing wrapper list 
        List<historyWrapper> approvals = new List<historyWrapper>();    
        Integer counter = 1;    
        //Looping over all quote approval record 
        for(GCR_Content_Document_Detail_Approval__c eachGCRDocumentApproval : gcrDocumentApprovals){
            
            historyWrapper newRecord = new historyWrapper();
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
            newRecord.SingaturePersons = null;
            approvals.add(newRecord);
            counter ++;
        }   
        if(gcrDocument.Contract_Type__c == null || String.isBlank(gcrDocument.Contract_Type__c) 
            || gcrDocument.Genesys_Entity__c == null || String.isBlank(gcrDocument.Genesys_Entity__c)){
            return approvals;
        }
        
        List<Legal_Approval_Configuration__c> configs = GCRContentDocumentApprovalsHelper.getConfigRecord(gcrDocument);
        if(configs.isEmpty() || configs[0].Signature_Person_s__c == null || String.isBlank(configs[0].Signature_Person_s__c) == null){
            return approvals;
        } 
        
        historyWrapper newRecord = new historyWrapper();
        newRecord.actionTitle = 'Signature Person';
        newRecord.showAction = false;
        newRecord.rowType = 'signatureDetail';
        newRecord.SingaturePersons = configs[0].Signature_Person_s__c;
        approvals.add(newRecord);               
        
        /*
        if(overAllStatus == null)
            overAllStatus = GCRContentDocumentApprovalUtil.STATUS_APPROVED; 
        */
        return approvals;
    }
    public class historyWrapper{
        public transient boolean showAction {get;set;}
        public transient String actionTitle {get;set;}
        public transient GCR_Content_Document_Detail_Approval__c approvalRecord {get;set;}
        public transient User actualApprover {get;set;}     
        public transient String rowType {get;set;}
        public transient String stepName {get;set;}
        public transient String styleClass {get;set;}
        public transient String statusClass {get;set;}
        public transient Boolean showOverallStatus {get;set;}
        public transient String submittedDate {get;set;}
        public transient String approvalRejectDate {get;set;}
        public transient String style {get;set;}
        public transient String SingaturePersons {get;set;}
    }
}