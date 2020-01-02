@isTest
private class TestCampaignMemberTrigger{
    @isTest static void TestCampaignMemberTrigger() {
        // Test data setup
        // Create an account with an opportunity, and then try to delete it
        Lead l = new Lead(LastName = 'Test', Email='Test@Test.com', Company='Test Company');
        insert l;
        Campaign c = new Campaign(Name='Test Campaign');
        insert c;
        
        Test.startTest();
        
        CampaignMember cm= new CampaignMember(CampaignId = c.Id, LeadId=l.Id);
        insert cm;
        
        cm.Status = 'Registered';
        update cm;
        
        delete cm;
        Test.stopTest();
    }
    
}