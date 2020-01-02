@isTest(seeAllData = true)
private class BatchCreateCaseFeed_Test {

    static testMethod void myUnitTest() {
		Account[] testAccounts = TestUtil.createAccounts(1, true);
    	List<Case> testCases = TestUtil.createCases(1, false);
    	testCases[0].Status = 'Open';
    	testCases[0].AccountId = testAccounts[0].Id;
    	insert testCases;
		Genesys_Case_Updates__c newCaseUpdate = new Genesys_Case_Updates__c();
		newCaseUpdate.Case__c = testCases[0].Id;
		newCaseUpdate.Make_Public__c = true;
		//newCaseUpdate.Description__c = 'Test';
		newCaseUpdate.Type__c = 'Research';
		insert newCaseUpdate;
		Test.startTest();
		BatchCreateCaseFeed bccf = new BatchCreateCaseFeed();
		bccf.Query =
			'select Created_By_Name__c, Type__c, Name, Case__c, ' +
			'Make_Public__c, Description__c ' +
			'from Genesys_Case_Updates__c ' +
			'where Id = \'' + newCaseUpdate.Id + '\'';
		Id batchprocessid = Database.executeBatch(bccf);
		Test.stopTest();
    }
}