/*   BatchLMSIntegrationProcessQueue batch = new BatchLMSIntegrationProcessQueue();
	 Database.executeBatch(batch, 5);
*/
global class BatchLMSIntegrationProcessQueue implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
	
    global String endpoint;  
    global String username;    
    global String password;    
    global String notifyOnErrors;

   global class ResponseStatus {
    	public String statusCode;
    	public String statusMsg;
    }
	
   global Database.Querylocator start(Database.BatchableContext ctx) {
		 return Database.getQueryLocator([SELECT id, Account__c, Error_Message__c, Failure_Count__c, Payload__c, Status__c
		                                    FROM LMS_Outbound_Msg_Queue__c
  	 	                                   WHERE Status__c = 'New' 
  	 	                                      OR (Status__c = 'Failed' AND Failure_Count__c < 4) ]); 
		                                  
	}
	
	global BatchLMSIntegrationProcessQueue() {
		
		LMS_Integration_Configuration__c custConf = LMS_Integration_Configuration__c.getOrgDefaults();
    	this.notifyOnErrors = custConf.Notify_On_Errors__c;     
        this.endpoint = custConf.Endpoint__c;   
   		this.username = custConf.Username__c;    
   		this.password = custConf.Password__c;    
		
	}
	
	global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
    	List<LMS_Outbound_Msg_Queue__c> responseList = (List<LMS_Outbound_Msg_Queue__c>) scope;
    	List<LMS_Outbound_Msg_Queue__c> processedList = new List<LMS_Outbound_Msg_Queue__c>();
    	
    	for (LMS_Outbound_Msg_Queue__c q : responseList)  {
    		LMSIintegrationService.AccountProductEntlmnt accntProds = new LMSIintegrationService.AccountProductEntlmnt(q.Account__c);
			LMSIintegrationService.AccountProductEntlmntBatchable tosend = new LMSIintegrationService.AccountProductEntlmntBatchable(accntProds);
		    String payload = JSON.serializePretty(tosend);
		    
		    ResponseStatus retVal = postAccountEntitlements(payload);
		    
		    if ( retVal.statusCode != 'OK' )  {
		      q.Failure_Count__c += 1;
		      q.Error_Message__c = retVal.statusMsg;
		      q.Status__c = 'Failed';
		    }
		    else {
		    	q.Status__c  = 'Success';
		    	q.Error_Message__c = '';
		    }
		    q.Payload__c = payload;
		    processedList.add(q);
    	}
    	
    	if ( !processedList.isEmpty() )	
    	   update processedList;
	}
	
	global ResponseStatus postAccountEntitlements(String payload) {
		ResponseStatus retVal = new ResponseStatus();
					
		HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        
        Blob headerValue = Blob.valueOf(username +':' + password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setBody(payload); 
                                       
        Http http = new Http();
        HTTPResponse res = http.send(req);
          
      	if ( res.getStatusCode() != 201 )  {
               retVal.statusCode = 'Error';
               retVal.statusMsg = res.toString() + '  ' + res.getBody();
		}  
		else {
			    String responseBody = res.getbody();
			    JSONParser parser = JSON.createParser(responseBody);
			    retVal = (ResponseStatus)parser.readValueAs(ResponseStatus.class);
		} 
                            
    	return retVal;		
	}
	
	
    global void finish(Database.BatchableContext ctx){
    	
            if ( notifyOnErrors == null || notifyOnErrors == '' )
                  return;
     
	        AsyncApexJob a = [SELECT id, ApexClassId,
	                       		JobItemsProcessed, TotalJobItems,
	                       		NumberOfErrors, ExtendedStatus
                       			FROM AsyncApexJob
	                       		WHERE id = :ctx.getJobId()];
            
            if ( a.NumberOfErrors > 0 || Test.isRunningTest() )  {
	            
		        String emailMessage = 'Errors executing job BatchLMSIntegrationAccountEntitlmnts. \n\n'
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
		        mail.setSubject('Errors executing job BatchLMSIntegrationAccountEntitlmnts');
		        mail.setPlainTextBody(emailMessage);
	        	Messaging.sendEmail(new Messaging.SingleEmailMessage[]
		                           { mail });  
            }
	}
    
}