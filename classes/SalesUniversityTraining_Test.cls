@isTest(SeeAllData=true)
public class SalesUniversityTraining_Test{
  
   static testMethod void testSalesUList() {
       
      Profile testProfile = [SELECT id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];                 
      User testUser = TestCommon.createUser('testU', 'testUser132@test132.com.test', 'Test', 'Test', testProfile.id, false);        
      insert testUser;
            
      System.runAs(testUser){
        SalesUniversityTraining cnt = new SalesUniversityTraining();
        cnt.getUnivTraining();
      }
   }
}