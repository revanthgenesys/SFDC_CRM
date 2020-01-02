//Naresh Kumar	09/05/2017
@isTest
public class ComplianceExpireBatch_Test {
    
    static testMethod void testMethod1(){
        User testUser = TestUtil.createUsers(1, true)[0];
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        testAcc.ownerId = testUser.id;
        update testAcc;
        
        Export_Screening_Checklist__c testCheckList = new Export_Screening_Checklist__c();
        testCheckList.Checklist_expiration_date__c = System.today().addMonths(1);
        testCheckList.Account__c = testAcc.id;
        insert testCheckList;
        testCheckList.ownerId = testUser.id;
        update testCheckList;
        
        ComplianexpireBatch obj = new ComplianexpireBatch();
        DataBase.executeBatch(obj); 
    }
}