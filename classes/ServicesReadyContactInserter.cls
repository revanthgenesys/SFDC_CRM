/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
@RestResource(urlMapping='/ServicesReadyContact/Insert')
global with sharing class ServicesReadyContactInserter
{
    @HttpPost
    global static Result doInsert(
        Id accountId,
        string lastName, 
        string firstName, 
        string phone, 
        string mobilePhone, 
        string email, 
        string title)
    {    
        Contact con = new Contact();        
        ServicesReadyContactMethods servicesContact;
        Result res = new Result();
        res.successMessages = new List<string>();
        res.CalloutMessages = new List<String>();
        
        try
        {
            if(string.isNotBlank(accountId))
            {
                con.AccountId = accountId;
            }
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
            if(string.isNotBlank(email))
            {
                con.Email = email;
            }
            if(string.isNotBlank(title))
            {
                con.Title = title;
            }
            servicesContact = new ServicesReadyContactMethods(con);
            System.debug('Methods Initialized for Inserter' + con); 
            servicesContact.UpdateAccountPermissions(accountId);
            System.debug('Permissions Updated on the Account: ' + con.AccountId);
            
            // Adds the needed contact permissions to make the Contact "services ready"        
          con.Ldap_Contact_Permissions__c = servicesContact.GetContactPermissions();            
            insert con;
            res.successMessages.add('The contact was created Successfully with required Permissions.');
            
            string Response = servicesContact.AsyncCreateLogin();
            
            res.InsertedId = con.Id;            
            res.CalloutMessages.add(Response);            
        }
        catch(Exception e)
        {
            res.CalloutMessages.add('An Exception was thrown while Inserting the Contact with Message: ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString());            
        }    
        return res;
    }

    global class Result
    {
        global string[] successMessages { get; private set; }
        global string[] CalloutMessages { get; private set; }
        global Id InsertedId { get; private set; }
    }
}