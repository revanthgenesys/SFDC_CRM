@isTest
public class SurveyRespRespondentIdChecks_Test  {
	
	static testmethod void testSurveyRespRespondentIdCheck() {
		
        Util.Bypass_Trigger_Chk = true;
		Survey_Integration_Inbound__c custConf = new Survey_Integration_Inbound__c(Security_Token__c = 'token');
		insert custConf;   	
	      
	    List<Case> cs = TestUtil.createCases(1, true);
	    /// insert    
		String retVal = SurveyRespRespondentIdCheck.checkExtId('External_ID', 'First_name', 'token', 'Last_name', 
	                                'Verbatim', 'NPS_Rating', null, cs[0].CaseNumber,
	                                null, 'Yes', 'Yes', null, null, 'text', 'No', null, 'Yes', null, null, null);
	                                
	    System.assertNotEquals(null, retVal);
	    
	    Survey_Response__c surveyResp_inst = new Survey_Response__c(Case__c = cs[0].Id);
		insert surveyResp_inst;
		
		retVal = SurveyRespRespondentIdCheck.checkExtId('External_ID', 'First_name', 'token', 'Last_name', 
	                                'Verbatim', 'NPS_Rating', null, cs[0].Id,
	                                 null, 'Yes', 'Yes', 'Yes', 'Yes', 'text', 'No', 'No', 'Yes', 'No', 'No', 'No');
			
		System.assertNotEquals(null, retVal);
		
		//error
		retVal = SurveyRespRespondentIdCheck.checkExtId('External_ID', 'First_name', '', 'Last_name', 
	                                'Verbatim', 'NPS_Rating', null, cs[0].Id,
	                                 null, 'Yes', 'Yes', null, null, 'text', 'No', null, 'Yes', null, null, null);
  }
  
  static testmethod void testSurveyRespRespondentIdCheckRelPremise() {
  	   
         Util.Bypass_Trigger_Chk = true;
		Survey_Integration_Inbound__c custConf = new Survey_Integration_Inbound__c(Security_Token__c = 'token');
		insert custConf;   	
	      
	    List<Case> cs = TestUtil.createCases(1, true);
	    /// insert    
		String retVal = SurveyRespRespondentIdCheckRelPremise.checkExtId(null, null, 'External_ID', 'First_name', 'token', 'Last_name', 
	                                'Verbatim', 'Verbatim1', 'Verbatim2', 'NPS_Rating', null, cs[0].CaseNumber, null, 'test@test',
	                                'Verbatim3', null, null, null, null, null, null, null, null);
	                                
	    System.assertNotEquals(null, retVal);
	        Survey_Response__c surveyResp_inst = new Survey_Response__c(Case__c = cs[0].Id, Respondent_ID__c='First_name');
		insert surveyResp_inst;
		
		retVal = SurveyRespRespondentIdCheckRelPremise.checkExtId(null, null, 'External_ID', 'First_name', 'token', 'Last_name', 
	                                'Verbatim', 'Verbatim1', 'Verbatim2', 'NPS_Rating', null, cs[0].Id, null, 'test@test',
	                                'Verbatim3', null, null, null, null, null, null, null, null );
	                                			
		System.assertNotEquals(null, retVal);
		
		//error
		retVal = SurveyRespRespondentIdCheckRelPremise.checkExtId(null, null, 'External_ID', 'First_name', '', 'Last_name', 
	                                'Verbatim', 'Verbatim1', 'Verbatim2', 'NPS_Rating', null, cs[0].Id, null, 'test@test',
	                                'Verbatim3', null, null, null, null, null, null, null, null );
  	 
  }
  
  static testmethod void testSurveyRespRespondentIdCheckBC() {
  	
         Util.Bypass_Trigger_Chk = true;
		Survey_Integration_Inbound__c custConf = new Survey_Integration_Inbound__c(Security_Token__c = 'token');
		insert custConf;   	
	      
	    List<Case> cs = TestUtil.createCases(1, true);
	    /// insert    
		String retVal = SurveyRespRespondentIdCheckBC.checkExtId('External_ID', 'First_name', 'token', 'Last_name', 
	                                'Verbatim', 'Verbatim1', 'Verbatim2', 'NPS_Rating', null, cs[0].CaseNumber, null, 'test@test');
	                                
	    System.assertNotEquals(null, retVal);
	        Survey_Response__c surveyResp_inst = new Survey_Response__c(Case__c = cs[0].Id, Respondent_ID__c=cs[0].Id);
		insert surveyResp_inst;
		
		retVal = SurveyRespRespondentIdCheckBC.checkExtId('External_ID', 'First_name', 'token', 'Last_name', 
	                                'Verbatim', 'Verbatim1', 'Verbatim2', 'NPS_Rating', null, cs[0].Id, null, 'test@test');
	                                
		System.assertNotEquals(null, retVal);
		
		//error
		retVal = SurveyRespRespondentIdCheckBC.checkExtId('External_ID', 'First_name', '', 'Last_name', 
	                                'Verbatim', 'Verbatim1', 'Verbatim2', 'NPS_Rating', null, cs[0].Id, null, 'test@test');
  	 
  }
  
  static testmethod void SurveyRespRespondentIdCheckPS() {
  	
         Util.Bypass_Trigger_Chk = true;
		Survey_Integration_Inbound__c custConf = new Survey_Integration_Inbound__c(Security_Token__c = 'token');
		insert custConf;   	
	      
	    List<Case> cs = TestUtil.createCases(1, true);
	    /// insert   
	    
	    SurveyRespRespondentIdCheckPS.SurveyResponse sr = new SurveyRespRespondentIdCheckPS.SurveyResponse();
	    sr.security_token ='token';
	    sr.External_ID = '15CAC354BE800011D0185201B00000000000';
	    sr.NPS_Rating = '6';
	    sr.SF_Opportunity_ID = '006U000000IxAQiIAN';
	    sr.CaseId = 'TMCO-102713';
	    
	    String retVal = SurveyRespRespondentIdCheckPS.checkExtId(sr);
	    
	    System.assertNotEquals(null, retVal);
	        Survey_Response__c surveyResp_inst = new Survey_Response__c(Case__c = cs[0].Id, First_Name__c=cs[0].Id);
		insert surveyResp_inst;
		
		sr.CaseId = cs[0].Id;
		String retVal2 = SurveyRespRespondentIdCheckPS.checkExtId(sr);
		
		sr.NPS_Rating = '';
	    String retVal3 = SurveyRespRespondentIdCheckPS.checkExtId(sr);
  }
  
   static testmethod void testSurveyRespRespondentIdCheckRelation() {
  	   
         Util.Bypass_Trigger_Chk = true;
		Survey_Integration_Inbound__c custConf = new Survey_Integration_Inbound__c(Security_Token__c = 'token');
		insert custConf;   	
	      
	    List<Case> cs = TestUtil.createCases(1, true);
	    /// insert    
		String retVal = SurveyRespRespondentIdCheckRelation.checkExtId(null, null, 'External_ID', 'First_name', 'token', 'Last_name', 
	                                'Verbatim', 'Verbatim1', 'Verbatim2', 'NPS_Rating', null, cs[0].CaseNumber, null, 'test@test',
	                                null, null, null, null, null, null, null);
	                                
	    System.assertNotEquals(null, retVal);
	        Survey_Response__c surveyResp_inst = new Survey_Response__c(Case__c = cs[0].Id, Respondent_ID__c='First_name');
		insert surveyResp_inst;
		
		retVal = SurveyRespRespondentIdCheckRelation.checkExtId(null, null, 'External_ID', 'First_name', 'token', 'Last_name', 
	                                'Verbatim', 'Verbatim1', 'Verbatim2', 'NPS_Rating', null, cs[0].Id, null, 'test@test', 
	                                null, null, null, null, null, null, null);
	                                
		System.assertNotEquals(null, retVal);
		
		//error
		retVal = SurveyRespRespondentIdCheckRelation.checkExtId(null, null, 'External_ID', 'First_name', '', 'Last_name', 
	                                'Verbatim', 'Verbatim1', 'Verbatim2', 'NPS_Rating', null, cs[0].Id, null, 'test@test', 
	                                null, null, null, null, null, null, null);
  	 
  }
  
   static testmethod void testSurveyResponsePartnerImport() {
  	  
         Util.Bypass_Trigger_Chk = true;
		Survey_Integration_Inbound__c custConf = new Survey_Integration_Inbound__c(Security_Token__c = 'token');
		insert custConf;   	
	      
	    /// insert    
		String retVal = SurveyResponsePartnerImport.importResp(null, null,'External_ID', 'First_name', 'token', 'Last_name', 
	                              'cont@test.com', 'Verbatim', 'NPS_Rating', 'partOfOrg', 'like', 'dont like');
	                                
	    System.assertNotEquals(null, retVal);
	    
		//error
		retVal =  SurveyResponsePartnerImport.importResp(null, null, 'External_ID', 'First_name', '', 'Last_name', 
	                                'cont@test.com', 'Verbatim', null, null, null, null);
	                                
	   retVal = SurveyResponsePartnerImport.importResp(null, null,'External_ID', 'First_name', 'token', 'Last_name', 
	                              'cont@test.com', 'Verbatim', '', 'partOfOrg', 'like', 'dont like');
  	 
  }
  
  static testmethod void testSurveyResponseSMARTImport() {
         Util.Bypass_Trigger_Chk = true;
		Survey_Integration_Inbound__c custConf = new Survey_Integration_Inbound__c(Security_Token__c = 'token');
		insert custConf;   	
	      
	    /// insert    
	    SurveyResponseSMART.SurvResponse sr = new SurveyResponseSMART.SurvResponse();
	    sr.security_token ='token';
	    sr.External_ID = '15CAC354BE800011D0185201B00000000000';
	    sr.NPS_Rating = '6';
	    sr.opptyId = '006U000000IxAQiIAN';
	    sr.Verbatim = 'TMCO-102713';
	    sr.CX_Verbatim = 'CX_Verbatim';
	    sr.BusValue_Verbatim = 'BusValue_Verbatim';
	    sr.SolDesign_Verbatim = 'SolDesign_Verbatim';
	    sr.RatingOnBusValue = '10';
	    sr.RatingOnCX = '10';
	    sr.RatingOnSolDesign = '9';
	    
	    String retVal = SurveyResponseSMART.processResp(sr);
	    
	    SurveyResponseSMART.SurvResponse sr1 = new SurveyResponseSMART.SurvResponse();
	    sr1.security_token ='';
	    sr1.External_ID = '15CAC354BE800011D0185201B00000000000';
	    sr1.NPS_Rating = '6';
	    sr1.opptyId = '006U000000IxAQiIAN';
	    sr1.Verbatim = 'TMCO-102713';
	    sr1.CX_Verbatim = 'CX_Verbatim';
	    sr1.BusValue_Verbatim = 'BusValue_Verbatim';
	    sr1.SolDesign_Verbatim = 'SolDesign_Verbatim';
	    sr.RatingOnBusValue = '10';
	    sr.RatingOnCX = '10';
	    sr.RatingOnSolDesign = '9';
	    
	    String retVal1 = SurveyResponseSMART.processResp(sr1);
	    
	   SurveyResponseSMART.SurvResponse sr2 = new SurveyResponseSMART.SurvResponse();
	   sr2.security_token ='token';
	   sr2.External_ID = '15CAC354BE800011D0185201B00000000000';
	   sr2.NPS_Rating = '6';
	   sr2.opptyId = '';
	   sr2.Verbatim = 'TMCO-102713';
	   sr2.CX_Verbatim = 'CX_Verbatim';
	   sr2.BusValue_Verbatim = 'BusValue_Verbatim';
	   sr2.SolDesign_Verbatim = 'SolDesign_Verbatim';
	   sr.RatingOnBusValue = '10';
	   sr.RatingOnCX = '10';
	   sr.RatingOnSolDesign = '9';
	    
	    String retVal2 = SurveyResponseSMART.processResp(sr2);
  	 
  }
  
}