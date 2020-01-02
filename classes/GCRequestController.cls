public with sharing class GCRequestController {
    
    public GCR__c record {get;set;}
    public String reqType {get;set;}
    public Attachment attachment {get;set;}
    public String subject { get; set; }
    public String body { get; set; }
    public String cc { get; set; }
    public boolean isComplete {get;set;}
    public String oppId{get;set;}
    public String accId{get;set;}
    public String documentId {get;set;}    
    public String strCountry{get;set;}
    public DateTime strDateTime{get;set;}
    public String strRequestor{get;set;}
    public String strProfileId{get;set;}
    public String strAccountLegal{get;set;}
    public String strContact{get;set;}
    public String strEmail{get;set;}
    public String gcrInitialStatus {get;set;}
    public String selectedView {get;set;}
    public List<SelectOption> options {get;set;}
    public Boolean showResult {get;set;}
    public transient List<GCR__c> gcrs {get;set;}
    public List<GCR__c> gcrApprovals {get;set;}
    public string ndaCon{get;set;}
    public string currentStatus{get;set;}
    public Boolean ndaShow {get;set;}
    private String recipient;
    public String mailTo {get;set;}
    public List<AttorneyDetailWrapper> attorneyDetailList{get;set;}
    public Boolean newAction {get;set;}
    public List<ProcessInstance> prosIns{get;set;}
    public List<ProcessInstanceWorkitem> prosInsWrkItms{get;set;}
    public Boolean showAttorneyWorkload {get;set;}
    public Boolean showParterType {get;set;}
    
    public ApexPages.StandardSetController setRecords{
        get{
            if(setRecords == null){
                setRecords = new ApexPages.StandardSetController(gcrs);
                setRecords.setPageSize(10);
            }  
            return setRecords;
        }set;
    }
    
    public List<GCR__c> getSObjectRecords(){
        List<GCR__c> sObjList = New List<GCR__c>();
        for(GCR__c SObj :(List<GCR__c>)setRecords.getRecords())
            sObjList.add(SObj); 
        return  sObjList ;   
        
    }
    
    public String selectedRecordId{get;set;}
    
    public String attIdToDelete{get;set;}
    public List<Attachment> attachmentList{get;set;}
    
    public String ActiveTab {get; set;}
    
    public GCR_Values__c gcrReplyToEmail;
    
    
    public Boolean isAdmin{get;set;}
    public Boolean isSales{get;set;}
    public Boolean isFinance{get;set;}
    public Boolean isUser{get;set;}
    public Boolean showTabs{get;set;}
    
    public Attachment emailAttachment{get;set;}
    
    public Boolean allRequests{get;set;}
    
    public List<AttachmentWrapper> attWrapperlist{get;set;}
    public String documentRecordId {get;set;}
    public GCRequestController() {
        strRequestor =UserInfo.getUserId() ;
    }
    public GCRequestController(ApexPages.StandardController stdCont) {
        
        attWrapperlist = new List<AttachmentWrapper>();
        emailAttachment = new Attachment();
        showTabs = false;
        ActiveTab = 'home';
        record = new GCR__c();
        record = (GCR__c)stdCont.getrecord(); 
       system.debug('record' + record );
        allRequests = false;
        isUser=false;
        gcrInitialStatus = GCRContentDocumentDetailsContHelper.GCR_STATUS_INITIAL;
        cc = UserInfo.getUserEmail();
        attorneyDetailList = new List<AttorneyDetailWrapper>();
        selectedRecordId = stdCont.getId();
        oppId = ApexPages.currentPage().getParameters().get('oppid');
        accId = ApexPages.currentPage().getParameters().get('accid');
        documentId = ApexPages.currentPage().getParameters().get('documentId');
        documentRecordId = ApexPages.currentPage().getParameters().get('documentRecordId');
        isAdmin = GCRContentDocumentDetailsContHelper.checkForAdminUser();
        isSales = !isAdmin;
        List<String> userNames = Label.Legal_contract_request.split(',');
        isUser = userNames.contains(UserInfo.getUserName());
        isSales = !isAdmin;
        if(isUser){
            isSales=false;
        }

        if(selectedRecordId != null && selectedRecordId.length() > 0)
            retrieveRecord();        
        else{
            Opportunity opp;
            if(oppId!=null && oppId.length() > 0){
                createNew();
                opp = [SELECT id, name, AccountId, Account.Country__r.Name, Account.Country__r.Region__c,
                       Primary_Line_of_Business__c, Offering_Detail__c, Lines_of_Businesses__c FROM Opportunity WHERE id=:oppId limit 1];
                record.Account__c = opp.AccountId;
                record.Opportunity__c = opp.id;
                record.Region__c = opp.Account.Country__r.Region__c;
                record.Request_Type__c = 'Sales';
                record.Platform_Type__c = opp.Primary_Line_of_Business__c;
                record.Offering_Type__c = opp.Lines_of_Businesses__c;
                record.Offering_Details__c = opp.Offering_Detail__c;
                record.Requestor_Name__c = UserInfo.getUserId() ;
                if(opp.Account.Country__r.Name == 'Brazil'){
                    record.Region__c = 'Brazil';
                } 
            }
            else{
                if(accId!=null && accId.length() > 0 && oppId ==null) {
                    Account acct;
                    createNew();
                    acct = [Select id, name, Country__r.Name, Country__r.Region__c from Account where id =:accId limit 1];
                    record.Account__c = accId;
                    record.Region__c = acct.Country__r.Region__c;
                    record.Request_Type__c = 'Sales';
                     record.Requestor_Name__c = UserInfo.getUserId() ;
                    if(documentId != null && documentId.length() > 0) {
                        record.GCR_Content_Document_Detail__c = documentId;
                    }  
                    if(acct.Country__r.Name == 'Brazil'){
                        record.Region__c = 'Brazil';
                    }           
                }
            } 
            setRegionAndRequestType();  
        }
        
        attachment = new Attachment();
        reqType = '';
        attachmentList = new List<Attachment>();
        
        if(isSales == true){
            options = new List<SelectOption>();
            SelectOption newOption = new SelectOption('Opened', 'All My open request');
            options.add(newOption);
            newOption = new SelectOption('Closed', 'All My Closed Requests');
            options.add(newOption);
            
            selectedView = 'Opened';
        }        
        else{
            options = new List<SelectOption>();
            SelectOption newOption = new SelectOption('All', 'All Requests');
            options.add(newOption);
            newOption = new SelectOption('AssignedToMe', 'Assigned To Me');
            options.add(newOption);            
            newOption = new SelectOption('compMonth', 'Completed This Month');
            options.add(newOption);
            newOption = new SelectOption('compYear', 'Completed This Year');
            options.add(newOption);
            newOption = new SelectOption('1-New', '1-New');
            options.add(newOption);
            newOption = new SelectOption('2-Assigned to Attorney', '2-Assigned to Attorney');
            options.add(newOption);
            newOption = new SelectOption('3-In Progress', '3-In Progress');
            options.add(newOption);
            
            newOption = new SelectOption('4-Approved By Legal', '4-Approved By Legal');
            options.add(newOption);
            newOption = new SelectOption('5-Pending Finance Approval', '5-Pending Finance Approval');
            options.add(newOption);
            
            newOption = new SelectOption('6-Approved by Finance', '6-Approved by Finance');
            options.add(newOption);
            newOption = new SelectOption('7-Rejected by Finance', '7-Rejected by Finance');
            options.add(newOption);
            newOption = new SelectOption('8-Metadata Complete', '8-Metadata Complete');
            options.add(newOption);
            newOption = new SelectOption('9-Signed by Genesys', '9-Signed by Genesys');
            options.add(newOption);
            newOption = new SelectOption('10-Signed by Customer', '10-Signed by Customer');
            options.add(newOption);            
            newOption = new SelectOption('11-Completed', '11-Completed');
            options.add(newOption);
            
            
            selectedView = 'All';
        }
        
        showResult = true;
        loadRecords();
        gcrReplyToEmail = GCR_Values__c.getValues('GCR_Reply_To_Email');
        
        
        //System.debug('*****gcrReplyToEmail'+gcrReplyToEmail);
        //System.debug('*****gcrReplyToEmail Value'+gcrReplyToEmail.value__c);
        
        
        strDateTime =null;
        strCountry = null;
        strRequestor =null;
        strEmail=null;
        strAccountLegal  = null;
        strContact = null;
        
        if(ApexPages.CurrentPage().getParameters().get('accid')!=null){
            strAccountLegal = ApexPages.CurrentPage().getParameters().get('accid');
        }
        
        
        strProfileId = Userinfo.getProfileId();
        System.debug('profileId'+strProfileId);
        
        if(!isAdmin){
            record.Request_Type__c = 'Sales';
        }
        //retrieveApprovalRecord();
        populateRecipients();
        String crt = ApexPages.CurrentPage().getParameters().get('crt');
        System.debug('crt--->'+crt);
        if( crt != null){
            record.Contract_Type__c = crt;
        }
        if( crt == 'Partner Contract'){
            record.Request_Type__c = 'Partner';
        }
        if(ApexPages.CurrentPage().getParameters().get('t') != null){
            ActiveTab = ApexPages.CurrentPage().getParameters().get('t');
        }
        if(ApexPages.currentPage().getParameters().get('appId') != null){
            record.Partner_Application__c = ApexPages.currentPage().getParameters().get('appId'); 
            //record.Contract_Type__c = 'New Contract';           
            showTabs = true;
            ActiveTab = 'gcrDetails';
        }
        populateAttorneyDetails();
        if(record.Region__c != null) {
            if(record.Region__c.contains('North America')){
                record.Region__c = 'North America (John Garcia/Tracey McAllister)';          
            }
            else if(record.Region__c.contains('APAC')){
                record.Region__c = 'APAC (Vincent Lim)';             
            }
            else if(record.Region__c.contains('EMEA')){
                record.Region__c = 'EMEA';          
            }
            else if(record.Region__c.contains('LATAM')){
                record.Region__c = 'LATAM (Jaime Borja)';
            }
        }            
        
    }
    
    public PageReference createGCRequest(){
        if(ApexPages.currentPage().getParameters().get('id') == null && ApexPages.currentPage().getParameters().get('sfdc.tabName') == null){
            record.Status__c = null;                
            insert record;
            PageReference pageRef = new pageReference('/apex/GCRequest?id='+ record.id);
            pageRef.setRedirect(true);
            return pageRef;
        }
        return null;
    }
    
    public void showAttorneyWorkload(){
        showAttorneyWorkload = true;
    }
    public void hideAttorneyWorkload(){
        showAttorneyWorkload = false;
    }
    public void resetNewAction(){
        if(record.id != null ){
            GCR__c gcrToBeUpdate = new GCR__c (id = record.id);
            gcrToBeUpdate.New_Action__c = false;
            newAction = false;
            update gcrToBeUpdate;
        }
    }
    
    public void queryRequestorInfo(){
        strDateTime =null;
        strCountry = null;
        try{
            if(strRequestor != null && record.Id!=null ){
                User usrObj = [SELECT Id,LanguageLocaleKey,LocaleSidKey,TimeZoneSidKey FROM User Where Id =: strRequestor LIMIT 1];
                if(usrObj != null){
                    strCountry = usrObj.TimeZoneSidKey;
                    if(record.CreatedDate !=null){
                        strDateTime = record.CreatedDate;
                    }
                    else{
                        strDateTime = System.Now();
                    }
                }
            }
        }catch(Exception ex){ }
    }
    public void setRegionAndRequestType(){
        System.debug('strAccountLegal'+strAccountLegal);
        //&& strProfileId == '00e11000000QP5K'
        try{
            if(strAccountLegal != null){    
                Account result = [SELECT Id,TM_Acc_Country_Region__c From Account Where Id =: strAccountLegal Limit 1];    
                if(result != null){
                    record.Region__c = result.TM_Acc_Country_Region__c ;
                    record.Request_Type__c ='Sales';  
                    
                    
                    if(record.Region__c != null) {
                        if(record.Region__c.contains('North America'))
                            record.Region__c = 'North America (John Garcia/Tracey McAllister)';
                    }
                    
                    
                }
            } 
        }catch(Exception ex){ }
    }
    public void setContactDetails(){
        strEmail = null;
        try{
            System.debug('contact id'+strContact);
            if(strContact != null){
                Contact conResult = [SELECT Id,ContactPhone__c,Name,Email From Contact Where Id =:strContact LIMIT 1];
                if(conResult != null){
                    record.Contact_Name__c = conResult.Name;
                    record.Contact_Phone__c = conResult.ContactPhone__c;
                    strEmail = conResult.Email;
                }
            }
        }catch(Exception ex){ }
    }
    public void loadRecords(){ 
        /*gcrApprovals = [SELECT Name, Request_Type__c,Date_Submitted__c,Date_Approved__c,
Status__c, Assigned_to_Attorney__c FROM GCR__c  
Where Status__c IN('Approved','Pending Approval')
ORDER BY createddate desc];
*/
        System.debug('******selectedView'+selectedView);
        if(isSales == true){
            System.debug('******isSales'+isSales);
            if(selectedView == 'Opened'){
                gcrs = [SELECT Name, Priority__c,Attorney_Name__c,Contract_Due_Date__c,Account__c,Owner.name,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c,Requestor_Name__c, Synopsis__c, Description__c, Request_Type__c,
                        Subscription_Sub_Type__c, CreatedDate, Status__c, Assigned_to_Attorney__c,New_Action__c, Partner_Contract_Type_Other__c, Offering_Type__c,  Platform_Type__c, Offering_Details__c FROM GCR__c 
                        WHERE Status__c != '11-Completed' AND Status__c != '10-Completed' AND Status__c !=: GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_GENESYS
                        AND OwnerId =:UserInfo.getUserId() ORDER BY createddate desc Limit 50];
            }
            else if(selectedView == 'Closed'){
                gcrs = [SELECT Name, Priority__c,Attorney_Name__c,Contract_Due_Date__c,Account__c,Owner.name,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c,Requestor_Name__c, Synopsis__c, Description__c, Request_Type__c,
                        Subscription_Sub_Type__c, CreatedDate, Status__c, Assigned_to_Attorney__c,New_Action__c,Partner_Contract_Type_Other__c, Offering_Type__c,  Platform_Type__c, Offering_Details__c FROM GCR__c 
                        WHERE (Status__c = '11-Completed' OR Status__c = '10-Completed' OR Status__c =: GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_GENESYS)
                        AND OwnerId =:UserInfo.getUserId() ORDER BY createddate desc limit 50];
            }
        }
        else{
            
            if(isAdmin == true && allRequests == false){
                System.debug('****allRequests With admin and all request false'+allRequests);
                if(selectedView == 'All'){
                    gcrs = [SELECT Name, Priority__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c,Contract_Due_Date__c,Account__c,Attorney_Name__c, Synopsis__c,Owner.name,Requestor_Name__c, Description__c, Request_Type__c,
                            Subscription_Sub_Type__c, CreatedDate, Status__c, Assigned_to_Attorney__c,New_Action__c,Partner_Contract_Type_Other__c, Offering_Type__c,  Platform_Type__c, Offering_Details__c FROM GCR__c 
                            WHERE Status__c != '11-Completed' AND Status__c != '10-Completed' AND Status__c !=: GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_GENESYS
                            //where Assigned_to_Attorney__c =: UserInfo.getUserId() 
                            ORDER BY createddate desc limit 50];
                }
                else if(selectedView == 'AssignedToMe'){
                    gcrs = [SELECT Name, Priority__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c,Contract_Due_Date__c,Account__c,Attorney_Name__c, Synopsis__c,Owner.name,Requestor_Name__c, Description__c, Request_Type__c,
                            Subscription_Sub_Type__c, CreatedDate, Status__c, Assigned_to_Attorney__c,New_Action__c,Partner_Contract_Type_Other__c, Offering_Type__c,  Platform_Type__c, Offering_Details__c FROM GCR__c 
                            WHERE Attorney_Name__c =: UserInfo.getName() AND Status__c != '11-Completed' AND Status__c != '10-Completed' 
                            AND Status__c !=: GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_GENESYS
                            ORDER BY createddate desc];
                    
                }else if(selectedView == 'compYear'){
                    gcrs = [SELECT Name, Priority__c,Attorney_Name__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c,Contract_Due_Date__c,Account__c, Synopsis__c,Owner.name,Requestor_Name__c, Description__c, Request_Type__c,
                            Subscription_Sub_Type__c, CreatedDate, Status__c, Assigned_to_Attorney__c,New_Action__c,Partner_Contract_Type_Other__c, Offering_Type__c,  Platform_Type__c, Offering_Details__c FROM GCR__c WHERE CreatedDate = THIS_YEAR 
                            AND Status__c != '11-Completed' AND Status__c != '10-Completed' AND Status__c !=: GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_GENESYS
                            //AND Assigned_to_Attorney__c =: UserInfo.getUserId()
                            ORDER BY createddate desc];
                }else if(selectedView == 'compMonth'){
                    gcrs = [SELECT Name, Priority__c,Attorney_Name__c,Contract_Due_Date__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c,Account__c, Synopsis__c,Owner.name,Requestor_Name__c, Description__c, Request_Type__c,
                            Subscription_Sub_Type__c, CreatedDate, Status__c, Assigned_to_Attorney__c, New_Action__c,Partner_Contract_Type_Other__c, Offering_Type__c,  Platform_Type__c, Offering_Details__c FROM GCR__c WHERE CreatedDate = THIS_Month 
                            AND Status__c != '11-Completed' AND Status__c != '10-Completed' AND Status__c !=: GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_GENESYS
                            //AND Assigned_to_Attorney__c =: UserInfo.getUserId()
                            ORDER BY createddate desc];
                    
                }
                /*
                * Commented By Ashish [Repeated code, will never execute]
                * Defined same scenario at line # 365
                else if(selectedView == 'AssignedToMe'){
                    gcrs = [SELECT Name, Priority__c,Attorney_Name__c,Contract_Due_Date__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c,Account__c, Synopsis__c,Owner.name,Requestor_Name__c, Description__c, Request_Type__c,
                            Subscription_Sub_Type__c, CreatedDate, Status__c, Assigned_to_Attorney__c, New_Action__c,Partner_Contract_Type_Other__c, Offering_Type__c,  Platform_Type__c, Offering_Details__c FROM GCR__c WHERE CreatedDate = THIS_Month 
                            AND Status__c != '11-Completed' AND Status__c != '10-Completed' AND Attorney_Name__c =: UserInfo.getName()
                            AND Status__c !=: GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_GENESYS
                            ORDER BY createddate desc];
                    
                }*/
                else{
                    gcrs = [SELECT Name, Priority__c,Attorney_Name__c,Contract_Due_Date__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c,Account__c,Owner.name,Requestor_Name__c, Synopsis__c, Description__c, Request_Type__c,
                            Subscription_Sub_Type__c, CreatedDate, Status__c, Assigned_to_Attorney__c,New_Action__c,Partner_Contract_Type_Other__c, Offering_Type__c,  Platform_Type__c, Offering_Details__c FROM GCR__c 
                            WHERE Status__c =: selectedView 
                            //AND Assigned_to_Attorney__c =: UserInfo.getUserId() 
                            ORDER BY createddate desc];
                }
            }
            else{
                if(selectedView == 'All'){
                    gcrs = [SELECT Name, Priority__c,Contract_Due_Date__c,Account__c,Attorney_Name__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c, Synopsis__c,Owner.name,Requestor_Name__c, Description__c, Request_Type__c,
                            Subscription_Sub_Type__c, CreatedDate, Status__c, Assigned_to_Attorney__c,New_Action__c,Partner_Contract_Type_Other__c, Offering_Type__c,  Platform_Type__c, Offering_Details__c FROM GCR__c 
                            WHERE Status__c != '11-Completed' AND Status__c != '10-Completed' AND Status__c !=: GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_GENESYS
                            ORDER BY createddate desc limit 50];
                }
                else if(selectedView == 'AssignedToMe'){
                    gcrs = [SELECT Name, Priority__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c,Contract_Due_Date__c,Account__c,Attorney_Name__c, Synopsis__c,Owner.name,Requestor_Name__c, Description__c, Request_Type__c,
                            Subscription_Sub_Type__c, CreatedDate, Status__c, Assigned_to_Attorney__c,New_Action__c,Partner_Contract_Type_Other__c FROM GCR__c                            
                            WHERE Attorney_Name__c =: UserInfo.getName() AND Status__c != '11-Completed' AND Status__c != '10-Completed' 
                            AND Status__c !=: GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_GENESYS
                            ORDER BY createddate desc];
                    
                }
                else if(selectedView == 'compYear'){
                    gcrs = [SELECT Name, Priority__c,Attorney_Name__c,Contract_Due_Date__c,Account__c, Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c,Synopsis__c,Owner.name,Requestor_Name__c, Description__c, Request_Type__c,
                            Subscription_Sub_Type__c, CreatedDate, Status__c, Assigned_to_Attorney__c,New_Action__c,Partner_Contract_Type_Other__c, Offering_Type__c,  Platform_Type__c, Offering_Details__c FROM GCR__c WHERE CreatedDate = THIS_YEAR
                            AND Status__c != '11-Completed' AND Status__c != '10-Completed'  AND Status__c !=: GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_GENESYS
                            ORDER BY createddate desc];
                }else if(selectedView == 'compMonth'){
                    gcrs = [SELECT Name, Priority__c,Attorney_Name__c,Contract_Due_Date__c,Account__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c, Synopsis__c,Owner.name,Requestor_Name__c, Description__c, Request_Type__c,
                            Subscription_Sub_Type__c, CreatedDate, Status__c, Assigned_to_Attorney__c,New_Action__c,Partner_Contract_Type_Other__c, Offering_Type__c,  Platform_Type__c, Offering_Details__c FROM GCR__c WHERE CreatedDate = THIS_Month
                            AND Status__c != '11-Completed' AND Status__c != '10-Completed' AND Status__c !=: GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_GENESYS
                            ORDER BY createddate desc];
                    
                }
                /*
                * Commented By Ashish [Repeated code, will never execute]
                * Defined same scenario at line # 407
                else if(selectedView == 'AssignedToMe'){
                    gcrs = [SELECT Name, Priority__c,Attorney_Name__c,Contract_Due_Date__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c,Account__c, Synopsis__c,Owner.name,Requestor_Name__c, Description__c, Request_Type__c,
                            Subscription_Sub_Type__c, CreatedDate, Status__c, Assigned_to_Attorney__c, New_Action__c,Partner_Contract_Type_Other__c, Offering_Type__c,  Platform_Type__c, Offering_Details__c FROM GCR__c WHERE CreatedDate = THIS_Month 
                            AND Attorney_Name__c =: UserInfo.getName() AND Status__c != '11-Completed' AND Status__c != '10-Completed'
                            AND Status__c !=: GCRContentDocumentDetailsContHelper.GCR_STATUS_SIGNED_BY_GENESYS
                            ORDER BY createddate desc];
                    
                }*/
                else{
                    gcrs = [SELECT Name, Priority__c,Attorney_Name__c,Contract_Due_Date__c,Account__c,Owner.name,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c,Requestor_Name__c, Synopsis__c, Description__c, Request_Type__c,Subscription_Sub_Type__c,
                            CreatedDate, Status__c, Assigned_to_Attorney__c,New_Action__c,Partner_Contract_Type_Other__c, Offering_Type__c,  Platform_Type__c, Offering_Details__c FROM GCR__c                            
                            WHERE Status__c =: selectedView ORDER BY createddate desc limit 50];
                }
            }
            
        }
        
        if(gcrs.size() == 0){
            showResult = false;
        }
        else{
            showResult = true;
        }
        setRecords = new ApexPages.StandardSetController(gcrs);
        getSObjectRecords();
    }
    
    public PageReference dummyMethod() {  
        system.debug('----- val = ' + record.Request_Type__c); 
        system.debug('----- val 2= ' + reqType); 
        //reqType = record.Request_Type__c ;  
        record.Request_Type__c = reqType ;
        return null;
    }
    
    
    public void moveToContracts(){      
        List<Attachment> attachments = [SELECT id, Name, Description,  Body FROM Attachment WHERE ParentId =: record.id];
        List<Attachment> attachmentsToBeInserted = new List<Attachment>();
        for(Attachment eachAtt : attachments){
            //if(a.id == record.Contract_File_Id__c){
            Attachment newAtt = new Attachment();
            newAtt.Name = eachAtt.Name;
            newAtt.Description = eachAtt.Description;
            newAtt.Body = eachAtt.Body;                     
            attachmentsToBeInserted.add(newAtt);
            //}
        }
        if(attachmentsToBeInserted.isEmpty())
            return;
        
        List<GCR_Content_Document_Detail__c> documentsToBeDeleted = [SELECT id FROM GCR_Content_Document_Detail__c WHERE Document_Name__c =: record.Name];
        List<GCR_Content_Document_Folder__c> foldersToBeDeleted = [SELECT id FROM GCR_Content_Document_Folder__c WHERE Name =: record.Name];
        if(!documentsToBeDeleted.isEmpty())
            delete documentsToBeDeleted;
        if(!foldersToBeDeleted.isEmpty())
            delete foldersToBeDeleted;
        
        GCR_Content_Document_Folder__c newFolder = new GCR_Content_Document_Folder__c();
        newFolder.Name = record.Name;
        newFolder.Account__c = record.Account__c;
        newFolder.GCR__c = record.id;
        newFolder.Active__c = true;
        insert newFolder;
        
        GCR_Content_Document_Detail__c newDocument = new GCR_Content_Document_Detail__c();
        newDocument.Folder__c = newFolder.id;
        newDocument.Account_Name__c = record.Account__c;
        newDocument.GCR__c = record.id;
        newDocument.Document_Name__c = record.Name;
        newDocument.Active__c = true;
        insert newDocument;
        
        for(Attachment eachAtt : attachmentsToBeInserted){
            eachAtt.ParentId = newDocument.id;
        }
        
        insert attachmentsToBeInserted;
        
    }
    
    public PageReference submitGCR(){
        if(!isAdmin){
            record.Requestor_Name__c = UserInfo.getUserId();
            if(record.Offering_Type__c == null){
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Offering Type.'));
                return null;
            }
        }
        if(record.Request_Type__c != 'Partner' && (record.Contract_Type__c == 'New Contract' || record.Contract_Type__c == 'Amendment') && record.Subscription_Sub_Type__c != 'New Org & Subscription' && record.Subscription_Sub_Type__c != '' && (record.Offering_Type__c == 'PureCloud' || record.Offering_Type__c == 'PureConnect' || record.Offering_Type__c == 'PureEngage') && record.CCDB_Subscription__c == null && Schema.sObjectType.GCR__c.fields.Subscription_Sub_Type__c.isUpdateable()){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Subscription.'));
            return null;
        }
        record.Status__c = GCRContentDocumentDetailsContHelper.GCR_STATUS_NEW;
        upsert record;
        //Creating new shell contract
        if(record.Contract_Type__c == 'New Contract'){
            GCR_Content_Document_Detail__c newContract = new GCR_Content_Document_Detail__c(GCR__c = record.id);    
            newContract.Document_Name__c = 'Contract';
            newContract.Account_Name__c = record.Account__c;
            newContract.Status__c = 'Draft';
            newContract.Active__c = true;
            newContract.Opportunity__c = record.Opportunity__c;
            List<GCR_Content_Document_Folder__c> folder = [SELECT id FROM GCR_Content_Document_Folder__c WHERE Active__c = true 
                                                           AND Name = 'Master Agreement'];
            if(!folder.isEmpty())
                newContract.Folder__c = folder[0].id;                
            insert newContract;
        }
        
        PageReference pRef = new PageReference('/apex/GCRequest?id=' + record.id);
        pRef.setRedirect(true);
        return pRef;
    }
    
    public PageReference insertDCR(){        
        if(record.id==null){
            record.Status__c = GCRContentDocumentDetailsContHelper.GCR_STATUS_INITIAL;
            if(record.Account__c != null){
                Account gcrAccount = [SELECT Country__r.Region__c FROM Account WHERE id =: record.Account__c];
                String legalGroupEmail = GCR_Approvers_Queues__c.getAll().get(gcrAccount.Country__r.Region__c).Legal_Group_Email__c;
                record.Legal_Group_Email__c = legalGroupEmail;
            }
        }
        if(!isAdmin){
            record.Requestor_Name__c = UserInfo.getUserId();
        }
        
        if(record.Partner_Contract_Type__c != null && !record.Partner_Contract_Type__c.contains('Other') && record.Partner_Contract_Type_Other__c != null) {
            record.Partner_Contract_Type_Other__c = '';    
        }
        //Navaneetha added for Pure engage cloud 20-Sep-2019 line 567 || record.Offering_Type__c == 'PureEngage'
        if(record.Request_Type__c != 'Partner' && (record.Contract_Type__c == 'New Contract' || record.Contract_Type__c == 'Amendment') && record.Subscription_Sub_Type__c != 'New Org & Subscription' && record.Subscription_Sub_Type__c != '' && (record.Offering_Type__c == 'PureCloud' || record.Offering_Type__c == 'PureConnect'|| record.Offering_Type__c == 'PureEngage') && record.CCDB_Subscription__c == null  && Schema.sObjectType.GCR__c.fields.Subscription_Sub_Type__c.isUpdateable() ){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Please select Subscription.'));
            System.debug(Schema.sObjectType.GCR__c.fields.Subscription_Sub_Type__c.isUpdateable());
            return null;
        }        
        try{          
            updateMSLink(record);// Priyank added.          
            upsert record;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,e.getMessage().substringBetween(',',':')));
            return null;
        }
        selectedRecordId = record.id;        
        loadRecords();
        retrieveRecord2();
        return null;
    }
    
    
    // Added by Priyank as discussed with JJ.
    private void updateMSLink(GCR__c record){
        if(record.Status__c == '10-Completed'){
            GCR__c gcr = [SELECT Id, Opportunity__c, (SELECT Id, Legal_Exceptions__c FROM GCR_Details__r WHERE IsGoverningContract__c = true AND Legal_Exceptions__c != 'None') FROM GCR__c WHERE Id =: record.id LIMIT 1];
            GCR__c gcr2 = [SELECT Id, Opportunity__c, (SELECT Id, Legal_Exceptions__c FROM GCR_Details__r WHERE IsGoverningContract__c = true AND Legal_Exceptions__c = 'None') FROM GCR__c WHERE Id =: record.id LIMIT 1];
            if(gcr.GCR_Details__r.size() > 0 && gcr2.GCR_Details__r.size() == 0){
                boolean isLegalExcExist = false;
                for(GCR_Content_Document_Detail__c contrct : gcr.GCR_Details__r){
                    if(contrct.Legal_Exceptions__c != null && contrct.Legal_Exceptions__c.length() > 0){
                        isLegalExcExist = true;
                        break;
                    }
                }
                if(isLegalExcExist){
                    List<BigMachines__Quote__c> list_QuoteToUpdate = new List<BigMachines__Quote__c>();
                    for(BigMachines__Quote__c quoteObj : [SELECT Id, MSA_Link__c , MSA_Link_Type__c FROM BigMachines__Quote__c WHERE BigMachines__Is_Primary__c = true AND BigMachines__Opportunity__c =: gcr.Opportunity__c]){
                        if(quoteObj.MSA_Link_Type__c != 'Custom'){
                            quoteObj.MSA_Link_Type__c = 'Custom';
                            quoteObj.MSA_Link__c = '';
                            list_QuoteToUpdate.add(quoteObj);
                        }
                    }
                    if(list_QuoteToUpdate.size() > 0){
                        update list_QuoteToUpdate;
                    }
                }
            }
        }
        
    }
    // Priyank code end.
    
    
    public PageReference insertAttachment() { 
        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = record.id;
        
        PageReference pr = new Pagereference('/apex/RecordCreationSuccess');
        
        try {
            upsert attachment;
        } catch (DMLException e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading attachment'));          
        }
        //System.debug('*******record'+record+'****'+record);
        //selectedRecordId = record.id;
        attachment = new Attachment();
        
        retrieveRecord2();
        
        return null;
    }
    public PageReference delAtt(){
        Attachment attToDelete = new Attachment(id=attIdToDelete);
        delete attToDelete;
        retrieveRecord2();
        
        return null;
    }
    
    private void populateRecipients(){
        recipient = record.Owner.Email;
        mailTo = record.Owner.Name;
        if(!isAdmin){
            if(record.Assigned_to_Attorney__c != null){
                recipient = record.Assigned_to_Attorney__r.Email;
                mailTo = record.Assigned_to_Attorney__r.Name;
            }   
            else if(record.Account__c != null && GCR_Approvers_Queues__c.getAll().get(record.Account__r.Country__r.Region__c) != null){                             
                String legalGroupEmail = GCR_Approvers_Queues__c.getAll().get(record.Account__r.Country__r.Region__c).Legal_Group_Email__c;
                recipient = legalGroupEmail;
                mailTo = legalGroupEmail;
            }
        }
        else{
            recipient = record.CreatedBy.Email;
            mailTo = record.CreatedBy.Name;
        }
    }
    public PageReference send() {
        // Define the email
        if(record.id!=null){            
            System.debug('NKC debug recipient ['+recipient+']');
            String subject = subject + ' ' + record.name;
            SendEmail.sendSingleEmail(recipient, subject, body, Label.GCR_Email_Reply_To, cc, null, emailAttachment, Label.GCR_Email_Reply_To); 
            //
            emailAttachment = new Attachment();
            subject = '';
            
            Note newNote = new Note();
            newNote.title = 'Email Comment';
            String newBody = body;
            newBody += '\n';
            newBody += 'From ' +UserInfo.getUserEmail()+ ' To ' + record.owner.email;
            newNote.body = newBody;
            newNote.parentId = record.id;
            insert newNote;
            retrieveRecord2();
        }  
        
        return null;
    }
    public Pagereference retrieveRecord(){
        record = [select id,name, Partner_Application__c, ownerId, owner.Name, owner.Email ,Request_Type__c,Contract_Due_Date__c,Contract_Type__c,Priority__c,Status__c,Contract_File_Id__c,
                  Account__c, Account__r.id,Deal_Size__c,Attorney_Name__c,Opportunity__c,Subscription_Sub_Type__c,CCDB_Subscription__c,
                  Order_No__c,Link_To_Quote__c, Account__r.Country__r.Region__c, Platform_Type__c, Offering_Details__c,
                  PR_Number__c,PO_Amount__c,Synopsis__c,Description__c, Offering_Type__c,Is_this_DSR_for_a_Ramp_Extension__c,Ramp_Extension_Reason__c,
                  CreatedBy.name,CreatedDate,createdbyId,Assigned_to_Attorney__r.Email,Assigned_to_Attorney__r.Name, 
                  Contact_Name__c,Contact__c,Contact_Phone__c,Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c, Partner_Contract_Type__c,
                  lastmodifiedbyid,lastmodifieddate,LastModifiedBy.name,Assigned_to_Attorney__c,CreatedBy.Email, License_Amount__c, Total_Contract_Value__c,
                  Region__c,Requestor_Name__c,Requestor_Name__r.email,GCR_Content_Document_Detail__c, New_Action__c,Partner_Contract_Type_Other__c,
                  (select id,name,description from Attachments),
                  (select id,body,title,createddate from Notes Order by createddate Desc),                    
                  (select id,ActorId,Actor.name,Comments,ElapsedTimeInDays,ElapsedTimeInHours,ElapsedTimeInMinutes,OriginalActorId,OriginalActor.name,ProcessInstanceId,RemindersSent,StepStatus,createddate from ProcessSteps order by createddate desc,StepStatus)
                  from GCR__c 
                  where id =: selectedRecordId limit 1];
        //apexpages.currentpage().getparameters().put('gcrid',selectedRecordId);
        //retrieveApprovalRecord();
        
        attachment = new Attachment();            
        ActiveTab = 'gcrDetails';
        System.debug('*****record'+record);
        if(documentRecordId != null){
            ActiveTab = 'Metadata';
        }
        attWrapperlist = new List<AttachmentWrapper>();
        if(record.Attachments !=null && record.Attachments.size()>0){
            for(Attachment a : record.Attachments){
                Boolean contratctFile = false;
                System.debug('*******'+a.id+'******'+record.Contract_File_Id__c);
                if(a.id == record.Contract_File_Id__c){
                    contratctFile = true;
                }
                AttachmentWrapper aw = new AttachmentWrapper(a,contratctFile);
                attWrapperlist.add(aw);
            }
        }
        
        strDateTime =null;
        strCountry = null;
        strRequestor =null;
        strEmail =null;
        
        System.Debug('Record Id:'+record.Requestor_Name__c);
        if(record.Requestor_Name__c !=null){
            strRequestor = record.Requestor_Name__c;
        }
        System.Debug('Record Id:'+strRequestor);
        
        queryRequestorInfo();
        strDateTime = record.CreatedDate;
        
        if(record.Account__c!=null){
            strAccountLegal = record.Account__c;
        }
        
        
        if(record.Contact__c!=null){
            strContact = record.Contact__c;
        }
        setContactDetails();
        return null;
    }
    
    public Pagereference retrieveRecord2(){
        record = [select id,name,Partner_Application__c,GCR_Content_Document_Detail__c,ownerId, Owner.Name, Owner.Email,Request_Type__c,Contract_Due_Date__c,Contract_Type__c,Priority__c,Status__c,Contract_File_Id__c,
                  Account__c,Deal_Size__c,Attorney_Name__c,Subscription_Sub_Type__c,CCDB_Subscription__c,
                  Order_No__c,Link_To_Quote__c,Opportunity__c,Is_this_DSR_for_a_Ramp_Extension__c,Ramp_Extension_Reason__c,
                  Field_1__c,Field_2__c,Field_3__c,Field_4__c,Field_5__c,Field_6__c,
                  PR_Number__c,PO_Amount__c,Synopsis__c,Description__c, Offering_Type__c,
                  CreatedBy.name,CreatedDate,createdbyId, Account__r.Country__r.Region__c,
                  Contact_Name__c,Contact__c,Contact_Phone__c,Assigned_to_Attorney__r.Email,CreatedBy.Email, Assigned_to_Attorney__r.Name, Partner_Contract_Type__c,
                  lastmodifiedbyid,lastmodifieddate,LastModifiedBy.name,Assigned_to_Attorney__c,  License_Amount__c, Total_Contract_Value__c,
                  Region__c,Requestor_Name__c,Requestor_Name__r.email, New_Action__c,Partner_Contract_Type_Other__c, Platform_Type__c, Offering_Details__c,
                  (select id,name,description from Attachments),
                  (select id,body,title,createdDate from Notes Order by createddate Desc)
                  ,(select id,ActorId,Actor.name,Comments,ElapsedTimeInDays,ElapsedTimeInHours,ElapsedTimeInMinutes,OriginalActorId,OriginalActor.name,ProcessInstanceId,RemindersSent,StepStatus,createddate from ProcessSteps order by createddate desc,StepStatus)
                  from GCR__c 
                  where id =: selectedRecordId limit 1];
        
        //retrieveApprovalRecord();
        
        attachment = new Attachment();
        System.debug('*****record'+record);
        
        attWrapperlist = new List<AttachmentWrapper>();
        if(record.Attachments !=null && record.Attachments.size()>0){
            for(Attachment a : record.Attachments){
                Boolean contratctFile = false;
                System.debug('*******'+a.id+'******'+record.Contract_File_Id__c);
                if(a.id == record.Contract_File_Id__c){
                    contratctFile = true;
                }
                AttachmentWrapper aw = new AttachmentWrapper(a,contratctFile);
                attWrapperlist.add(aw);
            }
        }
        return null;
    }
    
    public PageReference cancel(){
        //PageReference pg = new PageReference('/home/home.jsp');
        showTabs = false;
        ActiveTab = 'gcrHome';
        selectedRecordId = null;
        return null;
        
    }
    public PageReference createNew(){       
        showTabs = true;
        record = new GCR__c();
        if(!isAdmin){
            record.Request_Type__c = 'Sales';
            if(ApexPages.CurrentPage().getParameters().get('accid') != null){
                record.Account__c = ApexPages.CurrentPage().getParameters().get('accid');
            }
        }
        attachment = new Attachment();
        attachmentList = new List<Attachment>();
        reqType = '';
        ActiveTab = 'gcrDetails';
        selectedRecordId = null;
        //queryRequestorInfo();
        if(ApexPages.CurrentPage().getParameters().get('id') == null && ApexPages.CurrentPage().getParameters().get('crt') == null){
            record.Status__c = null;
            insert record;
            PageReference pageRef = new pageReference('/apex/GCRequest?id='+ record.id);
            pageRef.setRedirect(true);
            return pageRef;        
        }
        else
            return null;
    }
    public PageReference saveList(){
        //System.debug('****SObjectRecords'+getSObjectRecords());
        List<GCR__c> gList = getSObjectRecords();
        update gList;
        return null;
    }
    
    public PageReference changeStatus(){
        System.debug('******isComplete'+isComplete);
        if(isComplete!=null && isComplete){
            record.status__c = '8-Metadata Complete';
            update record;
            retrieveRecord2();
            loadRecords();
        }
        return null;
    }
    public class AttorneyDetailWrapper{
        public String name{get;set;}
        public Integer Count{get;set;}
        public String status{get;set;}
        AttorneyDetailWrapper(String name,Integer Count,String status){
            this.name = name;
            this.count=count;
            this.status=status;
        }
    }
    public PageReference populateAttorneyDetails(){
        AggregateResult[] groupedResults = [SELECT Attorney_Name__c, COUNT(name),status__c FROM GCR__c GROUP BY Attorney_Name__c,status__c];
        System.debug('****'+groupedResults);
        attorneyDetailList = new List<AttorneyDetailWrapper>();
        if(groupedResults!=null && groupedResults.size()>0){
            for (AggregateResult ar : groupedResults)  {
                Integer countOfGCR = Integer.valueOf(ar.get('expr0'));
                String attorneyName = String.valueOf(ar.get('Attorney_Name__c'));
                if(attorneyName == null || attorneyName == ''){
                    attorneyName = '*Not Assigned*';
                }
                String status = String.valueOf(ar.get('status__c'));
                attorneyDetailList.add(new AttorneyDetailWrapper(attorneyName,countOfGCR,status));
            }
        }
        return null;
    }
    public PageReference submitForApproval(){
        // Create an approval request for the GCR
        if(record.Attorney_Name__c==null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'Please fill the Attorney Info before Submitting for Approval'));
            return null;
        }
        Approval.ProcessSubmitRequest approvalReq = new Approval.ProcessSubmitRequest();
        approvalReq.setComments('Submitting request for approval.');
        approvalReq.setObjectId(record.id);
        try{
            // Submit the approval request for the GCR
            Approval.ProcessResult result = Approval.process(approvalReq);
            
            loadRecords();
            retrieveRecord2();
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Your request has been submitted for approval'));
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error approval process '+e.getMessage()));          
        }
        return null;
    }
    /*
public void retrieveApprovalRecord(){
prosIns = new List<ProcessInstance>();
Set<String> prosInsIds = new Set<String>();

prosIns = [SELECT Id, Status, TargetObject.Id, TargetObject.Name, TargetObject.Type, CreatedDate FROM ProcessInstance where TargetObjectId =: record.id];     
for(ProcessInstance prIns: prosIns){
prosInsIds.add(prIns.Id);
}
prosInsWrkItms =  [SELECT Id, ProcessInstance.Id, ProcessInstance.Status, Actor.Id, Actor.Name, Actor.Type FROM ProcessInstanceWorkitem where ProcessInstance.Id in : prosInsIds];
} 
*/  
    public class AttachmentWrapper{
        public Attachment attac{get;set;}
        public Boolean isContract{get;set;}
        public AttachmentWrapper(Attachment att,Boolean isAttContract){
            attac = att;
            isContract = isAttContract;
        }
    }
    public void showNDA () {
        
        system.debug(ndaCon);
        try {
            if(ndaCon.equalsIgnoreCase('I Agree')) {
                
                record.Status__c = GCRContentDocumentDetailsContHelper.GCR_STATUS_COMPLETED;
                update record;
            }
        } catch (exception e ) {} 
    }
    public string radioSelectLabel {  
        get {  
            return '&nbsp;&nbsp;'+ 'I Agree' + '&nbsp;&nbsp;&nbsp;&nbsp;'; 
        }  
    }    
    public string radioSelectLabel1 {  
        get {  
            return '&nbsp;&nbsp;'+ 'I Disagree' + '&nbsp;&nbsp;'; 
        }  
    }
    public string radioSelectLabel2 {  
        get {  
            return '&nbsp;&nbsp;'+ 'Manual' + '&nbsp;&nbsp;&nbsp;&nbsp;'; 
        }  
    }    
    public string radioSelectLabel3 {  
        get {  
            return '&nbsp;&nbsp;'+ 'Digital' + '&nbsp;&nbsp;'; 
        }  
    }
    public void testM () {
        
        system.debug(ndaCon);
    }
    public void showNdaButton() {
        
        ndaShow = false;
        //showParterType = false;
        if(currentStatus != null && currentStatus.equalsIgnoreCase('Self-Service')) {
            
            ndaShow = true;
        }
        /*if(record.Contract_Type__c == 'New Contract') {
showParterType = true;      
} */  
        
    }
    public PageReference retrieveRecordTemp(){
        System.debug('****selectedRecordId'+selectedRecordId);
        PageReference pRef = Page.GCRequest;
        pRef.getparameters().put('id',selectedRecordId);
        pRef.setRedirect(true);
        return pRef;
    }
    
    public PageReference metadataClicked(){
        System.debug('****metadataClicked');
        PageReference pRef = Page.GCRContentDocumentDetails;
        pRef.getparameters().put('accId',record.Account__c);
        pRef.setRedirect(true);
        return pRef;
    }
    
    public PageReference selfServiceNDA(){      
        List<GCR_Content_Document_Detail__c> ndaDocument = [SELECT id FROM GCR_Content_Document_Detail__c 
                                                            WHERE Account_Name__c =: record.Account__c AND Folder__r.Name = 'One'   //: GCRContentDocumentDetailsContHelper.NDA_FOLDER_NAME 
                                                            ORDER BY CreatedDate DESC];
        
        String ndaDocumentId;
        if(ndaDocument.isEmpty()){
            List<GCR_Content_Document_Folder__c> folder = [SELECT id FROM GCR_Content_Document_Folder__c WHERE Name =: GCRContentDocumentDetailsContHelper.NDA_FOLDER_NAME];
            if(folder.isEmpty())
                return null;
            
            GCR_Content_Document_Detail__c newDocument = new GCR_Content_Document_Detail__c();
            newDocument.Account_Name__c = record.Account__c;
            newDocument.Folder__c = folder[0].id;
            newDocument.Document_Name__c = 'Document';
            newDocument.Visibility_Status__c = 'Visible';
            newDocument.Active__c = true;
            newDocument.GCR__c=record.id;
            insert newDocument;
            ndaDocumentId = newDocument.id;
            
        }
        else
            ndaDocumentId = ndaDocument[0].id;
        String retURL = '/apex/GCRequest%3Fid=' + record.id;
        PageReference pRef = new PageReference('/apex/loop__looplus?sessionId=' + UserInfo.getSessionId() + '&eid=' + ndaDocumentId + '&retURL=' + retURL + '&filtertype=doesnotcontain&filter=Contract');
        pRef.setRedirect(true);
        return pRef;
        
    }
    
}