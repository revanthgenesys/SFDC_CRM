public with sharing class RemoveDeletedReferences {
	
	public static void getDeletedOrderIds(String orderId){
		List<Order_Line_Item__c> orderLines = [SELECT id, Service_Contract_Line_ID__c FROM Order_Line_Item__c WHERE Order__c =: orderId];
		Map<Id, Order_Line_Item__c> mapContractIdVsOLI = new Map<Id, Order_Line_Item__c>();
		for(Order_Line_Item__c eachOLI : orderLines){
			if(eachOLI.Service_Contract_Line_ID__c != null)
				mapContractIdVsOLI.put(eachOLI.Service_Contract_Line_ID__c, eachOLI);
		}
		
		Map<Id, ContractLineItem> mapIdVsCLI = new Map<Id, ContractLineItem>([SELECT id FROM ContractLineItem WHERE id IN : mapContractIdVsOLI.keyset()]);
		Set<String> deletedRecordIds = new Set<String>();
		for(String cId : mapContractIdVsOLI.keyset()){
			if(!mapIdVsCLI.containsKey(cId)){
				deletedRecordIds.add(mapContractIdVsOLI.get(cId).id);	
			}
		}
		List<Order_Line_Item__c> orderLineItemsToUpdated = new List<Order_Line_Item__c>();
		for(String oId : deletedRecordIds){
			Order_Line_Item__c newOLI = new Order_Line_Item__c(id = oId, Service_Contract_Line_ID__c = null);
			orderLineItemsToUpdated.add(newOLI);	
		}
		if(!orderLineItemsToUpdated.isEmpty())
			update orderLineItemsToUpdated;
		System.debug('NKC debug deletedRecordIds ['+deletedRecordIds+']');
	}

}