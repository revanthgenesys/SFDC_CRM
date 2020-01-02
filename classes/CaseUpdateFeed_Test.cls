/*
	Naresh Kumar	06/14/2013
	Test class for the main extension class CaseUpdateFeed.
*/
@isTest(seeAllData = true)
public with sharing class CaseUpdateFeed_Test {
	static testMethod void myUnitTest() {
 		Case testCase = TestUtil.createCases(1, true)[0];
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        CaseUpdateFeed objExtension = new CaseUpdateFeed(stdController);
        objExtension.genCaseUp.Make_Public__c = true;
        objExtension.saveCaseUpdate();
	}
}