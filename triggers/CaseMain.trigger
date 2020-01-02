/*
Case Relationship
04/15/2013    Naresh Kumar    Original for Task/Story #   
Description : This trigger will be entry point for all types of events and won't have any code written directly in it. 
              Please use static class to put your code in.
*/
trigger CaseMain on Case (before insert, after insert, before update, after update, before delete ) {

 if(Util.Bypass_Trigger_Chk)return;

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
        FR_FieldUpdate.updateFRFields(Trigger.new, Trigger.oldMap);   
    }
    if(Trigger.isAfter && ( Trigger.isInsert || Trigger.isUpdate) && TriggerFlowManager.CASE_IMPORTSCORE_FIELD_UPDATES){
        ImportantScoreHandler.updateIsOpenEscalationOnAccount(Trigger.newMap, Trigger.oldMap, Trigger.isInsert);
    }
    if( Trigger.isAfter && Trigger.isUpdate ){
    	SoundBite.sendInfoToSoundBite(Trigger.new, Trigger.oldMap);
    }
}