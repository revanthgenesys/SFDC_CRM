trigger PushCampaignOnCloudSync on Lead (after update) 
{
    
    if(!PushCampaignMembers.isScheduled)
    {
        if(trigger.isUpdate && trigger.isAfter)
        {
            Set<ID> syncedLeadIds = new Set<Id>();
            
            for(Lead l : trigger.new)
            {
                if(trigger.oldMap.get(l.Id).Cloud_Connect_Sync__c!=trigger.newMap.get(l.Id).Cloud_Connect_Sync__c
                   && trigger.newMap.get(l.Id).Cloud_Connect_Sync__c)
                {
                    syncedLeadIds.add(l.Id);
                }
            }
            
            System.debug('=====> Synced Lead Ids = '+syncedLeadIds.size());
            
            if(syncedLeadIds.size()>0)
            {
                PushCampaignMembers m = new PushCampaignMembers(syncedLeadIds);
                String sch = '';
                DateTime d = System.now().addMinutes(5);
                sch += d.second() + ' ' + d.minute() + ' ' + d.hour() + ' ' + d.day() + ' ' + d.month() + ' ' + '?' + ' ' + d.year();
                
                system.schedule('Push Campaign'+sch, sch, m);
                PushCampaignMembers.isScheduled = true;
            }
        }
    }
}