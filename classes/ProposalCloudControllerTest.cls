@isTest(seealldata=true)
private class ProposalCloudControllerTest {
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
        list_NewQuotes[0].Group_Product_By__c = 'Standard View';
        update list_NewQuotes[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
         //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQuoteProds.size(), 2);  
        
        //Unit tests for CreateQuoteCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.ProposalCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);  
        ProposalCloudController objProposalCloudCntrl = new ProposalCloudController(); 
        
        list_NewQuotes[0].Group_Product_By__c = 'Proposal View';
        update list_NewQuotes[0];
        
        Test.setCurrentPageReference(new PageReference('Page.ProposalCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);  
        ProposalCloudController objProposalCloudCntr2 = new ProposalCloudController();
        
    }

    @isTest
    static void test2() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewQuotes[0].Group_Product_By__c = 'Standard View';
        update list_NewQuotes[0];
        Subscription__C objsub = new Subscription__c(Account__c=list_NewAccts[0].id,Subscription_Start_Date__c = Date.today(),ACV__c = 0.00,CMRR__c=0.00,TAM_Services_Amount__c =0.00,TCV__c=0.00,Total_Education__c=0.00,Total_Hardware__c=0.00,Total_Non_Recurring_Fees__c = 0.00,Total_Services__c=0.00);
        insert objsub;
        list_NewQuotes[0].Amendment_For__c = objsub.id;
        list_NewQuotes[0].Order_Type__c = Label.Amend_Subscription;
        list_NewQuotes[0].Subscription_Start_Date__c =Date.today();
        list_NewQuotes[0].Subscription_End_Date__c = Date.today()+365;
        update list_NewQuotes[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
         //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQuoteProds.size(), 2);  
        
        //Unit tests for CreateQuoteCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.ProposalCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);  
        ProposalCloudController objProposalCloudCntrl = new ProposalCloudController(); 
        
        list_NewQuotes[0].Group_Product_By__c = 'Proposal View';
        update list_NewQuotes[0];
        
        Test.setCurrentPageReference(new PageReference('Page.ProposalCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);  
        ProposalCloudController objProposalCloudCntr2 = new ProposalCloudController();
        
    }

    @isTest
    static void testProposalGroup(){

        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewQuotes[0].Group_Product_By__c = 'Standard View';
        update list_NewQuotes[0];
        Subscription__C objsub = new Subscription__c(Account__c=list_NewAccts[0].id,Subscription_Start_Date__c = Date.today(),ACV__c = 0.00,CMRR__c=0.00,TAM_Services_Amount__c =0.00,TCV__c=0.00,Total_Education__c=0.00,Total_Hardware__c=0.00,Total_Non_Recurring_Fees__c = 0.00,Total_Services__c=0.00);
        insert objsub;
        list_NewQuotes[0].Amendment_For__c = objsub.id;
        list_NewQuotes[0].Order_Type__c = Label.Amend_Subscription;
        list_NewQuotes[0].Subscription_Start_Date__c =Date.today();
        list_NewQuotes[0].Subscription_End_Date__c = Date.today()+365;
        update list_NewQuotes[0];
        
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
         //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQuoteProds.size(), 2);  

        Quote_Proposal_Group__c objQP = new Quote_Proposal_Group__c();

        objQP.Group_Number__c = '12222';
        objQP.Name__c = 'Test';
        objQP.Description__c = 'Test';
        objQP.Quote__c =list_NewQuotes[0].Id;

        insert objQP;

        //Unit tests for CreateQuoteCloudController methods        
        Test.setCurrentPageReference(new PageReference('Page.ProposalCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);  
        ProposalCloudController objProposalCloudCntrl = new ProposalCloudController(); 
        
        list_NewQuotes[0].Group_Product_By__c = 'Proposal View';
        update list_NewQuotes[0];
        
        Test.setCurrentPageReference(new PageReference('Page.ProposalCloud')); 
        System.currentPageReference().getParameters().put('id', list_NewQuotes[0].Id);  
        ProposalCloudController objProposalCloudCntr2 = new ProposalCloudController();
    }


}