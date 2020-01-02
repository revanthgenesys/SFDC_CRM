@RestResource(urlMapping='/SurveyRespRespondentIdCheckRelation/v1/*')
global without sharing class SurveyRespRespondentIdCheckRelation {

    @HttpPost
    global static String checkExtId(String ContactId, String AccountId, String External_ID,String First_name,
                                    String security_token,String Last_name, String Verbatim,String Verbatim1,String Verbatim2, 
                                    String NPS_Rating, String Salesforce_Id, String CaseId, String Future_Use_Rating, String Contact_Email,
                                    String PartOfOrg, String RoleInOrg, String EaseOfBus, String VerbatimOnEaseOfBus,
                                    String 	NPS_CloudOffer, String NPS_DeplType, String NPS_Tier ) {
        
       String LogName = 'Survey Response';
       String LogSource = 'SurveyRespRespondentIdCheckRelation'; 
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
                
      try {
	            Survey_Response__c surveyResp_inst = new Survey_Response__c(Respondent_ID__c = External_ID, CaseText__c = CaseId,
	                                               NPS_Rating__c = NPS_Rating,First_Name__c = First_name, Last_Name__c = Last_name, 
	                                               Email_Address__c = Contact_Email, Salesforce_id__c = Salesforce_id, 
	                                               Verbatim__c = Verbatim,  Verbatim2__c = Verbatim2,
	                                               Business_Consulting__c = CaseId,
	                                               Future_Business_Consulting_NPS_Rating__c = Future_Use_Rating,
	                                               Department__c ='Customer Care', Survey_Type__c ='Relationship',
	                                               Account__c = AccountId, Contact__c = ContactId,
	                                               Part_of_Organization__c = PartOfOrg, Role_in_Organization__c = RoleInOrg,
	                                               Easiness_of_doing_business_with_Genesys__c = EaseOfBus,
	                                               Verbatim_on_doing_business_with_Genesys__c = VerbatimOnEaseOfBus,
	                                               NPS_Cloud_Offer__c = NPS_CloudOffer, NPS_Deployment_Type__c = NPS_DeplType, NPS_Tier__c = NPS_Tier );
	
	            if(!bc.isEmpty())
	                surveyResp_inst.Account__c = bc[0].End_User_Account__c;
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