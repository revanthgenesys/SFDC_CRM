/***********************************************************************************************
 * Class Name   : Test_PushCampaignMembersFromLeadToCC
 * Author       : Sornanathan (ClearTask)
 * Created Date : 04/02/2013
 * Version      : 1.0
 * Description  : Test class to test the campaign members push to cloud connect from Lead
 **********************************************************************************************/
 
@isTest
public class Test_PushCampaignMembersFromLeadToCC
{
	public static List<Lead> createLeads(Integer cnt, Boolean isCloudConnect)
	{
		List<Lead> leadList = new List<Lead>();
		
		Country__c c = new Country__c(Name='United States of America',Country__c='United States of America');
		insert c;
		
		for(Integer i=0;i<cnt;i++)
		{
			leadList.add(new Lead(FirstName='Test', LastName='Lead'+i, Status='Inquiry', Company='Test Company', Cloud_Connect_Sync__c=isCloudConnect,Country__c=c.Id));
		}
		
		if(leadList.size()>0)
		{
			insert leadList;
		}
		
		return leadList;
	}
	
	private static testMethod void Test_PushCampaignMembersFromLead_Insert()
    {
        Test.startTest();
        
        Test.setMock(HttpCalloutMock.class, new CCHttpResponseGenerator());
        
        List<Campaign> campaigns = Test_PushCampaignsToCC.testCreateCampaigns(2,'Cloud Connect');
        
        List<Lead> leads = createLeads(2, false);
        
        List<CampaignMember> cMemberslist = Test_PushCampaignMembersToCC.createCampaignMembers(leads,campaigns);
        
        leads[0].Cloud_Connect_Sync__c = true;
        leads[1].Cloud_Connect_Sync__c = true;
        
        update leads;
        
        test.stoptest();
    }
}