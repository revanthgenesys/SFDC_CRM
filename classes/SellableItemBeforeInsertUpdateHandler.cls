//Naresh Kumar	08/05/2014
public without sharing class SellableItemBeforeInsertUpdateHandler {
	/*
	public static void updateSellableItemName(List<Sellable_Item_Product__c> newList, Map<Id, Sellable_Item_Product__c> oldMap){
		Set<Id> setOfSIVersionNumbers = new Set<Id>();
		List<Sellable_Item_Product__c> listOfSellableItemsToBeupdated = new List<Sellable_Item_Product__c>(); 
		//Looping over each selllable Item
		for(Sellable_Item_Product__c eachItem : newList){
			if(eachItem.SI_Version_Number__c != null && (oldMap == null || oldMap.get(eachItem.id).SI_Version_Number__c == null )){
				setOfSIVersionNumbers.add(eachItem.SI_Version_Number__c);
				listOfSellableItemsToBeupdated.add(eachItem);
			}
		}
		Map<Id, Sellable_Item_SI_Version_Number__c> mapOfIdVsSIVersionNo = new Map<Id, Sellable_Item_SI_Version_Number__c>([SELECT Name FROM Sellable_Item_SI_Version_Number__c WHERE id IN : setOfSIVersionNumbers]);
		//Looping over each selllable Item to be updated
		for(Sellable_Item_Product__c eachItem : newList){
			if(eachItem.Name != null && mapOfIdVsSIVersionNo.get(eachItem.SI_Version_Number__c) != null){
				eachItem.Name = 'v' + mapOfIdVsSIVersionNo.get(eachItem.SI_Version_Number__c).Name + ' - ' + eachItem.Name;
			}
		}
	}	
	*/
	public static void handleUprevActions(List<Sellable_Item_Product__c> newList, Map<Id, Sellable_Item_Product__c> oldMap){
		List<Sellable_Item_Product__c> sellableItemsToUpdate = new List<Sellable_Item_Product__c>();
		Set<Id> setOfUndoUpRevIds = new Set<Id>();
		//Looping over each sellable item
		for(Sellable_Item_Product__c eachSellableItem : newList){
			if(eachSellableItem.Action__c != null && eachSellableItem.Action__c != oldMap.get(eachSellableItem.id).Action__c){
				Sellable_Item_Product__c sellableItemToBeUpdated = new Sellable_Item_Product__c(id = eachSellableItem.id);
				//Validation
				if(eachSellableItem.Locked__c){
					eachSellableItem.addError('This record is locked for uprev actions. Please unlock the record by unchecking Locked checkbox.');
				}				
				//UP REV
				if(eachSellableItem.Action__c == MDMUtil.ACTION_UP_REV){
					MDMUtil.cloneSellableItem(eachSellableItem.id, eachSellableItem.New_Family__c, eachSellableItem.Family_Version__c);
				}
				/*
				As per Johhney, nothing to do in case of EOL
				//EOL Announcement
				if(eachSellableItem.Action__c == MDMUtil.ACTION_PLANNED_EOL){
					sellableItemToBeUpdated.Previous_Availability__c = eachSellableItem.Availability__c;
					sellableItemToBeUpdated.Availability__c = MDMUtil.SELLABLE_AVAILABILITY_STATUS_EOL;					
				}
				//Undo EOL
				if(oldMap.get(eachSellableItem.id).Action__c == MDMUtil.ACTION_PLANNED_EOL){
					sellableItemToBeUpdated.Availability__c = eachSellableItem.Previous_Availability__c;
					sellableItemToBeUpdated.Previous_Availability__c = null;
				}
				*/
				//Undo UP REV
				if(oldMap.get(eachSellableItem.id).Action__c == MDMUtil.ACTION_UP_REV){
					setOfUndoUpRevIds.add(eachSellableItem.id);
				}
				sellableItemToBeUpdated.Locked__c = true;	
				sellableItemsToUpdate.add(sellableItemToBeUpdated);			
			}
		}
		if(!setOfUndoUpRevIds.isEmpty()){
			List<Sellable_Item_Product__c> sellableItemToBeDeleted = [SELECT id, Status__c FROM Sellable_Item_Product__c WHERE Cloned_From__c IN: setOfUndoUpRevIds];
			//Updating status to null to avoid validation rule
			for(Sellable_Item_Product__c eachItem : sellableItemToBeDeleted){
				eachItem.Status__c = MDMUtil.SELLABLE_STATUS_DRAFT;
				eachItem.APN_Number__c = null;
			}			
			if(!sellableItemToBeDeleted.isEmpty()){
				update sellableItemToBeDeleted;
				delete sellableItemToBeDeleted;
			}
		}
		update sellableItemsToUpdate;
	}
	
	public static void handleSellableItemDelete(List<Sellable_Item_Product__c> newList){
		//Looping over each sellable item
		for(Sellable_Item_Product__c eachSellableItem : newList){
			if(!isRecordDeletable(eachSellableItem)){
				eachSellableItem.addError('This sellable item can\'t be deleted.');
			}
		}
	}
	
	public static Boolean isRecordDeletable(Sellable_Item_Product__c sellableItem){
		if(sellableItem.Status__c == MDMUtil.SELLABLE_STATUS_DRAFT && SellableItem.APN_Number__c == null){
			return true;
		}
		return false;
	}
	
	public static void validateBOMDelete(List<Sellable_Shippable_Items__c> BOMItems){
		Set<Id> sellableItemIds = new Set<Id>();
		//Looping over each item
		for(Sellable_Shippable_Items__c eachItem : BOMItems){
			sellableItemIds.add(eachItem.Sellable_Item_Product__c);
		}
		//Getting sellable item record
		Map<Id, Sellable_Item_Product__c> mapOfSellableItems = new Map<Id, Sellable_Item_Product__c>([SELECT id, Status__c FROM Sellable_Item_Product__c WHERE id IN : sellableItemIds]); 
		//Looping over each item
		for(Sellable_Shippable_Items__c eachItem : BOMItems){
			Sellable_Item_Product__c sellableItem = mapOfSellableItems.get(eachItem.Sellable_Item_Product__c);
			if(sellableItem.Status__c != MDMUtil.SELLABLE_STATUS_DRAFT && sellableItem.Status__c != MDMUtil.SELLABLE_STATUS_TO_BE_UPDATED){
				eachItem.addError('BOM Item can\'t be deleted at this stage.');
			}
		}
	}
}