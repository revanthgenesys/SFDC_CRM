trigger OQM_FormAfterUpdate on OQM_Form__c (after update) {
if(Util.Bypass_Trigger_Chk)return;
// Create a list of opportunities to update 
 List <Opportunity> ListOppty = new List<Opportunity> ();
 
 // Fetch OQM record updated
 for (Integer i = 0; i < Trigger.New.size(); i++) {
    // Keep OQM which have OfferMade field modified
    if (Trigger.old[i].OfferMade__c != Trigger.new[i].OfferMade__c) {
        
        // Modify related opportunity stage field 
        Opportunity newOpp = new Opportunity(id = Trigger.new[i].OpportunityName__c);
        newOpp.StageName = Config.OPP_STAGE4;
        // Add modified opportunity to ListOppty
        ListOppty.add(newOpp);
        }
 }

//Update opportunities list
 update ListOppty ;
}