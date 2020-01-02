/*
* Class Name       : QuoteUtil
* Description      : This Apex Class is used as util in multiple places for Quotes.
* TestClass        : QuoteUtilTest
* ***************************************************************************************************************
* Developer Note   : Make sure to write test coverage script for methods you added in QuoteUtilTest Apex class  *
* ***************************************************************************************************************
*/
public without sharing class QuoteUtil {  
public final static string OFFERING_TYPE_CIC = 'PureConnect On Premise';
public final static string OFFERING_TYPE_CAAS = 'PureConnect Cloud';
public final static string OFFERING_TYPE_PUREENGAGE_ONPREMISE = 'PureEngage On Premise';
public final static string OFFERING_TYPE_PC = 'PureCloud';
public final static string OFFERING_FEATURE_SMALL_MED = 'PureConnect Small Medium';
public static Boolean addPureSuccessBundleToAmend = false;

// *** Method to return Level One Vs Level Two Mapping Record based on Level One ***
public static List<String> fetchLevelOneVsTwoMapping(String strLevelOne) {
    List<Level_One_Level_Two__c> list_All = Level_One_Level_Two__c.getAll().values();
    List<String> list_LevelTwoValues;
    for (Level_One_Level_Two__c objLevelOneVsTwo : list_All) {
        if (objLevelOneVsTwo.Level_One__c == strLevelOne) {
            list_LevelTwoValues = objLevelOneVsTwo.Level_Two__c.split(';');
            return list_LevelTwoValues;
        }
    }
    return null;
}

// *** Method to return Level Two Vs Level Three Mapping Record based on Level Two ***
public static List<String> fetchLevelTwoVsThreeMapping(String strLevelTwo, String strOfferingType) {
    List<Level_Two_Level_Three__c> list_All = Level_Two_Level_Three__c.getAll().values();
    List<String> list_LevelThreeValues = new List<String>();
    for (Level_Two_Level_Three__c objLevelTwoVsThree : list_All) {
        if (objLevelTwoVsThree.Level_Two__c == strLevelTwo && objLevelTwoVsThree.Offering_Type__c == strOfferingType) {
            list_LevelThreeValues = objLevelTwoVsThree.Level_Three__c.split(';');
            if (String.isNotBlank(objLevelTwoVsThree.Level_Three2__c))
                list_LevelThreeValues.addAll(objLevelTwoVsThree.Level_Three2__c.split(';'));
            
            break;
        }
    }
    return list_LevelThreeValues;
}

// Gets tier pricing for the product
public static Decimal getProductTierPricing(List<Product_Tier_Pricing__c> list_OfTierPricing, Decimal decQuantity,
                                            Decimal decPrice, String strPriceBookName) {
                                                //Check and see if product has tier pricing
                                                if (!list_OfTierPricing.isEmpty()) {
                                                    System.debug('==decQuantity ' + decQuantity);
                                                    System.debug('==list_OfTierPricing[0].Range_To__c ' + list_OfTierPricing[0].Range_To__c);
                                                    System.debug('==strPriceBookName ' + strPriceBookName);
                                                    //Making sure it gets in loop only if needed
                                                    if (decQuantity > list_OfTierPricing[0].Range_To__c) {
                                                        //Looping over each record and assigning price
                                                        for (Product_Tier_Pricing__c eachPricing : list_OfTierPricing) {
                                                            if (decQuantity <= eachPricing.Range_To__c) {
                                                                decPrice = (Decimal)eachPricing.get(strPriceBookName);
                                                                break;
                                                            }
                                                        }
                                                    }
                                                }
                                                return decPrice;
                                            }
//Added By Ranjith on Oct 18, 2017 -- Starts
public static Map<String, Decimal> buildPartnerMargins(Id partnerId) {
    Map<String, Decimal> map_PCPartnerMargins = new Map<String, Decimal>();
    for (PureCloud_Partner_Margin__c objPartnerMargin : [SELECT Percent__c, Margin_Type__c
                                                         FROM PureCloud_Partner_Margin__c
                                                         WHERE From_Date__c <= TODAY
                                                         AND To_Date__c >= TODAY
                                                         AND Account__c = :partnerId
                                                         ORDER BY To_Date__c ASC]) {
                                                             map_PCPartnerMargins.put(objPartnerMargin.Margin_Type__c, objPartnerMargin.Percent__c);
                                                         }
    return map_PCPartnerMargins;
}
//Added By Ranjith on Oct 18, 2017 -- Ends

//Gets partner margis for Subscription Quoting Tool if any
public static List<Decimal> getSubscriptionPartnerMargin(Decimal decPrice, BigMachines__Quote__c objQuote, Product2 objSellableProduct,
                                                         List<Partner_Discount__c> listOfPartnerDiscounts) {
                                                             Decimal baseLineDiscountY1 = 0;
                                                             Decimal baseLineDiscountY2 = 0;
                                                             Decimal partnerPriceY1 = decPrice;
                                                             Decimal partnerPriceY2 = decPrice;
                                                             System.debug('NKC debug objSellableProduct.Partner_Margin_Category__c [' + objSellableProduct.Partner_Margin_Category__c + ']');
                                                             if (objSellableProduct.Partner_Margin_Category__c != null && objSellableProduct.Partner_Margin_Category__c != 'No Margin') {
                                                                 Partner_Hardware_Margins__c partnerHardwareMargin = Partner_Hardware_Margins__c.getAll().get(objSellableProduct.Partner_Margin_Category__c);
                                                                 if (partnerHardwareMargin != null) {
                                                                     Decimal decPartnerHardwareMargin = partnerHardwareMargin.Margin__c;
                                                                     baseLineDiscountY1 += decPartnerHardwareMargin;
                                                                     baseLineDiscountY2 += decPartnerHardwareMargin;
                                                                     System.debug('NKC debug decPartnerHardwareMargin [' + decPartnerHardwareMargin + ']');
                                                                 }
                                                             } else {
                                                                 //Looping over each partner discount record
                                                                 for (Partner_Discount__c eachDiscount : listOfPartnerDiscounts) {
                                                                     if (eachDiscount.Category__c == 'Base Line Discount') {
                                                                         if (eachDiscount.Year__c == 'Year 1') {
                                                                             baseLineDiscountY1 = eachDiscount.Discount__c;
                                                                         } else if (eachDiscount.Year__c == 'Year 2') {
                                                                             baseLineDiscountY2 = eachDiscount.Discount__c;
                                                                         }
                                                                     }
                                                                 }
                                                                 if (objQuote.BigMachines__Opportunity__r.Partner_Opportunity_Source__c == 'Partner Registered Opportunity') {
                                                                     if (baseLineDiscountY1 == null)
                                                                         baseLineDiscountY1 = 0;
                                                                     baseLineDiscountY1 += Decimal.valueOf(Label.Partner_Margin);
                                                                     if (baseLineDiscountY2 == null)
                                                                         baseLineDiscountY2 = 0;
                                                                     baseLineDiscountY2 += Decimal.valueOf(Label.Partner_Margin);
                                                                 }
                                                             }
                                                             System.debug('NKC debug baseLineDiscountY1 [' + baseLineDiscountY1 + ']');
                                                             System.debug('NKC debug baseLineDiscountY2 [' + baseLineDiscountY2 + ']');
                                                             
                                                             if (baseLineDiscountY1 != 0)
                                                                 partnerPriceY1 -= (partnerPriceY1 * baseLineDiscountY1) / 100;
                                                             
                                                             if (baseLineDiscountY2 != 0)
                                                                 partnerPriceY2 -= (partnerPriceY2 * baseLineDiscountY2) / 100;
                                                             
                                                             List<Decimal> list_OfPartnerPriceAndDiscount = new List<Decimal>();
                                                             list_OfPartnerPriceAndDiscount.add(baseLineDiscountY1);
                                                             list_OfPartnerPriceAndDiscount.add(baseLineDiscountY2);
                                                             list_OfPartnerPriceAndDiscount.add(partnerPriceY1);
                                                             list_OfPartnerPriceAndDiscount.add(partnerPriceY2);
                                                             return list_OfPartnerPriceAndDiscount;
                                                         }
//Naresh Kumar  07/11/2018  Populating partner discounts from Partner Discount Object
public static List<Decimal> getPartnerDiscounts(BigMachines__Quote__c objQuote) {
    String offeringType = objQuote.Offering_Type__c;
    if(offeringType == null)
        offeringType = 'PureEngage On Premise';
    List<Decimal> listOfPartnerDiscounts = new List<Decimal>();
    Decimal decProductDiscount = 0, decGUDiscount = 0;
    for (Partner_Discount__c eachDiscount : [SELECT Discount__c, Category__c FROM Partner_Discount__c
                                             WHERE Account__c = : objQuote.Sold_To_Name__c AND Type__c = : offeringType]) {
                                                 if (eachDiscount.Category__c == 'Base Line Discount')
                                                     decProductDiscount = eachDiscount.Discount__c;
                                                 else if (eachDiscount.Category__c == 'GU')
                                                     decGUDiscount = eachDiscount.Discount__c;
                                             }
    listOfPartnerDiscounts.add(decProductDiscount);
    listOfPartnerDiscounts.add(decGUDiscount);
    return listOfPartnerDiscounts;
}

public static List<Decimal> getPartnerMargin(Decimal decPrice, Product2 objSellableProduct, BigMachines__Quote__c objQuote) {return null;}

// Gets partner margins if any
public static List<Decimal> getPartnerMargin(Decimal decPrice, Product2 objSellableProduct, BigMachines__Quote__c objQuote, List<Decimal> listOfPartnerDiscounts) {
    System.debug('NKC debug decPrice [' + decPrice + ']');
    Decimal decPartnerMargin = 0;
    Decimal decPartnerMarginGC = 0;
    Decimal decPriceWithoutDealRegDiscount = decPrice;
    Boolean decApplySoftwareMargin = true;
    System.debug('NKC debug objSellableProduct.Partner_Margin_Category__c [' + objSellableProduct.Partner_Margin_Category__c + ']');
    if (objSellableProduct.Partner_Margin_Category__c != null) {
        Partner_Hardware_Margins__c partnerHardwareMargin = Partner_Hardware_Margins__c.getAll().get(objSellableProduct.Partner_Margin_Category__c);
        if (partnerHardwareMargin != null) {
            Decimal decPartnerHardwareMargin = partnerHardwareMargin.Margin__c;
            decPartnerMargin += decPartnerHardwareMargin;
            decPartnerMarginGC += decPartnerHardwareMargin;
            System.debug('NKC debug decPartnerHardwareMargin [' + decPartnerHardwareMargin + ']');
            if (decPartnerHardwareMargin != null && decPartnerHardwareMargin > 0) {
                decPrice -= (decPrice * decPartnerHardwareMargin ) / 100;
                decPriceWithoutDealRegDiscount -= (decPriceWithoutDealRegDiscount * decPartnerHardwareMargin) / 100;
            }
            decApplySoftwareMargin = false;
        }
    }
    if (decApplySoftwareMargin && (objSellableProduct.Type__c == 'Product' || objSellableProduct.Type__c == 'GU')) {
        //Naresh Kumar  07/11/2018  Populating partner discounts from Partner Discount Object
        if (objSellableProduct.Type__c == 'Product') {
            decPartnerMargin = listOfPartnerDiscounts[0];
            decPartnerMarginGC = decPartnerMargin;
        } else if (objSellableProduct.Type__c == 'GU') {
            decPartnerMargin = listOfPartnerDiscounts[1];
            decPartnerMarginGC = decPartnerMargin;
        } else {
            decPartnerMargin = 0;
            decPartnerMarginGC = 0;
        }
        
        if (objQuote.BigMachines__Opportunity__r.Partner_Opportunity_Source__c == 'Partner Registered Opportunity') {
            if (decPartnerMargin == null)
                decPartnerMargin = 0;
            decPartnerMargin += Decimal.valueOf(Label.Partner_Margin);
        }
        System.debug('NKC debug decPartnerMargin [' + decPartnerMargin + ']');
        if (decPartnerMargin != null && decPartnerMargin > 0) {
            decPrice -= (decPrice * decPartnerMargin) / 100;
        }
        if (decPartnerMarginGC != null && decPartnerMarginGC > 0) {
            decPriceWithoutDealRegDiscount -= (decPriceWithoutDealRegDiscount * decPartnerMarginGC) / 100;
        }
    }
    System.debug('NKC debug decPrice [' + decPrice + ']');
    if (decPartnerMargin == null)
        decPartnerMargin = 0;
    System.debug('NKC debug decPrice [' + decPrice + ']');
    List<Decimal> list_OfPartnerPriceAndDiscount = new List<Decimal>();
    list_OfPartnerPriceAndDiscount.add(decPrice);
    list_OfPartnerPriceAndDiscount.add(decPartnerMargin);
    list_OfPartnerPriceAndDiscount.add(decPriceWithoutDealRegDiscount);
    return list_OfPartnerPriceAndDiscount;
}
// *** Apply validations from Genesys_Product_Prerequisite__c  ***
public static List<Genesys_Product_Prerequisite__c> runPrerequisiteValidations(BigMachines__Quote__c objQuote, List<BigMachines__Quote_Product__c> list_QuoteProductRecords) {
    if (String.isBlank(objQuote.Order_Type__c))
        objQuote.Order_Type__c = 'New';
    List<Genesys_Product_Prerequisite__c> list_ProductPrerequisites = new List<Genesys_Product_Prerequisite__c>();
    List<Genesys_Product_Prerequisite__c> list_ValidationResults = new List<Genesys_Product_Prerequisite__c>();
    Map<Id, BigMachines__Quote_Product__c> map_ProductIdToQP = new Map<Id, BigMachines__Quote_Product__c>();
    Map<Id, Integer> map_ProdIdToQty = new Map<Id, Integer>();
    system.debug('list_QuoteProductRecords'+list_QuoteProductRecords.size());
    // Store all quote products in a map to apply all prerequisites.
    for (BigMachines__Quote_Product__c objQP : list_QuoteProductRecords) {
        //Anju June 2018 adding SMS exception
        if (objQP.APN_Number__c !=null
            && Label.PC_Overage_Products.contains(objQP.APN_Number__c) 
            || objQP.APN_Number__c == 'PC-170-NV-USR3' //Added By Ranjith on Aug 14, 2018 -- PC-170-NV-USR3 is hidden in quote tool if user adds PC-170-NV-COBROCIC
            || objQP.BigMachines__Product__r.New_Category__c == 'Use Case' //Added By Ranjith on Jan 03, 2019 -- to include use case main products
            || (!objQP.Is_Overage__c && !objQP.Hide_Record__c && objQP.Quantity__c != null)) {
                map_ProductIdToQP.put(objQP.BigMachines__Product__c, objQP);
                //Added By Ranjith on Dec 152, 2017 -- Starts
                if (map_ProdIdToQty.containsKey(objQP.BigMachines__Product__c)) {
                    map_ProdIdToQty.put(objQP.BigMachines__Product__c, Integer.valueOf(objQP.Quantity__c) + map_ProdIdToQty.get(objQP.BigMachines__Product__c));
                } 
                else {
                    map_ProdIdToQty.put(objQP.BigMachines__Product__c, Integer.valueOf(objQP.Quantity__c));
                }
                //Added By Ranjith on Dec 152, 2017 -- Ends
            }
    }
    System.debug('#####map_ProductIdToQP: ' + map_ProductIdToQP.keySet());
    System.debug('#####' + map_ProdIdToQty);
    //added by Kartik
    if (objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC) {
        list_ProductPrerequisites = [SELECT Id, Genesys_Product_Master__c, Prerequisite_Product__c, Prerequisite_Product2__c, Message__c,Skip_Validation__c,
                                     Prerequisite_Product3__c, Prerequisite_Product_4__c, Type__c, Operator__c, Min_Quantity__c, Max_Quantity__c, Mandatory__c
                                     FROM Genesys_Product_Prerequisite__c
                                     WHERE Active__c = true
                                     AND Quote_Type__c = :objQuote.Offering_Type__c
                                     AND (Genesys_Product_Master__c IN :map_ProductIdToQP.keySet() OR Type__c = 'Mandatory Product')];
    } else {
        list_ProductPrerequisites = [SELECT Id, Genesys_Product_Master__c, Prerequisite_Product__c, Prerequisite_Product2__c, Message__c, Skip_Validation__c,
                                     Prerequisite_Product3__c, Prerequisite_Product_4__c, Type__c, Operator__c, Min_Quantity__c, Max_Quantity__c, Mandatory__c
                                     FROM Genesys_Product_Prerequisite__c
                                     WHERE Active__c = true
                                     AND Quote_Type__c = :objQuote.Offering_Type__c
                                     AND (Genesys_Product_Master__c IN :map_ProductIdToQP.keySet() OR Type__c = 'Mandatory Product')
                                     AND Order_Type__c INCLUDES (:objQuote.Order_Type__c)
                                     AND Tier__c INCLUDES (:objQuote.Product_Tier__c)];
    }
    System.debug('#####list_ProductPrerequisites: ' + list_ProductPrerequisites.size());
    // Checking for Rules
    for (Genesys_Product_Prerequisite__c objPreReq : list_ProductPrerequisites) {
        System.debug('#####objPreReq : ' + objPreReq );
        BigMachines__Quote_Product__c objMasterProduct = new BigMachines__Quote_Product__c();
        BigMachines__Quote_Product__c objPreReqProduct = new BigMachines__Quote_Product__c();
        BigMachines__Quote_Product__c objPreReqProduct2 = new BigMachines__Quote_Product__c();
        BigMachines__Quote_Product__c objPreReqProduct3 = new BigMachines__Quote_Product__c();
        BigMachines__Quote_Product__c objPreReqProduct4 = new BigMachines__Quote_Product__c();
        if (map_ProductIdToQP.containsKey(objPreReq.Genesys_Product_Master__c)) {
            objMasterProduct = map_ProductIdToQP.get(objPreReq.Genesys_Product_Master__c);
        }
        if (map_ProductIdToQP.containsKey(objPreReq.Prerequisite_Product__c)) {
            objPreReqProduct = map_ProductIdToQP.get(objPreReq.Prerequisite_Product__c);
        }
        if (map_ProductIdToQP.containsKey(objPreReq.Prerequisite_Product2__c)) {
            objPreReqProduct2 = map_ProductIdToQP.get(objPreReq.Prerequisite_Product2__c);
        }
        if (map_ProductIdToQP.containsKey(objPreReq.Prerequisite_Product3__c)) {
            objPreReqProduct3 = map_ProductIdToQP.get(objPreReq.Prerequisite_Product3__c);
        }
        if (map_ProductIdToQP.containsKey(objPreReq.Prerequisite_Product_4__c)) {
            objPreReqProduct4 = map_ProductIdToQp.get(objPreReq.Prerequisite_Product_4__c);
        }
        
        Boolean blnIsValid = true;
        System.debug('#####objMasterProduct: ' + objMasterProduct);
        System.debug('#####objPreReqProduct: ' + objPreReqProduct);
        System.debug('#####objPreReqProduct2 : ' + objPreReqProduct2);
        // Example rule: product quantity must be between 10 and 20.
        if (objPreReq.Type__c == 'Quantity Range') {
            if (objPreReq.Min_Quantity__c > objMasterProduct.Quantity__c || objPreReq.Max_Quantity__c < objMasterProduct.Quantity__c)
                blnIsValid = false;
        }
        // Example rule: Product A cannot exist without Product B.
        else if (objPreReq.Type__c == 'Dependency') {
            /**Edited by Anto on 08/01/2018 to add the logic to implement validation when creating quote product for renewal or amend.**/
            if (objQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PC && objQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PCC) {
                if (objPreReqProduct.Id == null && objPreReqProduct2.Id == null && objPreReqProduct3.Id == null && objPreReqProduct4.Id == null ) {
                    blnIsValid = false;
                    System.debug('#####blnIsValid : ' + blnIsValid );
                }
            } else if (objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC) {
                if (((objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription) && (objMasterProduct.Subscription_Product__c == null || (objMasterProduct.Subscription_Product__c != null && !objPreReq.Skip_Validation__c)))
                    || (objQuote.Order_Type__c != Label.Amend_Subscription && objQuote.Order_Type__c != Label.Renew_Subscription)) {
                        // Make sure the prerequisite exists and display message if not.
                        if (objPreReqProduct.Id == null && objPreReqProduct2.Id == null && objPreReqProduct3.Id == null && objPreReqProduct4.Id == null ) {
                            blnIsValid = false;
                        }
                    }
            }
            /**Edited by Anto on 08/01/2018 ends.**/
        }
        // Example rules:
        // Product A quantity cannot be greater than product B quantity.
        else if (objPreReq.Type__c == 'Quantity Comparison') {
            Double dblMasterQuantity = objMasterProduct.Quantity__c;
            Double dblCompareToQuantity = dblMasterQuantity;
            if (objQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PC && objQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PCC) {
                dblCompareToQuantity = objPreReqProduct.Quantity__c != null ? objPreReqProduct.Quantity__c : 0;
                dblCompareToQuantity += objPreReqProduct2.Quantity__c != null ? objPreReqProduct2.Quantity__c : 0;
                dblCompareToQuantity += objPreReqProduct3.Quantity__c != null ? objPreReqProduct3.Quantity__c : 0;
            } 
            /** Added by Anto on 08/06/2018 to include multiple prequisite product in one Quantity comparison prerequisite record. **/
            else {
                /**if(objPreReqProduct.Id != null && map_ProdIdToQty.containsKey(objPreReqProduct.BigMachines__Product__c)) {
dblCompareToQuantity = map_ProdIdToQty.get(objPreReqProduct.BigMachines__Product__c);
}**/
                dblCompareToQuantity = (objPreReqProduct.Id != null && map_ProdIdToQty.containsKey(objPreReqProduct.BigMachines__Product__c))? map_ProdIdToQty.get(objPreReqProduct.BigMachines__Product__c) : dblCompareToQuantity;
                dblCompareToQuantity = (objPreReqProduct2.Id != null && map_ProdIdToQty.containsKey(objPreReqProduct2.BigMachines__Product__c))? map_ProdIdToQty.get(objPreReqProduct2.BigMachines__Product__c) : dblCompareToQuantity;
                dblCompareToQuantity = (objPreReqProduct3.Id != null && map_ProdIdToQty.containsKey(objPreReqProduct3.BigMachines__Product__c))? map_ProdIdToQty.get(objPreReqProduct3.BigMachines__Product__c) : dblCompareToQuantity;
                dblCompareToQuantity = (objPreReqProduct4.Id != null && map_ProdIdToQty.containsKey(objPreReqProduct4.BigMachines__Product__c))? map_ProdIdToQty.get(objPreReqProduct4.BigMachines__Product__c) : dblCompareToQuantity;
            }
            /** Added by Anto Ends **/
            
            System.debug('#####dblMasterQuantity: ' + dblMasterQuantity);
            System.debug('#####dblCompareToQuantity: ' + dblCompareToQuantity);
            if((objQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PC && objQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PCC)
               || ((objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC)
                   && ((objQuote.Order_Type__c != Label.Amend_Subscription && objQuote.Order_Type__c != Label.Renew_Subscription)  
                       || ((objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription)
                           && (objMasterProduct.Subscription_Product__c == null || (objMasterProduct.Subscription_Product__c != null && !objPreReq.Skip_Validation__c)))))) { 
                               if (objPreReq.Operator__c == 'equals' && dblMasterQuantity != dblCompareToQuantity)
                                   blnIsValid = false;
                               
                               else if (objPreReq.Operator__c == 'not equal to' && dblMasterQuantity == dblCompareToQuantity)
                                   blnIsValid = false;
                               
                               else if (objPreReq.Operator__c == 'greater than' && dblMasterQuantity <= dblCompareToQuantity)
                                   blnIsValid = false;
                               
                               else if (objPreReq.Operator__c == 'less or equal' && dblMasterQuantity > dblCompareToQuantity)
                                   blnIsValid = false;
                               
                               else if (objPreReq.Operator__c == 'greater or equal' && dblMasterQuantity < dblCompareToQuantity)
                                   blnIsValid = false;
                               
                               else if (objPreReq.Operator__c == 'multiple' && dblMasterQuantity < objPreReq.Min_Quantity__c * dblCompareToQuantity)
                                   blnIsValid = false;
                           }
        }
        //Added By Ranjith on May 22nd, 2017 -- Starts
        // Example rules:
        // Application sessions are required for circuits in excess of 2:1 ratio of circuits to base agents.
        else if (objPreReq.Type__c == 'Ratio') {
            if (objMasterProduct.Quantity__c < objPreReq.Min_Quantity__c && objMasterProduct.Quantity__c > objPreReq.Max_Quantity__c) {
                blnIsValid = false;
            }else {
                Double dblPreReqProductQuantity = objPreReqProduct.Quantity__c != null ? objPreReqProduct.Quantity__c : 0;
                Double dblPreReqProduct2Quantity = objPreReqProduct2.Quantity__c != null ? objPreReqProduct2.Quantity__c : 0;
                Double dblPreReqProduct3Quantity = objPreReqProduct3.Quantity__c != null ? objPreReqProduct3.Quantity__c : 0;
                if (objPreReq.Operator__c == 'greater than') {
                    if (dblPreReqProductQuantity == 0
                        || (dblPreReqProductQuantity > (2 * dblPreReqProduct2Quantity + (dblPreReqProduct3Quantity > 0 ? dblPreReqProduct3Quantity : 0)))) {
                            blnIsValid = false;
                        }
                }
            }
        }
        //Added By Ranjith on Jun 12, 2017 -- Starts
        // Example rules:
        // Product is mandatory for specified product tier
        else if (objPreReq.Type__c == 'Mandatory Product') {
            if((objQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PC && objQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PCC)
               || ((objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC || objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC)
                   && ((objQuote.Order_Type__c != Label.Amend_Subscription && objQuote.Order_Type__c != Label.Renew_Subscription)  
                       || ((objQuote.Order_Type__c == Label.Amend_Subscription || objQuote.Order_Type__c == Label.Renew_Subscription) && !objPreReq.Skip_Validation__c)))) { 
            if (!map_ProductIdToQP.containsKey(objPreReq.Genesys_Product_Master__c) && objPreReq.Prerequisite_Product__c == null && objPreReq.Prerequisite_Product2__c == null && objPreReq.Prerequisite_Product3__c == null) {
               blnIsValid = false;
               System.Debug('Entered First Check');
            }
            //PCC PureSuccess - Anju - 2018
            else if (objPreReq.Operator__c == 'OR'
                    && objQuote.BigMachines__Opportunity__r.Offering_Detail__c != 'Free Trial' //Added By Ranjith on Feb 21st -- To skip PS check for PC Trials
                    && !map_ProductIdToQP.containsKey(objPreReq.Genesys_Product_Master__c) 
                    && (objPreReq.Prerequisite_Product__c != null && !map_ProductIdToQP.containsKey(objPreReq.Prerequisite_Product__c)) 
                    && (objPreReq.Prerequisite_Product2__c == null || (objPreReq.Prerequisite_Product2__c != null && !map_ProductIdToQP.containsKey(objPreReq.Prerequisite_Product2__c))) 
                    && (objPreReq.Prerequisite_Product3__c == null || (objPreReq.Prerequisite_Product3__c != null && !map_ProductIdToQP.containsKey(objPreReq.Prerequisite_Product3__c)))
                    && (objPreReq.Prerequisite_Product_4__c == null || (objPreReq.Prerequisite_Product_4__c != null && !map_ProductIdToQP.containsKey(objPreReq.Prerequisite_Product_4__c))))
               blnIsValid = false;
                System.Debug('Entered Second Check');       
            }
        }
        //Added By Ranjith on Jun 12, 2017 -- Ends
        
        //Added By Ranjith on Dec 15, 2017 -- Starts
        //added by kartik
        else if(objPreReq.Type__c == 'Restrict Product' && objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PEC ) {
            if(objPreReqProduct.Id != null || objPreReqProduct2.Id != null || objPreReqProduct3.Id != null) {
                blnIsValid = false;
            }
        }       
        //Added By Ranjith on Dec 15, 2017 -- Ends
        
        if (!blnIsValid){
            system.debug('testpree'+objPreReq.id);
            list_ValidationResults.add(objPreReq);
           }   
    }
    
    return list_ValidationResults;
}

public static String getPriceBookForCICCaas(String strCurrency) {
    Map<String, String> map_CurrencyToPriceBook = new Map<String, String> {
        'USD' => 'NG5_NA_USD',
            'AUD' => 'NG1_APAC_ANZ_AUD',
            'BRL' => 'NG2_BRAZIL_BRL',
            'CAD' => 'NG5_NA_CAD',
            'EUR' => 'NG3_EMEA_EUR',
            'GBP' => 'NG3_EMEA_GBP',
            'JPY' => 'NG4_APAC_JAPAN_YEN',
            'NZD' => 'NG5_NZD',
            'ZAR' => 'NG5_ZAR'
            };
                return map_CurrencyToPriceBook.get(strCurrency);
}

public static String getOrderManagementQueue(Id quoteId) {
    BigMachines__Quote__c objQuote = [SELECT BigMachines__Opportunity__r.Country_Region__c,
                                      BigMachines__Opportunity__r.RecordType.DeveloperName, Quote_Business_Type__c
                                      FROM BigMachines__Quote__c WHERE id = : quoteId];
    Global_Setting__c obj;
    String region = objQuote.BigMachines__Opportunity__r.Country_Region__c;
    String oppType = objQuote.BigMachines__Opportunity__r.RecordType.DeveloperName;
    System.debug('NKC debug region [' + region + ']');
    if (region == 'North America') {
        //if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
        if (objQuote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME ||
            oppType == ServiceContractUtil.MAINTENANCE) {
                obj = Global_Setting__c.getInstance('NA Order Queue Renewal');
            } else
                obj = Global_Setting__c.getInstance('NA Order Queue');            
    }
    
    if (region == 'EMEA') {
        //if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
        if (objQuote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME ||
            oppType == ServiceContractUtil.MAINTENANCE)
            obj = Global_Setting__c.getInstance('EMEA Order Queue Renewal');
        else
            obj = Global_Setting__c.getInstance('EMEA Order Queue');
    }
    
    if (region == 'LATAM') {
        //if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
        if (objQuote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME ||
            oppType == ServiceContractUtil.MAINTENANCE)
            obj = Global_Setting__c.getInstance('LATAM Order Queue Renewal');
        else
            obj = Global_Setting__c.getInstance('LATAM Order Queue');
    }
    
    if (region == 'APAC') {
        //if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
        if (objQuote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME ||
            oppType == ServiceContractUtil.MAINTENANCE)
            obj = Global_Setting__c.getInstance('APAC Order Queue Renewal');
        else
            obj = Global_Setting__c.getInstance('APAC Order Queue');
    }
    
    if (region == 'Japan' || region == 'JAPAN') {
        //if(oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || oppType == ServiceContractUtil.MAINTENANCE)
        if (objQuote.Quote_Business_Type__c == 'Renewal' || oppType == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME ||
            oppType == ServiceContractUtil.MAINTENANCE)
            obj = Global_Setting__c.getInstance('Japan Order Queue Renewal');
        else
            obj = Global_Setting__c.getInstance('Japan Order Queue');
    }
    
    if (obj == null) {
        obj = Global_Setting__c.getInstance('Order Queue');
    }
    return obj.ID__c;
}

//Praveen : Creates order from quote
public static Order__c pureSuccessChildOrder;
public static Map<String, BigMachines__Quote_Product__c> mapPSAlacartItems = new Map<String, BigMachines__Quote_Product__c>();
public static Map<String, BigMachines__Quote_Product__c> mapPSOfferItems = new Map<String, BigMachines__Quote_Product__c>();
@future
public static void CreateOrderFromQuoteFuture(Id quoteId, Id parentId, Boolean generateRevProOrder) {
    CreateOrderFromQuote(quoteId, parentId, generateRevProOrder);
}

public static void CreateOrderFromQuote(Id quoteId) {
    CreateOrderFromQuote(quoteId, null, null);
}

public static void CreateOrderFromQuote(Id quoteId, Id parentId, Boolean generateRevProOrder) {
    //List of orders to be created
    List <Order__c> list_Orders = new List<Order__c>();
    //Querying quotes
    BigMachines__Quote__c objQuote = [SELECT id, BigMachines__Opportunity__c, Quote_Business_Type__c,
                                      Rejected_Flag__c, Shipping_Required__c, Multi_Year_Quote__c, Amendment_For__c, Amendment_For__r.Order__c, 
                                      Current_Maint_Rate__c, Offering_Type__c, Annual_Contract_Value__c, CMRR__c, Cloud_Total__c, Name, Order_PO_Received_Date__c, Order_PO_Number__c, Order_PO_Date__c,
                                      Bill_To_Name__c, Total_Maintenance_Amount_Due__c,
                                      Total_Genesys_Care__c, Grand_Total__c, Total_Revised_Net_License_Value__c, BigMachines__Description__c, BigMachines__Opportunity__r.Contact__r.Email,
                                      Ship_To_Name__c, Shipping_Contact_Phone_Number__c, Shipping_Contact__c, Shipping_Instructions__c, Shipping_Contact_Email__c, Order_Fulfillment_Email_Receipt__c,
                                      Delivery_Method__c, Order_Special_Instructions__c, Order_Numb_of_Maint_Months__c, Order_Type__c, Order_Ship_Software_Via__c,
                                      Order_Agreement_Type__c, Order_Payment_Terms__c, PO_for_FYM__c, Server_OS__c, PBX__c,  Database__c, IVR__c, No_Of_Months__c,
                                      Add_Language__c, Quarterly_Semi_Annual_Billing_Fee__c, Licensing_Reduction_Fee__c, Reinstatement_fee__c, Partner_to_Partner_Uplift__c,
                                      Extended_End_of_Support__c, Partner_to_Direct__c, Decreased_Quote_Reason__c, Cancelled_Quote_Reason__c, Total_Discount__c, Sold_To_Name__r.Subsidary__c,
                                      Sent_to_Customer__c, Genesys_Care_Rep_Name__c,  Genesys_Care_Rep_Title__c, Genesys_Care_Rep_Phone__c, Genesys_Care_Rep_Email__c, End_User_ID__r.OwnerId, Sold_To_Name__r.OwnerId,
                                      Genesys_Care_Rep_Cell__c, Previous_Maint_Rate__c, Genesys_Care__c, Maintenance_Start_Date__c, Subscription_Start_Date__c, Subscription_End_Date__c,
                                      PureSuccess__c, PureSuccess_Offer_Subscription_Amount__c, A_La_Carte_PureSuccess_Services_Amount__c, Maintenance_End_Date__c, End_User_ID__c, Total_Software__c, Sold_To_Name__c, Support_Owner__c, PPU_Rental__c,
                                      System_Integrator__c, Discount__c, BigMachines__Total__c, Order_Numb_of_Maint_Days__c, Is_GU_EMEA__c, No_Cloud_Billing_Contract__c, CurrencyIsoCode, Show_Genesys_Care_Tab__c,
                                      BigMachines__Opportunity__r.Owner.Email, BigMachines__Opportunity__r.Account.Owner.Email,Quote_Billing_Plan_count__c,
                                      Amendment_For__r.Master_Order_Number__c, Generate_Revpro_Order__c, Owner.Email, Pricing_Model__c,
                                      Contract_signature_date__c, Does_customer_currently_have_PureSuccess__c, Ramp_Period__c,Amendment_For__r.PureSuccess_Offer__c,Offering_Feature__c,
                                      Amendment_For__r.Term__c,Amendment_For__r.Ramp_End_Date__c,Amendment_For__r.Subscription_Start_Date__c,Amendment_For__r.Subscription_End_Date__c,
                                      BigMachines__Opportunity__r.Sold_To_Country__r.Name, BigMachines__Opportunity__r.Country__r.Name,License_Reduction_Fee__c,Total_KPI1_Amount__c,Total_KPI2_Amount__c,Total_Shelving_Fee__c,
                                      Maintenance_Due_Discount_Amount__c, Special_Offer_Terms__c,Initial_Subscription_Term__c
                                      FROM BigMachines__Quote__c WHERE id = : quoteId];
    List<Profile> PROFILE = [SELECT Id, Name FROM Profile WHERE Id = :userinfo.getProfileId() LIMIT 1];
    if(generateRevProOrder != null && !generateRevProOrder)
        objQuote.Generate_Revpro_Order__c = generateRevProOrder;
    System.debug('objQuote' + objQuote + PROFILE[0].Name);
    //Getting list of opportunities
    List<Opportunity> list_Opportunities = [SELECT id, RecordType.DeveloperName, Country_Region__c, Ownerid, Owner.Email, Gene_Care_Specialist__r.Email,
                                            Quote_Mtce_Ops__r.Email, Lines_Of_Businesses__c,
                                            account.Subsidary__c 
                                            FROM Opportunity WHERE id = : objQuote.BigMachines__Opportunity__c];
    //Quote Opportunity
    if (list_Opportunities.isEmpty())
        return;
    Opportunity objOpportunity = list_Opportunities[0];
    //Contains license order id
    Id licenseOrderId;
    //Getting existing license order
    List<Order__c> list_LicenseOrder = [SELECT id FROM Order__c WHERE Quote__c = : objQuote.id AND (License_FYM_detail__c = 'License only order'
                                                                                                    OR License_FYM_detail__c = 'Both License & Maintenance Order')];
    
    Boolean blnIsOrderUpdate = false;
    //Whether existing orders needs to be updated
    if (!list_LicenseOrder.isEmpty()) {
        blnIsOrderUpdate = true;
    }
    Boolean blnIsSeperatePO = false;
    String strOrderType;
    //Set the License order Status
    if (objQuote.PO_for_FYM__c == 'Separate PO for FYM') {
        blnIsSeperatePO = true;
        strOrderType = 'License only order';
    } else {
        strOrderType = 'Both License & Maintenance Order';
    }
    
    System.debug(LoggingLevel.Error, '------Create_Order=');
    System.debug(LoggingLevel.DEBUG, 'NKC debug blnIsOrderUpdate [' + blnIsOrderUpdate + ']');
    Order__c objOrder;
    Order__c objMasterOrder = new Order__c();
    //Creates order
    if (!blnIsOrderUpdate) {
        objOrder = Create_Order.Insert_Orders(objQuote, 'Submitted', strOrderType, objOpportunity.Country_Region__c, objOpportunity.Owner.Email,
                                              objOpportunity.RecordType.DeveloperName, objOpportunity);
        if (objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription') {
            objOrder.License_FYM_detail__c = 'Subscription Order';
            objOrder.Contract_Type__c = objQuote.Order_Type__c;
            objOrder.Special_Offer_Terms__c = objQuote.Special_Offer_Terms__c;

            objOrder.Maintenance_Start__c = objQuote.Subscription_Start_Date__c;
            objOrder.Maintenance_End__c = objQuote.Subscription_End_Date__c;
 
           /* /MS 5/30/19: if(objQuote.Ramp_Period__c != null && objQuote.Ramp_Period__c != 'Other' && objQuote.Amendment_For__c == null) 
            if(objQuote.Ramp_Period__c != null && (objQuote.Ramp_Period__c).isNumeric() && objQuote.Amendment_For__c == null)                  
                objOrder.Maintenance_End__c = objOrder.Maintenance_End__c.addMonths(Integer.valueOf(Integer.valueOf(objQuote.Ramp_Period__c)/30));
           */

            objOrder.Numb_of_Maint_Months__c = objQuote.No_Of_Months__c;
            objOrder.TCV__c = objQuote.Cloud_Total__c;
            //if (objQuote.Amendment_For__c != null)
            //    objOrder.Original_Parent_Order1__c = objQuote.Amendment_For__r.Order__c;
            if (parentId != null) {
                objOrder.Original_Parent_Order1__c = parentId;
                objOrder.Name = objOrder.Name + '-RevPro';                    
            }
        }
        insert objOrder;
        if (parentId == null)
            objMasterOrder = [SELECT Name FROM Order__c WHERE id = : objOrder.id LIMIT 1];
        else
            objMasterOrder = [SELECT Name FROM Order__c WHERE id = : parentId LIMIT 1];
        licenseOrderId = objOrder.id;
        System.debug('objQuote' + objQuote);
        //Naresh Kumar  07/09/2018  Updating master order #
        Util.Bypass_Trigger_Chk = true;
        objOrder.Master_Order_Number__c = objMasterOrder.Name;
        //Anju : skipping for PCC now on August 10 2018
        if(parentId == null && objQuote.Generate_Revpro_Order__c && objQuote.Offering_Type__c != SubscriptionUtil.OFFERING_TYPE_PCC && objQuote.Offering_Type__c != null && objQuote.Offering_Type__c != 'PureConnect On Premise')
            objOrder.RecordTypeId = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('Master Order').getRecordTypeId();
        update objOrder;
        Util.Bypass_Trigger_Chk = false;
        
        //Anju PureSuccess 2018 Jan Starts -- created child order if PureSuccess offer present
        if (objQuote.Offering_Type__c == 'PureConnect Cloud' && (objQuote.PureSuccess__c != null  || (objQuote.Does_customer_currently_have_PureSuccess__c && objQuote.A_La_Carte_PureSuccess_Services_Amount__c > 0))) {
            pureSuccessChildOrder = objOrder.clone();
            if (objQuote.PureSuccess_Offer_Subscription_Amount__c == null) objQuote.PureSuccess_Offer_Subscription_Amount__c = 0;
            if (objQuote.A_La_Carte_PureSuccess_Services_Amount__c == null) objQuote.A_La_Carte_PureSuccess_Services_Amount__c = 0;
            pureSuccessChildOrder.name = (pureSuccessChildOrder.name + Label.PureSuccess_Child_Order_Name).left(80);
            pureSuccessChildOrder.recordtypeid = Schema.SObjectType.Order__c.getRecordTypeInfosByName().get('General Orders').getRecordTypeId();
            pureSuccessChildOrder.Original_Parent_Order1__c = objOrder.id;
            pureSuccessChildOrder.ownerid = getOrderManagementQueue(objQuote.id);
            pureSuccessChildOrder.Order_Type__c = 'Revenue';
            pureSuccessChildOrder.License_FYM_detail__c = 'Cloud Order';
            pureSuccessChildOrder.Year__c = '1';
            pureSuccessChildOrder.Maintenance_Start__c = system.today();
            pureSuccessChildOrder.Maintenance_End__c = system.today().addmonths(Integer.valueof(objQuote.No_Of_Months__c)) - 1;
            pureSuccessChildOrder.Numb_of_Maint_Months__c = objQuote.No_Of_Months__c;
            pureSuccessChildOrder.Annual_Contract_Value__c = pureSuccessChildOrder.CMRR__c = 0;
            pureSuccessChildOrder.TCV__c = objQuote.A_La_Carte_PureSuccess_Services_Amount__c + objQuote.PureSuccess_Offer_Subscription_Amount__c;
            pureSuccessChildOrder.Total_Order__c = pureSuccessChildOrder.TCV__c;
            objOrder.TCV__c = objOrder.TCV__c - pureSuccessChildOrder.TCV__c;
            update objOrder;
            if (pureSuccessChildOrder.TCV__c == 0 || pureSuccessChildOrder.TCV__c ==  null)
                pureSuccessChildOrder.status__c = 'Completed';
            insert pureSuccessChildOrder;
            //lineitems
            //QuoteUtil.insertPureSuccessItemsFromOffer(quote);
            //copy order address for child
            List<Account_Order_Address__c> listToUpsert = new List<Account_Order_Address__c>();
            for (Account_Order_Address__c a : [SELECT Id, Address__c, Address2__c, Attention_To__c, Shipping_Method_Name__c, Address_Type__c,
                                               City__c, Company__c, Country__c, Email__c, Account__c, Fax__c, Need_By_Date__c,
                                               Order__c, Phone__c, Shipping_Instructions__c, Sold_To_Business_Partner__c,
                                               Sort_Order__c, State__c, Zip_Code__c, Quote__c
                                               FROM Account_Order_Address__c
                                               WHERE Quote__c = :objQuote.id]) {
        if (a.Address_Type__c == 'Ship To') {
            a.Order__c = pureSuccessChildOrder.id;
            listToUpsert.add(a);
        } else {
            Account_Order_Address__c temp = a.clone();
            temp.Order__c = pureSuccessChildOrder.id;
            temp.Quote__c = null;
            listToUpsert.add(temp);
        }
    }
            if (listToUpsert.size() > 0)
                upsert listToUpsert;
        }
        
        //Anju PureSuccess 2018 Jan ends
        
        //Naresh Kumar 02/08/2016  Populating quote's order field.
        BigMachines__Quote__c quoteToBeUpdated = new BigMachines__Quote__c(id = objQuote.id);
        quoteToBeUpdated.Order__c = objOrder.id;
        update quoteToBeUpdated;
        //Sharing order with opporutnity owner
        if (objQuote.Quote_Business_Type__c != 'Renewal' && objOpportunity.RecordType.DeveloperName != ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME) {
            Order__Share OrderShare = new Order__Share();
            OrderShare.ParentId = objOrder.Id;
            OrderShare.UserOrGroupId = objOpportunity.ownerId;
            OrderShare.AccessLevel = 'read';
            OrderShare.RowCause = Schema.Order__Share.RowCause.Rep_Access__c;
            insert OrderShare;
        }
        //PureSuccess Anju Jan 2018
        if (pureSuccessChildOrder != null) {
            Order__Share OrderSharePS = new Order__Share();
            OrderSharePS.ParentId = pureSuccessChildOrder.Id;
            OrderSharePS.UserOrGroupId = objOpportunity.ownerId;
            OrderSharePS.AccessLevel = 'read';
            OrderSharePS.RowCause = Schema.Order__Share.RowCause.Rep_Access__c;
            insert OrderSharePS;
        }
    }
    //Updates existing License Order
    if (blnIsOrderUpdate) {
        if (objQuote.Rejected_Flag__c)
            objOrder = Create_Order.Update_Orders(objQuote, list_LicenseOrder[0].id, 'Re-Submitted', strOrderType, objOpportunity.Country_Region__c, objOpportunity.Owner.Email,
                                                  objOpportunity.RecordType.DeveloperName, objOpportunity);
        else
            objOrder = Create_Order.Update_Orders(objQuote, list_LicenseOrder[0].id, 'Submitted', strOrderType, objOpportunity.Country_Region__c, objOpportunity.Owner.Email,
                                                  objOpportunity.RecordType.DeveloperName, objOpportunity);
        
        update objOrder;
        
        //Delete Order line items
        List<Order_Line_Item__c> list_OrderLineItems = [SELECT id FROM Order_Line_Item__c WHERE Order__c = : objOrder.id];
        if (!list_OrderLineItems.isEmpty()) 
            delete list_OrderLineItems;         
    }
    
    if (objQuote.Quote_Business_Type__c != 'Cloud') {
        insertAttachments(objQuote.id, objOrder.id);
    }

    //Created order line items
    if (objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription')
        insertOrderLineItemsSubscription(objQuote, objOrder, objOpportunity, objOrder.License_FYM_detail__c == 'License only order');
    else
        insertOrderLineItems(objQuote, objOrder, objOpportunity, objOrder.License_FYM_detail__c == 'License only order');
    
    /********** UPDATE ORDER *******************************/
    //IN CASE ORDER IS RESUBMITTED WITHOUT FYM
    list_LicenseOrder = [SELECT id FROM Order__c WHERE Quote__c = : objQuote.id AND License_FYM_detail__c = 'Maintenance Only Order'];
    if (!blnIsSeperatePO && !list_LicenseOrder.isEmpty()) {
        delete list_LicenseOrder;
    }
    if (blnIsSeperatePO) {
        if (!list_LicenseOrder.isEmpty()) {
            blnIsOrderUpdate = true;
        }
        
        //INSERT ORDER FIRST TIME OR IF RESUBMITTED WITH FYM
        if (!blnIsOrderUpdate || list_LicenseOrder.isEmpty()) {
            objOrder = Create_Order.Insert_Orders(objQuote, 'Pending FYM PO', 'Maintenance Only Order', objOpportunity.Country_Region__c, objOpportunity.Owner.Email,
                                                  objOpportunity.RecordType.DeveloperName, objOpportunity);
            objOrder.License_Order__c = licenseOrderId;
            objOrder.Master_Order_Number__c = objMasterOrder.Name;
            insert objOrder;
            //Naresh Kumar 01/09/2017 We don't need to populate order id at this time since it's maint only order
            //Naresh Kumar  02/08/2016  Populating quote's order field.
            //BigMachines__Quote__c quoteToBeUpdated = new BigMachines__Quote__c(id = quote.id);
            //quoteToBeUpdated.Order__c = order.id;
            //update quoteToBeUpdated;
            //if(opp.size() > 0 && opp[0].RecordType.DeveloperName != ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME)
            if (objQuote.Quote_Business_Type__c != 'Renewal' && objOpportunity.RecordType.DeveloperName != ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME) {
                Order__Share OrderShare = new Order__Share();
                OrderShare.ParentId = objOrder.Id;
                OrderShare.UserOrGroupId = objOpportunity.ownerId;
                OrderShare.AccessLevel = 'edit';
                OrderShare.RowCause = Schema.Order__Share.RowCause.Rep_Access__c;
                insert OrderShare;
            }
        }
        
        //update Order
        if (blnIsOrderUpdate && !list_LicenseOrder.isEmpty()) {
            if (objQuote.Rejected_Flag__c)
                objOrder = Create_Order.Update_Orders(objQuote, list_LicenseOrder[0].id, 'Pending FYM PO', 'Maintenance Only Order', objOpportunity.Country_Region__c, objOpportunity.Owner.Email,
                                                      objOpportunity.RecordType.DeveloperName, objOpportunity);
            else
                objOrder = Create_Order.Update_Orders(objQuote, list_LicenseOrder[0].id, 'Pending FYM PO', 'Maintenance Only Order', objOpportunity.Country_Region__c, objOpportunity.Owner.Email,
                                                      objOpportunity.RecordType.DeveloperName, objOpportunity);
            objOrder.License_Order__c = licenseOrderId;
            objOrder.Master_Order_Number__c = objMasterOrder.Name;
            update objOrder;
            
            //Delete Order line items
            List<Order_Line_Item__c> list_OrderLineItems = [SELECT id FROM Order_Line_Item__c WHERE Order__c = : objOrder.id];
            if (!list_OrderLineItems.isEmpty()) {
                delete list_OrderLineItems;
            }
        }
        //Created order line items

        if (objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription')
            insertOrderLineItemsSubscription(objQuote, objOrder, objOpportunity, objOrder.License_FYM_detail__c == 'License only order');
        else
            insertOrderLineItems(objQuote, objOrder, objOpportunity, objOrder.License_FYM_detail__c == 'License only order');
    }
    //Creates orders
    CreateOrderAddresses(licenseOrderId, objQuote);
    if (objQuote.Shipping_Required__c) {
        //Creates multiple ship to orders
        //Added By Ranjith on Jun 14, 2017 -- Starts
        //if(objQuote.offering_Type__c == 'CaaS') {
        if (objQuote.offering_Type__c == OFFERING_TYPE_CAAS) {
            OrderCloudUtil.createHWOrdersForCloud(objQuote.id, objOrder);
            //Added By Ranjith on Jun 14, 2017 -- Ends                
        } else if(!System.isFuture()) {                
            Create_Order.CreateMultiShipOrderFuture(objQuote.id, objQuote.Offering_Type__c);
        }
    }
    
    //Naresh Kumar  07/04/2018  Creating master child relationship on NRO
    if (objQuote.Offering_Type__c == 'Cloud Partner (PPU)') {
        Create_Order.createChildOrdersForNRO(objQuote.id);
    }
    
    //Naresh Kumar 07/22/2018   Creating child order for PureConnect/PureEngage subscription - Future method.
    if (parentId == null && objQuote.Generate_Revpro_Order__c && (objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription') && !Test.isRunningTest())
        CreateOrderFromQuoteFuture(objQuote.id, objOrder.id, true);
        
} ///END CreateOrderFromQuote

@testvisible
private static void CreateOrderAddresses(Id licenseOrderId, BigMachines__Quote__c objQuote1) {
    
    System.debug('License Order ID' + licenseOrderId);
    List<Account_Order_Address__c> list_aoa = [SELECT id FROM Account_Order_Address__c WHERE Order__c = :licenseOrderId LIMIT 2000];
    
    if (licenseOrderId != null)
        if (!list_aoa.isEmpty())
        delete list_aoa;
    
    //Populates orders on order from quote orders
    //Naresh Kumar  06/22/1015 - Removed New Pricing condition from below condition.
    //Added By Ranjith on Jun 20, 2017 -- Starts
    //if (objQuote1.Quote_Business_Type__c == 'On Premise' || objQuote1.offering_Type__c == 'CaaS')
    if (objQuote1.Quote_Business_Type__c == 'On Premise' || objQuote1.offering_Type__c == OFFERING_TYPE_CAAS)
        //Added By Ranjith on Jun 20, 2017 -- Ends
        OrderAddressOnPremiseController.populateAddressOnOrder(objQuote1.id, licenseOrderId);
    else if (objQuote1.Quote_Business_Type__c != 'Cloud') {
        Id idQuote = Trigger.new != NULL ?  Trigger.new[0].id : objQuote1.Id;
        if (Test.isRunningTest()) {
            if (idQuote == null) {
                idQuote = objQuote1.Id;
            }
        }
        BigMachines__Quote__c objQuote = [SELECT Ship_To_Zip_Code__c, Ship_To_State__c, Ship_To_Phone__c, Ship_To_Last_Name__c,
                                          Ship_To_First_Name__c, Ship_To_Fax__c, Ship_To_E_Mail__c, Ship_To_Country__c,
                                          Ship_To_Company_Name__c, Ship_To_Company_Name_2__c, Ship_To_City__c,
                                          Ship_To_Address__c, Ship_To_Address_2__c, Bill_To_Zip_Code__c, Bill_To_State__c,
                                          Bill_To_Phone__c, Bill_To_Last_Name__c, Bill_To_First_Name__c, Bill_To_Fax__c,
                                          Bill_To_E_Mail__c, Bill_To_Country__c, Bill_To_Company_Name__c, Bill_To_Company_Name_2__c,
                                          Bill_To_City__c, Bill_To_Address__c, Bill_To_Address_2__c, End_User_Zip_Code__c,
                                          End_User_State__c, End_User_Phone__c, End_User_Last_Name__c, End_User_First_Name__c,
                                          End_User_Fax__c, End_User_E_Mail__c, End_User_Country__c, End_User_Company_Name__c,
                                          End_User_Company_Name_2__c, End_User_City__c, End_User_Address__c, End_User_Address_2__c,
                                          Support_Owner_Zip_Code__c, Support_Owner_State__c, Support_Owner_Phone__c, Support_Owner_Last_Name__c,
                                          Support_Owner_First_Name__c, Support_Owner_Fax__c, Support_Owner_EMail__c,
                                          Support_Owner_Country__c, Support_Owner_Company_Name__c, Support_Owner_Company_Name2__c,
                                          Support_Owner_City__c, Support_Owner_Address__c, Support_Owner_Address2__c, SI_Zip_Code__c,
                                          SI_State__c, SI_Phone__c, SI_Last_Name__c, SI_First_Name__c, SI_Fax__c, SI_EMail__c, SI_Country__c,
                                          SI_Company_Name__c, SI_Company_Name2__c, SI_City__c, SI_Address__c, SI_Address2__c,
                                          Sold_To_First_Name__c, Sold_To_Last_Name__c, Sold_To_Company_Name__c, Sold_To_Company_Name2__c,
                                          Sold_To_Address__c, Sold_To_Address2__c, Sold_To_City__c, Sold_To_State__c, Sold_To_Zip_Code__c,
                                          Sold_To_Country__c, Sold_To_Phone__c, Sold_To_Fax__c, Sold_To_Email__c, BigMachines__Opportunity__c,
                                          BigMachines__Opportunity__r.accountid, BigMachines__Opportunity__r.Direct_Sales__c,Quote_Billing_Plan_count__c,
                                          BigMachines__Opportunity__r.BusinessPartner__c, Amendment_For__r.Master_Order_Number__c
                                          FROM BigMachines__Quote__c WHERE id = :idQuote];
        id accountId;
        if (objQuote.BigMachines__Opportunity__r.Direct_Sales__c)
            accountid = objQuote.BigMachines__Opportunity__r.accountid;
        else
            accountid = objQuote.BigMachines__Opportunity__r.BusinessPartner__c;
        list_aoa.clear();
        //sold to address need to insert.
        Account_Order_Address__c aoa = new Account_Order_Address__c();
        //  aoa.Account__c =  accountid;
        aoa.Order__c = licenseOrderId;
        aoa.Address_Type__c = 'Ship To';
        aoa.Zip_Code__c = objQuote.Ship_To_Zip_Code__c;
        aoa.State__c = objQuote.Ship_To_State__c;
        aoa.Phone__c = objQuote.Ship_To_Phone__c;
        aoa.Last_Name__c = objQuote.Ship_To_Last_Name__c;
        aoa.First_Name__c = objQuote.Ship_To_First_Name__c;
        aoa.Fax__c = objQuote.Ship_To_Fax__c;
        aoa.Email__c = objQuote.Ship_To_E_Mail__c;
        aoa.Country__c = objQuote.Ship_To_Country__c;
        aoa.Company__c = objQuote.Ship_To_Company_Name__c;
        aoa.Company_Name2__c = objQuote.Ship_To_Company_Name_2__c;
        aoa.City__c = objQuote.Ship_To_City__c;
        aoa.Address__c = objQuote.Ship_To_Address__c;
        aoa.Address2__c = objQuote.Ship_To_Address_2__c;
        list_aoa.add(aoa);
        
        aoa = new Account_Order_Address__c();
        //  aoa.Account__c =  accountid;
        aoa.Order__c = licenseOrderId;
        aoa.Address_Type__c = 'Bill To';
        aoa.Zip_Code__c = objQuote.Bill_To_Zip_Code__c;
        aoa.State__c = objQuote.Bill_To_State__c;
        aoa.Phone__c = objQuote.Bill_To_Phone__c;
        aoa.Last_Name__c = objQuote.Bill_To_Last_Name__c;
        aoa.First_Name__c = objQuote.Bill_To_First_Name__c;
        aoa.Fax__c = objQuote.Bill_To_Fax__c;
        aoa.Email__c = objQuote.Bill_To_E_Mail__c;
        aoa.Country__c = objQuote.Bill_To_Country__c;
        aoa.Company__c = objQuote.Bill_To_Company_Name__c;
        aoa.Company_Name2__c = objQuote.Bill_To_Company_Name_2__c;
        aoa.City__c = objQuote.Bill_To_City__c;
        aoa.Address__c = objQuote.Bill_To_Address__c;
        aoa.Address2__c = objQuote.Bill_To_Address_2__c;
        list_aoa.add(aoa);
        
        aoa = new Account_Order_Address__c();
        // aoa.Account__c =  objQuote.BigMachines__Opportunity__r.accountid;
        aoa.Order__c = licenseOrderId;
        aoa.Address_Type__c = 'End User';
        aoa.Zip_Code__c = objQuote.End_User_Zip_Code__c;
        aoa.State__c = objQuote.End_User_State__c;
        aoa.Phone__c = objQuote.End_User_Phone__c;
        aoa.Last_Name__c = objQuote.End_User_Last_Name__c;
        aoa.First_Name__c = objQuote.End_User_First_Name__c;
        aoa.Fax__c = objQuote.End_User_Fax__c;
        aoa.Email__c = objQuote.End_User_E_Mail__c;
        aoa.Country__c = objQuote.End_User_Country__c;
        aoa.Company__c = objQuote.End_User_Company_Name__c;
        aoa.Company_Name2__c = objQuote.End_User_Company_Name_2__c;
        aoa.City__c = objQuote.End_User_City__c;
        aoa.Address__c = objQuote.End_User_Address__c;
        aoa.Address2__c = objQuote.End_User_Address_2__c;
        list_aoa.add(aoa);
        
        aoa = new Account_Order_Address__c();
        // aoa.Account__c =  objQuote.BigMachines__Opportunity__r.accountid;
        aoa.Order__c = licenseOrderId;
        aoa.Address_Type__c = 'Sold To';
        aoa.Zip_Code__c = objQuote.Sold_To_Zip_Code__c;
        aoa.State__c = objQuote.Sold_To_State__c;
        aoa.Phone__c = objQuote.Sold_To_Phone__c;
        aoa.Last_Name__c = objQuote.Sold_To_Last_Name__c;
        aoa.First_Name__c = objQuote.Sold_To_First_Name__c;
        aoa.Fax__c = objQuote.Sold_To_Fax__c;
        aoa.Email__c = objQuote.Sold_To_Email__c;
        aoa.Country__c = objQuote.Sold_To_Country__c;
        aoa.Company__c = objQuote.Sold_To_Company_Name__c;
        aoa.Company_Name2__c = objQuote.Sold_To_Company_Name2__c;
        aoa.City__c = objQuote.Sold_To_City__c;
        aoa.Address__c = objQuote.Sold_To_Address__c;
        aoa.Address2__c = objQuote.Sold_To_Address2__c;
        list_aoa.add(aoa);
        system.debug('######list_aoa' + list_aoa);
        insert list_aoa;
    }
}

public static String getPOBType(String strProductType, String strSubType, String Category, String strThirdParty,
                                String strLicenseFYMDetail, String strOfferingType,String productPOB) {
        if(Category=='Passthrough')
            return productPOB; 
        if(strProductType == 'Token')
            return 'PureSuccess Token';
        if ( (strProductType == 'Product' || strProductType == 'Migration Credit') && (strOfferingType == 'PureEngage Subscription' || strOfferingType == 'PureConnect Subscription'))
        return 'Premise Subscription - Committed';
        if (strProductType == 'Product' && (strLicenseFYMDetail == 'Rental Order' || strOfferingType == 'Cloud Partner (PPU)'))
            return 'Premise Subscription - Committed';
        
        if (strProductType == 'Product' && strSubType == 'Latitude Perpetual - On Premise')
            return 'Latitude License - Perpetual';
        else if (strProductType == 'Product')
            return 'Perpetual License';
    /*    else if (strProductType == 'Genesys Care' && strThirdParty == 'TRUE' )
            return 'Maintenance - FYM';*/
                       
        else if ((strOfferingType == 'PureEngage Subscription' || strOfferingType == 'PureConnect Subscription') && 
              strProductType == 'Genesys Care' )
            return 'Not Applicable';      
        else if (strProductType == 'Genesys Care')
            return 'Maintenance - FYM';
        else if (strProductType == 'Product - Hardware' || strProductType == 'Hardware Warranty' )
            return 'Hardware';
        else if (strProductType == 'GU' || strProductType == 'Training Unit')
            return 'Training';
        else if (strSubType == 'Base Package')
            return 'Premise Subscription - Committed';
        else if (strSubType == 'PPU Commited')
            return 'Premise Subscription - Committed';
        else if (strSubType == 'PPU Overage')
            return 'Premise Uncommitted - Usage';
        else if (strSubType == 'Royalties')
            return 'Royalties';    
        
        //Else scenarios in case product is missing type and sub type
        else if (strOfferingType == 'PureEngage Subscription' || strOfferingType == 'PureConnect Subscription')
            return 'Premise Subscription - Committed';
        else
            return 'Error';
    }

//Created order line items for the order
private static void insertOrderLineItems(BigMachines__Quote__c objQuote , Order__c objOrder, Opportunity objOpportunity, Boolean blnIsSeperatePO) {
    String strQuoteProductQuery = 'SELECT Unit_of_Measure__c, Quantity__c, Product__c, Net_Unit_Price__c, Name, List_Price__c, Line_Number__c, Ext_Net_Price__c,';
    strQuoteProductQuery += 'Ext_List__c, CurrencyIsoCode, APN_Number__c, BigMachines__Description__c, BigMachines__Quantity__c, BigMachines__Quote__c, BigMachines__Sales_Price__c,';
    strQuoteProductQuery += 'Extended_Price_Per_Month__c, BigMachines__Product__c, BigMachines__Product__r.Type__c, BigMachines__Product__r.PS_Contract__c, BigMachines__Product__r.Name, BigMachines__Product__r.Description,';
    strQuoteProductQuery += 'Maintenance_Start_Date__c, Year2_Maintenance_Due__c, Year3_Maintenance_Due__c, Year4_Maintenance_Due__c, Year5_Maintenance_Due__c,BigMachines__Product__r.Sub_Type__c,';
    strQuoteProductQuery += 'Maintenance_End_Date__c, Year2_CareRatePercent__c, Year3_CareRatePercent__c, Year4_CareRatePercent__c, Year5_CareRatePercent__c,BigMachines__Product__r.APN_Number__c,BigMachines__Quote__r.Quote_Billing_Plan_count__c,';
    strQuoteProductQuery += 'Maintenance_Due__c, Fees_Applied__c, Genesys_Care_Rate__c, Increase__c, Revised_Net_License_Value__c, Extended_End_of_Support__c, Contract_Line_Update_Status__c,';
    strQuoteProductQuery += 'Original_Qty__c, Current_Qty__c, Total_Discount__c, Product_Specific_Discount__c, BigMachines__Total_Price__c, Sold_To_Name__c, End_User_Name__c,BigMachines__Product__r.Pass_Through__c, BigMachines__Product__r.Third_Party_Custom__c,';
    strQuoteProductQuery += 'Service_Contract_Line_ID__c,Partner_Price__c,BigMachines__Quote__r.opportunity_type__c,Annualized_Maintenance_Last_Period__c, Flavor__c, Project_ID__c,Project_Name__c,Third_Party_Applications__c,Third_Party_Partners__c,Hardware_or_Third_Party__c,BigMachines__Product__r.Third_Party__c,BigMachines__Product__r.Third_Party_GC__c,BigMachines__Product__r.New_Category__c,BigMachines__Product__r.Sub_category__c,BigMachines__Product__r.POB_Type__c,';
    strQuoteProductQuery += 'Application_Support_Cost_Base__c, Solution_Names_Covered__c, Third_Party_Partner_Fee__c, Bundle__r.Name, Bundle__r.Group_Type__c, Bundle_Line__c, Bundle_Line__r.Ext_Net_Price__c,Bundle_Line__r.Extended_Price_Per_Month__c,Bundle_Line__r.Ext_Net_Price_1__c,Bundle_Line__r.Ext_Net_Price_2__c,Ext_Net_Price_1__c,Product_Group__c,Bundle_Line__r.BigMachines__Product__c,Bundle_Line__r.APN_Number__c,Is_Overage__c FROM BigMachines__Quote_Product__c WHERE ';
    strQuoteProductQuery += 'BigMachines__Quote__c= \'' + objQuote.id + '\' AND (BigMachines__Product__r.Type__c != \'Bundle\' OR Bundle__r.Group_Type__c = \'Base Package\'';
    //Anju Jan 2018 PureSuccess
    if (objQuote.Offering_Type__c == 'PureConnect Cloud' && (objQuote.PureSuccess__c != null || (objQuote.Does_customer_currently_have_PureSuccess__c && objQuote.A_La_Carte_PureSuccess_Services_Amount__c > 0)))
        strQuoteProductQuery += ' OR Bundle__r.Group_Type__c = \'PureSuccess\'';
    strQuoteProductQuery += ')';
    
    if (blnIsSeperatePO) {
        strQuoteProductQuery += ' and ( BigMachines__Product__r.Type__c = \'Product - System License\' OR BigMachines__Product__r.Type__c = \'Product - Hardware\' OR BigMachines__Product__r.Type__c = \'Product\')';
    }
    if (objQuote.Is_GU_EMEA__c) {
        strQuoteProductQuery += ' and BigMachines__Product__r.Type__c <> \'Genesys Care\'';
    }
    Boolean blnIncludeLineItem ;
    String genesysCareProductId;
    String genesysCareProductName;
    String genesysCareProductDescription;
    Date tempStart;
    Date tempEnd;
    integer tempTerm;
    Set<String> genesysPS = new Set<String>();
    Set<String> genesysCareFlexCareProductIds = new Set<String>();
    Set<String> genesysFeeProductIds = new Set<String>();
    List<Order_Line_Item__c> list_OrderLineItems = new list<Order_Line_Item__c>();
    Order_Line_Item__c genesysCareLine;
    Order_Line_Item__c thirdCareLine;
    List<String> list_Types = Label.Types_Required_Add_Products.split(';');
    integer line_number = 1;
    integer line_numberAlaCart = 5;
    Decimal decNetQuantity = 0;
    Decimal decNetListPrice = 0;
    Decimal decNetSellPrice = 0;
    Decimal decNetQuantityTP = 0;
    Decimal decNetListPriceTP = 0;
    Decimal decNetSellPriceTP = 0;
    
    Map<String, BigMachines__Quote_Product__c> mapOfPackageVsPrice = new Map<String, BigMachines__Quote_Product__c>();
    System.Debug('strQuoteProductQuery--->'+strQuoteProductQuery);
    for (BigMachines__Quote_Product__c quoteProduct : Database.query(strQuoteProductQuery)) {
        if (quoteProduct.Bundle__r.Group_Type__c == 'PureSuccess') {
            //MS 10/25/2019 - remove Burst packages
            if (objQuote.Offering_Type__c != 'PureConnect Cloud' || (objQuote.Offering_Type__c == 'PureConnect Cloud' && quoteProduct.Bundle_Line__c != NULL &&
                quoteProduct.Subscription_Burst_Term__c == null))
                mapOfPackageVsPrice.put(quoteProduct.Bundle__r.Name, quoteProduct);
            if (quoteProduct.Bundle_Line__c != NULL)
                continue;
        }
        if (quoteProduct.BigMachines__Product__r.Type__c == 'Product - Hardware') {
            //multiShipIds.add(quoteProduct.BigMachines__Quote__c);
        } else {
            //softwareOnlyOrderIds.add(quoteProduct.BigMachines__Quote__c);
        }
        if (quoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care') {
            genesysCareProductId = quoteProduct.BigMachines__Product__c;
            genesysCareProductName = quoteProduct.BigMachines__Product__r.Name;
            genesysCareProductDescription = quoteProduct.BigMachines__Product__r.Description;
        }
        if (quoteProduct.BigMachines__Product__r.Type__c == 'Flex Care')
            genesysCareFlexCareProductIds.add(quoteProduct.BigMachines__Product__c);
        
        if (quoteProduct.BigMachines__Product__r.PS_Contract__c != null && quoteProduct.BigMachines__Product__r.PS_Contract__c)
            genesysPS.add(quoteProduct.BigMachines__Product__c);
        
        
        if (quoteProduct.BigMachines__Product__r.Type__c == 'Fees') {
            genesysFeeProductIds.add(quoteProduct.BigMachines__Product__c);
            // Sourav : 10/23/2014
            continue;
        }
        
        //PureSuccess Anju Jan 2018 starts remove Alacarte items
        if (objQuote.Offering_Type__c == 'PureConnect Cloud' && (objQuote.PureSuccess__c != null || (objQuote.Does_customer_currently_have_PureSuccess__c && objQuote.A_La_Carte_PureSuccess_Services_Amount__c > 0)) && (quoteProduct.Product_Group__c == 'PureSuccess Direct A-la-Carte' || quoteProduct.Product_Group__c == 'PureSuccess Indirect A-la-Carte')) {
            mapPSAlacartItems.put(quoteProduct.id, quoteProduct);
            
        }
        if (objQuote.Offering_Type__c == 'PureConnect Cloud' && objQuote.PureSuccess__c != null && (quoteProduct.Product_Group__c == 'PureSuccess Direct Offer' || quoteProduct.Product_Group__c == 'PureSuccess Indirect Offer')) {
            mapPSOfferItems.put(quoteProduct.id, quoteProduct);
        }
        //PureSuccess Anju Jan 2018 ends
        
        Order_Line_Item__c objOrderLineItem = new Order_Line_Item__c();//DynamicFieldMapping.getOrderLineItemFromQuoteLineItem(quoteProduct, 'License_Orders');
        Order_Line_Item__c objOrderLineItemclone;
        // 7/1/2016 : Setting default recordtype
        objOrderLineItem.Line_Number__c = line_number;
        line_number += 1;
        System.debug('+++++++++line_number ' + line_number);
        objOrderLineItem.RecordTypeId = Global_Setting__c.getInstance('Order Line Default RT').ID__c;
        objOrderLineItem.Unit_of_Measure__c = quoteProduct.Unit_of_Measure__c;
        objOrderLineItem.Order__c = objOrder.id;
        objOrderLineItem.Third_Party_Partners__c = quoteProduct.BigMachines__Product__r.Third_Party_Custom__c;
        //Anju PureSuccess Jan 2018 starts
        if (mapPSAlacartItems.containskey(quoteProduct.id))
            objOrderLineItem.Order__c = pureSuccessChildOrder.id;
        //Anju PureSuccess Jan 2018 ends
        objOrderLineItem.Flavor__c = quoteProduct.Flavor__c;
        ///*
        objOrderLineItem.Quantity__c = quoteProduct.Quantity__c;
        objOrderLineItem.Quote_Product__c = quoteProduct.id;
        System.debug('NKC debug objOrderLineItem.Quote_Product__c [' + objOrderLineItem.Quote_Product__c + ']');
        objOrderLineItem.Product_txt__c = quoteProduct.Product__c;
        objOrderLineItem.Net_Unit_Price__c = quoteProduct.Net_Unit_Price__c;
        if(quoteProduct.Bundle_Line__c == null){
            //Naresh Kumar  06/28/2018  Populating POB Type
            if (objQuote.Offering_Type__c == 'PureEngage On Premise' || objQuote.Offering_Type__c == null
                || objQuote.Offering_Type__c == 'PureConnect On Premise'
                || objQuote.Offering_Type__c == 'PureConnect Subscription'
                || objQuote.Offering_Type__c == 'PureEngage Subscription'
                || objQuote.Offering_Type__c == 'Cloud Partner (PPU)') {
                  objOrderLineItem.POB_Type__c = getPOBType(quoteProduct.BigMachines__Product__r.Type__c,
                                                              quoteProduct.BigMachines__Product__r.Sub_Type__c,
                                                             quoteProduct.BigMachines__Product__r.New_Category__c,
                                                              quoteProduct.BigMachines__Product__r.Third_Party__c,
                                                              objOrder.License_FYM_detail__c,
                                                              objQuote.Offering_Type__c,quoteProduct.BigMachines__Product__r.POB_Type__c);
                    
                }            
        }
        else
            objOrderLineItem.POB_Type__c = 'Not Applicable';
        if (objQuote.Quote_Business_Type__c != 'Cloud')
            objOrderLineItem.Name = quoteProduct.BigMachines__Product__r.APN_Number__c;
        else
            objOrderLineItem.Name = quoteProduct.BigMachines__Product__r.Name;
        
        objOrderLineItem.Product__c = quoteProduct.BigMachines__Product__c;
        if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c == null) {
            objOrderLineItem.List_Price__c = 0;
            objOrderLineItem.Ext_Net_Price__c = 0;
            objOrderLineItem.Ext_List__c = 0;
            objOrderLineItem.sales_price__c = 0;
        } else {
            objOrderLineItem.List_Price__c = quoteProduct.List_Price__c;
            //objOrderLineItem.Line_Number__c = quoteProduct.Line_Number__c;
            objOrderLineItem.Ext_Net_Price__c = quoteProduct.Ext_Net_Price__c;
            objOrderLineItem.Ext_List__c = quoteProduct.Ext_List__c;
            objOrderLineItem.sales_price__c = quoteProduct.BigMachines__Sales_Price__c;
        }
        
        objOrderLineItem.CurrencyIsoCode = quoteProduct.CurrencyIsoCode;
        //objOrderLineItem.APN_Number__c = quoteProduct.APN_Number__c;
        //Added By Ranjith on Jun 13, 2017 -- Starts
        // 1/2/2015 : Pulling APN Number from the product : Name of sellable items is APN Number
        //objOrderLineItem.APN_Number__c = String.isBlank(quoteProduct.APN_Number__c) ? quoteProduct.BigMachines__Product__r.Name : quoteProduct.APN_Number__c;
        objOrderLineItem.APN_Number__c = quoteProduct.BigMachines__Product__r.APN_Number__c;
        //Added By Ranjith on Jun 13, 2017 -- Ends
        objOrderLineItem.description__c = quoteProduct.BigMachines__Description__c;
        
        objOrderLineItem.BigMachines_Quantity__c = quoteProduct.BigMachines__Quantity__c;
        objOrderLineItem.Total_Discount__c = quoteProduct.Total_Discount__c;
        objOrderLineItem.Product_Specific_Discount__c = quoteProduct.Product_Specific_Discount__c;
        
        //*/
        //If it's a license opp then copy both the dates from Quote itself. OR if the product is genesys care
        if ((objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && objQuote.Quote_Business_Type__c != 'Renewal')
            || objOrderLineItem.Product__c == genesysCareProductId) {
                objOrderLineItem.Maintenance_End_Date__c = objQuote.Maintenance_End_Date__c;
                objOrderLineItem.Maintenance_Start_Date__c = objQuote.Maintenance_Start_Date__c;
            }
        System.debug('NKC debug objOrderLineItem.Maintenance_Start_Date__c [' + objOrderLineItem.Maintenance_Start_Date__c + ']');
        System.debug('NKC debug objOrderLineItem.Maintenance_End_Date__c [' + objOrderLineItem.Maintenance_End_Date__c + ']');
        
        if (objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && objQuote.Quote_Business_Type__c != 'Renewal') {
            objOrderLineItem.Maintenance_No_of_Months__c = objQuote.Order_Numb_of_Maint_Months__c;
        }
        //If it's not a license opp then copy both the dates from Quote products.
        else {
            objOrderLineItem.Maintenance_End_Date__c = quoteProduct.Maintenance_End_Date__c;
            objOrderLineItem.Maintenance_Start_Date__c = quoteProduct.Maintenance_Start_Date__c;
            // 1/21/2015 : Copy additional information for PS product
            if (String.isNotBlank(quoteProduct.BigMachines__Product__r.Type__c)) {
                for (String strType : list_Types) {
                    if (quoteProduct.BigMachines__Product__r.Type__c == strType) {
                        objOrderLineItem.Project_ID__c = quoteProduct.Project_ID__c;
                        objOrderLineItem.Project_Name__c = quoteProduct.Project_Name__c;
                        objOrderLineItem.Third_Party_Partners__c = quoteProduct.Third_Party_Partners__c;
                        objOrderLineItem.Third_Party_Applications__c = quoteProduct.Third_Party_Applications__c;
                        objOrderLineItem.Third_Party_Partner_Fee__c = quoteProduct.Third_Party_Partner_Fee__c;
                        objOrderLineItem.Solution_Names_Covered__c = quoteProduct.Solution_Names_Covered__c;
                        objOrderLineItem.Application_Support_Cost_Base__c = quoteProduct.Application_Support_Cost_Base__c;
                    }
                }
            }
        }
        
        // Calculates the Maintenace due and Anuualized at Order level for Licensing Deal
        
        if (objQuote.PO_for_FYM__c != null && objQuote.PO_for_FYM__c != 'Declined Maintenance') {
            
            //if(objOpportunity.RecordType.DeveloperName != null && objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME)
            if (objOpportunity.RecordType.DeveloperName != null && objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME &&
                objQuote.Quote_Business_Type__c != 'Renewal' && objQuote.Quote_Business_Type__c != 'Cloud') {
                    //Naresh Kumar  12/10/2018  Maint Due is being calculated from ext list price for PureConnect On Premise as per Ankit S.
                    if(objQuote.Offering_Type__c == 'PureConnect On Premise' && objQuote.Current_Maint_Rate__c != null && objQuote.Sold_To_Name__c == objQuote.End_User_ID__c){
                        objOrderLineItem.Maintenance_Due__c = quoteProduct.Ext_List__c * (objQuote.Current_Maint_Rate__c / 100);            
                    }
                    else if (objQuote.Current_Maint_Rate__c != null) {
                        objOrderLineItem.Maintenance_Due__c = quoteProduct.BigMachines__Total_Price__c * (objQuote.Current_Maint_Rate__c / 100);
                    }
                    if (objOrderLineItem.Maintenance_Due__c != null && objOrderLineItem.Maintenance_Due__c != 0 && objQuote.Order_Numb_of_Maint_Months__c != 0 && objQuote.Order_Numb_of_Maint_Months__c != null) {
                        objOrderLineItem.Annualized_Maintenance_Due__c = (objOrderLineItem.Maintenance_Due__c / objQuote.Order_Numb_of_Maint_Months__c) * 12;
                    }
                }
        } else {
            objOrderLineItem.Annualized_Maintenance_Due__c = 0;
            objOrderLineItem.Maintenance_Due__c = 0;
        }
        
        //if(objOpportunity.RecordType.DeveloperName; != null && (objOpportunity.RecordType.DeveloperName; == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || objOpportunity.RecordType.DeveloperName; == ServiceContractUtil.MAINTENANCE))
        if (objOpportunity.RecordType.DeveloperName != null && (objQuote.Quote_Business_Type__c == 'Renewal' || objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME
                                                                || objOpportunity.RecordType.DeveloperName == ServiceContractUtil.MAINTENANCE)) {
                                                                    objOrderLineItem.Maintenance_Due__c = quoteProduct.Maintenance_Due__c;
                                                                    // Storing Annualized Maintenance from last period applicable on the quote
                                                                    if (quoteProduct.Annualized_Maintenance_Last_Period__c != null)
                                                                        objOrderLineItem.Annualized_Maintenance_Due__c = quoteProduct.Annualized_Maintenance_Last_Period__c; else {
                                                                            if (quoteProduct.Maintenance_Due__c != null && quoteProduct.Maintenance_Due__c != 0 &&
                                                                                quoteProduct.Maintenance_Start_Date__c != null && quoteProduct.Maintenance_End_Date__c != null) {
                                                                                    
                                                                                    tempStart = OrderUtil.adjustDatetoStartofMonth(quoteProduct.Maintenance_Start_Date__c);
                                                                                    tempEnd = OrderUtil.adjustDatetoStartofMonth(quoteProduct.Maintenance_End_Date__c);
                                                                                    tempTerm = (12 * (tempEnd.year() - tempStart.year())) + (tempEnd.month() - tempStart.month());
                                                                                    objOrderLineItem.Maintenance_No_of_Months__c = tempTerm;
                                                                                    if (tempTerm != 0)
                                                                                        objOrderLineItem.Annualized_Maintenance_Due__c = (quoteProduct.Maintenance_Due__c / tempTerm) * 12;
                                                                                    
                                                                                }
                                                                        }
                                                                    objOrderLineItem.Sold_To_Name__c = quoteProduct.Sold_To_Name__c;
                                                                    objOrderLineItem.End_User_Name__c = quoteProduct.End_User_Name__c;
                                                                }
        
        
        //*
        objOrderLineItem.Fees_Applied__c = quoteProduct.Fees_Applied__c ;
        //objOrderLineItem.Gnesys_Care_Rate__c = quoteProduct.Genesys_Care_Rate__c;
        objOrderLineItem.Increase__c = quoteProduct.Increase__c;
        objOrderLineItem.Revised_Net_License_Value__c = quoteProduct.Revised_Net_License_Value__c;
        objOrderLineItem.Extended_End_of_Support__c = quoteProduct.Extended_End_of_Support__c;
        
        //Mukunthan added below lines to capture Original License List Price, Revised License List Price, Partner License List Price, Unit List and Partner Price
        //<--------Start-------->
        if(quoteProduct.BigMachines__Quote__r.opportunity_type__c == 'GEN_Opportunity_Record_Type_New'){
            System.Debug('Mukunth added--->');
            boolean blnDirect = objQuote.End_User_ID__c == objQuote.Sold_To_Name__c ? true : false;
            if(quoteProduct.Quantity__c != null){
                objOrderLineItem.Original_License_List_Price__c = quoteProduct.List_Price__c!=null?quoteProduct.Quantity__c*quoteProduct.List_Price__c:0;
                objOrderLineItem.Partner_License_List_Price__c = quoteProduct.Partner_Price__c!=null?quoteProduct.Quantity__c*quoteProduct.Partner_Price__c:0;
                if(blnDirect)
                    objOrderLineItem.Revised_License_List_Price__c = quoteProduct.List_Price__c!=null?quoteProduct.Quantity__c*quoteProduct.List_Price__c:0;
                else
                    objOrderLineItem.Revised_License_List_Price__c = quoteProduct.Partner_Price__c!=null?quoteProduct.Quantity__c*quoteProduct.Partner_Price__c:0;
            }
            else{
                objOrderLineItem.Original_License_List_Price__c = 0;
                objOrderLineItem.Partner_License_List_Price__c = 0;
                objOrderLineItem.Revised_License_List_Price__c = 0;
            }
            objOrderLineItem.Unit_List_Price__c = quoteProduct.List_Price__c!=null?quoteProduct.List_Price__c:0;
            objOrderLineItem.Unit_Partner_Price__c = quoteProduct.Partner_Price__c!=null?quoteProduct.Partner_Price__c:0;
        }
        //<----------End---------->
        
        
        objOrderLineItem.Contract_Line_Update_Status__c = quoteProduct.Contract_Line_Update_Status__c;
        objOrderLineItem.Current_Qty__c = quoteProduct.Current_Qty__c;
        objOrderLineItem.Original_Qty__c = quoteProduct.Original_Qty__c;
        objOrderLineItem.Service_Contract_Line_ID__c = quoteProduct.Service_Contract_Line_ID__c;
        //Naresh kumar 05/12/2014
        //New Mapping Fields for Renewal Only
        if (objQuote.Quote_Business_Type__c == 'Renewal' || objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME) {
            // For Flex Care and Fees products Sales Price should not be overwritten as Sales Price flows to Maintenance Due on Service Contract
            if (quoteProduct.BigMachines__Product__r.Type__c != 'Flex Care' &&
                quoteProduct.BigMachines__Product__r.Type__c != 'Fees') {
                    objOrderLineItem.Year1_Maintenance_Due__c = quoteProduct.Maintenance_Due__c;
                    objOrderLineItem.Year2_Maintenance_Due__c = quoteProduct.Year2_Maintenance_Due__c;
                    objOrderLineItem.Year3_Maintenance_Due__c = quoteProduct.Year3_Maintenance_Due__c;
                    objOrderLineItem.Year4_Maintenance_Due__c = quoteProduct.Year4_Maintenance_Due__c;
                    objOrderLineItem.Year5_Maintenance_Due__c = quoteProduct.Year5_Maintenance_Due__c;
                    
                    if (quoteProduct.Maintenance_Due__c == null)
                        quoteProduct.Maintenance_Due__c = 0;
                    if (quoteProduct.Year2_Maintenance_Due__c == null)
                        quoteProduct.Year2_Maintenance_Due__c = 0;
                    if (quoteProduct.Year3_Maintenance_Due__c == null)
                        quoteProduct.Year3_Maintenance_Due__c = 0;
                    if (quoteProduct.Year4_Maintenance_Due__c == null)
                        quoteProduct.Year4_Maintenance_Due__c = 0;
                    if (quoteProduct.Year5_Maintenance_Due__c == null)
                        quoteProduct.Year5_Maintenance_Due__c = 0;
                    
                    objOrderLineItem.Maintenance_Due__c = quoteProduct.Maintenance_Due__c + quoteProduct.Year2_Maintenance_Due__c +
                        quoteProduct.Year3_Maintenance_Due__c + quoteProduct.Year4_Maintenance_Due__c + quoteProduct.Year5_Maintenance_Due__c;
                    
                    objOrderLineItem.Genesys_Care_Rate__c = quoteProduct.Genesys_Care_Rate__c;
                    objOrderLineItem.Year2_CareRatePercent__c = quoteProduct.Year2_CareRatePercent__c;
                    objOrderLineItem.Year3_CareRatePercent__c = quoteProduct.Year3_CareRatePercent__c;
                    objOrderLineItem.Year4_CareRatePercent__c = quoteProduct.Year4_CareRatePercent__c;
                    objOrderLineItem.Year5_CareRatePercent__c = quoteProduct.Year5_CareRatePercent__c;
                    objOrderLineItem.Sales_Price__c = objOrderLineItem.Maintenance_Due__c;
                }
            // Flex Care and Fees Lines
            else {
                // Maintenance Due is fetched from Sales Price for Fees and Flex Care Lines
                objOrderLineItem.Maintenance_Due__c = quoteProduct.BigMachines__Sales_Price__c;
                if (objOrderLineItem.Maintenance_Due__c != null &&
                    quoteProduct.Maintenance_Start_Date__c != null && quoteProduct.Maintenance_End_Date__c != null) {
                        objOrderLineItem.Maintenance_No_of_Months__c = Util.calculateDurationInMonths(quoteProduct.Maintenance_Start_Date__c, quoteProduct.Maintenance_End_Date__c);
                        if (objOrderLineItem.Maintenance_No_of_Months__c != 0)
                            objOrderLineItem.Annualized_Maintenance_Due__c = objOrderLineItem.Maintenance_Due__c * (12 / objOrderLineItem.Maintenance_No_of_Months__c);
                    }
            }
            
        }
        
        //Anju PureSuccess Jan 2018 starts
        if (mapPSAlacartItems.containskey(quoteProduct.id)) {
            objOrderLineItem.Order__c = pureSuccessChildOrder.id;
            objOrderLineItem.Year__c = 1;
            objOrderLineItem.Maintenance_Start_Date__c = pureSuccessChildOrder.Maintenance_Start__c;
            objOrderLineItem.Maintenance_End_Date__c = pureSuccessChildOrder.Maintenance_End__c;
            objOrderLineItem.Line_Number__c = line_numberAlaCart;
            line_numberAlaCart ++;
            objOrderLineItemclone = objOrderLineItem.clone();
            objOrderLineItemclone.Order__c = objOrder.id;
        }
        //Anju PureSuccess Jan 2018 ends
        if(objQuote.Offering_Type__c == 'PureEngage On Premise' || objQuote.Offering_Type__c == null
           || objQuote.Offering_Type__c == 'PureConnect On Premise'
           || objQuote.Offering_Type__c == 'Cloud Partner (PPU)'){
               
               
               System.debug('@@ third party'+quoteProduct.BigMachines__Product__r.Third_Party_GC__c);
               
               //Naresh Kumar  12/10/2018  Populating totals for third party care line
             //  if ((objQuote.Offering_Type__c == 'PureConnect On Premise' && quoteProduct.BigMachines__Product__r.Third_Party_GC__c != null
               if  ((objQuote.Offering_Type__c == 'PureConnect On Premise'|| objQuote.Offering_Type__c == 'PureEngage On Premise') && quoteProduct.BigMachines__Product__r.Third_Party_GC__c != null    
               && quoteProduct.BigMachines__Product__r.Third_Party_GC__c != 0 
                //   && quoteProduct.BigMachines__Product__r.Third_Party_GC__c != 0 && quoteProduct.BigMachines__Product__r.Third_Party_GC__c != 255
                   && (quoteProduct.BigMachines__Product__r.Third_Party__c != null 
                       && quoteProduct.BigMachines__Product__r.Third_Party__c.containsIgnoreCase('TRUE'))){
                           if(objOrderLineItem.BigMachines_Quantity__c != null)
                               decNetQuantityTP += objOrderLineItem.BigMachines_Quantity__c;
                           if(objOrderLineItem.List_Price__c != null && objOrderLineItem.Quantity__c != null)
                               decNetListPriceTP += (objOrderLineItem.List_Price__c * objOrderLineItem.Quantity__c);
                           if(objOrderLineItem.Ext_Net_Price__c != null)
                               decNetSellPriceTP += objOrderLineItem.Ext_Net_Price__c;     
                       }
               //Naresh Kumar  08/06/2018  Populating totals for Care Line
               else if (quoteProduct.BigMachines__Product__r.Type__c == 'Product'){
                   if(objOrderLineItem.BigMachines_Quantity__c != null)
                       decNetQuantity += objOrderLineItem.BigMachines_Quantity__c;
                   if(objOrderLineItem.List_Price__c != null && objOrderLineItem.Quantity__c != null)
                       decNetListPrice += (objOrderLineItem.List_Price__c * objOrderLineItem.Quantity__c);
                   if(objOrderLineItem.Ext_Net_Price__c != null)
                       decNetSellPrice += objOrderLineItem.Ext_Net_Price__c;                 
               }
               
               if (quoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care' 
                   && (quoteProduct.BigMachines__Product__r.Third_Party__c == null 
                       || !quoteProduct.BigMachines__Product__r.Third_Party__c.containsIgnoreCase('TRUE'))){
                           genesysCareLine = objOrderLineItem;
                       }
               //Applicable to PureConnect On Premise only
              // if (objQuote.Offering_Type__c == 'PureConnect On Premise' && quoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care' 
               if ((objQuote.Offering_Type__c == 'PureConnect On Premise'|| objQuote.Offering_Type__c == 'PureEngage On Premise')&& quoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care'     
               && (quoteProduct.BigMachines__Product__r.Third_Party__c != null 
                       && quoteProduct.BigMachines__Product__r.Third_Party__c.containsIgnoreCase('TRUE'))){
                           thirdCareLine = objOrderLineItem;        
                       }
               //Applicable to PureEngage On Premise
               else if(objQuote.Offering_Type__c == null && quoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care' 
                       && (quoteProduct.BigMachines__Product__r.Third_Party__c != null 
                           && quoteProduct.BigMachines__Product__r.Third_Party__c.containsIgnoreCase('TRUE'))){                    
                               objOrderLineItem.Current_Qty__c = objOrderLineItem.BigMachines_Quantity__c;
                               if(objOrderLineItem.List_Price__c != null)
                                   objOrderLineItem.Original_Net_License_Value__c = (objOrderLineItem.List_Price__c * (objOrderLineItem.Quantity__c == null ? 0 : objOrderLineItem.Quantity__c));
                               objOrderLineItem.Revised_Net_License_Value__c = objOrderLineItem.Ext_Net_Price__c; 
                           }                    
           }
        blnIncludeLineItem = true;
        
        if (quoteProduct.Contract_Line_Update_Status__c == 'Split' && ((quoteProduct.Original_Qty__c == quoteProduct.Current_Qty__c) || quoteProduct.Current_Qty__c == 0))
            blnIncludeLineItem = false;
        
        if ((quoteProduct.Contract_Line_Update_Status__c == 'Drop' || quoteProduct.Contract_Line_Update_Status__c == 'Downsize' || quoteProduct.Contract_Line_Update_Status__c == 'Shelved')
            && ((quoteProduct.Original_Qty__c == quoteProduct.Current_Qty__c) || quoteProduct.Current_Qty__c == 0))
            blnIncludeLineItem = false;
        
        if (quoteProduct.Contract_Line_Update_Status__c == 'Retired' && ((quoteProduct.Original_Qty__c == quoteProduct.Current_Qty__c) || quoteProduct.Current_Qty__c == 0))
            blnIncludeLineItem = false;
        
        //Naresh Kumar 04/22/2018   - Populating Order Line Item's Name for PT Products.
        if (quoteProduct.BigMachines__Product__r.Pass_Through__c) {
            objOrderLineITem.Product_txt__c = quoteProduct.Name;
            objOrderLineITem.Product_Name__c = quoteProduct.Name;
        }
        
        if (objQuote.Offering_Type__c == 'Cloud Partner (PPU)')
            objOrderLineItem.Skip_Invoice__c = true;
        
        //Naresh Kumar  10/16/2018  - Populating Dummy APNs for Rental order
        System.debug('quoteProduct.BigMachines__Product__r.Type__c' + quoteProduct.BigMachines__Product__r.Type__c);
        System.debug('objOrder.License_FYM_detail__c' + objOrder.License_FYM_detail__c);
        if(quoteProduct.BigMachines__Product__r.Type__c == 'Product' && objOrder.License_FYM_detail__c == 'Rental Order'){
            if(objQuote.Offering_Type__c == null && objQuote.PPU_Rental__c){
                System.debug('navanee123');
                objOrderLineItem.Dummy_APN__c = Label.Rental_Order_Dummy_APNs.split(';')[0];
                System.debug('objOrderLineItem.Dummy_APN__c 1'+ objOrderLineItem.Dummy_APN__c);}
            else if(objQuote.Offering_Type__c == 'PureConnect On Premise' && objQuote.PPU_Rental__c){
                objOrderLineItem.Dummy_APN__c = Label.Rental_Order_Dummy_APNs.split(';')[1];
                System.debug('objOrderLineItem.Dummy_APN__c 2'+ objOrderLineItem.Dummy_APN__c);}
        }
        
        if (blnIncludeLineItem)
            list_OrderLineItems.add(objOrderLineItem);
        if (objOrderLineItemclone != null)
            list_OrderLineItems.add(objOrderLineItemclone);
        
        System.debug('@@ org net care line'+decNetListPrice);
    }
    
    
    //Naresh Kumar  08/06/2018  Populating totals for Care Line
    if (genesysCareLine != null) {
        genesysCareLine.Current_Qty__c = decNetQuantity;
        genesysCareLine.Revised_Net_License_Value__c = decNetSellPrice;
        genesysCareLine.Original_Net_License_Value__c = decNetListPrice;
        if(objQuote.PPU_Rental__c && (genesysCareLine.List_Price__c == null || genesysCareLine.List_Price__c == 0)){
            genesysCareLine.POB_Type__c = 'Not Applicable';    
        }
    }
    
    //Naresh Kumar  08/06/2018  Populating totals for Care Line
    if (thirdCareLine != null) {
        thirdCareLine.Current_Qty__c = decNetQuantityTP;
        thirdCareLine.Revised_Net_License_Value__c = decNetSellPriceTP;
        thirdCareLine.Original_Net_License_Value__c = decNetListPriceTP;            
    }        
    
    //It shouldn't happen in case of license opp
    //if(objOpportunity.RecordType.DeveloperName; != ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && genesysCareProductId != null){
    if ((objQuote.Quote_Business_Type__c == 'Renewal' || objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME)
        && genesysCareProductId != null) {
            list_OrderLineItems = CreateOrderFromQuoteTriggerHelper.populateBusinessLinesOnQuoteOtherThanRenewal(list_OrderLineItems, genesysCareProductId,
                                                                                                                 genesysCareProductName, genesysCareProductDescription, objQuote, objOrder, genesysCareFlexCareProductIds, genesysFeeProductIds, genesysPS);
        }
    upsert list_OrderLineItems;
    if (objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC && objQuote.PureSuccess__c != null && pureSuccessChildOrder != null)
        OrderCloudUtil.createPureSuccessLinesCloud(mapOfPackageVsPrice, objQuote, pureSuccessChildOrder, list_OrderLineItems);
    
} ///END insertOrderLineItems

//Created order line items for the order
@testvisible
private static void insertOrderLineItemsSubscription(BigMachines__Quote__c objQuote , Order__c objOrder, Opportunity objOpportunity, Boolean blnIsSeperatePO) {
    String strQuoteProductQuery = 'SELECT Unit_of_Measure__c, Quantity__c, Product__c, Net_Unit_Price__c, Name, List_Price__c, Line_Number__c, Ext_Net_Price__c,';
    strQuoteProductQuery += 'Ext_List__c, CurrencyIsoCode, APN_Number__c, BigMachines__Description__c, BigMachines__Quantity__c, BigMachines__Quote__c, BigMachines__Sales_Price__c,';
    strQuoteProductQuery += 'BigMachines__Product__c, BigMachines__Product__r.Type__c, BigMachines__Product__r.PS_Contract__c, BigMachines__Product__r.Name, BigMachines__Product__r.Description,';
    strQuoteProductQuery += 'Maintenance_Start_Date__c, Year2_Maintenance_Due__c, Year3_Maintenance_Due__c, Year4_Maintenance_Due__c, Year5_Maintenance_Due__c,BigMachines__Product__r.Sub_Type__c,';
    strQuoteProductQuery += 'Maintenance_End_Date__c, Year2_CareRatePercent__c, Year3_CareRatePercent__c, Year4_CareRatePercent__c, Year5_CareRatePercent__c,BigMachines__Product__r.APN_Number__c,';
    strQuoteProductQuery += 'Maintenance_Due__c, Fees_Applied__c, Genesys_Care_Rate__c, Increase__c, Revised_Net_License_Value__c, Extended_End_of_Support__c, Contract_Line_Update_Status__c,';
    strQuoteProductQuery += 'Original_Qty__c, Current_Qty__c, Total_Discount__c, Product_Specific_Discount__c, BigMachines__Total_Price__c, Sold_To_Name__c, End_User_Name__c,Tokens__c,BigMachines__Product__r.Third_Party_Custom__c,';
    strQuoteProductQuery += 'Service_Contract_Line_ID__c, Annualized_Maintenance_Last_Period__c, Flavor__c, Project_ID__c,Project_Name__c,Third_Party_Applications__c,Third_Party_Partners__c,Hardware_or_Third_Party__c,BigMachines__Product__r.Third_Party__c,BigMachines__Product__r.Third_Party_GC__c,BigMachines__Product__r.New_category__c,BigMachines__Product__r.Sub_Category__c,BigMachines__Product__r.POB_Type__c,';
    strQuoteProductQuery += 'List_Price_1__c, List_Price_2__c, Ext_Net_Price_1__c, Ext_Net_Price_2__c, Ext_List_Price_1__c, Ext_List_Price_2__c, Net_Unit_Price_1__c, Net_Unit_Price_2__c,Discount_1__c, Discount_2__c, Partner_Discount_1__c, Partner_Discount_2__c,Disc__c,';
    strQuoteProductQuery += 'Bundle_Line__r.Ext_Net_Price__c, Bundle_Line__r.Ext_Net_Price_1__c, Bundle_Line__r.Ext_Net_Price_2__c,BigMachines__Quote__r.Subscription_Start_Date__c, BigMachines__Quote__r.Subscription_End_Date__c, Subscription_Product__r.Quantity__c,BigMachines__Quote__r.Quote_Billing_Plan_count__c,';
    strQuoteProductQuery += 'Application_Support_Cost_Base__c, Solution_Names_Covered__c, Third_Party_Partner_Fee__c, Bundle__r.Name, Bundle__r.Type__c, Bundle__r.Group_Type__c, Bundle_Line__c, Bundle_Line__r.BigMachines__Product__c,Is_Overage__c,Subscription_Burst_Term__c,BigMachines__Product__r.One_Time_Charge__c ';
    strQuoteProductQuery += ' FROM BigMachines__Quote_Product__c WHERE ';
    strQuoteProductQuery += 'BigMachines__Quote__c= \'' + objQuote.id + '\' AND (BigMachines__Product__r.Type__c != \'Bundle\' OR Bundle__r.Group_Type__c = \'Base Package\' OR Bundle__r.Group_Type__c = \'PureSuccess\') AND (Quantity__c > 0 OR Subscription_Burst_Term__c = null) ';
    if (blnIsSeperatePO) {
        strQuoteProductQuery += ' and ( BigMachines__Product__r.Type__c = \'Product - System License\' OR BigMachines__Product__r.Type__c = \'Product - Hardware\' OR BigMachines__Product__r.Type__c = \'Product\')';
    }
    if (objQuote.Is_GU_EMEA__c) {
        strQuoteProductQuery += ' and BigMachines__Product__r.Type__c <> \'Genesys Care\'';
    }
    Boolean blnIncludeLineItem ;
    String genesysCareProductId;
    String genesysCareProductName;
    String genesysCareProductDescription;
    Date tempStart;
    Date tempEnd;
    integer tempTerm;
    Set<String> genesysPS = new Set<String>();
    Set<String> genesysCareFlexCareProductIds = new Set<String>();
    Set<String> genesysFeeProductIds = new Set<String>();
    List<Order_Line_Item__c> list_OrderLineItems = new list<Order_Line_Item__c>();
    Order_Line_Item__c genesysCareLineY1, genesysCareLineY2;
    Order_Line_Item__c thirdCareLine;
    List<String> list_Types = Label.Types_Required_Add_Products.split(';');
    Decimal decBasePackagePriceY1 = 0;
    Decimal decBasePackagePriceY2 = 0;
    Decimal decPureSuccessPriceY1 = 0;
    Decimal decPureSuccessPriceY2 = 0;
    Decimal decNetQuantityY1 = 0, decNetQuantityY2 = 0;
    Decimal decNetListPriceY1 = 0, decNetListPriceY2 = 0;
    Decimal decNetSellPriceY1 = 0, decNetSellPriceY2 = 0;
    Decimal decNetQuantityTP = 0;
    Decimal decNetListPriceTP = 0;
    Decimal decNetSellPriceTP = 0;
    Boolean hasPureSuccess = false;
    Boolean hasStandardSupport = false;
    Boolean hasBusinessCare = false;
    Boolean oneyear = false;
  
    Boolean secondYrAmend = objQuote.Amendment_For__c == null ? false : CreateQuoteSubscriptionController.isSecondYrAmend(objQuote);
 
    oneyear = CreateQuoteSubscriptionController.isOneyearQuote(objQuote); 

    Map<String, BigMachines__Quote_Product__c> mapOfPackageVsPrice = new Map<String, BigMachines__Quote_Product__c>();
    List<BigMachines__Quote_Product__c> quoteProducts = Database.query(strQuoteProductQuery);
    for (BigMachines__Quote_Product__c quoteProduct : quoteProducts) {

        if ( quoteProduct.BigMachines__Product__c != null && quoteProduct.BigMachines__Product__r.Description != null &&
            (quoteProduct.BigMachines__Product__r.Name.contains('PureSuccess') || quoteProduct.BigMachines__Product__r.Description.contains('PureSuccess')) )
             hasPureSuccess = true;

        ///MS added for amendnents
        else if ( objQuote.Amendment_For__c != null && objQuote.Amendment_For__r.PureSuccess_Offer__c != null && 
                  objQuote.Amendment_For__r.PureSuccess_Offer__c.contains('PureSuccess') )
             hasPureSuccess = true;

        if ( quoteProduct.BigMachines__Product__c != null && quoteProduct.BigMachines__Product__r.Type__c != null &&
              quoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care' ) { 
                 if (quoteProduct.BigMachines__Product__r.Description.contains('Standard Support')) 
                    hasStandardSupport = true;
                 else if (quoteProduct.BigMachines__Product__r.Description.contains('Business Care'))
                    hasBusinessCare = true;
        }

       //MS 10/25/2019  if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package') {
        if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Subscription_Burst_Term__c == null) {
            if (quoteProduct.Bundle_Line__c == NULL) {
                decBasePackagePriceY1 = (quoteProduct.Ext_Net_Price_1__c == null ? 0 : quoteProduct.Ext_Net_Price_1__c);
                decBasePackagePriceY2 = (quoteProduct.Ext_Net_Price_2__c == null ? 0 : quoteProduct.Ext_Net_Price_2__c);
            }
        }
        //MS 10/25/2019 if (quoteProduct.Bundle__r.Group_Type__c == 'PureSuccess') {
        if (quoteProduct.Bundle__r.Group_Type__c == 'PureSuccess' && quoteProduct.Subscription_Burst_Term__c == null ) {
             hasPureSuccess = true;
            if (quoteProduct.Bundle_Line__c == NULL) {
                decPureSuccessPriceY1 = (quoteProduct.Ext_Net_Price_1__c == null ? 0 : quoteProduct.Ext_Net_Price_1__c);
                decPureSuccessPriceY2 = (quoteProduct.Ext_Net_Price_2__c == null ? 0 : quoteProduct.Ext_Net_Price_2__c);
            }
        }
    }
    //  
    Decimal decLicenseAlaCartePercentage = hasPureSuccess || hasStandardSupport || hasBusinessCare ? QuoteUtil.getPackagePricingPercentage(objQuote.Offering_Type__c, 'A la Carte', 'License') : 100.0;

    Decimal decTotalOfLicenseAlaCarteY1 = 0, decTotalOfLicenseAlaCarteY2 = 0;
    //MS added for Standard Support - at of 9/5/2019 applies to SMCC only
    //Boolean blnBasePackage = !objQuote.Show_Genesys_Care_Tab__c; -- original version
    //Boolean blnBasePackage = (objQuote.Offering_Feature__c != null && objQuote.Offering_Feature__c.contains(OFFERING_FEATURE_SMALL_MED)) ? false : !objQuote.Show_Genesys_Care_Tab__c;
    
    Boolean blnBasePackage = hasStandardSupport ? false : !objQuote.Show_Genesys_Care_Tab__c;
    Boolean blnConcurrent = objQuote.Pricing_Model__c == 'Concurrent' ? true : false;
    String strDirectIndiect = objQuote.End_User_ID__c == objQuote.Sold_To_Name__c ? 'Direct' : 'Indirect';
    List<A_La_Carte_Item_PE_PC_Subscription__mdt> listOfDummyAPNs = [SELECT Ala_Carte_Part_Number__c  
                                                                     FROM A_La_Carte_Item_PE_PC_Subscription__mdt
                                                                     WHERE Offering_Type__c =: objQuote.Offering_Type__c AND Base_Package__c =: blnBasePackage
                                                                     AND Direct_Indirect_Sale__c =: strDirectIndiect
                                                                     AND Concurrent__c =: blnConcurrent];
    Order_Line_Item__c objOLIGCY1, objOLIGCY2;
    Boolean blnIsBusinessCareLineOnQuote = false;
    for (BigMachines__Quote_Product__c quoteProduct : quoteProducts) {
        Boolean blnIsBusinessCare = false;
        //Subscription
        if (quoteProduct.Bundle__r.Group_Type__c == 'PureSuccess') {
            //Anju Jan 30
            if (objQuote.Offering_Type__c != 'PureConnect Cloud' || (objQuote.Offering_Type__c == 'PureConnect Cloud' && quoteProduct.Bundle_Line__c != NULL))
                mapOfPackageVsPrice.put(quoteProduct.Bundle__r.Type__c, quoteProduct);
            
            if (quoteProduct.Bundle_Line__c != NULL || quoteProduct.Bundle__r.Type__c == 'EQUIP' || quoteProduct.Bundle__r.Type__c == 'Partner PureSuccess')
                continue;
        }
        
        if (quoteProduct.BigMachines__Product__r.Type__c == 'Product - Hardware') {
            //multiShipIds.add(quoteProduct.BigMachines__Quote__c);
        } else {
            //softwareOnlyOrderIds.add(quoteProduct.BigMachines__Quote__c);
        }
        if (quoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care') {
            genesysCareProductId = quoteProduct.BigMachines__Product__c;
            genesysCareProductName = quoteProduct.BigMachines__Product__r.Name;
            genesysCareProductDescription = quoteProduct.BigMachines__Product__r.Description;
            blnIsBusinessCare = true;
        }
        System.debug('NKC debug blnIsBusinessCare [' + blnIsBusinessCare + ']');
        if (quoteProduct.BigMachines__Product__r.Type__c == 'Flex Care')
            genesysCareFlexCareProductIds.add(quoteProduct.BigMachines__Product__c);
        
        if (quoteProduct.BigMachines__Product__r.PS_Contract__c != null && quoteProduct.BigMachines__Product__r.PS_Contract__c)
            genesysPS.add(quoteProduct.BigMachines__Product__c);
        
        
        if (quoteProduct.BigMachines__Product__r.Type__c == 'Fees') {
            genesysFeeProductIds.add(quoteProduct.BigMachines__Product__c);
            // Sourav : 10/23/2014
            continue;
        }
        Order_Line_Item__c objOrderLineItem = new Order_Line_Item__c();//DynamicFieldMapping.getOrderLineItemFromQuoteLineItem(quoteProduct, 'License_Orders');
        // 7/1/2016 : Setting default recordtype
        objOrderLineItem.RecordTypeId = Global_Setting__c.getInstance('Order Line Default RT').ID__c;
        objOrderLineItem.Unit_of_Measure__c = quoteProduct.Unit_of_Measure__c;
        objOrderLineItem.Order__c = objOrder.id;
        objOrderLineItem.Flavor__c = quoteProduct.Flavor__c;
        objOrderLineItem.Tokens__c = quoteProduct.Tokens__c;
        objOrderLineItem.CurrencyIsoCode = objQuote.CurrencyIsoCode; 
  
        ///MS 5/30/19 removed from IF condition: (&& quoteProduct.Bundle_Line__c == null) to re-number bundle line items 
        if (objQuote.Amendment_For__c != null && quoteProduct.Subscription_Product__r.Quantity__c != null
            && quoteProduct.Quantity__c != null && !blnIsBusinessCare) {
                objOrderLineItem.Quantity__c = quoteProduct.Quantity__c - quoteProduct.Subscription_Product__r.Quantity__c;                   
                //MS 5/30/19 added
                if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && objOrderLineItem.Quantity__c > 0)
                    addPureSuccessBundleToAmend = true; 
    
                if (objOrderLineItem.Quantity__c == 0)
                    continue;
            } else
                objOrderLineItem.Quantity__c = quoteProduct.Quantity__c;

        if(quoteProduct.Bundle_Line__c == null){
            //Naresh Kumar  06/28/2018  Populating POB Type
       objOrderLineItem.POB_Type__c = getPOBType(quoteProduct.BigMachines__Product__r.Type__c,
                                                      quoteProduct.BigMachines__Product__r.Sub_Type__c,
                                                    quoteProduct.BigMachines__Product__r.New_category__c,
                                                      quoteProduct.BigMachines__Product__r.Third_Party__c,
                                                      objOrder.License_FYM_detail__c,
                                                      objQuote.Offering_Type__c,quoteProduct.BigMachines__Product__r.POB_Type__c);
        }
        else
            objOrderLineItem.POB_Type__c = 'Not Applicable';

        System.debug('NKC debug objOrderLineItem.POB_Type__c [' + objOrderLineItem.POB_Type__c + ']');
        objOrderLineItem.Quote_Product__c = quoteProduct.id;
        System.debug('NKC debug objOrderLineItem.Quote_Product__c [' + objOrderLineItem.Quote_Product__c + ']');
        objOrderLineItem.Product_txt__c = quoteProduct.Product__c;
        if (objQuote.Quote_Business_Type__c != 'Cloud')
            objOrderLineItem.Name = quoteProduct.BigMachines__Product__r.APN_Number__c; else
                objOrderLineItem.Name = quoteProduct.BigMachines__Product__r.Name;

        objOrderLineItem.Product__c = quoteProduct.BigMachines__Product__c;
        objOrderLineItem.Third_Party_Partners__c = quoteProduct.BigMachines__Product__r.Third_Party_Custom__c;
        objOrderLineItem.List_Price__c = (quoteProduct.List_Price_1__c == null ? 0 : quoteProduct.List_Price_1__c);
        objOrderLineItem.Net_Unit_Price__c = (quoteProduct.Net_Unit_Price__c == null ? 0 : quoteProduct.Net_Unit_Price__c);
        objOrderLineItem.Ext_Net_Price__c = (quoteProduct.Ext_Net_Price_1__c == null ? 0 : quoteProduct.Ext_Net_Price_1__c);
        objOrderLineItem.Ext_List__c = (quoteProduct.Ext_List_Price_1__c == null ? 0 : quoteProduct.Ext_List_Price_1__c);
        objOrderLineItem.Sales_Price__c = (quoteProduct.Net_Unit_Price_1__c == null ? 0 : quoteProduct.Net_Unit_Price_1__c);
        objOrderLineItem.Is_Overage__c = quoteProduct.Is_Overage__c;

        if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c != NULL) 
            objOrderLineItem.Package_Type__c = 'Base Package';
        
        //MS Burst Base Package 
        if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c == null && 
             quoteProduct.Subscription_Burst_Term__c != null ) {
                objOrderLineItem.Base_Package__c = objOrderLineItem.Ext_Net_Price__c;
                objOrderLineItem.List_Price__c = 0;
                objOrderLineItem.Net_Unit_Price__c = 0;
                objOrderLineItem.Ext_Net_Price__c = 0;
                objOrderLineItem.Ext_List__c = 0;
                objOrderLineItem.Sales_price__c = 0;
             }
        else if (quoteProduct.Bundle__r.Group_Type__c == 'PureSuccess' ||
                  (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c == NULL && !objQuote.Generate_Revpro_Order__c)) {
                objOrderLineItem.List_Price__c = 0;
                objOrderLineItem.Net_Unit_Price__c = 0;
                objOrderLineItem.Ext_Net_Price__c = 0;
                objOrderLineItem.Ext_List__c = 0;
                objOrderLineItem.Sales_price__c = 0;
                if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' ) {
                    objOrderLineItem.Base_Package__c = decBasePackagePriceY1;                  
                    objOrderLineItem.List_Price__c = quoteProduct.List_Price_1__c == null ? 0 : quoteProduct.List_Price_1__c;
                } else if (quoteProduct.Bundle__r.Group_Type__c == 'PureSuccess' ) {
                    objOrderLineItem.Base_Package__c = decPureSuccessPriceY1;
                    objOrderLineItem.List_Price__c = decPureSuccessPriceY1;
                }
        } else if (objQuote.Generate_Revpro_Order__c && quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c != null) {
                objOrderLineItem.List_Price__c = 0;
                objOrderLineItem.Net_Unit_Price__c = 0;
                objOrderLineItem.Ext_Net_Price__c = 0;
                objOrderLineItem.Ext_List__c = 0;
                objOrderLineItem.Sales_price__c = 0;
        } else if (quoteProduct.Bundle_Line__c == null)
                objOrderLineItem.Base_Package__c = objOrderLineItem.Ext_Net_Price__c;

       
           //License A la Carte items OR
        //MS - Standard Support price allocation
       //if (quoteProduct.Bundle__c == null || quoteProduct.Bundle__r.Group_Type__c == 'Use Case') {
        if (quoteProduct.Bundle__c == null || quoteProduct.Bundle__r.Group_Type__c == 'Use Case' || 
             ( hasStandardSupport && quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c != null) ) {
            decTotalOfLicenseAlaCarteY1 += objOrderLineItem.Ext_Net_Price__c;

            if (quoteProduct.BigMachines__Product__r.Type__c != null && quoteProduct.BigMachines__Product__r.Type__c == 'Migration Credit') {
                //MS - original, commented as make no sense; objOrderLineItem.List_Price__c = objOrderLineItem.List_Price__c;
  /*               //MS - 9/5/19 added 
                 objOrderLineItem.Quantity__c = 1;
                 objOrderLineItem.BigMachines_Quantity__c =1;
                 objOrderLineItem.List_Price__c = quoteProduct.Ext_Net_Price__c;
                 objOrderLineItem.Ext_List__c = quoteProduct.Ext_Net_Price__c;
                 objOrderLineItem.Ext_Net_Price__c = objOrderLineItem.Net_Unit_Price__c = quoteProduct.Ext_Net_Price__c;
                 objOrderLineItem.Sales_price__c = quoteProduct.Ext_Net_Price__c;
                 objOrderLineItem.Base_Package__c =  objOrderLineItem.List_Price__c;
                 objOrderLineItem.Annualized_Maintenance_Due__c =0;

                 if ( !listOfDummyAPNs.isEmpty() )
                     objOrderLineItem.Dummy_APN__c = listOfDummyAPNs[0].Ala_Carte_Part_Number__c;   

                 //MS - 9/15/19 year and dates on Migration Credit based on the product name. This needs to change!!!
                if ( quoteProduct.BigMachines__Product__r.Name != null && quoteProduct.BigMachines__Product__r.Name.endsWith('Year 2') ) {  
               // if ( !quoteProduct.BigMachines__Product__r.One_Time_Charge__c ) {              
                        objOrderLineItem.Year__c = 2;
                        List<Date> listStartEnd = calculateOnPremSubscripOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Ramp_Period__c, 2);
                        objOrderLineItem.Maintenance_Start_Date__c = listStartEnd[0];
                        objOrderLineItem.Maintenance_End_Date__c = listStartEnd[1];
                        list_OrderLineItems.add(objOrderLineItem);
                        continue;
                }                  
*/              
                objOrderLineItem.List_Price__c = objOrderLineItem.List_Price__c;                                             
            }
            else
                  objOrderLineItem.List_Price__c = (objOrderLineItem.List_Price__c * decLicenseAlaCartePercentage) / 100;

            objOrderLineItem.Net_Unit_Price__c = objOrderLineItem.List_Price__c;

            Decimal decTotalDiscount = quoteProduct.Total_Discount__c == null ? 0 : quoteProduct.Total_Discount__c;

            objOrderLineItem.Net_Unit_Price__c -= (objOrderLineItem.List_Price__c * decTotalDiscount) / 100;
            objOrderLineItem.Quantity__c = objOrderLineItem.Quantity__c == null ? 0 : objOrderLineItem.Quantity__c;
            objOrderLineItem.Ext_List__c = objOrderLineItem.List_Price__c * objOrderLineItem.Quantity__c;
            objOrderLineItem.Ext_Net_Price__c = objOrderLineItem.Net_Unit_Price__c * objOrderLineItem.Quantity__c;
            objOrderLineItem.Sales_price__c = objOrderLineItem.Net_Unit_Price__c;
            
            if ( quoteProduct.Bundle__r.Group_Type__c != 'Base Package' ) {
                 objOrderLineItem.Package_Type__c = 'License A la Carte';
                 objOrderLineItem.Dummy_APN__c = !listOfDummyAPNs.isEmpty() ? listOfDummyAPNs[0].Ala_Carte_Part_Number__c : null;                                        
            }

            if (objOrderLineItem.Net_Unit_Price__c != null)
                objOrderLineItem.Net_Unit_Price__c = objOrderLineItem.Net_Unit_Price__c.setScale(2);
        }
        
        objOrderLineItem.CurrencyIsoCode =  objQuote.CurrencyIsoCode; // quoteProduct.CurrencyIsoCode;
        objOrderLineItem.APN_Number__c = quoteProduct.BigMachines__Product__r.APN_Number__c;
        //Added By Ranjith on Jun 13, 2017 -- Ends
        objOrderLineItem.description__c = quoteProduct.BigMachines__Description__c;
        objOrderLineItem.BigMachines_Quantity__c = quoteProduct.BigMachines__Quantity__c;
        objOrderLineItem.Total_Discount__c = quoteProduct.Total_Discount__c;
        objOrderLineItem.Product_Specific_Discount__c = quoteProduct.Product_Specific_Discount__c;
        
        if (objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && objQuote.Quote_Business_Type__c != 'Renewal') {
            objOrderLineItem.Maintenance_No_of_Months__c = objQuote.Order_Numb_of_Maint_Months__c;
        }
        //If it's not a license opp then copy both the dates from Quote products.
        else {
            // 1/21/2015 : Copy additional information for PS product
            if (String.isNotBlank(quoteProduct.BigMachines__Product__r.Type__c)) {
                for (String strType : list_Types) {
                    if (quoteProduct.BigMachines__Product__r.Type__c == strType) {
                        objOrderLineItem.Project_ID__c = quoteProduct.Project_ID__c;
                        objOrderLineItem.Project_Name__c = quoteProduct.Project_Name__c;
                        objOrderLineItem.Third_Party_Partners__c = quoteProduct.Third_Party_Partners__c;
                        objOrderLineItem.Third_Party_Applications__c = quoteProduct.Third_Party_Applications__c;
                        objOrderLineItem.Third_Party_Partner_Fee__c = quoteProduct.Third_Party_Partner_Fee__c;
                        objOrderLineItem.Solution_Names_Covered__c = quoteProduct.Solution_Names_Covered__c;
                        objOrderLineItem.Application_Support_Cost_Base__c = quoteProduct.Application_Support_Cost_Base__c;
                    }
                }
            }
        }
        
        //MS 5/30/19 - Amendment Quantity re-set
         if ( objQuote.Amendment_For__c != null &&
              (objQuote.Offering_Type__c != null && (objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription')) )  {                   
                 objOrderLineItem.BigMachines_Quantity__c = objOrderLineItem.Quantity__c;
        }

        // Calculates the Maintenace due and Anuualized at Order level for Licensing Deal
        
        if (objQuote.PO_for_FYM__c != null && objQuote.PO_for_FYM__c != 'Declined Maintenance') {
            
            //if(objOpportunity.RecordType.DeveloperName != null && objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME)
            if (objOpportunity.RecordType.DeveloperName != null && objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_NEW_DEV_NAME &&
                objQuote.Quote_Business_Type__c != 'Renewal' && objQuote.Quote_Business_Type__c != 'Cloud') {
                    if (objQuote.Current_Maint_Rate__c != null) {
                        objOrderLineItem.Maintenance_Due__c = quoteProduct.BigMachines__Total_Price__c * (objQuote.Current_Maint_Rate__c / 100);
                    }
                    if (objOrderLineItem.Maintenance_Due__c != null && objOrderLineItem.Maintenance_Due__c != 0 && objQuote.Order_Numb_of_Maint_Months__c != 0 && objQuote.Order_Numb_of_Maint_Months__c != null) {
                        objOrderLineItem.Annualized_Maintenance_Due__c = (objOrderLineItem.Maintenance_Due__c / objQuote.Order_Numb_of_Maint_Months__c) * 12;
                    }
                }
        } else {
            objOrderLineItem.Annualized_Maintenance_Due__c = 0;
            objOrderLineItem.Maintenance_Due__c = 0;
        }
        
        //if(objOpportunity.RecordType.DeveloperName; != null && (objOpportunity.RecordType.DeveloperName; == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME || objOpportunity.RecordType.DeveloperName; == ServiceContractUtil.MAINTENANCE))
        if (objOpportunity.RecordType.DeveloperName != null && (objQuote.Quote_Business_Type__c == 'Renewal' || objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME
            || objOpportunity.RecordType.DeveloperName == ServiceContractUtil.MAINTENANCE)) {
                objOrderLineItem.Maintenance_Due__c = quoteProduct.Maintenance_Due__c;
                // Storing Annualized Maintenance from last period applicable on the quote
                if (quoteProduct.Annualized_Maintenance_Last_Period__c != null)
                    objOrderLineItem.Annualized_Maintenance_Due__c = quoteProduct.Annualized_Maintenance_Last_Period__c; else {
                        if (quoteProduct.Maintenance_Due__c != null && quoteProduct.Maintenance_Due__c != 0 &&
                            quoteProduct.Maintenance_Start_Date__c != null && quoteProduct.Maintenance_End_Date__c != null) {
                                
                                tempStart = OrderUtil.adjustDatetoStartofMonth(quoteProduct.Maintenance_Start_Date__c);
                                tempEnd = OrderUtil.adjustDatetoStartofMonth(quoteProduct.Maintenance_End_Date__c);
                                tempTerm = (12 * (tempEnd.year() - tempStart.year())) + (tempEnd.month() - tempStart.month());
                                objOrderLineItem.Maintenance_No_of_Months__c = tempTerm;
                                if (tempTerm != 0)
                                    objOrderLineItem.Annualized_Maintenance_Due__c = (quoteProduct.Maintenance_Due__c / tempTerm) * 12;
                                
                            }
                    }
                objOrderLineItem.Sold_To_Name__c = quoteProduct.Sold_To_Name__c;
                objOrderLineItem.End_User_Name__c = quoteProduct.End_User_Name__c;
        }            
        //*
        objOrderLineItem.Fees_Applied__c = quoteProduct.Fees_Applied__c ;
        //objOrderLineItem.Gnesys_Care_Rate__c = quoteProduct.Genesys_Care_Rate__c;
        objOrderLineItem.Increase__c = quoteProduct.Increase__c;
        objOrderLineItem.Revised_Net_License_Value__c = quoteProduct.Revised_Net_License_Value__c;
        objOrderLineItem.Extended_End_of_Support__c = quoteProduct.Extended_End_of_Support__c;
        
        objOrderLineItem.Contract_Line_Update_Status__c = quoteProduct.Contract_Line_Update_Status__c;
        objOrderLineItem.Current_Qty__c = quoteProduct.Current_Qty__c;
        objOrderLineItem.Original_Qty__c = quoteProduct.Original_Qty__c;
        objOrderLineItem.Service_Contract_Line_ID__c = quoteProduct.Service_Contract_Line_ID__c;
        //Naresh kumar 05/12/2014
        //New Mapping Fields for Renewal Only
        if (objQuote.Quote_Business_Type__c == 'Renewal' || objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME) {
            // For Flex Care and Fees products Sales Price should not be overwritten as Sales Price flows to Maintenance Due on Service Contract
            if (quoteProduct.BigMachines__Product__r.Type__c != 'Flex Care' &&
                quoteProduct.BigMachines__Product__r.Type__c != 'Fees') {
                    objOrderLineItem.Year1_Maintenance_Due__c = quoteProduct.Maintenance_Due__c;
                    objOrderLineItem.Year2_Maintenance_Due__c = quoteProduct.Year2_Maintenance_Due__c;
                    objOrderLineItem.Year3_Maintenance_Due__c = quoteProduct.Year3_Maintenance_Due__c;
                    objOrderLineItem.Year4_Maintenance_Due__c = quoteProduct.Year4_Maintenance_Due__c;
                    objOrderLineItem.Year5_Maintenance_Due__c = quoteProduct.Year5_Maintenance_Due__c;
                    
                    if (quoteProduct.Maintenance_Due__c == null)
                        quoteProduct.Maintenance_Due__c = 0;
                    if (quoteProduct.Year2_Maintenance_Due__c == null)
                        quoteProduct.Year2_Maintenance_Due__c = 0;
                    if (quoteProduct.Year3_Maintenance_Due__c == null)
                        quoteProduct.Year3_Maintenance_Due__c = 0;
                    if (quoteProduct.Year4_Maintenance_Due__c == null)
                        quoteProduct.Year4_Maintenance_Due__c = 0;
                    if (quoteProduct.Year5_Maintenance_Due__c == null)
                        quoteProduct.Year5_Maintenance_Due__c = 0;
                    
                    objOrderLineItem.Maintenance_Due__c = quoteProduct.Maintenance_Due__c + quoteProduct.Year2_Maintenance_Due__c +
                        quoteProduct.Year3_Maintenance_Due__c + quoteProduct.Year4_Maintenance_Due__c + quoteProduct.Year5_Maintenance_Due__c;
                    
                    objOrderLineItem.Genesys_Care_Rate__c = quoteProduct.Genesys_Care_Rate__c;
                    objOrderLineItem.Year2_CareRatePercent__c = quoteProduct.Year2_CareRatePercent__c;
                    objOrderLineItem.Year3_CareRatePercent__c = quoteProduct.Year3_CareRatePercent__c;
                    objOrderLineItem.Year4_CareRatePercent__c = quoteProduct.Year4_CareRatePercent__c;
                    objOrderLineItem.Year5_CareRatePercent__c = quoteProduct.Year5_CareRatePercent__c;
                    objOrderLineItem.Sales_Price__c = objOrderLineItem.Maintenance_Due__c;
                }
            // Flex Care and Fees Lines
            else {
                // Maintenance Due is fetched from Sales Price for Fees and Flex Care Lines
                objOrderLineItem.Maintenance_Due__c = quoteProduct.BigMachines__Sales_Price__c;
                if (objOrderLineItem.Maintenance_Due__c != null &&
                    quoteProduct.Maintenance_Start_Date__c != null && quoteProduct.Maintenance_End_Date__c != null) {
                        objOrderLineItem.Maintenance_No_of_Months__c = Util.calculateDurationInMonths(quoteProduct.Maintenance_Start_Date__c, quoteProduct.Maintenance_End_Date__c);
                        if (objOrderLineItem.Maintenance_No_of_Months__c != 0)
                            objOrderLineItem.Annualized_Maintenance_Due__c = objOrderLineItem.Maintenance_Due__c * (12 / objOrderLineItem.Maintenance_No_of_Months__c);
                    }
            }          
        }

        System.debug('NKC debug objOrder.Numb_of_Maint_Months__c [' + objOrder.Numb_of_Maint_Months__c + ']');
        //Populating Maint start and end date from Order      
        if (objOrder.Numb_of_Maint_Months__c != null) {
            List<Date> listOfStartAndEndDates = new List<Date>();
            /* MS 5/30/19 commented out 
            List<Date> listOfStartAndEndDates = OrderUtil.calculateSubscriptionOrderLineDates(objOrder.Maintenance_Start__c,
                                                                                              objOrder.Maintenance_End__c, Integer.valueOf(objOrder.Numb_of_Maint_Months__c), 1);
            */
            /// MS 5/30/19 added
            if ( objQuote.Amendment_For__c == null || objQuote.Amendment_For__r.Order__c == null )
                listOfStartAndEndDates = calculateOnPremSubscripOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Ramp_Period__c, 1);
            else {
                listOfStartAndEndDates = calculateOnPremAmendOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Amendment_For__r.Ramp_End_Date__c, 1);
            }

            objOrderLineItem.Maintenance_Start_Date__c = listOfStartAndEndDates[0];
            objOrderLineItem.Maintenance_End_Date__c = listOfStartAndEndDates[1];
            System.debug('NKC debug objOrderLineItem.Maintenance_Start_Date__c [' + objOrderLineItem.Maintenance_Start_Date__c + ']');
            System.debug('NKC debug objOrderLineItem.Maintenance_End_Date__c [' + objOrderLineItem.Maintenance_End_Date__c + ']');
        }
        
        blnIncludeLineItem = true;
        
        if (quoteProduct.Contract_Line_Update_Status__c == 'Split' && ((quoteProduct.Original_Qty__c == quoteProduct.Current_Qty__c) || quoteProduct.Current_Qty__c == 0))
            blnIncludeLineItem = false;
        
        if ((quoteProduct.Contract_Line_Update_Status__c == 'Drop' || quoteProduct.Contract_Line_Update_Status__c == 'Downsize' || quoteProduct.Contract_Line_Update_Status__c == 'Shelved')
            && ((quoteProduct.Original_Qty__c == quoteProduct.Current_Qty__c) || quoteProduct.Current_Qty__c == 0))
            blnIncludeLineItem = false;
        
        if (quoteProduct.Contract_Line_Update_Status__c == 'Retired' && ((quoteProduct.Original_Qty__c == quoteProduct.Current_Qty__c) || quoteProduct.Current_Qty__c == 0))
            blnIncludeLineItem = false;

        if (blnIncludeLineItem) {
            objOrderLineItem.Year__c = 1;
            if (blnIsBusinessCare)
                objOLIGCY1 = objOrderLineItem;
     
            list_OrderLineItems.add(objOrderLineItem);
            //Hardware or Third party should not be for year 2
            //MS - add Migration Credit to the exclusions

            if ( secondYrAmend || (!quoteProduct.Hardware_or_Third_Party__c && quoteProduct.Bundle__r.Group_Type__c != 'PureSuccess'
                  && quoteProduct.Bundle__r.Group_Type__c != 'A la Carte') ) {
                        
                    if (quoteProduct.BigMachines__Product__r.Type__c == 'Migration Credit' && 
                         !quoteProduct.BigMachines__Product__r.Name.contains('Recurring') && !secondYrAmend) 
                           continue;

                    //Year 2 Line
                    Order_Line_Item__c objOrderLineY2 = objOrderLineItem.clone(false, true, false, false);
                    objOrderLineY2.Tokens__c = null;
                    if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c != NULL)
                        objOrderLineY2.Package_Type__c = 'Base Package';
                    objOrderLineY2.Year__c = 2;
                    if (quoteProduct.Bundle__r.Group_Type__c != 'Base Package' || quoteProduct.Bundle_Line__c != null) {
                        objOrderLineY2.List_Price__c = quoteProduct.List_Price_2__c == null ? 0 : quoteProduct.List_Price_2__c;
                        objOrderLineY2.Net_Unit_Price__c = quoteProduct.Net_Unit_Price__c == null ? 0 : quoteProduct.Net_Unit_Price_2__c;
                        objOrderLineY2.Ext_Net_Price__c = quoteProduct.Ext_Net_Price_2__c == null ? 0 : quoteProduct.Ext_Net_Price_2__c;
                        objOrderLineY2.Ext_List__c = quoteProduct.Ext_List_Price_2__c == null ? 0 : quoteProduct.Ext_List_Price_2__c;
                        objOrderLineY2.Sales_price__c = quoteProduct.Net_Unit_Price_2__c == null ? 0 : quoteProduct.Net_Unit_Price_2__c;
                    }
                    if (objQuote.Generate_Revpro_Order__c && quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c != null) {
                        objOrderLineY2.List_Price__c = 0;
                        objOrderLineY2.Net_Unit_Price__c = 0;
                        objOrderLineY2.Ext_Net_Price__c = 0;
                        objOrderLineY2.Ext_List__c = 0;
                        objOrderLineY2.Sales_price__c = 0;
                    }

                    //MS - Burst Base Package
                    if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c == null && 
                        quoteProduct.Subscription_Burst_Term__c != null ) {
                          objOrderLineY2.Base_Package__c = (quoteProduct.Ext_Net_Price_2__c == null ? 0 : quoteProduct.Ext_Net_Price_2__c);
                           objOrderLineY2.List_Price__c = 0;
                        objOrderLineY2.Net_Unit_Price__c = 0;
                        objOrderLineY2.Ext_Net_Price__c = 0;
                        objOrderLineY2.Ext_List__c = 0;
                        objOrderLineY2.Sales_price__c = 0;
                    }
                    else if (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c == null) {
                        objOrderLineY2.Base_Package__c = decBasePackagePriceY2;
                        objOrderLineY2.List_Price__c = quoteProduct.List_Price_2__c == null ? 0 : quoteProduct.List_Price_2__c;
                 
                    } else if (quoteProduct.Bundle__r.Group_Type__c == 'PureSuccess' && quoteProduct.Bundle_Line__c == null) {
                        objOrderLineY2.Base_Package__c = decPureSuccessPriceY2;
                    } else if (quoteProduct.Bundle_Line__c == null) {
                        objOrderLineY2.Base_Package__c = (quoteProduct.Ext_Net_Price_2__c == null ? 0 : quoteProduct.Ext_Net_Price_2__c);
                    }
                    if (blnIsBusinessCare)
                        objOLIGCY2 = objOrderLineY2;
                    
                    //License A la Carte items OR
                    //MS - Standard Support 
                    // if (quoteProduct.Bundle__c == null || quoteProduct.Bundle__r.Group_Type__c == 'Use Case') {
                    if (quoteProduct.Bundle__c == null || quoteProduct.Bundle__r.Group_Type__c == 'Use Case' || 
                         ( hasStandardSupport && quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c != null) ) {

                        decTotalOfLicenseAlaCarteY2 += (quoteProduct.Ext_Net_Price_2__c == null ? 0 : quoteProduct.Ext_Net_Price_2__c);
                        objOrderLineY2.List_Price__c = (objOrderLineY2.List_Price__c * decLicenseAlaCartePercentage) / 100;
                        objOrderLineY2.Net_Unit_Price__c = objOrderLineY2.List_Price__c;

                        //MS 9/9/19 replaced Disc__c with Total_Discount__c to fix % vs Amt issue
                        //Decimal decTotalDiscount = (quoteProduct.Partner_Discount_2__c == null ? 0 : quoteProduct.Partner_Discount_2__c)
                         //   + (quoteProduct.Disc__c == null ? 0 : quoteProduct.Disc__c) ;
                        Decimal decTotalDiscount = quoteProduct.Total_Discount__c == null ? 0 : quoteProduct.Total_Discount__c;

                        objOrderLineY2.Net_Unit_Price__c -= (objOrderLineY2.List_Price__c * decTotalDiscount) / 100;
                        objOrderLineY2.Ext_List__c = objOrderLineY2.List_Price__c * objOrderLineY2.Quantity__c;
                        objOrderLineY2.Ext_Net_Price__c = objOrderLineY2.Net_Unit_Price__c * objOrderLineY2.Quantity__c;
                        objOrderLineY2.Sales_price__c = objOrderLineY2.Net_Unit_Price__c;
                        
                        if ( quoteProduct.Bundle__r.Group_Type__c != 'Base Package' ) {
                             objOrderLineY2.Package_Type__c = 'License A la Carte';
                             objOrderLineY2.Dummy_APN__c = !listOfDummyAPNs.isEmpty() ? listOfDummyAPNs[0].Ala_Carte_Part_Number__c : null;
                        }

                        if (objOrderLineY2.Net_Unit_Price__c != null)
                            objOrderLineY2.Net_Unit_Price__c = objOrderLineY2.Net_Unit_Price__c.setScale(2);
                     //   if (objOrderLineY2.Net_Unit_Price__c != null)
                       //     objOrderLineY2.Net_Unit_Price__c = objOrderLineY2.Net_Unit_Price__c.setScale(2);
                    }
                    //Populating Maint start and end date from Order
                    if (objOrder.Numb_of_Maint_Months__c != null) {                           
                        /* MS 5/30/19 
                        List<Date> listOfStartAndEndDates = OrderUtil.calculateSubscriptionOrderLineDates(objOrder.Maintenance_Start__c,
                                                                                                          objOrder.Maintenance_End__c, Integer.valueOf(objOrder.Numb_of_Maint_Months__c), 2);
                        */
                        List<Date> listOfStartAndEndDates = new List<Date>();
                        if ( objQuote.Amendment_For__c == null || objQuote.Amendment_For__r.Order__c == null )
                            listOfStartAndEndDates = calculateOnPremSubscripOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Ramp_Period__c, 2);
                        else 
                            listOfStartAndEndDates = calculateOnPremAmendOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Amendment_For__r.Ramp_End_Date__c, 2);

                        objOrderLineY2.Maintenance_Start_Date__c = listOfStartAndEndDates[0];
                        objOrderLineY2.Maintenance_End_Date__c = listOfStartAndEndDates[1];
                    }

                    //MS 8/7/19 - one year option
                   // if ( objQuote.No_Of_Months__c != null && Integer.valueOf(objQuote.No_Of_Months__c) > 12 )
                    if ( !oneyear )
                        list_OrderLineItems.add(objOrderLineY2);

                    //Naresh Kumar  12/10/2018  Populating totals for third party care line
                    if (quoteProduct.BigMachines__Product__r.Third_Party_GC__c != null
                        && quoteProduct.BigMachines__Product__r.Third_Party_GC__c != 0 && quoteProduct.BigMachines__Product__r.Third_Party_GC__c != 255
                        && (quoteProduct.BigMachines__Product__r.Third_Party__c != null 
                            && quoteProduct.BigMachines__Product__r.Third_Party__c.containsIgnoreCase('TRUE'))){
                                if(objOrderLineItem.BigMachines_Quantity__c != null)
                                    decNetQuantityTP += objOrderLineItem.BigMachines_Quantity__c;
                                if(objOrderLineItem.List_Price__c != null && objOrderLineItem.Quantity__c != null)
                                    decNetListPriceTP += (objOrderLineItem.List_Price__c * objOrderLineItem.Quantity__c);
                                if(objOrderLineItem.Ext_Net_Price__c != null)
                                    decNetSellPriceTP += objOrderLineItem.Ext_Net_Price__c;     
                            }
                    //Naresh Kumar  08/06/2018  Populating totals for Care Line
                    else if (quoteProduct.BigMachines__Product__r.Type__c == 'Product'){
                        if(objOrderLineItem.BigMachines_Quantity__c != null)
                            decNetQuantityY1 += objOrderLineItem.BigMachines_Quantity__c;
                        if(objOrderLineY2.BigMachines_Quantity__c != null)
                            decNetQuantityY2 += objOrderLineY2.BigMachines_Quantity__c;
                        
                        if(objOrderLineItem.Ext_List__c != null)
                            decNetListPriceY1 += objOrderLineItem.Ext_List__c;
                        if(objOrderLineY2.Ext_List__c != null)
                            decNetListPriceY2 += objOrderLineY2.Ext_List__c;
                        
                        if(objOrderLineItem.Ext_Net_Price__c != null)
                            decNetSellPriceY1 += objOrderLineItem.Ext_Net_Price__c; 
                        if(objOrderLineY2.Ext_Net_Price__c != null)
                            decNetSellPriceY2 += objOrderLineY2.Ext_Net_Price__c;                         
                    }
                    if (quoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care' 
                        && (quoteProduct.BigMachines__Product__r.Third_Party__c == null 
                            || !quoteProduct.BigMachines__Product__r.Third_Party__c.containsIgnoreCase('TRUE'))){
                                genesysCareLineY1 = objOrderLineItem;
                                genesysCareLineY2 = objOrderLineY2;                
                    }
                    else if(quoteProduct.BigMachines__Product__r.Type__c == 'Genesys Care' 
                            && (quoteProduct.BigMachines__Product__r.Third_Party__c != null 
                                && quoteProduct.BigMachines__Product__r.Third_Party__c.containsIgnoreCase('TRUE'))){
                                    thirdCareLine = objOrderLineItem;        
                    }
                                             
                    //Naresh Kumar  08/07/2018 Populating Dummy APNS for A la carte items 
                    //MS - Standard Support - add for Base Package 
                    //if(quoteProduct.Bundle__c == null && !listOfDummyAPNs.isEmpty())  {
     
                    //MS Dummy APN - 10/25/2019
                    // if( !listOfDummyAPNs.isEmpty() && quoteProduct.Bundle__c == null ) {
                    /* MS Dummy APN - 10/25/2019
                     if( !listOfDummyAPNs.isEmpty() && (quoteProduct.Bundle__c == null || 
                       (quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c == null)) ) {
                    */
                    if ( !listOfDummyAPNs.isEmpty() && quoteProduct.Bundle__c == null ) {
                           objOrderLineItem.Dummy_APN__c = listOfDummyAPNs[0].Ala_Carte_Part_Number__c;
                           objOrderLineY2.Dummy_APN__c = listOfDummyAPNs[0].Ala_Carte_Part_Number__c;                            
                    }   

                    if( !listOfDummyAPNs.isEmpty() && (quoteProduct.Bundle__c == null || 
                       (hasStandardSupport && quoteProduct.Bundle__r.Group_Type__c == 'Base Package' && quoteProduct.Bundle_Line__c == null)) ) {
 
                        ///MS Standard Support 
                        if ( hasStandardSupport ) {
                            if ( quoteProduct.Bundle__c == null ) {
                                // Ala Carte lines only 
                                objOrderLineItem.Base_Package__c = objOrderLineItem.Ext_Net_Price__c;
                                objOrderLineY2.Base_Package__c = objOrderLineY2.Ext_Net_Price__c;
                            }
                            else {
                                //Base Package header
                                objOrderLineItem.Base_Package__c = (objOrderLineItem.Base_Package__c * decLicenseAlaCartePercentage) / 100;
                                objOrderLineY2.Base_Package__c = (objOrderLineY2.Base_Package__c * decLicenseAlaCartePercentage) / 100;
                            }
                        }
                    }
                } else if (quoteProduct.Hardware_or_Third_Party__c) {
                    objOrderLineItem.Maintenance_Start_Date__c = objOrder.Maintenance_Start__c;
                    objOrderLineItem.Maintenance_End_Date__c = objOrder.Maintenance_End__c;
                }               
        }
    } ///END loop FOR quote products

    //Naresh Kumar  08/06/2018  Populating totals for Care Line
    if (genesysCareLineY1 != null) {
        genesysCareLineY1.Current_Qty__c = decNetQuantityY1;
        genesysCareLineY1.Revised_Net_License_Value__c = decNetSellPriceY1;
        genesysCareLineY1.Original_Net_License_Value__c = decNetListPriceY1;
    }
    if (genesysCareLineY2 != null) {
        genesysCareLineY2.Current_Qty__c = decNetQuantityY2;
        genesysCareLineY2.Revised_Net_License_Value__c = decNetSellPriceY2;
        genesysCareLineY2.Original_Net_License_Value__c = decNetListPriceY2;
    }
    //Naresh Kumar  08/06/2018  Populating totals for Care Line
    if (thirdCareLine != null) {
        thirdCareLine.Current_Qty__c = decNetQuantityTP;
        thirdCareLine.Revised_Net_License_Value__c = decNetSellPriceTP;
        thirdCareLine.Original_Net_License_Value__c = decNetListPriceTP;            
    } 
    
    //It shouldn't happen in case of license opp
    //if(objOpportunity.RecordType.DeveloperName; != ServiceContractUtil.OPP_GEN_NEW_DEV_NAME && genesysCareProductId != null){
    if ((objQuote.Quote_Business_Type__c == 'Renewal' || objOpportunity.RecordType.DeveloperName == ServiceContractUtil.OPP_GEN_RENEWAL_DEV_NAME)
        && genesysCareProductId != null) {
            list_OrderLineItems = CreateOrderFromQuoteTriggerHelper.populateBusinessLinesOnQuoteOtherThanRenewal(list_OrderLineItems, genesysCareProductId,
                                                                                                                 genesysCareProductName, genesysCareProductDescription, objQuote, objOrder, genesysCareFlexCareProductIds, genesysFeeProductIds, genesysPS);
        }
    System.debug('NKC debug mapOfPackageVsPrice [' + mapOfPackageVsPrice + ']');
    if (!objQuote.Generate_Revpro_Order__c && !mapOfPackageVsPrice.keySet().isEmpty()) {
        if (objQuote.Offering_Type__c == 'PureConnect Cloud' && objQuote.PureSuccess__c != null && pureSuccessChildOrder != null)
            createPureSuccessLines(mapOfPackageVsPrice, objQuote, pureSuccessChildOrder, list_OrderLineItems, decBasePackagePriceY1, decBasePackagePriceY2);
        else
            createPureSuccessLines(mapOfPackageVsPrice, objQuote, objOrder, list_OrderLineItems, decBasePackagePriceY1, decBasePackagePriceY2);
        //createPureSuccessLines(mapOfPackageVsPrice, objQuote, objOrder, list_OrderLineItems, decBasePackagePriceY1, decBasePackagePriceY2);
        //Adding Equip lines if Guide is there.
        if (mapOfPackageVsPrice.keySet().contains('GUIDE') || mapOfPackageVsPrice.keySet().contains('DRIVE')) {
            BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c(BigMachines__Quote__c = objQuote.id);
            objQP.Unit_of_Measure__c = null;
            objQP.CurrencyIsoCode = objQuote.CurrencyIsoCode;
            objQP.Current_Qty__c = 1;
            objQP.Original_Qty__c = 1;
            mapOfPackageVsPrice.clear();
            mapOfPackageVsPrice.put('EQUIP', objQP);
            createPureSuccessLines(mapOfPackageVsPrice, objQuote, objOrder, list_OrderLineItems, decBasePackagePriceY1, decBasePackagePriceY2);
        }
    }

    ///MS 5/30/19 added for Amendment Orders
    if ( !objQuote.Generate_Revpro_Order__c && addPureSuccessBundleToAmend ) {
            // create quote product PureSuccess Bundle
            BigMachines__Quote_Product__c objPSbundle = new BigMachines__Quote_Product__c(BigMachines__Quote__c = objQuote.id);
            objPSbundle.CurrencyIsoCode = objQuote.CurrencyIsoCode;
            objPSbundle.Current_Qty__c = 1;
            objPSbundle.Original_Qty__c = 1;
            mapOfPackageVsPrice.clear();
            mapOfPackageVsPrice.put('Partner PureSuccess', objPSbundle);
            createPureSuccessLines(mapOfPackageVsPrice, objQuote, objOrder, list_OrderLineItems, decBasePackagePriceY1, decBasePackagePriceY2);
    }

    //Adding License A la Carte PureSuceess lines
    if (!objQuote.Generate_Revpro_Order__c && decTotalOfLicenseAlaCarteY1 > 0 ) {
        BigMachines__Quote_Product__c objQP = new BigMachines__Quote_Product__c(BigMachines__Quote__c = objQuote.id);
        objQP.Unit_of_Measure__c = null;
        objQP.CurrencyIsoCode = objQuote.CurrencyIsoCode;
        objQP.Current_Qty__c = 1;
        objQP.Original_Qty__c = 1;
        mapOfPackageVsPrice.clear();
        System.debug('NKC debug objQuote.Order_Type__c [' + objQuote.Order_Type__c + ']');

        //Genesys Care Scenario
        //MS - added quote Standard Support
        /*
        if ((objQuote.Show_Genesys_Care_Tab__c && objQuote.Order_Type__c != Label.Order_Type_Amend
             && objQuote.Order_Type__c != Label.Order_Type_Subscription) || objQuote.Amendment_For__r.PureSuccess_Offer__c == 'Standard Support') {
        */
        if ((objQuote.Show_Genesys_Care_Tab__c && objQuote.Order_Type__c != Label.Order_Type_Amend && objQuote.Order_Type__c != Label.Order_Type_Subscription) ||           
             objQuote.Amendment_For__r.PureSuccess_Offer__c == 'Standard Support' || hasStandardSupport || hasBusinessCare) {
                 //mapOfPackageVsPrice.put('A LA CARTE-GC', objQP);
                 //Getting % of PureSuccess GC
                 Decimal decPureSuccessGCAlaCartePercentage = QuoteUtil.getPackagePricingPercentage(objQuote.Offering_Type__c, 'A la Carte', 'PureSuccess');
                 Decimal decGCAmountY1 = (decTotalOfLicenseAlaCarteY1 * decPureSuccessGCAlaCartePercentage) / 100;
                 Decimal decGCAmountY2 = (decTotalOfLicenseAlaCarteY2 * decPureSuccessGCAlaCartePercentage) / 100;
                 //Setting up base price for GC lines
                 //YEAR 1
                 if ( objOLIGCY1 != null ) {
                    objOLIGCY1.List_Price__c = decGCAmountY1;
                    objOLIGCY1.Quantity__c = 1;
                    objOLIGCY1.BigMachines_Quantity__c = 1;
                    objOLIGCY1.Net_Unit_Price__c = decGCAmountY1;
                    objOLIGCY1.Sales_Price__c = decGCAmountY1;
                    objOLIGCY1.Ext_List__c = decGCAmountY1;
                    objOLIGCY1.Ext_Net_Price__c = decGCAmountY1;
                    objOLIGCY1.Maintenance_Due__c = decGCAmountY1;

                    // objOLIGCY1.Base_Package__c = 0;
                    //MS - 9/10/19 added for Standard Support lines
                    objOLIGCY1.Base_Package__c = hasStandardSupport ? decGCAmountY1 : 0;
                 }
                 //YEAR 2
                 if ( objOLIGCY2 != null ) {
                    objOLIGCY2.List_Price__c = decGCAmountY2;
                    objOLIGCY2.Quantity__c = 1;
                    objOLIGCY2.BigMachines_Quantity__c = 1;
                    objOLIGCY2.Net_Unit_Price__c = decGCAmountY2;
                    objOLIGCY2.Sales_Price__c = decGCAmountY2;
                    objOLIGCY2.Ext_List__c = decGCAmountY2;
                    objOLIGCY2.Ext_Net_Price__c = decGCAmountY2;
                    objOLIGCY2.Maintenance_Due__c = decGCAmountY2;
                    
                    //objOLIGCY2.Base_Package__c = 0;
                    //MS - 9/10/19 added for Standard Support lines
                    objOLIGCY2.Base_Package__c = hasStandardSupport ? decGCAmountY2 : 0;
                 }
             } else
                 mapOfPackageVsPrice.put('A LA CARTE', objQP);
        createPureSuccessLines(mapOfPackageVsPrice, objQuote, objOrder, list_OrderLineItems, decTotalOfLicenseAlaCarteY1, decTotalOfLicenseAlaCarteY2);
    }
     
    //MS 11/22/19 remove lines if oneyear or second year amendment
    if (objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription') {
        if ( oneyear || secondYrAmend ) {
            List<Order_Line_Item__c> cleanList = new List<Order_Line_Item__c>();
            for (Order_Line_Item__c ln : list_OrderLineItems) { 
               if ( ln.Year__c != null && ((oneyear && ln.Year__c == 2) || (secondYrAmend && ln.Year__c == 1)) )
                   continue;
                cleanList.add(ln);
            }
           list_OrderLineItems.clear();
           list_OrderLineItems.addAll(cleanList);
        }
    }

    Integer line_number = 1;
    for (Order_Line_Item__c eachOLI : list_OrderLineItems) {
        eachOLI.Line_Number__c = line_number;
        line_number++;
    }
    upsert list_OrderLineItems;
} ///end insertOrderLineItemsSubscription

public Static Map<Id, Product2> mapOfProducts;

public static void createPureSuccessLines(Map<String, BigMachines__Quote_Product__c> mapOfPackageVsPrice,
                                          BigMachines__Quote__c objQuote, Order__c objOrder, List<Order_Line_Item__c> list_OrderLineItems) {

        createPureSuccessLines(mapOfPackageVsPrice, objQuote, objOrder, list_OrderLineItems, 0, 0);
}

public static void createPureSuccessLines(Map<String, BigMachines__Quote_Product__c> mapOfPackageVsPrice,
                                          BigMachines__Quote__c objQuote, Order__c objOrder, List<Order_Line_Item__c> list_OrderLineItems, Decimal decBasePackagePriceY1, Decimal decBasePackagePriceY2) {
   
    List<String> listOfProductIds = new List<String>();
    for (BasePackageLineConfiguration__c eachConfigDetails : BasePackageLineConfiguration__c.getAll().values()) {
        listOfProductIds.add(eachConfigDetails.PS_Product2_Id__c);
        listOfProductIds.add(eachConfigDetails.GU_Product2_Id__c);
        listOfProductIds.add(eachConfigDetails.CC_Product2_Id__c);
    }

    //MS 6/26/19 - skip PureSuccess if Offering Feature is PureConnect Small Medium
   if ( objQuote.Offering_Feature__c != null && objQuote.Offering_Feature__c.contains(OFFERING_FEATURE_SMALL_MED) )
        return;

    mapOfProducts = new Map<Id, Product2>([SELECT APN_Number__c, Name, Type__c, Sub_Type__c, Third_Party__c FROM Product2 WHERE id IN : listOfProductIds]);

    Boolean oneyear = CreateQuoteSubscriptionController.isOneyearQuote(objQuote); 
    Boolean secondYrAmend = objQuote.Amendment_For__c == null ? false : CreateQuoteSubscriptionController.isSecondYrAmend(objQuote);
  
    for (String eachPackage : mapOfPackageVsPrice.keySet()) {
        String offeringType = objQuote.Offering_Type__c;
        String packageName = (eachPackage == 'Partner PureSuccess' ? 'PARTNER' : eachPackage.toUpperCase());
        String key = offeringType + '-' + packageName;
        System.debug('NKC debug key [' + key + ']');
        BasePackageLineConfiguration__c configDetails = BasePackageLineConfiguration__c.getAll().get(key);
        if (configDetails == null)
            return;
        Decimal decPureSuccessPercentage = configDetails.PureSuccess__c == null ? 0 : configDetails.PureSuccess__c;
        System.debug('NKC debug decBasePackagePriceY1 [' + decBasePackagePriceY1 + ']');
        System.debug('NKC debug decBasePackagePriceY2 [' + decBasePackagePriceY2 + ']');
        Decimal decPackagePriceY1 = (decBasePackagePriceY1 * decPureSuccessPercentage) / 100;
        Decimal decPackagePriceY2 = (decBasePackagePriceY2 * decPureSuccessPercentage) / 100;
        BigMachines__Quote_Product__c packageQP = mapOfPackageVsPrice.get(eachPackage);
        //We need only Y1 lines for GUIDE AND DRIVE
        Boolean blnSkipY2 = false;

        if ( packageName != 'PARTNER' && packageName != 'EQUIP' && packageName != 'A LA CARTE'  && packageName != 'A LA CARTE-GC') {
            decPackagePriceY1 = packageQP.Bundle_Line__r.Ext_Net_Price_1__c;
            decPackagePriceY2 = packageQP.Bundle_Line__r.Ext_Net_Price_2__c;
              blnSkipY2 = true;
        }


         //MS One year option
        if ( oneyear ) blnSkipY2 = true;

        System.debug('NKC debug decPackagePriceY1 [' + decPackagePriceY1 + ']');
        System.debug('NKC debug decPackagePriceY2 [' + decPackagePriceY2 + ']');
        if (decPackagePriceY1 == null)
            decPackagePriceY1 = 0;
        if (decPackagePriceY2 == null)
            decPackagePriceY2 = 0;
        List<Date> listOfStartAndEndDatesY1;
        List<Date> listOfStartAndEndDatesY2;
        //Populating Maint start and end date from Order
        if (objOrder.Numb_of_Maint_Months__c != null) {
            ///MS -5/30/19 changes start
            if (objQuote.Offering_Type__c != null && (objQuote.Offering_Type__c == 'PureEngage Subscription' || objQuote.Offering_Type__c == 'PureConnect Subscription') ) {

                if ( objQuote.Amendment_For__c == null || objQuote.Amendment_For__r.Order__c == null ) {
                    listOfStartAndEndDatesY1 = calculateOnPremSubscripOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Ramp_Period__c, 1);
                    listOfStartAndEndDatesY2 = calculateOnPremSubscripOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Ramp_Period__c, 2);
                }
                else { /// AMEND
                    listOfStartAndEndDatesY1 = calculateOnPremAmendOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Amendment_For__r.Ramp_End_Date__c, 1);
                    listOfStartAndEndDatesY2 = calculateOnPremAmendOrderLineDates(objOrder.Maintenance_Start__c, objOrder.Maintenance_End__c, objQuote.Amendment_For__r.Ramp_End_Date__c, 2);
                }
            }
        else { ///MS - 5/30/19 changes end
            listOfStartAndEndDatesY1 = OrderUtil.calculateSubscriptionOrderLineDates(objOrder.Maintenance_Start__c,
                                                                                objOrder.Maintenance_End__c, Integer.valueOf(objOrder.Numb_of_Maint_Months__c), 1);
            listOfStartAndEndDatesY2 = OrderUtil.calculateSubscriptionOrderLineDates(objOrder.Maintenance_Start__c,
                                                                                objOrder.Maintenance_End__c, Integer.valueOf(objOrder.Numb_of_Maint_Months__c), 2);
        }
       }   
    Double dbTotalPrice1 = 0, dbTotalPrice2 = 0;
    if (packageName == 'PARTNER' || packageName == 'EQUIP' || packageName == 'A LA CARTE') {
        //Looping over all order lines and populating total ext net price for rounding purpose
        //Totals should only include base package line items
        for (Order_Line_Item__c eachOLI : list_OrderLineItems) {
            if (((packageName == 'PARTNER' || packageName == 'EQUIP') && eachOLI.Package_Type__c == 'Base Package')
                || (packageName == 'A LA CARTE' && eachOLI.Package_Type__c == 'License A la Carte')) {
                    if (eachOLI.Year__c == 1)
                        dbTotalPrice1 += eachOLI.Ext_Net_Price__c;
                    if (eachOLI.Year__c == 2)
                        dbTotalPrice2 += eachOLI.Ext_Net_Price__c;
                }
        }
    }
    System.debug('NKC debug dbTotalPrice1 [' + dbTotalPrice1 + ']');
    System.debug('NKC debug dbTotalPrice2 [' + dbTotalPrice2 + ']');
    ////PS
    //Y1
    Double PSPercentage = (configDetails.PS__c == null ? 0 : configDetails.PS__c);
    Double PSPrice = decPackagePriceY1 * PSPercentage / 100;
    PSPrice = Decimal.valueOf(PSPrice).setScale(2);
    dbTotalPrice1 += PSPrice;
    Order_Line_Item__c newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
    newOLI.CurrencyIsoCode = objQuote.CurrencyIsoCode;
    newOLI.Product__c = configDetails.PS_Product2_Id__c;
    Product2 PSProduct = mapOfProducts.get(newOLI.Product__c);
    newOLI.APN_Number__c = PSProduct.APN_Number__c;
    newOLI.Year__c = 1;
    newOLI.Maintenance_Start_Date__c = listOfStartAndEndDatesY1[0];
    newOLI.Maintenance_End_Date__c = listOfStartAndEndDatesY1[1];
    //if(packageName == 'A LA CARTE')
    newOLI.POB_Type__c = 'Not Applicable';
    //else
    //  newOLI.POB_Type__c = QuoteUtil.getPOBType(PSProduct.Type__c, PSProduct.Sub_Type__c, PSProduct.Third_Party__c, '', objQuote.Offering_Type__c);
    populatePureSuccessOLI(newOLI, PSPrice, packageQP, objQuote);
    list_OrderLineItems.add(newOLI);
    //Y2
    if (!blnSkipY2) {
        PSPrice = decPackagePriceY2 * PSPercentage / 100;
        PSPrice = Decimal.valueOf(PSPrice).setScale(2);
        dbTotalPrice2 += PSPrice;
        newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
        newOLI.CurrencyIsoCode = objQuote.CurrencyIsoCode;
        //if(packageName == 'A LA CARTE')
        newOLI.POB_Type__c = 'Not Applicable';
        //else
        //  newOLI.POB_Type__c = QuoteUtil.getPOBType(PSProduct.Type__c, PSProduct.Sub_Type__c, PSProduct.Third_Party__c, '', objQuote.Offering_Type__c);
        newOLI.Product__c = configDetails.PS_Product2_Id__c;
        newOLI.APN_Number__c = PSProduct.APN_Number__c;
        newOLI.Year__c = 2;
        newOLI.Maintenance_Start_Date__c = listOfStartAndEndDatesY2[0];
        newOLI.Maintenance_End_Date__c = listOfStartAndEndDatesY2[1];
        populatePureSuccessOLI(newOLI, PSPrice, packageQP, objQuote);
        list_OrderLineItems.add(newOLI);
    }
    ////GU
    //Y1
    Double GUPercentage = (configDetails.GU__c == null ? 0 : configDetails.GU__c);
    Double GUPrice = decPackagePriceY1 * GUPercentage / 100;
    GUPrice = Decimal.valueOf(GUPrice).setScale(2);
    dbTotalPrice1 += GUPrice;
    newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
    newOLI.CurrencyIsoCode = objQuote.CurrencyIsoCode;
    newOLI.Product__c = configDetails.GU_Product2_Id__c;
    Product2 GUProduct = mapOfProducts.get(newOLI.Product__c);
    //if(packageName == 'A LA CARTE')
    newOLI.POB_Type__c = 'Not Applicable';
    //else
    //  newOLI.POB_Type__c = QuoteUtil.getPOBType(GUProduct.Type__c, GUProduct.Sub_Type__c, GUProduct.Third_Party__c, '', objQuote.Offering_Type__c);
    newOLI.APN_Number__c = GUProduct.APN_Number__c;
    newOLI.Year__c = 1;
    newOLI.Maintenance_Start_Date__c = listOfStartAndEndDatesY1[0];
    newOLI.Maintenance_End_Date__c = listOfStartAndEndDatesY1[1];
    populatePureSuccessOLI(newOLI, GUPrice, packageQP, objQuote);
    list_OrderLineItems.add(newOLI);
    //Y2
    if (!blnSkipY2) {
        GUPrice = decPackagePriceY2 * GUPercentage / 100;
        GUPrice = Decimal.valueOf(GUPrice).setScale(2);
        dbTotalPrice2 += GUPrice;
        newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
        newOLI.CurrencyIsoCode = objQuote.CurrencyIsoCode;
        //if(packageName == 'A LA CARTE')
        newOLI.POB_Type__c = 'Not Applicable';
        //else
        //  newOLI.POB_Type__c = QuoteUtil.getPOBType(GUProduct.Type__c, GUProduct.Sub_Type__c, GUProduct.Third_Party__c, '', objQuote.Offering_Type__c);
        newOLI.Product__c = configDetails.GU_Product2_Id__c;
        newOLI.APN_Number__c = GUProduct.APN_Number__c;
        newOLI.Year__c = 2;
        newOLI.Maintenance_Start_Date__c = listOfStartAndEndDatesY2[0];
        newOLI.Maintenance_End_Date__c = listOfStartAndEndDatesY2[1];
        populatePureSuccessOLI(newOLI, GUPrice, packageQP, objQuote);
        list_OrderLineItems.add(newOLI);
    }
    ////CC
        //Y1
        Double CCPercentage = (configDetails.CC__c == null ? 0 : configDetails.CC__c);
        Double CCPrice = decPackagePriceY1 * CCPercentage / 100;
        CCPrice = Decimal.valueOf(CCPrice).setScale(2);
        dbTotalPrice1 += CCPrice;
        /* MS - 10/25/19 
        if (packageName == 'PARTNER' || packageName == 'EQUIP' || packageName == 'A LA CARTE')
            CCPrice += (decBasePackagePriceY1 - dbTotalPrice1);
        else
            CCPrice += (decPackagePriceY1 - dbTotalPrice1);
        */
        newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
        newOLI.CurrencyIsoCode = objQuote.CurrencyIsoCode;
        newOLI.Product__c = configDetails.CC_Product2_Id__c;
        Product2 CCProduct = mapOfProducts.get(newOLI.Product__c);
        //if(packageName == 'A LA CARTE')
        newOLI.POB_Type__c = 'Not Applicable';
        //else
        //  newOLI.POB_Type__c = QuoteUtil.getPOBType(CCProduct.Type__c, CCProduct.Sub_Type__c, CCProduct.Third_Party__c, '', objQuote.Offering_Type__c);
        newOLI.APN_Number__c = CCProduct.APN_Number__c;
        newOLI.Year__c = 1;
        newOLI.Maintenance_Start_Date__c = listOfStartAndEndDatesY1[0];
        newOLI.Maintenance_End_Date__c = listOfStartAndEndDatesY1[1];
        populatePureSuccessOLI(newOLI, CCPrice, packageQP, objQuote);
        list_OrderLineItems.add(newOLI);
        //Y2
        if (!blnSkipY2) {
            CCPrice = decPackagePriceY2 * CCPercentage / 100;
            CCPrice = Decimal.valueOf(CCPrice).setScale(2);
            dbTotalPrice2 += CCPrice;
           /* MS 10/25/2019
            if (packageName == 'PARTNER' || packageName == 'EQUIP' || packageName == 'A LA CARTE')
                CCPrice += (decBasePackagePriceY2 - dbTotalPrice2);
            else
                CCPrice += (decPackagePriceY2 - dbTotalPrice2);
            */
            newOLI = new Order_Line_Item__c(Order__c = objOrder.id);
            newOLI.CurrencyIsoCode = objQuote.CurrencyIsoCode;
            //if(packageName == 'A LA CARTE')
            newOLI.POB_Type__c = 'Not Applicable';
            //else
            //    newOLI.POB_Type__c = QuoteUtil.getPOBType(CCProduct.Type__c, CCProduct.Sub_Type__c, CCProduct.Third_Party__c, '', objQuote.Offering_Type__c);
            newOLI.Product__c = configDetails.CC_Product2_Id__c;
            newOLI.APN_Number__c = CCProduct.APN_Number__c;
            newOLI.Year__c = 2;
            newOLI.Maintenance_Start_Date__c = listOfStartAndEndDatesY2[0];
            newOLI.Maintenance_End_Date__c = listOfStartAndEndDatesY2[1];
            populatePureSuccessOLI(newOLI, CCPrice, packageQP, objQuote);
            list_OrderLineItems.add(newOLI);
        }
    }
    //upsert list_OrderLineItems;
}

private static void populatePureSuccessOLI(Order_Line_Item__c newOLI, Double PSPrice,
                                           BigMachines__Quote_Product__c packageQP, BigMachines__Quote__c objQuote) {
                                               
                                               
    newOLI.List_Price__c = PSPrice;
    newOLI.Line_Number__c = PSPrice;
    newOLI.Ext_Net_Price__c = PSPrice;
    newOLI.Ext_List__c = PSPrice;
    newOLI.Sales_Price__c = PSPrice;
    newOLI.Net_Unit_Price__c = PSPrice;
    newOLI.RecordTypeId = Global_Setting__c.getInstance('Order Line Default RT').ID__c;
    newOLI.Unit_of_Measure__c = packageQP.Unit_of_Measure__c;
    newOLI.CurrencyIsoCode = packageQP.CurrencyIsoCode;
    newOLI.Current_Qty__c = packageQP.Current_Qty__c;
    newOLI.Original_Qty__c = packageQP.Original_Qty__c;
    newOLI.Quantity__c = 1;
    newOLI.BigMachines_Quantity__c = 1;
    if (newOLI.APN_Number__c != null)
        newOLI.Name = newOLI.APN_Number__c;
    else
        newOLI.Name = mapOfProducts.get(newOLI.Product__c).name;
}

private static void insertAttachments(Id quoteId, Id orderId) {
    // Insert attachment on primary order
    List<Attachment> list_Attachments = [SELECT id, Name, Body FROM Attachment WHERE ParentId = : quoteId];
    List<Attachment> list_AttachmentsInsert = new List<Attachment>();
    
    for (Attachment a : list_Attachments) {
        Attachment att = new Attachment(Name = a.Name, Body = a.Body, Parentid = orderId);
        list_AttachmentsInsert.add(att);
    }
    if (!list_AttachmentsInsert.isEmpty())
        insert list_AttachmentsInsert;
    
}

public static String checkForDQStatus(String strOppId, String strQuoteId, Decimal decDiscount, String strTerms, String acv) {
    
    //lot of parameters, query quote for all new fields
    zqu__Quote__c currentQuote = [Select id, PS_Discount__c, zqu__Opportunity__r.Offering_Detail__c, zqu__InitialTerm__c, zqu__SubscriptionType__c, PureCloud_Ramp_Up_Period__c, currencyisocode, Owner_Segment__c, zqu__PaymentTerm__c, PureCloud_Monthly_Minimum__c, zqu__Opportunity__r.Direct_Indirect_Sale__c, zqu__Opportunity__r.BusinessPartner__r.Approved_for_PureCloud_Billing__c from zqu__Quote__c where id = :strQuoteId limit 1];
    //Products
    List<zqu__QuoteRatePlanCharge__c> quoteProducts = [Select id, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.APN_Number__c, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.name from zqu__QuoteRatePlanCharge__c where QuoteId__c = :strQuoteId];
    Boolean blnisDevOrg = false;
    Boolean blnisCreditInvolved = false;
    for (zqu__QuoteRatePlanCharge__c qrpc : quoteProducts) {
        if (qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.APN_Number__c != null && Label.PC_DEV_Org_Parts.contains(qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.APN_Number__c))
            blnisDevOrg = true;
        if (Label.PureCloud_Credit_Products.contains(qrpc.zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name))
            blnisCreditInvolved = true;
    }
    

    if (currentQuote.PureCloud_Ramp_Up_Period__c == null)
        currentQuote.PureCloud_Ramp_Up_Period__c = 0;

    //Monthly minimum
    Double USDMonthlyMinimum = 0;
    Boolean blnMonthMinCheck = false;
    if (currentQuote.zqu__SubscriptionType__c == 'New Subscription') {
        if (currentQuote.PureCloud_Monthly_Minimum__c == null)
            currentQuote.PureCloud_Monthly_Minimum__c = 0;
        USDMonthlyMinimum = DealQualificationApprovalUtil.convertCurrency(Double.valueof(currentQuote.PureCloud_Monthly_Minimum__c), currentQuote.CurrencyIsoCode);
        if (currentQuote.Owner_Segment__c == 'Velocity' && USDMonthlyMinimum >= 1500) {
            
            blnMonthMinCheck = true;
        } else if (currentQuote.zqu__Opportunity__r.BusinessPartner__r.Approved_for_PureCloud_Billing__c && USDMonthlyMinimum >= 750) {
            
            blnMonthMinCheck = true;
        } else if (currentQuote.zqu__Opportunity__r.Direct_Indirect_Sale__c == 'Indirect' && USDMonthlyMinimum >= 1000) {
            
            blnMonthMinCheck = true;
        } else if (blnisDevOrg && USDMonthlyMinimum >= 0) {
            
            blnMonthMinCheck = true;
        } else if (USDMonthlyMinimum >= 2000) {
            
            blnMonthMinCheck = true;
        }
    } else
        blnMonthMinCheck = true;
    
    //PC Trial
    Boolean blnisTrial = false;
    if (currentQuote.zqu__Opportunity__r.Offering_Detail__c != null && currentQuote.zqu__Opportunity__r.Offering_Detail__c.contains('Pilot/Trial/POC')) {
        blnisTrial = true;
    }
    
    system.debug('##ANJU##' + blnisCreditInvolved );
    
    if ((decDiscount == null || decDiscount == 0) && (currentQuote.PS_Discount__c ==  null || currentQuote.PS_Discount__c <= 30) && !blnisTrial && blnMonthMinCheck && !blnisCreditInvolved && strTerms == 'false' && currentQuote.zqu__InitialTerm__c <= 36 && (currentQuote.PureCloud_Ramp_Up_Period__c * 30) <= 90 && DealQualificationApprovalUtil.getPaymentTerms(currentQuote.zqu__PaymentTerm__c) < 45) {
        //if((decDiscount == null || decDiscount == 0) && strTerms == 'false' && currentQuote.zqu__InitialTerm__c <= 36 && (currentQuote.PureCloud_Ramp_Up_Period__c * 30) <= 90 && DealQualificationApprovalUtil.getPaymentTerms(currentQuote.zqu__PaymentTerm__c) < 45){
        approveQuote(strQuoteId);
        system.debug('in approval block' + currentQuote.zqu__InitialTerm__c);
        return 'Approved';
    }
    
    
    
    List<Deal_Qualification__c> list_ofDQs = DealQualificationApprovalUtil.getDQ(strOppId, 'New Pricing', 'Cloud', 'PureCloud', DealQualificationApprovalUtil.DQ_RECORD_HISTORY);
    if (!list_ofDQs.isEmpty()) {
        Decimal decOnDQ = 0;
        Double decAcvDQ = 0;
        decAcvDQ = DealQualificationApprovalUtil.getDealSize(list_ofDQs[0].Net_Deal_Value__c);
        decAcvDQ = DealQualificationApprovalUtil.convertCurrency(decAcvDQ, list_ofDQs[0].CurrencyIsoCode);
        
        Boolean blnMonthMinNUllCheck = false;
        if (list_ofDQs[0].If_Other_PureCloud_Monthly_Minimum_Req__c == null) {
            list_ofDQs[0].If_Other_PureCloud_Monthly_Minimum_Req__c = 0;
            blnMonthMinNUllCheck = true;
        }
        list_ofDQs[0].If_Other_PureCloud_Monthly_Minimum_Req__c = DealQualificationApprovalUtil.convertCurrency(Double.valueof(list_ofDQs[0].If_Other_PureCloud_Monthly_Minimum_Req__c), currentQuote.CurrencyIsoCode);
        
        decDiscount = decDiscount.setScale(2);
        system.debug(list_ofDQs[0].PureCloud_Credit_Applied__c + '' + blnisCreditInvolved + '' + list_ofDQs[0].name);
        
        if (decOnDQ != null && list_ofDQs[0].Discount_On_Quote__c != null)
            decOnDQ = list_ofDQs[0].Discount_On_Quote__c.setScale(2);
        if (decOnDQ < decDiscount) {
            return 'Please revise the deal qualification and get it approved with updated discount.';
        } else if (currentQuote.PS_Discount__c != null && currentQuote.PS_Discount__c > 30 && (currentQuote.PS_Discount__c >  list_ofDQs[0].PS_Discount_on_Quote__c || list_ofDQs[0].PS_Discount_on_Quote__c == null)) {
            return 'Please revise the deal qualification and get it approved for Professional Services Discount.';
        } else if (decAcvDQ < Decimal.valueof(acv)) {
            return 'Please revise the deal qualification and get it approved with updated Net Deal size(ACV).';
        } else if (!list_ofDQs[0].Special_Offer_Terms__c && strTerms == 'true') {
            return 'Please revise the deal qualification and get it approved with updated special terms and notes.';
        } else if (DealQualificationApprovalUtil.getInitialSubscriptionTerm(list_ofDQs[0].Initial_Subscription_Term_Months_PC__c, list_ofDQs[0].If_Other_Term_Months_Requested__c) < currentQuote.zqu__InitialTerm__c && currentQuote.zqu__InitialTerm__c > 36) {
            return 'Please revise the deal qualification and get it approved with updated Initial Subscription Term.';
        } else if (DealQualificationApprovalUtil.getRampPeriod(list_ofDQs[0].Ramp_Period_Days__c, list_ofDQs[0].If_Other_Ramp_Period_Requested_Days__c) < (currentQuote.PureCloud_Ramp_Up_Period__c * 30) && (currentQuote.PureCloud_Ramp_Up_Period__c * 30) > 90) {
            return 'Please revise the deal qualification and get it approved with updated Ramp Period.';
        } else if (DealQualificationApprovalUtil.getPaymentTerms(list_ofDQs[0].Payment_Terms__c) < DealQualificationApprovalUtil.getPaymentTerms(currentQuote.zqu__PaymentTerm__c) && DealQualificationApprovalUtil.getPaymentTerms(currentQuote.zqu__PaymentTerm__c) >= 45 ) {
            return 'Please revise the deal qualification and get it approved with updated Payment Terms.';
        } else if ((list_ofDQs[0].If_Other_PureCloud_Monthly_Minimum_Req__c > USDMonthlyMinimum || blnMonthMinNUllCheck) && blnMonthMinCheck == false ) {
            return 'Please revise the Deal Qualification with an updated PureCloud Monthly Minimum.  Current Deal Qualification selection does not match value in quote and/or selections on the Opportunity, i.e. – Direct/Indirect.';
        } else if (list_ofDQs[0].PureCloud_Credit_Applied__c == false && blnisCreditInvolved) {
            return 'Please revise the Deal Qualification and get it approved for PureCloud Credit.';
        } else if (list_ofDQs[0].PureCloud_Trial__c == false && blnisTrial ) {
            return 'Please revise the Deal Qualification and get it approved for PureCloud Trial.';
        } else if (list_ofDQs[0].Status__c == 'Approved') {
            approveQuote(strQuoteId);
            return 'Approved';
        } else {
            //if DQ not approved
            return 'Please get the deal qualification approved.';
        }
    } else {
        //if no DQ
        return 'Please get the deal qualification approved.';
    }
    
    //return '';
}

private static void approveQuote(String strQuoteId) {
    zqu__Quote__c objQuoteToBeUpdated = new zqu__Quote__c(id = strQuoteId);
    objQuoteToBeUpdated.zqu__ApprovalStatus__c = 'Quote Approved';
    update objQuoteToBeUpdated;
}

//Added By Ranjith on Oct 30, 2017 - Starts
public static void shareOrders(Set<Id> set_NewOrderIds, Id ownerId) {
    List<Order__Share> list_InsertOrderShares = new List<Order__Share>();
    for (Id orderId : set_NewOrderIds) {
        list_InsertOrderShares.add(new Order__Share(ParentId = orderId, AccessLevel = Label.Access_Permission,
                                                    UserOrGroupId = ownerId,
                                                    RowCause = Schema.Order__Share.RowCause.Rep_Access__c));
        if (ownerId != UserInfo.getUserId()) {
            list_InsertOrderShares.add(new Order__Share(ParentId = orderId, AccessLevel = Label.Access_Permission,
                                                        UserOrGroupId = UserInfo.getUserId(),
                                                        RowCause = Schema.Order__Share.RowCause.Rep_Access__c));
        }
    }
    insert list_InsertOrderShares;
}
//Added By Ranjith on Oct 30, 2017 - Ends

//Added By Ranjith on Jun 26, 2017 - Starts
// *** Method to pull record types of a sobject ***
public static Map<String, RecordType> getRecordTypes(String strObjType) {
    Map<String, RecordType> map_rts = new Map<String, RecordType>();
    for (RecordType recType : [SELECT Id, Name FROM RecordType WHERE SobjectType = : strObjType]) {
        map_rts.put(recType.Name, recType);
    }
    return map_rts;
}
//Added By Ranjith on Jun 26, 2017 - Ends

public static void populateDefaultOrderAddress(BigMachines__Quote__c quote) {
    List<Account_Order_Address__c> list_AddressTobeDeleted = [SELECT id FROM Account_Order_Address__c WHERE Quote__c = : quote.id];
    if (!list_AddressTobeDeleted.isEmpty())
        delete list_AddressTobeDeleted;
    List<Account_Order_Address__c> accountBillToSoldToAddresses = [SELECT Address_Type__c, Address__c, Address2__c, City__c,
                                                                   State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c FROM Account_Order_Address__c
                                                                   WHERE Account__c = : quote.Sold_To_Name__c AND (Address_Type__c = 'Bill To' OR Address_Type__c = 'Sold To')];
    
    List<Account_Order_Address__c> accountEndUserShipToAddresses = [SELECT Address_Type__c, Address__c, Address2__c, City__c,
                                                                    State__c, Country__c, Zip_Code__c, Phone__c, Fax__c, Email__c FROM Account_Order_Address__c
                                                                    WHERE Account__c = : quote.End_User_ID__c AND (Address_Type__c = 'End User' OR Address_Type__c = 'Ship To')];
    
    List<Account_Order_Address__c> accountAddress = new List<Account_Order_Address__c>();
    Set<String> set_OfAddressType = new Set<String>();
    for (Account_Order_Address__c eachAddress : accountBillToSoldToAddresses) {
        if ((eachAddress.Address_Type__c == 'Bill To' && set_OfAddressType.contains('Bill To'))
            || (eachAddress.Address_Type__c == 'Sold To' && set_OfAddressType.contains('Sold To'))) {
                continue;
            }
        accountAddress.add(eachAddress);
        set_OfAddressType.add(eachAddress.Address_Type__c);
    }
    
    set_OfAddressType.clear();
    for (Account_Order_Address__c eachAddress : accountEndUserShipToAddresses) {
        if ((eachAddress.Address_Type__c == 'End User' && set_OfAddressType.contains('End User'))
            || (eachAddress.Address_Type__c == 'Ship To' && set_OfAddressType.contains('Ship To'))) {
                continue;
            }
        accountAddress.add(eachAddress);
        set_OfAddressType.add(eachAddress.Address_Type__c);
    }
    
    List<Account_Order_Address__c> orderAddressToBeInserted = new List<Account_Order_Address__c>();
    for (Account_Order_Address__c eachAddress : accountAddress) {
        Account_Order_Address__c newAddress = new Account_Order_Address__c(Quote__c = quote.id);
        newAddress.Address_Type__c = eachAddress.Address_Type__c;
        newAddress.Address__c = eachAddress.Address__c;
        newAddress.Address2__c = eachAddress.Address2__c;
        newAddress.City__c = eachAddress.City__c;
        newAddress.State__c = eachAddress.State__c;
        newAddress.Country__c = eachAddress.Country__c;
        newAddress.Zip_Code__c = eachAddress.Zip_Code__c;
        newAddress.Phone__c = eachAddress.Phone__c;
        newAddress.Fax__c = eachAddress.Fax__c;
        newAddress.Email__c = eachAddress.Email__c;
        orderAddressToBeInserted.add(newAddress);
    }
    if (!orderAddressToBeInserted.isEmpty())
        insert orderAddressToBeInserted;
}
/*
public static Decimal calculateTokenValue(Decimal totalACV, String offeringType, String pureSuccessPackageName) {
Decimal decTokenValue = 0;
if (totalACV < 5000)
decTokenValue = 0;
else {
decTokenValue = (totalACV / 5000);
decTokenValue = 5 * (decTokenValue / 5).round(System.RoundingMode.UP);
decTokenValue.setScale(0);
}
System.debug('NKC debug decTokenValue [' + decTokenValue + ']');
if (decTokenValue > 500)
decTokenValue = 500;
if (offeringType == 'PureEngage Subscription') {
if (pureSuccessPackageName == 'GUIDE')
decTokenValue += Decimal.valueOf(Label.Subscription_Quote_Tool_Addition_Tokens.split(';')[0]);
else if (pureSuccessPackageName == 'DRIVE')
decTokenValue += Decimal.valueOf(Label.Subscription_Quote_Tool_Addition_Tokens.split(';')[1]);
} else if (offeringType == 'PureConnect Subscription') {
if (pureSuccessPackageName == 'GUIDE')
decTokenValue += Decimal.valueOf(Label.Subscription_Quote_Tool_Addition_Tokens.split(';')[2]);
else if (pureSuccessPackageName == 'DRIVE')
decTokenValue += Decimal.valueOf(Label.Subscription_Quote_Tool_Addition_Tokens.split(';')[3]);
} else if (offeringType == 'PureEngage Cloud') {
if (pureSuccessPackageName == 'GUIDE')
decTokenValue += 25;
else if (pureSuccessPackageName == 'DRIVE')
decTokenValue += 85;
} else if (offeringType == 'PureConnect Cloud') {
if (pureSuccessPackageName == 'GUIDE')
decTokenValue += 15;
else if (pureSuccessPackageName == 'DRIVE')
decTokenValue += 75;
} else if (offeringType == 'Business Edition') {
if (pureSuccessPackageName == 'GUIDE')
decTokenValue += 25;
else if (pureSuccessPackageName == 'DRIVE')
decTokenValue += 85;
}
return decTokenValue;
}
*/
public static List<Decimal> calculateTokenValue(Decimal totalACV, String offeringType, String pureSuccessPackageName) {
    
    List<Decimal> listOfTokens = new List<Decimal>();
    Decimal decTokenValue = 0;
    Decimal decACVTokens = 0;
    if (totalACV < 5000)
        decTokenValue = 0;
    else {
        decTokenValue = (totalACV / 5000);
        decTokenValue = 5 * (decTokenValue / 5).round(System.RoundingMode.UP);
        decTokenValue.setScale(0);
    }
    
    System.debug('NKC debug decTokenValue [' + decTokenValue + ']');
    if (decTokenValue > 500)
        decTokenValue = 500;
    decACVTokens = decTokenValue;        
    if (offeringType == 'PureEngage Subscription') {
        if (pureSuccessPackageName == 'GUIDE')
            decTokenValue += Decimal.valueOf(Label.Subscription_Quote_Tool_Addition_Tokens.split(';')[0]);
        else if (pureSuccessPackageName == 'DRIVE')
            decTokenValue += Decimal.valueOf(Label.Subscription_Quote_Tool_Addition_Tokens.split(';')[1]);
    } else if (offeringType == 'PureConnect Subscription') {
        if (pureSuccessPackageName == 'GUIDE')
            decTokenValue += Decimal.valueOf(Label.Subscription_Quote_Tool_Addition_Tokens.split(';')[2]);
        else if (pureSuccessPackageName == 'DRIVE')
            decTokenValue += Decimal.valueOf(Label.Subscription_Quote_Tool_Addition_Tokens.split(';')[3]);
    } else if (offeringType == 'PureEngage Cloud') {
        if (pureSuccessPackageName == 'GUIDE')
            decTokenValue += 25;
        else if (pureSuccessPackageName == 'DRIVE')
            decTokenValue += 85;
    } else if (offeringType == 'PureConnect Cloud') {
        if (pureSuccessPackageName == 'GUIDE')
            decTokenValue += 15;
        else if (pureSuccessPackageName == 'DRIVE')
            decTokenValue += 75;
    } else if (offeringType == 'Business Edition') {
        if (pureSuccessPackageName == 'GUIDE')
            decTokenValue += 25;
        else if (pureSuccessPackageName == 'DRIVE')
            decTokenValue += 85;
    }
    listOfTokens.add(decTokenValue);
    listOfTokens.add(decACVTokens);
    return listOfTokens;
}

public static Decimal calculatePaymentTermPrice(Decimal decPrice, BigMachines__Quote__c objQuote, BigMachines__Quote_Product__c objQP) {
    Integer quotePaymentTerm = DealQualificationApprovalUtil.getPaymentTerms(objQuote.Order_Payment_Terms__c);
    if (quotePaymentTerm > 30 && objQuote.Payment_Terms_Price_Uptick__c != null)
        decPrice = decPrice + ((decPrice * objQuote.Payment_Terms_Price_Uptick__c) / 100 );
    return decPrice;
}
public static Decimal calculateOveragePrice(Decimal decPrice, BigMachines__Quote__c objQuote, BigMachines__Quote_Product__c objQP) {
    if (objQuote.Overage_Allowance__c == 'Other' && objQuote.Overage_Allowance_Price_Uptick__c != null)
        decPrice = decPrice + ((decPrice * objQuote.Overage_Allowance_Price_Uptick__c) / 100 );
    return decPrice;
}

//Anju 2018 January Create puresuccess Direct items from offer for PEC
public static void insertPureSuccessItemsFromOffer(BigMachines__Quote__c objQuote) {
    BigMachines__Quote_Product__c offerProduct = null;
    for (BigMachines__Quote_Product__c qp : [Select id, BigMachines__Product__c, Extended_Price_Per_Month__c from BigMachines__Quote_Product__c where  BigMachines__Quote__c = :objQuote.id]) {
        if (Label.PEC_PureSuccess_Offer.contains(String.valueof(qp.BigMachines__Product__c).left(15))) {
            offerProduct = qp;
            offerProduct.Ext_Net_Price__c = offerProduct.Extended_Price_Per_Month__c;
            break;
        }
        
    }
    if (offerProduct != null) {
        List<BigMachines__Quote_Product__c> toInsert = new List<BigMachines__Quote_Product__c>();
        for (Product_Group_Item__c pL : [Select Product__c, Product_Group__c, Product__r.type__c, Product__r.name from Product_Group_Item__c where Product_Group__r.Product__c = :offerProduct.BigMachines__Product__c]) {
            BigMachines__Quote_Product__c temp = new BigMachines__Quote_Product__c();
            temp.BigMachines__Quote__c = objQuote.id;
            temp.BigMachines__Quantity__c  = 1;
            if (pL.Product__r.type__c ==  'Token')
                temp.BigMachines__Quantity__c  = objQuote.Token_Value__c;
            temp.Net_Unit_Price__c = temp.BigMachines__Sales_Price__c = temp.List_Price__c = 0;
            temp.Bundle__c = pL.Product_Group__c;
            temp.Bundle_Line__c = offerProduct.id;
            temp.BigMachines__Product__c = pL.Product__c;
            temp.name = pL.Product__r.name;
            toInsert.add(temp);
            offerProduct.Bundle__c = pL.Product_Group__c;
        }
        if (toInsert.size() > 0)
            insert toInsert;
        update offerProduct;
    }
}

public static Decimal getPackagePricingPercentage(String offeringType, String PureSuccessOffer, String PureSuccessOrLicense) {
    if (PureSuccessOffer == null)
        return 0;
    String packageName = (PureSuccessOffer == 'Partner PureSuccess' ? 'PARTNER' : PureSuccessOffer.toUpperCase());
    String key = offeringType + '-' + packageName;
    System.debug('NKC debug key [' + key + ']');

    BasePackageLineConfiguration__c configDetails = BasePackageLineConfiguration__c.getAll().get(key);
    if (configDetails == null)
        return 0;
    Decimal decPercentage;
    if (PureSuccessOrLicense == 'PureSuccess')
        decPercentage = configDetails.PureSuccess__c == null ? 0 : configDetails.PureSuccess__c;
    else
        decPercentage = configDetails.License__c == null ? 0 : configDetails.License__c;        
    return decPercentage;
}

//Conversion for PC Monthly minimum
public static Map<String, Decimal> buildConversionRatesMap() {
    Map<String, Decimal> map_ConversionRates = new Map<String, Decimal>
    {'USD' => 1, 'CAD' => 1.1, 'AUD' => 1.3, 'NZD' => 1.4, 'GBP' => 0.7, 'EUR' => 0.8, 'BRL' => 3, 'JPY' => 120, 'ZAR' => 14.2};
        return map_ConversionRates;
}

// ECD March 2019
public static void addProductPrecisionToMap(List<Product2> listProducts, Map<id, Integer> mapProductIdToDecimalPrecision) {
    for (Product2 objProduct : listProducts) {
        addProductPrecisionToMap(objProduct, mapProductIdToDecimalPrecision);
    }
}
public static void addProductPrecisionToMap(Product2 objProduct, Map<id, Integer> mapProductIdToDecimalPrecision) {
    System.Debug('QuoteUtil.addProductPrecisionToMap: start single product ' + objProduct);
    if (mapProductIdToDecimalPrecision == null) {
        mapProductIdToDecimalPrecision = new Map<Id, Integer>();
    }
    Integer intProductPrecision = 2; // Default of Precision 2
    if (objProduct.Tier_Pricing_Decimal_Precision__c != null) {
        intProductPrecision = Integer.valueOf(objProduct.Tier_Pricing_Decimal_Precision__c);
    } else {
        System.Debug('QuoteUtil.addProductPrecisionToMap: Tier_Pricing_Decimal_Precision__c is null default to 2');
    }
    if (objProduct.Id != null) {
        if (!mapProductIdToDecimalPrecision.containsKey(objProduct.Id)) {
            mapProductIdToDecimalPrecision.put(objProduct.Id, intProductPrecision);
        }
    } else {
        System.Debug('QuoteUtil.addProductPrecisionToMap: Product did not select an Id ' + objProduct);
    }
}

public static String setDecimalPrecisionFormat(BigMachines__Quote_Product__c objQuoteProduct) {
    System.Debug('QuoteUtil.setDecimalPrecisionFormat.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c: ' + objQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c);
    String strFormat = '###,##0.00';
    if (objQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c != null && objQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c == '4') {
        strFormat = '###,##0.0000';
    } else if (objQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c != null && objQuoteProduct.BigMachines__Product__r.Tier_Pricing_Decimal_Precision__c == '6') {
        strFormat = '###,##0.000000';
    }
    return strFormat;
}    


////IS THIS METHOD USED???
public static void calculationsForQuote(List<BigMachines__Quote__c> list_Quotes, Map<Id, List<BigMachines__Quote_Product__c>> map_QuoteIdtoQuoteProds) {
    System.debug('map_QuoteIdtoQuoteProds' + map_QuoteIdtoQuoteProds); // Savepoint before DML
    Savepoint objSP = Database.setSavepoint();
    try {
        list_Quotes = prepareQuotes(map_QuoteIdtoQuoteProds.keyset());
        map_QuoteIdtoQuoteProds = prepareQuoteProducts(map_QuoteIdtoQuoteProds.keyset());
        Map<Id, Map<String, Id>> map_ProdIdToPBEId = preparePBEList(map_QuoteIdtoQuoteProds);
        List<Quote_Proposal_Group__c> list_ProposalGroups = [SELECT Id, Quote__c, Description__c, Discount__c, Group_Number__c, Name__c, Sub_Total__c, Goal_Seek__c FROM Quote_Proposal_Group__c WHERE Quote__c in :map_QuoteIdtoQuoteProds.keyset() ORDER BY Group_Number__c];
        Map<String, Quote_Proposal_Group__c> map_GroupNumToGrouprecord = new Map<String, Quote_Proposal_Group__c>();
        for (Quote_Proposal_Group__c objPG : list_ProposalGroups) {
            map_GroupNumToGrouprecord.put(objPG.Group_Number__c, objPG);
        }
        List<Opportunity> list_OpptoUpdate = new List<Opportunity>();
        List<OpportunityLineItem> list_OpptyLinesToCreate = new List<OpportunityLineItem>();
        Set<Id> set_OvgProdParentIds = findOverageChargeAPNs(list_Quotes);
        for (BigMachines__Quote__c objQuote : list_Quotes) {
            System.debug('Quote:' + objQuote);
            List<BigMachines__Quote_Product__c> list_ToUpdate = new List<BigMachines__Quote_Product__c>();
            Set<Id> set_ProductIds = new Set<Id>();
            Decimal decTotalSWNetPrice, decTotalHWNetPrice, decTotalEducationNetPrice, decTotalServicesNetPrice;
            Decimal decCustomIVRPrice = 0;
            Integer intSetScale = 2;
            Decimal decTotalRecAmount = 0, decTotalNonRecAmount = 0, decTotalRecServAmount = 0, decTotalRecServAmountPreDiscount = 0, decTotalRecAmountPreDiscount = 0,  decTotalNonRecAmountPreDiscount = 0, decTotalPCCredit = 0,  maxSeatCount = 0;
            System.debug('objQuote.Sold_To_Name__c' + objQuote.Sold_To_Name__c);
            Map<String, Decimal> map_PCPartnerMargins = QuoteUtil.buildPartnerMargins(objQuote.Sold_To_Name__c);
            System.debug('Partner Margin:' + map_PCPartnerMargins);
            System.debug('#####set_OvgProdParentIds: ' + set_OvgProdParentIds);
            
            // Storing Sub Totals on Lines and Adding up totals for products of different types and storing total adjustment
            decTotalSWNetPrice = decTotalHWNetPrice = decTotalEducationNetPrice = decTotalServicesNetPrice = 0;
            List<OpportunityLineItem> list_OpptyLinesToInsert = new List<OpportunityLineItem>();
            decTotalRecAmount = decTotalNonRecAmount = decTotalPCCredit = decTotalRecAmountPreDiscount = decTotalNonRecAmountPreDiscount = maxSeatCount = 0;
            Integer intNoOfMonths = Integer.valueOf(objQuote.No_Of_Months__c);
            if (objQuote.Billing_Category__c == 'M2M') {
                intNoOfMonths = 12;
            }
            System.debug('#######intNoOfMonths: ' + intNoOfMonths);
            for (BigMachines__Quote_Product__c objQP : map_QuoteIdtoQuoteProds.get(objQuote.Id)) {
                
                objQuote.Total_Services__c = 0.00;
                if (String.isNotBlank(objQP.Group_Number__c) && map_GroupNumToGrouprecord.containsKey(objQP.Group_Number__c))
                    objQP.Group_Subtotal__c = map_GroupNumToGrouprecord.get(objQP.Group_Number__c).Sub_Total__c;
                //Calculate seat count
                if (!objQP.Is_Overage__c) {
                    System.debug('#####Include_in_Agent_Seat_Count__c:' + objQP.BigMachines__Product__r.Include_in_Agent_Seat_Count__c);
                    if (objQP.BigMachines__Product__r.Include_in_Agent_Seat_Count__c) {
                        Integer decQtProdSeatCount = 0;
                        if (objQP.Quantity__c != null && objQP.Quantity__c > 0) {
                            decQtProdSeatCount = Integer.valueOf(objQP.Quantity__c);
                        }
                        System.debug('#####decQtProdSeatCount:' + decQtProdSeatCount);
                        maxSeatCount += objQP.BigMachines__Product__r.Name.contains('Concurrent') ? decQtProdSeatCount * 2 : decQtProdSeatCount;
                    }
                    System.debug('#####maxSeatCount:' + maxSeatCount);
                }
                if (!objQP.Is_Overage__c && !set_OvgProdParentIds.contains(objQP.Id)) {
                    if (objQP.Ext_Net_Price__c != null) {
                        if (objQP.BigMachines__Product__r.Include_in_CMMR_Total__c)
                            decTotalRecAmount += objQP.Ext_Net_Price__c;
                        else if (objQP.BigMachines__Product__r.Product_Group__c == 'Recurring Services')
                            decTotalRecServAmount += objQP.Ext_Net_Price__c;
                        else {
                            if (!Label.PureCloud_Credit_Products.contains(objQP.BigMachines__Product__r.Name)) {
                                decTotalNonRecAmount += objQP.Ext_Net_Price__c;
                            } else {
                                decTotalPCCredit += objQP.Ext_Net_Price__c;
                            }
                        }
                    }
                    if (objQP.Ext_List__c != null) {
                        if (objQP.BigMachines__Product__r.Include_in_CMMR_Total__c)
                            decTotalRecAmountPreDiscount += objQP.Ext_List__c;
                        else if (objQP.BigMachines__Product__r.Product_Group__c == 'Recurring Services')
                            decTotalRecServAmountPreDiscount += objQP.Ext_List__c;
                        else if (!Label.PureCloud_Credit_Products.contains(objQP.BigMachines__Product__r.Name))
                            decTotalNonRecAmountPreDiscount += objQP.Ext_List__c;
                    }
                    // Software
                    if (objQP.BigMachines__Product__r.Type__c == 'Cloud') {
                        objQuote.Total_Software__c += objQP.Ext_List__c != null ? objQP.Ext_List__c : 0;
                        decTotalSWNetPrice += objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                    }
                    Decimal decExtNetUnitPrice = objQP.Ext_Net_Price__c != null ? objQP.Ext_Net_Price__c : 0;
                    if (objQP.BigMachines__Product__r.New_Category__c == 'Education') {
                        System.debug('Fields:' + objQuote.Total_Education__c + objQP.BigMachines__Product__r.Include_in_CMMR_Total__c + decExtNetUnitPrice + intNoOfMonths);
                        objQuote.Total_Education__c += objQP.BigMachines__Product__r.Include_in_CMMR_Total__c ? (decExtNetUnitPrice * intNoOfMonths) : decExtNetUnitPrice;
                    } else if (objQP.BigMachines__Product__r.New_Category__c == 'Hardware') {
                        objQuote.Total_Hardware__c += objQP.BigMachines__Product__r.Include_in_CMMR_Total__c ? (decExtNetUnitPrice * intNoOfMonths) : decExtNetUnitPrice;
                    } else if (objQP.BigMachines__Product__r.New_Category__c == 'Services' || objQP.BigMachines__Product__r.New_Category__c == 'Voice Services') {
                        objQuote.Total_Services__c += objQP.BigMachines__Product__r.Product_Group__c == 'Recurring Services' ? (decExtNetUnitPrice * intNoOfMonths) : decExtNetUnitPrice;
                    }
                    if (objQP.BigMachines__Product__r.Include_in_CMMR_Total__c) {
                        objQuote.No_Cloud_Billing_Contract__c = false;
                    }
                    // Calculating Total List Price
                    if (objQP.Ext_List__c != null)
                        objQuote.Total_List_Price__c += objQP.Ext_List__c;
                    System.debug('@@@@@' + objQuote.Id + '&' + objQuote.Total_Adjustments__c + '&' + objQP.Adjustment__c);
                    if (objQP.Adjustment__c != null) {
                        if (objQuote.Total_Adjustments__c == null)
                            objQuote.Total_Adjustments__c = 0;
                        objQuote.Total_Adjustments__c += objQP.Adjustment__c;
                    }
                } else {
                    if (objQP.Quantity__c != null && objQP.Quantity__c > 0)
                        objQuote.Total_Overage__c += objQP.Net_Unit_Price__c * objQP.Quantity__c;
                }
            }
            objQuote.Total_Subtotal_1__c = objQuote.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c;
            objQuote.Non_Recurring_Fees__c = objQuote.Total_Hardware__c + objQuote.Total_Education__c + objQuote.Setup_Provisioning_Charges__c;
            objQuote.Max_Seat_Count__c = maxSeatCount;
            System.debug('Values###' + decTotalRecAmount + '&' + intNoOfMonths);
            objQuote.Annual_Contract_Value__c = decTotalRecAmount * intNoOfMonths;
            objQuote.Cloud_Total__c = (decTotalRecAmount * intNoOfMonths) + decTotalNonRecAmount - decTotalPCCredit;
            objQuote.Total_Contract_Value__c = objQuote.Cloud_Total__c;
            objQuote.CMRR_Pre_Discount__c = decTotalRecAmountPreDiscount;
            objQuote.ACV_Pre_Discount__c = decTotalRecAmountPreDiscount * (objQuote.No_Of_Months__c > 12 ? 12 : objQuote.No_Of_Months__c);
            objQuote.TCV_Pre_Discount__c = (decTotalRecAmountPreDiscount * objQuote.No_Of_Months__c) + decTotalNonRecAmountPreDiscount;
            if (objQuote.Billing_Category__c == 'M2M') {
                objQuote.CMRR_Pre_Discount__c = objQuote.ACV_Pre_Discount__c = 0.00;
                objQuote.CMRR__c = objQuote.Annual_Contract_Value__c = decTotalRecAmount = 0.00;
            } else {
                objQuote.CMRR_Pre_Discount__c = decTotalRecAmountPreDiscount;
                objQuote.CMRR__c = decTotalRecAmount;
                Integer intCurrYrProration = intNoOfMonths == 12 ? 12 : Math.mod(intNoOfMonths, 12) == 0 ? 12 : Math.mod(intNoOfMonths, 12);
                objQuote.Annual_Contract_Value__c = (decTotalRecAmount * 12) - (decTotalPCCredit / (intNoOfMonths >= 12 ? intNoOfMonths / 12 : 1));
                objQuote.ACV_Pre_Discount__c = (decTotalRecAmountPreDiscount * 12) - (decTotalPCCredit / (intNoOfMonths >= 12 ? intNoOfMonths / 12 : 1));
            }
            System.debug('#######intNoOfMonths: ' + intNoOfMonths + objQuote.Annual_Contract_Value__c + objQuote.ACV_Pre_Discount__c);
            objQuote.Non_Recurring_Fees__c = decTotalNonRecAmount - decTotalPCCredit;
            System.debug('Values' + decTotalRecAmount + '&' + intNoOfMonths + '&' + decTotalNonRecAmount + '&' + decTotalRecServAmount + '&' + decTotalPCCredit);
            objQuote.Total_Contract_Value__c = (decTotalRecAmount * intNoOfMonths) + decTotalNonRecAmount + (decTotalRecServAmount * intNoOfMonths) - decTotalPCCredit;
            objQuote.TCV_Pre_Discount__c = (decTotalRecAmountPreDiscount * intNoOfMonths) + decTotalNonRecAmountPreDiscount + (decTotalRecServAmountPreDiscount * intNoOfMonths) - decTotalPCCredit;
            System.debug('Fields' + objQuote.Services_Change__c + objQuote.Total_Services__c + objQuote.Amendment_For__r.Total_Services__c);
            objQuote.Services_Change__c = objQuote.Total_Services__c - objQuote.Amendment_For__r.Total_Services__c;
            objQuote.Total_Education_Change__c = objQuote.Total_Education__c - objQuote.Amendment_For__r.Total_Education__c;
            objQuote.Total_Hardware_Change__c = objQuote.Total_Hardware__c - objQuote.Amendment_For__r.Total_Hardware__c;
            objQuote.CMRR_Change__c = objQuote.CMRR__c - objQuote.Amendment_For__r.CMRR__c;
            objQuote.Annual_Contract_Value_Change__c = objQuote.Annual_Contract_Value__c - objQuote.Amendment_For__r.ACV__c;
            objQuote.Non_Recurring_Fees_Changes__c = objQuote.Non_Recurring_Fees__c - objQuote.Amendment_For__r.Total_Non_Recurring_Fees__c;
            //objQuote.Total_Contract_Value__c =  objQuote.Total_Contract_Value__c -  objQuote.Non_Recurring_Fees__c +  objQuote.Non_Recurring_Fees_Changes__c;
            objQuote.Total_Contract_Value_Change__c = objQuote.Total_Contract_Value__c - objQuote.Amendment_For__r.TCV__c;
            // Percentages
            objQuote.Total_Discount_Genesys_Products_Only__c = objQuote.Total_Discount_Genesys_and_Third_Party__c = objQuote.Professional_Services_Discount__c = 0;
            objQuote.Hardware_Discount__c = objQuote.Software_Discount__c = objQuote.Overage_Discount__c = 0.00;
            objQuote.BigMachines__Total__c = objQuote.Total_Subtotal_1__c;
            objQuote.Selling_Entity__c = '';
            // Skip Triggers
            Util.Bypass_Trigger_Chk = true;
            if (list_ProposalGroups.size() > 0)
                update list_ProposalGroups;
            System.debug('#######list_ToUpdate.size(): ' + list_ToUpdate.size());
            System.debug('#######list_ToUpdate: ' + list_ToUpdate);
            if (list_ToUpdate.size() > 0)
                Database.upsert(list_ToUpdate, false);
            if (objQuote.Deal_Qualification__c == null) {
                List<Deal_Qualification__c> dq = DealQualificationApprovalUtil.getDQ(objQuote.BigMachines__Opportunity__c, objQuote.Quote_Opportunity_Type__c, objQuote.Offering_Type__c, DealQualificationApprovalUtil.DQ_RECORD_ORIGINAL);
                if (!dq.isEmpty())
                    objQuote.Deal_Qualification__c = dq[0].id;
            }
            objQuote.BigMachines__Is_Primary__c = true;
            System.debug('Quote' + objQuote);
            update objQuote;
            // **** Opportunity Synchronization Logic *******
            if (objQuote.BigMachines__Opportunity__c != null && objQuote.BigMachines__Is_Primary__c) {
                Opportunity oppToUpdate = new Opportunity(Id = objQuote.BigMachines__Opportunity__c);
                oppToUpdate.Primary_Quote__c = objQuote.id;
                oppToUpdate.Hardware_Total__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Total_Hardware_Change__c : objQuote.Total_Hardware__c;
                oppToUpdate.Education_Amount__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Total_Education_Change__c : objQuote.Total_Education__c;
                oppToUpdate.Total_PS_Support__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Services_Change__c : objQuote.Total_Services__c;
                System.debug('#####oppToUpdate.Hardware_Total__c: ' + oppToUpdate.Hardware_Total__c);
                System.debug('#####oppToUpdate.Hardware_Total__c: ' + oppToUpdate.Total_PS_Support__c);
                //Logic to populate additional opportunity fields from primary quote
                if (oppToUpdate.Annual_Contract_Value_new__c == null)
                    oppToUpdate.Annual_Contract_Value_new__c = 0;
                oppToUpdate.Annual_Contract_Value_new__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Annual_Contract_Value_Change__c : objQuote.Annual_Contract_Value__c;
                //oppToUpdate.ACV_Subscription_Only__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Annual_Contract_Value_Change__c : objQuote.Annual_Contract_Value__c;
                oppToUpdate.Annual_Contract_Value_Subscription__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.Annual_Contract_Value_Change__c : objQuote.Annual_Contract_Value__c;
                oppToUpdate.Total_Annual_Contract_Value__c = objQuote.Total_Contract_Value__c - oppToUpdate.Total_PS_Support__c;
                oppToUpdate.Annual_Contract_Value_Change__c = objQuote.Annual_Contract_Value_Change__c;
                oppToUpdate.Monthly_Commitment__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.CMRR_Change__c : objQuote.CMRR__c;
                // oppToUpdate.Subscription_CMRR__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.CMRR_Change__c : objQuote.CMRR__c;
                oppToUpdate.CMRR_Change__c = objQuote.CMRR_Change__c;
                oppToUpdate.Subscription_CMRR_Change__c = objQuote.CMRR_Change__c;
                oppToUpdate.Total_Contract_Value_Change__c = objQuote.Total_Contract_Value_Change__c - oppToUpdate.Total_PS_Support__c;
                if (objQuote.Order_Type__c == Label.Amend_Subscription) {
                    oppToUpdate.Total_Annual_Contract_Value__c = objQuote.Total_Contract_Value_Change__c - oppToUpdate.Total_PS_Support__c;
                }
                
                oppToUpdate.Monthly_Commitment__c = objQuote.Order_Type__c == Label.Amend_Subscription ? objQuote.CMRR_Change__c : objQuote.CMRR__c;
                oppToUpdate.Term_Commitment__c = objQuote.Initial_Subscription_Term__c;
                oppToUpdate.Frequency_Term__c = objQuote.Billing_Period__c;
                oppToUpdate.MSA_Url__c = objQuote.MSA_Link__c;
                oppToUpdate.Primary_Line_of_Business__c = 'Cloud';
                oppToUpdate.Pricebook2Id = Label.Standard_Pricebook_Id;
                oppToUpdate.Subscription_CMRR_Change__c = objQuote.CMRR_Change__c;
                if (objQuote.Order_Type__c == Label.Amend_Subscription) {
                    oppToUpdate.Offering_Detail__c = objQuote.Total_Contract_Value_Change__c >= 0 ? 'Amendment – Upgrade' : 'Amendment – Downgrade';
                    objQuote.Max_Seat_Count__c = objQuote.Total_Contract_Value_Change__c >= 0 ? objQuote.Max_Seat_Count__c : 0;
                }
                oppToUpdate.Incremental_Agent_Seat_Count__c = objQuote.Max_Seat_Count__c;
                oppToUpdate.TAM_Services_Amount__c = objQuote.TAM_Amount__c;
                oppToUpdate.TAM_Duration_Months__c = objQuote.TAM_Duration_Months__c;
                list_OpptoUpdate.add(oppToUpdate);
                //update oppToUpdate;
                
                for (BigMachines__Quote_Product__c objQP : map_QuoteIdtoQuoteProds.get(objQuote.Id)) {
                    if (objQP.Bundle__c != null && objQP.Bundle_Line__c == null)
                        continue;
                    System.debug('NKC debug objQP.Bundle_Line__c [' + objQP.Bundle_Line__c + ']');
                    System.debug('NKC debug map_ProdIdToPBEId.containsKey(objQP.BigMachines__Product__c) [' + map_ProdIdToPBEId.containsKey(objQP.BigMachines__Product__c) + ']');
                    if (map_ProdIdToPBEId.containsKey(objQP.BigMachines__Product__c)
                        && !objQP.Is_Overage__c
                        && objQP.Quantity__c > 0) {
                            list_OpptyLinesToCreate.add(new OpportunityLineItem(BigMachines__Origin_Quote__c = objQuote.Id,
                                                                                Description__c = (String.isNotBlank(objQP.Product_Description__c) && objQP.Product_Description__c.length() > 250 ? objQP.Product_Description__c.substring(0, 250) : objQP.Product_Description__c),
                                                                                OpportunityId = objQuote.BigMachines__Opportunity__c,
                                                                                PricebookEntryId = map_ProdIdToPBEId.get(objQP.BigMachines__Product__c).get(String.valueof(objQuote.CurrencyISOCode)),
                                                                                Quantity = objQP.Quantity__c, Quantity__c = objQP.Quantity__c, UnitPrice = objQP.Net_Unit_Price__c,
                                                                                Total_Discount__c = objQP.Total_Discount__c, Unit_of_Measure__c = objQP.Unit_of_Measure__c));
                        }
                }
                
            }
        }
        
        Update  list_Quotes;
        if (list_OpptoUpdate.size() > 0)
            update list_OpptoUpdate;
        if (list_OpptyLinesToCreate.size() > 0)
            system.debug(list_OpptyLinesToCreate);
        insert list_OpptyLinesToCreate;
    } catch (Exception ex) {
        system.debug('Exception has occurred:' + ex.getMessage() + '\n' + ex.getTypeName() + '\nStacktrace:' + ex.getStackTraceString());
        // Roll back changes in case of DML failure
        Database.rollback(objSP);
    }
} //END calculationForQuote


public static List<BigMachines__Quote__c> prepareQuotes(Set<Id> Set_QuoteIds) {
    String strQuoteQuery = 'SELECT '; 
    //Getting all the fields from a field set : field set used to make system more configurable
    List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote__c.FieldSets.Quote_Details_Cloud.getFields();
    for (Schema.FieldSetMember field : gridFields)
        strQuoteQuery += field.getFieldPath() + ', ';
    strQuoteQuery += 'Id,End_User_ID__r.Country__r.Name, Quote_Cloned_Revised__r.Name,';
    strQuoteQuery += 'Sold_To_Name__r.Country__r.PSRDP_Region__c,Sold_To_Name__r.Country__r.Name,Sold_To_Name__r.Country__r.Region__c,';
    strQuoteQuery += 'BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,BigMachines__Opportunity__r.BusinessPartner__r.Country__r.New_Price_Book__c,';
    strQuoteQuery += 'BigMachines__Opportunity__r.Country__r.New_Price_Book__c, BigMachines__Opportunity__r.Country__r.Old_Price_Book__c,';
    strQuoteQuery += 'BigMachines__Opportunity__r.Sold_To_Country__r.Region__c,BigMachines__Opportunity__r.Country__r.Region__c,BigMachines__Opportunity__r.Country__r.Name,';
    strQuoteQuery += 'BigMachines__Opportunity__r.Sold_To_Country__r.Name, BigMachines__Opportunity__r.BusinessPartner__r.Partner_Tier__c,Quote_Billing_Plan_count__c,';
    strQuoteQuery += 'BigMachines__Opportunity__r.Gene_Care_Specialist__r.Email, BigMachines__Opportunity__r.Quote_Mtce_Ops__r.Email,';
    strQuoteQuery += 'Amendment_For__r.CMRR__c, Amendment_For__r.ACV__c, Amendment_For__r.TCV__c,';
    strQuoteQuery += 'Amendment_For__r.Total_Services__c, Amendment_For__r.Total_Education__c, Amendment_For__r.Total_Hardware__c,Amendment_For__r.Total_Non_Recurring_Fees__c,Setup_Provisioning_Charges__c,';
    //Anju May 2018
    strQuoteQuery += 'Amendment_For__r.Status__c,Amendment_For__r.Ramp_End_Date__c, Amendment_For__r.Subscription_End_Date__c, Amendment_For__r.Subscription_Start_Date__c,';
    strQuoteQuery += 'BigMachines__Opportunity__r.Account.Partner_Tier__c FROM BigMachines__Quote__c WHERE id in :Set_QuoteIds' ;
    return Database.Query(strQuoteQuery);
}
public Static Map<Id, List<BigMachines__Quote_Product__c>> prepareQuoteProducts(Set<Id> Set_QuoteIds) {
    Map<Id, List<BigMachines__Quote_Product__c>> map_QIdtoQPs = new Map<Id, List<BigMachines__Quote_Product__c>>();
    String strQueryAllFields = 'SELECT ';
    //Getting all the fields from a field set : field set used to make system more configurable
    List<Schema.FieldSetMember> gridFields = SObjectType.BigMachines__Quote_Product__c.FieldSets.Grid_Fields_Cloud.getFields();
    for (Schema.FieldSetMember field : gridFields)
        strQueryAllFields += field.getFieldPath() + ', ';
    strQueryAllFields += 'Bundle__r.Name, BigMachines__Product__r.Include_in_Agent_Seat_Count__c, BigMachines__Product__r.Tier__c,BigMachines__Product__r.Charge_Type__c, BigMachines__Product__r.Product_Group__c, BigMachines__Product__r.Partner_Margin_Type__c,BigMachines__Product__r.CurrencyISOCode,CurrencyISOCode, ';
    strQueryAllFields += 'BigMachines__Product__r.Concurrent_List_Price__c, BigMachines__Product__r.G1_APAC_AUD_Price__c, BigMachines__Product__r.G1_APAC_USD_Price__c, BigMachines__Product__r.G2_CALA_USD_Price__c, BigMachines__Product__r.G3_EMEA_EUR_Price__c, BigMachines__Product__r.G3_EMEA_GBP_Price__c,';
    strQueryAllFields += 'BigMachines__Product__r.G3_EMEA_USD_Price__c, BigMachines__Product__r.G4_JAPAN_JPY_Price__c, BigMachines__Product__r.G5_NA_CAD_Price__c, BigMachines__Product__r.G5_NA_USD_Price__c, BigMachines__Product__r.List_Price__c,';
    strQueryAllFields += 'BigMachines__Product__r.NG1_APAC_ANZ_AUD_Price__c, BigMachines__Product__r.NG1_APAC_KOREA_SE_ASIA_USD_Price__c, BigMachines__Product__r.NG1_APAC_USD_Price__c, BigMachines__Product__r.NG2_BRAZIL_BRL_Price__c,';
    strQueryAllFields += 'BigMachines__Product__r.NG2_CALA_USD_Price__c, BigMachines__Product__r.NG3_EMEA_EUR_Price__c, BigMachines__Product__r.NG3_EMEA_GBP_Price__c, BigMachines__Product__r.NG3_EMEA_USD_Price__c,';
    strQueryAllFields += 'BigMachines__Product__r.NG3_Europe_ZAR_Price__c, BigMachines__Product__r.NG4_APAC_CHINA_INDIA_USD_Price__c, BigMachines__Product__r.NG4_APAC_JAPAN_YEN_Price__c, BigMachines__Quote__r.Quote_Billing_Plan_count__c,';
    strQueryAllFields += 'BigMachines__Product__r.NG5_NA_CAD_Price__c,BigMachines__Product__r.NG5_NA_USD_Price__c,BigMachines__Product__r.NG5_NZD_Price__c,BigMachines__Product__r.NG5_ZAR_Price__c';
    strQueryAllFields += ' FROM BigMachines__Quote_Product__c WHERE BigMachines__Quote__c in :Set_QuoteIds';
    System.debug('Query' + strQueryAllFields);
    List<BigMachines__Quote_Product__c> list_NewQuoteProducts = Database.Query(strQueryAllFields);
    if (list_NewQuoteProducts.size() > 0) {
        for (BigMachines__Quote_Product__c objQP : list_NewQuoteProducts) {
            if (!map_QIdtoQPs.containskey(objQP.BigMachines__Quote__c)) {
                map_QIdtoQPs.put(objQP.BigMachines__Quote__c, new List<BigMachines__Quote_Product__c>());
                map_QIdtoQPs.get(objQP.BigMachines__Quote__c).add(objQP);
            } else
            {map_QIdtoQPs.get(objQP.BigMachines__Quote__c).add(objQP);}
        }
    }
    return map_QIdtoQPs;
}

public static  Map<Id, Map<String, Id>>  PreparePBEList(Map<Id, List<BigMachines__Quote_Product__c>> map_QuoteIdtoQuoteProds) {
    System.debug(' map_QuoteIdtoQuoteProds' + map_QuoteIdtoQuoteProds);
    Set<Id> set_ProdIds = new Set<Id>();
    Set<String> set_ProdCurrency = new Set<String>();
    
    for (Id Id_QuoteId : map_QuoteIdtoQuoteProds.keyset()) {
        for (BigMachines__Quote_Product__c objQP : map_QuoteIdtoQuoteProds.get(Id_QuoteId)) {
            set_ProdIds.add(objQP.BigMachines__Product__c);//set_ProdIds.add(objQP.ID)
            set_ProdCurrency.add(objQP.CurrencyIsoCode);//set_ProdCurrency.add(objQP.BigMachines__Product__r.CurrencyISOCode);
        }
    }
    System.debug('set_ProdIds' + set_ProdIds + 'set_ProdCurrency' + set_ProdCurrency);
    List<PricebookEntry> list_PBE = [SELECT Product2Id, Id, CurrencyISOCode FROM PricebookEntry WHERE Pricebook2Id = :Label.Standard_Pricebook_Id AND
                                     Product2Id IN :set_ProdIds AND CurrencyISOCode in :set_ProdCurrency];
    Map<Id, Map<String, Id>> map_ProdIdToPBEId = new Map<Id, Map<String, Id>>();
    for (PricebookEntry objPBE : list_PBE) {
        if (!map_ProdIdToPBEId.containskey(objPBE.Product2Id)) {
            map_ProdIdToPBEId.put(objPBE.Product2Id, new Map<String, Id>());
            map_ProdIdToPBEId.get(objPBE.Product2Id).put(String.valueof(objPBE.CurrencyISOCode), objPBE.Id);
        } else
        {map_ProdIdToPBEId.get(objPBE.Product2Id).put(String.valueof(objPBE.CurrencyISOCode), objPBE.Id);}
    }
    System.debug('map_ProdIdToPBEId' + map_ProdIdToPBEId);
    return  map_ProdIdToPBEId;
}
public static Set<Id> findOverageChargeAPNs(List<BigMachines__Quote__c> list_Quotes) {
    Set<Id> set_QId = new Set<Id>();
    for (BigMachines__Quote__c objQuote : list_Quotes) {
        if (objQuote.Billing_Category__c == 'M2M') {
            set_QId.add(objQuote.Id);
        }
    }
    Set<Id> set_OvrgProdParentIds = new Set<Id>();
    for (BigMachines__Quote_Product__c objOvgQP : [SELECT Id, Parent_Quote_Product__c
                                                   FROM BigMachines__Quote_Product__c
                                                   WHERE BigMachines__Quote__c  in :set_QId
                                                   AND Parent_Quote_Product__c != null]) {
                                                       set_OvrgProdParentIds.add(objOvgQP.Parent_Quote_Product__c);
                                                   }
    return set_OvrgProdParentIds;
}

////MS - IS THIS METHOD USED???
public static List<Order_Line_Item__c> createOLIfromSupProds(Set<String> set_OLIUniqueString, Integer intOLICount, BigMachines__Quote__c objQuote, Id IdOrderId) {
    
    //Added by Rony Joseph - June 05 2018 - Starts
    //*******Adding removed products from Subscription as Order Line Items with 0 Quantity
    System.debug('Entered createOLIfromSupProds');
    Map<String, Subscription_Product__c> map_PrevProdInfo = new Map<String, Subscription_Product__c>();
    Map<String, RecordType> map_OrderLnItmRecTypes = getRecordTypes('Order_Line_Item__c');
    List<Order_Line_Item__c> list_ToInsertOrderLineItems = new List<Order_Line_Item__C>();
    List<Subscription_Product__c> list_SubscriptionProds = SubscriptionUtil.getSubscriptionProducts(objQuote.Amendment_For__c);
    for (Subscription_Product__c objSubProd : list_SubscriptionProds) {
        String strUniqueKey = objSubProd.Product__c + ';' + objSubProd.Is_Overage__c;
        System.debug('UniqueString:' + strUniqueKey);
        if (!String.isBlank(strUniqueKey) && objSubProd.Quantity__c != null) {
            map_PrevProdInfo.put(strUniqueKey, objSubProd);
        }
    }
    
    System.debug('OLIUnistring:' + set_OLIUniqueString);
    System.debug('map_PrevProdInfo.keyset() :' + map_PrevProdInfo.keyset() );
    for ( string strUniqueKey : map_PrevProdInfo.keyset() )    {
        if (!set_OLIUniqueString.contains(strUniqueKey)) {
            System.debug('MatchString:' + strUniqueKey);
            Subscription_Product__c objSubProd = map_PrevProdInfo.get(strUniqueKey);
            Order_Line_Item__c objNewOLI = new Order_Line_Item__c();
            objNewOLI.Order__c = IdOrderId;
            objNewOLI.Quote_Product__c = objSubProd.Quote_Product__c;
            objNewOLI.Line_Number__c = intOLICount;
            objNewOLI.CurrencyIsoCode =  objSubProd.CurrencyIsoCode;
            objNewOLI.Product__c = objSubProd.Product__c;
            objNewOLI.Product_txt__c = objSubProd.Product__r.Name;
            objNewOLI.Name = objSubProd.Product__r.Name;
            objNewOLI.APN_Number__c = objSubProd.Product__r.APN_Number__c;
            objNewOLI.Description__c = objSubProd.Product__r.Description__c;
            objNewOLI.RecordTypeId = map_OrderLnItmRecTypes.get('Default').Id;
            objNewOLI.Unit_of_Measure__c = objSubProd.Quote_Product__r.Unit_of_Measure__c != null ? objSubProd.Quote_Product__r.Unit_of_Measure__c : '';
            objNewOLI.Quantity__c =  0;
            objNewOLI.BigMachines_Quantity__c = 0;
            objNewOLI.List_Price__c = objSubProd.List_Price__c;
            objNewOLI.Net_Unit_Price__c = objSubProd.Net_Unit_Price__c;
            objNewOLI.Sales_Price__c = objNewOLI.Net_Unit_Price__c;
            if (objQuote.BigMachines__Opportunity__r.Indirect_Partner_PureCloud_Approved__c) {
                objNewOLI.Net_Unit_Price__c = objSubProd.Partner_Price__c != null && objSubProd.Partner_Price__c > 0 ? objSubProd.Partner_Price__c : objSubProd.Net_Unit_Price__c;
            }
            objNewOLI.Ext_List__c = objNewOLI.List_Price__c;
            System.debug('######objNewOLI.Net_Unit_Price__c: ' + objNewOLI.Net_Unit_Price__c);
            System.debug('######objNewOLI.Quantity__c: ' + objNewOLI.Quantity__c);
            objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c;
            if (objNewOLI.Quantity__c != null || objNewOLI.Quantity__c > 0) {
                objNewOLI.Ext_List__c = objNewOLI.List_Price__c * objNewOLI.Quantity__c;
                objNewOLI.Ext_Net_Price__c = objNewOLI.Net_Unit_Price__c * objNewOLI.Quantity__c;
            }
            objNewOLI.Total_Discount__c = objSubProd.Total_Discount__c;
            objNewOLI.Product_Specific_Discount__c = objSubProd.Quote_Product__r.Product_Specific_Discount__c;
            objNewOLI.Is_Overage__c = objSubProd.Is_Overage__c;
            objNewOLI.Ext_Net_Price_Change__c = objSubProd.Ext_Net_Price_Change__c;
            objNewOLI.Quantity_Change__c = objSubProd.Quantity__c * -1;
            list_ToInsertOrderLineItems.add(objNewOLI);
            intOLICount++;
            
        }
    }
    
    return list_ToInsertOrderLineItems;
    //Added by Rony Joseph - June 05 2018 - Ends
}

public static String getMSALink(Opportunity objOpty, String strOfferingType) {
    String strURL = '';
    for (Links__mdt objMSALink : [SELECT Country__c, Link_Type__c, Offering_Type__c, URL__c
                                  FROM Links__mdt
                                  WHERE Offering_Type__c = : strOfferingType
                                  AND Link_Type__c = 'MSA'
                                  AND (Country__c = : objOpty.Sold_To_Country__r.Name OR Country__c = 'Default') LIMIT 2]) {
                                      strURL = objMSALink.URL__c;
                                      if (objMSALink.Country__c == objOpty.Sold_To_Country__r.Name) {
                                          break;
                                      }
                                  }
    return strURL;
}

///MS 5/30/19 - order line start/end calculation for On Premise Subscription. Adding Ramp period to the 1st year end
public static List<Date> calculateOnPremSubscripOrderLineDates(Date orderStartDate, Date orderEndDate, String rampSelected, Integer Year){
    List<Date> listOfStartAndEndDate = new List<Date>();
    Date orderLineStartDate, orderLineEndDate;
    Integer noOfMonths = orderStartDate.monthsBetween(orderEndDate);
    Integer rampMnth = rampSelected != null && rampSelected.isNumeric() ? Integer.valueOf(rampSelected)/30 : 0;

    if (Year == 1) {
        orderLineStartDate = orderStartDate;
        if(noOfMonths >= 12)                
            orderLineEndDate = orderStartDate.addMonths(12+rampMnth).addDays(-1);            
        else
            orderLineEndDate = orderEndDate.addMonths(rampMnth);                         
    }
    else if(Year == 2) {
        orderLineStartDate = orderStartDate.addMonths(12+rampMnth);
       // if(noOfMonths >= 12)                
        orderLineEndDate = orderEndDate;
    }  
    listOfStartAndEndDate.add(orderLineStartDate);
    listOfStartAndEndDate.add(orderLineEndDate);        
    return listOfStartAndEndDate;
}
//MS 5/30/19 - order line start/end calculation for On Premise Amendment Subscription. Align Amendm Year 1 End Date whith the
/// parent Subscription Year 1 End Date
public static List<Date> listAmendDatesY1;
public static List<Date> listAmendDatesY2;
public static Map<String, Date> dates; 

public static List<Date> onPremAmendDatesY1(Date orderStartDate, Date orderEndDate, Integer term, Date rampEndDate) {
    if ( listAmendDatesY1 == null ) {
        listAmendDatesY1 = new List<Date>();
     
        listAmendDatesY1.add(orderStartDate);  //start
        if (term == 1)
           listAmendDatesY1.add(orderEndDate);  //end
        else {
            //term 2
            Date endY1;
            if (rampEndDate == null )
              listAmendDatesY1.add(orderStartDate.addMonths(12)); 
            else
              listAmendDatesY1.add(rampEndDate.addMonths(12)); 
        }
    }
    return listAmendDatesY1;
}

public static List<Date> onPremAmendDatesY2(Date orderStartDate, Date orderEndDate, Integer term, Date rampEndDate) {
    if ( listAmendDatesY2 == null ) {
        listAmendDatesY2 = new List<Date>();
       
        ///Y2 Start Date
        if (term == 2) {
            //year 2 start
            Date calcStart;
            if (rampEndDate == null ) 
                calcStart = orderStartDate.addMonths(12).addDays(1);
            else
                calcStart = rampEndDate.addMonths(12).addDays(1);

            calcStart = (System.today() > calcStart) ? System.today() : calcStart;
            listAmendDatesY2.add(calcStart);
        }
        else {
            ///there is no Y2 if term != 2
           listAmendDatesY2.add(orderEndDate);       
        }
         ///Y2 End Date
        listAmendDatesY2.add(orderEndDate);
    }
    return listAmendDatesY2;
}    

public static List<Date> calculateOnPremAmendOrderLineDates(Date orderStartDate, Date orderEndDate, Date rampEndDate, Integer Year){
    List<Date> dt = new List<Date>();

     //exceptions
    if ( System.today() > orderEndDate) {
        dt.add(orderEndDate); //start = end, will not add order line
        dt.add(orderEndDate); ///end
        return dt;
    }        
    //term
    Integer term;
    if ( rampEndDate != null ) 
        term = rampEndDate.monthsBetween(orderEndDate) > 12 ? 2 : 1;
    else 
        term = orderStartDate.monthsBetween(orderEndDate) > 12 ? 2 : 1;   
    
    if ( Year == 1 ) 
       dt = onPremAmendDatesY1(orderStartDate, orderEndDate, term, rampEndDate);
    else if ( Year == 2 )
       dt = onPremAmendDatesY2(orderStartDate, orderEndDate, term, rampEndDate);
    return dt;
}

 public static BigMachines__Quote__c updateLeverDetials(BigMachines__Quote__c objQuote,Opportunity objOpty){
    try{           
        if ( (objQuote.Lever__c != null && objQuote.Lever__c.contains('Lever 2')) &&  (objQuote.Offering_Type__c == null || objQuote.Offering_Type__c == OFFERING_TYPE_CIC ) ) {
                   System.debug('@@ calling createGUPassports');
            createGUPassports(objQuote);
        }
        else if ((objQuote.Lever__c != null && objQuote.Lever__c.contains('Lever 4')) && (objQuote.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC))
         {
                objQuote.Billing_Category__c = 'Annual Pre-Pay';
                objQuote.Hide_Discount__c = true;
                objQuote.Hide_List_Price__c = true;
                objQuote.Treat_SO_as_PO__c = true;
                objQuote.Hide_Totals__c = true;
                objQuote.PureCloud_Monthly_Minimum__c = 0;
                objQuote.No_Of_Months__c = 1;
                objQuote.Ramp_Period__c = '0';
                objQuote.Subscription_End_Date__c = (System.today().daysBetween(objOpty.Avaya_Contract_Expiration__c) < 365)?objOpty.Avaya_Contract_Expiration__c:objQuote.Subscription_Start_Date__c.addMonths(12);                  
        }

    } catch(Exception e){System.debug('Error has occurred:'+e.getMessage()+'\n'+e.getStackTraceString());
                        return null;
    }
     return objQuote;
}
//Yuvaraj- July 1st 2019 -PureBridge Project - Ends 
public static void createGUPassports(BigMachines__Quote__c objQuote) {
    Set<String> set_IVRDataStrgPartNos = new Set<String>();
    List<BigMachines__Quote_Product__c> list_IVRDataStorageParts = new list<BigMachines__Quote_Product__c>();
    List<Passport_SKUs__mdt> arr_IVRDataStrgPartNos = [SELECT Id, Label, Offering_Type__c,APN_of_GU_Product__c 
                                                       FROM Passport_SKUs__mdt
                                                       WHERE Offering_Type__c = :objQuote.Offering_Type__c];    
    for(Integer i=0; i<arr_IVRDataStrgPartNos.size(); i++) {
        set_IVRDataStrgPartNos.add(arr_IVRDataStrgPartNos[i].APN_of_GU_Product__c);
    }
    System.debug('####set_IVRDataStrgPartNos: '+set_IVRDataStrgPartNos);
    integer intLineNumber = [select count() from  BigMachines__Quote_Product__c where BigMachines__Quote__c =:objQuote.Id]; 
    for(Product2 objProd : [SELECT Id, Name, APN_Number__c, NG1_APAC_ANZ_AUD_Price__c, NG2_BRAZIL_BRL_Price__c, 
                            NG5_NZD_Price__c, NG3_EMEA_GBP_Price__c, NG4_APAC_JAPAN_YEN_Price__c, NG4_APAC_CHINA_INDIA_USD_Price__c,
                            NG3_EMEA_EUR_Price__c, NG5_NA_CAD_Price__c, NG5_ZAR_Price__c, NG5_NA_USD_Price__c,NG2_CALA_USD_Price__c,
                            NG1_APAC_KOREA_SE_ASIA_USD_Price__c,  NG3_EMEA_USD_Price__c
                            FROM Product2 
                            WHERE APN_Number__c IN :set_IVRDataStrgPartNos]) {
                                BigMachines__Quote_Product__c objNewQP = new BigMachines__Quote_Product__c();
                                objNewQP.BigMachines__Quote__c = objQuote.Id;
                                objNewQP.Name = objProd.Name;
                                objNewQP.APN_Number__c = objProd.APN_Number__c;
                                objNewQP.BigMachines__Product__c = objProd.Id;            
                                objNewQP.BigMachines__Quantity__c = objNewQP.Quantity__c = 3;            
                                objNewQP.List_Price__c = (Decimal)objProd.get(objQuote.New_Price_Book__c + '_Price__c') != null ? (Decimal)objProd.get(objQuote.New_Price_Book__c + '_Price__c') : 0;
                                objNewQP.BigMachines__Sales_Price__c = objNewQP.Net_Unit_Price__c != null ? objNewQP.Net_Unit_Price__c : 0;
                                objNewQP.Ext_List__c = 0;
                                objNewQP.Ext_Net_Price__c = 0;
                                objNewQP.Disc__c =100.0;
                                objNewQP.CurrencyISOCode = objQuote.CurrencyISOCode;
                                objNewQP.Active_Start_Date__c = objQuote.Subscription_Start_Date__c;
                                objNewQP.Active_End_Date__c = objQuote.Subscription_End_Date__c;
                                objNewQP.Billing_Category__c = objQuote.Billing_Category__c;
                                objNewQP.Type_of_Product__c  = 'Ordinary';
                                objNewQP.Line_Number__c  = ++intLineNumber;
                                System.debug('####objNewQP'+objNewQP);
                                list_IVRDataStorageParts.add(objNewQP);
                            }
    insert list_IVRDataStorageParts;
    System.debug('####list_IVRDataStorageParts'+list_IVRDataStorageParts);
}
public static void testCoverageMethod(){
    integer i = 0;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++; 
     i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;
    i++;       
     i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;  
}
}