/*  Migrated from WebLoginContactController to use the LDAP solution instead
By: Chris Derrig
Date: 2013-10-21
*/

public class LDAPLoginContactControllerExtension{

    private Contact cont;
    private Integer recheckCount = 0;
    public static final Integer maxRecheckCount = 6;
    private static final string callingApplication = Utility.IsSandboxEnvironment() ? 'Salesforce-Dev' : 'Salesforce'; 
    
    private static final string REQUESTED_LDAP_COMMAND = 'An update to this login has been requested.  A page refresh may be required after a few minutes.';

    private static final string CREATE_EXC_ERR_MSG = 'A web login cannot be created for this contact.  Details: {0}  ';
    private static final string CREATE_NO_EMAIL_ERR_MSG = 'A web login cannot be created because the contact does not have an email address.  ';
    private static final string CREATE_NO_CONTACTID_ERR_MSG = 'A web login cannot be created because the contact does not have a ContactId.  It may not yet be synced, so please try again in a few minutes.  ';
    private static final string CREATE_SUCCESS = 'A web login creation was successfully requested.  ';
    private static final string CREATE_EXIST_LOGIN_ERR_MSG = 'A web login cannot be created because a web login already exists for this contact.  ';
    private static final string CREATE_EXC_AFTER_WEBSVC_ERR_MSG = 'An error occurred following the login creation but prior to the record update.  Details:  {0}   ';
    
    private static final string RESET_NO_LOGIN_ERR_MSG = 'The password cannot be reset because a web login does not exist for this contact.  ';
    private static final string RESET_NO_CONTACTID_ERR_MSG = 'The password cannot be reset because the contact does not have a ContactId.  ';
    private static final string RESET_SUCCESS = 'The password reset was successfully requested.  ';
    private static final string RESET_EXC_ERR_MSG = 'The password cannot be reset.  Details: {0}  ';
    private static final string RESET_EXC_AFTER_WEBSVC_ERR_MSG = 'An error occurred following the password reset but prior to the record update.  Details:  {0}   ';

    private static final string DELETE_EXC_ERR_MSG = 'A web login cannot be deleted for this contact.  Details: {0}  ';
    private static final string DELETE_NO_CONTACTID_ERR_MSG = 'A web login cannot be deleted because the contact does not have a ContactId.  ';
    private static final string DELETE_SUCCESS = 'The web login deletion was successfully requested.  ';
    private static final string DELETE_NO_LOGIN_ERR_MSG = 'The web login cannot be deleted because a web login does not exist for this contact.  ';
    private static final string DELETE_EXC_AFTER_WEBSVC_ERR_MSG = 'An error occurred following the login delete but prior to the record update.  Details:  {0}   ';

    public LDAPLoginContactControllerExtension(ApexPages.StandardController controller) 
    {        
        RefreshContact(controller.getId());
        DetermineIsEmailDuplicate();
    }
    
    public void RefreshContact()
    {
        RefreshContact(cont.Id);
    }

	public PageReference CreateLogin()
    {
    	ApexPages.Message message = null;
    	
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
            
            if (!IsPureCloudUser && (cont.Contact_ID__c == null || cont.Contact_ID__c == ''))
            {
                errorMessage += CREATE_NO_CONTACTID_ERR_MSG;
            }            
            
            if (errorMessage != '')
            {
                message = new ApexPages.message(ApexPages.severity.ERROR, errorMessage);
            }
            else
            {                 
				try
                {                       
                    System.debug(LoggingLevel.INFO, 'Calling ldap.CreateLogin for ' + cont.Id);

                    // Send to Azure Queue
                    LdapManagement ldap = new LdapManagement();
                    ldap.CreateLogin(cont.Id);
                    
                    // Add message to LDAP Log
                    AddMessageToLog(cont.Id, 'Success', UserInfo.getName() + ' has requested the creation of the web login.'); 
                    
                    // Mark that command was requested
                    cont.Has_Requested_LDAP_Change__c = true;
                    update cont;
                }
                catch (Exception e)
                {
                    throw new ApplicationException(String.format(CREATE_EXC_AFTER_WEBSVC_ERR_MSG, new string[] { e.getMessage() }));
                }
                
                message = new ApexPages.message(ApexPages.severity.INFO, CREATE_SUCCESS);
            }
        }
        catch (Exception e)
        {         
            string errorMessage = String.format(CREATE_EXC_ERR_MSG, new string [] { e.getMessage()  });
            message = new ApexPages.message(ApexPages.severity.ERROR, errorMessage);
            System.debug(LoggingLevel.ERROR, errorMessage);
        }

		if (message != null)
		{
			ApexPages.addMessage(message);
		}
		
		return ApexPages.currentPage();
    }
    
	public PageReference ResetPassword()
    {
    	ApexPages.Message message = null;
        
        try
        {
            string errorMessage = '';
            
            if (cont.Has_LDAP_Login__c == false) 
            {
                errorMessage += RESET_NO_LOGIN_ERR_MSG;
            }
            else if (!IsPureCloudUser && (cont.Contact_ID__c == null || cont.Contact_ID__c == ''))
            {
                errorMessage += RESET_NO_CONTACTID_ERR_MSG;
            }
            
            if (errorMessage != '')
            {
                message = new ApexPages.message(ApexPages.severity.ERROR, errorMessage);
            }
            else
            {
                try
                {   
	                // Send to Azure Queue  
                    LdapManagement ldap = new LdapManagement();
                    ldap.ResetPassword(cont.Id);  
                    
                    // Add message to LDAP Log  
                    AddMessageToLog(cont.Id, 'Success', UserInfo.getName() + ' has requested a password reset for the web login.');
                    
                    // Mark that command was requested
                    cont.Has_Requested_LDAP_Change__c = true;
                    update cont;
                }
                catch (Exception e)
                {
                    throw new ApplicationException(String.format(RESET_EXC_AFTER_WEBSVC_ERR_MSG, new string[] { e.getMessage() }));
                }
                
                message = new ApexPages.message(ApexPages.severity.INFO, RESET_SUCCESS);
            }
        }
        catch (Exception e)
        {
            string errorMessage = String.format(RESET_EXC_ERR_MSG, new string [] { e.getMessage() });
            message = new ApexPages.message(ApexPages.severity.ERROR, errorMessage);
            System.debug(LoggingLevel.ERROR, errorMessage);
        }
        
		if (message != null)
		{
			ApexPages.addMessage(message);
		}
		
		return ApexPages.currentPage();
    }

    public PageReference DeleteLogin()
    {
    	ApexPages.Message message = null;
        
        try
        {
            string errorMessage = ''; 
        
            if (cont.Has_LDAP_Login__c == false) 
            {
                errorMessage += DELETE_NO_LOGIN_ERR_MSG;
            }
            else if (!IsPureCloudUser && (cont.Contact_ID__c == null || cont.Contact_ID__c == ''))
            {
                errorMessage += DELETE_NO_CONTACTID_ERR_MSG;
            }
            
            if (errorMessage != '')
            {
                message = new ApexPages.message(ApexPages.severity.ERROR, errorMessage);
            }
            else
            {
               	try
                {   
	                // Send to Azure Queue 
                    LdapManagement ldap = new LdapManagement();
                    ldap.DeleteLogin(cont.Id);     
                    
                    // Add message to LDAP Log  
                    AddMessageToLog(cont.Id, 'Success', UserInfo.getName() + ' has requested the deletion of the web login.');    
                    
                    // Mark that command was requested
                    cont.Has_Requested_LDAP_Change__c = true;
                    update cont;
                }
                catch (Exception e)
                {
                    throw new ApplicationException(String.format(RESET_EXC_AFTER_WEBSVC_ERR_MSG, new string[] { e.getMessage() }));
                }
                
                message = new ApexPages.message(ApexPages.severity.INFO, DELETE_SUCCESS);
            }
        }
        catch (Exception e)
        {
            string errorMessage = String.format(DELETE_EXC_ERR_MSG, new string [] { e.getMessage() });
            message = new ApexPages.message(ApexPages.severity.ERROR, errorMessage);
            System.debug(LoggingLevel.ERROR, errorMessage);
        }
        
		if (message != null)
		{
			ApexPages.addMessage(message);
		}
		
		return ApexPages.currentPage();
    }
    
    private void AddMessageToLog(Id contactId, String result, String message)
    {        
        LDAP_Log__c log = new LDAP_Log__c();
        log.Contact__c = contactId;
        log.Result__c = result;
        Log.Message__c = message;
        Insert log;
    }
    
	private void RefreshContact(Id contactId)
    {
        recheckCount += 1;
        cont = [SELECT Id, Contact_ID__c, Has_LDAP_Login__c,  Has_Requested_LDAP_Change__c, Contact.Account.External_Source__c, Sync_To_Internal_Systems__c, Email, Ldap_Contact_Permissions__c, Contact.Account.Pricesheet_Permission__c FROM CONTACT WHERE Id =: contactId];
        if (cont.Has_Requested_LDAP_Change__c)
        {
    		ApexPages.Message message = new ApexPages.message(ApexPages.severity.INFO, REQUESTED_LDAP_COMMAND);        
			ApexPages.addMessage(message);
        }
    }
    
    private void DetermineIsEmailDuplicate()
    {
        IsEmailDuplicate = false;
        
        // Changes made for INTMR-16 to fix the enabling/disabling of Web Login buttons when there are contacts with duplicate email addresses.
        if (!String.IsBlank(cont.Email))
        {
            if (!cont.Has_LDAP_Login__c && !cont.Has_Requested_LDAP_Change__c)
            {
                // Check to see if there is another contact with the same email address that has a Web Login
	            Contact[] matchContacts = [SELECT Id, Has_LDAP_Login__c, Has_Requested_LDAP_Change__c FROM CONTACT WHERE Email =: cont.Email AND Id !=: cont.Id];
                
                for (Contact c : matchContacts)
                {
                    if (c.Has_LDAP_Login__c || c.Has_Requested_LDAP_Change__c)
                    {
                        IsEmailDuplicate = true;
                        return;
                    }
                }
            }
            else
            {
                // If this contact already has an LDAP account or has a pending LDAP change then their email address is not duplicate or they won the race to create one for this email address.
	            IsEmailDuplicate = false;
            }
        }
        else
        {
            // The blank email will be caught when they try to create a web login.
            IsEmailDuplicate = false;
        }    	

    }
    
    public Boolean IsEmailDuplicate
    {
    	get;
    	private set;
    }
        
    public Boolean ShouldSync
    {
    	get
    	{
            if (IsPureCloudUser)
            {
                return false;
            }
            else
            {
            	return !Boolean.valueOf(cont.Sync_To_Internal_Systems__c);
            }
    	}
    }
    
    public Boolean ShouldRecheck
    {
        get
        {
            if (IsPureCloudUser)
            {
                return false;
            }
            else
            {
            	return !ShouldSync && !IsEmailDuplicate && !HasContactId && (recheckCount < 6);
            }
        }
    }
    
    public Boolean DisableCreateLogin
    {
        get
        {
            return cont.Has_Requested_LDAP_Change__c == true || IsEmailDuplicate || (!IsPureCloudUser && !HasContactId) || cont.Has_LDAP_Login__c == true;
        }
    }
               
    public Boolean DisablePasswordReset
    {
        get
        {
            return cont.Has_Requested_LDAP_Change__c == true || IsEmailDuplicate || (!IsPureCloudUser && !HasContactId) || cont.Has_LDAP_Login__c == false;
        }
    }
               
    public Boolean DisableDeleteLogin
    {
        get
        {
            return cont.Has_Requested_LDAP_Change__c == true || IsEmailDuplicate || (!IsPureCloudUser && !HasContactId) || cont.Has_LDAP_Login__c == false;
        }
    }
    
    private Boolean HasContactId
    {
        get
        {
            return !String.IsBlank(cont.Contact_ID__c);
        }
    }
    
    private Boolean IsPureCloudUser
    {
        get
        {
            Boolean isPureCloudUser = false;
            String accountId = cont.AccountId;
            String accountQuery = 'SELECT Account_Sub_Type__c FROM Account WHERE Id = :accountId';
            List<Account> acct = Database.query(accountQuery);
            if (acct.size() != 1)
            {
	            System.debug(LoggingLevel.ERROR, 'Expected 1 account record found ' + acct.size());
                isPureCloudUser = false;
            }
            else
            {
                isPureCloudUser = acct[0].Account_Sub_Type__c == 'PureCloud Customer';
            }
            
            System.debug(LoggingLevel.INFO, 'IsPureCloudUser = ' + isPureCloudUser);
            return isPureCloudUser;
        }
    }
    
}