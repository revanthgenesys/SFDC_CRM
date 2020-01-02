/*
	Naresh Kumar	06/18/2013
	Test class for the main controller class RelatedCaseInsertUpdateHandler.
*/
@isTest(seeAllData = true)
private class RelatedCaseInsertUpdateHandler_Test {

    static testMethod void myUnitTest() {
    	RecordType recordType = [SELECT id FROM RecordType WHERE DeveloperName = 'Genesys_Escalation_Case' LIMIT 1];
        List<Case> testCases = TestUtil.createCases(2, false);
        testCases[0].recordTypeId = recordType.id;
        insert testCases;
        Related_Case__c testRC = new Related_Case__c();
        testRC.Case__c = testCases[0].id;
        testRC.Parent_Case__c = testCases[1].id;
        testRC.Escalation__c = testCases[0].id;
        insert testRC;
        RelatedCaseInsertUpdateHandler.updateEscaltionFlag(testCases[0], 'Reopen');
    }
}