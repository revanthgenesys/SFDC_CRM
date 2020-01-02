global with sharing class BatchUserSubscriptions implements Database.Batchable<sObject> {

	Boolean isDaily;
	
	global  DateTime startDate;
	

	global BatchUserSubscriptions(Boolean Daily){
		isDaily = Daily;
		startDate = Datetime.now();
	}

	global List<sObject> start(Database.BatchableContext batchableContext) {
		return userSubscriptionAlerts.batchStart(isDaily);
	}
	
	
	global void execute(Database.BatchableContext batchableContext, List<sObject> scopeList) {
		userSubscriptionAlerts.batchExcecute(isDaily,scopeList);
	}
	
	
	global void finish(Database.BatchableContext batchableContext) {
		
		Integer internalCount = [ Select count() 
                    FROM System_Subscription_Email__c 
                    Where To_User__r.UserType ='Standard'
                    And CreatedDate >=: startDate ];
        Integer externalCount = [ Select count() 
                    FROM System_Subscription_Email__c 
                    Where To_User__r.UserType !='Standard'
                    And CreatedDate >=: startDate ];

		delete [select Email_Body__c,To_User__c from System_Subscription_Email__c where isSent__c = true];
		    
		   AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
		      TotalJobItems, CreatedBy.Email
		      FROM AsyncApexJob WHERE Id =
		      :batchableContext.getJobId()];
		   
		   String emailBody = ''; 
		   emailBody = 'The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n';
		   emailBody += 'The start time is ' + startDate.format() + ' \n';
		   emailBody += 'The the end time is ' + Datetime.now().format() + ' \n';
		   emailBody += internalCount + ' emails sent to internal users is '  + ' \n';
		   emailBody += externalCount + ' emails sent to external users is ' + externalCount + ' \n';
		   System.debug(emailBody);
		   // Send an email to the Apex job's submitter notifying of job completion.
		   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		   
		   List<Article_Alert_Monitor__c> aams = Article_Alert_Monitor__c.getall().values();
		   List<String> addresses = new List<String>();
		   for(Article_Alert_Monitor__c aam:aams){
		   	addresses.add(aam.Email_Address__c);
		   }
		    
		   //String[] toAddresses = new String[] {};
		   mail.setToAddresses(addresses);
		   mail.setSubject('Email Alert Batch Job: ' + a.Status);
		   mail.setPlainTextBody(emailBody);
		   if(!Test.isRunningTest()){
		   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		   }
		
	}

}