//Naresh Kumar  08/26
trigger CostCenterMain on Cost_Center__c (before insert, before update) {
    if (Util.Bypass_Trigger_Chk) return;
    
    if(Trigger.isBefore){
    	
    	   //Update the SFDC Record Name
	    for(Cost_center__C obj : trigger.new)
	    {
	        obj.Name = obj.Cost_Center_ID1__c +'-'+ obj.description__C;
	    }
    
        if(Trigger.isInsert)
            FinanceMDMTriggerHelper.onBeforeInsertCC(trigger.new); 
        if(Trigger.isUpdate){
            FinanceMDMTriggerHelper.preventRecordFromSameApprover(trigger.newMap);
            FinanceMDMTriggerHelper.onBeforeUpdateCC(trigger.new, trigger.oldMap);
            
            FinanceMDMTriggerHelper.synchCostCenterHierarchies(trigger.oldMap, trigger.newMap);
        }
    }

}