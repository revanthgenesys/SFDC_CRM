public with sharing class SupportAccessUtil {
   
     public static void disableEnablePartnerPortal(List<Contact> newList, Map<Id, Contact> oldMap){
        Set<Id> contSetEnable = new Set<Id>();
        Set<Id> contSetDisable = new Set<Id>();
        
        for(Contact eachContact : newList){
            if(eachContact.Status__c == 'Inactive' && (oldMap.get(eachContact.id).Status__c == 'Active' || oldMap.get(eachContact.id).Status__c == null || oldMap.get(eachContact.id).Status__c == ''))
                contSetDisable.add(eachContact.id);
            
            if(eachContact.Status__c == 'Active' && (oldMap.get(eachContact.id).Status__c == 'Inactive' || oldMap.get(eachContact.id).Status__c == null || oldMap.get(eachContact.id).Status__c == ''))
                contSetEnable.add(eachContact.id);
                
        }
        if(!contSetDisable.isEmpty()){
            updateUserFuture(contSetDisable, false);
        }
        if(!contSetEnable.isEmpty()){
            updateUserFuture(contSetEnable, true);
        }
        
    }
     
    @future
    private static void updateUserFuture(Set<Id> contactsNotHavingSA, Boolean enable){
        System.debug('NKC debug enable ['+enable+']');
        List<User> usersToBeUpdated = [SELECT id FROM User WHERE ContactId IN : contactsNotHavingSA];
        if(!usersToBeUpdated.isEmpty()){
            for(User eachUser : usersToBeUpdated) {
                eachUser.isActive = enable;
                eachUser.IsPortalEnabled = enable;
            }
            
            update usersToBeUpdated;
        }       
    }
    @future
    private static void updateUserProfileFuture(Map<Id,Id> contactIdVsProfileId){
        System.debug('NKC debug contactIdVsProfileId ['+contactIdVsProfileId+']');
        List<User> users = [SELECT id, profileId, contactId FROM User WHERE ContactId IN : contactIdVsProfileId.keyset()];
        List<User> usersToBeUpdated = new List<User>();
        if(!users.isEmpty()){
            for(User eachUser : users){
                if(eachUser.profileId != contactIdVsProfileId.get(eachUser.contactId)){
                    eachUser.profileId = contactIdVsProfileId.get(eachUser.contactId);
                    usersToBeUpdated.add(eachUser); 
                }               
            }
            if(!usersToBeUpdated.isEmpty())
                update usersToBeUpdated;
        }       
    }
    
    
    public static void setSupportAccessFields (List<Support_Access__c> newSAList) {
        for ( Support_Access__c sa : newSAList ) {
           if ( sa.Back_Office_Account__c != null )  {
              List<Back_Office_Account__c> boa = [SELECT End_User_Account__c, Sold_To_Account__c
                                                    FROM Back_Office_Account__c WHERE Id = :sa.Back_Office_Account__c];
              if ( !boa.isEmpty() ) {
                 sa.End_User_Account__c = boa[0].End_User_Account__c;
                 sa.Sold_To_Account__c = boa[0].Sold_To_Account__c;
                 sa.Unique_Boa_Contact_Combination__c = (Id) boa[0].Id + '_' + (Id) sa.Contact__c;
              }
           }
        }
    }    

}