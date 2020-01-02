/**
 * Test class for BigMachinesQuote Before and After Trigger
 * Author - Rashmi K (ClearTask) - Mar 27 2013
 */
@isTest
private class TestBigMachineQuoteTrigger {
  /* Vikram to deploy
	// when a quote is cancelled, update opp stage to Closed Quote Cancelled
    static testMethod void testQuoteCancelledOnUpdate() {
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAcc.Id, true)[0];
        BigMachines__Quote__c quote = testUtil.createQuotes(1, testOpp.Id, true)[0];
        
        Test.startTest();
        	quote.Cancellation_Reason__c = 'Cancelled';
        	update quote;
        Test.stopTest();
        
        testOpp = [Select Id, StageName from Opportunity where Id=:testOpp.Id];
        system.assertEquals(QuoteProductUtil.QUOTE_CLOSE_CANCELLED , testOpp.StageName);
    }
    
    static testMethod void testQuoteCancelledOnInsert() {
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAcc.Id, true)[0];
        BigMachines__Quote__c quote = testUtil.createQuotes(1, testOpp.Id, false)[0];
        
        Test.startTest();
        	quote.Cancellation_Reason__c = 'Cancelled';
        	insert quote;
        Test.stopTest();
        
        testOpp = [Select Id, StageName from Opportunity where Id=:testOpp.Id];
        system.assertEquals(QuoteProductUtil.QUOTE_CLOSE_CANCELLED , testOpp.StageName);
    }
    
    // field mapping from primary quote To Opp
    static testMethod void testPrimaryQuoteFieldMappings() {
    	TestUtil.createGlobalSettings();
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAcc.Id, true)[0];
        BigMachines__Quote__c quote = testUtil.createQuotes(1, testOpp.Id, false)[0];
        quote.Genesys_Care_Rate__c = 18;
        quote.Decreased_Quote_Reason__c = 'Discount';
        quote.BigMachines__Status__c = 'Order Submitted';
        quote.Comment__c = 'Testing';
        quote.Genesys_Care__c = 'Business Care-Renewal(End User)';
        quote.Maintenance_Start_Date__c = Date.today();
        quote.Maintenance_End_Date__c = Date.today().addYears(1);
        quote.Quote_Version__c = 1;
        quote.Big_Six__c = 'North America';
        quote.SG2_Region__c = 'EMEA';
        quote.Current_Maint_Rate__c = 0; 
        insert quote;
        
        Test.startTest();
        	quote.BigMachines__Is_Primary__c = true;
        	update quote;
        Test.stopTest();
        
        testOpp = [Select Id, Quote_Genesys_Care_Rate__c, Quote_Decreased_Quote_Reason__c,
        				  Quote_Quote_Status__c, Quote_Comment__c, Quote_Genesys_Care__c,
        				  Quote_Maintenance_Start_Date__c, Quote_Maintenance_End_Date__c,
        				  Quote_Quote_Version__c, Quote_Big_Six__c, Quote_SG2_Region__c, Current_Maint_Rate__c 
        		   from Opportunity where Id=:testOpp.Id];
        system.assertEquals(quote.Genesys_Care_Rate__c, testOpp.Quote_Genesys_Care_Rate__c);
        system.assertEquals(quote.Decreased_Quote_Reason__c, testOpp.Quote_Decreased_Quote_Reason__c);
        system.assertEquals(quote.BigMachines__Status__c, testOpp.Quote_Quote_Status__c);
        system.assertEquals(quote.Comment__c, testOpp.Quote_Comment__c);
        system.assertEquals(quote.Genesys_Care__c, testOpp.Quote_Genesys_Care__c);
        system.assertEquals(quote.Maintenance_Start_Date__c, testOpp.Quote_Maintenance_Start_Date__c);
        system.assertEquals(quote.Maintenance_End_Date__c, testOpp.Quote_Maintenance_End_Date__c);
        system.assertEquals(quote.Quote_Version__c, testOpp.Quote_Quote_Version__c);
        system.assertEquals(quote.Big_Six__c, testOpp.Quote_Big_Six__c);
        system.assertEquals(quote.SG2_Region__c, testOpp.Quote_SG2_Region__c);
        system.assertEquals(quote.Current_Maint_Rate__c, testOpp.Current_Maint_Rate__c);
    }
    
    static testMethod void testMaintRateForLicenseOppQuotes(){
    	RecordType rtype = [Select Id from RecordType where SobjectType='Opportunity' and DeveloperName =:ServiceContractUtil.OPP_GEN_NEW_DEV_NAME];
        Account testAcc = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAcc.Id, false)[0];
        testOpp.RecordTypeId = rtype.Id;
        insert testOpp;
        BigMachines__Quote__c quote = testUtil.createQuotes(1, testOpp.Id, false)[0];
        quote.Genesys_Care_Overide__c = '18';
        quote.Current_Maint_Rate__c = 0;
        Test.startTest();
        	insert quote;
        Test.stopTest();
        
        quote = [Select Current_Maint_Rate__c, Id, Genesys_Care_Overide__c
        		 from BigMachines__Quote__c where Id=:quote.Id];
        System.assertEquals( Decimal.valueof(quote.Genesys_Care_Overide__c), quote.Current_Maint_Rate__c);
    }
 */
}