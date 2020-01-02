@RestResource(urlMapping='/SurveyRespRespondentIdCheckPS/v1/*')
global class SurveyRespRespondentIdCheckPS {

   global class SurveyResponse {
   	
    public String Contact_Email, External_ID, First_name, security_token, Last_name, Verbatim,  NPS_Rating,  Salesforce_Id, CaseId,  
		          Contact_Name,  Contact_Title, Contact_Phone,   Friendly_Project_Name, Project_GoLive_Date, 
				  Project_Reference_ID,  Client,  Project_Name, Project_Description, Project_Type, 
		          Project_Health,  Project_Start_Date, Project_End_Date,  End_User, Direct_Indirect, 
		          Delivery_PM,  AE_Name , BD_PM_Name, Budget, Project_Business_Unit,
		          Project_COE_Resources, SFDC_Client_Reference_ID,  SF_Opportunity_ID, Internal_ID,
		          Date_readyTo_Send_Survey; 	
   }

    @HttpPost
    global static String checkExtId(SurveyResponse SurvResponse)  {
  
       String LogName = 'Survey Response';
       String LogSource = 'SurveyRespRespondentIdCheckPS'; 
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
  
        List<Survey_Response__c> surveyResp_updt = new List<Survey_Response__c>();
        
        if ( SurvResponse.CaseId != null )
       		 surveyResp_updt = [Select id from Survey_Response__c where Case__c =: SurvResponse.CaseId];
       		 
        try {
        	
        	List<Opportunity> opp = new List<Opportunity>();
        	if ( SurvResponse.SF_Opportunity_ID != null )
       	       opp = [SELECT ID FROM Opportunity WHERE id = :SurvResponse.SF_Opportunity_ID];
       	       
       	    List<Account> acct = new List<Account>();
       	    if ( SurvResponse.SFDC_Client_Reference_ID != null )
       	       acct = [SELECT ID FROM Account WHERE id = :SurvResponse.SFDC_Client_Reference_ID];
       	            	
	        if(surveyResp_updt.size() > 0) {
	              surveyResp_updt[0].First_Name__c = SurvResponse.First_name;
		          surveyResp_updt[0].NPS_Rating__c = SurvResponse.NPS_Rating;
		          surveyResp_updt[0].Last_Name__c = SurvResponse.Last_name;
		          surveyResp_updt[0].Verbatim__c = SurvResponse.Verbatim;
		          surveyResp_updt[0].Salesforce_id__c = SurvResponse.Salesforce_id;
		          
		          update surveyResp_updt[0];
		          retValue = surveyResp_updt[0].id;
	        }
	        else { 
	        	  	
	            Survey_Response__c surveyResp_inst = new Survey_Response__c( Respondent_ID__c = SurvResponse.External_ID, CaseText__c = SurvResponse.CaseId,
	               NPS_Rating__c = SurvResponse.NPS_Rating, First_Name__c = SurvResponse.First_name, Last_Name__c = SurvResponse.Last_name, 
	            	Verbatim__c = SurvResponse.Verbatim, Salesforce_id__c = SurvResponse.Salesforce_id, Contact_Name__c= SurvResponse.Contact_Name,
	            	Contact_Title__c= SurvResponse.Contact_Title, Contact_Phone__c=SurvResponse.Contact_Phone, 
	            	Friendly_Project_Name__c = SurvResponse.Friendly_Project_Name, COE_resources_assigned__c = SurvResponse.Project_COE_Resources,
	            	Project_Go_Live_Date__c = SurvResponse.Project_GoLive_Date, Project_Reference_ID__c = SurvResponse.Project_Reference_ID, 
	            	Client__c = SurvResponse.Client, Survey_Requested__c = SurvResponse.Date_readyTo_Send_Survey,
	            	OrenAir_Project_Id__c = SurvResponse.Internal_ID, 
	                Project_Name__c = SurvResponse.Project_Name, Project_Description__c = SurvResponse.Project_Description, Project_Type__c = SurvResponse.Project_Type,
	               Project_Health__c = SurvResponse.Project_Health, Project_Start_Date__c = SurvResponse.Project_Start_Date, Project_End_Date__c = SurvResponse.Project_End_Date,
	                Direct_or_Indirect__c = SurvResponse.Direct_Indirect, Delivery_PM__c = SurvResponse.Delivery_PM, AE_Name__c = SurvResponse.AE_Name, 
	                BD_PM_Name__c = SurvResponse.BD_PM_Name, Budget__c = SurvResponse.Budget, Project_Business_Unit__c = SurvResponse.Project_Business_Unit,
	                Department__c = 'PS', PS_Contact_Email__c = SurvResponse.Contact_Email, End_user__c = SurvResponse.End_User );
	            
	            if ( !opp.isEmpty())
	               surveyResp_inst.Opportunity__c = SurvResponse.SF_Opportunity_ID;
	               
	            if ( !acct.isEmpty() ) 
	                 surveyResp_inst.Account__c = SurvResponse.SFDC_Client_Reference_ID;
	            
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