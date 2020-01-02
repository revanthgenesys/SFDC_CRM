/*
 * Class			: GenesysCareForecastingUtilTest
 * Description		: A Test Class for GenesysCareForecastingUtil.
 * Author			: Narasimha "Rao" Tumma
 * Created Date		: Dec 19, 2016
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Harish, 03/30/207 - updated testGenesysCareForecastingUtil add a param to generateForeCastByServiceContractIds.
 */
@isTest(seeAllData=true)
private class GenesysCareForecastingUtilTest {
   	@isTest
    static void testGenesysCareForecastingUtil(){
        
        Decimal amountUSD2USD = GenesysCareForecastingUtil.convertCurrency(1000, 'USD', 'USD');
        Decimal amountUSD2EUR = GenesysCareForecastingUtil.convertCurrency(1000, 'USD', 'EUR');
        Decimal amountEUR2USD = GenesysCareForecastingUtil.convertCurrency(1000, 'EUR', 'USD');
        Decimal amountEUR2EUR = GenesysCareForecastingUtil.convertCurrency(1000, 'EUR', 'EUR');
        
        List<String> buildCellNames = new List<String>();
        buildCellNames = GenesysCareForecastingUtil.buildCellNames('', '2017', 'All');
        buildCellNames = GenesysCareForecastingUtil.buildCellNames('', '2017', '1');
        buildCellNames = GenesysCareForecastingUtil.buildCellNames('', '2017', '2');
        buildCellNames = GenesysCareForecastingUtil.buildCellNames('', '2017', '3');
        buildCellNames = GenesysCareForecastingUtil.buildCellNames('', '2017', '4');
        
        String monthName = '';
        monthName = GenesysCareForecastingUtil.getMonthName(1);
        monthName = GenesysCareForecastingUtil.getMonthName(2);
        monthName = GenesysCareForecastingUtil.getMonthName(3);
        monthName = GenesysCareForecastingUtil.getMonthName(4);
        monthName = GenesysCareForecastingUtil.getMonthName(5);
        monthName = GenesysCareForecastingUtil.getMonthName(6);
        monthName = GenesysCareForecastingUtil.getMonthName(7);
        monthName = GenesysCareForecastingUtil.getMonthName(8);
        monthName = GenesysCareForecastingUtil.getMonthName(9);
        monthName = GenesysCareForecastingUtil.getMonthName(10);
        monthName = GenesysCareForecastingUtil.getMonthName(11);
        monthName = GenesysCareForecastingUtil.getMonthName(12);
        
        Integer quarter = 0;
        quarter = GenesysCareForecastingUtil.getQuarter(1);
        quarter = GenesysCareForecastingUtil.getQuarter(4);
        quarter = GenesysCareForecastingUtil.getQuarter(7);
        quarter = GenesysCareForecastingUtil.getQuarter(10);
        
        List<String> quoteIds = new List<String>();
        for(BigMachines__Quote__c quote : [SELECT id, name, BigMachines__Opportunity__c FROM BigMachines__Quote__c  
                                           WHERE Quote_Business_Type__c = 'Renewal' 
                                           AND Order__c != NULL 
                                           AND BigMachines__Is_Primary__c = true 
                                           AND Maintenance_Start_Date__c != NULL 
                                           AND Maintenance_End_Date__c != NULL
                                           AND Maintenance_End_Date__c > TODAY LIMIT 5])
        {
        	quoteIds.add(quote.Id);	                                       
        }
		List<Genesys_Care_Forecasting__c> quoteBasedFC = GenesysCareForecastingUtil.generateForecastByQuoteIds(quoteIds);
        
        List<String> serviceContractIds = new List<String>();
        for(Quote_Service_Contracts__c qsc : [SELECT id, Service_Contract__c, Service_Contract__r.Renewal_Opportunity__c FROM Quote_Service_Contracts__c WHERE Quote__c IN :quoteIds])
        {
        	serviceContractIds.add(qsc.Service_Contract__c);	                                       
        }
		List<Genesys_Care_Forecasting__c> serviceContractBasedFC = GenesysCareForecastingUtil.generateForeCastByServiceContractIds(serviceContractIds, null);
        
        // Creating Filiting data sets
        List<String> oppStagesToInlcude             = new List<String>{'1.Recognize Needs','2.Identify Requirements','3.Evaluate Options','4.Resolve Concerns','5.Purchase Solution','6.Closed'};
        List<String> oppForecastStatusToInlcude     = new List<String>{'0.Booked','1.In Hand','2.Commit','3.Expected','4.Upside'};
        List<String> oppWinLossStatusNotToInlcude   = new List<String>{'Lost','Merged/Dup Opp'};
        List<String> oppOwnerNamesNotToInlcude      = new List<String>{'Brian Jonkman','Superstar AE','Pushpa Ramachandran','Gina Martinez'};
        List<String> oppAccountNamesNotToInlcude    = new List<String>{'ABC Testing'};
        List<String> oppNamesNotToInlcude           = new List<String>{'test','renewal','CMRR','upgrade','downgrade'};
        ID oppRecordTypeIDFilter                    = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GEN - Opportunity Record Type').getRecordTypeId();
        
        // Products filtering condition for FYM
        String filterCondition = 'Product_Name__c LIKE \'%care%\' AND ' 
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.RecordTypeId =:oppRecordTypeIDFilter AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.StageName IN :oppStagesToInlcude AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.ForecastStatus__c IN :oppForecastStatusToInlcude AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Win_Loss_Status__c NOT IN :oppWinLossStatusNotToInlcude AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Opportunity_Owner__r.Name NOT IN :oppOwnerNamesNotToInlcude AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Account.Name NOT IN :oppAccountNamesNotToInlcude AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Name NOT IN :oppNamesNotToInlcude AND '
                                +'BigMachines__Quote__r.BigMachines__Is_Primary__c = TRUE AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Has_PPU_Usage__c = FALSE AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Primary_Line_of_Business__c =\'On Premise\' AND '
                                +'BigMachines__Quote__r.Total_Genesys_Care__c != 0 AND '
                                +'(NOT Product_Name__c  like \'%3rd%\') AND '
                                +'BigMachines__Quote__r.Forecast_Maint_End_Date__c > TODAY ';
        
        // fields for fetching required information to calculate FYM
       // fields for fetching required information to calculate FYM
        String fieldsToQuery = 'Id, Name, BigMachines__Quote__r.Maintenance_Start_Date__c, BigMachines__Quote__r.Maintenance_End_Date__c,'
                                +'Maintenance_Due__c, Service_Contract_Line__r.Sold_To_Name_Lookup__c,'
                                +'Product_Name__c, Product_Description__c, Original_PO__c, '
            					+'Service_Contract_Line__r.Order_SO__c, APN_Number__c, BigMachines__Quote__c, '
                                +'BigMachines__Quote__r.End_User_ID__c,'
                                +'BigMachines__Quote__r.End_User_ID__r.Name,'
                                +'BigMachines__Quote__r.End_User_ID__r.Subsidary__r.Name,'
                                +'BigMachines__Quote__r.End_User_ID__r.SAP_Account_Code__c,'
                                +'BigMachines__Quote__r.End_User_ID__r.Country__r.Region__c,'
                                +'BigMachines__Quote__r.End_User_ID__r.Country__r.RU__c,'
                                +'BigMachines__Quote__r.Sold_To_Name__c,'
                                +'BigMachines__Quote__r.Sold_To_Name__r.Name,'
                                +'BigMachines__Quote__r.Sold_To_Name__r.Subsidary__r.Name,'
                                +'BigMachines__Quote__r.Sold_To_Name__r.SAP_Account_Code__c,'
                                +'BigMachines__Quote__r.Sold_To_Name__r.Country__r.Region__c,'
                                +'BigMachines__Quote__r.Sold_To_Name__r.Country__r.RU__c,'
                                +'Service_Contract_Line__r.ServiceContract.Region__c,'
                                +'BigMachines__Quote__r.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c ,'
                                +'BigMachines__Quote__r.Opportunity_Close_Date__c, BigMachines__Quote__r.Forecast_Maint_End_Date__c, '
                                +'BigMachines__Quote__r.Order_Numb_of_Maint_Months__c, BigMachines__Quote__r.Total_Genesys_Care__c, '
                                +'BigMachines__Quote__r.Duration_Unit__c, BigMachines__Quote__r.BigMachines__Opportunity__r.ID,'
                                +'BigMachines__Quote__r.Quote_Opportunity_Type__c,'
                                +'BigMachines__Quote__r.CurrencyIsoCode,'
                                +'BigMachines__Quote__r.Name, BigMachines__Quote__r.BigMachines__Opportunity__r.Name,'
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Opportunity_Owner__r.Name,'
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.StageName ,'
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.CloseDate,'
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.ForecastStatus__c,'
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Country_Sub_Region__c,'
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Account.Name,'
            					+'BigMachines__Quote__r.Order__r.Net_Suite_Order__c, '
                                +'BigMachines__Quote__r.Order__r.Order_Number__c,'
            					+'BigMachines__Quote__r.BigMachines__Opportunity__c, BigMachines__Quote__r.BigMachines__Opportunity__r.Service_Contract__c,'
                                +'BigMachines__Quote__r.Sold_To_Name__r.Region__c';
        
        String query = 'SELECT ' + fieldsToQuery + ' FROM BigMachines__Quote_Product__c WHERE '+ filterCondition + ' LIMIT 10';
        GenesysCareForecastingUtil.generateForeCastByProducts(Database.query(query));
        
        // Test Case for GenesysCareForecastingUtil.prepareGenesysCareForeCastingRollupObject()
        Integer rollupRecordsCount = [SELECT Count() FROM Genesys_Care_Forecasting_Rollup__c];
        if(rollupRecordsCount == 0){
            Integer minYear = Date.Today().year();
            Integer maxYear = minYear + 1;
            List<Genesys_Care_Forecasting_Rollup__c> rollupRecords = new List<Genesys_Care_Forecasting_Rollup__c>();
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
        GenesysCareForecastingUtil.prepareGenesysCareForeCastingRollupObject();
        
    }
}