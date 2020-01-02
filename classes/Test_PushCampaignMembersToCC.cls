/***********************************************************************************************
 * Class Name   : Test_PushCampaignMembersToCC
 * Author       : Sornanathan (ClearTask)
 * Created Date : 04/02/2013
 * Version      : 1.0
 * Description  : Test class to push the campaign members to cloud connect
 **********************************************************************************************/
 
@isTest
public class Test_PushCampaignMembersToCC
{
	public static List<CampaignMember> createCampaignMembers(List<Lead> leadList,List<Campaign> campaignList)
	{
		List<CampaignMember> cMemberslist = new List<CampaignMember>();
		for(Lead l : leadList)
		{
			for(Campaign c : campaignList)
			{
				cMembersList.add(new CampaignMember(CampaignId=c.Id, LeadId=l.Id, Status='Responded'));
				break;
			}
		}
		
		if(cMembersList.size()>0)
		{
			insert cMembersList;
		}
		
		return cMembersList;
	}
	
	private static testMethod void Test_PushCampaignMembers_Insert()
    {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CCHttpResponseGenerator());
        
        List<Campaign> campaigns = Test_PushCampaignsToCC.testCreateCampaigns(2,'Cloud Connect');
        
        List<Lead> leads = Test_PushCampaignMembersFromLeadToCC.createLeads(2, true);
        
        System.debug('==========>>>>'+CCHttpResponseGenerator.countofrestcalls);
        
        List<CampaignMember> cMemberslist = createCampaignMembers(leads,campaigns);
        
        PushCampaignsToCloudConnect.isExecutedCampaignMember = false;
        
        cMembersList[0].Status = 'Sent';
        update cMembersList[0];
        
        Test.stopTest();
    }
    
    public static testMethod void Test_failedCampaignsBatch()
    {
    	PushCampaignsToCloudConnect.isExecutedCampaignMember = true;
    	
		List<Campaign> campaigns = Test_PushCampaignsToCC.testCreateCampaigns(2,'Cloud Connect');
        
        List<Lead> leads = Test_PushCampaignMembersFromLeadToCC.createLeads(2, true);
        
        List<CampaignMember> cMemberslist = createCampaignMembers(leads,campaigns);
        
        cMemberslist[0].Cloud_Connect_Failed__c = true; 
    	cMemberslist[0].Cloud_connect_Failed_Reason__c = 'Test Method';
    	cMemberslist[1].Cloud_Connect_Failed__c = true; 
    	cMemberslist[1].Cloud_connect_Failed_Reason__c = 'Test Method';
    	update cMemberslist;
    	
    	Test.startTest();
    	
    	Test.setMock(HttpCalloutMock.class, new CCHttpResponseGenerator());
    	
    	String sch = '';
        DateTime d = System.now().addMinutes(1);
        sch += d.second() + ' ' + d.minute() + ' ' + d.hour() + ' ' + d.day() + ' ' + d.month() + ' ' + '?' + ' ' + d.year();
        
        system.schedule('Push Failed Campaign Members', sch, new PushFailedCampaignMembersScheduler());
        
        Test.stopTest();
    }
}