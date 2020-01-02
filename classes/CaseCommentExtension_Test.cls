@isTest
private class CaseCommentExtension_Test {
	
    static testMethod void myUnitTest() {
    	TestUtil.setConfigValues();
    	 List<User> runAsUser = TestUtil.createUsers(1, true);
        runAsUser[0].Bypass_Triggers__c = true;
        runAsUser[0].BypassWorkflows__c = true;
        runAsUser[0].BypassValidationRules__c = true;
        update runAsUser[0];
       
        System.runAs(runAsUser[0]) {
            TestUtil.setCaseSupportTypesSettings();
        }
    	Util.Bypass_Trigger_Chk = true;
    	Case testCase = TestUtil.createCases(1, true)[0];
    	
    	Test.startTest();
        ApexPages.currentPage().getParameters().put('caseId', testCase.id);        
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        CaseCommentExtension objExtension = new CaseCommentExtension(stdController);
        objExtension.newCaseUpdate.Make_Public__c = true;
        objExtension.fr_case = true;
        objExtension.getTypes();
        objExtension.getSubstatusClose();
        objExtension.save();
        objExtension.saveClose();
        objExtension.reopenCase();
        objExtension.saveOpen();
        objExtension.cancel();
        
        objExtension.isPortal = true;
        objExtension.returnDetPage();
        
        Test.stopTest();
    }
}