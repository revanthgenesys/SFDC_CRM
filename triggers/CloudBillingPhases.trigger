trigger CloudBillingPhases on Cloud_Billing_Phase__c (after update) {

	QuoteRevenueForecastControllerHelper.revenueHistoryUpdate(trigger.oldMap, trigger.new);

}