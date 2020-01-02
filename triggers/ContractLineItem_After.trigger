trigger ContractLineItem_After on ContractLineItem (after insert, before insert, after update) {
    if(Util.Bypass_Trigger_Chk)return;
    if(trigger.isInsert && trigger.isAfter){
        ServiceContractUtil.createAssets(trigger.new);
        ServiceContractUtil.createEntitlements(trigger.new);        
        SendEmailNotificationForPSSC.sendEmailAlert(trigger.new, false);
    }
    if(trigger.isUpdate && trigger.isAfter){
      SendEmailNotificationForPSSC.sendEmailAlert(trigger.new, true);
    }

    //Naresh Kumar	12/15/2015	SML Data Update 
    if(TriggerFlowManager.CONTRACT_LINEITEM_SML_UPDATE && !System.isFuture() && !System.isBatch() 
    	&& trigger.isAfter){
    	TriggerFlowManager.CONTRACT_LINEITEM_SML_UPDATE = false;
    	if(trigger.isDelete)
			SMLHelperWTS.runSMLUpdateForServiceContract(trigger.old);
		else		
			SMLHelperWTS.runSMLUpdateForServiceContract(trigger.new);
	}    
}