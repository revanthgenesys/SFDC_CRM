public class ContactControllerExtension { 
    
    public Boolean submitted { get; set; }
    public String txtMsg { get; set; }
    public boolean isEdit { get; set; }
    public String txtMobilePhone { get; set; }
    public String contactPhone { get; set; }
    public String email { get; set; }
    //public String accountName { get; set; }
    public String emplName { get; set; }
    public String lastName { get; set; }
    public String middleName { get; set; }
    public string firstName {get;set;}        
    private final Contact con;
    private final User user;

    public ContactControllerExtension() {//c.Country__r.Country__c, c.Country__c
          isEdit= false;
          submitted = false;
 
          user = [ Select firstname,email, lastname,u.Contact.Email, u.Contact.AssistantPhone, u.Contact.OtherPhone, u.Contact.HomePhone, u.Contact.MobilePhone, u.Contact.Fax, u.Contact.Phone,
              u.Contact.MailingCountry, u.Contact.MailingPostalCode, u.Contact.MailingState, u.Contact.MailingCity, u.Contact.MailingStreet, u.Contact.FirstName, u.Contact.LastName,
              u.Contact.Id, u.ContactId, u.AccountId,u.contact.Account.name  From User u where id=:UserInfo.getUserId()];
              
              if(user.contactid != null){
                List<Contact> conts = [Select c.Street2__c, c.Street1__c,c.id, c.StateProvince__c, c.Owner.Id, 
                                               c.ZipCode__c ,c.Pin__c, c.IVR_Code__c, c.Name ,c.OwnerId, c.LastName, c.FirstName, c.Salutation,
                                               c.Fax, c.Email,c.ContactPhone__c, c.mobilephone, c.Country__r.Country__c, 
                                               c.Country__c,c.Country__r.Name, c.City__c, c.Alternate_Email__c, c.Account.Name, 
                                                c.AccountId, c.Preferred_Method__c, c.Preferred_Language__c, c.Middle_Name__c, c.Employer__r.Name 
                                        From Contact c where c.Id=:user.contactid];
                         if(!conts.isEmpty()){
                                 con = conts[0];
                             firstname = con.FirstName;
                             lastName = con.lastName;
                             //accountName = con.account.name;  
                             emplName = con.Employer__r.Name;  
                             email = con.email;
                             txtMobilePhone = con.mobilephone;
                             middleName = con.Middle_Name__c;
                             contactPhone = con.ContactPhone__c;                                                   
                         }
              }
    }
    public Contact getContact () {
        return con;
    }
    public PageReference Cancel() {
    
        string urls = URL.getSalesforceBaseUrl().toExternalForm()+ '/home/home.jsp';
        PageReference pageRef = new PageReference(urls);
        pageRef .setRedirect(true);
        return pageRef ;
    }
    
    public PageReference manageSub() {
    
        PageReference pageRef = new PageReference('/apex/MySubscriptions');
        pageRef .setRedirect(true);
        return pageRef ;
        return null;
    }

    public User getUser () {
        return user;
    }

    public PageReference UpdateContactInfo() {
    
        /* Validation*/
        boolean err_flag=false;
        if(firstName == '' || firstName == null){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.error,'Error: Please enter First Name');
                       ApexPages.addMessage(myMsg);
                       err_flag=true;
        }
        if(lastname == '' || lastname== null){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.error,'Error: Please enter Last Name');
                       ApexPages.addMessage(myMsg);
                       err_flag=true;
         }
        if(email == '' || email == null){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.error,'Error: Please enter Email');
                       ApexPages.addMessage(myMsg);
                       err_flag=true;
        }
        if(emplName == '' || emplName == null){
             ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.error,'Error: Please enter a vaild Employer Name');
                       ApexPages.addMessage(myMsg);
                       err_flag=true;
        }
        if(err_flag == true || con == null)
        return null;
               /* Validation*/   
       
       try{  
           if( firstName != con.FirstName || lastname != con.lastName || email != con.email || emplName != con.Employer__r.Name ){
           
               //Get the admin case record type 
               List<RecordType> recordType =[ Select Id From RecordType r where DeveloperName='Genesys_Admin_Case'];
               List<QueueSobject> queue;
               if(!Test.isRunningTest())
                        queue = [Select id ,q.Queue.Name, q.QueueId From QueueSobject q where q.Queue.Name='Admin Case'];  
              
               //create new admin case
               case newAdminCase = new case();
               
               newAdminCase.Subject ='Contact Information Change';
               
               newAdminCase.origin = 'Web';
               newAdminCase.reason = 'User Management';
               newAdminCase.Case_Type__c ='User Role/Profile';
               newAdminCase.ContactId = con.id;
              
              
               if(con.firstName != firstname)
                   newAdminCase.description =  'Please change First Name from ' + con.firstName  + ' to ' +firstname + '\n' ;
               
               if(con.lastName != lastName)
                   newAdminCase.description +=  'Please change Last Name from ' + con.lastName  + ' to ' +lastName  + '\n' ;
               
               if(con.email != email)
                   newAdminCase.description +=  'Please change Email from ' + con.email  + ' to ' +email + '\n' ;
                
               if(con.Employer__r.Name != emplName )
                   newAdminCase.description +=  'Please change Company from ' + con.Employer__r.Name  + ' to ' + emplName + '\n' ;     
               
               newAdminCase.First_Name__c = firstName ;
               newAdminCase.Last_Name__c = lastName  ;
               newAdminCase.email__c = email ;
               newAdminCase.Company_Name__c = emplName ;
               
               newAdminCase.Old_First_Name__c = con.firstName ;
               newAdminCase.Old_Last_Name__c = con.lastName  ;
               newAdminCase.Old_email__c = con.email ;
               newAdminCase.Old_Company_Name__c = con.Employer__r.Name;
               if(queue != null && !queue.isEmpty())
                    newAdminCase.OwnerId = queue[0].QueueId; 
               newAdminCase.sub_status__C ='New';
               if(!recordType.isEmpty())
                newAdminCase.RecordTypeId = recordType[0].id; 
               
               
               insert newAdminCase;  
               
               update con;
                            
               ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm,' We have received your request to update your Contact Information. An Admin Case has been created on your behalf for further review by our Customer Care team.');
               ApexPages.addMessage(myMsg);
               
           }
           else{
                   update con;                  
                   ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Confirm,'Your profile has been updated Successfully.');
                   ApexPages.addMessage(myMsg);
               }
           }catch(System.DMLException e) {
                    ApexPages.addMessages(e);
                    return null;
           }
        
        submitted = true;
        return null;
    }
}