@IsTest(SeeAllData=true)
private class TestAQIAuditSharingRules {

    static testMethod void testAQISharing() {
		AQI_Audit__c assessment = new AQI_Audit__c(Author__c = TestAQIRQIUtils.createTestAgent(UserInfo.getUserID()).Id);
     	insert assessment;
     	
		System.runAs(TestAQIRQIUtils.createTestAgent(UserInfo.getUserID()))  {
			List <AQI_Audit__c> assessments = [Select Id from AQI_Audit__c where Id=:assessment.Id];
			System.assert(assessments.size() > 0);
		}   
		
		
    }
    
    
   
    
    
}