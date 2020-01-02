@isTest(seeAllData=true)
private class opportunityExtn_Test {

    static testMethod void testLowHangingFruit() {
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        opportunityExtn objController = new opportunityExtn(stdController);
		objController.opplines = new List<OpportunityLineItem>();
        objController.SelectedOppLineId = testOpp.Id;
        objController.uname = UserInfo.getName();

    }

    static testMethod void myUnitTest() {
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        opportunityExtn objController = new opportunityExtn(stdController);
        //objController.Change_PB();
        objController.getQuotecheck();
        objController.getOppline();
        objController.DeleteLineItem();
    }
    static testMethod void testChangePBNoChange() {
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        PriceBook2 pb = [select Id,Name from pricebook2 where Name = 'Sales PriceBook'];
		testOpp.Pricebook2Id = pb.Id;
        update testOpp;
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        opportunityExtn objController = new opportunityExtn(stdController);
       
        objController.Change_PB();
    }

    static testMethod void testChangePB() {
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        ApexPages.StandardController stdController = new ApexPages.StandardController(testOpp);
        opportunityExtn objController = new opportunityExtn(stdController);

        PriceBook2 pbStandard = [select Id,Name from pricebook2 where Name = 'Standard Price Book'];
		testOpp.Pricebook2Id = pbStandard.Id;

        List<PricebookEntry> listPriceBookEntries = [SELECT Id, product2id, IsActive, CurrencyIsoCode, UnitPrice, ProductCode, UseStandardPrice
                                                     FROM PricebookEntry
                                                     WHERE CurrencyIsoCode = :testOpp.CurrencyIsoCode
                                                     AND Pricebook2.Name = 'Standard Price Book'
                                                     AND IsActive = true
                                                     ORDER BY CreatedDate desc LIMIT 3];
        System.Debug('opportunityExtn_Test.testChangePB: listPriceBookEntries ' + listPriceBookEntries);
/*
        Set<Id> setPriceBookEntries = new Set<Id>();
        Map<Id, PriceBookEntry> mapPriceBookIdToPriceBookEntry = new Map<Id, PriceBookEntry>();

        for (PricebookEntry objPBE : listPriceBookEntries) {
            setPriceBookEntries.add(objPBE.Id);
			mapPriceBookIdToPriceBookEntry.put
        }
        List<PriceBookEntry> listPBE = [Select id,product2id,Pricebook2.Name
                                        FROM pricebookentry where pricebook2id in :setPriceBookEntries];
		System.Debug('opportunityExtn_Test.testChangePB: listPBE ' + listPBE);
		List<PriceBookEntry> listPBEToInsert = new List<PriceBookEntry>();
        for (PriceBookEntry objPBE : listPriceBookEntries) {
            if (!mapPriceBookIdToPriceBookEntry.containsKey(objPBE)
        }
*/        
        List<OpportunityLineItem> listOppLines = TestUtil.createOlis(listPriceBookEntries, testOpp.Id, true);

        PriceBook2 pbSales = [select Id,Name from pricebook2 where Name = 'Sales PriceBook'];
		//List<PricebookEntry> listPriceBookEntriesToInsert = new List<PricebookEntry>();
        for (PricebookEntry objPBE : listPriceBookEntries) {
            objPBE.Id = null;
            objPBE.pricebook2id = pbSales.Id;
            objPBE.UnitPrice = 0.0;
        }
        System.Debug('opportunityExtn_Test.testChangePB: Changed listPriceBookEntries for insert ' + listPriceBookEntries);
		insert listPriceBookEntries;

        System.Debug('opportunityExtn_Test.testChangePB: listOppLines ' + listOppLines);

        Util.Bypass_Trigger_Chk = true;
        objController.Change_PB();
    }

}