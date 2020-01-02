trigger PushCampaignMemberToCloudConnect on CampaignMember (after insert, after update) 
{
    PushCampaignsToCloudConnect.isExecutedCampaign = true;
    if(!PushCampaignsToCloudConnect.isExecutedCampaignMember)
    {
        Set<Id> syncedMemberIds = new Set<Id>(); 
        Set<Id> unsyncedMemberIds = new Set<Id>();
        Boolean isUpdate = false; 
        
        Map<Id,CampaignMember> memberWithLeadCampaignInfo = new Map<Id,CampaignMember>(
                                                            [Select Id, LeadId, CampaignId, Lead.Cloud_Connect_Sync__c, Campaign.Marketing_Group__c 
                                                             from CampaignMember where Id in :trigger.newMap.keyset()]);
        
        if(trigger.isInsert && trigger.isAfter)
        {
            for(CampaignMember cm : trigger.new)
            {
                if(//cm.Status=='Responded' && 
                   memberWithLeadCampaignInfo.get(cm.Id).Lead.Cloud_Connect_Sync__c 
                   && memberWithLeadCampaignInfo.get(cm.Id).Campaign.Marketing_Group__c == 'Cloud Connect')
                {
                    unsyncedMemberIds.add(cm.Id);
                }
            }
        }
        
        if(trigger.isUpdate && trigger.isAfter)
        {
            isUpdate = true;
            for(CampaignMember cm : trigger.new)
            {
                if(//trigger.oldMap.get(cm.Id).Status != trigger.newMap.get(cm.Id).Status && 
                   //cm.Status=='Responded' && 
                   memberWithLeadCampaignInfo.get(cm.Id).Lead.Cloud_Connect_Sync__c 
                   && memberWithLeadCampaignInfo.get(cm.Id).Campaign.Marketing_Group__c == 'Cloud Connect')
                {
                    if(cm.Sent_to_Cloud_Connect__c)
                    {
                        syncedMemberIds.add(cm.Id);
                    }
                    else
                    {
                        unsyncedMemberIds.add(cm.Id);
                    }
                }
            }
        }
        
        if(unsyncedMemberIds.size()>0 || syncedMemberIds.size()>0)
        {
            PushCampaignsToCloudConnect.pushCampaignMembersFuture(unsyncedMemberIds,syncedMemberIds);
            PushCampaignsToCloudConnect.isExecutedCampaignMember = true;
        }
    }
}