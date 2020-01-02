/*
 * Class			: GenesysCareForecastingIRBatch
 * Description		: This Batch Class generates data for Incremental Revenue forecasting.
 * Author			: Narasimha "Rao" Tumma
 * Created Date		: Dec 19, 2016
 * Test Class		: GenesysCareForecastingBatchesTest	 
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Harish, 03/03/207 - updated execute to add opportunityId to generateForeCastByServiceContractIds.
 * Harish, 03/05/207 - updated execute skip service contract processing if end date does not match with opportunity's closedate+1.
 * Harish, 03/20/207 - Added split renewal opportunity scenario.
 *                     Updated primary quote inclusion when non-completed order exists.
 * Harish, 03/22/207 - Updated execute method to treat Order's status of Credit same as Completed.
 */
global class GenesysCareForecastingIRBatch  implements Database.Batchable<sObject>{
	global String query ;
    global GenesysCareForecastingIRBatch(String q){
        query = q;
    }
    global GenesysCareForecastingIRBatch(){
        // String GenesysRenewalRT = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Genesys Renewal').getRecordTypeId();
        Id GenesysRenewalRT = MetaUtils.getRecordTypeId(Opportunity.SObjectType, CONSTANTS.OPP_RT_GENESYSRENEWAL);
        query = 'Select Id, Name, CloseDate, Opportunity_Status__c, '
                + ' Service_Contract__c, Service_Contract__r.EndDate, '
                +' Split_Parent_Quote__c, Split_Parent_Quote__r.BigMachines__Is_Primary__c '
                +' FROM Opportunity '
            	+ ' Where RecordTypeId = \''+GenesysRenewalRT+'\'' 
            	// + ' AND Forecast_Status__c IN (' + Label.GenesysCareForecasting_IR_OppForecastStatus_Filter + ')'
            	+ ' AND Opportunity_Status__c NOT IN (' + Label.GenesysCareForecasting_IR_OppStages_Filter + ')'
                +' AND (NOT Name LIKE \''+CONSTANTS.OPP_NAME_PPU+'%\')'
                +' AND (NOT Name LIKE \''+CONSTANTS.OPP_NAME_CAS+'%\')';
    }
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    global void execute (Database.BatchableContext bc, List<Sobject> scope){
        List<Genesys_Care_Forecasting__c> forecastingData = new List<Genesys_Care_Forecasting__c>();
        for(sObject so : scope){
            Opportunity opp = (Opportunity)so;
		
			Id associatedQuoteId = null;  
            
            // Getting all the Orders for given Opportunity and Order status is "completed".
            // Update: Harish, 03/20/2017: check for all orders but not just first.
            // Update: Harish, 03/22/2017: Ignore orders with status = credit along with completed.
            Boolean completedOrderExists = true;
            List<Order__c> orderList = [Select Id, Name, Status__c, Quote__c 
                                                From Order__c 
                                                    Where Opportunity__c = :opp.Id
                                                          AND (status__c = :CONSTANTS.ORDER_STATUS_COMPLETED
                                                               OR status__c = :CONSTANTS.ORDER_STATUS_CREDIT)];
            if(orderList.isEmpty()) 
		        completedOrderExists = false;
            
            // Add logic to check the current order/ quote in FYM or not ...
            
            // Process for forecasting calcualtions only if the there is NO COMPLETED order
            // Update: Harish 03/20/2017: always consider primary quote even if non-completed order exists.
            if(completedOrderExists == false){
                // If an Incompleted Order exists
                /*if(orderList.size() > 0){
                    associatedQuoteId = orderList[0].Quote__c;                
                } else {
                    // Query the Primary Quote assocaited with the Opportunity
                    List<BigMachines__Quote__c> bmQuotes = [SELECT Id, Name, BigMachines__Is_Primary__c 
                                                                FROM BigMachines__Quote__c 
                                                                    WHERE BigMachines__Opportunity__c = :opp.Id 
                                                                          AND BigMachines__Is_Primary__c = true];
                    // If a Primary Quote exists
                    if(bmQuotes.size() > 0){
                        associatedQuoteId = bmQuotes[0].Id;
                    }
                }*/
                
                // Query the Primary Quote assocaited with the Opportunity
                List<BigMachines__Quote__c> bmQuotes = [Select Id, Name, BigMachines__Is_Primary__c 
                                                            From BigMachines__Quote__c 
                                                                Where BigMachines__Opportunity__c = :opp.Id 
                                                                      AND BigMachines__Is_Primary__c = true];
                // If a Primary Quote exists
                if(!bmQuotes.isEmpty()){
                    associatedQuoteId = bmQuotes.get(0).Id;
                }

                if(associatedQuoteId != null){
                    forecastingData.addAll(GenesysCareForecastingUtil.generateForecastByQuoteIds(new List<String>{associatedQuoteId}));   
                } else {
                    // Previous Contract on Opportunity if no-primary quote exists on opportunity
                    // Update: Harish 03/03/2017 - In split scenario, old contract could be referring to old opportunity so added a new param named opportunityId. 
					// Update: Harish, 03/05/2017 - Skip processing service contract, if end date of service contract is not equals to renewal opportunity's close date +1.
                    // Update: Harish, 03/05/2017 - Consider the service contract from where Renewal_Opportunity__c = current oppty in context for split opportunities(opportunity Status = 'Split' and Split_Parent_Quote__r.BigMachines__Is_Primary__c = true)
                    
                    Id previousServiceContractId = null;
                    
                    // check if opportunity is split oppty.
                    if(opp.Opportunity_Status__c == CONSTANTS.OPP_OPPSTATUS_SPLIT){
                        if(opp.Split_Parent_Quote__c != null
                            && opp.Split_Parent_Quote__r.BigMachines__Is_Primary__c == true){
                            // Query the Service contracts with matching renewal opportunity.
                            List<ServiceContract> sContracts = [Select Id, Name, Renewal_Opportunity__c, EndDate 
                                                                        From ServiceContract 
                                                                            Where Renewal_Opportunity__c = :opp.Id];
                            if(!sContracts.isEmpty()){
                                previousServiceContractId = sContracts.get(0).Id;
                            }
                        }
                    }else{// non-split opportunities.
                        // include service contract only if enddate is one day past oppty closeDate. - not applicable for split opportunities.
                        if(opp.Service_Contract__c != null
                            && opp.CloseDate != null
                            && opp.Service_Contract__r.EndDate == opp.CloseDate.addDays(1))
                        previousServiceContractId = opp.Service_Contract__c;
                    }

                    if(previousServiceContractId != NULL){
                        forecastingData.addAll(GenesysCareForecastingUtil.generateForeCastByServiceContractIds(new List<String>{}, opp.Id));
                    }
                }
            }
        }
        Insert forecastingData;
    }
    
    
    global void finish(Database.BatchableContext bc){
        if(!Test.isRunningTest())
        	Database.executeBatch(new GenesysCareForecastingFYMBatch());
    }
}