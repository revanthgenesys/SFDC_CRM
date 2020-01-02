@isTest(seeAllData = true)
private class AssignmentManagerExtensionControllerTest {

    static testMethod void myUnitTest() {
		Account[] testAccounts = TestUtil.createAccounts(1, true);
		List<Support_Product__c> supportProducts = TestUtil.createSupportProducts(1, true);
    	List<Case> testCases = TestUtil.createCases(1, false);
    	testCases[0].Status = 'Open';
    	testCases[0].AccountId = testAccounts[0].Id;
    	//testCases[0].Support_Product__c = supportProducts[0].Id;
    	insert testCases;
    	PageReference pageRef = Page.AssignmentManager;
		Test.setCurrentPage(pageRef);
		ApexPages.currentPage().getParameters().put('id', testCases[0].Id);
		AssignmentManagerExtensionController contr = new AssignmentManagerExtensionController();
		ApexPages.StandardSetController con = contr.con;
		List<AssignmentManagerExtensionController.userWrapper> lstUsers = contr.getUsers();
		contr.calculateScore();
		//contr.hasNext();
		//contr.hasPrevious();
		contr.first();
		contr.last();
		contr.next();
		contr.previous();
		contr.cancel();
		contr.newOwnerId = UserInfo.getUserId();
		contr.assignCaseOwner();
		contr.closePage();
    }

}