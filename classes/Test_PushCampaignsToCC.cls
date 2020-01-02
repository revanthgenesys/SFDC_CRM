/***********************************************************************************************
 * Class Name   : Test_PushCampaignsToCC
 * Author       : Sornanathan (ClearTask)
 * Created Date : 04/02/2013
 * Version      : 1.0
 * Description  : Test class to push the campaigns to cloud connect
 **********************************************************************************************/
 
@isTest
public class Test_PushCampaignsToCC
{
    public static List<Campaign> testCreateCampaigns(Integer cnt, String marketingGroup)
    {
        List<Campaign> campaigns = new List<Campaign>();
        Campaign c;
        
        for(Integer i=0;i<cnt;i++)
        {
            c = new Campaign(Name='Test Campaign'+i, 
                             isActive=true, StartDate=System.Today(), EndDate=System.Today(), 
                             Region__c='North America');
            c.Marketing_Group__c = marketingGroup;
            
            campaigns.add(c);
        }
        
        if(campaigns.size() > 0)
        {
            insert campaigns;
        }
        
        return campaigns;
    }
    
    private static testMethod void Test_PushCampaigns_Insert()
    {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CCHttpResponseGenerator());
        
        List<Campaign> campaigns = testCreateCampaigns(2,'Cloud Connect');
        
        Test.stopTest();
    }
    
    private static testMethod void Test_PushCampaigns_Update()
    {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CCHttpResponseGenerator());
        
        List<Campaign> campaigns = testCreateCampaigns(2,'Channel Marketing');
        System.debug('------> Insert Completed');
        
        CCHttpResponseGenerator.countofRestCalls = 0;
        
        campaigns[0].Marketing_Group__c = 'Cloud Connect';
        campaigns[1].Marketing_Group__c = 'Cloud Connect';
        update campaigns;
        
        Test.stopTest();
    }
    
    private static testMethod void Test_PushCampaignStatuses_Insert()
    {
        List<Campaign> campaigns = testCreateCampaigns(2,'Cloud Connect');
        
        CampaignMemberStatus c = new CampaignMemberStatus(CampaignId=campaigns[0].Id, Label='Sent', isDefault=true, SortOrder=1, HasResponded=true);
        insert c;
        
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CCHttpResponseGenerator());
        
        Test.setCurrentPage(Page.Sync_Campaign_Member_Status);
        ApexPages.currentPage().getParameters().put('id',campaigns[0].Id);
        PushCampaignMemberStatusController controller = new PushCampaignMemberStatusController (new ApexPages.standardController(campaigns[0]));
        controller.returnBack();
        
        Test.stopTest();
    }
    
    public static testMethod void Test_failedCampaignsBatch()
    {
    	PushCampaignsToCloudConnect.isExecutedCampaign = true;
    	List<Campaign> campaigns = testCreateCampaigns(2,'Cloud Connect');
    	campaigns[0].Cloud_Connect_Failed__c = true; 
    	campaigns[0].Cloud_connect_Failed_Reason__c = 'Test Method';
    	campaigns[1].Cloud_Connect_Failed__c = true; 
    	campaigns[1].Cloud_connect_Failed_Reason__c = 'Test Method';
    	update campaigns;
    	
    	Test.startTest();
    	
    	Test.setMock(HttpCalloutMock.class, new CCHttpResponseGenerator());
    	
    	String sch = '';
        DateTime d = System.now().addMinutes(1);
        sch += d.second() + ' ' + d.minute() + ' ' + d.hour() + ' ' + d.day() + ' ' + d.month() + ' ' + '?' + ' ' + d.year();
        
        system.schedule('Push Failed Campaigns', sch, new PushFailedCampaignsScheduler());
        
        Test.stopTest();
    }
}