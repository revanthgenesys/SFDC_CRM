public class AssignContactsUsingRRTeam
{
    @InvocableMethod
    public static void ContactAssign(List<Id> ContactIds)
    {
            integer newNumber_of_Prospects_Assigned;
            integer assigneeOffset;
            integer currentRRTeamMemberOffset;
            Id AssigneeUser;
            
                        
            List<Contact> contacts=[select id, OwnerId, Lead_Development_Rep__c, RR_Team__c, hot_lead__c from contact where contact.id in :ContactIds];
            Set<Id> rrTeamIds = new Set<Id>();
            For (Contact c: contacts) 
            {
                rrTeamIds.add(c.RR_Team__c);
            }
            List<RR_Team__c> rrTeams=[select id, Number_of_Prospects_Assigned__c, Number_of_Prospects_Assigned_Hot__c, Member_Count__c, User_Lookup_Field__c  from RR_Team__c where RR_Team__c.Id in :rrTeamIds];
            List<RR_Team_Member__c> rrTeamMembers=[select id, Name, RR_Team__c, Available__c, Assignee_User__c from RR_Team_Member__c where RR_Team_Member__c.RR_Team__c in :rrTeamIds and RR_Team_Member__c.Available__c = true order by RR_Team_Member__c.RR_Team__c ASC, RR_Team_Member__c.Name ASC];
                
            For (Contact c: contacts) 
            {
                
                For (RR_Team__c rrTeam: rrTeams) {
                    if (c.RR_Team__c == rrTeam.Id) {
                        
                        If (c.hot_lead__c != null && c.hot_lead__c > (date.today().addDays(-7))) 
                        {
                            if (rrTeam.Number_of_Prospects_Assigned_Hot__c == null)
                            {
                                newNumber_of_Prospects_Assigned = 1;
                            } else {
                                newNumber_of_Prospects_Assigned= rrTeam.Number_of_Prospects_Assigned_Hot__c.intValue() + 1;
                            }                    
                            rrTeam.Number_of_Prospects_Assigned_Hot__c= newNumber_of_Prospects_Assigned;
                            
                        } else {
                            if (rrTeam.Number_of_Prospects_Assigned__c == null)
                            {
                                newNumber_of_Prospects_Assigned = 1;
                            } else {
                                newNumber_of_Prospects_Assigned= rrTeam.Number_of_Prospects_Assigned__c.intValue() + 1;
                            }                    
                            rrTeam.Number_of_Prospects_Assigned__c= newNumber_of_Prospects_Assigned;
                        }
                        
                        system.debug('>>>>>newNumber_of_Prospects_Assigned = '+ newNumber_of_Prospects_Assigned);
                        system.debug('>>>>>rrTeam.Member_Count__c.intValue() = '+ rrTeam.Member_Count__c.intValue());
                        assigneeOffset = Math.mod( newNumber_of_Prospects_Assigned - 1, rrTeam.Member_Count__c.intValue() );
                        currentRRTeamMemberOffset = 0;
                        AssigneeUser = null;
                        
                        For (RR_Team_Member__c rrTeamMember: rrTeamMembers) {
                            if (rrTeamMember.RR_Team__c == c.RR_Team__c) {
                                if ( currentRRTeamMemberOffset >= assigneeOffset) {
                                    AssigneeUser = rrTeamMember.Assignee_User__c;
                                    break;
                                }
                                currentRRTeamMemberOffset = currentRRTeamMemberOffset + 1;
                            }
                        }
                                                
                        if (rrTeam.User_Lookup_Field__c == 'Journey Engagement Rep')
                        {
                           c.Journey_Engagement_Rep__c = AssigneeUser;
                        }
                  
                        //Only update owner if owner matches previous Lead_Development_Rep__c
                        if (c.OwnerId == c.Lead_Development_Rep__c) {
                            c.OwnerId = AssigneeUser;
                        }
                        
                        c.Lead_Development_Rep__c = AssigneeUser;
                        c.RR_Team__c = null;
                                                
                        break;
                    }
                }                                
            }
    update contacts;           
    update rrTeams;
   }
}