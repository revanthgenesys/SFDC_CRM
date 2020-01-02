public class LdapManagement {
    private string MESSAGEFORMAT = 'command: "{0}", id: "{1}"';
    
    private AzureManagement azure;
    
    public LdapManagement()
    { 
     	if (Utility.IsSandboxEnvironment())
        {
            // This is a sandbox so only use development custom settings            
            azure = new AzureManagement(Utility.GetRequiredGeneralCustomSetting('DevAzureStorageKey'),
                                        Utility.GetRequiredGeneralCustomSetting('DevAzureStorageName'),
                                        Utility.GetRequiredGeneralCustomSetting('DevAzureStorageContainer'),
                                        Utility.GetRequiredGeneralCustomSetting('DevAzureStorageUrl'));
        } 
        else 
        {
            // This is production so use the production values
            azure = new AzureManagement(Utility.GetRequiredGeneralCustomSetting('AzureStorageKey'),
                                        Utility.GetRequiredGeneralCustomSetting('AzureStorageName'),
                                        Utility.GetRequiredGeneralCustomSetting('AzureStorageContainer'),
                                        Utility.GetRequiredGeneralCustomSetting('AzureStorageUrl'));
        }  
    }
    
    public void CreateLogin(ID contactId)
    {
        azure.sendMessageToQueue('{ ' + string.format(MESSAGEFORMAT, new String[] {'create', contactId }) + ' }');
    }
    
    public void CreateLogins(List<ID> contactIds)
    {
        List<string> messages = new List<string>();
        
        for (ID i : contactIds)
        {
            messages.add('{ ' + string.format(MESSAGEFORMAT, new String[] {'create', i }) + ' }');
        }
                         
        azure.sendMultipleMessagesToQueue(messages);
    }
    
    // Call from trigger if needed
    @future(callout=true)
    public static void CreateLoginsAsync(List<ID> contactIds)
    {
        LdapManagement ldap = new LdapManagement();
        ldap.CreateLogins(contactIds);
    }
    
    public void UpdateLogin(ID contactId)
    {
        azure.sendMessageToQueue('{ ' + string.format(MESSAGEFORMAT, new String[] {'update', contactId }) + ' }');
    }
    
    public void UpdateLogins(List<ID> contactIds)
    {
        List<string> messages = new List<string>();
        
        for (ID i : contactIds)
        {
            messages.add('{ ' + string.format(MESSAGEFORMAT, new String[] {'update', i }) + ' }');
        }
                         
        azure.sendMultipleMessagesToQueue(messages);
    }
    
    // Call from trigger if needed
    @future(callout=true)
    public static void UpdateLoginsAsync(List<ID> contactIds)
    {
        LdapManagement ldap = new LdapManagement();
        ldap.UpdateLogins(contactIds);
    }
    
    public void DeleteLogin(ID contactId)
    {
        azure.sendMessageToQueue('{ ' + string.format(MESSAGEFORMAT, new String[] {'delete', contactId }) + ' }');
    }
    
    public void DeleteLogins(List<ID> contactIds)
    {
        List<string> messages = new List<string>();
        
        for (ID i : contactIds)
        {
            messages.add('{ ' + string.format(MESSAGEFORMAT, new String[] {'delete', i }) + ' }');
        }
                         
        azure.sendMultipleMessagesToQueue(messages);
    }
    
    // Call from trigger if needed
    @future(callout=true)
    public static void DeleteLoginsAsync(List<ID> contactIds)
    {
        LdapManagement ldap = new LdapManagement();
        ldap.DeleteLogins(contactIds);
    }
    
    public void ResetPassword(ID contactId)
    {
        azure.sendMessageToQueue('{ ' + string.format(MESSAGEFORMAT, new String[] {'reset', contactId }) + ' }');
    }
    
    public void ResetPasswords(List<ID> contactIds)
    {
        List<string> messages = new List<string>();
        
        for (ID i : contactIds)
        {
            messages.add('{ ' + string.format(MESSAGEFORMAT, new String[] {'reset', i }) + ' }');
        }
                         
        azure.sendMultipleMessagesToQueue(messages);
    }
    
    public void UpdatePermissions(ID contactId)
    {
        azure.sendMessageToQueue('{ ' + string.format(MESSAGEFORMAT, new String[] {'updateperm', contactId }) + ' }');
    }
    
    public void UpdatePermissions(List<ID> contactIds)
    {
        List<string> messages = new List<string>();
        
        for (ID i : contactIds)
        {
            messages.add('{ ' + string.format(MESSAGEFORMAT, new String[] {'updateperm', i }) + ' }');
        }
                         
        azure.sendMultipleMessagesToQueue(messages);
    }
    
    // Call from trigger if needed
    @future(callout=true)
    public static void UpdatePermissionsAsync(List<ID> contactIds)
    {
        LdapManagement ldap = new LdapManagement();
        ldap.UpdatePermissions(contactIds);
    }
}