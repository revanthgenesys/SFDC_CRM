trigger OpportunityAfterDelete on Opportunity (after delete) {
	if(Util.Bypass_Trigger_Chk)return;
System.Debug('## >>> Opportunity After update <<< run by ' + UserInfo.getName());

  //TM02 :  (MLG 02/06/2009) Opportunity TM fields are updated on Account TM fields
        // if Opportunity[Old].BusinessPartner__c <> null
        // Or if Opportunity[Old].Country__c <> null
    if(Util.canTrigger('TM02'))
    {
        System.Debug('## TM02 begin prepare');
        Opportunity [] TM02Opportunities=new Opportunity[]{};   
      
      for(Integer i = (Trigger.old.size()-1); i >=0 ; i--) 
      {
        System.debug('## OpportunityId:'+ Trigger.old[i].Id);
        System.debug('## Opportunity.BusinessPartner__c :'+ Trigger.old[i].BusinessPartner__c );
        System.debug('## Opportunity.Country__c :'+ Trigger.old[i].Country__c );
        if(Trigger.old[i].BusinessPartner__c <> null || Trigger.old[i].Country__c <> null )
        {
            TM02Opportunities.add(Trigger.old[i]);
        }
      
      } 
        System.Debug('## TM02 end prepare');  
        if(TM02Opportunities.size()>0){   
            TM02Opportunity.addLstOptyFieldValuesOnAccount(TM02Opportunities);
        }else System.Debug('## TM02 no Opportunities to treat on '+Trigger.old.size()+' opportunities');
     }//bypass
     
}