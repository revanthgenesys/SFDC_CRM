global class QuoteApprovalEmailServiceOnPremise implements Messaging.InboundEmailHandler { 
  global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
      Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
      String DQNo='';
      //Eamil approval history
      Email_Approval_History__c newEAH = new Email_Approval_History__c();    
      try{          
        List<String> userIdAndQuoteApprovalId = getUserAndApprovalRecordId(email.plainTextBody);
        if(userIdAndQuoteApprovalId.size() > 3 && userIdAndQuoteApprovalId[3] != ''){
            List<Deal_Qualification__c> dqs_lst = new List<Deal_Qualification__c>();
            dqs_lst = [SELECT id, Name, Opportunity__r.Name FROM Deal_Qualification__c WHERE id =: userIdAndQuoteApprovalId[3]];
            if(!dqs_lst.isempty()){
                DQNo = dqs_lst[0].name+' : ';
            }
        }
        System.debug('NKC debug userIdAndQuoteApprovalId ['+userIdAndQuoteApprovalId+']');
        
        if(userIdAndQuoteApprovalId.size() < 2){
          SendEmail.sendSingleEmail(email.fromAddress, DQNo + 'Approval was not precessed successfully.' , 'Your request was not processed successfully. Please contact the administrator.', 'Approvals');
          result.success = true;
          return result;
        }
        String subject = email.Subject;
        newEAH.Subject__c = subject;
          newEAH.Email_Body__c = email.plainTextBody;
          newEAH.From__c = email.fromAddress;
          System.debug('NKC debug fromUser ['+userIdAndQuoteApprovalId[0]+']');
          System.debug('NKC debug email.plainTextBody ['+email.plainTextBody+']');
        String action;
        String firstLine = email.plainTextBody.split('\n')[0];
        String secondLine ='';
        String oppName;
        List<User> fromUser = [SELECT id FROM User WHERE email =: email.fromAddress];
        if(fromUser.isEmpty()){
          newEAH.Reason_If_any__c = 'No user found with email id : ' + email.fromAddress;
            newEAH.Status__c = 'Error';
        }
        List<BigMachines__Quote__c> quotes = new List<BigMachines__Quote__c>();
        List<Deal_Qualification__c> dqs = new List<Deal_Qualification__c>();
        if(userIdAndQuoteApprovalId[2] != null && userIdAndQuoteApprovalId[2] != ''){
            quotes = [SELECT id, Name, BigMachines__Opportunity__r.Name FROM BigMachines__Quote__c WHERE id =: userIdAndQuoteApprovalId[2]];
            if(quotes.isEmpty()){
              newEAH.Reason_If_any__c = 'No Matching Quote found.';
              newEAH.Status__c = 'Error';
            }
            else{
              newEAH.Quote__c = quotes[0].id;
              newEAH.Quote_No__c = quotes[0].Name;
              oppName = quotes[0].BigMachines__Opportunity__r.Name;
            }            
        }
          if(userIdAndQuoteApprovalId.size() > 3 && userIdAndQuoteApprovalId[2] != null && userIdAndQuoteApprovalId[3] != ''){
            dqs = [SELECT id, Name, Opportunity__r.Name FROM Deal_Qualification__c WHERE id =: userIdAndQuoteApprovalId[3]];
            if(dqs.isEmpty()){
              newEAH.Reason_If_any__c = 'No Matching DQ found.';
              newEAH.Status__c = 'Error';
            }
            else{
              newEAH.Deal_Qualification__c = dqs[0].id;
              newEAH.Quote_No__c = dqs[0].Name;
              oppName = dqs[0].Opportunity__r.Name;
            }
          }
          
          if(email.plainTextBody.split('\n').size() > 1)
            secondLine = email.plainTextBody.split('\n')[1];
          System.debug('NKC debug secondLine ['+secondLine+']');
      
          if(firstLine.contains('Approved') || firstLine.contains('approved') || firstLine.contains('Approve') || firstLine.contains('approve'))
            action = 'Approve';
          else if(firstLine.contains('Rejected') || firstLine.contains('rejected') || firstLine.contains('Reject') || firstLine.contains('reject'))
            action = 'Reject';
          else{
            newEAH.Request_Type__c = action;
            newEAH.Status__c = 'Failure';
            newEAH.Reason_If_any__c = 'The word used to approve or reject the item was not understood.';
            String htmlBody = DQNo +'Your workflow approval message was not processed.  The word used to approve or reject the item was not understood. </br> Please contact your system administrator if you feel you received this message as an error.';        
            SendEmail.sendSingleEmail(email.fromAddress, DQNo + email.subject , htmlBody);
          }
          newEAH.Request_Type__c = action;
          System.debug('NKC debug action ['+action+']');
          System.debug('NKC debug subject ['+subject+']');
          Boolean isActionTaken = false;
          if(action != null){        
            if(!quotes.isEmpty() || !dqs.isEmpty()){
              List<Quote_Approval__c> quoteApprovals = [SELECT Status__c, ownerId FROM Quote_Approval__c 
                  WHERE Status__c =: QuoteApprovalUtil.STATUS_PENDING AND id =: userIdAndQuoteApprovalId[1]];
            
          if(!quoteApprovals.isEmpty()){
                  Set<String> queueIds = new Set<String>();
                  for(Quote_Approval__c eachQA : quoteApprovals){
                      queueIds.add(eachQA.ownerId);
                  }
                  List<GroupMember> queueUsers = [Select UserOrGroupId, GroupId From GroupMember where GroupId IN : queueIds];
                  Map<String,String> userIdVsQueueId = new Map<String,String>();
                  for(GroupMember eachMember : queueUsers){
                    userIdVsQueueId.put(eachMember.UserOrGroupId, eachMember.GroupId);
                  }  
                  System.debug('NKC debug userIdVsQueueId ['+userIdVsQueueId+']');
                  System.debug('NKC debug fromUser[0].id ['+fromUser[0].id+']');
                  
                  for(Quote_Approval__c eachQA : quoteApprovals){
                    System.debug('NKC debug eachQA.ownerId ['+eachQA.ownerId+']');
                    System.debug('NKC debug fromUser[0].id ['+fromUser[0].id+']');                    
                    if(eachQA.ownerId == userIdVsQueueId.get(fromUser[0].id) || eachQA.OwnerId == fromUser[0].id){
                        System.debug('NKC debug in APPROVE/REJECT');
                        /*
                        if(eachQA.Status__c != QuoteApprovalUtil.STATUS_PENDING){
                          String htmlBody = 'Your ' + action + ' request wan not processed successfully. The record which you are trying to ' + action + ' is already in ' + eachQA.Status__c + ' status.';        
                      SendEmail.sendSingleEmail(email.fromAddress, email.subject , htmlBody, 'Auto Approvals');
                      break;
                        }
                        */
                        if(action == 'Approve'){                            
                            eachQA.Status__c = QuoteApprovalUtil.STATUS_APPROVED;
                        }
                        else{                            
                            eachQA.Status__c = QuoteApprovalUtil.STATUS_REJECTED;
                        }
                        eachQA.Comments__c = secondLine.replace('Comments:', '');
                          eachQA.Actual_Approver__c = fromUser[0].id;  
                          eachQA.Quote_Approval_Date__c = System.now(); 
                          eachQA.Approval_Method__c = 'Email';                    
                        isActionTaken = true;
                        update eachQA;
                        if(action == 'Reject'){
                          if(!quotes.isEmpty())
                            QuoteApprovalAssignmentHelper.approvalRejectionActions(quotes[0].id);
                          if(!dqs.isEmpty())
                            DealQualificationAppAssignmentHelper.approvalRejectionActions(dqs[0].id);
                        }
                        break;
                        //newEAH.OwnerId = eachPIWI.OriginalActorId;
                      }  
                  }
                }
            }
          }
          System.debug('NKC debug oppName ['+oppName+']');
          if(isActionTaken){
            String htmlBody = 'Your ' + action + ' request has been processed successfully.';
            String temp; 
            if(action == 'Approve')
              temp = 'Approval';
            else
              temp = 'Rejection';       
            SendEmail.sendSingleEmail(email.fromAddress, DQNo + temp + ' was successful for ' + oppName, htmlBody, 'Approvals');
          }
          else{
            String htmlBody = 'Your ' + action + ' request was not processed successfully. Please contact admin.';        
            SendEmail.sendSingleEmail(email.fromAddress, DQNo + 'Approval was not successful for ' + oppName , htmlBody, 'Approvals');
            newEAH.Status__c = 'Failure';
          }
          if(newEAH.Status__c == null)
            newEAH.Status__c = 'Success';
          result.success = true;        
      }
      catch(Exception ex){
        newEAH.Status__c = 'Failure';
        newEAH.Reason_If_any__c = ex.getMessage();
        result.success = false;
      }
      insert newEAH;
      return result;
  }
  
  private List<String> getUserAndApprovalRecordId(String emailBody){
    Integer startIndex = emailBody.indexOf('ref:') + 4;    
    Integer lastIndex = emailBody.lastIndexOf(':ref');    
    String ids = emailBody.substring(startIndex, lastIndex);
    return ids.split('-');    
  } 
}