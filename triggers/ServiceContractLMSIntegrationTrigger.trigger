trigger ServiceContractLMSIntegrationTrigger on ServiceContract (after update) {
 
    if(Util.Bypass_Trigger_Chk)return;
    
    /// insert is covered by trigger ContractLineItemLMSIntegrTrigger
    if (Trigger.isUpdate) {
    	List<Id> termChangeAccntIDs = new List<Id>();
    	Set<Id> EndUserChangeAccntIDs = new Set<Id>();
    	List<ServiceContract> termChangedContracts = new List<ServiceContract>();
    	
    	for (ServiceContract sc : Trigger.new) {
    		/// status change
    		Boolean wasActive = LMSIintegrationService.isContractActive(Trigger.oldMap.get(sc.Id).Agreement_Status__c);
    		Boolean isActive = LMSIintegrationService.isContractActive(sc.Agreement_Status__c);
    		
    		Boolean startDateChanged = (sc.StartDate == Trigger.oldMap.get(sc.Id).StartDate ? false : true);
    		Boolean endDateChanged = (sc.EndDate == Trigger.oldMap.get(sc.Id).EndDate ? false : true);
    		
    		if ( isActive != wasActive ||
    		     isActive && (startDateChanged || endDateChanged) )
    				termChangedContracts.add(sc);  
    		
    		/// End User change	
    		Id oldEndUserId = Trigger.oldMap.get(sc.Id).End_User_Name__c;
    		Id newEndUserId = sc.End_User_Name__c;
    		
    		if ( oldEndUserId != newEndUserId ) {
    			if ( oldEndUserId != null )
    			   EndUserChangeAccntIDs.add(oldEndUserId);
    			   
    			if ( newEndUserId != null )
    			   EndUserChangeAccntIDs.add(newEndUserId);
    		}
    		   	
    	}
    	
    	if ( ! termChangedContracts.isEmpty() ) 
    	     termChangeAccntIDs = LMSIintegrationService.lmsAccountsFromContracts(termChangedContracts);  
    	     
    	Set<Id> acctIDs = new Set<Id>();
    	acctIDs.addAll(termChangeAccntIDs);
    	acctIDs.addAll(EndUserChangeAccntIDs);
    	
    	if ( !acctIDs.isEmpty() )  
    	   LMSIintegrationService.putAccountsInLMSQueueById( new List<Id>(acctIDs) );
    	
    }
      
}