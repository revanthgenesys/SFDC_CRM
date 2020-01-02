@isTest
public class ConsumeServiceTriggerHandler_Test{
  
  
  static testMethod void testConsumarService(){
      
        
        
        List<Account> lstAnt = TestUtil.createAccounts(2, true);
        
        
        
        Pure_Success_Package__c pureSuccessPack = new Pure_Success_Package__c();
        pureSuccessPack.Account__c = lstAnt[0].Id;
        insert pureSuccessPack;
        
        Consume_Service__C comSerObj = new Consume_Service__C();
        //comSerObj.Service_Element__c = packSer.id;
        comSerObj.Status__c = 'Open';
        insert comSerObj;
      
        Consume_Service__C comSerObj2 = new Consume_Service__C();
        //comSerObj.Service_Element__c = packSer.id;
        comSerObj2.Status__c = 'Open';
        insert comSerObj2;  
      
        Package_Services__c packSer = new Package_Services__c(); 
        packSer.PureSuccess_Package__c = pureSuccessPack.Id;
        packSer.Status__c = 'Available';
        packSer.Consume_Service__c = comSerObj.Id;
        insert packSer;
        
              
        
      
        Map<ID,Consume_Service__C> oldComSerMap= new Map<ID,Consume_Service__C>();
        oldComSerMap.put(comSerObj.Id,comSerObj);
        oldComSerMap.put(comSerObj2.Id,comSerObj2);
      
        comSerObj.Status__c = 'Closed';
        update comSerObj;
        
        Map<ID,Consume_Service__C> newComSerMap= new Map<ID,Consume_Service__C>();
        newComSerMap.put(comSerObj.Id,comSerObj);
        newComSerMap.put(comSerObj2.Id,comSerObj2);
      
        Test.startTest();
        ConsumeServiceTriggerHandler.afterStatusClosedUpdatePkgSrv(newComSerMap,oldComSerMap);
        //ConsumeServiceTriggerHandler.updateServiceElementStatus();
        Test.stopTest();
        
        
            
          
      }
    
    static testMethod void testConsumarService2(){
      
        
        
        List<Account> lstAnt = TestUtil.createAccounts(2, true);
        
        
        
        Pure_Success_Package__c pureSuccessPack = new Pure_Success_Package__c();
        pureSuccessPack.Account__c = lstAnt[0].Id;
        insert pureSuccessPack;
        
        Package_Services__c packSer = new Package_Services__c(); 
        packSer.PureSuccess_Package__c = pureSuccessPack.Id;
        packSer.Status__c = 'Available';
        insert packSer;
        
        Consume_Service__C comSerObj = new Consume_Service__C();
        comSerObj.Service_Element__c = packSer.id;
        comSerObj.Status__c = 'Open';
        insert comSerObj;
        
        Map<ID,Consume_Service__C> oldComSerMap= new Map<ID,Consume_Service__C>();
        oldComSerMap.put(comSerObj.Id,comSerObj);
      
        comSerObj.Status__c = 'Cancelled';
        update comSerObj;
        
        
        Map<ID,Consume_Service__C> newComSerMap= new Map<ID,Consume_Service__C>();
        newComSerMap.put(comSerObj.Id,comSerObj);
        
      
        Test.startTest();
        //ConsumeServiceTriggerHandler.afterStatusClosedUpdatePkgSrv();
        ConsumeServiceTriggerHandler.updateServiceElementStatus(oldComSerMap,newComSerMap);
        Test.stopTest();
        
        
            
          
      }
      
     
   
    
}