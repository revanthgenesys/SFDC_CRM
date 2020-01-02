trigger LeadCampaignSourceCopyBeforeUpdate on Lead (before insert, before update) {
ID userid = UserInfo.getUserId();
for(Lead ld : trigger.new){
if(ld.Campaign_Source__c == null && ld.Campaign_Source_From_SP__c != null && userid == '005U0000000eECvIAM'){ld.Campaign_Source__c = ld.Campaign_Source_From_SP__c;} 
else if (ld.Campaign_Source__c == null && ld.Campaign_Source_From_SP__c != null && userid != '005U0000000eECvIAM'){ld.Campaign_Source_From_SP__c = ld.Campaign_Source__c;}
}
}
//comment