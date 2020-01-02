/*
 * Class            : GenesysCareForecastingUtil
 * Description      : A Utility Class that provides common functions for Genesys Care forecasting calculations.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Dec 19, 2016
 * Test Class       : GenesysCareForecastingUtilTest     
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Harish, 03/03/207 - updated generateForeCastByServiceContractIds to fix the Opportunity__c value on Genesys_Care_Forecasting__c.
 * Harish, 03/04/207 - updated generateForecastByQuoteIds, generateForeCastByServiceContractIds to include past months revenue in first month's forecasting record.
 * Harish, 03/07/207 - updated generateForeCastByServiceContractIds to default the days/months between start and end dates to 1 if <= 0.
 * Harish, 03/07/207 - rewrote generateForecastByQuoteIds, generateForeCastByServiceContractIds.
 * Harish, 03/22/207 - updated generateForeCastByServiceContractIds to consider term_duration from lines if null on header.
 */

public class GenesysCareForecastingUtil {

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
    
    /*
        While exploding Incremental Revenue Make Sure that 
        - End Date is into future compared to Current Date
        - if Start Date is in the past set explode Start Date as Today ...
        Harish: 03/08/2017 - replaced with new version below.
    */
    
    /*public static List<Genesys_Care_Forecasting__c> generateForecastByQuoteIds(List<String> quoteIds){
        Date cutOffDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        List<Genesys_Care_Forecasting__c> forecastingData = new List<Genesys_Care_Forecasting__c>();
        List<BigMachines__Quote_Product__c> quoteProducts = [SELECT Id, Original_Qty__c, Current_Qty__c, Contract_Line_Update_Status__c,
                                                             BigMachines__Quote__r.Sold_To_Name__c, BigMachines__Quote__r.Sold_To_Name__r.Name, 
                                                             BigMachines__Quote__r.Sold_To_Name__r.SAP_Account_Code__c, BigMachines__Quote__r.Sold_To_Name__r.Subsidary__r.Name,
                                                             BigMachines__Quote__r.Sold_To_Name__r.Region__c, BigMachines__Quote__r.Sold_To_Name__r.Sales_Region__c,
                                                             BigMachines__Quote__r.End_User_ID__c, BigMachines__Quote__r.End_User_ID__r.Name, 
                                                             BigMachines__Quote__r.End_User_ID__r.SAP_Account_Code__c, BigMachines__Quote__r.End_User_ID__r.Subsidary__r.Name,
                                                             BigMachines__Quote__r.End_User_ID__r.Region__c, BigMachines__Quote__r.End_User_ID__r.Sales_Region__c,   
                                                             Product__c, Product_Name__c, Product_Description__c, APN_Number__c, 
                                                             Maintenance_Start_Date__c, Maintenance_End_Date__c,
                                                             BigMachines__Quote__r.BigMachines__Opportunity__r.CurrencyIsoCode, BigMachines__Quote__r.PO__c,
                                                             BigMachines__Quote__r.Order__r.Order_Number__c, BigMachines__Quote__r.Name,
                                                             Annualized_Maintenance_Due__c,   BigMachines__Quote__c,
                                                             Region__c, Status__c , BigMachines__Quote__r.CurrencyIsoCode,
                                                             BigMachines__Quote__r.BigMachines__Opportunity__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Service_Contract__c
                                                             FROM BigMachines__Quote_Product__c 
                                                             WHERE BigMachines__Quote__c  IN : quoteIds
                                                             AND Annualized_Maintenance_Due__c != NULL 
                                                             AND Annualized_Maintenance_Due__c != 0
                                                             AND Maintenance_Start_Date__c != NULL 
                                                             AND Maintenance_End_Date__c != NULL
                                                             AND Maintenance_End_Date__c > TODAY
                                                             AND (NOT Product_Description__c like 'Custom App%') 
                                                             AND (NOT Product_Description__c like 'Custom Software%')
                                                             AND (NOT Product_Description__c like '%Care%')
                                                            ];

        for(BigMachines__Quote_Product__c quoteProduct : quoteProducts){
            Boolean processRecord = true;
            if((quoteProduct.Contract_Line_Update_Status__c == 'Drop' || quoteProduct.Contract_Line_Update_Status__c == 'Downsize' || quoteProduct.Contract_Line_Update_Status__c == 'Retired' || quoteProduct.Contract_Line_Update_Status__c == 'Shelved')
               && quoteProduct.Original_Qty__c == quoteProduct.Current_Qty__c)
                processRecord = false;
            
            Date startDate =  quoteProduct.Maintenance_Start_Date__c ;
            if(startDate < Date.today()){
                startDate = Date.today();
            }
            Date endDate = quoteProduct.Maintenance_End_Date__c;

            //Integer qp_termDuration_months = quoteProduct.Maintenance_Start_Date__c.monthsBetween(quoteProduct.Maintenance_End_Date__c)+1;
            //Integer qp_termDuration_Days = quoteProduct.Maintenance_Start_Date__c.daysBetween(quoteProduct.Maintenance_End_Date__c);

            Date mStartDate = quoteProduct.Maintenance_Start_Date__c;//startDate;
            Date mEndDate   = endDate;

            if(processRecord 
                && quoteProduct.Maintenance_Start_Date__c != NULL 
                && quoteProduct.Maintenance_End_Date__c != NULL 
                && quoteProduct.Annualized_Maintenance_Due__c != NULL 
                && startDate < endDate){
                //integer noOfRevenueMonths = quoteProduct.Maintenance_Start_Date__c.monthsBetween(quoteProduct.Maintenance_End_Date__c) + 1;
                Decimal monthlyRevenue = quoteProduct.Annualized_Maintenance_Due__c/ 12;//qp_termDuration_months;
                Decimal dailyRevenue = quoteProduct.Annualized_Maintenance_Due__c/ 365;//qp_termDuration_Days;
                
                Integer monthsCount = startDate.monthsBetween(endDate)+1;
                
                Date tempDate = startDate.addMonths(1).toStartOfMonth().addDays(-1); //Date.newInstance(startDate.year(), startDate.month(), 1);
                for(integer i = 0; i < monthsCount; i++){
                    Genesys_Care_Forecasting__c gcFCast = new Genesys_Care_Forecasting__c();
                    
                    Date postingDate = tempDate.addMonths(i);

                    // Sold To User Info
                    gcFCast.Sold_To__c = quoteProduct.BigMachines__Quote__r.Sold_To_Name__c;
                    gcFCast.Sold_To_Name__c = quoteProduct.BigMachines__Quote__r.Sold_To_Name__r.Name;
                    gcFCast.Sold_To_GARN_Code__c = quoteProduct.BigMachines__Quote__r.Sold_To_Name__r.SAP_Account_Code__c;
                    gcFCast.Sold_To_Subsidary_Code__c = quoteProduct.BigMachines__Quote__r.Sold_To_Name__r.Subsidary__r.Name;
                    
                    // End User Info
                    gcFCast.End_User__c = quoteProduct.BigMachines__Quote__r.End_User_ID__c;
                    gcFCast.End_User_Name__c = quoteProduct.BigMachines__Quote__r.End_User_ID__r.Name;
                    gcFCast.End_User_GARN_Code__c = quoteProduct.BigMachines__Quote__r.End_User_ID__r.SAP_Account_Code__c;
                    gcFCast.End_User_Subsidary_Code__c = quoteProduct.BigMachines__Quote__r.End_User_ID__r.Subsidary__r.Name;
                    
                    //Region Info
                    gcFCast.Region__c = (quoteProduct.BigMachines__Quote__r.Sold_To_Name__r.Region__c == 'LATAM' ? 'Latin America' : quoteProduct.BigMachines__Quote__r.Sold_To_Name__r.Region__c);
                    gcFCast.Sub_Region__c = quoteProduct.BigMachines__Quote__r.Sold_To_Name__r.Sales_Region__c;
                    
                    //Item Info
                    // gcFCast.Item_Name__c = quoteProduct.Product_Name__c;
                    gcFCast.Item_Name__c = quoteProduct.APN_Number__c;
                    gcFCast.APN_Number__c = quoteProduct.APN_Number__c;
                    gcFCast.Item_Description__c = quoteProduct.Product_Description__c;
                    
                    // Maintenance Dates Info
                    gcFCast.Maintenance_Start_Date__c = mStartDate;
                    gcFCast.Maintenance_End_Date__c = mEndDate;
                    
                    // Revenue Posting Info
                    gcFCast.Posting_Date__c = postingDate;//tempDate.addMonths(i);
                    if(i == 0){
                        // Update: Harish, 03/04/2017 - Include past months to first month of Incremental revenue.
                        //Integer startDay =  quoteProduct.Maintenance_Start_Date__c.day() ;
                        // Integer DaysInMonth = Date.daysInMonth(startDate.year(), startDate.month());
                        // gcFCast.Posting_Amount__c = dailyRevenue * (DaysInMonth - startDay + 1);
                        // If end date is greater than or equal to posting date then take days between maintenance start date and posting date.
                        // else If end date is less than posting date then take days between maintenance start date and end date.
                        Date firstDate = endDate >= postingDate ? postingDate : endDate;  
                        Integer noOfDaysFromMStoPostingDate = quoteProduct.Maintenance_Start_Date__c.daysBetween(firstDate);
                        gcFCast.Posting_Amount__c = dailyRevenue * noOfDaysFromMStoPostingDate;
                    } else if (i == (monthsCount-1)){
                        Integer endDay =  endDate.day() ;
                        gcFCast.Posting_Amount__c = dailyRevenue * endDay; 
                    } else {
                        gcFCast.Posting_Amount__c = monthlyRevenue;
                    }                    
                    
                    gcFCast.Posting_Amount_USD__c = GenesysCareForecastingUtil.convertCurrency(gcFCast.Posting_Amount__c, quoteProduct.BigMachines__Quote__r.CurrencyIsoCode, 'USD');
                    gcFCast.Posting_Amount_EUR__c = GenesysCareForecastingUtil.convertCurrency(gcFCast.Posting_Amount__c, quoteProduct.BigMachines__Quote__r.CurrencyIsoCode, 'EUR');                    
                    gcFCast.CurrencyIsoCode = quoteProduct.BigMachines__Quote__r.CurrencyIsoCode;
                    
                    // Additional Details
                    gcFCast.Revenue_Type__c = 'Incremental Revenue';
                    gcFCast.PO_Number__c = quoteProduct.BigMachines__Quote__r.PO__c;
                    //gcFCast.Order_Number__c = quoteProduct.BigMachines__Quote__r.Order__r.Order_Number__c;
                    gcFCast.Quote_Number__c = quoteProduct.BigMachines__Quote__r.Name;
                    gcFCast.Opportunity__c = quoteProduct.BigMachines__Quote__r.BigMachines__Opportunity__c;
                    gcFCast.Service_Contract__c = quoteProduct.BigMachines__Quote__r.BigMachines__Opportunity__r.Service_Contract__c;
                    
                    gcFCast.Posting_Year__c = gcFCast.Posting_Date__c.year();
                    gcFCast.Posting_Month__c = gcFCast.Posting_Date__c.month();
                    
                    // Add Each Monthly records in this below list.
                    if(gcFCast.Posting_Date__c >= cutOffDate){
                        forecastingData.add(gcFCast);
                    }
                }
            }
        }
        return forecastingData;
    }*/
    
    /*
        Harish, 03/08/2017.
        Incremental Revenue 
            - End Date must be in future.
            - If maintenance start date is in the past then consider today as start.
            - include prior months revenue in current month - applicable only if maintenance start date was in the past.
            - create forecasting monthly at quote level but not product level.
        Assumption: maintenance end date on lines will always match with parent quote.
     */
    public static List<Genesys_Care_Forecasting__c> generateForecastByQuoteIds(List<String> quoteIds){
        Date cutOffDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        Map<String, Genesys_Care_Forecasting__c> qIdpluspDatetoForecastingSOMap = new Map<String, Genesys_Care_Forecasting__c>();
        List<BigMachines__Quote_Product__c> quoteProducts = [SELECT Id, Original_Qty__c, Current_Qty__c, Contract_Line_Update_Status__c,
                                                             BigMachines__Quote__r.Sold_To_Name__c, BigMachines__Quote__r.Sold_To_Name__r.Name, 
                                                             BigMachines__Quote__r.Sold_To_Name__r.SAP_Account_Code__c, BigMachines__Quote__r.Sold_To_Name__r.Subsidary__r.Name,
                                                             BigMachines__Quote__r.Sold_To_Name__r.Region__c, BigMachines__Quote__r.Sold_To_Name__r.Sales_Region__c,
                                                             BigMachines__Quote__r.End_User_ID__c, BigMachines__Quote__r.End_User_ID__r.Name, 
                                                             BigMachines__Quote__r.End_User_ID__r.SAP_Account_Code__c, BigMachines__Quote__r.End_User_ID__r.Subsidary__r.Name,
                                                             BigMachines__Quote__r.End_User_ID__r.Region__c, BigMachines__Quote__r.End_User_ID__r.Sales_Region__c,   
                                                             Product__c, Product_Name__c, Product_Description__c, APN_Number__c, 
                                                             Maintenance_Start_Date__c, Maintenance_End_Date__c,
                                                             BigMachines__Quote__r.Maintenance_Start_Date__c, BigMachines__Quote__r.Maintenance_End_Date__c,
                                                             BigMachines__Quote__r.BigMachines__Opportunity__r.CurrencyIsoCode, BigMachines__Quote__r.PO__c,
                                                             BigMachines__Quote__r.Order__r.Order_Number__c, BigMachines__Quote__r.Name,
                                                             Annualized_Maintenance_Due__c,   BigMachines__Quote__c,
                                                             Region__c, Status__c , BigMachines__Quote__r.CurrencyIsoCode,
                                                             BigMachines__Quote__r.BigMachines__Opportunity__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Service_Contract__c
                                                                 FROM BigMachines__Quote_Product__c 
                                                                 WHERE   BigMachines__Quote__c  IN : quoteIds
                                                                         AND Annualized_Maintenance_Due__c != NULL 
                                                                         AND Annualized_Maintenance_Due__c != 0
                                                                         AND Maintenance_Start_Date__c != NULL 
                                                                         AND Maintenance_End_Date__c != NULL
                                                                         AND Maintenance_End_Date__c > TODAY
                                                                         AND (NOT Product_Description__c like 'Custom App%') 
                                                                         AND (NOT Product_Description__c like 'Custom Software%')
                                                                         AND (NOT Product_Description__c like '%Care%')
                                                                            order by BigMachines__Quote__c];

        for(BigMachines__Quote_Product__c quoteProduct : quoteProducts){
            Boolean processRecord = true;
            if((quoteProduct.Contract_Line_Update_Status__c == 'Drop' 
                || quoteProduct.Contract_Line_Update_Status__c == 'Downsize' 
                || quoteProduct.Contract_Line_Update_Status__c == 'Retired' 
                || quoteProduct.Contract_Line_Update_Status__c == 'Shelved')
               && quoteProduct.Original_Qty__c == quoteProduct.Current_Qty__c)
                processRecord = false;
            
            // bring the startDate to today if maintenance start date is in the past.
            Date startDate =  quoteProduct.Maintenance_Start_Date__c ;
            if(startDate < Date.today()){
                startDate = Date.today();
            }
            Date endDate = quoteProduct.Maintenance_End_Date__c;

            //Integer qp_termDuration_months = quoteProduct.Maintenance_Start_Date__c.monthsBetween(quoteProduct.Maintenance_End_Date__c)+1;
            //Integer qp_termDuration_Days = quoteProduct.Maintenance_Start_Date__c.daysBetween(quoteProduct.Maintenance_End_Date__c);

            Date mStartDate = quoteProduct.Maintenance_Start_Date__c;//startDate;
            Date mEndDate   = endDate;

            if(processRecord == true
                && quoteProduct.Maintenance_Start_Date__c != NULL 
                && quoteProduct.Maintenance_End_Date__c != NULL 
                && quoteProduct.Annualized_Maintenance_Due__c != NULL 
                && startDate < endDate){
                
                //integer noOfRevenueMonths = quoteProduct.Maintenance_Start_Date__c.monthsBetween(quoteProduct.Maintenance_End_Date__c) + 1;
                Decimal monthlyRevenue = quoteProduct.Annualized_Maintenance_Due__c/ 12;//qp_termDuration_months;
                Decimal dailyRevenue = quoteProduct.Annualized_Maintenance_Due__c/ 365;//qp_termDuration_Days;
                
                Integer monthsCount = startDate.monthsBetween(endDate)+1;
                
                Date tempDate = startDate.addMonths(1).toStartOfMonth().addDays(-1); //Date.newInstance(startDate.year(), startDate.month(), 1);
                for(integer i = 0; i < monthsCount; i++){
                    Date postingDate = tempDate.addMonths(i);
                    
                    //Genesys_Care_Forecasting__c gcFCast = new Genesys_Care_Forecasting__c();
                    
                    // Only one forecasting record will be created for month so see if forecasting for posting period exists or not.
                    Genesys_Care_Forecasting__c gcFCast =  new Genesys_Care_Forecasting__c();
                    String qIdpluspDate = quoteProduct.BigMachines__Quote__c+''+String.valueOf(postingDate);
                    if(qIdpluspDatetoForecastingSOMap.containsKey(qIdpluspDate)){// if already exists then posting amount will be added.
                        gcFCast = qIdpluspDatetoForecastingSOMap.get(qIdpluspDate);

                        // populate with min start date and max end date.
                        if(gcFCast.Maintenance_Start_Date__c > mStartDate)
                            gcFCast.Maintenance_Start_Date__c = mStartDate;
                        if(gcFCast.Maintenance_End_Date__c < mEndDate)
                            gcFCast.Maintenance_End_Date__c = mEndDate;
                    }else{
                        // Sold To User Info
                        gcFCast.Sold_To__c = quoteProduct.BigMachines__Quote__r.Sold_To_Name__c;
                        gcFCast.Sold_To_Name__c = quoteProduct.BigMachines__Quote__r.Sold_To_Name__r.Name;
                        gcFCast.Sold_To_GARN_Code__c = quoteProduct.BigMachines__Quote__r.Sold_To_Name__r.SAP_Account_Code__c;
                        gcFCast.Sold_To_Subsidary_Code__c = quoteProduct.BigMachines__Quote__r.Sold_To_Name__r.Subsidary__r.Name;
                        
                        // End User Info
                        gcFCast.End_User__c = quoteProduct.BigMachines__Quote__r.End_User_ID__c;
                        gcFCast.End_User_Name__c = quoteProduct.BigMachines__Quote__r.End_User_ID__r.Name;
                        gcFCast.End_User_GARN_Code__c = quoteProduct.BigMachines__Quote__r.End_User_ID__r.SAP_Account_Code__c;
                        gcFCast.End_User_Subsidary_Code__c = quoteProduct.BigMachines__Quote__r.End_User_ID__r.Subsidary__r.Name;
                        
                        //Region Info
                        gcFCast.Region__c = (quoteProduct.BigMachines__Quote__r.Sold_To_Name__r.Region__c == 'LATAM' ? 'Latin America' : quoteProduct.BigMachines__Quote__r.Sold_To_Name__r.Region__c);
                        gcFCast.Sub_Region__c = quoteProduct.BigMachines__Quote__r.Sold_To_Name__r.Sales_Region__c;

                        // Additional Details
                        gcFCast.Revenue_Type__c = 'Incremental Revenue';
                        gcFCast.PO_Number__c = quoteProduct.BigMachines__Quote__r.PO__c;
                        //gcFCast.Order_Number__c = quoteProduct.BigMachines__Quote__r.Order__r.Order_Number__c;
                        gcFCast.Quote_Number__c = quoteProduct.BigMachines__Quote__r.Name;
                        gcFCast.Quote__c = quoteProduct.BigMachines__Quote__c;
                        gcFCast.Opportunity__c = quoteProduct.BigMachines__Quote__r.BigMachines__Opportunity__c;
                        gcFCast.Service_Contract__c = quoteProduct.BigMachines__Quote__r.BigMachines__Opportunity__r.Service_Contract__c;
                        gcFCast.HeaderMaintenanceStartDate__c = quoteProduct.BigMachines__Quote__r.Maintenance_Start_Date__c;
                        gcFCast.HeaderMaintenanceEndDate__c = quoteProduct.BigMachines__Quote__r.Maintenance_End_Date__c;
                        
                        // Revenue Posting Info
                        gcFCast.Posting_Date__c = postingDate;//tempDate.addMonths(i);
                        gcFCast.Posting_Year__c = gcFCast.Posting_Date__c.year();
                        gcFCast.Posting_Month__c = gcFCast.Posting_Date__c.month();
                        
                        // Amount related
                        gcFCast.CurrencyIsoCode = quoteProduct.BigMachines__Quote__r.CurrencyIsoCode;
                        gcFCast.Posting_Amount__c = 0;// set to ZERO, calculated value will be added below.
                        gcFCast.Posting_Amount_USD__c = 0;// set to ZERO, calculated value will be added below.
                        gcFCast.Posting_Amount_EUR__c = 0;// set to ZERO, calculated value will be added below.
                        
                        gcFCast.Maintenance_Start_Date__c = mStartDate;
                        gcFCast.Maintenance_End_Date__c = mEndDate;
                    }
                    
                    //Item Info
                    // gcFCast.Item_Name__c = quoteProduct.Product_Name__c;
                    //gcFCast.Item_Name__c = quoteProduct.APN_Number__c;
                    //gcFCast.APN_Number__c = quoteProduct.APN_Number__c;
                    //gcFCast.Item_Description__c = quoteProduct.Product_Description__c;
                    
                    // Maintenance Dates Info
                    //gcFCast.Maintenance_Start_Date__c = mStartDate;
                    //gcFCast.Maintenance_End_Date__c = mEndDate;
                    
                    Decimal postingAmount = 0;
                    if(i == 0){// If first month.
                        // Include past months to first month of Incremental revenue.
                        // If end date is greater than or equal to posting date then take days between maintenance start date and posting date.
                        // else If end date is less than posting date then take days between maintenance start date and end date.
                        Date firstDate = endDate >= postingDate ? postingDate : endDate;  
                        Integer noOfDaysFromMStoPostingDate = quoteProduct.Maintenance_Start_Date__c.daysBetween(firstDate);
                        postingAmount = dailyRevenue * noOfDaysFromMStoPostingDate;
                    } else if (i == (monthsCount-1)){// if last month.
                        Integer endDay =  endDate.day() ;
                        postingAmount = dailyRevenue * endDay; 
                    } else {// any other month.
                        postingAmount = monthlyRevenue;
                    }                    
                    
                    gcFCast.Posting_Amount__c += postingAmount;
                    gcFCast.Posting_Amount_USD__c += GenesysCareForecastingUtil.convertCurrency(postingAmount, quoteProduct.BigMachines__Quote__r.CurrencyIsoCode, 'USD');
                    gcFCast.Posting_Amount_EUR__c += GenesysCareForecastingUtil.convertCurrency(postingAmount, quoteProduct.BigMachines__Quote__r.CurrencyIsoCode, 'EUR');                    
                    
                    // Add Each Monthly records in this below list.
                    if(gcFCast.Posting_Date__c >= cutOffDate){
                        qIdpluspDatetoForecastingSOMap.put(qIdpluspDate, gcFCast);
                    }
                }
            }
        }
        return qIdpluspDatetoForecastingSOMap.values();
    }

    // Harish: 03/08/2017 - replaced with new version below.
    /*public Static List<Genesys_Care_Forecasting__c> generateForeCastByServiceContractIds(List<String> serviceContractIds, Id opportunityId){
        // Assumption: line item's maintenance end date will always match with service contract's end date.
        Date cutOffDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        List<Genesys_Care_Forecasting__c> genCareFCList = new List<Genesys_Care_Forecasting__c>();

        List<ContractLineItem> contLineItms = [SELECT id, 
                                               Sold_To_Name_Lookup__c, Sold_To_Name_Lookup__r.Name, Sold_To_Name_Lookup__r.SAP_Account_Code__c, Sold_To_Name_Lookup__r.Subsidary__r.Name,
                                               End_Usr_Name__c, End_Usr_Name__r.Name, End_Usr_Name__r.SAP_Account_Code__c, End_Usr_Name__r.Subsidary__r.Name,
                                               LineItemNumber, PricebookEntry.Product2.Name, Product_Description__c, Maintenance_Start_Date__c, Maintenance_End_Date__c,
                                               ServiceContract.CurrencyIsoCode, Original_PO__c, Order_SO__c, 
                                               Order_Line_Item__r.Order__r.Order_Number__c, Quote_Product__r.BigMachines__Quote__r.Name,
                                               ServiceContractId, ServiceContract.Renewal_Opportunity__c, ServiceContract.Term_Duration__c, ServiceContract.Renewal_Opportunity__r.CloseDate, 
                                               ServiceContract.Sold_To_Name__c, ServiceContract.Sold_To_Name__r.Name,  ServiceContract.Sold_To_Name__r.SAP_Account_Code__c, ServiceContract.Sold_To_Name__r.Subsidary__r.Name,
                                               ServiceContract.End_User_Name__c, ServiceContract.End_User_Name__r.Name,  ServiceContract.End_User_Name__r.SAP_Account_Code__c, ServiceContract.End_User_Name__r.Subsidary__r.Name,
                                               ServiceContract.Region__c, ServiceContract.Sold_To_Name__r.Sales_Region__c, 
                                               Previous_Line_Maintenance_Value__c, Product_Description_RO__c
                                               FROM ContractLineItem 
                                               WHERE ServiceContractId IN :serviceContractIds
                                               AND Previous_Line_Maintenance_Value__c != NULL AND Previous_Line_Maintenance_Value__c != 0
                                               AND Maintenance_Start_Date__c != NULL 
                                               AND Maintenance_End_Date__c != NULL
                                               // AND Maintenance_End_Date__c > TODAY
                                               AND (NOT Product_Description__c like 'Custom App%') 
                                               AND (NOT Product_Description__c like 'Custom Software%')
                                               AND (NOT Product_Description__c like '%Care%')];
       
        for(ContractLineItem cLItem : contLineItms){
            Integer termDuration_sContract = cLItem.ServiceContract.Term_Duration__c != NULL ? Integer.valueOf(cLItem.ServiceContract.Term_Duration__c) : 0;
            
            // startDate is line item's maintenance start date + term duration.
            // If in the past then bring it to current month.
            //Date startDate =  cLItem.Maintenance_Start_Date__c;
            //startDate = startDate.addMonths(termDuration_sContract);
            Date startDate = cLItem.Maintenance_End_Date__c.addDays(1);
            if(startDate < Date.today()){
                startDate = Date.today();
            }

            // endDate is line item's maintenance end date + term duration.
            Date endDate = cLItem.Maintenance_End_Date__c;
            endDate = endDate.addMonths(termDuration_sContract);
            
            Integer li_termDuration_months = cLItem.Maintenance_Start_Date__c.monthsBetween(cLItem.Maintenance_End_Date__c)+1;
            Integer li_termDuration_Days = cLItem.Maintenance_Start_Date__c.daysBetween(cLItem.Maintenance_End_Date__c);
            li_termDuration_months = li_termDuration_months <= 0 ? 1 : li_termDuration_months;
            li_termDuration_Days = li_termDuration_Days <= 0 ? 1 : li_termDuration_Days;

            Date mStartDate = cLItem.Maintenance_End_Date__c.addDays(1);
            Date mEndDate   = endDate;

            if(cLItem.Previous_Line_Maintenance_Value__c != NULL 
                && endDate > Date.today() 
                && startDate < endDate){
                //integer noOfRevenueMonths = cLItem.Maintenance_Start_Date__c.monthsBetween(cLItem.Maintenance_End_Date__c)+1;
                
                Decimal monthlyRevenue = cLItem.Previous_Line_Maintenance_Value__c/li_termDuration_months;
                Decimal dailyRevenue = cLItem.Previous_Line_Maintenance_Value__c/ li_termDuration_Days;
                Integer monthsCount = startDate.monthsBetween(endDate)+1;
                
                // start with last day of startDate.
                Date tempDate = startDate.addMonths(1).toStartOfMonth().addDays(-1); //Date.newInstance(startDate.year(), startDate.month(), 1);
                
                for(integer i = 0; i < monthsCount; i++){
                    Genesys_Care_Forecasting__c gcFCast = new Genesys_Care_Forecasting__c();

                    Date postingDate = tempDate.addMonths(i);
                    
                    // Sold To User Info
                    gcFCast.Sold_To__c = cLItem.ServiceContract.Sold_To_Name__c;
                    gcFCast.Sold_To_Name__c = cLItem.ServiceContract.Sold_To_Name__r.Name;
                    gcFCast.Sold_To_GARN_Code__c = cLItem.ServiceContract.Sold_To_Name__r.SAP_Account_Code__c;
                    gcFCast.Sold_To_Subsidary_Code__c = cLItem.ServiceContract.Sold_To_Name__r.Subsidary__r.Name;
                    
                    // End User Info
                    gcFCast.End_User__c = cLItem.ServiceContract.End_User_Name__c;
                    gcFCast.End_User_Name__c = cLItem.ServiceContract.End_User_Name__r.Name;
                    gcFCast.End_User_GARN_Code__c = cLItem.ServiceContract.End_User_Name__r.SAP_Account_Code__c;
                    gcFCast.End_User_Subsidary_Code__c = cLItem.ServiceContract.End_User_Name__r.Subsidary__r.Name;
                    
                    //Region Info
                    //gcFCast.Region__c = cLItem.ServiceContract.Region__c;
                    gcFCast.Region__c = (cLItem.ServiceContract.Region__c == 'LATAM' ? 'Latin America' : cLItem.ServiceContract.Region__c);
                    gcFCast.Sub_Region__c = cLItem.ServiceContract.Sold_To_Name__r.Sales_Region__c;
                    
                    //Item Info
                    //gcFCast.Item_Name__c = cLItem.LineItemNumber;
                    gcFCast.APN_Number__c = cLItem.PricebookEntry.Product2.Name;
                    gcFCast.Item_Name__c = cLItem.PricebookEntry.Product2.Name;
                    gcFCast.Item_Description__c = cLItem.Product_Description__c;
                    
                    // Maintenance Dates Info
                    // Update: Harish, 03/05/2017 - maintenance start date should always be end date +1.
                    gcFCast.Maintenance_Start_Date__c = mStartDate;//startDate;
                    gcFCast.Maintenance_End_Date__c = mEndDate;
                    
                    // Revenue Posting Info
                    gcFCast.Posting_Date__c = postingDate;
                    // Posting_Amount__c:
                    //              1st month: daily revenue * number of days between contract line items's and postingDate.
                    //              last month: daily revenue * number of days in last month(endDate). 
                    //              all other months: just montly value.
                    if(i == 0){
                        // Update: Harish, 03/04/2017 - Include past months to first month of Incremental revenue.
                        //Integer startDay =  cLItem.Maintenance_Start_Date__c.day() ;
                        //Integer DaysInMonth = Date.daysInMonth(startDate.year(), startDate.month());
                        //gcFCast.Posting_Amount__c = dailyRevenue * (DaysInMonth - startDay + 1);
                        // If end date is greater than or equal to posting date then take days between maintenance start date and posting date.
                        // else If end date is less than posting date then take days between maintenance start date and end date.
                        Date firstDate = endDate >= postingDate ? postingDate : endDate;  
                        Integer noOfDaysFromMEtoPostingDate = cLItem.Maintenance_End_Date__c.daysBetween(firstDate);
                        gcFCast.Posting_Amount__c = dailyRevenue * noOfDaysFromMEtoPostingDate;
                    } else if (i == (monthsCount-1)){
                        Integer endDay =  endDate.day();//cLItem.Maintenance_End_Date__c.day() ;
                        gcFCast.Posting_Amount__c = dailyRevenue * endDay; 
                    } else {
                        gcFCast.Posting_Amount__c = monthlyRevenue;
                    }                              
                     
                    gcFCast.Posting_Amount_USD__c = GenesysCareForecastingUtil.convertCurrency(gcFCast.Posting_Amount__c, cLItem.ServiceContract.CurrencyIsoCode, 'USD');
                    gcFCast.Posting_Amount_EUR__c = GenesysCareForecastingUtil.convertCurrency(gcFCast.Posting_Amount__c, cLItem.ServiceContract.CurrencyIsoCode, 'EUR');                    
                    
                    gcFCast.CurrencyIsoCode = cLItem.ServiceContract.CurrencyIsoCode;
                    
                    gcFCast.Revenue_Type__c = 'Incremental Revenue';
                    // gcFCast.PO_Number__c = cLItem.Original_PO__c;
                    // gcFCast.SO_Number__c = cLItem.Order_SO__c;
                    // gcFCast.Order_Number__c = cLItem.Order_Line_Item__r.Order__r.Order_Number__c;
                    // gcFCast.Quote_Number__c = cLItem.Quote_Product__r.BigMachines__Quote__r.Name;
                    // Update: Harish, 03/03/2017 - In split scenario, old contract could be referring to old opportunity so added a new param named opportunityId.
                    gcFCast.Opportunity__c = opportunityId;//cLItem.ServiceContract.Renewal_Opportunity__c;
                    gcFCast.Service_Contract__c = cLItem.ServiceContractId;
                        
                    gcFCast.Posting_Year__c = gcFCast.Posting_Date__c.year();
                    gcFCast.Posting_Month__c = gcFCast.Posting_Date__c.month();

                    // Add Each Monthly records in this below list.
                    if(gcFCast.Posting_Date__c >= cutOffDate){
                        genCareFCList.add(gcFCast);
                    }
                }
                
            }
        }
        return genCareFCList;
    }*/
    
    /*
        Harish, 03/08/2017.
        Incremental Revenue 
            - End Date+term must be in future.
            - If (maintenance end date+1) is in the past then consider today as start.
            - include prior months revenue in current month - applicable only if (maintenance end date+1)was in the past.
            - create forecasting monthly at contract level but not product level.
        Assumption: maintenance end date on lines will always match with parent contract.
     */
    public Static List<Genesys_Care_Forecasting__c> generateForeCastByServiceContractIds(List<String> serviceContractIds, Id opportunityId){
        // Assumption: line item's maintenance end date will always match with service contract's end date.
        Date cutOffDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        Map<String, Genesys_Care_Forecasting__c> scIdpluspDatetoForecastingSOMap = new Map<String, Genesys_Care_Forecasting__c>();
        List<ContractLineItem> contLineItms = [SELECT id, 
                                               Sold_To_Name_Lookup__c, Sold_To_Name_Lookup__r.Name, Sold_To_Name_Lookup__r.SAP_Account_Code__c, Sold_To_Name_Lookup__r.Subsidary__r.Name,
                                               End_Usr_Name__c, End_Usr_Name__r.Name, End_Usr_Name__r.SAP_Account_Code__c, End_Usr_Name__r.Subsidary__r.Name,
                                               LineItemNumber, PricebookEntry.Product2.Name, Product_Description__c, Maintenance_Start_Date__c, Maintenance_End_Date__c,
                                               ServiceContract.CurrencyIsoCode, Original_PO__c, Order_SO__c, 
                                               Order_Line_Item__r.Order__r.Order_Number__c, Quote_Product__r.BigMachines__Quote__r.Name,
                                               ServiceContract.StartDate, ServiceContract.EndDate,
                                               ServiceContractId, ServiceContract.Renewal_Opportunity__c, ServiceContract.Term_Duration__c, ServiceContract.Renewal_Opportunity__r.CloseDate, 
                                               ServiceContract.Sold_To_Name__c, ServiceContract.Sold_To_Name__r.Name,  ServiceContract.Sold_To_Name__r.SAP_Account_Code__c, ServiceContract.Sold_To_Name__r.Subsidary__r.Name,
                                               ServiceContract.End_User_Name__c, ServiceContract.End_User_Name__r.Name,  ServiceContract.End_User_Name__r.SAP_Account_Code__c, ServiceContract.End_User_Name__r.Subsidary__r.Name,
                                               ServiceContract.Region__c, ServiceContract.Sold_To_Name__r.Sales_Region__c, 
                                               Previous_Line_Maintenance_Value__c, Product_Description_RO__c
                                                   FROM ContractLineItem
                                                       WHERE   ServiceContractId IN :serviceContractIds
                                                               AND Previous_Line_Maintenance_Value__c != NULL AND Previous_Line_Maintenance_Value__c != 0
                                                               AND Maintenance_Start_Date__c != NULL 
                                                               AND Maintenance_End_Date__c != NULL
                                                               // AND Maintenance_End_Date__c > TODAY
                                                               AND (NOT Product_Description__c like 'Custom App%') 
                                                               AND (NOT Product_Description__c like 'Custom Software%')
                                                               AND (NOT Product_Description__c like '%Care%')
                                                                    Order by ServiceContractId];
        // get the min startDate and max endDate from lines if term duration on service contract is null.
        Map<Id, Date> scIdToMinStartDateMap = new Map<Id, Date>();
        Map<Id, Date> scIdToMaxEndDateMap = new Map<Id, Date>();
        for(ContractLineItem cLItem : contLineItms){
            Id scId = cLItem.ServiceContractId;
            Date mStartDate = cLItem.Maintenance_Start_Date__c;
            Date mEndDate = cLItem.Maintenance_End_Date__c;
            if(cLItem.ServiceContract.Term_Duration__c == null){
                if(scIdToMinStartDateMap.containsKey(scId)
                    && scIdToMaxEndDateMap.containsKey(scId)){
                    if(scIdToMinStartDateMap.get(scId) > mStartDate)
                        scIdToMinStartDateMap.put(scId, mStartDate);
                    if(scIdToMaxEndDateMap.get(scId) < mEndDate)
                        scIdToMaxEndDateMap.put(scId, mStartDate);
                }
            }else{
                scIdToMinStartDateMap.put(scId, mStartDate);
                scIdToMaxEndDateMap.put(scId, mStartDate);
            }
        }        

        for(ContractLineItem cLItem : contLineItms){
            Integer termDuration_sContract = cLItem.ServiceContract.Term_Duration__c != NULL ? Integer.valueOf(cLItem.ServiceContract.Term_Duration__c) : 0;
            
            // Update: Harish, 03/22/2017 - consider the duration between min start and max end date from lines if term_duration on contract is null.
            if(termDuration_sContract == 0){
                Id scId = cLItem.ServiceContractId;
                Date minStartDate = scIdToMinStartDateMap.get(scId);
                Date maxEndDate = scIdToMaxEndDateMap.get(scId);
                termDuration_sContract = minStartDate != null && maxEndDate != null ? minStartDate.monthsBetween(maxEndDate)+1 : 0;
            }

            // startDate is line item's maintenance end date + 1.
            // If in the past then bring it to current month.
            Date startDate = cLItem.Maintenance_End_Date__c.addDays(1);
            if(startDate < Date.today()){
                startDate = Date.today();
            }

            // endDate is line item's maintenance end date + term duration.
            Date endDate = cLItem.Maintenance_End_Date__c;
            endDate = endDate.addMonths(termDuration_sContract);
                
            // get term duration get daily, monthly revenue.
            Integer li_termDuration_months = cLItem.Maintenance_Start_Date__c.monthsBetween(cLItem.Maintenance_End_Date__c)+1;
            Integer li_termDuration_Days = cLItem.Maintenance_Start_Date__c.daysBetween(cLItem.Maintenance_End_Date__c);
            li_termDuration_months = li_termDuration_months <= 0 ? 1 : li_termDuration_months;
            li_termDuration_Days = li_termDuration_Days <= 0 ? 1 : li_termDuration_Days;

            Date mStartDate = cLItem.Maintenance_End_Date__c.addDays(1);
            Date mEndDate   = endDate;

            if(cLItem.Previous_Line_Maintenance_Value__c != NULL 
                && endDate > Date.today() 
                && startDate < endDate){
                
                Decimal monthlyRevenue = cLItem.Previous_Line_Maintenance_Value__c/li_termDuration_months;
                Decimal dailyRevenue = cLItem.Previous_Line_Maintenance_Value__c/ li_termDuration_Days;
                Integer monthsCount = startDate.monthsBetween(endDate)+1;
                
                // start with last day of startDate as first posting date.
                Date tempDate = startDate.addMonths(1).toStartOfMonth().addDays(-1);
                for(integer i = 0; i < monthsCount; i++){
                    Date postingDate = tempDate.addMonths(i);
                    
                    // Only one forecasting record will be created for month so see if forecasting for posting period exists or not.
                    Genesys_Care_Forecasting__c gcFCast =  new Genesys_Care_Forecasting__c();
                    String scIdpluspDate = cLItem.ServiceContractId+''+String.valueOf(postingDate);
                    if(scIdpluspDatetoForecastingSOMap.containsKey(scIdpluspDate)){// if already exists then posting amount will be added.
                        gcFCast = scIdpluspDatetoForecastingSOMap.get(scIdpluspDate);

                        if(gcFCast.Maintenance_Start_Date__c > mStartDate)
                            gcFCast.Maintenance_Start_Date__c = mStartDate;
                        if(gcFCast.Maintenance_End_Date__c < mEndDate)
                            gcFCast.Maintenance_End_Date__c = mEndDate;
                    }else{
                        // Sold To User Info
                        gcFCast.Sold_To__c = cLItem.ServiceContract.Sold_To_Name__c;
                        gcFCast.Sold_To_Name__c = cLItem.ServiceContract.Sold_To_Name__r.Name;
                        gcFCast.Sold_To_GARN_Code__c = cLItem.ServiceContract.Sold_To_Name__r.SAP_Account_Code__c;
                        gcFCast.Sold_To_Subsidary_Code__c = cLItem.ServiceContract.Sold_To_Name__r.Subsidary__r.Name;
                        
                        // End User Info
                        gcFCast.End_User__c = cLItem.ServiceContract.End_User_Name__c;
                        gcFCast.End_User_Name__c = cLItem.ServiceContract.End_User_Name__r.Name;
                        gcFCast.End_User_GARN_Code__c = cLItem.ServiceContract.End_User_Name__r.SAP_Account_Code__c;
                        gcFCast.End_User_Subsidary_Code__c = cLItem.ServiceContract.End_User_Name__r.Subsidary__r.Name;
                        
                        //Region Info
                        //gcFCast.Region__c = cLItem.ServiceContract.Region__c;
                        gcFCast.Region__c = (cLItem.ServiceContract.Region__c == 'LATAM' ? 'Latin America' : cLItem.ServiceContract.Region__c);
                        gcFCast.Sub_Region__c = cLItem.ServiceContract.Sold_To_Name__r.Sales_Region__c;
                        
                        gcFCast.Revenue_Type__c = 'Incremental Revenue';
                        // Update: Harish, 03/03/2017 - In split scenario, old contract could be referring to old opportunity so added a new param named opportunityId.
                        gcFCast.Opportunity__c = opportunityId;//cLItem.ServiceContract.Renewal_Opportunity__c;
                        gcFCast.Service_Contract__c = cLItem.ServiceContractId;
                        if(cLItem.ServiceContract.EndDate != null
                            && cLItem.ServiceContract.Term_Duration__c != null){
                            gcFCast.HeaderMaintenanceStartDate__c = cLItem.ServiceContract.EndDate.addDays(1);
                            gcFCast.HeaderMaintenanceEndDate__c = cLItem.ServiceContract.EndDate.addMonths(Integer.valueOf(cLItem.ServiceContract.Term_Duration__c));
                        }

                        // Revenue Posting Info
                        gcFCast.Posting_Date__c = postingDate;//tempDate.addMonths(i);
                        gcFCast.Posting_Year__c = gcFCast.Posting_Date__c.year();
                        gcFCast.Posting_Month__c = gcFCast.Posting_Date__c.month();
                        
                        // Amount related
                        gcFCast.CurrencyIsoCode = cLItem.ServiceContract.CurrencyIsoCode;
                        gcFCast.Posting_Amount__c = 0;// set to ZERO, calculated value will be added below.
                        gcFCast.Posting_Amount_USD__c = 0;// set to ZERO, calculated value will be added below.
                        gcFCast.Posting_Amount_EUR__c = 0;// set to ZERO, calculated value will be added below.
                        
                        gcFCast.Maintenance_Start_Date__c = mStartDate;
                        gcFCast.Maintenance_End_Date__c = mEndDate;
                    }
                    
                    //Item Info
                    //gcFCast.Item_Name__c = cLItem.LineItemNumber;
                    //gcFCast.APN_Number__c = cLItem.PricebookEntry.Product2.Name;
                    //gcFCast.Item_Name__c = cLItem.PricebookEntry.Product2.Name;
                    //gcFCast.Item_Description__c = cLItem.Product_Description__c;
                    
                    // Maintenance Dates Info
                    // Update: Harish, 03/05/2017 - maintenance start date should always be end date +1.
                    //gcFCast.Maintenance_Start_Date__c = mStartDate;//startDate;
                    //gcFCast.Maintenance_End_Date__c = mEndDate;

                    // gcFCast.PO_Number__c = cLItem.Original_PO__c;
                    // gcFCast.SO_Number__c = cLItem.Order_SO__c;
                    // gcFCast.Order_Number__c = cLItem.Order_Line_Item__r.Order__r.Order_Number__c;
                    // gcFCast.Quote_Number__c = cLItem.Quote_Product__r.BigMachines__Quote__r.Name; 
                    
                    // Posting_Amount__c:
                    //              1st month: daily revenue * number of days between contract line items's and postingDate.
                    //              last month: daily revenue * number of days in last month(endDate). 
                    //              all other months: just montly value.
                    Decimal postingAmount = 0;
                    if(i == 0){
                        // Include past months to first month of Incremental revenue.
                        // If end date is greater than or equal to posting date then take days between maintenance start date and posting date.
                        // else If end date is less than posting date then take days between maintenance start date and end date.
                        Date firstDate = endDate >= postingDate ? postingDate : endDate;  
                        Integer noOfDaysFromMEtoPostingDate = cLItem.Maintenance_End_Date__c.daysBetween(firstDate);
                        postingAmount = dailyRevenue * noOfDaysFromMEtoPostingDate;
                    } else if (i == (monthsCount-1)){
                        Integer endDay =  endDate.day();//cLItem.Maintenance_End_Date__c.day() ;
                        postingAmount = dailyRevenue * endDay; 
                    } else {
                        postingAmount = monthlyRevenue;
                    }                              
                    
                    gcFCast.Posting_Amount__c += postingAmount;
                    gcFCast.Posting_Amount_USD__c += GenesysCareForecastingUtil.convertCurrency(postingAmount, cLItem.ServiceContract.CurrencyIsoCode, 'USD');
                    gcFCast.Posting_Amount_EUR__c += GenesysCareForecastingUtil.convertCurrency(postingAmount, cLItem.ServiceContract.CurrencyIsoCode, 'EUR');                    
                    
                    // Add Each Monthly records in this below list.
                    if(gcFCast.Posting_Date__c >= cutOffDate){
                        scIdpluspDatetoForecastingSOMap.put(scIdpluspDate, gcFCast);
                    }
                }                
            }
        }
        return scIdpluspDatetoForecastingSOMap.values();
    }

    public Static List<Genesys_Care_Forecasting__c> generateForeCastByProducts(List<BigMachines__Quote_Product__c> products){
        Date cutOffDate = Date.newInstance(Date.today().year(), Date.today().month(), 1);
        List<Genesys_Care_Forecasting__c> genCareFCList = new List<Genesys_Care_Forecasting__c>();
        for(BigMachines__Quote_Product__c prod : products){
            System.debug('prod = ' + prod.Product_Name__c + ' ' + prod.BigMachines__Quote__r.Maintenance_Start_Date__c +  ' ' + prod.BigMachines__Quote__r.Maintenance_End_Date__c);
            Date startDate =  prod.BigMachines__Quote__r.Opportunity_Close_Date__c ;
            Date endDate = prod.BigMachines__Quote__r.Forecast_Maint_End_Date__c;
            if(prod.BigMachines__Quote__r.Total_Genesys_Care__c != NULL && startDate != NULL && endDate != NULL && startDate < endDate){
                integer noOfRevenueMonths = startDate.monthsBetween(endDate)+1;
                integer noOfRevenueDays = startDate.daysBetween(endDate);
                Decimal dailyRevenue = prod.BigMachines__Quote__r.Total_Genesys_Care__c/noOfRevenueDays;
                Date tempDate = Date.newInstance(startDate.year(), startDate.month(), 1);
                for(integer i = 0; i<noOfRevenueMonths; i++){
                    Genesys_Care_Forecasting__c gcFCast = new Genesys_Care_Forecasting__c();
                    // Sold To User Info
                    gcFCast.Sold_To__c = prod.BigMachines__Quote__r.Sold_To_Name__c;
                    gcFCast.Sold_To_Name__c = prod.BigMachines__Quote__r.Sold_To_Name__r.Name;
                    gcFCast.Sold_To_GARN_Code__c = prod.BigMachines__Quote__r.Sold_To_Name__r.SAP_Account_Code__c;
                    gcFCast.Sold_To_Subsidary_Code__c = prod.BigMachines__Quote__r.Sold_To_Name__r.Subsidary__r.Name;
                    
                    // End User Info
                    gcFCast.End_User__c = prod.BigMachines__Quote__r.End_User_ID__c;
                    gcFCast.End_User_Name__c = prod.BigMachines__Quote__r.End_User_ID__r.Name;
                    gcFCast.End_User_GARN_Code__c = prod.BigMachines__Quote__r.End_User_ID__r.SAP_Account_Code__c;
                    gcFCast.End_User_Subsidary_Code__c = prod.BigMachines__Quote__r.End_User_ID__r.Subsidary__r.Name;
                    
                    //Region Info
                    //gcFCast.Region__c = cLItem.ServiceContract.Region__c;
                    gcFCast.Region__c = (prod.BigMachines__Quote__r.Sold_To_Name__r.Country__r.Region__c == 'LATAM' ? 'Latin America' : prod.BigMachines__Quote__r.Sold_To_Name__r.Country__r.Region__c);
                    gcFCast.Sub_Region__c = prod.BigMachines__Quote__r.Sold_To_Name__r.Country__r.RU__c;
                    
                    //Item Info
                    gcFCast.Item_Name__c = prod.Product_Name__c;
                    gcFCast.APN_Number__c = prod.Product_Name__c;
                    gcFCast.Item_Description__c = prod.Product_Description__c;
                    
                    // Maintenance Dates Info
                    gcFCast.Maintenance_Start_Date__c = startDate;
                    gcFCast.Maintenance_End_Date__c = endDate;
                    
                    // Posting Info
                    gcFCast.Posting_Date__c = tempDate.addMonths(i);
                    if(i == 0){
                        Integer startDay =  prod.BigMachines__Quote__r.Opportunity_Close_Date__c.day() ;
                        Integer DaysInMonth = Date.daysInMonth(startDate.year(), startDate.month());
                        gcFCast.Posting_Amount__c = dailyRevenue * (DaysInMonth - startDay + 1);
                    } else if (i == (noOfRevenueMonths-1)){
                        Integer endDay =  prod.BigMachines__Quote__r.Forecast_Maint_End_Date__c.day() ;
                        gcFCast.Posting_Amount__c = dailyRevenue * endDay; 
                    } else {
                       gcFCast.Posting_Amount__c = dailyRevenue * 30; 
                    }
                    gcFCast.Posting_Amount_USD__c = GenesysCareForecastingUtil.convertCurrency(gcFCast.Posting_Amount__c, prod.BigMachines__Quote__r.CurrencyIsoCode, 'USD');
                    gcFCast.Posting_Amount_EUR__c = GenesysCareForecastingUtil.convertCurrency(gcFCast.Posting_Amount__c, prod.BigMachines__Quote__r.CurrencyIsoCode, 'EUR');                    
                    
                    gcFCast.CurrencyIsoCode = prod.BigMachines__Quote__r.CurrencyIsoCode;
                    
                    gcFCast.Revenue_Type__c = 'First Year Maintenance';
                    gcFCast.PO_Number__c = prod.Original_PO__c;
                    gcFCast.SO_Number__c = prod.Service_Contract_Line__r.Order_SO__c;
                    gcFCast.Order_Number__c = prod.BigMachines__Quote__r.Order__r.Order_Number__c;
                    gcFCast.Quote_Number__c = prod.BigMachines__Quote__r.Name;
                    gcFCast.Opportunity__c = prod.BigMachines__Quote__r.BigMachines__Opportunity__c;
                    gcFCast.Service_Contract__c = prod.BigMachines__Quote__r.BigMachines__Opportunity__r.Service_Contract__c;
                    gcFCast.Posting_Year__c = gcFCast.Posting_Date__c.year();
                    gcFCast.Posting_Month__c = gcFCast.Posting_Date__c.month();
                    
                    // Add Each Monthly records in this below list.
                    if(gcFCast.Posting_Date__c >= cutOffDate){
                        genCareFCList.add(gcFCast);
                    }
                }
            }
        }
        return genCareFCList;
    }
    
    public static void prepareGenesysCareForeCastingRollupObject(){
        List<Genesys_Care_Forecasting_Rollup__c> rollupRecords = [SELECT id FROM Genesys_Care_Forecasting_Rollup__c];
        if(rollupRecords.size() > 0){
            Database.delete(rollupRecords);
            Database.emptyRecycleBin(rollupRecords);
        }
        rollupRecords = new List<Genesys_Care_Forecasting_Rollup__c>();
        Integer minYear = Date.Today().year() - 1;
        Integer maxYear = minYear + 5;
        
        for(Integer y = minYear; y <=maxYear; y++){
            for(Integer m=1; m<=12; m++){
                rollupRecords.add(new Genesys_Care_Forecasting_Rollup__c(Unique_Id__c = y + '-' + m, 
                                                                         Year__c = y, 
                                                                         Month__c = m, 
                                                                         Quarter__c = GenesysCareForecastingUtil.getQuarter(m),
                                                                         Year_Text__c = ''+y,
                                                                         Month_Text__c = ''+m,
                                                                         Quarter_Text__c = ''+GenesysCareForecastingUtil.getQuarter(m)
                                                                        ));
            }
        }
        Database.insert(rollupRecords);
    }
    
    public static List<String> buildCellNames(String region, String year, String quarter){
        List<String> cellNames = new List<String>();
        
        Integer currentYear = Date.Today().Year();
        Integer currentMonth = Date.Today().Month();
        
        Integer startMonth = 1;
        Integer endMonth = 12;
        if(quarter == 'All'){
            startMonth = 1;
            endMonth = 12;
        } else if(quarter == '1'){
            startMonth = 1;
            endMonth = 3;
        } else if(quarter == '2'){
            startMonth = 4;
            endMonth = 6;
        } else if(quarter == '3'){
            startMonth = 7;
            endMonth = 9;
        } else if(quarter == '4'){
            startMonth = 10;
            endMonth = 12;
        } 
        
        for(Integer m=startMonth; m <=endMonth; m++){
            cellNames.add(getMonthName(m) + ' ' + year);
        }
        
        return cellNames;
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
}