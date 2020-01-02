trigger PortalContactUpdate on User (before insert,after insert,after update,before update) {
    if(Util.Bypass_Trigger_Chk)
        return;

    if(Trigger.isBefore){
        if(Trigger.isInsert){
           UserUpdateUtil.updateGenieFields(Trigger.new); 
           UserUpdateUtil.updateUserNames(Trigger.new);
        } 
        if(Trigger.isUpdate){
           UserUpdateUtil.updateGenieFieldForStandardUser(Trigger.oldMap,Trigger.newMap,Trigger.new);
        } 
    }
    if(Trigger.isAfter){
        try{
            if(Trigger.isInsert){
                UserUpdateUtil.addToPublicGroupAndUpdateContactFlag(Trigger.newMap.keySet());

                //Mukunthan Koothan added below code to add Partner portal users to "All Partner Portal Users" public group
                list<string> partnerProfiles = (label.Partner_Portal_Profiles).split(';');
                set<string> profileSet = new set<string>();
                profileSet.addAll(partnerProfiles);
                list<Id> userIDs = new list<Id>();
                for(User usrRec:trigger.new){
                    System.Debug('usrRec.ProfileId--->'+usrRec.ProfileId);
                    System.Debug('profileSet.contains(usrRec.ProfileId)--->'+profileSet.contains(usrRec.ProfileId));
                    if(profileSet.contains(usrRec.ProfileId) && usrRec.isActive){
                        userIDs.add(usrRec.Id);
                    }
                }
                system.debug('userIDs--->'+userIDs);
                if(userIDs.size()>0){
                    UserUpdateUtil.addPartnerUserToGroup(userIDs);
                }
            } 
            if(Trigger.isUpdate){
               UserUpdateUtil.updateLdapContactPermissionsOnProfileChange(Trigger.newMap, Trigger.oldMap);
               UserUpdateUtil.updateContactFlag(Trigger.new,Trigger.oldMap);
            }
            
            list<profile> profileIDs = [Select Id from Profile where Name IN ('Genesys Portal Partner','Genesys Portal Gold Partner')];
            set<string> portalProfiles = new set<string>();
            for(profile prof:profileIDs){
                portalProfiles.add(prof.Id);
            }
            UserUpdateUtil.updateLitmosPermissionSet(trigger.new,trigger.newMap,trigger.oldMap,portalProfiles,trigger.isInsert,trigger.isUpdate);

            //Add GeneralBasic, KnowledgeNetwork,HigherLogic to LDAP Contacts Permissions if User profile is Genesys Portal Knowledge Network
            string gknProfileId = Global_setting__c.getInstance('Genesys Portal Knowledge Network Id').Id__c;
            list<string> contactIDs = new list<string>();
            for(User eachUsr:trigger.new){
                if(eachUsr.profileId == gknProfileId){
                    if(trigger.isInsert){
                        contactIDs.add(eachUsr.contactId);
                    }
                    else if(trigger.isUpdate && (trigger.OldMap).get(eachUsr.Id).profileId != gknProfileId){
                            contactIDs.add(eachUsr.contactId);
                    }
                }
            }
            if(contactIDs.size()>0){
                string GKNProfileLDAP = Global_setting__c.getInstance('GKNProfileLDAPContactPerm').Information__c;
                UserUpdateUtil.addRemoveLDAPContactPerms(contactIDs,GKNProfileLDAP,'Contact','add');
            }

        }
        catch(exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorinLine--->'+e.getLineNumber());
        }
    
    }
}