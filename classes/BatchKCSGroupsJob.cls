global with sharing class BatchKCSGroupsJob  implements Database.Batchable<sObject> {


	global integer queryLimit;

	global static Map<id,Group> groupMap;

	global List<sObject> start(Database.BatchableContext batchableContext) {
		if( queryLimit == null || queryLimit == 0){
			return [select id,KCS_Groups__c from User where userType = 'Standard'];
		}else{
			return [select id,KCS_Groups__c from User where userType = 'Standard' limit: queryLimit];
		}
	}


	global void execute(Database.BatchableContext batchableContext, List<sObject> scopeList) {

		setGroupsMap();

		Set<Id> userIds = new Set<Id>();

		for(sObject theObject:scopeList){
			userIds.add(theObject.Id);
		}
		
		
		Map<id,Set<Id>> usersWithGroup = getGroupsForIds(new Map<id,Set<Id>>(),userIds);
		
		
		List<User> usersToUpdate = new List<User>();
		
		for(sObject theObject:scopeList){

			User currentUser = (User)theObject;
			String currentKCSGroups = '';
			if(currentUser.KCS_Groups__c != null){
				currentKCSGroups = currentUser.KCS_Groups__c;
			}
			String newKCSGroups = '';

			if(usersWithGroup.containsKey(currentUser.id)){
				
				for(id theGroupId:usersWithGroup.get(currentUser.id)){
					if(groupMap.containsKey(theGroupId)){
						System.debug('YES it has this Role' + groupMap.get(theGroupId));
						if(newKCSGroups != ''){
							newKCSGroups += ';';
						}
						newKCSGroups += groupMap.get(theGroupId).Name;
					}
				}
			}
			
			System.debug('currentKCSGroups' + currentKCSGroups);
			System.debug('newKCSGroups' + newKCSGroups);
			if(doesNeedChange(currentKCSGroups,newKCSGroups)){
				currentUser.KCS_Groups__c = newKCSGroups;
				usersToUpdate.add(currentUser);
			}
			
			
		}
		
		update usersToUpdate;
	}
	
	
	global void finish(Database.BatchableContext batchableContext) {
		
		 AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
		      TotalJobItems, CreatedBy.Email
		      FROM AsyncApexJob WHERE Id =
		      :batchableContext.getJobId()];
		   
		   String emailBody = ''; 
		   emailBody = 'The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n';
		   System.debug(emailBody);
		   // Send an email to the Apex job's submitter notifying of job completion.
		   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		   
		   List<Article_Alert_Monitor__c> aams = Article_Alert_Monitor__c.getall().values();
		   List<String> addresses = new List<String>();
		   for(Article_Alert_Monitor__c aam:aams){
		   	addresses.add(aam.Email_Address__c);
		   }
		    
		   //String[] toAddresses = new String[] {};
		   mail.setToAddresses(addresses);
		   mail.setSubject('KCS groups Stats Job:: ' + a.Status);
		   mail.setPlainTextBody(emailBody);
		   if(!Test.isRunningTest()){
		   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		   }

	}

	public static void setGroupsMap(){
		
		List<String> KCSGroupNames = new List<String>();
		
		KCSGroupNames.add('Knowledge-Publisher');
		KCSGroupNames.add('Knowledge-In Training');
		KCSGroupNames.add('Knowledge-Contributor');
		KCSGroupNames.add('Knowledge-Candidate');
		KCSGroupNames.add('KCS Coaches');
		KCSGroupNames.add('ADMIN View');
		
		groupMap = new Map<id,Group>([select Id , Name from Group where Name in: KCSGroupNames]);
	}



	// return all ids the user belongs to via direct or indirect membership
	public static Map<id,Set<Id>> getGroupsForIds(Map<id,Set<Id>> usersWithGroups,Set<Id> userOrGroupIds){
	
	    Set<Id> nestedGroupIds = new Set<Id>();
	
	    // only query actual groups and not roles and queues
	    list<GroupMember> records = [
	        select id
	             , GroupId
	             , UserOrGroupId
	          from GroupMember
	         where UserOrGroupId in: userOrGroupIds
	        and UserOrGroupId != null
	           and Group.Type = 'Regular'];
	
	    for (GroupMember record:records)
	    {
	        // found a group, remember for traversal
	        if (!(record.UserOrGroupId + '').startsWith('005'))
	        {
	            nestedGroupIds.add(record.UserOrGroupId);   
	        }
	        else
	        {
	        	Set<Id> mapGroup ;
	        	if(usersWithGroups.containsKey(record.UserOrGroupId)){
	        		mapGroup = usersWithGroups.get(record.UserOrGroupId);
	        	}else{
	        		mapGroup = new Set<Id>();
	        	}
	        	
	        	mapGroup.add(record.GroupId);
	        	usersWithGroups.put(record.UserOrGroupId,mapGroup);
	        }
	    }
	
	    // call self to get nested groups we found
	    if (nestedGroupIds.size() > 0)
	    {
	        usersWithGroups.putAll(getGroupsForIds(usersWithGroups,nestedGroupIds));
	    }
	
	    return usersWithGroups;
	}


		
	global static boolean doesNeedChange(String KCSGroups,String newGroups){
		
		if(KCSGroups == null && newGroups == null){
			return false;
		}
		
		if(KCSGroups != null && newGroups == null || KCSGroups == null && newGroups != null){
			return true;
		}
		
		List <String> KCSGroupsList = KCSGroups.split(';');
		List <String> newGroupsList = newGroups.split(';');
		
		Set <String> KCSGroupsSet = new Set<String>();
		KCSGroupsSet.addAll(KCSGroupsList);
		Set <String> newGroupsSet = new Set<String>();
		newGroupsSet.addAll(newGroupsList);
		
		for(String theGroup:KCSGroupsSet){
			if(!newGroups.contains(theGroup)){
				return true;
			}else{
				newGroupsSet.remove(theGroup);
			}
		}
		if(!newGroupsSet.isEmpty()){
			return true;
		}
		
		return false;
		
	}
		
		
		
		




}