//Naresh Kumar  10/24/2014
public without sharing class GCRContentDocumentDetailsController {
    public String recordId {get;set;}
    public List<treeNodes> treeItems {get;set;}
    public String selectedAccountName {get;set;}
    public List<SelectOption> accounts {get;set;} 
    public String selectedAccountId {get;set;}
    public GCR_Content_Document_Detail__c currentRecord {get;set;}
    public GCR_Content_Document_Folder__c currentRecordFolder {get;set;}    
    public Boolean renderPageBlock {get;set;}
    public Boolean renderFolderPagebLock {get;set;}
    public String pageMode {get;set;}
    public String accountId {get;set;}
    public String searchTerm {get; set;}
    public String selectedAccount {get; set;}
    public Boolean lockAccountSelection {get;set;}
    public Boolean isAdminUser {get;set;}
    public Boolean isAdminDeleteUser {get;set;}
    public Account currentAccount {get;set;}
    //Used for account input field only
    public GCR__c gcr {get;set;}    
    public GCR__c currentGCR {get;set;}
    public String gcrId {get;set;}    
    public Boolean hideHeader {get;set;}
    public Boolean embedded {get;set;}
    public Boolean showAll {get;set;}
    public Boolean showFromCurrentGCR {get;set;}
    public List<attachmentWrapper> attachments {get;set;}
    public String attachmentIdToBeDeleted {get;set;}
    public Boolean showAttachments {get;set;}
    public String attachmentId {get;set;}
    public Boolean autoRenew {get;set;}
    public List<GCR_Content_Document_Detail__c> documentsUnderFolder {get;set;}
    public Boolean showDocumentsUnderFolder {get;set;}
    public String urlParams {get;set;}
    public List<SelectOption> folderList {get;set;}
    public Partner_Application__c newApplication {get;set;}
    public List<SelectOption> approverOptions {get;set;}
    public List<SelectOption> list_SelectedCountries { get; set; }
    public List<SelectOption> list_AllCountries {get; set;}
    public Boolean hasParterApplication {get; set;} 
    public Boolean hasoverride {get; set;} 
    // Added by Ashish Goyal
    // To check the governing contract type and enable/disable fields
    public Boolean isGovContrctType {get;set;}
    public Boolean isEffDateEnable {get;set;}
    public Boolean isExpDateEnable {get;set;}
    public Boolean isLEDateEnable {get;set;}
    public Boolean isEditHide {get;set;}
    
    
    public GCRContentDocumentDetailsController(ApexPages.StandardController stdController){
        try{
            recordId = ApexPages.currentPage().getParameters().get('id');
            String documentRecordId = ApexPages.currentPage().getParameters().get('documentRecordId');
            if(documentRecordId != null && documentRecordId != '')
                recordId = documentRecordId;
            gcrId = ApexPages.currentPage().getParameters().get('gcrId');
            accountId = ApexPages.currentPage().getParameters().get('accId');       
            lockAccountSelection = false;
            isAdminUser = GCRContentDocumentDetailsContHelper.checkForAdminUser();
            isAdminDeleteUser = GCRContentDocumentDetailsContHelper.checkForAdminDeleteUser();
            accounts = GCRContentDocumentDetailsContHelper.populateAccounts();
            gcr = new GCR__c();
            hasParterApplication = false;
            if(ApexPages.currentPage().getParameters().get('hideHeader') != null
               && ApexPages.currentPage().getParameters().get('hideHeader') == 'true')
                hideHeader = true;
            else
                hideHeader = false;
            if(ApexPages.currentPage().getParameters().get('embedded') != null
               && ApexPages.currentPage().getParameters().get('embedded') == 'true')
                embedded = true;
            else
                embedded = false;
            if(ApexPages.currentPage().getParameters().get('showAll') != null
               && ApexPages.currentPage().getParameters().get('showAll') == 'true')
                showAll = true;
            else
                showAll = false;
            
            if(ApexPages.currentPage().getParameters().get('showFromCurrentGCR') != null
               && ApexPages.currentPage().getParameters().get('showFromCurrentGCR') == 'false') 
                showFromCurrentGCR = false;
            else if((ApexPages.currentPage().getParameters().get('showFromCurrentGCR') != null
                     && ApexPages.currentPage().getParameters().get('showFromCurrentGCR') == 'true') || gcrId != null)
                showFromCurrentGCR = true;  
            
            renderPageBlock = false;
            renderFolderPagebLock = false;      
            pageMode = 'detail';
            if(recordId != null && recordId != ''){
                populateCurrentRecord();
                populateAttachments();
            }
            if(accountId != null || (!embedded && currentRecord.Account_Name__c != null)){
                if(accountId == null)
                    accountId = currentRecord.Account_Name__c;
                lockAccountSelection = true;
                currentAccount = GCRContentDocumentDetailsContHelper.populateCurrentAccount(accountId);
            } 
            if(ApexPages.currentPage().getParameters().get('addNewDocument') != null){
                addNewDocument();
            }
            if(ApexPages.currentPage().getParameters().get('addNewFolder') != null){
                addNewFolder();
            }       
            if(ApexPages.currentPage().getParameters().get('folderId') != null){
                viewFolder();
            }
            if(gcrId != null && gcrId != '' && gcrId != 'null') {
                currentGCR = GCRContentDocumentDetailsContHelper.populateGCR(gcrId);
                if(currentGCR.Partner_Application__c != null)
                    hasParterApplication = true;
                
            }
            folderList = GCRContentDocumentDetailsContHelper.getFoldersAsListItems(accountId);
            approverOptions = GCRContentDocumentDetailsContHelper.getApprovers();
            populateTreeItems();
            
            // Added by Ashish Goyal
            // To check the governing contract type on record load
            
            isGovContrctType = false;
            isEffDateEnable = true;
            isExpDateEnable = true;
            isLEDateEnable = false;
            isEditHide = false;
    
            if(currentRecord != null && currentRecord.Id != null){
                checkGoverningTypeOnLoad();
                if(currentRecord.GCR__r.Status__c == '10-Completed'){
                    isEditHide = true;
                    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'Records cannot be edited when the Legal Request is in Completed status. To edit the record, please update the Status of this Legal Request.');
                    ApexPages.addMessage(myMsg);
                }
            }
            // End Ashish
        }
        catch(Exception e){
            System.debug('Exception has occurred: '+e.getMessage()+'\n'+e.getStackTraceString());
        }        
    }
    
    private void populateAttachments(){
        Set<String> statusIds = new Set<String>();
        Map<Id, dsfs__DocuSign_Status__c> mapIdVsDocusignStatus = new Map<Id, dsfs__DocuSign_Status__c>([SELECT id FROM dsfs__DocuSign_Status__c 
                                                                                                         WHERE GCR_Content_Document__c =: recordId]); 
        attachments = new List<attachmentWrapper>();
        List<Attachment> atts = [SELECT Name, CreatedBy.Name, CreatedDate, parentId FROM Attachment 
                                 WHERE parentId =: recordId OR parentId IN : mapIdVsDocusignStatus.keyset()
                                 ORDER BY CreatedDate DESC];
        Integer counter = 1;
        for(Attachment eachAtt : atts){
            attachmentWrapper newAtt = new attachmentWrapper();
            newAtt.att = eachAtt;
            if(mapIdVsDocusignStatus.keyset().contains(eachAtt.parentId) && counter == 1)
                newAtt.isFinal = true;
            else
                newAtt.isFinal = false;         
            attachments.add(newAtt);
            counter ++;
        }
        if(attachments.isEmpty())
            showAttachments = false;
        else
            showAttachments = true;
    }
    
    
    public void setFinalAttachmentId(){
        currentRecord.Final_Attachment_Id__c = attachmentId;
        update currentRecord;
    }
    
    public void delAttachment(){
        Attachment attachmentToBeDeleted = new Attachment(id = attachmentIdToBeDeleted);
        delete attachmentToBeDeleted;
        populateAttachments();
    }
    
    
    public Id getDocusignStatusRecordId() {
        Id rid;
        List<dsfs__DocuSign_Status__c> dsid = [SELECT id FROM dsfs__DocuSign_Status__c WHERE GCR_Content_Document__c =: recordId and dsfs__Envelope_Status__c = 'Completed' order by CreatedDate DESC];
        for(dsfs__DocuSign_Status__c eachId: dsid) {
            rid = eachId.Id;
        }
        
        return rid;
    }
    
    
    public void refresh(){    
    }
    
    public void edit(){
        pageMode = 'edit';
        intializeCountryList();
    }
    
    public pageReference setAccountId(){
        PageReference pageRef = new PageReference('/apex/GCRContentDocumentDetails?accId=' + gcr.Account__c);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public void resetAccount(){
        lockAccountSelection = false;
    }
    
    public pageReference save(){
        //Added by Ashish, on request of Vivek, modified the error message
        if(!currentRecord.Is_Governing_Contract__c && isEffDateEnable && currentRecord.Effective_Date__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Effective Date: You must enter a value or select "Are Governing Contract Dates same as Subscription Term Dates?"');
            ApexPages.addMessage(myMsg);
            return null;
        }
        if(!currentRecord.Is_Governing_Contract__c && currentRecord.Expiration_Renewal_Date__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Expiration/Renewal Date: You must enter a value or select "Are Governing Contract Dates same as Subscription Term Dates?"');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        //Added by JJ
        GCR__c tempGCR;
        if(currentRecord.Id == null && currentRecord.GCR__c != null){
            tempGCR = [SELECT Id, Contract_Type__c,Opportunity__c,CCDB_Subscription__c,Subscription_Sub_Type__c    FROM GCR__c WHERE Id =:currentRecord.GCR__c];
        }
        
        if(tempGCR != null)
        {
            if(currentRecord.Contract_Category__c != null && tempGCR.Opportunity__c == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity is not selected on Legal Request Header!');
                ApexPages.addMessage(myMsg);
                return null;
            }
            
            if(currentRecord.Contract_Category__c == 'Amend' && tempGCR.Subscription_Sub_Type__c == 'Amend Existing Subscription' && tempGCR.CCDB_Subscription__c == null){
                ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'CCDB Subscription is not selected on Legal Request Header!');
                ApexPages.addMessage(myMsg);
                return null;
            }
        }
        //Commented by JJ
        /*
        if(currentRecord.Contract_Category__c != null && currentRecord.GCR__r.Opportunity__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Opportunity is not selected on Legal Request Header!');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        if(currentRecord.Contract_Category__c == 'Amend' && currentRecord.GCR__r.Subscription_Sub_Type__c == 'Amend Existing Subscription' && currentRecord.GCR__r.CCDB_Subscription__c == null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'CCDB Subscription is not selected on Legal Request Header!');
            ApexPages.addMessage(myMsg);
            return null;
        }
        */
        
        if(currentRecord.Legal_Exceptions__c != null && currentRecord.Legal_Exceptions__c != 'None' && currentRecord.Legal_Exceptions__c.contains('None')){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'A "None" value for Legal Exceptions mean there are no Legal Exceptions in this contract to be identified. You may not select "None" Legal Exceptions in combination with other Legal Exceptions. Please review and update your selections appropriately.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        
        String selectedCountries = '';
        for(SelectOption so :list_SelectedCountries) {
            selectedCountries += so.getLabel() + ';';       
        }
        if(selectedCountries.length() > 0) {
            currentRecord.Territory_ies__c =  selectedCountries.substring(0,selectedCountries.length()-1);   
        }
        else if(selectedCountries.length() == 0) {
            currentRecord.Territory_ies__c = '';        
        }
        
        if(currentRecord.Agreement_Type__c != null && !currentRecord.Agreement_Type__c.contains('Other') && currentRecord.Partner_Agreement_Type_Other__c != null) {
            currentRecord.Partner_Agreement_Type_Other__c = '';    
        }
        if(currentRecord.Contract_Type__c != 'Partner Agreement' ) {
            currentRecord.Agreement_Type__c = '';
            currentRecord.Partner_Agreement_Type_Other__c = '';
            currentRecord.Current_Partner_Agreement__c = false;
            currentRecord.Territory_ies__c = '';    
        }
        currentRecord.IsGoverningContract__c = isGovContrctType;
        upsert currentRecord;
                
        pageMode = 'detail';
        populateTreeItems();
        if(ApexPages.currentPage().getParameters().get('parentId') != null){
            PageReference pageRef;
            if(currentRecord == null)
                pageRef = new PageReference('/apex/GCRContentDocumentDetails?accId=' + accountId + '&gcrId=' + gcrId + '&showAll=' + showAll + '&embedded=' + embedded + '&hideHeader=' + hideHeader + '&showFromCurrentGCR=' + showFromCurrentGCR);
            else
                pageRef = new PageReference('/apex/GCRContentDocumentDetails?id=' + currentRecord.id + '&accId=' + accountId + '&gcrId=' + gcrId + '&showAll=' + showAll + '&embedded=' + embedded + '&hideHeader=' + hideHeader + '&showFromCurrentGCR=' + showFromCurrentGCR);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }
    
    public pageReference showAll(){
        PageReference pageRef;
        if(currentRecord == null)
            pageRef = new PageReference('/apex/GCRContentDocumentDetails?accId=' + accountId + '&gcrId=' + gcrId + '&showAll=' + showAll + '&embedded=' + embedded + '&hideHeader=' + hideHeader + '&showFromCurrentGCR=' + showFromCurrentGCR);
        else
            pageRef = new PageReference('/apex/GCRContentDocumentDetails?id=' + currentRecord.id + '&accId=' + accountId + '&gcrId=' + gcrId + '&showAll=' + showAll + '&embedded=' + embedded + '&hideHeader=' + hideHeader + '&showFromCurrentGCR=' + showFromCurrentGCR);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public pageReference showFromCurrentGCR(){
        PageReference pageRef;
        if(currentRecord == null)
            pageRef = new PageReference('/apex/GCRContentDocumentDetails?accId=' + accountId + '&gcrId=' + gcrId + '&showAll=' + showAll + '&embedded=' + embedded + '&hideHeader=' + hideHeader + '&showFromCurrentGCR=' + showFromCurrentGCR);
        else
            pageRef = new PageReference('/apex/GCRContentDocumentDetails?id=' + currentRecord.id + '&accId=' + accountId + '&gcrId=' + gcrId + '&showAll=' + showAll + '&embedded=' + embedded + '&hideHeader=' + hideHeader + '&showFromCurrentGCR=' + showFromCurrentGCR);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public void viewFolder(){
        renderPageBlock = false;
        renderFolderPagebLock = true;
        pageMode = 'detail';
        String folderId = ApexPages.currentPage().getParameters().get('folderId'); 
        currentRecordFolder = GCRContentDocumentDetailsContHelper.populateFolderRecord(folderId);
        documentsUnderFolder = GCRContentDocumentDetailsContHelper.getDocumentsForFolder(folderId, accountId);
        if(documentsUnderFolder.isEmpty())
            showDocumentsUnderFolder = false;
        else
            showDocumentsUnderFolder = true;
        urlParams = GCRContentDocumentDetailsContHelper.getURLParams(accountId, gcrId, hideHeader, embedded, showAll, isAdminUser, showFromCurrentGCR);
    }
    
    public pageReference deleteFolder(){
        List<GCR_Content_Document_Detail__c> childDocuments = [SELECT id FROM GCR_Content_Document_Detail__c WHERE Folder__c =: currentRecordFolder.id ];//AND Active__c = true
        if(!childDocuments.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You can not delete this folder as it contains document(s).'));
            return null; 
        }
        List<GCR_Content_Document_Folder__c> childFolders = [SELECT id FROM GCR_Content_Document_Folder__c WHERE Parent_Folder__c =: currentRecordFolder.id ];//AND Active__c = true
        if(!childFolders.isEmpty()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'You can not delete this folder as it contains folder(s).'));
            return null; 
        }
        GCR_Content_Document_Folder__c folderToBeDeleted = new GCR_Content_Document_Folder__c(id = currentRecordFolder.id, Active__c = false);
        update folderToBeDeleted;
        return returnPageReference();
    }
    
    private void addNewFolder(){
        renderPageBlock = false;
        renderFolderPagebLock = true;
        String parentId = ApexPages.currentPage().getParameters().get('parentId');
        currentRecordFolder = new GCR_Content_Document_Folder__c();
        if(parentId != '' && parentId != null){         
            GCR_Content_Document_Folder__c parentFolder = GCRContentDocumentDetailsContHelper.populateFolderRecord(parentId);
            currentRecordFolder.Parent_Folder__c = parentFolder.id;
            currentRecordFolder.Account__c = accountId;
            if(gcrId != null && gcrId != 'null' && gcrId != '')
                currentRecordFolder.GCR__c = gcrId;
        }               
        else{
            if(accountId != null && accountId != '')
                currentRecordFolder.Account__c = accountId;
            if(gcrId != null && gcrId != 'null' && gcrId != '')
                currentRecordFolder.GCR__c = gcrId;
        }
        currentRecordFolder.Active__c = true;
        pageMode = 'edit';          
    }
    
    public pageReference saveFolder(){
        upsert currentRecordFolder;     
        return returnPageReference();       
    }
    
    public void editFolder(){
        pageMode = 'edit';
    }
    
    public void addNewDocument(){
        try{
            renderPageBlock = true;
            String parentId = ApexPages.currentPage().getParameters().get('parentId');  
            currentRecord = new GCR_Content_Document_Detail__c();
            currentRecord.Folder__c = parentId;
            currentRecord.Account_Name__c = accountId;
            if(gcrId != null && gcrId != 'null' && gcrId != '') {
                System.debug('gcrId--if->'+gcrId);
                System.debug('currentRecord->'+gcrId);
                currentRecord.GCR__c = gcrId;
                GCR__c tempcurrentGCR = GCRContentDocumentDetailsContHelper.populateGCR(gcrId);
                currentRecord.Agreement_Type__c = tempcurrentGCR.Partner_Contract_Type__c;
                //currentRecord.Amendments__c = tempcurrentGCR.Amendment__c;
                //currentRecord.Amendments_Other__c = tempcurrentGCR.Amendment_Other__c; 
                currentRecord.Partner_Agreement_Type_Other__c = tempcurrentGCR.Partner_Contract_Type_Other__c;
                if(tempcurrentGCR.Contract_Type__c == 'Partner Contract') {
                    currentRecord.Contract_Type__c = 'Partner Agreement';    
                }
                /*if(tempcurrentGCR.Partner_Application__c != null) {
hasParterApplication = true;
currentRecord.Contract_Type__c = 'Partner Agreement';
}*/
            }
            currentRecord.Active__c = true;
            pageMode = 'edit';
            intializeCountryList();
            GCR__c objGCR = [SELECT Subscription_Sub_Type__c,Opportunity__c ,CCDB_Subscription__r.Opportunity_LookUp__c,CCDB_Subscription__r.Legal_Exceptions__c, 
                                CCDB_Subscription__r.Contract_Expiration_Date__c, CCDB_Subscription__r.Contract_Effective_Date__c 
                                FROM GCR__c WHERE id = :gcrId] ;  
            if( objGCR != null && objGCR.Subscription_Sub_Type__c != '' && objGCR.Subscription_Sub_Type__c == 'Amend Existing Subscription'){
                if(objGCR.CCDB_Subscription__r.Legal_Exceptions__c != null) {
                    currentRecord.Legal_Exceptions__c = objGCR.CCDB_Subscription__r.Legal_Exceptions__c;
                }
                currentRecord.Effective_Date__c = objGCR.CCDB_Subscription__r.Contract_Effective_Date__c;
                currentRecord.Expiration_Renewal_Date__c = objGCR.CCDB_Subscription__r.Contract_Expiration_Date__c;
            }      
        }catch(Exception e){System.debug('Exception has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());}       
    }
    
    public pageReference deleteDocument(){
        currentRecord.Active__c = false;
        update currentRecord;
        return returnPageReference();
    }
    
    private pageReference returnPageReference(){
        PageReference pageRef = new PageReference('/apex/GCRContentDocumentDetails?accId=' + accountId + '&gcrId=' + gcrId + '&hideHeader=' + hideHeader + '&embedded=' + embedded + '&showAll='+showAll + '&showFromCurrentGCR=' + showFromCurrentGCR);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    public PageReference cancel(){      
        String parentId = ApexPages.currentPage().getParameters().get('parentId');
        if(parentId != null){
            return returnPageReference();
        }
        pageMode = 'detail';        
        return null;
    }
    
    public void populateCurrentRecord(){
        renderPageBlock = true;
        currentRecord = GCRContentDocumentDetailsContHelper.populateCurrentRecord(recordId);
        System.debug('currentRecord-->'+currentRecord);
    }
    
    public void populateTreeItems(){
        treeItems = GCRContentDocumentDetailsContHelper.populateTreeItems(accountId, gcrId, isAdminUser, recordId, hideHeader, embedded, showAll, showFromCurrentGCR);
    }
    
    public pagereference sendToFinanceDirectly(){          
        if(currentRecord.Legal_Approval_Signature_Configuration__c != null)     {           
            submitForApproval();
            String url =  ApexPages.currentPage().getUrl();
            PageReference pageRef = new PageReference(url +'/documentRecordId' );          
            return pageRef;           
          
        }
        else {
            
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select an Override Default Approval in order to send for finance approval');
            ApexPages.addMessage(myMsg);           
            return null;
        } 
        
    }
    
    public void sendToFinanceViaDocusign(){     
        PageReference pRef = new PageReference('/apex/loop__looplus?sessionId=' + UserInfo.getSessionId() + '&eid=' + recordId );
        pRef.setRedirect(true);
        //return pRef;
    }
    public void submitForApproval(){
        GCRContentDocumentApprovalsHelper.submitForFinanceApprovals(currentRecord);
    }
    
    public void approve(){
        currentGCR.Status__c = '6-Approved by Finance';
        update currentGCR;
    }
    
    
    public List<dsfs__DocuSign_Recipient_Status__c> getDocusignRecpDisplay() {
        
        List<dsfs__DocuSign_Recipient_Status__c> docusignRecp  = new List<dsfs__DocuSign_Recipient_Status__c>();
        List <dsfs__DocuSign_Status__c>  docusignStatus = new List <dsfs__DocuSign_Status__c>();
        
        if(recordId != null && recordId <> '') {
            
            docusignStatus = [Select id from dsfs__DocuSign_Status__c where GCR_Content_Document__c= :recordId ];
            
            if( docusignStatus.isEmpty()) {
                
            }
            else { 
                docusignRecp = [Select id,dsfs__DocuSign_Recipient_Email__c,dsfs__Date_Sent__c,dsfs__Date_Delivered__c,dsfs__Recipient_Status__c,dsfs__Date_Signed__c from dsfs__DocuSign_Recipient_Status__c where dsfs__Parent_Status_Record__c in :docusignStatus];
            }
        }
        
        if(docusignRecp.isEmpty())
            return null;
        else
            return docusignRecp ;
    }
    
    
    
    /*
@RemoteAction
public static List<Account> searchAccount(String searchTerm) {
System.debug('Account Name is: '+searchTerm );
List<Account> accounts = Database.query('SELECT Id, Name FROM Account WHERE Name LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' LIMIT 10');
return accounts;
}
*/
    //Wrapper class
    public class treeNodes {
        public Boolean isFolder {get;set;}
        public Boolean isAddFolder {get;set;}
        public Boolean isDocument {get;set;}
        public Boolean isAddDocument {get;set;}     
        public String recordId {get;set;}
        public String record {get;set;}
        public Boolean isAddDocumentTop {get;set;}
        public List<treeNodes> childRecords {get;set;}
        public treeNodes(String r, List<treeNodes> childs, Boolean isFolder, Id id){
            this.record = r;
            this.childRecords = childs;
            this.isFolder = isFolder;
            this.recordId = id;
            this.isAddFolder = false;
            this.isDocument = false;
            this.isAddDocument = false;
            this.isAddDocumentTop = false;          
        }
    }
    public class attachmentWrapper{
        public Attachment att {get;set;}
        public Boolean isFinal {get;set;}
    }
    
    
    public void intializeCountryList()
    {
        list_AllCountries = new List<SelectOption>(); 
        list_SelectedCountries = new List<SelectOption>();
        List<Country__c> list_Countries = [SELECT Id,Name FROM Country__c where Country__c not in ('Cuba','Iran','North Korea','Sudan','Syria') ORDER BY Name];
        if(gcrId != null && gcrId != 'null' && gcrId != '') {
            GCR__c gcrRecord = [select Id,Partner_Application__c from GCR__c where Id =: gcrId];
            if(ApexPages.currentPage().getParameters().get('addNewDocument') != null && gcrRecord.Partner_Application__c != null) {
                List<Partner_Application_Category_and_Country__c> list_ExistingCombinations = [SELECT Category__c, Country__c,Country__r.Name 
                                                                                               FROM Partner_Application_Category_and_Country__c
                                                                                               WHERE Partner_Application__c =: gcrRecord.Partner_Application__c 
                                                                                               ORDER BY Category__c];
                Map<Id,String> mapSelectedCountries = new Map<Id,String>();
                System.debug('list_ExistingCombinations->'+list_ExistingCombinations);
                for(Partner_Application_Category_and_Country__c objCombination : list_ExistingCombinations)
                {
                    if(!mapSelectedCountries.containsKey(objCombination.Country__c))
                        mapSelectedCountries.put(objCombination.Country__c,objCombination.Country__r.Name);
                }
                System.debug('mapSelectedCountries-->'+mapSelectedCountries);
                for(Country__c objCountry : list_Countries)
                {
                    if(mapSelectedCountries.containsKey(objCountry.Id))
                        list_SelectedCountries.add(new SelectOption(objCountry.Id,objCountry.Name));
                    else
                        list_AllCountries.add(new SelectOption(objCountry.Id,objCountry.Name));
                }
                list_AllCountries.add(new SelectOption('Global','Global'));
            }
            else if (ApexPages.currentPage().getParameters().get('addNewDocument') != null && gcrRecord.Partner_Application__c == null) {
                for(Country__c objCountry : list_Countries)
                {
                    list_AllCountries.add(new SelectOption(objCountry.Id,objCountry.Name));
                }
                list_AllCountries.add(new SelectOption('Global','Global'));
            }
            else if (pageMode == 'edit') {
                Set<String> setCountries = new Set<String>();
                String selCountries = currentRecord.Territory_ies__c;
                System.debug('selCountries-->'+selCountries);
                if(selCountries != null) {
                    List<String> lstSelCountries = selCountries.split(';');
                    for(String str : lstSelCountries) {
                        setCountries.add(str);    
                    }    
                }
                
                for(Country__c objCountry : list_Countries)
                {
                    if(setCountries.contains(objCountry.Name))
                        list_SelectedCountries.add(new SelectOption(objCountry.Id,objCountry.Name));
                    else
                        list_AllCountries.add(new SelectOption(objCountry.Id,objCountry.Name));
                }
                if(setCountries.contains('Global')) {
                    list_SelectedCountries.add(new SelectOption('Global','Global'));            
                }
                else
                {
                    list_AllCountries.add(new SelectOption('Global','Global'));
                }
            }
        }
        if(list_AllCountries.size() > 0 ) {
            list_AllCountries.sort();
        }
        if(list_SelectedCountries.size() > 0 ) {
            list_SelectedCountries.sort();
        }
    }
    
    public Id getPartnerDDP() {
        return [Select Id from Loop__DDP__c where Name=: System.Label.Send_To_Partner_DDP].Id;    
    }
    
    
    
    /*
    * @author: Ashish Goyal
    * @desc: check the governing contract type
    */
    public void checkRequiredField(){
        GCR__c tempGCR;
        if(currentRecord.Id == null && currentRecord.GCR__c != null){
            tempGCR = [SELECT Id, Offering_Type__c, Contract_Type__c FROM GCR__c WHERE Id =:currentRecord.GCR__c];
        }
        
       // if(currentRecord.Contract_Category__c == 'Amend' && ((tempGCR != null && tempGCR.Offering_Type__c != 'PureEngage' && tempGCR.Contract_Type__c != 'Amendment') || 
       //(currentRecord.GCR__r.Offering_Type__c != 'PureEngage' && currentRecord.GCR__r.Contract_Type__c != null && currentRecord.GCR__r.Contract_Type__c != 'Amendment'))){
        if(currentRecord.Contract_Category__c == 'Amend' && ((tempGCR != null &&  tempGCR.Contract_Type__c != 'Amendment') || 
               (currentRecord.GCR__r.Contract_Type__c != null && currentRecord.GCR__r.Contract_Type__c != 'Amendment'))){         
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Amended contracts must have the Contract Request Type selection as Amendment within the Legal Request Details tab. Please contact the Requestor to populate the Contract Request Type as ‘Amendment’, the Subscription Sub-Type as ‘Amend Existing Subscription’, and select the CCDB/Subscription to be amended in order to proceed with this legal request.');
            ApexPages.addMessage(myMsg);
            return;
        }
        //if(currentRecord.Contract_Category__c == 'New' && ((tempGCR != null && tempGCR.Offering_Type__c != 'PureEngage' && tempGCR.Contract_Type__c != 'New Contract') ||
        //(currentRecord.GCR__r.Offering_Type__c != 'PureEngage' && currentRecord.GCR__r.Contract_Type__c != null && currentRecord.GCR__r.Contract_Type__c != 'New Contract'))){
         if(currentRecord.Contract_Category__c == 'New' && ((tempGCR != null &&  tempGCR.Contract_Type__c != 'New Contract') ||               
                        (currentRecord.GCR__r.Contract_Type__c != null && currentRecord.GCR__r.Contract_Type__c != 'New Contract'))){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'New contracts must have the Contract Request Type selection as New Contract within the Legal Request Details tab. Please contact the Requestor to populate the Contract Request Type as ‘New Contract’ and the Subscription Sub-Type as ‘New Org & Subscription’ in order to proceed with this request.');
            ApexPages.addMessage(myMsg);
            return;
        }
        checkGoverningType();
    }
    
    
    /*
    * @author: Ashish Goyal
    * @desc: check the governing contract type
    */
    public void checkGoverningType(){
        GCR__c tempGCR;
        if(currentRecord.Id == null && currentRecord.GCR__c != null){
            tempGCR = [SELECT Id, Offering_Type__c FROM GCR__c WHERE Id =:currentRecord.GCR__c];
        }
        
        for(Governing_Contract_Type__mdt custMD : [SELECT Governing_Contract_Type__c, Offering_Type__c FROM Governing_Contract_Type__mdt]){
            String offeringType = custMD.Offering_Type__c;
            if(offeringType == 'PureConnect Cloud'){
                offeringType = 'PureConnect';
            }
             if(offeringType == 'PureEngage Cloud'){
                offeringType = 'PureEngage';
            }
            if(currentRecord.Contract_Type__c == custMD.Governing_Contract_Type__c && ((tempGCR != null && tempGCR.Offering_Type__c == offeringType) ||
                currentRecord.GCR__r.Offering_Type__c == offeringType)){
                isGovContrctType = true;
                
                //first time, the checkbox should be checked. 
                if(currentRecord.Contract_Category__c == 'New'){
                    currentRecord.Is_Governing_Contract__c = true;
                }
                break;
            }
            else{
                isGovContrctType = false;     
                currentRecord.Is_Governing_Contract__c = false;                  
            }
        }
        enableGoveringFields();
    }
    
    
    /*
    * @author: Ashish Goyal
    * @desc: check the governing contract type
    */
    public void checkGoverningTypeOnLoad(){
        GCR__c tempGCR;
        if(currentRecord.Id == null && currentRecord.GCR__c != null){
            tempGCR = [SELECT Id, Offering_Type__c FROM GCR__c WHERE Id =:currentRecord.GCR__c];
        }
        
        for(Governing_Contract_Type__mdt custMD : [SELECT Governing_Contract_Type__c, Offering_Type__c FROM Governing_Contract_Type__mdt]){
            String offeringType = custMD.Offering_Type__c;
            if(offeringType == 'PureConnect Cloud'){
                offeringType = 'PureConnect';
            }
            if(offeringType == 'PureEngage Cloud'){
                offeringType = 'PureEngage';
            }
            if(currentRecord.Contract_Type__c == custMD.Governing_Contract_Type__c && ((tempGCR != null && tempGCR.Offering_Type__c == offeringType) ||
                currentRecord.GCR__r.Offering_Type__c == offeringType)){
                isGovContrctType = true;
                break;
            }
            else{
                isGovContrctType = false;                       
            }
        }
        enableGoveringFields();
    }
    
    
    /*
    * @author: Ashish Goyal
    * @desc: enable/disable the fields on page on basis of governing contract type
    */
    public void enableGoveringFields(){
        GCR__c tempGCR;
        if(currentRecord.Id == null && currentRecord.GCR__c != null){
            tempGCR = [SELECT Id, Offering_Type__c FROM GCR__c WHERE Id =:currentRecord.GCR__c];
        }
        //if((tempGCR != null && tempGCR.Offering_Type__c != 'PureEngage') || (currentRecord.Id != null && currentRecord.GCR__r.Offering_Type__c != 'PureEngage')){
            if((tempGCR != null ) || (currentRecord.Id != null )){
            if(currentRecord.Contract_Category__c == 'New' && isGovContrctType && !currentRecord.Is_Governing_Contract__c){
                isEffDateEnable = true;
                isExpDateEnable = true;
                isLEDateEnable = true;
            }
            else if(currentRecord.Contract_Category__c == 'New' && !isGovContrctType){
                isEffDateEnable = true;
                isExpDateEnable = true;
                isLEDateEnable = false;
            }
            else if(currentRecord.Contract_Category__c == 'New' && isGovContrctType && currentRecord.Is_Governing_Contract__c){
                isEffDateEnable = false;
                isExpDateEnable = false;
                isLEDateEnable = true;
                currentRecord.Effective_Date__c = null;
                currentRecord.Expiration_Renewal_Date__c = null;
            }
            
            if(currentRecord.Contract_Category__c == 'Amend' && isGovContrctType && !currentRecord.Is_Governing_Contract__c){
                isEffDateEnable = true;
                isExpDateEnable = true;
                isLEDateEnable = true;
            }
            else if(currentRecord.Contract_Category__c == 'Amend' && !isGovContrctType){
                isEffDateEnable = true;
                isExpDateEnable = true;
                isLEDateEnable = false;
            }
            else if(currentRecord.Contract_Category__c == 'Amend' && isGovContrctType && currentRecord.Is_Governing_Contract__c){
                isEffDateEnable = false;
                isExpDateEnable = false;
                isLEDateEnable = true;
                currentRecord.Effective_Date__c = null;
                currentRecord.Expiration_Renewal_Date__c = null;
            }
            
            if(currentRecord.Contract_Category__c == 'Amend' && currentRecord.Contract_Type__c == 'Service Order'){
                isEffDateEnable = false;
                isExpDateEnable = true;
                isLEDateEnable = true;
                currentRecord.Effective_Date__c = null;
            }
            //kartik 
             if((tempGCR != null && tempGCR.Offering_Type__c == 'PureCloud' ||currentRecord.GCR__r.Offering_Type__c == 'PureCloud'  ) && currentRecord.Contract_Category__c == 'Amend' && currentRecord.Contract_Type__c == 'PureCloud T&C' && !currentRecord.Is_Governing_Contract__c){
                isEffDateEnable = false;
                isExpDateEnable = true;
            } 
            if((tempGCR != null && tempGCR.Offering_Type__c == 'PureConnect' || currentRecord.GCR__r.Offering_Type__c == 'PureConnect' ) && currentRecord.Contract_Category__c == 'Amend' && currentRecord.Contract_Type__c == 'Master Subscription Agreement' && !currentRecord.Is_Governing_Contract__c){
                isEffDateEnable = false;
                isExpDateEnable = true;
            }
            if((tempGCR != null && tempGCR.Offering_Type__c == 'PureEngage' || currentRecord.GCR__r.Offering_Type__c == 'PureEngage' ) && currentRecord.Contract_Category__c == 'Amend' && currentRecord.Contract_Type__c == 'Master Subscription Agreement' && !currentRecord.Is_Governing_Contract__c){
                isEffDateEnable = false;
                isExpDateEnable = true;
            }
            //kartik 
        }
    }
}