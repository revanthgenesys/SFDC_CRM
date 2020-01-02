@RestResource(urlMapping='/SurveyRespRespondentIdCheck/v1/*')
global with sharing class SurveyRespRespondentIdCheck {

    @HttpPost
    global static String checkExtId(String External_ID,String First_name,String security_token,String Last_name, 
                                    String Verbatim, String NPS_Rating, String Salesforce_Id, String CaseId,
                                    String satisResolTime, String satisTechExpert, String satisProfAttitude, String satisProdQual,
                                    String satisDoc, String satisOther,
                                    String dissResolTime, String dissTechExpert, String dissProfAttitude, String dissProdQual,
                                    String dissDoc, String dissOther )    {
    
    
       String LogName = 'Survey Response';
       String LogSource = 'SurveyRespRespondentIdCheck';
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
                         					
        List<Survey_Response__c> surveyResp_updt = new List<Survey_Response__c>();
        
        if ( CaseId != null )
        	surveyResp_updt = [Select id from Survey_Response__c where Case__c =:CaseId];    
     
        try {
        	
	        if(surveyResp_updt.size() > 0)
	        {
	              surveyResp_updt[0].First_Name__c = First_name;
		          surveyResp_updt[0].NPS_Rating__c = NPS_Rating;
		          surveyResp_updt[0].Last_Name__c = Last_name;
		          surveyResp_updt[0].Verbatim__c = Verbatim;
		          surveyResp_updt[0].Salesforce_id__c = Salesforce_id;
		          
		          update surveyResp_updt[0];
		          retValue = surveyResp_updt[0].id;
	        }
	        else { 
	        	
	            Survey_Response__c surveyResp_inst = new Survey_Response__c (
	              Respondent_ID__c = External_ID, 
	              CaseText__c = CaseId, 
	              NPS_Rating__c = NPS_Rating,
	              First_Name__c = First_name, Last_Name__c = Last_name, 
	              Verbatim__c = Verbatim, 
	              Salesforce_id__c = Salesforce_id,
	              Satis_Responsiveness_Resolution_time__c = satisResolTime.ToUpperCase() == 'YES'? 'Yes' : null, 
	              Satis_Technical_Expertise__c            = satisTechExpert.ToUpperCase() == 'YES'? 'Yes' : null,  
	              Satis_Professionalism_Attitude__c       = satisProfAttitude.ToUpperCase() == 'YES'? 'Yes' : null, 
	              Satis_Product_Quality__c                = satisProdQual.ToUpperCase() == 'YES'? 'Yes' : null, 
                  Satis_Documentation__c                  = satisDoc.ToUpperCase() == 'YES'? 'Yes' : null, 
                  Satis_Other__c = satisOther.length() < 254 ? satisOther : satisOther.substring(0, 254),          
                  Dissatis_Responsiveness_Resolution_time__c = dissResolTime.ToUpperCase() == 'YES'? 'Yes' : null, 
                  Dissatis_Technical_Expertise__c          = dissTechExpert.ToUpperCase() == 'YES'? 'Yes' : null, 
                  Dissatis_Professionalism_Attitude__c     = dissProfAttitude.ToUpperCase() == 'YES'? 'Yes' : null, 
                  Dissatis_Product_Quality__c              = dissProdQual.ToUpperCase() == 'YES'? 'Yes' : null, 
                  Dissatis_Documentation__c                = dissDoc.ToUpperCase() == 'YES'? 'Yes' : null, 
                  Dissatis_Other__c = dissOther.length() < 254 ? dissOther : dissOther.substring(0, 254)
                 );
                  
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