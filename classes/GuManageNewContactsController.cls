public class GuManageNewContactsController {
    
    // Pagination variables for unProcessed Contacts
    public Integer unproPageSize{get; set;}
	public Integer unproPageNumber{get; set;}
    public Integer unproTotalPages{get; set;}
    public Integer unproTotalRecords{get; set;}
    public Integer unproStartRecord{get; set;}
    public Integer unproEndRecord{get; set;}
    
    // Pagination variables for processed Contacts
    public Integer proPageSize{get; set;}
	public Integer proPageNumber{get; set;}
    public Integer proTotalPages{get; set;}
    public Integer proTotalRecords{get; set;}
    public Integer proStartRecord{get; set;}
    public Integer proEndRecord{get; set;}

    // Variable for indentifying selected Tab in the UI	
    public String selectedTab {get; set;}
    
    // List to hold the information about Unprocessed Contacts
    public List<String> unprocessedGuContactIds {get; set;}
    public List<GUContactWrapper> currentUnprocessedContacts {get; set;} 

    // List to hold the information about processed Contacts
    public List<String> processedGuContactIds {get; set;}
    public List<GU_New_Contact__c> currentProcessedContacts {get; set;} 
    
    // Constructor 
    public GuManageNewContactsController(){
        // By default set the selected tab to Unprocessed Contacts
        selectedTab = 'pendingContacts';
        unproPageSize = proPageSize = 10;

        // Initialize the Unprocessed Contacts lists
        initializeUnprocessedContacts();
        fetchUnprocessedContacts(++unproPageNumber);        
        
        // Initialize the Processed Contacts lists
        initializeProcessedContacts();
    } 
    
	// Pagination Methods
	// Enable Previous if Current Page is greater than 1
    public Boolean getDisableUnproPrevious(){
        return (unproPageNumber == 1 ? true : false);
    }
    // Enable Next if Still records are there in the list 
    public Boolean getDisableUnproNext(){
        return ((unproPageNumber * unproPageSize) < unproTotalRecords ? false : true);
    }
    public Boolean getDisableUnproFirst(){
        return (unproTotalRecords > unproPageSize && unproPageNumber > 1 ? false: true);
    }
    public Boolean getDisableUnproLast(){
        return (unproPageNumber * unproPageSize < unproTotalRecords ? false : true);
    }
    
    public PageReference unproFirstBtnClick() {
        unproPageNumber = 1;
        fetchUnprocessedContacts(unproPageNumber);
        return null;
    }
    
    public PageReference unproLastBtnClick() {
        unproPageNumber = unproTotalRecords / unproPageSize;
		if( (unproPageNumber * unproPageSize) < unproTotalRecords)        
        	unproPageNumber++;
        
        fetchUnprocessedContacts(unproPageNumber);
        return null;
    }
    
    public PageReference unproNextBtnClick() {
        fetchUnprocessedContacts(++unproPageNumber);
        return null;
    }
    
    public PageReference unproPreviousBtnClick() {
        fetchUnprocessedContacts(--unproPageNumber);
        return null;
    }
    
    public void initializeUnprocessedContacts(){
        unproPageNumber = unproStartRecord = unproEndRecord = unproTotalPages = unproTotalRecords = 0;
		 
        unprocessedGuContactIds = new List<String>();
        for(GU_New_Contact__c guc : [SELECT Id FROM GU_New_Contact__c WHERE Processed__c = false AND SystemModStamp = LAST_N_DAYS:90 ORDER BY FirstName__c, LastName__c]){
            unprocessedGuContactIds.add(guc.Id);
        }
		unproTotalRecords = unprocessedGuContactIds.size();
        unproTotalPages = unproTotalRecords / unproPageSize;
		if( (unproTotalPages * unproPageSize) < unproTotalRecords)        
        	unproTotalPages++;
        
        currentUnprocessedContacts = new List<GUContactWrapper>();
    }
    
    public void fetchUnprocessedContacts(Integer currentPage){
        Integer startRecordIndex = ((currentPage - 1) * unproPageSize);
        Integer endRecordIndex = currentPage * unproPageSize - 1;
        if(unprocessedGuContactIds.size()-1 < endRecordIndex)
            endRecordIndex = unprocessedGuContactIds.size()-1;
        
        List<String> currentUnprocessedContactIds = new List<String>();
        for(Integer i = startRecordIndex; i <= endRecordIndex; i++){
            currentUnprocessedContactIds.add(unprocessedGuContactIds.get(i));
        }

        List<GU_New_Contact__c> guContactsTemp = [SELECT Id, Account__c, Email__c, FirstName__c, LastName__c, GARN__c, Matching_Contact_Found__c, Processed__c, ViewCentral_ID__c 
                                        FROM GU_New_Contact__c WHERE Id IN :currentUnprocessedContactIds ORDER BY FirstName__c, LastName__c ASC];
        
        Set<String> contactEmails = new Set<String>();
        Set<String> accountGarns = new Set<String>();
       	for(GU_New_Contact__c guc: guContactsTemp){
            contactEmails.add(guc.Email__c);
            accountGarns.add(guc.GARN__c);
        }
        
        List<Contact> matchingContacts = [select Id,email,FirstName,LastName,Status__c,Account.Name,Account.SAP_Account_Code__c,Account.RecordType.Name from Contact where email in: contactEmails];
        Map<String,List<Contact>> matchingContactsMap = new Map<String, List<Contact>>();
        for(Contact cnt : matchingContacts) {
            if(!matchingContactsMap.containsKey(cnt.email)) {
                matchingContactsMap.put(cnt.email, new List<Contact>{cnt});    
            } else {
                matchingContactsMap.get(cnt.email).add(cnt);    
            }
        } 

        List<Account> matchingAccounts =  [SELECT Id,Name,Street1__c,Country__c,BillingCity,StateProvince__c,SAP_Account_Code__c,RecordType.Name,Subsidary__c,Type,OwnerId,Owner.Name, Status__c from Account where RecordType.Name NOT IN ('Group Account - Customer','Party Account') and Status__c != 'Merged' and SAP_Account_Code__c  IN: accountGarns];
		Map<String,List<Account>> matchingAccountsMap = new Map<String,List<Account>>();
 		for(Account acc : matchingAccounts) {
            if(!matchingAccountsMap.containsKey(acc.SAP_Account_Code__c)) {
                matchingAccountsMap.put(acc.SAP_Account_Code__c, new List<Account>{acc});    
            } else {
                matchingAccountsMap.get(acc.SAP_Account_Code__c).add(acc);    
            }
        } 
	
    	Integer recordCount = 0;    
        currentUnprocessedContacts = new List<GUContactWrapper>();
        for(GU_New_Contact__c guc: guContactsTemp){
            if(matchingContactsMap.containsKey(guc.Email__c)){
                currentUnprocessedContacts.add(new GUContactWrapper(guc, true, matchingContactsMap.get(guc.Email__c), null, recordCount++));
            }  else {
                currentUnprocessedContacts.add(new GUContactWrapper(guc, false, null,matchingAccountsMap.get(guc.GARN__c), recordCount++));     
            }                                  
		}
        
		unproStartRecord = startRecordIndex + 1;
        unproEndRecord = endRecordIndex + 1;
    }
    
    
    
    // Pagination Methods for Processed Contacts
	// Enable Previous if Current Page is greater than 1
    public Boolean getDisableProPrevious(){
        return (proPageNumber == 1 ? true : false);
    }
    // Enable Next if Still records are there in the list 
    public Boolean getDisableProNext(){
        return ((proPageNumber * proPageSize) < proTotalRecords ? false : true);
    }
    public Boolean getDisableProFirst(){
        return (proTotalRecords > proPageSize && proPageNumber > 1 ? false: true);
    }
    public Boolean getDisableProLast(){
        return (proPageNumber * proPageSize < proTotalRecords ? false : true);
    }
    
    public PageReference proFirstBtnClick() {
        proPageNumber = 1;
        fetchProcessedContacts(proPageNumber);
        return null;
    }
    
    public PageReference proLastBtnClick() {
        proPageNumber = proTotalRecords / proPageSize;
		if( (proPageNumber * proPageSize) < proTotalRecords)        
        	proPageNumber++;
        
        fetchProcessedContacts(proPageNumber);
        return null;
    }
    
    public PageReference proNextBtnClick() {
        fetchProcessedContacts(++proPageNumber);
        return null;
    }
    
    public PageReference proPreviousBtnClick() {
        fetchProcessedContacts(--proPageNumber);
        return null;
    }
    
    public void initializeProcessedContacts(){
 		proPageNumber = proStartRecord = proEndRecord = proTotalPages = proTotalRecords = 0;
		 
        processedGuContactIds = new List<String>();
        for(GU_New_Contact__c guc : [SELECT Id FROM GU_New_Contact__c WHERE Processed__c = true AND SystemModStamp = LAST_N_DAYS:90 ORDER BY FirstName__c, LastName__c]){
            processedGuContactIds.add(guc.Id);
        }
		proTotalRecords = processedGuContactIds.size();
        proTotalPages = proTotalRecords / proPageSize;
		if( (proTotalPages * proPageSize) < proTotalRecords)        
        	proTotalPages++;
        
        fetchProcessedContacts(++proPageNumber);                
    }

    public void fetchProcessedContacts(Integer currentPage){
        Integer startRecordIndex = ((currentPage - 1) * proPageSize);
        Integer endRecordIndex = currentPage * proPageSize - 1;
        if(processedGuContactIds.size()-1 < endRecordIndex)
            endRecordIndex = processedGuContactIds.size()-1;
        
        List<String> currentProcessedContactIds = new List<String>();
        for(Integer i = startRecordIndex; i <= endRecordIndex; i++){
            currentProcessedContactIds.add(processedGuContactIds.get(i));
        }

        currentProcessedContacts = [SELECT Id, Account__c, Email__c, FirstName__c, LastName__c, GARN__c, Matching_Contact_Found__c, Processed__c, ViewCentral_ID__c 
                                        FROM GU_New_Contact__c WHERE Id IN :currentProcessedContactIds ORDER BY FirstName__c, LastName__c ASC];
        
		proStartRecord = startRecordIndex + 1;
        proEndRecord = endRecordIndex + 1;
         
     }
    
    
    public class GUContactWrapper {
        public Integer recordNo {get; set;}
        public GU_New_Contact__c guContact {get; set;}
        public boolean isExistingContact {get; set;}
        public List<Contact> existingContacts {get; set;} 
        public List<Account> garnAccounts {get; set;}
        
        public GUContactWrapper(GU_New_Contact__c guContact, boolean isExistingContact, List<Contact> existingContacts, List<Account> garnAccounts, Integer counter){
            this.guContact = guContact;
            this.isExistingContact = isExistingContact;
            this.existingContacts = existingContacts;
            this.garnAccounts = garnAccounts;
            recordNo = counter;
        }
    }
    
    public String selectedGURecordId {get; set;}
    public String selectedAccountId {get; set;}
    public String selectedContactId {get; set;}
    
    
   	public pagereference getSelected() {
        selectedGURecordId = ApexPages.currentPage().getParameters().get('selectedGU');
        selectedAccountId = ApexPages.currentPage().getParameters().get('selectedAccount');
        selectedContactId = ApexPages.currentPage().getParameters().get('selectedContact');
        System.debug('selectedGURecord---'+selectedGURecordId);
        System.debug('selectedAccount---'+selectedAccountId);
        return null;    
    }
    
    public Pagereference updateContact() {
        Integer tempPageNumber = unproPageNumber;
       	GU_New_Contact__c guContact = [SELECT Id, Account__c, Email__c, FirstName__c, LastName__c, GARN__c, Matching_Contact_Found__c, Processed__c, ViewCentral_ID__c 
                                        	FROM GU_New_Contact__c WHERE Id = :selectedGURecordId LIMIT 1];

        Contact contactToUpdate = new Contact(Id = selectedContactId, ViewCentral_ID__c = guContact.ViewCentral_ID__c); 
        update contactToUpdate;
        
        guContact.Processed__c = true;
        update guContact;

        // Reset selected variables	
        selectedGURecordId = selectedAccountId = selectedContactId = null;
        
        // Refresh the Current GU Contacts List
         // if the record processed is whether last record or not
        if(unproTotalRecords == 1){
            initializeUnprocessedContacts();
        } else {
            initializeUnprocessedContacts();
            if(unproTotalPages < tempPageNumber)
                unproPageNumber = unproTotalPages;
            else
                unproPageNumber = tempPageNumber;
            fetchUnprocessedContacts(unproPageNumber);        
        }
    	return null;
    }
    
 	public Pagereference createContact() {
        Integer tempPageNumber = unproPageNumber;

        
       	GU_New_Contact__c guContact = [SELECT Id, Account__c, Email__c, FirstName__c, LastName__c, GARN__c, Matching_Contact_Found__c, Processed__c, ViewCentral_ID__c 
                                        	FROM GU_New_Contact__c WHERE Id = :selectedGURecordId LIMIT 1];
        
        if(guContact.Processed__c == false ){
            Contact contactToCreate = new Contact(FirstName = guContact.FirstName__c, LastName = guContact.LastName__c, Email = guContact.Email__c,
                                        AccountId = selectedAccountId, ViewCentral_ID__c = guContact.ViewCentral_ID__c); 
            insert contactToCreate;
        }

        guContact.Processed__c = true;
        update guContact;
		
        // Reset selected variables	
        selectedGURecordId = selectedAccountId = selectedContactId = null;
        
        // Refresh the Current GU Contacts List
        // if the record processed is whether last record or not
        if(unproTotalRecords == 1){
            initializeUnprocessedContacts();
        } else {
            initializeUnprocessedContacts();
            if(unproTotalPages < tempPageNumber)
                unproPageNumber = unproTotalPages;
            else
                unproPageNumber = tempPageNumber;
            fetchUnprocessedContacts(unproPageNumber);        
        }
        return null;    
   	}
    
     public Pagereference back() {
        // Reset selected variables	
        selectedGURecordId = selectedAccountId = selectedContactId = null;
     	return null;
   	}
}