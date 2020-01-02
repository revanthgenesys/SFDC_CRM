public without sharing class BillingPlanExtension {
	String orderId {get;set;}
	public List<Quote_Billing_Plan__c> quoteBillingPlans {get;set;}
	public Boolean noRecordsFound {get;set;}
	public BillingPlanExtension(ApexPages.StandardController sc){
		orderId = sc.getId();
		System.debug('NKC debug orderId ['+orderId+']');
		init();
	}
	
	private void init(){
		Order__c order = [SELECT Quote__c FROM Order__c WHERE id =: orderId];
		quoteBillingPlans = [SELECT id, Name, Invoice__c, Invoice_Date__c, Amount__c, Support_Period_Start_Date__c, 
			Support_Period_End_Date__c, Comments__c FROM Quote_Billing_Plan__c WHERE Quote__c =: order.Quote__c];
		if(quoteBillingPlans.isEmpty())
			noRecordsFound = true;
		else
			noRecordsFound = false;
	}

}