// Test Class: QuoteProductsCurrencyFieldsUpdateTest
public class CurrencyConversionUtil {
	public static String corporateCurrencyISOCode = 'USD';
    public static List<DatedConversionRate> datedCurrencies = new List<DatedConversionRate>();
    public static Map<String, Decimal> currenciesMap = new Map<String, Decimal>();
    
    
    static{
        datedCurrencies = [SELECT Id, IsoCode, ConversionRate, nextStartDate, startDate from DatedConversionRate ORDER BY IsoCode, StartDate];
        for(CurrencyType ct : [SELECT IsoCode, ConversionRate, IsCorporate FROM CurrencyType WHERE IsActive = TRUE]){
            currenciesMap.put(ct.IsoCode, ct.ConversionRate);
            if(ct.IsCorporate){
                corporateCurrencyISOCode = ct.IsoCode;
            }
        }
    }
    /*
    public static decimal convertCurrency(Decimal amount, String sourceCurrencyISOCode , String targetCurrencyISOCode){
        Decimal returnAmount;
        // if Source and target CurrencyISOCode are same no conversion needed
        if(sourceCurrencyISOCode == targetCurrencyISOCode){
            returnAmount = amount != NULL ? amount : 0.0;                    
        } 
        else // if Source and target CurrencyISOCode are different
        {
            Decimal amountInCorpCurrency = 0.0;
            if(sourceCurrencyISOCode == corporateCurrencyISOCode){
                amountInCorpCurrency = amount != NULL ? amount : 0.0; 
            }else{
                Decimal conversionRate = currenciesMap.get(sourceCurrencyISOCode);
                amountInCorpCurrency = (amount != NULL ? amount : 0.0)/ conversionRate;
            } 
            returnAmount = amountInCorpCurrency * currenciesMap.get(targetCurrencyISOCode);                   
        }
        return returnAmount;
    }
    */
    
    public static decimal convertCurrencyToUSD(Decimal amount, String sourceCurrencyISOCode, Date conversionDate){
		Decimal returnAmount;
        if(sourceCurrencyISOCode == 'USD'){
            returnAmount = amount != NULL ? amount : 0.0;                    
        } else {
            Decimal conversionRate = 0.0;
            for(DatedConversionRate dtr: datedCurrencies){
                if(dtr.IsoCode == sourceCurrencyISOCode && conversionDate >= dtr.startDate && conversionDate < dtr.nextStartDate){
                    conversionRate = dtr.ConversionRate;   
                }
            }
            if(conversionRate == NULL || conversionRate <= 0){
             	conversionRate = 1;   
            }
            returnAmount = (amount != NULL ? amount : 0.0)/ conversionRate;
		}
        return returnAmount;
    }
    
    public static void updateQuoteProductsCurrencyFields(BigMachines__Quote_Product__c quoteProduct, Date currencyDate){
        	quoteProduct.New_Genesys_Care_Amount_USD__c = CurrencyConversionUtil.convertCurrencyToUSD(quoteProduct.Genesys_Care_Amount__c, 
                                                                                                      quoteProduct.CurrencyISOCode, 
                                                                                                      currencyDate);
            quoteProduct.New_Ext_Net_Price_USD__c = CurrencyConversionUtil.convertCurrencyToUSD(quoteProduct.Ext_Net_Price__c, 
                                                                                                      quoteProduct.CurrencyISOCode, 
                                                                                                      currencyDate);
            quoteProduct.New_Equivalent_Total_New_Price_USD__c = CurrencyConversionUtil.convertCurrencyToUSD(quoteProduct.Equivalent_Total_New_Price__c, 
                                                                                                      quoteProduct.CurrencyISOCode, 
                                                                                                      currencyDate);
            quoteProduct.New_Ext_List_Price_USD__c = CurrencyConversionUtil.convertCurrencyToUSD(quoteProduct.Ext_List__c, 
                                                                                                      quoteProduct.CurrencyISOCode, 
                                                                                                      currencyDate);
    }
}