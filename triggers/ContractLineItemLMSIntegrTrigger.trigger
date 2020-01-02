trigger ContractLineItemLMSIntegrTrigger on ContractLineItem (after delete, after insert, after update) {
	
	if(Util.Bypass_Trigger_Chk)return;
    
    Set<Id> accntIdSet = new Set<Id>();
    
    if (Trigger.isUpdate) {
    	
    	for (ContractLineItem li : Trigger.new) {
    		
    		Boolean isPC = Trigger.oldMap.get(li.Id).isPureConnectPrem__c;
    		Boolean wasPC = li.isPureConnectPrem__c;
 		
    		if ( !isPC && !wasPC )
    		    continue;
    		    
    		if ( Trigger.oldMap.get(li.Id).Upgraded_Product__c != li.Upgraded_Product__c ||   
    		     Trigger.oldMap.get(li.Id).Current_Quantity__c != li.Current_Quantity__c ||
    		     Trigger.oldMap.get(li.Id).Maintenance_Start_Date__c != li.Maintenance_Start_Date__c ||
    		     Trigger.oldMap.get(li.Id).Maintenance_End_Date__c != li.Maintenance_End_Date__c ||
    		     Trigger.oldMap.get(li.Id).Non_Billable__c != li.Non_Billable__c )  {
    		     	
    		     	accntIdSet.add(li.End_User_Id__c);    		     	
    		     }   		
    	}    		    	
    }
    
    if (Trigger.isInsert)  {
    	for (ContractLineItem li : Trigger.new) {
    		if ( li.isPureConnectPrem__c )
    		   accntIdSet.add(li.End_User_Id__c);    		
    	}
    }
    
    if (Trigger.isDelete)  {
    	for (ContractLineItem li : Trigger.old) {
    		if ( Trigger.oldMap.get(li.Id).isPureConnectPrem__c )
    		   accntIdSet.add(li.End_User_Id__c);    		
    	}
    }
    
    if ( ! accntIdSet.isEmpty() )
  	  LMSIintegrationService.putAccountsInLMSQueueById(new List<Id>(accntIdSet));
        
}