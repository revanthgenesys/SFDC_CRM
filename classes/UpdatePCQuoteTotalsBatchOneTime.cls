global class UpdatePCQuoteTotalsBatchOneTime implements Database.Batchable<sObject> {
    
    public String strQuoteType = 'New Subscription';
    global UpdatePCQuoteTotalsBatchOneTime(String strQtType) {
        strQuoteType = strQtType;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
         String query = 'SELECT Id, zqu__InitialTerm__c, zqu__Opportunity__r.Indirect_Partner_PureCloud_Approved__c, '
                        + 'zqu__SubscriptionType__c, Annual_PrePay__c, zqu__Previewed_Discount__c, '
                        + 'zqu__SubscriptionTermStartDate__c, zqu__SubscriptionTermEndDate__c, '
                        + 'zqu__Account__c, zqu__Currency__c, zqu__Opportunity__r.BusinessPartner__c, '
                        + 'Multi_Year_Term_Length__c, zqu__Previewed_TCV__c, zqu__Previewed_MRR__c, '
                        + 'zqu__Previewed_Delta_TCV__c, zqu__Previewed_Delta_MRR__c, ACV__c, TCV__c, CMRR__c, '
                        + 'Hardware_Total__c, Education_Total__c, Services_Total__c, zqu__Opportunity__c, '
                        + 'PureCloud_Ramp_Up_Period__c, zqu__StartDate__c '
                        + 'FROM zqu__Quote__c '
                        + 'WHERE zqu__SubscriptionType__c = \'' + strQuoteType + '\' ' 
                        + (Test.isRunningTest() ? ('AND Id=\'' + Label.Quote_Id_For_Test_Class + '\' ') : '');
         if(Label.PureCloud_Totals_Batch_Query_Condition.length() > 2) {
             query += Label.PureCloud_Totals_Batch_Query_Condition;
         }
         return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<zqu__Quote__c> scope) {
        Map<Id, zqu__QuoteRatePlanCharge__c> map_qtRtPlnChrgs = new Map<Id, zqu__QuoteRatePlanCharge__c>();
           
        for(zqu__Quote__c zQuote : scope) {             
            Decimal TotalOneTime = 0;
            Decimal TotalOneTimeAll = 0;
            Decimal TotalRecurringHardware = 0;
            Decimal TotalNonRecurringHardware = 0;
            Decimal TotalRecurringEducation = 0;
            Decimal TotalNonRecurringEducation = 0;
            Decimal TotalSubscription = 0;
            Decimal TotalNonRecurringServices = 0;
            Decimal TotalRecurringServices = 0;
            Decimal TotalPCCredit = 0;
            
            map_qtRtPlnChrgs = new Map<Id, zqu__QuoteRatePlanCharge__c>(
                                [SELECT Id, zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Partner_Margin_Type__c,
                                        zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name,
                                        Product_Category__c, zqu__ProductRatePlanCharge__c, zqu__ChargeType__c,
                                        zqu__Period__c, Estimated_Discount__c, zqu__Discount__c, zqu__ListPrice__c,
                                        zqu__Quantity__c, EstimatedQty__c, Document_Category__c
                                 FROM zqu__QuoteRatePlanCharge__c
                                 WHERE zqu__QuoteRatePlan__r.zqu__Quote__c =: zQuote.Id]); 
            System.debug('######zQuote.Id '+zQuote.Id);                     
            
            Map<String, zqu__QuoteRatePlanCharge__c> uncategorizedCharges = new Map<String, zqu__QuoteRatePlanCharge__c>();      
            Map<String, List<zqu__QuoteRatePlanCharge__c>> map_NewCharges = new Map<String, List<zqu__QuoteRatePlanCharge__c>>();
            map_NewCharges.put('OneTime', new List<zqu__QuoteRatePlanCharge__c>());
            map_NewCharges.put('PCCredit', new List<zqu__QuoteRatePlanCharge__c>());
            map_NewCharges.put('RecurringHardware', new List<zqu__QuoteRatePlanCharge__c>());
            map_NewCharges.put('NonRecurringHardware', new List<zqu__QuoteRatePlanCharge__c>());
            map_NewCharges.put('RecurringEducation', new List<zqu__QuoteRatePlanCharge__c>());
            map_NewCharges.put('NonRecurringEducation', new List<zqu__QuoteRatePlanCharge__c>());
            map_NewCharges.put('NonRecurringService', new List<zqu__QuoteRatePlanCharge__c>());
            map_NewCharges.put('RecurringService', new List<zqu__QuoteRatePlanCharge__c>());
            map_NewCharges.put('Subscription', new List<zqu__QuoteRatePlanCharge__c>());  
            
            System.debug('######map_NewCharges'+map_NewCharges);
            System.debug('######uncategorizedCharges'+uncategorizedCharges);
            
            for(zqu__QuoteRatePlanCharge__c charge : map_qtRtPlnChrgs.values())
            {
                if(String.isBlank(charge.Product_Category__c) && String.isNotBlank(charge.zqu__ProductRatePlanCharge__c))
                {
                    uncategorizedCharges.put(charge.zqu__ProductRatePlanCharge__c, charge);
                    continue;
                }
                
                if(charge.Product_Category__c == 'Hardware')
                {
                    
                    if (charge.zqu__ChargeType__c == 'Recurring')
                    {
                        map_NewCharges.get('RecurringHardware').add(charge);
                    }
                    else if(charge.zqu__ChargeType__c != 'Usage')
                    {
                        map_NewCharges.get('OneTime').add(charge);
                        map_NewCharges.get('NonRecurringHardware').add(charge);
                    }
                }
                if(charge.Product_Category__c == 'Education')
                {
                    
                    if (charge.zqu__ChargeType__c == 'Recurring')
                    {
                        map_NewCharges.get('RecurringEducation').add(charge);
                    }
                    else if(charge.zqu__ChargeType__c != 'Usage')
                    {
                        map_NewCharges.get('OneTime').add(charge);
                        map_NewCharges.get('NonRecurringEducation').add(charge);
                    }
                }
                if(charge.Product_Category__c == 'Services')
                {    
                    if (charge.zqu__ChargeType__c == 'Recurring')
                    {
                        map_NewCharges.get('RecurringService').add(charge);
                    }
                    else 
                    {
                        map_NewCharges.get('NonRecurringService').add(charge);
                    }
                }
                
                if(charge.Product_Category__c == 'Licenses' && charge.zqu__ChargeType__c != 'Usage') // || (charge.Product_Category__c == 'Hardware' && charge.zqu__ChargeType__c == 'Usage'))
                {    
                    if(charge.zqu__ChargeType__c == 'One-Time')
                    {
                        if(map_qtRtPlnChrgs.containsKey(charge.Id) 
                           && Label.PureCloud_Credit_Products.contains(map_qtRtPlnChrgs.get(charge.Id).zqu__ProductRatePlanCharge__r.zqu__ProductRatePlan__r.zqu__Product__r.Name)) 
                        {
                            map_NewCharges.get('PCCredit').add(charge);
                        }
                        else
                        {
                            map_NewCharges.get('OneTime').add(charge);
                        }
                    }
                    else
                    {
                        map_NewCharges.get('Subscription').add(charge); 
                    }                
                }
            }System.debug('######uncategorizedCharges'+uncategorizedCharges);
            if(uncategorizedCharges.keySet().size() != 0)
            {
                for(zqu__ProductRatePlanCharge__c p : [SELECT Id, zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c FROM zqu__ProductRatePlanCharge__c WHERE Id IN: uncategorizedCharges.keySet()])
                {
                    zqu__QuoteRatePlanCharge__c charge = uncategorizedCharges.get(p.Id);
                    
                    if(p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Services')
                    {
                        map_NewCharges.get('Service').add(charge);
                    }
    
                    if(p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Licenses' ||
                        (p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Hardware' && charge.zqu__ChargeType__c == 'Usage'))
                    {
                        if(charge.zqu__ChargeType__c == 'One-Time')
                        {
                            map_NewCharges.get('OneTime').add(charge);
                        }
                        else
                        {
                            map_NewCharges.get('Subscription').add(charge); 
                        }
                    }
    
                    if(p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Hardware')
                    {
                        if(charge.zqu__ChargeType__c == 'Recurring')
                        {
                            map_NewCharges.get('RecurringHardware').add(charge);
                        }
                        else if(charge.zqu__ChargeType__c != 'Usage')
                        {
                            map_NewCharges.get('OneTime').add(charge);
                            map_NewCharges.get('NonRecurringHardware').add(charge);
                        }                
                    }
                    if(p.zqu__ProductRatePlan__r.zqu__Product__r.Product_Category__c == 'Education')
                    {
                        if(charge.zqu__ChargeType__c == 'Recurring')
                        {
                            map_NewCharges.get('RecurringEducation').add(charge);
                        }
                        else if(charge.zqu__ChargeType__c != 'Usage')
                        {
                            map_NewCharges.get('OneTime').add(charge);
                            map_NewCharges.get('NonRecurringEducation').add(charge);
                        }                
                    }
                }
            }  
            System.debug('######map_NewCharges'+map_NewCharges);
            TotalOneTime = CalculateTotalCost(map_NewCharges.get('OneTime'), zQuote);
            TotalRecurringHardware = CalculateTotalCost(map_NewCharges.get('RecurringHardware'), zQuote);
            TotalNonRecurringHardware = CalculateTotalCost(map_NewCharges.get('NonRecurringHardware'), zQuote);
            TotalRecurringEducation = CalculateTotalCost(map_NewCharges.get('RecurringEducation'), zQuote);
            TotalNonRecurringEducation = CalculateTotalCost(map_NewCharges.get('NonRecurringEducation'), zQuote);             
            TotalRecurringServices = CalculateTotalCost(map_NewCharges.get('RecurringService'), zQuote);
            TotalNonRecurringServices = CalculateTotalCost(map_NewCharges.get('NonRecurringService'), zQuote);
            TotalSubscription = CalculateTotalCost(map_NewCharges.get('Subscription'), zQuote);   
            TotalPCCredit = CalculateTotalCost(map_NewCharges.get('PCCredit'), zQuote);    
            
            System.debug('######'+TotalSubscription );
            if(zQuote.zqu__SubscriptionType__c == 'New Subscription') 
            {
                Decimal decTermYear = zQuote.zqu__InitialTerm__c != null && zQuote.zqu__InitialTerm__c != 0 ? zQuote.zqu__InitialTerm__c/12 : 1;
                zQuote.ACV__c = (TotalSubscription + (decTermYear != 0 ? TotalPCCredit/decTermYear : 0)).setscale(2);
                zQuote.CMRR__c = (zQuote.ACV__c/12).setscale(2);    
                zQuote.Hardware_Total__c = (TotalNonRecurringHardware + (TotalRecurringHardware*decTermYear)).setscale(2);  
                zQuote.Education_Total__c = (TotalNonRecurringEducation + (TotalRecurringEducation*decTermYear)).setscale(2);  
                zQuote.Services_Total__c = (TotalNonRecurringServices + (TotalRecurringServices*decTermYear)).setscale(2);
                zQuote.TCV__c = (TotalOneTime + (TotalSubscription*decTermYear) + TotalPCCredit + (TotalRecurringHardware*decTermYear) + (TotalRecurringEducation*decTermYear)).setscale(2);
            }
            else if(zQuote.zqu__SubscriptionType__c == 'Amend Subscription') 
            {
                Integer remainingTerm = 12;
                if(zQuote.zqu__SubscriptionTermStartDate__c == null) {
                    zQuote.zqu__SubscriptionTermStartDate__c = zQuote.zqu__StartDate__c + (zQuote.PureCloud_Ramp_Up_Period__c != null ? Integer.valueOf(zQuote.PureCloud_Ramp_Up_Period__c) : 0);
                }
                if(zQuote.zqu__SubscriptionTermEndDate__c == null) {
                    zQuote.zqu__SubscriptionTermEndDate__c = zQuote.zqu__SubscriptionTermStartDate__c + (zQuote.zqu__InitialTerm__c != null ? Integer.valueOf(zQuote.zqu__InitialTerm__c) : 12);
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
                zQuote.TCV__c = ((zQuote.CMRR__c*remainingTerm) + TotalOneTime + (TotalRecurringHardware*remainingTerm/12.0) + (TotalRecurringEducation*remainingTerm/12.0)).setscale(2);
            }
            try 
            {
                update zQuote;        
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            }
        }
    }
    global void finish(Database.BatchableContext BC) {

    }
    
    private Decimal calculateTotalCost(List<zqu__QuoteRatePlanCharge__c> chargeItems, zqu__Quote__c zQuote)
    {
        Decimal total = 0;
        for(zqu__QuoteRatePlanCharge__c q : chargeItems)
        {            
            Decimal chargeTotal = 0;
            //Integer period = ((zQuote.Annual_PrePay__c || zQuote.zqu__InitialTerm__c == 12) && q.zqu__Period__c == 'Month' && !q.zqu__ChargeType__c.equalsIgnoreCase('One-Time')) ? 12 : 1;
            Integer period = 1;
            if(q.Document_Category__c == 'Monthly Recurring Charges' && !q.zqu__ChargeType__c.equalsIgnoreCase('One-Time'))
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
            total += (chargeTotal * period);
        }
        return total;
    } 
}