global class CaseAddFeedItemInvocable {

/* Used in process flow
  only needed because process does not allow to set post visibility

*/	
	@InvocableMethod(label='Post to Case')
	global static void feedPostToCase(List<PostRequest> req) {
	    addPost(req);
	}
	
	global class PostRequest {
		
		@InvocableVariable(required=true label='CaseId' )
		global ID caseId;
		
		@InvocableVariable(required=true label='isPostPublic' )
		global Boolean isPublic = false;
		
		@InvocableVariable(required=true label='Post Body' )
		global String postBody;		
	}
	
	public static void addPost (List<PostRequest> req)  {
		
       try {
			  FeedItem fdi = new FeedItem();
		      fdi.Body = req[0].postBody;
		      fdi.ParentId = req[0].caseId;
		      
		      if ( req[0].isPublic )
		   		  fdi.Visibility = 'AllUsers';
		   	  else
	              fdi.Visibility = 'InternalUsers';
	                            
		      insert fdi;	
		}
		catch (Exception ex) {
		   ErrorLogUtil.insertLog('CaseAddFeedItemInvocable', 'Error saving Case Post ' +  req[0].caseId +
			                       '  ' + ex.getMessage(),  'CaseAddFeedItemInvocable.addPost');     
    		return;
		} 
	}
    
}