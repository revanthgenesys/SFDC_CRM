/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
@RestResource(urlMapping='/ServicesReadyContact/RevokePermissions')
global with sharing class RevokeContactPermissions {
  @HttpPost
    global static Result revokePermissions(
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
              System.debug('Contact for which the Login is being Created: ' + con.FirstName);
            
                contactMethods = new ContactAPIMethods(con, contactPermissions);
                
                System.debug('Methods Initialized for Revoke Contact Permissions' + con);
                
                if(contactPermissions != null && contactPermissions.size() > 0)
                {
                  contactMethods.RevokePermissions();               
                    res.successMessages.add('The specified permissions were removed successfully for ContactId: ' + con.Id);
                }        
                else
                {
                    res.failureMessages.add('NO PERMISSIONS WERE SPECIFIED TO REVOKE.');            
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
            res.failureMessages.add('An Exception was thrown while removing the Contact Permissions with Message: ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString());            
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