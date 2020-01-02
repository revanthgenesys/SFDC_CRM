//Naresh Kumar  01/15/2014
public without sharing class CreateUserForPortalApplicationHandler {
    
    public static void processRequests(List<Partner_User_Request__c> newList, Map<Id, Partner_User_Request__c> oldMap){
        
        system.debug('Processing User Creation');
        
        
        List<Partner_User_Request__c> requestsToBeProcessed = new List<Partner_User_Request__c>();
        Map<Id,Boolean> userAppCheck = new Map<Id,Boolean>();
        Map<Id,String> contactPortalAccessMap = new Map<Id,String>();
        
        for(Partner_User_Request__c eachPUR : newList){
            if(eachPUR.Status__c == 'Approved' && oldMap.get(eachPUR.id).Status__c != 'Approved'){
                if(eachPUR.Partner_Portal_Access__c !=null){
                    requestsToBeProcessed.add(eachPUR);
                }else{
                    eachPUR.addError('Please select Partner Portal Access.');
                    return;
                }
            }
        }
        
        List<Account> accountsToBeInserted = new List<Account>();
        List<Contact> contactsToBeInserted = new List<Contact>();
        List<User> usersToBeInserted = new List<User>();
        Map<String, Contact> mapPURIdVsContact = new Map<String, Contact>();
        
        for(Partner_User_Request__c eachPUR : requestsToBeProcessed){
            if(eachPUR.Create_New_Account__c){
                accountsToBeInserted.add(getAccount(eachPUR));
            }           
        }      
        
        if(!accountsToBeInserted.isEmpty())
            insert accountsToBeInserted;
        
        Map<String, Account> mapAccNameNewVsAccount = new Map<String, Account>(); 
        for(Account eachAccount : accountsToBeInserted){
            String key = eachAccount.Name + eachAccount.Country__c;
            mapAccNameNewVsAccount.put(key, eachAccount);
        }
        
        for(Partner_User_Request__c eachPUR : requestsToBeProcessed){
                                    
            if(eachPUR.Create_New_Contact__c){
                Account accountToUse;
                if(!eachPUR.Create_New_Account__c)
                    accountToUse = new Account( id = eachPUR.Duplicate_Account__c );
                else{
                    String key = eachPUR.Company_Name__c + eachPUR.Country__c;
                    accountToUse = mapAccNameNewVsAccount.get(key);
                }
                
                Contact newContact = getContact(eachPUR, accountToUse);
                contactsToBeInserted.add(newContact);
                mapPURIdVsContact.put(eachPUR.id, newContact);
            }           
        } 
              

        if(!contactsToBeInserted.isEmpty()){
            insert contactsToBeInserted;
        }
        
        List<String> contactIds = new List<String>();
        Set<String> emails = new Set<String>();
        List<String> firstNames = new List<String>();
        List<String> lastNames = new List<String>();
        Set<String> existingEmailsPP = new Set<String>();
        Set<String> existingEmailsGP = new Set<String>();       
        List<String> profileIds = new List<String>();
        Map<String,String> portalAccessMap = new  Map<String,String>(); 
        
        for(Partner_User_Request__c eachPUR : requestsToBeProcessed){
            if(eachPUR.Request_Type__c == PartnerPortalUtil.PARTNER_REQUEST_APPLICATION_SUBMISSION){
              existingEmailsPP.add(eachPUR.Email__c);   
            }      
            else if(eachPUR.Request_Type__c == PartnerPortalUtil.PARTNER_REQUEST_PARTNER_CREATION){
             existingEmailsGP.add(eachPUR.Email__c);    
            }
            portalAccessMap.put(eachPUR.email__c , eachPUR.Partner_Portal_Access__c);            
        }
        
        
        //Searching for Potential Parter existing user
        List<User> existingUserPP = [SELECT id, isActive, email, Contact.AccountId FROM User WHERE Email IN : existingEmailsPP AND Profile.Name =: PartnerPortalUtil.POTENTIAL_PARTNER_PROFILE_NAME];
        Map<String, User> mapEmailVsExistingUserPP = new Map<String, User>();
        for(User eachUser : existingUserPP)
            mapEmailVsExistingUserPP.put(eachUser.Email, eachUser);
            
        //Searching for Gold Partner existing user
        List<User> existingUserGP = [SELECT id, isActive, email, Contact.AccountId FROM User WHERE Email IN : existingEmailsGP AND Profile.Name =: PartnerPortalUtil.GOLD_PARTNER_PROFILE_NAME];
        Map<String, User> mapEmailVsExistingUserGP = new Map<String, User>();
        for(User eachUser : existingUserGP)
            mapEmailVsExistingUserGP.put(eachUser.Email, eachUser);
        
        List<User> existingUserCP = [SELECT id, isActive, email, Contact.AccountId FROM User WHERE ( Email IN : existingEmailsPP or Email IN : existingEmailsGP) AND (Profile.Name =: PartnerPortalUtil.CUSTOMER_PORTAL_ENDUSER or Profile.Name =: PartnerPortalUtil.CUSTOMER_PORTAL_ENDUSER_RO or Profile.Name =: PartnerPortalUtil.CUSTOMER_PORTAL_ENDUSER_NA or Profile.Name =:PartnerPortalUtil.MARKETING_PORTAL_PROFILE)];
        Map<String, User> mapEmailVsExistingUserCP = new Map<String, User>();
        for(User eachUser : existingUserCP)
            mapEmailVsExistingUserCP.put(eachUser.Email, eachUser);
            
        System.debug('Existing Portal User List Size: '+mapEmailVsExistingUserCP.size());
        
        List<Profile> userProfiles = [SELECT id, Name FROM Profile WHERE Name =: PartnerPortalUtil.POTENTIAL_PARTNER_PROFILE_NAME OR Name =: PartnerPortalUtil.GOLD_PARTNER_PROFILE_NAME];
        Profile potentialPartnerProfile;
        Profile customerPortalEndUserProfile;
        for(Profile eachProfile : userProfiles){
          if(eachProfile.Name == PartnerPortalUtil.POTENTIAL_PARTNER_PROFILE_NAME)
                 potentialPartnerProfile = eachProfile;
            else if(eachProfile.Name == PartnerPortalUtil.GOLD_PARTNER_PROFILE_NAME)
                 customerPortalEndUserProfile = eachProfile;
           }     
                    
        for(Partner_User_Request__c eachPUR : requestsToBeProcessed){       
            if((mapEmailVsExistingUserPP.get(eachPUR.Email__c) != null || mapEmailVsExistingUserGP.get(eachPUR.Email__c) != null))
                continue;
            Id contactId;
            if(!mapEmailVsExistingUserCP.containsKey(eachPUR.Email__c)){
                if(!eachPUR.Create_New_Contact__c){
                    contactId = eachPUR.Duplicate_Contact__c;
                }
                else {
                    contactId = mapPURIdVsContact.get(eachPUR.id).id;
             }
                        
            userAppCheck.put(contactId,eachPUR.Show_Partner_Application__c);
            contactIds.add(contactId);
            emails.add(eachPUR.Email__c);
            firstNames.add(eachPUR.First_Name__c);
            lastNames.add(eachPUR.Last_Name__c);
            contactPortalAccessMap.put(contactId,eachPUR.Partner_Portal_Access__c);
                      
            if(eachPUR.Partner_Portal_Access__c == PartnerPortalUtil.PER_NEW_USER_PROFILE )
                profileIds.add(potentialPartnerProfile.id);
            else if(eachPUR.Partner_Portal_Access__c == PartnerPortalUtil.PER_FULL_USER_PROFILE)
               profileIds.add(customerPortalEndUserProfile.id);
           }
        }         
        
        //New User(s)
        if(!contactIds.isEmpty()){          
            List<String> emailList = new List<String>();
            emailList.addAll(emails); 
            
            // Genesys Portal End user 
            createUsers(contactIds, emailList, firstNames, lastNames, profileIds,userAppCheck,contactPortalAccessMap,requestsToBeProcessed);
        }
        
        //Existing User(s), Potential Partner - Reapplying 
        List<Account> accountsToBeUpdated = new List<Account>();
        List<Id> userIdsToBeActivated = new List<Id>();
        List<Id> customerPortalUsers = new List<Id>();
        
        for(User eachUser : mapEmailVsExistingUserPP.values()){
            Account accountToBeUpdate = new Account( id = eachUser.Contact.AccountId, Approval_Status__c = 'Reapplying for Partner' );
            accountsToBeUpdated.add(accountToBeUpdate);
            if(!mapEmailVsExistingUserCP.containsKey(eachUser.Email)){
                userIdsToBeActivated.add(eachUser.id);
            }
        }
        
        //Existing User(s), Gold Partner
        for(User eachUser : mapEmailVsExistingUserGP.values()){
           if(!mapEmailVsExistingUserCP.containsKey(eachUser.Email)){
            userIdsToBeActivated.add(eachUser.id);
           }
        }
                
        /*if(!userIdsToBeActivated.isEmpty()){
           activeExistingUsers(userIdsToBeActivated);
        }*/
                
        
        // Add existing customer portal users to permission set
        for(User eachUser : mapEmailVsExistingUserCP.values()){
           System.debug('Adding permissions to Customer Portal User Id:'+eachUser.id);
           customerPortalUsers.add(eachUser.id);
        }      
        
        system.debug('----------------------------------------customerPortalUsers--------------------------------------------------'+customerPortalUsers);       
       
        if(!customerPortalUsers.isEmpty()){
           addCustomerPortalUsers(customerPortalUsers,PartnerPortalUtil.PARTNER_PORTAL_PERMISSIONSET_ID,PartnerPortalUtil.PARTNER_POTENTIAL_PERMISSIONSET_ID,PartnerPortalUtil.PARTNER_PORTAL_CONTENT_PUBLICGROUP_ID,portalAccessMap,requestsToBeProcessed);
        } 
    }
    
      
    private static void addCustomerPortalUsers(List<Id> userIds,Id permId,Id potentialID,Id pGroupId, Map<String,String> portalAccessMap,List<Partner_User_Request__c> requestsToBeProcessed){
        
        List<User> usersToBeAdded = [SELECT Id, IsActive, ContactId, Email, UserName,FirstName,LastName,Profile.Name FROM User WHERE id IN : userIds];
        List<String> emails = new List<String>();
        List<Id> cntIdList = new List<Id>();
        List<Case> cases = new List<Case>();
        List<Id> caseIds = new List<Id>();
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Boolean isError = false;
        String htmlBody = 'Hi Admin, <br/> Following admin cases to create partner portal users have been created :' ;
        
        RecordType recordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];
        Group adminQ = [SELECT Id from Group where Name = 'Admin Case' and Type = 'Queue'];
        
        try {
            for(User eachUser : usersToBeAdded){
                cntIdList.add(eachUser.ContactId);
                emails.add(eachUser.Email);
            }
        
            List<Contact> cntList = [SELECT Id,Name,Email,AccountId from Contact where Id IN : cntIdList];
            for(Contact eachContact : cntList){
                contactMap.put(eachContact.Id,eachContact);
            }
                
            System.debug('Entering addCustomerPortalUsers');
        
            for(User eachUser : usersToBeAdded){
           
                String ppaccess = portalAccessMap.get(eachUser.Email);
           
                Case newCase = new Case();
                newCase.RecordTypeId = recordType.Id;
                newCase.AccountId = contactMap.get(eachUser.ContactId).AccountId;
                newCase.ContactId = eachUser.ContactId;
                newCase.Subject = 'Partner Portal: New Account Request';
                newCase.Priority = '2-High';
                newCase.Problem_Sub_Type__c = 'Request: Create Website Account';
                newCase.Sub_Type__c = 'Request: Create Website Account';
                newCase.OwnerId = adminQ.Id;
           
                if(ppaccess == PartnerPortalUtil.PER_FULL_USER_PROFILE) {
                    newCase.Description = 'Portal access approved and a matching Customer Portal User has been found. Please disable the existing user and enable a new Partner Portal User with User Profile = “Genesys Portal Partner”';
                }
                else if(ppaccess == PartnerPortalUtil.PER_NEW_USER_PROFILE) {
                    newCase.Description = 'Portal access approved and a matching Customer Portal User has been found. Please disable the existing user and enable a new Partner Portal User with User Profile = “Genesys Portal Potential Partner”';                    
                }
           
                cases.add(newCase);
            }
        
            if(!cases.isEmpty()){
                insert cases;
                                        
                for(Case eachcase : cases){ 
                    caseIds.add(eachcase.Id);
                }
                
                List<Partner_User_Request__c> purToUpdate = new List<Partner_User_Request__c>();
                for(Partner_User_Request__c eachPUR : requestsToBeProcessed) {
                    if(!caseIds.isEmpty()) {
                        purToUpdate.add(new Partner_User_Request__c(Id=eachPUR.Id,Case__c = caseIds[0]));     
                    }
                }
                
                if(!purToUpdate.isEmpty()) {
                    update purToUpdate;                                                             
                }
                
                List<Case> insertedCases = [SELECT Id,CaseNumber,Subject,Priority,Description from Case where Id IN : caseIds];
                for(Case eachcase : insertedCases){ 
                    htmlBody += '<br/><br/><b>Case Number: ' + eachcase.CaseNumber + '</b><br/>';
                    htmlBody += 'Subject: ' + eachcase.Subject + '<br/>';
                    htmlBody += 'Priority: ' + eachcase.Priority + '<br/>';
                    htmlBody += 'Description: ' + eachcase.Description + '<br/><br/>';
                    System.debug('Inserted Admin Case:'+eachcase.CaseNumber);
                }
            }
        }
 
        catch(Exception ex){
            isError = true;
            String subject = 'Error while creating admin case in the future method.';
            String htmlBody1 = 'Hi <br/><br/>';
            htmlBody1 += 'System was trying to create admin case for following user name(s) :' + emails;
            htmlBody1 += '. But it failed due to following error. <br/>';
            htmlBody1 += 'Error Details :' + ex.getMessage();            
            SendEmail.sendSingleEmail(Label.Admin_Emails, subject, htmlBody1);           
        }
        /*if(!isError)
            SendEmail.sendSingleEmail(Label.Admin_Emails, 'New Admin Case Created', htmlBody);*/
        
    }
    
    
    // Create new Partner Portal user with full partner portal access
    private static void createUsers(List<String> contactIds, List<String> emails, List<String> firstNames, 
        List<String> lastNames, List<String> profileIds , Map<Id,Boolean> userAppCheck,Map<Id,String> contactPortalAccessMap,List<Partner_User_Request__c> requestsToBeProcessed)  {
            
        Boolean isError = false;
        String htmlBody = 'Hi Admin, <br/><br/> Following admin cases to create partner portal users have been created :' ;
        List<User> disabledUsers = new List<User>();
        List<User> existingUsers = new List<User>();
        
        Map<Id,Id> disabledContactIdVsUserId = new Map<Id,Id>();
        Map<Id,Id> existingContactIdVsUserId = new Map<Id,Id>();
            
        Map<Id,Contact> contactMap = new Map<Id,Contact>();
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        List<Case> cases = new List<Case>();
        List<Id> caseIds = new List<Id>();
        RecordType recordType = [SELECT Id, Name, DeveloperName FROM RecordType WHERE SobjectType = 'Case' AND DeveloperName = 'Genesys_Admin_Case'];
        Group adminQ = [SELECT Id from Group where Name = 'Admin Case' and Type = 'Queue'];
              
        system.debug('------------inside--createusers----------');
                
        system.debug('--------profileIds---------'+profileIds);
        
        List<Contact> cntList = [SELECT Id,Name,Email,AccountId from Contact where Id IN : contactIds];
        for(Contact eachContact : cntList){
            contactMap.put(eachContact.Id,eachContact);
        }
        
        
        try{
            if(contactIds.size() > 0) {
                disabledUsers = [SELECT id, contactId FROM User WHERE IsActive=false and contactId IN :contactIds and contactId != null];
            }
                        
          
            for(User eachUser : disabledUsers) {
                disabledContactIdVsUserId.put(eachUser.contactId, eachUser.id);
                system.debug('disabled user id:'+eachUser.id); 
            }
                        

            existingUsers = [SELECT id, contactId FROM User WHERE UserName IN : emails];

            for(User eachUser : existingUsers) {
                existingContactIdVsUserId.put(eachUser.contactId, eachUser.id);
                system.debug('existing user id:'+eachUser.id);
            }
                       
            system.debug('contactIds size:'+contactIds.size()); 
                        
            for(Id contactId : contactIds){
                
                String ppaccess = contactPortalAccessMap.get(contactId);
                
                Case newCase = new Case();
                newCase.RecordTypeId = recordType.Id;
                newCase.AccountId = contactMap.get(contactId).AccountId;
                newCase.ContactId = contactId;
                newCase.Subject = 'Partner Portal: New Account Request';
                newCase.Priority = '2-High';
                newCase.Problem_Sub_Type__c = 'Request: Create Website Account';
                newCase.Sub_Type__c = 'Request: Create Website Account';
                newCase.OwnerId = adminQ.Id;
                
                if (disabledContactIdVsUserId.get(contactId) == null && existingContactIdVsUserId.get(contactId) == null) {
                    if(ppaccess == PartnerPortalUtil.PER_FULL_USER_PROFILE) {
                        newCase.Description = '“Partner Portal access approved. Please enable a new Partner Portal User with User Profile = “Genesys Portal Partner”.';
                    }
                    else if(ppaccess == PartnerPortalUtil.PER_NEW_USER_PROFILE) {
                        newCase.Description = '“Partner Portal access approved. Please enable a new Partner Portal User with User Profile = “Genesys Portal Potential Partner”.';
                    }
                }
                
                
                if(disabledContactIdVsUserId.get(contactId) != null) {
                    if(ppaccess == PartnerPortalUtil.PER_FULL_USER_PROFILE) {
                        newCase.Description = '"Partner Portal access approved and a matching INACTIVE user has been found. Please disable the existing user and enable a new Partner Portal User with User Profile = "Genesys Portal Partner". If this is already a Partner User, you don’t need to disable. Simply ensure that the user profile is set to Genesys Portal Partner and then activate the user (Active = Yes)"';
                    }
                    else if(ppaccess == PartnerPortalUtil.PER_NEW_USER_PROFILE) {
                        newCase.Description = '“Partner Portal access approved and a matching INACTIVE user has been found. Please disable the existing user and enable a new Partner Portal User with User Profile = "Genesys Portal Potential Partner". If this is already a Partner User, you don’t need to disable. Simply ensure that the user profile is set to Genesys Portal Potential Partner and then activate the user (Active = Yes)"';
                    }
                }  
                
                                 
                if(disabledContactIdVsUserId.get(contactId) == null && existingContactIdVsUserId.get(contactId) != null) {
                    if(ppaccess == PartnerPortalUtil.PER_FULL_USER_PROFILE) {
                        newCase.Description = '“Partner Portal access approved and a matching User has been found. Please disable the existing user and enable a new Partner Portal User with User Profile = “Genesys Portal Partner”. If this is already a Partner User, you don’t need to disable. Simply ensure that the user profile is set correctly and ask the user if they need their password reset.”';
                    }
                    else if(ppaccess == PartnerPortalUtil.PER_NEW_USER_PROFILE) {
                        newCase.Description = '“Partner Portal access approved and a matching User has been found. Please disable the existing user and enable a new Partner Portal User with User Profile = “Genesys Portal Potential Partner”. If this is already a Partner User, you don’t need to disable. Simply ensure that the user profile is set correctly and ask the user if they need their password reset.”';
                    }
                }      
                    
                cases.add(newCase);
            }
              
            if(!cases.isEmpty()) {
                insert cases;
                                        
                for(Case eachcase : cases){ 
                    caseIds.add(eachcase.Id);
                }
                
                List<Partner_User_Request__c> purToUpdate = new List<Partner_User_Request__c>();
                for(Partner_User_Request__c eachPUR : requestsToBeProcessed) {
                    if(!caseIds.isEmpty()) {
                        purToUpdate.add(new Partner_User_Request__c(Id=eachPUR.Id,Case__c = caseIds[0]));     
                    }
                }
                
                if(!purToUpdate.isEmpty()) {
                    update purToUpdate;                                                             
                }                                                                                                        
                
                List<Case> insertedCases = [SELECT Id,CaseNumber,Subject,Priority,Description from Case where Id IN : caseIds];
                for(Case eachcase : insertedCases){ 
                    htmlBody += '<br/><br/><b>Case Number: ' + eachcase.CaseNumber + '</b><br/>';
                    htmlBody += 'Subject: ' + eachcase.Subject + '<br/>';
                    htmlBody += 'Priority: ' + eachcase.Priority + '<br/>';
                    htmlBody += 'Description: ' + eachcase.Description + '<br/><br/>';
                    System.debug('Inserted Admin Case:'+eachcase.CaseNumber);
                }
            }

        }

        catch(Exception ex){
            isError = true;
            String subject = 'Error while creating admin case in the future method.';
            String htmlBody1 = 'Hi <br/><br/>';
            htmlBody1 += 'System was trying to create admin case for following user name(s) :' + emails;
            htmlBody1 += '. But it failed due to following error. <br/>';
            htmlBody1 += 'Error Details :' + ex.getMessage();            
            SendEmail.sendSingleEmail(Label.Admin_Emails, subject, htmlBody1);            
        }
        
        /*if(!isError)
            SendEmail.sendSingleEmail(Label.Admin_Emails, 'New Admin Case Created', htmlBody);*/
    }
    
            
    
    private static String removeBlankSpaces(String str){
        return str.replace(' ', '');
    }
    
    
    // Return Account details
    private static Account getAccount(Partner_User_Request__c eachPUR){
        Account newAccount = new Account();
        newAccount.Name = eachPUR.Company_Name__c;
        newAccount.Country__c = eachPUR.Country__c;
        Country__c cntry = [Select Id,Name from Country__c where id =:eachPUR.Country__c];
                
        if(cntry.Name == 'Canada')
        {
          newAccount.StateProvince__c ='Ontario';   
        }else if(cntry.Name == 'Australia')
        {
          newAccount.StateProvince__c = 'Victoria'; 
        }else if(cntry.Name == 'Germany')
        {
          newAccount.StateProvince__c = 'Berlin';   
        }else if(cntry.Name == 'USA')
        {
          newAccount.StateProvince__c = 'CA';   
        }else if(cntry.Name == 'China')
        {
          newAccount.StateProvince__c = 'Beijing';  
        }
        return newAccount;  
    }
    
    // Return Contact details
    private static Contact getContact(Partner_User_Request__c eachPUR, Account accountToUse){
        
        Account acnt = new Account();
        User user = new User();
        if(accountToUse != null)
        {
          acnt = [Select id,Name,OwnerId From Account where id=:accountToUse.Id];
        }
        
        If(acnt.OwnerId != null)
        {
          user = [Select id,Name,isActive from User where id =:acnt.OwnerId];
        }
        
        RecordType recType = [select Id from RecordType where Name='EMG - Customer / Prospect Contact Record Type'];
                
        Contact newContact = new Contact();
        newContact.FirstName = eachPUR.First_Name__c;
        newContact.LastName = eachPUR.Last_Name__c;     
        newContact.Email = eachPUR.Email__c;
        newContact.AccountId = accountToUse.id;
        newContact.RecordTypeId = recType.Id;
        newContact.Status__c = 'Active';
        newContact.Country__c = eachPUR.Country__c;
        if(user.IsActive)
        {
         newContact.OwnerId = acnt.OwnerID;
        }else{
        newContact.OwnerId =  PartnerPortalUtil.SALESOPS_USER_ID;   
        }
        return newContact;
    }
    
       public static String getPassword(Integer len) {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        
        System.debug(key);
        return key.substring(0,len);
       }
    
    public static void updateCreateNewFlags(List<Partner_User_Request__c> newList){
       /* for(Partner_User_Request__c eachPUR : newList){
            if(eachPUR.Duplicate_Account__c == NULL)
                eachPUR.Create_New_Account__c = true;
            if(eachPUR.Duplicate_Contact__c == NULL)
                eachPUR.Create_New_Contact__c = true;
        }   */    
    }
    
   public static String GetResourceURL(String resourceName){

            // Fetching the resource
            List<StaticResource> resourceList= [SELECT Name, NamespacePrefix, SystemModStamp FROM StaticResource WHERE Name = :resourceName];

            // Checking if the result is returned or not
            if(resourceList.size() == 1){

               // Getting namespace
               String namespace = resourceList[0].NamespacePrefix;
               // Resource URL
               return '/resource/' + resourceList[0].SystemModStamp.getTime() + '/' + (namespace != null && namespace != '' ? namespace + '__' : '') + resourceName; 
            }
            else return '';
    }
    
    private static void isExistingPartnerUser(User userDetail) {
        
    }
    
}