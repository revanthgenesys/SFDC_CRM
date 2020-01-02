trigger creditMemoNewTrigger on Credit_Memo__c (before insert, before update, after insert, after update) {

    if (Util.Bypass_Trigger_Chk) 
        return;

    if(trigger.isInsert || trigger.isUpdate){
        CreditMemoTriggerHandler.beforeInsert(trigger.new, trigger.oldMap, trigger.isUpdate, trigger.isAfter);
    }
    
     if(trigger.isBefore && trigger.isUpdate){
        CreditMemoTriggerHandler.validation(trigger.new,trigger.oldMap);
    }
}