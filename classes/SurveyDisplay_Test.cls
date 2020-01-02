@isTest(SeeAllData=true)
public class SurveyDisplay_Test {

static testMethod void Submit_BillTo() {
      
      Test.StartTest();
      Account testAccount = TestUtil.createAccounts(1, true)[0];
      Survey_Response__c sresp = new Survey_Response__c();
      sresp.Account__c = testAccount.id;
      insert sresp;

      PageReference pageRef = page.survey;
      Test.setCurrentPage(pageRef);
            
      ApexPages.StandardController sc = new ApexPages.standardController(testAccount);                
      SurveyDisplay controller = new SurveyDisplay(sc); 
      
      controller.getSurvey();
      Test.StopTest();
}
}