/*
 * Class            : AutoRenewalBatch
 * Description      : Batch Class to invoke processing for creating Auto Quotes for Pure Enagage and Pure Connect in Regular Period.
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
 
global class AutoRenewalBatch implements Database.Batchable<SObject>{
    
    global String query {get; set;}
    
    global AutoRenewalBatch(){
    	query = '';	
    }
    
    global AutoRenewalBatch(String q){
    	query = q;	
    }

    global Database.QueryLocator start(Database.BatchableContext bc){
    	if(query != ''){
    		 return Database.getQueryLocator(query);	
    	} else {
	        // Find all Accounts Due for Auto Renewal in next 120 days
	        return Database.getQueryLocator([SELECT Id, Name, Genesys_Care_Offering__c, Support_Option__c, Partner_Product_Margin__c, Partner_GU_Margin__c,
	                                         Auto_Renew_Eligible__c, Auto_Renew_Anniversary__c, Auto_Renew_Contract_Term__c, Auto_Renew_Rate__c,
	                                         Increased_Percentage__c, Auto_Renew_Contractual_Increase__c,
					                         Genesys_Care_specialist__c, Genesys_Care_specialist__r.Email, Genesys_Care_Ops__c, Genesys_Care_Ops__r.Email
	                         				FROM Account WHERE Auto_Renew_Eligible__c = true 
	                         				AND Auto_Renew_Anniversary__c <= :Date.Today().addDays(120)]);
    	}	                         				
    }
    
    global void execute(Database.BatchableContext bc, List<SObject> scope){
        for(sObject so: scope){
            Account a = (Account)so;
        	AutoRenewalUtil.createAutoRenewalQuotes(a);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        // TBD
    }
}