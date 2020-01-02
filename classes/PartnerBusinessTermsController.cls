// Sourav Mitra : Feb 2014
public class PartnerBusinessTermsController 
{
    public Id applicationId {get;set;}
    Map<String, List<String>> map_CategoryVsCountries;
    public List<SelectOption> categoryOptions {get;set;}
    public String selectedCategory {get;set;}
    public String selectedApprovalStatus {get;set;}
    //public List<SelectOption> approvalStatusOptions {get;set;}
    
    public Map<String,String> map_CountryIdToCountryName {get; private set;}
    public Partner_Business_Terms_Category__c objPBTC {get; set;}
    public List<Partner_Business_Terms_Country__c> list_PBTCCountriesToCreate {get; set;}
    Map<String,Partner_Business_Terms_Country__c> map_CountryIdToRecord;
    
    public Partner_Business_Terms_and_Conditions__c objPartnerBusinessTandC {get; set;}
    public Boolean blnIsReadMode {get; private set;}
    String strTandCId;
    public Partner_Contract__c objContract {get; private set;}
    List<Partner_Business_Terms_Category__c> list_CategoryRecords;
    public Boolean showSignContractButton {get;set;}
    public String docuSignRecipientExtId {get;set;}
    public Map<String,String> map_catgoryAndCountries {get;set;}
    public boolean hasCC {get;set;}
    public boolean isNew {get;set;}
    public Partner_Application__c pa {get;set;}
    public PartnerBusinessTermsController(ApexPages.StandardController controller) 
    {
        applicationId = ApexPages.currentPage().getParameters().get('appId');
        String strMode = ApexPages.currentPage().getParameters().get('mode');
        strTandCId = controller.getId();
        if(strMode == 'edit')
            blnIsReadMode = false;
        else
            blnIsReadMode = true;    
        
        init();
        getPartnerApplicationCategoryAndCountries();
    }
    
    //*** Method to initialize data when the page loads ***
    private void init()
    {
        //initializeApprovalStatusOptions();
        map_CategoryVsCountries = new Map<String,List<String>>();
        map_CountryIdToCountryName = new Map<String,String>();
        categoryOptions = new List<SelectOption>();
        selectedCategory = '';
        
        List<Partner_Business_Terms_and_Conditions__c> list_Temp;
        if(strTandCId == null || strTandCId == '')
        {
            list_Temp = [SELECT Id, Partner_Application__c, Partner_Application__r.Account__c, Approval_Status__c, Date_Acknowledged__c, Partner_Account_Name__c              			 
                        FROM Partner_Business_Terms_and_Conditions__c WHERE Partner_Application__c = :applicationId LIMIT 1];
        }
        else
        {
            list_Temp = [SELECT Id,Partner_Application__c, Partner_Application__r.Account__c, Approval_Status__c,Date_Acknowledged__c, Partner_Account_Name__c 
                        FROM Partner_Business_Terms_and_Conditions__c WHERE Id = :strTandCId LIMIT 1];
        }
        if(list_Temp.size() > 0)
        {
            objPartnerBusinessTandC = list_Temp[0];
            ApexPages.currentPage().getParameters().put('id',objPartnerBusinessTandC.Id);
            applicationId = objPartnerBusinessTandC.Partner_Application__c;
        }
        else
        {
            isNew = true;
            pa = new Partner_Application__c();
            pa = [select Account__c from Partner_Application__c where Id =: applicationId];
            objPartnerBusinessTandC = new Partner_Business_Terms_and_Conditions__c(Partner_Application__c = applicationId,
                                        Approval_Status__c = 'In Review');
            blnIsReadMode = false;
        }
        
        objContract = new Partner_Contract__c();
        List<Partner_Contract__c> list_TempContract = [SELECT Id,Status__c FROM Partner_Contract__c 
                WHERE (Status__c = 'Approved' OR Status__c = 'Approved by Partner') AND
                Partner_Business_Terms_and_Conditions__c = :objPartnerBusinessTandC.Id LIMIT 1];
        if(list_TempContract.size() > 0)
            objContract = list_TempContract[0];   
        // Sorted by category and then country : so under each category countries will be sorted
        for(Partner_Application_Category_and_Country__c objPACC :  [SELECT Category__c, Country__c, Country__r.Name 
                                    FROM Partner_Application_Category_and_Country__c 
                            WHERE Partner_Application__c =: applicationId 
                            AND Approval_Status__c = 'Approved'
                            AND Category__c != null ORDER BY Category__c ASC,Country__r.Name ASC])
        {
            if(!map_CategoryVsCountries.containsKey(objPACC.Category__c))
            {
                map_CategoryVsCountries.put(objPACC.Category__c,new List<String>{objPACC.Country__c});
            }
            else
                map_CategoryVsCountries.get(objPACC.Category__c).add(objPACC.Country__c);
                
            if(selectedCategory == '')
                selectedCategory = objPACC.Category__c;
                
            map_CountryIdToCountryName.put(objPACC.Country__c,objPACC.Country__r.Name);
            
        }
        refresh();
        checkForPendingSignatures();
    }
    
    public void checkForPendingSignatures(){
    	List<dsfs__DocuSign_Recipient_Status__c> dsRecipientStatus = [SELECT dsfs__DocuSign_Recipient_Id__c 
    		FROM dsfs__DocuSign_Recipient_Status__c 
    		WHERE dsfs__DocuSign_Recipient_Email__c =: UserInfo.getUserEmail() 
    		AND dsfs__Recipient_Status__c = 'Sent'
    		AND dsfs__Parent_Status_Record__r.dsfs__Envelope_Status__c != 'Completed'];
    	if(dsRecipientStatus.isEmpty())
    		showSignContractButton = false;
    	else{
    		docuSignRecipientExtId = dsRecipientStatus[0].dsfs__DocuSign_Recipient_Id__c;
    		showSignContractButton = true;
    	}
    	 
    }
    
    //*** Edit button handler ***
    public PageReference changeToEditMode()
    {
        blnIsReadMode = false;
        PageReference pg = new PageReference('/apex/PartnerBusinessTerms?appId=' + applicationId+ '&mode=edit');
        pg.setRedirect(true);
      	return pg;
    }
    
    //*** Edit button handler ***
    public void cancelBtnHandler()
    {
        blnIsReadMode = true;
    }
    
    //*** Submit for Approval button handler ***
    public void submitForApproval()
    {
     objPartnerBusinessTandC.Approval_Status__c = 'Submitted';
     upsert objPartnerBusinessTandC;
     submitPartnerApplicationToApprovalProcess(objPartnerBusinessTandC);         
    }
    
    //*** Contract Request button handler ***
    public PageReference contractRequest()
    {
    	/*
        Partner_Contract_Request__c objContractRequest = new Partner_Contract_Request__c();
        List<Partner_Contract_Request__c> list_Temp = [SELECT Id FROM Partner_Contract_Request__c 
                WHERE Partner_Business_Terms_and_Conditions__c = :objPartnerBusinessTandC.Id LIMIT 1];
        if(list_Temp.size() > 0)
            objContractRequest = list_Temp[0];
        else
        {
            // New Contract Request is being created with Categories, Categories and Countries, Solutions,Status and Currencies pre-populated
            objContractRequest.Partner_Business_Terms_and_Conditions__c = objPartnerBusinessTandC.Id;
            objContractRequest.Status__c = 'Draft';
            String strCategories = '';
            String strSolutions = '';
            objContractRequest.Approved_Categories_and_Countries__c = '';
            objContractRequest.Currencies__c = '';
            Set<Id> set_CountryIds = new Set<Id>();
            List<String> list_CountryCurrencies = new List<String>();
            for(Partner_Business_Terms_Category__c objCategory : [SELECT Category__c,Solutions__c,
                  (SELECT Country__c,Country__r.Name,Country__r.CurrencyISOCode FROM Partner_Business_Terms_Countries__r ORDER BY Country__r.Name)    
                  FROM Partner_Business_Terms_Category__c WHERE 
                  Partner_Business_Terms_and_Conditions__c = :objPartnerBusinessTandC.Id ORDER BY Category__c])
            {
                strCategories += objCategory.Category__c + ';';
                if(objCategory.Solutions__c != null)
                    strSolutions += objCategory.Solutions__c + ';';
                String strEachCategory = '<b>' + objCategory.Category__c + '</b> : ';
                for(Partner_Business_Terms_Country__c objCountry :objCategory.Partner_Business_Terms_Countries__r)
                {
                    strEachCategory += objCountry.Country__r.Name + ', ';
                    if(!set_CountryIds.contains(objCountry.Country__c))
                    {
                        String strEachCountry = '';
                        strEachCountry += '<b>' + objCountry.Country__r.Name + '</b> : ';
                        if(objCountry.Country__r.CurrencyISOCode != null)
                            strEachCountry += objCountry.Country__r.CurrencyISOCode;
                        strEachCountry += '<br/>';
                        list_CountryCurrencies.add(strEachCountry);
                        set_CountryIds.add(objCountry.Country__c);
                    }
                }
                strEachCategory.trim();
                strEachCategory = strEachCategory.substringBeforeLast(',');
                strEachCategory += '<br/>';
                objContractRequest.Approved_Categories_and_Countries__c += strEachCategory;
            }
            list_CountryCurrencies.sort();
            for(String strCountryCurrency : list_CountryCurrencies)
                objContractRequest.Currencies__c += strCountryCurrency;
            strCategories = strCategories.substringBeforeLast(';');
            strSolutions = strSolutions.substringBeforeLast(';');
            objContractRequest.Categories__c = strCategories;
            objContractRequest.Solutions__c = strSolutions;
            insert objContractRequest;
        }
        */
        return (new PageReference('/apex/GCRequest?appId=' + applicationId + '&accid=' + objPartnerBusinessTandC.Partner_Application__r.Account__c+'&crt=Partner Contract&t=gcrDetails'));
    }
    
    
    //*** Contract button handler ***
    public PageReference viewContract()
    {
        return (new PageReference('/' + objContract.Id));
    }
    
   public Pagereference approveContract()
   {
       Partner_Contract__c objContract_new = new Partner_Contract__c();
       objContract_new.id = objContract.Id;
       objContract_new.Status__c = 'Approved by Partner';
       update objContract_new;
       return (new PageReference('/' + objContract.Id));
     // return null;
   }
    
    /*
    //*** Method to initialize Approval Status Options ***
    void initializeApprovalStatusOptions()
    {
        approvalStatusOptions = new List<SelectOption>();
        approvalStatusOptions.add(new SelectOption('In Review','In Review'));
        approvalStatusOptions.add(new SelectOption('Approved','Approved'));
        approvalStatusOptions.add(new SelectOption('Rejected','Rejected'));
        approvalStatusOptions.add(new SelectOption('Request For Update','Request For Update'));
    }*/
    
    //*** Method to Handle refresh of bottom section based on Category selected ***
    public void refresh()
    {
        Partner_Application__c pa = getPartnerContact();
        objPBTC = new Partner_Business_Terms_Category__c(//Partner_Application__c = applicationId,
                            Tier__c = 'Bronze',Category__c = selectedCategory);
        if(objPartnerBusinessTandC.Id != null)
            objPBTC.Partner_Business_Terms_and_Conditions__c = objPartnerBusinessTandC.Id;
        if(pa != null)
           objPBTC.Partner_Contact__c = pa.Contact__r.Name;
        list_PBTCCountriesToCreate = new List<Partner_Business_Terms_Country__c>();
        Boolean blnHasExistingData = checkExistingData();       
        if(map_CategoryVsCountries.containsKey(selectedCategory))
        {
            List<String> list_CountryIds = map_CategoryVsCountries.get(selectedCategory);
            
            for(String strCountryId : list_CountryIds)
            {
                Partner_Business_Terms_Country__c obj = new Partner_Business_Terms_Country__c();
                // Checking if the country record already exists
                if(blnHasExistingData && map_CountryIdToRecord.containsKey(strCountryId))
                    obj = map_CountryIdToRecord.get(strCountryId);

                else
                    obj.Country__c = strCountryId;
                
                list_PBTCCountriesToCreate.add(obj);
            }
        }         
    }
    
    //*** Method to check whether category exists or not and to pre-populate as required ***
    Boolean checkExistingData()
    {
        if(objPartnerBusinessTandC.Id == null)
            return false;
            
        String strQuery = 'SELECT Tier__c,Partner_Business_Terms_and_Conditions__c,Category__c,';
        for(Schema.FieldSetMember f : SObjectType.Partner_Business_Terms_Category__c.FieldSets.Partner_Business_Terms_Top_Section.getFields())
            strQuery += f.getFieldPath() + ', ';
        strQuery += '(SELECT Country__c,Country__r.Name,Partner_Business_Terms_Category__c,';
        for(Schema.FieldSetMember f : SObjectType.Partner_Business_Terms_Country__c.FieldSets.Partner_Business_Terms_Bottom_Section.getFields())
            strQuery += f.getFieldPath() + ', ';
        strQuery += 'Id FROM Partner_Business_Terms_Countries__r ORDER BY Country__r.Name),';
        strQuery += 'Id FROM Partner_Business_Terms_Category__c ';
        strQuery += 'WHERE Category__c = \'' + selectedCategory + '\' AND Partner_Business_Terms_and_Conditions__c = ';
        strQuery += '\'' + objPartnerBusinessTandC.Id + '\'';
        list_CategoryRecords = Database.query(strQuery);
        for(Partner_Business_Terms_Category__c objPartnerCategory : list_CategoryRecords)
        {
            objPBTC = objPartnerCategory;
            //list_PBTCCountriesToCreate = objPartnerCategory.Partner_Business_Terms_Countries__r;
            map_CountryIdToRecord = new Map<String,Partner_Business_Terms_Country__c>();
            for(Partner_Business_Terms_Country__c objRecord : objPartnerCategory.Partner_Business_Terms_Countries__r)
                map_CountryIdToRecord.put(objRecord.Country__c,objRecord);
            return true;
        }
        return false;
    }
    
    public void quickSaveBtnHandler()
    {
        saveBtnHandler();
        blnIsReadMode = false;
    }
    
    //*** Save Button Handler/function ***
    public PageReference saveBtnHandler()
    {
        upsert objPartnerBusinessTandC;
        if(objPBTC != null)
        {
            if(objPBTC.Partner_Business_Terms_and_Conditions__c == null)
                objPBTC.Partner_Business_Terms_and_Conditions__c = objPartnerBusinessTandC.Id;
            upsert objPBTC;
            if(list_PBTCCountriesToCreate != null && list_PBTCCountriesToCreate.size() > 0)
            {
                for(Partner_Business_Terms_Country__c objRecord : list_PBTCCountriesToCreate)
                {
                    if(objRecord.Partner_Business_Terms_Category__c == null)
                        objRecord.Partner_Business_Terms_Category__c = objPBTC.Id;
                }
                upsert list_PBTCCountriesToCreate;
            }
            
            //return (new PageReference('/' + applicationId));
            ApexPages.currentPage().getParameters().put('id',objPartnerBusinessTandC.Id);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Business terms for category : ' + selectedCategory + ' has been saved.');
            ApexPages.addMessage(myMsg);
            blnIsReadMode = true;
            /*PageReference pg = new PageReference('/apex/PartnerBusinessTerms?appId=' + applicationId);
        	pg.setRedirect(true);
      		return pg; */
            return null;
        }
        return null;
    }
    
    //*** Acknowledge Terms Button Handler/function ***
    public void partnerAcknowledgement()
    {
        objPartnerBusinessTandC.Approval_Status__c = 'Partner Acknowledged';
        objPartnerBusinessTandC.Date_Acknowledged__c = Date.today();
        upsert objPartnerBusinessTandC;
       
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments('Partner Acknowledged Terms and Conditions.');
        req1.setObjectId(objPartnerBusinessTandC.id);
        Approval.ProcessResult result = Approval.process(req1);
       
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Business Terms and Conditions have been acknowledged.');
        ApexPages.addMessage(myMsg);
        
    }
    
    //*** Reject Terms Button Handler/function ***
    public void rejectTerms()
    {
        objPartnerBusinessTandC.Approval_Status__c = 'Partner Rejected';
        upsert objPartnerBusinessTandC;
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.Info,'Business Terms and Conditions have been Rejected.');
        ApexPages.addMessage(myMsg);
    }
    
    //*** Back To Application Button Handler/function ***
    public PageReference backToApplication()
    {
        return (new PageReference('/apex/Partner_ApplicationDetail?id=' + applicationId));
    }
    
    public static void submitPartnerApplicationToApprovalProcess(Partner_Business_Terms_and_Conditions__c newApplication){
    Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
    req.setComments('Request submitted for approval automatically.');
    req.setObjectId(newApplication.id);
        // Submit the approval request for the account
    Approval.ProcessResult result = Approval.process(req);
    }
    
    public Partner_Application__c getPartnerContact() {
        Partner_Application__c pa;
        System.debug('start-getPartnerContact--->');
        System.debug('start-applicationId--->'+applicationId);
        if(applicationId != null) {
            System.debug('start-applicationId--->'+applicationId);
        	pa = new Partner_Application__c();
            pa = [select Id,Contact__r.Name from Partner_Application__c where Id=: applicationId];	    
        	return pa;
        }    
    	return null;
    }
    
    public void getPartnerApplicationCategoryAndCountries() {
    	List<Partner_Application_Category_and_Country__c> list_catgoryAndCountries = new List<Partner_Application_Category_and_Country__c>();
        list_catgoryAndCountries = [SELECT Category__c, Country__c, Country__r.Name 
                                    FROM Partner_Application_Category_and_Country__c 
                            WHERE Partner_Application__c =: applicationId 
                            AND Category__c != null ORDER BY Country__r.Name ASC];
        map_catgoryAndCountries = new Map<String,String>();
        for(Partner_Application_Category_and_Country__c pacc :list_catgoryAndCountries) {
            if(!map_catgoryAndCountries.containsKey(pacc.Country__r.Name)) {
            	map_catgoryAndCountries.put(pacc.Country__r.Name,pacc.Category__c);    
            }
            else {
               	map_catgoryAndCountries.put(pacc.Country__r.Name,String.valueOf(map_catgoryAndCountries.get(pacc.Country__r.Name))+ ' , ' +pacc.Category__c);
            }
        }
        if(map_catgoryAndCountries.size()>0) {
        	hasCC = true;	    
        } else {
            hasCC = false;
        }
        System.debug('map_catgoryAndCountries-->'+map_catgoryAndCountries);
    }
}