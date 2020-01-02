//Naresh Kumar  04/04/2014
trigger DocuSignStatusMain on dsfs__DocuSign_Status__c (after insert, after update, before insert, 
before update) {
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate)){
        if(trigger.isInsert){
            DocuSignMainTriggerHelper.generateServiceContract(trigger.newMap, null);
            //DocuSignMainTriggerHelper.updateGCRContentDocument(trigger.newMap, null);
        }
        if(trigger.isUpdate){
            DocuSignMainTriggerHelper.generateServiceContract(trigger.newMap, trigger.oldMap);
            //DocuSignMainTriggerHelper.updateGCRContentDocument(trigger.newMap, null);
        }         
    }
}