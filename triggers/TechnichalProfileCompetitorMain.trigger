trigger TechnichalProfileCompetitorMain on Technical_Profile_Competitors__c (after insert, after update, after delete, before update, before insert) {
    if(Util.Bypass_Trigger_Chk)return;
    if(trigger.isAfter){
        if(trigger.isDelete)
            SMLHelperWTS.runSMLUpdateForBlocked(trigger.old);
        else
            SMLHelperWTS.runSMLUpdateForBlocked(trigger.new);
    }
    else{
        SMLHelperWTS.populateAccountSCKey(trigger.new);
    }
}