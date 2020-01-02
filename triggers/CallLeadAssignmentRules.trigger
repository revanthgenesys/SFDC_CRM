trigger CallLeadAssignmentRules on Lead (before update){

// This will grabs all the Leads that have the checkbox Checked
List<Id> leadIds = new List<Id>();
    for(Lead eachLead : Trigger.new){
        if(eachLead.Call_Lead_Assignment__c || eachLead.Call_Premier_Lead_Assignment__c){
        	leadIds.add(eachLead.Id);
        }            
    }

// This part pushes all IDs from above to our class 'Assign_Leads' and then uses
// its method to run Lead Assignments   
    if (Assign_Leads.assignAlreadyCalled()==FALSE){
        // system.debug is a message if this was already done (if the checkbox is false)
        // we could probably go without that line actually
        // system.debug('Assign already called?' + Assign_Leads.assignAlreadyCalled());
        // Calling the method to do the assignments
        if(!leadIds.isEmpty())
        	Assign_Leads.Assign(leadIds);
    }
}