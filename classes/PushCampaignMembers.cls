/***********************************************************************************************
 * Class Name   : PushCampaignMembers
 * Author       : Sornanathan (ClearTask)
 * Created Date : 04/02/2013
 * Version      : 1.0
 * Description  : A schedular to push campaign members to cloud connect when a lead is synced with cloud connect
 **********************************************************************************************/
 
global without sharing class PushCampaignMembers implements Schedulable
{
    Set<Id> leadIds;
    
    public static Boolean isScheduled = false;
    
    public PushCampaignMembers(Set<Id> leadIdSet)
    {
        leadIds = leadIdSet;
    }
    
    global void execute(SchedulableContext SC) 
    {
        PushCampaignsToCloudConnect.pushCampaignMembersFromLeadFuture(leadIds,SC.getTriggerId());
    }
}