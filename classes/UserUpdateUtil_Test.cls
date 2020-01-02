/*
  Sivarajan Dhandapani  04/08/2015
  Test class for the util class 'UserUpdateUtil'.
*/
@isTest(seeAllData = true)

public class UserUpdateUtil_Test {

    static testMethod void addToPublicGroupTest() {
      Account testAccount = TestUtil.createAccounts(1, false)[0];
      RecordType rt = [select Id from RecordType where Name = 'Enterprise - Business Partner'];
      Country__c Ctry = [select Id, Region__c from Country__c where Name = 'United States'];
      testAccount.Country__c = Ctry.Id;
      testAccount.recordTypeId = rt.Id;
      testAccount.Status__c = 'Active';
      testAccount.Account_Status__c = 'Active';  
      testAccount.Partner_Program_Status__c = 'Active';
      testAccount.Partner_Tier__c = 'Bronze';
      testAccount.PartnerType__c = 'VAR;Specialized Reseller;Cloud Reseller;Managed Services Provider;Contract Reseller';  
      insert testAccount;
      
      Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
      Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Partner Community Login New' LIMIT 1];
      Profile potenPartnerProfile = [SELECT id FROM Profile WHERE Name = 'Custom Potential Partner User' LIMIT 1];
          
          
      User testUser1 = [SELECT id FROM User WHERE Profile.Name LIKE '%System Admin%' AND isActive = true LIMIT 1];
      User testUser;
      
      System.runAs(testUser1){
      Test.startTest();
      testUser = TestCommon.createUser('t024', 'testGenUser024@test132.com.test', 'testGenUserfname024', 'testGenUserlname024', partnerProfile.id, false);      
      testUser.ContactId = testContact.id;
      insert testUser;
      testUser.isActive = false;
      update testUser;   
      Test.stopTest();    
      } 
      
  }

  static testMethod void updateContactFlagTest() {
      Account testAccount = TestUtil.createAccounts(1, false)[0];
      testAccount.Partner_Program_Status__c = 'Active';
      RecordType rt = [select Id from RecordType where Name = 'Enterprise - Business Partner'];
      Country__c Ctry = [select Id, Region__c from Country__c where Name = 'United States'];
      testAccount.Country__c = Ctry.Id;
      testAccount.recordTypeId = rt.Id;
      testAccount.Status__c = 'Active';
      testAccount.Account_Status__c = 'Active';  
      testAccount.Partner_Program_Status__c = 'Active';
      testAccount.Partner_Tier__c = 'Bronze';
      testAccount.PartnerType__c = 'VAR;Specialized Reseller;Cloud Reseller;Managed Services Provider;Contract Reseller';  
      insert testAccount;
      
      Contact testContact = TestUtil.createContacts(1, testAccount, true)[0];
      Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Partner Community Login New' LIMIT 1];
      Profile potenPartnerProfile = [SELECT id FROM Profile WHERE Name = 'Custom Potential Partner User' LIMIT 1];
          
          
      User testUser1 = [SELECT id FROM User WHERE Profile.Name LIKE '%System Admin%' AND isActive = true LIMIT 1];
      User testUser;
      
      System.runAs(testUser1){
      Test.startTest();
      testUser = TestCommon.createUser('t0233', 'testGenUser0233@test132.com.test', 'testGenUserfname0233', 'testGenUserlname0233', partnerProfile.id, false);      
      testUser.ContactId = testContact.id;
      insert testUser;
      testUser.ProfileId = potenPartnerProfile.Id;
      update testUser; 
      Test.stopTest();    
      } 
    }
    
  static testmethod void updateGenieFieldsOnAccountUpdTest() {
      Test.StartTest();
      user currUser = [Select Id,Name from User where Id=:userinfo.getUserId()];
      Account testAccount = new Account();
      Contact testContact = new contact();
    
        testAccount = TestUtil.createAccounts(1, false)[0];
        testAccount.Partner_Program_Status__c = 'Active';
        RecordType rt = [select Id from RecordType where Name = 'Enterprise - Business Partner'];
        Country__c Ctry = [select Id, Region__c from Country__c where Name = 'United States'];
        testAccount.Country__c = Ctry.Id;
        testAccount.recordTypeId = rt.Id;
        testAccount.Status__c = 'Active';
        testAccount.Account_Status__c = 'Active';  
        testAccount.Partner_Program_Status__c = 'Active';
        testAccount.Partner_Tier__c = 'Bronze';
        testAccount.PartnerType__c = 'VAR;Specialized Reseller;Cloud Reseller;Managed Services Provider;Contract Reseller'; 
        testAccount.PM_Control__c = false; 
        insert testAccount;

      testContact = TestUtil.createContacts(1, testAccount, true)[0];

    User runningUsr = [Select Id from User where Profile.Name = 'General User Access Group SU' and isActive = true limit 1];
    User testUser1;
    System.runAs(runningUsr){
    Profile partnerProfile = [SELECT id FROM Profile WHERE Name = 'Genesys Portal Partner' LIMIT 1];
        
    
    testUser1 = new User(ProfileId=partnerProfile.Id,Username='test1@testerGen.com',Alias='testtest',email='testing@test.com',EmailEncodingKey='UTF-8',
                            Firstname='Test',Lastname='King',LanguageLocaleKey='en_US',LocaleSidKey='en_US',TimeZoneSidKey='America/Los_Angeles',isActive=true,
                            ContactId=testContact.Id);
    insert testUser1;
    System.Debug('testUser1.Usertype--->'+testUser1.Usertype);
    }
 
      testAccount.Partner_Tier__c='Gold';
      update testAccount;

      //User runningUsr = [Select Id from User where Profile.Name = 'General User Access Group SU' and isActive = true limit 1];
      System.runAs(runningUsr){
          testUser1.isActive = false;
          update testUser1;
      }
      testAccount.PM_Control__c = true;
      update testAccount;

      Test.stopTest();    
    }
}