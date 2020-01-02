@isTest
public class RolledUpUsageDataFactory {

    public static Rolled_Up_Usage_Data__c createRolledUpUsageDataInboundUS()
    {
        return createRolledUpUsageData(
            'BEEEC',
            'Tenant123',
            'test-1',
            1,
            3,
            2,
            0,
            1,
            null,
            null,
            null,
            66,
            90,
            120,
            DateTime.now(),
            null
        );
    }

    public static Rolled_Up_Usage_Data__c createRolledUpUsageDataWirelessOutboundUS()
    {
        return createRolledUpUsageData(       
            'BEEEC',
            'Tenant123',
            'test-2',
            1,
            13,
            1,
            0,
            1,
            'US',
            null,
            null,
            126,
            150,
            180,
            DateTime.now(),
            null
        );
    }

    public static Rolled_Up_Usage_Data__c createRolledUpUsageDataOutboundWithTax(String platformId, String zipPostalCode)
    {
        return createPCVRolledUpUsageData(
            'PCL',
            platformId,
            'test-2',
            1,
            0,
            'US',
            'US',
            '0',
            '1',
            'USAGE#US#purchased#US#0.67500',
            12600, //REMOVE?
            15000, // REMOVE?
            18000, // REMOVE?
            DateTime.now(),
            zipPostalCode
        );
    }

    public static Rolled_Up_Usage_Data__c createRolledUpUsageData(String sourceName, String platformId, String rollupId, Integer channelType, Integer deviceType, Integer serviceType, Integer serviceClass, 
        Integer originCountryCode, String originISOCode, Integer destinationCountryCode, String regionCode, Integer billable6, Integer billable30, Integer billable60, DateTime startTime, String zipPostalCode)
    {
        return new Rolled_Up_Usage_Data__c(
            Source_Name__c = sourceName,
            Platform_Id__c = platformId,
            Rollup_Id__c = rollupId,
            Channel_Type__c = channelType,
            Device_Type__c = deviceType,
            Service_Type__c = serviceType,
            Service_Class__c = serviceClass,
            Origin_Country_Code__c = originCountryCode,
            Origin_Country_Code_ISO__c = originISOCode,
            Destination_Country_Code__c = destinationCountryCode,
            Billable_6__c = billable6,
            Billable_30__c = billable30,
            Billable_60__c = billable60,
            Start_Time__c = startTime
        );
    }

    public static Rolled_Up_Usage_Data__c createPCVRolledUpUsageData(String sourceName, String platformId, String rollupId, Integer serviceType, Integer activityType, 
       String regionCode, String pcvGroup, String pcvZone, String pcvType, String pcvCategory, Integer billable6, Integer billable30, Integer billable60, DateTime startTime, String zipPostalCode)
    {
        return new Rolled_Up_Usage_Data__c(
            Source_Name__c = sourceName,
            Platform_Id__c = platformId,
            Rollup_Id__c = rollupId,
            Channel_Type__c = 0,
            Device_Type__c = 0,
            Service_Type__c = serviceType,
            Activity_Type__c = activityType,
            Region_Code__c = regionCode,
            PCV_Group__c = pcvGroup,
            PCV_Zone__c = pcvZone,
            PCV_Type__c = pcvType,
            PCV_Category__c = pcvCategory,
            Service_Class__c = 0,
            Origin_Country_Code__c = 0,
            Origin_Country_Code_ISO__c = '',
            Destination_Country_Code__c = 0,
            Billable_6__c = billable6,
            Billable_30__c = billable30,
            Billable_60__c = billable60,
            Start_Time__c = startTime,
            ZIP_Postal_Code__c = zipPostalCode,
            Total_Duration__c = 450,
            Count__c = 400,
            Processed__c = false
        );
    }

    public static List<Rolled_Up_Usage_Data__c> reselectUsageData()
    {
        return [SELECT 
                    Source_Name__c
                    , Platform_Id__c
                    , Service_Type__c
                    , Channel_Type__c
                    , Service_Class__c
                    , Destination_Country_Code__c
                    , Origin_Country_Code__c
                    , Origin_Country_Code_ISO__c
                    , Billable_6__c
                    , Billable_30__c
                    , Billable_60__c
                    , Start_Time__c
                    , Service_Identifier__c
                FROM Rolled_Up_Usage_Data__c];
    }
}