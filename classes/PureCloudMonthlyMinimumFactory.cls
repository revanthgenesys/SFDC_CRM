@isTest
public class PureCloudMonthlyMinimumFactory {
    
    public static List<PureCloud_Monthly_Minimum__c> createPureCloudMonthlyMinimums()
    {
        List<PureCloud_Monthly_Minimum__c> monthlyMinimums = new List<PureCloud_Monthly_Minimum__c>();

        monthlyMinimums.add(new PureCloud_Monthly_Minimum__c(
            CurrencyISOCode = 'USD',
            Monthly_Minimum__c = 2000
        )); 
        
        monthlyMinimums.add(new PureCloud_Monthly_Minimum__c(
            CurrencyISOCode = 'CAD',
            Monthly_Minimum__c = 2200
        ));

        return monthlyMinimums;
    }
}