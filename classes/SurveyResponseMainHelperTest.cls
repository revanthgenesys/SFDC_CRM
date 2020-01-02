//Naresh Kumar    07/12/2016
@isTest(seeAllData=true)
private class SurveyResponseMainHelperTest{    
    static testMethod void testMethod1() {
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        testAccount.Cloud__c = true;
        insert testAccount;
        
        JBCXM__SurveyMaster__c testSurveyMaster = new JBCXM__SurveyMaster__c();
        testSurveyMaster.Name = '2016H1R';
        testSurveyMaster.JBCXM__SURVEYNAME__C = '2016 H1 Relationship';
        testSurveyMaster.JBCXM__SURVEYTYPE__C = 'Relationship';
        testSurveyMaster.JBCXM__PublishDate__c = System.today();
        insert testSurveyMaster;
        
        Survey_Response__c testResponse = new Survey_Response__c();
        testResponse.Account__c = testAccount.id;
        testResponse.NPS_Rating__c = '10';
        testResponse.Follow_Up_Comments__c = 'Test Comments';
        testResponse.Survey_Type__c = 'Relationship';
        insert testResponse;        
    }
    static testMethod void testMethod2() {
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        testAccount.Cloud__c = true;
        insert testAccount;
        
        JBCXM__SurveyMaster__c testSurveyMaster = new JBCXM__SurveyMaster__c();
        testSurveyMaster.Name = '2016H1R';
        testSurveyMaster.JBCXM__SURVEYNAME__C = '2016 H1 Support';
        testSurveyMaster.JBCXM__SURVEYTYPE__C = 'Support_Transactions';
        testSurveyMaster.JBCXM__PublishDate__c = System.today();
        insert testSurveyMaster;
        
        
        Survey_Response__c testResponse = new Survey_Response__c();
        testResponse.Account__c = testAccount.id;
        testResponse.NPS_Rating__c = '6';
        testResponse.Follow_Up_Comments__c = 'Test Comments';
        testResponse.Survey_Type__c = 'Transactional';
        insert testResponse;        
    }
    
}