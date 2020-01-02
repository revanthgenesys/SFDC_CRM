/***********************************************************************************************
 * Class Name   : PushFailedCampaignsScheduler
 * Author       : Sornanathan (ClearTask)
 * Created Date : 04/02/2013
 * Version      : 1.0
 * Description  : This is to schedule the batch which will push the failed campaigns to cloud connect
 **********************************************************************************************/
 
global without sharing class PushFailedCampaignsScheduler implements Schedulable
{
	global void execute(SchedulableContext SC) 
    {
        PushFailedCampaignsBatch batchObj = new PushFailedCampaignsBatch();
        database.executeBatch(batchObj);
    }
}