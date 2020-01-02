public class ZQuoteManagement {

    // Initializes several fields on the Quote before insert
    public static void beforeInsert(List<zqu__Quote__c> newQuoteList)
    {
        for (zqu__Quote__c quote : newQuoteList)
        {
            // For new subscriptions, set the purecloud monthly minimum
            if (quote.zqu__SubscriptionType__c == 'New Subscription')
            {
                Opportunity opportunity = [SELECT Offering_Detail__c FROM Opportunity WHERE Id = :quote.zqu__Opportunity__c LIMIT 1];
                if (String.IsBlank(opportunity.Offering_Detail__c) || opportunity.Offering_Detail__c != 'Pilot/Trial/POC')
                {
                    quote.PureCloud_Monthly_Minimum__c = PureCloudMonthlyMinimum.getMonthlyMinimumForAccount(quote.zqu__Account__c, quote.zqu__Currency__c);
                    ZQuoteManagement.setTermStartDate(quote);
                }
                else
                {
                    quote.PureCloud_Monthly_Minimum__c = 0;
                    quote.PureCloud_Ramp_Up_Period__c = 0;
                }
            }
        } 
    }

    public static void setTermStartDate(Map<Id, zqu__Quote__c> oldQuoteMap, List<zqu__Quote__c> newQuoteList)
    {
        for (zqu__Quote__c quote : newQuoteList)
        {
            zqu__Quote__c oldQuote = oldQuoteMap.get(quote.Id);
            // Automatically set the Term Start Date to the Start Date of the Quote plus the PureCloud Ramp Up Period
            if (quote.zqu__SubscriptionType__c == 'New Subscription')
            {

                if (oldQuote.zqu__StartDate__c != quote.zqu__StartDate__c
                ||  oldQuote.PureCloud_Ramp_Up_Period__c != quote.PureCloud_Ramp_Up_Period__c)
                {
                    ZQuoteManagement.setTermStartDate(quote);
                }
            }
        } 
    }

    public static void setTermStartDate(zqu__Quote__c quote)
    {
        quote.zqu__TermStartDate__c = quote.zqu__StartDate__c.addMonths(Integer.valueOf(quote.PureCloud_Ramp_Up_Period__c));
    }
}