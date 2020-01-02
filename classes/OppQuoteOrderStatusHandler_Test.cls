/*
	04/25/2013	Naresh Kumar
	Test Class to test main class OppQuoteOrderStatusHandler
 */
@isTest (seeAllData = true)
public class OppQuoteOrderStatusHandler_Test {
    static testMethod void testStatus1() {
   		BigMachines__Quote__c testQuote = TestUtil.createQuotes(1, true)[0];
   		 Util.Bypass_Trigger_Chk = true;
        testQuote.BigMachines__Status__c = 'Quote In Progress';
       // testQuote.Quote_Business_Type__c = 'Renewal';
   		update testQuote;
         Util.Bypass_Trigger_Chk = false;
   		
   		TriggerFlowManager.QUOTE_STATUS_TO_OPP_STATUS_POPULATION = true;
   		testQuote.BigMachines__Status__c = 'Quote Pending Approval';
   		update testQuote;
   		   		
    	TriggerFlowManager.QUOTE_STATUS_TO_OPP_STATUS_POPULATION = true;	
    	testQuote.BigMachines__Status__c = 'Order Submitted';
   		update testQuote;
        
        TriggerFlowManager.QUOTE_STATUS_TO_OPP_STATUS_POPULATION = true;	
    	testQuote.BigMachines__Status__c = 'Order Approved';
   		update testQuote;
        
        TriggerFlowManager.QUOTE_STATUS_TO_OPP_STATUS_POPULATION = true;	
    	testQuote.BigMachines__Status__c = 'Order Rejected';
   		update testQuote;

    	
    	TriggerFlowManager.QUOTE_STATUS_TO_OPP_STATUS_POPULATION = true;
   		testQuote.BigMachines__Status__c = 'Legacy Cancelled';
   		update testQuote;   
    
   		testQuote.Sent_to_Customer__c = true;
   		testQuote.BigMachines__Is_Primary__c = true;
   		update testQuote;   		
    }
    static testMethod void testStatus2() {
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Cloud Renewal' LIMIT 1];
        
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        list_NewOpps[0].RecordTypeId = rt.id;
        update list_NewOpps[0];
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
         Util.Bypass_Trigger_Chk = false;
   		list_NewQuotes[0].BigMachines__Status__c = 'Quote In Progress';
   		update list_NewQuotes;
   		
        
   	}
     static testMethod void testStatus3() {
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Cloud Renewal' LIMIT 1];
        
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        list_NewOpps[0].RecordTypeId = rt.id;
        update list_NewOpps[0];
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
         Util.Bypass_Trigger_Chk = false;
   		list_NewQuotes[0].BigMachines__Status__c = 'Order Accepted';
   		update list_NewQuotes; 
        
        
   	}
       static testMethod void testStatus4() {
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        RecordType rt = [SELECT Id,name FROM RecordType WHERE sObjectType = 'Opportunity' AND Name = 'Cloud Renewal' LIMIT 1];
        
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        list_NewOpps[0].RecordTypeId = rt.id;
        update list_NewOpps[0];
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
         Util.Bypass_Trigger_Chk = false;
   		list_NewQuotes[0].BigMachines__Status__c = 'Quote Approved';
   		update list_NewQuotes; 
        
        
   	}
      static testMethod void testStatus5() {
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 2);
        update list_NewOpps[0];
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
         Util.Bypass_Trigger_Chk = false;
        ServiceContract sc =new ServiceContract( Name = 'Service Contract ', Pricebook2id = Test.getStandardPricebookId(), 
            									CurrencyIsoCode = 'USD', Agreement_Status__c = 'Active',
            									Sold_To_Name__c = list_NewAccts[0].id, End_User_Name__c = list_NewAccts[0].id, 
								            	AccountId = list_NewAccts[0].id, Renewal_Opportunity__c = list_NewOpps[1].Id);
		insert sc;	
        Quote_Service_Contracts__c cotermServiceContract =new Quote_Service_Contracts__c(Quote__c = list_NewQuotes[0].Id, Service_Contract__c = sc.Id);
        insert cotermServiceContract;
   		list_NewQuotes[0].BigMachines__Status__c = 'Quote Approved';
   		update list_NewQuotes; 
          list_NewQuotes[0].BigMachines__Status__c = 'Order Approved';
   		update list_NewQuotes; 
        
        
   	}
    
}