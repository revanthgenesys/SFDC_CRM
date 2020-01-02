/***************************************************************************************************************************************
    Trigger:       	CustCareSkillAfterUpdInsDel
    
    Description:    Calculates the workload score when a skill is changed for a user
    
    Author:         Jeremy Henson                   
****************************************************************************************************************************************/


trigger CustCareSkillAfterUpdInsDel on Customer_Care_Analyst_Skill__c (after insert, after update, after delete, before insert) {

 if(Util.Bypass_Trigger_Chk)return;

	Set<id> userIDsToScore = new Set<Id>{};
	
	List<Customer_Care_Analyst_Skill__c> skills = (trigger.isDelete ? trigger.old : trigger.new);

	if(trigger.isAfter){
		for(Customer_Care_Analyst_Skill__c skill : skills){
			userIDsToScore.add(skill.User__c);
		}
	
		UserWorkload.calculateWorkload(userIDsToScore);
	}
}