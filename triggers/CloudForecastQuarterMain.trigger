//Naresh Kumar	05/31/2016
trigger CloudForecastQuarterMain on Cloud_Forecast_Quarter__c (after insert, after update) {
	if((trigger.isInsert || trigger.isUpdate) && trigger.isAfter){
		if(trigger.isInsert)
			CloudForecastQuarterMainHelper.onAfterUpdate(trigger.new, null);
		if(trigger.isUpdate)
			CloudForecastQuarterMainHelper.onAfterUpdate(trigger.new, trigger.oldMap);
	}
}