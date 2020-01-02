@isTest
public class ForgotPasswordCommunityController_Test {
  
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
         
      Profile usrProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal End User' LIMIT 1];       
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
        User testUser;
       
        testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', usrProfile.id, false);  
        testUser.username = '123Name@123test.com';
        testUser.isActive = true;
        testUser.ContactId = testContact.id;
        insert testUser;
        
        Test.startTest();       
        System.runAs(testUser){
          ForgotPasswordCommunityController fpssw1 = new ForgotPasswordCommunityController();         
          fpssw1.username = testUser.EMail;
          fpssw1.forgotPassword();
          System.assertNotEquals(null, fpssw1.messg);
          
          ForgotPasswordCommunityController fpssw2 = new ForgotPasswordCommunityController();         
          fpssw2.username = '';
          fpssw2.forgotPassword();
          System.assertNotEquals(null, fpssw1.messg);
          
          ForgotPasswordCommunityController fpssw3 = new ForgotPasswordCommunityController();         
          fpssw3.username = 'Invalid';
          fpssw3.forgotPassword();
          System.assertNotEquals(null, fpssw3.messg);          
        }
        
        Test.stopTest();
   }
  
  static testMethod void testForgotPasswordPartnerController() {
        Test.startTest();
        PageReference pageRef = Page.ForgotPasswordPartner;
        Test.setCurrentPage(pageRef);
      	List<PermissionSetAssignment> listOfAssignment = [SELECT id, AssigneeId, Assignee.UserName, Assignee.Email FROM PermissionSetAssignment WHERE PermissionSetId = '0PSU00000004qr5OAA' AND Assignee.IsActive = true LIMIT 1];
      	if(!listOfAssignment.isEmpty()){
        	String uName = listOfAssignment[0].Assignee.Email;
            pageRef.getParameters().put('uName',uName);
            ForgotPasswordPartnerController fppc = new ForgotPasswordPartnerController();
                fppc.userName = '';
                PageReference pg = fppc.forgotPassword();
        
                fppc.userName = 'user@dummy.com';
                pg = fppc.forgotPassword();
                
                fppc.userName =  UserInfo.getUserName();
                pg = fppc.forgotPassword();
                
                fppc.userName = uName;
                pg = fppc.forgotPassword();
                
                String pwd = ForgotPasswordPartnerController.getPassword(10);
      }
        Test.stopTest();    
    }
}