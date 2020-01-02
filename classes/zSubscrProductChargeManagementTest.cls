@isTest
private class zSubscrProductChargeManagementTest {
	
	public testMethod static void TestzSubscrProductChargeManagementInsert()
    {
        zqu__Quote__c zQuote;
        Test.startTest();
        TestZQuoteContext context = new TestZQuoteContext();
        //5 charges for ZQuote added
        context.SetupZQuote();
        Test.stopTest();
        context.SimulateSendtoZBilling();
        zQuote = context.ZQuote;
        
        // An update already happens to the QuoteCharge through a WF, so the IncludedUnits should reflect the value from its Usage Qty
        Account acc = [SELECT Id, Name, PureCloud_Products__c FROM Account WHERE Id = :zQuote.zqu__Account__c LIMIT 1];
        
        System.debug('PC Products: ' + acc.PureCloud_Products__c);
        System.assert(String.isNotBlank(acc.PureCloud_Products__c),'PureCloud Products is blank.');        
        if (acc.PureCloud_Products__c != null)
        {
            System.assert(acc.PureCloud_Products__c.Contains('Standard'), 'Updated Account PC Products field');
        }
    }
    
    public testMethod static void TestzSubscrProductChargeManagementInsertNoNewToken()
    {
         zqu__Quote__c zQuote;
        Test.startTest();
        TestZQuoteContext context = new TestZQuoteContext();
        //5 charges for ZQuote added
        context.SetupZQuote();
        zQuote = context.ZQuote;
        Service_Token__c token = new Service_Token__c();
        token.Account__c = zQuote.zqu__Account__c;
        token.Description__c = 'PS-170-PURE-SVBRONZE';
        token.Effective_Date__c = date.today();
		token.Expiration_Date__c = date.today().addDays(365);
		token.Quantity__c = 40;
        token.Batch__c = 1;
        insert token;
        Test.stopTest();
        context.SimulateSendtoZBilling();
       	Integer rows = [select count() from Service_Token__c where Account__c = : zQuote.zqu__Account__c];
        system.assertEquals(1, rows, 'Number of Tokens');
        
    }
	
}