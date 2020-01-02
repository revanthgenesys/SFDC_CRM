public without sharing class FavoritesController {
	
	public String articleId { get; set; }
	public String articleTitle { get; set; }
	public String articleSummary { get; set; }
	public String articleNumber { get; set; }
	public String articleLanguage { get; set; }
	public Favorite__c theFavorite = null;
	private String favoriteInit = null;
		
	/* get our User Id for owner identification, in case the sharing model for Favorites changes */
	public String getUserId() {
		return UserInfo.getUserId();
	}
	
	/* getTheFavorite() - return the current favorite object if we are a favorite, null otherwise.
	                      Set theFavorite value as a side effect if we start as null but actually have a favorite.
	                      Use getIsFavorite() to avoid extra calls when we are not a favorite. */
	public Favorite__c getTheFavorite() {
		if (theFavorite==null || favoriteInit!=articleId) {
			Favorite__c myFavorite = null;
			String uid = getUserId();
			if (uid!=null) {
				Favorite__c[] favs = [
					SELECT Id, Article_ID__c 
					  FROM Favorite__c
					 WHERE Owner.Id=:uid AND Article_ID__c=:articleId 
				]; 	
				if (favs.size()>0) myFavorite = favs[0];
			}
			favoriteInit = articleId;
			theFavorite = myFavorite;
		}
		return theFavorite;
	}
	
	/* getIsFavorite() - return boolean value to say if we article is a favorite or not */ 
	public Boolean getIsFavorite() {
		if (favoriteInit==articleId) return (theFavorite!=null);		
		else return (getTheFavorite()!=null);
	}
	
	/* removeFavorite() - remove a favorite
	*/
  	public void removeFavorite() {
	  	if (getIsFavorite()) {
	  		delete(theFavorite);
	  		theFavorite=null;
	  	}
  	}
  	
    /* addFavorite() - add a favorite
     */
  	public void addFavorite() {
  		if (!getIsFavorite()) {
  			Favorite__c newFav = new Favorite__c(
				Article_Number__c = articleNumber,
				Article_Id__c = articleId,
				Article_Title__c = articleTitle,
				Article_Summary__c = articleSummary,
				Article_Language__c = articleLanguage
			);
			insert(newFav);
			theFavorite=newFav;  		
	  	}
	}
	
	/* toggleFavorite() - addFavorite() or removeFavorite() as appropriate
	*/
	public void toggleFavorite() {
		if (getIsFavorite()) removeFavorite();
		else addFavorite();
	}
	

}