global with sharing class BatchKCSJob  implements Database.Batchable<sObject> {

//The person excecuting this must have a bypass validation rules checkbox enabled

// /!\ NOTE: THIS BATCH JOB is created to update the cases that were changed by a user not having a knowledge license
// THe cases changes for user having the knowledge license will be in the caseArticleCheck trigger.

	global integer queryLimit;

	

	global List<sObject> start(Database.BatchableContext batchableContext) {
		
		
		if( queryLimit == null || queryLimit == 0){
			return [select id,KCS_Article_Citation__c,KCS_Known_Vs_New__c, KCS_Has_Article_Linked__c from case where NeedKCSRerun__c =true and isClosed  = true];
		}else{
			return [select id,KCS_Article_Citation__c,KCS_Known_Vs_New__c, KCS_Has_Article_Linked__c from case where NeedKCSRerun__c =true and isClosed  = true limit: queryLimit];
		}
	}
	
	
	global void execute(Database.BatchableContext batchableContext, List<sObject> scopeList) {
		update scopeList;
	}
	
	
	global void finish(Database.BatchableContext batchableContext) {
		
		 AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
		      TotalJobItems, CreatedBy.Email
		      FROM AsyncApexJob WHERE Id =
		      :batchableContext.getJobId()];
		   
		   String emailBody = ''; 
		   emailBody = 'The batch Apex job processed ' + a.TotalJobItems + ' batches with '+ a.NumberOfErrors + ' failures.\n';
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
		   mail.setSubject('KCS Stats Job:: ' + a.Status);
		   mail.setPlainTextBody(emailBody);
		   if(!Test.isRunningTest()){
		   		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		   }

	}




}