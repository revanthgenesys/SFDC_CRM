//Naresh Kumar  12/05/2014
public with sharing class GCRContentDocumentApprovalsHelper {

    public static void submitForFinanceApprovals(GCR_Content_Document_Detail__c documentDetail){        
        if(documentDetail.Genesys_Entity__c == null || String.isBlank(documentDetail.Genesys_Entity__c)){
            return;
        }
        List<Legal_Approval_Configuration__c> configs = getConfigRecord(documentDetail);
        if(configs.isEmpty()){
            return;
        }
        List<Legal_Approver__c> legalApprovers = [SELECT OwnerId, Order__c FROM Legal_Approver__c WHERE Legal_Approval_Signature_Configuration__c =: configs[0].id ORDER BY Order__c];
        Decimal submissionCounter = GCRContentDocumentApprovalUtil.getApprovalSubmission(documentDetail.id);
        List<GCR_Content_Document_Detail_Approval__c> approvalsToBeInserted = new List<GCR_Content_Document_Detail_Approval__c>();
        for(Legal_Approver__c eachLegalApprover : legalApprovers){
            GCR_Content_Document_Detail_Approval__c newApprover = new GCR_Content_Document_Detail_Approval__c();
            newApprover.ownerId = eachLegalApprover.ownerId;
            newApprover.Status__c = GCRContentDocumentApprovalUtil.STATUS_PENDING;
            newApprover.GCR_Content_Document_Detail__c = documentDetail.id;
            newApprover.Order__c = eachLegalApprover.Order__c;
            newApprover.Submitted_Date__c = System.Now(); 
            newApprover.Allow_Add_Approvers__c = true;
            newApprover.Approval_Submission_Counter__c = submissionCounter;
            approvalsToBeInserted.add(newApprover);
        }
        
        insert approvalsToBeInserted;
        
        documentDetail.Approval_Status__c = GCRContentDocumentApprovalUtil.STATUS_PENDING;
        update documentDetail;
        
        GCR__c gcrToBeUpdated = new GCR__c(id = documentDetail.GCR__c);
        gcrToBeUpdated.Status__c = '5-Pending Finance Approval';
        update gcrToBeUpdated;
    }
    public static List<Legal_Approval_Configuration__c> getConfigRecord(GCR_Content_Document_Detail__c documentDetail ){
        if(documentDetail.Legal_Approval_Signature_Configuration__c != null){
        return [SELECT Genesys_Entity__c, Device_DDP__c,DDP_Delivery_Option__c,Signature_Person_s__c  FROM Legal_Approval_Configuration__c 
          WHERE id =: documentDetail.Legal_Approval_Signature_Configuration__c];
        }
        
        String contractType = documentDetail.Contract_Type__c.replace('(','*').replace(')','&');
        contractType = String.valueOf(contractType.split(';')).replace('(','(\'').replace(')','\')').replace(',','\',\'');
        contractType = contractType.replace('*','(').replace('&',')');
        String query = 'SELECT Genesys_Entity__c, Device_DDP__c,DDP_Delivery_Option__c,Signature_Person_s__c  FROM Legal_Approval_Configuration__c WHERE Contract_Type__c INCLUDES ' + contractType 
            + ' AND Genesys_Entity__c = \'' + documentDetail.Genesys_Entity__c + '\'';
        System.debug('NKC debug query ['+query+']');
        
        List<Legal_Approval_Configuration__c> configs = (List<Legal_Approval_Configuration__c>)Database.query(query);
        if(configs.isEmpty()){
            configs = [SELECT Genesys_Entity__c, Device_DDP__c,DDP_Delivery_Option__c,Signature_Person_s__c  FROM Legal_Approval_Configuration__c WHERE Default__c = true];
        }
        return configs;
        
    }
    public static void submitForFinanceApprovals1(GCR_Content_Document_Detail__c documentDetail){
        String currentAccountRegion = (documentDetail.Account_Name__r.Country__r.Region__c == null ? 'North America' : documentDetail.Account_Name__r.Country__r.Region__c);
        List<String> approverQueueIds;
        List<String> approverOrder;
        String businessFinanceApproverQueueId;
        String financeApproverQueueId;
        if(GCR_Approvers_Queues__c.getAll().get(currentAccountRegion) != null 
            && GCR_Approvers_Queues__c.getAll().get(currentAccountRegion).Queue_Ids__c != null){
            approverQueueIds  = GCR_Approvers_Queues__c.getAll().get(currentAccountRegion).Queue_Ids__c.split(',');
            approverOrder = GCR_Approvers_Queues__c.getAll().get(currentAccountRegion).Order__c.split(',');    
            businessFinanceApproverQueueId = approverQueueIds[0];
            financeApproverQueueId = approverQueueIds[1];           
        }  
        Decimal submissionCounter = GCRContentDocumentApprovalUtil.getApprovalSubmission(documentDetail.id);
        List<GCR_Content_Document_Detail_Approval__c> approvalsToBeInserted = new List<GCR_Content_Document_Detail_Approval__c>();
        //Business Finance Approver
        GCR_Content_Document_Detail_Approval__c businessFinanceApprover = new GCR_Content_Document_Detail_Approval__c();
        if(businessFinanceApproverQueueId != null)
            businessFinanceApprover.ownerId = businessFinanceApproverQueueId;
        businessFinanceApprover.Status__c = GCRContentDocumentApprovalUtil.STATUS_PENDING;
        businessFinanceApprover.GCR_Content_Document_Detail__c = documentDetail.id;
        if(approverOrder != null)
            businessFinanceApprover.Order__c = Integer.valueOf(approverOrder[0]);
        businessFinanceApprover.Submitted_Date__c = System.Now(); 
        businessFinanceApprover.Allow_Add_Approvers__c = true;
        businessFinanceApprover.Approval_Submission_Counter__c = submissionCounter;
        approvalsToBeInserted.add(businessFinanceApprover);
        
        //Finance Approver
        GCR_Content_Document_Detail_Approval__c financeApprover = new GCR_Content_Document_Detail_Approval__c();
        if(financeApproverQueueId != null)
            financeApprover.ownerId = financeApproverQueueId;
        financeApprover.Status__c = GCRContentDocumentApprovalUtil.STATUS_PENDING;
        financeApprover.GCR_Content_Document_Detail__c = documentDetail.id;
        if(approverOrder != null)
            financeApprover.Order__c = Integer.valueOf(approverOrder[1]);
        financeApprover.Submitted_Date__c = System.Now();
        financeApprover.Allow_Add_Approvers__c = true;
        financeApprover.Approval_Submission_Counter__c = submissionCounter;
        approvalsToBeInserted.add(financeApprover);
        
        insert approvalsToBeInserted;
        
        documentDetail.Approval_Status__c = GCRContentDocumentApprovalUtil.STATUS_PENDING;
        update documentDetail;
        
        GCR__c gcrToBeUpdated = new GCR__c(id = documentDetail.GCR__c);
        gcrToBeUpdated.Status__c = '5-Pending Finance Approval';
        update gcrToBeUpdated;
    }
    
     public static void approvalRejectionActions(String gcrDocumentId){
        //Getting approval records from last submission
        List<GCR_Content_Document_Detail_Approval__c> quoteApprovalsToBeDeActivated = [SELECT Status__c FROM GCR_Content_Document_Detail_Approval__c 
            WHERE GCR_Content_Document_Detail__c =: gcrDocumentId];
        //Looping over each quote approval record and updating status
        for(GCR_Content_Document_Detail_Approval__c eachApproval : quoteApprovalsToBeDeActivated){
            if(eachApproval.Status__c == GCRContentDocumentApprovalUtil.STATUS_PENDING){
                eachApproval.Status__c = GCRContentDocumentApprovalUtil.STATUS_CANCELLED;
                eachApproval.Comments__c = 'Rejected.';
            }           
        }
        update quoteApprovalsToBeDeActivated;
    }
    /*
    public static void assignNextStep(Map<Id, GCR_Content_Document_Detail_Approval__c> oldMap, List<GCR_Content_Document_Detail_Approval__c> newList){
        //Getting current approval record
        GCR_Content_Document_Detail_Approval__c newRecord = [SELECT GCR_Content_Document_Detail__c, Status__c, 
            Order__c, Comments__c FROM GCR_Content_Document_Detail_Approval__c WHERE id =: newList[0].id];
        //If current quote is rejected, quote approval cancelled, do nothing
        if(newRecord.Status__c == GCRContentDocumentApprovalUtil.STATUS_REJECTED 
            || newRecord.Status__c == GCRContentDocumentApprovalUtil.STATUS_CANCELLED)// || newRecord.Comments__c == GCRContentDocumentApprovalUtil.APPROVAL_BY_PASSED)
            return;
        //Getting current quote record
        GCR_Content_Document_Detail__c gcrDocument = GCRContentDocumentDetailsContHelper.populateCurrentRecord(newRecord.GCR_Content_Document_Detail__c);
        //If quote is approved or rejected
        if(newRecord.Status__c != GCRContentDocumentApprovalUtil.STATUS_PENDING && oldMap.get(newRecord.id).Status__c == GCRContentDocumentApprovalUtil.STATUS_PENDING){            
            setNextApprovalRecords(gcrDocument, newRecord.Order__c);                
        }                   
    }
    
    private static void setNextApprovalRecords(GCR_Content_Document_Detail__c gcrDocument, Decimal currentApproverOrder){
        Decimal submissionCounter = GCRContentDocumentApprovalUtil.getApprovalSubmission(gcrDocument.id);
        //Getting next step items (if any)
        List<GCR_Content_Document_Detail_Approval__c> nextStepApprovals = [SELECT Status__c FROM GCR_Content_Document_Detail_Approval__c WHERE 
            GCR_Content_Document_Detail__c =: gcrDocument.id AND Approval_Submission_Counter__c =: submissionCounter AND Status__c =: QuoteApprovalUtil.STATUS_INACTIVE
            AND Approval_Submission_Counter__c =: (submissionCounter - 1) AND Order__c =: (currentApproverOrder + 1)];
        //If there is any pending approval items
        if(!nextStepApprovals.isEmpty()){
            for(GCR_Content_Document_Detail_Approval__c eachApproval : nextStepApprovals){
                eachApproval.Status__c = QuoteApprovalUtil.STATUS_PENDING;
                eachApproval.Submitted_Date__c = System.now();
            }
            update nextStepApprovals;
        }
    }
    */
    public static void gcrDocumentStatusHandler(Map<Id, GCR_Content_Document_Detail_Approval__c> oldMap, List<GCR_Content_Document_Detail_Approval__c> newList){
        //Getting max approval submission order     
        List<GCR_Content_Document_Detail_Approval__c> existingQuoteApprovals = [SELECT Approval_Submission_Counter__c, GCR_Content_Document_Detail__r.GCR__c 
            FROM GCR_Content_Document_Detail_Approval__c 
            WHERE GCR_Content_Document_Detail__c =: newList[0].GCR_Content_Document_Detail__c ORDER BY Approval_Submission_Counter__c DESC LIMIT 1];
        //If there is no approval record, just return
        if(existingQuoteApprovals.isEmpty())
            return; 
        //Getting all approval records for current Quote
        List<GCR_Content_Document_Detail_Approval__c> allGCRDocumentApprovalForCurrentGCRDocument = [SELECT Status__c FROM GCR_Content_Document_Detail_Approval__c 
            WHERE GCR_Content_Document_Detail__c =: newList[0].GCR_Content_Document_Detail__c AND Approval_Submission_Counter__c =: existingQuoteApprovals[0].Approval_Submission_Counter__c];
        //Would contain all different status
        Set<String> setStatus = new Set<String>();
        //Whether current quote approval is rejected or not
        Boolean rejectQuote = false;
        //GCR Content Document 
        GCR_Content_Document_Detail__c documentToBeUpdated = new GCR_Content_Document_Detail__c(id = newList[0].GCR_Content_Document_Detail__c);
        Boolean fireDML = false;
        String GCRStatus = '';
        //Looping over the list     
        for(GCR_Content_Document_Detail_Approval__c eachApproval : allGCRDocumentApprovalForCurrentGCRDocument){
            //Ignore notification only records
            //if(eachApproval.Status__c == GCRContentDocumentApprovalUtil.STATUS_APPROVER_NOTIFICATION_ONLY)
            //  continue;
            setStatus.add(eachApproval.Status__c);      
            if(eachApproval.id == newList[0].id && eachApproval.Status__c == GCRContentDocumentApprovalUtil.STATUS_REJECTED){
                documentToBeUpdated.Approval_Status__c = GCRContentDocumentApprovalUtil.STATUS_REJECTED;
                GCRStatus = '7-Rejected by Finance';
                fireDML = true; 
            }
        }               
        //Updated quote status if all approval are approved.
        if(setStatus.size() == 1 && setStatus.contains(GCRContentDocumentApprovalUtil.STATUS_APPROVED)){        
            documentToBeUpdated.Approval_Status__c = GCRContentDocumentApprovalUtil.STATUS_APPROVED;
            GCRStatus = '6-Approved by Finance';
            fireDML = true;
        }
        //Updated quote status if all approval are rejected.
        if(setStatus.size() == 1 && setStatus.contains(GCRContentDocumentApprovalUtil.STATUS_REJECTED)){
            documentToBeUpdated.Approval_Status__c = GCRContentDocumentApprovalUtil.STATUS_REJECTED;
            GCRStatus = '7-Rejected by Finance';
            fireDML = true;
        }
        if(fireDML){
            update documentToBeUpdated;
            GCR__c gcrToBeUpdated = new GCR__c(id = existingQuoteApprovals[0].GCR_Content_Document_Detail__r.GCR__c);
            gcrToBeUpdated.Status__c = GCRStatus;
            update gcrToBeUpdated;
            if(GCRStatus == '6-Approved by Finance'){
                sendDDP(documentToBeUpdated.id,userInfo.getSessionId());
            }
        }               
    }
    @future(callout=true)
    public static void sendDDP(String gcrDocumentDetailId, string sessionId){
        try {
            
            GCR_Content_Document_Detail__c gcrDocument = [SELECT Contract_Type__c, Genesys_Entity__c,Legal_Approval_Signature_Configuration__c FROM GCR_Content_Document_Detail__c 
                WHERE id =: gcrDocumentDetailId];
            
            if(gcrDocument.Genesys_Entity__c == null || String.isBlank(gcrDocument.Genesys_Entity__c)){
                return;
            }
            List<Legal_Approval_Configuration__c> configs = getConfigRecord(gcrDocument);
            if(configs.isEmpty()){
                return;
            }    
                
            List<Attachment> attachments = [select id,name from Attachment where parentid =: gcrDocumentDetailId];
            String attachIds='';
            for(Attachment eachAtt : attachments){
                //if(gcrDocument.Final_Attachment_Id__c == null || eachAtt.id == gcrDocument.Final_Attachment_Id__c){
                    attachIds = eachAtt.id;
                //}
            }
            Map<string, string> variables = new Map<String, String> { 'deploy' => configs[0].DDP_Delivery_Option__c ,'attachIds' => attachIds };
            
            //Below ID is of main "DDP"
            System.debug(variables);
            //Loop.loopMessage.send(gcrDocumentDetailId, 'a2g110000012zMHAAY', variables, 'cs18');
            
            Loop.loopMessage lm = new Loop.loopMessage();
            
            // SESSION ID NEEDED IF IT CANNOT BE DETERMINED FROM UserInfo.getSessionId()
            lm.sessionId = sessionId;
            
            // SET DESIRED BATCH NOTIFICATION. IF THIS IS NOT DONE, THE DEFAULT IS 'NONE'
            // THIS IS AVAILABLE IN LOOP 6.7 / 9.56 AND ABOVE
            //lm.batchNotification = Loop.loopMessage.Notification.BEGIN_AND_COMPLETE;
            //lm.batchNotification = Loop.loopMessage.Notification.ON_COMPLETE;
            //lm.batchNotification = Loop.loopMessage.Notification.ON_ERROR;
            
            lm.requests.add(new Loop.loopMessage.loopMessageRequest( gcrDocumentDetailId, configs[0].Device_DDP__c, variables ));
            
            // SEND ALL DDP RUN REQUESTS IN A SINGLE CALL OUT
            lm.sendAllRequests();
        }
        catch(Exception e){
            system.debug('--------e-----:'+e);
        }
    }
}