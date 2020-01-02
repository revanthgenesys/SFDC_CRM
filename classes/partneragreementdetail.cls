public class partneragreementdetail {

    private Id applicationId;
    private Id accountId;
     private Id contactId;
    public Partner_Application__c partner {get;set;}
    public Account accList {get; set;}
    public Contact conList {get; set;}
    public Boolean istrue {get; set;}
    public partneragreementdetail(){ 
    applicationId = ApexPages.currentPage().getParameters().get('appId');
         accountId = ApexPages.currentPage().getParameters().get('accid');
      contactId =ApexPages.currentPage().getParameters().get('conid');
       istrue=true;
    partner=get(applicationId);
    accList=getAccount(accountId);
    conList=getContact(contactId);
         
    }
    public static Partner_Application__c get(String applicationId){  
       Partner_Application__c partner=[Select Account__c,Contact__c,Company_Name__c,Corporate_name__c from Partner_Application__c where id=:applicationId];
    return partner;
    }
    public static Account getAccount(String accountId){  
        Account newAccount = [SELECT Name, Website, ZipCode__c, Phone, Fax, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,   
            Business_Country__c, Commercial_Registration_Number__c, Company_Type__c, Executive_Mgmt_Emakil__c, Executive_Mgmt_Name__c,
            Finance_Name__c, Incorporation_Location__c, Industries_Comment__c, No_Of_Customers__c, No_Of_Sales_Rep__c, Partner_Program_Status__c,
            SIC_Code__c, VAT_Number__c, YearStarted, Approval_Status__c, Country__c, StateProvince__c, Street1__c, Street2__c, Street3__c,
            Related_Company_Name__c, Jurisdiction_of_Incorporation__c, Date_Of_Company_Formation__c, Vertical_Markets__c,
            Anticipated_Terro__c, Publicaly_or_Privately_Owned__c, AnnualRevenue, NumberOfEmployees, Industry,Industry__c FROM Account WHERE id =: accountId];
        return newAccount;
    }
     public static Contact getContact(String contactId){
        Contact newContact = [SELECT FirstName, LastName, Title, Email, Phone, Fax, MailingStreet, MailingCity, MailingCountry, MailingState, 
            MailingPostalCode, Additional_Comments__c, Certification_Name__c, Certification_Year_Achieved__c, Owner_Percent__c, ContactPhone__c,
            ContactFax__c, Country__c,Street1__c, Street2__c, Street3__c,city__c,StateProvince__c,ZipCode__c FROM Contact WHERE id =: contactId];
        return newContact;
    }
   
}