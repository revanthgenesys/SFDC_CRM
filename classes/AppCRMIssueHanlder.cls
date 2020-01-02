/*
	Naresh Kumar 	07/26/2013
*/
global class AppCRMIssueHanlder implements Messaging.InboundEmailHandler {
	  global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		  Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		  
		  Workload_Manager__c newRecord = new Workload_Manager__c();
		  newRecord.From__c = email.fromAddress;
		  newRecord.Subject__c = email.subject;
		  newRecord.Description_Plain__c = email.plainTextBody;
		  newRecord.Description_Rich__c = email.htmlBody;
		  insert newRecord;
		  
		  result.success = true;
          return result;
      }
 }