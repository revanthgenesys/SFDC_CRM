global class PartnerAppApprovalEmailServiceHandler implements Messaging.InboundEmailHandler {

    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,
    Messaging.InboundEnvelope envelope) {
    Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
    
    String subToCompare = 'PA-';
        
    if(email.subject.contains(subToCompare)){
        System.debug('Testing' + email.subject.indexOf(subToCompare));
        Integer index = email.subject.indexOf(subToCompare);
        Integer endIndex = index +8;
        String PartnerApplicationName = email.subject.substring(index,endIndex);
        System.debug('*****PartnerApplicationName'+PartnerApplicationName+'****');
        List<Partner_Application__c> PartnerApplicationobjList = [Select id,(select id,ActorId,Actor.name,Comments,ElapsedTimeInDays,ElapsedTimeInHours,ElapsedTimeInMinutes,OriginalActorId,OriginalActor.name,ProcessInstanceId,RemindersSent,StepStatus from ProcessSteps where StepStatus = 'Pending') from Partner_Application__c where name =: PartnerApplicationName LIMIT 1];
        System.debug('*****PartnerApplicationobjList'+PartnerApplicationobjList);
        if(PartnerApplicationobjList.size() == 1){
        if(email.plainTextBody != '' && email.plainTextBody != null){
            Partner_Application__c PartnerApplicationObj = PartnerApplicationobjList[0];
            String processWorkItemId;
            System.debug('****PartnerApplicationObj'+PartnerApplicationObj);
            String action;
            //String fromEmailAddress = email.fromAddress;
            String fromEmailAddress = envelope.fromAddress;
            System.debug('*****fromEmailAddress'+fromEmailAddress);
            List<User> userList = [select id,name from User where Email=:fromEmailAddress limit 1];
            System.debug('*****userList'+userList);
            User approvalUser;
            if(userList!=null && userList.size()>0){
                approvalUser = userList[0];
            }
            if(PartnerApplicationObj.ProcessSteps!=null && PartnerApplicationObj.ProcessSteps.size()>0){
                System.debug('******PartnerApplicationObj.ProcessSteps[0]'+PartnerApplicationObj.ProcessSteps[0]);
                processWorkItemId = PartnerApplicationObj.ProcessSteps[0].id;
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
                    //System.runAs(approvalUser){
                        if(processWorkItemId!=null && action!=null){
                            /*
                            ProcessInstanceWorkitem  p = new ProcessInstanceWorkitem(id=processWorkItemId);
                            p.actorid= '005U0000000gZL2';
                            p.OriginalActorId = '005U0000000gZL2';
                            update p;
                            System.debug('*****p'+p);
                            */
                            Approval.ProcessWorkitemRequest req2 = new Approval.ProcessWorkitemRequest();
                            if(comments!=null && comments!=''){
                                req2.setComments(comments);
                            }
                            req2.setAction(action);
                            if(action == 'Approve'){
                                //req2.setNextApproverIds(new Id[] {UserInfo.getUserId()});
                                req2.setNextApproverIds(new Id[] {approvalUser.Id});
                            }                           
                            // Use the ID from the newly created item to specify the item to be worked
                            req2.setWorkitemId(processWorkItemId);
                            
                            Approval.ProcessResult result2 =  Approval.process(req2);
                            /*
                            ProcessInstanceStep pis = new ProcessInstanceStep(id='04hK0000000FfDaIAK');
                            pis.ActorId = '005U0000000gZL2';
                            update pis;
                            */
                        }
                    //}
                }
                
            }
            catch(Exception e){
                System.debug('The exception is' + e);
            }
        }
        }
    }

    result.success = true;
        return result;
    }
}