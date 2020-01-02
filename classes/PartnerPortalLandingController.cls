/**
 * Partner Portal Landing Controller
 *    - Do we go to home or login page?
 */
public with sharing class PartnerPortalLandingController {

    public PartnerPortalHomeController homeController { get; set; }
      public Account newAccount {get;set;}
    // page load action
    public PageReference forwardToPartnerPortalStart() { 
        if(UserInfo.getUserType() == 'Guest'){
            return new PageReference('/PartnerLogin');
        }
        else{
            //Naresh Kumar 01/20/2014   If the logged in user is Potential partner, redirecting him/her to partner application page.
            Profile pf = [SELECT Name FROM Profile WHERE id =: UserInfo.getProfileId() LIMIT 1];       
            
            system.debug('----------------------------------------pf.Name------------------------------------------------'+pf.Name);
                        
            system.debug('----------------------------------------Label.Customer_Portal_EndUser_PP-----------------------------------------------'+Label.Customer_Portal_EndUser_PP);
            
                 
            if(pf.Name == Label.Potential_Partner_User_Profile_Name || pf.Name == Label.Customer_Portal_EndUser_PP){
                return new PageReference('/PotentialPartnerHome?sfdc.tabName=01rU0000000QELS');
                
            }
            return new PageReference('/Home?sfdc.tabName=01rU0000000QTHz');
        }
    }

    // empty constructor
    public PartnerPortalLandingController() {
        
        homeController = new PartnerPortalHomeController();
        getUser();
    }
   public void getUser() {
        String accountId;      
        List<User> currentUser;
        if(ApexPages.currentPage().getParameters().get('runAs') == null){
                        currentUser = [SELECT contactId, Contact.AccountId FROM User where id =:Userinfo.getUserId()];
                }
                else{
                        String userId = ApexPages.currentPage().getParameters().get('runAs');
                        currentUser = [SELECT contactId, Contact.AccountId FROM User where id = :userId];
                }
        if(!currentUser.isEmpty()){
                accountId = currentUser[0].Contact.AccountId;
                newAccount = getAccount(accountId);
                }
        } 
   
        public static Account getAccount(String accountId){  
        Account newAccount = [SELECT Id,Name, Website, Phone, Fax, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,   
            Business_Country__c, Commercial_Registration_Number__c, Company_Type__c, Executive_Mgmt_Emakil__c, Executive_Mgmt_Name__c,
            Finance_Name__c, Incorporation_Location__c, Industries_Comment__c, No_Of_Customers__c, No_Of_Sales_Rep__c, Partner_Program_Status__c,
            SIC_Code__c, VAT_Number__c, YearStarted, Approval_Status__c, Country__c, StateProvince__c, Street1__c, Street2__c, Street3__c,
            Related_Company_Name__c, Jurisdiction_of_Incorporation__c, Date_Of_Company_Formation__c, Vertical_Markets__c,
            Anticipated_Terro__c, Publicaly_or_Privately_Owned__c, AnnualRevenue, NumberOfEmployees, Industry FROM Account WHERE id =: accountId];
            
        return newAccount;
    } 
}