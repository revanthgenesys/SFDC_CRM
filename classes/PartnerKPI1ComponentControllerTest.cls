@isTest
private class  PartnerKPI1ComponentControllerTest {

    static Account testAccount;
    static Contact testContact;
    static User usr;
    static Partner_KPI_Periods__c  partnerKPIPeriodsCS;
    static List<Partner_Quarterly_KPI__c> kpi1Data;
    static List<KPI1_Case_Details__c> kpi1CaseDetais;
    
    
    @isTest
    static void TestPartnerKPI1ComponentController(){
        setupData();
        PartnerKPI1ComponentController controller;
        Test.startTest();
        System.runAs(usr){   
            controller = new PartnerKPI1ComponentController();
            controller.accountId = testAccount.Id;
            //controller.platform = 'PureEngage On Premise';
        }  
        Test.stopTest();
    }
    
    @isTest
    static void TestShowCaseDetailsController(){
        setupData();
        
        Test.startTest();
        Test.setCurrentPage(Page.ShowCaseDetails);
        ApexPages.currentPage().getParameters().put('kpiid', kpi1Data[0].id);
        System.runAs(usr){   
            ShowCaseDetailsController controller = new ShowCaseDetailsController();  
        }  
        Test.stopTest();
    }
    
    static void setupData(){
        // Set up data for mandatory config ..
        List<Config__c> conList = new List<Config__c>();
        conList.add(new Config__c(Name = 'CORE_OPP_STAGE_CLOSED_WON', Value__c = 'User Contract'));
        conList.add(new Config__c(Name = 'USER_PARTNER', Value__c = 'PowerPartner'));
        conList.add(new Config__c(Name = 'USER_STANDARD',Value__c =''));
        conList.add(new Config__c(Name = 'CORE_OPP_BP_STATUS_ALLOCATED',Value__c =''));
        conList.add(new Config__c(Name = 'ALE_TEAM_MEMBER_ROLE',Value__c =''));
        conList.add(new Config__c(Name = 'CORE_OPP_BP_STATUS_REJECTED',Value__c =''));
        conList.add(new Config__c(Name = 'CORE_OPP_BP_STATUS_NOT_ALLOCATED',Value__c =''));
        conList.add(new Config__c(Name = 'CORE_OPP_BP_STATUS_APPROVED',Value__c =''));
        conList.add(new Config__c(Name = 'BP_TEAM_MEMBER_ROLE',Value__c =''));
        conList.add(new Config__c(Name = 'TM_MONITOR_AD_EMAIL1',Value__c =''));
        conList.add(new Config__c(Name = 'TM_MONITOR_AD_EMAIL2',Value__c =''));
        conList.add(new Config__c(Name = 'TM_MONITOR_AD_EMAIL3',Value__c =''));
        conList.add(new Config__c(Name = 'TM_VALUE_SEPARATOR',Value__c =''));
        conList.add(new Config__c(Name = 'TM_USER_NAME_TEST1',Value__c =''));
        conList.add(new Config__c(Name = 'TM_USER_NAME_TEST2',Value__c =''));
        conList.add(new Config__c(Name = 'ASSET_DEFAULT_MANUFACTURER',Value__c =''));
        conList.add(new Config__c(Name = 'CORE_OpportunityApprovalProcess',Value__c =''));
        conList.add(new Config__c(Name = 'COREOpportunityRecordType',Value__c ='012U0000000Ldb8'));
        conList.add(new Config__c(Name = 'EMGBusinessPartnerRecordType',Value__c =''));
        conList.add(new Config__c(Name = 'EMGBusinessPartnerOwner',Value__c =''));
        conList.add(new Config__c(Name = 'EMGStatusGetRejected',Value__c =''));
        conList.add(new Config__c(Name = 'RT_RFP_Refused',Value__c =''));
        conList.add(new Config__c(Name = 'RT_RFP_Accepted',Value__c =''));
        conList.add(new Config__c(Name = 'RT_RFP_PROPOSAL_ACCEPTED',Value__c =''));
        conList.add(new Config__c(Name = 'RT_RFP_PROPOSAL_REFUSED',Value__c =''));
        conList.add(new Config__c(Name = 'ACCEPTED_RFP_FORM_TEMPLATE',Value__c =''));
        conList.add(new Config__c(Name = 'REJECTED_RFP_FORM_TEMPLATE',Value__c =''));
        conList.add(new Config__c(Name = 'SUBMIT_RFP_FORM_TEMPLATE',Value__c =''));
        conList.add(new Config__c(Name = 'PENDING_RFP_FORM_TEMPLATE',Value__c =''));
        conList.add(new Config__c(Name = 'INACTIVE_OFFER',Value__c =''));
        conList.add(new Config__c(Name = 'ACTIVE_OFFER',Value__c =''));
        conList.add(new Config__c(Name = 'REGION_EMEA',Value__c =''));
        conList.add(new Config__c(Name = 'BID_PROPOSAL_CONTACT_EMEA',Value__c =''));
        conList.add(new Config__c(Name = 'BID_PROPOSAL_CONTACT_NA',Value__c =''));
        conList.add(new Config__c(Name = 'RFP_QUEUE',Value__c =''));
        conList.add(new Config__c(Name = 'RFP_MAIL',Value__c =''));
        conList.add(new Config__c(Name = 'RT_OQM_Submission',Value__c =''));
        conList.add(new Config__c(Name = 'RT_RFP_Submission',Value__c =''));
        conList.add(new Config__c(Name = 'RT_OQM_PROPOSAL_ACCEPTED',Value__c =''));
        conList.add(new Config__c(Name = 'RT_OQM_PROPOSAL_REFUSED',Value__c =''));
        conList.add(new Config__c(Name = 'OQM_STATUS_PENDING',Value__c =''));
        conList.add(new Config__c(Name = 'OQM_STATUS_SUBMIT',Value__c =''));
        conList.add(new Config__c(Name = 'OQM_STATUS_REJECTED',Value__c =''));
        conList.add(new Config__c(Name = 'OQM_STATUS_ACCEPTED',Value__c =''));
        conList.add(new Config__c(Name = 'OPP_STAGE4',Value__c =''));
        conList.add(new Config__c(Name = 'OPP_STAGE5',Value__c =''));
        conList.add(new Config__c(Name = 'OPP_STAGE6',Value__c =''));
        conList.add(new Config__c(Name = 'OPP_STAGE7',Value__c =''));
        conList.add(new Config__c(Name = 'OPP_STAGE81',Value__c =''));
        conList.add(new Config__c(Name = 'OPP_STAGE82',Value__c =''));
        conList.add(new Config__c(Name = 'OPP_STAGE9',Value__c =''));
        conList.add(new Config__c(Name = 'OPP_STAGE10',Value__c =''));
        conList.add(new Config__c(Name = 'BP_ROLE',Value__c =''));
        conList.add(new Config__c(Name = 'PROFIL_ADMIN_ID',Value__c =''));
        insert conList;
        
        
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1]; 
        
        testAccount = new Account (Name = 'Holding Account',RecordTypeId='012U0000000Le3f', Status__c='Active', 
                                   PartnerType__c = 'Carrier; Direct Reseller; Distributor; Indirect Reseller; NextiraOne; VAD; Specialized Reseller; '
                                   + 'VAR; Service Partner; Consultant; Cloud Partner; Managed Services Provider; Technology Partner; OEM Partner; '
                                   +  'Contract Reseller; Global Strategic Alliance; Cloud Referral Partner; Lead Referral; Support Only; '
                                   + 'Non-Commercial; AppFoundry Partner; Cloud Solution Provider; Cloud Reseller'
                                  );  
        insert testAccount;
        
        testContact = new Contact (AccountId = testAccount.id,FirstName='TestContact',LastName = 'Foss',Designated_Partner_Contact__c = true);
        insert testContact;
        
        usr = new User(profileId = partnerProfile.id,username = 'newUser211@salesforce.com',email = 'pb211@ff.com',
                       emailencodingkey = 'UTF-8',localesidkey = 'en_US',languagelocalekey = 'en_US',
                       timezonesidkey = 'America/Los_Angeles',alias='nuser',lastname='lastname',contactId = testContact.id);
        insert usr;
        
        partnerKPIPeriodsCS = new Partner_KPI_Periods__c (Name = 'Mar-Apr-May 2018', Active__c  = true, Order__c  = 1,
                                                 Period__c = 'Mar-Apr-May 2018', Quarter__c = 1, Date_Opened__c = Date.newInstance(2018, 5, 31),                                          
                                                 Start_Date__c = Date.newInstance(2018, 3, 1), End_Date__c = Date.newInstance(2018, 5, 31),
                                                 Current_Quarter__c = true, Year__c = 2018);
        insert partnerKPIPeriodsCS;
                                                 
        
        
        kpi1Data = new List<Partner_Quarterly_KPI__c>();
        kpi1Data.add(new Partner_Quarterly_KPI__c(Period__c='Mar-Apr-May 2018',Closure_Assessment__c=30,
                                                Training_Assessment__c=30,Quality_Assessment__c=10,Total_KPI_Score__c=70,
                                                Closure_Assessment_YTD__c=10,Quality_Assessment_YTD__c=10,
                                                Training_Assessment_YTD__c=10,Total_YTD_KPI_Score__c=30,
                                                Account__c=testAccount.Id, Platform__c = 'PureEngage On Premise'));
        kpi1Data.add(new Partner_Quarterly_KPI__c(Period__c='Mar-Apr-May 2018',Closure_Assessment__c=30,
                                                Training_Assessment__c=30,Quality_Assessment__c=10,Total_KPI_Score__c=70,
                                                Closure_Assessment_YTD__c=10,Quality_Assessment_YTD__c=10,
                                                Training_Assessment_YTD__c=10,Total_YTD_KPI_Score__c=30,
                                                Account__c=testAccount.Id, Platform__c = 'PureConnect On Premise'));
        insert kpi1Data;
        
        
        kpi1CaseDetais = new List<KPI1_Case_Details__c>();
        for(Integer i = 0; i < 5; i++){
            kpi1CaseDetais.add(new KPI1_Case_Details__c(Case_Number__c = 'C-0001'+i, Contact_Name__c = testContact.FirstName, Product__c = 'Test Product',
                                                        Problem_Description_Clear_and_Detailed__c = 'Yes', Supporting_Info_Provided__c = 'Yes',
                                                        Should_Have_Been_Solved_Using_Docs_KB__c = 'Yes', Case_Logged_by_GU_Certified_Contact__c = 'Yes', 
                                                        Sub_Status_Group__c = 'Sub Status', Platform__c = 'PureEngage On Premise', 
                                                        Account__c=testAccount.Id, Period__c='Mar-Apr-May 2018' ));
        }
        for(Integer i = 5; i < 10; i++){
            kpi1CaseDetais.add(new KPI1_Case_Details__c(Case_Number__c = 'C-0001'+i, Contact_Name__c = testContact.FirstName, Product__c = 'Test Product',
                                                        Problem_Description_Clear_and_Detailed__c = 'Yes', Supporting_Info_Provided__c = 'Yes',
                                                        Should_Have_Been_Solved_Using_Docs_KB__c = 'Yes', Case_Logged_by_GU_Certified_Contact__c = 'Yes', 
                                                        Sub_Status_Group__c = 'Sub Status', Platform__c = 'PureConnect On Premise',
                                                        Account__c=testAccount.Id, Period__c='Mar-Apr-May 2018' ));
        }
        insert kpi1CaseDetais;
    }        
    
}