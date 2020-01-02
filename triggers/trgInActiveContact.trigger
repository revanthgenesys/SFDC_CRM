//Naresh Kumar    03/04/2016    Updating code to handle bulk records
trigger trgInActiveContact on Contact (before update){    
    
    
    Set<Id> setOfContactIds = new Set<Id>();
    //Looping over each Contact
    for(Contact eachContact : trigger.new){
        if(eachContact.Status__c == 'Inactive' && trigger.oldMap.get(eachContact.id).Status__c != 'Inactive'){
            setOfContactIds.add(eachContact.id);            
        }
        Contact oldContact = trigger.oldMap.get(eachContact.id);
        //User 'Automation Integration Marketing' can not update the contact' name     
        if(UserInfo.GetUserName() == 'marketo@genesyslab.com.marketo'){
            if(eachContact.FirstName != oldContact.FirstName || eachContact.LastName != oldContact.LastName){
                eachContact.FirstName = oldContact.FirstName;
                eachContact.LastName = oldContact.LastName;
            } 
        }        
    }
    if(setOfContactIds.isEmpty())
        return;
    
    List<User> contactUsers = [SELECT id, CommunityNickname, IsPortalEnabled, contactId FROM User WHERE ContactId =: setOfContactIds AND IsPortalEnabled = true];
    Map<Id, User> mapOfContactIdVsUser = new Map<Id, User>();
    for(User eachUser : contactUsers){
        mapOfContactIdVsUser.put(eachUser.contactId, eachUser);
    }
    
    //Looping over each Contact
    for(Contact eachContact : trigger.new){
        if(mapOfContactIdVsUser.get(eachContact.id) != null && mapOfContactIdVsUser.get(eachContact.id).IsPortalEnabled){
        	List<Profile> currentUserProfile = [SELECT Id, Name FROM Profile WHERE Id =: UserInfo.getProfileId()];
        	if(!currentUserProfile.isEmpty() && currentUserProfile[0].Name == 'System Administrator'){
        		eachContact.Legacy_Account__c = eachContact.AccountId;
            	eachContact.AccountId = Label.Inactive_Contact_Settings.split(';')[0];	
        	}
			else
				eachContact.addError('This contact can not be inactivated, it has a active portal user tied to it.  Please deactivate portal user first.');
        }
        else{
            eachContact.Legacy_Account__c = eachContact.AccountId;
            eachContact.AccountId = Label.Inactive_Contact_Settings.split(';')[0];
            //eachContact.ownerId = Label.Inactive_Contact_Settings.split(';')[1];
        }
    }      
}