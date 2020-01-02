/***********************************************************************************************
 * Class Name   : PushFailedCampaignsBatch
 * Author       : Sornanathan (ClearTask)
 * Created Date : 04/02/2013
 * Version      : 1.0
 * Description  : When a campaign is failed to sync with cloud connect use this class to sync again after fixing errors if any.
 **********************************************************************************************/
 
global without sharing class PushFailedCampaignsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    public String queryStr;
    
    global PushFailedCampaignsBatch()
    {
		queryStr = 'Select Id from Campaign where Cloud_Connect_Failed__c = true';
   	}

   	global Database.QueryLocator start(Database.BatchableContext BC)
   	{
      	return Database.getQueryLocator(queryStr);
   	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope)
   	{
		Set<Id> campaignIds = new Set<Id>();
		
		for(SObject s : scope)
		{
			campaignIds.add(Id.valueOf(String.valueOf(s.get('id'))));
		}
		
		PushCampaignsToCloudConnect.pushCampaigns(campaignIds);
        PushCampaignsToCloudConnect.isExecutedCampaign = true;
    }

   	global void finish(Database.BatchableContext BC)
   	{
   		
   	}
}