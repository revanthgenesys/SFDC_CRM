/*
 * Class            : GCFTotalBookingForecastBatch
 * Description      : A Batch class to explode Genesys Care forecasting Data into GCF_Data__c Object for Total Booking Forecast Type.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : May 19, 2017
 * Test Class       : GCFAllTests   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 global class GCFTotalBookingForecastBatch implements Database.Batchable<sObject>{
	
    global Database.QueryLocator start(Database.BatchableContext bc){
 		String GenesysRenewalRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Genesys Renewal').getRecordTypeId();
    	String GenesysFYMRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GEN - Opportunity Record Type').getRecordTypeId();
	
 		String query 	= 'SELECT Id, Name, CurrencyIsoCode, '
 						+ 'Maintenance_Start_Date__c, Maintenance_End_Date__c, Total_Maintenance_Amount_Due_Formula__c,'
 						+ 'Opportunity_Close_Date__c, Forecast_Maint_End_Date__c, Order_Numb_of_Maint_Months__c, Total_Genesys_Care__c, '
		            	+ 'Order__c, Order__r.Status__c, Order__r.Invoice_Date__c, Sold_To_Name__r.Region__c, BigMachines__Account__r.Region__c, '
		            	+ 'BigMachines__Opportunity__c, BigMachines__Opportunity__r.PO_Expected_Date__c, BigMachines__Opportunity__r.RecordTypeId, BigMachines__Opportunity__r.Lines_of_Businesses__c '
		            	+ 'FROM BigMachines__Quote__c '
		                + 'WHERE BigMachines__Is_Primary__c = TRUE '
		            	+ 'AND ( (BigMachines__Opportunity__r.RecordTypeId = \''+GenesysFYMRT+'\' ' 
            			+ 'AND BigMachines__Opportunity__r.CloseDate = THIS_YEAR '       
                		+ 'AND BigMachines__Opportunity__r.StageName IN ( \'1.Understand Needs\',\'2.Define Requirements\',\'3.Evaluate Options\',\'4.Build Consensus\',\'5.Purchase Solution\',\'6.Closed\' ) '
                		+ 'AND BigMachines__Opportunity__r.ForecastStatus__c IN ( \'0.Booked\',\'1.In Hand\',\'2.Commit\',\'3.Expected\' ) '
                		+ 'AND BigMachines__Opportunity__r.Win_Loss_Status__c NOT IN ( \'Lost\',\'Merged/Dup Opp\' ) '
                		+ 'AND BigMachines__Opportunity__r.Opportunity_Owner__r.Name NOT IN ( \'Brian Jonkman\',\'Superstar AE\',\'Pushpa Ramachandran\',\'Gina Martinez\' ) '
                		+ 'AND BigMachines__Opportunity__r.Account.Name NOT IN ( \'ABC Testing\' ) '
                		+ 'AND BigMachines__Opportunity__r.Name NOT IN ( \'test\',\'renewal\',\'CMRR\',\'upgrade\',\'downgrade\' ) '
                		+ 'AND BigMachines__Opportunity__r.Has_PPU_Usage__c = FALSE '
                		+ 'AND BigMachines__Opportunity__r.Primary_Line_of_Business__c =\'On Premise\' '
                		+ 'AND Total_Genesys_Care__c > 0 '
                		+ 'AND Forecast_Maint_End_Date__c > TODAY ) '
                		+ ' OR '                
		            	+ '(BigMachines__Opportunity__r.RecordTypeId = \''+GenesysRenewalRT+'\' '
		            	+ 'AND BigMachines__Opportunity__r.CloseDate = THIS_QUARTER '       
		            	+ 'AND BigMachines__Opportunity__r.Opportunity_Status__c NOT IN (\'Prior Siebel\',\'Cancelled\',\'Dropped\',\'Drop\',\'Non Renewed\',\'Duplicate\',\'Declined\',\'Closed-CoTerm\',\'CoTerm Pending\',\'CO-Term Closed\',\'CO-Term Pending\',\'Closed Transferred\',\'Hypothetical\') '
		                + 'AND (NOT BigMachines__Opportunity__r.Name LIKE \'PPU%\') '
		                + 'AND (NOT BigMachines__Opportunity__r.Name LIKE \'CAS%\') ) )';
		                
 		if(Test.isRunningTest())
            query = query + ' LIMIT 10';          	
        return Database.getQueryLocator(query);
    }
    
     global void execute(Database.BatchableContext bc, List<Sobject> scope){
     	
		Date quarterStartDate;
    	Integer month = Date.today().month();
    	if(month == 1 || month == 2 || month == 3)
            quarterStartDate = Date.newInstance(Date.Today().Year(), 1, 1);
        else if(month == 4 || month == 5 || month == 6)
            quarterStartDate = Date.newInstance(Date.Today().Year(), 4, 1);
        else if(month == 7 || month == 8 || month == 9)
            quarterStartDate = Date.newInstance(Date.Today().Year(), 7, 1);
        else if(month == 10 || month == 11 || month == 12)
            quarterStartDate = Date.newInstance(Date.Today().Year(), 10, 1);     	
     	
     	Set<String> quoteNames = new Set<String>();
     	for(sObject so : scope){
     		BigMachines__Quote__c quote = (BigMachines__Quote__c)so;
     		quoteNames.add(quote.Name);
     	}
        
        Set<String> netSuiteQuoteNames = new Set<String>();
     	for(GCF_NetSuite_Data__c  gcfNetSuiteData : [SELECT id, Name, Quote_Number__c  FROM GCF_NetSuite_Data__c WHERE Revenue_Type__c = 'Deferred Revenue' AND Quote_Number__c IN :quoteNames]){
     		netSuiteQuoteNames.add(gcfNetSuiteData.Quote_Number__c);
     	}
     	
     	String GenesysRenewalRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Genesys Renewal').getRecordTypeId();
    	String GenesysFYMRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GEN - Opportunity Record Type').getRecordTypeId();
     	
		List<GCF_Data__c> forecastingData = new List<GCF_Data__c>();
        for(sObject so : scope){
            BigMachines__Quote__c quote = (BigMachines__Quote__c)so;
            if(!netSuiteQuoteNames.contains(quote.Name)  
            	&& 
            	( 
            		(quote.BigMachines__Opportunity__r.RecordTypeId == GenesysFYMRT && quote.Opportunity_Close_Date__c != NULL && quote.Order_Numb_of_Maint_Months__c > 0)
            		||
            		(quote.BigMachines__Opportunity__r.RecordTypeId == GenesysRenewalRT && quote.Maintenance_Start_Date__c != NULL && quote.Maintenance_End_Date__c != NULL && quote.Maintenance_Start_Date__c <  quote.Maintenance_End_Date__c)
            	)
            ){
	            Date startDate;
	            Date endDate; 
	            Decimal quoteAmount; 
	            
	            if(quote.BigMachines__Opportunity__r.RecordTypeId == GenesysRenewalRT){
					startDate = quote.Maintenance_Start_Date__c ;
				    endDate = quote.Maintenance_End_Date__c;   
				    quoteAmount = quote.Total_Maintenance_Amount_Due_Formula__c;   	
	            } else if(quote.BigMachines__Opportunity__r.RecordTypeId == GenesysFYMRT) {
	            	startDate = quote.Opportunity_Close_Date__c + 1;
				    endDate = startDate.addMonths(Integer.valueOf(quote.Order_Numb_of_Maint_Months__c)) - 1;
				    quoteAmount = quote.Total_Genesys_Care__c;
	            }
	            
	            // *** ADDED LOGIC FOR FULL AMOUNT POSTING
	            Date cutOffDate;
				    		
		    	if(quote.Order__c != NULL && quote.Order__r.Invoice_Date__c != NULL)
		    		cutOffDate = Date.newInstance(quote.Order__r.Invoice_Date__c.year(), quote.Order__r.Invoice_Date__c.month(), 1);
		    	else if(quote.BigMachines__Opportunity__r.PO_Expected_Date__c != NULL) 
		    		cutOffDate = Date.newInstance(quote.BigMachines__Opportunity__r.PO_Expected_Date__c.year(), quote.BigMachines__Opportunity__r.PO_Expected_Date__c.month(), 1);
		    	else if(startDate.toStartOfMonth() > Date.Today().toStartOfMonth())
		    		cutOffDate = Date.newInstance(startDate.year(),startDate.month(), 1);
		    	else
		    		cutOffDate = Date.newInstance(Date.Today().year(),Date.Today().month(), 1);

	            String invoicedWhen = '';
				if(cutOffDate.toStartOfMonth() < startDate.toStartOfMonth()){
					invoicedWhen = 'BEFORE';
				} else if(cutOffDate.toStartOfMonth() > endDate.toStartOfMonth()){
					invoicedWhen = 'AFTER';
				} else {
					invoicedWhen = 'BETWEEN';
				}				
			
				// If Invoice date not in between Support_Period_Start_Date__c,  Support_Period_End_Date__c, then make an entry for TIV beacuse the loop wont cover this case
				if((invoicedWhen == 'BEFORE' || invoicedWhen == 'AFTER') && endDate.toStartOfMonth() >= quarterStartDate){
					if(cutOffDate.toStartOfMonth() >= quarterStartDate){
						forecastingData.add(getGCFRecord(quote, cutOffDate, startDate, endDate, GCFUtil.convertCurrency(quoteAmount, quote.CurrencyIsoCode, 'USD')));
					}
				} else {
		            // *** ADDED LOGIC FOR FULL AMOUNT POSTING
		            
		            Integer monthsCount = startDate.monthsBetween(endDate) + 1;
					Integer daysCount = startDate.daysBetween(endDate) + 1;
					if(daysCount <= 0)
						daysCount = 1;
			
					Decimal amountInUSD = GCFUtil.convertCurrency(quoteAmount, quote.CurrencyIsoCode, 'USD');
					Decimal dailyAmountInUSD = amountInUSD/ daysCount;
					Date tempDate = Date.newInstance(startDate.year(), startDate.month(), 1);
		            
		            Decimal cummlativeValueTillDate = 0.0; 
					for(integer i = 0; i < monthsCount; i++){
						Date monthStartDate = tempDate.addMonths(i);
						Date monthEndDate = Date.newInstance(monthStartDate.year(), monthStartDate.month(), Date.daysInMonth(monthStartDate.year(), monthStartDate.month()));
			
			        	Date postingDate = tempDate.addMonths(i);
		
						GCF_Data__c record = new GCF_Data__c();
						record.Revenue_Type__c = 'Total Booking Forecast';
						record.CurrencyIsoCode = 'USD';
						record.Posting_Date__c = monthStartDate;
						record.Year__c = monthStartDate.year();
						record.Year_Text__c = ''+monthStartDate.year();
						record.Month__c = monthStartDate.month();
						record.Month_Text__c = ''+monthStartDate.month();
						record.Quarter__c = GCFUtil.getQuarter(monthStartDate.month());
						record.Quarter_Text__c = ''+GCFUtil.getQuarter(monthStartDate.month());
						record.Region__c = (quote.BigMachines__Account__r.Region__c == 'LATAM' ? 'Latin America' : quote.BigMachines__Account__r.Region__c);
						record.Reference_Quote__c = quote.Id;
						record.Reference_Order__c = quote.Order__c;
						record.Reference_Opportunity__c = quote.BigMachines__Opportunity__c;
						record.Maintenance_Start_Date__c = startDate;
						record.Maintenance_End_Date__c = endDate;
						record.Offering_Type__c = quote.BigMachines__Opportunity__r.Lines_of_Businesses__c != NULL ? quote.BigMachines__Opportunity__r.Lines_of_Businesses__c : 'PureEngage';
								
						Decimal recordAmount; 
			 			if(i == 0){
			            	Integer startDay =  startDate.day() ;
			                Integer daysInMonth = Date.daysInMonth(startDate.year(), startDate.month());
			                recordAmount = dailyAmountInUSD * (daysInMonth - startDay + 1);
						} else if (i == (monthsCount-1)){
			            	Integer endDay =  endDate.day() ;
			                recordAmount = dailyAmountInUSD * endDay; 
						} else {
			            	recordAmount = dailyAmountInUSD * Date.daysInMonth(monthStartDate.year(), monthStartDate.month()); 
						}
							
						record.Total_Booking_Forecast_E__c = 0.0;
						record.Total_Booking_Forecast_U__c = 0.0;
						if(quote.Order__c != NULL 
							&& (
								 (quote.Order__r.Status__c == 'Completed' || quote.Order__r.Status__c == 'Approved') && quote.BigMachines__Opportunity__r.RecordTypeId == GenesysRenewalRT)
								 ||
								 (quote.Order__r.Status__c == 'Completed' && quote.BigMachines__Opportunity__r.RecordTypeId == GenesysFYMRT) 
							
						)
						{
							record.Total_Booking_Forecast_E__c = recordAmount;
						} 
						record.Total_Booking_Forecast_U__c = recordAmount;
						
						// Add records only the Posting Date is from begining of this quarter 
						if(monthStartDate >= quarterStartDate)
							forecastingData.add(record); 
		            }
				}
            }
        }
       	Database.insert(forecastingData);     	
     }
     
     global void finish(Database.BatchableContext bc){
     	if(!Test.isRunningTest()){
        	Database.executeBatch(new GCFReportDataCleanupBatch(), 2000);
        }
     }
     
     public GCF_Data__c getGCFRecord(BigMachines__Quote__c quote, Date cutOffDate,Date startDate, Date endDate, Decimal amountInUSD){
    	GCF_Data__c record = new GCF_Data__c();
		record.CurrencyIsoCode = 'USD';
		record.Revenue_Type__c = 'Incremental Revenue';
		record.Posting_Date__c = cutOffDate.toStartOfMonth();
		record.Year__c = cutOffDate.year();
		record.Year_Text__c = ''+cutOffDate.year();
		record.Month__c = cutOffDate.month();
		record.Month_Text__c = ''+cutOffDate.month();
		record.Quarter__c = GCFUtil.getQuarter(cutOffDate.month());
		record.Quarter_Text__c = ''+GCFUtil.getQuarter(cutOffDate.month());
		record.Region__c = (quote.BigMachines__Account__r.Region__c == 'LATAM' ? 'Latin America' : quote.BigMachines__Account__r.Region__c);
		record.Reference_Quote__c = quote.Id;
		record.Reference_Order__c = quote.Order__c;
		record.Reference_Opportunity__c = quote.BigMachines__Opportunity__c;
		record.Maintenance_Start_Date__c = startDate;
		record.Maintenance_End_Date__c = endDate;
		record.Total_Booking_Forecast_E__c = 0.0;
		record.Total_Booking_Forecast_U__c = amountInUSD;
		record.Offering_Type__c = quote.BigMachines__Opportunity__r.Lines_of_Businesses__c != NULL ? quote.BigMachines__Opportunity__r.Lines_of_Businesses__c : 'PureEngage';	
		
        return record;        		
    }
}