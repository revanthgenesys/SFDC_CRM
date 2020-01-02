trigger CampaignMemberTrigger on CampaignMember (after insert, after update, after delete) {

    if (Trigger.isInsert) {
        if (Trigger.isAfter) {
            CampaignMemberTriggerActions.doAfterInsert(Trigger.new);
        }
    }

    if (Trigger.isUpdate) {
        if (Trigger.isAfter) {
            CampaignMemberTriggerActions.doAfterUpdate(Trigger.oldMap, Trigger.new);
        }
    }

    if (Trigger.isDelete) {
        if (Trigger.isAfter) {
            CampaignMemberTriggerActions.doAfterDelete(Trigger.old);
        }
    }

}