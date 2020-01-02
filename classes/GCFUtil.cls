/*
 * Class            : GCFUtil
 * Description      : A Util class to for all generic functions used Genesys Care forecasting.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : May 19, 2017
 * Test Class       : GCFAllTests   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 public class GCFUtil {
    public static String corporateCurrencyISOCode = 'USD';
    public static Map<String, Decimal> currenciesMap = new Map<String, Decimal>();
    
    static{
        for(CurrencyType ct : [SELECT IsoCode, ConversionRate, IsCorporate FROM CurrencyType WHERE IsActive = TRUE]){
            currenciesMap.put(ct.IsoCode, ct.ConversionRate);
            if(ct.IsCorporate){
                corporateCurrencyISOCode = ct.IsoCode;
            }
        }
    }
    
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
    
     public static String getMonthName(Integer month){
        String monthName = '';
        if(month == 1){
            monthName = 'Jan';
        } else if(month == 2){
            monthName = 'Feb';
        } else if(month == 3){
            monthName = 'Mar';
        } else if(month == 4){
            monthName = 'Apr';
        } else if(month == 5){
            monthName = 'May';
        } else if(month == 6){
            monthName = 'Jun';
        } else if(month == 7){
            monthName = 'Jul';
        } else if(month == 8){
            monthName = 'Aug';
        } else if(month == 9){
            monthName = 'Sep';
        } else if(month == 10){
            monthName = 'Oct';
        } else if(month == 11){
            monthName = 'Nov';
        } else if(month == 12){
            monthName = 'Dec';
        } 
        return monthName;
    }
    
    public static integer getQuarter(integer month){
        Integer quarter = 0;
        if(month == 1 || month == 2 || month == 3)
            quarter = 1;
        else if(month == 4 || month == 5 || month == 6)
            quarter = 2;
        else if(month == 7 || month == 8 || month == 9)
            quarter = 3;
        else if(month == 10 || month == 11 || month == 12)
            quarter = 4;
        return quarter;
    }
    
    public static Date getQuarterStartDate(Integer month){
    	Date quarterStartDate;
    	if(month == 1 || month == 2 || month == 3)
            quarterStartDate = Date.newInstance(Date.Today().Year(), 1, 1);
        else if(month == 4 || month == 5 || month == 6)
            quarterStartDate = Date.newInstance(Date.Today().Year(), 4, 1);
        else if(month == 7 || month == 8 || month == 9)
            quarterStartDate = Date.newInstance(Date.Today().Year(), 7, 1);
        else if(month == 10 || month == 11 || month == 12)
            quarterStartDate = Date.newInstance(Date.Today().Year(), 10, 1);
        return quarterStartDate;    
    }
    
    public static String getQuarterStartDateString(Integer month){
    	String startDate;
    	if(month == 1 || month == 2 || month == 3)
        	startDate = Date.Today().Year() + '-01-01';
    	else if(month == 4 || month == 5 || month == 6)
        	startDate = Date.Today().Year() + '-04-01';
    	 else if(month == 7 || month == 8 || month == 9)
        	startDate = Date.Today().Year() + '-07-01';
    	else if(month == 10 || month == 11 || month == 12)
        	startDate = Date.Today().Year() + '-10-01';
    	return startDate;
    }
    
    public static boolean isNetSuiteReportDataImportNeeded(){
		boolean isImportNeeded = false;
    	if(NetSuite_Report_Data_Last_Imported__c.getInstance('LastImported') != NULL){
    		Date lastImportedDate = NetSuite_Report_Data_Last_Imported__c.getInstance('LastImported').Imported_Date__c;
    		GCF_NetSuite_Data__c netSuiteData = [SELECT CreatedDate FROM GCF_NetSuite_Data__c ORDER BY ID DESC LIMIT 1];
			Date maxDate = netSuiteData != NULL ? netSuiteData.CreatedDate.date() : Date.Today();
			if(maxDate > lastImportedDate){
				isImportNeeded = true;
			}
    	} else {
    		isImportNeeded = true;
    	}
    	return isImportNeeded;
    }
}