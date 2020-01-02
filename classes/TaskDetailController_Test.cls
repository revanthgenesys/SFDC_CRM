/*
	Naresh Kumar	06/15/2013
	Test class for the main controller class TaskDetailController.
*/
@isTest(seeAllData = true)
private class TaskDetailController_Test {
    static testMethod void myUnitTest() {
    	Test.StartTest();
        Case testCase = TestUtil.createCases(1, true)[0];
        Task testTask = TestUtil.createTasks(1, true, testCase)[0];
        EmailMessage testEM = TestUtil.createEmailMessage(1, true, testTask)[0];
        //Attachment testAtt = TestUtil.createAttachment(1, true, testEM.id)[0];
        ApexPages.StandardController stdController = new ApexPages.StandardController(testTask);
        TaskDetailController objExtension = new TaskDetailController(stdController);
        Test.StopTest();
        Case testCase1 = TestUtil.createCases(1, true)[0];
        objExtension.currentTask.WhatId = testCase1.id;
        //objExtension.updateTask();
    }
}