//04/01/2014
global class QuoteApprovalEmailService implements Messaging.InboundEmailHandler { 
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		Email_Approval_History__c newEAH = new Email_Approval_History__c();		
		try{					
			String subject = email.Subject;
			List<User> fromUser = [SELECT Id, Name FROM User WHERE Email =: email.fromAddress AND isActive = true];
			if(fromUser.size() > 1){
				newEAH.Reason_If_any__c = 'More than one user found.';
			}
			newEAH.Subject__c = subject;
			newEAH.Email_Body__c = email.plainTextBody;
			newEAH.From__c = email.fromAddress;
			System.debug('NKC debug fromUser ['+fromUser+']');
			System.debug('NKC debug email.plainTextBody ['+email.plainTextBody+']');
			String action;
			String firstLine = email.plainTextBody.split('\n')[0];
			String secondLine ='';
			String quoteNo = subject.split('Quote#')[1];
			System.debug('NKC debug quoteNo ['+quoteNo+']');
			quoteNo = quoteNo.split(':')[0];
			quoteNo = quoteNo.replace(' ','');
			newEAH.Quote_No__c = quoteNo;
			List<BigMachines__Quote__c> quotes = [SELECT id FROM BigMachines__Quote__c WHERE Name =: quoteNo LIMIT 1];
			if(quotes.isEmpty()){
				newEAH.Reason_If_any__c = 'No Matching Quote found.';
			}
			else{
				newEAH.Quote__c = quotes[0].id;
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
				String htmlBody = 'Your workflow approval message was not processed.  The word used to approve or reject the item was not understood. </br> Please contact your system administrator if you feel you received this message in error.';				
				SendEmail.sendSingleEmail(email.fromAddress, email.subject , htmlBody);
			}
			newEAH.Request_Type__c = action;
			System.debug('NKC debug action ['+action+']');
			System.debug('NKC debug subject ['+subject+']');
			Boolean isActionTaken = false;
			if(subject.contains('Quote#') && subject.contains(':') && !fromUser.isEmpty() && action != null){				
				if(!quotes.isEmpty()){
					List<ProcessInstance> procins = new List<ProcessInstance>([select Id from ProcessInstance where Status = 'Pending' and TargetObjectId = :quotes[0].id]);
					if(!procins.isEmpty()){
						List<ProcessInstanceWorkitem> workItems = new List<ProcessInstanceWorkitem>([select Id, ActorId, OriginalActorId from ProcessInstanceWorkitem where ProcessInstanceId = :procins[0].id]);
						Set<String> queueIds = new Set<String>();
						for(ProcessInstanceWorkitem eachPIWI : workItems){
							queueIds.add(eachPIWI.ActorId);
						}
						List<GroupMember> queueUsers = [Select UserOrGroupId, GroupId From GroupMember where GroupId IN : queueIds];
						Map<String,String> userIdVsQueueId = new Map<String,String>();
						for(GroupMember eachMember : queueUsers){
							userIdVsQueueId.put(eachMember.UserOrGroupId, eachMember.GroupId);
						}  
						System.debug('NKC debug userIdVsQueueId ['+userIdVsQueueId+']');
						for(ProcessInstanceWorkitem eachPIWI : workItems){
							System.debug('NKC debug eachPIWI.ActorId ['+eachPIWI.ActorId+']');
							System.debug('NKC debug userIdVsQueueId.get(fromUser[0].id) ['+userIdVsQueueId.get(fromUser[0].id)+']');							
							if(eachPIWI.ActorId == userIdVsQueueId.get(fromUser[0].id)){
								System.debug('NKC debug in APPROVE/REJECT');
								Approval.ProcessWorkitemRequest PWR = new Approval.ProcessWorkitemRequest();
								if(action == 'Approve')
									PWR.setComments('Approved By ' + fromUser[0].Name + ' - ' + secondLine);
								else
									PWR.setComments('Rejected By ' + fromUser[0].Name + ' - ' + secondLine);
								PWR.setNextApproverIds(new Id[] {fromUser[0].id});
								PWR.setAction(action);
								PWR.setWorkitemId(eachPIWI.id);											
								Approval.ProcessResult result1 =  Approval.process(PWR);	
								isActionTaken = true;
								//newEAH.OwnerId = eachPIWI.OriginalActorId;
							}	
						}
					}
				}
			}
			if(isActionTaken){
				String htmlBody = 'Your ' + action + ' request has been processed successfully.';				
				SendEmail.sendSingleEmail(email.fromAddress, email.subject , htmlBody);
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
}