public class MarketplaceApplicationController {
    public Technology_Market_place_Application__c newApplication {get;set;}
    public List<Technology_Market_place_Application__c> existingApplications {get;set;}
    public Map<String,String> mapFieldLabelVsHelpText {get;set;}
    public Account newAccount {get;set;}
    public Contact newContact {get;set;}
    public List<wrapperCustomerSolution> customerSolution {get;set;}
    public List<wrapperCompetitors> competitors {get;set;}
    public List<wrapperLicensedUsers> licensedUsers {get;set;}
    public Integer rowToRemove {get;set;}
    public Boolean appAlreadySubmitted {get;set;}
    public Boolean hideDetails {get;set;}
    public List<Attachment> appFoundryAttachment {get;set;}
    public boolean hasAttachment {get;set;}
    public boolean updateAttachment {get;set;}
    public Attachment AttachmentToUpdate {get;set;}
    public Integer step {get;set;}
    public boolean appBeingEditedByOther {get;set;} 
    
    private Id applicationId;
	public MarketplaceApplicationController(){
        applicationId = ApexPages.currentPage().getParameters().get('id');
        
        step = 0;
        appFoundryAttachment = new List<Attachment>();
        Attachment att = new Attachment();
        appFoundryAttachment.add(att);
        hasAttachment = false;
        updateAttachment = false;
        Boolean isNewApplication = false;
        appAlreadySubmitted = false;
        appBeingEditedByOther = false;
        // isApplicationAlreadySubmitted();
        System.debug('isNewApplication-->'+isNewApplication);
        wholeMarketPlaceApplication result = MarketPlaceApplicationControllerHelper.init(applicationId);
        newApplication = result.newApplication;
        newAccount = result.newAccount;
        newContact = result.newContact;
        newApplication.Company_Name__c  = newAccount.Name;
        newApplication.Primary_contact_Name__c = newContact.Id;
        newApplication.Primary_Contact_e_mail__c = newContact.Email;
        init();
        //retriveAttachment();
    }
	/*
    public MarketplaceApplicationController(){
        step = 0;
        appFoundryAttachment = new List<Attachment>();
        Attachment att = new Attachment();
        appFoundryAttachment.add(att);
        hasAttachment = false;
        updateAttachment = false;
        Boolean isNewApplication = false;
        appAlreadySubmitted = false;
        appBeingEditedByOther = false;
        isApplicationAlreadySubmitted();
        System.debug('isNewApplication-->'+isNewApplication);
        wholeMarketPlaceApplication result = MarketPlaceApplicationControllerHelper.init(newApplication, newAccount, newContact, isNewApplication);
        newApplication = result.newApplication;
        newAccount = result.newAccount;
        newContact = result.newContact;
        newApplication.Company_Name__c  = newAccount.Name;
        newApplication.Primary_contact_Name__c = newContact.Id;
        newApplication.Primary_Contact_e_mail__c = newContact.Email;
        init();
        //retriveAttachment();
    }
    */
    private void init(){
        mapFieldLabelVsHelpText = MarketPlaceApplicationControllerHelper.getMapOfFieldsAndHelpText();
        customerSolution = MarketPlaceApplicationControllerHelper.intializeCustomerSolution(newApplication.id);
        competitors = MarketPlaceApplicationControllerHelper.intializeCompetitors(newApplication.id);
        licensedUsers = MarketPlaceApplicationControllerHelper.intializeLicensedUsers(newApplication.id);
    }
    
    public void addNewRowTocustomerSolutionList(){
        customerSolution = MarketPlaceApplicationControllerHelper.addNewRowToCustomerSolution(customerSolution);
    }
    
    public void removeRowFromcustomerSolutionList(){
        customerSolution = MarketPlaceApplicationControllerHelper.removeRowFromCustomerSolutionList(rowToRemove, customerSolution);
    }
    
    public void addNewRowToCompetitorList(){
        competitors = MarketPlaceApplicationControllerHelper.addNewRowToCompetitor(competitors);
    }
    
    public void removeRowFromCompetitorList(){
        competitors = MarketPlaceApplicationControllerHelper.removeRowFromCompetitorList(rowToRemove, competitors);
    }
    
    public void addNewRowToLicensedUserList(){
        licensedUsers = MarketPlaceApplicationControllerHelper.addNewRowToLicensedUsers(licensedUsers);
    }
    
    public void removeRowFromLicensedUserList(){
        licensedUsers = MarketPlaceApplicationControllerHelper.removeRowFromLicensedUserList(rowToRemove, licensedUsers);
    }
    
    public pageReference save(){
        // isApplicationAlreadySubmitted();
        
        System.debug('appFoundryAttachment[0].name-->'+appFoundryAttachment[0].name);
        System.debug('step-->'+step);
        if(appBeingEditedByOther == false) { 
       	 MarketPlaceApplicationControllerHelper.save(newApplication,
                                                 newAccount, 
                                                 newContact,
                                                  customerSolution,
                                                  competitors,
                                                  licensedUsers,
                                                  step,  
                                                  appFoundryAttachment[0],
                                                  updateAttachment  
                                                  );  
            ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.INFO, 
                'Application saved sucessfully.'));
        }
        //updateAttachment = false;
        //appFoundryAttachment.clear();
        if(step == 1) {
            hasAttachment = true;
            retriveAttachment();
        }
        return null;
    }
    
    
    
    public void isApplicationAlreadySubmitted(){
        appAlreadySubmitted = false;
        existingApplications = MarketPlaceApplicationControllerHelper.getExistingApplication();
        if(existingApplications.isEmpty())
            appAlreadySubmitted = false;
        for(Technology_Market_place_Application__c eachMA : existingApplications){
            if(eachMA.Status__c.equals('In Progress')){
                appAlreadySubmitted = false;
                if(eachMA.For_User__c != userInfo.getUserId()) {
                	appBeingEditedByOther = true;
                }
                break;
            }
            if(eachMA.Status__c.equals('Approved') || eachMA.Status__c.equals('Submitted') || eachMA.Status__c.equals('In Review')){
                appAlreadySubmitted = true;
                break;
            }               
        }       
    }
    
    public pageReference submit() {
        
        retriveAttachment();
        newApplication.Status__c = 'Submitted'; 
        newApplication.Date_Completed__c = System.now();    
        MarketPlaceApplicationControllerHelper.save(newApplication,
                                                 newAccount, 
                                                 newContact,
                                                  customerSolution,
                                                  competitors,
                                                  licensedUsers,
                                                  step,
                                                  appFoundryAttachment[0],
                                                   updateAttachment);
        ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.INFO, 
            'Application submitted sucessfully.'));
        //updateAttachment = false;
        hasAttachment = true;
        hideDetails = true;
        appFoundryAttachment.clear();
        //retriveAttachment();
        if(newContact.Email != null){
            String htmlBody = 'Hi ' + newContact.FirstName + ',<br/><br/>';
            htmlBody += 'Thank you for your interest in the Genesys AppFoundry.';
            htmlBody += 'Your application has been submitted and awaiting approval. You will receive an email notification when your application has been fully approved or rejected.';
            htmlBody += 'Please reach out to appfoundry@genesys.com if you have any questions in the meantime.<br/><br/>';
            htmlBody += 'Thank you!<br/>';
            htmlBody += 'Your AppFoundry team';
            SendEmail.sendSingleEmail(newContact.Email, 'AppFoundry: Application Submitted Successfully.', htmlBody, 'Genesys Partner Network Program');
        }
        
        try{
        	MarketPlaceApplicationControllerHelper.submitMpApplicationToApprovalProcess(newApplication);
        }catch(Exception ex){
            system.debug(ex);
        }
        return null;
    }
    
    public void retriveAttachment() {
        if(newApplication.Id != null) {
            List<Attachment> ExistingAttachment = [select Id, Name from Attachment where parentId =: newApplication.Id];
            if(!ExistingAttachment.isEmpty()) {
                appFoundryAttachment = ExistingAttachment;
                System.debug('first if stm---');
            }  
            if(appFoundryAttachment[0].Id != null) {
                System.debug('2nd if stm---');
                hasAttachment = true;
            }
            else {
                System.debug(' else stm---');
                hasAttachment = false;
                appFoundryAttachment.add(new Attachment());
            }
        }
    }
    
   	public pageReference next() {
        MarketPlaceApplicationControllerHelper.save(newApplication,
                                                 newAccount, 
                                                 newContact,
                                                  customerSolution,
                                                  competitors,
                                                  licensedUsers,
                                                  step,
                                                  appFoundryAttachment[0],
                                                  updateAttachment  
                                                  );  
        step = 1;
        retriveAttachment();
        return null;
    }
    
   	public PageReference cancelAction(){
        User currentUser = [SELECT id, Name, ContactId, Contact.Account.Name, AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        List<Technology_Market_place_Application__c> afApplications = [SELECT id, Name, Partner_Account__c, Partner_Account__r.Name, Company_Name__c, Date_Completed__c, Solution_Name__c, Status__c, CreatedDate, CreatedBy.Name
                          FROM Technology_Market_place_Application__c 
                          WHERE Partner_Account__c = :currentUser.AccountId];
        PageReference pg;
        if(afApplications.isEmpty()){
	        pg = new PageReference('/partner/Home');
        } else {
	        pg = new PageReference('/partner/AppFoundryApplications');
        } 
        return pg;
    }

    
    //*** Page Action method for re-direction to detail page if appFoundry program application is not in progress ***
    public PageReference redirectToDetailPage(){
        if(newApplication != null && newApplication.Id != null && newApplication.Status__c != 'In Progress')
            return (new PageReference('/partner/AppFoundry_ApplicationDetail?id=' + newApplication.Id));
            
        return null;
    }
    public class wholeMarketPlaceApplication{
        public Technology_Market_place_Application__c newApplication {get;set;}
        public Account newAccount {get;set;}
        public Contact newContact {get;set;}
        
        public wholeMarketPlaceApplication(){
            newApplication = new Technology_Market_place_Application__c();
            newAccount = new Account();
            newContact = new Contact();
        }
    }
    
    public class wrapperCustomerSolution{
        public Integer index {get;set;}
        public Genesys_Customer_Solution__c record {get;set;} 
    }
    
    public class wrapperCompetitors{
        public Integer index {get;set;}
        public MarketPlace_Competitor__c record {get;set;}
    }
    
    public class wrapperLicensedUsers{
        public Integer index {get;set;}
        public Licensed_User_Detail__c record {get;set;}
    }
    
}