/*
 * Class            : AutoRenewalGapQuotesBatch
 * Description      : Batch Class to invoke processing for creating Auto Quotes for Pure Enagage and Pure Connect in Gap Period.
 * Author           : Narasimha "Rao" Tumma
 * Created Date     : Jul 03, 2017
 * Test Class       : AutoRenewalAllTests   
 * ----------------------------------------------------------------------------------------------
 * Modification Log
 * ----------------------------------------------------------------------------------------------
 * Modified BY		Modified Date		Changes/ Notes
 * ----------------------------------------------------------------------------------------------
 *
 */ 
 
global class AutoRenewalGapQuotesBatch implements Database.Batchable<SObject>{
    global String query {get; set;}
    
    global AutoRenewalGapQuotesBatch(){
    	query = '';	
    }
 
    global AutoRenewalGapQuotesBatch(String q){
    	query = q;	
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
    	if(query == ''){
    		query =  'SELECT AccountId FROM Opportunity WHERE RecordType.Name = \'Genesys Renewal\' AND Eligible_for_Gap_Quote__c = true ORDER BY Account.Name, CloseDate ';
    		if(Test.isRunningTest())
            	query = query + ' LIMIT 1'; 
    	}
    	return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        for(sObject so: scope){
            Opportunity opp = (Opportunity)so;
        	AggregateResult[] groupedResults = [SELECT Accountid, Count(Id) FROM Opportunity WHERE AccountId = :opp.AccountId AND Eligible_for_Gap_Quote__c = true GROUP BY AccountId];
			
        	if(groupedResults.size() > 0){
				Account a = [SELECT Id, Name, Genesys_Care_Offering__c, Support_Option__c, Partner_Product_Margin__c, Partner_GU_Margin__c,
                             Auto_Renew_Eligible__c, Auto_Renew_Anniversary__c, Auto_Renew_Contract_Term__c, Auto_Renew_Rate__c,
             				 Increased_Percentage__c, Auto_Renew_Contractual_Increase__c,
	                         Genesys_Care_specialist__c, Genesys_Care_specialist__r.Email, Genesys_Care_Ops__c, Genesys_Care_Ops__r.Email
             				FROM Account WHERE Id = :opp.AccountId]; 
            	AutoRenewalUtil.createAutoRenewalGapQuotes(a);
        	}
        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        // TBD
    }
}