//Naresh Kumar    02/17/2017
@isTest(seeAllData=true)
private class DealQualificationCloudControllerTest{ 
    static testMethod void testDealQualificationCloudController1() { 
        Test.starttest();
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        insert testAccount;
        
        map<string, DQ_Special_Offers__c> dqSpecOffersCS = DQ_Special_Offers__c.getAll();
        System.debug('dqSpecOffersCS--->'+dqSpecOffersCS);
        
        country__c ccc = [select id from country__C where name='United States' limit 1];
        
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Enablement_Model__c = 'Direct Enablement';
        testOpp.Country__c = ccc.Id;
        insert testOpp;
        
        Deal_Qualification__c testDQ = new Deal_Qualification__c();
        testDQ.Opportunity__c = testOpp.id;
        testDQ.Offering_Type__c = 'Business Edition';
        testDQ.Pricing_Type__c = 'New Pricing';
        testDQ.Type__c = DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL;
        testDQ.Platform_Type__c = 'Cloud';
        testDQ.Is_Telco_Included__c = 'No';
        testDQ.Status__c = DealQualificationApprovalUtil.QUOTE_STATUS_PENDING;
        insert testDQ;
        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('id', testDQ.id);
        
        ApexPages.StandardController stdCtr = new ApexPages.StandardController(testOpp);
        DealQualificationCloudController objController = new DealQualificationCloudController(stdCtr);
        objController.telcoIncludedToggleHandler();        
        objController.revise();
        objController.reviseOnLoad();
        objController.save();
        //objController.objDQ.Req_Revenue_Approval__c = true;
        objController.saveFinanceApproval();
        system.debug('dqSpecOffrWrppr--->'+objController.dqSpecOffrWrppr);
        objController.requestSpecOfferSubApproval();
        objController.unlockFinFn = 'revenue';
        objController.unlockSubApprSection();
        objController.unlockFinFn = 'orderMgmt';
        objController.unlockSubApprSection();
        objController.unlockFinFn = 'creditCol';
        objController.unlockSubApprSection();
        objController.unlockFinFn = 'legal';
        objController.unlockSubApprSection();
        //objController.submitForApproval();   
        Test.stoptest();     
    }
    
    static testMethod void testDealQualificationCloudController2() { 
        Test.starttest();
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        insert testAccount;
        
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Enablement_Model__c = 'Direct Enablement';
        insert testOpp;
        
        Deal_Qualification__c testDQ = new Deal_Qualification__c();
        testDQ.Opportunity__c = testOpp.id;
        testDQ.Offering_Type__c = 'Business Edition';
        testDQ.Pricing_Type__c = 'New Pricing';
        testDQ.Type__c = DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL;
        testDQ.Platform_Type__c = 'Cloud';
        testDQ.Status__c = 'In Progress';
        insert testDQ;
        
        BigMachines__Quote__c quote = TestUtil.createQuotes(1, testOpp.id, true)[0];
        
        //ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('id', testDQ.id);
        
        ApexPages.StandardController stdCtr = new ApexPages.StandardController(testOpp);
        DealQualificationCloudController objController = new DealQualificationCloudController(stdCtr);
        objController.objDQ.Type__c = DealQualificationApprovalUtil.DQ_RECORD_HISTORY;
        objController.reviseOnLoad();
        Test.stoptest();
    }
    
    static testMethod void testDealQualificationCloudController3() { 
        Test.starttest();
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        insert testAccount;
        
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Enablement_Model__c = 'Direct Enablement';
        insert testOpp;        
        
        Deal_Qualification__c testDQ = new Deal_Qualification__c();
        testDQ.Opportunity__c = testOpp.id;
        testDQ.Offering_Type__c = 'Business Edition';
        testDQ.Pricing_Type__c = 'New Pricing';
        testDQ.Type__c = DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL;
        testDQ.Platform_Type__c = 'Cloud';
        testDQ.Status__c = 'In Progress';
        testDQ.Type__c = DealQualificationApprovalUtil.DQ_RECORD_HISTORY;
        testDQ.Competitor__c = 'Test Competitor';
        insert testDQ;
        
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, testOpp.id, false)[0];
        testQuote.Quote_Business_Type__c = 'Cloud';
        testQuote.Offering_Type__c = 'Business Edition';
        insert testQuote;
        
        ApexPages.currentPage().getParameters().put('id', testDQ.id);
        ApexPages.currentPage().getParameters().put('REVISE', 'true');
        ApexPages.StandardController stdCtr = new ApexPages.StandardController(testOpp);
        DealQualificationCloudController objController = new DealQualificationCloudController(stdCtr);
        objController.objDQ.id = testDQ.id;
        objController.reviseOnLoad(); 
        Test.stoptest();    
    }
    
    static testMethod void testDealQualificationCloudController4() { 
    
        Test.starttest();
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        Opportunity testOpp = TestUtil.createOpportunities(1, list_NewAccts[0].id, false)[0];
        testOpp.Enablement_Model__c = 'Direct Enablement';
        insert testOpp; 
        List<zqu__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createZuoraQuotes(testOpp.Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewQuotes[0].zqu__Previewed_MRR__c = 1000;
        update list_NewQuotes[0];
        
        ApexPages.StandardController stdCtr = new ApexPages.StandardController(testOpp);
        ApexPages.currentPage().getParameters().put('oppId',testOpp.id);
        DealQualificationCloudController objController = new DealQualificationCloudController(stdCtr);
        objController.zQuote = list_NewQuotes[0];
        objController.onQuoteChange();
        objController.getZQuotes();
        objController.submitForApproval();
        
        Test.stoptest();
    }
    
    static testMethod void testDealQualificationCloudController5() { 
        Test.starttest();
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        insert testAccount;
        
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Enablement_Model__c = 'Direct Enablement';
        insert testOpp;
        
        Deal_Qualification__c testDQ = new Deal_Qualification__c();
        testDQ.Opportunity__c = testOpp.id;
        testDQ.Offering_Type__c = 'PureConnect Cloud';
        testDQ.Pricing_Type__c = 'New Pricing';
        testDQ.Business_Users_Add_On__c = 10;
        testDQ.Justification_for_Discount__c = null;
        testDQ.Initial_Subscription_Term_Months_PC__c = 'Other';
        testDQ.Ramp_Period_Days__c = 'Other';
        testDQ.Type__c = DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL;
        testDQ.Platform_Type__c = 'Cloud';
        testDQ.Status__c = 'In Progress';
        insert testDQ;
        
        BigMachines__Quote__c quote = TestUtil.createQuotes(1, testOpp.id, true)[0];
        
        //ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('id', testDQ.id);
        
        ApexPages.StandardController stdCtr = new ApexPages.StandardController(testOpp);
        DealQualificationCloudController objController = new DealQualificationCloudController(stdCtr);
        objController.objDQ.Type__c = DealQualificationApprovalUtil.DQ_RECORD_HISTORY;
        objController.reviseOnLoad();
        objController.save();
        
        testDQ.If_Other_Ramp_Period_Requested_Days__c = 120;
        testDQ.If_Other_Term_Months_Requested__c = 30;
        testDQ.Justification_for_Discount__c = 'test';
        update testDQ;
        ApexPages.currentPage().getParameters().put('id', testDQ.id);
        
        ApexPages.StandardController stdCtr2 = new ApexPages.StandardController(testOpp);
        DealQualificationCloudController objController2 = new DealQualificationCloudController(stdCtr2);
        objController2.objDQ.Type__c = DealQualificationApprovalUtil.DQ_RECORD_HISTORY;
        objController2.reviseOnLoad();
        objController2.save();
        
        Test.stoptest();
    }
    
    static testMethod void testDealQualificationCloudController6() { 
        Test.starttest();
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        insert testAccount;
        
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Enablement_Model__c = 'Direct Enablement';
        insert testOpp;
        
        Deal_Qualification__c testDQ = new Deal_Qualification__c();
        testDQ.Opportunity__c = testOpp.id;
        testDQ.Offering_Type__c = 'PureCloud';
        testDQ.Discount_On_Quote__c = 10;
        testDQ.Justification_for_Discount__c = null;
        testDQ.Is_Telco_Quoted_At_Standard_Rates__c = 'No';
        testDQ.PureCloud_Monthly_Minimum__c = 'Other';
        testDQ.Monthly_Recurring_Revenue_less_than_14K__c = 'Yes';
        testDQ.More_than_5_000_Business_Users__c = 'Yes';
        testDQ.Less_than_100_Agents__c = 'Yes';
        testDQ.Pricing_Type__c = 'New Pricing';
        testDQ.Type__c = DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL;
        testDQ.Platform_Type__c = 'Cloud';
        testDQ.Status__c = 'In Progress';
        insert testDQ;
        
        BigMachines__Quote__c quote = TestUtil.createQuotes(1, testOpp.id, true)[0];
        
        //ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('id', testDQ.id);
        
        ApexPages.StandardController stdCtr2 = new ApexPages.StandardController(testOpp);
        DealQualificationCloudController objController = new DealQualificationCloudController(stdCtr2);
        objController.objDQ.Type__c = DealQualificationApprovalUtil.DQ_RECORD_HISTORY;
        objController.reviseOnLoad();
        objController.save();
        
        testDQ.Justification_for_Discount__c = 'test';
        testDQ.Explanation_for_Telco_Pricing__c = 'test';
        testDQ.Estimated_Number_of_Agents__c = 50;
        testDQ.Estimated_Number_of_Business_Users__c = 6000;
        testDQ.Estimated_Monthly_Recurring_Revenue__c = 200;
        testDQ.If_Other_PureCloud_Monthly_Minimum_Req__c = 200;
        update testDQ;
        ApexPages.currentPage().getParameters().put('id', testDQ.id);
        
        ApexPages.StandardController stdCtr = new ApexPages.StandardController(testOpp);
        DealQualificationCloudController objController2 = new DealQualificationCloudController(stdCtr);
        objController2.objDQ.Type__c = DealQualificationApprovalUtil.DQ_RECORD_HISTORY;
        objController2.reviseOnLoad();
        objController2.save();
        
        Test.stoptest();
    }
    
    static testMethod void testDealQualificationCloudController7() { 
        Test.starttest();
        Account testAccount = TestUtil.createAccounts(1, false)[0];
        insert testAccount;
        
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Enablement_Model__c = 'Direct Enablement';
        insert testOpp;
        
         
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('ot', 'PureConnect Cloud');
        ApexPages.currentPage().getParameters().put('p', 'New Pricing');
        ApexPages.currentPage().getParameters().put('pt', 'Cloud');
        
        ApexPages.StandardController stdCtr2 = new ApexPages.StandardController(testOpp);
        DealQualificationCloudController objController = new DealQualificationCloudController(stdCtr2);
        
        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('ot', 'PureCloud');
        ApexPages.currentPage().getParameters().put('p', 'New Pricing');
        ApexPages.currentPage().getParameters().put('pt', 'Cloud');
        
        ApexPages.StandardController stdCtr3 = new ApexPages.StandardController(testOpp);
        DealQualificationCloudController objController3 = new DealQualificationCloudController(stdCtr3);
        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('ot', 'Business Edition');
        ApexPages.currentPage().getParameters().put('p', 'New Pricing');
        ApexPages.currentPage().getParameters().put('pt', 'Cloud');
        
        ApexPages.StandardController stdCtr4 = new ApexPages.StandardController(testOpp);
        DealQualificationCloudController objController4 = new DealQualificationCloudController(stdCtr4);
        
        BigMachines__Quote__c quote = TestUtil.createQuotes(1, testOpp.id, true)[0];
        quote.offering_type__c = 'Business Edition';
        quote.Quote_Business_Type__c = 'Cloud';
        quote.Initial_Subscription_Term__c = '3 Years';
        update quote;
        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('ot', 'Business Edition');
        ApexPages.currentPage().getParameters().put('p', 'New Pricing');
        ApexPages.currentPage().getParameters().put('pt', 'Cloud');
        
        ApexPages.StandardController stdCtr5 = new ApexPages.StandardController(testOpp);
        DealQualificationCloudController objController5 = new DealQualificationCloudController(stdCtr5);
        
        
        quote.offering_type__c = QuoteUtil.OFFERING_TYPE_CAAS;
        quote.No_Of_Months__c = 46;
        update quote;
        
        ApexPages.currentPage().getParameters().put('oppId', testOpp.id);
        ApexPages.currentPage().getParameters().put('ot', 'PureConnect Cloud');
        ApexPages.currentPage().getParameters().put('p', 'New Pricing');
        ApexPages.currentPage().getParameters().put('pt', 'Cloud');
        
        ApexPages.StandardController stdCtr6 = new ApexPages.StandardController(testOpp);
        DealQualificationCloudController objController6 = new DealQualificationCloudController(stdCtr6);
        
        Test.stoptest();
    }
}