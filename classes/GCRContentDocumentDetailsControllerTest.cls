@isTest(seeAllData = true)
private class GCRContentDocumentDetailsControllerTest {
    public static String gcrId;
    public static String documentId;
    public static String accountId;
    public static String folderId;
    public static String attachmentId;
    public static String docusignStatusId;
    
    static void insertTestData(){
        Country__c testCountry = [SELECT Id, Name, Country__c, Region__c FROM Country__c WHERE Name = 'United States'];
        /*testCountry.Name = 'Test Country';
        testCountry.Country__c = 'Test Country';
        testCountry.Region__c = 'APAC';
        insert testCountry;*/
        
        Account acct = new Account();
        acct.Name = 'Test Account';
        acct.Country__c = testCountry.id;
        insert acct;
      
        Opportunity opp = new Opportunity();
        opp.AccountId = acct.Id;
        opp.Name = 'Test Opportunity';
        acct.Country__c = testCountry.id;
        opp.StageName = 'Prospect';
        opp.CloseDate = Date.Today();        
        insert opp;
             
        Contact con = new Contact();
        con.AccountId = acct.Id;
        con.LastName = 'Test Contact';
        con.Email = 'test@test.com';        
        insert con;
        
        String paID = [SELECT Partner_Application__c FROM Partner_Application_Category_and_Country__c WHERE Country__r.Name = 'United States' LIMIT 1][0].Partner_Application__c;
        
        List<GCR__c> gcrList = new List<GCR__c>();   
        
        GCR__c gcr = new GCR__c();
        gcr.Contact__c = con.id;
        gcr.Account__c = acct.Id;
        gcr.Region__c = acct.Country__r.Region__c;
        gcr.Request_Type__c = 'Sales';
        gcr.Contact_Name__c = con.Name;
        gcr.Contact_Phone__c = con.ContactPhone__c;
        gcr.Requestor_Name__c = UserInfo.getUserId();
        gcr.Attorney_Name__c = UserInfo.getUserId();
        gcr.Opportunity__c = opp.Id;
        gcr.Subscription_Sub_Type__c = 'Amend Existing Subscription';
        gcr.Partner_Application__c = paID;
        gcrList.add(gcr);
        insert gcrList;
        
        GCR_Content_Document_Detail__c document = new GCR_Content_Document_Detail__c();        
        document.Account_Name__c = acct.Id;
        document.GCR__c = gcrList[0].id;       
        document.Active__c = true;
        insert document;
        
        GCR_Content_Document_Folder__c folder = new GCR_Content_Document_Folder__c();
        folder.Active__c = true;
        folder.Account__c = acct.id;
        folder.Name = 'Test Folder';
        folder.GCR__c = gcrList[0].id;
        insert folder;
        
        dsfs__DocuSign_Status__c docStatus = new dsfs__DocuSign_Status__c();
        docStatus.GCR_Content_Document__c = document.id;
        insert docStatus;
        
        Attachment attach=new Attachment();     
        attach.Name = 'Unit Test Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = docStatus.id;
        insert attach;
        
        folderId = folder.id;
        gcrId = gcrList[0].id;
        documentId = document.id;       
        accountId = acct.id;
        attachmentId = attach.id;
        docusignStatusId = docStatus.id;
    }
    static testMethod void myUnitTest1() {  
        insertTestData();   
        ApexPages.currentPage().getParameters().put('id', gcrId);
        String documentRecordId = ApexPages.currentPage().getParameters().put('documentRecordId', documentId);
        
        GCRContentDocumentDetailsController objPg = new GCRContentDocumentDetailsController(new ApexPages.StandardController(new GCR_Content_Document_Detail__c()));
    }
    static testMethod void myUnitTest2() {  
        insertTestData(); 
        
        ApexPages.currentPage().getParameters().put('id', gcrId);
        ApexPages.currentPage().getParameters().put('gcrId', gcrId);
        ApexPages.currentPage().getParameters().put('hideHeader','true');
        ApexPages.currentPage().getParameters().put('embedded', 'true');
        ApexPages.currentPage().getParameters().put('showAll', 'true');
        ApexPages.currentPage().getParameters().put('addNewDocument', 'true');
        ApexPages.currentPage().getParameters().put('accId', accountId);        
        ApexPages.currentPage().getParameters().put('folderId', folderId);
        ApexPages.currentPage().getParameters().put('addNewFolder', 'true');
        
        String documentRecordId = ApexPages.currentPage().getParameters().put('documentRecordId', documentId);
        GCRContentDocumentDetailsController objPg = new GCRContentDocumentDetailsController(new ApexPages.StandardController(new GCR_Content_Document_Detail__c()));
        objPg.addNewDocument();        
        objPg.refresh();
        objPg.edit();
        objPg.setAccountId();
        objPg.resetAccount();
        objPg.currentRecord.Effective_Date__c = System.today();
        objPg.currentRecord.Expiration_Renewal_Date__c = System.today().addDays(7);
        objPg.currentRecord.Legal_Exceptions__c = 'None;Background Checks';
        objPg.save();
        objPg.currentRecord.Legal_Exceptions__c = 'Background Checks';
        objPg.save();
        objPg.showAll();
        objPg.saveFolder();
        objPg.editFolder();
        objPg.cancel();
        objPg.sendToFinanceDirectly();
        objPg.sendToFinanceViaDocusign();
        objPg.approve();
        objPg.getDocusignRecpDisplay();
        objPg.attachmentIdToBeDeleted = attachmentId;
        objPg.delAttachment();
        objPg.deleteFolder();  
    }
    
    static testMethod void myUnitTest3() {  
        insertTestData();   
        ApexPages.currentPage().getParameters().put('id', gcrId);
        ApexPages.currentPage().getParameters().put('gcrId', gcrId);
        ApexPages.currentPage().getParameters().put('hideHeader','true');
        ApexPages.currentPage().getParameters().put('embedded', 'true');
        ApexPages.currentPage().getParameters().put('showAll', 'true');
        ApexPages.currentPage().getParameters().put('addNewDocument', 'true');
        ApexPages.currentPage().getParameters().put('accId', accountId);        
        ApexPages.currentPage().getParameters().put('folderId', folderId);
        ApexPages.currentPage().getParameters().put('addNewFolder', 'true');
        
        GCR_Content_Document_Folder__c folder = new GCR_Content_Document_Folder__c();
        folder.Active__c = true;
        folder.Account__c = accountId;
        folder.Name = 'Test Folder 1';
        folder.GCR__c = gcrId;
        folder.Parent_Folder__c = folderId;
        insert folder;
        
        GCR_Content_Document_Detail__c document = new GCR_Content_Document_Detail__c();        
        document.Account_Name__c = accountId;
        document.Contract_Category__c = 'Amend';
        document.GCR__c = gcrId;       
        document.Active__c = true;
        document.Folder__c = folder.id;
        insert document;
        
        String documentRecordId = ApexPages.currentPage().getParameters().put('documentRecordId', documentId);
        GCRContentDocumentDetailsController objPg = new GCRContentDocumentDetailsController(new ApexPages.StandardController(new GCR_Content_Document_Detail__c()));
        objPg.addNewDocument();        
        objPg.refresh();
        objPg.edit();
        objPg.setAccountId();
        objPg.resetAccount();
        objPg.currentRecord.Legal_Exceptions__c = 'None';
        objPg.currentRecord.Effective_Date__c = System.today();
        objPg.save();
        objPg.currentRecord.Expiration_Renewal_Date__c = System.today().addDays(7);
        objPg.save();
        objPg.currentRecord.Contract_Category__c = 'Amend';
        objPg.save();
        objPg.showAll();
        objPg.saveFolder();
        objPg.editFolder();
        objPg.cancel();
        objPg.sendToFinanceDirectly();
        objPg.sendToFinanceViaDocusign();
        objPg.getDocusignRecpDisplay();
        objPg.getDocusignStatusRecordId();
        objPg.showFromCurrentGCR();
        objPg.attachmentIdToBeDeleted = attachmentId;
        objPg.delAttachment();
        objPg.deleteFolder();  
    }
    
    static testMethod void testDocuSignRecipientStatusTrigger(){
        insertTestData();
        dsfs__DocuSign_Recipient_Status__c newRecipientStatus = new dsfs__DocuSign_Recipient_Status__c();
        newRecipientStatus.dsfs__Recipient_Status__c = 'Test';  
        newRecipientStatus.dsfs__DocuSign_Recipient_Id__c = 'test'; 
        newRecipientStatus.dsfs__Parent_Status_Record__c = docusignStatusId;
        insert newRecipientStatus;
        newRecipientStatus.dsfs__Date_Signed__c = System.today();
        newRecipientStatus.dsfs__DocuSign_Recipient_Email__c = 'test@genesys.com';
        update newRecipientStatus;
        newRecipientStatus.dsfs__Date_Signed__c = System.today().addDays(1);
        newRecipientStatus.dsfs__DocuSign_Recipient_Email__c = 'test@test.com';         
        update newRecipientStatus;
        
    }   
    
    
    static testmethod void TestGCRequestController2(){
                   
        Account acct = new Account();
        acct.Name = 'Test Account';
        insert acct;

        Opportunity opp = new Opportunity();
        opp.AccountId = acct.Id;
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Prospect';
        opp.CloseDate = Date.Today();        
        insert opp;  
        
        Contact con = new Contact();
        con.AccountId = acct.Id;
        con.LastName = 'Test Contact';
        con.Email = 'standarduser@testorg.com';        
        insert con;
        
        GCR__c gcr = new GCR__c();
        gcr.Contact__c = con.id;
        gcr.Account__c = acct.Id;
        gcr.Region__c = acct.Country__r.Region__c;
        gcr.Request_Type__c = 'Sales';
        gcr.Contact_Name__c = con.Name;
        gcr.Contact_Phone__c = con.ContactPhone__c;
        gcr.Requestor_Name__c = UserInfo.getUserId();
        gcr.Attorney_Name__c = UserInfo.getUserId();
        gcr.Contract_Type__c = 'Amendment';
        gcr.Offering_Type__c = 'PureCloud';
        insert gcr;
        
        List<GCR_Content_Document_Folder__c> gcrFolderList = new List<GCR_Content_Document_Folder__c>();        
        GCR_Content_Document_Folder__c gcrFolder = new GCR_Content_Document_Folder__c();
        gcrFolder.Name = gcr.Name;
        gcrFolder.Account__c = gcr.Account__c;
        gcrFolder.GCR__c = gcr.id;
        gcrFolder.Active__c = true;
        gcrFolderList.add(gcrFolder);
        insert gcrFolderList;
        
             
        GCR_Content_Document_Detail__c  gcrDocDetail = new GCR_Content_Document_Detail__c();
        gcrDocDetail.Folder__c = gcrFolder.id;
        gcrDocDetail.Legal_Exceptions__c = 'Billing Period';
        gcrDocDetail.IsGoverningContract__c = true;
        gcrDocDetail.Contract_Category__c = 'Amend';
        gcrDocDetail.Expiration_Renewal_Date__c = System.today().addDays(5);
        gcrDocDetail.Contract_Type__c = 'Service Order';
        gcrDocDetail.Account_Name__c = gcr.Account__c;
        gcrDocDetail.GCR__c = gcr.id;
        gcrDocDetail.Document_Name__c = gcr.Name;
        gcrDocDetail.Active__c = true;        
        insert gcrDocDetail;
        
        Test.startTest();
        ApexPages.currentPage().getParameters().put('documentRecordId', gcrDocDetail.Id);
        ApexPages.currentPage().getParameters().put('gcrId', gcr.Id);
        GCRContentDocumentDetailsController objPg = new GCRContentDocumentDetailsController(new ApexPages.StandardController(gcrDocDetail));
        objPg.checkRequiredField();
        objPg.currentRecord.Contract_Type__c = 'PureCloud T&C';
        objPg.checkRequiredField();
        objPg.currentRecord.Is_Governing_Contract__c = true;
        objPg.checkRequiredField();
        objPg.enableGoveringFields();
        objPg.currentRecord.Contract_Category__c = 'New';
        objPg.currentRecord.Contract_Type__c = 'Service Order';
        objPg.checkRequiredField();
        objPg.checkGoverningType();
        objPg.currentRecord.Contract_Category__c = 'New';
        objPg.currentRecord.Contract_Type__c = 'PureCloud T&C';
        objPg.checkRequiredField();
        objPg.checkGoverningType();
        objPg.currentRecord.Is_Governing_Contract__c = false;
        objPg.enableGoveringFields();
        objPg.deleteDocument();
        objPg.pageMode = 'edit';
        objPg.intializeCountryList();
        Test.stopTest();
    }
}