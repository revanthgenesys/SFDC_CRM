public class ZQuoteDiscountUtilities {
            
    // Start PCPQ-76                

    /*public static void CalculateQuantityAndTotals(Map<Id, zqu__Quote__c> newQuotes, Map<Id, zqu__Quote__c> oldQuotes)
    {
        system.debug(LoggingLevel.ERROR, 'ZQuoteDiscountUtilities.CalculateQuantityAndTotals');

        List<zqu__QuoteCharge__c> changedQuoteCharges = new List<zqu__QuoteCharge__c>();

        Set<Id> ids = new Set<Id>(newQuotes.keySet());
        List<zqu__QuoteCharge__c> allQuoteCharges = [SELECT Id, zqu__Quantity__c, zqu__Total__c, zqu__EffectivePrice__c, zqu__ChargeType__c, Product_Category__c, zqu__Quote__r.Annual_PrePay__c, zqu__PrepaymentPeriods__c FROM zqu__QuoteCharge__c WHERE zqu__Quote__c IN :newQuotes.keySet()];
        Map<Id, List<zqu__QuoteCharge__c>> allQuoteChargesByQuoteId = new Map<Id, List<zqu__QuoteCharge__c>>();
        List<zqu__QuoteCharge__c> chargeList;
        
        if ((allQuoteCharges != null) && (allQuoteCharges.size() > 0))
        {
            for (zqu__QuoteCharge__c quoteCharge : allQuoteCharges)
            {
                if (allQuoteChargesByQuoteId.containsKey(quoteCharge.zqu__Quote__c))
                {
                    chargeList = allQuoteChargesByQuoteId.get(quoteCharge.zqu__Quote__c);
                }
                else
                {
                    chargeList = new List<zqu__QuoteCharge__c>();
                }
                chargeList.add(quoteCharge);
                allQuoteChargesByQuoteId.put(quoteCharge.zqu__Quote__c, chargeList);
            }
            
            for (zqu__Quote__c quote : newQuotes.values())
            {
                zqu__Quote__c oldQuote = oldQuotes.get(quote.Id);
                
                if (quote.Annual_PrePay__c != oldQuote.Annual_PrePay__c)
                {
                    List<zqu__QuoteCharge__c> quoteCharges = allQuoteChargesByQuoteId.get(quote.Id);
                    system.debug(LoggingLevel.ERROR, 'ZQuoteDiscountUtilities.CalculateQuantityAndTotals quote Id: ' + quote.Id);
                    if ((quoteCharges != null) && (quoteCharges.size() > 0))
                    {
                        for (zqu__QuoteCharge__c toUpdate : quoteCharges)
                        {
                            CalculateQuantityAndTotal(toUpdate);
                            changedQuoteCharges.add(toUpdate);
                        }
                    }
                }
            }
        }
        
        if (changedQuoteCharges.size() > 0)
        {
            update changedQuoteCharges;
        }
    }
    // End PCPQ-76

    // Start PCPQ-76                
    public static void CalculateQuantityAndTotal(zqu__QuoteCharge__c toUpdate)
    {
        system.debug(LoggingLevel.ERROR, 'ZQuoteDiscountUtilities.CalculateQuantityAndTotal');
        
        if (toUpdate.zqu__Quantity__c != null)
        {
            toUpdate.zqu__Total__c = toUpdate.zqu__EffectivePrice__c * toUpdate.zqu__Quantity__c;
        } 
        else
        {
            toUpdate.zqu__Total__c = 0;
        }
        
        if (toUpdate.Product_Category__c == 'Licenses')
        {
            if (toUpdate.zqu__Quote__r.Annual_PrePay__c)
            {
                toUpdate.zqu__Total__c = toUpdate.zqu__Total__c * 12;  
            }
            else
            {
                toUpdate.zqu__Total__c = toUpdate.zqu__Total__c * 1;  
            }
        }
        else
        {
            if (toUpdate.zqu__Period__c != null)
            {
                if (toUpdate.zqu__Period__c == 'Annual')
                {
                    toUpdate.zqu__Total__c = toUpdate.zqu__Total__c * 12;  
                }
                else
                {
                    toUpdate.zqu__Total__c = toUpdate.zqu__Total__c * 1;  
                }
            }
        } 
        
    }*/
    // End PCPQ-76
    
    // JH Overload method for deprecation of Quote Charge Table
    public static void CalculateQuantityAndTotal(zqu__QuoteRatePlanCharge__c toUpdate)
    {
        system.debug(LoggingLevel.ERROR, 'ZQuoteDiscountUtilities.CalculateQuantityAndTotal');
        
        if (toUpdate.zqu__Quantity__c != null)
        {
            toUpdate.zqu__Total__c = toUpdate.zqu__EffectivePrice__c * toUpdate.zqu__Quantity__c;
        } 
        else
        {
            toUpdate.zqu__Total__c = 0;
        }
        
        if (toUpdate.Product_Category__c == 'Licenses')
        {
            if (toUpdate.Annual_PrePay__c)
            {
                toUpdate.zqu__Total__c = toUpdate.zqu__Total__c * 12;  
            }
            else
            {
                toUpdate.zqu__Total__c = toUpdate.zqu__Total__c * 1;  
            }
        }
        else
        {
            if (toUpdate.zqu__Period__c != null)
            {
                if (toUpdate.zqu__Period__c == 'Annual')
                {
                    toUpdate.zqu__Total__c = toUpdate.zqu__Total__c * 12;  
                }
                else
                {
                    toUpdate.zqu__Total__c = toUpdate.zqu__Total__c * 1;  
                }
            }
        } 
        
    }
}