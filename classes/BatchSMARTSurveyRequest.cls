/************************************************************************************
Purpose : Daily batch to send request for Survey to SoundBite when followining conditions are met
  Opportunity:
    Stage = 6. Closed
    Win/Loss Status = Won
    Primary Contact is assigned
If criterias are met – wait for 7 days, after that check DSR SC Engagement Status:
   SC Engagement Status = Completed
   SMART Opportunity Flag = True
   From Design – are use cases assigned?
     
Written By : Mariya Steason
Test Classes : BatchSMARTSurveyRequest_Test
Business Areas affected: DSR 

//   BatchSMARTSurveyRequest batch = new BatchSMARTSurveyRequest();
	 Database.executeBatch(batch, 5);
*************************************************************************************/
global class BatchSMARTSurveyRequest  implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    
    global String endpoint;  
    global String username;    
    global String password;    
    global String notifyOnErrors;
    global Map<String, String> useCaseCode;
    global Map<String, String> useCaseName;
            
    global BatchSMARTSurveyRequest() {  
        SmartSurveyConfiguration__c custConf = SmartSurveyConfiguration__c.getOrgDefaults();
        this.notifyOnErrors = custConf.Notify_On_Errors__c;     
        this.endpoint = custConf.Endpoint__c;   
        this.username = custConf.Username__c;    
        this.password = custConf.Psswd__c;    
    }
    
    ///JSON format
    public class SurvReqHeader {
    	public cls_owner owner  {get; set;} 
    	public cls_campaign campaign  {get; set;}
    	public cls_outstr outreachStrategy  {get; set;}
    	
    	public SurvReqHeader () {
    		owner = new cls_owner();
    		campaign = new cls_campaign();
    		outreachStrategy = new cls_outstr();
    	}
    } 
    public class cls_owner {
    	public String internalId = '3000311503';     	
    }
    public class cls_campaign {
    	public String externalId = 'Sales_Survey';
    } 
    public class cls_outstr {
    	public String externalId = 'sales_survey';
    } 
    public class cls_body {		   
		public String externalId {get; set;}	
		public List<BatchSMARTSurveyRequest.cls_devices> devices {get; set;}
		public List<BatchSMARTSurveyRequest.cls_attributes> attributes {get; set;}	
    }   
	public class cls_devices {
		public String externalId {get; set;}	
	}
	public class cls_attributes {
		public String name {get; set;}	
		public String value {get; set;}	
	}    
    
    global Database.Querylocator start(Database.BatchableContext ctx) {
        
        return Database.getQueryLocator([SELECT Id, Name, Primary_Design_ID__c, Primary_Design_ID__r.Name,
								           AccountName__c, 
								           Opportunity_ID__r.Contact__c, Opportunity_ID__r.Contact__r.FirstName,
										   Opportunity_ID__r.Contact__r.LastName, Opportunity_ID__r.Contact__r.Email,
										   OpportunityOfferingType__c, OpportunityPlatformType__c, OpportunityName__c,
										   Opportunity_ID__c, Opportunity_ID__r.Owner.FirstName, 
										   Opportunity_ID__r.Owner.LastName, Opportunity_ID__r.Owner.Email
								    FROM DSR_SCEngagement__c
								    WHERE SC_Engagement_Status__c = 'Completed'                     
								      AND Smart_Opportunity_Intent_Use__c = 'Yes'
								      AND Opportunity_ID__r.StageName = '6.Closed'	
								      AND Opportunity_ID__r.Win_Loss_Status__c = 'Won'	  
									  AND Opportunity_ID__r.Contact__c != null 
									  AND Number_of_Designs__c > 0
									  AND Opportunity_ID__r.CloseDate >= :Date.today().addDays(-10) 
									  AND Opportunity_ID__r.CloseDate < :Date.today().addDays(-7)
									  AND Survey_Requested_On__c = null]);  								 							                                                 
        return null;        
    }
        
    global void execute(Database.BatchableContext ctx, List<Sobject> scope) {
        List<DSR_SCEngagement__c> dseng = (List<DSR_SCEngagement__c>) scope;
        List<DSR_SCEngagement__c> processedList = new List<DSR_SCEngagement__c>();

        /// use cases
        List<DSR_Use_Case_Blueprints__c> usecases = [SELECT Name__c, ShortCode__c, DSRSCEDesign__c, DSRSCEngagement__c
                                                     FROM DSR_Use_Case_Blueprints__c 
                                                     WHERE Type__c ='Use Case' 
                                                     AND DSRSCEngagement__c IN :scope];
                                                      
        useCaseCode = new Map<String, String>();
        useCaseName = new Map<String, String>();
        if ( !usecases.isEmpty() )  {
        	for (DSR_Use_Case_Blueprints__c usc : usecases)  {
        		if ( usc.Name__c != null && String.isNotBlank(usc.Name__c) ) {
        			///names
        			if ( useCaseName.containsKey(usc.DSRSCEngagement__c) )
        			   useCaseName.put(usc.DSRSCEngagement__c, useCaseName.get(usc.DSRSCEngagement__c) + ',' + usc.Name__c);
        			else         					   
        			   useCaseName.put(usc.DSRSCEngagement__c, usc.Name__c);        			        			
        			///codes
        			if ( useCaseCode.containsKey(usc.DSRSCEngagement__c) )
        			   useCaseCode.put(usc.DSRSCEngagement__c, useCaseCode.get(usc.DSRSCEngagement__c) + ',' + usc.ShortCode__c);
        			else     			   
        			   useCaseCode.put(usc.DSRSCEngagement__c, usc.ShortCode__c);
        		}        		
        	} // end for       	
        } /// use cases
        
        ///send requests
        Set<Id> oppty = new Set<Id>(); ///skip if already been processed in a different engagement
        for ( DSR_SCEngagement__c eng : dseng ) {
            if ( !oppty.contains(eng.Opportunity_ID__c) ) {
            	
	            String payload = buildPayload(eng);
	            
	        	if ( postRequest(payload) ) {
	        	   eng.Survey_Requested_On__c = System.now();	        	   
	        	   processedList.add(eng);
	        	}	        	
	        	oppty.add(eng.Opportunity_ID__c);
            }
            else {
              ///multiple engagements for same oppty and one of them is already processed
               eng.Survey_Requested_On__c = System.now();
               processedList.add(eng);
            }
        }
        
        if ( !processedList.isEmpty() )	
    	   update processedList; 
    }
    
    global String buildPayload(DSR_SCEngagement__c eng) {
    	String payload;
    	SurvReqHeader hdr = new SurvReqHeader();   
    	cls_body sr = new cls_body();
        
    	sr.externalId = eng.Opportunity_ID__c;
    	
    	List<BatchSMARTSurveyRequest.cls_devices> dvlst = new List<BatchSMARTSurveyRequest.cls_devices>();
    	cls_devices dv = new cls_devices();
    	dv.externalId = eng.Opportunity_ID__r.Owner.Email;
    	dvlst.add(dv);    	
    	sr.devices = dvlst;
    	
    	List<BatchSMARTSurveyRequest.cls_attributes> attrlst = new List<BatchSMARTSurveyRequest.cls_attributes>();
  	
    	cls_attributes opfstnm = new cls_attributes();
    	opfstnm.name ='firstName';
    	opfstnm.value = eng.Opportunity_ID__r.Owner.FirstName;
    	attrlst.add(opfstnm);

    	cls_attributes oplst = new cls_attributes();
    	oplst.name ='lastName';
    	oplst.value = eng.Opportunity_ID__r.Owner.LastName;
    	attrlst.add(oplst);
    	
    	cls_attributes other1 = new cls_attributes();
    	other1.name ='other1';
    	other1.value = eng.OpportunityName__c;
    	attrlst.add(other1);
    	
    	cls_attributes other2 = new cls_attributes();
    	other2.name ='other2';
    	other2.value = eng.AccountName__c;
    	attrlst.add(other2);
    	
    	cls_attributes other3 = new cls_attributes();
    	other3.name ='other3';
    	other3.value = eng.OpportunityOfferingType__c;
    	attrlst.add(other3);
    	
    	cls_attributes other4 = new cls_attributes();
    	other4.name ='other4';
    	other4.value = eng.OpportunityPlatformType__c;
    	attrlst.add(other4);
    	
    	cls_attributes other5 = new cls_attributes();
    	other5.name ='other5';
    	other5.value = eng.Opportunity_ID__r.Contact__r.FirstName + ',' + 
    	               eng.Opportunity_ID__r.Contact__r.LastName + ',' + 
    	               eng.Opportunity_ID__r.Contact__r.Email;
    	attrlst.add(other5);
    	
    	cls_attributes other6 = new cls_attributes();
    	other6.name ='other6';
    	other6.value = eng.Primary_Design_ID__r.Name;
    	attrlst.add(other6);
    	
    	cls_attributes other7 = new cls_attributes();
    	other7.name ='other7';
    	other7.value = eng.Primary_Design_ID__c + ',' + eng.Id;
    	attrlst.add(other7);
    	
    	cls_attributes other8 = new cls_attributes();
    	other8.name ='other8';
    	other8.value = useCaseCode.get(eng.Id) == null ? '' : useCaseCode.get(eng.Id);
    	attrlst.add(other8);
    	
    	cls_attributes other9 = new cls_attributes();
    	other9.name ='other9';
    	other9.value = useCaseName.get(eng.Id) == null ? '' : useCaseName.get(eng.Id);
    	attrlst.add(other9);
    	   	    	
    	sr.attributes = attrlst;
    	
    	System.debug('*** Payload: ' + '[' + JSON.serialize(hdr) + ', [' + JSON.serialize(sr) + ']]');
  	
    	payload = '[' + JSON.serializePretty(hdr) + ', [' + JSON.serializePretty(sr) + ']]';
    	 
    	return payload;
    }
    
    global Boolean postRequest(String payload) {
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

        System.debug('** Status Code: ' + res.getStatusCode());
        
      	if ( res.getStatusCode() != 200 )  //error
      	  return false;

    	return true;		
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
	            
		        String emailMessage = 'Errors executing job BatchSMARTSurveyRequest. \n\n'
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
		        mail.setSubject('Errors executing job BatchSMARTSurveyRequest');
		        mail.setPlainTextBody(emailMessage);
	        	Messaging.sendEmail(new Messaging.SingleEmailMessage[]
		                           { mail });  
            }
        
     }
}