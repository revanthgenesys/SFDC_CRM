@isTest
public class ZuoraQuoteUtilityTest {

    @isTest
    static void TestSettingZuoraQuoteAsPrimary()
    {
        TestZQuoteContext context = new TestZQuoteContext();
        context.SetupZQuote();
        
        // Put two quotes on the same opp
        context.ZQuote2.zqu__Opportunity__c = context.ZQuote.zqu__Opportunity__c;
        context.ZQuote.zqu__Primary__c = true;
        update new List<zqu__Quote__c>{ context.ZQuote, context.ZQuote2 };
        
        Test.startTest();
        String result = ZuoraQuoteUtility.setZuoraQuoteAsPrimary(context.ZQuote2.Id);
        
        Map<Id, zqu__Quote__c> quotes = new Map<Id, zqu__Quote__c>([SELECT Id, zqu__Primary__c FROM zqu__Quote__c]);
        System.assert(!quotes.get(context.ZQuote.Id).zqu__Primary__c, 'Quote1 was not removed as the primary');
        System.assert(quotes.get(context.ZQuote2.Id).zqu__Primary__c, 'Quote2 was not set as the primary');
        
        Test.stopTest();
    }
    
    @isTest
    static void TestUpdatingOppFromZuoraQuote()
    {
        TestZQuoteContext context = new TestZQuoteContext();
        context.SetupZQuote();
        
        // Put two quotes on the same opp
        context.ZQuote2.zqu__Opportunity__c = context.ZQuote.zqu__Opportunity__c;
        context.ZQuote.zqu__Primary__c = true;
        update new List<zqu__Quote__c>{ context.ZQuote, context.ZQuote2 };
                
        Test.startTest();
        
        // Attempt to sync a quote that is not primary
        String result = ZuoraQuoteUtility.syncQuoteToOpportunity(context.ZQuote2.Id);
        System.assertEquals('The quote you are attempting to sync is not the primary quote for this opportunity.  You may only sync the primary quote to the Opportunity.', result);
        
        result = ZuoraQuoteUtility.syncQuoteToOpportunity(context.ZQuote.Id);
        System.assertEquals('The Opportunity was successfully updated with information from the Primary Quote.', result);
        
        Test.stopTest();
    }
    
    @isTest
    static void TestSettingPartnerPricing()
    {
        insert GeneralCustomSettingFactory.CreateZuoraCustomSettings();
        
        // Create Test Accounts
        Account holdingAcct = AccountFactory.CreateHoldingAccount();
        Account prospectAccount = AccountFactory.CreateProspectAccount('PureCloud Prospect');
        AccountFactory.SetRequiredPureCloudCustomerFields(prospectAccount);
        Account partnerAccount = AccountFactory.CreatePartnerProspectAccount('Approved Partner Account');
        AccountFactory.SetRequiredPartnerFields(partnerAccount);
        insert new List<Account>{ holdingAcct, prospectAccount, partnerAccount };
            
        // Create PureCloud Partner Margins
        insert new PureCloud_Partner_Margin__c(Account__c = partnerAccount.Id,
                                               Margin_Type__c = 'PureCloud',
                                               From_Date__c = Date.today().addDays(-1),
                                               To_Date__c = Date.today().addDays(364),
                                               Percent__c = 25.0);
        
        // Create PureCloud Opp
        Opportunity pcOpp = OpportunityFactory.CreatePureCloudOpportunity('Partner PC Opp');
        pcOpp.BusinessPartner__c = partnerAccount.Id;
        pcOpp.AccountId = prospectAccount.Id;
        pcOpp.Direct_Indirect_Sale__c = 'Indirect';
        insert pcOpp;
        
        pcOpp = [SELECT Id, Indirect_Partner_PureCloud_Approved__c FROM Opportunity WHERE Id = :pcOpp.Id];
        System.assert(pcOpp.Indirect_Partner_PureCloud_Approved__c, 'PureCloud Approved flag on the Opportunity is not set to True');
        
        // Create product catalog        
        Product2 product = zqu.ZQTestDataSetup.prepareProduct();        
     
        product = [SELECT Id, Product_Category__c,Partner_Margin_Type__c  FROM Product2 WHERE Id = :product.Id];
        product.Product_Category__c = 'Licenses';
        product.Partner_Margin_Type__c = 'PureCloud';
        update product;
        
        // Create Quote
        zqu__Quote__c quote = zqu.ZQTestDataSetup.prepareNewSubscriptionQuote(false);
        quote.zqu__Opportunity__c = pcOpp.Id;
        quote.zqu__Account__c = prospectAccount.Id;
        insert quote;
        
        // Create quote charge groups
        Map<Id, zqu__ProductRatePlan__c> rateplanMap = new Map <Id, zqu__ProductRatePlan__c> ([select Id from zqu__ProductRatePlan__c where zqu__Product__c = :product.Id]);
        List<Id> ratePlanIds = new List<Id>(rateplanMap.keySet());
        List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id, ratePlanIds);
        List<zqu.zChargeGroup> addedGroups = zqu.zQuoteUtil.addChargeGroups(chargeGroups);
        
        Test.startTest();
        
        ZuoraQuoteUtility.updateChargePartnerPricing(quote.Id);
        
        List<zqu__QuoteRatePlanCharge__c> quoteCharges = [SELECT Id, Name, Product_Category__c, Partner_Price__c,
                                                                 zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Partner_Margin_Type__c
                                                          FROM zqu__QuoteRatePlanCharge__c 
                                                          WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :quote.Id];
        for(zqu__QuoteRatePlanCharge__c q : quoteCharges)
        {
            if(q.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Partner_Margin_Type__c == 'PureCloud')
            {
                System.assert(q.Partner_Price__c != null, 'The Partner Price was not set for: ' + q.Name);
            }
        }
        
        Test.stopTest();
    }
    @isTest(seealldata=true)
    static void TestUpdatingOppFromBMQuote()
    {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
       // Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createQuoteProducts(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQuoteProds.size(), 2);    
                
        Test.startTest();
        
        ZuoraQuoteUtility util = ZuoraQuoteUtility.getInstance(list_NewOpps[0].Id);
        util.primaryQuoteId = list_NewQuotes[0].Id;
        util.setPrimaryQuote();        
       
        Test.stopTest();
    }
}