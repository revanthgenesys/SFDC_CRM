@isTest
private class GUComplianceModuleAllTests {
    @isTest
    static void TestGUComplianceRequirements(){
        setupData();
        
        Test.startTest();
        PageReference pageRef = Page.GUComplianceRequirementsPage;
        Test.setCurrentPageReference(pageRef);
        GUComplianceRequirementsController controller = new GUComplianceRequirementsController();
        controller.selectedPartnerType = 'Cloud Reseller';
        controller.retrieveOrInitializeGUCR();
        controller.editGUCR();
        controller.cancelEditGUCR();
        controller.quickSaveGUCR();
        controller.saveGUCR();
        controller.selectedPartnerType = 'Cloud Reseller';
        controller.retrieveOrInitializeGUCR();
        Test.stopTest(); 
    }
    
    @isTest
    static void TestGUCompliancePartnerInfo(){
        
        setupData();
        // Create custom settings
        
        // Create Partner Account
        // Create Contact
        // Create Partner User
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile p = [Select Id from Profile where name = 'Genesys Portal End User'];
        recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
        
        //Create account
        Account a1 = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
        insert a1;
        Account a2 = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
        insert a2;
        
        //Create contact
        Contact c1 = new Contact(FirstName = 'Rao', Lastname = 'Tumma', AccountId = a1.Id, HomePhone = '1236547890', MobilePhone = '9012345678',
                                 MailingStreet = 'xyz', MailingCity = 'CA', MailingState = 'calfornia', MailingPostalCode = '654321', MailingCountry = 'USA',
                                 Designated_Partner_Contact__c=true,  Email='raotest1@test.com');
        insert c1;
        
        Contact c2 = new Contact(FirstName = 'Narasimha1', Lastname = 'Tumma1', AccountId = a2.Id, HomePhone = '1236547890', MobilePhone = '9012345678',
                                 MailingStreet = 'xyz', MailingCity = 'CA', MailingState = 'calfornia', MailingPostalCode = '654321', MailingCountry = 'USA',
                                 Designated_Partner_Contact__c=true,  Email='raotest21@test.com');
        insert c2;
        
        User u1 = new User( ProfileId = p.Id, Username = 'raotest1@test.com', Alias = 'Test1', Email='raotest1@test.com', EmailEncodingKey='UTF-8', Firstname='Rao', Lastname='Tumma', 
                           LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', ContactId = c1.id );
        insert u1;
        
        User u2 = new User( ProfileId = p.Id, Username = 'raotest12@test.com', Alias = 'Test21', Email='raotest12@test.com', EmailEncodingKey='UTF-8', Firstname='Narasimha1', Lastname='Tumma1', 
                           LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', ContactId = c2.id );
        insert u2;
        
        setupTrainingAndCertifications(a1, c1, u1);
        //setupTrainingAndCertifications(a2, c2, u2);
        
        
        PageReference gucrPageRef = Page.GUComplianceRequirementsPage;
        Test.setCurrentPageReference(gucrPageRef);
        GUComplianceRequirementsController gucrController = new GUComplianceRequirementsController();
        gucrController.selectedPartnerType = 'Cloud Reseller';
        gucrController.retrieveOrInitializeGUCR();
        gucrController.saveGUCR();
        
        PageReference pciPageRef = Page.GUCompliancePartnerInfoPage;
        Test.setCurrentPageReference(gucrPageRef);
        GUCompliancePartnerInfoController pciController;
        pciController = new GUCompliancePartnerInfoController(a1.Id);
        ApexPages.currentPage().getParameters().put('aid',a1.Id);
        pciController = new GUCompliancePartnerInfoController();
        ApexPages.currentPage().getParameters().put('aid',a2.Id);
        pciController = new GUCompliancePartnerInfoController();
        Test.startTest();
        pciController.partnerTypeChanged();
        pciController.certificationListType = 'CURRENT';
        pciController.getCertificationDetails();
        pciController.certificationListType = 'PAST3MONTHS';
        pciController.getCertificationDetails();
        pciController.certificationListType = 'NEXT3MONTHS';
        pciController.getCertificationDetails();
        pciController.certificationListType = 'BEFOREEOY';
        pciController.getCertificationDetails();
        
        pciController.getTrainingDetails();
        pciController.getAllCertifications();
        //pciController.getAllLitmosTrainings();
        // pciController.getAllTrainings();
        
        pciController.getNewSpecializationDetails();
        pciController.changeSelection();
        pciController.getSpecializationByOffering();
        pciController.getSelectedSpecializationDetails();
        pciController.getCertificationDetailsBySpecialization();
        pciController.certificationListType = 'Sales - Training';
        pciController.getCertificationDetailsBySpecialization();
        pciController.fetchcurrentSpecialization();
        
        List<GUCompliancePartnerInfoController.PartnerComplianceInfoWrapper> data  = pciController.data;
        for(GUCompliancePartnerInfoController.PartnerComplianceInfoWrapper pciw : data){
            System.debug(pciw.requirementsDone);
            System.debug(pciw.requirementsGap);
        }
        Test.stopTest();
    } 
    
    @isTest
    static void TestGUComplianceEmailPartnersBatch(){
        
        setupData();
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile p = [Select Id from Profile where name = 'Genesys Portal End User'];
        recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
        
        //Create account
        Account a = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
        insert a;
        
        //Create contact
        Contact c = new Contact(FirstName = 'Rao', Lastname = 'Tumma', AccountId = a.Id, HomePhone = '1236547890', MobilePhone = '9012345678',
                                MailingStreet = 'xyz', MailingCity = 'CA', MailingState = 'calfornia', MailingPostalCode = '654321', MailingCountry = 'USA',
                                Designated_Partner_Contact__c=true,  Email='raotest@test.com');
        insert c;
        
        User u = new User( ProfileId = p.Id, Username = 'raotest@test.com', Alias = 'Test1', Email='raotest@test.com', EmailEncodingKey='UTF-8', Firstname='Rao', Lastname='Tumma', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', ContactId = c.id );
        insert u;
        
        setupTrainingAndCertifications(a, c, u);
        
        Test.startTest();
        Database.executeBatch(new GUComplianceEmailPartnersBatch());    
        Test.stopTest();
        
    } 
    
    @isTest
    static void TestGUComplianceEmailPartnersScheduler(){
        
        setupData();
        
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        system.debug('portalRole is ' + portalRole);
        
        Profile p = [Select Id from Profile where name = 'Genesys Portal End User'];
        recordtype rc = [select id from recordtype where developername = 'EMGBusinessPartnerRecordType' limit 1];
        
        //Create account
        Account a = new Account (Name = 'Holding Account', RecordTypeId=rc.id, Status__c='Active', PartnerType__c='Cloud Reseller;VAR' , Partner_Tier__c = 'Gold', Partner_Business_Size__c = 'MAJ'); 
        insert a;
        
        //Create contact
        Contact c = new Contact(FirstName = 'Rao', Lastname = 'Tumma', AccountId = a.Id, HomePhone = '1236547890', MobilePhone = '9012345678',
                                MailingStreet = 'xyz', MailingCity = 'CA', MailingState = 'calfornia', MailingPostalCode = '654321', MailingCountry = 'USA',
                                Designated_Partner_Contact__c=true,  Email='raotest@test.com');
        insert c;
        
        User u = new User( ProfileId = p.Id, Username = 'raotest@test.com', Alias = 'Test1', Email='raotest@test.com', EmailEncodingKey='UTF-8', Firstname='Rao', Lastname='Tumma', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', TimeZoneSidKey='America/Chicago', ContactId = c.id );
        insert u;
        
        setupTrainingAndCertifications(a, c, u);
        
        Test.startTest();
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        // Schedule the test job
        String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP,  new GUComplianceEmailPartnersScheduler());
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, ct.CronExpression);
        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        // Verify the next time the job will run
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));
        Test.stopTest();
        
    } 
    
    
    static void setupTrainingAndCertifications(Account a, Contact c, User u){
        //List<Litmos__Course__c> litmosCourses = new List<Litmos__Course__c>();
        //List<Litmos__User_Record__c> litmosUserRecords = new List<Litmos__User_Record__c>();
        
        /*for(Integer i=1; i <= 200; i++){
            litmosCourses.add(new Litmos__Course__c(Name = 'Course ' + i, Litmos__Course_Id__c = '1010101' + i, 
                                                    Litmos__Course_Name__c= 'Training ' + i, Litmos__Course_Description__c = 'This is Training ' + i));
        }
        insert litmosCourses;*/
        
        /*for(Integer i=1; i <= 200; i++){
            litmosUserRecords.add(new Litmos__User_Record__c(
                Name = 'LUR-'+i,
                Litmos__Active__c = True,
                Litmos__Completed__c = True,
                Litmos__Assigned_Date__c = Date.today().addDays(-i*20),
                Litmos__Completed_Date__c = Date.today().addDays(-i*10),
                Litmos__Contact__c = c.Id,
                Litmos__Course__c = litmosCourses[i-1].Id,
                Litmos__Percentage_Complete__c = 100.0,
                Litmos__User__c = u.Id
            ));
        }
        insert litmosUserRecords;*/
        
        
        docebo_v3__DoceboUser__c doceboUsr = new docebo_v3__DoceboUser__c(docebo_v3__Contact__c=c.Id,docebo_v3__UserId__c = 44444,docebo_v3__Who__c = c.Id);
        insert doceboUsr;
        
        docebo_v3__Course__c doceboCourse = new docebo_v3__Course__c(docebo_v3__Code__c='SSU-PureConnect-E-19-004',docebo_v3__CourseId__c=608,
                                                                        docebo_v3__Deleted__c = false,docebo_v3__Description__c='<p><span style="color:#000000;">n this course, you will get an understanding of the core functions of the PureConnect Offer. We will also help you learn about the four core application used to administer, configure and manage PureConnect. </span></p>',
                                                                        docebo_v3__Effective__c = true,docebo_v3__Language__c = 'english',docebo_v3__CreationDate__c=Date.newInstance(2019, 12, 9),
                                                                        docebo_v3__Name__c = 'PureConnect Features and Capabilities for Partners',docebo_v3__Slug__c='pureconnect-features-and-capabilities-for-partners',
                                                                        docebo_v3__Type__c='Elearning');
        insert doceboCourse;
        
        docebo_v3__CourseEnrollment__c  enrollmnt = new docebo_v3__CourseEnrollment__c(docebo_v3__CompletedLearningObjects__c=2, docebo_v3__Completion__c=100, 
                                                         docebo_v3__Course__c=doceboCourse.Id, docebo_v3__Credits__c=0, docebo_v3__DoceboUser__c=doceboUsr.Id, 
                                                        docebo_v3__EnrolmentId__c='44444_608', docebo_v3__Score__c=0, docebo_v3__Status__c='Completed', 
                                                        docebo_v3__TimeInCourse__c=1167, docebo_v3__Who__c=c.Id);
        insert enrollmnt;
                                                        
        
        List<Partner_Certifications__c> certifications = new List<Partner_Certifications__c>();
        for(integer i = 1; i <= 20; i ++){
            certifications.add(new Partner_Certifications__c(Name = 'CERT-GCPS'+i, Account__c = a.Id, Account_Name__c = a.Name,
                                                             Country_Code__c = 'USA', Country_Name__c = 'USA',
                                                             First_Name__c = 'Candidate', Last_Name__c = ''+i, Email__c = 'candidate'+i+'@test.com',
                                                             Test_Code__c = 'GCPS'+i, Test_Name__c = 'GCPS'+i, Genesys_Test_Code__c = 'GCPS'+i,
                                                             Test_Date__c = Date.today().addDays((i * 10) - 300), Expiry_Date__c = Date.today().addDays((i * 10) - 50), Pass_Fail__c = 'P',
                                                             ViewCentral_Contact_ID__c = 'GCPSVCCID'+i, ViewCentral_ID__c = 'GCPSVCID'+i, Voucher_Code__c = 'GCPSVC'+i));
        }
        for(integer i = 1; i <= 20; i ++){
            certifications.add(new Partner_Certifications__c(Name = 'CERT-GCP'+i, Account__c = a.Id, Account_Name__c = a.Name,
                                                             Country_Code__c = 'USA', Country_Name__c = 'USA',
                                                             First_Name__c = 'Candidate', Last_Name__c = ''+i, Email__c = 'candidate'+i+'@test.com',
                                                             Test_Code__c = 'GCP'+i, Test_Name__c = 'GCP'+i, Genesys_Test_Code__c = 'GCP'+i,
                                                             Test_Date__c = Date.today().addDays((i * 10) - 300), Expiry_Date__c = Date.today().addDays((i * 10) - 50), Pass_Fail__c = 'P',
                                                             ViewCentral_Contact_ID__c = 'GCPVCCID'+i, ViewCentral_ID__c = 'GCPVCID'+i, Voucher_Code__c = 'GCPVC'+i));
        }
        for(integer i = 1; i <= 20; i ++){
            certifications.add(new Partner_Certifications__c(Name = 'CERT-GCS'+i, Account__c = a.Id, Account_Name__c = a.Name,
                                                             Country_Code__c = 'USA', Country_Name__c = 'USA',
                                                             First_Name__c = 'Candidate', Last_Name__c = ''+i, Email__c = 'candidate'+i+'@test.com',
                                                             Test_Code__c = 'GCS'+i, Test_Name__c = 'GCS'+i, Genesys_Test_Code__c = 'GCS'+i,
                                                             Test_Date__c = Date.today().addDays((i * 10) - 300), Expiry_Date__c = Date.today().addDays((i * 10) - 50), Pass_Fail__c = 'P',
                                                             ViewCentral_Contact_ID__c = 'GCSVCCID'+i, ViewCentral_ID__c = 'GCSVCID'+i, Voucher_Code__c = 'GCSVC'+i));
        }
        for(integer i = 1; i <= 20; i ++){
            certifications.add(new Partner_Certifications__c(Name = 'CERT-GCD'+i, Account__c = a.Id, Account_Name__c = a.Name,
                                                             Country_Code__c = 'USA', Country_Name__c = 'USA',
                                                             First_Name__c = 'Candidate', Last_Name__c = ''+i, Email__c = 'candidate'+i+'@test.com',
                                                             Test_Code__c = 'GCD'+i, Test_Name__c = 'GCD'+i, Genesys_Test_Code__c = 'GCD'+i,
                                                             Test_Date__c = Date.today().addDays((i * 10) - 300), Expiry_Date__c = Date.today().addDays((i * 10) - 50), Pass_Fail__c = 'P',
                                                             ViewCentral_Contact_ID__c = 'GCDVCCID'+i, ViewCentral_ID__c = 'GCDVCID'+i, Voucher_Code__c = 'GCDVC'+i));
        }
        
        insert certifications;
    }
    
    static void setupData(){
        List<CS_Partner_Type__c> cspTypesCS = new List<CS_Partner_Type__c>();
        List<CS_Partner_Tier__c> cspTiersCS = new List<CS_Partner_Tier__c>();
        List<CS_Partner_Size__c> cspSizesCS = new List<CS_Partner_Size__c>();
        List<CS_Partner_Certification_Group__c> cspCertGroupsCS = new List<CS_Partner_Certification_Group__c>();
        List<Config__c> conList = new List<Config__c>();
        
        cspTypesCS.add(new CS_Partner_Type__c(Name = 'Business', DisplayOrder__c = 1, isActive__c = TRUE));
        cspTypesCS.add(new CS_Partner_Type__c(Name = 'Services', DisplayOrder__c = 2, isActive__c = TRUE));
        cspTypesCS.add(new CS_Partner_Type__c(Name = 'Technology', DisplayOrder__c = 3, isActive__c = TRUE));
        insert cspTypesCS;
        
        cspTiersCS.add(new CS_Partner_Tier__c(Name = 'Gold', DisplayOrder__c = 1));
        cspTiersCS.add(new CS_Partner_Tier__c(Name = 'Silver', DisplayOrder__c = 2));
        cspTiersCS.add(new CS_Partner_Tier__c(Name = 'Bronze', DisplayOrder__c = 3));
        insert cspTiersCS;
        
        cspSizesCS.add(new CS_Partner_Size__c(Name = 'LG', DisplayOrder__c = 1, isActive__c = TRUE));
        cspSizesCS.add(new CS_Partner_Size__c(Name = 'MAJ', DisplayOrder__c = 2, isActive__c = TRUE));                       
        cspSizesCS.add(new CS_Partner_Size__c(Name = 'MID', DisplayOrder__c = 3, isActive__c = TRUE));
        cspSizesCS.add(new CS_Partner_Size__c(Name = 'SM', DisplayOrder__c = 4, isActive__c = TRUE));                       
        insert cspSizesCS;
        
        cspCertGroupsCS.add(new CS_Partner_Certification_Group__c(Name = '# of Certifications', Certification_Prefix__c = 'G', DisplayOrder__c = 1, isActive__c = TRUE));
        insert cspCertGroupsCS;
        
        conList.add(new Config__c(Name = 'CORE_OPP_STAGE_CLOSED_WON',Value__c = 'User Contract'));
        conList.add(new Config__c(Name = 'USER_PARTNER',Value__c = 'PowerPartner'));
        conList.add(new Config__c(Name = 'USER_STANDARD',Value__c = ''));
        conList.add(new Config__c(Name = 'CORE_OPP_BP_STATUS_ALLOCATED',Value__c = ''));
        conList.add(new Config__c(Name = 'ALE_TEAM_MEMBER_ROLE',Value__c = ''));
        conList.add(new Config__c(Name = 'CORE_OPP_BP_STATUS_REJECTED',Value__c = ''));
        conList.add(new Config__c(Name = 'CORE_OPP_BP_STATUS_NOT_ALLOCATED',Value__c = ''));
        conList.add(new Config__c(Name = 'CORE_OPP_BP_STATUS_APPROVED',Value__c = ''));
        conList.add(new Config__c(Name = 'BP_TEAM_MEMBER_ROLE',Value__c = ''));
        conList.add(new Config__c(Name = 'TM_MONITOR_AD_EMAIL1',Value__c = ''));
        conList.add(new Config__c(Name = 'TM_MONITOR_AD_EMAIL2',Value__c = ''));
        conList.add(new Config__c(Name = 'TM_MONITOR_AD_EMAIL3',Value__c = ''));
        conList.add(new Config__c(Name = 'TM_VALUE_SEPARATOR',Value__c = ''));
        conList.add(new Config__c(Name = 'TM_USER_NAME_TEST1',Value__c = ''));
        conList.add(new Config__c(Name = 'TM_USER_NAME_TEST2',Value__c = ''));
        conList.add(new Config__c(Name = 'ASSET_DEFAULT_MANUFACTURER',Value__c = ''));
        conList.add(new Config__c(Name = 'CORE_OpportunityApprovalProcess',Value__c = ''));
        conList.add(new Config__c(Name = 'COREOpportunityRecordType',Value__c = '012U0000000Ldb8'));
        conList.add(new Config__c(Name = 'EMGBusinessPartnerRecordType',Value__c = ''));
        conList.add(new Config__c(Name = 'EMGBusinessPartnerOwner',Value__c = ''));
        conList.add(new Config__c(Name = 'EMGStatusGetRejected',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_RFP_Refused',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_RFP_Accepted',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_RFP_PROPOSAL_ACCEPTED',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_RFP_PROPOSAL_REFUSED',Value__c = ''));
        conList.add(new Config__c(Name = 'ACCEPTED_RFP_FORM_TEMPLATE',Value__c = ''));
        conList.add(new Config__c(Name = 'REJECTED_RFP_FORM_TEMPLATE',Value__c = ''));
        conList.add(new Config__c(Name = 'SUBMIT_RFP_FORM_TEMPLATE',Value__c = ''));
        conList.add(new Config__c(Name = 'PENDING_RFP_FORM_TEMPLATE',Value__c = ''));
        conList.add(new Config__c(Name = 'INACTIVE_OFFER',Value__c = ''));
        conList.add(new Config__c(Name = 'ACTIVE_OFFER',Value__c = ''));
        conList.add(new Config__c(Name = 'REGION_EMEA',Value__c = ''));
        conList.add(new Config__c(Name = 'BID_PROPOSAL_CONTACT_EMEA',Value__c = ''));
        conList.add(new Config__c(Name = 'BID_PROPOSAL_CONTACT_NA',Value__c = ''));
        conList.add(new Config__c(Name = 'RFP_QUEUE',Value__c = ''));
        conList.add(new Config__c(Name = 'RFP_MAIL',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_OQM_Submission',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_RFP_Submission',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_OQM_PROPOSAL_ACCEPTED',Value__c = ''));
        conList.add(new Config__c(Name = 'RT_OQM_PROPOSAL_REFUSED',Value__c = ''));
        conList.add(new Config__c(Name = 'OQM_STATUS_PENDING',Value__c = ''));
        conList.add(new Config__c(Name = 'OQM_STATUS_SUBMIT',Value__c = ''));
        conList.add(new Config__c(Name = 'OQM_STATUS_REJECTED',Value__c = ''));
        conList.add(new Config__c(Name = 'OQM_STATUS_ACCEPTED',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE4',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE5',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE6',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE7',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE81',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE82',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE9',Value__c = ''));
        conList.add(new Config__c(Name = 'OPP_STAGE10',Value__c = ''));
        conList.add(new Config__c(Name = 'BP_ROLE',Value__c = ''));
        conList.add(new Config__c(Name = 'PROFIL_ADMIN_ID',Value__c = ''));
        insert conList;
        
        List<CS_Partner_Offering_Type__c> list_CSPartnerOffers = new List<CS_Partner_Offering_Type__c>();
        list_CSPartnerOffers.add(new CS_Partner_Offering_Type__c(name = 'PureCloud' , DisplayOrder__c = 1 , Specialization__c = 'PureCloud'));
        list_CSPartnerOffers.add(new CS_Partner_Offering_Type__c(name = 'PureConnect' , DisplayOrder__c = 2, Specialization__c = 'Core \n Quality Management \n Optimizer \n Developer(lslibe) \n Dialer'));
        list_CSPartnerOffers.add(new CS_Partner_Offering_Type__c(name = 'PureEngage' , DisplayOrder__c = 3 , Specialization__c = 'Core \n WFM \n Digital \n Outbound \n EWM \n Self-Service'));
        insert list_CSPartnerOffers;
        
        List<CS_Specialization__c> list_Specializations = new List<CS_Specialization__c>();
        list_Specializations.add(new CS_Specialization__c(Name= 'PureCloud' ,  Prerequisite__c = '' , Offering_Type__c = 'PureCloud'));
        list_Specializations.add(new CS_Specialization__c(Name= 'Core' ,  Prerequisite__c = '' , Offering_Type__c = 'PureConnect'));
        list_Specializations.add(new CS_Specialization__c(Name= 'Quality Management ' ,  Prerequisite__c = 'Core' , Offering_Type__c = 'PureConnect'));
        list_Specializations.add(new CS_Specialization__c(Name= 'Optimizer' ,  Prerequisite__c = 'Core' , Offering_Type__c = 'PureConnect'));
        list_Specializations.add(new CS_Specialization__c(Name= 'Dialer' ,  Prerequisite__c = 'Core' , Offering_Type__c = 'PureConnect'));
        list_Specializations.add(new CS_Specialization__c(Name= 'PureEngage - Core' ,  Prerequisite__c = '' , Offering_Type__c = 'PureEngage'));
        list_Specializations.add(new CS_Specialization__c(Name= 'WFM' ,  Prerequisite__c = 'PureEngage - Core' , Offering_Type__c = 'PureEngage'));
        list_Specializations.add(new CS_Specialization__c(Name= 'Self-Service' ,  Prerequisite__c = 'PureEngage - Core' , Offering_Type__c = 'PureEngage'));
        list_Specializations.add(new CS_Specialization__c(Name= 'Outbound' ,  Prerequisite__c = 'PureEngage - Core' , Offering_Type__c = 'PureEngage'));
        list_Specializations.add(new CS_Specialization__c(Name= 'EWM' ,  Prerequisite__c = 'PureEngage - Core' , Offering_Type__c = 'PureEngage'));
        list_Specializations.add(new CS_Specialization__c(Name= 'Digital' ,  Prerequisite__c = 'PureEngage - Core' , Offering_Type__c = 'PureEngage'));
        list_Specializations.add(new CS_Specialization__c(Name= 'Speech Analytics   ' ,  Prerequisite__c = '' , Offering_Type__c = ''));
        insert list_Specializations;
        
        List<CS_Certification_Group_By_Specialization__c> list_CSCGBS = new List<CS_Certification_Group_By_Specialization__c>();
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'WFM-Sales - Training ' , Certification_Codes__c = '304730' , Solution_Group__c = 'Sales - Training' , Specialization__c = 'WFM' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'WFM-Pre-Sales' , Certification_Codes__c = '602993' , Solution_Group__c = 'Pre-Sales' , Specialization__c = 'WFM' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'WFM-Services/Support' , Certification_Codes__c = 'GCP8-GIR,GCP8-WFM' , Solution_Group__c = 'Services/Support' , Specialization__c = 'WFM' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'WFM-Developer' , Certification_Codes__c = '' , Solution_Group__c = 'Developer' , Specialization__c = 'WFM' ));
        
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Digital-Sales - Training ' , Certification_Codes__c = '599808' , Solution_Group__c = 'Sales - Training' , Specialization__c = 'Digital' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Digital-Pre-Sales' , Certification_Codes__c = '602980' , Solution_Group__c = 'Pre-Sales' , Specialization__c = 'Digital' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Digital-Services/Support' , Certification_Codes__c = 'GCP8-ESV' , Solution_Group__c = 'Services/Support' , Specialization__c = 'Digital' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Digital-Developer' , Certification_Codes__c = '' , Solution_Group__c = 'Developer' , Specialization__c = 'Digital' ));
        
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Outbound-Sales - Training ' , Certification_Codes__c = '304808' , Solution_Group__c = 'Sales - Training' , Specialization__c = 'Outbound' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Outbound-Pre-Sales' , Certification_Codes__c = '29566' , Solution_Group__c = 'Pre-Sales' , Specialization__c = 'Outbound' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Outbound-Services/Support' , Certification_Codes__c = 'GCP8-COV' , Solution_Group__c = 'Services/Support' , Specialization__c = 'Outbound' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Outbound-Developer' , Certification_Codes__c = '' , Solution_Group__c = 'Developer' , Specialization__c = 'Outbound' ));
        
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'EWM-Sales - Training ' , Certification_Codes__c = '601078' , Solution_Group__c = 'Sales - Training' , Specialization__c = 'EWM' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'EWM-Pre-Sales' , Certification_Codes__c = '602987' , Solution_Group__c = 'Pre-Sales' , Specialization__c = 'EWM' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'EWM-Services/Support' , Certification_Codes__c = 'GCP8-IWD' , Solution_Group__c = 'Services/Support' , Specialization__c = 'EWM' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'EWM-Developer' , Certification_Codes__c = '' , Solution_Group__c = 'Developer' , Specialization__c = 'EWM' ));
        
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Self-Service-Sales - Training ' , Certification_Codes__c = '600001' , Solution_Group__c = 'Sales - Training' , Specialization__c = 'Self-Service' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Self-Service-Pre-Sales' , Certification_Codes__c = '602984' , Solution_Group__c = 'Pre-Sales' , Specialization__c = 'Self-Service' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Self-Service-Services/Support' , Certification_Codes__c = 'GCP8-DCV,GCP8-GVP8' , Solution_Group__c = 'Services/Support' , Specialization__c = 'Self-Service' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Self-Service-Developer' , Certification_Codes__c = '' , Solution_Group__c = 'Developer' , Specialization__c = 'Self-Service' ));
        
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Core-Sales - Training ' , Certification_Codes__c = '' , Solution_Group__c = 'Sales - Training' , Specialization__c = 'Core' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Core-Pre-Sales' , Certification_Codes__c = '' , Solution_Group__c = 'Pre-Sales' , Specialization__c = 'Core' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Core-Services/Support' , Certification_Codes__c = 'ICCE' , Solution_Group__c = 'Services/Support' , Specialization__c = 'Core' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Core-Developer' , Certification_Codes__c = 'ICHD,ILID' , Solution_Group__c = 'Developer' , Specialization__c = 'Core' ));
        
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'PureEngage - Core-Sales - Training ' , Certification_Codes__c = '555377,555436' , Solution_Group__c = 'Sales - Training' , Specialization__c = 'PureEngage - Core' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'PureEngage - Core-Pre-Sales' , Certification_Codes__c = '586559' , Solution_Group__c = 'Pre-Sales' , Specialization__c = 'PureEngage - Core' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'PureEngage - Core-Services/Support' , Certification_Codes__c = 'GCP8-CIV,GCP8-GIM' , Solution_Group__c = 'Services/Support' , Specialization__c = 'PureEngage - Core' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'PureEngage - Core-Developer' , Certification_Codes__c = 'GCD-PSDK' , Solution_Group__c = 'Developer' , Specialization__c = 'PureEngage - Core' ));
        
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Quantity Management-Sales - Training ' , Certification_Codes__c = '' , Solution_Group__c = 'Sales - Training' , Specialization__c = 'Quantity Management' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Quantity Management-Pre-Sales' , Certification_Codes__c = '' , Solution_Group__c = 'Pre-Sales' , Specialization__c = 'Quantity Management' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Quantity Management-Services/Support' , Certification_Codes__c = '' , Solution_Group__c = 'Services/Support' , Specialization__c = 'Quantity Management' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Quantity Management-Developer' , Certification_Codes__c = '' , Solution_Group__c = 'Developer' , Specialization__c = 'Quantity Management' ));
        
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Dialer-Sales - Training ' , Certification_Codes__c = '' , Solution_Group__c = 'Sales - Training' , Specialization__c = 'Dialer' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Dialer-Pre-Sales' , Certification_Codes__c = '' , Solution_Group__c = 'Pre-Sales' , Specialization__c = 'Dialer' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Dialer-Services/Support' , Certification_Codes__c = 'IDCE' , Solution_Group__c = 'Services/Support' , Specialization__c = 'Dialer' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Dialer-Developer' , Certification_Codes__c = '' , Solution_Group__c = 'Developer' , Specialization__c = 'Dialer' ));
        
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'PureCloud-Sales - Training ' , Certification_Codes__c = '' , Solution_Group__c = 'Sales - Training' , Specialization__c = 'PureCloud' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'PureCloud-Pre-Sales' , Certification_Codes__c = '' , Solution_Group__c = 'Pre-Sales' , Specialization__c = 'PureCloud' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'PureCloud-Services/Support' , Certification_Codes__c = 'PCP' , Solution_Group__c = 'Services/Support' , Specialization__c = 'PureCloud' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'PureCloud-Developer' , Certification_Codes__c = '' , Solution_Group__c = 'Developer' , Specialization__c = 'PureCloud' ));
        
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Optimizer-Sales - Training ' , Certification_Codes__c = '' , Solution_Group__c = 'Sales - Training' , Specialization__c = 'Optimizer' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Optimizer-Pre-Sales' , Certification_Codes__c = '' , Solution_Group__c = 'Pre-Sales' , Specialization__c = 'Optimizer' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Optimizer-Services/Support' , Certification_Codes__c = 'IOCA' , Solution_Group__c = 'Services/Support' , Specialization__c = 'Optimizer' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Optimizer-Developer' , Certification_Codes__c = '' , Solution_Group__c = 'Developer' , Specialization__c = 'Optimizer' ));
        
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Developer-Sales - Training ' , Certification_Codes__c = '' , Solution_Group__c = 'Sales - Training' , Specialization__c = 'Developer' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Developer-Pre-Sales' , Certification_Codes__c = '' , Solution_Group__c = 'Pre-Sales' , Specialization__c = 'Developer' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Developer-Services/Support' , Certification_Codes__c = 'ICHD' , Solution_Group__c = 'Services/Support' , Specialization__c = 'Developer' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Developer-Developer' , Certification_Codes__c = '' , Solution_Group__c = 'Developer' , Specialization__c = 'Developer' ));
        
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Speech Analytics-Sales - Training ' , Certification_Codes__c = '' , Solution_Group__c = 'Sales - Training' , Specialization__c = 'Speech Analytics' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Speech Analytics-Pre-Sales' , Certification_Codes__c = '' , Solution_Group__c = 'Pre-Sales' , Specialization__c = 'Speech Analytics' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Speech Analytics-Services/Support' , Certification_Codes__c = '' , Solution_Group__c = 'Services/Support' , Specialization__c = 'Speech Analytics' ));
        list_CSCGBS.add(new CS_Certification_Group_By_Specialization__c(Name = 'Speech Analytics-Developer' , Certification_Codes__c = '' , Solution_Group__c = 'Developer' , Specialization__c = 'Speech Analytics' ));
        insert list_CSCGBS;
        
        
        List<CS_Partner_Type_Category_Mapping__c> list_CSPTCM = new List<CS_Partner_Type_Category_Mapping__c>();
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Support Only' ));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Specialized Reseller' , Category__c = 'Business'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Global Strategic Alliance' , Category__c = 'Business'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Cloud Reseller' , Category__c = 'Business'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Cloud Partner' , Category__c = 'Business'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Cloud Solution Provider' , Category__c = 'Business'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'VAR' , Category__c = 'Business'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Contract Reseller' , Category__c = 'Business'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Lead Referral' , Category__c = 'Business'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Consultant' , Category__c = 'Business'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Cloud Referral Partner' , Category__c = 'Business'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'OEM Partner' , Category__c = 'Business'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Managed Services Provider' , Category__c = 'Services'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Service Partner' , Category__c = 'Services'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Services Partner' , Category__c = 'Services'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Technology Partner' , Category__c = 'Technology'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'AppFoundry Partner' , Category__c = 'Technology'));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Non-Commercial' ));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Transformational Partner' ));
        list_CSPTCM.add(new CS_Partner_Type_Category_Mapping__c(name = 'Prospective Transformational Partner' ));
        insert list_CSPTCM;
        
        List<GU_Compliance_Requirement__c> list_GUCR = new List<GU_Compliance_Requirement__c>();
        
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='MAJ',Partner_Tier__c='Gold',Partner_Type__c='Technology',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='MAJ',Partner_Tier__c='Gold',Partner_Type__c='Business',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='LG',Partner_Tier__c='Gold',Partner_Type__c='Services',Required_Number__c=5));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='MAJ',Partner_Tier__c='Gold',Partner_Type__c='Services',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='LG',Partner_Tier__c='Gold',Partner_Type__c='Services',Required_Number__c=20));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='LG',Partner_Tier__c='Gold',Partner_Type__c='Services',Required_Number__c=4));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='MID',Partner_Tier__c='Gold',Partner_Type__c='Services',Required_Number__c=5));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='MID',Partner_Tier__c='Gold',Partner_Type__c='Services',Required_Number__c=12));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='MID',Partner_Tier__c='Gold',Partner_Type__c='Services',Required_Number__c=4));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='SM',Partner_Tier__c='Gold',Partner_Type__c='Services',Required_Number__c=5));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='SM',Partner_Tier__c='Gold',Partner_Type__c='Services',Required_Number__c=9));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='SM',Partner_Tier__c='Gold',Partner_Type__c='Services',Required_Number__c=4));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='LG',Partner_Tier__c='Silver',Partner_Type__c='Services',Required_Number__c=4));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='LG',Partner_Tier__c='Silver',Partner_Type__c='Services',Required_Number__c=10));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='LG',Partner_Tier__c='Silver',Partner_Type__c='Services',Required_Number__c=2));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='MID',Partner_Tier__c='Silver',Partner_Type__c='Services',Required_Number__c=4));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='MID',Partner_Tier__c='Silver',Partner_Type__c='Services',Required_Number__c=7));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='MID',Partner_Tier__c='Silver',Partner_Type__c='Services',Required_Number__c=2));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='SM',Partner_Tier__c='Silver',Partner_Type__c='Services',Required_Number__c=4));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='SM',Partner_Tier__c='Silver',Partner_Type__c='Services',Required_Number__c=6));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='SM',Partner_Tier__c='Silver',Partner_Type__c='Services',Required_Number__c=2));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='LG',Partner_Tier__c='Bronze',Partner_Type__c='Services',Required_Number__c=3));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='LG',Partner_Tier__c='Bronze',Partner_Type__c='Services',Required_Number__c=5));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='LG',Partner_Tier__c='Bronze',Partner_Type__c='Services',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='MID',Partner_Tier__c='Bronze',Partner_Type__c='Services',Required_Number__c=3));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='MID',Partner_Tier__c='Bronze',Partner_Type__c='Services',Required_Number__c=5));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='MID',Partner_Tier__c='Bronze',Partner_Type__c='Services',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='SM',Partner_Tier__c='Bronze',Partner_Type__c='Services',Required_Number__c=3));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='SM',Partner_Tier__c='Bronze',Partner_Type__c='Services',Required_Number__c=5));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='SM',Partner_Tier__c='Bronze',Partner_Type__c='Services',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='LG',Partner_Tier__c='Gold',Partner_Type__c='Business',Required_Number__c=5));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='LG',Partner_Tier__c='Gold',Partner_Type__c='Business',Required_Number__c=20));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='LG',Partner_Tier__c='Gold',Partner_Type__c='Business',Required_Number__c=4));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='MID',Partner_Tier__c='Gold',Partner_Type__c='Business',Required_Number__c=3));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='MID',Partner_Tier__c='Gold',Partner_Type__c='Business',Required_Number__c=12));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='MID',Partner_Tier__c='Gold',Partner_Type__c='Business',Required_Number__c=4));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='SM',Partner_Tier__c='Gold',Partner_Type__c='Business',Required_Number__c=2));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='SM',Partner_Tier__c='Gold',Partner_Type__c='Business',Required_Number__c=9));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='SM',Partner_Tier__c='Gold',Partner_Type__c='Business',Required_Number__c=4));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='LG',Partner_Tier__c='Silver',Partner_Type__c='Business',Required_Number__c=3));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='LG',Partner_Tier__c='Silver',Partner_Type__c='Business',Required_Number__c=10));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='LG',Partner_Tier__c='Silver',Partner_Type__c='Business',Required_Number__c=2));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='MID',Partner_Tier__c='Silver',Partner_Type__c='Business',Required_Number__c=2));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='MID',Partner_Tier__c='Silver',Partner_Type__c='Business',Required_Number__c=7));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='MID',Partner_Tier__c='Silver',Partner_Type__c='Business',Required_Number__c=2));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='SM',Partner_Tier__c='Silver',Partner_Type__c='Business',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='SM',Partner_Tier__c='Silver',Partner_Type__c='Business',Required_Number__c=6));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='SM',Partner_Tier__c='Silver',Partner_Type__c='Business',Required_Number__c=2));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='LG',Partner_Tier__c='Bronze',Partner_Type__c='Business',Required_Number__c=2));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='LG',Partner_Tier__c='Bronze',Partner_Type__c='Business',Required_Number__c=5));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='LG',Partner_Tier__c='Bronze',Partner_Type__c='Business',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='MID',Partner_Tier__c='Bronze',Partner_Type__c='Business',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='MID',Partner_Tier__c='Bronze',Partner_Type__c='Business',Required_Number__c=5));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='MID',Partner_Tier__c='Bronze',Partner_Type__c='Business',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='SM',Partner_Tier__c='Bronze',Partner_Type__c='Business',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='SM',Partner_Tier__c='Bronze',Partner_Type__c='Business',Required_Number__c=5));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='SM',Partner_Tier__c='Bronze',Partner_Type__c='Business',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='LG',Partner_Tier__c='Gold',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='LG',Partner_Tier__c='Gold',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='LG',Partner_Tier__c='Gold',Partner_Type__c='Technology',Required_Number__c=4));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='MID',Partner_Tier__c='Gold',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='MID',Partner_Tier__c='Gold',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='MID',Partner_Tier__c='Gold',Partner_Type__c='Technology',Required_Number__c=4));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='SM',Partner_Tier__c='Gold',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='SM',Partner_Tier__c='Gold',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='SM',Partner_Tier__c='Gold',Partner_Type__c='Technology',Required_Number__c=4));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='LG',Partner_Tier__c='Silver',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='LG',Partner_Tier__c='Silver',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='LG',Partner_Tier__c='Silver',Partner_Type__c='Technology',Required_Number__c=2));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='MID',Partner_Tier__c='Silver',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='MID',Partner_Tier__c='Silver',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='MID',Partner_Tier__c='Silver',Partner_Type__c='Technology',Required_Number__c=2));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='SM',Partner_Tier__c='Silver',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='SM',Partner_Tier__c='Silver',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='SM',Partner_Tier__c='Silver',Partner_Type__c='Technology',Required_Number__c=2));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='LG',Partner_Tier__c='Bronze',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='LG',Partner_Tier__c='Bronze',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='LG',Partner_Tier__c='Bronze',Partner_Type__c='Technology',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='MID',Partner_Tier__c='Bronze',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='MID',Partner_Tier__c='Bronze',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='MID',Partner_Tier__c='Bronze',Partner_Type__c='Technology',Required_Number__c=1));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='Trained Sales People',Partner_Size__c='SM',Partner_Tier__c='Bronze',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Certifications',Partner_Size__c='SM',Partner_Tier__c='Bronze',Partner_Type__c='Technology',Required_Number__c=0));
        list_GUCR.add(new GU_Compliance_Requirement__c(Compliance_Requirement__c='# of Specializations',Partner_Size__c='SM',Partner_Tier__c='Bronze',Partner_Type__c='Technology',Required_Number__c=1));
        insert list_GUCR;
    }
}