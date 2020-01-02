/*
 *  Contains functionality regarding PureCloud Monthly Minimums
 */
public class PureCloudMonthlyMinimum {

    public static Double getMonthlyMinimum(String currencyISOCode)
    {
        List<PureCloud_Monthly_Minimum__c> monthlyMinimum = new List<PureCloud_Monthly_Minimum__c>([SELECT Monthly_Minimum__c 
                                                                                                    FROM PureCloud_Monthly_Minimum__c 
                                                                                                    WHERE currencyISOCode = :currencyISOCode 
                                                                                                    LIMIT 1]);

        return monthlyMinimum.size() > 0 ? monthlyMinimum[0].Monthly_Minimum__c : 0;
    }

    public static Double getMonthlyMinimumForAccount(Id accountId, String currencyISOCode)
    {
        List<Account_PureCloud_Monthly_Minimum__c> monthlyMinimum = new List<Account_PureCloud_Monthly_Minimum__c>([SELECT Monthly_Minimum__c 
                                                                                                                    FROM Account_PureCloud_Monthly_Minimum__c 
                                                                                                                    WHERE currencyISOCode = :currencyISOCode
                                                                                                                    AND Account__c = :accountId 
                                                                                                                    LIMIT 1]);

        return monthlyMinimum.size() > 0 ? monthlyMinimum[0].Monthly_Minimum__c : 0;
    }
}