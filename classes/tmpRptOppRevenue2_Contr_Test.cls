@isTest(seeAllData = true)
private class tmpRptOppRevenue2_Contr_Test {
    static testMethod void generalTest() {
        Account[] testAccounts = TestUtil.createAccounts(1, true);
        Contact[] testContacts = TestUtil.createContacts(1, testAccounts[0], true);
        Opportunity[] testOpps = TestUtil.createOpportunities(1, false);
        testOpps[0].AccountId =  testAccounts[0].Id;
        testOpps[0].Opportunity_Status__c = 'Renewed';
        Map<String, RecordType> OPP_RECORDTYPEMAP = Opportunity_H.RECORDTYPEMAP;
        testOpps[0].RecordTypeId = OPP_RECORDTYPEMAP.get('Genesys Renewal').Id;
        testOpps[0].Quote_Maintenance_Start_Date__c = Date.today();
        testOpps[0].Quote_Maintenance_End_Date__c = Date.today().addMonths(12);
        insert testOpps;
        BigMachines__Quote__c[] testBMQuotes = TestUtil.createQuotes(1, testOpps[0].Id, true);

		PageReference pageRef = Page.tmpRptOppRevenue2;
		Test.setCurrentPage(pageRef);
		tmpRptOppRevenue2_Contr contr = new tmpRptOppRevenue2_Contr();
		contr.canAccess();
		contr.getRecordTypes();
		contr.getOppStatuses();		
		contr.setStartDate(Date.today().addDays(-1));
		contr.setEndDate(Date.today().addMonths(1));
		contr.setOpportunityRecordIds(new String[]{testOpps[0].RecordTypeId});
		contr.setOpportunityStatuses(new String[]{'Renewed'});
		contr.runReport();
		contr.getQueryData();
		contr.getQueryDataAsSingleList();
		contr.getQueryDataAsCSV();
    }
}