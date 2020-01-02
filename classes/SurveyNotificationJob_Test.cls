@isTest 
private class SurveyNotificationJob_Test {
    
    static testmethod void testSrvNotification() {
        
        TestUtil.setConfigValues();
        List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        update runAsUser[0];
       
        System.runAs(runAsUser[0]) {
            TestUtil.setConfigValues();
        }
        
        Survey_Notification_Settings__c notifSettings = new Survey_Notification_Settings__c (
                Name = 'Survey Notification Settings',
                APAC__c = 'test@t.com',
                EMEA__c = 'test@t.com',
                LATAM__c = 'test@t.com',
                North_America__c = 'test@t.com',
                Always_Copy__c = 'test@t.com'   
                 );          
        insert notifSettings;
        
        Account accnt = TestUtil.createAccounts(1, true)[0];

        Survey_Response__c sr2 = new Survey_Response__c(Verbatim__c = 'verbatim',
                                                       NPS_Rating__c = '8',
                                                       Account__c = accnt.Id,
                                                       Survey_Type__c = 'Relationship');
        insert sr2;
        
       Test.StartTest();
         SurveyNotificationJob batch = new SurveyNotificationJob();
         Database.executeBatch(batch, 10);
       Test.StopTest();
       
       List<Survey_Response__c> lst = [SELECT Id, NPS_Notification_Sent__c FROM Survey_Response__c];
      // System.assertNotEquals(null, lst[0].NPS_Notification_Sent__c);

    }
    
    public static String CRON_EXP = '0 0 0 15 3 ? 2025';
    static testMethod void testSchedulable() {      
        String jobId = System.schedule('ScheduleClassTest',
                        CRON_EXP, 
                        new SurveyNotificationJobSchedulable());
                        
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                                  NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
    }
    
}