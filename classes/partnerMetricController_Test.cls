@isTest(seeAllData=true)
private class partnerMetricController_Test{
    static testMethod void myUnitTest() {
        Test.startTest();
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];       
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Partner_EndUser_Data__c pendData = new Partner_EndUser_Data__c();
        pendData.Customer__c = testAccount.Name;
        insert pendData;
        
        Partner_Quarterly_KPI__c partKPI1 = new Partner_Quarterly_KPI__c ();
        partKPI1.Account_Name__c = testAccount.Name;
        insert partKPI1;
        
        Partner_KPI2__c partKPI2 = new Partner_KPI2__c();
        partKPI2.Account_Name__c = testAccount.Name;
        insert partKPI2;

        
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        System.currentPageReference().getParameters().put('id', testAccount.id);
       
        User testUser;
        Test.stopTest();
        testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', partnerProfile.id, false);        
        testUser.ContactId = testContact.id;
        insert testUser;
        
        Partner_Certifications__c patCert = new Partner_Certifications__c();
        patCert.email__c = testUser.email;
        insert patCert;
                
        System.runAs(testUser){
            partnerMetricController obj = new partnerMetricController();
            obj.init();
        }
    }
}