@RestResource(urlMapping='/SurveyResponseSMART/*')
global class SurveyResponseSMART {
	
	global class SurvResponse {
		public String External_ID, security_token, opptyId, DSR_EngmntId,
		              RatingOnBusValue, RatingOnCX, RatingOnSolDesign,  
		              NPS_Rating, Verbatim, CX_Verbatim, BusValue_Verbatim, SolDesign_Verbatim;		              
	}
	
	@HttpPost
    global static String processResp(SurvResponse SurvResponse)  {
    	
       String LogName = 'Survey Response';
       String LogSource = 'SurveyResponseSMART'; 
       String baseLogMsg = SurvResponse.External_ID;
       String retValue='';  
        
       if ( SurvResponse.NPS_Rating == '' ) {
       	   String logMsg = baseLogMsg + ': NPS Rating Blank';
           ErrorLogUtil.insertLog(LogName, logMsg, LogSource);          
           return logMsg;
      	}
        
        if ( !verifyToken(SurvResponse.security_token) ) {
           String logMsg = baseLogMsg + ': Invalid Security Token.';
           ErrorLogUtil.insertLog(LogName, logMsg, LogSource);         
           return logMsg;
        } 
        
        if ( String.isBlank(SurvResponse.opptyId) ) {
           String logMsg = baseLogMsg + ': Opportunity ID is blank.';
           ErrorLogUtil.insertLog(LogName, logMsg, LogSource);         
           return logMsg;
        }   
        
        try {
        	
        	 List<Opportunity> opp = [SELECT Contact__c, AccountId FROM Opportunity WHERE id = :SurvResponse.opptyId];
        	 
        	 List<RecordType> rt = [SELECT Id FROM RecordType WHERE Name = 'SMART' AND sobjecttype = 'Survey_Response__c'];
        	 Survey_Response__c surveyResp_inst = new Survey_Response__c( 
        	        Survey_Type__c = 'SMART',
        	        RecordTypeId = rt[0].Id,
        	        Respondent_ID__c = SurvResponse.External_ID, 
	                NPS_Rating__c = SurvResponse.NPS_Rating, 
	            	Verbatim__c = SurvResponse.Verbatim, 
	                Opportunity__c = SurvResponse.opptyId,
	                DSR_SC_Engagement__c = SurvResponse.DSR_EngmntId,
	                Verbatim_on_CX_vision__c = SurvResponse.CX_Verbatim,
	                Verbatim_on_Business_Value__c = SurvResponse.BusValue_Verbatim,
	                Verbatim_on_solution_design__c = SurvResponse.SolDesign_Verbatim,
	                Rating_on_Business_Value__c = SurvResponse.RatingOnBusValue, 	
	                Rating_on_CX_Vision__c = SurvResponse.RatingOnCX, 
	                Rating_on_Solution_Design__c = SurvResponse.RatingOnSolDesign,  
	                Contact__c = opp[0].Contact__c,
	                Account__c = opp[0].AccountId
	             );
	            
	            insert surveyResp_inst;
	            retValue = surveyResp_inst.id;
	
        } 
        catch (Exception ex) {
	   	    String logMsg = baseLogMsg + ': ' + ex.getMessage();
	   	    ErrorLogUtil.insertLog(LogName, logMsg, LogSource);  
        	return ex.getMessage();
       } 
        
       return retValue;      

    }
    
    private static Boolean verifyToken(String token)  {
   	    Survey_Integration_Inbound__c custConf = Survey_Integration_Inbound__c.getOrgDefaults();    	     
        return ( custConf.Security_Token__c == null || custConf.Security_Token__c !=  token ) ? false : true;    			 			    	
   	}
}