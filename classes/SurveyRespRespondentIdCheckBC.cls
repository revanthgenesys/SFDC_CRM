@RestResource(urlMapping='/SurveyRespRespondentIdCheckBC/v1/*')
global without sharing class SurveyRespRespondentIdCheckBC {

    @HttpPost
    global static String checkExtId(String External_ID,String First_name,String security_token,String Last_name, 
                                     String Verbatim,String Verbatim1,String Verbatim2, String NPS_Rating, String Salesforce_Id, 
                                     String CaseId, String Future_Use_Rating, String Contact_Email  )    {
        
       String LogName = 'Survey Response';
       String LogSource = 'SurveyRespRespondentIdCheckBC'; 
       String baseLogMsg = External_ID;
       String retValue='';  
        
       if ( NPS_Rating == '' ) {
       	   String logMsg = baseLogMsg + ': NPS Rating Blank';
           ErrorLogUtil.insertLog(LogName, logMsg, LogSource);          
           return logMsg;
      	}
        
        if ( !verifyToken(security_token) ) {
           String logMsg = baseLogMsg + ': Invalid Security Token.';
           ErrorLogUtil.insertLog(LogName, logMsg, LogSource);         
           return logMsg;
        }       
        
        List<Business_Consulting__c> bc = [Select End_User_Account__c from Business_Consulting__c where id = :CaseId];        
        List<Survey_Response__c> surveyResp_updt = [Select id from Survey_Response__c where Respondent_ID__c = :CaseId];
        
        try {
        	
	        if(surveyResp_updt.size() > 0)
	        {
	    		surveyResp_updt[0].First_Name__c = First_name;
		          surveyResp_updt[0].NPS_Rating__c = NPS_Rating;
		          surveyResp_updt[0].Last_Name__c = Last_name;
		          surveyResp_updt[0].Verbatim__c = Verbatim1;
		          surveyResp_updt[0].Verbatim2__c = Verbatim2;
		          
		          surveyResp_updt[0].Future_Business_Consulting_NPS_Rating__c = Future_Use_Rating;
		          surveyResp_updt[0].Salesforce_id__c = Salesforce_id;
		          if(!bc.isEmpty())
		            surveyResp_updt[0].Account__c = bc[0].End_User_Account__c;
		          update surveyResp_updt[0];
		          retValue = surveyResp_updt[0].id;
	        }
	        else { 
	        	
	            Survey_Response__c surveyResp_inst = new Survey_Response__c( Respondent_ID__c = External_ID,CaseText__c = CaseId,
	                                                                 NPS_Rating__c = NPS_Rating,
	                                                                 First_Name__c = First_name,Last_Name__c = Last_name, Email_Address__c = Contact_Email,
	                                                                 Verbatim__c = Verbatim1, Verbatim2__c = Verbatim2,
	                                                                 Salesforce_id__c = Salesforce_id, Business_Consulting__c = CaseId,
	                                                                 Future_Business_Consulting_NPS_Rating__c = Future_Use_Rating,
	                                                                 Department__c ='Business Consulting', Survey_Type__c ='Transactional' );
	            
	  
	             if(!bc.isEmpty())
	                surveyResp_inst.Account__c = bc[0].End_User_Account__c;
	            insert surveyResp_inst;
	            retValue = surveyResp_inst.id;
	         }
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