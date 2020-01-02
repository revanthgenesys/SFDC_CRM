/*
* @Name: TestCampaignMemberTriggerActions
* @Desc: Test TestCampaignMemberTriggerActions class.
* @Author: Rohit Mehta
* @Date: 12/04/2012
*/
@isTest
private class TestCampaignMemberTriggerActions {

    static testMethod void insertTest() {
        //create campaign
        Map<String, Object> attributes = new Map<String, Object> {'Marketing_Group__c' => 'Cloud Connect', 'IsActive' => true};
        List<Campaign> campaigns = TestObjectFactory.createCampaign(1, attributes);
        insert campaigns;
        
        System.debug('Marketing_Group__c = '+ [Select Marketing_Group__c FROM Campaign WHERE Id = :campaigns.get(0).Id].Marketing_Group__c);

        //create country and lead
        List<Country__c> countries = TestObjectFactory.createCountry(1, new Map<String, Object>());
        insert countries;
        
        attributes = new Map<String, Object> {'Cloud_Connect_Sync__c' => false,
            'Country__c' => countries.get(0).Id};
        List<Lead> leads = TestObjectFactory.createLead(1, attributes);
        insert leads;
        
        attributes = new Map<String, Object> {'CampaignId' => campaigns.get(0).Id,
            'LeadId' => leads.get(0).Id, 'Status' => 'Responded'};
        List<CampaignMember> members = TestObjectFactory.createCampaignMember(1, attributes);
        insert members;
        
        System.debug('member Responded = '+ [Select hasResponded FROM CampaignMember WHERE Id = :members.get(0).Id].hasResponded);
        System.debug('member LeadId = '+ [Select LeadId FROM CampaignMember WHERE Id = :members.get(0).Id].LeadId);
        
        /*System.assert([SELECT Campaign_History__c FROM Lead WHERE Id = :leads.get(0).Id].Campaign_History__c == 1);

        //now update the status to "not responded" - should make Campaign_History__c = 0
        members.get(0).Status = null;
        update members;
        System.assert([SELECT Campaign_History__c FROM Lead WHERE Id = :leads.get(0).Id].Campaign_History__c == 0);
        
        //now update the status to "Responded" - should make Campaign_History__c back to 1
        members.get(0).Status = 'Responded';
        update members;
        System.assert([SELECT Campaign_History__c FROM Lead WHERE Id = :leads.get(0).Id].Campaign_History__c == 1);
        
        //just an empty update should not change anything
        update members;
        System.assert([SELECT Campaign_History__c FROM Lead WHERE Id = :leads.get(0).Id].Campaign_History__c == 1);
                
        //now delete the members - should make Campaign_History__c = 0
        delete members;
        System.assert([SELECT Campaign_History__c FROM Lead WHERE Id = :leads.get(0).Id].Campaign_History__c == 0);
        */              
    }


}