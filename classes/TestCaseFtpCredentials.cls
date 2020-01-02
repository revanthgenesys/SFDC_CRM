@isTest(seeAllData = true)
private class TestCaseFtpCredentials {
	
	static testMethod void myUnitTest() {
		Case testCase = TestUtil.createCases(1, true)[0];       
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        CaseFtpCredentials crd = new CaseFtpCredentials(stdController);
        String pswd = crd.pswd;
        String user = crd.user;
	}

}