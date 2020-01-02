trigger SurveyResponseMain on Survey_Response__c (after insert) {
    SurveyResponseMainHelper.createNPSSurveyResponseRecord(trigger.newMap);
}