/* Find service contract line items with approaching Maintenance Start or End date. Query is filtered by CIC category product.
   Identifies and puts account GARN in the queue for further processing by BatchLMSIntegrationProcessQueue job.
   
   Date of the last successful execution is stored in LMS_Integration_Configuration__c custom setting and then used in the query. 
   
   BatchLMSIntegrationAddToQueue batch = new BatchLMSIntegrationAddToQueue();
	Database.executeBatch(batch); 
*/
global class BatchLMSIntegrationAddToQueue implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
	
	global String notifyOnErrors;
	global Date dateOffset;
	
	global Database.Querylocator start(Database.BatchableContext ctx) {
	      return Database.getQueryLocator(
	          [SELECT ServiceContract.End_User_Name__c
			   FROM ContractLineItem WHERE isPureConnectPrem__c = true
			    AND (					  	  	           
	                 (ServiceContract.Agreement_Status__c IN ('Active') AND (			  	  	               
					    (Maintenance_Start_Date__c > :dateOffset AND Maintenance_Start_Date__c <= :Date.today())
					     OR
						(Maintenance_End_Date__c > :dateOffset AND Maintenance_End_Date__c <= :Date.today().addDays(-1)) ) )	
						
                 OR  (ServiceContract.Agreement_Status__c IN ('In Negotiation') AND (			  	  	               
					    (ServiceContract.StartDate > :dateOffset AND ServiceContract.StartDate <= :Date.today())
					     OR
						(ServiceContract.EndDate > :dateOffset AND ServiceContract.EndDate <= :Date.today().addDays(-1)) ) )							
	             OR 
					(ServiceContract.Agreement_Status__c = 'Shelved' AND (					  	  	               
					  (Maintenance_End_Date__c > :dateOffset AND Maintenance_End_Date__c <= :Date.today().addDays(-1))
					    OR
					  (Maintenance_End_Date__c > :dateOffset.addMonths(18) AND Maintenance_End_Date__c <= :Date.today().addMonths(18)) ) )						  	  	            
			      )]);  
		                                  
	}
	
	global BatchLMSIntegrationAddToQueue () {
		
		LMS_Integration_Configuration__c custConf = LMS_Integration_Configuration__c.getOrgDefaults();
    	this.notifyOnErrors = custConf.Notify_On_Errors__c;  
    			
		dateOffset = custConf.Last_Successful_AddQ_Run__c == null ? Date.today().addDays(-1) : custConf.Last_Successful_AddQ_Run__c;
	}
	
	global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
		List<ContractLineItem> contarctLineItems = (List<ContractLineItem>) scope;
    	List<LMS_Outbound_Msg_Queue__c> queueItemsToInsert = new List<LMS_Outbound_Msg_Queue__c>();
    	Set<String> acctIDs = new Set<String>();
    	
    	for (ContractLineItem li : contarctLineItems)  {
    		acctIDs.add(li.ServiceContract.End_User_Name__c);
    	}
    	
    	if ( ! acctIDs.isEmpty() )
    		LMSIintegrationService.putAccountsInLMSQueueById( new List<String>(acctIDs) );
	}
	
	global void finish(Database.BatchableContext ctx) {
		
		   if ( notifyOnErrors == null || notifyOnErrors == '' )
                  return;
     
	        AsyncApexJob a = [SELECT id, ApexClassId,
	                       		JobItemsProcessed, TotalJobItems,
	                       		NumberOfErrors, ExtendedStatus
                       			FROM AsyncApexJob
	                       		WHERE id = :ctx.getJobId()];
            
            if ( a.NumberOfErrors > 0 || Test.isRunningTest() )  {
	            
		        String emailMessage = 'Errors executing job BatchLMSIntegrationAddToQueue. \n\n'
		         + 'It executed ' + a.totalJobItems  + ' batches. \n'
		         + 'Of which, ' + a.JobItemsProcessed + ' processed without any exceptions thrown. \n'
	             + a.numberOfErrors + ' batches threw unhandled exceptions. \n\n'
	             + 'Status Details: \n' + a.ExtendedStatus;
		         
		        Messaging.SingleEmailMessage mail =
		              new Messaging.SingleEmailMessage();
		        String[] toAddresses = new String[] {notifyOnErrors};
		        mail.setToAddresses(toAddresses);
		        mail.setReplyTo('noreply@genesyslab.com');
		        mail.setSenderDisplayName('Batch Job Summary');
		        mail.setSubject('Errors executing job BatchLMSIntegrationAddToQueue');
		        mail.setPlainTextBody(emailMessage);
	        	Messaging.sendEmail(new Messaging.SingleEmailMessage[]
		                           { mail });  
            }
            else {
            	
            	LMS_Integration_Configuration__c custConf = LMS_Integration_Configuration__c.getOrgDefaults();
    	        custConf.Last_Successful_AddQ_Run__c = Date.today();  
    	        update custConf;
            }
            	 	
	 }    
}