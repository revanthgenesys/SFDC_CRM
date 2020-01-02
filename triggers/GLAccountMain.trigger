/*
* Added By: Ashish Goyal (08/30/2018)
* Desc: Update Blackout Period field
*/
trigger GLAccountMain on GL_Account__c (before insert, before update, after insert, after update) {
    if (Util.Bypass_Trigger_Chk) return;
    
    if(Trigger.isBefore) {
	    if(Trigger.isUpdate) {
	        FinanceMDMTriggerHelper.preventRecordFromSameApprover(trigger.newMap);
	    }
	    
	    FinanceMDMTriggerHelper.checkDuplicateGLIdOrDescription(trigger.new);
	    FinanceMDMTriggerHelper.updateGlAccount(trigger.new, trigger.oldMap);
    }
    
    if (Trigger.isAfter) {
    	FinanceMDMTriggerHelper.synchGLAccountHierarchies(trigger.newMap);
    }
}