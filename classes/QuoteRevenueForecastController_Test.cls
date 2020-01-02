@isTest (seeAllData = true)
private class QuoteRevenueForecastController_Test {
    static testMethod void testMethod1() {
        Account testAcc = TestUtil.createAccounts(1, false)[0];
        testAcc.Name='AccNameTest';
        Insert testAcc;
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, false)[0];
        
        Opportunity testOpp = TestUtil.createOpportunities(1,false)[0];
        testOpp.closeDate = Date.Today();
        testOpp.name='TestName';
        testOpp.Subscription_Term__c='TestTerm';
        testOpp.Monthly_Commitment__c =10;
        insert testOpp;   
        
        Opportunity testChildOpp = TestUtil.createOpportunities(1,false)[0];
        testChildOpp.closeDate = Date.Today();
        testChildOpp.ParentOpportunity__c=testOpp.id;
        insert testChildOpp;
        
        
        List<Product2> productTemp = TestUtil.createProducts(1,true);
        List<PricebookEntry> pbTemp =TestUtil.CreatePriceBookEntries(  productTemp, true);
        TestUtil.createOlis( pbTemp, testChildOpp.id, true);
        
        Test.startTest();

        Cloud_Billing_Information__c newCloudBillingInfo = new Cloud_Billing_Information__c(Opportunity__c = testOpp.id);
        newCloudBillingInfo.Account__c = testAcc.id;
        newCloudBillingInfo.Quote__c = testQuote.id;
        newCloudBillingInfo.Actual_Go_Live_Date__c = Date.today().addDays(-1);
        insert newCloudBillingInfo;
        
        Cloud_Billing_Phase__c tempPhase = new Cloud_Billing_Phase__c();
        tempPhase.End_date__c = Date.Today();
        tempPhase.Cloud_Billing_Information__c = newCloudBillingInfo.id;
        tempPhase.Phase_Name__c = 'Go Live';
        insert tempPhase;
        
        Cloud_Billing_Phase__c tempPhase1 = new Cloud_Billing_Phase__c();
        tempPhase1.End_date__c = Date.Today();
        tempPhase1.Cloud_Billing_Information__c = newCloudBillingInfo.id;
        tempPhase1.Phase_Name__c = 'Steady State';
        insert tempPhase1;

       Test.stopTest();
      

    }
    static testMethod void testMethod2() {
        Account testAcc = TestUtil.createAccounts(1, false)[0];
        testAcc.Name='AccNameTest';
        Insert testAcc;
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, false)[0];
        
        Opportunity testOpp = TestUtil.createOpportunities(1,false)[0];
        testOpp.closeDate = Date.Today();
        testOpp.name='TestName';
        testOpp.Subscription_Term__c='TestTerm';
        testOpp.Monthly_Commitment__c =10;
        insert testOpp;   
        
        Opportunity testChildOpp = TestUtil.createOpportunities(1,false)[0];
        testChildOpp.closeDate = Date.Today();
        testChildOpp.ParentOpportunity__c=testOpp.id;
        insert testChildOpp;
        
        
        List<Product2> productTemp = TestUtil.createProducts(1,true);
        List<PricebookEntry> pbTemp =TestUtil.CreatePriceBookEntries(  productTemp, true);
        TestUtil.createOlis( pbTemp, testChildOpp.id, true);
        
        Test.startTest();

        Cloud_Billing_Information__c newCloudBillingInfo = new Cloud_Billing_Information__c(Opportunity__c = testOpp.id);
        newCloudBillingInfo.Account__c = testAcc.id;
        newCloudBillingInfo.Quote__c = testQuote.id;
        newCloudBillingInfo.Actual_Go_Live_Date__c = Date.today().addDays(-1);
        insert newCloudBillingInfo;
        
        Cloud_Billing_Phase__c tempPhase = new Cloud_Billing_Phase__c();
        tempPhase.End_date__c = Date.Today();
        tempPhase.Cloud_Billing_Information__c = newCloudBillingInfo.id;
        tempPhase.Phase_Name__c = 'Steady State';
        insert tempPhase;
        
        
       Test.stopTest();
      

    }
    static testMethod void testMethod3() {
        Account testAcc = TestUtil.createAccounts(1, false)[0];
        testAcc.Name='AccNameTest';
        Insert testAcc;
        BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, false)[0];
        
        Opportunity testOpp = TestUtil.createOpportunities(1,false)[0];
        testOpp.closeDate = Date.Today();
        testOpp.name='TestName';
        testOpp.Subscription_Term__c='TestTerm';
        testOpp.Monthly_Commitment__c =10;
        insert testOpp;   
        
        Opportunity testChildOpp = TestUtil.createOpportunities(1,false)[0];
        testChildOpp.closeDate = Date.Today();
        testChildOpp.ParentOpportunity__c=testOpp.id;
        insert testChildOpp;
        
        
        List<Product2> productTemp = TestUtil.createProducts(1,true);
        List<PricebookEntry> pbTemp =TestUtil.CreatePriceBookEntries(  productTemp, true);
        TestUtil.createOlis( pbTemp, testChildOpp.id, true);
        
        Test.startTest();

        Cloud_Billing_Information__c newCloudBillingInfo = new Cloud_Billing_Information__c(Opportunity__c = testOpp.id);
        newCloudBillingInfo.Account__c = testAcc.id;
        newCloudBillingInfo.Quote__c = testQuote.id;
        newCloudBillingInfo.Actual_Go_Live_Date__c = Date.today().addDays(-1);
        insert newCloudBillingInfo;

        Cloud_Billing_Phase__c tempPhase = new Cloud_Billing_Phase__c();
        tempPhase.End_date__c = Date.Today();
        tempPhase.Cloud_Billing_Information__c = newCloudBillingInfo.id;
        tempPhase.Phase_Name__c = 'Phase1';
        insert tempPhase;
        
        
       Test.stopTest();
      

    }
}