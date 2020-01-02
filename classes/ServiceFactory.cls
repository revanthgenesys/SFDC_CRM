@isTest
public class ServiceFactory {

    public static Service__c createInboundService()
    {
        return createService(
            'Inbound Wireline (US)',
            'Inbound Wireline (US)',
            11,
            1,
            3,
            2,
            2,
            0,
            1,
            'US',
            null,
            false
        );
    }

    public static Service__c createOutboundService(Boolean useCallingRates, String sureTaxTransTypeCode)
    {
        return createService(
            'Wireless Outbound (US)',
            'Wireless Outbound (US)',
            151,
            1,
            13,
            1,
            0,
            0,
            1,
            'US',
            sureTaxTransTypeCode,
            useCallingRates
        );
    }

    public static Service__c createOutboundRateTableService()
    {
        return createService(
            'Outbound Use Rate Table',
            'Outbound Use Rate Table',
            5100151,
            1,
            13,
            1,
            0,
            0,
            0,
            'X',
            null,
            false
        );
    }

    public static Service__c createPCVOutboundService(String regionCode, Boolean useCallingRates, String sureTaxTransTypeCode)
    {
        // U.S. Outbound Calling Interstate Service
        return createPCVService(
            'Wireless Outbound (US)',
            'Wireless Outbound (US)',
            151,
            regionCode,
            0,
            1,
            '0',
            '0',
            '1',
            '0',
            sureTaxTransTypeCode,
            useCallingRates
        );
    }

    public static Service__c createService(String name, String description, Integer uid, Integer channelType, Integer deviceType, Integer serviceType, Integer subCampaign, Integer serviceClass, Integer countryCode, String isoCode, String sureTaxTransTypeCode, Boolean useCallingRates)
    {
        return new Service__c(
            Name = name,
            Description__c = description,
            UID__c = uid,
            Channel_Type_Value__c = channelType,
            Device_Type_Value__c = deviceType,
            Service_Type_Value__c = serviceType,
            SubCampaign_Type_Value__c = subCampaign,
            Service_Class__c = serviceClass,
            Country_Code__c = countryCode,
            Country_Code_ISO__c = isoCode,
            Active__c = true,
            SureTax_Transaction_Type_Code__c = sureTaxTransTypeCode,
            Use_Calling_Rates__c = useCallingRates
        );
    }
    public static Service__c createPCVService(String name, String description, Integer uid, String regionCode, Integer activityType, Integer serviceType, String pcvGroup, String pcvZone, String pcvType, String pcvCategory, String sureTaxTransTypeCode, Boolean useCallingRates)
    {
        return new Service__c(
            Name = name,
            Description__c = description,
            UID__c = uid,
            Channel_Type_Value__c = 0,
            Device_Type_Value__c = 0,
            Service_Type_Value__c = serviceType,
            SubCampaign_Type_Value__c = 0,
            Service_Class__c = 0,
            Country_Code__c = 0,
            Country_Code_ISO__c = 'US',
            Active__c = true,
            Region_Code__c = regionCode,
            PCV_Activity_Type__c = activityType,
            PCV_Group__c = pcvGroup,
            PCV_Zone__c = pcvZone,
            PCV_Type__c = pcvType,
            PCV_Category__c = pcvCategory,
            SureTax_Transaction_Type_Code__c = sureTaxTransTypeCode,
            Use_Calling_Rates__c = useCallingRates,
            Note__c = 'PureVoice'
        );
    }
}