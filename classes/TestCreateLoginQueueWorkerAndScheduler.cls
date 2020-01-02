/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
@isTest
public class TestCreateLoginQueueWorkerAndScheduler{

    public static String CRON_EXP = '0 0 * * * ?'; 
    public static DateTime currentTime = DateTime.now();
    
    public static testMethod void TestSetSchedule() 
    {        
        Test.startTest();
        
        String jobId = CreateLoginQueueWorkerScheduler.setSchedule('Test Job');
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        System.debug('Set CronExp Format: ' + CRON_EXP + ' and Expr on CronTrigger: ' + ct.CronExpression);
        // Verify the expressions are the same
        System.assertEquals(CRON_EXP, 
                            ct.CronExpression);
        
        System.debug('Number of times the Job is triggered?: ' + ct.TimesTriggered);
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        
        System.debug('NextFireTime: ' + ct.NextFireTime);
        
        // Verify the scheduled job hasn't run yet.
        CreateLoginQueue__c[] cl = [SELECT Id FROM CreateLoginQueue__c];
        System.debug('CreateLoginQueue size before the Job has run: ' + cl.size());  
        System.assertEquals(cl.size(),0);
        
        //Insert a record into CreateLoginQueue__c table so that the batch job can pick it up 
        TestAccountContext context = new TestAccountContext();       
        TestServicesReadyContactsContext.createLoginQueueEntry(context.partContact1);  
        
        Id partnerContactId = context.partContact1.Id;        
    System.debug('Partner Contact for which Create Login Job will be Queued: ' + partnerContactId);        
        
        Test.stopTest();

        // Now that the scheduled job has executed after Test.stopTest(),
        //   fetch the new CreateLoginQueue record that got added.
        cl = [SELECT Id FROM CreateLoginQueue__c ];
        system.debug('While the Job runs, it will pick up ' + cl.size() + ' record');
        System.assertEquals(cl.size(), 1);        
    }  
    
    public static testMethod void TestWorkerBatch()
    {
        Datetime now = DateTime.now();
        Datetime batachableTime =  now;
        String query = 'SELECT Id, ContactId__c, Result__c, IsProcessed__c, IsError__c FROM CreateLoginQueue__c'; 
        
        //Insert a record into CreateLoginQueue__c table so that the batch job can pick it up        
        TestAccountContext context = new TestAccountContext();       
        TestServicesReadyContactsContext.createLoginQueueEntry(context.partContact1);  
        
        Id partnerContactId = context.partContact1.Id;        
    System.debug('Partner Contact for which Create Login Job will be Queued: ' + partnerContactId);        
        
        Test.startTest();
        CreateLoginQueueWorker c = new CreateLoginQueueWorker(query);
        system.debug('CreateLoginQueue record grabbed for the batch process: ' + c);
        Id batchJobId = Database.executeBatch(c);
        system.debug('Database Batch JOb created with Id: ' + batchJobId);
        Test.stopTest();
        
        //   fetch the new CreateLoginQueue record that should have been processed by now.
        CreateLoginQueue__c[] cl = [SELECT Id FROM CreateLoginQueue__c 
              WHERE CreatedDate >=: currentTime AND IsProcessed__c = true];
            system.debug('The number of records processed by the batch job: ' + cl.size());
            System.assertEquals(1, cl.size()); 
            system.debug('CreateLoginQueue after batch: ' + cl[0]);
    } 
}