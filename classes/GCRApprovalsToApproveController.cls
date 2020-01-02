//Naresh Kumar  01/09/2015
public without sharing class GCRApprovalsToApproveController {
    public List<GCR_Content_Document_Detail_Approval__c> gcrApprovals {get;set;}
    public List<dsfs__DocuSign_Recipient_Status__c> pendingSignatures {get;set;}
    public Boolean showGrid {get;set;}
    public Boolean showPendingSigGrid {get;set;}
    public GCRApprovalsToApproveController(){
        //Would hold all the ids of queues in which current user 
        Set<Id> currentUserIdAndQueues = new Set<Id>();
        //Adding current user to set
        currentUserIdAndQueues.add(UserInfo.getUserId());
        //Querying queues
        List<GroupMember> groupMemberRecord = [SELECT GroupId, UserOrGroupId FROM GroupMember WHERE UserOrGroupId =: UserInfo.getUserId()];
        for(GroupMember eachGM : groupMemberRecord){
            currentUserIdAndQueues.add(eachGM.GroupId);
        }
        User currentUser = [SELECT DelegatedApproverId FROM User WHERE id =: UserInfo.getUserId()];
        if(currentUser.DelegatedApproverId != null){
            currentUserIdAndQueues.add(currentUser.DelegatedApproverId);    
        }
        gcrApprovals = [SELECT id, GCR__c, GCR_Content_Document_Detail__r.GCR__c, Submitted_Date__c, Status__c, GCR_Content_Document_Detail__c,
            GCR_Content_Document_Detail__r.GCR__r.Request_Type__c, GCR_Content_Document_Detail__r.Document_Name__c,  
            GCR_Content_Document_Detail__r.GCR__r.Requestor_Name__r.Name, GCR_Content_Document_Detail__r.GCR__r.Attorney_Name__c,
            GCR_Content_Document_Detail__r.Account_Name__r.Name, GCR_Content_Document_Detail__r.Account_Name__c
            FROM GCR_Content_Document_Detail_Approval__c WHERE ownerId IN : currentUserIdAndQueues
            AND Status__c =: QuoteApprovalUtil.STATUS_PENDING AND GCR_Content_Document_Detail__r.Approval_Status__c =: QuoteApprovalUtil.STATUS_PENDING 
            ORDER BY GCR_Content_Document_Detail__r.GCR__r.Name DESC];
        
        if(gcrApprovals.isEmpty())
            showGrid = false;
        else
            showGrid = true;
        List<User> delegateUser = [SELECT Email FROM User WHERE id =: currentUser.DelegatedApproverId];
        Set<String> setOfEmailIds = new Set<String>();
        setOfEmailIds.add(UserInfo.getUserEmail());
        if(!delegateUser.isEmpty()){
            setOfEmailIds.add(delegateUser[0].Email);   
        }
        //Dec 1 - Anju adding few more fields for Quote approvals
        pendingSignatures = [SELECT  
            dsfs__Parent_Status_Record__r.GCR_Content_Document__r.GCR__c, 
            dsfs__Parent_Status_Record__r.GCR_Content_Document__r.GCR__r.Name,  
            dsfs__Parent_Status_Record__r.GCR_Content_Document__r.GCR__r.Status__c, 
            dsfs__Parent_Status_Record__r.GCR_Content_Document__c,
            dsfs__Parent_Status_Record__r.GCR_Content_Document__r.GCR__r.Request_Type__c, 
            dsfs__Parent_Status_Record__r.GCR_Content_Document__r.Document_Name__c,  
            dsfs__Parent_Status_Record__r.GCR_Content_Document__r.GCR__r.Requestor_Name__r.Name, 
            dsfs__Parent_Status_Record__r.GCR_Content_Document__r.GCR__r.Attorney_Name__c,
            dsfs__Parent_Status_Record__r.GCR_Content_Document__r.Account_Name__r.Name, 
            dsfs__Parent_Status_Record__r.GCR_Content_Document__r.Account_Name__c, dsfs__DocuSign_Recipient_Id__c,
            dsfs__Account__c,dsfs__Contact__c,dsfs__Date_Declined__c,dsfs__Date_Delivered__c,dsfs__Date_Sent__c,
            dsfs__Date_Signed__c,dsfs__Decline_Reason__c,dsfs__DocuSign_Recipient_Company__c,
            dsfs__DocuSign_Recipient_Email__c,dsfs__DocuSign_Recipient_Title__c,dsfs__Parent_Status_Record__r.dsfs__Company__r.name,
            dsfs__DocuSign_Routing_Order__c,dsfs__Envelope_Id__c,dsfs__Lead__c,dsfs__Recipient_Status__c,
            dsfs__Parent_Status_Record__r.dsfs__Company__c,dsfs__Parent_Status_Record__r.dsfs__Contract__c,dsfs__Parent_Status_Record__r.dsfs__Days_to_Complete__c,dsfs__Parent_Status_Record__r.dsfs__DocuSign_Envelope_ID__c,
            dsfs__Parent_Status_Record__r.dsfs__Envelope_Link__c,dsfs__Parent_Status_Record__r.dsfs__Envelope_Status__c,dsfs__Parent_Status_Record__r.dsfs__Hrs_Sent_to_Sign__c,dsfs__Parent_Status_Record__r.dsfs__Hours_to_Complete__c,dsfs__Parent_Status_Record__r.dsfs__Viewed_Date_Time__c,
            dsfs__Parent_Status_Record__r.dsfs__Minutes_to_Complete__c,dsfs__Parent_Status_Record__r.dsfs__Number_Completed__c,dsfs__Parent_Status_Record__r.dsfs__Opportunity__c,dsfs__Parent_Status_Record__r.Quote__c,dsfs__Parent_Status_Record__r.dsfs__Sender__c,dsfs__Parent_Status_Record__r.dsfs__Sender_Email__c,
            dsfs__Parent_Status_Record__r.dsfs__Sent_Date_Time__c,dsfs__Parent_Status_Record__r.dsfs__Sent_Age__c,dsfs__Parent_Status_Record__r.dsfs__Subject__c,dsfs__Parent_Status_Record__r.dsfs__Time_to_Complete__c,dsfs__Parent_Status_Record__r.Zuora_Quote__c
            FROM dsfs__DocuSign_Recipient_Status__c
            WHERE dsfs__DocuSign_Recipient_Email__c IN : setOfEmailIds
            AND dsfs__Recipient_Status__c =: 'Sent' ORDER BY dsfs__Parent_Status_Record__r.GCR_Content_Document__r.GCR__r.Name DESC];   
            
        if(pendingSignatures.isEmpty())
            showPendingSigGrid = false;
        else
            showPendingSigGrid = true;
    }
}