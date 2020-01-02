@isTest(SeeAllData= true)
private class PartnerPortal_PeriodicReview_ClassTest {
    
     static testMethod void myUnitTest1() {
        Test.startTest();
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];       
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        User testUser;
       
        testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);        
        testUser.ContactId = testContact.id;
        insert testUser;       
        Account testChildAccount = TestUtil.createAccounts(1, false)[0];
        testChildAccount.ParentId = testAccount.id;
        insert testChildAccount;
        Partner_Quarterly_KPI__c testQuarterlyKPI = new Partner_Quarterly_KPI__c();
        testQuarterlyKPI.Account_Name__c = testChildAccount.id;
        insert testQuarterlyKPI;
        ApexPages.currentPage().getParameters().put('runAs', testUser.id);
        ApexPages.currentPage().getParameters().put('Id', testAccount.id); 
        System.runAs(testUser){
            PartnerPortal_PeriodicReview_Class obj = new PartnerPortal_PeriodicReview_Class();
            obj.init();
            obj.inCommunity();
        }
         Test.stopTest();
    }
    
    static testMethod void myUnitTest2() {
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];       
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        User testUser;
       
        testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);        
        testUser.ContactId = testContact.id;
        insert testUser;       
        System.runAs(testUser){
        List<Account> testChildAccounts = new List<Account>();        
        Account testChildAccount1 = TestUtil.createAccounts(1, false)[0];
        testChildAccount1.ParentId = testAccount.id;
        testChildAccounts.add(testChildAccount1);
        
        Account testChildAccount2 = TestUtil.createAccounts(1, false)[0];
        testChildAccount2.ParentId = testAccount.id;
        testChildAccounts.add(testChildAccount2);
        insert testChildAccounts;
        List<Partner_Quarterly_KPI__c> testQuarterlyKPIs = new List<Partner_Quarterly_KPI__c>();
        List<Partner_KPI2__c> testPartnerKPI2 = new List<Partner_KPI2__c>();
        Partner_KPI2__c testRecKPI2 = new Partner_KPI2__c(Account_Name__c = testChildAccounts[0].Name,Period__c='testPeriod');
        insert testRecKPI2;    
        Partner_EndUser_Data__c testprtnrEndData = new Partner_EndUser_Data__c(Customer__c = testChildAccounts[0].Name,Revenue_Type__c ='Quarterly',Revenue_Amount__c =12345,SAP_Account_Id__c = 'testSAPId' );
        insert testprtnrEndData;
        Partner_Quarterly_KPI__c testQuarterlyKPI1 = new Partner_Quarterly_KPI__c();
        testQuarterlyKPI1.Account_Name__c = testChildAccounts[0].Name;
        testQuarterlyKPIs.add(testQuarterlyKPI1); 
        
        Partner_Quarterly_KPI__c testQuarterlyKPI2 = new Partner_Quarterly_KPI__c();
        testQuarterlyKPI2.Account_Name__c = testChildAccounts[1].Name;
        testQuarterlyKPIs.add(testQuarterlyKPI2); 
        insert testQuarterlyKPIs;
        
        Partner_Certifications__c prtnrCert = new Partner_Certifications__c(Name='Test Partner Account',Pass_Fail__c = 'P',Email__c = testUser.Email,Account_Name__c = testAccount.Name,Account__c=testAccount.Id,first_Name__c='first',last_name__c='last');
        insert prtnrCert;
        Partner_Training_Info__c prtnrTrngInfo = new Partner_Training_Info__c(Name='Test Partner Training',Email__c = testUser.Email,Account_Name__c = testAccount.Name,Account__c=testAccount.Id,first_Name__c='first',last_name__c='last');
        insert prtnrTrngInfo; 
        Partner_portal_prospect__c prspct = new Partner_Portal_Prospect__c(Account__c = testAccount.id);
        insert prspct;
        Lead_Referral_Registration__c rgstrtn = new Lead_Referral_Registration__c(Account__c = testAccount.id);
        insert rgstrtn;
        Test.startTest();
            PartnerPortal_PeriodicReview_Class obj = new PartnerPortal_PeriodicReview_Class();
            obj.init(); 
            obj.returnPartnerDataList('testSAPId');
            obj.returnPertnerCertList(testUser.Email);
            obj.returnPartneroppList(testAccount.id);
            obj.returnPartnerleadList(testAccount.id);
            obj.returnTotalRevenue('testSAPId');
            obj.getRecordsToDisplay_lead();
            obj.getRecordsToDisplay_opp();
            PartnerPortal_PeriodicReview_Class.eachKPI2Details(testChildAccounts[0].Name,null,'testPeriod');
            PartnerPortal_PeriodicReview_Class.eachTrainDetails('first','last',testAccount.Id);
            PartnerPortal_PeriodicReview_Class.eachCertDetails('first','last',testAccount.Id);
           
        Test.stopTest();    
        }
         
    }
}