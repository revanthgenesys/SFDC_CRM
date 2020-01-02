//Naresh Kumar	07/24/2015
public without sharing class SellableItemHistoryTrackingHelper {
	public static final String HISTORY_EVENT_CREATED = 'Created';
	public static final String HISTORY_EVENT_CHANGED = 'Changed';
	
	public static void populateFieldHistory(Map<Id, Sellable_Item_Product__c> newMap, Map<Id, Sellable_Item_Product__c> oldMap){
	
		Map<String, Schema.DescribeFieldResult> listOfFieldsToTack = getAllTrackableFields();
	    List<Sellable_Item_History__c> recordsToBeInserted = new List<Sellable_Item_History__c>();
	    //Looping over all records
		for(Sellable_Item_Product__c newRecord : newMap.values()){
			
		    for (Schema.DescribeFieldResult fieldDescribe : listOfFieldsToTack.values()) {
		    	String fieldName = fieldDescribe.getName();
		    	String fieldLabel = fieldDescribe.getLabel();
		    	Sellable_Item_History__c newSellableItemHistory;
		    	if(oldMap == null){
		    		newSellableItemHistory = createUpdateHistory(fieldName, fieldLabel, newRecord, null, HISTORY_EVENT_CREATED);
		    		recordsToBeInserted.add(newSellableItemHistory);
		    		break;
		    	}		    	
		        else if (newRecord.get(fieldDescribe.getName()) != oldMap.get(newRecord.id).get(fieldName)) {
		        	Sellable_Item_Product__c oldRecord = oldMap.get(newRecord.id);
		            newSellableItemHistory = createUpdateHistory(fieldName, fieldLabel, newRecord, oldRecord, HISTORY_EVENT_CHANGED);
		         	recordsToBeInserted.add(newSellableItemHistory);   
		        }		        
		    }	
		}
		if(!recordsToBeInserted.isEmpty()){
			Database.SaveResult[] lsr = Database.insert(recordsToBeInserted);
		}
	}
	
	private static Sellable_Item_History__c createUpdateHistory(String fieldName, String fieldLabel, Sellable_Item_Product__c newRecord, Sellable_Item_Product__c oldRecord, String event) {
	    Sellable_Item_History__c newSellableItemHistory = new Sellable_Item_History__c();
	    newSellableItemHistory.Sellable_Item__c = newRecord.Id;
	    newSellableItemHistory.Event__c = event;
	    newSellableItemHistory.User__c = UserInfo.getUserId();
	    if(event == HISTORY_EVENT_CREATED)
	    	return newSellableItemHistory;
	    newSellableItemHistory.Field_Name__c = fieldLabel;	    	    
	    String newValue = String.valueOf(newRecord.get(fieldName));
	    if(newValue != null){
	    	newSellableItemHistory.New_Value__c = newValue.abbreviate(255);
	    } 
	    if(oldRecord != null){
		    String oldValue = String.valueOf(oldRecord.get(fieldName));
		    if(oldValue != null){
		    	newSellableItemHistory.Old_Value__c = oldValue.abbreviate(255);
		    } 
	    }
	    return newSellableItemHistory;
	}
	
	private static Map<String, Schema.DescribeFieldResult > getAllTrackableFields(){
		//get all fields from compliance that we want to check for changes
	    Map<String, Schema.SObjectField> allComplFieldsMap = Schema.SObjectType.Sellable_Item_Product__c.fields.getMap();
	    Map<String, Schema.DescribeFieldResult> listOfFieldsToTack = new Map<String, Schema.DescribeFieldResult>();
	    for (Schema.SObjectField complField : allComplFieldsMap.values()) {
	        Schema.DescribeFieldResult describeResult = complField.getDescribe();
	        //choose which fields to track depending on the field type
	        if (describeResult.getType() == Schema.DisplayType.Boolean ||
	            describeResult.getType() == Schema.DisplayType.Combobox ||
	            describeResult.getType() == Schema.DisplayType.Currency ||
	            describeResult.getType() == Schema.DisplayType.Date ||
	            describeResult.getType() == Schema.DisplayType.DateTime ||
	            describeResult.getType() == Schema.DisplayType.Double ||
	            describeResult.getType() == Schema.DisplayType.Email ||
	            describeResult.getType() == Schema.DisplayType.Integer ||
	            describeResult.getType() == Schema.DisplayType.MultiPicklist ||
	            describeResult.getType() == Schema.DisplayType.Percent ||
	            describeResult.getType() == Schema.DisplayType.Phone ||
	            describeResult.getType() == Schema.DisplayType.Picklist ||
	            describeResult.getType() == Schema.DisplayType.String ||
	            describeResult.getType() == Schema.DisplayType.TextArea ||
	            describeResult.getType() == Schema.DisplayType.Time ||
	            describeResult.getType() == Schema.DisplayType.URL ||
	            describeResult.getType() == Schema.DisplayType.Reference) {
	            //don't add standard fields that are not necessary
	            if (describeResult.getName() != 'CreatedDate' &&
	                describeResult.getName() != 'LastModifiedDate' &&
	                describeResult.getName() != 'SystemModstamp' &&
	                //only add fields that are visible to the current user
	                describeResult.isAccessible() &&
	                //do not add formula fields
	                !describeResult.isCalculated()
	                )
	           {
	                listOfFieldsToTack.put(describeResult.getName(), describeResult);
	            }
	        }
	    }
	    return listOfFieldsToTack;
	}
	
	public static void replaceIdsWithRecordName(List<Sellable_Item_History__c> newList){
		//Looping over each record
		for(Sellable_Item_History__c eachItem : newList){
			if(eachItem.Old_Value__c != null){
				eachItem.Old_Value__c = getValueToBeReplacedWith(eachItem.Old_Value__c);
			}
			if(eachItem.New_Value__c != null){
				eachItem.New_Value__c = getValueToBeReplacedWith(eachItem.New_Value__c);
			}
		}
	}
	
	private static String getValueToBeReplacedWith(String value){
		if(isValueAnId(value)){
			String objectName = findObjectNameFromRecordIdPrefix(value);
			if(objectName == '')
				return value;
			System.debug('NKC debug objectName ['+objectName+']');
			String soql = 'SELECT Name FROM ' + objectName + ' WHERE  id = \'' + value + '\'';
			List<SObject> records = Database.query(soql);
			if(!records.isEmpty()){
				return (String)records[0].get('Name');
			}
		}
		return value;
	}
	
	private static Boolean isValueAnId(String value){
		Boolean isId = false;
		try{
			Id idValue = id.valueOf(value);
			isId = true;
		}
		catch(Exception ex){
			isId = false;
		}
		return isId;
	}
	
	public static String findObjectNameFromRecordIdPrefix(String recordIdOrPrefix){
        String objectName = '';
        try{
            //Get prefix from record ID
            //This assumes that you have passed at least 3 characters
            String myIdPrefix = String.valueOf(recordIdOrPrefix).substring(0,3);
             
            //Get schema information
            Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe(); 
             
            //Loop through all the sObject types returned by Schema
            for(Schema.SObjectType stype : gd.values()){
                Schema.DescribeSObjectResult r = stype.getDescribe();
                String prefix = r.getKeyPrefix();                 
                //Check if the prefix matches with requested prefix
                if(prefix != null && prefix.equals(myIdPrefix)){
                    objectName = r.getName();                    
                    break;
                }
            }
        }catch(Exception e){
            System.debug(e);
        }
        return objectName;
    }
}