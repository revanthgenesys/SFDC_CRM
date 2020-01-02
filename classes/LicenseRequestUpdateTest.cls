//@isTest (SeeAllData = True)
@isTest
private class LicenseRequestUpdateTest {
   public static void createLogs(){
       List<License_Request_Log__c> logs = new List<License_Request_Log__c>();
       Integer i = 0; 
       for(i=0;i<5;i++)
           logs.add(new License_Request_Log__c(Machine_Name__c='MVICIC001',MAC_Address__c='D65056BA0823',type__c=''));
       
       insert logs;     
   }
    static testmethod void RequestUpdateMethod() {
   /* List<License_Request_Log__c> reqList = [Select Id, Type__c from License_Request_Log__c Limit 1];
    for (License_Request_Log__c l: reqList) {
            l.type__c = '';
    }
    update reqList;
    */
    createLogs();
    Test.startTest();
    LicenseRequestUpdateBatch c = new LicenseRequestUpdateBatch();
    Database.executeBatch(c);
    Test.stopTest();
    
    }
}