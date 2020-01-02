//Naresh Kumar  01/17/2013
public without sharing class PartnerApplicationControllerHelper {

    public static PartnerApplicationController.wholeApplication init(Partner_Application__c newApplication, Account newAccount, Contact newContact, Boolean isNewApplication){
        
        List<Partner_Application__c> partnerApplications = (List<Partner_Application__c>)Database.query(prepareQuery());
        String contactId;
        String accountId;
        if(partnerApplications.isEmpty() || isNewApplication){
            newApplication = new Partner_Application__c();
            List<User> currentUser = [SELECT contactId, Contact.AccountId FROM User WHERE id =: UserInfo.getUserId()];
            if(!currentUser.isEmpty()){
                contactId = currentUser[0].contactId;
                accountId = currentUser[0].Contact.AccountId;
            }           
        }
        else{
            //Populating application record
            newApplication = partnerApplications[0]; 
            contactId = newApplication.Contact__c;
            accountId = newApplication.Account__c;          
        }
        //contactId = '003U000000wG2k0IAC';//'003Z000000db1yU';
        //accountId = '001U000000mE92sIAC';//'001Z000000itIGX';
        //Populating account record 
        newAccount = getAccount(accountId);
        //Populating contact record
        newContact = getContact(contactId);
        PartnerApplicationController.wholeApplication newObject = new PartnerApplicationController.wholeApplication();
        newObject.newApplication = newApplication;
        newObject.newAccount = newAccount;
        newObject.newContact = newContact;
        //newObject.newContact.LastName = (newObject.newContact.FirstName == null? '' : newObject.newContact.FirstName) + ' ' + newObject.newContact.LastName; 
        
        return newObject;     
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
    
    
    private static String prepareQuery(){
        return prepareQuery('In Progress');
    }
    
    public static String prepareQuery(Id applicationId){
        String queryAllFields = 'SELECT ';
        //Getting all the fields for the object, Not in mood of copy each field name manually.      
        Set<String> fieldSet = Schema.SObjectType.Partner_Application__c.fields.getMap().keySet();
        for(String eachFieldName : fieldSet){
            queryAllFields += eachFieldName + ', ';
        }
        queryAllFields = queryAllFields.substring(0, queryAllFields.lastIndexOf(','));      
        queryAllFields += ', Account__r.Name, Contact__r.Name FROM Partner_Application__c WHERE id = \'' + applicationId + '\' ORDER BY CreatedDate DESC';// AND Status__c IN (\''  + status + '\')';
        //queryAllFields += ' FROM Partner_Application__c WHERE For_User__c = \'' + '005Z0000001QWUZ' + '\' AND Status__c IN (\''  + status + '\')';
        return queryAllFields;
    }
    
    private static String prepareQuery(String status){
        String queryAllFields = 'SELECT ';
        //Getting all the fields for the object, Not in mood of copy each field name manually.      
        Set<String> fieldSet = Schema.SObjectType.Partner_Application__c.fields.getMap().keySet();
        for(String eachFieldName : fieldSet){
            queryAllFields += eachFieldName + ', ';
        }
        queryAllFields = queryAllFields.substring(0, queryAllFields.lastIndexOf(','));      
        queryAllFields += ', Account__r.Name, Contact__r.Name FROM Partner_Application__c WHERE For_User__c = \'' + UserInfo.getUserId() + '\' ORDER BY CreatedDate DESC';// AND Status__c IN (\''  + status + '\')';
        //queryAllFields += ' FROM Partner_Application__c WHERE For_User__c = \'' + '005Z0000001QWUZ' + '\' AND Status__c IN (\''  + status + '\')';
        return queryAllFields;
    }
    
    public static List<Partner_Application__c> getExistingApplication(){
        List<Partner_Application__c> partnerApplications = (List<Partner_Application__c>)Database.query(prepareQuery(''));
        return partnerApplications;
    }
    @future
    public static void disableUser(List<String> userIds){ 
        
        List<User> usersTOBeDisabled = [SELECT IsActive FROM User WHERE id IN  : userIds];
        for(User eachUser : usersTOBeDisabled)
            eachUser.isActive = false;
        if(!usersTOBeDisabled.isEmpty()){           
            update usersTOBeDisabled;
        }
    }
    
    private static Contact populateFirstNameLastName(Contact newContact){
        List<String> names = newContact.LastName.split(' ');
        newContact.LastName = '';
        newContact.FirstName = '';
        if(names.size() == 1){
            newContact.LastName = names[0]; 
        }       
        else if(names.size() > 1){
            newContact.FirstName = names[0];
            for(Integer i = 1; i < names.size(); i++)
                newContact.LastName = newContact.LastName + ' ' + names[i];         
        }
        return newContact;
    }
     
    public static boolean save(Partner_Application__c newApplication, 
                            Account newAccount, 
                            Contact newContact,
                            List<PartnerApplicationController.wrapperExecMgmtList> execMgmtList, 
                            List<PartnerApplicationController.wrapperCompanyOwnershipList> companyOwnershipList,
                            List<PartnerApplicationController.wrapperCategoryAndCountryList> categoryAndCountry,
                            List<PartnerApplicationController.WrapperpaSummaryRatesList> appsummaryRateList,
                            List<Partner_Application_Head_Count__c> list_PAHeadCount, 
                            List<PartnerApplicationController.WrapperpaEmployeeList> paEmployeeList
                            
                            ){
                            boolean IsError = false;
                            System.debug('-----categoryAndCountry----'+categoryAndCountry);
        
      try
      {  
        /* Check category ,Country and Platform Type*/                    
        for(PartnerApplicationController.wrapperCategoryAndCountryList objWrapper : categoryAndCountry)
        {
          if((objWrapper.record.Category__c == null || objWrapper.list_SelectedCountries == null)&& objWrapper.list_SelectedPTType != null)
          {
             
            // throw new applicationException('Please select country and category...');
            //ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 'Please select country and category.'));
            IsError = true;
            break;
          }
        }  
           
           
          // ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 'Please select country and category.'));
        if(!IsError)
        {                     
            update newAccount;  
            //newContact = populateFirstNameLastName(newContact);
            update newContact;
            if(newApplication.Account__c == null)
                newApplication.Account__c = newAccount.id;
            if(newApplication.Contact__c == null){
                newApplication.Contact__c = newContact.id;
                newApplication.Primary_Contact__c = newContact.id;
            }       
            if(newApplication.For_User__c == null)
                newApplication.For_User__c = UserInfo.getUserId();
            System.debug('Hello ... before');                                   
            upsert newApplication;
            System.debug('Hello ... after');                                    
            
            updateChildRecords(newApplication.id, execMgmtList, companyOwnershipList,categoryAndCountry,appsummaryRateList,list_PAHeadCount,paEmployeeList);
            
            if(newApplication.Status__c != null && (newApplication.Status__c.equals('In Progress') || newApplication.Status__c.equals('Submitted')))
                updateUser('Update Reapply Flag');
            if(newApplication.Status__c != null && newApplication.Status__c.equals('Cancelled'))
                updateUser('Deactive User'); 
                 
        }
        
      }
      catch(Exception ex)      
      {
        throw(ex);
        //ApexPages.addMessage(new ApexPages.message (ApexPages.SEVERITY.ERROR, 'Please select country and category.'));
      }
      return IsError;
    }   
    
    private static void updateChildRecords(String partnerApplicationId, 
                                           List<PartnerApplicationController.wrapperExecMgmtList> execMgmtList, 
                                           List<PartnerApplicationController.wrapperCompanyOwnershipList> companyOwnershipList,
                                           List<PartnerApplicationController.wrapperCategoryAndCountryList> categoryAndCountry,
                                           List<PartnerApplicationController.WrapperpaSummaryRatesList> appsummaryRateList ,
                                           List<Partner_Application_Head_Count__c> list_PAHeadCount,  
                                           List<PartnerApplicationController.WrapperpaEmployeeList> paEmployeeList
                                           ){
        List<Executive_Management_Team__c> execMgmtTeamRecordsToBeDeleted = [SELECT id FROM Executive_Management_Team__c WHERE Partner_Application__c =: partnerApplicationId];
        //Deleting existing records     
        if(!execMgmtTeamRecordsToBeDeleted.isEmpty())   
            delete execMgmtTeamRecordsToBeDeleted;
        List<Company_Ownership__c> execCompanyOwnershipRecordsToBeDeleted = [SELECT id FROM Company_Ownership__c WHERE Partner_Application__c =: partnerApplicationId];
        if(!execCompanyOwnershipRecordsToBeDeleted.isEmpty())   
            delete execCompanyOwnershipRecordsToBeDeleted;  
        List<Partner_Application_Category_and_Country__c> categorAndCountryRecordsToBeDeleted = [SELECT id FROM Partner_Application_Category_and_Country__c WHERE Partner_Application__c =:partnerApplicationId];
        if(!categorAndCountryRecordsToBeDeleted.isEmpty())  
            delete categorAndCountryRecordsToBeDeleted; 
            
        List<Partner_Application_Employee_Info__c> paEmpInfoToBeDeleted = [SELECT id FROM Partner_Application_Employee_Info__c WHERE Partner_Application__c =: partnerApplicationId];
        if(!paEmpInfoToBeDeleted.isEmpty())  
        delete paEmpInfoToBeDeleted; 
        
        List<Partner_Application_Summary_Rate__c> paAppSummaryToBeDeleted = [select id from Partner_Application_Summary_Rate__c where Partner_Application__c =: partnerApplicationId];
        if(!paAppSummaryToBeDeleted.isEmpty())
        delete paAppSummaryToBeDeleted;
                
        //Inserting records;
        List<Executive_Management_Team__c> execMgmtTeamRecordsToBeInserted = new List<Executive_Management_Team__c>();
        for(PartnerApplicationController.wrapperExecMgmtList eachRecord : execMgmtList){
            if(eachRecord.record.Name == null || eachRecord.record.Name == '')
                continue;
            Executive_Management_Team__c newRecord = new Executive_Management_Team__c();
            newRecord.Partner_Application__c = partnerApplicationId;
            newRecord.Name = eachRecord.record.Name;
            newRecord.Email__c = eachRecord.record.Email__c;
            newRecord.Position__c = eachRecord.record.Position__c;          
            execMgmtTeamRecordsToBeInserted.add(newRecord);
        }
        List<Company_Ownership__c> companyOwnershipRecordsToBeInserted = new List<Company_Ownership__c>();
        for(PartnerApplicationController.wrapperCompanyOwnershipList eachRecord : companyOwnershipList){
            if(eachRecord.record.Name == null || eachRecord.record.Name == '')
                continue;
            if(eachRecord.record.Partner_Application__c == null)
                eachRecord.record.Partner_Application__c = partnerApplicationId;
            Company_Ownership__c newRecord = new Company_Ownership__c();
            newRecord.Partner_Application__c = partnerApplicationId;            
            newRecord.Name = eachRecord.record.Name;
            newRecord.Ownership__c = eachRecord.record.Ownership__c;
            newRecord.Person_Firm__c = eachRecord.record.Person_Firm__c;            
            companyOwnershipRecordsToBeInserted.add(newRecord);
        }
        
         List<Partner_Application_Employee_Info__c> employeeRecordsToBeInserted = new List<Partner_Application_Employee_Info__c>();
                for(PartnerApplicationController.WrapperpaEmployeeList eachRecord : paEmployeeList){
            if(eachRecord.record.Employee_Name__c == null || eachRecord.record.Employee_Name__c == '')
                continue;
            if(eachRecord.record.Partner_Application__c == null)
                eachRecord.record.Partner_Application__c = partnerApplicationId;
            Partner_Application_Employee_Info__c newRecord = new Partner_Application_Employee_Info__c();
            newRecord.Partner_Application__c = partnerApplicationId;            
            newRecord.Employee_Name__c = eachRecord.record.Employee_Name__c;
            newRecord.Certification_Name__c = eachRecord.record.Certification_Name__c;
            newRecord.Year_Aheived__c = eachRecord.record.Year_Aheived__c;  
            newRecord.Resource_Country_of_Residence__c = eachRecord.record.Resource_Country_of_Residence__c;          
            employeeRecordsToBeInserted.add(newRecord);
        }
        
        //creating new records for Partner_Application_Summary_Rate__c
        List<Partner_Application_Summary_Rate__c> appSummaryRecordsToBeInserted = new List<Partner_Application_Summary_Rate__c>();
        system.debug(
        'PartnerApplicationControllerHelper.appsummaryRateList-->'+appsummaryRateList);
                for(PartnerApplicationController.WrapperpaSummaryRatesList eachRecord : appsummaryRateList){
           
            if(eachRecord.record.Partner_Application__c == null)
                eachRecord.record.Partner_Application__c = partnerApplicationId;
                
            Partner_Application_Summary_Rate__c newRecord = new Partner_Application_Summary_Rate__c();
            newRecord.Partner_Application__c = partnerApplicationId;            
            newRecord.Resource_or_Skill_Type__c = eachRecord.record.Resource_or_Skill_Type__c;
            newRecord.Rate_or_Rate_Range__c = eachRecord.record.Rate_or_Rate_Range__c;
            newRecord.Currency_Type__c = eachRecord.record.Currency_Type__c;  
            newRecord.Comments__c = eachRecord.record.Comments__c;          
            appSummaryRecordsToBeInserted.add(newRecord);
        }
        
        
        
        
        List<Partner_Application_Head_Count__c> employeeHeadCountToInsert = new List<Partner_Application_Head_Count__c>();
        List<Partner_Application_Head_Count__c> employeeHeadCountToupdate = new List<Partner_Application_Head_Count__c>();
        
        for (Partner_Application_Head_Count__c eachHead : list_PAHeadCount)
        {
          if(eachHead.Partner_Application__c == null)
          {
            eachHead.Partner_Application__c = partnerApplicationId;
          }
          
          if(eachHead.id != null)
          {
            employeeHeadCountToupdate.add(eachHead);
          }else{
            employeeHeadCountToInsert.add(eachHead);
          }
        } 
        
        List<Partner_Application_Category_and_Country__c> categoryAndCountryToBeInserted = new List<Partner_Application_Category_and_Country__c>();
        /*
        for(PartnerApplicationController.wrapperCategoryAndCountryList eachRecord : categoryAndCountry)
        {
            if(eachRecord.record.Country__c == null)
                continue;
            if(eachRecord.record.Partner_Application__c == null)
                eachRecord.record.Partner_Application__c = partnerApplicationId;
            Partner_Application_Category_and_Country__c newRecord = new Partner_Application_Category_and_Country__c();
            newRecord.Partner_Application__c = partnerApplicationId;            
            newRecord.Country__c = eachRecord.record.Country__c;
            newRecord.Category__c = eachRecord.record.Category__c;
            newRecord.Comments__c = eachRecord.record.Comments__c;
            //newRecord.Approved__c = eachRecord.record.Approved__c;                      
            categoryAndCountryToBeInserted.add(newRecord);
        }*/
        
        for(PartnerApplicationController.wrapperCategoryAndCountryList objWrapper : categoryAndCountry)
        {
            if(objWrapper.record.Category__c != null && objWrapper.record.Category__c != '')
            {
                for(SelectOption objSelectedCountryOption : objWrapper.list_SelectedCountries)
                {
                    Partner_Application_Category_and_Country__c objNewRecord = new Partner_Application_Category_and_Country__c();
                    objNewRecord.Partner_Application__c = partnerApplicationId; 
                    objNewRecord.Country__c = objSelectedCountryOption.getValue();
                    objNewRecord.Category__c = objWrapper.record.Category__c;
                    
                    for(SelectOption objSelectedPTT : objWrapper.list_SelectedPTType){
                        objNewRecord.PlatformType__c = objNewRecord.PlatformType__c != null?objNewRecord.PlatformType__c + ';' + objSelectedPTT.getvalue():objSelectedPTT.getValue();
                    }
                    
                    objNewRecord.Company_partner_CX_space__c = objWrapper.record.Company_partner_CX_space__c;
                    objNewRecord.Genesys_AppFoundry__c = objWrapper.record.Genesys_AppFoundry__c;
                    objNewRecord.Project_priority_in_your_Development__c = objWrapper.record.Project_priority_in_your_Development__c;
                    objNewRecord.Reason_for_integration__c = objWrapper.record.Reason_for_integration__c;
                    system.debug('+++++objNewRecord.PlatformType__c+++'+objNewRecord.PlatformType__c);
                    
                    categoryAndCountryToBeInserted.add(objNewRecord);
                    
                }
             }
        }
        system.debug('+++categoryAndCountryToBeInserted+++'+categoryAndCountryToBeInserted);
        if(!execMgmtTeamRecordsToBeInserted.isEmpty()){
            insert execMgmtTeamRecordsToBeInserted;
        }
        if(!companyOwnershipRecordsToBeInserted.isEmpty()){
            insert companyOwnershipRecordsToBeInserted;
        }
        if(!categoryAndCountryToBeInserted.isEmpty()){
            insert categoryAndCountryToBeInserted;
        }
      
       if(!employeeRecordsToBeInserted.isEmpty()){
            insert employeeRecordsToBeInserted;
        }
        
        if(!appSummaryRecordsToBeInserted.isEmpty()){
            insert appSummaryRecordsToBeInserted;
        }
        
        
        if(!employeeHeadCountToInsert.isEmpty())
        {
            insert employeeHeadCountToInsert;
        }  
        
        if(!employeeHeadCountToupdate.isEmpty())
        {
            update employeeHeadCountToupdate;
        }
    }
    
    @future
    private static void updateUser(String updateType){
        User currentUser = new User( id = UserInfo.getUserId() );
        if(updateType == 'Update Reapply Flag')
            currentUser.Allow_Potential_Partner_to_Reapply__c = false;
        if(updateType == 'Deactive User')
            currentUser.Deactivate_User__c = true;
        update currentUser;
    }
    
    public static void submitPartnerApplicationToApprovalProcess(Partner_Application__c newApplication){
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Request submitted for approval automatically.');
        req.setObjectId(newApplication.id);
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req);
    }
    
    public static Map<String,String> getMapOfFieldsAndHelpText(){
        String objName ='Partner_Application__c';
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
        mapFieldLabelVsHelpText.put('Account Name', 'Company Name (Full Legal Company Name including legal entity designation suffix (e.g. B.V., GmbH, S.P.A.))');
        mapFieldLabelVsHelpText.put('Related Company Name','Related company name(s): (Holding company, subsidiaries, DBAs (doing business as))');
        mapFieldLabelVsHelpText.put('Website','Company Website');
        mapFieldLabelVsHelpText.put('Phone','HQ Phone');
        mapFieldLabelVsHelpText.put('Fax','HQ Fax');
        mapFieldLabelVsHelpText.put('Industry','Select Industries and Vertical Markets');
        mapFieldLabelVsHelpText.put('Vertical','Vertical');
        
        mapFieldLabelVsHelpText.put('Contact Us Email','Contact Us Email or URL');
        mapFieldLabelVsHelpText.put('Address 1','HQ Address 1');
        mapFieldLabelVsHelpText.put('Address 2','HQ Address 2');
        mapFieldLabelVsHelpText.put('Address 3','HQ Address 3');
        mapFieldLabelVsHelpText.put('Billing City','Billing City');     
        mapFieldLabelVsHelpText.put('State/Province','State/Province');
        mapFieldLabelVsHelpText.put('Country','Country');       
        mapFieldLabelVsHelpText.put('Jurisdiction of Incorporation','Jurisdiction of Incorporation (Country / State / Province)');
        mapFieldLabelVsHelpText.put('Date Of Company Formation','Date Of Company Formation');
        mapFieldLabelVsHelpText.put('Commercial Registration Number','Commercial Registration Number');
        mapFieldLabelVsHelpText.put('VAT Number','VAT Number');
        mapFieldLabelVsHelpText.put('SIC Code','Standard Industrial Classification Code (SIC)');
        mapFieldLabelVsHelpText.put('Anticipated Territories and Country','Territory and Countries where you anticipate doing business with Genesys (list individual countries)');
        mapFieldLabelVsHelpText.put('Publicaly or Privately Owned','Is your organization publicly or privately owned?');
        mapFieldLabelVsHelpText.put('Revenue','Annual Revenues');
        mapFieldLabelVsHelpText.put('No Of Customers','Approximate Number of Customers');
        mapFieldLabelVsHelpText.put('Employees','Approximate Number of Employees');
        mapFieldLabelVsHelpText.put('No Of Sales Rep','Number of Sales Reps per Territory / Region');
        mapFieldLabelVsHelpText.put('Vertical Markets','Vertical Markets');
        mapFieldLabelVsHelpText.put('10% Ownership Comments','Do any of the directors or officers of the Company, employees of the Company who will perform services with respect to Genesys products, or persons or firms who have more than 10% ownership of the Company (Company Personnel) hold legislative, administrative or judicial office (whether elected or appointed) at any level of government, or exercise a public function (including for a public agency or public enterprise), or serve as an official or agent of any public international organization? If yes, please provide details.');       
        mapFieldLabelVsHelpText.put('Convicted Executive Comments','Have any Company Executive Management Team Personnel ever been convicted of, or pleaded guilty to, an offense involving fraud or corruption; or been listed by any governmental authority anywhere in the world as debarred, suspended, or otherwise ineligible for government procurement programs?  If yes, please provide details.');
        mapFieldLabelVsHelpText.put('Conflict of Interest Comments','Do any Company Personnel have an actual or potential conflict of interest because of a business, professional, private or family relationship with any of the following: ' +
        ', Actual or potential customer of Genesys' +
        ', Actual or potential competitor or supplier of Genesys ' +
        ', Director or employee of Genesys ' +
        'If yes, please provide details.');
        return mapFieldLabelVsHelpText;
    }
    
    public static Map<String,String> getMapOfFieldsAndHelpTextContact(){
        Map<String, String> mapFieldLabelVsHelpText = new Map<String, String>();
        mapFieldLabelVsHelpText.put('Contact Name','Name');
        mapFieldLabelVsHelpText.put('Job Title','Title');
        mapFieldLabelVsHelpText.put('Email','Email');       
        mapFieldLabelVsHelpText.put('Contact Phone','Phone Number');
        mapFieldLabelVsHelpText.put('Contact Fax','FAX Number');
        //mapFieldLabelVsHelpText.put('Address 1','Address 1 (put �same� if same as HQ address)');
        mapFieldLabelVsHelpText.put('Address 1','Address 1');
        mapFieldLabelVsHelpText.put('Address 2','Address 2');
        mapFieldLabelVsHelpText.put('Address 3','Address 3');
        mapFieldLabelVsHelpText.put('Mailing City','City');
        mapFieldLabelVsHelpText.put('Mailing State/Province','State/Province');
        mapFieldLabelVsHelpText.put('Mailing Zip/Postal Code','Zip/Postal Code');
        mapFieldLabelVsHelpText.put('Country','Country');
        mapFieldLabelVsHelpText.put('Last Name','Last Name');
        return mapFieldLabelVsHelpText;
    }
    
    public static List<PartnerApplicationController.wrapperExecMgmtList> intializeExeMgmgTeamList(String partnerApplicationId){
        List<PartnerApplicationController.wrapperExecMgmtList> execMgmtTeam = new List<PartnerApplicationController.wrapperExecMgmtList>();
        if(partnerApplicationId != null){
            List<Executive_Management_Team__c> execMgmtTeamRecords = [SELECT Position__c, Name, Email__c, Partner_Application__c FROM Executive_Management_Team__c 
            WHERE Partner_Application__c =: partnerApplicationId];
            Integer index = 0;
            for(Executive_Management_Team__c eachRecord : execMgmtTeamRecords){
                PartnerApplicationController.wrapperExecMgmtList newRecord = new PartnerApplicationController.wrapperExecMgmtList();
                newRecord.record = eachRecord;
                newRecord.index = index;
                index ++;
                execMgmtTeam.add(newRecord);
            }
                
        }
        if(execMgmtTeam.isEmpty()){
            execMgmtTeam = addNewRowToexecMgmtTeamList(execMgmtTeam);       
        }
        return execMgmtTeam;
    }
    
    public static List<PartnerApplicationController.wrapperExecMgmtList> addNewRowToexecMgmtTeamList(List<PartnerApplicationController.wrapperExecMgmtList> execMgmtTeam){
        PartnerApplicationController.wrapperExecMgmtList newRecord = new PartnerApplicationController.wrapperExecMgmtList();
        Executive_Management_Team__c newTeamRecord = new Executive_Management_Team__c();        
        newRecord.record = newTeamRecord;
        newRecord.index = execMgmtTeam.size();
        execMgmtTeam.add(newRecord);
        return execMgmtTeam;
    }
    
    public static List<PartnerApplicationController.wrapperExecMgmtList> removeRowFromExecMgmtTeamList(Integer rowToRemove, List<PartnerApplicationController.wrapperExecMgmtList> execMgmtTeam){
        execMgmtTeam.remove(rowToRemove);
        return execMgmtTeam;
    }
    
    public static List<PartnerApplicationController.wrapperCompanyOwnershipList> intializeCompanyOwnershipList(String partnerApplicationId){
        List<PartnerApplicationController.wrapperCompanyOwnershipList> companyOwnership = new List<PartnerApplicationController.wrapperCompanyOwnershipList>();
        if(partnerApplicationId != null){
            List<Company_Ownership__c> companyOwnershipRecords = [SELECT Person_Firm__c, Name, Ownership__c, Partner_Application__c FROM Company_Ownership__c 
            WHERE Partner_Application__c =: partnerApplicationId];
            Integer index = 0;
            for(Company_Ownership__c eachRecord : companyOwnershipRecords){
                PartnerApplicationController.wrapperCompanyOwnershipList newRecord = new PartnerApplicationController.wrapperCompanyOwnershipList();
                newRecord.record = eachRecord;
                newRecord.index = index;
                index ++;
                companyOwnership.add(newRecord);
            }
                
        }
        if(companyOwnership.isEmpty()){
            companyOwnership = addNewRowToCompanyOwnershipList(companyOwnership);       
        }
        return companyOwnership;
    }
    
    
    public static List<PartnerApplicationController.wrapperCompanyOwnershipList> addNewRowToCompanyOwnershipList(List<PartnerApplicationController.wrapperCompanyOwnershipList> companyOwnership){
        PartnerApplicationController.wrapperCompanyOwnershipList newRecord = new PartnerApplicationController.wrapperCompanyOwnershipList();
        Company_Ownership__c newTeamRecord = new Company_Ownership__c();        
        newRecord.record = newTeamRecord;
        newRecord.index = companyOwnership.size();
        companyOwnership.add(newRecord);
        return companyOwnership;
    }
    
        
    public static List<PartnerApplicationController.wrapperCompanyOwnershipList> removeRowFromCompanyOwnershipList(Integer rowToRemove, List<PartnerApplicationController.wrapperCompanyOwnershipList> companyOwnership){
        companyOwnership.remove(rowToRemove);
        return companyOwnership;
    }
    
     public static List<PartnerApplicationController.WrapperpaEmployeeList> intializeEmployeeList(String partnerApplicationId){
     List<PartnerApplicationController.WrapperpaEmployeeList> paEmployeeList = new List<PartnerApplicationController.WrapperpaEmployeeList>();
     if(partnerApplicationId != null){
            List<Partner_Application_Employee_Info__c> companyEmpployeeRecords = [SELECT Name,Partner_Application__c,Employee_Name__c,Certification_Name__c,Year_Aheived__c,Resource_Country_of_Residence__c FROM Partner_Application_Employee_Info__c 
            WHERE Partner_Application__c =: partnerApplicationId];
            Integer index = 0;
            if(companyEmpployeeRecords !=null && companyEmpployeeRecords.size()>0){
            for(Partner_Application_Employee_Info__c eachRecord : companyEmpployeeRecords){
                PartnerApplicationController.WrapperpaEmployeeList newRecord = new PartnerApplicationController.WrapperpaEmployeeList();
                newRecord.record = eachRecord;
                newRecord.index = index;
                index ++;
                paEmployeeList.add(newRecord); 
            }
           }
                
        }
        if(paEmployeeList.isEmpty()){
            paEmployeeList = addNewRowToEmployeeList(paEmployeeList);       
        }
        return paEmployeeList;
     }
     
     /*
      mehotd is used for initialize summary rates.
     */
     
   public static List<PartnerApplicationController.WrapperpaSummaryRatesList> intializeSummaryRatesList(String partnerApplicationId){
     List<PartnerApplicationController.WrapperpaSummaryRatesList> summaryRatesList = new List<PartnerApplicationController.WrapperpaSummaryRatesList>();
     if(partnerApplicationId != null){
            List<Partner_Application_Summary_Rate__c> summaryRatesRecords = [SELECT Name,Partner_Application__c,Comments__c,Currency_Type__c,Rate_or_Rate_Range__c,Resource_or_Skill_Type__c FROM Partner_Application_Summary_Rate__c    
            WHERE Partner_Application__c =: partnerApplicationId];
            Integer index = 0;
            for(Partner_Application_Summary_Rate__c eachRecord : summaryRatesRecords){
                PartnerApplicationController.WrapperpaSummaryRatesList newRecord = new PartnerApplicationController.WrapperpaSummaryRatesList();
                newRecord.record = eachRecord;
                newRecord.index = index;
                index ++;
                summaryRatesList.add(newRecord); 
            }
                
        }
        if(summaryRatesList.isEmpty()){
            summaryRatesList = addNewRowToSummaryRatesList(summaryRatesList);       
        }
        return summaryRatesList;
     }
     
     
       public static List<PartnerApplicationController.WrapperpaSummaryRatesList> addNewRowToSummaryRatesList(List<PartnerApplicationController.WrapperpaSummaryRatesList> sumaryRatesList){
        PartnerApplicationController.WrapperpaSummaryRatesList newRecord = new PartnerApplicationController.WrapperpaSummaryRatesList();
        Partner_Application_Summary_Rate__c newSummaryRecord = new Partner_Application_Summary_Rate__c();        
        newRecord.record = newSummaryRecord;
        newRecord.index = sumaryRatesList.size();
        sumaryRatesList.add(newRecord);
        return sumaryRatesList;
    }
     
    
    public static List<PartnerApplicationController.WrapperpaEmployeeList> addNewRowToEmployeeList(List<PartnerApplicationController.WrapperpaEmployeeList> paEmployeeList){
        PartnerApplicationController.WrapperpaEmployeeList newRecord = new PartnerApplicationController.WrapperpaEmployeeList();
        Partner_Application_Employee_Info__c newTeamRecord = new Partner_Application_Employee_Info__c();        
        newRecord.record = newTeamRecord;
        newRecord.index = paEmployeeList.size();
        paEmployeeList.add(newRecord);
        return paEmployeeList;
    }
    
        
    public static List<PartnerApplicationController.WrapperpaSummaryRatesList> removeRowToASumaryList(Integer rowToRemove, List<PartnerApplicationController.WrapperpaSummaryRatesList> sumaryRatesList){
        sumaryRatesList.remove(rowToRemove);
        return sumaryRatesList;
    }
    
           
    public static List<PartnerApplicationController.WrapperpaEmployeeList> removeRowToEmployeeList(Integer rowToRemove, List<PartnerApplicationController.WrapperpaEmployeeList> paEmployeeList){
        paEmployeeList.remove(rowToRemove);
        return paEmployeeList;
    }
    
    
    public static String getCurrentUserProfile(){
        Profile currentUserProfile = [SELECT Name FROM Profile WHERE id =: UserInfo.getProfileId()];
        return currentUserProfile.Name;
    }
    public static List<Partner_Application_Industry_Vertical__c> getIndustryNVertical(Id applicationId)
    {
        List<Partner_Application_Industry_Vertical__c> list_IndustryVertical =[SELECT Id, Industry__c, Vertical_Markets__c FROM Partner_Application_Industry_Vertical__c WHERE Partner_Application__c=: applicationId];
        return list_IndustryVertical;
    }
}