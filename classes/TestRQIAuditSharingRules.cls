@IsTest(SeeAllData=true)
private class TestRQIAuditSharingRules {

    static testMethod void testRQISharing() {
        
		List<case> needOneCase = [select id from case limit 1];
		
		RQI_Audit__c assessment = new RQI_Audit__c(Case__c = needOneCase[0].Id, Answer_New_1__c  = 'No' , Answer_new_2__c  = 'Yes', Author__c = TestAQIRQIUtils.createTestAgent(UserInfo.getUserID()).Id);
     	insert assessment;
     	
		System.runAs(TestAQIRQIUtils.createTestAgent(UserInfo.getUserID()))  {
			List <RQI_Audit__c> assessments = [Select Id from RQI_Audit__c where Id=:assessment.Id];
			System.assert(assessments.size() > 0);
		}   
				
    }
}