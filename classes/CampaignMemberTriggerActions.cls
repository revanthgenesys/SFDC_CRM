/*
* @Name: CampaignMemberTriggerActions
* @Desc: Called from CampaignMemberTrigger..all actions happen here.
* @Author: Rohit Mehta
* @Date: 11/16/2012
*/
public with sharing class CampaignMemberTriggerActions {

	public static void doAfterInsert(List<CampaignMember> members) {
		Map<Id, Integer> m = new Map<Id, Integer>();
		for (CampaignMember member : members) {
			
			System.debug('member Responded = '+ member.hasResponded);
			System.debug('member LeadId = '+ member.LeadId);
			System.debug('member.Include_for_Cloud_Connect__c = ' + member.Include_for_Cloud_Connect__c);
			if (member.Include_for_Cloud_Connect__c == 1) {
				Integer count = (m.containsKey(member.LeadId)) ? m.get(member.LeadId) : 0;
				m.put(member.LeadId, ++count);
			}
		}
		setCampaignHistory(m);
	}

	public static void doAfterDelete(List<CampaignMember> members) {
		Map<Id, Integer> m = new Map<Id, Integer>();
		for (CampaignMember member : members) {
			if (member.Include_for_Cloud_Connect__c == 1) {
				Integer count = (m.containsKey(member.LeadId)) ? m.get(member.LeadId) : 0;
				m.put(member.LeadId, --count);
			}
		}
		setCampaignHistory(m);
	}

	public static void doAfterUpdate(Map<Id, CampaignMember> oldMembers, List<CampaignMember> members) {
		Map<Id, Integer> m = new Map<Id, Integer>();
		for (CampaignMember member : members) {
			CampaignMember oldMember = oldMembers.get(member.Id);
			
			if (oldMember.Include_for_Cloud_Connect__c == member.Include_for_Cloud_Connect__c) {
				continue;
			}
			
			Integer count = (m.containsKey(member.LeadId)) ? m.get(member.LeadId) : 0;
			//count = (member.Include_for_Cloud_Connect__c == 1) ? count++ : count--;
			m.put(member.LeadId, (member.Include_for_Cloud_Connect__c == 1) ? ++count : --count);
		}
		setCampaignHistory(m);
		
	}
	
	public static void setCampaignHistory(Map<Id, Integer> m) {
		List<Lead> leads = [SELECT Campaign_History__c FROM Lead WHERE Id IN :m.keySet()];
		for (Lead lead : leads) {
			Integer campaignHistory = lead.Campaign_History__c == null ? 0 : (Integer) lead.Campaign_History__c;
			System.debug('campaignHistory = ' + campaignHistory);
			System.debug('m = ' + m);
			System.debug('lead.Id = ' + lead.Id);
			Integer count = m.containsKey(lead.Id) ? m.get(lead.Id) : 0;
			
			lead.Campaign_History__c = campaignHistory + count;
		}
		
		if (! leads.isEmpty()) {
			update leads;
		}
		
	}

}