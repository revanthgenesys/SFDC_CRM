@isTest(seeAllData=true)
private class PartnerKPIControllerTest {

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
        ApexPages.currentPage().getParameters().put('Id', testAccount.id); 
        System.runAs(testUser){
            PartnerKPIController obj = new PartnerKPIController();
            obj.setIdAccount(testAccount.id);
            obj.getIdAccount();
            obj.inCommunity();
            //Partner_Quarterly_KPI__c = obj.getObjPartnerKPI;  
            //obj.getObjPartnerKPI();
        }
         Test.stopTest();
    }
    
    static testMethod void myUnitTest2() {
        Test.startTest();
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];       
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        User testUser;
       
        testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);        
        testUser.ContactId = testContact.id;
        insert testUser;       
        List<Account> testChildAccounts = new List<Account>();        
        Account testChildAccount1 = TestUtil.createAccounts(1, false)[0];
        testChildAccount1.ParentId = testAccount.id;
        testChildAccounts.add(testChildAccount1);
        
        Account testChildAccount2 = TestUtil.createAccounts(1, false)[0];
        testChildAccount2.ParentId = testAccount.id;
        testChildAccounts.add(testChildAccount2);
        insert testChildAccounts;
        
        List<Partner_Quarterly_KPI__c> testQuarterlyKPIs = new List<Partner_Quarterly_KPI__c>();
        Partner_Quarterly_KPI__c testQuarterlyKPI1 = new Partner_Quarterly_KPI__c();
        testQuarterlyKPI1.Account_Name__c = testChildAccounts[0].id;
        testQuarterlyKPIs.add(testQuarterlyKPI1); 
        Partner_Quarterly_KPI__c testQuarterlyKPI2 = new Partner_Quarterly_KPI__c();
        testQuarterlyKPI2.Account_Name__c = testChildAccounts[1].id;
        testQuarterlyKPIs.add(testQuarterlyKPI2); 
        insert testQuarterlyKPIs;        
        
        ApexPages.currentPage().getParameters().put('runAs', testUser.id);
        System.runAs(testUser){
            PartnerKPIController obj = new PartnerKPIController();
            obj.setIdAccount(testAccount.id);
            obj.getIdAccount();
            
            //Partner_Quarterly_KPI__c = obj.getObjPartnerKPI;  
            //obj.getObjPartnerKPI();
        }
         Test.stopTest();
    }
    
}