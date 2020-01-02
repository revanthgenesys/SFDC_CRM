/***********************************************************************************************
 * Class Name   : PushFailedCampaignMembersBatch
 * Author       : Sornanathan (ClearTask)
 * Created Date : 04/02/2013
 * Version      : 1.0
 * Description  : When a campaign member is failed to sync with cloud connect use this class to sync again after fixing errors if any.
 **********************************************************************************************/
 
global without sharing class PushFailedCampaignMembersBatch implements Database.Batchable<sObject>, Database.AllowsCallouts
{
    public String queryStr;
    
    global PushFailedCampaignMembersBatch()
    {
		queryStr = 'Select Id, Sent_to_Cloud_Connect__c from CampaignMember where Cloud_Connect_Failed__c = true';
   	}

   	global Database.QueryLocator start(Database.BatchableContext BC)
   	{
      	return Database.getQueryLocator(queryStr);
   	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope)
   	{
		Set<Id> syncedMemberIds = new Set<Id>(); 
        Set<Id> unsyncedMemberIds = new Set<Id>();
		
		for(SObject s : scope)
		{
			System.debug('----->'+s);
			if(String.valueOf(s.get('Sent_to_Cloud_Connect__c'))=='True')
            {
                syncedMemberIds.add(Id.valueOf(String.valueOf(s.get('id'))));
            }
            else
            {
                unsyncedMemberIds.add(Id.valueOf(String.valueOf(s.get('id'))));
            }
		}
		
		PushCampaignsToCloudConnect.pushCampaignMembers(unsyncedMemberIds,syncedMemberIds);
        PushCampaignsToCloudConnect.isExecutedCampaignMember = true;
    }

   	global void finish(Database.BatchableContext BC)
   	{
   		
   	}
}