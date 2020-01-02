@isTest
private class Test_BatchSurveySendToSolariat {
    
    static testmethod void testRespSurvey1() {
    
       TestUtil.setConfigValues();
		Util.Bypass_Trigger_Chk = true;
		
        SOLARIAT_Connect_Configuration__c custConf = new SOLARIAT_Connect_Configuration__c (
                            Name = 'SOLARIAT_Connect_Configuration',
                            Notify_On_Errors__c = 'msteason@genesys.com',   
                            Post_URL__c = 'http://111.111.111',   
                            Token_URL__c = 'http://111.111.111',    
                            User_Name__c = 'usename',  
                            Password__c = 'passw',    
                            Channels__c = 'channels',
                            Api_Key__c = 'key'
                            );
         
        insert custConf;
    
        Survey_Response__c sr = new Survey_Response__c(Verbatim__c = 'verbatim',
                                                       NPS_Rating__c = '9');
        insert sr;
        
        System.Test.startTest();
            Test.setMock(HttpCalloutMock.class, new Test_BatchSurveySolariatHttpResponseMock());
            Test_BatchSurveySolariatHttpResponseMock.returnType = 'Token';
            
            BatchSurveysSendToSolariat batch1 = new BatchSurveysSendToSolariat();
            Database.executeBatch(batch1, 5);
        System.Test.stopTest(); 
        
        Survey_Response__c res = [SELECT Solariat_Response__c FROM Survey_Response__c WHERE ID = :sr.Id];
        system.assertEquals(res.Solariat_Response__c, 'Processed');         
        
    }
    static testmethod void testRespSurvey2() {
        
       TestUtil.setConfigValues();
		Util.Bypass_Trigger_Chk = true;
		
        SOLARIAT_Connect_Configuration__c custConf = new SOLARIAT_Connect_Configuration__c (
                            Name = 'SOLARIAT_Connect_Configuration',
                            Notify_On_Errors__c = 'msteason@genesys.com',   
                            Post_URL__c = 'http://111.111.111',   
                            Token_URL__c = 'http://111.111.111',    
                            User_Name__c = 'usename',  
                            Password__c = 'passw',    
                            Channels__c = 'channels',
                            Api_Key__c = 'key'
                            );
         
        insert custConf;
    
        Survey_Response__c sr = new Survey_Response__c(Verbatim__c = 'verbatim',
                                                       NPS_Rating__c = '3');
        insert sr;
        
        System.Test.startTest();
    
            Test.setMock(HttpCalloutMock.class, new Test_BatchSurveySolariatHttpResponseMock());
            Test_BatchSurveySolariatHttpResponseMock.returnType = 'Error';
            
            BatchSurveysSendToSolariat batch2 = new BatchSurveysSendToSolariat();
            Database.executeBatch(batch2, 5);
        System.Test.stopTest(); 
        
        Survey_Response__c res = [SELECT Solariat_Response__c FROM Survey_Response__c WHERE ID = :sr.Id];
        system.assertEquals(res.Solariat_Response__c, null);        
        
    }
}