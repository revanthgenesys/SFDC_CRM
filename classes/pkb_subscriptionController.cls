public without sharing class pkb_subscriptionController {
	
	public String articleId { get; set; }
	public String articleTitle { get; set; }
	public String articleLanguage { get; set; }
	public Solution_Search_Alert__c subscription = null;
	private String subscribeInit = null;
		
	/* get our User Id for owner identification, in case the sharing model for subscribes changes */
	public String getUserId() {
		return UserInfo.getUserId();
	}
	
	/* getThesubscribe() - return the current subscribe object if we are a subscribe, null otherwise.
	                      Set thesubscribe value as a side effect if we start as null but actually have a subscribe.
	                      Use getIssubscribe() to avoid extra calls when we are not a subscribe. */
	public Solution_Search_Alert__c getThesubscribe() {
		if (subscription==null || subscribeInit!=articleId) {
			Solution_Search_Alert__c mysubscribe = null;
			String uid = getUserId();
			if (uid!=null) {
				Solution_Search_Alert__c[] subs = [
					SELECT Id, Article_ID__c 
					  FROM Solution_Search_Alert__c
					 WHERE Owner.Id=:uid AND Article_ID__c=:articleId 
				]; 	
				if (subs.size()>0) mysubscribe = subs[0];
			}
			subscribeInit = articleId;
			subscription = mysubscribe;
		}
		return subscription;
	}
	
	/* getIssubscribe() - return boolean value to say if we article is a subscribe or not */ 
	public Boolean getIssubscribe() {
		if (subscribeInit==articleId) return (subscription!=null);		
		else return (getThesubscribe()!=null);
	}
	
	/* removesubscribe() - remove a subscribe
	*/
  	public void removesubscribe() {
	  	if (getIssubscribe()) {
	  		delete(subscription);
	  		subscription=null;
	  	}
  	}
  	
    /* addsubscribe() - add a subscribe
     */
  	public void addsubscribe() {
  		if (!getIssubscribe()) {
  			
  			List<recordType> recordTypes = [Select r.SobjectType, r.Name, r.Id From RecordType r where name='Article' and SobjectType = 'Solution_Search_Alert__c'];
  			
  			if(!recordTypes.isEmpty()){
	  			Solution_Search_Alert__c newsub = new Solution_Search_Alert__c(
					User__c = userInfo.getUserId(),
					Article_Id__c = articleId,
					Article_Title__c = articleTitle,
					Article_Language__c = articleLanguage,
					Solution_Search_Alert_Preference__c = 'New And Updated Articles',
					Type__c = 'Article',
					RecordTypeId = recordTypes[0].Id
				);
				insert(newsub);
				subscription=newsub;  
  			}		
	  	}
	}
	
	/* togglesubscribe() - addsubscribe() or removesubscribe() as appropriate
	*/
	public void togglesubscribe() {
		if (getIssubscribe()) removesubscribe();
		else addsubscribe();
	}
	

}