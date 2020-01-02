/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
@RestResource(urlMapping='/ServicesReadyContact/GrantPermissions')
global with sharing class GrantContactPermissions {
  @HttpPost
    global static Result grantPermissions(
        Id contactId, 
        string[] contactPermissions)
    {
        Contact con;
        Result res = new Result(); 
        res.failureMessages = new List<string>();
        res.successMessages = new List<string>();
        ContactAPIMethods contactMethods;
        string CONTACT_NOT_FOUND = 'No Contact was found with the requested ContactId.';
        string response;        
        
        try
        {            
            con = GetContact(contactId); 
            if(con != null)
            {
              System.debug('Contact for which the Permission(s) are being granted: ' + con.FirstName);
            
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
                    res.failureMessages.add('NO PERMISSIONS WERE SPECIFIED TO BE GRANTED.');            
                }  
            }
            else
            {
                system.debug('Contact Not Found');
                res.failureMessages.add(CONTACT_NOT_FOUND);
            }
        }
        catch (Exception e)
        {   
            res.failureMessages.add('An Exception was thrown while Updating the Contact Permissions with Message: ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString());            
        }        
        
        return res;
    }    
    
    public static Contact GetContact(Id updateId)
    {   
        Contact con = [
            SELECT LastName, FirstName, Phone, MobilePhone, Email, Title, Ldap_Contact_Permissions__c, Has_Ldap_Login__c, AccountId, Contact_ID__c, Account.Pricesheet_Permission__c 
            FROM Contact
            WHERE Id =: updateId
        ];
        
        return con;
    }   
    
    global class Result
    {
        global string[] successMessages { get; private set; }    
        global string[] failureMessages { get; private set; } 
    }
}