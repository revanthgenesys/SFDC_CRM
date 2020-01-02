public class AssignLeadsUsingRRTeam
{
    @InvocableMethod
    public static void LeadAssign(List<Id> LeadIds)
    {
        integer newNumber_of_Prospects_Assigned;
        integer assigneeOffset;
        integer currentRRTeamMemberOffset;
        Id AssigneeUser;
        
                    
        List<Lead> leads=[select id, OwnerId, RR_Team__c, hot_lead__c from lead where lead.id in :LeadIds];
        Set<Id> rrTeamIds = new Set<Id>();
        For (Lead c: leads) 
        {
            rrTeamIds.add(c.RR_Team__c);
        }
        List<RR_Team__c> rrTeams=[select id, Number_of_Prospects_Assigned__c, Number_of_Prospects_Assigned_Hot__c, Member_Count__c, User_Lookup_Field__c  from RR_Team__c where RR_Team__c.Id in :rrTeamIds];
        List<RR_Team_Member__c> rrTeamMembers=[select id, Name, RR_Team__c, Available__c, Assignee_User__c from RR_Team_Member__c where RR_Team_Member__c.RR_Team__c in :rrTeamIds and RR_Team_Member__c.Available__c = true order by RR_Team_Member__c.RR_Team__c ASC, RR_Team_Member__c.Name ASC];
            
        For (Lead l: leads) 
        {
        
            For (RR_Team__c rrTeam: rrTeams) {
                
                if (rrTeam.Id == l.RR_Team__c) {
            
                    If (l.hot_lead__c != null && l.hot_lead__c > (date.today().addDays(-7))) 
                    {
                        if (rrTeam.Number_of_Prospects_Assigned_Hot__c== null)
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
                    
                    assigneeOffset = Math.mod( newNumber_of_Prospects_Assigned - 1, rrTeam.Member_Count__c.intValue() );
                    currentRRTeamMemberOffset = 0;
                    AssigneeUser = null;
                            
                    For (RR_Team_Member__c rrTeamMember: rrTeamMembers) {
                        if (rrTeamMember.RR_Team__c == l.RR_Team__c) {
                            if ( currentRRTeamMemberOffset >= assigneeOffset) {
                                AssigneeUser = rrTeamMember.Assignee_User__c;
                                break;
                            }
                            currentRRTeamMemberOffset = currentRRTeamMemberOffset + 1;
                        }
                    }
                          
                    
                    if (rrTeam.User_Lookup_Field__c == 'Journey Engagement Rep')
                    {
                       l.Journey_Engagement_Rep__c = AssigneeUser;
                    } else if (rrTeam.User_Lookup_Field__c == 'Journey Manager')
                    {
                        l.LDR__c = AssigneeUser;
                    }
              
                    
                    l.OwnerId = AssigneeUser;
                    l.RR_Team__c = null;
                    
                    break;
                
                }
            }
        }   
        update leads;
        update rrTeams;
   }
}