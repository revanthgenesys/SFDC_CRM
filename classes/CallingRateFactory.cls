@isTest
public class CallingRateFactory {

    public static Calling_Rate__c createCallingRate()
    {
        return createCallingRate('US','1','default', 0.0400);
    }

    public static Calling_Rate__c createCallingRate(String regionCode, String destCountryCode, String destCareerDigits, Decimal ratePerMinute)
    {
        return new Calling_Rate__c(
                Region_Code__c = regionCode,
                Destination_Country_Code__c = destCountryCode,
                Destination_Career_Digits__c = destCareerDigits,
                Rate_Per_Minute__c = ratePerMinute,
                Effective_End_Date__c = Date.Today().addYears(1),
                Effective_Start_Date__c = Date.Today().addYears(-1),
                RecordTypeId = '0120B000000QwgfQAC'
        );
    }
}