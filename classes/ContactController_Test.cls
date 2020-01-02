/*
	Naresh Kumar	06/14/2013
	Test class for the main extension class CaseCommentExtension.
*/
@isTest(seeAllData = true)
private class ContactController_Test {

    static testMethod void myUnitTest() {
        ContactController extController = new ContactController();
        extController.UpdateContactInfo();
        extController.getTxtMsg();
        extController.getIsEdit();
    }
}