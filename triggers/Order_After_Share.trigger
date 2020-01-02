trigger Order_After_Share on Order__c (after insert) {
    if(Util.Bypass_Trigger_Chk) 
        return;   
 
    if(Trigger.isAfter && Trigger.isInsert) {
        PartnerPortalCustomSharing.shareOrderWithOpportunityTeam(Trigger.NEW);
    }   
    //Added by navaneetha for order created date updated to opportunity closedate.
   /* if(Trigger.isInsert && Trigger.isAfter){  
    system.debug('TEstnavanee'+ 'ABC1');
        Util.Bypass_Trigger_Chk = true;
        OrderTriggerHandler.updateopportunityclosedate(trigger.new, Trigger.newmap); 
        Util.Bypass_Trigger_Chk = false;    
        
    } */
    // Navaneetha Code Ended. 
}