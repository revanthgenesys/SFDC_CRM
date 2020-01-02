/*
	 BatchSurveysSendToSolariat batch = new BatchSurveysSendToSolariat();
	 Database.executeBatch(batch, 5);
*/
global class BatchSurveysSendToSolariat implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    global String postURL;  
    global String tokenURL;    
    global String username;    
    global String password;    
    global String channel;
    global String apiKey;
    global String notifyOnErrors;
    global String accessToken;
    global Integer errorNum=0;
    global String errorMsg = '';
    global Integer prcossedNum=0;
    global String STR_SUCCESS_RESPONSE = 'Success';
    global String NO_CONTENT = 'No Content';
    global String PROCESSED_SUCCESS = 'Processed';
    
    global BatchSurveysSendToSolariat() {
    	
    	SOLARIAT_Connect_Configuration__c custConf = SOLARIAT_Connect_Configuration__c.getOrgDefaults();
    	this.notifyOnErrors = custConf.Notify_On_Errors__c;     
        this.postURL = custConf.Post_URL__c;   
    	this.tokenURL = custConf.Token_URL__c;    
   		this.username = custConf.User_Name__c;    
   		this.password = custConf.Password__c;    
 		this.channel  = custConf.Channels__c;
 		this.apiKey  = custConf.API_Key__c;   	
    }
        
    global Database.Querylocator start(Database.BatchableContext ctx) {
		 return Database.getQueryLocator([SELECT Id, Verbatim__c, Response_Type_2__c, CreatedDate, Name
		                                  FROM Survey_Response__c  
		                                  WHERE Solariat_Response__c = null
		                                   AND Response_Type_2__c != null
		                                   AND NPS_Rating__c != null
		                                   AND CreatedDate = LAST_N_DAYS:90]); 
		                                  
	}
    
    global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
    	List<Survey_Response__c> responseList = (List<Survey_Response__c>) scope;
    	List<Survey_Response__c> processedList = new List<Survey_Response__c>();
    	
    	/// get auth token
    	String respMsg = getAuthToken();
    	if ( respMsg != STR_SUCCESS_RESPONSE ) {
			 	errorMsg = ( respMsg.length() > 255 ) ? respMsg.substring(0,254) : respMsg;	 	 
			 	errorNum++;			 	
			 	return;
	     }
    	
    	/// send survey data to analytics and query for tags after the data is processed
    	for ( Survey_Response__c srvResp : responseList )  { 
    		String errorResp = '';
    		///send    		  
			String respPost = postSurvey( srvResp );		 
			if ( respPost != STR_SUCCESS_RESPONSE ) {
			 	errorResp = ( respPost.length() > 255 ) ? respPost.substring(0,254) : respPost;			 										 	
			 	if ( respPost != NO_CONTENT )
			 	   	 errorNum++;
	        } 
            else {  
		        ///query for Tags	        
		        String respGetTags = getSurveyTags( srvResp ) ;   
		        if ( respGetTags != STR_SUCCESS_RESPONSE ) {
				 	 errorResp = ( respGetTags.length() > 255 ) ? respGetTags.substring(0,254) : respGetTags;
				 	 errorNum++;
		        }
	        }
	        
			srvResp.Solariat_Response__c = ( errorResp != '' ) ? errorResp : PROCESSED_SUCCESS;			
	        processedList.add(srvResp); 
	         
		}
				
		update processedList;		      	
    }
    
    global String getAuthToken() {  	
    	accessToken = null;
    	Boolean retStatus = false;
    	String retValue = '';
    	
    	JSONGenerator generator = JSON.createGenerator(true);
    	generator.writeStartObject();     	
        generator.writeStringField('username', username);  
    	generator.writeStringField('password', password);
    	generator.writeStringField('api_key', apiKey);
    	String requestTokenJSON = generator.getAsString();
    	
    	JSONParser parser;    	    	
    	HttpRequest req = new HttpRequest();
        req.setEndpoint(tokenURL);
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        
        req.setBody(requestTokenJSON);                        
        Http http = new Http();
        HTTPResponse res = http.send(req);
           
        if( res.getStatuscode() ==200 )
        {
            String authResult = res.getbody();
            
            parser = JSON.createParser(authResult);
            while (parser.nextToken() != null) {

               if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'ok') )  {
                      parser.nextToken();
                      retStatus = parser.getBooleanValue();
               }                              
               if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'token') ) {
                    	parser.nextToken();
                        accessToken = parser.getText();
               }  
               if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'error') ) {
                    	parser.nextToken();
                        retValue = parser.getText();
               }                
            }
        }
        else {
        	retValue = 'Error obtaining auth Token - ' + res.getStatus();
        }
        
        if ( retStatus ) 
             retValue = STR_SUCCESS_RESPONSE;
                          
    	return retValue;
    }

    global String postSurvey(Survey_Response__c srvResp) {
    	Boolean retStatus = false;
    	String postText = srvResp.Verbatim__c;
    	String retValue = '';
  	  	    
  	    if ( postText == null || postText == '' ) {
  	    	retValue = NO_CONTENT;
  	        return retValue;
  	    }
  	    
  	    postText = postText.replace('\n','').replace('\r','').replace('\\','').replace('"','');
  	   // postText = EncodingUtil.UrlEncode(postText, 'UTF-8');
  	
    	JSONGenerator generator = JSON.createGenerator(true);
    	generator.writeStartObject();     	
        generator.writeStringField('token', accessToken);  
    	generator.writeStringField('username', username);
    	generator.writeStringField('channel', channel);
    	generator.writeStringField('survey_id', srvResp.Id);
    	generator.writeStringField('survey_name', srvResp.Name);
    	generator.writeStringField('verbatim', postText);
    	generator.writeStringField('response_type', srvResp.Response_Type_2__c); 
    	generator.writeStringField('survey_date', srvResp.CreatedDate.format('yyyy-MM-dd HH:mm:ss'));
    	generator.writeEndObject();     	
    	String postSuveyJSON = generator.getAsString();
    	   	    	
    	HttpRequest req = new HttpRequest();
        req.setEndpoint(postURL);
        req.setMethod('POST');
        req.setHeader('content-type', 'application/json');
        
        req.setBody(postSuveyJSON); 
                                       
        Http http = new Http();
        HTTPResponse res = http.send(req);
           
        if( res.getStatuscode() ==200 )
        {
            String responseBody = res.getbody();
            
            JSONParser parser = JSON.createParser(responseBody);
            while (parser.nextToken() != null) {

               if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'ok') )  {
                      parser.nextToken();
                      retStatus = parser.getBooleanValue();
               }
               if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'error') )  {
                      parser.nextToken();
                      retValue = parser.getText();
               }                              
            }
        }
        else {
        	retValue = 'Error Sending data - ' + res.getStatus();
        }
        
        if ( retStatus ) {
        	retValue = STR_SUCCESS_RESPONSE;       	
        }
                       
    	return retValue;
    }

   
    global String getSurveyTags(Survey_Response__c srvResp) {
    	Boolean retStatus = false;
        String retValue = '';
    	
    	String url = postURL;
		url += '?token=' + accessToken;
		url += '&survey_id=' + srvResp.Id;
 	
    	HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        req.setTimeout(20000);

        Http http = new Http();
        HTTPResponse res = http.send(req);
           
        if( res.getStatuscode() ==200 )
        {
            String responseBody = res.getbody();
            
            JSONParser parser = JSON.createParser(responseBody);
            while (parser.nextToken() != null) {

               if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'ok') )  {
                      parser.nextToken();
                      retStatus = parser.getBooleanValue();
               }
               
               if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'tags') )  {
               	   Integer n=1;
               	   while ( parser.nextToken() != JSONToken.END_ARRAY && n<11 )  {
               	   	  String tag = parser.getText();
               	   	 
               	   	  if ( tag != null && tag != '' && tag != '[' && tag != ']' ) {
               	   	  	 srvResp.put('Analytics_Tag' + String.ValueOf(n) + '__c', parser.getText()); 
               	      	 n++;
               		  }
               	   }   
               }
                              
               if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'error') )  {
                      parser.nextToken();
                      retValue = parser.getText();
               }                              
            }
        }
        else {
        	retValue = 'Error quering - ' + res.getStatus();
        }
        
        if ( retStatus ) {
        	retValue = STR_SUCCESS_RESPONSE;       	
        }
                       
    	return retValue;
    }
    
    
    global void finish(Database.BatchableContext ctx){
    	
            if ( notifyOnErrors == null || notifyOnErrors == '' )
                  return;
     
	        AsyncApexJob a = [SELECT id, ApexClassId,
	                       		JobItemsProcessed, TotalJobItems,
	                       		NumberOfErrors, ExtendedStatus
                       			FROM AsyncApexJob
	                       		WHERE id = :ctx.getJobId()];
            
            if ( errorNum > 0 || a.NumberOfErrors > 0 )  {
	            
		        String emailMessage = 'Errors executing job BatchSurveysSendToSolariat sending surveys to Analytics. \n\n'
		         + 'It executed ' + a.totalJobItems  + ' batches. \n'
		         + 'Of which, ' + a.JobItemsProcessed + ' processed without any exceptions thrown. \n'
	             + a.numberOfErrors + ' batches threw unhandled exceptions. \n\n'
	             + 'Of the batches that executed without error, ' + errorNum + ' records were NOT processed successfully.\n'
	             + 'See process detailes in the field Solariat Response. \n'
	             + 'Number of Records processed successfully ' + prcossedNum + ' \n\n' 
	             + 'To resubmit failed recordes, remove text from the field Survey_Response__c.Solariat_Response__c \n\n'
	             + 'Status Details: \n' + a.ExtendedStatus;
		         
		         if (errorMsg != '')
		             emailMessage += '\n\n Additinal Information: ' + errorMsg;
		         
		        Messaging.SingleEmailMessage mail =
		              new Messaging.SingleEmailMessage();
		        String[] toAddresses = new String[] {notifyOnErrors};
		        mail.setToAddresses(toAddresses);
		        mail.setReplyTo('noreply@genesyslab.com');
		        mail.setSenderDisplayName('Batch Job Summary');
		        mail.setSubject('Errors executing job BatchSurveysSendToSolariat');
		        mail.setPlainTextBody(emailMessage);
	        	Messaging.sendEmail(new Messaging.SingleEmailMessage[]
		                           { mail });
            }
	}
	
}