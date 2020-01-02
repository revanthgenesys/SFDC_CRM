trigger LeadCountryCopy on Lead (before insert, before update){

system.debug('++++Country__c+++'+trigger.new[0].Country__c);
system.debug('++++country+++'+trigger.new[0].Country);

if(Trigger.isInsert)
{
    if(trigger.isBefore && trigger.new[0].Country != null)
    {
      List<Country__c>list_Contry = [Select id from Country__c where name =:trigger.new[0].Country];
      if(list_Contry.size()>0 && list_Contry != null)
       trigger.new[0].Country__c = list_Contry[0].id;
    }
}


ID userid = UserInfo.getUserId();
for(Lead ld : trigger.new){
if(ld.Country_From_Silverpop__c != null && userid == '005U0000000eECvIAM'){
ld.Country__c = ld.Country_From_Silverpop__c;
} else if (ld.Country_From_Silverpop__c != null && userid != '005U0000000eECvIAM'){
ld.Country_From_Silverpop__c = ld.Country__c;
}
}
}