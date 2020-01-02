/*
* @Name: TestLeadTriggerActions
* @Desc: Test LeadTriggerActions class.
* @Author: Rohit Mehta
* @Date: 12/04/2012
*/
@IsTest
private class TestLeadTriggerActions {

	static testMethod void cloudConnectSyncInsertTest() {
		List<Country__c> countries = TestObjectFactory.createCountry(1, new Map<String, Object>());
		insert countries;
		
		Map<String, Object> attributes = new Map<String, Object> {'Cloud_Connect_Sync__c' => true,
			'Country__c' => countries.get(0).Id};
		List<Lead> leads = TestObjectFactory.createLead(10, attributes);
		insert leads;
		
		Set<Id> leadIds = new Set<Id>();
		for (Lead l : leads) {
			leadIds.add(l.Id);
		}
		
		List<PartnerNetworkRecordConnection> recordConnections = 
			[SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE LocalRecordId IN :leadIds];
			
		//all 10 leads should get shared.			
		System.assert(recordConnections.size() == 10);
	}

	static testMethod void cloudConnectSyncUpdateTest() {
		List<Country__c> countries = TestObjectFactory.createCountry(1, new Map<String, Object>());
		insert countries;
		
		Map<String, Object> attributes = new Map<String, Object> {'Cloud_Connect_Sync__c' => false,
			'Country__c' => countries.get(0).Id};
		List<Lead> leads = TestObjectFactory.createLead(10, attributes);
		insert leads;
		
		Set<Id> leadIds = new Set<Id>();
		for (Lead l : leads) {
			leadIds.add(l.Id);
		}
		
		List<PartnerNetworkRecordConnection> recordConnections = 
			[SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE LocalRecordId IN :leadIds];
		//nothing shared as cloud connect was set to false
		System.assert(recordConnections.size() == 0);
		
		//update leads to set cloud connect to true
		for (Lead l : leads) {
			l.put('Cloud_Connect_Sync__c', true);
		}
		update leads;
		
		recordConnections = 
			[SELECT LocalRecordId FROM PartnerNetworkRecordConnection WHERE LocalRecordId IN :leadIds];
		//all 10 leads should get shared.			
		System.assert(recordConnections.size() == 10);
		
	}
}