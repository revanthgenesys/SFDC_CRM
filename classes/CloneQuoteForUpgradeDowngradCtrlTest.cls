//Naresh Kumar
@IsTest(SeeAllData=true)
private class CloneQuoteForUpgradeDowngradCtrlTest {
	static testMethod void myUnitTest() {
		Account testAccount = TestUtil.createAccounts(1, true)[0];
    	Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
    	testOpp.Quote_Category__c = 'Cloud';
    	testOpp.Is_Downgrade__c = true;
        insert testOpp;       
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('cloneOpty', 'true');
		ApexPages.currentPage().getParameters().put('upgrade', 'upgrade');		
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, true)[0];
		CloneQuoteForUpgradeDowngradeController obj = new CloneQuoteForUpgradeDowngradeController();
		obj.selectedQuote = testQuote.id;
		obj.next();
        try{
		obj.cloneAndGoToOpty();
        }catch(Exception ex){}
		obj.selectedQuote = testQuote.id;
		obj.populateQuoteDetails();
	}
}