@isTest 
private class BatchLMSIntegrationProcessQueue_Test {
    
    static testmethod void tst() {
        TestUtil.setConfigValues();
        Util.Bypass_Trigger_Chk = true;

        Account acc = new Account( Name='Account', Status__c = 'Active');  
        insert acc;   
        
        LMS_Outbound_Msg_Queue__c que = new LMS_Outbound_Msg_Queue__c(Account__c = acc.Id, Status__c='New');
        insert que;
        
        LMS_Integration_Configuration__c custConf = new LMS_Integration_Configuration__c(
            Notify_On_Errors__c = 'tst@tst.com',     
            Endpoint__c = 'https//gen.com',   
            Username__c = 'usr',    
            Password__c = 'psswd'    
        );
        insert custConf;
        
         System.Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Test_BatchSurveySolariatHttpResponseMock());
            Test_BatchSurveySolariatHttpResponseMock.returnType = 'Error';
                   
            BatchLMSIntegrationProcessQueue batch1 = new BatchLMSIntegrationProcessQueue();
            Database.executeBatch(batch1, 5);
          System.Test.stopTest(); 
 
    }
    
    static testmethod void tstschedulable() {
       Test.startTest();
        system.schedule('BatchLMSIntegrationProcessQueueTest','0 0 * * * ?', new BatchLMSIntegrationProcessQueueSchedulbl());
       Test.stopTest();
    }   
}