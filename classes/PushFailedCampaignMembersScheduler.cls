/***********************************************************************************************
 * Class Name   : PushFailedCampaignMembersScheduler
 * Author       : Sornanathan (ClearTask)
 * Created Date : 04/02/2013
 * Version      : 1.0
 * Description  : This is to schedule the batch which will push the failed campaign members to cloud connect
 **********************************************************************************************/
 
global without sharing class PushFailedCampaignMembersScheduler implements Schedulable
{
	global void execute(SchedulableContext SC) 
    {
        PushFailedCampaignMembersBatch batchObj = new PushFailedCampaignMembersBatch();
        database.executeBatch(batchObj);
    }
}