trigger Quote_Share on BigMachines__Quote__c (after insert) {

List<OpportunityTeamMember> oppTeam = [Select UserId, OpportunityAccessLevel  From OpportunityTeamMember Where 
    OpportunityId =: trigger.new[0].BigMachines__Opportunity__c];  
    
List<BigMachines__Quote__Share> quote_share_lst = new List<BigMachines__Quote__Share>();

if(oppTeam.size()>0){
                    for(OpportunityTeamMember otm_obj : oppTeam){
                BigMachines__Quote__Share Quote_Share = new BigMachines__Quote__Share();
                Quote_Share.ParentId = trigger.new[0].id;
                Quote_Share.UserOrGroupId = otm_obj.UserId;
                Quote_Share.AccessLevel = otm_obj.OpportunityAccessLevel;
                Quote_Share.RowCause = Schema.BigMachines__Quote__Share.RowCause.Sales_Team_Access__c;
                quote_share_lst.add(Quote_Share);
                  }           
            
  
               List<Database.SaveResult> sr = Database.insert(quote_share_lst,false);
    }

}