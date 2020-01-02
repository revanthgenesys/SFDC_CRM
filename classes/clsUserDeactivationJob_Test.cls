@isTest(SeeAllData=true)
private class clsUserDeactivationJob_Test {
  
    static testMethod void myUnitTest() {
      
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    
    User objUser = new User(Alias = 'newUser', Email='newuser6789@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='newuser6789@testorg.com',isActive=true);
    insert objUser;
    
    User objUser2 = new User(Alias = 'newU', Email='newuser67@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='newuser67@testorg.com',ManagerId = objUser.id,Termination_Date__c = Date.today().adddays(-7),isActive=true);
    insert objUser2;
      
     System.runAs(objUser2)
     {
        test.StartTest();
        List<Account> accListToInsert=  TestUtil.createAccounts(3, false);
        accListToInsert[0].name='new test accountt';  
        accListToInsert[1].name='new test accountt1'; 
        accListToInsert[2].name='new test accountt2';        
        insert accListToInsert;
        
        List<Contact> conListToInsert=  TestUtil.createContacts(1,accListToInsert[0] ,false);
      
        insert conListToInsert;
        
        test.StopTest();
      }

      
       List<ObjectListDeactivationUser__c> lstCstSetting = ObjectListDeactivationUser__c.getall().values();
       
       clsUserDeactivationJob  obj = new clsUserDeactivationJob(objUser2.id,lstCstSetting);
       Database.executebatch(obj,1);  
       
       //clsPendingUserDeactivationJob obj2 = new clsPendingUserDeactivationJob(objUser2.id,lstCstSetting);
       //Database.executebatch(obj2,1);
        
    }
    
   static testMethod void myUnitTest2() {
      
    Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
    
    User objUser = new User(Alias = 'newUser', Email='newuser6789@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='newuser6789@testorg.com',isActive=true);
    insert objUser;
    
    User objUser2 = new User(Alias = 'newU', Email='newuser67@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='newuser67@testorg.com',Termination_Date__c = Date.today().adddays(-7),isActive=true);
    insert objUser2;
      
     System.runAs(objUser2)
     {
        test.StartTest();
        List<Account> accListToInsert=  TestUtil.createAccounts(3, false);
        accListToInsert[0].name='new test accountt';  
        accListToInsert[1].name='new test accountt1'; 
        accListToInsert[2].name='new test accountt2';        
        insert accListToInsert;
        
        List<Contact> conListToInsert=  TestUtil.createContacts(1,accListToInsert[0] ,false);
        //conListToInsert[0].name='new test accountt';  
        insert conListToInsert;
        
        test.StopTest();
      }

      
       List<ObjectListDeactivationUser__c> lstCstSetting = ObjectListDeactivationUser__c.getall().values();
       
       clsUserDeactivationJob  obj = new clsUserDeactivationJob(objUser2.id,lstCstSetting);
       Database.executebatch(obj,1);  
       
       //clsPendingUserDeactivationJob obj2 = new clsPendingUserDeactivationJob(objUser2.id,lstCstSetting);
       //Database.executebatch(obj2,1);
        
    }
}