/* Registration Controller for new users to request access for Portal*/
public class RegistrationController {
        public string lastName {get; set;}
        public string firstName {get; set;}
        public string email {get; set;}
        public string phone {get; set;}
        public string selectedType {get;set;}
        public string alternateEmail {get;set;}
        public string companyName {get;set;}
        public string addrLine1 {get;set;}
        public string addrLine2 {get;set;}
        public string city {get;set;}
        public string selectedSalutation {get;set;}
        public string selectedCountry { get; set; }
        public string selectedContactMethod {get;set;}
        public string zipPostalCode {get;set;}
        public string businessPhone {get;set;}
        public string cellularPhone {get;set;}
        public string privatePhone {get;set;}
        public string pager {get;set;}
        public string fax {get;set;}
        public string notes {get;set;}
        public boolean agreedTermsAndCond {get;set;}
        public String middleName { get; set; }
        public String requestedAccess {get; set;}
        public String helpfulInfo {get; set;}
        public String exisingContacts {get; set;}
        public Boolean selectedCloud {get; set;}
        public Boolean selectedPrem {get; set;}
        public String selectedTZ {get; set;}
        
        public Boolean linePureEngPrem {get; set;}
        public Boolean linePureEngCloud {get; set;}
        public Boolean linePureCnctPrem {get; set;}
        public Boolean linePureCnctCloud {get; set;}
        public Boolean linePureCloud {get; set;}
        
        public Boolean accsKnowNetwrk {get; set;}
        public Boolean accsCommunity {get; set;}
        public Boolean accsProdIdeasLab {get; set;}
        public Boolean accsPartnerPortal {get; set;}
        public Boolean accsCustPortalKB {get; set;}
        public Boolean accsCustPortalCaseRO {get; set;}
        public Boolean accsCustPortalCaseRW {get; set;}

        public List<String> avalblVals {get; private set;}
        public String chllgNum {get; private set;} 
        public Integer fst {get; private set;}
        public Integer snd {get; private set;}
        public String chllgResp {get; set;}
        public Boolean notRobot {get; private set;}

        private Contact con;
        
        public RegistrationController() {
                email = Apexpages.currentPage().getParameters().get('em');
                if ( !String.isBlank(email) )
                   isValidEmail = true;
                else  
                   isValidEmail = false; 

                requestedAccess = '';  
                selectedCloud = false;
                selectedPrem = false;
                
                linePureEngPrem = false;
                linePureEngCloud = false;
                linePureCnctPrem = false;
                linePureCnctCloud = false;
                linePureCloud = false;
                
                accsKnowNetwrk = false;
                accsCommunity = false;
                accsProdIdeasLab = false;
                accsPartnerPortal = false;
                accsCustPortalKB = false;
                accsCustPortalCaseRO = false;
                accsCustPortalCaseRW = false;

                notRobot = false;
                chllgResp = '';
                setChallenge();
        }
            
        public List<Selectoption> prefContactMethod{get{
                prefContactMethod = new List<Selectoption>();
                prefContactMethod.add(new SelectOption('Email','Email'));
                prefContactMethod.add(new SelectOption('Contact Phone', 'Contact Phone'));
                prefContactMethod.add(new SelectOption('Mobile Phone','Mobile Phone'));         
                return prefContactMethod;
                }set;}
        
        public List<Selectoption> salutations {
                get{
                        salutations = new List<SelectOption>();
                        salutations.add( new SelectOption( 'Mr.', 'Mr.' ));
                        salutations.add( new SelectOption( 'Mrs.', 'Mrs.' ));
                        salutations.add( new SelectOption( 'Ms.', 'Ms.'));
                        salutations.add( new SelectOption( 'Dr.', 'Dr.' ));
                        return salutations;
                }
                set;
        }
        
        public List<SelectOption> accessTypes {
             get{
                   accessTypes = new List<selectOption>();
                   accessTypes.add( new SelectOption( 'Basic Access', 'Basic Access' )); 
                   accessTypes.add( new SelectOption( 'Read/Only', 'Read/Only' ));  
                   accessTypes.add( new SelectOption( 'Read/Write', 'Read/Write' )); 
                   return accessTypes; 
             }
             set;
        }
                
        public boolean isValidEmail {get;set;}
                
        public string selectedStateProvince {      
                get {
                if(selectedStateProvince == null) 
                        selectedStateProvince ='**USA States**';                        
                return selectedStateProvince;
        
           } set;
        }
        public List<SelectOption> stateProvince {
                get{
                        if(stateProvince == null){
                                stateProvince =  new List<Selectoption>();
                                Schema.DescribeFieldResult F = Contact.StateProvince__c.getDescribe();
                                List<Schema.PicklistEntry> entries = F.getPicklistValues();
                                for(Schema.PicklistEntry e : entries)
                                        stateProvince.add(new SelectOption(e.getLabel(), e.GetValue()));        
                        }
                        return stateProvince;
                        
                }
                set;}
        
        public String selectedLang { 
           get {
                if(selectedLang == null) 
                        selectedLang ='English';                        
                return selectedLang;
        
           } set;
        }       
        public List<SelectOption> language {
                get{
                        if(language == null){
                                language =  new List<Selectoption>();
                                Schema.DescribeFieldResult lang = Contact.Preferred_Language__c.getDescribe();
                                List<Schema.PicklistEntry> langEntries = lang.getPicklistValues();
                                for(Schema.PicklistEntry e : langEntries)
                                        language.add(new SelectOption(e.getLabel(), e.GetValue()));     
                        }
                        language.sort();
                        return language;
                        
                }
                set;}
                
        public List<SelectOption> countries{
                get{
                        if(countries == null){
                                countries = new List<SelectOption>();
                                for(Country__c us : [Select Id, Name from Country__c WHERE Name = 'United States']) {
                                        countries.add(new SelectOption(us.Id, us.Name));
                                }                               
                                for(Country__c c : [Select Id, Name from Country__c ORDER BY Name]){
                                        countries.add(new SelectOption(c.Id, c.Name));
                                }
                        }
                        return countries;
                                
                }set;
        }
        
   public List<SelectOption> getTimeZone() {
                  List<SelectOption> options = new List<SelectOption>();
                
                  Schema.DescribeFieldResult fieldResult =User.TimeZoneSidKey.getDescribe();    
                  List<Schema.PicklistEntry> PkListEntry = fieldResult.getPicklistValues();
                
                  options.add(new SelectOption('', '--None--'));
                  for( Schema.PicklistEntry  pkEnt : PkListEntry)       
                     options.add(new SelectOption(pkEnt.getLabel(), pkEnt.getLabel()));
        
                  return options;
    }
        
    public static final Set<String> invalidDomains = InvalidDomains__c.getAll().keySet();
    
    public PageReference save() { 
        
        if ( String.isBlank(firstName) || String.isBlank(lastName) || String.isBlank(email) || 
             String.isBlank(companyName) || String.isBlank(businessPhone) ) {                
            Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, 'Please fill the missing fields marked in red.'));                                                                                                                                                      
            return null;        
        }
    /*    
        else if (requestedAccess == null || requestedAccess == '') {
                Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, 'Please specify the Access Level requested.'));                                                                                                                                                      
            return null;
        }
    */           
        try {
                if(con == null || con.Id == null)
                        con = createContact( );
            createCase(con);
        }catch(DmlException ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.SEVERITY.ERROR, 'There was an error processing your request' + ex.getMessage()));
            return null;
        }
        return new PageReference('/apex/ThankYou');
    }
  
    public PageReference cancel(){
        isValidEmail = false;
        PageReference pageRef = new PageReference('/customercare/GenesysCommunityLogin');
        pageRef.setRedirect(true);
        return pageRef;
    }
  
    public boolean isUserEmailValid() {
        Boolean flag = false;
        if(email != null) {
            String  emailRegex      = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
            Pattern emailPattern    = Pattern.compile(emailRegex);
            Matcher emailMatcher    = emailPattern.matcher(email.trim());
            flag                    = emailMatcher.matches();
        }
        return flag;
    }
    
    public PageReference submit(){      
        Integer i = email.indexOfIgnoreCase('@');
        
        String emailDomain = email.substring(i+1, email.length());
        
        isValidEmail = isUserEmailValid() && !invalidDomains.contains(emailDomain);
  
        if(!isValidEmail) {
                Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.ERROR, 'Please provide a valid email address at your current employer.'));
                email='';
                return null;
        }
        con = checkifContactExits();            
        if(con != null) {
                if(con.Status__c == 'Active'){
                        isValidEmail= false;
                        Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO, 'There is already an account with this email address on our system.  '+
                                                  'If you forgot your password please go to URL  ' +  
                                                 '__https://careers.genesys.com/pcodebroker/resetPcode.aspx___  ' +
                                                '  If you haven’t registered with us before please contact CustomerCare@Genesys.Com to have your account activated.'));
                        email='';
                        return null;
                }
                else if(con.Status__c == 'Pending'){
                        isValidEmail= false;
                        
                        Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO,
                                 'Thank you for your My Support login account submission. Your request is being processed and we will contact you shortly.'));                          
                        email='';
                        return null;
                }
                else if(con.Status__c == 'Inactive'){
                        isValidEmail= false;
                        Apexpages.addMessage( new Apexpages.Message(Apexpages.Severity.INFO, 'Your account is currently Inactive. '+
                                                                                    'Please contact your sales representative for assistance'));
                        email='';
                        return null;
                }
        }
                         
        return new PageReference('/customercare/GenesysRegistration?em=' + email);
    }
    
    // if a contact already exists and depending on the respective status field, update the boolean so that appropriate email alerts go thru
    public Contact checkifContactExits() {
        con = null;        
        List<Contact> contacts = [Select Id, AccountId, Status__c from Contact where Email = :email.trim() ];
        if(contacts != null && !contacts.isEmpty())
        {               
              con = contacts[0];
        }
        return con;
    }
    
    // create a new contact with its status as Pending -> confirm with Jose
    public Contact createContact( ) {
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType ='Contact' and DeveloperName= 'EMGContactRecordType'];
        
        con = new Contact();
        con.is_Created_From_Site__c     = true;
        con.FirstName                   = firstName;
        con.LastName                    = lastName;
        con.Email                       = email;
        con.Alternate_Email__c          = alternateEmail;
        con.ContactPhone__c             = businessPhone;
        con.MobilePhone                 = cellularPhone;
        con.OtherPhone                  = privatePhone;
        con.Street1__c                  = addrLine1;
        con.Street2__c                  = addrLine2;
        con.ZipCode__c                  = zipPostalCode;
        con.City__c                     = city;
        con.StateProvince__c            = selectedStateProvince;
        con.Country__c                  = selectedCountry;
        con.Status__c                   = 'Pending';
        con.Salutation                  = selectedSalutation;
        con.Preferred_Method__c         = selectedContactMethod;
        con.Middle_Name__c              = middleName;
        con.Preferred_Language__c       = selectedLang;
        
        if(rtypes != null && !rtypes.isEmpty())
                con.RecordTypeId = rtypes[0].Id;                       
        insert con;
        return con;
    }
    
    // create a case  
    public void createCase( Contact con )  {                
        List<RecordType> rtypes = [Select Id from RecordType where SobjectType ='Case' and DeveloperName= 'Genesys_Admin_Case']; 

         /// Product Line
         String prodLine = '';
         if ( linePureEngPrem ) 
            prodLine = 'PureEngage Premise';
         if ( linePureEngCloud )  {
                prodLine += prodLine != '' ? ', ' : '';
                prodLine += 'PureEngage Cloud';
         } 
         if ( linePureCnctPrem )  {
                prodLine += prodLine != '' ? ', ' : '';
                prodLine += 'PureConnect Premise';
         } 
         if ( linePureCnctCloud )  {
                prodLine += prodLine != '' ? ', ' : '';
                prodLine += 'PureConnect Cloud';
         } 
         if ( linePureCloud )  {
                prodLine += prodLine != '' ? ', ' : '';
                prodLine += 'PureCloud';
         }

         String onlineResrs = '';
         
         onlineResrs += accsKnowNetwrk ? 'Genesys Knowledge Network \n' : '';
                 onlineResrs += accsCommunity ? 'Genesys Community \n' : '';
                 onlineResrs += accsProdIdeasLab ? 'Product Ideas Lab \n' : '';
                 onlineResrs += accsPartnerPortal ? 'Partner Portal \n' : '';
                 onlineResrs += accsCustPortalKB ? 'Customer Care Portal – Knowledge Base \n' : '';
                 onlineResrs += accsCustPortalCaseRO ? 'Customer Care Portal – Cases – Read Only \n' : '';
                 onlineResrs += accsCustPortalCaseRW ? 'Customer Care Portal – Cases – Read/ Write \n' : '';
                      
        Case newCase = new Case();
        newCase.AccountId = con.AccountId;
        newCase.ContactId = con.Id;
        newCase.subject = 'Customer Care Portal: New Account Request';
        newCase.Type = 'Access Request';
        newCase.Problem_Sub_Type__c ='Request: Create Website Account';
        newCase.Description = 'Employer Name: ' + companyName + '\n\n' +
                              'Access Requested: ' + requestedAccess + '\n\n' +
                              'Access to On-Line Resources: '  + '\n' + onlineResrs + '\n\n' +
                              'Product Line(s): '  + prodLine + '\n\n' +
                              'End User/Sold To: ' + helpfulInfo + '\n\n' +
                              'Existing Contacts: ' + exisingContacts + '\n\n' +
                              'Contact Time Zone: ' + selectedTZ;
                              
        if(rtypes != null && !rtypes.isEmpty())
                newCase.RecordTypeId = rtypes[0].Id;
        insert newCase;
    }

    public void setChallenge() {
       Integer STRING_LENGTH = 6;
       avalblVals = new List<String>{'first','second','third','fourth','fifth','sixth'};
      
       Integer min = (Integer)Math.pow(10,STRING_LENGTH -1); 
       Integer max = (Integer)Math.pow(10,STRING_LENGTH) - 1; 

       chllgResp = '';
       chllgNum = String.valueOf(Math.Round(Math.Random() * (max-min) + min));

       fst = -1;
       snd = -1;
       for (Integer i=0; i<20 && snd == -1; i++) {
          Integer rand = Integer.valueof((math.random() * 10));

          if ( fst == -1 && rand < STRING_LENGTH )
                fst = rand;
          else if ( snd == -1 && fst != rand && rand < STRING_LENGTH )
                snd = rand;
        }
    }

    public void vaidateChallenge() {
        notRobot = false;
        if ( chllgResp != null && fst != null && snd != null && chllgNum != null ) {

        try {
                String fstDigit = chllgNum.substring(fst,fst+1);
                String sndDigit = chllgNum.substring(snd,snd+1);

                if ( chllgResp.deleteWhitespace() == fstDigit + sndDigit ) 
                        notRobot = true;           
            }
            catch (Exception e) {}
        }

        if ( !notRobot ) {    
             setChallenge(); 
        }
    }
}