/************************************************************************************
Purpose : Batch job to auto renew PC subscription which expires today
Written By : Ranjith Punneli
Test Classes : SubscriptionAutoRenewalTest
*************************************************************************************/

public class SubscriptionAutoRenewal {
    
    Set<Id> set_SubscriptionIds = new Set<Id>();
    Set<Id> set_SoldToIds = new Set<Id>();
    Set<Id> set_RatePlanProdIds = new Set<Id>();    
    Set<Id> set_BundleSubscriptionProdIds = new Set<Id>();
    Set<String> set_SubscriptionIdsToPC = new Set<String>();
    List<Subscription__c> list_Subscriptions = new List<Subscription__c>();
    List<Subscription__c> list_ChangeToInactiveSubscriptions = new List<Subscription__c>();
    List<Subscription__c> list_ChangeToCancelledSubscriptions = new List<Subscription__c>();
    List<Subscription__c> list_AllSubscriptions = new List<Subscription__c>();
    List<Subscription__c> list_ToInsertSubscrptions = new List<Subscription__c>();
    List<Subscription__c> list_ToUpdateSubscrptions = new List<Subscription__c>();
    List<Subscription_Product__c> list_ToInsertSubscrptionProds = new List<Subscription_Product__c>();
    List<Subscription_Product__c> list_ToUpdateSubscrptionProds = new List<Subscription_Product__c>();
    Map<Id, Id> map_OldToNewSubscriptionIds = new Map<Id, Id>();
    Map<Id, Id> map_BundleSubscrProdOldToNewIds = new Map<Id, Id>();
    Map<Id, List<Product_Tier_Pricing__c>> map_ExistingProdTiers = new Map<Id, List<Product_Tier_Pricing__c>>();
    Map<Id, Map<String, Decimal>> map_SoldToPCPartnerMargins = new Map<Id, Map<String, Decimal>>();
    Map<Id, Decimal> map_SubscripIdToTotalRecAmount = new Map<Id, Decimal>();
    Map<Id, Decimal> map_SubscripIdToTotalNonRecAmount = new Map<Id, Decimal>();
    Map<Id, Decimal> map_SubscripIdToTotalNonCreditAmount = new Map<Id, Decimal>();
    Map<Id, Decimal> map_SubscripIdToTotalRecServAmount = new Map<Id, Decimal>();
    Map<Id, Decimal> map_SubscripIdToTotalEducation = new Map<Id, Decimal>();
    Map<Id, Decimal> map_SubscripIdToTotalHardware = new Map<Id, Decimal>();
    Map<Id, Decimal> map_SubscripIdToTotalServices = new Map<Id, Decimal>();
    Map<Id, Decimal> map_SubscripIdToTotalSetupProvisioningCharges = new Map<Id, Decimal>();
    
    
    public SubscriptionAutoRenewal(Date dtRunDate) {
        list_AllSubscriptions = SubscriptionUtil.getSubscriptionsForAutoRenewal(dtRunDate);        
        
        
        for(Subscription__c objSubscrp : list_AllSubscriptions) {
            System.debug(objSubscrp);
            if(objSubscrp.NewSubscriptions__r.size() > 0) {                              
                Subscription__c objExistingRenewSub = new Subscription__c(Id=objSubscrp.NewSubscriptions__r[0].Id, Org_Id__c=objSubscrp.Org_Id__c);
                list_ChangeToInactiveSubscriptions.add(objExistingRenewSub);
                objSubscrp.Org_Id__c = '';
                objSubscrp.Status__c = 'Inactive';  
                list_ChangeToInactiveSubscriptions.add(objSubscrp);
                set_SubscriptionIdsToPC.add(objSubscrp.Id);
            }
            else if (objSubscrp.Offering_Detail__c == 'Free Trial' && Integer.valueof(objSubscrp.Version__c) <= 3){
                objSubscrp.Status__c = 'Cancelled';  
                objSubscrp.Org_Id__c = '';
                list_ChangeToCancelledSubscriptions.add(objSubscrp);
            }
            else  {
                list_Subscriptions.add(objSubscrp);
            }
        }
        
        //Changed for S-647874-Added by Dekshant for CCDB Requirement
        List<Subscription__c> subscriptionToInactive = new List<Subscription__c>();
        Boolean isInsertSubscription;
        for(Subscription__c objSubscrp : list_Subscriptions) {
            
            if(objSubscrp.Billing_Category__c == 'Annual M2M' || objSubscrp.Billing_Category__c == 'Annual Pre-Pay'){
                system.debug('annual m2m case'+objSubscrp.Billing_Category__c);
                set_SubscriptionIds.add(objSubscrp.Id);
                if(objSubscrp.Sale_Type__c == 'Indirect' && objSubscrp.Account__c != objSubscrp.Business_Partner__c) {
                    set_SoldToIds.add(objSubscrp.Business_Partner__c);
                }
                Subscription__c objNewSubscrp = objSubscrp.clone(false, true, false, false);   
                objNewSubscrp.Start_Date__c = objNewSubscrp.Subscription_End_Date__c + 1;  
                objNewSubscrp.Ramp_End_Date__c = objNewSubscrp.Start_Date__c;
                objNewSubscrp.Subscription_Start_Date__c = objNewSubscrp.Subscription_End_Date__c + 1;
                objNewSubscrp.Subscription_End_Date__c = objNewSubscrp.Subscription_Start_Date__c.addMonths(1) - 1;
                
                // objNewSubscrp.Amendment_For__c = objNewSubscrp.Id;
                
                //Added by Dekshant for CCDB-Populating the date when it converted to M2M
                objNewSubscrp.Billing_Category__c = 'M2M';
                
                if(objNewSubscrp.M2M_Converted_Date__c==Null)
                {
                    objNewSubscrp.M2M_Converted_Date__c=date.today(); 
                }
                //END
                objNewSubscrp.Billing_Period__c = 'Monthly';
                objNewSubscrp.Requires_Manual_Billing_Review__c=objSubscrp.Requires_Manual_Billing_Review__c;
                objNewSubscrp.Manual_Billing_Review_Status__c=objSubscrp.Manual_Billing_Review_Status__c;
                objNewSubscrp.Order_Special_Offer__c=objSubscrp.Order_Special_Offer__c;
                objNewSubscrp.Term__c = '1 Month';             
                objNewSubscrp.Ramp_Period__c = 0;
                objNewSubscrp.Sync_Status__c = 'Waiting to Sync';
                objNewSubscrp.Version__c += 1;
                objNewSubscrp.CMRR__c = 0;
                objNewSubscrp.ACV__c = 0;
                objNewSubscrp.Total_Tokens__c = 0;
                objNewSubscrp.Other_Genesys_Care_Support_Value__c = 0;
                objNewSubscrp.PureSuccess_Dollar_Amount__c = 0;
                objNewSubscrp.Auto_Renewed__c = true;
                objNewSubscrp.Message__c = '';
                If(objNewSubscrp.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC){
                    objNewSubscrp.Committed_Term_Date_Validation__c = objNewSubscrp.Subscription_Start_Date__c;//Updated for I-396805
                }
                /*if(objNewSubscrp.Original_Subscription__c == null) {
objNewSubscrp.Original_Subscription__c = objNewSubscrp.Id;
} */       //Changed for S-647874
                objNewSubscrp.Is_Cloned__c = false;
                //Anju June New CCDB field
                objNewSubscrp.Term_Length_Months__c = 1;
                list_ToInsertSubscrptions.add(objNewSubscrp);
                isInsertSubscription = true;
                objSubscrp.Status__c = 'Inactive';
                subscriptionToInactive.add(objSubscrp);
            }
            else if(objSubscrp.Billing_Category__c == 'M2M'){
                system.debug('m2m case'+objSubscrp.Billing_Category__c);
                set_SubscriptionIds.add(objSubscrp.Id);
                if(objSubscrp.Sale_Type__c == 'Indirect' && objSubscrp.Account__c != objSubscrp.Business_Partner__c) {
                    set_SoldToIds.add(objSubscrp.Business_Partner__c);
                }
                //Subscription__c objNewSubscrp = objSubscrp.clone(false, true, false, false);   
                objSubscrp.Start_Date__c = objSubscrp.Subscription_End_Date__c + 1;  
                objSubscrp.Ramp_End_Date__c = objSubscrp.Start_Date__c;
                objSubscrp.Subscription_Start_Date__c = objSubscrp.Subscription_End_Date__c + 1;
                objSubscrp.Subscription_End_Date__c = objSubscrp.Subscription_Start_Date__c.addMonths(1) - 1;
                
                // objSubscrp.Amendment_For__c = objSubscrp.Id;
                
                //Added by Dekshant for CCDB-Populating the date when it converted to M2M
                //objSubscrp.Billing_Category__c = 'M2M';
                
               /* if(objSubscrp.M2M_Converted_Date__c==Null)
                {
                    objSubscrp.M2M_Converted_Date__c=date.today(); 
                }*/
                //END------
                objSubscrp.Billing_Period__c = 'Monthly';
                objSubscrp.Term__c = '1 Month';             
                objSubscrp.Ramp_Period__c = 0;
                objSubscrp.Sync_Status__c = 'Waiting to Sync';
                objSubscrp.Version__c += 1;
                objSubscrp.CMRR__c = 0;
                objSubscrp.ACV__c = 0;
                objSubscrp.Total_Tokens__c = 0;
                objSubscrp.Other_Genesys_Care_Support_Value__c = 0;
                objSubscrp.PureSuccess_Dollar_Amount__c = 0;
                objSubscrp.Auto_Renewed__c = true;
                objSubscrp.Message__c = '';
                If(objSubscrp.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC){
                    objSubscrp.Committed_Term_Date_Validation__c = objSubscrp.Subscription_Start_Date__c;//Updated for I-396805
                }
                /*if(objSubscrp.Original_Subscription__c == null) {
objSubscrp.Original_Subscription__c = objSubscrp.Id;
} */       //Changed for S-647874
                objSubscrp.Is_Cloned__c = false;
                //Anju June New CCDB field
                objSubscrp.Term_Length_Months__c = 1;
                list_ToInsertSubscrptions.add(objSubscrp);
                isInsertSubscription = false;
            }
            
        }

        
        try {
            if(isInsertSubscription){
                Database.SaveResult[] saveResult = Database.insert(list_ToInsertSubscrptions, false);//Changed for S-647874-Ends here
                Database.SaveResult[] saveResult2 = Database.update(subscriptionToInactive, false);//Changed for S-647874-Ends here
            }else{
                Database.SaveResult[] saveResult = Database.update(list_ToInsertSubscrptions, false);//Changed for S-647874-Ends here
            }
            for(Subscription__c objNewSubscrp : list_ToInsertSubscrptions) {
                map_OldToNewSubscriptionIds.put(objNewSubscrp.Amendment_For__c, objNewSubscrp.Id);
                map_SubscripIdToTotalRecAmount.put(objNewSubscrp.Id, 0);
                map_SubscripIdToTotalNonRecAmount.put(objNewSubscrp.Id, 0);
                map_SubscripIdToTotalNonCreditAmount.put(objNewSubscrp.Id, 0);
                map_SubscripIdToTotalRecServAmount.put(objNewSubscrp.Id, 0);
                map_SubscripIdToTotalEducation.put(objNewSubscrp.Id, 0);
                map_SubscripIdToTotalHardware.put(objNewSubscrp.Id, 0);
                map_SubscripIdToTotalServices.put(objNewSubscrp.Id, 0); 
                map_SubscripIdToTotalSetupProvisioningCharges.put(objNewSubscrp.Id, 0);               
            }
            
            List<Subscription_Product__c> list_SubscriptionProds = SubscriptionUtil.getSubscriptionProductForSubscrps(set_SubscriptionIds);
            System.debug('######list_SubscriptionProds' + list_SubscriptionProds);
            
            for(Subscription_Product__c objSubscrpProd : list_SubscriptionProds) {
                if(objSubscrpProd.Product__r.Price_Type__c == 'Rate Plan' || objSubscrpProd.Product__r.Price_Type__c == 'Range') {
                    set_RatePlanProdIds.add(objSubscrpProd.Product__c);
                }
            }
            
            //Added By Ranjith on Feb 26, 2019 -- Starts - For Data Type Conversion under Product Tier Pricing object
            String strWhereCondition = 'WHERE Product__c IN :set_RatePlanProdIds  AND Charge_Type__c = \'M2M\' ORDER BY Range_From__c';
            for(Product_Tier_Pricing__c objProdTr : Database.query(QuoteCloudUtil.buildTierPricingQuery(strWhereCondition, 'NG1_APAC_ANZ_AUD_Price__c, NG2_BRAZIL_BRL_Price__c, NG3_EMEA_EUR_Price__c, NG5_NA_CAD_Price__c, NG5_NZD_Price__c, NG3_EMEA_GBP_Price__c, NG4_APAC_JAPAN_YEN_Price__c, NG5_ZAR_Price__c'))) {
                //Added By Ranjith on Feb 26, 2019 -- Ends
                if(map_ExistingProdTiers.containskey(objProdTr.Product__c))
                    map_ExistingProdTiers.get(objProdTr.Product__c).add(objProdTr);
                else
                    map_ExistingProdTiers.put(objProdTr.Product__c, new List<Product_Tier_Pricing__c>{objProdTr});
            }
            
            for(PureCloud_Partner_Margin__c objPartnerMargin : [SELECT Account__c, Percent__c, Margin_Type__c
                                                                FROM PureCloud_Partner_Margin__c
                                                                WHERE From_Date__c <= TODAY 
                                                                AND To_Date__c >= TODAY 
                                                                AND Account__c IN :set_SoldToIds
                                                                ORDER BY To_Date__c ASC]) {
                                                                    if(map_SoldToPCPartnerMargins.containsKey(objPartnerMargin.Account__c)) {
                                                                        map_SoldToPCPartnerMargins.get(objPartnerMargin.Account__c).put(objPartnerMargin.Margin_Type__c, objPartnerMargin.Percent__c);
                                                                    }
                                                                    else {
                                                                        map_SoldToPCPartnerMargins.put(objPartnerMargin.Account__c, new Map<String, Decimal> {objPartnerMargin.Margin_Type__c => objPartnerMargin.Percent__c});
                                                                    }
                                                                }
            
            //PCC Partner margin
            for(Partner_Discount__c objPartnerMargin : [SELECT Discount__c, Category__c,Account__c 
                                                        FROM Partner_Discount__c
                                                        WHERE Account__c IN :set_SoldToIds AND type__c =: SubscriptionUtil.OFFERING_TYPE_PCC]) {
                                                            if(map_SoldToPCPartnerMargins.containsKey(objPartnerMargin.Account__c)) {
                                                                map_SoldToPCPartnerMargins.get(objPartnerMargin.Account__c).put(objPartnerMargin.Category__c == 'Base Line Discount' ? 'Software' : objPartnerMargin.Category__c, objPartnerMargin.Discount__c);
                                                            }
                                                            else {
                                                                map_SoldToPCPartnerMargins.put(objPartnerMargin.Account__c, new Map<String, Decimal> {objPartnerMargin.Category__c == 'Base Line Discount' ? 'Software' : objPartnerMargin.Category__c => objPartnerMargin.Discount__c});
                                                            }
                                                        } 
            
            
            for(Subscription_Product__c objSubscrpProd : list_SubscriptionProds) {
                //if(objSubscrpProd.Product__r.IsActive) {
                Subscription_Product__c objNewSubscrpProd = objSubscrpProd.clone(false, true, false, false);  
                objNewSubscrpProd.Subscription__c = map_OldToNewSubscriptionIds.get(objSubscrpProd.Subscription__c);
                objNewSubscrpProd.Amendment_For__c = objSubscrpProd.Id;
                
                if(objSubscrpProd.Subscription__r.Billing_category__c != 'M2M' || Test.isRunningTest()) {
                    objNewSubscrpProd.Total_Discount__c = 0;                     
                    objNewSubscrpProd.List_Price__c = (Decimal)objSubscrpProd.Product__r.get(objNewSubscrpProd.Subscription__r.Price_Book_Currency__c + '_Price__c');
                    if(objNewSubscrpProd.Product__r.Price_Type__c == 'Rate Plan'
                       && map_ExistingProdTiers.containsKey(objNewSubscrpProd.Product__c)) {
                           objNewSubscrpProd.List_Price__c = (Decimal)map_ExistingProdTiers.get(objNewSubscrpProd.Product__c)[0].get(objNewSubscrpProd.Subscription__r.Price_Book_Currency__c + '_Price__c');
                       }
                    else if(objNewSubscrpProd.Product__r.Price_Type__c == 'Range'
                            && map_ExistingProdTiers.containsKey(objNewSubscrpProd.Product__c)) {
                                objNewSubscrpProd.List_Price__c = QuoteCloudUtil.getProductTierPricing(map_ExistingProdTiers.get(objNewSubscrpProd.Product__c), 
                                                                                                       objNewSubscrpProd.Quantity__c, objNewSubscrpProd.List_Price__c,  objNewSubscrpProd.Subscription__r.Price_Book_Currency__c + '_Price__c');
                            }
                    objNewSubscrpProd.List_Price__c = objNewSubscrpProd.List_Price__c != null ? objNewSubscrpProd.List_Price__c : 0;
                    System.debug('######List_Price__c : ' + objNewSubscrpProd.List_Price__c );
                    objNewSubscrpProd.Ext_List__c = objNewSubscrpProd.List_Price__c * objNewSubscrpProd.Quantity__c; 
                    objNewSubscrpProd.Net_Unit_Price__c = objNewSubscrpProd.List_Price__c;
                    if(objSubscrpProd.Subscription__r.Sale_Type__c == 'Indirect'
                       && map_SoldToPCPartnerMargins.containsKey(objSubscrpProd.Subscription__r.Business_Partner__c)) {
                           Decimal decProductPartnerMargin = 0;
                           Map<String, Decimal> map_PCPartnerMargins = new Map<String, Decimal>();
                           map_PCPartnerMargins = map_SoldToPCPartnerMargins.get(objSubscrpProd.Subscription__r.Business_Partner__c); 
                           if(objSubscrpProd.Subscription__r.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC
                              && objSubscrpProd.Subscription__r.Business_Partner__r.Approved_for_PureCloud_Billing__c)                       
                               decProductPartnerMargin = map_PCPartnerMargins.containsKey(objSubscrpProd.Product__r.Partner_Margin_Type__c) ? map_PCPartnerMargins.get(objSubscrpProd.Product__r.Partner_Margin_Type__c) : 0;
                           else if(objSubscrpProd.Subscription__r.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC 
                                   && objSubscrpProd.Subscription__r.Business_Partner__r.PartnerType__c != null 
                                   && objSubscrpProd.Subscription__r.Business_Partner__r.PartnerType__c.contains('Cloud Reseller') 
                                   && objSubscrpProd.Subscription__r.Business_Partner__r.Partner_Offering_Type__c != null 
                                   && objSubscrpProd.Subscription__r.Business_Partner__r.Partner_Offering_Type__c.contains('PureConnect Cloud Reseller'))
                           {
                               if(map_PCPartnerMargins.containsKey(objSubscrpProd.Product__r.Partner_Margin_Category__c)) 
                                   decProductPartnerMargin =  map_PCPartnerMargins.get(objSubscrpProd.Product__r.Partner_Margin_Category__c);
                               else if(Partner_Hardware_Margins__c.getInstance(objSubscrpProd.Product__r.Partner_Margin_Category__c) != NULL)
                                   decProductPartnerMargin =  Partner_Hardware_Margins__c.getInstance(objSubscrpProd.Product__r.Partner_Margin_Category__c).Margin__c;
                           }    
                           objNewSubscrpProd.Partner_Price__c = (objNewSubscrpProd.List_Price__c - (objNewSubscrpProd.List_Price__c * decProductPartnerMargin/100));
                           objNewSubscrpProd.Ext_List__c = objNewSubscrpProd.Partner_Price__c * objNewSubscrpProd.Quantity__c; 
                           objNewSubscrpProd.Total_Discount__c += decProductPartnerMargin;                        
                       }
                    System.debug('######Partner_Price__c : ' + objNewSubscrpProd.Partner_Price__c );
                    // Line Discount
                    if(objNewSubscrpProd.Disc__c != null && String.isNotBlank(objNewSubscrpProd.or_Amount__c)){
                        if(objNewSubscrpProd.or_Amount__c == '%'){
                            objNewSubscrpProd.Total_Discount__c += objNewSubscrpProd.Disc__c;           
                        }
                        else if(objNewSubscrpProd.or_Amount__c == 'Amt'){
                            objNewSubscrpProd.Total_Discount__c += (objNewSubscrpProd.Disc__c/objNewSubscrpProd.List_Price__c) * 100;           
                        }
                    }    
                    // Bundle Discount
                    /*if(objNewSubscrpProd.Bundle__c != null && objNewSubscrpProd.Bundle_Discount__c != null) {
objNewSubscrpProd.Total_Discount__c += objNewSubscrpProd.Bundle_Discount__c;        
}*/
                    // Adjustment Discount
                    if(objNewSubscrpProd.Adjustment__c != null && objNewSubscrpProd.Adjustment__c != 0) {
                        objNewSubscrpProd.Total_Discount__c += objNewSubscrpProd.Adjustment__c;     
                    }       
                    
                    if(objNewSubscrpProd.Total_Discount__c > 0) {
                        objNewSubscrpProd.Net_Unit_Price__c = objNewSubscrpProd.List_Price__c - (objNewSubscrpProd.List_Price__c * (objNewSubscrpProd.Total_Discount__c/100));
                    }         
                    objNewSubscrpProd.Ext_Net_Price__c = objNewSubscrpProd.Net_Unit_Price__c * objNewSubscrpProd.Quantity__c;
                    objNewSubscrpProd.Total_Price__c = objNewSubscrpProd.Ext_Net_Price__c;    
                }
                if(objNewSubscrpProd.Bundle__c != null) {
                    set_BundleSubscriptionProdIds.add(objNewSubscrpProd.Bundle__c);
                }                    
                if(objNewSubscrpProd.Is_Overage__c) {
                    objNewSubscrpProd.Hide_Record__c = true;
                }
                else if(objNewSubscrpProd.Ext_Net_Price__c != null) {
                    if(objNewSubscrpProd.Product__r.Include_in_CMMR_Total__c)
                        map_SubscripIdToTotalRecAmount.put(objNewSubscrpProd.Subscription__c, map_SubscripIdToTotalRecAmount.get(objNewSubscrpProd.Subscription__c) + objNewSubscrpProd.Ext_Net_Price__c);
                    else if(objNewSubscrpProd.Product__r.Product_Group__c == 'Recurring Services')
                        map_SubscripIdToTotalRecServAmount.put(objNewSubscrpProd.Subscription__c, map_SubscripIdToTotalRecServAmount.get(objNewSubscrpProd.Subscription__c) + objNewSubscrpProd.Ext_Net_Price__c);
                    //Added By Ranjith on Apr 9, 2019 -- Starts -- For Migration Credit
                    else if(objNewSubscrpProd.Product__r.New_Category__c == 'Credit') {  
                        map_SubscripIdToTotalNonCreditAmount.put(objNewSubscrpProd.Subscription__c, map_SubscripIdToTotalNonCreditAmount.get(objNewSubscrpProd.Subscription__c) + objNewSubscrpProd.Ext_Net_Price__c);
                    }
                    //else if(!Label.PureCloud_Credit_Products.contains(objNewSubscrpProd.Product__r.Name)) {
                    else {
                        //Added By Ranjith on Apr 9, 2019 -- Ends-- For Migration Credit
                        map_SubscripIdToTotalNonRecAmount.put(objNewSubscrpProd.Subscription__c, map_SubscripIdToTotalNonRecAmount.get(objNewSubscrpProd.Subscription__c) + objNewSubscrpProd.Ext_Net_Price__c);
                    }
                    
                    if(objSubscrpProd.Subscription__r.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC)
                    {
                        if(objNewSubscrpProd.Product__r.New_Category__c == 'Education') {
                            map_SubscripIdToTotalEducation.put(objNewSubscrpProd.Subscription__c, map_SubscripIdToTotalEducation.get(objNewSubscrpProd.Subscription__c) + objNewSubscrpProd.Ext_Net_Price__c);
                        }
                        else if(objNewSubscrpProd.Product__r.New_Category__c == 'Hardware') {
                            map_SubscripIdToTotalHardware.put(objNewSubscrpProd.Subscription__c, map_SubscripIdToTotalHardware.get(objNewSubscrpProd.Subscription__c) + objNewSubscrpProd.Ext_Net_Price__c);
                        }
                        else if(objNewSubscrpProd.Product__r.New_Category__c == 'Services' || objNewSubscrpProd.Product__r.New_Category__c == 'Voice Services') {
                            map_SubscripIdToTotalServices.put(objNewSubscrpProd.Subscription__c, map_SubscripIdToTotalServices.get(objNewSubscrpProd.Subscription__c) + objNewSubscrpProd.Ext_Net_Price__c);
                        }
                    }
                    if(objSubscrpProd.Subscription__r.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PCC)
                    {
                        if(objNewSubscrpProd.Product__r.Product_Group__c == 'Upfront Provisioning Fees') {
                            map_SubscripIdToTotalSetupProvisioningCharges.put(objNewSubscrpProd.Subscription__c, map_SubscripIdToTotalEducation.get(objNewSubscrpProd.Subscription__c) + objNewSubscrpProd.Ext_Net_Price__c);
                        }
                        else if(objNewSubscrpProd.Product__r.Product_Group__c == 'Upfront Hardware Costs') {
                            map_SubscripIdToTotalHardware.put(objNewSubscrpProd.Subscription__c, map_SubscripIdToTotalHardware.get(objNewSubscrpProd.Subscription__c) + objNewSubscrpProd.Ext_Net_Price__c);
                        }
                        else if(objNewSubscrpProd.Product__r.Product_Group__c == 'Upfront Education and Training Services') {
                            map_SubscripIdToTotalEducation.put(objNewSubscrpProd.Subscription__c, map_SubscripIdToTotalEducation.get(objNewSubscrpProd.Subscription__c) + objNewSubscrpProd.Ext_Net_Price__c);
                        }
                    }
                }                    
                list_ToInsertSubscrptionProds.add(objNewSubscrpProd);
                // }
            }
            insert list_ToInsertSubscrptionProds;            
            
            for(Subscription_Product__c objNewSubscrpProd : list_ToInsertSubscrptionProds) {
                if(set_BundleSubscriptionProdIds.contains(objNewSubscrpProd.Amendment_For__c)) {
                    map_BundleSubscrProdOldToNewIds.put(objNewSubscrpProd.Amendment_For__c, objNewSubscrpProd.Id);    
                }
                if(objNewSubscrpProd.Bundle__c != null) {
                    list_ToUpdateSubscrptionProds.add(objNewSubscrpProd);
                }
            }
            
            for(Subscription_Product__c objNewSubscrpProd : list_ToUpdateSubscrptionProds) {
                if(objNewSubscrpProd.Bundle__c != null && map_BundleSubscrProdOldToNewIds.containsKey(objNewSubscrpProd.Bundle__c)) {
                    objNewSubscrpProd.Bundle__c = map_BundleSubscrProdOldToNewIds.get(objNewSubscrpProd.Bundle__c);
                }
            }
            update list_ToUpdateSubscrptionProds;
            
            for(Subscription__c objNewSubscrp : list_ToInsertSubscrptions) {
                if(objNewSubscrp.Offering_Type__c == SubscriptionUtil.OFFERING_TYPE_PC)
                    set_SubscriptionIdsToPC.add(objNewSubscrp.Id);
                objNewSubscrp.Total_Education__c = map_SubscripIdToTotalEducation.get(objNewSubscrp.Id);
                objNewSubscrp.Total_Hardware__c = map_SubscripIdToTotalHardware.get(objNewSubscrp.Id);
                objNewSubscrp.Total_Services__c = map_SubscripIdToTotalServices.get(objNewSubscrp.Id);
                objNewSubscrp.Total_Non_Recurring_Fees__c = map_SubscripIdToTotalNonRecAmount.get(objNewSubscrp.Id);
                objNewSubscrp.TCV__c = map_SubscripIdToTotalRecAmount.get(objNewSubscrp.Id) + map_SubscripIdToTotalNonRecAmount.get(objNewSubscrp.Id) + map_SubscripIdToTotalRecServAmount.get(objNewSubscrp.Id) + map_SubscripIdToTotalNonCreditAmount.get(objNewSubscrp.Id);
            }
            
            /*for(Subscription__c objSubscrp : list_Subscriptions) {
                System.debug('InactiveSubs1');
                if(objSubscrp.Billing_Category__c == 'Annual M2M')
                {
                    System.debug('InactiveSubs2');
                objSubscrp.Status__c = 'Inactive';
                objSubscrp.Auto_Renewed__c = true;
                list_ToInsertSubscrptions.add(objSubscrp);
                //set_SubscriptionIdsToPC.add(objSubscrp.Id);
                    }
            } *///Changed for S-647874-Added by Dekshant for CCDB
            list_ToInsertSubscrptions.addAll(list_ChangeToInactiveSubscriptions);
            list_ToInsertSubscrptions.addAll(list_ChangeToCancelledSubscriptions);
			Map<Id,Subscription__C> map_SubIdtoSub = new map<Id,Subscription__c>();
            for(Subscription__C objSub:list_ToInsertSubscrptions){
                map_SubIdtoSub.put(objSub.Id,objSub);
            }
            Update   map_SubIdtoSub.values();   
			SubscriptionUtil.sendSubscriptionsToPC(set_SubscriptionIdsToPC);        
        }
          	
        catch(Exception e) {
            System.debug('Error has occurred:'+e.getMessage()+'\n'+ e.getStackTraceString());
		    ErrorLogUtil.insertLog('SubscriptionAutoRenewal', 'Error from method SubscriptionAutoRenewal: ' +  e.getMessage()+'\n'+e.getStackTraceString(), 'SubscriptionAutoRenewal.SubscriptionAutoRenewal()'); 
            String strmessage = 'Renewal of Subcriptions ending on ' + String.valueof(System.Today())+ ' has failed. The error message returned by the program is ' +  +e.getMessage()+'\n'+ e.getStackTraceString();
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { 'rony.joseph@genesys.com'};
                message.optOutPolicy = 'FILTER';
            message.subject = 'Failure during auto-renewal of CCDB';
            message.plainTextBody = strmessage;
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
          //  Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);    

                
                }        
    }
}