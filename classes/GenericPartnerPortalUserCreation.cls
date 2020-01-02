global class GenericPartnerPortalUserCreation {

    /**    
    * @Description: method to insert one contact per account whenever Account is converted to Partner Account.
    * @Param: Map of Account
    * @Return: void
    */
    webservice static String insertPartnerContactAndUser(Id accountId){
        try{
            List<Contact> conRec = [Select Id,name,email,AccountId from Contact where AccountId=:accountId AND Partner_Portal_User_Name__c=:Label.Generic_Portal_User_Email LIMIT 1];
            if(conRec==null || conRec.size()==0){
                Contact con = new Contact();
                con.LastName = 'User';
                con.FirstName = 'Portal';
                con.Email= 'genUser'+ String.valueOf(accountId).substring(8,15) + '@genesys.com';
                con.Partner_Portal_User_Name__c= Label.Generic_Portal_User_Email;
                con.AccountId = accountId;
                con.Designated_Partner_Contact__c = true;
                 
                RecordType rt = [select Id from RecordType where SobjectType='Contact' and Name='Generic Partner Portal User' limit 1];
                if(rt.Id!=null) {
                    con.RecordTypeId=rt.Id;
                }
                
                insert con;
            
                //create portal users associated to these contacts
                insertPortalUsers(con.Id,AccountId);
            }
            else if(conRec!=null && conRec.size()>0){
                List<User> userRec = [Select Id,email,contactId from User where contactId =:conRec[0].Id AND Email=:Label.Generic_Portal_User_Email LIMIT 1];
                if(userRec==null || userRec.size()==0){
                    //create portal users associated to existing Contact record
                    insertPortalUsers(conRec[0].Id,conRec[0].AccountId);
                }
                else{
                    return Label.Duplicate_Partner_User_Error_Message;
                }
            }
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        return 'OK';
    }
    
    /**    
    * @Description: future method to insert users associated to every contact and set generic password to them.
    username is setting to - genUser + Last 6 characters of AccountId + @genesys.com
    email is constant and coming from Custom Label - Generic_Portal_User_Email
    Profile should be set to - Partner Community Login New. stored in Custom Label - Generic_Portal_User_Profile
    * @Param: map of ContactId and AccountId.
    * @Return: void
    */
    @future
    public static void insertPortalUsers(Id contactId, Id accountId){
        List<User> lstUser = new List<User>();
        try{
            User userRec = new User();
            userRec.Username = 'genUser'+ String.valueOf(accountId).substring(8,15) + '@genesys.com';
            userRec.LastName = 'GenUser'+ String.valueOf(accountId).substring(8,15);
            userRec.Email= Label.Generic_Portal_User_Email;
            userRec.CommunityNickname = 'gU'+ String.valueOf(accountId).substring(8,15) +'.mc';
            userRec.ProfileId = Util.getProfileId(Label.Generic_Portal_User_Profile);
            userRec.contactId = contactId;
            userRec.isActive = true;
            userRec.Alias = 'gen' + String.valueOf(accountId).substring(13,15);
            userRec.TimeZoneSidKey = 'America/Los_Angeles';
            userRec.LocaleSidKey = 'en_US';
            userRec.EmailEncodingKey = 'UTF-8';
            userRec.LanguageLocaleKey = 'en_US';
            
            insert userRec;
            
            //System.setPassword(userRec.Id,'genesys123');
            
            User userUpdRec = [Select Id,Generic_Portal_User__c,Generic_Portal_Password_Set__c from User where Id=:userRec.Id LIMIT 1];
            userUpdRec.Generic_Portal_User__c = true;
            userUpdRec.Generic_Portal_Password_Set__c = false;
            
            update userUpdRec;
            
        }catch(Exception e){
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
    }
}