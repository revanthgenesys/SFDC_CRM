/*
 * Class			: GenesysCareForecastingFYMBatch
 * Description		: This Batch Class generates data for First Year Maintenance forecasting.
 * Author			: Narasimha "Rao" Tumma
 * Created Date		: Dec 19, 2016
 * Test Class		: GenesysCareForecastingBatchesTest	 
 */
global class GenesysCareForecastingFYMBatch implements Database.Batchable<SObject>{
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        ID oppRecordTypeIDFilter = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GEN - Opportunity Record Type').getRecordTypeId();
        // Products filtering condition for FYM
        String filterCondition = 'Product_Name__c LIKE \'%care%\' AND ' 
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.RecordTypeId =:oppRecordTypeIDFilter AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.StageName IN ( ' + Label.GenesysCareForecasting_FYM_OppStages_Filter + ' ) AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.ForecastStatus__c IN ( ' + Label.GenesysCareForecasting_FYM_OppForecastStatus_Filter + ' ) AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Win_Loss_Status__c NOT IN ( ' + Label.GenesysCareForecasting_FYM_OppWinLossStatus_Filter + ' ) AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Opportunity_Owner__r.Name NOT IN ( ' + Label.GenesysCareForecasting_FYM_OppOwnerNames_Filter + ' ) AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Account.Name NOT IN ( ' + Label.GenesysCareForecasting_FYM_OppAccountNames_Filter + ' ) AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Name NOT IN ( ' + Label.GenesysCareForecasting_FYM_OppNames_Filter + ' ) AND '
                                +'BigMachines__Quote__r.BigMachines__Is_Primary__c = TRUE AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Has_PPU_Usage__c = FALSE AND '
                                +'BigMachines__Quote__r.BigMachines__Opportunity__r.Primary_Line_of_Business__c =\'On Premise\' AND '
                                +'BigMachines__Quote__r.Total_Genesys_Care__c != 0 AND '
                                +'(NOT Product_Name__c  like \'%3rd%\') AND '
                                +'BigMachines__Quote__r.Forecast_Maint_End_Date__c > TODAY AND '
            					+'BigMachines__Quote__r.BigMachines__Opportunity__r.CloseDate > LAST_YEAR';
        
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
                                +'BigMachines__Quote__r.Net_Price_Lic_Sw_Srvcs_Edu_Discounts__c,'
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
        
        String query = 'SELECT ' + fieldsToQuery + ' FROM BigMachines__Quote_Product__c WHERE '+ filterCondition;
        if(Test.isRunningTest())
            query = query + ' LIMIT 10';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        // Collect all quotes ids 
        Set<String> quoteNumbers = new Set<String>();
        for(SObject so: scope){
            BigMachines__Quote_Product__c quoteProduct = (BigMachines__Quote_Product__c)so;
            if(String.isNotBlank(quoteProduct.BigMachines__Quote__c))
            	quoteNumbers.add(quoteProduct.BigMachines__Quote__c);
        }
        
        // Collect all Net_Suite_Order__c from associcated order on those quotes
        Set<String> orderNumbers = new Set<String>();
        for(Order__c order: [SELECT Id, Net_Suite_Order__c FROM Order__c WHERE Quote__c IN : quoteNumbers]){
            if(String.isNotBlank(order.Net_Suite_Order__c))
            	orderNumbers.add(order.Net_Suite_Order__c);
        }
        
        // Check if the quote product has already processed from NetSuite data 
        Set<String> orderNumbersAlreadyProcessed = new Set<String>();
        for(Genesys_Care_Forecasting__c gcf : [SELECT SO_Number__c FROM Genesys_Care_Forecasting__c WHERE SO_Number__c IN : orderNumbers 
                                               AND SO_Number__c != NULL AND Revenue_Type__c IN ('Billing Schedule', 'Deferred Revenue', 'Recognized Revenue')])
        {
			orderNumbersAlreadyProcessed.add(gcf.SO_Number__c);
        }
        
    	List<BigMachines__Quote_Product__c> productsToProcess = new List<BigMachines__Quote_Product__c>();
        for(SObject so: scope){
            BigMachines__Quote_Product__c quoteProduct = (BigMachines__Quote_Product__c)so;
            if(!orderNumbersAlreadyProcessed.contains(quoteProduct.BigMachines__Quote__r.Order__r.Net_Suite_Order__c)){
                productsToProcess.add(quoteProduct);
            }
        }
	    // Process only rows that does not have orders info from NetSuite Data    
        if(productsToProcess.size() > 0){
            List<Genesys_Care_Forecasting__c> forecastingData = new List<Genesys_Care_Forecasting__c>();
            forecastingData.addAll(GenesysCareForecastingUtil.generateForeCastByProducts(productsToProcess));
    		if(forecastingData.size() > 0)
                Insert forecastingData;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        if(!Test.isRunningTest()){
            GenesysCareForecastingUtil.prepareGenesysCareForeCastingRollupObject();
            Database.executeBatch(new GenesysCareForeCastingRollupBatch(), 1);
        }
        	
    }
}