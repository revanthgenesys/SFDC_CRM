@isTest
private class PerformanceGraphControllerTest{
    
    static Config__c configData(String name,String value){
        
        Config__c config = new Config__c();
        config.Name = name;
        config.Value__c = value;
        return config;
    }
    
     static Partner_KPI_Periods__c  kpiPeriods(String name,Boolean isActive,Integer order,String period, 
                                               Date startDate, Date endDate, Boolean isCurrent,Integer year
                                              ){
        
        Partner_KPI_Periods__c  kpiPeriod = new Partner_KPI_Periods__c ();
        kpiPeriod.Name = name;
        kpiPeriod.Active__c  = isActive;
        kpiPeriod.Order__c  = order;
        kpiPeriod.Period__c = period;
    kpiPeriod.Start_Date__c = startDate;
        kpiPeriod.End_Date__c = endDate;
        kpiPeriod.Current_Quarter__c = isCurrent;  
        kpiPeriod.Year__c = year;
        return kpiPeriod;
    }
    
    public static Account testAccount;
    public static Contact testContact;
    public static User usr; 
    public static List<Partner_Rebate__c> rebateData;
    public static Partner_Quarterly_KPI__c kpi1Data;
    
    @isTest
    static void TestPerformanceGraphController(){
        setupData();
        Test.startTest();
        PerformanceGraphController controller;
        System.runAs(usr){   
            controller = new PerformanceGraphController();
            controller.getRevenueChart();
            //controller.getKPI1Chart();
    
            controller = new PerformanceGraphController();
            PerformanceGraphController.currencySymbol('USD');
            PerformanceGraphController.currencySymbol('AUD');
            PerformanceGraphController.currencySymbol('BRL');
            PerformanceGraphController.currencySymbol('CAD');
            PerformanceGraphController.currencySymbol('EUR');
            PerformanceGraphController.currencySymbol('GBP');
            PerformanceGraphController.currencySymbol('JPY');
            PerformanceGraphController.currencySymbol('INR');
            PerformanceGraphController.currencySymbol('KRW');
            PerformanceGraphController.currencySymbol('EGP');
            PerformanceGraphController.currencySymbol('SGD');
            
            controller.getRevenueChart();
            controller.getRevenue();
            controller.getRevenueYears();
            controller.getRebate();
            controller.getRebateYears();
            //controller.getKPI1Chart();
            //controller.getKPI1();
            //controller.getKPI1Periods();
            //controller.getKPI2();
            //controller.getKPI2Periods();
            
            controller.selectedCCBDPeriod = 'May/Jun/Jul '+Date.today().year();
            controller.refreshCCBD();
            PerformanceGraphController.CCBDGaugeData ccdbdData = new PerformanceGraphController.CCBDGaugeData('Test', 10, 20);
            
            //rebate.Published_to_Partner_Portal__c = true;
            rebateData[0].Partner_Designated_Contact__c = usr.ContactId;
            update rebateData[0];
            
            //controller = new PerformanceGraphController();
            controller.getRebate();
            controller.getRebateYears();
            controller.convertCurrencyToSpecDate(1000.00,'USD','EUR',date.today());
            controller.getdatedCurrencies(); 
            controller.getFiscalYears();
            controller.getPureCloudChart();
            controller.getpartnerDiscount();
            controller.getpureCldMargins();
        Test.stopTest();
        }
    }
    
    @isTest
    static void TestShowCaseDetailsController(){
        setupData();
        PageReference pageRef = Page.ShowCaseDetails;
        pageRef.getParameters().put('kpiid', kpi1Data.id);
        pageRef.getParameters().put('quarter', 'Jan/Feb '+Date.today().year());
        Test.setCurrentPage(pageRef);
        
        ShowCaseDetailsController controller;
         System.runAs(usr){  
          controller = new ShowCaseDetailsController();
        }
    }
    
    public static void setupData(){
         Util.Bypass_Trigger_Chk = true;
    List<Partner_KPI_Periods__c> kpi1PeriodList = new List<Partner_KPI_Periods__c>();
        kpi1PeriodList.add(kpiPeriods('Jan/Feb '+Date.today().year(),true,1,'Jan/Feb '+Date.today().year(), Date.newInstance(Date.today().year(),1,1),Date.newInstance(Date.today().year(),2,28),false,2014));
        insert kpi1PeriodList; 
        
        list<global_setting__c> glgSetLst = new list<global_setting__c>();
        Global_setting__c perfDashb = new Global_setting__c(Name='Performance Dash 2019',Information__c='2019,2020,2021,2022,2023,2024,2025');
        Global_setting__c optyRecTp = new Global_setting__c(Name='GEN - Opportunity Record Type',Information__c='RecordType',ID__c='012U0000000LrBP',Type__c='Opportunity');
        Global_setting__c cldBknTp = new Global_setting__c(Name='Cloud Booking Type',
                                                            Information__c='PureConnect Cloud,PureConnect Premise Subscription,PureConnect Premise Rental,PureConnect Cloud Partner PPU,PureEngage Cloud,PureEngage Premise Subscription,PureEngage Premise Rental,PureEngage Cloud Partner PPU,PureCloud',
                                                            ID__c='Cloud');
        Global_setting__c LicBkTp = new Global_setting__c(Name='License Booking Type',Information__c='PureConnect Premise,PureEngage Premise',ID__c='License');
        Global_setting__c RevTpTN = new Global_setting__c(Name='Revenue Types 2019 Dash',Information__c='Revenue - Cloud,Revenue - License,Total');
        glgSetLst.add(perfDashb);
        glgSetLst.add(optyRecTp);
        glgSetLst.add(cldBknTp);
        glgSetLst.add(LicBkTp);
        glgSetLst.add(RevTpTN);
        insert glgSetLst; 
        
        List<Config__c> conList = new List<Config__c>();
      conList.add(configData('CORE_OPP_STAGE_CLOSED_WON','User Contract'));
        conList.add(configData('USER_PARTNER','PowerPartner'));
        conList.add(configData('USER_STANDARD',''));
        conList.add(configData('CORE_OPP_BP_STATUS_ALLOCATED',''));
        conList.add(configData('ALE_TEAM_MEMBER_ROLE',''));
        conList.add(configData('CORE_OPP_BP_STATUS_REJECTED',''));
        conList.add(configData('CORE_OPP_BP_STATUS_NOT_ALLOCATED',''));
        conList.add(configData('CORE_OPP_BP_STATUS_APPROVED',''));
        conList.add(configData('BP_TEAM_MEMBER_ROLE',''));
        conList.add(configData('TM_MONITOR_AD_EMAIL1',''));
        conList.add(configData('TM_MONITOR_AD_EMAIL2',''));
        conList.add(configData('TM_MONITOR_AD_EMAIL3',''));
        conList.add(configData('TM_VALUE_SEPARATOR',''));
        conList.add(configData('TM_USER_NAME_TEST1',''));
        conList.add(configData('TM_USER_NAME_TEST2',''));
        conList.add(configData('ASSET_DEFAULT_MANUFACTURER',''));
        conList.add(configData('CORE_OpportunityApprovalProcess',''));
        conList.add(configData('COREOpportunityRecordType','012U0000000Ldb8'));
        conList.add(configData('EMGBusinessPartnerRecordType',''));
        conList.add(configData('EMGBusinessPartnerOwner',''));
        conList.add(configData('EMGStatusGetRejected',''));
        conList.add(configData('RT_RFP_Refused',''));
        conList.add(configData('RT_RFP_Accepted',''));
        conList.add(configData('RT_RFP_PROPOSAL_ACCEPTED',''));
        conList.add(configData('RT_RFP_PROPOSAL_REFUSED',''));
        conList.add(configData('ACCEPTED_RFP_FORM_TEMPLATE',''));
        conList.add(configData('REJECTED_RFP_FORM_TEMPLATE',''));
        conList.add(configData('SUBMIT_RFP_FORM_TEMPLATE',''));
        conList.add(configData('PENDING_RFP_FORM_TEMPLATE',''));
        conList.add(configData('INACTIVE_OFFER',''));
        conList.add(configData('ACTIVE_OFFER',''));
        conList.add(configData('REGION_EMEA',''));
        conList.add(configData('BID_PROPOSAL_CONTACT_EMEA',''));
        conList.add(configData('BID_PROPOSAL_CONTACT_NA',''));
        conList.add(configData('RFP_QUEUE',''));
        conList.add(configData('RFP_MAIL',''));
        conList.add(configData('RT_OQM_Submission',''));
        conList.add(configData('RT_RFP_Submission',''));
        conList.add(configData('RT_OQM_PROPOSAL_ACCEPTED',''));
        conList.add(configData('RT_OQM_PROPOSAL_REFUSED',''));
        conList.add(configData('OQM_STATUS_PENDING',''));
        conList.add(configData('OQM_STATUS_SUBMIT',''));
        conList.add(configData('OQM_STATUS_REJECTED',''));
        conList.add(configData('OQM_STATUS_ACCEPTED',''));
        conList.add(configData('OPP_STAGE4',''));
        conList.add(configData('OPP_STAGE5',''));
        conList.add(configData('OPP_STAGE6',''));
        conList.add(configData('OPP_STAGE7',''));
        conList.add(configData('OPP_STAGE81',''));
        conList.add(configData('OPP_STAGE82',''));
        conList.add(configData('OPP_STAGE9',''));
        conList.add(configData('OPP_STAGE10',''));
        conList.add(configData('BP_ROLE',''));
        conList.add(configData('PROFIL_ADMIN_ID',''));
       insert conList;        
        
    List<Partner_Revenue_Mapping__c> partnerRevenueMapping = new List<Partner_Revenue_Mapping__c>();
        partnerRevenueMapping.add(new Partner_Revenue_Mapping__c(Name='SaaS',Revenue_Type__c ='Revenue - Soundbite,Revenue - PPU,Revenue - Angel,Revenue - Managed Hosted,Revenue - Platform on Demand,Revenue – Echopass'));
        partnerRevenueMapping.add(new Partner_Revenue_Mapping__c(Name='Professional Services',Revenue_Type__c = 'Revenue - PS'));
        partnerRevenueMapping.add(new Partner_Revenue_Mapping__c(Name='Maintenance',Revenue_Type__c = 'Revenue - Maintenance'));
        partnerRevenueMapping.add(new Partner_Revenue_Mapping__c(Name='License',Revenue_Type__c = 'Revenue - License'));
        partnerRevenueMapping.add(new Partner_Revenue_Mapping__c(Name='Education',Revenue_Type__c = 'Revenue - Education'));
    insert partnerRevenueMapping;    
        
        
    Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1]; 
        
        testAccount = new Account (Name = 'Holding Account',RecordTypeId='012U0000000Le3f', Status__c='Active', Partner_Offering_Type__c = 'PureCloud',
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
        
        //NPS Dashbaord
    List<Survey_Response__c> surveyResponseList = new List<Survey_Response__c>();
        surveyResponseList.add(new Survey_Response__c(Survey_Type__c = 'Relationship',Partner_Account__c = testAccount.Id, NPS_Recommend_Rating__c  = '9'));
        surveyResponseList.add(new Survey_Response__c(Survey_Type__c = 'Relationship',Partner_Account__c = testAccount.Id, NPS_Recommend_Rating__c  = '6'));
        surveyResponseList.add(new Survey_Response__c(Survey_Type__c = 'Relationship',Partner_Account__c = testAccount.Id, NPS_Recommend_Rating__c  = '7'));
        insert surveyResponseList;
        
        list<Partner_Revenue_Reporting__c> revCS = new list<Partner_Revenue_Reporting__c>();
        revCS.add(new Partner_Revenue_Reporting__c(Name='Revenue - Education'));
        revCS.add(new Partner_Revenue_Reporting__c(Name='Revenue - Cloud'));
        insert revCS;
        
        Partner_MLB_Target_Data__c mlbData = new Partner_MLB_Target_Data__c(MLB_Year__c=''+Date.today().year(),MLB__c=1234,
                                                                            Region__c = usr.Contact.Account.TM_Acc_Country_Region__c,
                                                                            Tier__c = usr.Contact.Account.Partner_Tier__c, Account__c = testAccount.Id); 
        insert mlbData;
        
        
        
        List<Partner_EndUser_Data__c> revenueData = new List<Partner_EndUser_Data__c>();
        
         revenueData.add(new Partner_EndUser_Data__c(Quarter__c='C'+Date.today().year()+' Q2',Revenue_Type__c='Revenue - Education',
                                                                        Revenue_Year__c='2018', Revenue_Amount__c=2000,Account__c=testAccount.Id,Offering_Type__c='pureEngage'));
        revenueData.add(new Partner_EndUser_Data__c(Quarter__c='C'+Date.today().year()+' Q2',Revenue_Type__c='Revenue - Education',
                                                                        Revenue_Year__c='2017', Revenue_Amount__c=4000,Account__c=testAccount.Id,Offering_Type__c='pureConnect'));
        
        revenueData.add(new Partner_EndUser_Data__c(Quarter__c='C'+Date.today().year()+' Q2',Revenue_Type__c='Revenue - Cloud',
                                                                        Revenue_Year__c='2018', Revenue_Amount__c=4000,Account__c=testAccount.Id,Offering_Type__c='pureCloud'));
                                                                        
        revenueData.add(new Partner_EndUser_Data__c(Quarter__c='C'+Date.today().year()+' Q2',Revenue_Type__c='Revenue - Cloud',
                                                                        Revenue_Year__c='2018', Revenue_Amount__c=7000,Account__c=testAccount.Id,Offering_Type__c='pureCloud'));

        revenueData.add(new Partner_EndUser_Data__c(Quarter__c='C'+Date.today().year()+' Q2',Revenue_Type__c='Revenue - Cloud Partner',
                                                                        Revenue_Year__c='2018', Revenue_Amount__c=7000,Account__c=testAccount.Id,Offering_Type__c='pureCloud'));
                                                                        
        insert revenueData;
            
        rebateData = new List<Partner_Rebate__c>();
        rebateData.add(new Partner_Rebate__c(Rebate_Name__c='Test Rebate',Rebate_Year__c=''+Date.today().year(),Start_Date__c=Date.today().addDays(-30),
                                                            End_Date__c=Date.today().addDays(30),Earned_Genesys_Care_Amount__c=100,
                                                            Earned_License_Amount__c=200,Earned_SaaS_Amount__c=100,
                                                            Amount__c=100,License_Amount__c=100,SaaS_Amount__c=100,
                                                            Agree_Disagree_Flag__c=true,Published_to_Partner_Portal__c = false,
                                                            Partner_Name__c= testAccount.Id));
       
        rebateData.add(new Partner_Rebate__c(Rebate_Name__c='Test Rebate',Rebate_Year__c='2015',Start_Date__c=Date.today().addDays(-30),
                                                            End_Date__c=Date.today().addDays(30),Earned_Genesys_Care_Amount__c=100,
                                                            Earned_License_Amount__c=200,Earned_SaaS_Amount__c=100,
                                                            Amount__c=100,License_Amount__c=100,SaaS_Amount__c=100,
                                                            Agree_Disagree_Flag__c=true,Published_to_Partner_Portal__c = true,
                                                            Partner_Name__c= testAccount.Id));
        insert rebateData;

        kpi1Data = new Partner_Quarterly_KPI__c(Period__c='Jan/Feb '+Date.today().year(),Closure_Assessment__c=30,
                                                    Training_Assessment__c=30,Quality_Assessment__c=10,Total_KPI_Score__c=70,
                                                    Closure_Assessment_YTD__c=10,Quality_Assessment_YTD__c=10,
                                                    Training_Assessment_YTD__c=10,Total_YTD_KPI_Score__c=30,Account__c=testAccount.Id);
        insert kpi1Data;
        
        Partner_KPI2__c kpi2Data = new Partner_KPI2__c(Period__c='Jan/Feb '+Date.today().year(),KPI_2_On_Time__c=20, Total_YTD_KPI_Score__c=100,
                                                            Account_Name__c='Holding Account',Sum_of_PO_s_Not_On_Time__c=20,
                                                            Sum_of_PO_s_On_Time__c=100,Total_PO_s__c=100,Account__c=testAccount.Id);
        insert kpi2Data;
        
        Partner_KPI2_PO_Details__c kpi2PO = new Partner_KPI2_PO_Details__c(End_User_Name__c='VoicePort, LLC',
                                                                                Maintenance_End_Date__c=Date.Today(),
                                                                                PO_Date__c=Date.Today(),
                                                                                PO_Number__c ='13092',Account__c =testAccount.Id,
                                                                                Period__c ='Jan/Feb '+Date.today().year());
        insert kpi2PO;
    
        
        //Cases closed by default 
        
        List<Cases_Closed_By_Default_Header__c> ccbdHeaders = new List<Cases_Closed_By_Default_Header__c>(); 
         ccbdHeaders.add(new Cases_Closed_By_Default_Header__c(Partner_Account__c = testAccount.Id, Account_Name__c = testAccount.Name, Period__c = 'Feb/Mar/Apr '+Date.today().year(), Closed_By_Default__c = 2, YTD_Closed_By_Default__c = 2));
         ccbdHeaders.add(new Cases_Closed_By_Default_Header__c(Partner_Account__c = testAccount.Id, Account_Name__c = testAccount.Name, Period__c = 'May/Jun/Jul '+Date.today().year(), Closed_By_Default__c = 3, YTD_Closed_By_Default__c = 5));
        insert ccbdHeaders;
        
        List<Cases_Closed_By_Default_Detail__c> ccbdDetails = new List<Cases_Closed_By_Default_Detail__c>(); 
        ccbdDetails.add(new Cases_Closed_By_Default_Detail__c(Partner_Account__c = testAccount.Id, Period__c = 'Feb/Mar/Apr '+Date.today().year(), Case_Number__c = '0000001', Contact_Name__c = 'Rao Tumma', Case_Owner__c = 'Narasimha Tumma'));
        ccbdDetails.add(new Cases_Closed_By_Default_Detail__c(Partner_Account__c = testAccount.Id, Period__c = 'Feb/Mar/Apr '+Date.today().year(), Case_Number__c = '0000002', Contact_Name__c = 'Rao Tumma', Case_Owner__c = 'Narasimha Tumma'));
        ccbdDetails.add(new Cases_Closed_By_Default_Detail__c(Partner_Account__c = testAccount.Id, Period__c = 'May/Jun/Jul '+Date.today().year(), Case_Number__c = '0000003', Contact_Name__c = 'Rao Tumma', Case_Owner__c = 'Narasimha Tumma'));
        ccbdDetails.add(new Cases_Closed_By_Default_Detail__c(Partner_Account__c = testAccount.Id, Period__c = 'May/Jun/Jul '+Date.today().year(), Case_Number__c = '0000004', Contact_Name__c = 'Rao Tumma', Case_Owner__c = 'Narasimha Tumma'));
        ccbdDetails.add(new Cases_Closed_By_Default_Detail__c(Partner_Account__c = testAccount.Id, Period__c = 'May/Jun/Jul '+Date.today().year(), Case_Number__c = '0000005', Contact_Name__c = 'Rao Tumma', Case_Owner__c = 'Narasimha Tumma'));
        insert ccbdDetails;
        
        
    String[] accountPartnerTypes = testAccount.PartnerType__c.split('; ');
        List<Portal_Manager_Roles__c> partnerManagerRoles = new List<Portal_Manager_Roles__c>();
        for(String pType : accountPartnerTypes){
      partnerManagerRoles.add(new Portal_Manager_Roles__c(Name = pType, Baseline_Pricing__c = true,  Gdemo__c = true, GU_Discount__c = true,
                                GU_Training__c = true, KPI_s__c = true,  Lab_Software__c = true, Lead_Referral__c = true,
                                MLB__c = true, NPS__c = true, Online_Directory__c = true, Oppty_Reg__c = true, 
                                                                Portal_Access__c = true, Program_Guide__c = true, PS_Discount__c = true, 
                                                                Rebate__c = true, Revenue_Reporting__c = true, RFP_Tool__c = true, Sales_U_Training__c = true));
      partnerManagerRoles.add(new Portal_Manager_Roles__c(Name = pType+'_designated', Baseline_Pricing__c = true,  Gdemo__c = true, GU_Discount__c = true,
                                GU_Training__c = true, KPI_s__c = true,  Lab_Software__c = true, Lead_Referral__c = true,
                                MLB__c = true, NPS__c = true, Online_Directory__c = true, Oppty_Reg__c = true, 
                                                                Portal_Access__c = true, Program_Guide__c = true, PS_Discount__c = true, 
                                                                Rebate__c = true, Revenue_Reporting__c = true, RFP_Tool__c = true, Sales_U_Training__c = true));
            
        }
    insert partnerManagerRoles;
    list<Opportunity> testOpp1 = TestUtil.createOpportunities(3, testAccount.id, false);
    testOpp1[0].Closedate = date.newinstance(2018, 2, 17);
    testOpp1[0].Lines_of_Businesses__c='PureCloud';
    testOpp1[0].BusinessPartner__c = testAccount.id;
    testOpp1[0].Win_Loss_Status__c = 'Won';
    testOpp1[0].RecordTypeId = '012U0000000LrBP';
    
    testOpp1[1].Closedate = date.newinstance(2019, 2, 18);
    testOpp1[1].StageName = '6.Closed';
    testOpp1[1].Win_Loss_Status__c = 'Won';
    testOpp1[1].RecordTypeId = '012U0000000LrBP';
    testOpp1[1].BusinessPartner__c = testAccount.id;
    testOpp1[1].Lead_Offer__c = 'PureConnect Premise';
    
    testOpp1[2].Closedate = date.newinstance(2019, 2, 18);
    testOpp1[2].StageName = '6.Closed';
    testOpp1[2].Win_Loss_Status__c = 'Won';
    testOpp1[2].RecordTypeId = '012U0000000LrBP';
    testOpp1[2].BusinessPartner__c = testAccount.id;
    testOpp1[2].Lead_Offer__c = 'PureConnect Cloud';
    
    insert testOpp1;
    
    
    PureCloud_Yearly_Bookings_Requirement__c tierMinTst = new PureCloud_Yearly_Bookings_Requirement__c(Year__c='2018',Tier_Minimum__c=450000,CurrencyIsoCode='EUR',Partner__c=testAccount.Id);
    insert tierMinTst;
    }

    
    /*static testmethod void convertCurrencyToSpecDateTest(){
        Test.startTest();
            PerformanceGraphController perfCtrl = new PerformanceGraphController();
            perfCtrl.convertCurrencyToSpecDate(1000.00,'USD','EUR',date.today());
            perfCtrl.getdatedCurrencies();
        Test.stopTest();
    }*/
}