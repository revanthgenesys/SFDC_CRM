/*
	Naresh Kumar	06/16/2013
	Test class for the main extension class EmailPublisherExtensions.
*/
@isTest(seeAllData = true)
private class EmailPublisherExtensions_Test {

    static testMethod void myUnitTest() {
        Case testCase = TestUtil.createCases(1, true)[0];
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        EmailPublisherExtensions objExtension = new EmailPublisherExtensions(stdController);
        objExtension.updateIsPublicField();
        objExtension.sendEmail();
        objExtension.to = 'test@test.com';
        objExtension.attFile = 'test';
        objExtension.fileNames = 'test1, test2';
        objExtension.sendEmail();
        
        objExtension.cngEmail();        
    }
}