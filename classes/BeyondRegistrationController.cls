public class BeyondRegistrationController {
	public string lastName { get; set; }
    public string firstName { get; set; }
    public string email { get; set; }
    public string phone { get; set; }
    public string companyName { get; set; }
    public string selectedCountry { get; set; }
    public string businessPhone { get; set; }
	public string selectedTZ { get; set; }
    
    public string honeyPot {get; set; }
    
    public boolean isValidEmail { get; set; }
    public static final Set<String> invalidDomains = InvalidDomains__c.getAll().keySet();
    
    public boolean hideForm { get; set; }
    
    private Contact con;
    
    public string selectedStateProvince {      
   		get {
            if (selectedStateProvince == null) {
            	selectedStateProvince ='**USA States**';
            }
            return selectedStateProvince;
       	} 
       	set;
    }
    
    public List<SelectOption> stateProvince {
        get {
         	if (stateProvince == null) {
            	stateProvince = new List<Selectoption>();
               	Schema.DescribeFieldResult F = Contact.StateProvince__c.getDescribe();
                List<Schema.PicklistEntry> entries = F.getPicklistValues();
                for(Schema.PicklistEntry e : entries) {
                    stateProvince.add(new SelectOption(e.getLabel(), e.GetValue()));
                }    
            }
            return stateProvince;
        }
        set;
    }
    
    public List<SelectOption> countries{
      	get {
           	if (countries == null) {
            	countries = new List<SelectOption>();
				
                for(Country__c us : [Select Id, Name from Country__c WHERE Name = 'United States']) {
                	countries.add(new SelectOption(us.Id, us.Name));
               	}                               
                
                for(Country__c c : [Select Id, Name from Country__c ORDER BY Name]){
                	countries.add(new SelectOption(c.Id, c.Name));
               	}
           	}
            return countries;
       	}
        set;
  	}
    
    public List<SelectOption> getTimeZone() {
		List<SelectOption> options = new List<SelectOption>();
                
        Schema.DescribeFieldResult fieldResult =User.TimeZoneSidKey.getDescribe();    
        List<Schema.PicklistEntry> PkListEntry = fieldResult.getPicklistValues();
                
        options.add(new SelectOption('', '--None--'));
        for( Schema.PicklistEntry  pkEnt : PkListEntry) {
        	options.add(new SelectOption(pkEnt.getLabel(), pkEnt.getLabel()));
        }
        
        return options;
    }
    
 	public boolean isUserEmailValid() {
        Boolean flag = false;
        if (email != null) {
            String  emailRegex      = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
            Pattern emailPattern    = Pattern.compile(emailRegex);
            Matcher emailMatcher    = emailPattern.matcher(email.trim());
            flag                    = emailMatcher.matches();
        }
        return flag;
    }
    
    // if a contact already exists and depending on the 
    // respective status field, update the boolean so that 
    // appropriate email alerts go thru
    public Contact checkifContactExits() {
        con = null;        
        List<Contact> contacts = [Select Id, AccountId, Status__c from Contact where Email = :email.trim() ];
        if (contacts != null && !contacts.isEmpty()) {               
        	con = contacts[0];
        }
        return con;
    }
    
    public BeyondRegistrationController() {
        
        email = Apexpages.currentPage().getParameters().get('em');
        
        if (!String.isBlank(email)) {
            isValidEmail = true;
        } else {  
            isValidEmail = false;
        }
    }
    
    public PageReference save() { 
        if (String.isBlank(honeyPot)) {
            if (validate()) {
                try {
                    if (con == null || con.Id == null) {
                        con = createContact();
                        createCase(con);
                        return new PageReference('/apex/BeyondRegistrationConfirmation');
                    }       
                } catch (DmlException ex) { 
                    ApexPages.addMessage(new ApexPages.message(ApexPages.SEVERITY.ERROR, 'There was an error processing your request. Please contact education@genesys.com for assistance.'));
                    return null;
                }
            }
            return null;
        } 
       	return new PageReference('/apex/BeyondRegistrationConfirmation');
    }
    
    public Boolean validate(){
       	if (String.isBlank(firstName) || 
            String.isBlank(lastName) || 
            String.isBlank(email) || 
            String.isBlank(companyName) || 
            String.isBlank(businessPhone)) {                
           	Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, 'Please fill the missing fields below.'));                                                                                                                                                      
            return false;        
        }
        
        Integer i = email.indexOfIgnoreCase('@');
        String emailDomain = email.substring(i+1, email.length());
        
        isValidEmail = isUserEmailValid() && !invalidDomains.contains(emailDomain);
  
        if (!isValidEmail) {
          	Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, 'Please provide a valid email address at your current employer.'));
            email='';
            return false;
        }
        
        con = checkifContactExits();            
        
        if (con != null) {
            if (con.Status__c == 'Active') {
                isValidEmail= false;
                Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO, 'There is already an active account with this email address on our system.  '+
                  	'If you forgot your password please go to URL  ' +  
                    '__https://apps.genesys.com/pcodebroker/resetPcode.aspx___  ' +
                    '  If you need additional assistance with your account, please contact education@genesys.com.'));
                email = '';
                hideForm = true;
                return false;
            } else if (con.Status__c == 'Pending') {
                isValidEmail= false;
                        
                Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO,
                 	'Thank you for your Beyond registration submission. Your request is being processed and we will contact you shortly.'));                          
                email = '';
                hideForm = true;
                return false;
            } else if (con.Status__c == 'Inactive') {
                isValidEmail= false;
                Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO, 'There is currently an inactive account with this email address on our system. '+
                    'Please contact education@genesys.com for assistance.'));
                email = '';
                hideForm = true;
                return false;
            }
        }
                         
        return true;
    }
    
    public Contact createContact( ) {
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType ='Contact' and DeveloperName= 'EMGContactRecordType'];
        
        con = new Contact();
        con.is_Created_From_Site__c     = true;
        con.FirstName                   = firstName;
        con.LastName                    = lastName;
        con.Email                       = email;
        con.ContactPhone__c             = businessPhone;
        con.StateProvince__c            = selectedStateProvince;
        con.Country__c                  = selectedCountry;
        con.Status__c                   = 'Pending';
        
        if(rtypes != null && !rtypes.isEmpty()) {
        	con.RecordTypeId = rtypes[0].Id; 
        }
        
        insert con;
        return con;
    }
    
    public void createCase(Contact con) {
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType ='Case' and DeveloperName= 'Genesys_Admin_Case']; 
       	String onlineResrs = 'Genesys Beyond';
        
        Case newCase = new Case();
        newCase.AccountId = con.AccountId;
        newCase.ContactId = con.Id;
        newCase.subject = 'Genesys Beyond Registration: New Account Request';
        newCase.Type = 'Access Request';
        newCase.Problem_Sub_Type__c ='Request: Create Website Account';
        newCase.Description = 'Employer Name: ' + companyName + '\n\n' +
                              'Access to On-Line Resources: '  + '\n' + onlineResrs + '\n\n' +
                              'Contact Time Zone: ' + selectedTZ;
        
        if (rtypes != null && !rtypes.isEmpty()) {
            newCase.RecordTypeId = rtypes[0].Id;
        }
        
        insert newCase;
    }
    
}