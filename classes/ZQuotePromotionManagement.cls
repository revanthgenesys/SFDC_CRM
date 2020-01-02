//
// This class was added to support promotion parts and the PureCloud Dev Org part
// JIRA: PCPQ-56, PCPQ-52
// 
public class ZQuotePromotionManagement {
    
    Map<String, List<Promotion_Part__c>> promotionBundles;
    
    public ZQuotePromotionManagement()
    {
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.Contructor');
        promotionBundles = LoadPromotions();
    }
    
    // Load the promotions from the Promotion Part and Promotions objects
    private Map<String, List<Promotion_Part__c>> LoadPromotions()
    {
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.LoadPromotions');
        Map<String, List<Promotion_Part__c>> loadedPromotions = new Map<String, List<Promotion_Part__c>> ();
        List<Promotion_Part__c> partsInPromotion;
        promotionBundles = new Map<String, List<Promotion_Part__c>> ();
        
        // Read all the promotion parts and put them in a map for easy searching
        for (Promotion_Part__c part :[SELECT PartToAdd__r.zqu__SKU__c, Discount_Amount__c, Discount_Percent__c, Discount_Length__c, 
                                      Committed_Quantity__c, Included_Usage_Units__c, Billing_Start_Date__c, 
                                      Promotion__r.PromoPart__r.zqu__SKU__c, Promotion__r.Name, Promotion__r.Start_Date__c, 
                                      Promotion__r.End_Date__c FROM Promotion_Part__c])
        {
            if (promotionBundles.containsKey(part.Promotion__r.PromoPart__r.zqu__SKU__c))
            {
                partsInPromotion = promotionBundles.get(part.Promotion__r.PromoPart__r.zqu__SKU__c);
            }
            else
            {
                partsInPromotion = new List<Promotion_Part__c> ();
            }
            partsInPromotion.add(part);
            promotionBundles.put(part.Promotion__r.PromoPart__r.zqu__SKU__c, partsInPromotion);
        }
        
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.LoadPromotions: ' + JSON.serialize(promotionBundles));
        
        return promotionBundles;
    }
    
    public Boolean HasPromotions()
    {
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.HasPromotions');
        Boolean hasPromotions = (promotionBundles != null) && (promotionBundles.size() > 0);
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement -- Has Promotions = ' + hasPromotions);
        return hasPromotions;
    }
    
    
    public void AddPromotions(String quoteId, List<String> addedRatePlans)
    {
        System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.AddPromotions (called from ZQuoteAddRemoveRatePlanPlugin)');
        
        System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.AddPromotions.addedRatePlans: ' + JSON.serialize(addedRatePlans));
        
        zqu__Quote__c quote = [SELECT zqu__Currency__c FROM zqu__Quote__c WHERE Id = :quoteId LIMIT 1];
        
        List<Promotion_Part__c> promotionPartsToAdd = new List<Promotion_Part__c>();
        List<Id> addedPromoProducts = new List<Id>();
        for (zqu__ProductRatePlan__c plan : [SELECT Id, Name, zqu__Description__c, zqu__Product__c FROM zqu__ProductRatePlan__c WHERE Id in :addedRatePlans])
        {
            addedPromoProducts.add(plan.zqu__Product__c);
            /*if (promotionBundles.containsKey(plan.zqu__Product__r.zqu__SKU__c))
            {
                promotionPartsToAdd.addAll(promotionBundles.get(plan.zqu__Product__r.zqu__SKU__c));
            }*/
        }

        
        for (Promotion_Part__c promoPart : [SELECT Product_Rate_Plan__c, PartToAdd__r.zqu__SKU__c, Discount_Amount__c, Discount_Percent__c, Discount_Length__c, 
                                            Committed_Quantity__c, Included_Usage_Units__c, Billing_Start_Date__c, 
                                            Promotion__r.PromoPart__r.zqu__SKU__c, Promotion__r.Name, Promotion__r.Start_Date__c, 
                                            Promotion__r.End_Date__c 
                                            FROM Promotion_Part__c
                                            WHERE Promotion__r.PromoPart__c IN :addedPromoProducts])
        {
            //TODO USE SET INSTEAD TO CHECK FOR DUPES?
            promotionPartsToAdd.add(promoPart);
        }

        /*List<zqu__ProductRatePlanChargeTier__c> productRatePlanChargeTiers = LoadProductRatePlanChargeTiers();
        
        Map<String, zqu__QuoteRatePlan__c> chargeMap = new Map<String, zqu__QuoteRatePlan__c>();
        
        for (zqu__QuoteRatePlan__c qrp : [SELECT Id, Name, zqu__Quote__c, zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c FROM zqu__QuoteRatePlan__c WHERE zqu__Quote__c = :quoteId]) {
            System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.AddPromotions.existing charge: ' + qrp.zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c);
            chargeMap.put(qrp.zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c, qrp);
        }*/
        
        List<zqu.zChargeGroup> chargeGroups = new List<zqu.zChargeGroup>();
        
        for (Promotion_Part__c part : promotionPartsToAdd)
        {                    
            System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.AddPromotions.part: ' + part.PartToAdd__r.zqu__SKU__c);
            
            //List<zqu__ProductRatePlanChargeTier__c> tiers = FindRatePlanTiersForProduct(part.PartToAdd__r, quote.zqu__Currency__c, productRatePlanChargeTiers, chargeMap);
            
            //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.AddPromotions.tiers: ' + JSON.serialize(tiers));
            
            if (part.Product_Rate_Plan__c != null)  
            {
                System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.AddPromotions.add: ' + part.PartToAdd__r.zqu__SKU__c);
                
                Decimal discountPercent = 0;
                Decimal discountAmount = 0;
                Decimal committedQuantity = 0;
                Decimal includedUnits = 0;
                
                if (part.Discount_Percent__c != null)
                {
                    discountPercent = part.Discount_Percent__c;
                }
                
                if (part.Discount_Amount__c != null)
                {
                    discountAmount = part.Discount_Amount__c;
                }
                
                if (part.Included_Usage_Units__c != null)
                {
                    includedUnits = part.Included_Usage_Units__c;
                }
                
                if (part.Committed_Quantity__c != null)
                {
                    committedQuantity = part.Committed_Quantity__c;
                }
                
                /*Set<Id> ratePlanIds = new Set<Id>();
                
                for (zqu__ProductRatePlanChargeTier__c tier : tiers)
                {
                    ratePlanIds.add(tier.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.Id);
                }
                */

                // We can't run any of the zqu.zQuoteUtil methods in a test context so we can't test this part of the code.
                if (!Test.isRunningTest())
                {
                 	zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String> { 'Added_From_Bundle__c', 'Product_Category__c' };   
                    List<zqu.zChargeGroup> partChargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteId, new List<Id>{part.Product_Rate_Plan__c});

                    if ((discountPercent > 0) || (discountAmount > 0) || (includedUnits > 0) || (committedQuantity > 0))
                    {
                        for (zqu.zChargeGroup chargeGroup : partChargeGroups)      
                        {
                            for(zqu.zCharge charge : chargeGroup.zCharges)
                            {
                                zqu__QuoteRatePlanCharge__c qCharge = (zqu__QuoteRatePlanCharge__c)charge.chargeObject;

                                if (discountAmount > 0 &&
                                    (charge.MODEL != 'Overage Pricing' || charge.Name.contains('Edge')))
                                {
                                    Decimal listPrice = Decimal.valueOf(charge.List_Price);
                                    if (listPrice > 0)
                                    {
                                        Decimal effectivePrice = listPrice - discountAmount;
                                        charge.Effective_Price = effectivePrice.toPlainString();
                                        qCharge.Added_From_Bundle__c = true;
                                    }
                                    
                                    chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chargeGroup.zCharges);                                
                                }

                                if (discountPercent > 0 &&
                                    (charge.MODEL != 'Overage Pricing' || charge.Name.contains('Edge')))
                                {
                                    charge.Discount = discountPercent.toPlainString();                                    
                                    chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(chargeGroup.zCharges);
                                    qCharge.Added_From_Bundle__c = true;                                    
                                }
                                
                                if (committedQuantity > 0)
                                {
                                    charge.Quantity = committedQuantity.toPlainString();                                    
                                    chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnQuantityChange(chargeGroup.zCharges);                                    
                                }
                                
                                if (includedUnits > 0)
                                {
                                    charge.Included_Units = includedUnits.toPlainString();
                                }
                            }
                            
                            /*if (discountAmount > 0)
                            {
                                for (zqu.zCharge charge : chargeGroup.zCharges)
                                {
                                    Decimal listPrice = Decimal.valueOf(charge.List_Price);
                                    if (listPrice > 0)
                                    {
                                        Decimal effectivePrice = listPrice - discountAmount;
                                        charge.Effective_Price = effectivePrice.toPlainString();
                                    }
                                }
                                
                                chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnEffectivePriceChange(chargeGroup.zCharges);                                
                            }
                            
                            if (discountPercent > 0)
                            {
                                for (zqu.zCharge charge : chargeGroup.zCharges)
                                {
                                    charge.Discount = discountPercent.toPlainString();
                                }
                                
                                chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnDiscountChange(chargeGroup.zCharges);                                    
                            }
                            
                            if (committedQuantity > 0)
                            {
                                for (zqu.zCharge charge : chargeGroup.zCharges)
                                {
                                    charge.Quantity = committedQuantity.toPlainString();
                                }
                                
                                chargeGroup.zCharges = zqu.zQuoteUtil.calculateChargesOnQuantityChange(chargeGroup.zCharges);                                    
                            }
                            
                            if (includedUnits > 0)
                            {
                                for (zqu.zCharge charge : chargeGroup.zCharges)
                                {
                                    charge.Included_Units = includedUnits.toPlainString();
                                }
                            }*/
                            
                        }
                        
                    }
                    
                    chargeGroups.addAll(partChargeGroups);
                    
                }
                
            }
            else 
            {
                System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.AddPromotions.already exists: ' + part.PartToAdd__r.zqu__SKU__c);
            }
        }
        
        if (chargeGroups.size() > 0)
        {
            System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.AddPromotions Adding charges: ' + chargeGroups.size());
            // We can't run any of the zqu.zQuoteUtil methods in a test context so we can't test this part of the code.
            if (!Test.isRunningTest())
            {
                zqu.zQuoteUtil.addChargeGroups(chargeGroups);
            }
        }
        else {
            System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.AddPromotions No charges to add');
        }    
        
    }
    
    public void DeletePromotions(String quoteId, List<String> removedRatePlans)
    {
        System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.DeletePromotions (called from ZQuoteAddRemoveRatePlanPlugin)');
        
        System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.DeletePromotions.removedRatePlans: ' + JSON.serialize(removedRatePlans));
        
        //List<zqu__ProductRatePlan__c> oldPlans = [SELECT Id, Name, zqu__ZProduct__c, zqu__Description__c, zqu__Product__r.zqu__SKU__c FROM zqu__ProductRatePlan__c WHERE Id in :removedRatePlans];

        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.DeletePromotions.oldPlans: ' + JSON.serialize(oldPlans));
        
        List<Promotion_Part__c> promotionPartsToDelete = new List<Promotion_Part__c>();
        
        List<Id> removedPromoProducts = new List<Id>();
        Set<Id> ratePlansToDelete = new Set<Id>();
        for (zqu__ProductRatePlan__c plan : [SELECT Id, Name, zqu__Description__c, zqu__Product__c FROM zqu__ProductRatePlan__c WHERE Id in :removedRatePlans])
        {
            removedPromoProducts.add(plan.zqu__Product__c);
        }
        
        for (Promotion_Part__c promoPart : [SELECT Product_Rate_Plan__c, PartToAdd__r.zqu__SKU__c, Discount_Amount__c, Discount_Percent__c, Discount_Length__c, 
                                            Committed_Quantity__c, Included_Usage_Units__c, Billing_Start_Date__c, 
                                            Promotion__r.PromoPart__r.zqu__SKU__c, Promotion__r.Name, Promotion__r.Start_Date__c, 
                                            Promotion__r.End_Date__c 
                                            FROM Promotion_Part__c
                                            WHERE Promotion__r.PromoPart__c IN :removedPromoProducts])
        {
            //TODO USE SET INSTEAD TO CHECK FOR DUPES?
            ratePlansToDelete.add(promoPart.Product_Rate_Plan__c);
        }

        //new Map<Id, zqu__ProductRatePlan__c)

        System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.DeletePromotions.promotionPartsToDelete: ' + JSON.serialize(promotionPartsToDelete));

        /*Set<String> productSKUsToDelete = new Set<String>();
        
        for (Promotion_Part__c part : promotionPartsToDelete)
        {
            productSKUsToDelete.add(part.PartToAdd__r.zqu__SKU__c);
        }

        System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.DeletePromotions.productSKUsToDelete: ' + JSON.serialize(productSKUsToDelete));
        
        Set<String> productIdsToDelete = new Set<String>();

        for (zqu__ProductRatePlan__c plan : [SELECT Id FROM zqu__ProductRatePlan__c WHERE zqu__Product__r.zqu__SKU__c in :productSKUsToDelete])
        {
            productIdsToDelete.add(plan.Id);
        }
        
        System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.DeletePromotions.productIdsToDelete: ' + JSON.serialize(productIdsToDelete));
        */
        List<zqu.zChargeGroup> chargeGroupsToDelete = new List<zqu.zChargeGroup>();
        
        // We can't run any of the zqu.zQuoteUtil methods in a test context so we can't test this part of the code.
        if (ratePlansToDelete.size() > 0 && !Test.isRunningTest())
        {
            List<zqu.zChargeGroup> chargeGroups = zqu.zQuoteUtil.getChargeGroups(quoteId);
            
            for (zqu.zChargeGroup chargeGroup : chargeGroups) 
            {
                if (ratePlansToDelete.contains(chargeGroup.productRatePlanId)) 
                {
                    //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.DeletePromotions.delete: ' + chargeGroup.productRatePlanId);
                    chargeGroupsToDelete.add(chargeGroup);
                }
            }
        }
        
        System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.DeletePromotions.chargeGroupsToDelete.size(): ' + chargeGroupsToDelete.size());
        
        if (chargeGroupsToDelete.size() > 0)
        {
            System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.DeletePromotions.Deleting');
            // We can't run any of the zqu.zQuoteUtil methods in a test context so we can't test this part of the code.
            if (!Test.isRunningTest())
            {
                zqu.zQuoteUtil.deleteChargeGroups(chargeGroupsToDelete);
            }
        }        
    }
    
    
    
    private Map<Id, Set<String>> FindProductIds(Map<Id, List<Promotion_Part__c>> quotePartsToDelete) 
    {        
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindProductIds');
        Map<Id, Set<String>> productIdsToDelete = new Map<Id, Set<String>>();
        
        Set<Id> quoteIds = quotePartsToDelete.keySet();
        for (Id quoteId : quoteIds) {    
            //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindProductIds.quoteId: ' + quoteId);
            Set<String> productIds = new Set<String>();
            
            for (Promotion_Part__c part : quotePartsToDelete.get(quoteId)) {
                //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindProductIds.part: ' + JSON.serialize(part));
                productIds.add(part.PartToAdd__r.Id);
            }
            
            productIdsToDelete.put(quoteId, productIds);
        }
        
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindProductIds.productIdsToDelete: ' + JSON.serialize(productIdsToDelete));
        
        return productIdsToDelete;
    }
    
    
    // Find the quotes with promotion part numbers
    private Map<Id, Set<String>> FindPromotions(List<zqu__QuoteRatePlanCharge__c> chargeList)
    {
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindPromotions(QRPC)');
        Map<Id, Set<String>> promotionsFound = new Map<Id, Set<String>> ();
        
        for (zqu__QuoteRatePlanCharge__c charge : chargeList)
        {
            
            //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindPromotions(QRPC).charge: ' + JSON.serialize(charge));
            string searchSKU = charge.SKU__c.substringBefore('-C');            
            //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindPromotions(QRPC).searchSKU: ' + searchSKU);
            
            if (promotionBundles.containsKey(searchSKU))
            {
                AddToStringSetMap(promotionsFound, charge.QuoteId__c, charge.SKU__c);
                //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindPromotions(QRPC).Found: ' + charge.SKU__c);
            }
            
        }
        
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindPromotions(QRPC): ' + promotionsFound.size() + ' promotions found');
        
        return promotionsFound;
    }
    
    private Map<Id, Set<String>> FindPromotions(List<zqu__QuoteAmendment__c> chargeList)
    {
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindPromotions');
        Map<Id, Set<String>> promotionsFound = new Map<Id, Set<String>> ();
        
        for (zqu__QuoteAmendment__c amendment : chargeList)
        {
            
            //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindPromotions.amendment: ' + JSON.serialize(amendment));
            
            List<zqu__QuoteRatePlan__c> ratePlans = [SELECT zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c FROM zqu__QuoteRatePlan__c WHERE zqu__QuoteAmendment__c =: amendment.Id];
            Set<String> SKUs = new Set<String>();
            for (zqu__QuoteRatePlan__c plan : ratePlans) 
            {
                SKUs.add(plan.zqu__ProductRatePlan__r.zqu__Product__r.zqu__SKU__c);
            }
            
            //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindPromotions.SKUs: ' + JSON.serialize(SKUs));
            
            for (String SKU : SKUs) {
                if (promotionBundles.containsKey(SKU))
                {
                    AddToStringSetMap(promotionsFound, amendment.zqu__Quote__c, SKU);
                    //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindPromotions.Found: ' + SKU);
                }
            }
            
        }
        
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindPromotions: ' + promotionsFound.size() + ' promotions found');
        
        return promotionsFound;
    }
    
    
        
    private Map<String, zqu__Quote__c> FindQuotes(Set<Id> quoteIds)
    {
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindQuotes');
        
        Map<String, zqu__Quote__c> quotes = new Map<String, zqu__Quote__c>();
        
        for (zqu__Quote__c q : [SELECT Id, Name, zqu__Currency__c FROM zqu__Quote__c WHERE id IN :quoteIds])
        {
            quotes.put(q.id, q);
        }
        
        return quotes;        
    }
    
    
    private List<zqu__ProductRatePlanChargeTier__c> LoadProductRatePlanChargeTiers()
    {
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.LoadProductRatePlanChargeTiers');
        
        List<zqu__ProductRatePlanChargeTier__c> tiers = [SELECT Id, Name,
                                                         zqu__ZuoraId__c,
                                                         zqu__Currency__c,
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
        
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.LoadProductRatePlanChargeTiers -- Loaded ' + tiers.size() + ' rate tiers');
        
        return tiers;
    }
    
    
    private List<zqu__ProductRatePlanChargeTier__c> FindRatePlanTiersForProduct(Product2 product, String cur, List<zqu__ProductRatePlanChargeTier__c> productRatePlanChargeTiers,  Map<String, zqu__QuoteRatePlan__c> chargeMap)
    {
        System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindRatePlanTiersForProduct');
        
        List<zqu__ProductRatePlanChargeTier__c> tiers = new List<zqu__ProductRatePlanChargeTier__c>();
        
        String searchSKU = product.zqu__SKU__c + '-C';
        
        for (zqu__ProductRatePlanChargeTier__c tier : productRatePlanChargeTiers)
        {
            String currentSKU = tier.zqu__ProductRatePlanCharge__r.SKU__c;
            
            if ((!chargeMap.containsKey(product.zqu__SKU__c)) && (cur == tier.zqu__Currency__c) && (currentSKU.startsWith(searchSKU)))
            {
                System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindRatePlanTiersForProduct.adding: ' + currentSKU);
                tiers.add(tier);
            }
        }
        
        return tiers;
    }
    
    
    
    
    // Find all the parts for the specified promotions
    private Map<Id, List<Promotion_Part__c>> FindParts(Map<Id, Set<String>> promotions)
    {
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindParts');
        
        Map<Id, List<Promotion_Part__c>> parts = new Map<Id, List<Promotion_Part__c>> ();
        
        for (Id id : promotions.keySet())
        {
            //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindParts.id: ' + id);
            
            for (String promoPartNumber : promotions.get(id))
            {
                //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindParts.promoPartNumber: ' + promoPartNumber);
                
                string searchSKU = promoPartNumber.substringBefore('-C');            
                //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindParts.searchSKU: ' + searchSKU);
                
                for (Promotion_Part__c part : promotionBundles.get(searchSKU))
                {
                    //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.FindParts.part: ' + JSON.serialize(part));
                    
                    AddPartToPartsList(parts, id, part);
                }
            }
        }
        
        return parts;
    }
    
    private void AddPartToPartsList(Map<Id, List<Promotion_Part__c>> parts, Id id, Promotion_Part__c part)
    {
        //System.debug(LoggingLevel.INFO, 'ZQuotePromotionManagement.AddPartToPartsList');
        
        List<Promotion_Part__c> partsList;
        
        if (parts.containsKey(id))
        {
            partsList = parts.get(id);
        }
        else
        {
            partsList = new List<Promotion_Part__c> ();
        }
        
        partsList.add(part);
        parts.put(id, partsList);
    }
    
    
    private void AddToStringSetMap(Map<Id, Set<String>> theMap, Id theId, String theString)
    {
        Set<String> theSet;
        
        if (theMap.containsKey(theId))
        {
            theSet = theMap.get(theId);
        }
        else
        {
            theSet = new Set<String> ();
        }
        
        theSet.add(theString);
        theMap.put(theId, theSet);
    }
    
        
}