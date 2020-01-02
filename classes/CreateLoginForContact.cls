/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
@RestResource(urlMapping='/ServicesReadyContact/CreateLogin')
global with sharing class CreateLoginForContact{
    @HttpPost
    global static Result createLogin(
        Id contactId, 
        string[] contactPermissions)
    {
        Contact con;
        Result res = new Result(); 
        res.successMessages = new List<string>();
        res.CalloutMessages = new List<String>();
        ContactAPIMethods contactMethods;
        string CONTACT_NOT_FOUND = 'No Contact was found with the requested ContactId.';
        string response;        
        
        try
        {            
            con = GetContact(contactId); 
            if(con != null)
            {
                System.debug('Contact for which the Login is being Created: ' + con.FirstName);
            
                contactMethods = new ContactAPIMethods(con, contactPermissions);
                
                System.debug('Methods Initialized for Updater' + con);
                if(contactPermissions != null && contactPermissions.size() > 0)
                {
                    System.debug('Permissions Updated on the Account: ' + con.AccountId);
                    contactMethods.GrantPermissions();               
                    res.successMessages.add('The requested Permissions were granted successfully to the Contact with Id: ' + con.Id);
                }        
                else
                {
                    res.CalloutMessages.add('NO PERMISSIONS WERE SPECIFIED TO BE GRANTED.');            
                } 
                
                if (!con.Has_LDAP_Login__c)
                {
                    response = contactMethods.AsyncCreateLogin(); 
                    system.debug('Added the contact to Create Login Queue');
                }
                res.CalloutMessages.add(response);
            }
            else
            {
                system.debug('Contact Not Found');
                res.CalloutMessages.add(CONTACT_NOT_FOUND);
            }
        }
        catch (Exception e)
        {            
            
            res.CalloutMessages.add('An Exception was thrown while Updating the Contact with Message: ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString());            
        }        
        
        return res;
    }    
    
    public static Contact GetContact(Id updateId)
    {   
        Contact con = [
            SELECT LastName, FirstName, Phone, MobilePhone, Email, Title, Ldap_Contact_Permissions__c, Portal_Permission__c, Has_Ldap_Login__c, AccountId, Contact_ID__c, Account.External_Source__c, Account.Pricesheet_Permission__c 
            FROM Contact
            WHERE Id =: updateId
        ];
        
        return con;
    }   
    
    global class Result
    {
        global string[] successMessages { get; private set; }
        global string[] CalloutMessages { get; private set; }        
    }
}