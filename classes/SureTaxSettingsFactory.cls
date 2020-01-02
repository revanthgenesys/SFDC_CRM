@isTest
public class SureTaxSettingsFactory {
    
    public static List<SureTax_Settings__c> createDefaultSureTaxSettings()
    {
        List<SureTax_Settings__c> sureTaxSettings = new List<SureTax_Settings__c>();
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxClientNumber-PEC-8100', Value__c='000001190', Description__c='The client number in SureTax'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxClientNumber-PEC-8110', Value__c='000001194', Description__c='The client number in SureTax'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxClientTracking', Value__c='SF', Description__c='Field for client transaction tracking. This value will be provided in the response data.'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxEnabled', Value__c='True', Description__c='If set to True, tax will be automatically calculated during batch rating of cloud usage data.'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxEndpoint', Value__c='https://testapi.taxrating.net/Services/Communications/V01/SureTax.asmx', Description__c='The SureTax API endpoint'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxExemptionCodeList', Value__c='00', Description__c='Exception List. Place each exception separated by comma'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxNamespace', Value__c='http://tempuri.org/', Description__c='The SureTax API namespace'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxRegulatoryCode', Value__c='03', Description__c='The provider type, default VoIP'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxResponseGroup', Value__c='03', Description__c='Determines how taxes are grouped for the response'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxResponseType', Value__c='D2', Description__c='Determines the granularity of taxes and the decimal precision for the tax amounts in the response.'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxReturnFileCode', Value__c='0', Description__c='Determines how the tax information is saved in SureTax. 0 - post, Q - quote'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxSalesTypeCode', Value__c='B', Description__c='	R – Residential customer B – Business customer I – Industrial customer L – Lifeline customer'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxSitusRule', Value__c='05', Description__c='Determines how the revenue will situated for tax purposes.'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxTaxIncludedCode', Value__c='0', Description__c='Determines if tax is included in the revenue. 0 - No 1 - Yes'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxUnitType', Value__c='00', Description__c='SureTax code for number of unique access lines'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='SureTaxValidationKey-PEC-8100', Value__c='8A8D332C-33BE-43DE-98AB-B7B3ED714148', Description__c=''));

        sureTaxSettings.add(new SureTax_Settings__c(Name='106', Product_APN__c='100-TAX-SL911'));
        sureTaxSettings.add(new SureTax_Settings__c(Name='035', Product_APN__c='100-TAX-FUSFC'));

        sureTaxSettings.add(new SureTax_Settings__c(name = '100' , Value__c = 'Test Tax 1'));
        sureTaxSettings.add(new SureTax_Settings__c(name = '101' , Value__c = 'Test Tax 1'));
        sureTaxSettings.add(new SureTax_Settings__c(name = '102' , Value__c = 'Test Tax 1'));
        sureTaxSettings.add(new SureTax_Settings__c(name = '103' , Value__c = 'Test Tax 1'));
//        sureTaxSettings.add(new SureTax_Settings__c(name = 'Product' , Value__c = objProduct.id));
//        sureTaxSettings.add(new SureTax_Settings__c(name = 'Product' , Value__c = objProduct.id));

        return sureTaxSettings;
    }

}