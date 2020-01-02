@isTest
private class SurveyResponseTriggerHandlerTest {

	private static testMethod void SurveyResponseMethodOne() {
    
         test.starttest(); 
            //Create Account
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
            
            Survey_Response__c SurveyResponse = new Survey_Response__c();
            SurveyResponse.Survey_Type__c = 'Transactional';
            SurveyResponse.Department__c = 'Customer Care';
            SurveyResponse.Account__c = lstAcc[0].Id;
            insert SurveyResponse;
            
            Survey_Response__c SurveyResponse1 = new Survey_Response__c();
            SurveyResponse1.Survey_Type__c = 'Partner';
            SurveyResponse1.Id = SurveyResponse.Id;
            update SurveyResponse1;
            
         test.stoptest();     
	}
	
	private static testMethod void SurveyResponseMethodTwo() {
    
         test.starttest(); 
            //Create Account
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
            
            Survey_Response__c SurveyResponse = new Survey_Response__c();
            SurveyResponse.Survey_Type__c = 'Transactional';
            SurveyResponse.Department__c = 'PS';
            SurveyResponse.Account__c = lstAcc[0].Id;
            insert SurveyResponse;
            
            Survey_Response__c SurveyResponse1 = new Survey_Response__c();
            SurveyResponse1.Survey_Type__c = 'Relationship';
            SurveyResponse1.Id = SurveyResponse.Id;
            update SurveyResponse1;
            
         test.stoptest();     
	}
	
	private static testMethod void SurveyResponseMethodThree() {
    
         test.starttest(); 
            //Create Account
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
            
            Survey_Response__c SurveyResponse = new Survey_Response__c();
            SurveyResponse.Survey_Type__c = 'Partner';
            SurveyResponse.Account__c = lstAcc[0].Id;
            insert SurveyResponse;
            
            Survey_Response__c SurveyResponse1 = new Survey_Response__c();
            SurveyResponse1.Survey_Type__c = 'Transactional';
            SurveyResponse1.Department__c = 'Customer Care';
            SurveyResponse1.Id = SurveyResponse.Id;
            update SurveyResponse1;
            
         test.stoptest();     
	}
	
	private static testMethod void SurveyResponseMethodFour() {
    
         test.starttest(); 
            //Create Account
            List<Account> lstAcc=TestUtil.createAccounts(1,true);
            
            Survey_Response__c SurveyResponse = new Survey_Response__c();
            SurveyResponse.Survey_Type__c = 'Relationship';
            SurveyResponse.Account__c = lstAcc[0].Id;
            insert SurveyResponse;
            
            Survey_Response__c SurveyResponse1 = new Survey_Response__c();
            SurveyResponse1.Survey_Type__c = 'Transactional';
            SurveyResponse1.Department__c = 'PS';
            SurveyResponse1.Id = SurveyResponse.Id;
            update SurveyResponse1;
            
         test.stoptest();     
	}

}