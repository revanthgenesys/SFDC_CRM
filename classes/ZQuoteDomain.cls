public class ZQuoteDomain {
    
    //Public Fields
    public zqu__Quote__c zQuote;
    public ID opportunityId;

    //Singletone instance
    private static ZQuoteDomain instance = null;
    
    //Lazy Loaded Properties

    private Set<String> independentParts = null;
    
    public List<zqu__QuoteRatePlanCharge__c> zQuoteCharges
    {
        get {
            if (zQuoteCharges == null)
            {
                LoadZQuoteCharges();
            }
            return zQuoteCharges;
        }
        private set;
    }
    
   
    
    private Map<String, List<String>> IndependentToDependentPartsMap
    {
        get {
            //System.debug(LoggingLevel.INFO, 'ZQuoteDomain.IndependentToDependentPartsMap');
            if (IndependentToDependentPartsMap == null)
            {
                LoadIndependentToDependentPartsMap();
            }
            return IndependentToDependentPartsMap;
        }
        private set;
    }
    
   
    
    private void LoadIndependentToDependentPartsMap()
    {
        //System.debug(LoggingLevel.INFO, 'ZQuoteDomain.LoadIndependentToDependentPartsMap');
        
        DependentPartsMappingProvider provider = new DependentPartsMappingProvider();
        IndependentToDependentPartsMap = provider.GetMap();
        
        //System.debug('Loaded Independent To Dependents Parts Map : ' + IndependentToDependentPartsMap);
    }
    
    private void LoadZQuoteCharges()
    {
        //System.debug(LoggingLevel.INFO, 'ZQuoteDomain.LoadZQuoteCharges: ' + ZQuote.Id);
        
        zQuoteCharges = [SELECT zqu__Quantity__c, zqu__EffectivePrice__c,
                         zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Product_Subcategory__c,
                         zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c
                         FROM zqu__QuoteRatePlanCharge__c Where zqu__QuoteRatePlan__r.zqu__Quote__c = :ZQuote.Id];
        
        if (zQuoteCharges.size() == 0)
        {
            zQuoteCharges = new List<zqu__QuoteRatePlanCharge__c> ();
        }
        
        //System.debug('Loaded ' + zQuoteCharges.size() + ' zQuoteCharges : ' + zQuoteCharges);
        
    }
    
    //Private Constructor
    private ZQuoteDomain() { }
    
    //Private Constructor
    private ZQuoteDomain(Id OppId)
    {
        
        //System.Debug('Creating a ZQuoteDomain from OppId');
        
        ZQuoteDomain zqDomain = new ZQuoteDomain();
        
        List<zqu__Quote__c> lstQuotes = [SELECT Name, Annual_Prepay__c, zqu__StartDate__c, zqu__Currency__c, zqu__InitialTerm__c,
                                         zqu__Previewed_MRR__c, zqu__Previewed_TCV__c, Amendment_Count__c, zqu__SubscriptionType__c from zqu__Quote__c where zqu__Opportunity__c = :OppId];
        
        //system.debug(('list quotes size: ' + lstQuotes.size());
        
        
        if (lstQuotes.size() == 0)
        {
            System.debug('No Quote found for Opp Id: ' + OppId);
        }
        else
        {
            this.ZQuote = lstQuotes.get(0);
            opportunityId = OppId;
        }
        
    }
    
    private ZQuoteDomain(Id OppId, Id QuoteId)
    {
        
        //System.Debug('Creating a ZQuoteDomain from OppId and QuoteId');
        
        ZQuoteDomain zqDomain = new ZQuoteDomain();
        
        List<zqu__Quote__c> lstQuotes = [SELECT Name, Annual_Prepay__c, zqu__StartDate__c, zqu__Currency__c, zqu__InitialTerm__c,
                                         zqu__Previewed_MRR__c, zqu__Previewed_TCV__c, Amendment_Count__c, zqu__SubscriptionType__c from zqu__Quote__c where Id = :QuoteId];
        
        //system.debug(('list quotes size: ' + lstQuotes.size());
        
        
        if (lstQuotes.size() == 0)
        {
            System.debug('No Quote found for Quote Id: ' + QuoteId);
        }
        else
        {
            this.ZQuote = lstQuotes.get(0);
            if(String.isNotEmpty(OppId)) opportunityId = OppId;
        }
        
    }
    
    
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //singleton method: lazy loads the zQuote domain object
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static ZQuoteDomain getInstance(ID QuoteId)
    {        
        if (instance == null)
        {
            instance = new ZQuoteDomain(null, QuoteId);
        }
        
        return instance;
    }
    
    public static ZQuoteDomain getInstance(ID OppId, ID QuoteId)
    {
        if (OppId == null)
        {
            return null;
        }
        
        if (instance == null || instance.opportunityId != OppId)
        {
            instance = new ZQuoteDomain(OppId, QuoteId);
        }
        
        return instance;
    }
    
    //adds dependent parts if any independent parts exist
    public void AutoAddDependentCharges()
    {
        //System.debug(LoggingLevel.INFO, 'ZQuoteDomain.AutoAddDependentCharges');
        
        if (zQuote == null)
        {
            System.debug(LoggingLevel.INFO, 'ZQuoteDomain.AutoAddDependentCharges: no quote, can\'t add anything');
            return;
        }        
        
        List<Id> productRatePlanIds = new List<Id>();

        /*List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(zQuote.Id);

        for (zqu.zChargeGroup chargeGroup : chargeGroups)
        {
            // Only add dependent parts for new products for either a new subscription or amendment quote
            if (chargeGroup.groupType == 2 || chargeGroup.groupType == 4)
            {
                productRatePlanIds.add(chargeGroup.productratePlanId);
            }
        }*/

        for (zqu__QuoteRatePlan__c quoteRatePlan : [SELECT Id, zqu__ProductRatePlan__c FROM zqu__QuoteRatePlan__c 
                                                    WHERE zqu__Quote__c = :zQuote.Id 
                                                    AND zqu__AmendmentType__c = 'NewProduct'])
        {
            productRatePlanIds.add(quoteRatePlan.zqu__ProductRatePlan__c);
        }

        //system.debug('ZQuoteDomain.AutoAddDependentCharges Independent Ids ' + productRatePlanIds);
        if (productRatePlanIds.size() > 0)
        {
            Set<Id> dependentRatePlanIds = new Set<Id>();

            // Only add rate plans that do not already exist and are still effective
            for (Dependent_Rate_Plan__c dependentRatePlan : [SELECT Dependent_Rate_Plan__c FROM Dependent_Rate_Plan__c
                                                             WHERE Independent_Rate_Plan__c IN :productRatePlanIds
                                                             AND Dependent_Rate_Plan__c NOT IN :productRatePlanIds
                                                             AND Dependent_Rate_Plan__r.zqu__EffectiveStartDate__c   <= TODAY
                                                             AND Dependent_Rate_Plan__r.zqu__EffectiveEndDate__c     >= TODAY])
            {
                if (!dependentRatePlanIds.contains(dependentRatePlan.Dependent_Rate_Plan__c))
                {
                    dependentRatePlanIds.add(dependentRatePlan.Dependent_Rate_Plan__c);
                }
            }
            
            if (dependentRatePlanIds.size() > 0)
            {
                //system.debug('ZQuoteDomain.AutoAddDependentCharges Dependent Ids ' + dependentRatePlanIds);
                List<zqu.zChargeGroup> newChargeGroups = zqu.zQuoteUtil.getChargeGroups(zQuote.Id, new List<Id>(dependentRatePlanIds));
                //system.debug(LoggingLevel.INFO, 'ZQuoteDomain.AutoAddDependentCharges Adding charges: ' + newChargeGroups.size());
                zqu.zQuoteUtil.addChargeGroups(newChargeGroups);
            }
        }

        /* Original code for legacy reasons
        //List<zqu__QuoteRatePlanCharge__c> totalChargesToAdd = new List<zqu__QuoteRatePlanCharge__c> ();
        Set<String> independentSKUs = new Set<String> ();
        Set<String> dependentSKUs = new Set<String> ();
    
        for (zqu__QuoteRatePlanCharge__c charge : zQuoteCharges)
        {
            if(charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c != null) {
                string sku = charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c.trim();
                if (IsIndependentPart(sku) && !independentSKUs.contains(sku))
                {
                    //system.debug(LoggingLevel.INFO, 'ZQuoteDomain.AutoAddDependentCharges.independent: ' + sku);
                    independentSKUs.add(sku);
                    
                    List<String> dependents = IndependentToDependentPartsMap.get(sku);
                    //system.debug(LoggingLevel.INFO, 'ZQuoteDomain.AutoAddDependentCharges.dependents: ' + JSON.serialize(dependents));
                    dependentSKUs.addAll(dependents);                    
                }
            }
            else
            {
                System.debug(LoggingLevel.INFO, 'ZQuoteDomain.AutoAddDependentCharges: no sku for: ' + JSON.serialize(charge));                    
            }
        }
        
        System.debug('ZQuoteDomain.AutoAddDependentCharges: number parts to add before cleaning: ' + dependentSKUs.size());                    
        dependentSKUs = RemoveExistingDependents(dependentSKUs);
        System.debug('ZQuoteDomain.AutoAddDependentCharges: number parts to add after cleaning: ' + dependentSKUs.size());                    

        if (dependentSKUs.size() > 0)
        {
            List<zqu__ProductRatePlanChargeTier__c> productRatePlanChargeTiers = LoadProductRatePlanChargeTiers();
            Set<Id> ratePlanIds = new Set<Id>();                    
            
            for (String sku : dependentSKUs)
            {
                List<zqu__ProductRatePlanChargeTier__c> tiers = FindRatePlanTiersForProduct(sku, zQuote.zqu__Currency__c, productRatePlanChargeTiers);
                
                system.debug(LoggingLevel.INFO, 'ZQuoteDomain.AutoAddDependentCharges.tiers: ' + JSON.serialize(tiers));
                
                if (tiers.size() > 0) {
                    
                    system.debug(LoggingLevel.INFO, 'ZQuoteDomain.AutoAddDependentCharges.add: ' + sku);
                    
                    for (zqu__ProductRatePlanChargeTier__c tier : tiers)
                    {
                        ratePlanIds.add(tier.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Id);
                    }
                    
                }
                else 
                {
                    System.debug(LoggingLevel.INFO, 'ZQuoteDomain.AutoAddDependentCharges.already exists: ' + sku);
                }
            }
            
            if (ratePlanIds.size() > 0)
            {
                system.debug(LoggingLevel.INFO, 'ZQuoteDomain.AutoAddDependentCharges.ratePlanIds: ' + JSON.serialize(ratePlanIds));
                List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(zQuote.Id, new List<Id>(ratePlanIds));
                system.debug(LoggingLevel.INFO, 'ZQuoteDomain.AutoAddDependentCharges Adding charges: ' + chargeGroups.size());
                zqu.zQuoteUtil.addChargeGroups(chargeGroups);
            }
            else {
                system.debug(LoggingLevel.INFO, 'ZQuoteDomain.AutoAddDependentCharges No charges to add');
            }
            */                          
    }
        
    /*
    private Set<String> RemoveExistingDependents(Set<String> dependents)
    {
        Set<String> cleanedDependents = new Set<String>();
        Set<String> existingCharges = new Set<String>();
        
        if (dependents.size() > 0)
        {
            for (zqu__QuoteRatePlanCharge__c charge : zQuoteCharges)
            {
                String sku = charge.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c.trim();
                System.debug('adding to existing charges: ' + sku);
                existingCharges.add(sku);
            }
    
            for (String sku : dependents)
            {
                if (!existingCharges.contains(sku))
                {
	                System.debug('adding to cleaned dependents: ' + sku);
                    cleanedDependents.add(sku);
                }
            }
    
            return cleanedDependents;
        }
        else
        {
            return dependents;
        }
    }
    
    private List<zqu__ProductRatePlanChargeTier__c> FindRatePlanTiersForProduct(String productSKU, String cur, List<zqu__ProductRatePlanChargeTier__c> productRatePlanChargeTiers)
    {
        System.debug(LoggingLevel.INFO, 'ZQuoteDomain.FindRatePlanTiersForProduct');
        
        List<zqu__ProductRatePlanChargeTier__c> tiers = new List<zqu__ProductRatePlanChargeTier__c>();
        
        String searchSKU = productSKU + '-C';
        
        for (zqu__ProductRatePlanChargeTier__c tier : productRatePlanChargeTiers)
        {
            String currentSKU = tier.zqu__ProductRatePlanCharge__r.SKU__c;
            //DEBUG
            if (currentSKU.startsWith(searchSKU))
            {
                system.debug(LoggingLevel.INFO, 'ZQuoteDomain.FindRatePlanTiersForProduct.searching: ' + currentSKU + ' vs ' + searchSKU);
                system.debug(LoggingLevel.INFO, 'ZQuoteDomain.FindRatePlanTiersForProduct.currency: ' + tier.zqu__Currency__c + ' vs ' + cur);
            }
            // DEBUG
            
            if ((cur == tier.zqu__Currency__c) && (currentSKU.startsWith(searchSKU)))
            {
                system.debug(LoggingLevel.INFO, 'ZQuoteDomain.FindRatePlanTiersForProduct.adding: ' + currentSKU);
                tiers.add(tier);
            }
        } 
        
        return tiers;
    }
    
    private List<zqu__ProductRatePlanChargeTier__c> LoadProductRatePlanChargeTiers()
    {
        System.debug(LoggingLevel.INFO, 'ZQuoteDomain.LoadProductRatePlanChargeTiers');
        
        List<zqu__ProductRatePlanChargeTier__c> tiers = [SELECT Id, Name,
                                                         zqu__ZuoraId__c,
                                                         zqu__Currency2__c,
                                                         zqu__Price__c,
                                                         CurrencyIsoCode,
                                                         zqu__IsOveragePrice__c,
                                                         zqu__ProductRatePlanCharge__r.Id,
                                                         zqu__ProductRatePlanCharge__r.Name,
                                                         zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Name,
                                                         zqu__ProductRatePlanCharge__r.zqu__Apply_Discount_To_One_Time_Charges__c,
                                                         zqu__ProductRatePlanCharge__r.zqu__Apply_Discount_To_Recurring_Charges__c,
                                                         zqu__ProductRatePlanCharge__r.zqu__Apply_Discount_To_Usage_Charges__c,
                                                         zqu__ProductRatePlanCharge__r.zqu__Type__c,
                                                         zqu__ProductRatePlanCharge__r.zqu__Model__c,
                                                         zqu__ProductRatePlanCharge__r.zqu__RecurringPeriod__c,
                                                         zqu__ProductRatePlanCharge__r.zqu__UOM__c,
                                                         zqu__ProductRatePlanCharge__r.zqu__Discount_Level__c,
                                                         zqu__ProductRatePlanCharge__r.zqu__ZuoraId__c,
                                                         zqu__ProductRatePlanCharge__r.SKU__c
                                                         FROM zqu__ProductRatePlanChargeTier__c
                                                         WHERE IsDeleted = false 
                                                         AND zqu__Deleted__c = false 
                                                         AND zqu__ProductRatePlanCharge__r.IsDeleted = false 
                                                         AND zqu__ProductRatePlanCharge__r.zqu__Deleted__c = false
                                                         AND zqu__ProductRatePlanCharge__r.SKU__c != null
                                                         AND zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__EffectiveStartDate__c <= TODAY
                                                         AND zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__EffectiveEndDate__c >= TODAY];
        
        system.debug(LoggingLevel.INFO, 'ZQuoteDomain.LoadProductRatePlanChargeTiers.Loaded: ' + tiers.size());
        
        return tiers;
    }    
    
    
    private boolean IsIndependentPart(string sku)
    {
        if (independentParts == null)
        {
            independentParts = IndependentToDependentPartsMap.keySet();
        }
        return independentParts.contains(sku);
    }
    */
    
    
    
    public static String GetDocumentCategory(String productCategory, zqu__QuoteRatePlanCharge__c qrpCharge)
    {
        //System.debug(LoggingLevel.INFO, 'ZQuoteDomain.GetDocumentCategory');
        
        If (qrpCharge.zqu__ChargeType__c == 'One-Time' || (productCategory == 'Licenses' && qrpCharge.zqu__ChargeType__c == 'Recurring'))
        {
            return 'One-Time Charges';
        }
        else
        {
            If (qrpCharge.zqu__ChargeType__c == 'Usage'
                || (productCategory == 'Services' && qrpCharge.zqu__ChargeType__c == 'Recurring')
                || (productCategory == 'Hardware' && qrpCharge.zqu__ChargeType__c == 'Recurring'))
            {
                return 'Monthly Recurring Charges';
            }
            Else
            {
                return 'Other Charges';
            }
            
        }
        
        
    }
    
    
    public static String GetDocumentSubCategory(String productCategory, String documentCategory, zqu__QuoteRatePlanCharge__c qrpCharge)
    {
        //System.debug(LoggingLevel.INFO, 'ZQuoteDomain.GetDocumentSubCategory');
        
        If (documentCategory == 'One Time')
        {
            If (productCategory == 'Hardware' || productCategory == 'Services')
            {
                return productCategory;
            }
            Else
            {
                return 'Annual Subscription';
            }
        }
        Else
        {
            If (productCategory == 'Licenses')
            {
                zqu__Quote__c quote = [SELECT Annual_PrePay__c FROM zqu__Quote__c WHERE Id = :qrpCharge.QuoteId__c LIMIT 1];
                If ((quote != null) && (quote.Annual_PrePay__c == true))
                {
                    return 'Subscription Overage';
                }
                Else
                {
                    return 'Estimated Subscription Usage';
                }
            }
            Else
            {
                If (productCategory == 'Voice Services')
                {
                    return 'Purecloud Voice';
                }
                Else
                {
                    If (productCategory == 'Services')
                    {
                        return 'Monthly Services';
                    }
                    Else
                    {
                        If (productCategory == 'Hardware')
                        {
                            return 'PureCloud Virtual Edge';
                        }
                        Else
                        {
                            return 'Other';
                        }
                        
                    }
                }
            }
            
        }
        
    }
    
}