//ANKAIAH BANDI  11/22/2018  Test class for AccountStatusHelper class.
@istest
private class AccountStatusHelperTest {
    
    static testMethod void testMethod1() {    
        Test.startTest();
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAcc.id, true)[0];
        AccountStatusHelper.populateAccountOppDetails(testAcc,testOpp.id);
        Test.stopTest();
    }
}