/*
* @Name: LeadTrigger
* @Desc: Trigger for the Lead Object.
* @Author: Rohit Mehta
* @Date: 11/16/2012
*/

/*
* TODO: We should merge all the lead triggers into this trigger
*/
trigger LeadTrigger on Lead (after insert, after update) {

    if (Trigger.isInsert) {
    	if (Trigger.isAfter) {
	    	LeadTriggerActions.doAfterInsert(Trigger.new);
    	}
    }

    if (Trigger.isUpdate) {
    	if (Trigger.isAfter) {
	    	LeadTriggerActions.doAfterUpdate(Trigger.oldMap, Trigger.newMap);
    	}
    }

}