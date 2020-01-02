@isTest(seeAllData=true)
private class partnerMetricsPageAccounts_Test{
    static testMethod void myUnitTest() {
        Test.startTest();
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        System.currentPageReference().getParameters().put('id', testAccount.id);
        
        Test.stopTest();
        partnerMetricsPageAccountsController obj = new partnerMetricsPageAccountsController();
        obj.nextPage();
    }
}