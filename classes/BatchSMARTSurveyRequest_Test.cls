@isTest //(SeeAllData = true)
public class BatchSMARTSurveyRequest_Test {
	
	static testmethod void test1()
    {
        try
        {
            Util.Bypass_Trigger_Chk = true;

            DSR_UseCase_BluePrint_Definition__c objDataDef_Fn = new DSR_UseCase_BluePrint_Definition__c();
            objDataDef_Fn.Active__c = true;
            objDataDef_Fn.Name__c = 'B01';
            objDataDef_Fn.ShortCode__c = 'B01';
            objDataDef_Fn.Type__c = 'Use Case';
            insert objDataDef_Fn;
    
            Account objTestAccount = new Account( Name='Test Account', Status__c = 'Active' );
            insert objTestAccount;
            
            Contact objContact = TestUtil.createContacts(1, objTestAccount, true)[0];
            
            Opportunity objTestOppty = new Opportunity(Name = 'Test Opp', AccountId = objTestAccount.Id);
            objTestOppty.Contact__c = objContact.Id;
            objTestOppty.CloseDate = Date.today().addDays(-9);
            objTestOppty.ForecastStatus__c = '0.Booked';
            objTestOppty.StageName = '6.Closed';     
            objTestOppty.Win_Loss_Status__c = 'Won'	;
            objTestOppty.BusinessPartner__c = objTestAccount.Id;
            objTestOppty.RecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Opportunity' 
                                        AND DeveloperName = 'Genesys_Renewal'].Id;
            insert objTestOppty;
            
            DSR_SCEngagement__c objSCE = new DSR_SCEngagement__c();
            objSCE.Account_ID__c = objTestAccount.id;
            objSCE.Opportunity_ID__c = objTestOppty.id;
            objSCE.SC_Engagement_Status__c = 'Completed';
            objSCE.Smart_Opportunity_Intent_Use__c = 'Yes';
            objSCE.Design_Start_Date__c = Date.Today().addDays(-20);
            objSCE.Design_End_Date__c = Date.Today().addDays(-10);
            
            insert objSCE;
      
            DSR_SCE_Design__c objSCDesign = new DSR_SCE_Design__c();
            objSCDesign.DSR_SCEngagement__c = objSCE.id;
            objSCDesign.HAType__c = 'aa';
            objSCDesign.DataCenters__c = 'aa';
            insert objSCDesign ;
              
            DSR_Use_Case_Blueprints__c objFnUseCase = new DSR_Use_Case_Blueprints__c();
            objFnUseCase.DSRSCEDesign__c = objSCDesign.id;
            objFnUseCase.DSRSCEngagement__c = objSCE.id;
            objFnUseCase.ShortCode__c = 'B01';
            objFnUseCase.Type__c = 'Use Case';
            objFnUseCase.Name__c = 'aa';
  
            SmartSurveyConfiguration__c custConf = new SmartSurveyConfiguration__c(
            Notify_On_Errors__c = 'tst@tst.com',     
            Endpoint__c = 'https//gen.com',   
            Username__c = 'usr',    
            Psswd__c = 'psswd'    
	        );
	        insert custConf;
            
            Test.startTest();
 
            Test.setMock(HttpCalloutMock.class, new Test_BatchSurveySolariatHttpResponseMock());
            Test_BatchSurveySolariatHttpResponseMock.returnType = 'Error';
            
            BatchSMARTSurveyRequest batch = new BatchSMARTSurveyRequest();
	        Database.executeBatch(batch, 1); 
              
            Test.stopTest();
        }
        catch(CalloutException ex)
        {}
    }
    
    static testmethod void tstschedulable() {
	   Test.startTest();
         system.schedule('BatchSMARTSurveyRequestTest','0 0 * * * ?', new BatchSMARTSurveyRequestSchedulable());
       Test.stopTest();
	}   
}