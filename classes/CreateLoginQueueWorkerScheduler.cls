/* This class originated from the ININ environment.  Originally created by Heather Geesaman */
global class CreateLoginQueueWorkerScheduler implements Schedulable
{
    // See https://www.salesforce.com/us/developer/docs/apexcode/Content/apex_batch_interface.htm
    // for information about scheduling batch Apex.
    // 
    // Schedule this class by executing the following line of code through the execute anonymous window:
    // CreateLoginQueueWorkerScheduler.setSchedule();
    global final String query = 'SELECT Id, ContactId__c, Result__c, IsProcessed__c, IsError__c FROM CreateLoginQueue__c WHERE IsProcessed__c = false AND CreatedDate <: batachableTime AND isDeleted = false ORDER BY CreatedDate DESC';
    global static string ScheduleJobName;
    
    global static string setSchedule() {
        if(ScheduleJobName == null)
        {
            ScheduleJobName = 'Create Login Job';
        }
        // Schedules the job for every hour at :00 - This one is used in the test class so jobId is needed.        
    string jobId = system.schedule(ScheduleJobName + ' 1', '0 0 * * * ?', new CreateLoginQueueWorkerScheduler());
        // Schedules the job for every hour at :15
        system.schedule(ScheduleJobName + ' 2', '0 15 * * * ?', new CreateLoginQueueWorkerScheduler());
        // Schedules the job for every hour at :30
        system.schedule(ScheduleJobName + ' 3', '0 30 * * * ?', new CreateLoginQueueWorkerScheduler());
        // Schedules the job for every hour at :45
        system.schedule(ScheduleJobName + ' 4', '0 45 * * * ?', new CreateLoginQueueWorkerScheduler());   
        
        return jobId;
    }
    
    global static string setSchedule(string jobName) {
        ScheduleJobName = jobName;
        String jobId = setSchedule();
        return jobId;
    }
    
    global void execute(SchedulableContext sc)
    {        
        CreateLoginQueueWorker worker = new CreateLoginQueueWorker(query);
        // Process only 2 contacts in each batch
        Database.executeBatch(worker, 2);        
    }
}