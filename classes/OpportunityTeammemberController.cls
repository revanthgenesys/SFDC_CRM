//R Systems Controller for the vf page OpportunityTeamMember>page
public class OpportunityTeammemberController {

    // will contain all the OpportunityTeamMember for a particular opportunities
    public List<OpportunityTeamMember> oppTeamMember{get;set;}
  
    //Constructor
    public OpportunityTeammemberController(ApexPages.StandardController stdCtrl){
    
        if(stdCtrl.getId()  != null){
            oppTeamMember = [SELECT Name, TeamMemberRole, OpportunityAccessLevel FROM OpportunityTeamMember where OpportunityId=:stdCtrl.getId()];
        }  
    }
}