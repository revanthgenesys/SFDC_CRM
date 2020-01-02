/* Delete Contact Support Accesses linked to the Expired Service Contracts after 10 days 
   of the contract End Date
   
    BatchDeleteExpiredSupportAccess batch = new BatchDeleteExpiredSupportAccess();
	 Database.executeBatch(batch);
*/
global class BatchDeleteExpiredSupportAccess implements Database.Batchable<SObject>, Database.Stateful{
	

	global static Boolean TEST_EXECUTION_EXCEPTION = false; 
	
	global Database.Querylocator start(Database.BatchableContext ctx) {		 
		 return Database.getQueryLocator([SELECT Id, Service_Contract__c, Sold_To_Account__c, 
		                                         End_User_Account__c, CreatedDate, Contact__c,
		                                         Service_Contract__r.EndDate
		 								  FROM Support_Access__c 
		                                  WHERE Service_Contract_Status__c ='Closed' 
		                                  ORDER BY Service_Contract__r.EndDate
		                                  LIMIT 10000]);   										
	}
        
    global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
    	List<Support_Access__c> suppAccessClosed = (List<Support_Access__c>)scope;
    	List<Support_Access__c> suppAccessToDelete = new List<Support_Access__c>();
    	Map<Id, ServiceContract> serviceContractMap = new Map<Id, ServiceContract>();
    	/// do not delete last Closed SA entry for tracing purpose
    	Map<String, Support_Access__c> prserveLastSupAccMap = new Map<String, Support_Access__c>();
    	
    	for (Support_Access__c sa : suppAccessClosed) {
    		serviceContractMap.put(sa.Service_Contract__c, null);
    		
    		prserveLastSupAccMap.put( sa.Contact__c + '_' + sa.Sold_To_Account__c + '_' + sa.End_User_Account__c,
    		                          sa);    		                           		                          
    	}
    	    	
    	Set<Support_Access__c> prserveLastSupAccSet = new Set<Support_Access__c>(prserveLastSupAccMap.values());

    	// this is to handle inconsistent Contract data
    	//exclude Support Accesses linked to Contracts where status is not aligned with the End Date
    	List<ServiceContract> activeContracts = [SELECT Id FROM ServiceContract
    	                                           WHERE (Status ='Active' 
  													OR Agreement_Status__c ='Active'
  													OR EndDate > LAST_N_DAYS:15) 
  												  AND Id IN: serviceContractMap.keySet()];
    	                                         
    	Map<Id, ServiceContract> serviceContractToExclude = new Map<Id, ServiceContract>(activeContracts);
   	
    	for (Support_Access__c supAcs: suppAccessClosed) {
    		if ( ! serviceContractToExclude.containsKey(supAcs.Service_Contract__c) &&
    		     ! prserveLastSupAccSet.contains(supAcs) )
    		                                        
    		        suppAccessToDelete.add( supAcs );
    	}

        if ( suppAccessToDelete.size() > 0 )  {
       		 List<Database.DeleteResult> deleteres = Database.delete(suppAccessToDelete, false);
      		 List<Database.EmptyRecycleBinResult> recres =  Database.emptyRecycleBin(suppAccessToDelete); 
        } 
    }
    
    global void finish(Database.BatchableContext ctx){
    	
      	AsyncApexJob a = [SELECT id, ApexClassId,
	                       	    JobItemsProcessed, TotalJobItems,
	                       		NumberOfErrors, CreatedBy.Email
                       	  FROM AsyncApexJob
	                      WHERE id = :ctx.getJobId()];
         
         if ( a.NumberOfErrors > 0 || TEST_EXECUTION_EXCEPTION == true ) {
	        String emailMessage = 'BatchDeleteExpiredSupportAccess complited with errors. \n' +
	                              'Number of Errors: '  + a.NumberOfErrors + '\n' +
	                              'JobItemsProcessed: ' + a.JobItemsProcessed;	         
	        Messaging.SingleEmailMessage mail =
	              new Messaging.SingleEmailMessage();
	        String[] toAddresses = new String[] {'mariya.steason@genesyslab.com'};
	        mail.setToAddresses(toAddresses);
	        mail.setReplyTo('noreply@genesyslab.com');
	        mail.setSenderDisplayName('Batch Job Summary');
	        mail.setSubject('BatchDeleteExpiredSupportAccess Batch job completed with Errors');
	        mail.setPlainTextBody(emailMessage);
	        mail.setHtmlBody(emailMessage);
	        
	      if ( !Test.isRunningTest() ) {
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[]
	                           { mail });
	      }
    	}
    }
}