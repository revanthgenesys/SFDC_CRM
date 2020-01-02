public without sharing class AppFoundryDetailExtension {
    public Technology_Market_place_Application__c appFoundryApplication {get;set;}
    public Account paAccount {get;set;}
    public Contact paContact {get;set;}
    public Map<String,String> mapFieldLabelVsHelpText {get;set;}
    public Map<String,String> mapFieldLabelVsHelpTextContact {get;set;}
    public List<MarketplaceApplicationController.wrapperCustomerSolution> customerSolution {get;set;}
    public List<MarketplaceApplicationController.wrapperCompetitors> competitors {get;set;}
    public List<MarketplaceApplicationController.wrapperLicensedUsers> licensedUsers {get;set;}
    public boolean hasAttachment {get;set;}
    public Attachment appFoundryAttachment {get;set;}
    
    public String currentUserProfile {get;set;}
    private Id applicationId;
    
    public AppFoundryDetailExtension(ApexPages.StandardController stdController){     
        
        try{  
            applicationId = ApexPages.currentPage().getParameters().get('id');
            List<Technology_Market_place_Application__c> appFoundryApplications = (List<Technology_Market_place_Application__c>)Database.query(MarketPlaceApplicationControllerHelper.prepareQuery(applicationId));
            System.debug('appFoundryApplications--->'+appFoundryApplications);
            if(!appFoundryApplications.isEmpty()){
                appFoundryApplication = appFoundryApplications[0];
                Id contactId = appFoundryApplication.Primary_contact_Name__c;
                Id accountId = appFoundryApplication.Partner_Account__c;
                paAccount = MarketPlaceApplicationControllerHelper.getAccount(accountId);
                paContact = MarketPlaceApplicationControllerHelper.getContact(contactId);
                paContact.LastName = (paContact.FirstName == null ? '' : paContact.FirstName) + ' ' + paContact.LastName;
                init(applicationId);
                if(appFoundryApplication.Id != null) {
                    appFoundryAttachment = [select Id, Name,body from Attachment where parentId =: appFoundryApplication.Id];     
                    if(appFoundryAttachment != null)
                        hasAttachment = true;
                }            
            }   
        } catch(exception ex) {
            callException(ex);
        }        
    }
    
    public void init(String applicationId){
        
        try{
            mapFieldLabelVsHelpText = MarketPlaceApplicationControllerHelper.getMapOfFieldsAndHelpText();
            customerSolution = MarketPlaceApplicationControllerHelper.intializeCustomerSolution(applicationId);
            competitors = MarketPlaceApplicationControllerHelper.intializeCompetitors(applicationId);
            licensedUsers = MarketPlaceApplicationControllerHelper.intializeLicensedUsers(applicationId);
            currentUserProfile = MarketPlaceApplicationControllerHelper.getCurrentUserProfile();
        } catch(exception ex) {
            callException(ex);
        }                 
    }
    
    
    public void callException( Exception ex){
        String subject = 'Error in the Application Detail Page.';
        String htmlBody1 = 'Hi <br/><br/>';
        htmlBody1 += 'Error Details :' + ex.getMessage();            
        SendEmail.sendSingleEmail(Label.Admin_Emails, subject, htmlBody1, 'Partner');  
        PageReference newpg;
        newpg = new Pagereference('/PartnerPortal_ErrorPage?eParameter='+ex.getMessage());
    }
}