trigger Provide_Quote_Access on OpportunityTeamMember (after delete, after insert, after update, 
before delete, before insert, before update) {
if(Util.Bypass_Trigger_Chk)return;
}