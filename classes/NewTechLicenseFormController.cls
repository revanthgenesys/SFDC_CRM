public without sharing class NewTechLicenseFormController {
    public Map<String,String> mapFieldLabelVsHelpText {get;set;}
    public Technology_License_Form__c newLicenseForm {get;set;}
    public Id applicationId;
    public Boolean isNew {get;set;}
    public Boolean isView {get;set;}
    public Boolean isSubmitted {get;set;}
    public boolean hasAppFoundryApproved {get;set;}
    public boolean appFoundryApplicationNotRequired {get;set;}
    public List<Attachment> licenseAttachment {get;set;}
    public Integer step {get;set;}
    public Id userAccountId;
    
    public NewTechLicenseFormController(ApexPages.StandardController stdController) {
        userAccountId = getUserAccountId(); 
        
        User currentUser = [SELECT Id, Name, Contact.AccountId, Contact.Account.AppFoundry_Application_Not_Required__c from User where Id = :Userinfo.getUserid()];
        appFoundryApplicationNotRequired = currentUser.Contact.Account.AppFoundry_Application_Not_Required__c;
        Integer approvedAppFoundryCount = [select count() from Technology_Market_place_Application__c where Partner_Account__c =: currentUser.Contact.AccountId and Status__c = 'Approved'];
        
        step = 0;
        licenseAttachment = new List<Attachment>();
        Attachment att = new Attachment();
        licenseAttachment.add(att);
        isView = false;
        isNew = false;
        isSubmitted = false;
        hasAppFoundryApproved = false;

        newLicenseForm = new Technology_License_Form__c();
        mapFieldLabelVsHelpText = getMapOfFieldsAndHelpText();

        if(approvedAppFoundryCount > 0 || appFoundryApplicationNotRequired) {

            hasAppFoundryApproved = true;
            applicationId = ApexPages.currentPage().getParameters().get('id');
            if(applicationId != null) {
                newLicenseForm = getLicenseFormDetails(); 
                isView = true;
                retriveAttachment();
            }
            else {
                isNew = true;
            }
        }
        
        
    }
    
    public Technology_License_Form__c getLicenseFormDetails() {
        newLicenseForm = [select Id,Country_of_sale__c,Date_of_billing__c,Product_Sold__c,Number_of_Licenses_sold__c,Sales_price_per_license__c,Customer_Name__c, Invoicing_Model__c,Involved_Genesys_Sales_Person_s__c,Sales_Currency__c,Total_sale__c,Partner_Account__c from Technology_License_Form__c where Id =:applicationId];    
        return newLicenseForm;
    }
    
    public PageReference save() {
        System.debug('testing-----');
        try {
            Id userAccountId = getUserAccountId();
            newLicenseForm.Partner_Account__c = userAccountId;
            insert newLicenseForm; 
            isView = false;
            isSubmitted = false;
            step = 1;
        }
        catch(Exception e) {
            licenseAttachment.clear();      
        }
        return null;
    }
    
    public pageReference submit() {
        if(licenseAttachment.isEmpty() || licenseAttachment[0].name == null) {  
            ApexPages.addMessage(new ApexPages.message(Apexpages.Severity.ERROR, 'Please attach Purchase Order'));              
            return null;
        }
        insertAttachement(licenseAttachment[0],newLicenseForm.Id);
        licenseAttachment.clear(); 
        isSubmitted = true;
        isNew = false;
        return null;
    }
    
    public List<Technology_License_Form__c> getTechnologyLicenseForm() {
        List<Technology_License_Form__c> technologyLicenseFormList = new List<Technology_License_Form__c>();
        technologyLicenseFormList =[select Id from Technology_License_Form__c where OwnerId =: userinfo.getuserid()];
        return technologyLicenseFormList;
    }
    
    public static Map<String,String> getMapOfFieldsAndHelpText() {
        String objName ='Technology_License_Form__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objName);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String, String> mapFieldLabelVsHelpText = new Map<String, String>();
        for (String fieldName: fieldMap.keySet()) {
            String label = fieldMap.get(fieldName).getDescribe().getLabel();
            String helpText = fieldMap.get(fieldName).getDescribe().getInlineHelpText();
            if(helpText == null || helpText == '')
                helpText = label;
            mapFieldLabelVsHelpText.put(label, helpText);
        }       
        return mapFieldLabelVsHelpText;
    }
    
    public static void insertAttachement(Attachment att, String licenseFormId) {
        att.parentId = licenseFormId;
        upsert att;
    } 
    
    public void retriveAttachment() {
        if(newLicenseForm.Id != null) {
            licenseAttachment = [select Id, Name from Attachment where parentId =: newLicenseForm.Id];     
        }
    }
    
    public static Id getUserAccountId() {
        List<User> currentUser = [select Contact.AccountId from User where Id =:Userinfo.getUserid()];
        System.debug('currentUser---'+currentUser);
        return currentUser[0].Contact.AccountId;    
    }
    
    /*public pageReference calculateTotalSalesPrice() {
        if(newLicenseForm.Sales_price_per_license__c == null)
            newLicenseForm.Sales_price_per_license__c = 0.00; 
        newLicenseForm.Total_sale__c = newLicenseForm.Sales_price_per_license__c * newLicenseForm.Number_of_Licenses_sold__c;    
        return null;
    }*/
}