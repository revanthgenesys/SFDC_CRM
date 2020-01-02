@isTest
private class ProposalOptionsExt1Test {
    @isTest(seealldata=true)
    static void intialTest() {
       
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Contact> list_NewConts = TestDataFactoryForQuoteTool.createContacts(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewConts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQuoteProds.size(), 2); 
        
        list_NewQuotes[0].BigMachines__Status__c = 'Quote Approved';
        list_NewQuotes[0].Contact__c = list_NewConts[0].Id;
        list_NewQuotes[0].Offering_Type__c = 'PureCloud';
        update list_NewQuotes[0];
        
        Account_Order_Address__c obj_NewAOA = new Account_Order_Address__c(Address__c='test', City__c='test', State__c='test',
                                                               Country__c='US', Zip_Code__c='66666', Address_Type__c='Bill To',
                                                               Quote__c=list_NewQuotes[0].Id);
        insert obj_NewAOA;
        //Unit tests for ProposalOptionsExt1 methods        
        ApexPages.StandardController sc = new ApexPages.StandardController(list_NewQuotes[0]);
        ProposalOptionsExt1 objProposalOptionsExt1 = new ProposalOptionsExt1(sc); 
        Test.setCurrentPageReference(new PageReference('Page.ProposalOptionsCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id); 
        objProposalOptionsExt1.viewContract();
        objProposalOptionsExt1.updateQuote();
        
        
        list_NewQuotes[0].Offering_Type__c = 'Cloud Partner (PPU)';
        list_NewQuotes[0].Quote_Business_Type__c = 'Cloud';
        update list_NewQuotes[0];               
        ApexPages.StandardController sc1 = new ApexPages.StandardController(list_NewQuotes[0]);
        ProposalOptionsExt1 objProposalOptionsExt12 = new ProposalOptionsExt1(sc1); 
    }
}