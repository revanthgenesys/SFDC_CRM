//Naresh Kumar	11/22/2018	Test class for main class OrderTriggerHelperFuture.
@isTest(SeeAllData=true)
private class OrderTriggerHelperFutureTest {
	
    static testMethod void testMethod1() {    
        Test.startTest();
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAcc.id, true)[0];
        OrderTriggerHelperFuture.updateOpportunityBookingStatus(testOpp.id, 'SO-TEST-ORDER');
        OrderTriggerHelperFuture.updateAccountSupportOption(testOpp.AccountId, 'Standard Support');
        Test.stopTest();
    }
}