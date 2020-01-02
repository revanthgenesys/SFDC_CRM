@isTest (SeeAllData = True)
/* 
   Test class for DDSToolInterface
*/
public class DDSToolInterface_Test {
	
	static testmethod void pureCnctTst () {
    	List<BigMachines__Quote__c> qt1 = [SELECT Id FROM BigMachines__Quote__c 
                          WHERE Offering_Type__c = 'PureConnect On Premise' 
                           AND BigMachines__Status__c = 'Quote Approved' 
                           AND Quote_Business_Type__c = 'On Premise'
                           AND Sold_To_Name__r.Type = 'Customer'                      
                           AND New_Price_Book__c = 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1]; 
        
        if ( !qt1.isEmpty() )  { 
        	for ( BigMachines__Quote__c qt : qt1 )
        		DDSToolInterface.QuoteDDSWrapper wr = DDSToolInterface.calculateDealScore(qt);
        	        	
        	Decimal cmp = DDSToolInterface.getDDSCompensation(qt1[0], 1, 'PureEngage');
        }
	}
	
     static testmethod void pureSubsTst () {   
        List<BigMachines__Quote__c> qt2 = [SELECT Id FROM BigMachines__Quote__c 
                         WHERE Offering_Type__c = 'PureEngage Subscription'
                           AND BigMachines__Status__c = 'Quote Approved' 
                           AND Quote_Business_Type__c = 'On Premise'
                           AND New_Price_Book__c = 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
                           
        if ( !qt2.isEmpty() )  { 
        	for ( BigMachines__Quote__c qt : qt2 )
        		DDSToolInterface.QuoteDDSWrapper wr = DDSToolInterface.calculateDealScore(qt);
        	        	
        }                           
	}
     static testmethod void pureAmendTst () {   
        List<BigMachines__Quote__c> qt2 = [SELECT Id FROM BigMachines__Quote__c 
                         WHERE Offering_Type__c = 'PureEngage Subscription'
                           AND Order_Type__c LIKE 'Amend%'
                           AND BigMachines__Status__c = 'Quote Approved' 
                           AND Quote_Business_Type__c = 'On Premise'
                           AND New_Price_Book__c = 'NG5_NA_USD' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
                           
        if ( !qt2.isEmpty() )  { 
        	for ( BigMachines__Quote__c qt : qt2 )
        		DDSToolInterface.QuoteDDSWrapper wr = DDSToolInterface.calculateDealScore(qt);
        	        	
        }                           
     }
     
     static testmethod void errTst1 () {   
        List<BigMachines__Quote__c> qt2 = [SELECT Id FROM BigMachines__Quote__c 
                         WHERE Quote_Business_Type__c = 'Cloud'
                          AND Offering_Type__c = 'PureCloud' AND CreatedDate = LAST_N_MONTHS:6 LIMIT 1];
                           
        if ( !qt2.isEmpty() )  { 
        	for ( BigMachines__Quote__c qt : qt2 )
        		DDSToolInterface.QuoteDDSWrapper wr = DDSToolInterface.calculateDealScore(qt);
        	        	
        }                           
     }
        
}