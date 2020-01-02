/*
* @Name: TestObjectFactory
* @Desc: Util class used by Test Methods to create test record instances.
* @Author: Rohit Mehta
* @Date: 12/04/2012
*/
public with sharing class TestObjectFactory {

	public static List<Lead> createLead(Integer size, Map<String, Object> attributes) {
		List<Lead> records = new List<Lead>();
		for (Integer i = 0; i < size; i++) {
			Lead record = new Lead(FirstName = 'Test', LastName = 'Lead-' + i, 
				Company = 'Tester' + i, Country = 'US');
			for (String key : attributes.keySet()) {
				record.put(key, attributes.get(key));
			}
			records.add(record);
		}
		return records;
	}

	public static List<Country__c> createCountry(Integer size, Map<String, Object> attributes) {
		List<Country__c> records = new List<Country__c>();
		for (Integer i = 0; i < size; i++) {
			Country__c record = new Country__c(Name = 'US', Country__c = 'USA');
			for (String key : attributes.keySet()) {
				record.put(key, attributes.get(key));
			}
			records.add(record);
		}
		return records;
		
	}

	public static List<Campaign> createCampaign(Integer size, Map<String, Object> attributes) {
		List<Campaign> records = new List<Campaign>();
		for (Integer i = 0; i < size; i++) {
			Campaign record = new Campaign(Name = 'Test Campaign' + i);
			for (String key : attributes.keySet()) {
				record.put(key, attributes.get(key));
			}
			records.add(record);
		}
		return records;
		
	}

	public static List<CampaignMember> createCampaignMember(Integer size, Map<String, Object> attributes) {
		List<CampaignMember> records = new List<CampaignMember>();
		for (Integer i = 0; i < size; i++) {
			CampaignMember record = new CampaignMember();
			for (String key : attributes.keySet()) {
				record.put(key, attributes.get(key));
			}
			records.add(record);
		}
		return records;
		
	}
}