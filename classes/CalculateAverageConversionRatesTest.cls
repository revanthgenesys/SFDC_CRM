@isTest
public class CalculateAverageConversionRatesTest {
    private static Map<String, Decimal> map_CurrencyCodesToConversionRate = new Map<String, Decimal>{
        'CAD' => 1.29,
        'AUD' => 1.30,
        'NZD' => 1.45,
        'EUR' => 0.86,
        'GBP' => 0.75,
        'BRL' => 3.27,
        'JPY' => 114.0,
        'ZAR' => 14.15
    };

    private static List<ERP_Currency_Daily_Exchange_Rate__c> dataSetupOneDate(Date dtDate, Decimal decDeviation) {
        List<String> list_CurrencyCodes = new List<String> {'CAD', 'AUD', 'NZD', 'EUR', 'GBP', 'BRL', 'JPY', 'ZAR'};

        List<ERP_Currency_Daily_Exchange_Rate__c> listDailyExchangeRates = new List<ERP_Currency_Daily_Exchange_Rate__c>();
        for (String strCurrencyCode : list_CurrencyCodes) {
            ERP_Currency_Daily_Exchange_Rate__c objDailyRate = new ERP_Currency_Daily_Exchange_Rate__c(
                Effective_Date__c = dtDate,
                EXCHANGE_RATE_TYPE__c = 'DAILY',
                FROM_CURRENCY_CODE__c = 'USD',
                TO_CURRENCY_CODE__c = strCurrencyCode,
                CONVERSION_RATE__c = map_CurrencyCodesToConversionRate.get(strCurrencyCode) + decDeviation
            );
            listDailyExchangeRates.add(objDailyRate);
        }
        return listDailyExchangeRates;
    }
    private static void dataSetup(Date dtDate, Integer intNumDays) {
        Date startDt = dtDate;
        List<ERP_Currency_Daily_Exchange_Rate__c> list_AllConversionRates = new List<ERP_Currency_Daily_Exchange_Rate__c>();
        for (Integer i = 0; i < intNumDays; i++) {
            List<ERP_Currency_Daily_Exchange_Rate__c> listConversionRatesDate = dataSetupOneDate(startDt, 0.0);
            list_AllConversionRates.addAll(listConversionRatesDate);
            startDt = startDt.addDays(1);
        }
        System.debug('Inserting rates'); for (ERP_Currency_Daily_Exchange_Rate__c objRate : list_AllConversionRates) System.Debug(objRate);
        insert list_AllConversionRates;
    }
    @isTest
    static void testCalculateAverageConversionRatesWithData() {
        Date dtDate = Date.newInstance(2016,1,1);
        Integer intDays = 31;
        dataSetup(dtDate, intDays);
        CalculateAverageConversionRates objCalculateAverageConversionRates = new CalculateAverageConversionRates();
        Date dtRateBuildDate = dtDate.addDays(intDays);
        System.debug('Calculating for dtRateBuildDate ' + dtRateBuildDate);
        objCalculateAverageConversionRates.buildConversionRates(dtRateBuildDate);
    }

    @isTest
    static void testCalculateAverageConversionRatesFebNonLeapYearDay28() {
        CalculateAverageConversionRates objCalculateAverageConversionRates = new CalculateAverageConversionRates();
        objCalculateAverageConversionRates.buildConversionRates(Date.newInstance(2017, 2, 28));
    }
    @isTest
    static void testCalculateAverageConversionRatesFebNonLeapYearDay27() {
        CalculateAverageConversionRates objCalculateAverageConversionRates = new CalculateAverageConversionRates();
        objCalculateAverageConversionRates.buildConversionRates(Date.newInstance(2017, 2, 27));
    }
    @isTest
    static void testCalculateAverageConversionRatesFebLeapYearDay27() {
        CalculateAverageConversionRates objCalculateAverageConversionRates = new CalculateAverageConversionRates();
        objCalculateAverageConversionRates.buildConversionRates(Date.newInstance(2016, 2, 27));
    }
    @isTest
    static void testCalculateAverageConversionRatesFebLeapYearDay28() {
        CalculateAverageConversionRates objCalculateAverageConversionRates = new CalculateAverageConversionRates();
        objCalculateAverageConversionRates.buildConversionRates(Date.newInstance(2016, 2, 28));
    }
    @isTest
    static void testCalculateAverageConversionRatesFebLeapYearDay29() {
        CalculateAverageConversionRates objCalculateAverageConversionRates = new CalculateAverageConversionRates();
        objCalculateAverageConversionRates.buildConversionRates(Date.newInstance(2016, 2, 29));
    }
    
    @isTest
    static void testCalculateAverageConversionRates30DayMonth29() {
        CalculateAverageConversionRates objCalculateAverageConversionRates = new CalculateAverageConversionRates();
        objCalculateAverageConversionRates.buildConversionRates(Date.newInstance(2017, 4, 29));
    }
    
    @isTest
    static void testCalculateAverageConversionRatesMarNotLeapYearDay29() {
        CalculateAverageConversionRates objCalculateAverageConversionRates = new CalculateAverageConversionRates();
        objCalculateAverageConversionRates.buildConversionRates(Date.newInstance(2017, 3, 29));
    }
    @isTest
    static void testCalculateAverageConversionRatesMarLeapYearDay28() {
        CalculateAverageConversionRates objCalculateAverageConversionRates = new CalculateAverageConversionRates();
        objCalculateAverageConversionRates.buildConversionRates(Date.newInstance(2016, 3, 28));
    }
    @isTest
    static void testCalculateAverageConversionRatesMarLeapYearDay29() {
        CalculateAverageConversionRates objCalculateAverageConversionRates = new CalculateAverageConversionRates();
        objCalculateAverageConversionRates.buildConversionRates(Date.newInstance(2016, 3, 29));
    }
    
    @isTest
    static void testCalculateAverageConversionRatesJanDay30() {
        CalculateAverageConversionRates objCalculateAverageConversionRates = new CalculateAverageConversionRates();
        objCalculateAverageConversionRates.buildConversionRates(Date.newInstance(2016, 1, 30));
    }
    
    @isTest
    static void testCalculateAverageConversionRatesMayDay30() {
        CalculateAverageConversionRates objCalculateAverageConversionRates = new CalculateAverageConversionRates();
        objCalculateAverageConversionRates.buildConversionRates(Date.newInstance(2016, 5, 30));
    }
}