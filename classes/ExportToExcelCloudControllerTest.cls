@isTest
private class ExportToExcelCloudControllerTest {
    @isTest(seealldata=true)
    static void intialTest() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQuoteProds.size(), 2); 
             
        //Unit tests for ExportToExcelCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.ExportToExcelCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);  
        ExportToExcelCloudController objExportToExcelCloudController = new ExportToExcelCloudController(); 
    }
}