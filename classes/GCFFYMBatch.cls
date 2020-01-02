/*
 * Class            : GCFFYMBatch
 * Description      : A Batch class to explode Genesys Care forecasting Data into GCF_Data__c Object for FYM.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : May 19, 2017
 * Test Class       : GCFAllTests   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 global class GCFFYMBatch implements Database.Batchable<sObject>{
	
    global Database.QueryLocator start(Database.BatchableContext bc){
    	ID GenesysFYMRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('GEN - Opportunity Record Type').getRecordTypeId();
		String quarterStartDate = GCFUtil.getQuarterStartDateString( Date.today().month());
 		String query 	= 'SELECT Id, Name, CurrencyIsoCode, Opportunity_Close_Date__c, Forecast_Maint_End_Date__c, Order_Numb_of_Maint_Months__c, Total_Genesys_Care__c, '
            	+ 'Order__c, Order__r.Status__c, Order__r.Invoice_Date__c, Order__r.Net_Suite_Order__c, Sold_To_Name__r.Region__c, BigMachines__Account__r.Region__c, '
            	+ 'BigMachines__Opportunity__c, BigMachines__Opportunity__r.PO_Expected_Date__c, BigMachines__Opportunity__r.Lines_of_Businesses__c, ' 
            	+ 'BigMachines__Opportunity__r.Forecast_Status__c, BigMachines__Opportunity__r.ForecastStatus__c '
            	+ 'FROM BigMachines__Quote__c '
            	+ 'WHERE BigMachines__Opportunity__r.RecordTypeId = \''+GenesysFYMRT+'\' ' 
            	+ 'AND BigMachines__Opportunity__r.CloseDate = THIS_YEAR '       
            	+ 'AND BigMachines__Opportunity__r.CloseDate >= '+quarterStartDate+' '
                + 'AND BigMachines__Opportunity__r.StageName IN ( \'1.Understand Needs\',\'2.Define Requirements\',\'3.Evaluate Options\',\'4.Build Consensus\',\'5.Purchase Solution\',\'6.Closed\' ) '
                + 'AND BigMachines__Opportunity__r.ForecastStatus__c IN ( \'0.Booked\',\'1.In Hand\',\'2.Commit\',\'3.Expected\' ) AND '
                + 'BigMachines__Opportunity__r.Win_Loss_Status__c NOT IN ( \'Lost\',\'Merged/Dup Opp\' ) AND '
                + 'BigMachines__Opportunity__r.Opportunity_Owner__r.Name NOT IN ( \'Brian Jonkman\',\'Superstar AE\',\'Pushpa Ramachandran\',\'Gina Martinez\' ) AND '
                + 'BigMachines__Opportunity__r.Account.Name NOT IN ( \'ABC Testing\' ) AND '
                + 'BigMachines__Opportunity__r.Name NOT IN ( \'test\',\'renewal\',\'CMRR\',\'upgrade\',\'downgrade\' ) AND '
                + 'BigMachines__Is_Primary__c = TRUE AND '
                + 'BigMachines__Opportunity__r.Has_PPU_Usage__c = FALSE AND '
                + 'BigMachines__Opportunity__r.Primary_Line_of_Business__c =\'On Premise\' ';
                // + ' AND id = \'a0d0B00000HCr6D\' ';
    	if(Test.isRunningTest())
            query = query + ' LIMIT 10';  
        return Database.getQueryLocator(query);
	}
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
    	
    	// Collect all Net_Suite_Order__c from associcated order on quotes
        Set<String> quoteNumbers = new Set<String>();
        Set<String> quoteIds = new Set<String>();
        for(SObject so: scope){
            BigMachines__Quote__c quote = (BigMachines__Quote__c)so;
            quoteIds.add(quote.Id);
            quoteNumbers.add(quote.Name);
        }
        
        Map<Id, List<Order__c>> quoteOrdersMap = new Map<Id, List<Order__c>>();
        for(Order__c order : [SELECT Id, Name, status__c, Invoice_Date__c, Quote__c, Net_Suite_Order__c, Invoice_Number__c FROM Order__c WHERE Quote__c IN : quoteIds AND Status__c != 'Cancelled']){
            if(quoteOrdersMap.keySet().contains(order.Quote__c)){
             	quoteOrdersMap.get(order.Quote__c).add(order);   
            } else {
                quoteOrdersMap.put(order.Quote__c, new List<Order__c>{order}); 
            }   
        }

    	// Check if the quote product has already processed from NetSuite data 
        Set<String> ordersInNetSuite = new Set<String>();
        Set<String> invoicesInNetSuite = new Set<String>();
        for(GCF_NetSuite_Data__c gcfnsd : [SELECT SO_Number__c, Document_Number__c FROM GCF_NetSuite_Data__c WHERE Quote_Number__c IN : quoteNumbers AND Revenue_Type__c = 'Deferred Revenue']){
			if(gcfnsd.SO_Number__c != NULL)
            	ordersInNetSuite.add(gcfnsd.SO_Number__c);
			if(gcfnsd.Document_Number__c != NULL)
            	invoicesInNetSuite.add(gcfnsd.Document_Number__c);
        }
    	
    	List<GCF_Data__c> forecastingData = new List<GCF_Data__c>();
    	Date quarterStartDate = GCFUtil.getQuarterStartDate(Date.today().month());
    	
        for(sObject so : scope){
            BigMachines__Quote__c quote = (BigMachines__Quote__c)so;
            Order__c orderProcessed;
            Boolean orderProcessedInNetSuite = false;
            if(quoteOrdersMap.keySet().contains(quote.Id)){
                for(Order__c order : quoteOrdersMap.get(quote.Id)){
                    if(ordersInNetSuite.contains(order.Net_Suite_Order__c)){
                    	orderProcessedInNetSuite = true;
                        orderProcessed = order;
                    } 
					if(invoicesInNetSuite.contains(order.Invoice_Number__c)){
                    	orderProcessedInNetSuite = true;
                        orderProcessed = order;
                    }	   
                }
            }
            // If Order is already processed in Net Suite, post only TIV 
            if(orderProcessedInNetSuite){
            	if(orderProcessed.Invoice_Date__c != NULL && orderProcessed.Invoice_Date__c >= quarterStartDate){
					forecastingData.add(getGCFRecord(quote));
            	}
			} // If Order is not Processed in Net Suite, follow the normal process to explode the ForeCasting Data
            else if( quote.Opportunity_Close_Date__c != NULL && quote.Order_Numb_of_Maint_Months__c > 0 
            		&& ( 
	            		(quote.Order__c != NULL && quote.Order__r.Status__c == 'Completed' && quote.Order__r.Invoice_Date__c >= quarterStartDate) 
	            		|| 
	            		(quote.Order__c != NULL && quote.Order__r.Status__c != 'Completed' && quote.Order__r.Status__c != 'Credit'  && quote.Order__r.Status__c != 'Rejected') 
	            		|| 
	            		quote.Order__c == NULL
	            	)
            ){
				Date startDate = quote.Opportunity_Close_Date__c + 1;
		        Date endDate = startDate.addMonths(Integer.valueOf(quote.Order_Numb_of_Maint_Months__c)) - 1;
		    	
		    	Date cutOffDate;
		    	if(quote.Order__c != NULL && quote.Order__r.Invoice_Date__c != NULL)
		    		cutOffDate = Date.newInstance(quote.Order__r.Invoice_Date__c.year(), quote.Order__r.Invoice_Date__c.month(), 1);
		    	else if(quote.BigMachines__Opportunity__r.PO_Expected_Date__c != NULL) 
		    		cutOffDate = Date.newInstance(quote.BigMachines__Opportunity__r.PO_Expected_Date__c.year(), quote.BigMachines__Opportunity__r.PO_Expected_Date__c.month(), 1);
		    	else if(startDate.toStartOfMonth() > Date.Today().toStartOfMonth())
		    		cutOffDate = Date.newInstance(startDate.year(),startDate.month(), 1);
		    	else 	
		    		cutOffDate = Date.newInstance(Date.Today().year(),Date.Today().month(), 1);
		
				Integer monthsCount = startDate.monthsBetween(endDate) + 1;
		    	Integer daysCount = startDate.daysBetween(endDate) + 1;

	            Decimal totalGenesysCare = quote.Total_Genesys_Care__c;
	            Decimal amountInUSD = GCFUtil.convertCurrency(totalGenesysCare, quote.CurrencyIsoCode, 'USD');
	            Decimal dailyAmountInUSD = amountInUSD/ daysCount;
				
				// If the cutOffDate is beyond the Maintenance End Date
				if(cutOffDate > endDate.toStartOfMonth() && endDate.toStartOfMonth() >= quarterStartDate){
					forecastingData.add(getGCFRecord(quote, cutOffDate, startDate, endDate, amountInUSD));
				} else{
					Date tempDate = Date.newInstance(startDate.year(), startDate.month(), 1);
		
					Decimal cummlativeValueTillDate = 0.0; 
		            for(integer i = 0; i < monthsCount; i++){
						Date monthStartDate = tempDate.addMonths(i);
						Date monthEndDate = Date.newInstance(monthStartDate.year(), monthStartDate.month(), Date.daysInMonth(monthStartDate.year(), monthStartDate.month()));
		
						GCF_Data__c record = new GCF_Data__c();
						record.Revenue_Type__c = 'First Year Maintenance';
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
			
						// Post Total Invoice Value to that month when the Invoice is expcected
						if(monthStartDate == cutOffDate){
							record.FYM_TIV__c = amountInUSD;
							if(quote.BigMachines__Opportunity__r.ForecastStatus__c == '0.Booked'){
								record.FYM_TIV_E__c = amountInUSD;	
							}
						}
			
						// If Order Status = Completed then Recoginized else Upside
						record.FYM_R__c = 0.0;
	                	record.FYM_U__c = 0.0;
						if(quote.BigMachines__Opportunity__r.ForecastStatus__c == '0.Booked'){
							if(monthStartDate < cutOffDate){
								cummlativeValueTillDate = cummlativeValueTillDate + recordAmount;
							} else if(monthStartDate == cutOffDate){
								record.FYM_R__c = cummlativeValueTillDate + recordAmount;
			                	cummlativeValueTillDate = 0.0;
							} else {
								record.FYM_R__c = recordAmount;
							}					
						} else {
							if(monthStartDate < cutOffDate){
								cummlativeValueTillDate = cummlativeValueTillDate + recordAmount;
							} else if(monthStartDate == cutOffDate){
			                	record.FYM_U__c = cummlativeValueTillDate + recordAmount;
			                	cummlativeValueTillDate = 0.0;
							} else {
			                	record.FYM_U__c = recordAmount;
							}					
						}
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
    	if(!Test.isRunningTest())
           Database.executeBatch(new GCFBillingPlanBatch());
    }
    
    public GCF_Data__c getGCFRecord(BigMachines__Quote__c quote, Date cutOffDate,Date startDate, Date endDate, Decimal amountInUSD){
    	GCF_Data__c record = new GCF_Data__c();
		record.Revenue_Type__c = 'First Year Maintenance';
		record.CurrencyIsoCode = 'USD';
		record.Posting_Date__c = cutOffDate;
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
		record.FYM_R__c = (quote.BigMachines__Opportunity__r.ForecastStatus__c == '0.Booked') ? amountInUSD : 0.0;
		record.FYM_U__c =  (quote.BigMachines__Opportunity__r.ForecastStatus__c != '0.Booked') ? 0.0 : amountInUSD;
		record.FYM_TIV__c = amountInUSD;
		record.FYM_TIV_E__c = (quote.BigMachines__Opportunity__r.ForecastStatus__c != '0.Booked') ? 0.0 : amountInUSD;
		record.Offering_Type__c = quote.BigMachines__Opportunity__r.Lines_of_Businesses__c != NULL ? quote.BigMachines__Opportunity__r.Lines_of_Businesses__c : 'PureEngage';
        return record;        		
    }
    
    public GCF_Data__c getGCFRecord(BigMachines__Quote__c quote){
    	
    	Integer contractTerm = quote.Order_Numb_of_Maint_Months__c != NULL ? Integer.valueOf(quote.Order_Numb_of_Maint_Months__c) : 1;
    	Date startDate = quote.Opportunity_Close_Date__c + 1;
		Date endDate = startDate.addMonths(contractTerm) - 1;
		Date cutOffDate = quote.Order__r.Invoice_Date__c != NULL ? Date.newInstance(quote.Order__r.Invoice_Date__c.year(), quote.Order__r.Invoice_Date__c.month(), 1) : Date.newInstance(Date.Today().year(),Date.Today().month(), 1);
        Decimal amountInUSD = GCFUtil.convertCurrency(quote.Total_Genesys_Care__c, quote.CurrencyIsoCode, 'USD');
    	
    	GCF_Data__c record = new GCF_Data__c();
		record.Revenue_Type__c = 'First Year Maintenance';
		record.CurrencyIsoCode = 'USD';
		record.Posting_Date__c = cutOffDate;
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
		record.FYM_R__c = 0.0;
		record.FYM_U__c = 0.0;
		record.FYM_TIV__c = amountInUSD;
		record.FYM_TIV_E__c = 0.0;
		record.Offering_Type__c = quote.BigMachines__Opportunity__r.Lines_of_Businesses__c != NULL ? quote.BigMachines__Opportunity__r.Lines_of_Businesses__c : 'PureEngage';
        return record;        		
    }
}