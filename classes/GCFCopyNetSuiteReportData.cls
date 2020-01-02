global class GCFCopyNetSuiteReportData implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
        String query = 'SELECT End_User_Name__c, End_User_GARN_Code__c, End_User_Subsidiary_ID__c, Sold_To_Name__c, Sold_To_GARN_Code__c, Sold_To_Subsidiary_ID__c, '
					 + 'Revenue_Type__c, Region__c, Quote_Number__c, Order_Number__c, Posting_Amount__c, Posting_Amount_USD__c, Posting_Date__c, Status__c, '
					 + 'Posting_Month_Formula__c, Posting_Quarter_Formula__c, Posting_Year_Formula__c, Maintenance_Start_Date__c, Maintenance_End_Date__c, Offering_Type__c, Offering_Type_Formula__c '
        			 + 'FROM GCF_NetSuite_Data__c WHERE Offering_Type_Formula__c IN (\'PureEngage\', \'PureConnect\') ';
     
        if(Test.isRunningTest())
            query = query + ' LIMIT 10';
        return Database.getQueryLocator(query);
    }
	
	global void execute (Database.BatchableContext bc , List<sObject> scope){
    	List<GCF_Report_Data__c> gcfReportData = new List<GCF_Report_Data__c>();
    	for(sObject so : scope){
    		GCF_NetSuite_Data__c inputObj = (GCF_NetSuite_Data__c)so;
    		GCF_Report_Data__c outputObj = new GCF_Report_Data__c();
    		
    		outputObj.Incremental_R__c = 0.0;
    		outputObj.Incremental_E__c = 0.0;
    		outputObj.Incremental_U__c = 0.0;
    		outputObj.Incremental_TIV__c = 0.0;
    		outputObj.FYM_R__c = 0.0;
    		outputObj.FYM_U__c = 0.0;
    		outputObj.FYM_TIV__c = 0.0;
    		outputObj.BillingPlan_R__c = 0.0;
    		outputObj.BillingPlan_E__c = 0.0;
    		outputObj.BillingPlan_TIV__c = 0.0;
    		outputObj.Total_Booking_Forecast_E__c = 0.0;
    		outputObj.Total_Booking_Forecast_U__c = 0.0;
			outputObj.Deferred__c = inputObj.Revenue_Type__c == 'Deferred Revenue' ? inputObj.Posting_Amount__c : 0.0;
			outputObj.Recognized__c = inputObj.Revenue_Type__c == 'Recognized Revenue' ? inputObj.Posting_Amount__c : 0.0;

    		outputObj.Revenue_Type__c = inputObj.Revenue_Type__c;
    		outputObj.Region__c = inputObj.Region__c;
    		outputObj.Posting_Date__c = inputObj.Posting_Date__c;
    		outputObj.Maintenance_Start_Date__c = inputObj.Maintenance_Start_Date__c;
    		outputObj.Maintenance_End_Date__c = inputObj.Maintenance_End_Date__c;
    		outputObj.Month__c = Integer.valueOf(inputObj.Posting_Month_Formula__c);
    		outputObj.Month_Text__c = ''+Integer.valueOf(inputObj.Posting_Month_Formula__c);
    		outputObj.Quarter__c = Integer.valueOf(inputObj.Posting_Quarter_Formula__c);
    		outputObj.Quarter_Text__c = ''+Integer.valueOf(inputObj.Posting_Quarter_Formula__c);
    		outputObj.Year__c = Integer.valueOf(inputObj.Posting_Year_Formula__c);
    		outputObj.Year_Text__c = ''+Integer.valueOf(inputObj.Posting_Year_Formula__c);
    		outputObj.Reference_Opportunity__c = null;
    		outputObj.Reference_Service_Contract__c = null;
    		outputObj.Reference_Quote__c = inputObj.Quote_Number__c;
    		outputObj.Reference_Order__c = inputObj.Order_Number__c;
    		outputObj.End_User_Name__c  = inputObj.End_User_Name__c;
    		outputObj.End_User_GARN__c = inputObj.End_User_GARN_Code__c;
    		outputObj.End_User_Subsidiary_ID__c = inputObj.End_User_Subsidiary_ID__c;
    		outputObj.Sold_To_Name__c = inputObj.Sold_To_Name__c;
    		outputObj.Sold_To_GARN__c = inputObj.Sold_To_GARN_Code__c;
    		outputObj.Sold_To_Subsidiary_ID__c = inputObj.Sold_To_Subsidiary_ID__c;
    		outputObj.Forecast_Status__c = inputObj.Status__c;
    		outputObj.Offering_Type__c = inputObj.Offering_Type_Formula__c;
    		gcfReportData.add(outputObj);
    	}
    	Database.insert(gcfReportData);
    }
    
    global void finish(Database.BatchableContext bc){
    	GCF_NetSuite_Data__c netSuiteData = [SELECT CreatedDate FROM GCF_NetSuite_Data__c ORDER BY ID DESC LIMIT 1];
		Date maxDate = netSuiteData != NULL ? netSuiteData.CreatedDate.date() : Date.Today();
		List<NetSuite_Report_Data_Last_Imported__c> lastImportedDateList = [SELECT id, Name, Imported_Date__c FROM NetSuite_Report_Data_Last_Imported__c];
		
		if(lastImportedDateList.isEmpty()){
		    lastImportedDateList.add(new NetSuite_Report_Data_Last_Imported__c(Name='LastImported',Imported_Date__c = maxDate));
		} else {
		    lastImportedDateList[0].Imported_Date__c = maxDate;
		}
		Database.upsert(lastImportedDateList);
    }
}