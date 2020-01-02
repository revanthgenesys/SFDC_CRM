/*
 Purpose: When Case Contact sends in an email Set case status to Open/Update from Customer
          Any inbound email Set New Update to Yes (unless update by Case Owner)
 
 Test: EmailMessageToCaseTrigger_Test
*/
trigger EmailMessageToCase on EmailMessage (after insert, after update) {

    if(Util.Bypass_Trigger_Chk)
 		return;

    Set<Id> caseIDs = new Set<Id>();
    for ( EmailMessage msg : Trigger.New )  {
    	if ( msg.ParentId != null )
    	   caseIDs.add(msg.ParentId);
    }
    List<Case> cases = [SELECT Id, New_Updates__c, Owner.Email, Contact.Email, Contact.Alternate_Email__c, 
			                   RecordType.DeveloperName, Status, First_Response_Timestamp__c, Priority
			           FROM Case WHERE Id = :caseIDs];
	
	Map<Id, Case> caseMap = new Map<Id, Case>(cases);		
    
    if ( Trigger.isInsert ) {
   
		Map<Id, String> fromAddrToCase = new Map<Id, String>();
		Map<Id, String> outboundMsg = new Map<Id, String>();
		
		for ( EmailMessage msg : Trigger.New )  {
			
	    	if ( msg.ParentId != null && msg.Incoming ) {
		    		fromAddrToCase.put( msg.ParentId, msg.FromAddress );
	    	}
	    	else if ( msg.ParentId != null && !msg.Incoming && msg.IsExternallyVisible && msg.TextBody != null ) {
	    	   	    String body = msg.TextBody.length() < 32000 ? msg.TextBody : msg.TextBody.substring(0, 32000);    	   	    
	    	        outboundMsg.put(msg.ParentId, body);
	    	}
		}
		// Inbound Emails
		if ( fromAddrToCase.size() != 0 )  {
			List<Case> updCases = new List<Case>();
						
			for ( Case cs : cases ) {
	
	            Case updcs = new Case(id=cs.id);			
	            
				if ( cs.Contact.Email == fromAddrToCase.get(cs.Id) || cs.Contact.Alternate_Email__c == fromAddrToCase.get(cs.Id) ||
				     ! fromAddrToCase.get(cs.Id).endsWith('@genesys.com') ) {
					
					if ( ! cs.RecordType.DeveloperName.contains('Feature') && cs.Status != 'Closed' ) {		
						updcs.Status = 'Open';   
					}   
					
					if ( cs.Status != 'Closed' )     
			       		 updcs.Sub_Status__c = 'Update from Customer';	
			        else 
			       		 updcs.Sub_Status__c = 'Customer Requested to Re-open';
			       	
			       	updcs.Last_Public_Customer_Update__c = system.now();	 
					updcs.New_Updates__c = true;					        				
				}
				else  {
					 updcs.New_Updates__c = true;
					 updcs.Last_Private_Care_Update__c = system.now();	
				}
	
				updCases.add(updcs);
			}
			
			if ( !updCases.isEmpty() )
			  update updCases;
		} 
		/// Outbound Emails
		else if ( outboundMsg.size() != 0 ) {
			List<Case> updCases = new List<Case>();
			
			for (Id csId : outboundMsg.keySet() ) {
				Case updcs = new Case(id = csId, Last_Public_Care_Update__c = system.now(),
				                      Last_Public_Case_Update_Description__c = outboundMsg.get(csId));
				                      
				if ( caseMap.containsKey(csId) && caseMap.get(csId).First_Response_Timestamp__c == null ) {
					updcs.First_Response_Timestamp__c = system.now();
					updcs.Last_Priority_FirstResponse__c = caseMap.get(csId).Priority;
				}
				updCases.add(updcs);			
			}
			
			if ( !updCases.isEmpty() )
			  update updCases;		
		}
	} 
	
	if ( Trigger.isUpdate )  {
		List<Case> updCases = new List<Case>();
		for ( EmailMessage msg : Trigger.New )  {
	    	if ( msg.ParentId != null && !msg.Incoming && msg.TextBody != null &&
	    	     msg.IsExternallyVisible && !Trigger.oldMap.get(msg.Id).IsExternallyVisible ) {
	    		
	    	   	    String body = msg.TextBody.length() < 32000 ? msg.TextBody : msg.TextBody.substring(0, 32000);    	   	    
	    	        Case updcs = new Case(id = msg.ParentId, Last_Public_Care_Update__c = system.now(),
				                      Last_Public_Case_Update_Description__c = body);
				                      
				    if ( caseMap.containsKey(msg.ParentId) && caseMap.get(msg.ParentId).First_Response_Timestamp__c == null ) {
						updcs.First_Response_Timestamp__c = system.now();
						updcs.Last_Priority_FirstResponse__c = caseMap.get(msg.ParentId).Priority;
					}
				    updCases.add(updcs);			
	    	}
		}
		
		if ( !updCases.isEmpty() )
			  update updCases;		
	}
}