/*
	Naresh Kumar	01/20/2014
	Batch to cancel all the applications which are not touched in last 6 month and in 'In Progress' status.
*/
global class PartnerApplicationAutoCancellationBatch implements Database.Batchable<SObject>{
	
	global Database.Querylocator start(Database.BatchableContext ctx) {
		List<Partner_Application__c> pas;
		if(Test.isRunningTest()){
			return Database.getQueryLocator([SELECT id, Status__c, Account__c, Contact__c, For_User__c FROM
				Partner_Application__c WHERE Company_Name__c = 'Test Company']);			
		}
		else{
			return Database.getQueryLocator([SELECT id, Status__c, Account__c, Contact__c, For_User__c FROM
				Partner_Application__c WHERE Status__c = 'In Progress' AND LastModifiedDate <: System.today() - 180]);			
		}		
		return null;
	}
	
	global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
		List<Partner_Application__c> expiredApplications = (List<Partner_Application__c>) scope;
		List<Id> userIdsToBeDisabled = new List<Id>();
		List<Account> accountsToBeUpdated = new List<Account>();
		Set<Id> accountIds = new Set<Id>();
		for(Partner_Application__c eachPA : expiredApplications){
			userIdsToBeDisabled.add(eachPA.For_User__c);
			if(eachPA.Account__c != null && !accountIds.contains(eachPA.Account__c)){
				accountsToBeUpdated.add(new Account(id = eachPA.Account__c, Approval_Status__c = 'Application timeout'));
				accountIds.add(eachPA.Account__c);
			}
			eachPA.Status__c = 'Application timeout';
		}		
		if(!expiredApplications.isEmpty())
			update expiredApplications;
		if(!accountsToBeUpdated.isEmpty())
			update accountsToBeUpdated;
		if(!userIdsToBeDisabled.isEmpty()){
			//PartnerApplicationControllerHelper.disableUser(userIdsToBeDisabled);
			List<User> usersTOBeDisabled = [SELECT IsActive FROM User WHERE id IN  : userIdsToBeDisabled];
	        for(User eachUser : usersTOBeDisabled)
	            eachUser.isActive = false;
	        if(!usersTOBeDisabled.isEmpty()){           
	            update usersTOBeDisabled;
	        }
		}
	}
	
	global void finish(Database.BatchableContext ctx){
		
	}
}