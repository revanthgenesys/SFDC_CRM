//Naresh Kumar  04/11/2017
public without sharing class PartnerOpportunityHelper {
    //populates partner opportunity details
    public static void populatePartnerOpportunityOnInsert(List<Opportunity> newOppList){
        //return if not partner user
        if(UserInfo.getUserType() != 'PowerPartner')
            return;
        //getting contact id
        Id contactId = [SELECT contactid FROM User WHERE id =: Userinfo.getUserid()].contactId;        
        //getting account details
        List<Account> endUserAccount = [SELECT id, Channel_Manager__c, OwnerId, Region__c FROM Account WHERE id 
                IN (SELECT AccountId FROM Contact WHERE id =: contactId)];
        if(endUserAccount.isEmpty())
            return;
        Id teamMemberId1; 
        Id oppOwnerId;
        //Channel manager is owner in case of NA
        if(endUserAccount[0].Region__c == 'North America'){            
            teamMemberId1 = endUserAccount[0].ownerId;
           // oppOwnerId = endUserAccount[0].Channel_Manager__c;
            oppOwnerId = endUserAccount[0].ownerId;
        }
        //AE is owner in case region is not NA
        else{            
            teamMemberId1 = endUserAccount[0].Channel_Manager__c;
            oppOwnerId = endUserAccount[0].ownerId;
        }
        //list of opportunities to be updated
        List<Opportunity> list_OfOppsToBeUpdated = new List<Opportunity>();
        //list of opportunity team
        List<OpportunityTeamMember> list_OfOppTeamToBeInserted = new List<OpportunityTeamMember >();
        //Looping over each Opportunity
        for(Opportunity eachObjOpp : newOppList){            
            Opportunity oppToBeUpdated = new Opportunity(id = eachObjOpp.id);
            oppToBeUpdated.Lines_of_Businesses__c = 'PureConnect';
            if(eachObjOpp.Type == 'New logo'){
                oppToBeUpdated.AccountId = endUserAccount[0].id;
                oppToBeUpdated.OwnerId = oppOwnerId;
            }
            oppToBeUpdated.Direct_Indirect_Sale__c = 'Indirect';
            //team member 1 - Channel Manager or AE
            list_OfOppTeamToBeInserted.add(new OpportunityTeamMember (UserId = UserInfo.getUserId(), 
                                                                OpportunityId = eachObjOpp.id,
                                                                OpportunityAccessLevel = 'Edit',
                                                                TeamMemberRole = 'Update'));
            if(teamMemberId1 != null){
                //team member 2 - current user
                list_OfOppTeamToBeInserted.add(new OpportunityTeamMember(UserId = teamMemberId1, 
                                                                OpportunityId = eachObjOpp.id,
                                                                OpportunityAccessLevel = 'Edit',
                                                                TeamMemberRole = 'Update'));   
            }
            list_OfOppsToBeUpdated.add(oppToBeUpdated);
        }                
        //updates opportunity
        update list_OfOppsToBeUpdated;        
        //inserts opportunity team
        insert list_OfOppTeamToBeInserted;
    }
    
    
    /*
    * Added By: Ashish Goyal (08/16/018)
    * Desc: To manage the Opportunity Team Member whenever Solt To/Business Partner is populated/updated on the Opportunity
    * Requested By: Debbie
    */
    public static void addOpportunityTeamMember(List<opportunity> list_Oppty, Map<Id, Opportunity> map_OldOppty, boolean isInsert){
        Map<Id, Id> map_OpptyIdLPartnerId = new Map<Id, Id>();
        Map<Id, Id> map_OpptyIdLPartnerIdDelete = new Map<Id, Id>();
        for(Opportunity opp : list_Oppty){
            if((isInsert && opp.BusinessPartner__c != null) || (!isInsert && opp.BusinessPartner__c != map_OldOppty.get(opp.Id).BusinessPartner__c)){
                if(!isInsert && map_OldOppty.get(opp.Id).BusinessPartner__c != null){
                    map_OpptyIdLPartnerIdDelete.put(opp.Id, map_OldOppty.get(opp.Id).BusinessPartner__c);
                }
                if(opp.BusinessPartner__c != null){
                    map_OpptyIdLPartnerId.put(opp.Id, opp.BusinessPartner__c);
                }
            }
        }
        
        if(map_OpptyIdLPartnerId.size() > 0){
            Map<Id, Set<Id>> map_AccountIdListUserId = new Map<Id, Set<Id>>();
            for(User usr : [SELECT Id, Contact.AccountId FROM User WHERE Contact.AccountId IN: map_OpptyIdLPartnerId.values() AND Contact.Designated_Partner_Contact__c = true]){
                if(!map_AccountIdListUserId.containsKey(usr.Contact.AccountId)){
                    map_AccountIdListUserId.put(usr.Contact.AccountId, new Set<Id>());
                }
                map_AccountIdListUserId.get(usr.Contact.AccountId).add(usr.Id);
            }
            if(map_AccountIdListUserId.size() > 0){
                List<OpportunityTeamMember> list_OppotyTeamMemberNew = new List<OpportunityTeamMember>();
                for(Id opptyId : map_OpptyIdLPartnerId.keySet()){
                    Id accId = map_OpptyIdLPartnerId.get(opptyId);
                    if(map_AccountIdListUserId.containsKey(accId)){
                        for(Id usrId : map_AccountIdListUserId.get(accId)){
                            OpportunityTeamMember opptyTeam = new OpportunityTeamMember();
                            opptyTeam.OpportunityId = opptyId;
                            opptyTeam.UserId = usrId;
                            opptyTeam.TeamMemberRole = 'Designated Partner Contact';
                            opptyTeam.OpportunityAccessLevel = 'Edit';
                            list_OppotyTeamMemberNew.add(opptyTeam);
                        }
                    }
                }
                
                if(list_OppotyTeamMemberNew.size() > 0){
                    insert list_OppotyTeamMemberNew;
                }
            }
        }
        
        if(map_OpptyIdLPartnerIdDelete.size() > 0){
            List<User> usrList = new List<User>([SELECT Id FROM User 
                                                    WHERE Contact.AccountId IN: map_OpptyIdLPartnerIdDelete.values() 
                                                        AND Contact.Designated_Partner_Contact__c = true]);
                                                        
            List<OpportunityTeamMember> list_OppotyTeamMemberNew = new List<OpportunityTeamMember>([SELECT Id FROM OpportunityTeamMember 
                                                                                                        WHERE OpportunityId IN: map_OpptyIdLPartnerIdDelete.keySet()
                                                                                                        AND UserId IN: usrList]);
            if(list_OppotyTeamMemberNew.size() > 0){
                delete list_OppotyTeamMemberNew;
            }
        }
    }
}