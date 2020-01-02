trigger SMLDataMain on SML_Data__c (after update, after insert) {
    if(trigger.isUpdate)
        SMLHelperWTS.SMLDataAfterInsertUpdate(trigger.new, trigger.oldMap);
    else
        SMLHelperWTS.SMLDataAfterInsertUpdate(trigger.new, null); 
}