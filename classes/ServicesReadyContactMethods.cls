/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
public without sharing class ServicesReadyContactMethods{
    
    public ServicesReadyContactMethods(Contact con) {
        cont = con;
    }
    
    List<ServicesReadyContactPermission__c> servicesPermissions = ServicesReadyContactPermission__c.getAll().values();
    
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
            if (cont.Contact_ID__c == null || cont.Contact_ID__c == '')
            {
                errorMessage += CREATE_NO_CONTACTID_ERR_MSG;
            }
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
                    return response;
                }
                
                response = CREATE_SUCCESS;
                System.debug('After webservice call, Response: ' + response);
            }
        }
        catch (Exception e)
        {         
            response = String.format(CREATE_EXC_ERR_MSG, new string [] { e.getMessage(), e.getStackTraceString() });
            System.debug(LoggingLevel.ERROR, response);
            return response;
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
    
    public void UpdateAccountPermissions(Id accountId)
    {
        Account acc = [SELECT Ldap_Account_Permissions__c FROM Account WHERE Id =: accountId];
        System.Debug('Account Found for permissions Update: ' + acc);
        SetPermissions(acc);
        update acc;
    }
    
    public void SetPermissions(Account acc)
    {
        // Adds the needed account level permissions to make the account "services ready"
        
        if (String.IsBlank(acc.Ldap_Account_Permissions__c))
        {
            acc.Ldap_Account_Permissions__c = 'AccountAccess;SupportAccess';
        }
        else
        {
            Set<String> perms = new Set<String>(acc.Ldap_Account_Permissions__c.split(';'));
            if (!perms.contains('AccountAccess') || !perms.contains('SupportAccess'))
            {                
                perms.add('AccountAccess');
                perms.add('SupportAccess');
                acc.Ldap_Account_Permissions__c = String.join(new List<string>(perms), ';');
            }
        }
        System.debug('Ldap_Account_Permissions__c: ' + acc.Ldap_Account_Permissions__c);
    }
    
    public void SetPermissionsAndUpdate()
    {
        if (servicesPermissions.size() > 0)
        {
            Set<string> permSettings = new Set<String>();
            for (ServicesReadyContactPermission__c sp : servicesPermissions)
            {
                permSettings.add(sp.Name);
            }
            // Adds the needed contact permissions to make the Contact "services ready"        
            if (String.isBlank(cont.Ldap_Contact_Permissions__c))
            {
                cont.Ldap_Contact_Permissions__c = String.join(new List<string>(permSettings), ';');
            }
            else
            {
                Set<String> perms = new Set<String>(cont.Ldap_Contact_Permissions__c.split(';'));
                perms.addAll(permSettings);
                cont.Ldap_Contact_Permissions__c = String.join(new List<string>(perms), ';');
            }
            System.debug('Contact ready for Permission Update: ' + cont);
            Update cont;
        }
        else
        {
      System.debug('NO PERMISSIONS SET IN CUSTOM SETTINGS.');            
        }
    }
    
    public string GetContactPermissions()
    {
        string perms = '';
        if (servicesPermissions.size() > 0)
        {
            Set<string> permSettings = new Set<String>();
            for (ServicesReadyContactPermission__c sp : servicesPermissions)
            {
                permSettings.add(sp.Name);
            }
            
            perms = String.join(new List<string>(permSettings), ';');
        }
        else
        {
      System.debug('NO PERMISSIONS SET IN CUSTOM SETTINGS.');            
        }
        return perms;
    }
}