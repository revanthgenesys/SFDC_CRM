/************************************************************************************
Purpose : Unit test class for ProposalCloudPECController
Written By : Kartik Silla
Test Classes : N/A
*************************************************************************************/
@isTest
private class ProposalCloudPECControllerTest {
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
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPECQuoteProducts(list_NewQuotes[0].Id);
        
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4); 
        
        //Create subscription & products        
        List<Subscription_Product__c> list_NewSubscriptionProds = new List<Subscription_Product__c>();
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);  
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = 0;
        insert objNewSubscription;
        for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds) {                    
            Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);             
            objNewSubscriptionProd.Subscription__c = objNewSubscription.Id;
            list_NewSubscriptionProds.add(objNewSubscriptionProd);
        }  
        insert list_NewSubscriptionProds;
        
        Test.setCurrentPageReference(new PageReference('Page.OptyQuoteCategory')); 
        System.currentPageReference().getParameters().put('oppId', list_NewOpps[0].Id);  
        OptyQuoteHandler objOptyQuoteHandler = new OptyQuoteHandler();
        objOptyQuoteHandler.selectedSubscrToAmend = objNewSubscription.Id;
        objOptyQuoteHandler.map_Subscriptions = SubscriptionUtil.getSubscriptionInfo(list_NewAccts[0].Id, 'PureCloud');
        objOptyQuoteHandler.strSubscrSubType = Label.Amend_Subscription;
        PageReference newQuotePage = objOptyQuoteHandler.createAmendPureCloudQuote();
        String strAmendQuoteId = newQuotePage.getParameters().get('id');
        
        //Unit tests for ProposalCloudPCController method       
        Test.setCurrentPageReference(new PageReference('Page.ProposalCloudPEC')); 
        System.currentPageReference().getParameters().put('id', strAmendQuoteId);  
        ProposalCloudPECController objProposalCloudPECController = new ProposalCloudPECController(); 
    }
}