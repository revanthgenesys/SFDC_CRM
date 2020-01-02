@isTest(seeAllData=true)
public class ServiceContract_TrackForLMS_After_Test {
	 
	@isTest
    static void testServiceContract_TrackForLMS_After(){
		Test.startTest();
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        ServiceContract testSC = TestUtil.createServiceContracts(1, false)[0];
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];
        testSC.Renewal_Opportunity__c = testOpp.id;
        testSC.Quote_Name__c = testQuote.id;
        insert testSC;
        update testSC;
        delete testSC;
		Test.stopTest();
    }
}