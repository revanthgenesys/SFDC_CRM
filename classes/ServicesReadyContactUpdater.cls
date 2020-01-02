/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
@RestResource(urlMapping='/ServicesReadyContact/Update')
global with sharing class ServicesReadyContactUpdater{

    @HttpPost
    global static Result doUpdate(
        Id updateId, 
        string lastName, 
        string firstName, 
        string phone, 
        string mobilePhone, 
        string title)
    {
        Contact con;
        Result res = new Result(); 
        res.successMessages = new List<string>();
        res.CalloutMessages = new List<String>();
        ServicesReadyContactMethods servicesContact;
        string CONTACT_NOT_FOUND = 'No Contact was found with the requested ContactId.';
        string response;
        System.debug('Contact to Update: ' + firstName);
        
        try
        {            
            con = GetContact(updateId); 
            System.debug('Contact Found for Update: ' + con);
            
            if(con != null)
            {
                if(string.isNotBlank(lastName))
                {
                    con.LastName = lastName;
                }
                if(string.isNotBlank(firstName))
                {
                    con.FirstName = firstName;
                }
                if(string.isNotBlank(phone))
                {
                    con.Phone = phone;
                }
                if(string.isNotBlank(mobilePhone))
                {
                    con.MobilePhone = mobilePhone;
                }
                if(string.isNotBlank(title))
                {
                    con.Title = title;
                }
                servicesContact = new ServicesReadyContactMethods(con);
                
                System.debug('Methods Initialized for Updater' + con);
                servicesContact.UpdateAccountPermissions(con.AccountId);
                
                System.debug('Permissions Updated on the Account: ' + con.AccountId);
                servicesContact.SetPermissionsAndUpdate();            
                
                res.successMessages.add('The contact was updated Successfully with required Permissions.');
                    
                if (!con.Has_LDAP_Login__c)
                {
                    response = servicesContact.AsyncCreateLogin(); 
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