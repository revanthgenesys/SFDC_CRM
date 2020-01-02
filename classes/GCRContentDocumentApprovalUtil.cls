//Naresh Kumar	12/05/2014
public with sharing class GCRContentDocumentApprovalUtil {

	public final static string STATUS_PENDING = 'Pending';
    public final static string STATUS_APPROVED = 'Approved';
    public final static string STATUS_REJECTED = 'Rejected';
    public final static string STATUS_INACTIVE = 'In-Active';
    public final static string STATUS_CANCELLED = 'Cancelled';
    
    
    public static Decimal getApprovalSubmission(String documentId){
        List<GCR_Content_Document_Detail_Approval__c> existingQuoteApprovals = [SELECT Approval_Submission_Counter__c FROM GCR_Content_Document_Detail_Approval__c 
            WHERE GCR_Content_Document_Detail__c =: documentId ORDER BY Approval_Submission_Counter__c DESC LIMIT 1];
        Decimal submissionCounter = 1;
        //Making sure counter increases only if quote is resubmitted to approvals
        if(!existingQuoteApprovals.isEmpty()){
            submissionCounter = existingQuoteApprovals[0].Approval_Submission_Counter__c + 1;            
        }
        return submissionCounter;
    }
}