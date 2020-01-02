public class QuoteDomain {

    Public Static String ProductRatePlansKey = 'ProductRatePlansKey';

    Public zqu__Quote__c quote;
    Public Id OppId;

    Public List<zqu__QuoteRatePlanCharge__c> usageLineItems;
    Public List<zqu__QuoteRatePlanCharge__c> oneTimeLineItems;
    Public List<zqu__QuoteRatePlanCharge__c> pcvLineItems;
    Public List<zqu__QuoteRatePlanCharge__c> axLineItems;
    Public List<zqu__QuoteRatePlanCharge__c> nonAXLineItems;

    Public List<zqu__QuoteRatePlan__c> amendmentRemovedOneTimeRatePlans;

    //cached map of product rate plans that is cached Org wide.
    //the Map Key is the Zuora Id and the value is the object.
    public static Map<String, zqu__ProductRatePlanCharge__c> productRatePlans
    {
        get
        {
            //System.debug('QuoteDomain.LoadProductRatePlans');

            LoadProductRatePlans();
            return(Map<String, zqu__ProductRatePlanCharge__c>) Cache.Org.get(ProductRatePlansKey);

        }

    }

    public static void LoadProductRatePlans()
    {
        //System.debug('QuoteDomain.LoadProductRatePlans');

        Boolean cachedItemIsNull = Cache.Org.get(ProductRatePlansKey) == null;

        //System.debug('cachedItemIsNull :' + cachedItemIsNull);

        if (cachedItemIsNull) {
            //System.debug('Loading Product Rate Plans in the cache.');
            Map<String, zqu__ProductRatePlanCharge__c> pRatePlans = BuildProductRatePlans();
            //System.debug('Product Rate plans built: ' + pRatePlans);
            Cache.Org.put(ProductRatePlansKey, pRatePlans);
            //System.debug('Product Rate Plans put in the cache.');
        }
    }


    public static void LoadCachedItems()
    {
        LoadProductRatePlans();
    }

    //
    // Call QuoteDomain.ForceCacheReload() from annonymous apex to reload the cache
    // 
    public static void ForceCacheReload()
    {
        //System.debug('************************* Reloading the QuoteDomain cache ************************* ');
        Map<String, zqu__ProductRatePlanCharge__c> pRatePlans = BuildProductRatePlans();
        Cache.Org.put(ProductRatePlansKey, pRatePlans);
        //System.debug('*************************  Done ************************* ');
    }

    private static Map<String, zqu__ProductRatePlanCharge__c> BuildProductRatePlans()
    {
        //System.debug('QuoteDomain.BuildProductRatePlans');
        
        Map<String, zqu__ProductRatePlanCharge__c> pRatePlans = new Map<String, zqu__ProductRatePlanCharge__c> ();

        for (zqu__ProductRatePlanCharge__c rPlanCharge :[SELECT Name, Id, zqu__ZuoraId__c,
             zqu__ProductRatePlan__r.zqu__Product__r.Name,
             zqu__ProductRatePlan__r.zqu__Product__r.Description,
             zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c,
             zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c,
             zqu__ProductRatePlan__r.zqu__Product__r.Cost__c,
             zqu__ProductRatePlan__r.zqu__Product__r.ProductShippable__c
             FROM zqu__ProductRatePlanCharge__c])
        {
            if (rPlanCharge.zqu__ZuoraId__c != null)
            {
                pRatePlans.put(rPlanCharge.zqu__ZuoraId__c, rPlanCharge);
            }
            else
            {
                //System.debug(LoggingLevel.ERROR, 'The ZuoraId is blank for ' + rPlanCharge.zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c + '.  It probably needs synced to Zuora.');
            }
        }

        return pRatePlans;
    }
    
    private void LoadRemovedRatePlans()
    {
        //System.debug('QuoteDomain.LoadRemovedRatePlans');

        for (zqu__QuoteRatePlan__c rp :[SELECT Id, Name, zqu__Quote__c, zqu__AmendmentType__c, zqu__QuoteProductName__c
                                        FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c = :this.quote.Id])
        {
            if (rp.zqu__AmendmentType__c == 'RemoveProduct')
            {
                amendmentRemovedOneTimeRatePlans.add(rp);
            }
        }
    }



    public QuoteDomain(ID quoteId)
    {
        //System.debug('QuoteDomain.QuoteDomain');

        usageLineItems = new List<zqu__QuoteRatePlanCharge__c> ();
        oneTimeLineItems = new List<zqu__QuoteRatePlanCharge__c> ();
        pcvLineItems = new List<zqu__QuoteRatePlanCharge__c>();
        axLineItems = new List<zqu__QuoteRatePlanCharge__c>();
        nonAXLineItems = new List<zqu__QuoteRatePlanCharge__c>();
        
        amendmentRemovedOneTimeRatePlans = new List<zqu__QuoteRatePlan__c>();
            
        List<zqu__Quote__c> zQuotes = [SELECT Id
                                        , Name
                                        , zqu__Status__c
                                        , zqu__Opportunity__c
                                        , Customer_Visible__c
                                        , Approval_Status__c
                                        , zqu__ApprovalStatus__c
                                        , zqu__Terms__c
                                        , zqu__SubscriptionType__c
                                        , Amendment_Count__c
                                        , zqu__BillToContact__r.MailingCountry
                                        , Opportunity_Owner__c 
                                       FROM zqu__Quote__c WHERE Id = :quoteId LIMIT 1];

        if (zQuotes.size() > 0)
        {
            this.quote = zQuotes.get(0);
            this.oppId = quote.zqu__Opportunity__c;
        }

        if (this.quote != null)
        {

            if (IsAmendmentQuote())
            {
                LoadRemovedRatePlans();
            }
            
            for (zqu__QuoteRatePlanCharge__c lineitem :[SELECT Id, Name, 
                zqu__QuoteRatePlan__r.zqu__Quote__c, zqu__ListPrice__c, 
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c,
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Cost__c, 
                zqu__Quantity__c, Product_Category__c, zqu__EffectivePrice__c, zqu__ChargeType__c, zqu__Period__c, zqu__ProductName__c,
                zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.ProductShippable__c, zqu__Currency__c
                FROM zqu__QuoteRatePlanCharge__c WHERE zqu__QuoteRatePlan__r.zqu__Quote__c = :this.quote.Id])
            {
                if (lineitem.zqu__ChargeType__c == 'One-Time')
                {
                    oneTimeLineItems.add(lineitem);
                    //Holds only the line items that must be sent to AX for processing.
                    //Per Lauren Lawrence - Services will now be billed throught OpenAir and will not be sent to AX via SFDC Ordering
                    if(lineitem.Product_Category__c != 'Services')
                    {
                        axLineItems.add(lineitem);
                    }
                    else
                    {
                        nonAXLineItems.add(lineitem);
                    }
                }
                else if(lineitem.Product_Category__c == 'Voice Services')
                {
                    pcvLineItems.add(lineitem);
                }
                else
                {
                    usageLineItems.add(lineitem);
                }
            }
        }
        system.Debug('axLineItems: ' + axLineItems);
        system.Debug('nonAxLineItems: ' + nonAxLineItems);
        system.Debug('pcvLineItems: ' + pcvLineItems);
        system.Debug('usageLineItems: ' + usageLineItems);
    }

    public boolean IsAmendmentQuote()
    {
        return this.quote.zqu__SubscriptionType__c == 'Amend Subscription';
    }

    public void PersistQuoteToDB()
    {
        //System.debug('QuoteDomain.PersistQuoteToDB');

        update this.quote;
    }
}