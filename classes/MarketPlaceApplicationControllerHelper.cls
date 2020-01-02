public without sharing class MarketPlaceApplicationControllerHelper {

    public static MarketplaceApplicationController.wholeMarketPlaceApplication init(String applicationId){
       ID AppId = applicationId;
       
        Technology_Market_place_Application__c application;
            
        String contactId;
        String accountId;
        if(AppId != null){
            List<Technology_Market_place_Application__c> MarketPlaceApplications = (List<Technology_Market_place_Application__c>)Database.query(prepareQuery(AppId));
            application = MarketPlaceApplications[0];
            contactId = application.Primary_contact_Name__c;
            accountId = application.Partner_Account__c;
        } else {
            application = new Technology_Market_place_Application__c();
            List<User> currentUser = [SELECT contactId, AccountId FROM User WHERE id = :UserInfo.getUserId()];
            if(!currentUser.isEmpty()){
                contactId = currentUser[0].contactId;
                accountId =  currentUser[0].AccountId;
            }          
        }
        
        MarketplaceApplicationController.wholeMarketPlaceApplication newObject = new MarketplaceApplicationController.wholeMarketPlaceApplication();
        newObject.newApplication = application;
        newObject.newAccount = getAccount(accountId);
        newObject.newContact = getContact(contactId);
        
        return newObject;     
    }

    /*
    public static MarketplaceApplicationController.wholeMarketPlaceApplication init(Technology_Market_place_Application__c newApplication, Account newAccount, Contact newContact, Boolean isNewApplication){
        
        List<Technology_Market_place_Application__c> MarketPlaceApplications = (List<Technology_Market_place_Application__c>)Database.query(prepareQuery());
        String contactId;
        String accountId;
        System.debug('MarketPlaceApplications----'+MarketPlaceApplications);
        if(MarketPlaceApplications.isEmpty() || isNewApplication){
            newApplication = new Technology_Market_place_Application__c();
            List<User> currentUser = [SELECT contactId,AccountId FROM User WHERE id =: UserInfo.getUserId()];
            if(!currentUser.isEmpty()){
                contactId = currentUser[0].contactId;
                accountId =  currentUser[0].AccountId;
            }           
        }
        else{
            //Populating application record
            newApplication = MarketPlaceApplications[0]; 
            contactId = newApplication.Primary_contact_Name__c;
            accountId = newApplication.Partner_Account__c;          
        }
        //contactId = '003Z000000db1yU';
        //accountId = '001Z000000itIGX';
        //Populating account record 
        newAccount = getAccount(accountId);
        //Populating contact record
        newContact = getContact(contactId);
        MarketplaceApplicationController.wholeMarketPlaceApplication newObject = new MarketplaceApplicationController.wholeMarketPlaceApplication();
        newObject.newApplication = newApplication;
        newObject.newAccount = newAccount;
        newObject.newContact = newContact;
        //newObject.newContact.LastName = (newObject.newContact.FirstName == null? '' : newObject.newContact.FirstName) + ' ' + newObject.newContact.LastName; 
        
        return newObject;     
    }
    */
    public static Account getAccount(String accountId){  
        Account newAccount = [SELECT Name, Website, Phone, Fax, BillingStreet, BillingCity, BillingCountry, BillingState, BillingPostalCode,   
            Business_Country__c, Commercial_Registration_Number__c, Company_Type__c, Executive_Mgmt_Emakil__c, Executive_Mgmt_Name__c,
            Finance_Name__c, Incorporation_Location__c, Industries_Comment__c, No_Of_Customers__c, No_Of_Sales_Rep__c, Partner_Program_Status__c,
            SIC_Code__c, VAT_Number__c, YearStarted, Approval_Status__c, Country__c, StateProvince__c, Street1__c, Street2__c, Street3__c,
            Related_Company_Name__c, Jurisdiction_of_Incorporation__c, Date_Of_Company_Formation__c, Vertical_Markets__c,
            Anticipated_Terro__c, Publicaly_or_Privately_Owned__c, AnnualRevenue, NumberOfEmployees, Industry FROM Account WHERE id =: accountId];
        return newAccount;
    }
    
    public static Contact getContact(String contactId){
        System.debug('contactId String...>'+contactId);
        system.debug('contact Query...>'+[select Id from Contact where Id=: contactId]);
        Contact newContact = [SELECT Name,FirstName, LastName, Title, Email, Phone, Fax, MailingStreet, MailingCity, MailingCountry, MailingState, 
            MailingPostalCode, Additional_Comments__c, Certification_Name__c, Certification_Year_Achieved__c, Owner_Percent__c, ContactPhone__c,
            ContactFax__c, Country__c,Street1__c, Street2__c, Street3__c   FROM Contact WHERE id =: contactId];
        return newContact;
    }
    
    
    public static String prepareQuery(){
        return prepareQuery('In Progress');
    }
    
    public static String prepareQuery(Id applicationId){
        String queryAllFields = 'SELECT ';
        //Getting all the fields for the object, Not in mood of copy each field name manually.      
        Set<String> fieldSet = Schema.SObjectType.Technology_Market_place_Application__c.fields.getMap().keySet();
        for(String eachFieldName : fieldSet){
            queryAllFields += eachFieldName + ', ';
        }
        queryAllFields = queryAllFields.substring(0, queryAllFields.lastIndexOf(','));      
        queryAllFields += ', Partner_Account__r.Name, Primary_contact_Name__r.Name FROM Technology_Market_place_Application__c WHERE id = \'' + applicationId + '\' ORDER BY CreatedDate DESC';// AND Status__c IN (\''  + status + '\')';
        return queryAllFields;
    }
    
    private static String prepareQuery(String status){
        String queryAllFields = 'SELECT ';
        //Getting all the fields for the object, Not in mood of copy each field name manually.      
        Set<String> fieldSet = Schema.SObjectType.Technology_Market_place_Application__c.fields.getMap().keySet();
        for(String eachFieldName : fieldSet){
            queryAllFields += eachFieldName + ', ';
        }
        queryAllFields = queryAllFields.substring(0, queryAllFields.lastIndexOf(','));   
        Id userAccountId = getUserAccountId();   
        queryAllFields += ', Partner_Account__r.Name, Primary_contact_Name__r.Name FROM Technology_Market_place_Application__c WHERE Partner_Account__c = \'' + userAccountId + '\' ORDER BY CreatedDate DESC';// AND Status__c IN (\''  + status + '\')';
        //queryAllFields += ' FROM Partner_Application__c WHERE For_User__c = \'' + '005Z0000001QWUZ' + '\' AND Status__c IN (\''  + status + '\')';
        return queryAllFields;
    }
    
    public static Id getUserAccountId() {
        List<User> currentUser = [select AccountId from User where Id =: Userinfo.getUserid()];
        return currentUser[0].AccountId;    
    }
    
    public static Map<String,String> getMapOfFieldsAndHelpText(){
        String objName ='Technology_Market_place_Application__c';
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
    
    public static List<MarketplaceApplicationController.wrapperCustomerSolution> intializeCustomerSolution(String marketPlaceApplicationId){
        List<MarketplaceApplicationController.wrapperCustomerSolution> customerSolution = new List<MarketplaceApplicationController.wrapperCustomerSolution>();
        if(marketPlaceApplicationId != null){
            List<Genesys_Customer_Solution__c> customerSolutionRecords = [SELECT Id,Customer_Name__c,Implementation__c,Time_in_Service__c,Technology_Market_place_Application__c FROM Genesys_Customer_Solution__c 
            WHERE Technology_Market_place_Application__c =: marketPlaceApplicationId];
            Integer index = 0;
            for(Genesys_Customer_Solution__c eachRecord : customerSolutionRecords){
                MarketplaceApplicationController.wrapperCustomerSolution newRecord = new MarketplaceApplicationController.wrapperCustomerSolution();
                newRecord.record = eachRecord;
                newRecord.index = index;
                index ++;
                customerSolution.add(newRecord);
            }
                
        }
        if(customerSolution.isEmpty()){
            customerSolution = addNewRowToCustomerSolution(customerSolution);       
        }
        return customerSolution;
    }
    
    public static List<MarketplaceApplicationController.wrapperCustomerSolution> addNewRowToCustomerSolution(List<MarketplaceApplicationController.wrapperCustomerSolution> customerSolution){
        MarketplaceApplicationController.wrapperCustomerSolution newRecord = new MarketplaceApplicationController.wrapperCustomerSolution();
        Genesys_Customer_Solution__c newTeamRecord = new Genesys_Customer_Solution__c();        
        newRecord.record = newTeamRecord;
        newRecord.index = customerSolution.size();
        customerSolution.add(newRecord);
        return customerSolution;
    }
    
    public static List<MarketplaceApplicationController.wrapperCustomerSolution> removeRowFromCustomerSolutionList(Integer rowToRemove, List<MarketplaceApplicationController.wrapperCustomerSolution> customerSolution){
        customerSolution.remove(rowToRemove);
        return customerSolution;
    }
    
    public static List<MarketplaceApplicationController.wrapperCompetitors> intializeCompetitors(String marketPlaceApplicationId){
        List<MarketplaceApplicationController.wrapperCompetitors> competitor = new List<MarketplaceApplicationController.wrapperCompetitors>();
        if(marketPlaceApplicationId != null){
            List<MarketPlace_Competitor__c> competitorsRecords = [SELECT Id,Competitor__c,Comments__c,Technology_Market_place_Application__c FROM MarketPlace_Competitor__c  
            WHERE Technology_Market_place_Application__c =: marketPlaceApplicationId];
            Integer index = 0;
            for(MarketPlace_Competitor__c eachRecord : competitorsRecords){
                MarketplaceApplicationController.wrapperCompetitors newRecord = new MarketplaceApplicationController.wrapperCompetitors();
                newRecord.record = eachRecord;
                newRecord.index = index;
                index ++;
                competitor.add(newRecord);
            }
                
        }
        if(competitor.isEmpty()){
            competitor = addNewRowTocompetitor(competitor);       
        }
        return competitor;
    }
    
    public static List<MarketplaceApplicationController.wrapperCompetitors> addNewRowToCompetitor(List<MarketplaceApplicationController.wrapperCompetitors> competitor){
        MarketplaceApplicationController.wrapperCompetitors newRecord = new MarketplaceApplicationController.wrapperCompetitors();
        MarketPlace_Competitor__c  newTeamRecord = new MarketPlace_Competitor__c ();        
        newRecord.record = newTeamRecord;
        newRecord.index = competitor.size();
        competitor.add(newRecord);
        return competitor;
    }
    
    public static List<MarketplaceApplicationController.wrapperCompetitors> removeRowFromCompetitorList(Integer rowToRemove, List<MarketplaceApplicationController.wrapperCompetitors> competitor){
        competitor.remove(rowToRemove);
        return competitor;
    }
    
    public static List<MarketplaceApplicationController.wrapperLicensedUsers> intializeLicensedUsers(String marketPlaceApplicationId){
        List<MarketplaceApplicationController.wrapperLicensedUsers> licensedUsers = new List<MarketplaceApplicationController.wrapperLicensedUsers>();
        if(marketPlaceApplicationId != null){
            List<Licensed_User_Detail__c > licensedUserRecords = [SELECT Id,User_Profile__c,Describe_user_experience__c,Technology_Market_place_Application__c FROM Licensed_User_Detail__c   
            WHERE Technology_Market_place_Application__c =: marketPlaceApplicationId];
            Integer index = 0;
            for(Licensed_User_Detail__c eachRecord : licensedUserRecords){
                MarketplaceApplicationController.wrapperLicensedUsers newRecord = new MarketplaceApplicationController.wrapperLicensedUsers();
                newRecord.record = eachRecord;
                newRecord.index = index;
                index ++;
                licensedUsers.add(newRecord);
            }
                
        }
        if(licensedUsers.isEmpty()){
            licensedUsers = addNewRowToLicensedUsers(licensedUsers);       
        }
        return licensedUsers;
    }
    
    public static List<MarketplaceApplicationController.wrapperLicensedUsers> addNewRowToLicensedUsers(List<MarketplaceApplicationController.wrapperLicensedUsers> LicensedUsers){
        MarketplaceApplicationController.wrapperLicensedUsers newRecord = new MarketplaceApplicationController.wrapperLicensedUsers();
        Licensed_User_Detail__c newTeamRecord = new Licensed_User_Detail__c  ();        
        newRecord.record = newTeamRecord;
        newRecord.index = LicensedUsers.size();
        LicensedUsers.add(newRecord);
        return LicensedUsers;
    }
    
    public static List<MarketplaceApplicationController.wrapperLicensedUsers> removeRowFromLicensedUserList(Integer rowToRemove, List<MarketplaceApplicationController.wrapperLicensedUsers> licensedUsers){
        licensedUsers.remove(rowToRemove);
        return licensedUsers;
    }
    
    public static void save(Technology_Market_place_Application__c newApplication, 
                            Account newAccount, 
                            Contact newContact,
                            List<MarketplaceApplicationController.wrapperCustomerSolution> wrapperCustomerSolutionList, 
                            List<MarketplaceApplicationController.wrapperCompetitors> wrapperCompetitorsList,
                            List<MarketplaceApplicationController.wrapperLicensedUsers> wrapperLicensedUsersList,
                            Integer step,
                            attachment appFoundryAttachment,
                            boolean updateAttachment
                            ){
         if(newApplication.Partner_Account__c  == null)
            newApplication.Partner_Account__c  = newAccount.id;
        if(newApplication.Primary_contact_Name__c == null){
            newApplication.Primary_contact_Name__c  = newContact.id;
        }       
        if(newApplication.For_User__c == null)
            newApplication.For_User__c = UserInfo.getUserId();
        upsert newApplication;
        
        updateChildRecords(newApplication.id, wrapperCustomerSolutionList, wrapperCompetitorsList,wrapperLicensedUsersList);
         /*if(updateAttachment == true) {
            deleteAttachment(newApplication.id);    
         } */
         if(step == 1 && appFoundryAttachment.Id == null && appFoundryAttachment.name != null)                       
        insertAttachement(appFoundryAttachment,newApplication.id);
                                
    }
    
    
    private static void updateChildRecords(String marketPlaceAppId, 
                                           List<MarketplaceApplicationController.wrapperCustomerSolution> wrapperCustomerSolutionList, 
                                           List<MarketplaceApplicationController.wrapperCompetitors> wrapperCompetitorsList,
                                           List<MarketplaceApplicationController.wrapperLicensedUsers> wrapperLicensedUsersList
                                           ){
        System.debug('wrapperCustomerSolutionList--->'+wrapperCustomerSolutionList);
        System.debug('wrapperCompetitorsList--->'+wrapperCompetitorsList);
        System.debug('wrapperLicensedUsersList--->'+wrapperLicensedUsersList);
        List<Genesys_Customer_Solution__c> customSolutionRecordsToBeDeleted = [SELECT id FROM Genesys_Customer_Solution__c WHERE Technology_Market_place_Application__c  =: marketPlaceAppId];
        //Deleting existing records     
        if(!customSolutionRecordsToBeDeleted.isEmpty())   
            delete customSolutionRecordsToBeDeleted;
        List<MarketPlace_Competitor__c> competitorRecordsToBeDeleted = [SELECT id FROM MarketPlace_Competitor__c  WHERE Technology_Market_place_Application__c =: marketPlaceAppId];
        if(!competitorRecordsToBeDeleted.isEmpty())   
            delete competitorRecordsToBeDeleted;  
        List<Licensed_User_Detail__c> licensedUserRecordsToBeDeleted = [SELECT id FROM Licensed_User_Detail__c  WHERE Technology_Market_place_Application__c =: marketPlaceAppId];
        if(!licensedUserRecordsToBeDeleted.isEmpty())  
            delete licensedUserRecordsToBeDeleted; 
            
        
                
        //Inserting records;
        List<Genesys_Customer_Solution__c> customSolutionRecordsToBeInserted = new List<Genesys_Customer_Solution__c>();
        for(MarketplaceApplicationController.wrapperCustomerSolution eachRecord : wrapperCustomerSolutionList){
            if(eachRecord.record.Technology_Market_place_Application__c == null)
                eachRecord.record.Technology_Market_place_Application__c = marketPlaceAppId;
                
            Genesys_Customer_Solution__c newRecord = new Genesys_Customer_Solution__c();
            newRecord.Technology_Market_place_Application__c = marketPlaceAppId;
            newRecord.Customer_Name__c = eachRecord.record.Customer_Name__c;
            newRecord.Implementation__c = eachRecord.record.Implementation__c; 
            newRecord.Time_in_Service__c = eachRecord.record.Time_in_Service__c; 
            customSolutionRecordsToBeInserted.add(newRecord);
        }
        List<MarketPlace_Competitor__c> competitorRecordsToBeInserted = new List<MarketPlace_Competitor__c>();
        for(MarketplaceApplicationController.wrapperCompetitors eachRecord : wrapperCompetitorsList){
            
            if(eachRecord.record.Technology_Market_place_Application__c == null)
                eachRecord.record.Technology_Market_place_Application__c = marketPlaceAppId;
            MarketPlace_Competitor__c newRecord = new MarketPlace_Competitor__c();
            newRecord.Technology_Market_place_Application__c = marketPlaceAppId;            
            newRecord.Competitor__c = eachRecord.record.Competitor__c;
            newRecord.Comments__c = eachRecord.record.Comments__c;            
            competitorRecordsToBeInserted.add(newRecord);
        }
        List<Licensed_User_Detail__c> licensedUserRecordsToBeInserted = new List<Licensed_User_Detail__c>();
        for(MarketplaceApplicationController.wrapperLicensedUsers eachRecord : wrapperLicensedUsersList){
            
            if(eachRecord.record.Technology_Market_place_Application__c == null)
                eachRecord.record.Technology_Market_place_Application__c = marketPlaceAppId;
            Licensed_User_Detail__c newRecord = new Licensed_User_Detail__c();
            newRecord.Technology_Market_place_Application__c = marketPlaceAppId;            
            newRecord.User_Profile__c = eachRecord.record.User_Profile__c;
            newRecord.Describe_user_experience__c = eachRecord.record.Describe_user_experience__c;            
            licensedUserRecordsToBeInserted.add(newRecord);
        }                                       
        
         
        
        if(!customSolutionRecordsToBeInserted.isEmpty()){
            insert customSolutionRecordsToBeInserted;
        }
        if(!competitorRecordsToBeInserted.isEmpty()){
            insert competitorRecordsToBeInserted;
        }
        if(!licensedUserRecordsToBeInserted.isEmpty()){
            insert licensedUserRecordsToBeInserted;
        }
   }
   
    
    public static void insertAttachement(Attachment att, String marketPlaceAppId) {
        System.debug('att-->'+att);
        att.parentId = marketPlaceAppId;
        upsert att;
    } 
    
    public static void deleteAttachment(String marketPlaceAppId) {
        Attachment att = [select Id from Attachment where parentId =: marketPlaceAppId]; 
        if(att != null) 
            delete att;
    }
    
   public static List<Technology_Market_place_Application__c> getExistingApplication(){
        List<Technology_Market_place_Application__c> marketApplications = (List<Technology_Market_place_Application__c>)Database.query(prepareQuery(''));
        return marketApplications;
    }
    
    public static void submitMpApplicationToApprovalProcess(Technology_Market_place_Application__c newApplication){
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments('Request submitted for approval automatically.');
        req.setObjectId(newApplication.id);
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req);
    }
    
    public static String getCurrentUserProfile(){
        Profile currentUserProfile = [SELECT Name FROM Profile WHERE id =: UserInfo.getProfileId()];
        return currentUserProfile.Name;
    }
    
}