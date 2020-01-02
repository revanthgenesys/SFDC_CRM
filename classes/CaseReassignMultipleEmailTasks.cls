global with sharing class CaseReassignMultipleEmailTasks {

     webservice static String reassignEmailTasks(List<Case> sourceCases, String targetCaseNum) {
     	String retMessage = ''; 
     	Integer success = 0, failed = 0, noemail = 0;
     	String body;
     	String targetCaseId;
     	List<Case> targetCase;
     	   
     	if ( targetCaseNum != null || targetCaseNum != '' )  {	
     		targetCase = [SELECT Id, Last_Public_Customer_Update__c, Contact.Email, Contact.Alternate_Email__c FROM Case WHERE CaseNumber = :targetCaseNum];
     		if ( !targetCase.isEmpty() ) 
     		     targetCaseId = targetCase[0].Id;
     	}
     	if ( targetCaseId == null ) {
     		return 'No Case with the Number ' + targetCaseNum + ' has been found. Please specify a valid Case Number.';
     	}
     	
     	List<Task> tasks = [SELECT Id, whatId FROM task WHERE whatId IN 
     						 (SELECT ID FROM Case WHERE id IN :sourceCases AND RecordType.Name = 'Email To Case')];
     	
     	if ( tasks.isEmpty() ) {    		
     		return 'No Email activities for reassignment have been fond.';
     	}
     	
     	for ( Task tsk : tasks ) {
     		if ( tsk.whatId == targetCaseId )
     		    continue;
     		
     		List<EmailMessage> eMesgs = [SELECT id, HtmlBody, TextBody, Incoming, CreatedBy.Email, FromAddress, 
     		                                     ActivityId, BccAddress, CcAddress, FromName, Headers,
					                             ParentId, ReplyToEmailMessageId, Status, ToAddress, Subject, Parent.CaseNumber 
					                     FROM EmailMessage 
					                     WHERE ActivityId = : tsk.id];
			if ( eMesgs.isEmpty() ) {
				noemail++;
				continue;
		   }	
     	   if ( reassignTask (eMesgs[0], targetCaseId, targetCase[0]) ) {
     	    	
     	    	try {
     	    		tsk.whatId = targetCaseId;
     	    		update tsk;
     	    	}
     	    	catch (Exception ex )  {
     	    		failed++;
     	    		continue;
     	    	}
     	    	success++;
     	    	 	
     	    	try {		
     	    		Case sourceCase = new Case(id = eMesgs[0].ParentId, Status = 'Closed');
     	    		update sourceCase;	    		
     	    	}
     	    	catch (Exception ex) {
     	    		retMessage += 'Error closing Case ' + eMesgs[0].Parent.CaseNumber + '\n';
     	    		continue;
     	    	}    	    	
     	   
     	    }
     	    else {
     	    	failed++;
     	        retMessage += 'Error reassigning activitiy from Case ' + eMesgs[0].Parent.CaseNumber + '\n';  
     	    }
     	}
     	
     	targetCase[0].Last_Public_Customer_Update__c = System.now();
     	update targetCase[0];
     	
     	retMessage += success + ' activities have been reassigned successfully, \n' +
     	              failed + ' activities failed reassigment. \n';
     	if ( noemail > 0 )             
     	       retMessage += noemail + ' cases have no associated email activities';
     	          	             
     	return retMessage;
     }
     
     private static Boolean reassignTask(EmailMessage orgEmailMsg, String targetCsId, Case cs)  {
 
     	try {	
			EmailMessage newEM = cloneEmailMsg(orgEmailMsg, targetCsId, cs);
			insert newEM;
			
			List<Attachment> newAtts = new List<Attachment>();
			List<Attachment> atts = [SELECT id, Name, Body, Description, IsPrivate, ParentId  FROM Attachment WHERE parentId =: orgEmailMsg.id];
			
			for(Attachment eachAtt : atts) {
				Attachment newAtt = new Attachment();
				newAtt.Body = eachAtt.Body;
				newAtt.Description = eachAtt.Description;
				newAtt.IsPrivate = eachAtt.IsPrivate;
				newAtt.Name = eachAtt.Name;
				newAtt.ParentId = newEM.id;
				newAtts.add(newAtt);
			}
			
			insert newAtts;				
		    delete orgEmailMsg;	
     	}
     	catch (Exception ex) {   		
     		return false;
     	}				
		
		return true;
	}
	
	private static EmailMessage cloneEmailMsg(EmailMessage em, String targetCsId, Case cs )  {
		EmailMessage newEM = new EmailMessage();
		newEM.ActivityId = em.ActivityId;
		newEM.BccAddress = em.BccAddress;
		newEM.CcAddress = em.CcAddress;
		newEM.FromAddress = em.FromAddress;
		newEM.FromName = em.FromName;
		newEM.Headers = em.Headers;
		newEM.HtmlBody = em.HtmlBody;
		newEM.Incoming = em.Incoming;
		newEM.ParentId = targetCsId;
		newEM.ReplyToEmailMessageId = em.ReplyToEmailMessageId;
		newEM.Status = em.Status;
		newEM.Subject = em.Subject;
		newEM.TextBody = em.TextBody;
		newEM.ToAddress = em.ToAddress;
		
		if ( String.isNotBlank(newEM.FromAddress) && (newEM.FromAddress == cs.Contact.Email || newEM.FromAddress == cs.Contact.Alternate_Email__c) )
		   newEM.IsExternallyVisible = true;
		
		return newEM;		
	}
}