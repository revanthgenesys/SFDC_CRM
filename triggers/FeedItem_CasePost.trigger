trigger FeedItem_CasePost on FeedItem (after insert, after update, before delete) {
	
	if ( Util.Bypass_Trigger_Chk) return;
 /* 
 update case: 
  1. set flag New Updates = true
  2. insert Case FeedLog record in order to send Email Notifications
*/
     Boolean isPortalUser = ContactUtil.isPortalUser();
     Set<ID> publicUpdCases = new Set<ID>();
     Set<ID> privateUpdCases = new Set<ID>();
     Map<ID, String> caseIdPublicUpdate = new Map<ID, String> ();
     List<Case_FeedPost_Log__c> plogs = new List<Case_FeedPost_Log__c>();
     
     if (Trigger.isInsert) {
  	
    	for ( FeedItem fi : Trigger.New )  {
    		if ( fi.ParentId.getSObjectType().getDescribe().getName() == 'Case' && (fi.Type == 'TextPost' || fi.Type == 'LinkPost') ) {

                 caseIdPublicUpdate.put(fi.ParentId, fi.Body);
    			 /// insert Case FeedPost for Email Notification
    			 if ( fi.Visibility == 'AllUsers' ) { 
    			 	 // skip Auto-Follow Up
    			 	 if ( fi.Title != 'Auto-Follow Up' )
    			 	     publicUpdCases.add(fi.ParentId);  
    			 	    			 	    	      	
    			 	 addPublicPostLog(fi);
    			 }
    			 else {
    			 	  privateUpdCases.add(fi.ParentId);
    			 }	
    		}
    	}
 
    	insertFeedLogs();
    	updateCases();
     }
     
     if (Trigger.isUpdate) {     	
     	for ( FeedItem fi : Trigger.New )  { 
    		if ( fi.ParentId.getSObjectType().getDescribe().getName() == 'Case' && (fi.Type == 'TextPost' || fi.Type == 'LinkPost') ) {
    			 /// insert Case FeedPost for Email Notification
    			 caseIdPublicUpdate.put(fi.ParentId, fi.Body);
    			 
    			 if ( fi.Visibility == 'AllUsers' && Trigger.oldMap.get(fi.Id).Visibility != 'AllUsers' ) {
    			 	    publicUpdCases.add(fi.ParentId);    			 			      	
    			 	    addPublicPostLog(fi);
    			 }
    		}
    	}
    	
    	insertFeedLogs();
    	updateCases();     	     	
     }
     
     if (Trigger.isDelete) {
     	    
     	 List<User> usr = [SELECT Profile.Name FROM User WHERE id = :UserInfo.getUserId()];   	 
     	 if ( !usr.isEmpty() && usr[0].Profile.Name == 'System Administrator') 
     	    return; 
     	
     	for ( FeedItem fi : Trigger.Old )  {
     		if ( fi.ParentId.getSObjectType().getDescribe().getName() == 'Case' && (fi.Type == 'TextPost' || fi.Type == 'LinkPost') )
     		
     		fi.addError('Post cannot be deleted');
     	}    	
     }
     
     private void insertFeedLogs() {
     	if ( plogs.isEmpty() )
     	   return;
     	   
     	try {	     	
	     	  insert plogs;
     	}
     	catch(Exception ex) {
     	   ErrorLogUtil.insertLog('FeedItem_CasePost trigger', 'Error inserting into Case_FeedPost_Log__c ' + ex.getMessage(), 
     	                                                                                      'FeedItem_CasePost.insertFeedLogs');
     	}     	
     	return;
     }
     
     private void updateCases() {
     	if ( publicUpdCases.isEmpty() && privateUpdCases.isEmpty() )
     	   return;
     	
     	ID userId = UserInfo.getUserId(); 
     	  
     	Set<ID> allCaseIDs = new Set<ID>();
     	allCaseIDs.addAll(publicUpdCases);
     	allCaseIDs.addAll(privateUpdCases);
     	
     	List<Case> casesToUpdate = new List<Case> ();
     	
     	List<Case> cases = [SELECT Id, First_Response_Timestamp__c, New_Updates__c, Priority, OwnerId, RecordType.Name     	                           
     	                    FROM Case WHERE Id = :allCaseIDs];
     	
     	for ( Case cs: cases ) {   	     		
     		// if update not made by the owner, 
     		if ( cs.OwnerId != userId && !cs.New_Updates__c ) {  			
     		    cs.New_Updates__c = true;
     		}    
     		// if update is public check for the First_Response_Timestamp__c
     		if ( cs.First_Response_Timestamp__c == null && publicUpdCases.contains(cs.Id) && !ContactUtil.isPortalUser() )  {
     		   cs.First_Response_Timestamp__c = System.now(); 
     		   cs.Last_Priority_FirstResponse__c = cs.Priority; 
     		} 
     		/// set Last Public Update timestamp, Description used in reports
     		if ( publicUpdCases.contains(cs.Id) && !ContactUtil.isPortalUser() ) {
     			cs.Last_Public_Care_Update__c = System.now(); 
     			
     			///do not update if Feature Request
     			if ( ! cs.RecordType.Name.contains('Feature') )  			
     				cs.Last_Public_Case_Update_Description__c = caseIdPublicUpdate.get(cs.Id);
     		}
     		else {
     		 /// to force reset Last Updated system fields 
     		   cs.Last_Private_Care_Update__c = system.now();
     		}
     		
     		casesToUpdate.add(cs);    		  		
     	}
     	
     	try {
	     	if ( !casesToUpdate.isEmpty() )
	     	  update casesToUpdate;
     	}
     	catch(Exception ex) {
     	   ErrorLogUtil.insertLog('FeedItem_CasePost trigger', 'Error updating Case(s) ' + ex.getMessage(), 
     	                                                                                      'FeedItem_CasePost.updateCases');
     	}  
     	   	
     	return;    	
     }
     
     private void addPublicPostLog (FeedItem fi) {
     	
     	 CaseMgmtEmailingService.CaseEmailRecipient recipts = new CaseMgmtEmailingService.CaseEmailRecipient(fi.ParentId);
     	
     	try {
     		
	     	Case_FeedPost_Log__c pl = new Case_FeedPost_Log__c();
	     	
	     	pl.Case_Contact_Email__c = recipts.ContactAddr.size() > 0 ? recipts.ContactAddr[0] : '';
 
            for ( Integer n=0; recipts.ExternalDistrAddrList.size() > n && n < 10; n++ )	{       
            	String fname = 'External_EmailAddr_' + String.valueOf(n+1) + '__c';   
                pl.put(fname, recipts.ExternalDistrAddrList[n]);
          
            }
            for ( Integer n=0; recipts.InternalDistribAddrList.size() > n && n < 10; n++ )	{ 
     
    	       String fname = 'Internal_EmailAddr_' + String.valueOf(n+1) + '__c';             	
               pl.put(fname, recipts.InternalDistribAddrList[n]);
            }
	     		     	
	     	pl.FeedPost_ID__c = fi.Id;
	     	pl.Case__c = fi.ParentId; 
	     	pl.FeedPost__c = fi.Body;
	     	pl.isAutoFollowUp__c = fi.Title == 'Auto-Follow Up' ? true : false;
	     		     	
	     	plogs.add(pl);
     	}
     	catch(Exception ex) {
     	   ErrorLogUtil.insertLog('FeedItem_CasePost trigger', 'Error adding new Case_FeedPost_Log__c ' + ex.getMessage(), 
     	                                                                                      'FeedItem_CasePost.addPublicPostLog');
     	}  
     	
     }
         
}