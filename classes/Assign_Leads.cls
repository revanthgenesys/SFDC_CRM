public class Assign_Leads{
    //declaring variable to determine whether to update or not
    public static Boolean assignAlreadyCalled = false;

    public static boolean assignAlreadyCalled(){
    	return assignAlreadyCalled;
    }
    // An asynchronous update was necessary because the trigger that utilizes
    // this method updates on the same sObject which throws an exception.
    @future    
    // This is the method that updates our leads.  It takes a List var.
    public static void assign(List<Id> lIds){    
	    // Set to true to prevent re-calling the method infinitely
	    assignAlreadyCalled = true;	    
	    // Grabs all Lead IDs from the trigger for updates.
	    List<Lead> leads = [SELECT Id, Call_Lead_Assignment__c, Call_Premier_Lead_Assignment__c FROM Lead WHERE Id IN: lIds];
	    List<AssignmentRule> assignmentRules = [SELECT id, Name FROM AssignmentRule WHERE SObjectType = 'Lead'];
	    AssignmentRule coreLeadAssignmentRule, new2014TLD;
	    for(AssignmentRule eachRule : assignmentRules){
	    	if(eachRule.Name == '2014 Territory Lead Distro')
	    		new2014TLD = eachRule;
	    	else if(eachRule.Name == 'Core - Lead Assignments')
	    		coreLeadAssignmentRule = eachRule;
	    }
	    for(Lead eachLead : leads){	    	
	        Database.DMLOptions dmo = new Database.DMLOptions();
	        if(eachLead.Call_Lead_Assignment__c){
	        	dmo.assignmentRuleHeader.useDefaultRule = true;	        	
	        }
	        else if(eachLead.Call_Premier_Lead_Assignment__c){
	        	dmo.assignmentRuleHeader.assignmentRuleId = new2014TLD.id;	        	
	        }
	        eachLead.setOptions(dmo);
	        // Returns the Call_Lead_Assignment__c checkbox to false to stop the trigger from
	        // recursive updates.
	        eachLead.Call_Lead_Assignment__c = false;
	        eachLead.Call_Premier_Lead_Assignment__c = false;
	    }
	    update leads;
  }

}