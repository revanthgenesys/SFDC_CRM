/*
 * Class			: GenesysCareForecastingControllerTest
 * Description		: A Test Class for GenesysCareForecastingController.
 * Author			: Narasimha "Rao" Tumma
 * Created Date		: Dec 19, 2016
 */
@isTest
private class GenesysCareForecastingControllerTest {
	@isTest
    static void testGenesysCareForecastingController(){
        setupTestData();
        
        GenesysCareForecastingController controller = new GenesysCareForecastingController();
		List<SelectOption> regions = controller.getRegions();
		List<SelectOption> years = controller.getYears();
		List<SelectOption> quarters = controller.getQuarters();
		List<SelectOption> currencies = controller.getCurrencies();
        controller.refereshChartRevenueData();

        List<GenesysCareForecastingController.RevenueData> revenueData = controller.getRevenueData();
        List<GenesysCareForecastingController.RevenueData> revenueDataWithTotals = controller.getRevenueDataWithTotals();
        List<GenesysCareForecastingController.RevenueData> revenueDataForChart = controller.getChartRevenueData();
        
        controller.selectedRegion = 'APAC';
        controller.buildChartRevenueData();
        controller.selectedRegion = 'EMEA';
        controller.buildChartRevenueData();
        controller.selectedRegion = 'Latin America';
        controller.buildChartRevenueData();
        controller.selectedRegion = 'North America';
        controller.buildChartRevenueData();
        
        controller.selectedYear = ''+ (Date.today().year());
        controller.selectedQuarter = '4';
        controller.buildChartRevenueData();
        
    }
    
    static void setupTestData(){
		Integer minYear = Date.today().Year();
        Integer maxYear = Date.today().Year() + 1;
        List<Genesys_Care_Forecasting_Rollup__c> rollupRecords = [SELECT id FROM Genesys_Care_Forecasting_Rollup__c];
		for(Integer y = Date.today().Year(); y <=maxYear; y++){
            for(Integer m=1; m<=12; m++){
                rollupRecords.add(new Genesys_Care_Forecasting_Rollup__c(Unique_Id__c = y + '-' + m,  Year__c = y,  Month__c = m,  Quarter__c = GenesysCareForecastingUtil.getQuarter(m),
                                                                         	Year_Text__c = ''+y, Month_Text__c = ''+m, Quarter_Text__c = ''+GenesysCareForecastingUtil.getQuarter(m),
                                                                         	APAC_Billing_Schedule__c = m*10000, APAC_Deferred_Revenue__c = m*10000, APAC_Incremental_Revenue__c = m*10000, APAC_Revenue_Recognition__c = m*10000, APAC_First_Year_Maintenance__c = m*10000,
                                        									EMEA_Billing_Schedule__c = m*10000, EMEA_Deferred_Revenue__c = m*10000, EMEA_Incremental_Revenue__c = m*10000, EMEA_Revenue_Recognition__c = m*10000, EMEA_First_Year_Maintenance__c = m*10000,
                                        									Latin_America_Billing_Schedule__c = m*10000, Latin_America_Deferred_Revenue__c = m*10000, Latin_America_Incremental_Revenue__c = m*10000, Latin_America_Revenue_Recognition__c = m*10000, Latin_America_First_Year_Maintenance__c = m*10000,
                                        									North_America_Billing_Schedule__c = m*10000, North_America_Deferred_Revenue__c = m*10000, North_America_Incremental_Revenue__c = m*10000, North_America_Revenue_Recognition__c = m*10000, North_America_First_Year_Maintenance__c = m*10000
                                                                        ));
            }
        }
        Database.insert(rollupRecords);
    }
}