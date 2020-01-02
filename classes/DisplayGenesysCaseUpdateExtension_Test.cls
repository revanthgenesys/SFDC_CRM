/*
	Naresh Kumar	06/14/2013
	Test class for the main extension class DisplayGenesysCaseUpdateExtension.
*/
@isTest(seeAllData = true)
private class DisplayGenesysCaseUpdateExtension_Test {
    static testMethod void myUnitTest() {
        Case testCase = TestUtil.createCases(1, true)[0];
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        displayGenesysCaseUpdateExtension objExtension = new displayGenesysCaseUpdateExtension(stdController);
    }
}