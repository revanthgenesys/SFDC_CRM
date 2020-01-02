/*
 * Class            : GenesysCareForecastingController
 * Description      : A Controller Class for Genesys Care forecasting UI.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Dec 19, 2016
 * Test Class       : GenesysCareForecastingControllerTest   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Harish, 03/11/207 - Added sub categories(Renewal, FYM) under Billing schedule, Deferred revenue and Recognized revenue.
 * Harish, 03/16/207 - Added sub categories(Expected, Upside) under Incremental Revenue and First Year Maintenance.
 */
public class GenesysCareForecastingController {
    
    public String selectedRegion {get; set;}
    public String selectedYear {get; set;}
    public String selectedQuarter {get; set;}
    public String selectedCurrency {get; set;}
    public Set<Integer> currentYears {get; set;}
    public Map<String, RevenueData> revenueMap {get; set;}
    
    public GenesysCareForecastingController(){
        currentYears = new Set<Integer>();
        selectedRegion = 'All';
        selectedYear = 'All';
        selectedQuarter = 'All';
        selectedCurrency = 'USD';
        buildChartRevenueData();
    }
    
    public List<SelectOption> getCurrencies(){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('USD','USD'));
        options.add(new SelectOption('EUR','EUR'));
        return options;
    }
    
    public void refereshChartRevenueData(){
        buildChartRevenueData();
    }
    
     // Return a list of data points for a chart
    public List<RevenueData> getRevenueData() {
        return getChartRevenueData();
    }

    public List<RevenueData> getRevenueDataWithTotals() {
        List<RevenueData> rData = new List<RevenueData>();
        Integer year = 0;
        RevenueData annualRD = new RevenueData('Total');
        for(RevenueData rd: revenueMap.values()){
            if(year == 0 || year == rd.year){
                year = rd.year;
                annualRD.name = year + ' Total'; 
                annualRD.year = year;
                annualRD.billingScheduleInMillions += rd.billingScheduleInMillions;
                annualRD.deferredRevenueInMillions += rd.deferredRevenueInMillions;
                annualRD.recognizedRevenueInMillions += rd.recognizedRevenueInMillions;
                annualRD.incrementalRevenueInMillions += rd.incrementalRevenueInMillions;
                annualRD.firstYearMaintenanceInMillions += rd.firstYearMaintenanceInMillions;
                annualRD.totalRevenueInMillions += rd.totalRevenueInMillions;

                annualRD.billingSchedule += rd.billingSchedule;
                annualRD.deferredRevenue += rd.deferredRevenue;
                annualRD.recognizedRevenue += rd.recognizedRevenue;

                annualRD.billingSchedule_fym += rd.billingSchedule_fym;
                annualRD.deferredRevenue_fym += rd.deferredRevenue_fym;
                annualRD.recognizedRevenue_fym += rd.recognizedRevenue_fym;

                annualRD.billingSchedule_renew += rd.billingSchedule_renew;
                annualRD.deferredRevenue_renew += rd.deferredRevenue_renew;
                annualRD.recognizedRevenue_renew += rd.recognizedRevenue_renew;

                annualRD.incrementalRevenue_e += rd.incrementalRevenue_e;
                annualRD.firstYearMaintenance_e += rd.firstYearMaintenance_e;
                
                annualRD.incrementalRevenue_u += rd.incrementalRevenue_u;
                annualRD.firstYearMaintenance_u += rd.firstYearMaintenance_u;

                annualRD.incrementalRevenue += rd.incrementalRevenue;
                annualRD.firstYearMaintenance += rd.firstYearMaintenance;

                annualRD.totalRevenue += rd.totalRevenue;
            } else if(year != rd.year){
                rData.add(annualRD);
                annualRD = new RevenueData('Total');
                year = rd.year;
                annualRD.name = year + ' Total'; 
                annualRD.year = year;
                annualRD.billingScheduleInMillions += rd.billingScheduleInMillions;
                annualRD.deferredRevenueInMillions += rd.deferredRevenueInMillions;
                annualRD.recognizedRevenueInMillions += rd.recognizedRevenueInMillions;
                annualRD.incrementalRevenueInMillions += rd.incrementalRevenueInMillions;
                annualRD.firstYearMaintenanceInMillions += rd.firstYearMaintenanceInMillions;
                annualRD.totalRevenueInMillions += rd.totalRevenueInMillions;

                annualRD.billingSchedule += rd.billingSchedule;
                annualRD.deferredRevenue += rd.deferredRevenue;
                annualRD.recognizedRevenue += rd.recognizedRevenue;

                annualRD.billingSchedule_fym += rd.billingSchedule_fym;
                annualRD.deferredRevenue_fym += rd.deferredRevenue_fym;
                annualRD.recognizedRevenue_fym += rd.recognizedRevenue_fym;

                annualRD.billingSchedule_renew += rd.billingSchedule_renew;
                annualRD.deferredRevenue_renew += rd.deferredRevenue_renew;
                annualRD.recognizedRevenue_renew += rd.recognizedRevenue_renew;
                
                annualRD.incrementalRevenue_e += rd.incrementalRevenue_e;
                annualRD.firstYearMaintenance_e += rd.firstYearMaintenance_e;
                
                annualRD.incrementalRevenue_u += rd.incrementalRevenue_u;
                annualRD.firstYearMaintenance_u += rd.firstYearMaintenance_u;

                annualRD.incrementalRevenue += rd.incrementalRevenue;
                annualRD.firstYearMaintenance += rd.firstYearMaintenance;
                
                annualRD.totalRevenue += rd.totalRevenue;
            } 
            rData.add(rd);
        }
        rData.add(annualRD);         
        return rData;
    }
    
    public List<RevenueData> getChartRevenueData() {
       return revenueMap.values(); 
    }
    // The actual chart data; needs to be static to be
    // called by a @RemoteAction method
    public void buildChartRevenueData() {
        revenueMap = new Map<String, RevenueData>();
        Integer currentYear = Date.Today().Year();  
        Integer currentMonth = Date.Today().Month();
        Integer previousYear = Date.Today().Year() - 1;  
        String filterString = '';
        if(selectedYear != 'All'){
            filterString = filterString + ' AND Year__c = '+selectedYear;
            if(selectedQuarter != 'All'){
                filterString = filterString + ' AND Quarter__c = '+selectedQuarter;
            }
        }
        
        String query_USD  = 'SELECT Year_Text__c,  Quarter_Text__c, ' 
                            + ' SUM(APAC_Billing_Schedule__c) APAC_BS_USD, SUM(APAC_Deferred_Revenue__c) APAC_DR_USD, SUM(APAC_Incremental_Revenue__c) APAC_IR_USD, SUM(APAC_Revenue_Recognition__c) APAC_RR_USD, SUM(APAC_First_Year_Maintenance__c) APAC_FYM_USD,'    
                            + ' SUM(EMEA_Billing_Schedule__c) EMEA_BS_USD, SUM(EMEA_Deferred_Revenue__c) EMEA_DR_USD, SUM(EMEA_Incremental_Revenue__c) EMEA_IR_USD, SUM(EMEA_Revenue_Recognition__c) EMEA_RR_USD, SUM(EMEA_First_Year_Maintenance__c) EMEA_FYM_USD,'
                            + ' SUM(Latin_America_Billing_Schedule__c) LATAM_BS_USD, SUM(Latin_America_Deferred_Revenue__c) LATAM_DR_USD, SUM(Latin_America_Incremental_Revenue__c) LATAM_IR_USD, SUM(Latin_America_Revenue_Recognition__c) LATAM_RR_USD, SUM(Latin_America_First_Year_Maintenance__c) LATAM_FYM_USD,'
                            + ' SUM(North_America_Billing_Schedule__c) NA_BS_USD, SUM(North_America_Deferred_Revenue__c) NA_DR_USD, SUM(North_America_Incremental_Revenue__c) NA_IR_USD, SUM(North_America_Revenue_Recognition__c) NA_RR_USD, SUM(North_America_First_Year_Maintenance__c) NA_FYM_USD,'
                            + ' SUM(APAC_Billing_Schedule_FYM__c) APAC_BS_FYM_USD, SUM(APAC_Deferred_Revenue_FYM__c) APAC_DR_FYM_USD, SUM(APAC_Revenue_Recognition_FYM__c) APAC_RR_FYM_USD, SUM(APAC_Incremental_Revenue_E__c) APAC_IR_E_USD, SUM(APAC_First_Year_Maint_E__c) APAC_FYM_E_USD, '
                            + ' SUM(EMEA_Billing_Schedule_FYM__c) EMEA_BS_FYM_USD, SUM(EMEA_Deferred_Revenue_FYM__c) EMEA_DR_FYM_USD, SUM(EMEA_Revenue_Recognition_FYM__c) EMEA_RR_FYM_USD, SUM(EMEA_Incremental_Revenue_E__c) EMEA_IR_E_USD, SUM(EMEA_First_Year_Maint_E__c) EMEA_FYM_E_USD, '
                            + ' SUM(Latin_America_Billing_Schedule_FYM__c) LATAM_BS_FYM_USD, SUM(Latin_America_Deferred_Revenue_FYM__c) LATAM_DR_FYM_USD, SUM(Latin_America_Revenue_Recognition_FYM__c) LATAM_RR_FYM_USD, SUM(Latin_America_Incremental_Revenue_E__c) LATAM_IR_E_USD, SUM(Latin_America_First_Year_Maint_E__c) LATAM_FYM_E_USD, '
                            + ' SUM(North_America_Billing_Schedule_FYM__c) NA_BS_FYM_USD, SUM(North_America_Deferred_Revenue_FYM__c) NA_DR_FYM_USD, SUM(North_America_Revenue_Recognition_FYM__c) NA_RR_FYM_USD, SUM(North_America_Incremental_Revenue_E__c) NA_IR_E_USD, SUM(North_America_First_Year_Maint_E__c) NA_FYM_E_USD, '
                            + ' SUM(APAC_Billing_Schedule_Renew__c) APAC_BS_R_USD, SUM(APAC_Deferred_Revenue_Renew__c) APAC_DR_R_USD, SUM(APAC_Revenue_Recognition_Renew__c) APAC_RR_R_USD, SUM(APAC_Incremental_Revenue_U__c) APAC_IR_U_USD, SUM(APAC_First_Year_Maint_U__c) APAC_FYM_U_USD, '
                            + ' SUM(EMEA_Billing_Schedule_Renew__c) EMEA_BS_R_USD, SUM(EMEA_Deferred_Revenue_Renew__c) EMEA_DR_R_USD, SUM(EMEA_Revenue_Recognition_Renew__c) EMEA_RR_R_USD, SUM(EMEA_Incremental_Revenue_U__c) EMEA_IR_U_USD, SUM(EMEA_First_Year_Maint_U__c) EMEA_FYM_U_USD, '
                            + ' SUM(Latin_America_Billing_Schedule_Renew__c) LATAM_BS_R_USD, SUM(Latin_America_Deferred_Revenue_Renew__c) LATAM_DR_R_USD, SUM(Latin_America_Revenue_Recognition_Renew__c) LATAM_RR_R_USD, SUM(Latin_America_Incremental_Revenue_U__c) LATAM_IR_U_USD, SUM(Latin_America_First_Year_Maint_U__c) LATAM_FYM_U_USD, '
                            + ' SUM(North_America_Billing_Schedule_Renew__c) NA_BS_R_USD, SUM(North_America_Deferred_Revenue_Renew__c) NA_DR_R_USD, SUM(North_America_Revenue_Recognition_Renew__c) NA_RR_R_USD, SUM(North_America_Incremental_Revenue_U__c) NA_IR_U_USD, SUM(North_America_First_Year_Maint_U__c) NA_FYM_U_USD '
                            + ' FROM Genesys_Care_Forecasting_Rollup__c '
                            + ' WHERE Year__c >= :previousYear '
                            + filterString
                            + ' GROUP BY  Year_Text__c,  Quarter_Text__c'
                            + ' ORDER BY Year_Text__c, Quarter_Text__c' ;
        
        String query_EUR  = 'SELECT Year_Text__c,  Quarter_Text__c, ' 
                            + ' SUM(APAC_Billing_Schedule_EUR__c) APAC_BS_EUR, SUM(APAC_Deferred_Revenue_EUR__c) APAC_DR_EUR, SUM(APAC_Incremental_Revenue_EUR__c) APAC_IR_EUR, SUM(APAC_Revenue_Recognition_EUR__c) APAC_RR_EUR, SUM(APAC_First_Year_Maintenance_EUR__c) APAC_FYM_EUR,'    
                            + ' SUM(EMEA_Billing_Schedule_EUR__c) EMEA_BS_EUR, SUM(EMEA_Deferred_Revenue_EUR__c) EMEA_DR_EUR, SUM(EMEA_Incremental_Revenue_EUR__c) EMEA_IR_EUR, SUM(EMEA_Revenue_Recognition_EUR__c) EMEA_RR_EUR, SUM(EMEA_First_Year_Maintenance_EUR__c) EMEA_FYM_EUR,'
                            + ' SUM(Latin_America_Billing_Schedule_EUR__c) LATAM_BS_EUR, SUM(Latin_America_Deferred_Revenue_EUR__c) LATAM_DR_EUR, SUM(Latin_America_Incremental_Revenue_EUR__c) LATAM_IR_EUR, SUM(Latin_America_Revenue_Recognition_EUR__c) LATAM_RR_EUR, SUM(Latin_America_First_Year_Maintenance_EUR__c) LATAM_FYM_EUR,'
                            + ' SUM(North_America_Billing_Schedule_EUR__c) NA_BS_EUR, SUM(North_America_Deferred_Revenue_EUR__c) NA_DR_EUR, SUM(North_America_Incremental_Revenue_EUR__c) NA_IR_EUR, SUM(North_America_Revenue_Recognition_EUR__c) NA_RR_EUR, SUM(North_America_First_Year_Maintenance_EUR__c) NA_FYM_EUR, '
                            + ' SUM(APAC_Billing_Schedule_FYM_EUR__c) APAC_BS_FYM_EUR, SUM(APAC_Deferred_Revenue_FYM_EUR__c) APAC_DR_FYM_EUR, SUM(APAC_Revenue_Recognition_FYM_EUR__c) APAC_RR_FYM_EUR, SUM(APAC_Incremental_Revenue_E_EUR__c) APAC_IR_E_EUR, SUM(APAC_First_Year_Maint_E_EUR__c) APAC_FYM_E_EUR,'    
                            + ' SUM(EMEA_Billing_Schedule_FYM_EUR__c) EMEA_BS_FYM_EUR, SUM(EMEA_Deferred_Revenue_FYM_EUR__c) EMEA_DR_FYM_EUR, SUM(EMEA_Revenue_Recognition_FYM_EUR__c) EMEA_RR_FYM_EUR, SUM(EMEA_Incremental_Revenue_E_EUR__c) EMEA_IR_E_EUR, SUM(EMEA_First_Year_Maint_E_EUR__c) EMEA_FYM_E_EUR,'    
                            + ' SUM(Latin_America_Billing_Schedule_FYM_EUR__c) LATAM_BS_FYM_EUR, SUM(Latin_America_Deferred_Revenue_FYM_EUR__c) LATAM_DR_FYM_EUR, SUM(Latin_America_Revenue_Recognition_F_EUR__c) LATAM_RR_FYM_EUR,SUM(Latin_America_Incremental_Revenue_E_EUR__c) LATAM_IR_E_EUR, SUM(Latin_America_First_Year_Maint_E_EUR__c) LATAM_FYM_E_EUR,'    
                            + ' SUM(North_America_Billing_Schedule_FYM_EUR__c) NA_BS_FYM_EUR, SUM(North_America_Deferred_Revenue_FYM_EUR__c) NA_DR_FYM_EUR, SUM(North_America_Revenue_Recognition_F_EUR__c) NA_RR_FYM_EUR, SUM(North_America_Incremental_Revenue_E_EUR__c) NA_IR_E_EUR, SUM(North_America_First_Year_Maint_E_EUR__c) NA_FYM_E_EUR,'    
                            + ' SUM(APAC_Billing_Schedule_Renew_EUR__c) APAC_BS_R_EUR, SUM(APAC_Deferred_Revenue_Renew_EUR__c) APAC_DR_R_EUR, SUM(APAC_Revenue_Recognition_Renew_EUR__c) APAC_RR_R_EUR,  SUM(APAC_Incremental_Revenue_U_EUR__c) APAC_IR_U_EUR, SUM(APAC_First_Year_Maint_U_EUR__c) APAC_FYM_U_EUR, '
                            + ' SUM(EMEA_Billing_Schedule_Renew_EUR__c) EMEA_BS_R_EUR, SUM(EMEA_Deferred_Revenue_Renew_EUR__c) EMEA_DR_R_EUR, SUM(EMEA_Revenue_Recognition_Renew_EUR__c) EMEA_RR_R_EUR, SUM(EMEA_Incremental_Revenue_U_EUR__c) EMEA_IR_U_EUR, SUM(EMEA_First_Year_Maint_U_EUR__c) EMEA_FYM_U_EUR, '
                            + ' SUM(Latin_America_Billing_Schedule_Renew_EUR__c) LATAM_BS_R_EUR, SUM(Latin_America_Deferred_Revenue_Renew_EUR__c) LATAM_DR_R_EUR, SUM(Latin_America_Revenue_Recognition_R_EUR__c) LATAM_RR_R_EUR, SUM(Latin_America_Incremental_Revenue_U_EUR__c) LATAM_IR_U_EUR, SUM(Latin_America_First_Year_Maint_U_EUR__c) LATAM_FYM_U_EUR, '
                            + ' SUM(North_America_Billing_Schedule_Renew_EUR__c) NA_BS_R_EUR, SUM(North_America_Deferred_Revenue_Renew_EUR__c) NA_DR_R_EUR, SUM(North_America_Revenue_Recognition_R_EUR__c) NA_RR_R_EUR, SUM(North_America_Incremental_Revenue_U_EUR__c) NA_IR_U_EUR, SUM(North_America_First_Year_Maint_U_EUR__c) NA_FYM_U_EUR '      
                            + ' FROM Genesys_Care_Forecasting_Rollup__c '
                            + ' WHERE Year__c >= :previousYear '
                            + filterString
                            + ' GROUP BY  Year_Text__c,  Quarter_Text__c'
                            + ' ORDER BY Year_Text__c, Quarter_Text__c' ;

        String query = selectedCurrency == 'USD' ? query_USD : query_EUR;
        System.debug('query ' + query);
        AggregateResult[] results = Database.query(query);

        for(AggregateResult ar : results){
            Integer revenueYear = Integer.valueof((String)ar.get('Year_Text__c'));
            Integer revenueQuarter = Integer.valueof((String)ar.get('Quarter_Text__c'));
            String key = revenueYear + ' Q' + revenueQuarter;
            if(filterString == '')
                currentYears.add(revenueYear);

            Decimal APAC_BS_FYM = ar.get('APAC_BS_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_BS_FYM_'+selectedCurrency) : 0.0;
            Decimal APAC_DR_FYM = ar.get('APAC_DR_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_DR_FYM_'+selectedCurrency) : 0.0;
            Decimal APAC_RR_FYM = ar.get('APAC_RR_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_RR_FYM_'+selectedCurrency) : 0.0;

            Decimal APAC_BS_R = ar.get('APAC_BS_R_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_BS_R_'+selectedCurrency) : 0.0;
            Decimal APAC_DR_R = ar.get('APAC_DR_R_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_DR_R_'+selectedCurrency) : 0.0;
            Decimal APAC_RR_R = ar.get('APAC_RR_R_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_RR_R_'+selectedCurrency) : 0.0;

            Decimal APAC_BS = ar.get('APAC_BS_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_BS_'+selectedCurrency) : 0.0;
            Decimal APAC_DR = ar.get('APAC_DR_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_DR_'+selectedCurrency) : 0.0;
            Decimal APAC_RR = ar.get('APAC_RR_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_RR_'+selectedCurrency) : 0.0;
            
            Decimal APAC_IR_E = ar.get('APAC_IR_E_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_IR_E_'+selectedCurrency) : 0.0;
            Decimal APAC_FYM_E = ar.get('APAC_FYM_E_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_FYM_E_'+selectedCurrency) : 0.0;

            Decimal APAC_IR_U = ar.get('APAC_IR_U_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_IR_U_'+selectedCurrency) : 0.0;
            Decimal APAC_FYM_U = ar.get('APAC_FYM_U_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_FYM_U_'+selectedCurrency) : 0.0;

            Decimal APAC_IR = ar.get('APAC_IR_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_IR_'+selectedCurrency) : 0.0;
            Decimal APAC_FYM = ar.get('APAC_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('APAC_FYM_'+selectedCurrency) : 0.0;


            Decimal EMEA_BS_FYM = ar.get('EMEA_BS_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_BS_FYM_'+selectedCurrency) : 0.0;
            Decimal EMEA_DR_FYM = ar.get('EMEA_DR_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_DR_FYM_'+selectedCurrency) : 0.0;
            Decimal EMEA_RR_FYM = ar.get('EMEA_RR_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_RR_FYM_'+selectedCurrency) : 0.0;

            Decimal EMEA_BS_R = ar.get('EMEA_BS_R_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_BS_R_'+selectedCurrency) : 0.0;
            Decimal EMEA_DR_R = ar.get('EMEA_DR_R_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_DR_R_'+selectedCurrency) : 0.0;
            Decimal EMEA_RR_R = ar.get('EMEA_RR_R_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_RR_R_'+selectedCurrency) : 0.0;

            Decimal EMEA_BS = ar.get('EMEA_BS_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_BS_'+selectedCurrency) : 0.0;
            Decimal EMEA_DR = ar.get('EMEA_DR_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_DR_'+selectedCurrency) : 0.0;
            Decimal EMEA_RR = ar.get('EMEA_RR_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_RR_'+selectedCurrency) : 0.0;
            
            Decimal EMEA_IR_E = ar.get('EMEA_IR_E_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_IR_E_'+selectedCurrency) : 0.0;
            Decimal EMEA_FYM_E = ar.get('EMEA_FYM_E_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_FYM_E_'+selectedCurrency) : 0.0;

            Decimal EMEA_IR_U = ar.get('EMEA_IR_U_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_IR_U_'+selectedCurrency) : 0.0;
            Decimal EMEA_FYM_U = ar.get('EMEA_FYM_U_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_FYM_U_'+selectedCurrency) : 0.0;

            Decimal EMEA_IR = ar.get('EMEA_IR_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_IR_'+selectedCurrency) : 0.0;
            Decimal EMEA_FYM = ar.get('EMEA_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('EMEA_FYM_'+selectedCurrency) : 0.0;


            Decimal LATAM_BS_FYM = ar.get('LATAM_BS_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_BS_FYM_'+selectedCurrency) : 0.0;
            Decimal LATAM_DR_FYM = ar.get('LATAM_DR_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_DR_FYM_'+selectedCurrency) : 0.0;
            Decimal LATAM_RR_FYM = ar.get('LATAM_RR_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_RR_FYM_'+selectedCurrency) : 0.0;
            
            Decimal LATAM_BS_R = ar.get('LATAM_BS_R_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_BS_R_'+selectedCurrency) : 0.0;
            Decimal LATAM_DR_R = ar.get('LATAM_DR_R_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_DR_R_'+selectedCurrency) : 0.0;
            Decimal LATAM_RR_R = ar.get('LATAM_RR_R_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_RR_R_'+selectedCurrency) : 0.0;
            
            Decimal LATAM_BS = ar.get('LATAM_BS_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_BS_'+selectedCurrency) : 0.0;
            Decimal LATAM_DR = ar.get('LATAM_DR_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_DR_'+selectedCurrency) : 0.0;
            Decimal LATAM_RR = ar.get('LATAM_RR_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_RR_'+selectedCurrency) : 0.0;

            Decimal LATAM_IR_E = ar.get('LATAM_IR_E_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_IR_E_'+selectedCurrency) : 0.0;
            Decimal LATAM_FYM_E = ar.get('LATAM_FYM_E_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_FYM_E_'+selectedCurrency) : 0.0;

            Decimal LATAM_IR_U = ar.get('LATAM_IR_U_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_IR_U_'+selectedCurrency) : 0.0;
            Decimal LATAM_FYM_U = ar.get('LATAM_FYM_U_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_FYM_U_'+selectedCurrency) : 0.0;

            Decimal LATAM_IR = ar.get('LATAM_IR_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_IR_'+selectedCurrency) : 0.0;
            Decimal LATAM_FYM = ar.get('LATAM_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('LATAM_FYM_'+selectedCurrency) : 0.0;


            Decimal NA_BS_FYM = ar.get('NA_BS_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_BS_FYM_'+selectedCurrency) : 0.0;
            Decimal NA_DR_FYM = ar.get('NA_DR_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_DR_FYM_'+selectedCurrency) : 0.0;
            Decimal NA_RR_FYM = ar.get('NA_RR_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_RR_FYM_'+selectedCurrency) : 0.0;

            Decimal NA_BS_R = ar.get('NA_BS_R_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_BS_R_'+selectedCurrency) : 0.0;
            Decimal NA_DR_R = ar.get('NA_DR_R_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_DR_R_'+selectedCurrency) : 0.0;
            Decimal NA_RR_R = ar.get('NA_RR_R_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_RR_R_'+selectedCurrency) : 0.0;

            Decimal NA_BS = ar.get('NA_BS_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_BS_'+selectedCurrency) : 0.0;
            Decimal NA_DR = ar.get('NA_DR_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_DR_'+selectedCurrency) : 0.0;
            Decimal NA_RR = ar.get('NA_RR_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_RR_'+selectedCurrency) : 0.0;
            
            Decimal NA_IR_E = ar.get('NA_IR_E_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_IR_E_'+selectedCurrency) : 0.0;
            Decimal NA_FYM_E = ar.get('NA_FYM_E_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_FYM_E_'+selectedCurrency) : 0.0;

            Decimal NA_IR_U = ar.get('NA_IR_U_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_IR_U_'+selectedCurrency) : 0.0;
            Decimal NA_FYM_U = ar.get('NA_FYM_U_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_FYM_U_'+selectedCurrency) : 0.0;

            Decimal NA_IR = ar.get('NA_IR_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_IR_'+selectedCurrency) : 0.0;
            Decimal NA_FYM = ar.get('NA_FYM_'+selectedCurrency) != NULL ? (Decimal)ar.get('NA_FYM_'+selectedCurrency) : 0.0;

            Decimal BS = 0.0;
            Decimal DR = 0.0;
            Decimal RR = 0.0;

            Decimal BS_FYM = 0.0;
            Decimal DR_FYM = 0.0;
            Decimal RR_FYM = 0.0;

            Decimal BS_R = 0.0;
            Decimal DR_R = 0.0;
            Decimal RR_R = 0.0;
            
            Decimal IR_E = 0.0;
            Decimal FYM_E = 0.0;

            Decimal IR_U = 0.0;
            Decimal FYM_U = 0.0;

            Decimal IR = 0.0;
            Decimal FYM = 0.0;

            if(selectedRegion == 'All'){
                BS_FYM = APAC_BS_FYM + EMEA_BS_FYM + LATAM_BS_FYM + NA_BS_FYM;
                DR_FYM = APAC_DR_FYM + EMEA_DR_FYM + LATAM_DR_FYM + NA_DR_FYM; 
                RR_FYM = APAC_RR_FYM + EMEA_RR_FYM + LATAM_RR_FYM + NA_RR_FYM;

                BS_R = APAC_BS_R + EMEA_BS_R + LATAM_BS_R + NA_BS_R;
                DR_R = APAC_DR_R + EMEA_DR_R + LATAM_DR_R + NA_DR_R; 
                RR_R = APAC_RR_R + EMEA_RR_R + LATAM_RR_R + NA_RR_R;

                BS = APAC_BS + EMEA_BS + LATAM_BS + NA_BS;
                DR = APAC_DR + EMEA_DR + LATAM_DR + NA_DR; 
                RR = APAC_RR + EMEA_RR + LATAM_RR + NA_RR;

                IR_E = APAC_IR_E + EMEA_IR_E + LATAM_IR_E + NA_IR_E;
                FYM_E = APAC_FYM_E + EMEA_FYM_E + LATAM_FYM_E + NA_FYM_E;

                IR_U = APAC_IR_U + EMEA_IR_U + LATAM_IR_U + NA_IR_U;
                FYM_U = APAC_FYM_U + EMEA_FYM_U + LATAM_FYM_U + NA_FYM_U;

                IR = APAC_IR + EMEA_IR + LATAM_IR + NA_IR;
                FYM = APAC_FYM + EMEA_FYM + LATAM_FYM + NA_FYM;
            } else if(selectedRegion == 'APAC'){
                BS_FYM = APAC_BS_FYM;
                DR_FYM = APAC_DR_FYM; 
                RR_FYM = APAC_RR_FYM;

                BS_R = APAC_BS_R;
                DR_R = APAC_DR_R; 
                RR_R = APAC_RR_R;

                BS = APAC_BS;
                DR = APAC_DR; 
                RR = APAC_RR;

                IR_E = APAC_IR_E;
                FYM_E = APAC_FYM_E;
                
                IR_U = APAC_IR_U;
                FYM_U = APAC_FYM_U;

                IR = APAC_IR;
                FYM = APAC_FYM;
            } else if(selectedRegion == 'EMEA'){
                BS_FYM = EMEA_BS_FYM;
                DR_FYM = EMEA_DR_FYM; 
                RR_FYM = EMEA_RR_FYM;

                BS_R = EMEA_BS_R;
                DR_R = EMEA_DR_R; 
                RR_R = EMEA_RR_R;

                BS = EMEA_BS;
                DR = EMEA_DR; 
                RR = EMEA_RR;

                IR_E = EMEA_IR_E;
                FYM_E = EMEA_FYM_E;
                
                IR_U = EMEA_IR_U;
                FYM_U = EMEA_FYM_U;

                IR = EMEA_IR;
                FYM = EMEA_FYM;
            } else if(selectedRegion == 'Latin America'){
                BS_FYM = LATAM_BS_FYM;
                DR_FYM = LATAM_DR_FYM; 
                RR_FYM = LATAM_RR_FYM;

                BS_R = LATAM_BS_R;
                DR_R = LATAM_DR_R; 
                RR_R = LATAM_RR_R;

                BS = LATAM_BS;
                DR = LATAM_DR; 
                RR = LATAM_RR;

                IR_E = LATAM_IR_E;
                FYM_E = LATAM_FYM_E;
                
                IR_U = LATAM_IR_U;
                FYM_U = LATAM_FYM_U;

                IR = LATAM_IR;
                FYM = LATAM_FYM;
            } else if(selectedRegion == 'North America'){
                BS_FYM = NA_BS_FYM;
                DR_FYM = NA_DR_FYM; 
                RR_FYM = NA_RR_FYM;

                BS_R = NA_BS_R;
                DR_R = NA_DR_R; 
                RR_R = NA_RR_R;

                BS = NA_BS;
                DR = NA_DR; 
                RR = NA_RR;

                IR_E = NA_IR_E;
                FYM_E = NA_FYM_E;
                
                IR_U = NA_IR_U;
                FYM_U = NA_FYM_U;

                IR = NA_IR;
                FYM = NA_FYM;
            } 
            RevenueData rd = new RevenueData(key, revenueYear, BS, DR, RR, BS_FYM, DR_FYM, RR_FYM, BS_R, DR_R, RR_R, IR_E, FYM_E, IR_U, FYM_U, IR, FYM);
            revenueMap.put(key, rd);
        }
        
        // clean up 
        // 
        List<String> allKeys = new List<String>();
        allKeys.addAll(revenueMap.keySet());
        allKeys.sort();

        for(Integer i=allKeys.size(); i > 0; i--){
            RevenueData rd = revenueMap.get(allKeys[i-1]);
            if(rd.billingSchedule == 0 && rd.deferredRevenue == 0 && rd.recognizedRevenue == 0 && rd.incrementalRevenue == 0){
                revenueMap.remove(allKeys[i-1]);    
            } else {
                break;
            }
        }
        
        if(filterString == ''){
            currentYears = new Set<Integer>();
            for(String s: revenueMap.keySet()){
                currentYears.add(Integer.valueOf(s.substring(0,4)));
            }
        }
    }
    
    // Wrapper class
    public class RevenueData {
        public String name { get; set; }
        public Integer year { get; set;}
        
        public Long billingScheduleInMillions { get; set; }
        public Long deferredRevenueInMillions { get; set; }
        public Long recognizedRevenueInMillions { get; set; }
        public Long incrementalRevenueInMillions { get; set; }
        public Long firstYearMaintenanceInMillions { get; set; }
        public Long totalRevenueInMillions { get; set; }

        public Decimal billingSchedule { get; set; }
        public Decimal deferredRevenue { get; set; }
        public Decimal recognizedRevenue { get; set; }

        public Decimal billingSchedule_fym { get; set; }
        public Decimal deferredRevenue_fym { get; set; }
        public Decimal recognizedRevenue_fym { get; set; }

        public Decimal billingSchedule_renew { get; set; }
        public Decimal deferredRevenue_renew { get; set; }
        public Decimal recognizedRevenue_renew { get; set; }

        public Decimal incrementalRevenue_e { get; set; }
        public Decimal firstYearMaintenance_e { get; set; }
        
        public Decimal incrementalRevenue_u { get; set; }
        public Decimal firstYearMaintenance_u { get; set; }

        public Decimal incrementalRevenue { get; set; }
        public Decimal firstYearMaintenance { get; set; }
        public Decimal totalRevenue { get; set; }

        public RevenueData(String name, Integer year, Decimal billingSchedule, Decimal deferredRevenue, Decimal recognizedRevenue, Decimal billingSchedule_fym, Decimal deferredRevenue_fym, Decimal recognizedRevenue_fym, Decimal billingSchedule_renew, Decimal deferredRevenue_renew, Decimal recognizedRevenue_renew, Decimal incrementalRevenue_e, Decimal firstYearMaintenance_e, Decimal incrementalRevenue_u, Decimal firstYearMaintenance_u, Decimal incrementalRevenue, Decimal firstYearMaintenance) {
            this.name = name;
            this.year = year;

            // first year maintenance revenue.,
            this.billingSchedule_fym = billingSchedule_fym;
            this.deferredRevenue_fym = deferredRevenue_fym;
            this.recognizedRevenue_fym = recognizedRevenue_fym;
            
            // renewal revenue.
            this.billingSchedule_renew = billingSchedule_renew;
            this.deferredRevenue_renew = deferredRevenue_renew;
            this.recognizedRevenue_renew = recognizedRevenue_renew;

            this.billingSchedule = billingSchedule;
            this.deferredRevenue = deferredRevenue;
            this.recognizedRevenue = recognizedRevenue;

            this.incrementalRevenue_e = incrementalRevenue_e;
            this.firstYearMaintenance_e = firstYearMaintenance_e;

            this.incrementalRevenue_u = incrementalRevenue_u;
            this.firstYearMaintenance_u = firstYearMaintenance_u;

            this.incrementalRevenue = incrementalRevenue;
            this.firstYearMaintenance = firstYearMaintenance;
            
            this.billingScheduleInMillions = (billingSchedule / 1000000).round(System.RoundingMode.CEILING);
            this.deferredRevenueInMillions = (deferredRevenue / 1000000).round(System.RoundingMode.CEILING);
            this.recognizedRevenueInMillions = (recognizedRevenue / 1000000).round(System.RoundingMode.CEILING);
            this.incrementalRevenueInMillions = (incrementalRevenue / 1000000).round(System.RoundingMode.CEILING);
            this.firstYearMaintenanceInMillions = (firstYearMaintenance / 1000000).round(System.RoundingMode.CEILING);

            totalRevenue = billingSchedule + deferredRevenue + recognizedRevenue + incrementalRevenue + firstYearMaintenance;     
            totalRevenueInMillions = billingScheduleInMillions + deferredRevenueInMillions + recognizedRevenueInMillions + incrementalRevenueInMillions + firstYearMaintenanceInMillions;
            
        }
        public RevenueData(String name){
            this.name = name;
            this.year = 0;
            this.totalRevenue = this.billingSchedule_fym = this.deferredRevenue_fym = this.recognizedRevenue_fym = this.billingSchedule_renew = this.deferredRevenue_renew = this.recognizedRevenue_renew = this.incrementalRevenue_e = this.firstYearMaintenance_e = this.incrementalRevenue_u = this.firstYearMaintenance_u = this.billingSchedule = this.deferredRevenue = this.recognizedRevenue = this.incrementalRevenue = this.firstYearMaintenance = 0.0;
            this.totalRevenueInMillions = this.billingScheduleInMillions = this.deferredRevenueInMillions = this.recognizedRevenueInMillions = this.incrementalRevenueInMillions = this.firstYearMaintenanceInMillions = 0;
        }
    }
    
    public List<SelectOption> getRegions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        options.add(new SelectOption('APAC','APAC'));
        options.add(new SelectOption('EMEA','EMEA'));
        options.add(new SelectOption('Latin America','Latin America'));
        options.add(new SelectOption('North America','North America'));
        return options;
    }

    public List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        List<Integer> years = new List<Integer>();
        years.addAll(currentYears);
        years.sort();
        for(Integer y : years){
            options.add(new SelectOption(''+y,''+y));
        }
        return options;
    }

    public List<SelectOption> getQuarters() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All','All'));
        options.add(new SelectOption('1','Q1'));
        options.add(new SelectOption('2','Q2'));
        options.add(new SelectOption('3','Q3'));
        options.add(new SelectOption('4','Q4'));
        return options;
    } 
}