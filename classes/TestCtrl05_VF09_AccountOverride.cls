@isTest
private class TestCtrl05_VF09_AccountOverride {

	static testMethod void TestAccount() {
		Account acc = [select id,recordTypeId from Account limit 1];
		Apexpages.Standardcontroller con = new Apexpages.Standardcontroller(acc);
		Ctrl05_VF09_AccountOverride ctrl = new Ctrl05_VF09_AccountOverride(con);
		ctrl.init();
		
	}
}