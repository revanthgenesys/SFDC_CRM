public class LicenseReportExportController {
    public List<Technology_License_Form__c> licenseFormList {get; set;}
    public Id userAccountId;
    
    public LicenseReportExportController() {
    	userAccountId = getUserAccountId(); 
    	licenseFormList = new List<Technology_License_Form__c>();
        init();    
    }
    public void init() {
        licenseFormList = [select Id,Product_Sold__c,Number_of_Licenses_sold__c,Sales_price_per_license__c,Customer_Name__c,Total_sale__c,CreatedDate,Sales_Currency__c,Invoicing_Model__c,Date_of_billing__c,Country_of_sale__c,Involved_Genesys_Sales_Person_s__c from Technology_License_Form__c where Partner_Account__c =: userAccountId];
    }
    
    public static Id getUserAccountId() {
    	List<User> currentUser = [select AccountId from User where Id =: Userinfo.getUserid()];
    	System.debug('currentUser---'+currentUser);
    	return currentUser[0].AccountId;	
    }
}