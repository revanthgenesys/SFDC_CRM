@isTest
private class GCRequestControllerTest{
    
    static testmethod void TestGCRequestController(){
        Test.startTest();
        List<Config__c> conList = new List<Config__c>();
    
        Config__c config = new Config__c();
        config.Name = 'CORE_OPP_STAGE_CLOSED_WON ';
        config.Value__c = 'User Contract';
        conList.add(config);
        
        Config__c config1 = new Config__c();
        config1.Name = 'USER_PARTNER';
        config1.Value__c = 'PowerPartner';
        conList.add(config1);
        
        Config__c config2 = new Config__c();
        config2.Name = 'USER_STANDARD';
        conList.add(config2);
        
        Config__c config3 = new Config__c();
        config3.Name = 'CORE_OPP_BP_STATUS_ALLOCATED';
        conList.add(config3);
        
        Config__c config4 = new Config__c();
        config4.Name = 'ALE_TEAM_MEMBER_ROLE ';
        conList.add(config4);
        
        Config__c config5 = new Config__c();
        config5.Name = 'CORE_OPP_BP_STATUS_REJECTED';
        conList.add(config5);
        
        Config__c config6 = new Config__c();
        config6.Name = 'CORE_OPP_BP_STATUS_NOT_ALLOCATED';
        conList.add(config6);
        
        Config__c config7 = new Config__c();
        config7.Name = 'CORE_OPP_BP_STATUS_APPROVED';
        conList.add(config7);
        
        Config__c config8 = new Config__c();
        config8.Name = 'BP_TEAM_MEMBER_ROLE';
        conList.add(config8);
        
        Config__c config9 = new Config__c();
        config9.Name = 'TM_MONITOR_AD_EMAIL1';
        conList.add(config9);
        
        Config__c config10 = new Config__c();
        config10.Name = 'TM_MONITOR_AD_EMAIL2';
        conList.add(config10);
        
        Config__c config11 = new Config__c();
        config11.Name = 'TM_MONITOR_AD_EMAIL3';
        conList.add(config11);
        
        Config__c config12 = new Config__c();
        config12.Name = 'TM_VALUE_SEPARATOR';
        conList.add(config12);
        
        Config__c config13 = new Config__c();
        config13.Name = 'TM_USER_NAME_TEST1';
        conList.add(config13);
        
        Config__c config14 = new Config__c();
        config14.Name = 'TM_USER_NAME_TEST2';
        conList.add(config14);
        
        Config__c config15 = new Config__c();
        config15.Name = 'ASSET_DEFAULT_MANUFACTURER';
        conList.add(config15);
        
        Config__c config16 = new Config__c();
        config16.Name = 'CORE_OpportunityApprovalProcess';
        conList.add(config16);

        Config__c config17 = new Config__c();
        config17.Name = 'COREOpportunityRecordType';
        config17.Value__c = '012U0000000Ldb8';
        conList.add(config17);
        
        Config__c config18 = new Config__c();
        config18.Name = 'EMGBusinessPartnerRecordType';
        conList.add(config18);
        
        Config__c config19 = new Config__c();
        config19.Name = 'EMGBusinessPartnerOwner';
        conList.add(config19);
        
        Config__c config20 = new Config__c();
        config20.Name = 'EMGStatusGetRejected';
        conList.add(config20);
        
        Config__c config21 = new Config__c();
        config21.Name = 'RT_RFP_Refused';
        conList.add(config21);
        
        Config__c config22 = new Config__c();
        config22.Name = 'RT_RFP_Accepted';
        conList.add(config22);
        
        Config__c config23 = new Config__c();
        config23.Name = 'RT_RFP_PROPOSAL_ACCEPTED ';
        conList.add(config23);
        
        Config__c config24 = new Config__c();
        config24.Name = 'RT_RFP_PROPOSAL_REFUSED ';
        conList.add(config24);
        
        Config__c config25 = new Config__c();
        config25.Name = 'ACCEPTED_RFP_FORM_TEMPLATE';
        conList.add(config25);
        
        Config__c config26 = new Config__c();
        config26.Name = 'REJECTED_RFP_FORM_TEMPLATE';
        conList.add(config26);
        
        Config__c config27 = new Config__c();
        config27.Name = 'SUBMIT_RFP_FORM_TEMPLATE';
        conList.add(config27);
        
        Config__c config28 = new Config__c();
        config28.Name = 'PENDING_RFP_FORM_TEMPLATE ';
        conList.add(config28);
        
        Config__c config29 = new Config__c();
        config29.Name = 'INACTIVE_OFFER';
        conList.add(config29);
        
        Config__c config30 = new Config__c();
        config30.Name = 'ACTIVE_OFFER';
        conList.add(config30);
        
        Config__c config31 = new Config__c();
        config31.Name = 'REGION_EMEA ';
        conList.add(config31);
        
            
        Config__c config33 = new Config__c();
        config33.Name =' BID_PROPOSAL_CONTACT_EMEA';
        conList.add(config33);
        
        Config__c config34 = new Config__c();
        config34.Name = 'BID_PROPOSAL_CONTACT_NA';
        conList.add(config34);
        
        Config__c config35 = new Config__c();
        config35.Name = 'RFP_QUEUE';
        conList.add(config35);
        
        Config__c config36 = new Config__c();
        config36.Name = 'RFP_MAIL';
        conList.add(config36);
        
        Config__c config37 = new Config__c();
        config37.Name = 'RT_OQM_Submission';
        conList.add(config37);
        
        Config__c config38 = new Config__c();
        config38.Name = 'RT_RFP_Submission';
        conList.add(config38);
        
        Config__c config39 = new Config__c();
        config39.Name = 'RT_OQM_PROPOSAL_ACCEPTED';
        conList.add(config39);
        
        Config__c config40 = new Config__c();
        config40.Name = 'RT_OQM_PROPOSAL_REFUSED';
        conList.add(config40);
        
        Config__c config41 = new Config__c();
        config41.Name = 'OQM_STATUS_PENDING';
        conList.add(config41);
        
        Config__c config42 = new Config__c();
        config42.Name = 'OQM_STATUS_SUBMIT';
        conList.add(config42);
        
        
        Config__c config44 = new Config__c();
        config44.Name = 'OQM_STATUS_REJECTED';
        conList.add(config44);
        
        Config__c config45 = new Config__c();
        config45.Name = 'OQM_STATUS_ACCEPTED';
        conList.add(config45);
        
        Config__c config46 = new Config__c();
        config46.Name = 'OPP_STAGE4';
        conList.add(config46);
        
        Config__c config47 = new Config__c();
        config47.Name = 'OPP_STAGE5';
        conList.add(config47);
        
        Config__c config48 = new Config__c();
        config48.Name = 'OPP_STAGE6';
        conList.add(config48);
        
        Config__c config49 = new Config__c();
        config49.Name = 'OPP_STAGE7';
        conList.add(config49);
        
        Config__c config50 = new Config__c();
        config50.Name = 'OPP_STAGE81';
        conList.add(config50);
        
        Config__c config51 = new Config__c();
        config51.Name = 'OPP_STAGE82';
        conList.add(config51);
        
        Config__c config52 = new Config__c();
        config52.Name = 'OPP_STAGE9';
        conList.add(config52);
        
        Config__c config53 = new Config__c();
        config53.Name = 'OPP_STAGE10';
        conList.add(config53);
        
        Config__c config54 = new Config__c();
        config54.Name = 'BP_ROLE';
        conList.add(config54);
        
        Config__c config55 = new Config__c();
        config55.Name = 'PROFIL_ADMIN_ID';
        conList.add(config55);
        
        insert conList;
        
    
        List<Account> accList = new List<Account>();
        
        Account acct = new Account();
        acct.Name = 'Test Account';
       // acct.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].id;
        accList.add(acct);
        
        Account acct1 = new Account();
        acct1.Name = 'Holding Account';
      // acct.Country__c = [SELECT Id FROM Country__c WHERE Name = 'United States' LIMIT 1].id;
        accList.add(acct1);
        
        insert accList;

        Opportunity opp = new Opportunity();
        opp.AccountId = acct.Id;
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Prospect';
        opp.CloseDate = Date.Today();
        
        insert opp;
             
        Contact con = new Contact();
        con.AccountId = acct1.Id;
        con.LastName = 'Test Contact';
        con.Email = 'standarduser@testorg.com';
        
        insert con;
        
        Profile profile = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        Profile profile1 = [SELECT Id FROM Profile WHERE Name='GEN - Finance'];
        Profile profile2 = [SELECT Id FROM Profile WHERE Name='GEN - Direct Touch AMERICAS'];
        
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

        gcrList.add(gcr);

        GCR__c gcr1 = new GCR__c();
        
        gcr1.Account__c = opp.AccountId;
        gcr1.Opportunity__c = opp.id;
        gcr1.Region__c = opp.Account.Country__r.Region__c;
        gcr1.Request_Type__c = 'Sales';
        gcr1.CreatedDate = Date.Today();
        gcr1.Contact_Name__c = con.Name;
        gcr1.Contact_Phone__c = con.ContactPhone__c;
        gcr1.Requestor_Name__c = UserInfo.getUserId() ;

        gcrList.add(gcr1);
        
        GCR__c gcrs = new GCR__c();
        gcrs.Contact__c = con.id;
        gcrs.Account__c = acct.Id;
        gcrs.Contract_Due_Date__c = Date.Today();
        gcrs.Attorney_Name__c = UserInfo.getUserId();
        
        gcrList.add(gcrs);
        

        PageReference pageRef = Page.GCRequest;
        pageRef.getparameters().put('id',gcr.Id);
        pageRef.setRedirect(true);
        
        PageReference pRef = Page.GCRContentDocumentDetails;
        pRef.getparameters().put('accId',gcr.Account__c);
        pRef.setRedirect(true);
        
        User usr = new User();
        usr.Alias = 'standt';
        usr.Email='standarduser@testorg.com'; 
        usr.EmailEncodingKey='UTF-8';
        usr.ProfileId = profile.Id; 
        usr.UserName = 'test65490111'+ Math.random().format()+'@genesys.com';
        usr.LastName = 'Testing';
        usr.LanguageLocaleKey='en_US'; 
        usr.LocaleSidKey='en_US';
        usr.TimeZoneSidKey='America/Los_Angeles';

        insert usr;
        
        System.runAs(usr){
        
        System.debug('Current User: ' + UserInfo.getUserName());
        System.debug('Current profile: ' + UserInfo.getProfileId()); 
        
        ApexPages.standardController stdCont = new ApexPages.standardController(gcr);
        GCRequestController gcrController =new GCRequestController(stdCont);
        

        }
        
        User usr1 = new User();
        usr1.Alias = 'standt';
        usr1.Email='standarduser@testorg.com'; 
        usr1.EmailEncodingKey='UTF-8';
        usr1.ProfileId = profile1.Id; 
        usr1.UserName = 'test8554411'+ Math.random().format()+'@genesys.com';
        usr1.LastName='Testing';
        usr1.LanguageLocaleKey='en_US'; 
        usr1.LocaleSidKey='en_US';
        usr1.TimeZoneSidKey='America/Los_Angeles';
        
        insert usr1;
        ApexPages.standardController stdCont = new ApexPages.standardController(gcr);
        GCRequestController gcrController =new GCRequestController(stdCont);
        
        System.runAs(usr1){        
          System.debug('Current User: ' + UserInfo.getUserName());
          System.debug('Current profile: ' + UserInfo.getProfileId()); 
          gcrController.selectedView = 'compYear';
          gcrController.loadRecords();
          gcrController.subject = 'test';
          gcrController.selectedView = 'compMonth';
          gcrController.loadRecords();
          
          gcrController.selectedView = gcr.Status__c;
          gcrController.loadRecords();
        }
        System.runAs(usr){          
       //   gcrController.insertDCR();        
        //  gcrController.createNew();
        
        }
        
        User usr2 = new User();
        usr2.Alias = 'standt';
        usr2.Email='standarduser@testorg.com'; 
        usr2.EmailEncodingKey='UTF-8';
        usr2.ProfileId = profile2.Id; 
        usr2.UserName = 'test88764411'+ Math.random().format()+'@genesys.com';
        usr2.LastName='Testing';
        usr2.LanguageLocaleKey='en_US'; 
        usr2.LocaleSidKey='en_US';
        usr2.TimeZoneSidKey='America/Los_Angeles';

        insert usr2;
        Test.stopTest();
        System.runAs(usr2){
        
          System.debug('Current User: ' + UserInfo.getUserName());
          System.debug('Current profile: ' + UserInfo.getProfileId()); 
          
          stdCont = new ApexPages.standardController(gcr);
          gcrController =new GCRequestController(stdCont);
          
          gcrController.selectedView = 'Closed';
          gcrController.loadRecords();
        
        }
        
        stdCont = new ApexPages.standardController(gcr);

        ApexPages.currentPage().getParameters().put('accid',acct.Id);
        //ApexPages.currentPage().getParameters().put('documentId',gcrDocDetail.Id);
        
        gcrController =new GCRequestController(stdCont);

        ApexPages.currentPage().getParameters().put('oppid',opp.Id);
        
        stdCont = new ApexPages.standardController(gcr);
        gcrController =new GCRequestController(stdCont);

        gcrController.submitForApproval();

        insert gcrList;

        List<Attachment> attachmentList = new List<Attachment>();
        
        Attachment attach = new Attachment();
        attach.Name = 'Test Attachment';
        attach.ParentId = gcr.Id;
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.Body = bodyBlob;
        attachmentList.add(attach);

        insert attachmentList;

        List<GCR_Content_Document_Folder__c> gcrFolderList = new List<GCR_Content_Document_Folder__c>();
        
        GCR_Content_Document_Folder__c gcrFolder = new GCR_Content_Document_Folder__c();
        gcrFolder.Name = gcr.Name;
        gcrFolder.Account__c = gcr.Account__c;
        gcrFolder.GCR__c = gcr.id;
        gcrFolder.Active__c = true;
        gcrFolderList.add(gcrFolder);
        insert gcrFolderList;
        
        List<GCR_Content_Document_Detail__c> gcrDocList = new  List<GCR_Content_Document_Detail__c>();
        
        GCR_Content_Document_Detail__c  gcrDocDetail = new GCR_Content_Document_Detail__c();
        gcrDocDetail.Folder__c = gcrFolder.id;
        gcrDocDetail.Account_Name__c = gcr.Account__c;
        gcrDocDetail.GCR__c = gcr.id;
        gcrDocDetail.Document_Name__c = gcr.Name;
        gcrDocDetail.Active__c = true;
        gcrDocDetail.Legal_Exceptions__c = 'Ramp Period';
        gcrDocDetail.IsGoverningContract__c = true;
        gcrDocDetail.Contract_Category__c = 'Amend';
        gcrDocDetail.Expiration_Renewal_Date__c = System.today().addDays(5);
        gcrDocDetail.Contract_Type__c = 'Service Order';
        gcrDocDetail.Is_Governing_Contract__c = true; 
        gcrDocList.add(gcrDocDetail);
        insert gcrDocList;
		
		List<GCR_Content_Document_Detail__c> gcrDocList1 = new  List<GCR_Content_Document_Detail__c>();
        
        GCR_Content_Document_Detail__c  gcrDocDetail1 = new GCR_Content_Document_Detail__c();
        gcrDocDetail1.Folder__c = gcrFolder.id;
        gcrDocDetail1.Account_Name__c = gcr.Account__c;
        gcrDocDetail1.GCR__c = gcr.id;
        gcrDocDetail1.Document_Name__c = gcr.Name;
        gcrDocDetail1.Active__c = true;
        gcrDocDetail1.Legal_Exceptions__c = 'Ramp Period';
        gcrDocDetail1.IsGoverningContract__c = true;
        gcrDocDetail1.Contract_Category__c = 'Amend';		
        gcrDocDetail1.Expiration_Renewal_Date__c = System.today().addDays(5);
        gcrDocDetail1.Contract_Type__c = 'New Contract';
        gcrDocDetail1.Is_Governing_Contract__c = true; 
        gcrDocList1.add(gcrDocDetail1);
        insert gcrDocList1;

        GCR_Values__c gcrReplyToEmail = new GCR_Values__c();
        gcrReplyToEmail.Name = 'GCR_Reply_To_Email';
             
        insert gcrReplyToEmail;
        ApexPages.CurrentPage().getParameters().put('accid', accList.get(0).Id);
        stdCont = new ApexPages.standardController(gcr);
        gcrController =new GCRequestController(stdCont);
        
        gcrController.body = '';
        gcrController.send();
  
        gcrController.moveToContracts();

        gcrController.attIdToDelete = attach.Id;
        gcrController.delAtt();  

        gcrController.selectedView = 'compYear';
        gcrController.loadRecords();
        
        gcrController.isSales= true;      
        gcrController.selectedView = 'Opened';        
        gcrController.loadRecords();
        
        gcrController.isSales= true;      
        gcrController.selectedView = 'All';
        gcrController.loadRecords();
                
         
        
        gcrController.selectedView = gcr.Status__c;
        gcrController.loadRecords();
        gcrController.record.Status__c = '10-Completed';
        gcrController.insertDCR();
        
        gcrController.insertAttachment();        
        gcrController.retrieveRecord();        
        gcrController.dummyMethod() ;        
        gcrController.createNew();        
        gcrController.cancel();

        stdCont = new ApexPages.standardController(gcr);
        gcrController =new GCRequestController(stdCont);

        gcrController.isComplete = true;
        gcrController.changeStatus();        
        gcrController.populateAttorneyDetails();        
        gcrController.submitForApproval();        
        gcrController.retrieveRecordTemp();        
        gcrController.metadataClicked();        
        gcrController.saveList();
        
        gcrController.ndaCon = 'I Agree';
        gcrController.showNDA();
        
        gcrController.currentStatus = 'Self-Service';
        gcrController.showNdaButton();
        gcrController.resetNewAction();
        gcrController.record.Id = null;
        gcrController.createGCRequest();
        gcrController.showAttorneyWorkload();
        gcrController.hideAttorneyWorkload();
        gcrController.isAdmin = false;
        gcrController.submitGCR();
        gcrController.gcrApprovals = gcrList;
        gcrController.showParterType = true;
        gcrController.isFinance = true;
        gcrController.testM();    
        gcrController.selfServiceNDA();
        //gcrController.isAdmin = false;
        
        gcr.Status__c = '10-Completed';
        update gcr; 
        gcrController.insertDCR();  
  }
  
  
    static testmethod void TestGCRequestController2(){
                
        List<Account> accList = new List<Account>();        
        Account acct = new Account();
        acct.Name = 'Test Account';
        accList.add(acct);
        
        Account acct1 = new Account();
        acct1.Name = 'Holding Account';
        accList.add(acct1);        
        insert accList;

        Opportunity opp = new Opportunity();
        opp.AccountId = acct.Id;
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Prospect';
        opp.CloseDate = Date.Today();        
        insert opp;
             
        Contact con = new Contact();
        con.AccountId = acct1.Id;
        con.LastName = 'Test Contact';
        con.Email = 'standarduser@testorg.com';        
        insert con;
        
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
        insert gcr;

        GCR__c gcr1 = new GCR__c();        
        gcr1.Account__c = opp.AccountId;
        gcr1.Opportunity__c = opp.id;
        gcr1.Region__c = opp.Account.Country__r.Region__c;
        gcr1.Request_Type__c = 'Sales';
        gcr1.CreatedDate = Date.Today();
        gcr1.Contact_Name__c = con.Name;
        gcr1.Contact_Phone__c = con.ContactPhone__c;
        gcr1.Requestor_Name__c = UserInfo.getUserId();
        gcrList.add(gcr1);
        
        GCR__c gcrs = new GCR__c();
        gcrs.Contact__c = con.id;
        gcrs.Account__c = acct.Id;
        gcrs.Contract_Due_Date__c = Date.Today();
        gcrs.Attorney_Name__c = UserInfo.getUserId();        
        gcrList.add(gcrs);
        
        List<GCR_Content_Document_Folder__c> gcrFolderList = new List<GCR_Content_Document_Folder__c>();        
        GCR_Content_Document_Folder__c gcrFolder = new GCR_Content_Document_Folder__c();
        gcrFolder.Name = gcr.Name;
        gcrFolder.Account__c = gcr.Account__c;
        gcrFolder.GCR__c = gcr.id;
        gcrFolder.Active__c = true;
        gcrFolderList.add(gcrFolder);
        insert gcrFolderList;
        
        List<GCR_Content_Document_Detail__c> gcrDocList = new  List<GCR_Content_Document_Detail__c>();        
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
        gcrDocList.add(gcrDocDetail);
        insert gcrDocList;

        GCR_Values__c gcrReplyToEmail = new GCR_Values__c();
        gcrReplyToEmail.Name = 'GCR_Reply_To_Email';             
        insert gcrReplyToEmail;
        
        Test.startTest();
        
        gcr.Status__c = '10-Completed';
        update gcr;
        Test.stopTest();
                
    
    }
    
    
}