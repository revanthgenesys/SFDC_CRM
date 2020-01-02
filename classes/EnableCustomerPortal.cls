public without sharing class EnableCustomerPortal { 
    public static List<Profile> genesysPortalEndUserProfile;
    public static List<Profile> genesysPortalEndUserROProfile;
    
    public static void enablePartnerPortalForContacts(List<Contact> newList, Map<Id, Contact> oldMap){
        List<String> contactIds = new List<String>();
        List<String> contactIdsWithRO = new List<String>();
        List<String> contactDisableIds = new List<String>();        
        System.debug('NKC debug newList ['+newList+']');
        for(Contact eachContact : newList){
            System.debug('NKC debug eachContact.Designated_Contact__c ['+eachContact.Designated_Contact__c+']');
            if(eachContact.Designated_Contact__c == 'Yes' && eachContact.Designated_Contact__c != oldMap.get(eachContact.id).Designated_Contact__c)
                contactIds.add(eachContact.id);
            else if(eachContact.No_Of_Read_Only_Support_Access__c > 0 && eachContact.No_Of_Read_Only_Support_Access__c != oldMap.get(eachContact.id).No_Of_Read_Only_Support_Access__c)
                contactIdsWithRO.add(eachContact.id);       
            if(eachContact.Status__c == 'Inactive' && (eachContact.Status__c != oldMap.get(eachContact.id).Status__c)) 
                contactDisableIds.add(eachContact.id);
        }       
        System.debug('NKC debug contactIds ['+contactIds+']');
        if(!contactIds.isEmpty())
            createPortalUsers(contactIds, false);
        if(!contactIdsWithRO.isEmpty())
            createPortalUsers(contactIdsWithRO, true);
            
    } 
    private static List<Profile> getProfile(String profileName){
        Profile[] profiles = [SELECT id, Name FROM Profile WHERE Name =: profileName];
        return profiles;
    }    
    private static void createPortalUsers(List<String> contactIds, Boolean isReadOnly){   
        genesysPortalEndUserROProfile = getProfile('Genesys Portal End User - ReadOnly');
        genesysPortalEndUserProfile = getProfile('Genesys Portal End User');
        List<Profile> profiles;
        List<Contact> contacts;
        System.debug('NKC debug isReadOnly ['+isReadOnly+']');
        if(isReadOnly){         
            contacts = getDisabledContacts(contactIds, isReadOnly);
            if(!contacts.isEmpty())
                profiles = genesysPortalEndUserROProfile;
        }
        else{           
            contacts = getDisabledContacts(contactIds, isReadOnly);
            if(!contacts.isEmpty())
                profiles = genesysPortalEndUserProfile;
        }
        System.debug('NKC debug contacts [' + contacts + ']');
        List<User> usersToBeInserted = new List<User>();        
        for(Contact eachContact : contacts){
            User newUser = new User();
            newUser.Alias = eachContact.FirstName.left(1) + eachContact.LastName.left(4);
            newUser.Email = eachContact.Email;
            newUser.LastName = eachContact.LastName;
            newUser.FirstName = eachContact.FirstName;
            newUser.Username = eachContact.Email;
            newUser.ProfileId = profiles[0].id;
            newUser.ContactId = eachContact.id;
            newUser.TimeZoneSidKey='America/Los_Angeles';  
            newUser.LocaleSidKey='en_US';
            newUser.EmailEncodingKey='ISO-8859-1';
            newUser.LanguageLocaleKey = 'en_US';
            usersToBeInserted.add(newUser);         
        }       
        if(!usersToBeInserted.isEmpty()){
            insert usersToBeInserted;
            if(!Test.isRunningTest()){
                List<Portal_Password__c> userPortalPasswords = new List<Portal_Password__c>();
                for(User eachUser : usersToBeInserted){
                    String pass = getPassword(7);
                    pass += '7';
                    System.setPassword(eachUser.id, pass);
                    Portal_Password__c portalPassword = new Portal_Password__c();
                    portalPassword.username__c = eachUser.Username;
                    portalPassword.Reset__c = true;
                    portalPassword.Current_Password__c = pass;
                    userPortalPasswords.add(portalPassword);
                }
                upsert userPortalPasswords Username__c;
            }
        }
        TriggerFlowManager.CONTACT_AFTER_ENABLE_PARTNER_PORTAL = false;
    }  
    private static List<Contact> getDisabledContacts(List<String> contactIds, Boolean isReadOnly){
        Map<String, Contact> mapIdlVsContact = new Map<String, Contact>();
        Set<String> usersIds = new Set<String>();
        Set<String> usersIdsWithRO = new Set<String>();
        Set<String> usersIdsWithRW = new Set<String>();
        
        List<Contact> contacts = [SELECT Email, FirstName, LastName FROM Contact WHERE id in : contactIds];
        for(Contact eachContact : contacts){
            mapIdlVsContact.put(eachContact.id, eachContact);
        }
        List<User> users = [SELECT id, name, username, isActive, ContactId, profileId  FROM User WHERE contactId IN : mapIdlVsContact.keyset()];
        for(User eachUser : users){
            if(mapIdlVsContact.containsKey(eachUser.contactId)){
                System.debug('NKC debug eachUser ['+eachUser+']');
                if(eachUser.isActive == false){
                    usersIds.add(eachUser.id);
                }
                else{
                    if(isReadOnly && eachUser.ProfileId != genesysPortalEndUserROProfile[0].id) {
                        usersIdsWithRO.add(eachUser.id);    
                    }
                    if(!isReadOnly && eachUser.ProfileId != genesysPortalEndUserProfile[0].id)  {
                        usersIdsWithRW.add(eachUser.id);    
                    }                       
                }
                mapIdlVsContact.remove(eachUser.contactId);
            }
        }
        System.debug('NKC debug usersIds ['+usersIds+']');
        System.debug('NKC debug usersIdsWithRO ['+usersIdsWithRO+']');
        System.debug('NKC debug usersIdsWithRW ['+usersIdsWithRW+']');
        
        if(!usersIds.isEmpty())
            updateUsersFuture(usersIds, null);
        if(!usersIdsWithRO.isEmpty())
            updateUsersFuture(usersIdsWithRO, true);
        if(!usersIdsWithRW.isEmpty())
            updateUsersFuture(usersIdsWithRW, false);
        
        return mapIdlVsContact.values();
    }  
    @future
    private static void updateUsersFuture(Set<String> userIds, Boolean isReadOnly){
        List<User> usersToBeUpdated = [SELECT id, isActive, profileId FROM User WHERE ID IN : userIds];
        for(User eachUser : usersToBeUpdated){
            eachUser.IsActive = true;
            if(isReadOnly)
                eachUser.profileId = genesysPortalEndUserROProfile[0].id;
            else
                eachUser.profileId = genesysPortalEndUserProfile[0].id;
        }
        update usersToBeUpdated;
    }
    private static String getPassword(Integer len) {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);        
        return key.substring(0,len);
    }
    
}