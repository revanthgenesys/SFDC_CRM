trigger ContentRating on ContentVersion (after Update) {

    System.debug('');
    
    List<Favorite_Content__c> favContentList = new List<Favorite_Content__c>();
    User usr = [Select Id,name FROM User WHERE Id =: UserInfo.getUserId()];
    
    for(ContentVersion contentNew : Trigger.new){

        ContentVersion contentOld = Trigger.oldMap.get(contentNew.Id);
        
        String contentId = contentNew.Id;
        String userId = usr.Id;
        
        
        if(contentNew.PositiveRatingCount > contentOld.PositiveRatingCount){
            
            favContentList.add(new Favorite_Content__c(
            
                CurrencyIsoCode = 'USD',
                User_Id__c = userId,
                Content_Version_Id__c = contentId,
                RatingCount__c = 'Positive Rating Count'
                ));
                
        }
        if(contentNew.NegativeRatingCount > contentOld.NegativeRatingCount){

            favContentList.add(new Favorite_Content__c(
            
                CurrencyIsoCode = 'USD',
                User_Id__c = userId,
                Content_Version_Id__c = contentId,
                RatingCount__c = 'Negative Rating Count'
                ));
                
        }
        
        List<Favorite_Content__c> favContentOldList = new List<Favorite_Content__c>([SELECT Id FROM Favorite_Content__c WHERE 
            User_Id__c =: userId AND Content_Version_Id__c =: contentId]);
        if(favContentOldList != null){
            delete favContentOldList;
        }
        
        
    }
    insert favContentList;  
}