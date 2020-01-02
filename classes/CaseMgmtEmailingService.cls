global class CaseMgmtEmailingService {
	
	@InvocableMethod(label='Send Case Email Notification')
	global static void emailNotificationRequest(List<EmailRequest> emreq) {
		processEmailRequest(emreq);
	}
	
	public static void processEmailRequest(List<EmailRequest> emreq) {
/*
 Notification to a Contact (External type) sent:
        to Contact, cc to all External type subscribers, bcc to all Internal type subscribers
               
 Notification to Genesys Employee (Internal) sent:
        to Employee, cc to all Internal type subscribers
*/		
		ID templateId = getTemplateIdByAPIName(emreq[0].templateName);
		if ( templateId == null ) {
		     ErrorLogUtil.insertLog('CaseMgmtEmailingService', 'Unable to locate Email Template: ' + emreq[0].templateName, 
		                             'CaseMgmtEmailingService.processEmailRequest');     
    		 return;
		}
		
		ID caseId;
		ID mergedObjectId;
		if ( emreq[0].sourceObject == 'Case' ) {
		   caseId = emreq[0].sourceId;
		   mergedObjectId = caseId;
		}
		else if ( emreq[0].sourceObject == 'FeedItemLog' ) {
		   caseId = getCaseIdByFeedPostId(emreq[0].sourceId);
		   mergedObjectId = emreq[0].sourceId;
		}
		CaseEmailRecipient recipts = new CaseEmailRecipient(caseId);
		
		try {
		   //sendSingleEmail(templateId, ObjectId, toAddr, ccAddr, bccAddr) 
			
			if ( emreq[0].sendToContact == true )  {  /// Contact + External + Internal							
				sendSingleEmail (templateId, mergedObjectId, recipts.ContactAddr, 
				             			 recipts.ExternalDistrAddrList, recipts.InternalDistribAddrList);
			}
			else if ( emreq[0].sendToOwner == true ) { /// Owner + Internal Subscribers
				sendSingleEmail (templateId, mergedObjectId, recipts.OwnerAddr, recipts.InternalDistribAddrList, null);
			}
			else if ( emreq[0].sendToContact == false ) { /// Internal Subscribers
				sendSingleEmail (templateId, mergedObjectId, recipts.InternalDistribAddrList, null, null);
			}
		} 
		catch (Exception ex) {
			ErrorLogUtil.insertLog('CaseMgmtEmailingService', 'Error sending Email Notification triggered from Id <' +  mergedObjectId +
			                       '>.  ' + ex.getMessage(),  'CaseMgmtEmailingService.processEmailRequest');     
    		return;
		}
	}
	
	global class EmailRequest {
		
		@InvocableVariable(required=true label='Source ID (Case Id or FeedItemLog Id)' Description='Case Id or Case FeedItemLog Log Id')
		global ID sourceId;
		
		@InvocableVariable(required=true label='Source Object (Case or FeedItemLog)' Description='Case or FeedItemLog')
		global String sourceObject;
		
		@InvocableVariable(required=true label='Email Template API Name' Description='API Name of the Email Template')
		global String templateName;
		
		@InvocableVariable(required=true label='To Contact')
		global Boolean sendToContact = false;
		
		@InvocableVariable(required=true label='To Owner')
		global Boolean sendToOwner = false;
	
	}

	public static ID getTemplateIdByAPIName (String templName) {		
		ID templId;
        List<EmailTemplate> tlst = new List<EmailTemplate>();
        
        if ( String.isNotBlank(templName) )	
     	   tlst = [SELECT id FROM EmailTemplate WHERE DeveloperName = :templName];  
        
        if ( !tlst.isEmpty() ) 
           templId = tlst[0].id;
            
        return templId;		
	}
	
	public static ID getCaseIdByFeedPostId(ID logId) {
		ID caseId;
		
		List<Case_FeedPost_Log__c> cf = [SELECT Case__c FROM Case_FeedPost_Log__c WHERE Id = :logId];
		
		if ( !cf.isEmpty() )
		  caseId = cf[0].Case__c;
		  
		return caseId;		
	}
		
	public static void sendSingleEmail (ID templateId, ID mergedObjectId, 
	                                    List<String> toAddr, List<String> ccAddr, List<String> bccAddr) {
	                                    	                                    			
		if ( templateId == null || toAddr.isEmpty() )
		    return;
	
		Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(templateId, null, mergedObjectId);
			 
		String subject = mail.getSubject(); 
		String body = mail.getHtmlBody(); 
	
		mail.setSubject(subject);
		mail.setHtmlBody(body);
			 	 
		mail.setToAddresses(toAddr);
		mail.setCcAddresses(ccAddr);
		mail.setBccAddresses(bccAddr);
		mail.setUseSignature(false);
		
		mail.setOrgWideEmailAddressId( Global_Setting__c.getInstance('CustomerCareEmailAddress').ID__c );
			 
		mail.saveAsActivity = false;
	
		 Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	}
	
	public class CaseEmailRecipient {
		public List<String> ContactAddr = new List<String>();
		public List<String> OwnerAddr = new List<String>();
		public List<String> ExternalDistrAddrList = new List<String>();
		public List<String> InternalDistribAddrList = new List<String>();
				
		public CaseEmailRecipient(ID caseId) {
			
			List<Case> cslst = [SELECT Contact.Email, contact.Alternate_Email__c, Owner.Email, RecordType.Name,
			                           Cloud_Deployment__c, Back_Office_Account__c,
			                 	(SELECT Subscription_Type__c, Contact_Email_Addr__c, Contact_Alternative_Email__c, 
			                 	        Genesys_Employee_Email__c, Additional_Email_Addr__c 
			                 	 FROM Case_Email_Subscriptions__r)			                 
			                 FROM Case
			                 WHERE Id = :caseId];
			
			if ( ! cslst.isEmpty() )  {
				// Recipients from the Case
				if ( cslst[0].Contact.Email != null )
					ContactAddr.add(cslst[0].Contact.Email);
					
				if ( cslst[0].Owner.Email != null )
				 	OwnerAddr.add(cslst[0].Owner.Email);
				
				if ( cslst[0].contact.Alternate_Email__c != null )
					ExternalDistrAddrList.add(cslst[0].contact.Alternate_Email__c);
				
				///Recipients from the Case Subsciption list
			    for ( Case_Email_Subscription__c sub : cslst[0].Case_Email_Subscriptions__r ) {
			    	if ( sub.Subscription_Type__c == 'External') {
			    		if ( sub.Additional_Email_Addr__c != null )
			    		   ExternalDistrAddrList.add(sub.Additional_Email_Addr__c); 
			    		else {
				    		if ( sub.Contact_Email_Addr__c != null )
				    		   ExternalDistrAddrList.add(sub.Contact_Email_Addr__c);
				    		if ( sub.Contact_Alternative_Email__c != null )
				    		    ExternalDistrAddrList.add(sub.Contact_Alternative_Email__c);	
			    		}		    					    		    
			    	}
			    	
			    	if ( sub.Subscription_Type__c == 'Internal')  {
			    		if ( sub.Genesys_Employee_Email__c != null )
			    		  InternalDistribAddrList.add( sub.Genesys_Employee_Email__c);
			    		else if ( sub.Additional_Email_Addr__c != null )
			    		  InternalDistribAddrList.add(sub.Additional_Email_Addr__c); 
			    	}			    				    	
			    } /// for case subscrp.
		
				   /// If case is type Cloud, add Recipients from Cloud Deployment Subscription list
				if ( cslst[0].RecordType.Name.contains('Cloud') && cslst[0].Cloud_Deployment__c != null )  {			    	
				     List<Case_Email_Subscription_CD__c> cdsubs = [SELECT Subscription_Type__c, Contact_Email_Addr__c, Contact_Alternative_Email__c, 
				                 	                                         Genesys_Employee_Email__c, Additional_Email_Addr__c 			                 	                                         
				                 	                                  FROM Case_Email_Subscription_CD__c
				                 	                                  WHERE Cloud_Deployment__c = :cslst[0].Cloud_Deployment__c];
				                 	                                  
				      for ( Case_Email_Subscription_CD__c sub : cdsubs )   {
					    	if ( sub.Subscription_Type__c == 'External') {
					    		if ( sub.Additional_Email_Addr__c != null )
					    		   ExternalDistrAddrList.add(sub.Additional_Email_Addr__c); 
					    		else {
						    		if ( sub.Contact_Email_Addr__c != null )
						    		   ExternalDistrAddrList.add(sub.Contact_Email_Addr__c);
						    		if ( sub.Contact_Alternative_Email__c != null )
						    		    ExternalDistrAddrList.add(sub.Contact_Alternative_Email__c);	
					    		}		    					    		    
					    	}
					    	
					    	if ( sub.Subscription_Type__c == 'Internal')  {
					    		if ( sub.Genesys_Employee_Email__c != null )
					    		  InternalDistribAddrList.add( sub.Genesys_Employee_Email__c);
					    		else if ( sub.Additional_Email_Addr__c != null )
					    		  InternalDistribAddrList.add(sub.Additional_Email_Addr__c); 
					    	}			    				    	
				    	}
			    } //if case coud
			    
			    /// if case is Premise add Recipients from Back Office Account Subscription list
			    if ( !cslst[0].RecordType.Name.contains('Cloud') && cslst[0].Back_Office_Account__c != null )  {			    	
				     List<Case_Email_Subscription_BOA__c> boasubs = [SELECT Subscription_Type__c, Contact_Email_Addr__c, Contact_Alternative_Email__c, 
				                 	                                         Genesys_Employee_Email__c, Additional_Email_Addr__c 			                 	                                         
				                 	                             FROM Case_Email_Subscription_BOA__c
				                 	                             WHERE Back_Office_Account__c = :cslst[0].Back_Office_Account__c];
				                 	                                  
				      for ( Case_Email_Subscription_BOA__c sub : boasubs )   {
					    	if ( sub.Subscription_Type__c == 'External') {
					    		if ( sub.Additional_Email_Addr__c != null )
					    		   ExternalDistrAddrList.add(sub.Additional_Email_Addr__c); 
					    		else {
						    		if ( sub.Contact_Email_Addr__c != null )
						    		   ExternalDistrAddrList.add(sub.Contact_Email_Addr__c);
						    		if ( sub.Contact_Alternative_Email__c != null )
						    		    ExternalDistrAddrList.add(sub.Contact_Alternative_Email__c);	
					    		}		    					    		    
					    	}
					    	
					    	if ( sub.Subscription_Type__c == 'Internal')  {
					    		if ( sub.Genesys_Employee_Email__c != null )
					    		  InternalDistribAddrList.add( sub.Genesys_Employee_Email__c);
					    		else if ( sub.Additional_Email_Addr__c != null )
					    		  InternalDistribAddrList.add(sub.Additional_Email_Addr__c); 
					    	}			    				    	
				    	}
			    } //if case Premise
			    
				    
			 }	/// if 	! cslst.isEmpty()	
		}		
	} 
	
}