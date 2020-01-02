public class CalculateAverageConversionRates {
    
    public Date dtForDate;
    public List<Billing_Conversion_Rate__c> list_AvgConversionRates = new List<Billing_Conversion_Rate__c>();
    
    public void buildConversionRates(Date dtRunningDate)
    { 
        //Find start and end date
        dtForDate = dtRunningDate;                       //Ex: 2017-09-20
        Date dtStartDate = getStartDate(dtForDate);      //Ex: 2017-08-21
        Date dtEndDate = dtForDate;                      //Ex: 2017-09-20
        
        System.debug('CalculateAverageConversionRates.buildConversionRates dtForDate is leap year ' +
                     Date.isLeapYear(dtForDate.year()) + ' dtForDate.day() = ' + dtForDate.day() +
                     ' dtStartDate ' + dtStartDate + ' dtEndDate ' + dtEndDate);
        list_AvgConversionRates = createAverageRecords(dtStartDate, dtEndDate);  
        
        //insert new avg conversion rates
        try
        {
            if(list_AvgConversionRates.size() > 0)
            {
                insert list_AvgConversionRates; 
                list_AvgConversionRates.clear();  
            }         
            if(dtForDate.month() == 2 && dtForDate.day() >= 27)
            {
                //Additional Jan 30 - Feb 28 or Jan 29 - Feb 27
                if((Date.isLeapYear(dtForDate.year()) && dtForDate.day() == 28) 
                    || !Date.isLeapYear(dtForDate.year()) && dtForDate.day() == 27) 
                {
                    //Additional Jan 30 - Feb 28 or Jan 29 - Feb 27
                    list_AvgConversionRates = createAverageRecords(dtStartDate + 1, dtEndDate);
                    if(list_AvgConversionRates.size() > 0)
                        insert list_AvgConversionRates; 
                    list_AvgConversionRates.clear();  
                    
                    //Additional Jan 31 - Feb 28 or Jan 30 - Feb 27 
                    list_AvgConversionRates = createAverageRecords(dtStartDate + 2, dtEndDate);
                    if(list_AvgConversionRates.size() > 0)
                        insert list_AvgConversionRates; 
                }
                list_AvgConversionRates.clear();  
                if(!Date.isLeapYear(dtForDate.year()) && dtForDate.day() == 27)
                {
                    //Additional Jan 31 - Feb 27
                    list_AvgConversionRates = createAverageRecords(dtStartDate + 3, dtEndDate);
                    if(list_AvgConversionRates.size() > 0)
                        insert list_AvgConversionRates; 
                }
            }
            //30th of Apr, Jun, Sep and Nov - additional records
            //Start Date  End Date    Running on  Invoice Date        
            //31-Mar-19   30-Apr-19   30-Apr-19   1-May-19 
            //31-May-19   30-Jun-19   30-Jun-19   1-Jul-19 
            //31-Aug-19   30-Sep-19   30-Sep-19   1-Oct-19 
            //31-Oct-19   30-Nov-19   30-Nov-19   1-Dec-19 
            else if(dtForDate.day() == 29
                    && (dtForDate.month() == 4 || dtForDate.month() == 6 || dtForDate.month() == 9 || dtForDate.month() == 11)) 
            {
                dtStartDate = Date.newInstance(dtForDate.year(), dtForDate.month()-1, 31);
                list_AvgConversionRates = createAverageRecords(dtStartDate, dtEndDate);
                if(list_AvgConversionRates.size() > 0)
                    insert list_AvgConversionRates; 
            }
        }
        catch(Exception e)
        {
            System.debug('Error Occurred:' + e.getMessage());
        }        
    }
    
    //*** Method to find start date for average conversion rates
    public static Date getStartDate(Date dtForDate) {
        Date dtStartDate;
        Integer intDaysInCurrentMonth = Date.daysInMonth(dtForDate.year(), dtForDate.month());
        
        //last day of the month
        //Start Date  End Date    Running on  Invoice Date
        //1-Jan-19    31-Jan-19   31-Jan-19   1-Feb-19
        //1-Feb-19    28-Feb-19   28-Feb-19   1-Mar-19
        //1-Feb-20    29-Feb-20   29-Feb-20   1-Mar-20
        //1-Mar-19    31-Mar-19   31-Mar-19   1-Apr-19
        //1-Apr-19    30-Apr-19   30-Apr-19   1-May-19
        //1-May-19    31-May-19   31-May-19   1-Jun-19
        if(dtForDate.day() == intDaysInCurrentMonth)
        {
            dtStartDate = Date.newInstance(dtForDate.year(), dtForDate.month(), 1); 
            System.debug('last day of month' + dtStartDate );
        }        
        /*
        //Feb
        //Start Date  End Date    Running on  Invoice Date    
        //29-Jan-19   27-Feb-19   27-Feb-19   28-Feb-19
        //30-Jan-19   27-Feb-19   27-Feb-19   28-Feb-19
        //31-Jan-19   27-Feb-19   27-Feb-19   28-Feb-19
        //Leap Year
        //30-Jan-20   28-Feb-20   28-Feb-20   29-Feb-20
        //31-Jan-20   28-Feb-20   28-Feb-20   29-Feb-20
        else if(dtForDate.month() == 2 && dtForDate.day() >= 27) 
        {
            if(!Date.isLeapYear(dtForDate.year()) && dtForDate.day() == 27) 
            {
                dtStartDate = Date.newInstance(dtForDate.year(), 1, 29);
            }
            else if(Date.isLeapYear(dtForDate.year()) && dtForDate.day() == 27)
            {
                dtStartDate = Date.newInstance(dtForDate.year(), 1, 28);
            }
            else if(Date.isLeapYear(dtForDate.year()) && dtForDate.day() == 28)
            {
                dtStartDate = Date.newInstance(dtForDate.year(), 1, 30);
            }
            System.debug('Feb month' + dtStartDate );
        }  
        */
        //March
        //Start Date  End Date    Running on  Invoice Date        
        //28-Feb-19   28-Mar-19   28-Mar-19   29-Mar-19
        //28-Feb-19   29-Mar-19   29-Mar-19   30-Mar-19
        //28-Feb-19   30-Mar-19   30-Mar-19   31-Mar-19
        //Leap year
        //29-Feb-20   29-Mar-20   29-Mar-20   30-Mar-20
        //29-Feb-20   30-Mar-20   30-Mar-20   31-Mar-20
        else if(dtForDate.month() == 3 && dtForDate.day() >= 28) 
        {
            if(!Date.isLeapYear(dtForDate.year()) && dtForDate.day() >= 28 && dtForDate.day() <= 30) 
            {
                dtStartDate = Date.newInstance(dtForDate.year(), 2, 28);
            }
            else if(Date.isLeapYear(dtForDate.year()) && dtForDate.day() == 28)
            {
                dtStartDate = Date.newInstance(dtForDate.year(), 2, 29);
            }
            else if(Date.isLeapYear(dtForDate.year()) && dtForDate.day() >= 29 && dtForDate.day() <= 30)
            {
                dtStartDate = Date.newInstance(dtForDate.year(), 2, 29);
            }
        }
        
        //Start Date  End Date    Running on  Invoice Date
        //2-Dec-18    1-Jan-19    1-Jan-19    2-Jan-19
        //2-Jan-19    1-Feb-19    1-Feb-19    2-Feb-19
        //2-Jan-20    1-Feb-20    1-Feb-20    2-Feb-20
        //2-Feb-19    1-Mar-19    1-Mar-19    2-Mar-19
        //2-Mar-19    1-Apr-19    1-Apr-19    2-Apr-19
        //28-Feb-19   27-Mar-19   27-Mar-19   28-Mar-19
        //29-Feb-20   28-Mar-20   28-Mar-20   29-Mar-20
        //30-Mar-19   29-Apr-19   29-Apr-19   30-Apr-19
        //30-Apr-19   29-May-19   29-May-19   30-May-19
        //30-May-19   29-Jun-19   29-Jun-19   30-Jun-19     
        //30-Dec-19   29-Jan-20   29-Jan-20   30-Jan-20         
        //31-Dec-19   30-Jan-20   30-Jan-20   31-Jan-19 
        //31-Jul-19   30-Aug-19   30-Aug-19   31-Aug-19
        else if((dtForDate.day() >= 1 && dtForDate.day() <= 29)
                || (dtForDate.day() == 30 &&  (dtForDate.month() == 1 || dtForDate.month() == 8))) //day 30 is only for Jan and Aug
        {
            dtStartDate = dtForDate.month() == 1 ? Date.newInstance(dtForDate.year()-1, 12, dtForDate.day() + 1) :
                                Date.newInstance(dtForDate.year(), dtForDate.month()-1, dtForDate.day() + 1);
           System.debug('1 to 29 ' + dtStartDate );
        }  
        
        //30th of May, Jul, Oct and Dec
        //Start Date  End Date    Running on  Invoice Date        
        //30-Apr-19   30-May-19   30-May-19   31-May-19 
        //30-Jun-19   30-Jul-19   30-Jul-19   31-Jul-19 
        //30-Sep-19   30-Oct-19   30-Oct-19   31-Oct-19 
        //30-Nov-19   30-Dec-19   30-Dec-19   31-Dec-19 
        else if(dtForDate.day() == 30
                && (dtForDate.month() == 5 || dtForDate.month() == 7 || dtForDate.month() == 10 || dtForDate.month() == 12)) 
        {
            dtStartDate = Date.newInstance(dtForDate.year(), dtForDate.month()-1, 30);
        }
        return dtStartDate;
    }
    
    //*** Method to query the rates and create average records
    private List<Billing_Conversion_Rate__c> createAverageRecords(Date dtStartDate, Date dtEndDate) {
        
        String strMessage = 'Success';
        String strBillingCurrenciesConsidered = Label.Cloud_Billing_Currencies_Considered;
        List<String> list_CurrencyCodes = strBillingCurrenciesConsidered.split(',');
        System.debug('Considering Currencies ' + list_CurrencyCodes);
        //new List<String> {'CAD', 'AUD', 'NZD', 'EUR', 'GBP', 'BRL', 'JPY', 'ZAR'};  
        Set<Date> set_DateExisting = new Set<Date>();

        Map<String, Decimal> map_CurrencyToSumOfRates = new Map<String, Decimal>();
        

        for(String strFromCurrCode : list_CurrencyCodes) {
	        for(String strToCurrCode : list_CurrencyCodes) {
                if (strFromCurrCode != strToCurrCode) {
                    String strFromToCurrCodeHash = strFromCurrCode + '#' + strToCurrCode;
	    	        map_CurrencyToSumOfRates.put(strFromToCurrCodeHash, 0.000000);
                }
            }
        }
        
        //Retrieve daily exchange rates
        List<ERP_Currency_Daily_Exchange_Rate__c> list_DailyExchgRates = [SELECT Id, FROM_CURRENCY_CODE__c,TO_CURRENCY_CODE__c,
                                                                          Effective_Date__c, CONVERSION_RATE__c
                                                                          FROM ERP_Currency_Daily_Exchange_Rate__c
                                                                          WHERE Effective_Date__c >= :dtStartDate 
                                                                            AND Effective_Date__c  <= :dtEndDate
                                                                            AND EXCHANGE_RATE_TYPE__c = 'DAILY'
                                                                            AND FROM_CURRENCY_CODE__c in :list_CurrencyCodes                                                                          AND FROM_CURRENCY_CODE__c in :list_CurrencyCodes
                                                                            AND TO_CURRENCY_CODE__c IN :list_CurrencyCodes];
        
        //Sum conversion rates under each currency code
        for(ERP_Currency_Daily_Exchange_Rate__c objExchgRate : list_DailyExchgRates){
            String strFromToCurrCodeHash = objExchgRate.FROM_CURRENCY_CODE__c + '#' + objExchgRate.TO_CURRENCY_CODE__c;


            if(map_CurrencyToSumOfRates.containsKey(strFromToCurrCodeHash)){
                map_CurrencyToSumOfRates.put(strFromToCurrCodeHash, 
                                             map_CurrencyToSumOfRates.get(strFromToCurrCodeHash) + objExchgRate.CONVERSION_RATE__c);
            }            
            set_DateExisting.add(objExchgRate.Effective_Date__c);
        }
        System.debug('#####NoOfDays'+set_DateExisting.size());
        System.debug('#####dtStartDate'+dtStartDate);
        System.debug('#####dtEndDate'+dtEndDate);
        System.debug('#####dtStartDate.daysBetween(dtEndDate)'+dtStartDate.daysBetween(dtEndDate));
        
        //Check if no of days are as expected
        Integer intNumberDaysExpected = dtStartDate.daysBetween(dtEndDate)+1;
        if(set_DateExisting.size() != intNumberDaysExpected)
        {
            strMessage = 'Missing daily date(s). Got ' + set_DateExisting.size() + ' expected ' + intNumberDaysExpected +
                ' from dtStartDate ' + dtStartDate + ' to dtEndDate ' + dtEndDate;
            System.debug(strMessage);
            //strMessage = 'Missing daily date(s) from ERP Currency Daily Exchange Rate object. Existing date(s) are '+set_DateExisting;
        }
        //Build new avg rates
        for(String strToFromCurrCode : map_CurrencyToSumOfRates.keySet()){
            List<String> listToFromCurrency = strToFromCurrCode.split('#');
            String strFromCurrency = listToFromCurrency[0];
            String strToCurrency = listToFromCurrency[1];
            Billing_Conversion_Rate__c objAvgConvRate = new Billing_Conversion_Rate__c();
            objAvgConvRate.From_Date__c = dtStartDate;
            objAvgConvRate.To_Date__c = dtEndDate;
            objAvgConvRate.CurrencyIsoCode = strFromCurrency;
            objAvgConvRate.To_Currency_Code__c = strToCurrency;
            if(set_DateExisting.size() > 0)
                objAvgConvRate.Average_Conversion_Rate__c = map_CurrencyToSumOfRates.get(strToFromCurrCode) / set_DateExisting.size();
            else
                objAvgConvRate.Average_Conversion_Rate__c = map_CurrencyToSumOfRates.get(strToFromCurrCode);
            objAvgConvRate.Status__c = strMessage;
            list_AvgConversionRates.add(objAvgConvRate);
        }         
        return list_AvgConversionRates;
    }
}