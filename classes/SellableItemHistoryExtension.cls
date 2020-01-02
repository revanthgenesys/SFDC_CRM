//Naresh Kumar
public without sharing class SellableItemHistoryExtension {
	public transient String sellableItemId;
	public transient List<historyWrapper> history {get;set;}
	public transient Boolean isOpenedInSeperateTab {get;set;}
	public transient String title {get;set;}
	public SellableItemHistoryExtension(ApexPages.StandardController sc){
		sellableItemId = sc.getId();
		populateHistoryRecords();
		isOpenedInSeperateTab = false;
		title = '';
		if(ApexPages.currentPage().getParameters().get('seperateTab') != null){
			isOpenedInSeperateTab = true;
			title = 'Sellable Item - Product History';
		}
	}
	
	private void populateHistoryRecords(){
		List<Sellable_Item_History__c> sellableHistoryItems = [SELECT CreatedDate, User__c, User__r.Name, Event__c, Field_Name__c, New_Value__c, 
			Old_Value__c FROM Sellable_Item_History__c WHERE Sellable_Item__c =: sellableItemId ORDER BY CreatedDate DESC];
		history = new List<historyWrapper>();
		//Looping over each history item
		for(Sellable_Item_History__c eachItem : sellableHistoryItems){
			historyWrapper newRecord = new historyWrapper();
			newRecord.record = eachItem;
			if(eachItem.Event__c == SellableItemHistoryTrackingHelper.HISTORY_EVENT_CHANGED){
				if(eachItem.New_Value__c == null){
					newRecord.Action = 'Deleted ' + eachItem.Old_Value__c + ' in ' + ' <b>' + eachItem.Field_Name__c + '</b>';
				}
				else if(eachItem.Old_Value__c == null){
					newRecord.Action = eachItem.Event__c + ' <b>' + eachItem.Field_Name__c 
						+ '</b> to <b>' + eachItem.New_Value__c + '</b>.';
				}
				else{
					newRecord.Action = eachItem.Event__c + ' <b>' + eachItem.Field_Name__c 
						+ '</b> from ' + eachItem.Old_Value__c + ' to <b>' + eachItem.New_Value__c + '</b>.';
				}
			}
			else{
				newRecord.Action = SellableItemHistoryTrackingHelper.HISTORY_EVENT_CREATED + '.';
			}
			history.add(newRecord);
		}
	}
	
	private String replceNullToBlank(String str){
		if(str == null)
			return '\'\'';
		return str;
	}
	
	public class historyWrapper{
		public Sellable_Item_History__c record {get;set;}
		public String action {get;set;} 
	}
}