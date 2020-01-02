@isTest

// The Dev Org items were added to support the test methods for promotion parts
// JIRA: PCPQ-56, PCPQ-52

public class TestZQuoteContext {
    private zqu__ProductRatePlanCharge__c dummyRatecharge;
    private zqu__ProductRatePlanCharge__c zratecharge5;
    private final static String DummyPartNumber = 'PV-170-NV-PCVOICE';
    
    public User Noah
    {
        get;
        private set;
    }
    
    public Contact ZContact
    {
        get;
        private set;
    }
    
    public Account ZAccount
    {
        get;
        private set;
    }
    
    public Opportunity ZOpportunity
    {
        get;
        private set;
    }
    
    public zqu__Quote__c ZQuote
    {
        get;
        private set;
    }
    
    public zqu__QuoteRatePlanCharge__c zQuoteLicenseCharge
    {
        get;
        private set;
    }
    
    public zqu__QuoteRatePlanCharge__c zQuoteTokenCharge
    {
        get;
        private set;
    }
    
    public zqu__QuoteRatePlanCharge__c zQuoteOverageCharge
    {
        get;
        private set;
    }
    
    public List<zqu__QuoteRatePlanCharge__c> oneTimeZQuoteCharges
    {
        get;
        private set;
    }
    
    public List<zqu__QuoteRatePlanCharge__c> licensesZQuoteCharges
    {
        get;
        private set;
    }
    
    
    public List<zqu__QuoteRatePlanCharge__c> zQuoteCharges
    {
        get;
        private set;
    }
    
    public zqu__Quote__c ZQuote2
    {
        get;
        private set;
    }
    
    public zqu__Quote__c ZQuoteLicenseOnly
    {
        get;
        private set;
    }
    
    public TestAccountContext acctContext;
    
    public TestZQuoteContext()
    { 
    }
    
    public Opportunity InternalPCOpp1
    {
        get;
        private set;
    }
    /*public List<Opportunity_line_item__c> InternalPCOpp1LineItems
    {
        get;
        private set;
    }*/
    
    public Order__c InternalPCOrder1
    {
        get;
        private set;
    }
    
    public List<Order_Line_Item__c> InternalPCOrder1LineItems
    {
        get;
        private set;
    }
    
    public Zuora__Subscription__c zQuoteSubscr
    {
        get;
        set;
    }
    
    public Zuora__SubscriptionProductCharge__c zQuoteAddSubscrlicense
    {
        get;
        set;
    }
    
    public List<zqu__QuoteAmendment__c> amendmentList
    {
        get;
        set;
    }
    
    public Boolean isAmendment
    {
        get;
        set;
    }
    
    public zqu__ZUnitOfMeasure__c zUOM
    {
        get;
        set;
    }

    
    public zqu__ProductRatePlan__c PromoPartProductRatePlan 
    {
        get;
        set;
    }
    

    public TestZQuoteContext SetQuote(zqu__Quote__c newQuote)
    {
        this.ZQuote = newQuote;
        
        return this;
    }
    //Create a test Quote
    
    public static zqu__Quote__c createQuote(Boolean doInsert, Id accId, Opportunity opp, Boolean isAnnual) 
    {
        return createQuote(doInsert, accId, opp, isAnnual, 'New Subscription', null, null, 'USD');
    }
    public static zqu__Quote__c createQuote(Boolean doInsert, Id accId, Opportunity opp, Boolean isAnnual, String subscriptionType, Contact billTo, Contact soldTo, String currencyIsoCode) 
    {
        zqu__Quote__c quote = new zqu__Quote__c();
        quote.Name = 'Test Quote';
        quote.zqu__SubscriptionType__c = subscriptionType;
        quote.zqu__StartDate__c = System.today();
        quote.zqu__ValidUntil__c = System.today().addDays(90);
        quote.zqu__InitialTerm__c = (isAnnual == true) ? 12 : 1;
        quote.zqu__RenewalTerm__c = (isAnnual == true) ? 12 : 1;
        quote.zqu__Account__c = (accId != null) ? accId : null;
        quote.zqu__Opportunity__c = (opp != null) ? opp.Id : null;
        quote.zqu__BillToContact__c = (billTo != null) ? billTo.Id : null;
        quote.zqu__SoldToContact__c = (soldTo != null) ? soldTo.Id : null;
        quote.zqu__Currency__c = currencyIsoCode;
        
        quote.zqu__Status__c = 'New';
        quote.zqu__PaymentTerm__c = 'Net 30';
        quote.zqu__Subscription_Term_Type__c = 'Termed';
        
        quote.CurrencyIsoCode = currencyIsoCode;
        quote.Opportunity_Owner__c = UserInfo.getUserId();
        quote.Annual_PrePay__c = (isAnnual == true) ? true : false;
        
        if (doInsert) 
        {
            insert quote;
        }
        
        return quote;
    }
    
    public static createCatalogResult createCatalog(String productZuoraId, String rateplanZuoraId, String chargeZuoraId) 
    {
        return createCatalog(productZuoraId, rateplanZuoraId, chargeZuoraId, 'tier01', '1234');
    }
    
    public static createCatalogResult createCatalog(String productId, String rateplanId, String chargeId, String tierId, String uomId) 
    {
        zqu__ZUnitOfMeasure__c uom = createUOM(true, uomId);
        Product2 prod = createProduct(true, productId);
        zqu__ProductRatePlan__c rateplan = createProductRatePlan(true, rateplanId, prod, null, null);
        zqu__ProductRatePlanCharge__c charge = createProductRatePlanCharge( true, chargeId, 'test charge name', rateplan, 50, 'model', 'type', 'test-sku-1', 'Month', uom);
        zqu__ProductRatePlanChargeTier__c tier = createProductRatePlanChargeTier( true, tierId, charge);	
        
        createCatalogResult result = new createCatalogResult();
        result.sProductId = prod.Id;
        result.sProductRatePlanId = rateplan.Id;
        result.sProductRatePlanChargeId = charge.Id;
        result.productRatePlan = rateplan;
        result.productRatePlanCharge = charge;
        
        return result;
    }
    
    public static zqu__ZUnitOfMeasure__c createUOM(Boolean doInsert, String zuoraId) 
    {
        zqu__ZUnitOfMeasure__c uom = new zqu__ZUnitOfMeasure__c();
        uom.Name = 'Each';
        uom.zqu__Active__c = true;
        uom.zqu__Uom_precision__c = 0;
        uom.zqu__Uom_rounding_mode__c = 'Up';
        uom.zqu__ZuoraId__c = zuoraId;
        
        if (doInsert) 
        {
            insert uom;
        }
        
        return uom;
    }
    
    public static Product2 createHardwareProduct(Boolean doInsert, String zuoraId, String productName, String productSubcategory, String sku, String productLine) 
    {
        return createProduct(doInsert, zuoraId, productName, 'Hardware', productSubcategory, true, sku, productLine);
    }
    public static Product2 createLicenseProduct(Boolean doInsert, String zuoraId, String productName, String productSubcategory, String sku, String productLine) 
    {
        return createProduct(doInsert, zuoraId, productName, 'Licenses', productSubcategory, false, sku, productLine);
    }
    public static Product2 createServiceProduct(Boolean doInsert, String zuoraId, String productName, String productSubcategory, String sku, String productLine) 
    {
        return createProduct(doInsert, zuoraId, productName, 'Services', productSubcategory, false, sku, productLine);
    }
    public static Product2 createProduct(Boolean doInsert, String zuoraId)
    {
        return createProduct(doInsert, zuoraId, 'Test Hardware Name', 'Hardware', 'Engage 1', true, 'TH-508-ACIP50PS', 'Communicate, Engage');
    }
    public static Product2 createProduct(Boolean doInsert, String zuoraId, String productName, String productCategory, String productSubcategory, Boolean shippable, String sku, String productLine) 
    {
        Product2 product = new Product2();
        product.Name = productName;//(isBase) ? baseProductName : (isVolume) ? volumeProductName : otherProductName;
        product.zqu__Deleted__c = false;
        product.zqu__ZuoraId__c = zuoraId;
        product.zqu__EffectiveStartDate__c = System.today().addYears(-1);
        product.zqu__EffectiveEndDate__c = System.today().addYears(1);
        product.zqu__SKU__c = sku;
        product.zqu__Category__c = ProductCategory;
        
        product.Product_Category__c = ProductCategory;
        product.Product_Subcategory__c = ProductSubcategory;
        product.ProductShippable__c = shippable == true ? 'Yes' : 'No';
        product.Product_Line__c = productLine;
        product.CurrencyIsoCode = 'USD';
        
        //System.debug('Creating product of category: '+product.Product_Category__c);
        
        if (doInsert) 
        {
            insert product;
        }
        return product;
    }
    
    public static zqu__ProductRatePlan__c createProductRatePlan(Boolean doInsert, String zuoraId, Product2 product, Date effectiveStartDate, Date effectiveEndDate) 
    {
        zqu__ProductRatePlan__c productRateplan = new zqu__ProductRatePlan__c();
        productRateplan.Name = product.Name;
        productRateplan.zqu__Deleted__c = false;
        productRateplan.zqu__EffectiveStartDate__c = (effectiveStartDate == null) ? System.today().addYears(-1) : effectiveStartDate;
        productRateplan.zqu__EffectiveEndDate__c = (effectiveEndDate == null) ? System.today().addYears(1) : effectiveEndDate;
        //productRateplan.zqu__ZProduct__c = [SELECT Id from zqu__ZProduct__c WHERE zqu__Product__c = :product.id LIMIT 1].id;
        productRateplan.zqu__Product__c = product.Id;
        productRateplan.zqu__ZuoraId__c = zuoraId;
        
        if (doInsert) 
        {
            insert productRateplan;
        }
        return productRateplan;
    }
    
    public static List<zqu__ProductRatePlan__c> createProductRatePlansFromProducts(Boolean doInsert, List<Product2> products)
    {
        List<zqu__ProductRatePlan__c> productRatePlans = new List<zqu__ProductRatePlan__c>();
        Integer index = 1;
        
        for (Product2 product : products)
        {
            productRatePlans.add(createProductRatePlan(false, 'plan'+index, product, null, null));
            ++index;
        }
        
        if (doInsert)
        {
            insert productRatePlans;
        }
        
        return productRatePlans;
    }

    public static zqu__ProductRatePlanCharge__c createProductRatePlanCharge(Boolean doInsert, String zuoraId, String name, zqu__ProductRatePlan__c rateplan, Decimal listPrice, String model, String type, String sku) 
    {
        return createProductRatePlanCharge(doInsert, zuoraId, name, rateplan, listPrice, model, type, sku, 'Month', null);
    }
    public static zqu__ProductRatePlanCharge__c createProductRatePlanCharge(Boolean doInsert, String zuoraId, String name, zqu__ProductRatePlan__c rateplan, Decimal listPrice, String model, String type, String sku, String billingPeriod) 
    {
        return createProductRatePlanCharge(doInsert, zuoraId, name, rateplan, listPrice, model, type, sku, billingPeriod, null);
    }
    public static zqu__ProductRatePlanCharge__c createProductRatePlanCharge(Boolean doInsert, String zuoraId, String name, zqu__ProductRatePlan__c rateplan, Decimal listPrice, String model, String type, String sku, String billingPeriod, zqu__ZUnitOfMeasure__c uom) 
    {
        zqu__ProductRatePlanCharge__c charge = new zqu__ProductRatePlanCharge__c();
        charge.Name = name;
        charge.zqu__AccountingCode__c = 'Accounts Receivable';
        charge.zqu__DefaultQuantity__c = 1;
        charge.zqu__Deleted__c = false;
        charge.zqu__ListPrice__c = listPrice;
        charge.zqu__Model__c = model;
        charge.zqu__RecurringPeriod__c = billingPeriod;
        charge.zqu__ProductRatePlan__c = rateplan.Id;
        //charge.zqu__RecurringPeriod__c = 'Month';
        charge.zqu__Type__c = type;
        if (uom != null)
        { 
        	charge.zqu__ZUnitOfMeasure__c = uom.Id;
        	charge.zqu__UOM__c = uom.Name;
        	charge.zqu__ZUom_Id__c = uom.zqu__ZuoraId__c;
        }
        charge.zqu__ZuoraId__c = zuoraId;
        charge.SKU__c = sku + '-C1';
        
        if (doInsert) 
        {
            insert charge;
        }
        return charge;
    }
    
    public static List<zqu__ProductRatePlanChargeTier__c> createProductTiersFromProductRatePlanCharges(Boolean doInsert, List<zqu__ProductRatePlanCharge__c> productRatePlanCharges)
    {
        List<zqu__ProductRatePlanChargeTier__c> productRatePlanChargeTiers = new List<zqu__ProductRatePlanChargeTier__c>();
        Integer index = 1;
        
        for (zqu__ProductRatePlanCharge__c productRatePlanCharge : productRatePlanCharges)
        {
            createProductRatePlanChargeTier(false, '2c92c0f84c5100b6014c6ab62dfc1e8'+index, productRatePlanCharge);
            ++index;
        }
        
        if (doInsert)
        {
            insert productRatePlanChargeTiers;
        }
        
        return productRatePlanChargeTiers;
    }
    
    public static zqu__ProductRatePlanChargeTier__c createProductRatePlanChargeTier(Boolean doInsert, String zuoraId, zqu__ProductRatePlanCharge__c charge) 
    {
        zqu__ProductRatePlanChargeTier__c tier = new zqu__ProductRatePlanChargeTier__c();
        tier.Name = '1';
        tier.zqu__Currency2__c = 'USD';
        tier.zqu__Deleted__c = false;
        tier.zqu__EndingUnit__c = 0;
        tier.zqu__IsOveragePrice__c = false;
        tier.zqu__Price__c = 100;
        tier.zqu__PriceFormat2__c = 'Flat Fee';
        tier.zqu__ProductRatePlanCharge__c = charge.Id;
        tier.zqu__ProductRatePlanChargeId__c = charge.Id;
        tier.zqu__StartingUnit__c = 0;
        tier.zqu__Tier__c = 1;
        tier.zqu__ZuoraId__c = zuoraId;
        
        if (doInsert) 
        {
            insert tier;
        }
        return tier;
    }
    
    public static zqu__QuoteAmendment__c createQuoteAmendment(Boolean doInsert, String name, String quoteId, String type, String status, String currencyIsoCode)
    {
        zqu__QuoteAmendment__c quoteAmendment = new zqu__QuoteAmendment__c();
        quoteAmendment.Name = name;
        quoteAmendment.CurrencyIsoCode = currencyIsoCode;
        quoteAmendment.zqu__Quote__c = quoteId;
        quoteAmendment.zqu__Type__c = type;
        quoteAmendment.zqu__Description__c = (type == 'NewProduct') ? 'New Product' : 'Updated or removed product';
        
        quoteAmendment.zqu__Status__c = status;
        quoteAmendment.zqu__DeltaTCV__c = 0;
        
        if (doInsert)
        {
            insert quoteAmendment;
        }
        
        return quoteAmendment;
    }
    
    public static List<zqu__QuoteAmendment__c> createQuoteAmendmentsFromProductRatePlanCharges(Boolean doInsert, Id quoteId, List<zqu__ProductRatePlanCharge__c> productRatePlanCharges)
    {
        List<zqu__QuoteAmendment__c> quoteAmendments = new List<zqu__QuoteAmendment__c>();
        
        for (zqu__ProductRatePlanCharge__c productRatePlanCharge : productRatePlanCharges)
        {
            quoteAmendments.add(createQuoteAmendment(false, productRatePlanCharge.Name, quoteId, 'NewProduct', 'Draft', productRatePlanCharge.CurrencyIsoCode));
        }
        
        if (doInsert)
        {
            insert quoteAmendments;
        }
        
        return quoteAmendments;
    }
    
    public static zqu__QuoteRatePlan__c createQuoteRatePlan(Boolean doInsert, String zuoraId, Id quoteId, zqu__ProductRatePlanCharge__c productRatePlanCharge, zqu__QuoteAmendment__c quoteAmendment)
    {
        zqu__QuoteRatePlan__c quoteRatePlan = new zqu__QuoteRatePlan__c();
        quoteRatePlan.Name = productRatePlanCharge.Name;
        quoteRatePlan.CurrencyIsoCode = productRatePlanCharge.CurrencyIsoCode;
        quoteRatePlan.zqu__QuoteAmendment__c = quoteAmendment.id;
        quoteRatePlan.zqu__AmendmentType__c = quoteAmendment.zqu__Type__c;
        quoteRatePlan.zqu__Quote__c = quoteId;
        quoteRatePlan.zqu__QuoteRatePlanZuoraId__c = zuoraId;
        quoteRatePlan.zqu__ProductRatePlan__c = productRatePlanCharge.zqu__ProductRatePlan__c;
        quoteRatePlan.zqu__ProductRatePlanZuoraId__c = [SELECT zqu__ZuoraId__c FROM zqu__ProductRatePlan__c WHERE id = :productRatePlanCharge.zqu__ProductRatePlan__c LIMIT 1].zqu__ZuoraId__c; // productRatePlanMap.get(charge.zqu__ProductRatePlan__c),
        quoteRatePlan.zqu__QuoteProductName__c = productRatePlanCharge.Name;
        
        if (doInsert)
        {
            insert quoteRatePlan;
        }
        
        return quoteRatePlan;
    }
    
    public static List<zqu__QuoteRatePlan__c> createQuoteRatePlans(Boolean doInsert, Id quoteId, List<zqu__ProductRatePlanCharge__c> productRatePlanCharges, List<zqu__QuoteAmendment__c> quoteAmendments)
    {
        List<zqu__QuoteRatePlan__c> quoteRatePlans = new List<zqu__QuoteRatePlan__c>();
        Integer index = 1;
        
        for (zqu__ProductRatePlanCharge__c productRatePlanCharge : productRatePlanCharges)
        {
            quoteRatePlans.add(createQuoteRatePlan(false, 'quoteRatePlanZuoraId'+index, quoteId, productRatePlanCharge, quoteAmendments[index-1]));
            ++index;
        }
        
        if (doInsert)
        {
            insert quoteRatePlans;
        }
        
        return quoteRatePlans;
    }
    public static zqu__QuoteRatePlanCharge__c createQuoteRatePlanChargeWithCatalog(Boolean doInsert, String name, String productName, Double quantity, Decimal discount, Decimal effectivePrice, String chargeType, String currencyIsoCode, String quoteId, Boolean isAmendment)
    {
        createCatalogResult catalog = createCatalog('TestProduct1', 'TestProductPlan1', 'TestProductCharge1');
        //(Boolean doInsert, String name, String quoteId, String type, String status, String currencyIsoCode)
        String amendmentType = isAmendment ? 'RemoveProduct' : 'NewProduct';
        zqu__QuoteAmendment__c quoteAmendment = createQuoteAmendment(true, 'Test Quote Amendment', quoteId, amendmentType, 'Draft', currencyIsoCode);	
        zqu__QuoteRatePlan__c quoteRatePlan = createQuoteRatePlan(true, 'TestQuoteRatePlan1', quoteId, catalog.productRatePlanCharge, quoteAmendment);
        
        return createQuoteRatePlanCharge(doInsert, name, productName, quantity, discount, effectivePrice, chargeType, currencyIsoCode, catalog.productRatePlanCharge, quoteRatePlan.Id, null);
    }
    
    public static zqu__QuoteRatePlanCharge__c createQuoteRatePlanCharge(Boolean doInsert, String name, String productName, Double quantity, Decimal discount, Decimal effectivePrice, String chargeType, String currencyIsoCode, zqu__ProductRatePlanCharge__c productCharge, String quoteRatePlanId, String shippingAddressId)
    {
        zqu__QuoteRatePlanCharge__c quoteRatePlanCharge = new zqu__QuoteRatePlanCharge__c(
            Name = name,
            zqu__ProductName__c = productName,
            zqu__Quantity__c = quantity,
            zqu__Discount__c = discount,
            zqu__EffectivePrice__c = effectivePrice,
            zqu__ChargeType__c = chargeType,
            zqu__Currency__c = currencyIsoCode,
            zqu__QuoteRatePlan__c = quoteRatePlanId,
            zqu__ProductRatePlanCharge__c = productCharge.Id,
            zqu__ProductRatePlanChargeZuoraId__c = productCharge.zqu__ZuoraId__c,
            //ShippingAddressId__c = (shippingAddressId != null) ? shippingAddressId : null,
            CurrencyIsoCode = currencyIsoCode,
            Estimated_Discount__c = 0,
            EstimatedQty__c = 0
        );
        
        if (doInsert)
        {
            insert quoteRatePlanCharge;
        }
        
        return quoteRatePlanCharge;
    }
    
    public class createCatalogResult 
    {
        public Id sProductId {get;set;}
        public Id sProductRatePlanId {get;set;}
        public Id sProductRatePlanChargeId {get;set;}
        public zqu__ProductRatePlan__c productRatePlan {get;set;}
        public zqu__ProductRatePlanCharge__c productRatePlanCharge {get;set;}
    }
    
    public void SetupPCVProducts()
    {
        List<Product2> products = new List<Product2> ();
        Product2 pcvProduct1 = new Product2();
        pcvProduct1.Name = 'PureVoice Directory Assistance';
        pcvProduct1.zqu__SKU__c = 'PV-TEMP-DIRECTORY-ASSISTANCE';
        pcvProduct1.Product_Line__c = 'Collaborate Pro, Communicate, Engage';
        pcvProduct1.zqu__Category__c = 'PureCloud Voice';
        pcvProduct1.Product_Category__c = 'PureCloud Voice';
        pcvProduct1.zqu__ZuoraId__c = '2c92c0f950fa765a0150fc71c2bc361d';
        pcvProduct1.Product_Subcategory__c = 'Standard';
        pcvProduct1.ProductShippable__c = 'No';
        pcvProduct1.CurrencyIsoCode = 'USD';
        products.add(pcvProduct1);
        
        Product2 pcvProduct2 = new Product2();
        pcvProduct2.Name = '911 National Emergency Call Center';
        pcvProduct2.zqu__SKU__c = 'PVR-170-NV-USNECC';
        pcvProduct2.Product_Line__c = 'Collaborate Pro, Communicate, Engage';
        pcvProduct2.zqu__Category__c = 'PureCloud Voice';
        pcvProduct2.Product_Category__c = 'PureCloud Voice';
        pcvProduct2.zqu__ZuoraId__c = '2c92c0f950fa765a0150fc71c2bc351d';
        pcvProduct2.Product_Subcategory__c = 'Standard';
        pcvProduct2.ProductShippable__c = 'No';
        pcvProduct2.CurrencyIsoCode = 'USD';
        products.add(pcvProduct2);
        
        insert products;
        
        List<zqu__ProductRatePlan__c> zplans = new List<zqu__ProductRatePlan__c> ();
        zqu__ProductRatePlan__c zplan1 = new zqu__ProductRatePlan__c();
        zplan1.zqu__Product__c = pcvProduct1.id;
        zplan1.zqu__ZuoraId__c = 'pcvplan1';
        zplan1.Name = pcvProduct1.Name;
        zplans.add(zplan1);
        
        zqu__ProductRatePlan__c zplan2 = new zqu__ProductRatePlan__c();
        zplan2.zqu__Product__c = pcvProduct2.id;
        zplan2.Name = pcvProduct2.Name;
        zplan2.zqu__ZuoraId__c = 'pcvplan2';
        zplans.add(zplan2);
        
        insert zplans;
        
        List<zqu__ProductRatePlanCharge__c> zratecharges = new List<zqu__ProductRatePlanCharge__c> ();
        zqu__ProductRatePlanCharge__c zratecharge1 = new zqu__ProductRatePlanCharge__c();
        zratecharge1.Name = pcvProduct1.Name;
        zratecharge1.zqu__AccountingCode__c = 'Accounts Receivable 1';
        zratecharge1.zqu__ListPrice__c = 10;
        zratecharge1.zqu__Model__c = 'Per Unit Pricing';
        zratecharge1.zqu__Type__c = 'Usage';
        zratecharge1.zqu__ZuoraId__c = 'ratecharge111';
        zratecharge1.zqu__ProductRatePlan__c = zplan1.id;
        zratecharge1.SKU__c = 'PV-TEMP-DIRECTORY-ASSISTANCE';
        
        zratecharges.add(zratecharge1);
        
        zqu__ProductRatePlanCharge__c zratecharge2 = new zqu__ProductRatePlanCharge__c();
        zratecharge2.Name = pcvProduct2.Name;
        zratecharge2.zqu__AccountingCode__c = 'Accounts Receivable';
        zratecharge2.zqu__ListPrice__c = 178;
        zratecharge2.zqu__Model__c = 'Per Unit Pricing';
        zratecharge2.zqu__Type__c = 'One-Time';
        zratecharge2.zqu__ZuoraId__c = 'ratecharge2222';
        zratecharge2.zqu__ProductRatePlan__c = zplan2.id;
        zratecharge2.SKU__c = 'PVR-170-NV-USNECC';
        zratecharges.add(zratecharge2);
        
        insert zratecharges;
        
        List<zqu__ProductRatePlanChargeTier__c> zratechargetiers = new List<zqu__ProductRatePlanChargeTier__c> ();
        zqu__ProductRatePlanChargeTier__c zratechargetier1 = new zqu__ProductRatePlanChargeTier__c();
        zratechargetier1.zqu__Currency__c = 'USD';
        zratechargetier1.zqu__Deleted__c = false;
        zratechargetier1.zqu__Price__c = 100;
        zratechargetier1.zqu__PriceFormat__c = 'Flat Fee';
        zratechargetier1.zqu__ProductRatePlanChargeId__c = zratecharge1.Id;
        zratechargetier1.zqu__Tier__c = 1;
        zratechargetier1.zqu__ZuoraId__c = '2c92c0f84c5100b6014c6ab62dfc1e85';
        zratechargetier1.zqu__ProductRatePlanCharge__c = zratecharge1.Id;
        zratechargetiers.add(zratechargetier1);
        
        zqu__ProductRatePlanChargeTier__c zratechargetier2 = new zqu__ProductRatePlanChargeTier__c();
        zratechargetier2.zqu__Currency__c = 'USD';
        zratechargetier2.zqu__Deleted__c = false;
        zratechargetier2.zqu__Price__c = 100;
        zratechargetier2.zqu__PriceFormat__c = 'Flat Fee';
        zratechargetier2.zqu__ProductRatePlanChargeId__c = zratecharge2.Id;
        zratechargetier2.zqu__Tier__c = 1;
        zratechargetier2.zqu__ZuoraId__c = '2c92c0f84c5100b6014c6ab62dfc1e83';
        zratechargetier2.zqu__ProductRatePlanCharge__c = zratecharge2.Id;
        zratechargetiers.add(zratechargetier2);
        
        insert zratechargetiers;
        
    }
    
    public void AddDummyPart()
    {
        List<zqu__QuoteRatePlanCharge__c> charges = new List<zqu__QuoteRatePlanCharge__c> ();
        zqu__QuoteRatePlanCharge__c dummyCharge = new zqu__QuoteRatePlanCharge__c();
        //dummyCharge.zqu__Quote__c = ZQuote.Id;
        dummyCharge.Name = 'PureCloud Voice';
        dummyCharge.CurrencyIsoCode = 'USD';
        dummyCharge.zqu__Quantity__c = 1;
        dummyCharge.EstimatedQty__c = 1;
        dummyCharge.zqu__ProductName__c = 'PureCloud Voice';
        dummyCharge.zqu__Discount__c = 10;
        dummyCharge.zqu__ChargeType__c = 'One-Time';
        dummyCharge.zqu__ProductRatePlanCharge__c = dummyRatecharge.Id;
        //dummyCharge.zqu__TimeProductAdded__c = '20150819T103845101Z';
        dummyCharge.zqu__Currency__c = 'USD';
        charges.add(dummyCharge);
        
        insert charges;
    }
    
    public void RemoveDummyPart()
    {
        List<zqu__QuoteRatePlanCharge__c> dummyCharge = [SELECT Id, Name,
                                                         zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c,
                                                         zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Name,
                                                         zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.zqu__Category__c
                                                         FROM zqu__QuoteRatePlanCharge__c
                                                         WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :zQuote.Id
                                                         and zqu__ProductRatePlanCharge__c = :dummyRatecharge.Id];
        
        ////System.debug('No of charges to delete: ' + dymmyCharge.size());
        ////System.debug('Name of charge to delete : ' + dymmyCharge[0].Name);
        delete dummyCharge;
    }
    
    public void AddRegularCharge()
    {
        List<zqu__QuoteRatePlanCharge__c> charges = new List<zqu__QuoteRatePlanCharge__c> ();
        zqu__QuoteRatePlanCharge__c charge = new zqu__QuoteRatePlanCharge__c();
        //charge.zqu__Quote__c = ZQuote.Id;
        charge.Name = 'charge 5';
        charge.CurrencyIsoCode = 'USD';
        charge.zqu__Quantity__c = 1;
        charge.EstimatedQty__c = 1;
        charge.zqu__ProductName__c = 'PureCloud Engage Outbound Dialer Enablement Package';
        charge.zqu__Discount__c = 0;
        charge.zqu__ChargeType__c = 'One-Time';
        charge.zqu__ProductRatePlanCharge__c = zratecharge5.Id;
        //charge.zqu__TimeProductAdded__c = '20150819T103845101Z';
        charge.zqu__Currency__c = 'USD';
        charges.add(charge);
        
        insert charges;
    }
    
    public void SetupZQuote()
    {
        SetupZQuote(false, false);
    }
    
    public void SetupZQuote(Boolean isAmendmentQuote)
    {
        SetupZQuote(isAmendmentQuote, false);
    }
    
    public void SetupZQuote(Boolean isAmendmentQuote, Boolean onlyDevOrg)
    {
        isAmendment = isAmendmentQuote;
        Date dStartDate = System.today().addDays(90);
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            Noah = UserFactory.CreateInternalUser('noah');
            insert new List<User> { Noah };
        }

		// Create List Custom Settings
		insert GeneralCustomSettingFactory.CreateZuoraCustomSettings();
        // create service token table:
        List<service_token_definition__c> tokenDefs = new List<service_token_definition__c>();
        service_token_definition__c tokendef = new service_token_definition__c();
        tokendef.Name = 'PS-170-PURE-SVBRONZE';
        tokendef.Part_Number__c = 'PS-170-PURE-SVBRONZE';
        tokendef.Service_Token_Count__c = 40;
        tokendef.Service_Token_Expire_Days__c = 365;
        tokendef.Support_Purchase_Count__c = 15;
        tokendef.Support_Purchase_Expire_Days__c = 365;
        tokendef.Support_Option__c = 'Bronze Support';
        tokenDefs.add(tokendef);
        
        tokendef = new service_token_definition__c();
        tokendef.Name = 'PS-170-PURE-SVSILVER';
        tokendef.Part_Number__c = 'PS-170-PURE-SVSILVER';
        tokendef.Service_Token_Count__c = 80;
        tokendef.Service_Token_Expire_Days__c = 365;
        tokendef.Support_Purchase_Count__c = 50;
        tokendef.Support_Purchase_Expire_Days__c = 365;
        tokendef.Support_Option__c = 'Silver Support';
        tokenDefs.add(tokendef);        
        
        insert tokendefs;

		// create monthly minimums
		List<PureCloud_Monthly_Minimum__c> mins = new List<PureCloud_Monthly_Minimum__c>();
		PureCloud_Monthly_Minimum__c min = new PureCloud_Monthly_Minimum__c();
		min.Monthly_Minimum__c = 2000;
		min.CurrencyIsoCode = 'USD';
		mins.add(min);

		insert mins;
        
        acctContext = new TestAccountContext();
        ZAccount = acctContext.PureCloudAcct1;
        ZContact = acctContext.purecloudContact1;
        
        ZOpportunity = OpportunityFactory.CreatePureCloudOpportunity('zOpportunity');
        ZOpportunity.OwnerId = Noah.Id;
        
        InternalPCOpp1 = OpportunityFactory.CreatePureCloudOpportunity('InternalPCOpp1');
        InternalPCOpp1.OwnerId = Noah.Id;
        
        ////System.debug('## PC Record Type Id - ' + CustomSettingsProvider.GetGeneralCustomSettingsVal('Opportunity_PCRecordTypeId'));
        //InternalPCOpp1.RecordTypeId = CustomSettingsProvider.GetGeneralCustomSettingsVal('Opportunity_PCRecordTypeId');
        InternalPCOpp1.ownerId = noah.id; // internal user
        InternalPCOpp1.AccountId = ZAccount.Id;
        InternalPCOpp1.StageName = 'Ready to Order';
        //InternalPCOpp1.Budgetary__c = false;
        InternalPCOpp1.Contact__c = ZContact.Id;
        
        insert new List<Opportunity> { ZOpportunity, InternalPCOpp1 };
            
        ZQuote = new zqu__Quote__c();
        ZQuote.zqu__Account__c = ZAccount.Id;
        ZQuote.zqu__SoldToContact__c = ZContact.Id;
        zQuote.Name = 'Test zQuote';
        //zQuote.Discount_Approval_Status__c = 'Not Required';
        zQuote.zqu__BillToContact__c = ZContact.Id;
        zQuote.zqu__PaymentTerm__c = 'Net 30';
        zQuote.zqu__Description__c = 'Test zQuote';
        zQuote.zqu__Opportunity__c = InternalPCOpp1.Id;
        zQuote.zqu__StartDate__c = dStartDate;
        //zQuote.zqu__Number__c = 'Q000108';
        zQuote.zqu__Status__c = 'New';
        zQuote.CurrencyIsoCode = 'USD';
        zQuote.zqu__Currency__c = 'USD';
        zQuote.Opportunity_Owner__c = UserInfo.getUserId();
        //ZQuote.docusign_signer__c = ZContact.Id;
        
        if (isAmendmentQuote) { 
            ZQuote.zqu__SubscriptionTermStartDate__c = date.today().addMonths(-3);
            ZQuote.zqu__Hidden_Subscription_Name__c = 'AmendedSubscription';
            ZQuote.zqu__SubscriptionType__c = 'Amend Subscription';
        }
        
        ZQuote2 = new zqu__Quote__c();
        ZQuote2.Name = 'Test zQuote';
        //zQuote2.Discount_Approval_Status__c = 'Not Required';
        zQuote2.zqu__PaymentTerm__c = 'Net 30';
        ZQuote2.zqu__Description__c = 'Test zQuote';
        ZQuote2.zqu__Opportunity__c = InternalPCOpp1.Id;
        zQuote2.zqu__StartDate__c = dStartDate;
        //zQuote.zqu__Number__c = 'Q000108';
        ZQuote2.zqu__Status__c = 'New';
        ZQuote2.CurrencyIsoCode = 'USD';
        ZQuote2.zqu__Currency__c = 'USD';
        ZQuote2.Opportunity_Owner__c = UserInfo.getUserId();
        //ZQuote2.docusign_signer__c = ZContact.Id;
        
        ZQuoteLicenseOnly = new zqu__Quote__c();
        ZQuoteLicenseOnly.Name = 'Test zQuote license only';
        //ZQuoteLicenseOnly.Discount_Approval_Status__c = 'Not Required';
        ZQuoteLicenseOnly.zqu__BillToContact__c = ZContact.Id;
        ZQuoteLicenseOnly.zqu__PaymentTerm__c = 'Net 30';
        ZQuoteLicenseOnly.zqu__Description__c = 'Test zQuote';
        ZQuoteLicenseOnly.zqu__Opportunity__c = InternalPCOpp1.Id;
        ZQuoteLicenseOnly.zqu__StartDate__c = dStartDate;
        //ZQuoteLicenseOnly.zqu__Number__c = 'Q000109';
        ZQuoteLicenseOnly.zqu__Status__c = 'New';
        ZQuoteLicenseOnly.CurrencyIsoCode = 'USD';
        ZQuoteLicenseOnly.zqu__Currency__c = 'USD';
        ZQuoteLicenseOnly.Opportunity_Owner__c = UserInfo.getUserId();
        //ZQuoteLicenseOnly.docusign_signer__c = ZContact.Id;
        
        insert new List<zqu__Quote__c> { ZQuote, ZQuote2, ZQuoteLicenseOnly };
            
        if (!onlyDevOrg)
        {
            List<Product2> products = new List<Product2> ();
            Product2 product1 = new Product2();
            product1.Name = 'PureCloud Collaborate Test License';
            product1.zqu__SKU__c = 'PC-170-NV-USCLP_14e303d9561';
            product1.Product_Line__c = 'Collaborate Pro, Communicate, Engage';
            product1.zqu__Category__c = 'Licenses';
            product1.Product_Category__c = 'Licenses';
            product1.zqu__ZuoraId__c = '2c92c0f94d2ccdf3014d31dd8ef1251a';
            product1.Product_Subcategory__c = 'Standard';
            product1.ProductShippable__c = 'No';
            products.add(product1);
            
            Product2 product2 = new Product2();
            product2.Name = 'GN Netcom Jabra Pro 920 Wireless Headset - North America';
            product2.zqu__SKU__c = 'TH-556-HDSGNP920';
            product2.Product_Line__c = 'Communicate, Engage';
            product2.zqu__Category__c = 'Hardware';
            product2.Product_Category__c = 'Hardware';
            product2.zqu__ZuoraId__c = '2c92c0f84e2efd45014e304cb41d4fdd';
            product2.Product_Subcategory__c = 'Phones';
            product2.ProductShippable__c = 'Yes';
            products.add(product2);
            
            Product2 product3 = new Product2();
            product3.Name = 'PureCloud Engage Outbound Dialer Enablement Package';
            product3.zqu__SKU__c = 'PS-170-PURE-SVEDE';
            product3.Product_Line__c = 'Engage';
            product3.zqu__Category__c = 'Services';
            product3.Product_Category__c = 'Services';
            product3.zqu__ZuoraId__c = '2c92c0f84d658e94014d6830912c2864';
            product3.Product_Subcategory__c = 'Standard';
            product3.ProductShippable__c = 'No';
            products.add(product3);
            
            Product2 product4 = new Product2();
            product4.Name = 'Universal Power Supply for IP 5000 - North America';
            product4.zqu__SKU__c = 'TH-508-ACIP50PS';
            product4.Product_Line__c = 'Communicate, Engage';
            product4.zqu__ZuoraId__c = '2c92c0f94e2f0c36014e304b7d426499';
            product4.zqu__Category__c = 'Hardware';
            product4.Product_Category__c = 'Hardware';
            product4.Product_Subcategory__c = 'Power Cords';
            product4.ProductShippable__c = 'Yes';
            products.add(product4);
            
            Product2 product5 = new Product2();
            product5.Name = 'Engage CRM Screen Pop Enablement Package';
            product5.zqu__SKU__c = 'PS-000-PURE-ECSPEP_14d6843bb03';
            product5.Product_Line__c = 'Communicate, Engage';
            product5.zqu__ZuoraId__c = '2c92c0f94e2f0c36014e7d4264944';
            product5.zqu__Category__c = 'Services';
            product5.Product_Category__c = 'Services';
            product5.Product_Subcategory__c = 'Power Cords';
            product5.ProductShippable__c = 'No';
            products.add(product5);
            
            Product2 product6 = new Product2();
            product6.Name = 'PureCloud Bronze Subscription Service';
            product6.zqu__SKU__c = 'PS-170-PURE-SVBRONZE';
            product6.Product_Line__c = 'Collaborate Pro, Communicate, Engage';
            product6.zqu__ZuoraId__c = '2c92c0f950dcbc9c0150dd80b0bronze';
            product6.zqu__Category__c = 'Services';
            product6.Product_Category__c = 'Services';
            product6.Product_Subcategory__c = 'Tokens';
            product6.ProductShippable__c = 'No';
            products.add(product6);
            
            Product2 dummyProduct = new Product2();
            dummyProduct.Name = 'PureCloud Voice';
            dummyProduct.zqu__SKU__c = DummyPartNumber;
            dummyProduct.Product_Line__c = 'Communicate, Engage';
            dummyProduct.zqu__ZuoraId__c = '2c92c0f950dcbc9c0150dd80b0690a6d';
            dummyProduct.zqu__Category__c = 'DevOrg';
            dummyProduct.Product_Category__c = 'DevOrg';
            dummyProduct.Product_Subcategory__c = 'Phones';
            dummyProduct.ProductShippable__c = 'No';
            dummyProduct.CurrencyIsoCode = 'USD';
            products.add(dummyProduct);
            
            Product2 collaborateProProduct = new Product2();
            collaborateProProduct.Name = 'PureCloud Collaborate Pro User';
            collaborateProProduct.zqu__SKU__c = 'PC-170-NV-USCLP';
            collaborateProProduct.Product_Line__c = 'Collaborate Pro, Communicate, Engage';
            collaborateProProduct.zqu__ZuoraId__c = '2c92c0f950dcbc9c0150dd80b0690a6e';
            collaborateProProduct.zqu__Category__c = 'Licenses';
            collaborateProProduct.Product_Category__c = 'Licenses';
            collaborateProProduct.Product_Subcategory__c = 'Standard';
            collaborateProProduct.ProductShippable__c = 'No';
            collaborateProProduct.CurrencyIsoCode = 'USD';
            products.add(collaborateProProduct);
            
            Product2 communicateProduct = new Product2();
            communicateProduct.Name = 'PureCloud Communicate User';
            communicateProduct.zqu__SKU__c = 'PC-170-NV-USCMS';
            communicateProduct.Product_Line__c = 'Collaborate Pro, Communicate, Engage';
            communicateProduct.zqu__ZuoraId__c = '2c92c0f9508hau5c0150dd80b0690a6e';
            communicateProduct.zqu__Category__c = 'Licenses';
            communicateProduct.Product_Category__c = 'Licenses';
            communicateProduct.Product_Subcategory__c = 'Communicate';
            communicateProduct.ProductShippable__c = 'No';
            communicateProduct.CurrencyIsoCode = 'USD';
            products.add(communicateProduct);
            
            ////System.debug('## Products being inserted - ' + products);
            insert products;
            
            //List<zqu__ZProduct__c> zProducts = new List<zqu__ZProduct__c>([SELECT Id from zqu__ZProduct__c]);
            
            List<zqu__ProductRatePlan__c> zplans = new List<zqu__ProductRatePlan__c> ();
            zqu__ProductRatePlan__c zplan1 = new zqu__ProductRatePlan__c();
            zplan1.zqu__Product__c = product1.id;
            zplan1.zqu__ZuoraId__c = 'plan1';
            //zplan1.zqu__ZProduct__c = zProducts[0].id;
            zplan1.Name = product1.Name;
            zplans.add(zplan1);
            
            zqu__ProductRatePlan__c zplan2 = new zqu__ProductRatePlan__c();
            zplan2.zqu__Product__c = product2.id;
            zplan2.Name = product2.Name;
            zplan2.zqu__ZuoraId__c = 'plan2';
            //zplan2.zqu__ZProduct__c = zProducts[1].id;
            zplans.add(zplan2);
            
            zqu__ProductRatePlan__c zplan3 = new zqu__ProductRatePlan__c();
            zplan3.zqu__Product__c = product3.id;
            zplan3.Name = product3.Name;
            zplan3.zqu__ZuoraId__c = 'plan3';
            //zplan3.zqu__ZProduct__c = zProducts[2].id;
            zplans.add(zplan3);
            
            zqu__ProductRatePlan__c zplan4 = new zqu__ProductRatePlan__c();
            zplan4.zqu__Product__c = product4.id;
            zplan4.Name = product4.Name;
            zplan4.zqu__ZuoraId__c = 'plan4';
            //zplan4.zqu__ZProduct__c = zProducts[3].id;
            zplans.add(zplan4);
            
            zqu__ProductRatePlan__c zplan5 = new zqu__ProductRatePlan__c();
            zplan5.zqu__Product__c = product5.id;
            zplan5.Name = product5.Name;
            zplan5.zqu__ZuoraId__c = 'plan5';
            //zplan5.zqu__ZProduct__c = zProducts[4].id;
            zplans.add(zplan5);
            
            zqu__ProductRatePlan__c zplan6 = new zqu__ProductRatePlan__c();
            zplan6.zqu__Product__c = product6.id;
            zplan6.Name = product6.Name;
            zplan6.zqu__ZuoraId__c = 'plan6';
            //zplan6.zqu__ZProduct__c = zProducts[5].id;
            zplans.add(zplan6);
            
            zqu__ProductRatePlan__c dummyPlan = new zqu__ProductRatePlan__c();
            dummyPlan.zqu__Product__c = dummyProduct.id;
            dummyPlan.Name = dummyProduct.Name;
            dummyPlan.zqu__ZuoraId__c = 'dummyPlan';
            //dummyPlan.zqu__ZProduct__c = zProducts[1].id;
            zplans.add(dummyPlan);
            
            zqu__ProductRatePlan__c collaborateProPlan = new zqu__ProductRatePlan__c();
            collaborateProPlan.zqu__Product__c = collaborateProProduct.id;
            collaborateProPlan.Name = collaborateProProduct.Name;
            collaborateProPlan.zqu__ZuoraId__c = 'collaborateProPlan';
            //collaborateProPlan.zqu__ZProduct__c = zProducts[1].id;
            zplans.add(collaborateProPlan);
            
            insert zplans;
            
            Map<String, String> productRatePlanMap = new Map<String, String>();
            
            for (zqu__ProductRatePlan__c zplan : zplans)
            {
                productRatePlanMap.put(zplan.id, zplan.zqu__ZuoraId__c);
            }
            
            //System.debug('!! Rate Plans being inserted - ' + zplans);
            List<zqu__ProductRatePlanCharge__c> zratecharges = new List<zqu__ProductRatePlanCharge__c> ();
            zqu__ProductRatePlanCharge__c zratecharge1 = new zqu__ProductRatePlanCharge__c();
            zratecharge1.Name = product1.Name;
            zratecharge1.zqu__AccountingCode__c = 'Accounts Receivable';
            zratecharge1.zqu__ListPrice__c = 10;
            zratecharge1.zqu__Model__c = 'Per Unit Pricing';
            zratecharge1.zqu__Type__c = 'Usage';
            //zratecharge1.zqu__ZuoraId__c = 'ratecharge1';
            zratecharge1.zqu__ProductRatePlan__c = zplan1.id;
            zratecharge1.SKU__c = 'test-sku-1';
            zratecharge1.zqu__ZuoraId__c = '34567890123456789012345678901231';
            zratecharges.add(zratecharge1);
            
            zqu__ProductRatePlanCharge__c zratecharge2 = new zqu__ProductRatePlanCharge__c();
            zratecharge2.Name = product2.Name;
            zratecharge2.zqu__AccountingCode__c = 'Accounts Receivable';
            zratecharge2.zqu__ListPrice__c = 178;
            zratecharge2.zqu__Model__c = 'Per Unit Pricing';
            zratecharge2.zqu__Type__c = 'One-Time';
            //zratecharge2.zqu__ZuoraId__c = 'ratecharge2';
            zratecharge2.zqu__ProductRatePlan__c = zplan2.id;
            zratecharge2.SKU__c = 'test-sku-2';
            zratecharge2.zqu__ZuoraId__c = '34567890123456789012345678901232';
            zratecharges.add(zratecharge2);
            
            zqu__ProductRatePlanCharge__c zratecharge3 = new zqu__ProductRatePlanCharge__c();
            zratecharge3.Name = product3.Name;
            zratecharge3.zqu__AccountingCode__c = 'Accounts Receivable';
            zratecharge3.zqu__ListPrice__c = 2500;
            zratecharge3.zqu__Model__c = 'Flat Fee Pricing';
            zratecharge3.zqu__Type__c = 'One-Time';
            //zratecharge3.zqu__ZuoraId__c = 'ratecharge3';
            zratecharge3.zqu__ProductRatePlan__c = zplan3.id;
            zratecharge3.SKU__c = 'test-sku-3';
            zratecharge3.zqu__ZuoraId__c = '34567890123456789012345678901233';
            zratecharges.add(zratecharge3);
            
            zqu__ProductRatePlanCharge__c zratecharge4 = new zqu__ProductRatePlanCharge__c();
            zratecharge4.Name = product4.Name;
            zratecharge4.zqu__AccountingCode__c = 'Accounts Receivable';
            zratecharge4.zqu__ListPrice__c = 97.25;
            zratecharge4.zqu__Model__c = 'Per Unit Pricing';
            zratecharge4.zqu__Type__c = 'One-Time';
            //zratecharge4.zqu__ZuoraId__c = 'ratecharge4';
            zratecharge4.zqu__ProductRatePlan__c = zplan4.id;
            zratecharge4.SKU__c = 'test-sku-4';
            zratecharge4.zqu__ZuoraId__c = '34567890123456789012345678901234';
            zratecharges.add(zratecharge4);
            
            zratecharge5 = new zqu__ProductRatePlanCharge__c();
            zratecharge5.Name = product5.Name;
            zratecharge5.zqu__AccountingCode__c = 'Accounts Receivable';
            zratecharge5.zqu__ListPrice__c = 97.25;
            zratecharge5.zqu__Model__c = 'Per Unit Pricing';
            zratecharge5.zqu__Type__c = 'One-Time';
            //zratecharge5.zqu__ZuoraId__c = 'ratecharge5';
            zratecharge5.zqu__ProductRatePlan__c = zplan5.id;
            zratecharge5.SKU__c = 'test-sku-5';
            zratecharge5.zqu__ZuoraId__c = '34567890123456789012345678901235';
            zratecharges.add(zratecharge5);
            
            zqu__ProductRatePlanCharge__c zratecharge6 = new zqu__ProductRatePlanCharge__c();
            zratecharge6.Name = product6.Name;
            zratecharge6.zqu__AccountingCode__c = 'Accounts Receivable';
            zratecharge6.zqu__ListPrice__c = 0.00;
            zratecharge6.zqu__Model__c = 'Per Unit Pricing';
            zratecharge6.zqu__Type__c = 'Recurring';
            //zratecharge6.zqu__ZuoraId__c = 'ratecharge6';
            zratecharge6.zqu__ProductRatePlan__c = zplan6.id;
            zratecharge6.SKU__c = 'PS-170-PURE-SVBRONZE-R2';
            zratecharge6.zqu__ZuoraId__c = '34567890123456789012345678901236';
            zratecharges.add(zratecharge6);
            
            dummyRatecharge = new zqu__ProductRatePlanCharge__c();
            dummyRatecharge.Name = dummyProduct.Name;
            dummyRatecharge.zqu__AccountingCode__c = 'Accounts Receivable';
            dummyRatecharge.zqu__ListPrice__c = 97.25;
            dummyRatecharge.zqu__Model__c = 'Per Unit Pricing';
            dummyRatecharge.zqu__Type__c = 'One-Time';
            //dummyRatecharge.zqu__ZuoraId__c = 'dummyRatecharge';
            dummyRatecharge.zqu__ProductRatePlan__c = dummyPlan.id;
            dummyRatecharge.SKU__c = 'test-sku-dummy';
            dummyRatecharge.zqu__ZuoraId__c = '34567890123456789012345678901237';
            zratecharges.add(dummyRatecharge);
            
            zqu__ProductRatePlanCharge__c collaborateProRateChargeAnnual = new zqu__ProductRatePlanCharge__c();
            collaborateProRateChargeAnnual.Name = collaborateProProduct.Name;
            collaborateProRateChargeAnnual.zqu__AccountingCode__c = 'Accounts Receivable';
            collaborateProRateChargeAnnual.zqu__ListPrice__c = 9.99;
            collaborateProRateChargeAnnual.zqu__Model__c = 'Per Unit Pricing';
            collaborateProRateChargeAnnual.zqu__Type__c = 'Recurring';
            collaborateProRateChargeAnnual.zqu__RecurringPeriod__c = 'Annual';
            //collaborateProRatecharge.zqu__ZuoraId__c = 'collaborateProRatecharge';
            collaborateProRateChargeAnnual.zqu__ProductRatePlan__c = collaborateProPlan.id;
            collaborateProRateChargeAnnual.SKU__c = 'PC-170-NV-USCLP-C1';
            collaborateProRateChargeAnnual.zqu__ZuoraId__c = '34567890123456789012345678901238';
            zratecharges.add(collaborateProRateChargeAnnual);

            zqu__ProductRatePlanCharge__c collaborateProRateChargeUsage = new zqu__ProductRatePlanCharge__c();
            collaborateProRateChargeUsage.Name = collaborateProProduct.Name;
            collaborateProRateChargeUsage.zqu__AccountingCode__c = 'Accounts Receivable';
            collaborateProRateChargeUsage.zqu__ListPrice__c = 9.99;
            collaborateProRateChargeUsage.zqu__Model__c = 'Per Unit Pricing';
            collaborateProRateChargeUsage.zqu__Type__c = 'Usage';
            collaborateProRateChargeUsage.zqu__RecurringPeriod__c = 'Month';
            //collaborateProRatecharge.zqu__ZuoraId__c = 'collaborateProRatecharge';
            collaborateProRateChargeUsage.zqu__ProductRatePlan__c = collaborateProPlan.id;
            collaborateProRateChargeUsage.SKU__c = 'PC-170-NV-USCLP-C1';
            collaborateProRateChargeUsage.zqu__ZuoraId__c = '34567890123456789012345678901239';
            zratecharges.add(collaborateProRateChargeUsage);
            
            ////System.debug('## Rate Plan Charges being inserted - ' + zratecharges);
            insert zratecharges;
            
            List<zqu__ProductRatePlanCharge__c> productRatePlanCharges = new List<zqu__ProductRatePlanCharge__c> {
                    zratecharge1,
                    zrateCharge2,
                    zrateCharge3,
                    zrateCharge4,
                    zrateCharge5,
                    zrateCharge6,
                    collaborateProRateChargeAnnual,
                    collaborateProRateChargeUsage
                    };
                        
                        // Insert the quote amendments.
                        List<zqu__QuoteAmendment__c> quoteAmendments = new List<zqu__QuoteAmendment__c> ();
            
            for (zqu__ProductRatePlanCharge__c charge : productRatePlanCharges) {
                quoteAmendments.add(new zqu__QuoteAmendment__c(
                    Name = charge.Name,
                    CurrencyIsoCode = charge.CurrencyIsoCode,
                    zqu__Quote__c = ZQuote.Id,
                    zqu__DeltaTCV__c = 0,
                    zqu__Description__c = 'New Product',
                    zqu__Status__c = 'Draft',
                    zqu__Type__c = isAmendmentQuote ? 'RemoveProduct' : 'NewProduct'
                ));
            }
            insert quoteAmendments;
            
            // Insert the quote rate plans.
            List<zqu__QuoteRatePlan__c> quoteRatePlans = new List<zqu__QuoteRatePlan__c> ();
            integer index = 0;
            for (zqu__ProductRatePlanCharge__c charge : productRatePlanCharges) 
            {
                quoteRatePlans.add(new zqu__QuoteRatePlan__c(
                    Name = charge.Name,
                    CurrencyIsoCode = charge.CurrencyIsoCode,
                    //zqu__QuoteAmendment__c = quoteAmendments.get(index).Id,
                    zqu__AmendmentType__c = isAmendmentQuote ? 'RemoveProduct' : 'NewProduct',
                    //zqu__ProductRatePlanZuoraId__c = 'productRatePlanZuoraId' + index,
                    zqu__Quote__c = ZQuote.Id,
                    zqu__QuoteRatePlanZuoraId__c = 'quoteRatePlanZuoraId' + index,
                    zqu__ProductRatePlan__c = charge.zqu__ProductRatePlan__c,
                    zqu__ProductRatePlanZuoraId__c = productRatePlanMap.get(charge.zqu__ProductRatePlan__c),
                    zqu__QuoteAmendment__c = quoteAmendments[index].id,
                    zqu__QuoteProductName__c = charge.Name
                ));
                index++;
            }
            insert quoteRatePlans;
            
            // Quote Charges
            if (isAmendmentQuote) 
            {
                // Insert the quote rate plans charges.
                List<zqu__QuoteRatePlanCharge__c> quoteRatePlanCharges = new List<zqu__QuoteRatePlanCharge__c> ();
                index = 0;
                for (zqu__ProductRatePlanCharge__c charge : productRatePlanCharges) {
                    quoteRatePlanCharges.add(new zqu__QuoteRatePlanCharge__c(
                        Name = charge.Name,
                        zqu__QuoteRatePlan__c = quoteRatePlans.get(index).Id,
                        zqu__Apply_Discount_To_One_Time_Charges__c = false,
                        zqu__Apply_Discount_To_Recurring_Charges__c = false,
                        zqu__Apply_Discount_To_Usage_Charges__c = false,
                        zqu__Currency__c = charge.CurrencyIsoCode,
                        zqu__Discount__c = 0,
                        zqu__EffectivePrice__c = charge.zqu__ListPrice__c,
                        zqu__Quantity__c = index,
                        zqu__ChargeType__c = charge.zqu__Type__c,
                        zqu__ProductRatePlanChargeZuoraId__c = 'ratecharge' + (index + 1)
                        //ShippingAddressId__c = acctContext.Address3.Id
                    ));
                    index++;
                }
                insert quoteRatePlanCharges;
                
            } 
            else 
            {
                List<zqu__QuoteRatePlanCharge__c> charges = new List<zqu__QuoteRatePlanCharge__c> ();
                
                //ZQuote charges
                zqu__QuoteRatePlanCharge__c charge = new zqu__QuoteRatePlanCharge__c();
                charge.zqu__QuoteRatePlan__c = quoteRatePlans[0].id;
                //charge.zqu__Quote__c = ZQuote.Id;
                charge.Name = 'charge 1';
                charge.CurrencyIsoCode = 'USD';
                charge.zqu__Quantity__c = 1;
                charge.EstimatedQty__c = 1;
                charge.zqu__ProductName__c = 'PureCloud Test User License';
                charge.zqu__Discount__c = 0;
                charge.zqu__EffectivePrice__c = 9;
                charge.zqu__ChargeType__c = 'Usage';
                charge.zqu__ProductRatePlanCharge__c = zratecharge1.Id;
                charge.zqu__ProductRatePlanChargeZuoraId__c = zratecharge1.zqu__ZuoraId__c;
                //charge.zqu__TimeProductAdded__c = '20150819T103845101Z';
                charge.zqu__Currency__c = 'USD';
                charge.Estimated_Discount__c = 0;
                charge.EstimatedQty__c = 1;
                
                charges.add(charge);
                
                zQuoteLicenseCharge = new zqu__QuoteRatePlanCharge__c();
                zQuoteLicenseCharge.zqu__QuoteRatePlan__c = quoteRatePlans[5].id;
                //zQuoteLicenseCharge.zqu__Quote__c = ZQuote.Id;
                zQuoteLicenseCharge.Name = 'collaborate Pro User Annual';
                zQuoteLicenseCharge.CurrencyIsoCode = 'USD';
                zQuoteLicenseCharge.zqu__Quantity__c = 50;
                zQuoteLicenseCharge.EstimatedQty__c = 50;
                zQuoteLicenseCharge.zqu__EffectivePrice__c = 9.99;
                zQuoteLicenseCharge.zqu__ProductName__c = 'PureCloud Collaborate Pro User';
                zQuoteLicenseCharge.zqu__Discount__c = 10;
                zQuoteLicenseCharge.zqu__Model__c = 'Per Unit Pricing';
                zQuoteLicenseCharge.zqu__ChargeType__c = 'Recurring';
                zQuoteLicenseCharge.zqu__ProductRatePlanCharge__c = collaborateProRateChargeAnnual.Id;
                zQuoteLicenseCharge.zqu__ProductRatePlanChargeZuoraId__c = collaborateProRateChargeAnnual.zqu__ZuoraId__c;
                //zQuoteLicenseCharge.zqu__TimeProductAdded__c = '20150819T103845101Z';
                zQuoteLicenseCharge.zqu__Currency__c = 'USD';
                zQuoteLicenseCharge.Estimated_Discount__c = 0;
                zQuoteLicenseCharge.EstimatedQty__c = 50;
                charges.add(zQuoteLicenseCharge);
                
                zQuoteTokenCharge = new zqu__QuoteRatePlanCharge__c();
                zQuoteTokenCharge.zqu__QuoteRatePlan__c = quoteRatePlans[6].id;
                //zQuoteTokenCharge.zqu__Quote__c = ZQuote.Id;
                zQuoteTokenCharge.Name = 'PureCloud Bronze Subscription Service';
                zQuoteTokenCharge.CurrencyIsoCode = 'USD';
                zQuoteTokenCharge.zqu__Quantity__c = 1;
                zQuoteTokenCharge.EstimatedQty__c = 1;
                zQuoteTokenCharge.zqu__EffectivePrice__c = 0.00;
                zQuoteTokenCharge.zqu__ProductName__c = 'PureCloud Bronze Subscription Service';
                zQuoteTokenCharge.zqu__Discount__c = 0;
                zQuoteTokenCharge.zqu__Model__c = 'Per Unit Pricing';
                zQuoteTokenCharge.zqu__ChargeType__c = 'Recurring';
                zQuoteTokenCharge.zqu__ProductRatePlanCharge__c = zratecharge6.Id;
                zQuoteTokenCharge.zqu__ProductRatePlanChargeZuoraId__c = zratecharge6.zqu__ZuoraId__c;
                //zQuoteTokenCharge.zqu__TimeProductAdded__c = '20150819T103845101Z';
                zQuoteTokenCharge.zqu__Currency__c = 'USD';
                zQuoteTokenCharge.Estimated_Discount__c = 0;
                zQuoteTokenCharge.EstimatedQty__c = 50;
                charges.add(zQuoteTokenCharge);
                
                zQuoteOverageCharge = new zqu__QuoteRatePlanCharge__c();
                zQuoteOverageCharge.zqu__QuoteRatePlan__c = quoteRatePlans[5].id;
                //zQuoteOverageCharge.zqu__Quote__c = ZQuote.Id;
                zQuoteOverageCharge.Name = 'collaborate Pro User Usage';
                zQuoteOverageCharge.CurrencyIsoCode = 'USD';
                zQuoteOverageCharge.zqu__EffectivePrice__c = 9.99;
                zQuoteOverageCharge.zqu__ProductName__c = 'PureCloud Collaborate Pro User';
                zQuoteOverageCharge.zqu__Discount__c = 10;
                zQuoteOverageCharge.zqu__Model__c = 'Overage Pricing';
                zQuoteOverageCharge.zqu__ChargeType__c = 'Usage';
                zQuoteOverageCharge.zqu__ProductRatePlanCharge__c = collaborateProRateChargeUsage.Id;
                zQuoteOverageCharge.zqu__ProductRatePlanChargeZuoraId__c = collaborateProRateChargeUsage.zqu__ZuoraId__c;
                //zQuoteOverageCharge.zqu__TimeProductAdded__c = '20150819T103845101Z';
                zQuoteOverageCharge.zqu__Currency__c = 'USD';
                zQuoteOverageCharge.Estimated_Discount__c = 0;
                zQuoteOverageCharge.EstimatedQty__c = 1;
                charges.add(zQuoteOverageCharge);
                
                charge = new zqu__QuoteRatePlanCharge__c();
                charge.zqu__QuoteRatePlan__c = quoteRatePlans[1].id;
                //charge.zqu__Quote__c = ZQuote.Id;
                charge.Name = 'charge 2';
                charge.CurrencyIsoCode = 'USD';
                charge.zqu__Quantity__c = 1;
                charge.EstimatedQty__c = 1;
                charge.zqu__EffectivePrice__c = 250;
                charge.zqu__ProductName__c = 'GN Netcom Jabra Pro 920 Wireless Headset - North America';
                charge.zqu__Discount__c = 25;
                charge.zqu__ChargeType__c = 'One-Time';
                charge.zqu__ProductRatePlanCharge__c = zratecharge2.Id;
                charge.zqu__ProductRatePlanChargeZuoraId__c = zratecharge2.zqu__ZuoraId__c;
                //charge.ShippingAddressId__c = acctContext.Address3.Id;
                //charge.zqu__TimeProductAdded__c = '20150819T103845101Z';
                charge.zqu__Currency__c = 'USD';
                charge.Estimated_Discount__c = 0;
                charge.EstimatedQty__c = 1;
                charges.add(charge);
                
                charge = new zqu__QuoteRatePlanCharge__c();
                charge.zqu__QuoteRatePlan__c = quoteRatePlans[2].id;
                //charge.zqu__Quote__c = ZQuote.Id;
                charge.Name = 'charge 3';
                charge.CurrencyIsoCode = 'USD';
                charge.zqu__EffectivePrice__c = 1250;
                charge.zqu__Quantity__c = 1;
                charge.EstimatedQty__c = 1;
                charge.zqu__ProductName__c = 'PureCloud Engage Outbound Dialer Enablement Package';
                charge.zqu__Discount__c = 0;
                charge.zqu__ChargeType__c = 'One-Time';
                charge.zqu__ProductRatePlanCharge__c = zratecharge3.Id;
                charge.zqu__ProductRatePlanChargeZuoraId__c = zratecharge3.zqu__ZuoraId__c;
                //charge.zqu__TimeProductAdded__c = '20150819T103845101Z';
                charge.zqu__Currency__c = 'USD';
                charge.Estimated_Discount__c = 0;
                charge.EstimatedQty__c = 1;
                charges.add(charge);
                
                charge = new zqu__QuoteRatePlanCharge__c();
                charge.zqu__QuoteRatePlan__c = quoteRatePlans[3].id;
                //charge.zqu__Quote__c = ZQuote.Id;
                charge.Name = 'charge 4';
                charge.CurrencyIsoCode = 'USD';
                charge.zqu__EffectivePrice__c = 55;
                charge.zqu__Quantity__c = 3;
                charge.EstimatedQty__c = 3;
                charge.zqu__ProductName__c = 'Universal Power Supply for IP 5000 - North America';
                charge.zqu__Discount__c = 10;
                charge.zqu__ChargeType__c = 'One-Time';
                charge.zqu__ProductRatePlanCharge__c = zratecharge4.Id;
                charge.zqu__ProductRatePlanChargeZuoraId__c = zratecharge4.zqu__ZuoraId__c;
                //charge.ShippingAddressId__c = acctContext.Address2.Id;
                //charge.zqu__TimeProductAdded__c = '20150819T103845101Z';
                charge.zqu__Currency__c = 'USD';
                charge.Estimated_Discount__c = 0;
                charge.EstimatedQty__c = 3;
                charges.add(charge);
                
                
                //ZQuote2 charges
                charge = new zqu__QuoteRatePlanCharge__c();
                charge.zqu__QuoteRatePlan__c = quoteRatePlans[6].id;
                //charge.zqu__Quote__c = ZQuote2.Id;
                charge.Name = 'collaborate Pro';
                charge.CurrencyIsoCode = 'USD';
                charge.zqu__EffectivePrice__c = 9.99;
                charge.zqu__Quantity__c = 50;
                charge.EstimatedQty__c = 50;
                charge.zqu__ProductName__c = 'PureCloud Collaborate Pro User';
                charge.zqu__Discount__c = 10;
                //charge.Product_Category__c
                charge.zqu__ChargeType__c = 'Usage';
                charge.zqu__ProductRatePlanCharge__c = collaborateProRateChargeUsage.Id;
                charge.zqu__ProductRatePlanChargeZuoraId__c = collaborateProRateChargeUsage.zqu__ZuoraId__c;
                //charge.zqu__TimeProductAdded__c = '20150819T103845101Z';
                charge.zqu__Currency__c = 'USD';
                charge.Estimated_Discount__c = 0;
                charge.EstimatedQty__c = 50;
                charges.add(charge);
                
                charge = new zqu__QuoteRatePlanCharge__c();
                charge.zqu__QuoteRatePlan__c = quoteRatePlans[3].id;
                //charge.zqu__Quote__c = ZQuote2.Id;
                charge.Name = 'charge 4';
                charge.CurrencyIsoCode = 'USD';
                charge.zqu__Quantity__c = 3;
                charge.EstimatedQty__c = 3;
                charge.zqu__EffectivePrice__c = 650;
                charge.zqu__ProductName__c = 'Universal Power Supply for IP 5000 - North America';
                charge.zqu__Discount__c = 10;
                charge.zqu__ChargeType__c = 'One-Time';
                charge.zqu__ProductRatePlanCharge__c = zratecharge4.Id;
                charge.zqu__ProductRatePlanChargeZuoraId__c = zratecharge4.zqu__ZuoraId__c;
                //charge.ShippingAddressId__c = acctContext.Address3.Id;
                //charge.zqu__TimeProductAdded__c = '20150819T103845101Z';
                charge.zqu__Currency__c = 'USD';
                charge.Estimated_Discount__c = 0;
                charge.EstimatedQty__c = 3;
                charges.add(charge);
                
                charge = new zqu__QuoteRatePlanCharge__c();
                charge.zqu__QuoteRatePlan__c = quoteRatePlans[0].id;
                //charge.zqu__Quote__c = ZQuoteLicenseOnly.Id;
                charge.Name = 'charge 1';
                charge.CurrencyIsoCode = 'USD';
                charge.zqu__Quantity__c = 1;
                charge.EstimatedQty__c = 1;
                charge.zqu__ProductName__c = 'PureCloud Test User License';
                charge.zqu__Discount__c = 0;
                charge.zqu__EffectivePrice__c = 9;
                charge.zqu__ChargeType__c = 'Usage';
                charge.zqu__ProductRatePlanCharge__c = zratecharge1.Id;
                charge.zqu__ProductRatePlanChargeZuoraId__c = zratecharge1.zqu__ZuoraId__c;
                //charge.zqu__TimeProductAdded__c = '20150819T103845101Z';
                charge.zqu__Currency__c = 'USD';
                charge.Estimated_Discount__c = 0;
                charge.EstimatedQty__c = 1;                
                charges.add(charge);
                
                ////System.debug('no of charges inserted in setup: ' +  charges.size());
                ////System.debug('## Charges being inserted - ' + charges);
                insert charges;
            }
        }
        
    }
    
    public void LoadAmendmentList()
    {
        amendmentList = [SELECT Id, IsDeleted, Name, CurrencyIsoCode, CreatedDate, CreatedById, LastModifiedDate, 
                         LastModifiedById, SystemModstamp, zqu__Quote__c, zqu__AutoRenew__c, zqu__DeltaMRR__c, 
                         zqu__DeltaTCV__c, zqu__Description__c, zqu__InitialTerm__c, zqu__QuoteAmendmentZuoraId__c, 
                         zqu__RenewalTerm__c, zqu__Status__c, zqu__TermStartDate__c, zqu__TermType__c, zqu__TotalAmount__c, 
                         zqu__Type__c, zqu__RenewalSetting__c, zqu__InitialTermPeriodType__c, zqu__RenewalTermPeriodType__c, 
                         Communicate_Parts_Lines_Count__c, PureCloud_License_Lines_Count__c,
                         Discount__c, PCV_Lines_Count__c, Services_Lines_Count__c, Service_Tokens_Lines_Count__c 
                         FROM zqu__QuoteAmendment__c];
    }
    
    public void SetupZQuoteForPCV()
    {
        Date dStartDate = System.today().addDays(90);
        System.runAs(new User(Id = UserInfo.getUserId()))
        {
            Noah = UserFactory.CreateInternalUser('noah');
            insert new List<User> { Noah };
		}

		// Create List Custom Settings
		insert GeneralCustomSettingFactory.CreateZuoraCustomSettings();
        
        acctContext = new TestAccountContext();
        ZAccount = acctContext.CustomerAcct1;
        ZContact = acctContext.partContact3;
        
        
        InternalPCOpp1 = OpportunityFactory.CreatePureCloudOpportunity('InternalPCOpp1');
        InternalPCOpp1.OwnerId = Noah.Id;
        
        ////System.debug('## PC Record Type Id - ' + CustomSettingsProvider.GetGeneralCustomSettingsVal('Opportunity_PCRecordTypeId'));
        //InternalPCOpp1.RecordTypeId = CustomSettingsProvider.GetGeneralCustomSettingsVal('Opportunity_PCRecordTypeId');
        InternalPCOpp1.ownerId = noah.id; // internal user
        InternalPCOpp1.AccountId = ZAccount.Id;
        InternalPCOpp1.StageName = 'Ready to Order';
        //InternalPCOpp1.Budgetary__c = false;
        InternalPCOpp1.Contact__c = ZContact.Id;
        
        insert new List<Opportunity> { InternalPCOpp1 };
            
        ZQuote = new zqu__Quote__c();
        ZQuote.zqu__Account__c = ZAccount.Id;
        ZQuote.zqu__SoldToContact__c = ZContact.Id;
        zQuote.Name = 'Test zQuote';
        //zQuote.Discount_Approval_Status__c = 'Not Required';
        zQuote.zqu__PaymentTerm__c = 'Net 30';
        zQuote.zqu__Description__c = 'Test zQuote';
        zQuote.zqu__Opportunity__c = InternalPCOpp1.Id;
        zQuote.zqu__StartDate__c = dStartDate;
        //zQuote.zqu__Number__c = 'Q000108';
        zQuote.zqu__Status__c = 'New';
        zQuote.CurrencyIsoCode = 'USD';
        zQuote.zqu__Currency__c = 'USD';
        zQuote.Opportunity_Owner__c = UserInfo.getUserId();
        
        
        insert new List<zqu__Quote__c> { ZQuote };
            
		List<Product2> products = new List<Product2> ();
        
        Product2 dummyProduct = new Product2();
        dummyProduct.Name = 'PureCloud Voice';
        dummyProduct.zqu__SKU__c = DummyPartNumber;
        dummyProduct.Product_Line__c = 'Communicate, Engage';
        dummyProduct.zqu__ZuoraId__c = '2c92c0f950dcbc9c0150dd80b0690a6d';
        dummyProduct.zqu__Category__c = 'Read Only';
        dummyProduct.Product_Category__c = 'Read Only';
        dummyProduct.Product_Subcategory__c = 'Phones';
        dummyProduct.ProductShippable__c = 'No';
        dummyProduct.CurrencyIsoCode = 'USD';
        products.add(dummyProduct);
        
        ////System.debug('## Products being inserted - ' + products);
        insert products;
        
        List<zqu__ProductRatePlan__c> zplans = new List<zqu__ProductRatePlan__c> ();
        
        zqu__ProductRatePlan__c dummyPlan = new zqu__ProductRatePlan__c();
        dummyPlan.zqu__Product__c = dummyProduct.id;
        dummyPlan.Name = dummyProduct.Name;
        dummyPlan.zqu__ZuoraId__c = 'dummyPlan';
        zplans.add(dummyPlan);
        
        ////System.debug('## Rate Plans being inserted - ' + zplans);
        insert zplans;
        
        List<zqu__ProductRatePlanCharge__c> zratecharges = new List<zqu__ProductRatePlanCharge__c> ();
        
        dummyRatecharge = new zqu__ProductRatePlanCharge__c();
        dummyRatecharge.Name = dummyProduct.Name;
        dummyRatecharge.zqu__AccountingCode__c = 'Accounts Receivable';
        dummyRatecharge.zqu__ListPrice__c = 97.25;
        dummyRatecharge.zqu__Model__c = 'Per Unit Pricing';
        dummyRatecharge.zqu__Type__c = 'One-Time';
        dummyRatecharge.zqu__ZuoraId__c = 'dummyRatecharge';
        dummyRatecharge.zqu__ProductRatePlan__c = dummyPlan.id;
        dummyRatecharge.SKU__c = 'test-sku-dummy';
        zratecharges.add(dummyRatecharge);
        
        ////System.debug('## Rate Plan Charges being inserted - ' + zratecharges);
        insert zratecharges;
        
        
        //Adding Charges
        List<zqu__QuoteRatePlanCharge__c> charges = new List<zqu__QuoteRatePlanCharge__c> ();
        /*   
		//ZQuote charges 
		zqu__QuoteRatePlanCharge__c charge = new zqu__QuoteRatePlanCharge__c();
		charge.zqu__Quote__c = ZQuote.Id;
		charge.Name = 'charge 1';
		charge.CurrencyIsoCode = 'USD';
		charge.zqu__Quantity__c = 1;
		charge.EstimatedQty__c = 1;
		charge.zqu__ProductName__c = 'PureCloud Test User License';
		charge.zqu__Discount__c = 0; 
		charge.zqu__EffectivePrice__c = 9;
		charge.zqu__ChargeType__c = 'Usage';
		charge.zqu__ProductRatePlanCharge__c = zratecharge1.Id;
		charge.zqu__TimeProductAdded__c = '20150819T103845101Z';
		charge.zqu__Currency__c = 'USD';
		charge.Estimated_Discount__c = 0;
		charge.EstimatedQty__c = 1;

		charges.add(charge);

		//System.debug('no of charges inserted in setup: ' +  charges.size());
		//System.debug('## Charges being inserted - ' + charges);
		insert charges;
		*/
    }
    
    public void SimulateSendtoZBilling()
    {
        SimulateSendtoZBilling(ZQuote, isAmendment);
    }
    public void SimulateSendtoZBilling(zqu__Quote__c quote, Boolean isAmendmentQuote)
    {
        zQuoteSubscr = new Zuora__Subscription__c();
        zQuoteSubscr.Zuora__Account__c = quote.zqu__Account__c;
        zQuoteSubscr.Zuora__Status__c = 'Active';
        zQuoteSubscr.Zuora__InitialTerm__c = 'Communicate, Engage';
        zQuoteSubscr.Zuora__Zuora_Id__c = '2c92c0f950d7hju60150dd80b0690a6d';
        zQuoteSubscr.Name = 'zQuote Collaborate Pro and Communicate subscr';
        zQuoteSubscr.Zuora__Version__c = 1;
        zQuoteSubscr.Zuora__External_Id__c = '2c92c0f950d7hju60150dd80b0690a6d';
        
        if (isAmendmentQuote)
        {
            zQuoteSubscr.Name = 'AmendedSubscription';
            zQuoteSubscr.Zuora__OriginalCreatedDate__c = date.today().addDays(-1);
            zQuoteSubscr.Zuora__OriginalCreated_Date__c = DateTime.now().addDays(-1);
        }

        quote.zqu__Status__c = 'Sent to Z-Billing';
        quote.zqu__Hidden_Subscription_Name__c = zQuoteSubscr.Name;
        update quote;

        ////System.debug('## subscription(s) being inserted - ' + zQuoteSubscr);
        insert new List<Zuora__Subscription__c> { zQuoteSubscr };
            
            
		List<Zuora__SubscriptionProductCharge__c> zSubscrCharges = new List<Zuora__SubscriptionProductCharge__c> ();
        
        Zuora__SubscriptionProductCharge__c subscrCharge = new Zuora__SubscriptionProductCharge__c();
        subscrCharge.Zuora__Account__c = quote.zqu__Account__c;
        subscrCharge.Zuora__Subscription__c = zQuoteSubscr.Id;
        subscrCharge.Zuora__Type__c = 'Usage';
        subscrCharge.Zuora__External_Id__c = '2c92c0f950id7s460150dd80b0609dhs';
        subscrCharge.Zuora__ProductSKU__c = 'PC-170-NV-USCLP';
        zSubscrCharges.add(subscrCharge);
        
        Zuora__SubscriptionProductCharge__c tokenCharge = new Zuora__SubscriptionProductCharge__c();
        tokenCharge.Zuora__Account__c = quote.zqu__Account__c;
        tokenCharge.Zuora__Subscription__c = zQuoteSubscr.Id;
        tokenCharge.Zuora__Type__c = 'Recurring';
        tokenCharge.Zuora__External_Id__c = '2c92c0f950id7s460150dd80b0bronze';
        tokenCharge.Zuora__ProductSKU__c = 'PS-170-PURE-SVBRONZE';
        tokenCharge.Zuora__ProductName__c = 'PureCloud Bronze Monthly Premier Success Service';
        tokenCharge.Zuora__Model__c = 'Per Unit Pricing';
        tokenCharge.Zuora__EffectiveStartDate__c = date.today();
        tokenCharge.Zuora__Quantity__c = 1;
        zSubscrCharges.add(tokenCharge);
        
        ////System.debug('## subscription Product Charge(s) being inserted - ' + zSubscrCharges);
        insert zSubscrCharges;
    }
    
    public void Refresh()
    {
        for (Account acct :[SELECT Id, Type, Account_Sub_Type__c, RecordTypeId, RecordType.DeveloperName
                            FROM Account WHERE Id IN(:ZAccount.Id)])
        {
            ////System.debug('## Account being refreshed - ' + acct);
            if (acct.Id == ZAccount.Id)
            {
                this.ZAccount = acct;
            }
        }
        
        for (zqu__Quote__c q :[SELECT Id, Name, zqu__Opportunity__c, Approval_Status__c, zqu__ApprovalStatus__c, zqu__Terms__c
                               FROM zqu__Quote__c WHERE Id IN(:ZQuote.Id, :ZQuote2.Id)])
        {
            ////System.debug('## Quote being refreshed - ' + q);
            if (q.Id == ZQuote.Id)
            {
                this.ZQuote = q;
            }
            if (q.Id == ZQuote2.Id)
            {
                this.ZQuote2 = q;
            }
        }
        licensesZQuoteCharges = new List<zqu__QuoteRatePlanCharge__c> ();
        oneTimeZQuoteCharges = new List<zqu__QuoteRatePlanCharge__c> ();
        for (zqu__QuoteRatePlanCharge__c qc :[SELECT Id, Name, QuoteId__c, zqu__ListPrice__c, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c,
                                              zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Cost__c, zqu__Quantity__c, Product_Category__c,
                                              zqu__EffectivePrice__c, zqu__ChargeType__c, zqu__Period__c, zqu__ProductName__c,
                                              zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.ProductShippable__c
                                              FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :ZQuote.Id AND Product_Category__c != 'PureCloud Voice'])
        {
            ////System.debug('## QuotCharge being refreshed - ' + qc);
            if (qc.zqu__ChargeType__c != 'One-Time')
            {
                ////System.debug('## License QuoteCharge being refreshed - ' + qc);    
                licensesZQuoteCharges.Add(qc);
            }
            else
            {
                ////System.debug('## OneTime QuoteCharge being refreshed - ' + qc);
                oneTimeZQuoteCharges.Add(qc);
            }
        }
    }
    
    public void SetupDevOrgPromotion()
    {
        Date d = date.today();
        Product2 p = MakeDevOrgPart();
        Product2 promoPart = [SELECT Id, Name, zqu__Category__c, zqu__Deleted__c, zqu__SKU__c, zqu__Type__c, Product_Category__c, zqu__SKU2__c, Product_Line__c FROM Product2 WHERE zqu__SKU__c =: p.zqu__SKU__c LIMIT 1];        
        
        Promotion__c devOrg = new Promotion__c();
        devOrg.Name = 'PureCloud Dev Org';
        devOrg.PromoPart__c = promoPart.Id;
        devOrg.Start_Date__c = d;
        devOrg.End_Date__c = d.addYears(1);
        
        insert devOrg;
        
        List<Promotion_Part__c> parts = new List<Promotion_Part__c> ();

        Product2 partToAdd = [SELECT Id, Name, zqu__Category__c, zqu__Deleted__c, zqu__SKU__c, zqu__Type__c, Product_Category__c, zqu__SKU2__c, Product_Line__c, 
                              (SELECT Id FROM zqu__Product_Rate_Plans__r LIMIT 1)
                              FROM Product2 WHERE zqu__SKU__c = 'PC-170-NV-PCEDGE-VIR' LIMIT 1];        
        
        Promotion_Part__c part = new Promotion_Part__c();
        part.Promotion__c = devOrg.Id;
        part.PartToAdd__c = partToAdd.Id;
        part.Product_Rate_Plan__c = new List<zqu__ProductRatePlan__c>((List<zqu__ProductRatePlan__c>)partToAdd.getSObjects('zqu__Product_Rate_Plans__r'))[0].Id;
        part.Discount_Percent__c = 100;
        parts.add(part);

        partToAdd = [SELECT Id, Name, zqu__Category__c, zqu__Deleted__c, zqu__SKU__c, zqu__Type__c, Product_Category__c, zqu__SKU2__c, Product_Line__c, 
                     (SELECT Id FROM zqu__Product_Rate_Plans__r LIMIT 1)
                     FROM Product2 WHERE zqu__SKU__c = 'PC-170-NV-USES3' LIMIT 1];        
        
        part = new Promotion_Part__c();
        part.Promotion__c = devOrg.Id;
        part.PartToAdd__c = partToAdd.Id;
        part.Product_Rate_Plan__c = new List<zqu__ProductRatePlan__c>((List<zqu__ProductRatePlan__c>)partToAdd.getSObjects('zqu__Product_Rate_Plans__r'))[0].Id;
        part.Discount_Amount__c = 10;
        part.Included_Usage_Units__c = 5;
        parts.add(part);
        
        partToAdd = [SELECT Id, Name, zqu__Category__c, zqu__Deleted__c, zqu__SKU__c, zqu__Type__c, Product_Category__c, zqu__SKU2__c, Product_Line__c, 
                     (SELECT Id FROM zqu__Product_Rate_Plans__r LIMIT 1)
                     FROM Product2 WHERE zqu__SKU__c = 'PV-170-NV-PCVOICE' LIMIT 1];        

        part = new Promotion_Part__c();
        part.Promotion__c = devOrg.Id;
        part.PartToAdd__c = partToAdd.Id;
        part.Product_Rate_Plan__c = new List<zqu__ProductRatePlan__c>((List<zqu__ProductRatePlan__c>)partToAdd.getSObjects('zqu__Product_Rate_Plans__r'))[0].Id;
        part.Discount_Percent__c = 1.0;
        parts.add(part);
        
        insert parts;
        
        /*List<Promotion_Part__c> check = [SELECT PartToAdd__r.zqu__SKU__c, Discount_Amount__c, Discount_Percent__c, Discount_Length__c, 
                                      Committed_Quantity__c, Included_Usage_Units__c, Billing_Start_Date__c, 
                                      Promotion__r.PromoPart__r.zqu__SKU__c, Promotion__r.Name, Promotion__r.Start_Date__c, 
                                      Promotion__r.End_Date__c FROM Promotion_Part__c];
        
       System.debug('Promotion_Part__c: ' + JSON.serialize(check));
       */

    }
    
    public Product2 MakeDevOrgPart()
    {
        Product2 product1 = new Product2();
        product1.Name = 'PureCloud Dev Org';
        product1.zqu__SKU__c = 'PV-170-NV-DEVORG';
        product1.Product_Line__c = 'Collaborate Pro, Communicate, Engage';
        product1.zqu__Category__c = '';
        product1.Product_Category__c = 'DevOrg';
        product1.Product_Subcategory__c = 'DevOrg';
        product1.ProductShippable__c = 'No';
        product1.CurrencyIsoCode = 'USD';
        product1.zqu__ZuoraId__c = 'p1';
        product1.zqu__Deleted__c = false;
        
        return product1;
    }
    
    public void SetupDevOrgProducts()
    {
        List<Product2> products = new List<Product2> ();
        
        Product2 product1 = MakeDevOrgPart();
        products.add(product1);
        
        Product2 product2 = new Product2();
        product2.Name = 'PureCloud Edge Virtual';
        product2.zqu__SKU__c = 'PC-170-NV-PCEDGE-VIR';
        product2.Product_Line__c = 'Communicate, Engage';
        product2.zqu__Category__c = '';
        product2.Product_Category__c = 'Hardware';
        product2.Product_Subcategory__c = 'Media Gateways & Accessories';
        product2.ProductShippable__c = 'Yes';
        product2.CurrencyIsoCode = 'USD';
        product2.zqu__ZuoraId__c = 'p2';
        product2.zqu__Deleted__c = false;
        products.add(product2);
        
        Product2 product3 = new Product2();
        product3.Name = 'PureCloud Engage 3 User';
        product3.zqu__SKU__c = 'PC-170-NV-USES3';
        product3.Product_Line__c = 'Engage';
        product3.zqu__Category__c = '';
        product3.Product_Category__c = 'Licenses';
        product3.Product_Subcategory__c = 'Engage 3';
        product3.ProductShippable__c = 'No';
        product3.CurrencyIsoCode = 'USD';
        product3.zqu__ZuoraId__c = 'p3';
        product3.zqu__Deleted__c = false;
        products.add(product3);
        
        Product2 product4 = new Product2();
        product4.Name = 'PureCloud Voice';
        product4.zqu__SKU__c = 'PV-170-NV-PCVOICE';
        product4.Product_Line__c = 'Communicate, Engage';
        product4.zqu__Category__c = 'Voice Services';
        product4.Product_Category__c = 'Hardware';
        product4.Product_Subcategory__c = 'Phones';
        product4.ProductShippable__c = 'No';
        product4.CurrencyIsoCode = 'USD';
        product4.zqu__ZuoraId__c = 'p4';
        product4.zqu__Deleted__c = false;
        products.add(product4);
        
        insert products;
        
        //System.debug('product1: ' + JSON.serialize(product1));
        //System.debug('product2: ' + JSON.serialize(product2));
        //System.debug('product3: ' + JSON.serialize(product3));
        //System.debug('product4: ' + JSON.serialize(product4));
        
        List<zqu__ProductRatePlan__c> plans = new List<zqu__ProductRatePlan__c> ();
        
        //zqu__ZProduct__c zprod1 = [SELECT Id, Name, zqu__Description__c, zqu__SKU__c, zqu__ZuoraId__c, zqu__Product__c 
									//FROM zqu__ZProduct__c WHERE zqu__Product__c =: product1.Id LIMIT 1];        
        //System.debug('zprod1: ' + JSON.serialize(zprod1));

        //zqu__ZProduct__c zprod2 = [SELECT Id, Name, zqu__Description__c, zqu__SKU__c, zqu__ZuoraId__c, zqu__Product__c 
									//FROM zqu__ZProduct__c WHERE zqu__Product__c =: product2.Id LIMIT 1];        
        //System.debug('zprod2: ' + JSON.serialize(zprod2));

        //zqu__ZProduct__c zprod3 = [SELECT Id, Name, zqu__Description__c, zqu__SKU__c, zqu__ZuoraId__c, zqu__Product__c 
									//FROM zqu__ZProduct__c WHERE zqu__Product__c =: product3.Id LIMIT 1];        
        //System.debug('zprod3: ' + JSON.serialize(zprod3));

        //zqu__ZProduct__c zprod4 = [SELECT Id, Name, zqu__Description__c, zqu__SKU__c, zqu__ZuoraId__c, zqu__Product__c 
									//FROM zqu__ZProduct__c WHERE zqu__Product__c =: product4.Id LIMIT 1];        
        //System.debug('zprod4: ' + JSON.serialize(zprod4));
        //
        zqu__ZUnitOfMeasure__c uom = createUOM(true, '12345678');
        
        zqu__ProductRatePlan__c plan1 = new zqu__ProductRatePlan__c();
        plan1.zqu__Product__c = product1.Id;
        //plan1.zqu__ZProduct__c = zprod1.Id;
        plan1.zqu__ZuoraId__c = 'prp1';
        plan1.Name = product1.Name;
        plan1.zqu__Deleted__c = false;
        plan1.zqu__EffectiveStartDate__c =  Date.newInstance(2010, 1, 1);
        plan1.zqu__EffectiveEndDate__c = Date.newInstance(2020, 1, 1);
        plans.add(plan1);
        
       	PromoPartProductRatePlan = plan1;
        
        zqu__ProductRatePlan__c plan2 = new zqu__ProductRatePlan__c();
        plan2.zqu__Product__c = product2.Id;
        //plan2.zqu__ZProduct__c = zprod2.Id;
        plan2.zqu__ZuoraId__c = 'prp2';
        plan2.Name = product2.Name;
        plan2.zqu__Deleted__c = false;
        plan2.zqu__EffectiveStartDate__c =  Date.newInstance(2010, 1, 1);
        plan2.zqu__EffectiveEndDate__c = Date.newInstance(2020, 1, 1);
        plans.add(plan2);
        
        zqu__ProductRatePlan__c plan3 = new zqu__ProductRatePlan__c();
        plan3.zqu__Product__c = product3.Id;
        //plan3.zqu__ZProduct__c = zprod3.Id;
        plan3.zqu__ZuoraId__c = 'prp3';
        plan3.Name = product3.Name;
        plan3.zqu__Deleted__c = false;
        plan3.zqu__EffectiveStartDate__c =  Date.newInstance(2010, 1, 1);
        plan3.zqu__EffectiveEndDate__c = Date.newInstance(2020, 1, 1);
        plans.add(plan3);
        
        zqu__ProductRatePlan__c plan4 = new zqu__ProductRatePlan__c();
        plan4.zqu__Product__c = product4.Id;
        //plan4.zqu__ZProduct__c = zprod4.Id;
        plan4.zqu__ZuoraId__c = 'prp4';
        plan4.Name = product4.Name;
        plan4.zqu__Deleted__c = false;
        plan4.zqu__EffectiveStartDate__c =  Date.newInstance(2010, 1, 1);
        plan4.zqu__EffectiveEndDate__c = Date.newInstance(2020, 1, 1);
        plans.add(plan4);
        
        insert plans;
        
        //System.debug('plan1: ' + JSON.serialize(plan1));
        //System.debug('plan2: ' + JSON.serialize(plan2));
        //System.debug('plan3: ' + JSON.serialize(plan3));
        //System.debug('plan4: ' + JSON.serialize(plan4));
        
        
        List<zqu__ProductRatePlanCharge__c> ratecharges = new List<zqu__ProductRatePlanCharge__c> ();
        
        //zqu__ProductRatePlanCharge__c ratecharge1 = new zqu__ProductRatePlanCharge__c();
        zqu__ProductRatePlanCharge__c ratecharge1 = createProductRatePlanCharge(false, 'prpc1', product1.name, plan1, 9.99, 'Per Unit Pricing', 'One-Time', product1.zqu__SKU__c + '-C1', 'Month', uom);
        /*ratecharge1.Name					= product1.Name;
        ratecharge1.zqu__AccountingCode__c	= 'Accounts Receivable';
        ratecharge1.zqu__ListPrice__c		= 9.99;
        ratecharge1.zqu__Model__c			= 'Per Unit Pricing';
        ratecharge1.zqu__Type__c			= 'One-Time';
        ratecharge1.zqu__ProductRatePlan__c = plan1.id;
        ratecharge1.SKU__c					= product1.zqu__SKU__c + '-C1';
        ratecharge1.zqu__ZuoraId__c 		= 'prpc1';
        ratecharge1.zqu__Deleted__c = false;*/
        ratecharges.add(ratecharge1);
        
        /*zqu__ProductRatePlanCharge__c ratecharge2 = new zqu__ProductRatePlanCharge__c();
        ratecharge2.Name					= product2.Name;
        ratecharge2.zqu__AccountingCode__c	= 'Accounts Receivable';
        ratecharge2.zqu__ListPrice__c		= 9.99;
        ratecharge2.zqu__Model__c			= 'Per Unit Pricing';
        ratecharge2.zqu__Type__c			= 'Recurring';
        ratecharge2.zqu__RecurringPeriod__c = 'Month';
        ratecharge2.zqu__ProductRatePlan__c = plan2.id;
        ratecharge2.SKU__c					= product2.zqu__SKU__c + '-C1';
        ratecharge2.zqu__ZuoraId__c 		= 'prpc2';
        ratecharge2.zqu__Deleted__c = false;*/
        zqu__ProductRatePlanCharge__c ratecharge2 = createProductRatePlanCharge(false, 'prpc2', product2.name, plan2, 9.99, 'Per Unit Pricing', 'Recurring', product2.zqu__SKU__c + '-C1', 'Month', uom);
        ratecharges.add(ratecharge2);
        
        /*zqu__ProductRatePlanCharge__c ratecharge3 = new zqu__ProductRatePlanCharge__c();
        ratecharge3.Name					= product3.Name;
        ratecharge3.zqu__AccountingCode__c	= 'Accounts Receivable';
        ratecharge3.zqu__ListPrice__c		= 9.99;
        ratecharge3.zqu__Model__c			= 'Overage Pricing';
        ratecharge3.zqu__Type__c			= 'Usage';
        ratecharge3.zqu__ProductRatePlan__c = plan3.id;
        ratecharge3.SKU__c					= product3.zqu__SKU__c + '-C1';
        ratecharge3.zqu__ZuoraId__c 		= 'prpc3';
        ratecharge3.zqu__Deleted__c = false;*/
        zqu__ProductRatePlanCharge__c ratecharge3 = createProductRatePlanCharge(false, 'prpc3', product3.name, plan3, 9.99, 'Overage Pricing', 'Usage', product3.zqu__SKU__c + '-C1', 'Month', uom);
        ratecharges.add(ratecharge3);
        
        /*zqu__ProductRatePlanCharge__c ratecharge4 = new zqu__ProductRatePlanCharge__c();
        ratecharge4.Name					= product4.Name;
        ratecharge4.zqu__AccountingCode__c	= 'Accounts Receivable';
        ratecharge4.zqu__ListPrice__c		= 9.99;
        ratecharge4.zqu__Model__c			= 'Flat Fee Pricing';
        ratecharge4.zqu__Type__c			= 'Usage';
        ratecharge4.zqu__ProductRatePlan__c = plan4.id;
        ratecharge4.SKU__c					= product4.zqu__SKU__c + '-C1';
        ratecharge4.zqu__ZuoraId__c 		= 'prpc4';
        ratecharge4.zqu__Deleted__c = false;*/
        zqu__ProductRatePlanCharge__c ratecharge4 = createProductRatePlanCharge(false, 'prpc4', product4.name, plan4, 9.99, 'Flat Fee Pricing', 'Usage', product4.zqu__SKU__c + '-C1', 'Month', uom);
        ratecharges.add(ratecharge4);
        
        insert ratecharges;
        
        //System.debug('ratecharge1: ' + JSON.serialize(ratecharge1));
        //System.debug('ratecharge2: ' + JSON.serialize(ratecharge2));
        //System.debug('ratecharge3: ' + JSON.serialize(ratecharge3));
        //System.debug('ratecharge4: ' + JSON.serialize(ratecharge4));
        
        
        List<zqu__ProductRatePlanChargeTier__c> tiers = new List<zqu__ProductRatePlanChargeTier__c> ();
        
        zqu__ProductRatePlanChargeTier__c tier1 = new zqu__ProductRatePlanChargeTier__c();
        tier1.zqu__Currency__c = 'USD';
        tier1.zqu__Deleted__c = false;
        tier1.zqu__Price__c = ratecharge1.zqu__ListPrice__c;
        tier1.zqu__PriceFormat__c = 'Flat Fee';
        tier1.zqu__ProductRatePlanChargeId__c = ratecharge1.Id;
        tier1.zqu__Tier__c = 1;
        tier1.zqu__ProductRatePlanCharge__c = ratecharge1.Id;
        tier1.zqu__ZuoraId__c = 'prpct1';
        tier1.zqu__Deleted__c = false;
        tiers.add(tier1);
        
        zqu__ProductRatePlanChargeTier__c tier2 = new zqu__ProductRatePlanChargeTier__c();
        tier2.zqu__Currency__c = 'USD';
        tier2.zqu__Deleted__c = false;
        tier2.zqu__Price__c = ratecharge2.zqu__ListPrice__c;
        tier2.zqu__PriceFormat__c = 'Flat Fee';
        tier2.zqu__ProductRatePlanChargeId__c = ratecharge2.Id;
        tier2.zqu__Tier__c = 1;
        tier2.zqu__ProductRatePlanCharge__c = ratecharge2.Id;
        tier2.zqu__ZuoraId__c = 'prpct2';
        tiers.add(tier2);
        
        zqu__ProductRatePlanChargeTier__c tier3 = new zqu__ProductRatePlanChargeTier__c();
        tier3.zqu__Currency__c = 'USD';
        tier3.zqu__Deleted__c = false;
        tier3.zqu__Price__c = ratecharge3.zqu__ListPrice__c;
        tier3.zqu__PriceFormat__c = 'Flat Fee';
        tier3.zqu__ProductRatePlanChargeId__c = ratecharge3.Id;
        tier3.zqu__Tier__c = 1;
        tier3.zqu__ProductRatePlanCharge__c = ratecharge3.Id;
        tier3.zqu__ZuoraId__c = 'prpct3';
        tiers.add(tier3);
        
        zqu__ProductRatePlanChargeTier__c tier4 = new zqu__ProductRatePlanChargeTier__c();
        tier4.zqu__Currency__c = 'USD';
        tier4.zqu__Deleted__c = false;
        tier4.zqu__Price__c = ratecharge4.zqu__ListPrice__c;
        tier4.zqu__PriceFormat__c = 'Flat Fee';
        tier4.zqu__ProductRatePlanChargeId__c = ratecharge4.Id;
        tier4.zqu__Tier__c = 1;
        tier4.zqu__ProductRatePlanCharge__c = ratecharge4.Id;
        tier4.zqu__ZuoraId__c = 'prpct4';
        tiers.add(tier4);
        
        insert tiers;
        
        //System.debug('tier1: ' + JSON.serialize(tier1));
        //System.debug('tier2: ' + JSON.serialize(tier2));
        //System.debug('tier3: ' + JSON.serialize(tier3));
        //System.debug('tier4: ' + JSON.serialize(tier4));
        
    }
    
    public void AddPromoPart()
    {        
        Product2 product = MakeDevOrgPart();
        
        String sku = product.zqu__SKU__c + '-C1';
        zqu__ProductRatePlan__c ratePlan = [SELECT Id, Name, zqu__Description__c, zqu__Product__r.zqu__SKU__c FROM zqu__ProductRatePlan__c WHERE zqu__Product__r.zqu__SKU__c = 'PV-170-NV-DEVORG'];

        //System.debug('ratePlan: ' + JSON.serialize(ratePlan));

        System.assertEquals('PureCloud Dev Org', ratePlan.Name, 'Dev Org Rate Plan not found');
               
        zqu.zChargeGroup chargeGroup = zqu.zQuoteUtil.getChargeGroup((ID) ZQuote.Id, (ID)ratePlan.Id);
        
        //System.debug('chargeGroup.groupID: ' + chargeGroup.groupID);
        //System.debug('chargeGroup.groupType: ' + chargeGroup.groupType);
        //System.debug('chargeGroup.productId: ' + chargeGroup.productId);
        //System.debug('chargeGroup.productName: ' + chargeGroup.productName);
        //System.debug('chargeGroup.productRatePlanId: ' + chargeGroup.productRatePlanId);
        //System.debug('chargeGroup.productRateplanZuoraID: ' + chargeGroup.productRateplanZuoraID);
        //System.debug('chargeGroup.productSelectorId: ' + chargeGroup.productSelectorId);
        //System.debug('chargeGroup.quote: ' + chargeGroup.quote);
        //System.debug('chargeGroup.ratePlanName: ' + chargeGroup.ratePlanName);
        //System.debug('chargeGroup.subscriptionRatePlanId: ' + chargeGroup.subscriptionRatePlanId);
        //System.debug('chargeGroup.zCharges.size(): ' + chargeGroup.zCharges.size());
        //System.debug('chargeGroup.zCharges[0]: ' + chargeGroup.zCharges[0]);
                
        zqu.zQuoteUtil.addChargeGroup(chargeGroup);
        
/*        
        List<zqu__QuoteRatePlanCharge__c> charges = new List<zqu__QuoteRatePlanCharge__c> ();
        
        zqu__QuoteRatePlanCharge__c charge = new zqu__QuoteRatePlanCharge__c();
        charge.zqu__QuoteRatePlan__c = quoteRatePlan.id;
        //charge.zqu__Quote__c = ZQuote.Id;
        charge.Name = product.Name;
        charge.CurrencyIsoCode = 'USD';
        charge.zqu__Quantity__c = 1;
        charge.EstimatedQty__c = 1;
        charge.zqu__ProductName__c = product.Name;
        charge.zqu__Discount__c = 0;
        charge.zqu__ChargeType__c = 'One-Time';
        charge.zqu__ProductRatePlanCharge__c = ratecharge1.Id;
        //charge.zqu__TimeProductAdded__c = '20150819T103845101Z';
        charge.zqu__Currency__c = 'USD';
        charge.Estimated_Discount__c = 0;
        charge.EstimatedQty__c = 1;        
        
        insert charge;
        */
 
        
    }
    
    public void AddPromoBundleParts()
    {        
        /*//System.debug('ZTestZQuoteContext.AddPromoBundleParts');
		List<String> bundleProducts = new List<String>();
		bundleProducts.add('PV-170-NV-DEVORG');
		bundleProducts.add('PC-170-NV-PCEDGE-VIR');
		bundleProducts.add('PC-170-NV-USES3');
		bundleProducts.add('PV-170-NV-PCVOICE');

		List<Product2> products = [SELECT Name, zqu__SKU__c FROM Product2 WHERE zqu__SKU__c in :bundleProducts];

		for(Product2 p : products)
		{
		//System.debug('ZTestZQuoteContext -- ' + p.Name + ' : ' + p.zqu__SKU__c);
		}

		System.assertEquals(4, products.size(), 'Not all of the parts for the Dev Org bundle were found');

		List<String> bundleSKUs = new List<String>();
		for (Product2 product : products)
		{
		bundleSKUs.add(product.zqu__SKU__c + '-C1');
		}

		List<zqu__ProductRatePlanCharge__c> ratecharges = [SELECT Id, zqu__AccountingCode__c, zqu__Apply_Discount_To_One_Time_Charges__c, zqu__Apply_Discount_To_Recurring_Charges__c, 
		zqu__Apply_Discount_To_Usage_Charges__c, zqu__DefaultQuantity__c, zqu__Deleted__c, zqu__Description__c, 
		zqu__Discount_Apply_Type__c, zqu__Discount_Level__c, zqu__ListPrice__c, zqu__MaxQuantity__c, zqu__MinQuantity__c, 
		zqu__Model__c, zqu__PrepaymentPeriods__c, zqu__PriceTable__c, zqu__ProductRatePlan__c, zqu__RecurringPeriod__c, 
		zqu__RevRecCode__c, zqu__TaxCode__c, zqu__Type__c, zqu__UOM__c, zqu__Upto_How_Many_Periods__c, zqu__ZUnitOfMeasure__c, 
		zqu__ZUom_Id__c, zqu__ZuoraId__c, SKU__c FROM zqu__ProductRatePlanCharge__c WHERE SKU__c in :bundleSKUs];
		System.assertEquals(4, ratecharges.size(), 'Dev Org Rate Plan Charge ZuoraId not found');



		List<zqu__QuoteRatePlanCharge__c> charges = new List<zqu__QuoteRatePlanCharge__c> ();

		for (Product2 product : products)
		{
		zqu__ProductRatePlanCharge__c ratePlan = null;

		for (zqu__ProductRatePlanCharge__c r : ratecharges)
		{
		if (r.SKU__c == product.zqu__SKU__c + '-C1')
		{
		ratePlan = r;
		break;
		}
		}

		System.assertNotEquals(null, ratePlan, 'Rate plan not found');

		zqu__QuoteRatePlanCharge__c charge = new zqu__QuoteRatePlanCharge__c();
		//charge.zqu__Quote__c = ZQuote.Id;
		charge.Name = product.Name;
		charge.CurrencyIsoCode = 'USD';
		charge.zqu__Quantity__c = 1;
		charge.EstimatedQty__c = 1;
		charge.zqu__ProductName__c = product.Name;
		charge.zqu__Discount__c = 100;
		charge.zqu__ChargeType__c = 'One-Time';
		charge.zqu__ProductRatePlanCharge__c = ratePlan.Id;
		//charge.zqu__TimeProductAdded__c = '20150819T103845101Z';
		charge.zqu__Currency__c = 'USD';
		charge.Estimated_Discount__c = 0;
		charge.EstimatedQty__c = 1;        
		charges.add(charge);

		}

		insert charges;*/
    }
    
}