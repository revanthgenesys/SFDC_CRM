@isTest(SeeAllData=true)
private class TestRQIAverageCtrl {

    static testMethod void testRQIAverage() {	
		
		List<case> needOneCase = [select id from case limit 1];
		
		RQI_Audit__c assessment = new RQI_Audit__c(Case__c = needOneCase[0].Id, Answer_New_1__c  = 'No' , Answer_new_2__c  = 'Yes', Status__c='Complete' ,Author__c = TestAQIRQIUtils.createTestAgent(UserInfo.getUserID()).Id);
     	insert assessment;
    	
		RQIAverageCtrl AAC = new RQIAverageCtrl(new ApexPages.standardController(assessment));
		System.assert(AAC.theAverage != null);
		
    }
}