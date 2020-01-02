trigger SMLAccountEngagementScoreMain on SML_Account_Engagement_Score__c (before update) {
    SMLHelperWTS.updateAccountEngScorePositiveNegativeStatus(trigger.new, trigger.oldMap);
}