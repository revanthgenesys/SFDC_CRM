/*
	04/25/2013	Naresh Kumar	Created
	06/14/2013	Naresh Kumar	Modified
	Test Class for the controller class CaseRelationshipController
 */
@isTest (seeAllData = true)
private class CaseRelationshipController_Test {

    static testMethod void testController() {
    	List<Case> testCases = TestUtil.createCases(2, true);
    	Related_Case__c caseRelation = TestUtil.createFRRelation(testCases[0], testCases[1], true); 
    	ApexPages.StandardController stdController = new ApexPages.StandardController(testCases[0]);
        CaseRelationshipController crc1 = new CaseRelationshipController(stdController); 
        crc1.add();
        crc1.back();
        crc1.deleteRelationship();
    }
}