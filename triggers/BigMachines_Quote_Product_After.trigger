trigger BigMachines_Quote_Product_After on BigMachines__Quote_Product__c (after insert, after update) {
	if(Util.Bypass_Trigger_Chk)return;
	// only insert splits if the opp record type is renewal
	if(trigger.isInsert){
		Set<Id> quoteIds = new Set<Id>();
		for(BigMachines__Quote_Product__c q : trigger.new)
			quoteIds.add(q.BigMachines__Quote__c);
		map<Id, BigMachines__Quote__c> quotesMap = new Map<Id, BigMachines__Quote__c>([Select Id, BigMachines__Opportunity__r.RecordType.DeveloperName 
																					from BigMachines__Quote__c where ID in : quoteIds]);
		List<BigMachines__Quote_Product__c> products = new List<BigMachines__Quote_Product__c>();
	    List<BigMachines__Quote_Product__c> productsToCreateRDs = new List<BigMachines__Quote_Product__c>();
		
		quoteIds.clear();																					
		for(BigMachines__Quote_Product__c q : trigger.new){
			Id quoteId = q.BigMachines__Quote__c;
			if(quotesMap.get(quoteId).BigMachines__Opportunity__r.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME){ 
				if( q.Contract_Line_Update_Status__c != null && ((q.Current_Qty__c > 0 && q.Current_Qty__c < q.Original_Qty__c) || 
																( q.Current_Qty__c==0 && q.Contract_Line_Update_Status__c.equalsIgnoreCase('Drop'))))
					products.add(q);
				quoteIds.add(q.BigMachines__Quote__c);
				//if( q.Maintenance_End_Date__c!= null && q.Maintenance_Start_Date__c != null )
					//productsToCreateRDs.add(q);
				//else q.addError('Please add Maintenance Start and End Date on Quote Products');
			}
		}
		if(!products.isEmpty())
			QuoteProductUtil.createContractLineSplits( products );
		if(!quoteIds.isEmpty())
			QuoteProductUtil.updateQuotes(quoteIds);
		//if(!productsToCreateRDs.isEmpty())
	    	//QuoteProductUtil.createRevenueDistributions( productsToCreateRDs );
	}
	
	if(trigger.isUpdate && TriggerFlowManager.QUOTEPRODUCT_AFTER_UPDATE_TRIGGER){
	    List<BigMachines__Quote_Product__c> productsToSplit = new List<BigMachines__Quote_Product__c>();
	    Set<Id> quoteIds = new Set<Id>();
		for(BigMachines__Quote_Product__c q : trigger.new)
			quoteIds.add(q.BigMachines__Quote__c);
		map<Id, BigMachines__Quote__c> quotesMap = new Map<Id, BigMachines__Quote__c>([Select Id, BigMachines__Opportunity__r.RecordType.DeveloperName 
																					from BigMachines__Quote__c where ID in : quoteIds]);
		quoteIds.clear();
	    for(BigMachines__Quote_Product__c prod : trigger.new){
	        BigMachines__Quote_Product__c oldQp = trigger.OldMap.get(prod.Id);
	       
    		if(quotesMap.get(prod.BigMachines__Quote__c).BigMachines__Opportunity__r.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME ){
				if((prod.Current_Qty__c != oldQp.Current_Qty__c && prod.Current_Qty__c > 0 && prod.Current_Qty__c < prod.Original_Qty__c) 
					|| (prod.Status__c != oldQp.Status__c))
	        			productsToSplit.add(prod);
    			quoteIds.add(prod.BigMachines__Quote__c);
			}
	    }
	    
	    if(!productsToSplit.isEmpty())
		    QuoteProductUtil.createContractLineSplits( productsToSplit );
		if(!quoteids.isEmpty())
			QuoteProductUtil.updateQuotes( quoteIds );
		TriggerFlowManager.QUOTEPRODUCT_AFTER_UPDATE_TRIGGER = false;		
	}
}