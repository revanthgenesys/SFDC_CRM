public class ZQuoteRatePlanChargeManagment {
    Private final static String LicenseModelName = 'Per Unit Pricing';
    Private final static String OverageModelName = 'Overage Pricing';
    
    private Map<Id, zqu__QuoteRatePlanCharge__c> quoteChargesMap;
    private List<zqu__QuoteRatePlanCharge__c> oldCharges;

    // Gets all the QuoteIds
    private Set<Id> QuoteIds
    {
        get
        {
            //System.debug('ZQuoteRatePlanChargeManagment.QuoteIds');

            if (QuoteIds == null)
            {
                QuoteIds = new Set<Id> ();
                for (zqu__QuoteRatePlanCharge__c quoteRatePlanCharge : this.quoteChargesMap.values())
                {
                    QuoteIds.add(quoteRatePlanCharge.QuoteId__c);
                }
            }
            return QuoteIds;
        }
        set;
    }

    // Gets the list of all the Quotes for the changed Quote Rate Plan Charges into a Map
    private Map<Id, zqu__Quote__c> QuotesMap
    {
        get
        {
            //System.debug('ZQuoteRatePlanChargeManagment.QuotesMap');

            if (QuotesMap == null)
            {
                QuotesMap = new Map<Id, zqu__Quote__c> ([SELECT Id, Name, zqu__Currency__c, PCV_Lines_Count__c FROM zqu__Quote__c where id IN :QuoteIds]);
            }
            return QuotesMap;
        }
        set;
    }

    private Map<Id, List<zqu__QuoteRatePlanCharge__c>> QuoteChargesQuoteIdMap
    {
        get
        {
            //System.debug('ZQuoteRatePlanChargeManagment.QuoteChargesQuoteIdMap');

            if (QuoteChargesQuoteIdMap == null)
            {
                QuoteChargesQuoteIdMap = new Map<Id, List<zqu__QuoteRatePlanCharge__c>> ();
                for (zqu__QuoteRatePlanCharge__c charge : this.quoteChargesMap.values())
                {
                    Id quoteId = charge.QuoteId__c;
                    if (!QuoteChargesQuoteIdMap.containsKey(quoteId))
                    {
                        QuoteChargesQuoteIdMap.put(quoteId, new List<zqu__QuoteRatePlanCharge__c> ());
                    }
                    List<zqu__QuoteRatePlanCharge__c> pCharges = QuoteChargesQuoteIdMap.get(quoteId);
                    pCharges.add(charge);
                }
            }
            return QuoteChargesQuoteIdMap;
        }
        set;
    }

    private Map<Id, List<zqu__QuoteRatePlanCharge__c>> AllQuoteChargesforQuoteIdsMap
    {
        get
        {
            //System.debug('ZQuoteRatePlanChargeManagment.AllQuoteChargesforQuoteIdsMap');

            //system.debug(this.QuoteIds);
            //system.debug(this.quoteChargesMap.keySet());
            if (AllQuoteChargesforQuoteIdsMap == null)
            {
                AllQuoteChargesforQuoteIdsMap = new Map<Id, List<zqu__QuoteRatePlanCharge__c>> ();
                for (zqu__QuoteRatePlanCharge__c charge :[SELECT Id, Product_Category__c, QuoteId__c, zqu__Model__c, zqu__Quantity__c, Part_Number__c, zqu__ChargeType__c, zqu__Currency__c, zqu__EffectivePrice__c,
                     zqu__ListTotal__c, zqu__Discount_Level__c, zqu__IncludedUnits__c, Name, SKU__c 
                     FROM zqu__QuoteRatePlanCharge__C WHERE zqu__QuoteRatePlan__r.zqu__Quote__c IN :this.QuoteIds AND Id NOT IN :this.quoteChargesMap.keySet()])
                {
                    Id quoteId = charge.QuoteId__c;
                    if (!AllQuoteChargesforQuoteIdsMap.containsKey(quoteId))
                    {
                        AllQuoteChargesforQuoteIdsMap.put(quoteId, new List<zqu__QuoteRatePlanCharge__c> ());
                    }
                    List<zqu__QuoteRatePlanCharge__c> qCharges = AllQuoteChargesforQuoteIdsMap.get(quoteId);
                    qCharges.add(charge);
                }
                for (Id quoteId : QuoteChargesQuoteIdMap.keySet())
                {
                    if (!AllQuoteChargesforQuoteIdsMap.containsKey(quoteId))
                    {
                        AllQuoteChargesforQuoteIdsMap.put(quoteId, new List<zqu__QuoteRatePlanCharge__c> ());
                    }
                    List<zqu__QuoteRatePlanCharge__c> qCharges = AllQuoteChargesforQuoteIdsMap.get(quoteId);
                    qCharges.addAll(QuoteChargesQuoteIdMap.get(quoteId));
                }
            }
            return AllQuoteChargesforQuoteIdsMap;
        }
        set;
    }

    //Gets the list of all the Product Rate Plans that is cached in the Organization wide Application cache.
    private static Map<String, zqu__ProductRatePlanCharge__c> ProductRatePlans
    {
        get
        {
            //System.debug('ZQuoteRatePlanChargeManagment.ProductRatePlans');

            QuoteDomain.LoadCachedItems();
            ProductRatePlans = QuoteDomain.productRatePlans;
                        
            return ProductRatePlans;
        }
        set;
    }
    
    private ZQuoteRatePlanChargeManagment(Map<Id, zqu__QuoteRatePlanCharge__c> quoteChargesMap, List<zqu__QuoteRatePlanCharge__c> oldCharges)
    {
        this.quoteChargesMap = quoteChargesMap;
        this.oldCharges = oldCharges;
    }

    private ZQuoteRatePlanChargeManagment(Map<Id, zqu__QuoteRatePlanCharge__c> quoteChargesMap)
    {
        this.quoteChargesMap = quoteChargesMap;
        this.oldCharges = null;
    }

    public static void BeforeInsert(List<zqu__QuoteRatePlanCharge__c> newCharges)
    {
        System.debug('ZQuoteRatePlanChargeManagment.BeforeInsert');
        System.debug('Inserted Charges: ' +  newCharges);

        if (newCharges.size() == 0)
        {
            //System.debug('newCharges is empty.');
            return;
        }

        for (zqu__QuoteRatePlanCharge__c qRatePlanCharge : newCharges)
        {
            setEffectivePriceAndTotal(qRatePlanCharge);
            //Anju Feb 2 2018
            qRatePlanCharge.Sub_Category__c = qRatePlanCharge.Sub_Category_Formula__c;
            //loop through the before-insert charges and update the CONGA fields
            
            string zuoraId = qRatePlanCharge.zqu__ProductRatePlanChargeZuoraId__c.trim();
            zqu__ProductRatePlanCharge__c pRatePlanCharge = GetProductRatePlanCharge(zuoraId);

            qRatePlanCharge.Product_Category_Text__c = pRatePlanCharge.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c;

            /* Replaced by formula fields
            String productCategory = pRatePlanCharge.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c;
            qRatePlanCharge.Product_Category__c = productCategory;
            qRatePlanCharge.Conga_Product_Category__c = productCategory;
            qRatePlanCharge.Conga_Product_Description__c = pRatePlanCharge.zqu__ProductRatePlan__r.zqu__Product__r.Description;
            

            String documentCategory = ZQuoteDomain.GetDocumentCategory(productCategory, qRatePlanCharge);
            qRatePlanCharge.Conga_Document_Category__c = documentCategory;
            qRatePlanCharge.Conga_Document_Subcategory__c = ZQuoteDomain.GetDocumentSubCategory(productCategory, documentCategory, qRatePlanCharge);
            */
        }
    }

    public static void BeforeUpdate(Map<Id, zqu__QuoteRatePlanCharge__c> updatedChargesMap, List<zqu__QuoteRatePlanCharge__c> oldCharges)
    {
        System.debug('ZQuoteRatePlanChargeManagment.BeforeUpdate');

        if (updatedChargesMap != null && updatedChargesMap.size() > 0)
        {
            for (zqu__QuoteRatePlanCharge__c charge : updatedChargesMap.values())
            {
                setEffectivePriceAndTotal(charge);
                 //Anju Feb 2 2018
                charge.Sub_Category__c = charge.Sub_Category_Formula__c;
            }

            ZQuoteRatePlanChargeManagment quoteRatePlanManagement = new ZQuoteRatePlanChargeManagment(updatedChargesMap, oldCharges);
            quoteRatePlanManagement.updateIncludedUnits();
            
        }
    }

    @future(callout=true)
    public static void updateQuoteTerms(Id quoteId)
    {
        // Default determined by General Custom Settings
        Boolean annualPrePay = false;
        Integer initialTerm = Integer.valueOf(Zuora_Custom_Settings__c.getValues('ZuoraInitialTerm').Value__c);
        Integer renewalTerm = Integer.valueOf(Zuora_Custom_Settings__c.getValues('ZuoraRenewalTerm').Value__c);
        String termType = initialTerm > 1 ? 'Termed' : 'Evergreen';

        Boolean licensesFound = false;
        Boolean annualFound = false;

        List<Id> productRatePlanIds = new List<Id>();

        zqu__Quote__c quote = [SELECT zqu__SubscriptionType__c
                                , zqu__Subscription_Term_Type__c
                                , zqu__InitialTerm__c
                                , zqu__RenewalTerm__c
                                , Annual_PrePay__c
                                , Bypass_Auto_Terms__c
                               FROM zqu__Quote__c 
                               WHERE Id = :quoteId LIMIT 1];

        if (!quote.Bypass_Auto_Terms__c)
        {
            if (Test.isRunningTest())
            {
                productRatePlanIds.addAll(new List<Id>(new Map<Id, zqu__ProductRatePlan__c>([SELECT Id FROM zqu__ProductRatePlan__c]).keySet()));
            }
            else
            {
                List<zqu.zChargeGroup> zChargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteId);
    
                for (zqu.zChargeGroup chargeGroup : zChargeGroups)
                {
                    if (chargeGroup.groupType != zqu.zChargeGroup.TYPE_AMENDMENT_REMOVEPRODUCT
                    &&  chargeGroup.groupType != zqu.zChargeGroup.TYPE_RENEWAL_REMOVEPRODUCT)
                    {
                        productRatePlanIds.add(chargeGroup.productRatePlanId);
                    }
                }   
            }               
    
            for (zqu__ProductRatePlanCharge__c productRatePlanCharge : [SELECT zqu__RecurringPeriod__c, zqu__Type__c
                                                                        FROM zqu__ProductRatePlanCharge__c
                                                                        WHERE zqu__ProductRatePlan__c IN :productRatePlanIds
                                                                        AND zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c = 'Licenses'])
            {   
                licensesFound = true;
                //system.debug('###zqu__RecurringPeriod__c ' + charge.zqu__ProductRatePlanCharge__r.zqu__RecurringPeriod__c);
                //system.debug('###zqu__Type__c ' + charge.zqu__ProductRatePlanCharge__r.zqu__Type__c );
    
                // If an annual license is found, set quote to annual prepay
                if (productRatePlanCharge.zqu__RecurringPeriod__c == 'Annual')
                {
                    //System.debug('###Annual License Found');
                    annualPrePay = true;
                }
    
                // If a non-usage license charge is found, annual termed
                if (productRatePlanCharge.zqu__Type__c != 'Usage')
                {
                    //System.debug('###Term License Found');
                    initialTerm = 12;
                    renewalTerm = 1;
                    termType = 'Termed';
                    annualFound = true;
                }
                else if (!annualFound)
                {
                    //System.debug('###Evergreen License Found');
                    initialTerm = 1;
                    renewalTerm = 1;
                    termType = 'Evergreen';
                }
            } 
    
            if (licensesFound && (quote.zqu__Subscription_Term_Type__c != termType || quote.Annual_PrePay__c != annualPrePay || quote.zqu__InitialTerm__c != initialTerm))
            {
                quote.zqu__Subscription_Term_Type__c = termType;
                quote.zqu__InitialTerm__c = initialTerm;
                quote.zqu__RenewalTerm__c = renewalTerm;
                quote.Annual_PrePay__c = annualPrePay;
    
                update quote;
            }
        }
    }

    public static void setEffectivePriceAndTotal(zqu__QuoteRatePlanCharge__c quoteRatePlanCharge)
    {
        System.debug('ZQuoteRatePlanChargeManagment.setEffectivePriceAndTotal');

        if (quoteRatePlanCharge != null)
        {
            if (quoteRatePlanCharge.zqu__EffectivePrice__c != null)
            {
                if ((quoteRatePlanCharge.zqu__EffectivePrice__c > 0) && (quoteRatePlanCharge.zqu__EffectivePrice__c.stripTrailingZeros().scale() > 2))
                {
                    quoteRatePlanCharge.zqu__EffectivePrice__c = quoteRatePlanCharge.zqu__EffectivePrice__c.setScale(2, System.RoundingMode.HALF_EVEN);
                }
                
                if (quoteRatePlanCharge.zqu__Quantity__c != null)
                {
                    quoteRatePlanCharge.zqu__Total__c = quoteRatePlanCharge.zqu__EffectivePrice__c * quoteRatePlanCharge.zqu__Quantity__c;
                }
            }
            
            // TODO This does not work...remove?
            // Start PCPQ-76
            /*if (quoteRatePlanCharge.zqu__QuoteRatePlan__r.zqu__Quote__r.Annual_PrePay__c)
            {
                quoteRatePlanCharge.zqu__Total__c = quoteRatePlanCharge.zqu__Total__c * 12;
            }*/
            // End PCPQ-76
        }
    }

    private void updateIncludedUnits()
    {
        System.debug('ZQuoteRatePlanChargeManagment.updateIncludedUnits');

        for (Id id : QuotesMap.keySet())
        {
            Id quoteId = Id;
            zqu__Quote__c quote = QuotesMap.get(quoteId);
            List<zqu__QuoteRatePlanCharge__c> charges = AllQuoteChargesforQuoteIdsMap.get(quoteId);
            Map<String, zqu__QuoteRatePlanCharge__c> PartNumAndItsOverageCharge = new Map<String, zqu__QuoteRatePlanCharge__c> ();
            Map<String, Integer> PartNumberLicenseQty = new Map<String, Integer> ();

            for (zqu__QuoteRatePlanCharge__c charge : charges)
            {
                // Keep all annual license quantaties in sync with the usage included units. 
                if ((charge.Product_Category__c == 'Licenses') && (charge.zqu__ChargeType__c =='Recurring'))
                {
                    // Update included unit of licenses usage if the annual committed quantity has changed.
                    zqu__QuoteRatePlanCharge__c oldCharge = FindOldCharge(charge.Id);
                    if ((oldCharge == null) || (oldCharge.zqu__Quantity__c != charge.zqu__Quantity__c))
                    {
                        zqu__QuoteRatePlanCharge__c usageCharge = FindUsageCharge(charges, charge.SKU__c);
                        if ((usageCharge != null) && ((usageCharge.zqu__IncludedUnits__c == null) || (usageCharge.zqu__IncludedUnits__c != charge.zqu__Quantity__c)))
                        {
                            usageCharge.zqu__IncludedUnits__c = charge.zqu__Quantity__c;
                        }
                    }
                }
                
                if (charge.zqu__Model__c == OverageModelName || charge.zqu__Model__c == LicenseModelName)
                {
                    if (!PartNumberLicenseQty.containsKey(charge.Part_Number__c))
                    {
                        PartNumberLicenseQty.put(charge.Part_Number__c, 0);
                        //System.debug('## PartNumber key included into PartNumberLicenseQty' + PartNumberLicenseQty);
                    }
                    if (charge.zqu__Model__c == LicenseModelName && charge.zqu__Quantity__c != null)
                    {
                        PartNumberLicenseQty.put(charge.Part_Number__c, Integer.Valueof(charge.zqu__Quantity__c));
                        //System.debug('## charge included into PartNumberLicenseQty: ' + charge);
                    }
                    if (charge.zqu__Model__c == OverageModelName)
                    {
                        if (!PartNumAndItsOverageCharge.containsKey(charge.Part_Number__c))
                        {
                            PartNumAndItsOverageCharge.put(charge.Part_Number__c, charge);
                            //System.debug('## Included overage charge map PartNumAndItsOverageCharge' + PartNumAndItsOverageCharge.get(charge.Part_Number__c));
                        }
                    }
                }
            }

            //System.debug('## PartNumberLicenseQty' + PartNumberLicenseQty + ' and its count: ' + PartNumberLicenseQty.size());
            for (String partNumber : PartNumberLicenseQty.keySet())
            {
                zqu__QuoteRatePlanCharge__c overageCharge = PartNumAndItsOverageCharge.get(partNumber);
                //System.debug('## overage charge - ' + overageCharge);
                if (overageCharge != null && (overageCharge.zqu__IncludedUnits__c == null || Integer.Valueof(overageCharge.zqu__IncludedUnits__c) == 0))
                {
                    //System.debug('## overage charge being processed');
                    Integer qty = PartNumberLicenseQty.get(partNumber);
                    //System.debug('## qty to be setup for Included Units for the overage charge - ' + qty);
                    if (qty != 0)
                    {
                        // Before Trigger - Includes the new values before the record is saved, an explicit save is not necessary
                        overageCharge.zqu__IncludedUnits__c = qty;
                        //System.debug('## overage charge after Included Units update - ' + overageCharge);
                    }
                }
            }
        }
    }

    private zqu__QuoteRatePlanCharge__c FindOldCharge(Id chargeId)
    {
        System.debug('ZQuoteRatePlanChargeManagment.FindOldCharge');
        zqu__QuoteRatePlanCharge__c foundCharge = null;
        
        for (zqu__QuoteRatePlanCharge__c charge : oldCharges)
        {
            if (charge.Id == chargeId)
            {
                foundCharge = charge;
                break;
            }
        }
        
        return foundCharge;
    }

    private zqu__QuoteRatePlanCharge__c FindUsageCharge(List<zqu__QuoteRatePlanCharge__c> charges, String sku)
    {
        System.debug('ZQuoteRatePlanChargeManagment.FindUsageCharge');
        zqu__QuoteRatePlanCharge__c foundCharge = null;
        String trimmedSKU = sku.substring(0, (sku.length() - 3));
        for (zqu__QuoteRatePlanCharge__c charge : charges)
        {
            if (charge.SKU__c.startsWith(trimmedSKU) && (charge.Product_Category__c == 'Licenses') && (charge.zqu__ChargeType__c =='Usage'))
            {
                foundCharge = charge;
                break;
            }
        }
        
        return foundCharge;
    }

    public static Id GetOppId(zqu__QuoteRatePlanCharge__c qRatePlanCharge)
    {
        System.debug('ZQuoteRatePlanChargeManagment.FindOldCharge');
    
        //System.debug('passed qRatePlanCharge to GetOppId: ' + qRatePlanCharge);
        Id qrpId = qRatePlanCharge.zqu__QuoteRatePlan__c;
        List<zqu__QuoteRatePlan__c> plans = [SELECT zqu__Quote__r.zqu__Opportunity__c  FROM zqu__QuoteRatePlan__c where Id = :qrpId];
        if (plans.size() == 0)
        {
            System.debug('ERROR: No Quote Rate Plan record found for this id:' + qrpId);
            return null;
        }

        return plans.get(0).zqu__Quote__r.zqu__Opportunity__c;
    }


    public static zqu__ProductRatePlanCharge__c GetProductRatePlanCharge(String zuoraId)
    {
        System.debug('ZQuoteRatePlanChargeManagment.GetProductRatePlanCharge');

        zqu__ProductRatePlanCharge__c pRatePlan = new zqu__ProductRatePlanCharge__c();
        if (ProductRatePlans.containsKey(zuoraId) == true)
        {
            pRatePlan = ProductRatePlans.get(zuoraId);
        }
        else
        {
            System.debug('no item found in pRatePlanMap with key(zuora id): ' + zuoraId);
        }

        return pRatePlan;
    }

}