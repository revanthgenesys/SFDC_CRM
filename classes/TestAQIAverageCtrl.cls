@IsTest(SeeAllData=true)

private class TestAQIAverageCtrl {

    static testMethod void testAQIAverage() {	
    	
    	AQI_Audit__c assessment = new AQI_Audit__c(Status__c='Complete' ,Author__c = TestAQIRQIUtils.createTestAgent(UserInfo.getUserID()).Id);
     	insert assessment;
    	
		AQIAverageCtrl AAC = new AQIAverageCtrl(new ApexPages.standardController(assessment));
		System.assert(AAC.theAverage != null);
    }
}