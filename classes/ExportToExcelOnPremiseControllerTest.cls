/************************************************************************************
Purpose : Unit test class for ExportToExcelOnPremiseController
Written By : Ashish Goyal (26/01/2019)
Test Classes : N/A
*************************************************************************************/
@isTest
private class ExportToExcelOnPremiseControllerTest {
    @isTest(seealldata=true)
    static void intialTest() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
       
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4); 
        
        //Unit tests for ExportToExcelCloudPCController method       
        Test.setCurrentPageReference(new PageReference('Page.ExportToPDFOnPremise')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);  
        ExportToExcelOnPremiseController objProposalCloudPCController = new ExportToExcelOnPremiseController();
        objProposalCloudPCController.quote = list_NewQuotes[0];
        objProposalCloudPCController.quote.Grid_Group_By__c = 'Bundles/Products';
        objProposalCloudPCController.prepareQuoteProductQuery(list_NewQuotes[0].Id);
        objProposalCloudPCController.quote.Grid_Group_By__c = 'Proposal Groups';
        objProposalCloudPCController.prepareQuoteProductQuery(list_NewQuotes[0].Id);        
        objProposalCloudPCController.quote.Grid_Group_By__c = null;
        objProposalCloudPCController.prepareQuoteProductQuery(list_NewQuotes[0].Id);
    }
}