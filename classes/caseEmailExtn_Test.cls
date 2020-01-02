/*
    Naresh Kumar    06/14/2013
    Test class for the main extension class caseEmailExtn.
*/
@isTest(seeAllData = true)
private class caseEmailExtn_Test {
    static testMethod void myUnitTest() {
        Case testCase = TestUtil.createCases(1, true)[0];
        Task testTask = TestUtil.createTasks(1, true, testCase)[0];
        List<Task> lstTasks = new List<Task>();
        Task tsk = new Task(WhatId = testCase.id,Subject = 'test Case # '+testCase.CaseNumber);
        lstTasks.add(tsk); 
        Task tsk1 = new Task(WhatId = testCase.id,Subject = 'test Case SR#'+testCase.CaseNumber+'-'+' 2');
        lstTasks.add(tsk1);
        Task tsk2 = new Task(WhatId = testCase.id,Subject = 'test Case SR#'+testCase.CaseNumber+'-'+'21212121');
        lstTasks.add(tsk2);
        insert lstTasks;
        EmailMessage testEM = TestUtil.createEmailMessage(1, true, testTask)[0];
        ApexPages.StandardController stdController = new ApexPages.StandardController(testCase);
        caseEmailExtn objExtension = new caseEmailExtn(stdController);
        PageReference tstPage = Page.CaseEmailTasks;
        tstPage.getParameters().put('id',testCase.id);
        Test.setCurrentPage(tstPage);
        caseEmailExtn c = new caseEmailExtn();
    }
}