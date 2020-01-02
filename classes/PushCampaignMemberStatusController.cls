/***********************************************************************************************
 * Class Name   : PushCampaignMemberStatusController
 * Author       : Sornanathan (ClearTask)
 * Created Date : 04/02/2013
 * Version      : 1.0
 * Description  : A controller class for Sync Campaign member status VF page which will sync the campaign member stauses on click of a button 
 **********************************************************************************************/
public without sharing class PushCampaignMemberStatusController 
{
    Cloud_Connect_Configuration__c cc = Cloud_Connect_Configuration__c.getOrgDefaults();
    String campaignsRestUrl = cc.Campaign_Member_Status_URL__c;
    String JSONC;
    List<Database.UpsertResult> upsertResult;
    String campaignId;
    Boolean isError;
    
    public PushCampaignMemberStatusController(Apexpages.StandardController controller)
    {
        List<CampaignMemberStatus> statuses = new List<CampaignMemberStatus>();
        campaignId = ApexPages.currentPage().getParameters().get('id');
        statuses = [Select CampaignId, Label, IsDefault, Id, HasResponded from CampaignMemberStatus where CampaignId = :campaignId]; 
        isError = false;
        
        try
        {
            if(statuses.size()>0)
            {
                JSONC = JSON.serialize(statuses);
                
                System.debug('-----> JSON Campaign Member Status Request: '+JSONC);
                
                RESTAPICallsToCloudConnect.authenticate();
                upsertResult = RESTAPICallsToCloudConnect.upsertCall(JSONC,campaignsRestUrl);
                System.debug('-----> Upsert Result: '+upsertResult);
            }
        }
        catch(Exception e)
        {
            isError = true;
            Apexpages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Campaign Member Status could not be synced with Cloud Connect due to an unexpected issue.'));
        }
    }
    
    public PageReference returnBack()
    {
        if(!isError)
            return new PageReference('/'+campaignId);
        else
            return null;
    }
}