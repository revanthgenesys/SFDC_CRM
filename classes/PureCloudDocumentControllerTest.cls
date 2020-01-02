@isTest
public class PureCloudDocumentControllerTest {
    
    // BEGIN: UNIT TESTS
    @isTest 
    static void VerifyOutputForNewSubscription() 
    {                
        TestZQuoteContext context = new TestZQuoteContext();
        /*context.SetupZQuote();

        Test.startTest();
        PageReference pg = Page.PureCloudDocument;
        Test.setCurrentPage(pg);
        ApexPages.StandardController stc = new ApexPages.StandardController(context.ZQuote);
        PureCloudDocumentController controller = new PureCloudDocumentController(stc);
        
        //Pull list of values from controller that VF would attempt to pull
        System.assert(controller.orderedCategories != null, 'The controller did not populate the ordered categories');
        // These values should at least be initialized.  
        System.assert(controller.educationTotal != null);
        System.assert(controller.hardwareTotal != null);
        System.assert(controller.onetimeServicesTotal != null);
        System.assert(controller.annualSubscriptionTotal != null);
        System.assert(controller.monthlySubscriptionTotals != null);
        System.assert(controller.discountCharges != null);

        System.assert(!controller.newCharges.isEmpty(), 'The controller did not see new charges');
        System.assert(controller.originalCharges.isEmpty(), 'The controller should not have original charges for a new subscription');
        
        Test.stopTest();
        */
    }
    
    @isTest
    static void VerifyOutputForAmendment() 
    {  
        insert new Account(name = 'Holding Account');
        insert GeneralCustomSettingFactory.CreateZuoraCustomSettings();
        zqu__Quote__c quoteAmend = zqu.ZQTestDataSetup.prepareAmendmentQuote(true);
        // This line will create the product catalog, so no need to create it prior.  THANKS ZUORA
        List<zqu.zChargeGroup> amendChargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteAmend.Id);
        
        // Update product fields
        Product2 product = [SELECT Id, Product_Category__c, Partner_Margin_Type__c FROM Product2 LIMIT 1];
        product.Product_Category__c = 'Licenses';
        product.Partner_Margin_Type__c = 'PureCloud';
        update product;

        // Remove a charge from the amendment quote
        zqu.zQuoteUtil.deleteChargeGroup(amendChargeGroups.get(0));

        Test.startTest();
        PageReference pg = Page.PureCloudDocument;
        Test.setCurrentPage(pg);
        ApexPages.StandardController stc = new ApexPages.StandardController(quoteAmend);
        PureCloudDocumentController controller = new PureCloudDocumentController(stc);

        System.assert(!controller.removedCharges.isEmpty(), 'The controller did not see removed charges');
        System.assert(!controller.originalCharges.isEmpty(), 'The controller did not see original charges');

        Test.stopTest();    
    }
    
    @isTest
    static void VerifyOutputForPartnerQuote() 
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

        Id quoteId = quote.Id;
        DescribeSObjectResult describeResult = quote.Id.getSObjectType().getDescribe();     
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        fieldNames.add('zqu__Opportunity__r.BusinessPartner__c');
        fieldNames.add('zqu__Opportunity__r.Indirect_Partner_PureCloud_Approved__c');
        String query = 'SELECT ' +  String.join( fieldNames, ',' ) + ' FROM ' +  describeResult.getName() + ' WHERE id = :quoteId LIMIT 1';
        quote = (zqu__Quote__c)Database.query(query);
        
        // Create quote charge groups
        Map<Id, zqu__ProductRatePlan__c> rateplanMap = new Map <Id, zqu__ProductRatePlan__c> ([select Id from zqu__ProductRatePlan__c where zqu__Product__c = :product.Id]);
        List<Id> ratePlanIds = new List<Id>(rateplanMap.keySet());
        List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id, ratePlanIds);
        List<zqu.zChargeGroup> addedGroups = zqu.zQuoteUtil.addChargeGroups(chargeGroups);
        
        // Create Account Order Addresses
        Account_Order_Address__c soldTo = new Account_Order_Address__c(Address_Type__c = 'Ship To',
                                                                       Address__c = '123 Testing Stree',
                                                                       City__c = 'Indianapolis',
                                                                       State__c = 'Indiana',
                                                                       Zip_Code__c = '12345',
                                                                       Country__c = 'USA',
                                                                       Account__c = prospectAccount.Id,
                                                                       Sold_To_Business_Partner__c = partnerAccount.Id,
                                                                       Zuora_Quote__c = quote.Id);
        
        Account_Order_Address__c billTo = new Account_Order_Address__c(Address_Type__c = 'Bill To',
                                                                       Address__c = '123 Testing Stree',
                                                                       City__c = 'Indianapolis',
                                                                       State__c = 'Indiana',
                                                                       Zip_Code__c = '12345',
                                                                       Country__c = 'USA',
                                                                       Account__c = prospectAccount.Id,
                                                                       Sold_To_Business_Partner__c = partnerAccount.Id,
                                                                       Zuora_Quote__c = quote.Id);
        insert new List<Account_Order_Address__c>{ soldTo, billTo };

        Test.startTest();
        PageReference pg = Page.PureCloudDocument;
        Test.setCurrentPage(pg);
        ApexPages.StandardController stc = new ApexPages.StandardController(quote);
        PureCloudDocumentController controller = new PureCloudDocumentController(stc);

        System.assert(!controller.partnerMargins.isEmpty(), 'The controller did not set partner margins');
        System.assert(controller.billingAddress != null);
        System.assert(controller.shippingAddress != null);
        //controller.getorderedCategories();
        String cur = controller.currencySymbol;
        //ID i = controller.imgDocumentId;
        Decimal eTotal = controller.educationTotal;
        Decimal hTotal = controller.hardwareTotal;
        Decimal oTotal = controller.onetimeServicesTotal;
        Test.stopTest();    
    }
    
    @isTest
    static void VerifyMultiYearTermOutput()
    {
        insert new Account(name = 'Holding Account');
        insert GeneralCustomSettingFactory.CreateZuoraCustomSettings();
        zqu__Quote__c quoteAmend = zqu.ZQTestDataSetup.prepareAmendmentQuote(false);
        quoteAmend.zqu__InitialTerm__c = 24;
        insert quoteAmend;

        List<zqu.zChargeGroup> amendChargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteAmend.Id);
        
        // Update product fields
        Product2 product = [SELECT Id, Product_Category__c, Partner_Margin_Type__c  FROM Product2 LIMIT 1];
        product.Product_Category__c = 'Licenses';
        product.Partner_Margin_Type__c = 'PureCloud';
        update product;

        zqu__ZUnitOfMeasure__c uom = TestZQuoteContext.createUOM(true, '1234');
        Product2 licenseProduct = TestZQuoteContext.createLicenseProduct(true, 'TestProductZuoraId', 'Test License Product', 'Engage 1', 'TestSKU-212345678', 'Engage');
        List<zqu__ProductRatePlan__c> ratePlan = TestZQuoteContext.createProductRatePlansFromProducts(true, new List<Product2>{licenseProduct});
        zqu__ProductRatePlanCharge__c ratePlanCharge = TestZQuoteContext.createProductRatePlanCharge(true, 'TestChargeZuoraId', 'test charge name', rateplan[0], 100, 'Per Unit Pricing', 'Recurring', 'sometestsku', 'Annual', uom);
        List<zqu__ProductRatePlanChargeTier__c> ratePlanChargeTier = TestZQuoteContext.createProductTiersFromProductRatePlanCharges(true, new List<zqu__ProductRatePlanCharge__c>{ratePlanCharge});
        
        Id quoteId = quoteAmend.Id;
        DescribeSObjectResult describeResult = quoteId.getSObjectType().getDescribe();      
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        fieldNames.add('zqu__Opportunity__r.BusinessPartner__c');
        fieldNames.add('zqu__Opportunity__r.Indirect_Partner_PureCloud_Approved__c');
        String query = 'SELECT ' +  String.join( fieldNames, ',' ) + ' FROM ' +  describeResult.getName() + ' WHERE id = :quoteId LIMIT 1';
        zqu__Quote__c quote = (zqu__Quote__c)Database.query(query);
        
        List<zqu__ProductRatePlanCharge__c> charges = [SELECT Id, zqu__ProductRatePlan__c FROM zqu__ProductRatePlanCharge__c WHERE zqu__Type__c = 'Recurring' and zqu__RecurringPeriod__c = 'Annual'];
        System.assert(!charges.isEmpty(), 'No annual recurring charges were created');
        List<Id> ratePlanIds = new List<Id>();
        for(zqu__ProductRatePlanCharge__c c : charges)
        {
            ratePlanIds.add(c.zqu__ProductRatePlan__c);
        }
        
        List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(quote.Id, ratePlanIds);
        List<zqu.zChargeGroup> addedGroups = zqu.zQuoteUtil.addChargeGroups(chargeGroups);
        
        Test.startTest();
        PageReference pg = Page.PureCloudDocument;
        Test.setCurrentPage(pg);
        ApexPages.StandardController stc = new ApexPages.StandardController(quote);
        PureCloudDocumentController controller = new PureCloudDocumentController(stc);

        System.assert(controller.remainingTerm != null);
        System.assert(controller.yearOneContractValue != null);
        System.assert(controller.totalContractValue != null);
        System.assert(controller.isMultiYearTerm);

        Test.stopTest(); 
    }
    // END: UNIT TESTS

}