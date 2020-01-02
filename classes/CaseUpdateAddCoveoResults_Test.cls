@isTest
public class CaseUpdateAddCoveoResults_Test {
	
	static testMethod void addResQuestionTest() {
		
		TestUtil.setConfigValues();
		List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
        System.runAs(runAsUser[0]) {   		
       		TestUtil.setCaseSupportTypesSettings();
        }   
	    
	    Util.Bypass_Trigger_Chk = true;
	                     
	    List<Case> cases = TestUtil.createCases(1, true);  
	
	    CoveoV2__CoveoCaseAttachedResult__c res1 = new CoveoV2__CoveoCaseAttachedResult__c(
	                                                                 CoveoV2__case__c = cases[0].Id,
	                                                                 	CoveoV2__ResultUrl__c = 'http://gen.com/123456?',
	                                                                 	CoveoV2__Source__c = 'Salesforce - Questions',
	                                                                 	CoveoV2__Title__c = 'Title',
	                                                                 	CoveoV2__UriHash__c = '3tyiio' ); 
	   insert res1;
	   
	   CoveoV2__CoveoCaseAttachedResult__c res2 = new CoveoV2__CoveoCaseAttachedResult__c(
	                                                                 CoveoV2__case__c = cases[0].Id,
	                                                                 	CoveoV2__ResultUrl__c = 'http://gen.com/123456?',
	                                                                 	CoveoV2__Source__c = 'Web - docs.genesys.com',
	                                                                 	CoveoV2__Title__c = 'Title',
	                                                                 	CoveoV2__UriHash__c = '1gvjkuh' ); 
	   
	   insert res2;
	                                                                 	                                                                   
	   System.runAs(runAsUser[0]) {                                      	        
	        Test.startTest();
	        CaseUpdateAddCoveoResults cov = new CaseUpdateAddCoveoResults();
	        cov.caseId = cases[0].Id;
	        Test.stopTest();
	   }    
	}
	

}