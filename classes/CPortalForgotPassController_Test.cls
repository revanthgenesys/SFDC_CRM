@isTest
public class CPortalForgotPassController_Test {
  
   static testMethod void tst() {
    TestUtil.setConfigValues();
      List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
        System.runAs(runAsUser[0]) {
            TestUtil.setCaseSupportTypesSettings();
        }
         
        Profile usrProfile = [SELECT id FROM Profile WHERE Name = 'Consultant Portal Manager Custom' LIMIT 1];       
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        User testUser;
       
        testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', usrProfile.id, false);  
        testUser.username = 'testUser132@test132.com.test';
        testUser.isActive = true;
        testUser.ContactId = testContact.id;
        insert testUser;
        
        Test.startTest();       
        System.runAs(testUser){
          CPortalForgotPassCommunityController fpssw1 = new CPortalForgotPassCommunityController();         
          fpssw1.username = testUser.username;
          fpssw1.forgotPassword();
          System.assertNotEquals(null, fpssw1.messg);
          
          CPortalForgotPassCommunityController fpssw2 = new CPortalForgotPassCommunityController();         
          fpssw2.username = '';
          fpssw2.forgotPassword();
          System.assertNotEquals(null, fpssw1.messg);
          
          CPortalForgotPassCommunityController fpssw3 = new CPortalForgotPassCommunityController();         
          fpssw3.username = 'Invalid';
          fpssw3.forgotPassword();
          System.assertNotEquals(null, fpssw3.messg);          
        }
        
        Test.stopTest();
   }
}