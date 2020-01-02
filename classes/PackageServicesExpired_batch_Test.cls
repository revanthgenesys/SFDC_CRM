@isTest
public class PackageServicesExpired_batch_Test {
   
    @isTest
    static void testPackageServicesExpiredbatch(){
    Auto_number__c am = new Auto_number__c();
    am.name='start';
    am.values__c=1;
    insert am;
    
    Account acc = new Account( Name='Test Account', Status__c = 'Active' );   
     insert acc;
    Order__c ord = new Order__c();
    ord.Name = 'test';
    //ord.CurrencyIsoCode = 'test';
    ord.Date_Accepted__c = (system.now()).addDays(-1000);
    insert ord;
     System.debug('order.... ' +ord.Date_Accepted__c);
    Pure_Success_Package__c ps1 = new Pure_Success_Package__c();
    ps1.Order__c =ord.id;
    ps1.Account__c = acc.id;
    insert ps1;
    
    
    Package_Services__c ps = new Package_Services__c();
    ps.Name ='testing';
    ps.Order__c =ord.id;
    ps.Status__c ='Allocated';
    ps.PureSuccess_Package__c = ps1.id;
    insert ps;
         
         // Invoke batch Job to process Usage Data
        Test.startTest();
      PackageServicesExpired_batch bsu = new PackageServicesExpired_batch();
      String sch = '0 0 23 * * ?';
      system.schedule('Test Territory Check', sch, bsu);
      PackageServicesExpired_batch objBatch = new PackageServicesExpired_batch();
      Database.executeBatch(objBatch, 200);
      //***when test class is executed the batch limit should be restricted*/
        
        Test.StopTest();
    }

}