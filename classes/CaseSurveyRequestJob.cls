global class CaseSurveyRequestJob implements Database.Batchable<sObject>,Database.AllowsCallouts {
	    
    global Database.Querylocator start(Database.BatchableContext ctx) {
		 return Database.getQueryLocator([SELECT Id, Request_Timestamp__c,Date_Closed__c,
		                                          Case__c,Body__c, Request_Status__c
		 								   FROM Survey_Case_Log__c 
		 								   WHERE Request_Timestamp__c = null ]); 
			  
	}
    
    global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
    	List<Survey_Case_Log__c> survRequList = (List<Survey_Case_Log__c>)scope;
  
	    List<ID> caseIdList = new List<ID>();
	    for (Survey_Case_Log__c survRequ : survRequList ) {
	    	caseIdList.add(survRequ.Case__c);
	    }  
	    ///find if any of the requested Cases already been sent for survey previously
	    List<Survey_Case_Log__c> survPastSentList = ([SELECT Id, Request_Timestamp__c,Date_Closed__c,Case__c,
	                                                         Body__c, Request_Status__c 
		 								  	  	      FROM Survey_Case_Log__c 
		 								              WHERE Request_Timestamp__c != null
		 								                AND Case__c IN : caseIdList]); 
		 								             
	    List<Survey_Case_Log__c> survToSendList = new List<Survey_Case_Log__c>();
	    
	    for ( Survey_Case_Log__c survRequ : survRequList ) {
	    	Boolean skip = false;
	    	///check for duplicates in the current batch
	    	for ( Survey_Case_Log__c survToSend : survToSendList )  {
	    		if ( survRequ.Case__c == survToSend.Case__c && survRequ.Date_Closed__c == survToSend.Date_Closed__c ) {
	    		   skip = true;
	    		   break;
	    		}
	    	}	    	
	    	///check for duplicates in already sent requests
	    	for ( Survey_Case_Log__c survPastSent : survPastSentList )  {
	    		if ( survRequ.Case__c == survPastSent.Case__c && survRequ.Date_Closed__c == survPastSent.Date_Closed__c ) {
	    		   	skip = true;
	    		   	break;
	    		}
	    	}	    	
	    	if ( skip == false ) {
	    		survToSendList.add(survRequ);
	    		survRequ.Request_Status__c = 'Sent';
	    	} 
	    	else {
	    		survRequ.Request_Status__c = 'Duplicate';
	    	}
	    	
	    	survRequ.Request_Timestamp__c = datetime.now();
	    }
	    /// send requests
	    for (Survey_Case_Log__c surv : survToSendList )  {
	    	SoundBite.callSoundBite(surv.Body__c);
	    }
	    ///update timestamps
	    update survRequList;	
	}
	
	global void finish(Database.BatchableContext ctx){
		
	}
}