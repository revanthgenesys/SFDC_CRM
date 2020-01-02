global class GCFCopyReportData implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc){
    	
        String query = 'SELECT Incremental_R__c, Incremental_E__c, Incremental_U__c, Incremental_TIV__c, Incremental_TIV_E__c, FYM_R__c, FYM_U__c, FYM_TIV__c, FYM_TIV_E__c, BillingPlan_R__c, BillingPlan_E__c, BillingPlan_TIV__c, Total_Booking_Forecast_E__c, Total_Booking_Forecast_U__c, '
        			 + 'Revenue_Type__c, Region__c, Posting_Date__c, Maintenance_End_Date__c, Maintenance_Start_Date__c, Month__c, Month_Text__c, Quarter__c, Quarter_Text__c, Year__c, Year_Text__c, '
        			 + 'Reference_Opportunity__r.Name, Reference_Opportunity__r.Opportunity_Status__c, Reference_Opportunity__r.Gene_Care_Specialist__r.Name, Reference_Opportunity__r.PO_Expected_Date__c,'
            		 + 'Reference_Opportunity__r.Forecast_Status__c, Reference_Order__r.Name, Reference_Order__r.Invoice_Date__c, Reference_Order__r.Invoice_Number__c, '
        			 + 'Reference_Quote__c, Reference_Quote__r.Name, Reference_Quote__r.End_User_ID__r.Name, Reference_Quote__r.End_User_ID__r.SAP_Account_Code__c, Reference_Quote__r.End_User_ID__r.Subsidary__r.Name, '
        			 + 'Reference_Quote__r.Sold_To_Name__r.Name, Reference_Quote__r.Sold_To_Name__r.SAP_Account_Code__c, Reference_Quote__r.Sold_To_Name__r.Subsidary__r.Name, '
        			 + 'Reference_Quote__r.BigMachines__Opportunity__r.Forecast_Status__c, Reference_Quote__r.End_User_ID__r.Country__r.Name, Reference_Quote__r.End_User_ID__r.Country__r.SubRU__c,'
        			 + 'Reference_Service_Contract__r.Name, Reference_Service_Contract__r.End_User_Name__r.Name, Reference_Service_Contract__r.End_User_Name__r.SAP_Account_Code__c, Reference_Service_Contract__r.End_User_Name__r.Subsidary__r.Name, '
        			 + 'Reference_Service_Contract__r.Sold_To_Name__r.Name, Reference_Service_Contract__r.Sold_To_Name__r.SAP_Account_Code__c, Reference_Service_Contract__r.Sold_To_Name__r.Subsidary__r.Name, '
        			 + 'Reference_Service_Contract__r.End_User_Name__r.Country__r.Name, Reference_Service_Contract__r.End_User_Name__r.Country__r.SubRU__c, '
            		 + 'Reference_Service_Contract__r.Renewal_Opportunity__r.Forecast_Status__c,Reference_Opportunity__r.GC_Comments__c, Offering_Type__c, Invoice_Date_Final__c '
        			 + 'FROM GCF_Data__c WHERE  Offering_Type__c IN (\'PureEngage\', \'PureConnect\') ';
     	
        if(Test.isRunningTest())
            query = query + ' LIMIT 10';
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc , List<sObject> scope){
    	List<GCF_Report_Data__c> gcfReportData = new List<GCF_Report_Data__c>();
    	for(sObject so : scope){
    		GCF_Data__c inputObj = (GCF_Data__c)so;
    		GCF_Report_Data__c outputObj = new GCF_Report_Data__c();
    		
    		outputObj.Incremental_R__c = inputObj.Incremental_R__c != NULL ? inputObj.Incremental_R__c : 0.0;
    		outputObj.Incremental_E__c = inputObj.Incremental_E__c != NULL ? inputObj.Incremental_E__c : 0.0;
    		outputObj.Incremental_U__c = inputObj.Incremental_U__c != NULL ? inputObj.Incremental_U__c : 0.0;
    		outputObj.Incremental_TIV_E__c = inputObj.Incremental_TIV_E__c != NULL ? inputObj.Incremental_TIV_E__c : 0.0;
    		outputObj.Incremental_TIV__c = inputObj.Incremental_TIV__c != NULL ? inputObj.Incremental_TIV__c : 0.0;
    		
    		outputObj.FYM_R__c = inputObj.FYM_R__c != NULL ? inputObj.FYM_R__c : 0.0;
    		outputObj.FYM_U__c = inputObj.FYM_U__c != NULL ? inputObj.FYM_U__c : 0.0;
    		outputObj.FYM_TIV_E__c = inputObj.FYM_TIV__c != NULL ? inputObj.FYM_TIV_E__c : 0.0;
    		outputObj.FYM_TIV__c = inputObj.FYM_TIV__c != NULL ? inputObj.FYM_TIV__c : 0.0;
    		
    		outputObj.BillingPlan_R__c = inputObj.BillingPlan_R__c != NULL ? inputObj.BillingPlan_R__c : 0.0;
    		outputObj.BillingPlan_E__c = inputObj.BillingPlan_E__c != NULL ? inputObj.BillingPlan_E__c : 0.0;
    		outputObj.BillingPlan_TIV__c = inputObj.BillingPlan_TIV__c != NULL ? inputObj.BillingPlan_TIV__c : 0.0;
    		
    		outputObj.Total_Booking_Forecast_E__c = inputObj.Total_Booking_Forecast_E__c != NULL ? inputObj.Total_Booking_Forecast_E__c : 0.0;
    		outputObj.Total_Booking_Forecast_U__c = inputObj.Total_Booking_Forecast_U__c != NULL ? inputObj.Total_Booking_Forecast_U__c : 0.0;

			outputObj.Deferred__c = 0.0;
			outputObj.Recognized__c = 0.0;

    		outputObj.Revenue_Type__c = inputObj.Revenue_Type__c;
    		outputObj.Region__c = inputObj.Region__c;
    		outputObj.Posting_Date__c = inputObj.Posting_Date__c;
    		outputObj.Maintenance_Start_Date__c = inputObj.Maintenance_Start_Date__c;
    		outputObj.Maintenance_End_Date__c = inputObj.Maintenance_End_Date__c;
    		outputObj.Month__c = inputObj.Month__c;
    		outputObj.Month_Text__c = inputObj.Month_Text__c;
    		outputObj.Quarter__c = inputObj.Quarter__c;
    		outputObj.Quarter_Text__c = inputObj.Quarter_Text__c;
    		outputObj.Year__c = inputObj.Year__c;
    		outputObj.Year_Text__c = inputObj.Year_Text__c;
    		outputObj.Reference_Opportunity__c = inputObj.Reference_Opportunity__r.Name;
    		outputObj.Reference_Service_Contract__c = inputObj.Reference_Service_Contract__r.Name;
    		outputObj.Reference_Quote__c = inputObj.Reference_Quote__r.Name;
    		outputObj.Reference_Order__c = inputObj.Reference_Order__r.Name;
    		outputObj.Offering_Type__c = inputObj.Offering_Type__c;
            outputObj.Forecast_Status__c = inputObj.Reference_Opportunity__r.Forecast_Status__c;
            outputObj.Opportunity_Status__c = inputObj.Reference_Opportunity__r.Opportunity_Status__c;  
            outputObj.Genesys_Care_Specialist__c = inputObj.Reference_Opportunity__r.Gene_Care_Specialist__r.Name;
            // outputObj.Invoice_Date__c =  inputObj.Reference_Order__r.Invoice_Date__c;
            outputObj.Invoice_Date__c =  inputObj.Invoice_Date_Final__c;
            outputObj.Invoice_Number__c =  inputObj.Reference_Order__r.Invoice_Number__c;
			outputObj.PO_Expected_Date__c =  inputObj.Reference_Opportunity__r.PO_Expected_Date__c;
			outputObj.GC_comments__c=inputObj.Reference_Opportunity__r.GC_comments__c;

            if(inputObj.Reference_Quote__c != NULL){
	    		outputObj.End_User_Name__c  = inputObj.Reference_Quote__r.End_User_ID__r.Name;
	    		outputObj.End_User_GARN__c = inputObj.Reference_Quote__r.End_User_ID__r.SAP_Account_Code__c;
	    		outputObj.End_User_Subsidiary_ID__c = inputObj.Reference_Quote__r.End_User_ID__r.Subsidary__r.Name;
	    		outputObj.Sold_To_Name__c = inputObj.Reference_Quote__r.Sold_To_Name__r.Name;
	    		outputObj.Sold_To_GARN__c = inputObj.Reference_Quote__r.Sold_To_Name__r.SAP_Account_Code__c;
	    		outputObj.Sold_To_Subsidiary_ID__c = inputObj.Reference_Quote__r.Sold_To_Name__r.Subsidary__r.Name;
				outputObj.End_User_Country__c = inputObj.Reference_Quote__r.End_User_ID__r.Country__r.Name;
				outputObj.End_User_Sub_Region__c = inputObj.Reference_Quote__r.End_User_ID__r.Country__r.SubRU__c;                
                
    		} else {
    			outputObj.End_User_Name__c  = inputObj.Reference_Service_Contract__r.End_User_Name__r.Name;
	    		outputObj.End_User_GARN__c = inputObj.Reference_Service_Contract__r.End_User_Name__r.SAP_Account_Code__c;
	    		outputObj.End_User_Subsidiary_ID__c = inputObj.Reference_Service_Contract__r.End_User_Name__r.Subsidary__r.Name;
	    		outputObj.Sold_To_Name__c = inputObj.Reference_Service_Contract__r.Sold_To_Name__r.Name;
	    		outputObj.Sold_To_GARN__c = inputObj.Reference_Service_Contract__r.Sold_To_Name__r.SAP_Account_Code__c;
	    		outputObj.Sold_To_Subsidiary_ID__c = inputObj.Reference_Service_Contract__r.Sold_To_Name__r.Subsidary__r.Name;
                outputObj.End_User_Country__c = inputObj.Reference_Service_Contract__r.End_User_Name__r.Country__r.Name;
				outputObj.End_User_Sub_Region__c = inputObj.Reference_Service_Contract__r.End_User_Name__r.Country__r.SubRU__c;                
    		}
    		gcfReportData.add(outputObj);
    	}
    	Database.insert(gcfReportData);
    }
    
    global void finish(Database.BatchableContext bc){
		 if(!Test.isRunningTest() && GCFUtil.isNetSuiteReportDataImportNeeded()){
        	Database.executeBatch(new GCFCopyNetSuiteReportData(), 500);
        }
    }
}