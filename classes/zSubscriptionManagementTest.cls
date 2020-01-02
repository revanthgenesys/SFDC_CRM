@isTest
private class zSubscriptionManagementTest {

	// BEGIN: TEST SETUP
    @testSetup
    static void SetupTestData()
    {
        insert new Account(name = 'Holding Account');
    }
    // END: TEST SETUP
	
	public testMethod static void testBulkSubscriptionInsert()
    {       
        List<zqu__Quote__c> quotes = new List<zqu__Quote__c>();
        List<zqu__QuoteAmendment__c> quoteAmendments = new List<zqu__QuoteAmendment__c>();
        Map<Id, zqu__QuoteAmendment__c> quoteIdToAmendment = new Map<Id, zqu__QuoteAmendment__c>();
        List<zqu__QuoteRatePlan__c> quoteRatePlans = new List<zqu__QuoteRatePlan__c>();
        List<Zuora__Subscription__c> subscriptions = new List<Zuora__Subscription__c>();

        insert GeneralCustomSettingFactory.CreateZuoraCustomSettings();        
        
        //AX_Legal_Entity__c axEntity = AxLegalentityFactory.CreateDefaultEntity();
        //insert axEntity;
        
        Account account = AccountFactory.CreateProspectAccount('TestAccount');
        AccountFactory.SetRequiredPureCloudCustomerFields(account);
        insert account;
        
        Opportunity opp = OpportunityFactory.createPurecloudOpportunity('TestOpp');
        opp.Account = account;
        insert opp;
        
        TestZQuoteContext.createCatalog('TestProductZuoraId', 'TestRatePlanZuoraId', 'TestChargeZuoraId');
     
        Product2 product = [SELECT Id, Product_Category__c FROM Product2 LIMIT 1];
        product.Product_Category__c = 'Licenses';
        update product;
        
        //Create Quotes
        for (integer i = 0; i <= 200; ++i)
        {
            zqu__Quote__c quote = new zqu__Quote__c();
        	quote.Name = 'Quote'+i;
            quote.zqu__SubscriptionType__c = 'Amend Subscription';
            quote.zqu__StartDate__c = System.today();
            quote.zqu__ValidUntil__c = System.today().addDays(90);
            quote.zqu__InitialTerm__c = 1;
            quote.zqu__RenewalTerm__c = 1;
            quote.zqu__Account__c = account.Id;
            quote.zqu__Opportunity__c = opp.Id;
            quote.zqu__BillToContact__c = null;
            quote.zqu__SoldToContact__c = null;
            quote.zqu__Currency__c = 'USD';
            quote.zqu__Status__c = 'Sent to Z-Billing';
            quote.zqu__PaymentTerm__c = 'Net 30';
            quote.zqu__Subscription_Term_Type__c = 'Termed';
            quote.zqu__SubscriptionVersion__c = 1;
            quote.zqu__Hidden_Subscription_Name__c = 'Subscription' + i;
            quotes.add(quote);
        }
        
        insert quotes;

        // Create Quote Amendments
        for(zqu__Quote__c quote : quotes)
        {
            zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
            quoteAmendment.Name = 'QuoteAmendment' + quote.Name;
            quoteAmendment.CurrencyIsoCode = quote.CurrencyIsoCode;
            quoteAmendment.zqu__Quote__c = quote.Id;
            quoteAmendment.zqu__Type__c = 'RemoveProduct';
            quoteAmendment.zqu__Description__c = 'Updated or removed product';
            
            quoteAmendment.zqu__Status__c = 'Completed';
            quoteAmendment.zqu__DeltaTCV__c = 0;
            quoteAmendments.add(quoteAmendment);
        }
        
        insert quoteAmendments;

        for(zqu__QuoteAmendment__c qa : [SELECT Id, zqu__Quote__c FROM zqu__QuoteAmendment__c])
        {
            quoteIdToAmendment.put(qa.zqu__Quote__c, qa);
        }

        // Create Quote Rate Plans
        for (zqu__Quote__c quote : quotes)
        {
        	zqu__QuoteRatePlan__c quoteRatePlan = new zqu__QuoteRatePlan__c();
            zqu__QuoteAmendment__c quoteAmendment = quoteIdToAmendment.get(quote.Id);
        	quoteRatePlan.Name = quote.Name + 'RatePlan';
            quoteRatePlan.CurrencyIsoCode = quote.CurrencyIsoCode;
            quoteRatePlan.zqu__QuoteAmendment__c = null;
            quoteRatePlan.zqu__AmendmentType__c = 'RemoveProduct';
            quoteRatePlan.zqu__Quote__c = quote.Id;
            //quoteRatePlan.zqu__QuoteRatePlanZuoraId__c = zuoraId;
            //quoteRatePlan.zqu__ProductRatePlan__c = productRatePlanCharge.zqu__ProductRatePlan__c;
            quoteRatePlan.zqu__ProductRatePlanZuoraId__c = 'TestRatePlanZuoraId';
            //quoteRatePlan.zqu__QuoteProductName__c = productRatePlanCharge.Name;
            quoteRatePlan.zqu__QuoteAmendment__c = quoteAmendment.Id;
        	quoteRatePlans.add(quoteRatePlan);
        }
        
        insert quoteRatePlans;        

        // Create Subscriptions
        for(zqu__Quote__c quote : quotes)
        {
            Zuora__Subscription__c subscription = new Zuora__Subscription__c();
            subscription.Name = quote.zqu__Hidden_Subscription_Name__c;
            subscription.Zuora__OriginalCreatedDate__c = Date.Today().addDays(-7);
            subscription.Zuora__OriginalCreated_Date__c = DateTime.Now().addDays(-7);
            subscription.Zuora__Account__c = account.Id;
            subscriptions.add(subscription);
        }

        Test.startTest();
        insert subscriptions;

        for(zqu__QuoteRatePlan__c qrp : [SELECT Send_Email__c FROM zqu__QuoteRatePlan__c])
        {
            System.assert(!qrp.Send_Email__c, 'The Send_Email__c flag on the Quote Rate Plan was not set to false');
        }

        Test.stopTest();

    }
    
    public testMethod static void testSubscriptionAmendmentProductRemoval()
    {
        Test.startTest();
        TestZQuoteContext context = new TestZQuoteContext();

        insert GeneralCustomSettingFactory.CreateZuoraCustomSettings();
                
        //AX_Legal_Entity__c axEntity = AxLegalentityFactory.CreateDefaultEntity();
        //insert axEntity;

        // Create amendment quote and the original charges
        zqu__Quote__c zQuote = zqu.ZQTestDataSetup.prepareAmendmentQuote(true);
		List<zqu.zChargeGroup> amendChargeGroups = zqu.zQuoteUtil.getChargeGroups(zQuote.Id);

        // Update product fields
        Product2 product = [SELECT Id, Product_Category__c FROM Product2 LIMIT 1];
        product.Product_Category__c = 'Licenses';
        update product;

        // Delete one charge group to create a removed product amendment
		zqu.zQuoteUtil.deleteChargeGroup(amendChargeGroups[2]);
        Test.stopTest();

        // Assert at least one quote rate plan is flagged to send an e-mail
        Integer removedProducts = [SELECT count() 
                                   FROM zqu__QuoteRatePlan__c 
                                   WHERE zqu__Quote__c = :zQuote.id AND zqu__AmendmentType__c = 'RemoveProduct'];

        System.assert(removedProducts > 0, 'No removed products found on subscription amendment');
        
        context.SimulateSendtoZBilling(zQuote, true);
                
        removedProducts = [SELECT count() 
                           FROM zqu__QuoteRatePlan__c 
                           WHERE zqu__Quote__c = :zQuote.id AND zqu__AmendmentType__c = 'RemoveProduct' AND Send_Email__c = true];

        System.assert(removedProducts == 0, 'Removed product e-mail sent');
    }
    
    public testMethod static void testNewSubscription()
    {
        zqu__Quote__c zQuote;
        Test.startTest();
        TestZQuoteContext context = new TestZQuoteContext();
        context.SetupZQuote();
        Test.stopTest();

        // Assert no quote rate plans were set to send an email
        zQuote = context.ZQuote;
        Integer removedProducts = [SELECT count() 
                                   FROM zqu__QuoteRatePlan__c 
                                   WHERE zqu__Quote__c = :zQuote.id AND Send_Email__c = true];

        System.assert(removedProducts == 0, 'No quote rate plans set to send email');
    }
    
    public testMethod static void testSubscriptionUpdate()
    {
        TestZQuoteContext context = new TestZQuoteContext();
		context.SetupZQuote();
        
        Test.startTest();

        context.SimulateSendtoZBilling(context.ZQuote, true);

        
        List<Zuora__Subscription__c> subscriptions = [SELECT Id, Zuora__Zuora_Id__c, PureCloud_Monthly_Minimum__c, PureCloud_Ramp_Up_Period__c FROM Zuora__Subscription__c];
        
        for (Zuora__Subscription__c subscription : subscriptions)
        {
            subscription.PureCloud_Monthly_Minimum__c = '4000';
        }
        
        update subscriptions;

        Zuora__Subscription__c subscription2 = context.zQuoteSubscr.clone();
        subscription2.Name = 'Sub2';
        subscription2.Zuora__Zuora_Id__c = '2c92c0f950d7hju60150dd80b0690a6e';
        subscription2.Zuora__Version__c = 1;
        subscription2.Zuora__External_Id__c = '2c92c0f950d7hju60150dd80b0690a6e';
        subscription2.Zuora__SubscriptionNumber__c = '2';
        insert subscription2;

       subscriptions = [SELECT Id, Zuora__Zuora_Id__c, PureCloud_Monthly_Minimum__c, PureCloud_Ramp_Up_Period__c FROM Zuora__Subscription__c];
        
        for (Zuora__Subscription__c subscription : subscriptions)
        {
            subscription.PureCloud_Monthly_Minimum__c = '4000';
        }
        
        update subscriptions;

        Test.stopTest();        

        subscriptions = [SELECT Id, Zuora__Zuora_Id__c, PureCloud_Monthly_Minimum__c, PureCloud_Ramp_Up_Period__c FROM Zuora__Subscription__c];
        
        for (Zuora__Subscription__c subscription : subscriptions)
        {
            System.assert(subscription.PureCloud_Monthly_Minimum__c == '4000', 'The PureCloud_Monthly_Minimum__c was not updated for ' + subscription.Id);
        }

        
    }
	
}