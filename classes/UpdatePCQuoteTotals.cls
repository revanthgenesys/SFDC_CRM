public class UpdatePCQuoteTotals {
    
    static zqu__Quote__c zQuote = new zqu__Quote__c();
    
    static Decimal TotalOneTime = 0;
    static Decimal TotalOneTimeAll = 0;
    static Decimal TotalRecurringHardware = 0;
    static Decimal TotalNonRecurringHardware = 0;
    static Decimal TotalRecurringEducation = 0;
    static Decimal TotalNonRecurringEducation = 0;
    static Decimal TotalSubscription = 0;
    static Decimal TotalNonRecurringServices = 0;
    static Decimal TotalRecurringServices = 0;
    static Decimal TotalPCCredit = 0;
    static Map<Id, zqu__QuoteRatePlanCharge__c> map_qtRtPlnChrgs = new Map<Id, zqu__QuoteRatePlanCharge__c>();
    
    public static zqu__Quote__c updateZQuoteTotals(Id quoteId) {
        
        prepareData(quoteId);
        
        Decimal decTermYear = zQuote.zqu__InitialTerm__c != null && zQuote.zqu__InitialTerm__c != 0 ? zQuote.zqu__InitialTerm__c/12 : 1;
        zQuote.ACV__c = (TotalSubscription + (decTermYear != 0 ? TotalPCCredit/decTermYear : 0)).setscale(2);
        zQuote.CMRR__c = (zQuote.ACV__c/12).setscale(2);    
        zQuote.Hardware_Total__c = (TotalNonRecurringHardware + (TotalRecurringHardware*decTermYear)).setscale(2);  
        zQuote.Education_Total__c = (TotalNonRecurringEducation + (TotalRecurringEducation*decTermYear)).setscale(2);  
        zQuote.Services_Total__c = (TotalNonRecurringServices + (TotalRecurringServices*decTermYear)).setscale(2);
        zQuote.TCV__c = (TotalOneTime + zQuote.Services_Total__c + (TotalSubscription*decTermYear) + TotalPCCredit + (TotalRecurringHardware*decTermYear) + (TotalRecurringEducation*decTermYear)).setscale(2); 
        
        updateZQuote();
        return zQuote;
    }    
    
    @future(callout=true)
    public static void updateZQuoteAmendTotalsFuture(Id quoteId) {
        if(!Test.isRunningTest())
        {
            prepareData(quoteId);
        }
        else
        {
            zQuote.zqu__SubscriptionTermStartDate__c = system.today();
            zQuote.zqu__SubscriptionTermEndDate__c = system.today() + 30;
        }
        Integer remainingTerm = 12;        
        if(zQuote.zqu__SubscriptionTermStartDate__c == null) {
            zQuote.zqu__SubscriptionTermStartDate__c = zQuote.zqu__StartDate__c.addMonths(zQuote.PureCloud_Ramp_Up_Period__c != null ? Integer.valueOf(zQuote.PureCloud_Ramp_Up_Period__c) : 0);
        }
        if(zQuote.zqu__SubscriptionTermEndDate__c == null) {
            zQuote.zqu__SubscriptionTermEndDate__c = zQuote.zqu__SubscriptionTermStartDate__c.addMonths(zQuote.zqu__InitialTerm__c != null ? Integer.valueOf(zQuote.zqu__InitialTerm__c) : 12);
        }
        remainingTerm = zQuote.zqu__SubscriptionTermStartDate__c.monthsBetween(zQuote.zqu__SubscriptionTermEndDate__c);
        if(zQuote.zqu__SubscriptionTermStartDate__c < Date.today() && zQuote.zqu__SubscriptionTermEndDate__c > Date.today())
        {
            remainingTerm = System.today().monthsBetween(zQuote.zqu__SubscriptionTermEndDate__c);
        }
        Integer currentYearProration = remainingTerm == 12 ? 12 : Math.mod(remainingTerm, 12);        
        zQuote.CMRR__c = zQuote.zqu__Previewed_Delta_MRR__c;
        zQuote.ACV__c = zQuote.CMRR__c * currentYearProration;
        zQuote.Hardware_Total__c = (TotalNonRecurringHardware + (TotalRecurringHardware*remainingTerm/12.0)).setscale(2);  
        zQuote.Education_Total__c = (TotalNonRecurringEducation + (TotalRecurringEducation*remainingTerm/12.0)).setscale(2);  
        zQuote.Services_Total__c = (TotalNonRecurringServices + (TotalRecurringServices*remainingTerm/12.0)).setscale(2);
        zQuote.TCV__c = ((zQuote.CMRR__c*remainingTerm) + TotalOneTime + zQuote.Services_Total__c + (TotalRecurringHardware*remainingTerm/12.0) + (TotalRecurringEducation*remainingTerm/12.0)).setscale(2);
        
        updateZQuote();
        updateZQuoteOpportunity();        
    }
    
    private static void prepareData(Id quoteId) {
        zqu.GlobalCustomFieldDefinition.CHARGE_FIELDS = new Set<String>{'Product_Description__c',
                                                                    'Product_Category__c',
                                                                    'Partner_Price__c',
                                                                    'Document_Category__c',
                                                                    'Document_Subcategory__c'};
                                                                            
        zQuote = [SELECT Id, zqu__InitialTerm__c, zqu__Opportunity__r.Indirect_Partner_PureCloud_Approved__c,
                        zqu__SubscriptionType__c, Annual_PrePay__c, zqu__Previewed_Discount__c, 
                        zqu__SubscriptionTermStartDate__c, zqu__SubscriptionTermEndDate__c,
                        zqu__Account__c, zqu__Currency__c, zqu__Opportunity__r.BusinessPartner__c,
                        Multi_Year_Term_Length__c, zqu__Previewed_TCV__c, zqu__Previewed_MRR__c,
                        zqu__Previewed_Delta_TCV__c, zqu__Previewed_Delta_MRR__c, ACV__c, TCV__c, CMRR__c,
                        Hardware_Total__c, Education_Total__c, Services_Total__c, zqu__Opportunity__c,
                        PureCloud_Ramp_Up_Period__c, zqu__StartDate__c
                    FROM zqu__Quote__c
                    WHERE Id =: quoteId];
            
        List<zqu.zChargeGroup> zChargeGroups = new List<zqu.zChargeGroup>();
        List<zqu.zCharge> newCharges = new List<zqu.zCharge>();
        
        //Partner pricing
       /* if(zQuote.zqu__Opportunity__r.Indirect_Partner_PureCloud_Approved__c) {
            ZuoraQuoteUtility.updateChargePartnerPricing(zQuote.Id);
        }
            */
        map_qtRtPlnChrgs = new Map<Id, zqu__QuoteRatePlanCharge__c>(
                            [SELECT Id, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Partner_Margin_Type__c,
                                    zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name, Document_Category__c,
                                    Partner_Price__c
                             FROM zqu__QuoteRatePlanCharge__c
                             WHERE zqu__QuoteRatePlan__r.zqu__Quote__c =: zQuote.Id]); 
        System.debug('######zChargeGroups '+zChargeGroups );                     
        zChargeGroups = zqu.zQuoteUtil.getChargeGroups(zQuote.Id);  
        System.debug('######zChargeGroups '+zChargeGroups );
        for(zqu.zChargeGroup z : zChargeGroups)
        {
            if(z.groupType == zqu.zChargeGroup.TYPE_SUBSCRIPTION_ADDED 
                || z.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_NEWPRODUCT
                || z.groupType == zqu.zChargeGroup.TYPE_PRODUCT_NEW
                || z.groupType == zqu.zChargeGroup.TYPE_AMENDMENT_UPDATEPRODUCT
                || z.groupType == zqu.zChargeGroup.TYPE_RENEWAL_NEWPRODUCT
                || z.groupType == zqu.zChargeGroup.TYPE_RENEWAL_UPDATEPRODUCT
                || z.groupType == zqu.zChargeGroup.TYPE_RENEWAL_RENEWED )
            {
                newCharges.addAll(z.zCharges);                
            }
        }
        
        Map<String, zqu.zCharge> uncategorizedCharges = new Map<String, zqu.zCharge>();      
        Map<String, List<zqu.zCharge>> map_NewCharges = new Map<String, List<zqu.zCharge>>();
        map_NewCharges.put('OneTime', new List<zqu.zCharge>());
        map_NewCharges.put('PCCredit', new List<zqu.zCharge>());
        map_NewCharges.put('RecurringHardware', new List<zqu.zCharge>());
        map_NewCharges.put('NonRecurringHardware', new List<zqu.zCharge>());
        map_NewCharges.put('RecurringEducation', new List<zqu.zCharge>());
        map_NewCharges.put('NonRecurringEducation', new List<zqu.zCharge>());
        map_NewCharges.put('NonRecurringService', new List<zqu.zCharge>());
        map_NewCharges.put('RecurringService', new List<zqu.zCharge>());
        map_NewCharges.put('Subscription', new List<zqu.zCharge>());  
        
        System.debug('######map_NewCharges'+map_NewCharges);
        System.debug('######uncategorizedCharges'+uncategorizedCharges);
        for(zqu.zCharge zchar : newCharges)
        {
            zqu__QuoteRatePlanCharge__c charge = (zqu__QuoteRatePlanCharge__c)zchar.chargeObject;
            if(String.isBlank(charge.Product_Category__c) && String.isNotBlank(zchar.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID))
            {
                uncategorizedCharges.put(zchar.PRODUCT_RATE_PLAN_CHARGE_SFDC_ID, zchar);
                continue;
            }
            
            if(charge.Product_Category__c == 'Hardware')
            {
                
                if (charge.zqu__ChargeType__c == 'Recurring')
                {
                    map_NewCharges.get('RecurringHardware').add(zchar);
                }
                else if(charge.zqu__ChargeType__c != 'Usage')
                {
                    map_NewCharges.get('OneTime').add(zchar);
                    map_NewCharges.get('NonRecurringHardware').add(zchar);
                }
            }
            if(charge.Product_Category__c == 'Education')
            {
                
                if (charge.zqu__ChargeType__c == 'Recurring')
                {
                    map_NewCharges.get('RecurringEducation').add(zchar);
                }
                else if(charge.zqu__ChargeType__c != 'Usage')
                {
                    map_NewCharges.get('OneTime').add(zchar);
                    map_NewCharges.get('NonRecurringEducation').add(zchar);
                }
            }
            if(charge.Product_Category__c == 'Services')
            {    
                if (charge.zqu__ChargeType__c == 'Recurring')
                {
                    map_NewCharges.get('RecurringService').add(zchar);
                }
                else 
                {
                    map_NewCharges.get('NonRecurringService').add(zchar);
                }
            }
            
            if(charge.Product_Category__c == 'Licenses' && charge.zqu__ChargeType__c != 'Usage') // || (charge.Product_Category__c == 'Hardware' && charge.zqu__ChargeType__c == 'Usage'))
            {    
                if(charge.zqu__ChargeType__c == 'One-Time')
                {
                    if(map_qtRtPlnChrgs.containsKey(charge.Id) 
                       && Label.PureCloud_Credit_Products.contains(map_qtRtPlnChrgs.get(charge.Id).zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name)) 
                    {
                        map_NewCharges.get('PCCredit').add(zchar);
                    }
                    else
                    {
                        map_NewCharges.get('OneTime').add(zchar);
                    }
                }
                else
                {
                    map_NewCharges.get('Subscription').add(zchar); 
                }                
            }
        }System.debug('######uncategorizedCharges'+uncategorizedCharges);
        if(uncategorizedCharges.keySet().size() != 0)
        {
            for(zqu__ProductRatePlanCharge__c p : [SELECT Id, zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c FROM zqu__ProductRatePlanCharge__c WHERE Id IN: uncategorizedCharges.keySet()])
            {
                zqu.zCharge zchar = uncategorizedCharges.get(p.Id);
                zqu__QuoteRatePlanCharge__c charge = (zqu__QuoteRatePlanCharge__c)zchar.chargeObject;
            
                if(p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Services')
                {
                    //map_NewCharges.get('Service').add(zchar);
                    if (charge.zqu__ChargeType__c == 'Recurring')
                    {
                        map_NewCharges.get('RecurringService').add(zchar);
                    }
                    else 
                    {
                        map_NewCharges.get('NonRecurringService').add(zchar);
                    }
                }

                if(p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Licenses' ||
                    (p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Hardware' && charge.zqu__ChargeType__c == 'Usage'))
                {
                    if(charge.zqu__ChargeType__c == 'One-Time')
                    {
                        map_NewCharges.get('OneTime').add(zchar);
                    }
                    else
                    {
                        map_NewCharges.get('Subscription').add(zchar); 
                    }
                }

                if(p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Hardware')
                {
                    if(charge.zqu__ChargeType__c == 'Recurring')
                    {
                        map_NewCharges.get('RecurringHardware').add(zchar);
                    }
                    else if(charge.zqu__ChargeType__c != 'Usage')
                    {
                        map_NewCharges.get('OneTime').add(zchar);
                        map_NewCharges.get('NonRecurringHardware').add(zchar);
                    }                
                }
                if(p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Education')
                {
                    if(charge.zqu__ChargeType__c == 'Recurring')
                    {
                        map_NewCharges.get('RecurringEducation').add(zchar);
                    }
                    else if(charge.zqu__ChargeType__c != 'Usage')
                    {
                        map_NewCharges.get('OneTime').add(zchar);
                        map_NewCharges.get('NonRecurringEducation').add(zchar);
                    }                
                }
            }
        }            
        
        System.debug('######map_NewCharges'+map_NewCharges);
        TotalOneTime = calculateTotalCost(map_NewCharges.get('OneTime'), zQuote);
        TotalRecurringHardware = calculateTotalCost(map_NewCharges.get('RecurringHardware'), zQuote);
        TotalNonRecurringHardware = calculateTotalCost(map_NewCharges.get('NonRecurringHardware'), zQuote);
        TotalRecurringEducation = calculateTotalCost(map_NewCharges.get('RecurringEducation'), zQuote);
        TotalNonRecurringEducation = calculateTotalCost(map_NewCharges.get('NonRecurringEducation'), zQuote);             
        TotalRecurringServices = calculateTotalCost(map_NewCharges.get('RecurringService'), zQuote);
        TotalNonRecurringServices = calculateTotalCost(map_NewCharges.get('NonRecurringService'), zQuote);
        TotalSubscription = calculateTotalCost(map_NewCharges.get('Subscription'), zQuote);   
        TotalPCCredit = calculateTotalCost(map_NewCharges.get('PCCredit'), zQuote);  
        
        System.debug('######'+TotalNonRecurringHardware );
    }
    
    private static Decimal calculateTotalCost(List<zqu.zCharge> chargeItems, zqu__Quote__c zQuote)
    {
        Decimal total = 0;
        for(zqu.zCharge charge : chargeItems)
        {            
            Decimal chargeTotal = 0;
            zqu__QuoteRatePlanCharge__c q = (zqu__QuoteRatePlanCharge__c)charge.chargeObject;    
            zqu__QuoteRatePlanCharge__c objQtRtPlnChrg = new zqu__QuoteRatePlanCharge__c();    
            
            Integer period = 1;
            if(map_qtRtPlnChrgs.containsKey(q.Id))
            {
                objQtRtPlnChrg = map_qtRtPlnChrgs.get(q.Id);
            }
            if(objQtRtPlnChrg.Document_Category__c == 'Monthly Recurring Charges' 
               && !q.zqu__ChargeType__c.equalsIgnoreCase('One-Time'))
            {
                period = 12;
            }
            
            if (q.zqu__ListPrice__c != null && q.Estimated_Discount__c != null && q.EstimatedQty__c != null)
            {
                chargeTotal = (q.zqu__ListPrice__c * (1 - (q.Estimated_Discount__c / 100))) * q.EstimatedQty__c; 
            }
            else if (q.zqu__ListPrice__c != null && q.zqu__Discount__c != null && q.zqu__Quantity__c != null)
            {
                chargeTotal = (q.zqu__ListPrice__c * (1 - (q.zqu__Discount__c / 100))) * q.zqu__Quantity__c; 
            }
            //Partner pricing
            if(zQuote.zqu__Opportunity__r.Indirect_Partner_PureCloud_Approved__c
               && objQtRtPlnChrg.Partner_Price__c != null) 
            {
                chargeTotal = objQtRtPlnChrg.Partner_Price__c * q.zqu__Quantity__c;
            }            
            System.debug('#####'+objQtRtPlnChrg.Partner_Price__c);
            System.debug('#####'+q.zqu__Quantity__c);
            total += (chargeTotal * period);
            System.debug('#####'+total );
        }
        return total;
    } 
    private static void updateZQuote() {
        try 
        {
            if(!Test.isRunningTest()) 
            {
                update zQuote;   
            }     
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }    
    private static void updateZQuoteOpportunity() {
        try 
        {              
            Opportunity objToUpdateOppTotals = new Opportunity(Id = zQuote.zqu__Opportunity__c);     
            objToUpdateOppTotals.Monthly_Commitment__c = zQuote.CMRR__c;
            objToUpdateOppTotals.Annual_Contract_Value_new__c = zQuote.ACV__c;  
            objToUpdateOppTotals.ACV_Subscription_Only__c = zQuote.ACV__c;
            objToUpdateOppTotals.Total_Annual_Contract_Value__c = zQuote.TCV__c;
            objToUpdateOppTotals.Hardware_Total__c = zQuote.Hardware_Total__c;
            objToUpdateOppTotals.Education_Amount__c = zQuote.Education_Total__c;  
            objToUpdateOppTotals.Total_PS_Support__c = zQuote.Services_Total__c;
            update objToUpdateOppTotals;
        }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }
    }
}