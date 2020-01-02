//Naresh Kumar	06/26/2015
public without sharing class APN_ECCN_GenerationHelper {

	public static void generateAPNs(List<Sellable_Item_Product__c> sellableItems){		
		for(Sellable_Item_Product__c eachItem : sellableItems){
			if(eachItem.Status__c == MDMUtil.SELLABLE_STATUS_SELLABLE_ITEM_READY 
				&& eachItem.Availability__c == MDMUtil.SELLABLE_AVAILABILITY_STATUS_IN_PROGRESS && eachItem.APN_Number__c == null){						
					//Prefix e.g. '3GP'
					String prefix = APN_ECCN_Mapping__c.getValues('APNPrefix').Value__c;
					//Auto Number
					String autoNumber = String.valueOf(eachItem.APN_Auto_Number1__c);
					//First Character = 'A'
					String firstCharacter = APN_ECCN_Mapping__c.getValues('APNFirstCharacter').Value__c;
					//Second Character, ERP Class
					String secondCharacter = APN_ECCN_Mapping__c.getValues(eachItem.ERP_Class__c).Value__c;
					//Third Character, ERP Education Type
					String thirdCharacter = ((APN_ECCN_Mapping__c.getValues(eachItem.ERP_Education_Type__c) == null || eachItem.ERP_Education_Type__c == null) ? 
						APN_ECCN_Mapping__c.getValues('Default-ERP-Edu-Type').Value__c : APN_ECCN_Mapping__c.getValues(eachItem.ERP_Education_Type__c).Value__c);
					//Fourth Character = 'A'
					String fourthCharacter = APN_ECCN_Mapping__c.getValues('APNLastCharacter').Value__c;
					//APN Number
					eachItem.APN_Number__c = prefix + autoNumber + firstCharacter + secondCharacter + thirdCharacter + fourthCharacter;							
			}	
		}
	}
	
	public static void reCalculateECCN(List<Shippable_Item__c> newList, Map<Id, Shippable_Item__c> oldMap){
		Set<Id> setOfUpdatedItems = new Set<Id>();
		//Looping over each item
		for(Shippable_Item__c eachItem : newList){
			if(eachItem.ECCN_US_Number__c != oldMap.get(eachItem.id).ECCN_US_Number__c
				|| eachItem.ECCN_GB_Numbers__c != oldMap.get(eachItem.id).ECCN_GB_Numbers__c
				|| eachItem.ECCN_NL_Number__c != oldMap.get(eachItem.id).ECCN_NL_Number__c){
				setOfUpdatedItems.add(eachItem.id);						
			}
		}
		List<Sellable_Shippable_Items__c> sellableShippableItems = [SELECT Sellable_Item_Product__c, Shippable_Item_Product__c
			FROM Sellable_Shippable_Items__c WHERE Shippable_Item_Product__c IN : setOfUpdatedItems];
		generateECCN(sellableShippableItems);
	}
	
	public static void generateECCN(List<Sellable_Shippable_Items__c> sellableShippableItems){
				
		Set<Id> setOfSellableItemProductIds = new Set<Id>();
		Set<Id> setOfShippableItemProductIds = new Set<Id>();
		Map<Id, List<Id>> mapOfSellableIdVsShippableIds = new Map<Id, List<Id>>();
		//Looping over each item
		for(Sellable_Shippable_Items__c eachItem : sellableShippableItems){
			setOfSellableItemProductIds.add(eachItem.Sellable_Item_Product__c);
						
		}		
		List<Sellable_Shippable_Items__c> allSellableShippableItems = [SELECT Sellable_Item_Product__c, Shippable_Item_Product__c
			FROM Sellable_Shippable_Items__c WHERE Sellable_Item_Product__c IN : setOfSellableItemProductIds];
		
		for(Sellable_Shippable_Items__c eachItem : allSellableShippableItems){	
			setOfShippableItemProductIds.add(eachItem.Shippable_Item_Product__c);	
			if(mapOfSellableIdVsShippableIds.get(eachItem.Sellable_Item_Product__c) == null){
				List<Id> newList = new List<Id>();
				newList.add(eachItem.Shippable_Item_Product__c);
				mapOfSellableIdVsShippableIds.put(eachItem.Sellable_Item_Product__c, newList);
			}						
			else{
				mapOfSellableIdVsShippableIds.get(eachItem.Sellable_Item_Product__c).add(eachItem.Shippable_Item_Product__c);
			}
		}
		
		Map<Id, Shippable_Item__c> mapOfIdVsShippableItemProduct = new Map<Id, Shippable_Item__c>( 
			[SELECT ECCN_US_Number__c, ECCN_GB_Numbers__c, ECCN_NL_Number__c FROM Shippable_Item__c WHERE id IN : setOfShippableItemProductIds]);
			
		updateECCN(mapOfSellableIdVsShippableIds, mapOfIdVsShippableItemProduct);
		
		Set<Id> sellableItemsWithoutShippableItems = new Set<Id>();
		for(Id eachSellableId : setOfSellableItemProductIds){
			if(!mapOfSellableIdVsShippableIds.containsKey(eachSellableId))
				sellableItemsWithoutShippableItems.add(eachSellableId);
		}
		List<Sellable_Item_Product__c> sellableItemsToUpdated = new List<Sellable_Item_Product__c>();
		for(Id eachSellableId : sellableItemsWithoutShippableItems){
			Sellable_Item_Product__c eachSellableItem = new Sellable_Item_Product__c(id = eachSellableId);
			eachSellableItem.ECCN_US__c = MDMUtil.DEFAULT_ECCN_US;
			eachSellableItem.ECCN_GB__c = MDMUtil.DEFAULT_ECCN_GB;
			eachSellableItem.ECCN_NL__c = MDMUtil.DEFAULT_ECCN_NL;
			sellableItemsToUpdated.add(eachSellableItem);
		}
		if(!sellableItemsToUpdated.isEmpty())
			update sellableItemsToUpdated;
	}
	
	private static void updateECCN(Map<Id, List<Id>> mapOfSellableIdVsShippableIds, Map<Id, Shippable_Item__c> mapOfIdVsShippableItemProduct){
		List<Sellable_Item_Product__c> sellableItemsToUpdated = new List<Sellable_Item_Product__c>(); 
		//Looping over each sellable item id
		for(Id eachSellableId : mapOfSellableIdVsShippableIds.keyset()){
			
			List<Id> shippableItemIds = mapOfSellableIdVsShippableIds.get(eachSellableId);
			String ECCNtoSetOnSellableItem = MDMUtil.DEFAULT_ECCN_US;
			//Looping over each shippable item id for current sellable item id
			for(Id eachShippableId : shippableItemIds){
				String ECCNOnShippableItem = mapOfIdVsShippableItemProduct.get(eachShippableId).ECCN_US_Number__c;
				if(getECCNRank(ECCNOnShippableItem) > getECCNRank(ECCNtoSetOnSellableItem))
					ECCNtoSetOnSellableItem = ECCNOnShippableItem;				
			}
			
			String ECCNGBtoSetOnSellableItem = MDMUtil.DEFAULT_ECCN_GB;
			//Looping over each shippable item id for current sellable item id
			for(Id eachShippableId : shippableItemIds){
				String ECCNGBOnShippableItem = mapOfIdVsShippableItemProduct.get(eachShippableId).ECCN_GB_Numbers__c;				
				if(getECCNRank(ECCNGBOnShippableItem) > getECCNRank(ECCNGBtoSetOnSellableItem))
					ECCNGBtoSetOnSellableItem = ECCNGBOnShippableItem;
			}
			String ECCNNLtoSetOnSellableItem = MDMUtil.DEFAULT_ECCN_NL;
			//Looping over each shippable item id for current sellable item id
			for(Id eachShippableId : shippableItemIds){
				String ECCNNLOnShippableItem = mapOfIdVsShippableItemProduct.get(eachShippableId).ECCN_NL_Number__c;				
				if(getECCNRank(ECCNNLOnShippableItem) > getECCNRank(ECCNNLtoSetOnSellableItem))
					ECCNNLtoSetOnSellableItem = ECCNNLOnShippableItem;
			}
			
			//ECCNGBtoSetOnSellableItem has ECCNGB for current sellable item
			Sellable_Item_Product__c eachSellableItem = new Sellable_Item_Product__c(id = eachSellableId);
			eachSellableItem.ECCN_US__c = ECCNtoSetOnSellableItem;
			eachSellableItem.ECCN_GB__c = ECCNGBtoSetOnSellableItem;
			eachSellableItem.ECCN_NL__c = ECCNNLtoSetOnSellableItem;			
			sellableItemsToUpdated.add(eachSellableItem);
		}
		//Update ECCN nos
		if(!sellableItemsToUpdated.isEmpty()){
			update sellableItemsToUpdated;		
		}
	}
	
	private static Integer getECCNRank(String ECCN){
		if(ECCN != null)
			ECCN = ECCN.replace('.','x');
		if(ECCN == null || APN_ECCN_Mapping__c.getValues(ECCN) == null)
			return -1;
		Integer rank = Integer.valueOf(APN_ECCN_Mapping__c.getValues(ECCN).Value__c);
		return rank;
	}
}