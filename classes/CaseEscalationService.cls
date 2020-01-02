/*
	08/14/2013	Naresh Kumar
	Case escalation email service.
*/
global class CaseEscalationService implements Messaging.InboundEmailHandler { 
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();		
		try{		    
		    String subject = email.Subject;    
		    //String str = FindCasePattern.fetchCaseNo(subject);
		    List<RecordType> escalationRecordType = [SELECT id FROM RecordType WHERE SobjectType = 'Case' 
		    	AND DeveloperName = 'Genesys_Escalation_Case' LIMIT 1];
		    if(!escalationRecordType.isEmpty()){
				//List<Case> caseFound = [SELECT id FROM Case WHERE (CaseNumber = : str OR Case_Number__c = : str) LIMIT 1];
				//Case caseToBeUpdated;
				//if(caseFound.isEmpty())
				Case caseToBeUpdated = new Case();
				//else
				//	caseToBeUpdated = caseFound[0];
				caseToBeUpdated.RecordTypeId = escalationRecordType[0].id;
				caseToBeUpdated.Status = 'New';
				caseToBeUpdated.Priority = '2-High';
				caseToBeUpdated.Subject = email.Subject;
				caseToBeUpdated.Description = email.plainTextBody + '   From Email Address : ' + email.fromAddress;
				String queueId = getQueueId(email.toAddresses);
				
				if(queueId != null)
					caseToBeUpdated.OwnerId = queueId;					
				upsert caseToBeUpdated;
				
		    }
			result.success = true;
		}
		catch(Exception ex){
			result.success = false;
		}
	    return result;
  	}
  	
  	private String getQueueId(List<String> toAddress){
  		String APACQueueId, AmericasQueueId, EMEAQueueId;
  		//Querying queues
		List<Group> queues = [SELECT id FROM Group WHERE Type = 'Queue' AND (DeveloperName = 'APAC_Escalation_Queue' OR 
				DeveloperName = 'Americas_Escalation_Queue' OR DeveloperName = 'EMEA_Escalation_Queue') ORDER BY DeveloperName];
		if(queues.isEmpty())
			return null;
		AmericasQueueId = queues[0].id;
		APACQueueId = queues[1].id;
		EMEAQueueId = queues[2].id;
		for(String eachToAddress : toAddress){
			if(eachToAddress.startsWith('escinitamer@'))
				return AmericasQueueId;
			if(eachToAddress.startsWith('escinitapac@'))
				return APACQueueId;
			if(eachToAddress.startsWith('escinitemea@'))
				return EMEAQueueId;
		}
		return null;
  	}
}