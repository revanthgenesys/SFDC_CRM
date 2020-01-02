public without sharing class UserUpdateUtil {
    public static Map<String,String> genieChUsrGroupMap = new Map<String,String>();
    private static list<User> gUpdUserList = new List<user>();
    
    /* Method to update Genie related fields in User */
    public static void updateGenieFields(List<User> usrList) {
        Map<Id,Contact> ContactMap;
        String channelGroupValues = '';
        List<Id> contactIds = new List<Id>();
        List<Profile> userProfiles = getPortalProfiles();
        Set<Id> profileIds = new Set<Id>();
        
        getGenieChannelUserGroupsValues();
        for(Profile eachProfile : userProfiles) {
            System.debug('eachProfile-->'+eachProfile);
            profileIds.add(eachProfile.Id);  
        }
        
        for(user usr : usrList) {
            contactIds.add(usr.ContactId);          
        }
        ContactMap = new Map<Id,Contact>([select Account.PartnerType__c,Account.Country__r.Region__c,Account.Partner_Tier__c from Contact where Id in: contactIds]);
        System.debug('ContactMap--'+ContactMap);
        for(user usr : usrList) {
            if (profileIds.contains(usr.ProfileId)) {
                usr.Genie_Access__c = true; 
                channelGroupValues = updateGenieChannelUserGroups(ContactMap.get(usr.ContactId).Account.PartnerType__c,ContactMap.get(usr.ContactId).Account.Partner_Tier__c,ContactMap.get(usr.ContactId).Account.Country__r.Region__c); 
                System.Debug('channelGroupValues--->'+channelGroupValues);
                if(channelGroupValues != '') {
                    usr.Genie_Channel_User_Groups__c = channelGroupValues;
                }
            }
        }
        gUpdUserList.addAll(usrList);
    }
    
    //called from AccountMain trigger to update Genie_Access__c and  Genie_Channel_User_Groups__c fields on update of Account
    @future
    public static void updateGenieFieldsOnAccountUpd(List<Id> accIDs){
        
        try{
            List<User> usrList = [Select Id,ContactId,AccountId,ProfileId,Genie_Access__c,Genie_Channel_User_Groups__c from User where isActive=true
                                    AND Profile.Name in ('Genesys Portal Gold Partner', 'Genesys Portal Partner','Partner Community Login New')
                                    AND Usertype = 'PowerPartner' AND AccountId IN:accIDs];
            System.Debug('usrList--->' + usrList);
            System.Debug('usrList--->' + usrList.size());
            updateGenieFields(usrList);
            if(gUpdUserList.size()>0){
                System.Debug('gUpdUserList--->'+gUpdUserList);
                update gUpdUserList;
            }
        }
        catch(exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('Error--->'+e.getLineNumber());
        }
    }

    //called from AccountMain trigger to remove Genie Access and clear Genie User Id
    @future
    public static void enableDisableGenieAccess(List<Id> accIDs){
        try{
            List<User> usrList = [Select Id,ContactId,AccountId,Genie_Access__c,Genie_User_Id__c from User where isActive=true
                                    AND Profile.Name in ('Genesys Portal Gold Partner', 'Genesys Portal Partner','Partner Community Login New')
                                    AND Usertype = 'PowerPartner' AND AccountId IN:accIDs];
            List<Id> contactIDs = new List<Id>();
            for(user usrRec:usrList){
                usrRec.Genie_Access__c = false;
                usrRec.Genie_User_Id__c=null;
                usrRec.Genie_Channel_User_Groups__c = null;
                contactIDs.add(usrRec.contactId);
            }
            update usrList;
            if(contactIDs.size()>0){
                List<contact> contactRecords = [Select Id,Ldap_Contact_Permissions__c from Contact where Id IN:contactIDs];
                Global_setting__c glbSet = Global_setting__c.getValues('LDAPContactPermissions');
                for(contact ctRec:contactRecords){
                    if(ctRec.Ldap_Contact_Permissions__c != null){
                        if(ctRec.Ldap_Contact_Permissions__c.contains(glbSet.Information__c)){
                            List<string> ldpPerm = ctRec.Ldap_Contact_Permissions__c.split(';');
                            for(integer i=0;i<=ldpPerm.size();i++){
                                if(ldpPerm[i] == glbSet.Information__c){
                                    ldpPerm.remove(i);
                                }
                            }
                            ctRec.Ldap_Contact_Permissions__c = string.join(ldpPerm,';');
                        }
                    }
                }
                update contactRecords;
            }
        }
        catch(exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorInLine--->'+e.getLineNumber());
        }
    }
    
    //called from PortalContactUpdate trigger on User object
    @future
    public static void addPartnerUserToGroup(list<Id> UserIDs){
        try{
            Group pGroup=[select Id from Group Where DeveloperName='All_Partner_Portal_Users' limit 1];
            list<GroupMember> grpMember = new list<GroupMember>();
            for(Id usrId:UserIDs){
                GroupMember grpMemRec = new GroupMember();
                grpMemRec.GroupId = pGroup.Id;
                grpMemRec.UserOrGroupId = usrId;
                grpMember.add(grpMemRec);
            }
            if(grpMember.size()>0){
                insert grpMember;
            }
        }
        catch(exception e){
            system.debug('Error--->'+e.getMessage());
            system.debug('ErrorInLine--->'+e.getLineNumber());
        }
    }

    public static void updateLitmosPermissionSet(list<user> triggerNew,map<id,user> triggerNewMap, map<id,user> triggerOldMap,
                                                    set<string> portalProfiles,boolean isInsert, boolean isUpdate){
        try{
            list<string> addPermissionUserIds = new list<string>();
            list<string> removePermissionUserIds = new list<string>();
            
            if(isInsert && !isUpdate){
                for(User usr:triggerNew){
                    if(portalProfiles.contains(usr.profileId) && usr.isActive == true){
                        addPermissionUserIds.add(usr.Id);
                    }
                }
            }
            else if(isUpdate && !isInsert){
                for(User usr:triggerNew){
                    if(portalProfiles.contains(usr.profileId) && usr.isActive == true && usr.profileId != triggerOldMap.get(usr.Id).profileId){
                        addPermissionUserIds.add(usr.Id);
                    }
                    else if(portalProfiles.contains(triggerOldMap.get(usr.Id).profileId) && !portalProfiles.contains(usr.profileId) && usr.isActive == true){
                        removePermissionUserIds.add(usr.Id);
                    }
                    else if(usr.isActive == false && (portalProfiles.contains(usr.profileId) || portalProfiles.contains(triggerOldMap.get(usr.Id).profileId))){
                        removePermissionUserIds.add(usr.Id);
                    }
                }
            }
            
            PermissionSet pSet = new PermissionSet();
            pSet = [Select Id from PermissionSet where Name = 'Litmos_Login_Access' limit 1];
            System.Debug('addPermissionUserIds--->'+addPermissionUserIds);
            System.Debug('removePermissionUserIds--->'+removePermissionUserIds);
            if(addPermissionUserIds.size()>0){
                addLitmosPermissionSet(addPermissionUserIds,pSet.Id);
            }
            if(removePermissionUserIds.size()>0){
                removeLitmosPermissionSet(removePermissionUserIds,pSet.Id);
            }
            
        }
        catch(exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorInLine--->'+e.getLineNumber());
        }
    }

    @future
    public static void addRemoveLDAPContactPerms(list<string> IDlst,string ldapPermString,string objToUpd,string actionTp){
        if(actionTp.containsIgnoreCase('add')){
            if(objToUpd.containsIgnoreCase('Contact')){
                list<string> permSet = ldapPermString.split(';');
                List<contact> contactRecords = [Select Id,Ldap_Contact_Permissions__c from Contact where Id IN:IDlst];
                for(contact ctRec:contactRecords){
                    if(ctRec.Ldap_Contact_Permissions__c != null){
                        for(string val:permSet){
                            if(!(ctRec.Ldap_Contact_Permissions__c).containsIgnoreCase(val)){
                                ctRec.Ldap_Contact_Permissions__c += ';'+val;
                            }
                        }
                    }
                    else{
                        ctRec.Ldap_Contact_Permissions__c = ldapPermString;
                    }
                }
                update contactRecords;
            }
        }
    }
    
    @future
    public static void addLitmosPermissionSet(list<string> UserIDs, string pSetId){
        try{
            list<PermissionSetAssignment> permSetAsmtList = new list<PermissionSetAssignment>();
            for(string usrId:UserIDs){
                PermissionSetAssignment pas = new PermissionSetAssignment(AssigneeId=usrId,permissionsetId=pSetId);
                permSetAsmtList.add(pas);
            }
            if(permSetAsmtList.size()>0){
                Database.SaveResult[] pasList = Database.insert(permSetAsmtList, false);
                System.Debug('pasList--->'+pasList);
            }
        }
        catch(exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorInLine--->'+e.getLineNumber());
        }
    }
    
    @future
    public static void removeLitmosPermissionSet(list<string> remUserIDs, string pSetId){
        try{
            list<PermissionSetAssignment> permSetAsmtRemList = [Select Id from permissionsetassignment where assigneeId IN:remUserIDs and permissionsetid=:pSetId];
            if(permSetAsmtRemList.size()>0){
                Database.DeleteResult[] pasRemList = Database.delete(permSetAsmtRemList, false);
                System.Debug('rempasList--->'+pasRemList);
            }
        }
        catch(exception e){
            System.Debug('Error--->'+e.getMessage());
            System.Debug('ErrorInLine--->'+e.getLineNumber());
        }
    }
    
    public static void addToPublicGroupAndUpdateContactFlag(Set<Id> userIds) {

        Set<String> ldapProfiles = new Set<String>{'Genesys Portal Partner', 'Genesys Portal Gold Partner', 'Genesys Portal Potential Partner', 'Genesys Portal Potential Gold Partner', 'Genesys Portal End User'};
        
        Map<Id,Id> contactIdUserIdMap = new Map<Id,Id>();
        Map<Id,User> userMap = new Map<Id,User>([SELECT Id, Username, ProfileId, Profile.Name, ContactId,Contact.Account.Country__r.Region__c,
                                                 Contact.Account.PartnerType__c,Contact.Account.Partner_Tier__c, Contact.Account.Partner_Offering_Type__c  
                                                 FROM User where Id IN : userIds]);

        for (User usr: userMap.values()) {    
            if(usr.ContactId != NULL){
                contactIdUserIdMap.put(usr.ContactId,usr.Id);
            }
        }
        
        //Name = 'Genesys Portal Partner' OR Name = 'Partner Community Login New'
        List<Profile> userProfiles = getPortalProfiles();
        Set<Id> profileIds = new Set<Id>();
        for(Profile eachProfile : userProfiles) {
            profileIds.add(eachProfile.Id);
        }

        List<Contact> cntToBeUpdated = new List<Contact>();
        List<User> userToBeUpdated = new List<User>();
        
        List<Contact> cntList = [SELECT Id, Name, Email, Partner_Portal_Access__c, Portal_User_Name__c, Ldap_Contact_Permissions__c, Account.Partner_Offering_Type__c  FROM Contact WHERE Id IN : contactIdUserIdMap.KeySet()];
        for(Contact eachContact: cntList) {
            User usr = userMap.get(ContactIdUserIdMap.get(eachContact.Id));
            
            String ldapPermissionsExisting = eachContact.Ldap_Contact_Permissions__c != NULL ? eachContact.Ldap_Contact_Permissions__c : '';
            String ldapPermissions = '';
            if(usr.Profile.Name == 'Genesys Portal Partner' || usr.Profile.Name == 'Genesys Portal Gold Partner'){
                if(eachContact.Account.Partner_Offering_Type__c != NULL && eachContact.Account.Partner_Offering_Type__c.contains('PureConnect'))
                    ldapPermissions = 'PartnerCommunity';
                else 
                    ldapPermissions = 'PartnerCommunity; CustomerCommunity';

                if(ldapPermissionsExisting == ''){
                    ldapPermissions = ldapPermissions + '; Marketplace; Education';
                } else {
                    if(!ldapPermissionsExisting.contains('Marketplace')){
                        ldapPermissions =  ldapPermissions + '; Marketplace';
                    }
                    if(!ldapPermissionsExisting.contains('Education')){
                        ldapPermissions =  ldapPermissions + '; Education';
                    }
                }   
            } else if(usr.Profile.Name == 'Genesys Portal Potential Partner' || usr.Profile.Name == 'Genesys Portal Potential Gold Partner') {
                ldapPermissions = 'PartnerCommunity;';
            } else if(usr.Profile.Name == 'Genesys Portal End User'){
                ldapPermissions = 'CustomerCommunity';
            }
            
            if(profileIds.contains(usr.ProfileId) || ldapProfiles.contains(usr.Profile.Name)){
                eachContact.Partner_Portal_Access__c = true;
                eachContact.Portal_User_Name__c = usr.Username;
                if(ldapProfiles.contains(usr.Profile.Name)){
                    eachContact.Ldap_Contact_Permissions__c = eachContact.Ldap_Contact_Permissions__c != NULL ? eachContact.Ldap_Contact_Permissions__c + '; ' +  ldapPermissions : ldapPermissions;  
                }
                if(eachContact.Ldap_Contact_Permissions__c == NULL || !eachContact.Ldap_Contact_Permissions__c.contains('GeneralBasic'))
                    eachContact.Ldap_Contact_Permissions__c = eachContact.Ldap_Contact_Permissions__c + '; ' + 'GeneralBasic';
                    
                cntToBeUpdated.add(eachContact);
            }
        }
                        
        if(!cntToBeUpdated.isEmpty())
            System.enqueueJob(new ContactFlagUpdateQueueableJob(cntToBeUpdated,userToBeUpdated));
        
        
        /*
        String channelGroupValues = '';
        for (User usr: userMap.values()) {            
            if (profileIds.contains(usr.ProfileId)) {
                // usr.Genie_Access__c = true;
                // channelGroupValues = updateGenieChannelUserGroups(usr.Contact.Account.PartnerType__c, usr.Contact.Account.Partner_Tier__c,usr.Contact.Account.Country__r.Region__c); 
                // if(channelGroupValues != '') {
                //    usr.Genie_Channel_User_Groups__c = channelGroupValues;
                //}
                //userToBeUpdated.add(usr); 
                
                ContactIdUserIdMap.put(usr.ContactId,usr.Id);
                cntIdList.add(usr.ContactId);
            }
        }
        System.debug('cntIdList--->'+cntIdList); 
        List<Contact> cntList = [SELECT Id, Name, Email, Partner_Portal_Access__c, Portal_User_Name__c, Ldap_Contact_Permissions__c FROM Contact WHERE Id IN : cntIdList];
        for (Contact eachContact: cntList) {
            eachContact.Partner_Portal_Access__c = true;
            eachContact.Portal_User_Name__c = userMap.get(ContactIdUserIdMap.get(eachContact.Id)).Username;
            cntToBeUpdated.add(eachContact);
        }
                        
        if(!cntToBeUpdated.isEmpty())
            System.enqueueJob(new ContactFlagUpdateQueueableJob(cntToBeUpdated,userToBeUpdated));
        */
    }
    
    public static void updateLdapContactPermissionsOnProfileChange(Map<Id, User> newMap, Map<Id, User> oldMap){
        Set<Id> potentialPartnerProfiles = new Set<Id>();
        Set<Id> partnerProfiles = new Set<Id>();
        
        for(Profile p : [Select Id, Name FROM Profile WHERE Name IN ('Genesys Portal Partner', 'Genesys Portal Gold Partner', 'Genesys Portal Potential Partner', 'Genesys Portal Potential Gold Partner')]){
            if(p.Name == 'Genesys Portal Partner' || p.Name == 'Genesys Portal Gold Partner'){
                partnerProfiles.add(p.Id);
            } else if(p.Name == 'Genesys Portal Potential Partner' || p.Name == 'Genesys Portal Potential Gold Partner'){
                potentialPartnerProfiles.add(p.Id);
            } 
        }
        
        Map<Id,Id> contactIdUserIdMap = new Map<Id,Id>();
        for (User usr: newMap.values()) {    
            if(usr.ContactId != NULL){
                contactIdUserIdMap.put(usr.ContactId,usr.Id);
            }
        }
        
        List<Contact> cntToBeUpdated = new List<Contact>();
        List<User> userToBeUpdated = new List<User>();
        
        List<Contact> cntList = [SELECT Id, Ldap_Contact_Permissions__c, Account.Partner_Offering_Type__c  FROM Contact WHERE Id IN : newMap.KeySet()];
        for(Contact eachContact: cntList) {
            User newUser = newMap.get(ContactIdUserIdMap.get(eachContact.Id));
            User oldUser = oldMap.get(ContactIdUserIdMap.get(eachContact.Id));
            
            if( newUser.ProfileId != oldUser.ProfileId && partnerProfiles.contains(newUser.ProfileId) && potentialPartnerProfiles.contains(oldUser.ProfileId)){
                if(eachContact.Account.Partner_Offering_Type__c == NULL || (eachContact.Account.Partner_Offering_Type__c != NULL && !eachContact.Account.Partner_Offering_Type__c.contains('PureConnect'))){
                    eachContact.Ldap_Contact_Permissions__c = eachContact.Ldap_Contact_Permissions__c != NULL ? eachContact.Ldap_Contact_Permissions__c + '; ' +  'GeneralBasic; CustomerCommunity' : 'GeneralBasic; PartnerCommunity; CustomerCommunity';  
                    cntToBeUpdated.add(eachContact);
                }
            }
        }
                        
        if(!cntToBeUpdated.isEmpty())
            System.enqueueJob(new ContactFlagUpdateQueueableJob(cntToBeUpdated,userToBeUpdated));
        
    }

    public static void updateContactFlag(List<User> usrList, Map<Id, User> oldMap){
        
        Set<Id> cntIdEnableList = new Set<Id>();
        Set<Id> cntIdDisableList = new Set<Id>();
        Set<Id> PermSetAssignmentIds = new Set<Id>();
        Set<Id> lstPortalUserIds = new Set<Id>();
        Set<Id> customProfileIds = new Set<Id>();
        Set<Id> userIdEnableList = new Set<Id>();
        Set<Id> userIdDisableList = new Set<Id>();
        
        for(user usr : usrList) {
            lstPortalUserIds.add(usr.Id);
        }
        
        List<PermissionSetAssignment>  lstPermSetAssignment = [SELECT Id, AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =: PartnerPortalUtil.PARTNER_PORTAL_PERMISSIONSET_ID and AssigneeId in: lstPortalUserIds];
        for(PermissionSetAssignment psa : lstPermSetAssignment) {
            PermSetAssignmentIds.add(psa.AssigneeId);       
        }
        
        List<Profile> lstCustomerProfile = [SELECT Id, Name FROM Profile WHERE Name =: PartnerPortalUtil.CUSTOMER_PORTAL_ENDUSER];
        for(Profile eachProfile : lstCustomerProfile) {
            customProfileIds.add(eachProfile.Id);
        }
        
            
        List<Profile> userProfiles = getPortalProfiles();
        Set<Id> PartnerProfileIds = new Set<Id>();
        Boolean flag = false;
                           
        for(Profile eachProfile : userProfiles) {
            PartnerProfileIds.add(eachProfile.Id);
        }
        
        
        for (User usr: usrList) { 
            /* Enable contact flag 'Portal partner access when 
            User isActive flag is activated or 
            User profile change into Genesys Portal Partner' or 'Partner Community Login New' or (profile:Genesys portal partner & Permission set :Partner Community user) 
            */
            if (usr.IsActive == true && user.contactId != null && ((usr.IsActive == true && oldMap.get(usr.Id).IsActive == false && (PartnerProfileIds.contains(usr.ProfileId) || (customProfileIds.contains(usr.ProfileId) && PermSetAssignmentIds.contains(usr.Id)))) ||
                    (PartnerProfileIds.contains(usr.ProfileId) && !PartnerProfileIds.contains(oldMap.get(usr.Id).ProfileId)) || (customProfileIds.contains(usr.ProfileId) && !customProfileIds.contains(oldMap.get(usr.Id).ProfileId) && PermSetAssignmentIds.contains(usr.Id)) )) 
            {
                System.debug('enabling');
                cntIdEnableList.add(usr.ContactId);
                userIdEnableList.add(usr.Id);
            }
            
            if ((PartnerProfileIds.contains(usr.ProfileId) || (customProfileIds.contains(usr.ProfileId) && PermSetAssignmentIds.contains(usr.Id))) && 
                ((usr.IsActive == false && oldMap.get(usr.Id).IsActive == true) || (user.contactId == null && oldMap.get(usr.Id).contactId != null))) {
                    System.debug('disabling');
                    cntIdDisableList.add(usr.ContactId);
                    userIdDisableList.add(usr.Id);
            }
        }
        
        if(!cntIdEnableList.isEmpty())      
            updateContact(cntIdEnableList,userIdEnableList,true);
        
        if(!cntIdDisableList.isEmpty())     
            updateContact(cntIdDisableList,userIdDisableList,false);
    }
    
    /* 1)Disabling Genie Access while deactivating standard user other than Partner user
     * 2)populate Genie Access and Genie Channel Manager fields when user change profile from
     *   Custom Potential Partner User/Genesys Portal Potential Partner into Genesys Portal Partner 
     */
    public static void updateGenieFieldForStandardUser(Map<Id,User> oldUserMap,Map<Id,User> newUserMap, List<User> userNewList) {
        Set<Id> potenialprofileIds = new Set<Id>();
        Set<Id> fullPartnerprofileId = new Set<Id>();
        List<Profile> potenialProfiles = getPotentialPortalProfiles();
        List<Profile> FullAccessProfile = getGenesysPortalPartnerProfile();
        List<Id> contactIds = new List<Id>();
        Map<Id,Contact> ContactMap;
        String channelGroupValues = '';
        
        getGenieChannelUserGroupsValues();
        for(Profile eachProfile : potenialProfiles) {
            potenialprofileIds.add(eachProfile.Id);  
        }
        for(Profile eachProfile : FullAccessProfile) {
            fullPartnerprofileId.add(eachProfile.Id);  
        }
        for(user usr : userNewList) {
            contactIds.add(usr.ContactId);          
        }
        ContactMap = new Map<Id,Contact>([select Account.PartnerType__c,Account.Country__r.Region__c,Account.Partner_Tier__c from Contact where Id in: contactIds]);
        
        for(User usr : userNewList) {
            //disable Genie Access for Standard user
            if (usr.IsActive == false && oldUserMap.get(usr.Id).IsActive == true && usr.contactId == null && oldUserMap.get(usr.Id).contactId == null) {
                usr.Genie_Access__c = false; 
            }
            /* populate Genie Access and Genie Channel Manager fields when user change profile from
             * Custom Potential Partner User/Genesys Portal Potential Partner into Genesys Portal Partner
             */ 
            if(usr.IsActive == true && oldUserMap.get(usr.Id).ProfileId != newUserMap.get(usr.Id).ProfileId) {
                if (potenialprofileIds.contains(oldUserMap.get(usr.Id).ProfileId) &&
                        fullPartnerprofileId.contains(newUserMap.get(usr.Id).ProfileId)) {
                    usr.Genie_Access__c = true; 
                    channelGroupValues = updateGenieChannelUserGroups(ContactMap.get(usr.ContactId).Account.PartnerType__c,ContactMap.get(usr.ContactId).Account.Partner_Tier__c,ContactMap.get(usr.ContactId).Account.Country__r.Region__c); 
                    if(channelGroupValues != '') {
                        usr.Genie_Channel_User_Groups__c = channelGroupValues;
                    }
                }
            }
        } // end of for loop        
    } // End of method
    
    public static void updateContact(Set<Id> cntIdList, Set<Id> userIdList, Boolean flag){
        
        List<Contact> cntToBeUpdated = new List<Contact>();
        List<Contact> cntList = [SELECT Id, Name, Email, Partner_Portal_Access__c FROM Contact WHERE Id IN : cntIdList];
        
        List<User> userToBeUpdated = new List<User>();
        List<User> userList = [SELECT Id, Name, Email, Genie_Access__c FROM User WHERE Id IN : userIdList];
        
        for (Contact eachContact: cntList) {        
            eachContact.Partner_Portal_Access__c = flag;
            cntToBeUpdated.add(eachContact);
        }
        
        for (User eachUser: userList) {        
            eachUser.Genie_Access__c = flag;
            userToBeUpdated.add(eachUser);
        }
        if(!Test.isRunningTest()){
        System.enqueueJob(new ContactFlagUpdateQueueableJob(cntToBeUpdated,userToBeUpdated));
        }
    }
    
    /*Method to get all the values of Genie Channela User group picklist values in User object */
    public static void getGenieChannelUserGroupsValues() {
        List<String> genieChUsrGroupList = new List<String> ();
        Schema.DescribeFieldResult genieChUserGroups = User.Genie_Channel_User_Groups__c.getDescribe();
        List<Schema.PicklistEntry> values = genieChUserGroups.getPickListValues();
        for (Schema.PicklistEntry v : values) {
            if(v.getValue().contains('Specialized Res')) {
                genieChUsrGroupMap.put('Specialized Reseller',v.getValue());   
            }
            else if(v.getValue().contains('MSP')) {
                genieChUsrGroupMap.put('Managed Services Provider',v.getValue());    
            }
            else if(v.getValue().contains('Global Strategic All')) {
                genieChUsrGroupMap.put('Global Strategic Alliance',v.getValue());    
            }
            else {
                genieChUsrGroupMap.put(v.getValue().mid(v.getValue().lastIndexOf('|')+2,v.getValue().length()),v.getValue());    
            }
        }
    }
    
    /*Method to Genie Channel user group field in user*/
    public static String updateGenieChannelUserGroups(String partnerType,String partnerTier,String region) {
        String genieChannelUserGroup = '';
        String combinedValues = '';
        
        if(partnerType!=null && partnerType!='') {
            combinedValues = partnerType +';';     
        }
        if(partnerTier!=null && partnerTier!='') {
            combinedValues += partnerTier +';';     
        }
        if(region!=null && region!='') {
            combinedValues += region;     
        }
        
        if(combinedValues!=null && combinedValues!=''){
            for(String indv : combinedValues.split(';')){
                if(genieChUsrGroupMap.containsKey(indv)){ 
                    genieChannelUserGroup += genieChUsrGroupMap.get(indv) + ';';    
                }
            }
            if(genieChannelUserGroup.length()> 0) {
                genieChannelUserGroup.substring(genieChannelUserGroup.length()-1);
                return genieChannelUserGroup;
            }
        }
        return '';
    }
    /*
    Partner Portal:
    Genesys Portal Partner                         - LDAP Group: PartnerCommunity, CustomerCommunity
    Custom Gold Partner                            - LDAP Group: PartnerCommunity, CustomerCommunity
    Genesys Portal Potential Partner               - LDAP Group: PartnerCommunity
    Custom Gold Potential Partner                  - LDAP Group: PartnerCommunity
     
    Customer Portal:
    Genesys Portal End User                        - LDAP Group: CustomerCommunity    

    */
    
    public static List<Profile> getPortalProfiles() {
        return [SELECT Id, Name FROM Profile WHERE Name = 'Genesys Portal Partner' OR Name = 'Partner Community Login New' OR Name = 'Genesys Portal Gold Partner'];
    }
    // CUSTOM_POTENTIAL_PARTNER_USER_PROFILE = Genesys Portal Potential Partner
    // POTENTIAL_PARTNER_PROFILE_NAME        = Genesys Portal Potential Partner
    public static List<Profile> getPotentialPortalProfiles() {
        return [SELECT Id, Name FROM Profile WHERE Name =: PartnerPortalUtil.CUSTOM_POTENTIAL_PARTNER_USER_PROFILE OR Name =: PartnerPortalUtil.POTENTIAL_PARTNER_PROFILE_NAME];
    }
    
    // PARTNER_COMMUNITY_LOGIN_NEW_PROFILE = Genesys Portal Partner
    public static List<Profile> getGenesysPortalPartnerProfile() {
        return [SELECT Id, Name FROM Profile WHERE Name =: PartnerPortalUtil.PARTNER_COMMUNITY_LOGIN_NEW_PROFILE];
    } 
   
    //Update Portal user usernames
    public static void updateUserNames(List<User> usrList) {
        // Move the list to the Label ...
        List <String> profileLst = new List<String>{
        'Genesys Portal Gold Partner',
        'Custom Potential Partner User',
        'Genesys Portal End User',
        'Genesys Portal Partner',
        'Genesys Portal Partner - PureConnect',
        'Genesys Portal Partner User',
        'Genesys Portal Potential Partner',
        'Gold Partner User',
        'Partner Community Login New',
        'Partner Community Login User'};
        List<profile> profiles = [Select Id from Profile where name in: profileLst];

        Set<Id> profileIds = new Set<Id>();
        for(Profile p: profiles)
         profileIds.add(p.id);
         
        List<Id> usrIds = new List<Id>();
        for(user usr : usrList){ 
           if(profileIds.contains(usr.profileId) && usr.Email == usr.username) {
               usr.username = usr.email + '.portal.gen';
           }
    }
     }
}