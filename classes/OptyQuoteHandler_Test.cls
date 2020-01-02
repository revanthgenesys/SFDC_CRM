/**

 */
@isTest(SeeAllData=true)
private class OptyQuoteHandler_Test {

    static testMethod void OptyQuoteHandler_Method1() {
        
        Test.startTest();
        Util.Bypass_Trigger_Chk = true;
        Opportunity testOpp = TestUtil.createOpportunities(1, false)[0];
        testOpp.Primary_Line_of_Business__c = 'Cloud';
        insert testOpp;
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0]; 
    
        PageReference pageRef = page.OptyQuoteCategory;
        Test.setCurrentPage(pageRef);

        System.currentPageReference().getParameters().put('oppId', testOpp.id);
                         
        OptyQuoteHandler controller = new OptyQuoteHandler();
        
        testOpp.Primary_Line_of_Business__c = 'On Premise';
        update testOpp;
        controller = new OptyQuoteHandler();
        
        testOpp.Primary_Line_of_Business__c = 'Cloud';
        update testOpp;
        controller = new OptyQuoteHandler();
        
       
    }
    
    static testMethod void OptyQuoteHandler_Method2() 
    {
        
        Opportunity testOpp = TestUtil.createOpportunities(1, true)[0];
        testOpp.Quote_Category__c = 'Cloud';
        update testOpp;
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0]; 
    
        PageReference pageRef = page.OptyQuoteCategory;
        Test.setCurrentPage(pageRef);

        System.currentPageReference().getParameters().put('oppId', testOpp.id);
            
        ApexPages.StandardController sc = new ApexPages.standardController(testOpp);                
        OptyQuoteHandler controller = new OptyQuoteHandler(); 
        
        controller.objOpty = testOpp;
        //controller.retrieveQuoteCategory();
            
        Test.startTest();
        //testOpp.Quote_Category__c = 'Cloud2';
        testOpp.Quote_Category__c = 'On Premise';
        testOpp.direct_sales__c = true;
        //controller.selectedPricingOption = 'New Pricing';
        update testOpp;
        //controller.retrieveQuoteCategory();
        controller.goToCloneQuoteIfOppIsDownUpGrade();
        Test.stopTest();
    }
    
    static testMethod void OptyQuoteHandler_Method3() 
    {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1); 
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
                       
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
               
        ApexPages.currentPage().getParameters().put('oppId', list_NewOpps[0].id);
        ApexPages.StandardController std = new ApexPages.StandardController(new Opportunity());
        OptyQuoteHandler obj = new OptyQuoteHandler();
        obj.strSubscrSubType = 'Replace Existing Subscription';
        obj.createCaaSOrPureCloudQuote();        
        
        //Create subscription & products        
        List<Subscription_Product__c> list_NewSubscriptionProds = new List<Subscription_Product__c>();
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);  
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = 0;
        objNewSubscription.Quote__c = null;
        insert objNewSubscription;
        for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds) {                    
            Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);             
            objNewSubscriptionProd.Subscription__c = objNewSubscription.Id;
            list_NewSubscriptionProds.add(objNewSubscriptionProd);
        }  
        insert list_NewSubscriptionProds;
        
        obj.strSelectedOrderType = 'Amend';
        obj.strSubscrSubType = 'Renew Existing Subscription';
        obj.selectedSubscrToAmend = objNewSubscription.Id;
        obj.map_Subscriptions.put(objNewSubscription.Id, objNewSubscription);
        obj.createAmendPureCloudQuote();
    }
}