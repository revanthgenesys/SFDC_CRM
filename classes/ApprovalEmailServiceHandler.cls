global class ApprovalEmailServiceHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    
    String emailTextBody = email.plainTextBody;
    System.debug('****emailTextBody'+emailTextBody);
    
    Integer startIndex = emailTextBody.indexOf('recordidstart');
    Integer endIndex = emailTextBody.indexOf('recordidend');
    System.debug('*****startIndex'+startIndex);
    System.debug('*****endIndex'+endIndex);
    startIndex += 13;
    System.debug('*****startIndex'+startIndex);
    String recordId = emailTextBody.substring(startIndex,endIndex);
    System.debug('*****recordId'+recordId);
    
    Integer startIndexWorkItem = emailTextBody.indexOf('workprocessitemidstart');
    Integer endIndexWorkItem = emailTextBody.indexOf('workprocessitemidend');
    System.debug('*****startIndexWorkItem'+startIndexWorkItem);
    System.debug('*****endIndexWorkItem'+endIndexWorkItem);
    startIndexWorkItem += 22;
    System.debug('*****startIndexWorkItem'+startIndexWorkItem);
    String workprocessitemid = emailTextBody.substring(startIndexWorkItem,endIndexWorkItem);
    System.debug('*****workprocessitemid'+workprocessitemid);
    if(workprocessitemid!=null && workprocessitemid!=''){
        String action;
        String fromEmailAddress = envelope.fromAddress;
        System.debug('*****fromEmailAddress'+fromEmailAddress);
        List<User> userList = [select id,name from User where Email=:fromEmailAddress limit 1];
        System.debug('*****userList'+userList);
        User approvalUser;
        if(userList!=null && userList.size()>0){
            approvalUser = userList[0];
        }
        try{
            String comments = '';
            String firstLine = email.plainTextBody.split('\n')[0];
            System.debug('*****firstLine'+firstLine);
            if(email.plainTextBody.split('\n')!=null && email.plainTextBody.split('\n').size()>1){
                comments = email.plainTextBody.split('\n')[1];
            }
            if(firstLine.contains('Approved') || firstLine.contains('approved') || firstLine.contains('Approve') || firstLine.contains('approve') || firstLine.contains('APPROVE') || firstLine.contains('APPROVED'))
            action = 'Approve';
              else if(firstLine.contains('Rejected') || firstLine.contains('rejected') || firstLine.contains('Reject') || firstLine.contains('reject') || firstLine.contains('REJECT') || firstLine.contains('REJECTED'))
            action = 'Reject';
            
            if(approvalUser!=null){
                if(action!=null){                       
                    Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                    if(comments!=null && comments!=''){
                        req2.setComments(comments);
                    }
                    req2.setAction(action);
                    if(action == 'Approve' || action == 'Approve'){
                        req2.setNextApproverIds(new Id[] {approvalUser.Id});
                    }                           
                    // Use the ID from the newly created item to specify the item to be worked
                    req2.setWorkitemId(workprocessitemid); 
                    System.debug('*****req2'+req2);
                    Approval.ProcessResult result2 =  Approval.process(req2);                       
                }
            }
            
        }       
        catch(Exception e){
            System.debug('The exception is' + e);
        }
    }
    result.success = true;
        return result;
    }
}