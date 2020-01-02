@isTest(seeAllData=true)
private class PartnerSearchControllerTest {
    static testMethod void myUnitTest1() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        ApexPages.currentPage().getParameters().put('id',testAccount.id);
        PartnerSearchController obj = new PartnerSearchController();
    }
    static testMethod void myUnitTest2() {
        PartnerSearchController obj = new PartnerSearchController();
        obj.partnerName = 'Test';
        obj.searchPartner();
    }
    
    static testMethod void myUnitTest3() {
        PartnerSearchController psc = new PartnerSearchController();
        psc.partnerName = 'Aria Solutions';
        psc.searchPartner();
        
        List<Partner_Directory__c> pdRecords = [SELECT id, Account__c FROM Partner_Directory__c LIMIT 3];
        PageReference pg = Page.PartnerSearch;
        Test.setCurrentPageReference(pg);
		System.currentPageReference().getParameters().put('id', pdRecords[0].Id);
        psc = new PartnerSearchController();
        
        pg = Page.PartnerSearch;
        Test.setCurrentPageReference(pg);
		System.currentPageReference().getParameters().put('id', pdRecords[1].Id);
        psc = new PartnerSearchController();

        pg = Page.PartnerSearch;
        Test.setCurrentPageReference(pg);
		System.currentPageReference().getParameters().put('id', pdRecords[2].Id);
        psc = new PartnerSearchController();
    }
    
}