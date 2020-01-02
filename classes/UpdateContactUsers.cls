/*
Naresh Kumar	06/10/2013
*/
public with sharing class UpdateContactUsers {
	public static void updateContactUserRecords(List<Account> newList, Map<Id, Account> oldMap){
		Set<Id> accIdWithPartnerStatusActive = new Set<Id>();
		Set<Id> accIdWithPartnerStatusInActive = new Set<Id>();		
		for(Account eachAccount : newList){
			if(eachAccount.Partner_Program_Status__c == 'Active' && eachAccount.Partner_Program_Status__c != oldMap.get(eachAccount.id).Partner_Program_Status__c){
				accIdWithPartnerStatusActive.add(eachAccount.id);
			}
			if(eachAccount.Partner_Program_Status__c == 'InActive' && eachAccount.Partner_Program_Status__c != oldMap.get(eachAccount.id).Partner_Program_Status__c){
				accIdWithPartnerStatusInActive.add(eachAccount.id);
			}
		}
		Map<Id, Contact> contactsWithAccStatusActive = new Map<Id, Contact>([SELECT id FROM Contact WHERE AccountId IN : accIdWithPartnerStatusActive]);
		Map<Id, Contact> contactsWithAccStatusInActive = new Map<Id, Contact>([SELECT id FROM Contact WHERE AccountId IN : accIdWithPartnerStatusInActive]);
		
		List<User> usersWithAccStatusActive = [SELECT ProfileId FROM User WHERE ContactId IN : contactsWithAccStatusActive.keyset()];
		List<User> usersWithAccStatusInActive = [SELECT ProfileId FROM User WHERE ContactId IN : contactsWithAccStatusInActive.keyset()];
		
		if(usersWithAccStatusActive.isEmpty() && usersWithAccStatusInActive.isEmpty())
			return;
		
		List<Profile> profiles = [SELECT id, Name FROM Profile WHERE Name = 'Genesys Portal Partner User' OR Name = 'Genesys Portal End User'];
		String partnerUseProfileId, partnerProfileId;
		if(profiles.size() == 2){
			if(profiles[0].Name == 'Genesys Portal Partner User'){
				partnerProfileId = profiles[0].id;
				partnerUseProfileId = profiles[1].id;
			}
			if(profiles[0].Name == 'Genesys Portal End User'){
				partnerProfileId = profiles[1].id;
				partnerUseProfileId = profiles[0].id;			
			}
		}
		else
			return;
		
		Set<Id> userIdsToBeUpdated = new Set<Id>();		
		for(User eachUser : usersWithAccStatusActive){
			userIdsToBeUpdated.add(eachUser.id);
		}
		if(!userIdsToBeUpdated.isEmpty())
			updateUserFuture(userIdsToBeUpdated, partnerProfileId);
		
		userIdsToBeUpdated.clear();		
		for(User eachUser : usersWithAccStatusInActive){
			userIdsToBeUpdated.add(eachUser.id);
		}
		if(!userIdsToBeUpdated.isEmpty())
			updateUserFuture(userIdsToBeUpdated, partnerUseProfileId);
		TriggerFlowManager.ACCOUNT_AFTER_UPDATE_CONTACT_USERS = false;
	}
	@future
	private static void updateUserFuture(Set<Id> userIdsToBeUpdated, String profileId){
		List<User> usersToBeUpdated = [SELECT profileId FROM USER WHERE id IN  : userIdsToBeUpdated];
		for(User eachUser : usersToBeUpdated){
			eachUser.ProfileId = profileId;
		}
		update usersToBeUpdated;
	}
}