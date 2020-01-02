@RestResource(urlMapping='/SurveyResponsePartnerImport/*')
global without sharing class SurveyResponsePartnerImport {
	
	@HttpPost
    global static String importResp(String ContactId, String AccountId, String External_ID,String First_name,String security_token,
                                    String Last_name, String Contact_Email, String Verbatim, String NPS_Rating,
                                    String PartOfOrg, String LikeLeast, String LikeMost)  {
                                    	
       String LogName = 'Survey Response';
       String LogSource = 'SurveyResponsePartnerImport'; 
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

        try { 	        	
	            Survey_Response__c surveyResp_inst = new Survey_Response__c( Respondent_ID__c = External_ID, Survey_Type__c ='Partner', 
	            						            Account__c = AccountId, Contact__c = ContactId, 
	           										First_Name__c = First_name, Last_Name__c = Last_name, Email_Address__c = Contact_Email,	           										 
	           									    NPS_Rating__c = NPS_Rating, Verbatim__c = Verbatim, 
	            							Part_of_Organization__c = PartOfOrg, Like_the_Least__c = LikeLeast, Like_the_most__c = LikeMost
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