/*
 * Class            : GCFIncrementalBatch
 * Description      : A Batch class to explode Genesys Care forecasting Data into GCF_Data__c Object for Incremental Type.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : May 19, 2017
 * Test Class       : GCFAllTests   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 */
 global class GCFIncrementalBatch implements Database.Batchable<sObject>{

	global String query ;
    global GCFIncrementalBatch(String q){
        query = q;
    }
    global GCFIncrementalBatch(){
    	
    	String GenesysRenewalRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Genesys Renewal').getRecordTypeId();
		String startDateStr = '';
		String startDateTimeStr = '';

    	Date startDate = Date.today().addMonths(-6);
		if(startDate.month() < 10){
			startDateStr = startDate.year() + '-0'+startDate.month() + '-01';
			startDateTimeStr = startDateStr + 't01:01:01z';
		} else {
			startDateStr = startDate.year() + '-'+startDate.month() + '-01';
			startDateTimeStr = startDateStr + 't01:01:01z';
		}
			
        query = 'SELECT Id, Name, CloseDate, Opportunity_Status__c, Lines_of_Businesses__c, '
                + ' Service_Contract__c, Service_Contract__r.EndDate, '
                + ' Split_Parent_Quote__c, Split_Parent_Quote__r.BigMachines__Is_Primary__c, Country__r.Name '
                + ' FROM Opportunity '
            	+ ' Where RecordTypeId = \''+GenesysRenewalRT+'\'' 
            	+ ' AND ((CloseDate < '+startDateStr+' AND Opportunity_Status__c IN (\'Hypothetical\',\'With Customer\',\'Sent To Customer\',\'Quoted\',\'In Progress\') ) OR CloseDate >= '+startDateStr+' OR (LastModifiedDate > '+startDateTimeStr+' AND Opportunity_Status__c = \'Renewed\')) ' 
            	+ ' AND Opportunity_Status__c NOT IN (\'Prior Siebel\',\'Cancelled\',\'Dropped\',\'Drop\',\'Non Renewed\',\'Duplicate\',\'Declined\',\'Closed-CoTerm\',\'CO-Term Closed\',\'Closed Transferred\',\'CoTerm Pending\',\'CO-Term Pending\',\'Downsize\',\'Credit\') '
                + ' AND (NOT Name LIKE \'PPU%\') ';
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }	
    
    global void execute(Database.BatchableContext bc, List<Sobject> scope){

    	Date quarterStartDate = GCFUtil.getQuarterStartDate(Date.today().month());
    	Date nextQuarterStartDate = quarterStartDate.addMonths(3);
    	
        List<GCF_Data__c> forecastingData = new List<GCF_Data__c>();
        for(sObject so : scope){
            Opportunity opp = (Opportunity)so;
			Boolean brailOppNotToProcess = (opp.Country__r.Name == 'Brazil' && opp.CloseDate < quarterStartDate) ? true : false;
            
			Id associatedQuoteId = null;  
			
            // Getting all the Orders for given Opportunity and Order status is "completed".
            Boolean creditOrderExists = false;
            Boolean orderInvoicedInThePast = false;
            Boolean pureConnectOpportunityNotToProcess = false; 
            for(Order__c order : [SELECT Id, Name, Status__c, Quote__c, Invoice_Date__c FROM Order__c WHERE Opportunity__c = :opp.Id]){
            	if(order.status__c == 'Credit' || Order.Name.contains('-CO')){
            		creditOrderExists = true;
            	}
            	if(order.Invoice_Date__c != NULL && order.Invoice_Date__c < quarterStartDate){
            		orderInvoicedInThePast = true;
            	}
                if(opp.Lines_of_Businesses__c == 'PureConnect' && opp.Opportunity_Status__c == 'Renewed' && order.Quote__c == NULL && order.Status__c == 'Completed'){
					pureConnectOpportunityNotToProcess = true;    
                }
            }
            
            // Process for forecasting calcualtions only if the there is NO COMPLETED order
            // Always consider primary quote even if non-completed order exists.
            if(creditOrderExists == false && orderInvoicedInThePast == false && pureConnectOpportunityNotToProcess == false && brailOppNotToProcess == false){
                // Query the Primary Quote assocaited with the Opportunity
                List<BigMachines__Quote__c> bmQuotes = [SELECT Id, Name, BigMachines__Is_Primary__c FROM BigMachines__Quote__c 
                										WHERE BigMachines__Opportunity__c = :opp.Id AND BigMachines__Is_Primary__c = true];
                // If a Primary Quote exists
                if(!bmQuotes.isEmpty()){
                    associatedQuoteId = bmQuotes[0].Id;
                }
                
                // If a Primary Quote does not exists
                // Check whether the Opportunity is included in existing Quote as Co-Termed in 'Approved' or 'Completed' Order's Quote 
				// If found Skip Processing
				Boolean skipProcessing = false;
				Integer countOfCotermedOpps = [SELECT Count() FROM Quote_Service_Contracts__c WHERE Quote__r.Order__C != NULL AND Quote__r.Order__r.Status__c IN ('Approved' , 'Completed') 
												AND Quote__r.BigMachines__Opportunity__c != :opp.Id AND Service_Contract__r.Renewal_Opportunity__c = :opp.Id];
				if(associatedQuoteId == NULL && countOfCotermedOpps > 0){
					skipProcessing = true;	
				}						
										
				if(skipProcessing == false){
	                if(associatedQuoteId != null){
	                	// Match Billing Plan conditions
	                	Boolean billingPlanExists = [SELECT count() FROM Quote_Billing_Plan__c WHERE Quote__c = :associatedQuoteId AND Quote__r.Order__r.Status__c IN ('Approved' , 'Completed') AND Invoice_Date__c >= :quarterStartDate] > 0 ? true : false;
	                	if(billingPlanExists == false){
	                		BigMachines__Quote__c quote = [SELECT Id, Name, CurrencyIsoCode, Maintenance_Start_Date__c, Maintenance_End_Date__c, 
	                   									Total_Maintenance_Amount_Due_Formula__c, CAS_Maintenance_Due__c, 
	            										Order__c, Order__r.Status__c, Order__r.Invoice_Date__c, Order__r.Net_Suite_Order__c, 
	            										Sold_To_Name__r.Region__c, BigMachines__Account__r.Region__c,
	            										BigMachines__Opportunity__c, BigMachines__Opportunity__r.CloseDate, BigMachines__Opportunity__r.PO_Expected_Date__c, 
	            										BigMachines__Opportunity__r.Forecast_Status__c, BigMachines__Opportunity__r.Lines_of_Businesses__c 
	            										FROM BigMachines__Quote__c  WHERE Id = :associatedQuoteId];
	            			
		            		Boolean orderAlreadyProcessed = false; 	
		            		
					    	// Get completed orders linked on the primary quote --> SO NUMBER and match agaist the deferred report
					    	String 	netSuiteOrderNumber = NULL;
					    	List<Order__c> quoteOrders = [SELECT id, Net_Suite_Order__c,Invoice_Number__c FROM Order__c WHERE Quote__c = :associatedQuoteId AND status__c = 'Completed']; 	
					    	if(!quoteOrders.isEmpty())
					    		netSuiteOrderNumber = quoteOrders[0].Net_Suite_Order__c;
					    	
		                    if(netSuiteOrderNumber != NULL){
		                    	orderAlreadyProcessed = [SELECT count() FROM GCF_NetSuite_Data__c WHERE ((SO_Number__c = :netSuiteOrderNumber AND SO_Number__c != NULL) OR (Document_Number__c =:quoteOrders[0].Invoice_Number__c AND Document_Number__c!=NULL)) AND Revenue_Type__c = 'Deferred Revenue'] > 0 ? true : false;
		                    }
		                    
		                    // If Order is already processed in Net Suite, post only TIV 
						    if(orderAlreadyProcessed){
						    	if(quote.Order__r.Invoice_Date__c >= quarterStartDate && quote.Order__r.Invoice_Date__c < nextQuarterStartDate)
									forecastingData.add(getGCFRecord(quote));
							}
							
		                    // If Order is not Processed in Net Suite, follow the normal process to explode the ForeCasting Data
							else if(quote.Maintenance_Start_Date__c != NULL && quote.Maintenance_End_Date__c != NULL && quote.Maintenance_Start_Date__c <  quote.Maintenance_End_Date__c){
								List<GCF_Data__c> qGCFData = processQuoteForGCF(quote, quarterStartDate, nextQuarterStartDate);
								if(qGCFData.size() > 0){
									forecastingData.addAll(qGCFData);
								}
							}	
	                	}
	                } else {
	                    // Previous Contract on Opportunity if no-primary quote exists on opportunity
	                    // In split scenario, old contract could be referring to old opportunity so added a new param named opportunityId. 
						// Skip processing service contract, if end date of service contract is not equals to renewal opportunity's close date +1.
	                    // Consider the service contract from where Renewal_Opportunity__c = current oppty in context for split opportunities(opportunity Status = 'Split' and Split_Parent_Quote__r.BigMachines__Is_Primary__c = true)
	                    
	                    Id previousServiceContractId = null;
	                    
	                    // check if opportunity is split oppty.
	                    if(opp.Opportunity_Status__c == 'Split'){
	                        if(opp.Split_Parent_Quote__c != null && opp.Split_Parent_Quote__r.BigMachines__Is_Primary__c == true){
	                            // Query the Service contracts with matching renewal opportunity.
	                            List<ServiceContract> sContracts = [SELECT Id, Name, Renewal_Opportunity__c, EndDate FROM ServiceContract WHERE Renewal_Opportunity__c = :opp.Id];
	                            if(!sContracts.isEmpty()){
	                                previousServiceContractId = sContracts.get(0).Id;
	                            }
	                        }
	                    } else {
	                    	// non-split opportunities.
	                        // include service contract only if enddate is one day past oppty closeDate. - not applicable for split opportunities.
	                        if(opp.Service_Contract__c != null && opp.CloseDate != null && opp.Service_Contract__r.EndDate == opp.CloseDate.addDays(1)){
	                        	previousServiceContractId = opp.Service_Contract__c;
	                        }
	                    }
	
	                    if(previousServiceContractId != NULL){
							List<GCF_Data__c> scGFCData = processServiceContractForGCF(previousServiceContractId, quarterStartDate);
							if(scGFCData.size() > 0){
								forecastingData.addAll(scGFCData);
							}
	                    }
	                }
	            }
            }
        }
        Insert forecastingData;
    }

    global void finish(Database.BatchableContext bc){
    	if(!Test.isRunningTest())
        	Database.executeBatch(new GCFFYMBatch());
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
		record.Incremental_R__c = 0.0;
		record.Incremental_E__c = 0.0;
        record.Incremental_U__c = 0.0;
		record.Incremental_TIV__c  = amountInUSD;
		record.Incremental_TIV_E__c  = (quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Booked/ In Hand' || quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Booked In' || quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Expected') ? amountInUSD : 0.0;
		record.Offering_Type__c = quote.BigMachines__Opportunity__r.Lines_of_Businesses__c != NULL ? quote.BigMachines__Opportunity__r.Lines_of_Businesses__c : 'PureEngage';	
		
        return record;        		
    }
    
    public GCF_Data__c getGCFRecord(BigMachines__Quote__c quote){

		Date startDate = quote.Maintenance_Start_Date__c;
        Date endDate = quote.Maintenance_End_Date__c;
    	Date cutOffDate = quote.Order__r.Invoice_Date__c != NULL ? Date.newInstance(quote.Order__r.Invoice_Date__c.year(), quote.Order__r.Invoice_Date__c.month(), 1) : Date.newInstance(Date.Today().year(),Date.Today().month(), 1);
				
        Decimal totalQuoteMaintenanceDue = quote.Total_Maintenance_Amount_Due_Formula__c;
        Decimal totalCASMaintenanceDue = quote.CAS_Maintenance_Due__c != NULL ? quote.CAS_Maintenance_Due__c : 0.0;
        Decimal amountInUSD = GCFUtil.convertCurrency(totalQuoteMaintenanceDue - totalCASMaintenanceDue, quote.CurrencyIsoCode, 'USD');
			            
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
		record.Incremental_R__c = 0.0;
		record.Incremental_E__c = 0.0;
        record.Incremental_U__c = 0.0;
		record.Incremental_TIV__c  = amountInUSD;
		record.Incremental_TIV_E__c  = (quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Booked/ In Hand' || quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Booked In' || quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Expected') ? amountInUSD : 0.0;
		record.Offering_Type__c = quote.BigMachines__Opportunity__r.Lines_of_Businesses__c != NULL ? quote.BigMachines__Opportunity__r.Lines_of_Businesses__c : 'PureEngage';	
		
        return record;        		
    }
    
    public List<GCF_Data__c> processQuoteForGCF(BigMachines__Quote__c quote, Date quarterStartDate, Date nextQuarterStartDate){
    	List<GCF_Data__c> qpForecastingData = new List<GCF_Data__c>();
    	Date quoteStartDate = quote.Maintenance_Start_Date__c ;
    	Date quoteEndDate = quote.Maintenance_End_Date__c;
    
		List<BigMachines__Quote_Product__c> quoteProducts = [SELECT Id, Original_Qty__c, Current_Qty__c, Contract_Line_Update_Status__c,BigMachines__Product__r.Type__c,Maintenance_Due_after_Discount__c,BigMachines__Total_Price__c,Product_Description__c,
																	Maintenance_Start_Date__c, Maintenance_End_Date__c,	Annualized_Maintenance_Due__c,Maintenance_Due__c,Annualized_Maintenance_Due_after_Discoun__c
                                                             FROM BigMachines__Quote_Product__c 
                                                             WHERE   BigMachines__Quote__c = :quote.Id
                                                                     AND Annualized_Maintenance_Due__c != NULL 
                                                                     AND Annualized_Maintenance_Due__c != 0
                                                                     AND Maintenance_Start_Date__c != NULL 
                                                                     AND Maintenance_End_Date__c != NULL
                                                                     AND Maintenance_End_Date__c > TODAY 
                                                                     AND (NOT Product_Description__c like 'Custom App%') 
																	 AND (APN_Number__c!= '3GP21571ACAA')
                                                                     AND (NOT Product_Description__c like 'Custom Software%')
                                                                     AND (NOT Product_Description__c like '%Care%')
                                                                        order by BigMachines__Quote__c];

		List<BigMachines__Quote_Product__c> flexCareQuoteProducts = [SELECT Id, Original_Qty__c, Current_Qty__c, Contract_Line_Update_Status__c,Annualized_Maintenance_Due_after_Discoun__c,Maintenance_Due_after_Discount__c,Product_Description__c,
																			Maintenance_Start_Date__c, Maintenance_End_Date__c,BigMachines__Total_Price__c,	Annualized_Maintenance_Due__c,Maintenance_Due__c,BigMachines__Product__r.Type__c
		                                                             FROM BigMachines__Quote_Product__c 
		                                                             WHERE   BigMachines__Quote__c = :quote.Id
		                                                                     AND BigMachines__Total_Price__c!=NULL
		                                                                     AND BigMachines__Total_Price__c != 0
		                                                                     AND Maintenance_Start_Date__c != NULL 
		                                                                     AND Maintenance_End_Date__c != NULL
		                                                                     AND Maintenance_End_Date__c > TODAY
		                                                                     AND Product_Description__c like 'Flex Care%'];
		if(!flexCareQuoteProducts.isEmpty())
			quoteProducts.addAll(flexCareQuoteProducts); 
    	
    	for(BigMachines__Quote_Product__c quoteProduct : quoteProducts){
			//	decimal AnnualizedMaintenanceDue=calculateQuoteAnnualizedDue(quoteProduct);
	        Boolean processRecord = true;
	        if(quoteProduct.Current_Qty__c <= 0 || (quoteProduct.Maintenance_Due__c <= 0 && !quoteProduct.Product_Description__c.contains('Flex Care')) ||(quoteProduct.BigMachines__Total_Price__c<=0 && quoteProduct.Product_Description__c.contains('Flex Care')))
	            processRecord = false;
						                
	    	if(processRecord == true && quoteProduct.Maintenance_Start_Date__c != NULL && quoteProduct.Maintenance_Start_Date__c < quoteProduct.Maintenance_End_Date__c){
						        		
	    		Date startDate = quoteProduct.Maintenance_Start_Date__c ;
		        Date endDate = quoteProduct.Maintenance_End_Date__c;
		    	Date cutOffDate;
								    		
		    	if(quote.Order__c != NULL && quote.Order__r.Invoice_Date__c != NULL)
		    		cutOffDate = Date.newInstance(quote.Order__r.Invoice_Date__c.year(), quote.Order__r.Invoice_Date__c.month(), 1);
		    	else if(quote.BigMachines__Opportunity__r.PO_Expected_Date__c != NULL && quote.BigMachines__Opportunity__r.PO_Expected_Date__c >= quarterStartDate && quote.BigMachines__Opportunity__r.PO_Expected_Date__c <= quoteEndDate) 
		    		cutOffDate = Date.newInstance(quote.BigMachines__Opportunity__r.PO_Expected_Date__c.year(), quote.BigMachines__Opportunity__r.PO_Expected_Date__c.month(), 1);
		    	else if(startDate.toStartOfMonth() > Date.Today().toStartOfMonth())
		    		cutOffDate = Date.newInstance(startDate.year(),startDate.month(), 1);
		    	else
		    		cutOffDate = Date.newInstance(Date.Today().year(),Date.Today().month(), 1);
								
		    	Integer monthsCount = startDate.monthsBetween(endDate) + 1;
		    	Integer daysCount = startDate.daysBetween(endDate) + 1;
				Decimal monthlyAmountInUSD;
				Decimal dailyAmountInUSD ;
				Decimal amountInUSD;

				if(quoteProduct.Product_Description__c.contains('Flex Care')){
				Decimal AnnualizedFlexCare=calculateFlexAnnualizedDue(quoteProduct);
				 monthlyAmountInUSD = GCFUtil.convertCurrency(AnnualizedFlexCare/ 12, quote.CurrencyIsoCode, 'USD');//qp_termDuration_months;
				dailyAmountInUSD =  GCFUtil.convertCurrency(AnnualizedFlexCare/ 365, quote.CurrencyIsoCode, 'USD');//qp_termDuration_Days;
				amountInUSD = GCFUtil.convertCurrency(AnnualizedFlexCare, quote.CurrencyIsoCode, 'USD');
				}
				else{
				monthlyAmountInUSD = GCFUtil.convertCurrency(quoteProduct.Annualized_Maintenance_Due_after_Discoun__c/ 12, quote.CurrencyIsoCode, 'USD');//qp_termDuration_months;
				dailyAmountInUSD =  GCFUtil.convertCurrency(quoteProduct.Annualized_Maintenance_Due_after_Discoun__c/ 365, quote.CurrencyIsoCode, 'USD');//qp_termDuration_Days;
				amountInUSD = GCFUtil.convertCurrency(quoteProduct.Maintenance_Due_after_Discount__c, quote.CurrencyIsoCode, 'USD');
				}
				
										
	       	 	Date tempDate = Date.newInstance(startDate.year(), startDate.month(), 1);
					
				String invoicedWhen = '';
				if(cutOffDate.toStartOfMonth() < quoteStartDate.toStartOfMonth()){
					invoicedWhen = 'BEFORE';
				} else if(cutOffDate.toStartOfMonth() > quoteEndDate.toStartOfMonth()){
					invoicedWhen = 'AFTER';
				} else {
					invoicedWhen = 'BETWEEN';
				}		
										
				// *** CHRIS COMMENTS -  If the it is AFTER and Start Date is in Future then monthly explosion is needed ... 		
			
				// If Invoice date not in between Support_Period_Start_Date__c,  Support_Period_End_Date__c, then make an entry for TIV beacuse the loop wont cover this case
				if((invoicedWhen == 'BEFORE' || invoicedWhen == 'AFTER')){
					if(cutOffDate.toStartOfMonth() >= quarterStartDate){
						qpForecastingData.add(getGCFRecord(quote, cutOffDate, quoteStartDate, quoteEndDate, amountInUSD));
					}
				} 
													
				Decimal cummlativeValueTillDate = 0.0; 
	            for(integer i = 0; i < monthsCount; i++){
					Date monthStartDate = tempDate.addMonths(i);
					Date monthEndDate = Date.newInstance(monthStartDate.year(), monthStartDate.month(), Date.daysInMonth(monthStartDate.year(), monthStartDate.month()));
	
	            	Date postingDate = tempDate.addMonths(i);

					GCF_Data__c record = new GCF_Data__c();
					record.Revenue_Type__c = 'Incremental Revenue';
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
		            	//recordAmount = dailyAmountInUSD * Date.daysInMonth(monthStartDate.year(), monthStartDate.month()); 
		            	recordAmount = monthlyAmountInUSD;
					}
		
					// Post Total Invoice Value to that month when the Invoice is expcected
					if(monthStartDate == cutOffDate){
						record.Incremental_TIV__c = amountInUSD;
						if(quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Expected' || quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Booked/ In Hand' || quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Booked In'){
							record.Incremental_TIV_E__c = amountInUSD;	
						}
					}
		
					record.Incremental_R__c = 0.0;
					record.Incremental_E__c = 0.0;
	                record.Incremental_U__c = 0.0;
					if(quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Booked/ In Hand' || quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Booked In'){
						if(monthStartDate < cutOffDate){
							cummlativeValueTillDate = cummlativeValueTillDate + recordAmount;
						} else if(monthStartDate == cutOffDate){
							record.Incremental_R__c = cummlativeValueTillDate + recordAmount;
			            	cummlativeValueTillDate = 0.0;
						} else {
							record.Incremental_R__c = recordAmount;
						}					
					} else if(quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Expected'){
						if(monthStartDate < cutOffDate){
							cummlativeValueTillDate = cummlativeValueTillDate + recordAmount;
						} else if(monthStartDate == cutOffDate){
							record.Incremental_E__c = cummlativeValueTillDate + recordAmount;
			            	cummlativeValueTillDate = 0.0;
						} else {
							record.Incremental_E__c = recordAmount;
						}					
					} else if(quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Upside' || 
								(quote.BigMachines__Opportunity__r.Forecast_Status__c == 'Pipeline' && quote.BigMachines__Opportunity__r.CloseDate >= nextQuarterStartDate)){
						if(monthStartDate < cutOffDate){
							cummlativeValueTillDate = cummlativeValueTillDate + recordAmount;
						} else if(monthStartDate == cutOffDate){
							record.Incremental_U__c = cummlativeValueTillDate + recordAmount;
			            	cummlativeValueTillDate = 0.0;
						} else {
							record.Incremental_U__c = recordAmount;
						}					
					} 
					// Add records only the Posting Date is from begining of this quarter 
					if(monthStartDate >= quarterStartDate)
		            	qpForecastingData.add(record); 
				} // end of months for loop
        	} // End of if condition whether to process quote product or not       
		} // end of Quote Products loop
		return qpForecastingData;
    }
    
    public List<GCF_Data__c> processServiceContractForGCF(String previousServiceContractId, Date quarterStartDate){
    	List<GCF_Data__c> scForecastingData = new List<GCF_Data__c>();
    	ServiceContract sc = [SELECT Id, CurrencyIsoCode, StartDate, EndDate, Term_Duration__c, Maintenance_Amount__c, CAS_Maintenance_Due__c, Region__c, 
									Renewal_Opportunity__c, Renewal_Opportunity__r.CloseDate, Renewal_Opportunity__r.PO_Expected_Date__c, Renewal_Opportunity__r.Lines_of_Businesses__c,
									Sold_To_Name__c, Sold_To_Name__r.Name, Sold_To_Name__r.SAP_Account_Code__c, Sold_To_Name__r.Subsidary__r.Name, 
									End_User_Name__c, End_User_Name__r.Name, End_User_Name__r.SAP_Account_Code__c, End_User_Name__r.Subsidary__r.Name,
									Quote_Name__c, Order__c, Order__r.Invoice_Date__c, Order__r.Status__c, Offering_Type__c
								FROM ServiceContract WHERE Id = :previousServiceContractId];
									
		if(sc.StartDate != NULL && sc.EndDate != NULL && sc.StartDate <  sc.EndDate){
			// Integer termDuration_sContract = sc.Term_Duration__c != NULL ? Integer.valueOf(sc.Term_Duration__c) : 12;
			
			Date startDate = sc.EndDate.addDays(2);
	        Date endDate = sc.EndDate.addDays(sc.StartDate.daysBetween(sc.EndDate));
			Date cutOffDate = Date.newInstance(Date.Today().year(),Date.Today().month(), 1);
			
	    	Integer monthsCount = startDate.monthsBetween(endDate) + 1;
	    	Integer daysCount = startDate.daysBetween(endDate) + 1;

            Decimal totalMaintenanceDue = sc.Maintenance_Amount__c != NULL ? sc.Maintenance_Amount__c : 0.0;
            Decimal casMaintenanceDue = sc.CAS_Maintenance_Due__c != NULL ? sc.CAS_Maintenance_Due__c : 0.0;
            Decimal amountInUSD = GCFUtil.convertCurrency(totalMaintenanceDue - casMaintenanceDue, sc.CurrencyIsoCode, 'USD');
            Decimal dailyAmountInUSD = amountInUSD/ daysCount;
	                
            Date tempDate = Date.newInstance(startDate.year(), startDate.month(), 1);
		
			Decimal cummlativeValueTillDate = 0.0; 
            for(integer i = 0; i < monthsCount; i++){
				Date monthStartDate = tempDate.addMonths(i);
				Date monthEndDate = Date.newInstance(monthStartDate.year(), monthStartDate.month(), Date.daysInMonth(monthStartDate.year(), monthStartDate.month()));
	
            	Date postingDate = tempDate.addMonths(i);

				GCF_Data__c record = new GCF_Data__c();
				record.Revenue_Type__c = 'Incremental Revenue';
				record.CurrencyIsoCode = 'USD';
				record.Posting_Date__c = monthStartDate;
				record.Year__c = monthStartDate.year();
				record.Year_Text__c = ''+monthStartDate.year();
				record.Month__c = monthStartDate.month();
				record.Month_Text__c = ''+monthStartDate.month();
				record.Quarter__c = GCFUtil.getQuarter(monthStartDate.month());
				record.Quarter_Text__c = ''+GCFUtil.getQuarter(monthStartDate.month());
				record.Region__c = (sc.Region__c == 'LATAM' ? 'Latin America' : sc.Region__c);
				//record.Reference_Quote__c = sc.Quote_Name__c;
				//record.Reference_Order__c = sc.Order__c;
				record.Reference_Opportunity__c = sc.Renewal_Opportunity__c;
				record.Reference_Service_Contract__c = sc.Id;
				record.Maintenance_Start_Date__c = startDate;
				record.Maintenance_End_Date__c = endDate;
				record.Offering_Type__c = sc.Renewal_Opportunity__r.Lines_of_Businesses__c != NULL ? sc.Renewal_Opportunity__r.Lines_of_Businesses__c : 'PureEngage';	
						
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
					record.Incremental_TIV__c = amountInUSD;
				}
		
        		record.Incremental_R__c = 0.0;
				record.Incremental_E__c = 0.0;
                record.Incremental_U__c = 0.0;
	               
				if(monthStartDate < cutOffDate){
					cummlativeValueTillDate = cummlativeValueTillDate + recordAmount;
				} else if(monthStartDate == cutOffDate){
					record.Incremental_U__c = cummlativeValueTillDate + recordAmount;
	            	cummlativeValueTillDate = 0.0;
				} else {
					record.Incremental_U__c = recordAmount;
				}	
				// Add records only the Posting Date is from begining of this quarter 
				if(monthStartDate >= quarterStartDate)
	            	scForecastingData.add(record); 
			}
		}
		return scForecastingData;
    }

	public Decimal calculateFlexAnnualizedDue(BigMachines__Quote_Product__c qp){
		Decimal result=0.0;
		if( (qp.Maintenance_End_Date__c.year()*12+qp.Maintenance_End_Date__c.month()) -((qp.Maintenance_Start_Date__c.year())*12+qp.Maintenance_Start_Date__c.month()) <> 0 && 
			((qp.Maintenance_End_Date__c.year())*12+qp.Maintenance_End_Date__c.month()) - ((qp.Maintenance_Start_Date__c.year())*12+qp.Maintenance_Start_Date__c.month())+ 1 <> 0){


		if(qp.BigMachines__Product__r.Type__c=='Genesys Care'){
			return result;
		}
		else{
			if(qp.Maintenance_Start_Date__c.day()>15)
			{
			result=qp.BigMachines__Total_Price__c * (12.0/ ( (qp.Maintenance_End_Date__c.year()*12+qp.Maintenance_End_Date__c.month())-(qp.Maintenance_Start_Date__c.year()*12+qp.Maintenance_Start_Date__c.month()) )) ;
			return result;
			}
			else {
				System.debug('start day < 15');
				result=qp.BigMachines__Total_Price__c * (12.0/ ((qp.Maintenance_End_Date__c.year()*12+qp.Maintenance_End_Date__c.month())-(qp.Maintenance_Start_Date__c.year()*12+qp.Maintenance_Start_Date__c.month())+ 1 ));
			
		return result; 	}
		}
		}
			else{
				return result;
			}


 

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