/************************************************************************************
Purpose : Unit test class for ShowBundleproductsController
Written By : Ranjith Punneli
Test Classes : N/A
*************************************************************************************/
@isTest(seealldata=true)
public class ShowBundleproductsTest {
    @isTest
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
        List<BigMachines__Quote_Product__c>list_ObjQP = TestDataFactoryForQuoteTool.createQuoteProducts4(list_NewQuotes[0].Id);
        List<Product_Group__c> list_PG = [select Id from  Product_Group__c limit 1];
        Test.setCurrentPageReference(new PageReference('Page.ShowBundleProducts')); 
        System.currentPageReference().getParameters().put('id', list_ObjQP[0].Id);  
        ShowBundleproductsController objShowBundleproductsController = new  ShowBundleproductsController(); 
        System.currentPageReference().getParameters().put('pgid', list_PG[0].Id);  
        ShowBundleproductsController objShowBundleproductsController2 = new  ShowBundleproductsController(); 
    }

}