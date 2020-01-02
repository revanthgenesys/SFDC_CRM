/*
Naresh K    05/27/2013
Modified By:        Swastika Rajkhowa(Rsystems)
Modified Date:      22/Apr/2016
Reason:             a.       When account status is changed to inactive from active.   It should change status of all contacts and any portal user tied to that contact to inactive.   
                    b.      Will be bit tricky because some accounts have 200+ contacts.   
                    c.       Also put a condition in trigger that this happens only for user who has Bulk Inactivation checkbox checked on user record (Create this field as checkbox)   
  
*/
public with sharing class ValidateAccountUpdate {
    public static void validateAccountForInactiveStatus(Map<Id,Account> newMap, Map<Id,Account> oldMap){
        //Set<Id> recordTypeIds = new Set<Id>();
        Set<Id> accIds = new Set<Id>();
        for(Account eachAccount : newMap.values()){
            if(eachAccount.Status__c == 'Inactive' && eachAccount.Status__c != oldMap.get(eachAccount.id).Status__c && eachAccount.Type=='Partner')
                accIds.add(eachAccount.id);
        }
        
        if(accIds.isEmpty()) return;
        
        //Set for Contact --Created by Swastika(Rsystems)
        Set<Id> set_ContactIds = new Set<Id>();        
        //List for Contact users --Created by Swastika(Rsystems)
        List<User> list_Portalusers = new List<User>();
        Map<Id,User>map_PortalUsers;
        Set<id>set_Users = new Set<id>();        
        //for(RecordType eachRecordType : [SELECT id FROM RecordType WHERE SobjectType = 'Account' AND Name LIKE 'Group Account%'])
        //  recordTypeIds.add(eachRecordType.id);
        
        User usr = [SELECT Profile.Name FROM USER WHERE Id =: UserInfo.getUserId()];        
        List<Contact> contacts = [SELECT AccountId FROM Contact WHERE AccountId IN : accIds];
        List<Account> accounts = [SELECT ParentId FROM Account WHERE ParentId IN : accIds];
        
        for(Account eachAccount : accounts){
            newMap.get(eachAccount.parentId).addError('The account can not be deactivated as long as it has active legal entities.');
        } 
        
        for(Contact eachContact : contacts){
            if(usr.Profile.Name == 'System Administrator'){
                eachContact.Status__c = 'Inactive';                             
                set_ContactIds.add(eachContact.Id);  //added by swastika (Rsystems) to add the inactive contacts 
            }
            else{
                newMap.get(eachContact.AccountId).addError('The account can not be deactivated as long as it has active contacts.');
            }
        } 
        
        //Added by Swastika (Rsystems) to find the portal user and inactive the portal users<Start>
        if(set_ContactIds.size()>0)
        {
           map_PortalUsers = new Map<ID, User>([SELECT id, CommunityNickname, IsPortalEnabled, contactId FROM User WHERE ContactId in :set_ContactIds AND IsActive = true]);
           //map_PortalUsers = new Map<ID, User>([SELECT id, CommunityNickname, IsPortalEnabled, contactId FROM User WHERE Id=:'005U0000003qmQ2IAI']);
           set_Users = map_PortalUsers.keySet();
        } 
       
         //Added by Swastika (Rsystems) to find the portal user and inactive the portal users<End>   
        if(usr.Profile.Name == 'System Administrator')
        {
          update contacts;
          updateUser(set_Users); //added by swastika (Rsystems) to inactive portal users
        }
    }
    @future
    public static void updateUser(set<id> set_Users)
        {
            List<User>list_Users = [Select id,isActive from User where ID IN : set_Users];
            for(User obj: list_Users)
            {
              obj.IsActive = false;             
            }
            update list_Users;
        }
}