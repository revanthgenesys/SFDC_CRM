trigger Contact_After on Contact (after insert, after update) {

 	if(Util.Bypass_Trigger_Chk)
 		return;

	if(Trigger.isUpdate)
		SupportAccessUtil.disableEnablePartnerPortal(Trigger.new, Trigger.oldMap);
	Set<Id> accountIds = new Set<Id>();
    for(Contact con : trigger.new){
    	accountIds.add(con.AccountId);
    }
    
    // for all the contacts with accounts, check if the account has a parent account then update the contacts employer as the parent account        
	if(Trigger.isUpdate || Trigger.isInsert)
		if(!accountIds.isEmpty())
            ContactUtil.updateContactsEmployer(accountIds, trigger.new, trigger.oldMap);
 	
    if(Trigger.isAfter && Trigger.isUpdate){
    	List<String> addSharingForContactIds = new List<String>();
    	List<String> deleteSharingForContactIds = new List<String>();
    	for(Contact c : Trigger.New){
    		if(
    			(c.Status__c == 'Active' && c.Designated_Partner_Contact__c == true && Trigger.oldMap.get(c.Id).Designated_Partner_Contact__c == false)
    			||
    			(c.Status__c == 'Active' && Trigger.oldMap.get(c.Id).Status__c != 'Active' && c.Designated_Partner_Contact__c == true)
    		){
    			addSharingForContactIds.add(c.id);
    		} 
    		
    		if(c.Designated_Partner_Contact__c == false && Trigger.oldMap.get(c.Id).Designated_Partner_Contact__c == true){
    			deleteSharingForContactIds.add(c.id);
    		}
    	}
		if(addSharingForContactIds.size() > 0){
			System.enqueueJob(new PartnerPortalCustomSharingQueueable(addSharingForContactIds));
			System.enqueueJob(new PartnerDealRegistrationSharingQueueable(addSharingForContactIds));
		}
		if(deleteSharingForContactIds.size() > 0){
			System.enqueueJob(new PartnerPortalDeleteSharingQueueable(deleteSharingForContactIds));
			System.enqueueJob(new PartnerDealRegDeleteSharingQueueable(deleteSharingForContactIds));
		}
    }   

    if(Trigger.isAfter){
        if(Trigger.isUpdate){
            ContactUtil.AfterUpdate(Trigger.new,Trigger.oldMap);
        }
        if(Trigger.isInsert){
            ContactUtil.AfterInsert(Trigger.new);
        }
    }      
}