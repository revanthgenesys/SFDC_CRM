//Naresh Kumar  08/13/2017
@isTest(seeAllData = false)
private class NewOpportunityExtension_Test {
    static testMethod void myUnitTest() {
        Test.startTest();
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];       
        
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        insert testAccount;        
        Contact testContact = TestUtil.createContacts(1, testAccount, false)[0];
        testContact.Designated_Partner_Contact__c = true;
        testContact.Business_Consulting_Approved__c = true;
        testContact.SEO_Beta_Program__c = true;
        testContact.G_PS_Approved__c = true;
        insert testContact;
        
        User testUser;
        Test.stopTest();
        testUser = TestCommon.createUser('testU', 'testUser139@test139.com.test', 'Test', 'Test', partnerProfile.id, false);        
        testUser.ContactId = testContact.id;
        testUser.UserPermissionsSFContentUser=true;
        testUser.Bypass_Triggers__c = true;
        insert testUser;
        
        recordtype rt = [Select Id,Name,developername from recordtype where developername = 'GEN_Opportunity_Record_Type_New' limit 1];
        
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.BusinessPartner__c = testAccount.id;
        testOpp.recordtypeid = rt.Id;        
        insert testOpp;
        
        Account testAccount1 = TestUtil.createAccounts(1, true)[0];
        System.runAs(testUser){    
            NewOpportunityExtension objExt = new NewOpportunityExtension(new ApexPages.StandardController(new Opportunity()));
            objExt.objOpp.CloseDate = System.today().addDays(50);
            objExt.objOpp.Name = 'Test Opp';
            objExt.objOpp.StageName = '1.Understand Needs';
            objExt.objOpp.AccountId = testAccount1.id;            
            objExt.next1();            
            //objExt.next2();            
        }
    }
    static testMethod void myUnitTest2() {
        Test.startTest();
        Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];       
        
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        insert testAccount;        
        Contact testContact = TestUtil.createContacts(1, testAccount, false)[0];
        testContact.Designated_Partner_Contact__c = true;
        testContact.Business_Consulting_Approved__c = true;
        testContact.SEO_Beta_Program__c = true;
        testContact.G_PS_Approved__c = true;
        insert testContact;
        
        User testUser;
        Test.stopTest();
        testUser = TestCommon.createUser('testU', 'testUser139@test139.com.test', 'Test', 'Test', partnerProfile.id, false);        
        testUser.ContactId = testContact.id;
        testUser.UserPermissionsSFContentUser=true;
        testUser.Bypass_Triggers__c = true;
        insert testUser;
        
        recordtype rt = [Select Id,Name,developername from recordtype where developername = 'GEN_Opportunity_Record_Type_New' limit 1];
        
        /*Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.BusinessPartner__c = testAccount.id;
        testOpp.recordtypeid = rt.Id;        
        insert testOpp;*/
        
        Account testAccount1 = TestUtil.createAccounts(1, true)[0];
        System.runAs(testUser){    
            NewOpportunityExtension objExt = new NewOpportunityExtension(new ApexPages.StandardController(new Opportunity()));
            objExt.objOpp.CloseDate = System.today().addDays(50);
            objExt.objOpp.Name = 'Test Opp';
            objExt.objOpp.Type = 'Existing Business - Expansion';
            objExt.objOpp.StageName = '1.Understand Needs';
            objExt.objOpp.AccountId = testAccount1.id;            
            objExt.next1();            
            //objExt.next2();            
        }
    }
}