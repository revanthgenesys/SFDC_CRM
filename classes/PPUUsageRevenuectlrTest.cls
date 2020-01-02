/*
  11/09/2017  R Systems
  Test class for PPUUsageRevenuectlr .
*/
@isTest (seeAllData = true)
private class PPUUsageRevenuectlrTest{
    static testMethod void myTestMethod() {
      Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
      PPUUsageRevenuectlr.processPPU(testOpp.Id);
    }
}