@isTest
private class clsScheduleUserDeactivationJob_Test {
    
  static testMethod void myUnitTest() {
    Test.startTest();
    
    //List<ObjectListDeactivationUser__c> lstCstSetting = ObjectListDeactivationUser__c.getall().values();
    
    ObjectListDeactivationUser__c objOL = new ObjectListDeactivationUser__c();
    objOL.Object_Name__c = 'Account';
    objOL.Name = 'Account';
    insert objOL;
   
    List<User>list_user2 = testUtil.createUsers(1, false);
    list_user2[0].Email = 'abc@abc.com';
    insert list_user2;
   
    List<User>list_user = testUtil.createUsers(1, false);
    list_user[0].Termination_Date__c = Date.today().adddays(-5);
    list_user[0].Deactivation_Date__c = null;
    list_user[0].Is_Ownership_Changed__c = false;
    list_user[0].ManagerId = list_user2[0].id;
    insert list_user;
    
    system.runas(list_user[0])
    {
        List<Account> lstAcc=TestUtil.createAccounts(1,true);
        
        clsScheduleUserDeactivationJob sh1 = new clsScheduleUserDeactivationJob();  
        sh1.execute(null);
        sh1.finish(null);  
        
        /*clsSchedulePendingUserDeactivationJob sh2 = new clsSchedulePendingUserDeactivationJob();  
        sh2.execute(null);
        sh2.finish(null);  */
             
        //String sch = '0 0 23 * * ?';
        //system.schedule('Test check', sch, sh1);
    }
    Test.stopTest();
  }
  
  static testMethod void myUnitTest2() {
    Test.startTest();
    
    //List<ObjectListDeactivationUser__c> lstCstSetting = ObjectListDeactivationUser__c.getall().values();
    ObjectListDeactivationUser__c objOL = new ObjectListDeactivationUser__c();
    objOL.Object_Name__c = 'Account';
    objOL.Name = 'Account';
    insert objOL;
   
    List<User>list_user2 = testUtil.createUsers(1, false);
    list_user2[0].Email = 'abc@abc.com';
    //insert list_user2;
   
    List<User>list_user = testUtil.createUsers(1, false);
    list_user[0].Termination_Date__c = Date.today().adddays(-5);
    list_user[0].Deactivation_Date__c = null;
    list_user[0].Is_Ownership_Changed__c = false;
    list_user[0].ManagerId = list_user2[0].id;
    insert list_user;
    
    system.runas(list_user[0])
    {
        List<Account> lstAcc=TestUtil.createAccounts(1,true);
        
        clsScheduleUserDeactivationJob sh1 = new clsScheduleUserDeactivationJob();  
        sh1.execute(null);
        sh1.finish(null);  

    }
    Test.stopTest();
  }
}