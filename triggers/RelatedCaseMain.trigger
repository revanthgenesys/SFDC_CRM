trigger RelatedCaseMain on Related_Case__c (after insert) {

    if(Util.Bypass_Trigger_Chk)return;
    
     RelatedCaseInsertUpdateHandler.updateRelatedCaseFields(Trigger.new);

}