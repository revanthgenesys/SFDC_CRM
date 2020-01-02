trigger CampaignTrigger on Campaign (after insert, after update) 
{
    if(!PushCampaignsToCloudConnect.isExecutedCampaign)
    {
        Set<ID> syncedCampaignIds = new Set<Id>();
        
        if(trigger.isInsert && trigger.isAfter)
        {
            for(Campaign c : trigger.new)
            {
                if(trigger.newMap.get(c.Id).Marketing_Group__c=='Cloud Connect')
                {
                    syncedCampaignIds.add(c.Id);
                }
            }
        }
        
        if(trigger.isUpdate && trigger.isAfter)
        {
            for(Campaign c : trigger.new)
            {
                System.debug(trigger.oldMap.get(c.Id).Cloud_Connect_Failed__c+'<<----->>'+c.Cloud_Connect_Failed__c);
                if(//trigger.oldMap.get(c.Id).Marketing_Group__c!=trigger.newMap.get(c.Id).Marketing_Group__c &&
                   trigger.newMap.get(c.Id).Marketing_Group__c=='Cloud Connect' 
                   && c.Cloud_Connect_Failed__c==trigger.oldMap.get(c.Id).Cloud_Connect_Failed__c
                   && c.Cloud_Connect_Failed_Reason__c==trigger.oldMap.get(c.Id).Cloud_Connect_Failed_Reason__c)
                {
                    syncedCampaignIds.add(c.Id);
                }
            }
        }
        
        System.debug('=====> Synced Campaign Ids = '+syncedCampaignIds.size());
            
        if(syncedCampaignIds.size()>0)
        {
            PushCampaignsToCloudConnect.pushCampaignsFuture(syncedCampaignIds);
            PushCampaignsToCloudConnect.isExecutedCampaign = true;
        }
    }
}