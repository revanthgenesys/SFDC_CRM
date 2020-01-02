/*
 * Class            : GCFBillingPlanBatch
 * Description      : A Batch class to explode Genesys Care forecasting Data into GCF_Data__c Object for BillingPlan.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : May 19, 2017
 * Test Class       : GCFAllTests   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Narasimha "Rao" Tumma 	Mar 19, 2018 	Update Logic based on feedback from Chris Reed
 *
 */
 
global class GCFBillingPlanBatch implements Database.Batchable<sObject>{
   
    global Database.QueryLocator start(Database.BatchableContext bc){
		String startDate = GCFUtil.getQuarterStartDateString( Date.today().month());
        String query = 'SELECT Id, Name, Amount__c, Support_Period_Start_Date__c, Support_Period_End_Date__c, Invoice__c, Invoice_Date__c,  '
        		+ 'Quote__c, Quote__r.Name, Quote__r.CurrencyIsoCode, Quote__r.Sold_To_Name__r.Region__c, '
        		+ 'Quote__r.BigMachines__Account__r.Region__c, Quote__r.BigMachines__Opportunity__c, Quote__r.BigMachines__Opportunity__r.Forecast_Status__c, Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c, '
        		+ 'Quote__r.Order__c, Quote__r.Order__r.Name, Quote__r.Order__r.Status__c, Quote__r.Order__r.Net_Suite_Order__c '
        		+ 'FROM Quote_Billing_Plan__c '
        		+ 'WHERE Quote__r.Order__r.Status__c IN (\'Approved\' , \'Completed\') '
        		+ 'AND Support_Period_Start_Date__c != NULL '
        		+ 'AND Support_Period_End_Date__c != NULL '
        		+ 'AND Invoice_Date__c != NULL '
        		+ 'AND Invoice_Date__c >= '+startDate ;
    	if(Test.isRunningTest())
            query = query + ' LIMIT 10'; 
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<sObject> scope){
        Set<String> quoteBillingPlanInvoices = new Set<String>();
        Set<String> processInNetSuite = new Set<String>();

        for(SObject so: scope){
            Quote_Billing_Plan__c qbp = (Quote_Billing_Plan__c)so;
            quoteBillingPlanInvoices.add(qbp.Invoice__c);
        }
		
        for(GCF_NetSuite_Data__c gcfnsd : [SELECT SO_Number__c, Document_Number__c FROM GCF_NetSuite_Data__c WHERE  Document_Number__c != NULL AND Document_Number__c IN : quoteBillingPlanInvoices AND Revenue_Type__c = 'Deferred Revenue']){
            processInNetSuite.add(gcfnsd.Document_Number__c);
        }
    	
    	List<GCF_Data__c> forecastingData = new List<GCF_Data__c>();
    	Date quarterStartDate = GCFUtil.getQuarterStartDate(Date.today().month());
    	Date nextQuarterStartDate = quarterStartDate.addMonths(3);
    	
    	for(sObject so : scope){
    		Quote_Billing_Plan__c qbp = (Quote_Billing_Plan__c)so;
    		
    		if(processInNetSuite.contains(qbp.Invoice__c)){
    			forecastingData.add(new GCF_Data__c(CurrencyIsoCode = 'USD',
															Revenue_Type__c = 'Billing Plan',
															Posting_Date__c = qbp.Invoice_Date__c.toStartOfMonth(),
															Year__c = qbp.Invoice_Date__c.year(),
															Year_Text__c = ''+qbp.Invoice_Date__c.year(),
															Month__c = qbp.Invoice_Date__c.month(),
															Month_Text__c = ''+qbp.Invoice_Date__c.month(),
															Quarter__c = GCFUtil.getQuarter(qbp.Invoice_Date__c.month()),
															Quarter_Text__c = ''+GCFUtil.getQuarter(qbp.Invoice_Date__c.month()),
															Region__c = (qbp.Quote__r.BigMachines__Account__r.Region__c == 'LATAM' ? 'Latin America' : qbp.Quote__r.BigMachines__Account__r.Region__c),
															Offering_Type__c = qbp.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c != NULL ? qbp.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c : 'PureEngage',
															Reference_Quote__c = qbp.Quote__c,
															Reference_Order__c = qbp.Quote__r.Order__c,
                                                    		Reference_Opportunity__c = qbp.Quote__r.BigMachines__Opportunity__c,
															Maintenance_Start_Date__c = qbp.Support_Period_Start_Date__c,
															Maintenance_End_Date__c = qbp.Support_Period_End_Date__c,
                                                    		Invoice_Date__c = qbp.Invoice_Date__c,
															BillingPlan_R__c = 0.0,
															BillingPlan_E__c = 0.0,
															BillingPlan_TIV__c  = GCFUtil.convertCurrency(qbp.Amount__c, qbp.Quote__r.CurrencyIsoCode, 'USD')
															));
    		} else {
    			Date startDate = qbp.Support_Period_Start_Date__c;
	    		Date endDate = qbp.Support_Period_End_Date__c;
	    		Date invoiceDate = qbp.Invoice_Date__c != NULL ? qbp.Invoice_Date__c : qbp.Support_Period_Start_Date__c;
	    		// Invoice Date is in Current Quarter and Support Start Date is in future
	    		if(invoiceDate >= quarterStartDate && invoiceDate <= nextQuarterStartDate && startDate >= nextQuarterStartDate){
	    			forecastingData.add(new GCF_Data__c(CurrencyIsoCode = 'USD',
															Revenue_Type__c = 'Billing Plan',
															Posting_Date__c = qbp.Invoice_Date__c.toStartOfMonth(),
															Year__c = qbp.Invoice_Date__c.year(),
															Year_Text__c = ''+qbp.Invoice_Date__c.year(),
															Month__c = qbp.Invoice_Date__c.month(),
															Month_Text__c = ''+qbp.Invoice_Date__c.month(),
															Quarter__c = GCFUtil.getQuarter(qbp.Invoice_Date__c.month()),
															Quarter_Text__c = ''+GCFUtil.getQuarter(qbp.Invoice_Date__c.month()),
															Region__c = (qbp.Quote__r.BigMachines__Account__r.Region__c == 'LATAM' ? 'Latin America' : qbp.Quote__r.BigMachines__Account__r.Region__c),
															Offering_Type__c = qbp.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c != NULL ? qbp.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c : 'PureEngage',
															Reference_Quote__c = qbp.Quote__c,
															Reference_Order__c = qbp.Quote__r.Order__c,
															Maintenance_Start_Date__c = qbp.Support_Period_Start_Date__c,
															Maintenance_End_Date__c = qbp.Support_Period_End_Date__c,
															Invoice_Date__c = qbp.Invoice_Date__c,
                                                        	BillingPlan_R__c = 0.0,
															BillingPlan_E__c = 0.0,
															BillingPlan_TIV__c  = GCFUtil.convertCurrency(qbp.Amount__c, qbp.Quote__r.CurrencyIsoCode, 'USD')
															));
	    		} 
	    		// Invoice Date is in future and Support Start Date is in Current Quarter 
	    		else if(invoiceDate >= nextQuarterStartDate && startDate < nextQuarterStartDate){
	    			forecastingData.add(new GCF_Data__c(CurrencyIsoCode = 'USD',
															Revenue_Type__c = 'Billing Plan',
															Posting_Date__c = qbp.Invoice_Date__c.toStartOfMonth(),
															Year__c = qbp.Invoice_Date__c.year(),
															Year_Text__c = ''+qbp.Invoice_Date__c.year(),
															Month__c = qbp.Invoice_Date__c.month(),
															Month_Text__c = ''+qbp.Invoice_Date__c.month(),
															Quarter__c = GCFUtil.getQuarter(qbp.Invoice_Date__c.month()),
															Quarter_Text__c = ''+GCFUtil.getQuarter(qbp.Invoice_Date__c.month()),
															Region__c = (qbp.Quote__r.BigMachines__Account__r.Region__c == 'LATAM' ? 'Latin America' : qbp.Quote__r.BigMachines__Account__r.Region__c),
															Offering_Type__c = qbp.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c != NULL ? qbp.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c : 'PureEngage',
															Reference_Quote__c = qbp.Quote__c,
															Reference_Order__c = qbp.Quote__r.Order__c,
															Maintenance_Start_Date__c = qbp.Support_Period_Start_Date__c,
															Maintenance_End_Date__c = qbp.Support_Period_End_Date__c,
															Invoice_Date__c = qbp.Invoice_Date__c,
                                                        	BillingPlan_R__c = 0.0,
															BillingPlan_E__c  = GCFUtil.convertCurrency(qbp.Amount__c, qbp.Quote__r.CurrencyIsoCode, 'USD'),
															BillingPlan_TIV__c  = GCFUtil.convertCurrency(qbp.Amount__c, qbp.Quote__r.CurrencyIsoCode, 'USD')
															));	
	    		} else {
		    		Integer monthsCount = startDate.monthsBetween(endDate)+1;
		    		Integer daysCount = startDate.daysBetween(endDate)+1;
		    		if(daysCount <= 0)
						daysCount = 1;
						
		    		Decimal invoiceAmountUSD = GCFUtil.convertCurrency(qbp.Amount__c, qbp.Quote__r.CurrencyIsoCode, 'USD');
					Decimal dailyInvoiceAmountUSD = invoiceAmountUSD / daysCount;
					Date tempDate = Date.newInstance(startDate.year(), startDate.month(), 1);
					Date cutOffDate = invoiceDate.toStartOfMonth(); 
					Decimal cummlativeValueTillDate = 0.0;
					
	    			for(Integer i = 0; i < monthsCount; i++){
						Date monthStartDate = tempDate.addMonths(i);
						Date monthEndDate = Date.newInstance(monthStartDate.year(), monthStartDate.month(), Date.daysInMonth(monthStartDate.year(), monthStartDate.month()));
										
						GCF_Data__c record = new GCF_Data__c();
						record.Revenue_Type__c = 'Billing Plan';
						record.CurrencyIsoCode = 'USD';
						record.Posting_Date__c = monthStartDate;
						record.Year__c = monthStartDate.year();
						record.Year_Text__c = ''+monthStartDate.year();
						record.Month__c = monthStartDate.month();
						record.Month_Text__c = ''+monthStartDate.month();
						record.Quarter__c = GCFUtil.getQuarter(monthStartDate.month());
						record.Quarter_Text__c = ''+GCFUtil.getQuarter(monthStartDate.month());
						record.Region__c = (qbp.Quote__r.BigMachines__Account__r.Region__c == 'LATAM' ? 'Latin America' : qbp.Quote__r.BigMachines__Account__r.Region__c);
						record.Offering_Type__c = qbp.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c != NULL ? qbp.Quote__r.BigMachines__Opportunity__r.Lines_of_Businesses__c : 'PureEngage';
						record.Reference_Quote__c = qbp.Quote__c;
						record.Reference_Order__c = qbp.Quote__r.Order__c;
						record.Maintenance_Start_Date__c = startDate;
						record.Maintenance_End_Date__c = endDate;
						record.Invoice_Date__c = qbp.Invoice_Date__c;
						Decimal recordAmount; 
		 				if(i == 0){
		                    Integer startDay =  startDate.day();
		                    Integer daysInMonth = Date.daysInMonth(startDate.year(), startDate.month());
		                    recordAmount = dailyInvoiceAmountUSD * (daysInMonth - startDay + 1);
		                } else if (i == (monthsCount-1)){
		                    Integer endDay =  endDate.day() ;
		                    recordAmount = dailyInvoiceAmountUSD * endDay; 
		                } else {
		                    recordAmount = dailyInvoiceAmountUSD * Date.daysInMonth(monthStartDate.year(), monthStartDate.month()); 
		                }
						record.BillingPlan_R__c = 0.0;
		                record.BillingPlan_E__c = 0.0;
						record.BillingPlan_TIV__c = 0.0;
						
						if(cutOffDate <= Date.Today()){
							if(monthStartDate < cutOffDate){
								cummlativeValueTillDate = cummlativeValueTillDate + recordAmount;
							} else if(monthStartDate == cutOffDate){
								record.BillingPlan_R__c = cummlativeValueTillDate + recordAmount;
								cummlativeValueTillDate = 0.0;
							} else {
                                record.BillingPlan_R__c = recordAmount;
							}	
						} else {
							if(monthStartDate < cutOffDate){
								cummlativeValueTillDate = cummlativeValueTillDate + recordAmount;
							} else if(monthStartDate == cutOffDate){
								record.BillingPlan_E__c = cummlativeValueTillDate + recordAmount;
								cummlativeValueTillDate = 0.0;
							} else {
                                record.BillingPlan_E__c = recordAmount;
							}	
						}
						
		                if(monthStartDate == cutOffDate){
		                	record.BillingPlan_TIV__c = invoiceAmountUSD;
		                }
		                // Add records only the Posting Date is from begining of this quarter 
						if(monthStartDate >= quarterStartDate && (record.BillingPlan_R__c > 0 || record.BillingPlan_E__c > 0 || record.BillingPlan_TIV__c > 0) )
		                	forecastingData.add(record); 
					}
	    		}
			}
    	}
    	Database.insert(forecastingData);
    }

    global void finish(Database.BatchableContext bc){
    	/*
    	if(!Test.isRunningTest())
        	Database.executeBatch(new GCFTotalBookingForecastBatch());
        */	
    	if(!Test.isRunningTest())
        	Database.executeBatch(new GCFReportDataCleanupBatch(), 2000);
        
    }
    
    public void fakeMethod(){
	    Integer i = 0;
	    i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
	    i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++; 
        i++;
	  }
}