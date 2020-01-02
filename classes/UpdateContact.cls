/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
@RestResource(urlMapping='/ServicesReadyContact/UpdateContact')
global with sharing class UpdateContact{

    @HttpPost
    global static Result doUpdate(
        Id updateId, 
        string lastName, 
        string firstName, 
        string phone, 
        string mobilePhone, 
        string emailAddress,
        string title)
    {
        boolean isAllowed = true;
        Contact con;
        Result res = new Result(); 
        res.failureMessages = new List<string>();
        res.successMessages = new List<string>();
            
        string CONTACT_NOT_FOUND = 'No Contact was found with the requested ContactId.';
        string response;
        System.debug('Contact to Update: ' + firstName);
        
        try
        {            
            con = GetContact(updateId); 
            System.debug('Contact Found for Update: ' + con);            
            
            if(String.isNotBlank(emailAddress) && con.Has_LDAP_Login__c)
            {
                system.debug('Cannot update Email Address of a contact that already has a login.');
                isAllowed = false;
                res.failureMessages.add('Cannot update Email Address of a contact that already has a login.');
            }
      
      if(String.isNotBlank(emailAddress) && !validateEmail(emailAddress))
            {
                system.debug('Email address is not valid. Please correct the email address.');
                isAllowed = false;
                res.failureMessages.add('Email address is not valid. Please correct the email address.');
            }
            
            if(con != null && isAllowed)
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
                if(string.isNotBlank(emailAddress))
                {   
                    con.Email = emailAddress;
                }
                
                update con;                                
                res.successMessages.add('The contact was updated Successfully.');                
            }
            else if(con == null)
            {
                system.debug('Contact Not Found');
                res.failureMessages.add(CONTACT_NOT_FOUND);
            }
        }
        catch (Exception e)
        {            
            if(e.getMessage().toLowerCase().Contains('dupecatcher'))
            {
                res.failureMessages.add('Cannot update Email Address, another contact record already exists in salesforce with the same Email Address');
            }
            else
            {
              res.failureMessages.add('An Exception was thrown while Updating the Contact with Message: ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString());            
            }
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
    
    public static Boolean validateEmail(String email) {
  Boolean isAllowed = true;
  
    String regex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})'; 
  Pattern MyPattern = Pattern.compile(regex);
  Matcher MyMatcher = MyPattern.matcher(email);
     
  if (!MyMatcher.matches()) 
      isAllowed = false;    
  
    return isAllowed;  
  }
    
    global class Result
    {
        global string[] successMessages { get; private set; }    
        global string[] failureMessages { get; private set; } 
    }
}