/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
public without sharing class ContactAPIMethods {
  public ContactAPIMethods(Contact con, string[] conPerms) {
        cont = con;
        contactPermissions = conPerms;
    }
    
    Map<string, ServicesReadyContactPermission__c> ldapPermMappings
    {
        get
        {
            if (ldapPermMappings == null)
            {
                System.debug('No existing perm mappings, creating them...');
                ldapPermMappings = new Map<String, ServicesReadyContactPermission__c>();
                for(List<ServicesReadyContactPermission__c> allmaps : [SELECT Name, Account_Permission__c FROM ServicesReadyContactPermission__c])
                {   
                    for (ServicesReadyContactPermission__c eachmap : allmaps)
                    {
                        if (!ldapPermMappings.containsKey(eachmap.Name))
                        {
                            ldapPermMappings.put(eachmap.Name, eachmap);
                        }                                                
                    }
                }                           
            }            
            return ldapPermMappings;
        }
        set;
    }
    
    private static final string CREATE_EXC_ERR_MSG = 'Web Login could not be created for this contact. Details: {0} \n and StackTrace: {1} ';
    private static final string CREATE_NO_EMAIL_ERR_MSG = 'A web login cannot be created because the contact does not have an email address.  ';
    private static final string CREATE_NO_CONTACTID_ERR_MSG = 'A web login cannot be created because the contact does not have a ContactId.  It may not yet be synced, so please try again in a few minutes.  ';
    private static final string CREATE_SUCCESS = 'A web login was created successfully.  ';
    private static final string CREATE_EXIST_LOGIN_ERR_MSG = 'A web login cannot be created because a web login already exists for this contact.  ';
    private static final string CREATE_EXC_AFTER_WEBSVC_ERR_MSG = 'An error occurred following the login creation but prior to the record update.  Details:  {0}   ';
    private static final string CREATE_DUPLICATE_EMAIL_ERR_MSG = 'A web login cannot be created because the contact does not have an email address.  ';
    private static final string CREATE_QUEUE_SUCCESS = 'The contact is Successfully added to the Create Login Queue to be processed by the Batch Job. ';
    private static final string CREATE_QUEUE_EXC_ERR_MSG = 'There was an error while adding the contact to the Create Login Queue to be processed by the Batch Job. Error Message: {0}. Stack Trace: {1} ';
        
    private static final string callingApplication = Utility.IsSandboxEnvironment() ? 'Salesforce-Dev' : 'Salesforce';  
    private Contact cont;
    private String[] contactPermissions;
    
    // Calls the PublicAPI using ININPortalUser class to Create the Login
    public string CreateLogin()
    {
        string response;        
        try
        {
            string errorMessage = '';
            
            if (cont.Has_LDAP_Login__c == true) 
            {
                errorMessage += CREATE_EXIST_LOGIN_ERR_MSG;
            }            
            if (cont.Email == null || cont.Email == '')
            {
                errorMessage += CREATE_NO_EMAIL_ERR_MSG;
            }
            /* Ignoring Contact_ID (BCF ID) per request INC0285608 since it is not needed for ISupport in merged instance.           
            'if (cont.Contact_ID__c == null || cont.Contact_ID__c == '')
            '{
            '    errorMessage += CREATE_NO_CONTACTID_ERR_MSG;
            '} */
            if (errorMessage != '')
            {
                System.debug('Error msg/Response: ' + errorMessage);
                response = errorMessage;
            }
            else
            {  
                try
                {   
                    // Add to Azure Queue 
                    LdapManagement ldap = new LdapManagement();
                    ldap.CreateLogin(cont.Id);           
                    system.debug('After Update Contact: ' + cont);
                }
                catch (Exception e)
                {
                    response = String.format(CREATE_EXC_AFTER_WEBSVC_ERR_MSG, new string[] { e.getMessage() });
                    System.debug(LoggingLevel.ERROR, errorMessage);
                    throw new ApplicationException(String.format(CREATE_EXC_AFTER_WEBSVC_ERR_MSG, new string[] { e.getMessage() }));
                    return 'Error: ' + response;
                }
                
                response = CREATE_SUCCESS;
                System.debug('After webservice call, Response: ' + response);
            }
        }
        catch (Exception e)
        {         
            response = String.format(CREATE_EXC_ERR_MSG, new string [] { e.getMessage(), e.getStackTraceString() });
            System.debug(LoggingLevel.ERROR, response);
            return 'Error: ' + response;
        }
        System.debug('Response String: ' + response);
        return response;
    }
    
    public string AsyncCreateLogin()
    {
        string Response;
        //Add/Update the Contact Details into the CreateLoginQueue object, to process them using a Scheduled Batch Job   
        Response = InsertOrUpdateContactQueue(cont.Id);                
        return Response;
    }
    
    public string InsertOrUpdateContactQueue(Id contId)
    {
        string Response;
        try
        {
            system.debug('InsertOrUpdateContactQueue called for Contact: ' + contId);
            List<CreateLoginQueue__c> conQueue = [SELECT Id,ContactId__c,Result__c,IsProcessed__c,IsError__c FROM CreateLoginQueue__c WHERE ContactId__c =: contId LIMIT 1];
            system.debug('contact list Object returned from the CreateQueue: ' + conQueue + ' Count: ' + conQueue.size());
            if(conQueue!= null && conQueue.size() > 0)
            {
                system.debug('Previous Result value of conQueue: ' + conQueue[0].Result__c);
                conQueue[0].Result__c = null;
                conQueue[0].IsProcessed__c = false;
                conQueue[0].IsError__c = false;
                Update conQueue;            
            }
            else
            {
                CreateLoginQueue__c queueEntry = new CreateLoginQueue__c();
                queueEntry.ContactId__c = cont.Id;
                system.debug('Row entered for the Contact into CreateLoginQueue__c: ' + queueEntry);
                Insert queueEntry;
            }
            Response = CREATE_QUEUE_SUCCESS;
        }
        catch(Exception e)
        {
            response =  String.format(CREATE_QUEUE_EXC_ERR_MSG, new string [] { e.getMessage(), e.getStackTraceString() });           
        }
        return Response;            
    }
    
    private void UpdateAccountPermissions()
    {
        Account acc = [SELECT Ldap_Account_Permissions__c FROM Account WHERE Id =: cont.AccountId];
        System.Debug('Account Found for permissions Update: ' + acc);
        
        SetPermissions(acc);
        update acc;
    }
    
    private void SetPermissions(Account acc)
    {
        ServicesReadyContactPermission__c permMap;        
        Set<String> perms;
        
        if(String.isNotBlank(acc.Ldap_Account_Permissions__c))
        {
            System.debug('Existing ldap_account_permissions...');
            perms = new Set<String>(acc.Ldap_Account_Permissions__c.split(';'));
        }
        else{
            System.debug('NO existing ldap_account_permissions...');
            perms = new Set<String>();
        }
            
        for (string contactPerm : contactPermissions)
        {
            permMap = ldapPermMappings.get(contactPerm);
            System.debug('Adding permission: ' + contactPerm + ' with permMap: ' + permMap);
            if(permMap != null && string.isNotBlank(permMap.Account_Permission__c))
            {
                if (!perms.contains(permMap.Account_Permission__c))
                { 
                    System.debug('Adding ' + permMap.Account_Permission__c + ' to the account permissions.');
                    perms.add(permMap.Account_Permission__c);
                }
            }
        }   
        acc.Ldap_Account_Permissions__c = String.join(new List<string>(perms), ';');
                
        System.debug('Ldap_Account_Permissions__c: ' + acc.Ldap_Account_Permissions__c);
    }
    
    public void GrantPermissions()
    {
        if (ldapPermMappings.size() > 0)
        {
            System.debug('ldapPermMappings.size > 0');               
            // Adds the required Account permission inorder to grant Contact Permission
            UpdateAccountPermissions();
        } 
        // Adds the needed contact permissions      
        if (String.isBlank(cont.Ldap_Contact_Permissions__c))
        {
            System.debug('ldap_contact_permissions blank');
            cont.Ldap_Contact_Permissions__c = String.join(new List<string>(contactPermissions), ';');
        }
        else
        {
            System.debug('existing ldap_contact_permissions, adding new ones...');
            Set<String> perms = new Set<String>(cont.Ldap_Contact_Permissions__c.split(';'));
            perms.addAll(contactPermissions);                
            cont.Ldap_Contact_Permissions__c = String.join(new List<string>(perms), ';');
        }            
        System.debug('Contact ready for Permission Update: ' + cont);
        Update cont;       
    }
    
    public void RevokePermissions()
    { 
        // Adds the needed contact permissions      
        if (String.isNotBlank(cont.Ldap_Contact_Permissions__c))
        {
            System.debug('Contact has permissions: ' + cont.Ldap_Contact_Permissions__c);
            Set<String> perms = new Set<String>(cont.Ldap_Contact_Permissions__c.split(';'));
            boolean hadPermissions = false;
            for (string contactPerm : contactPermissions)
            {         
                System.debug('Checking to remove permission: ' + contactPerm);       
                if (perms.contains(contactPerm))
                { 
                    System.debug('Removing permission: ' + contactPerm);
                    perms.remove(contactPerm);
                    hadPermissions = true;
                }
            }
            if(hadPermissions)
            {
                cont.Ldap_Contact_Permissions__c = String.join(new List<string>(perms), ';');
                System.debug('Contact ready for permission(s) removal: ' + cont);
                Update cont;
                System.debug('Contact permissions after removal: ' + cont.Ldap_Contact_Permissions__c);
            }
            else
            {
                System.debug('The contact did not have the permissions marked for revoke.');
            } 
        }
        else
        {
            System.debug('The contact did not have any permissions to revoke.');
        } 
    }
}