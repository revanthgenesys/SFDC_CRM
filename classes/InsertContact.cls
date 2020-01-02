/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
@RestResource(urlMapping='/ServicesReadyContact/InsertContact')
global with sharing class InsertContact
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
        Result res = new Result();
        boolean isAllowed = true;
        res.failureMessages = new List<string>();
        res.successMessages = new List<string>();
        
        try
        {
            if(String.isNotBlank(email) && !validateEmail(email))
            {
                system.debug('Email address is not valid. Please correct the email address.');
                isAllowed = false;
                res.failureMessages.add('Email address is not valid. Please correct the email address.');
            }
            
            if(isAllowed)
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
                con.Status__c = 'Pending';
            
                Insert con;           
                
                res.successMessages.add('The contact was created Successfully.');
                
                res.InsertedId = con.Id;                                
            }
        }
        catch(Exception e)
        {
            if(e.getMessage().toLowerCase().Contains('dupecatcher'))
            {
                res.failureMessages.add('Cannot update Email Address, another contact record already exists in salesforce with the same Email Address');
            }
            else
            {
              res.failureMessages.add('An Exception was thrown while Inserting the Contact with Message: ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString());            
            }
        }    
        return res;
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
        global Id InsertedId { get; private set; }
    }
}