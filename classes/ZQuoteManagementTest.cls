@isTest (seeAllData=false)
private class ZQuoteManagementTest {

    static zqu__Quote__c getQuote(Id quoteId)
    {
        return [SELECT Id
                , PureCloud_Monthly_Minimum__c
                , zqu__StartDate__c
                , zqu__TermStartDate__c 
                , PureCloud_Ramp_Up_Period__c
                FROM zqu__Quote__c 
                WHERE Id = :quoteId LIMIT 1];
    }

    static testMethod void testQuoteFieldInitialization()
    {
        TestZQuoteContext context = new TestZQuoteContext();
        context.SetupZQuote();

        Test.startTest();
        // Assert Minimum
        zqu__Quote__c quote = [SELECT Id
                               , PureCloud_Monthly_Minimum__c
                               , zqu__StartDate__c
                               , zqu__TermStartDate__c 
                               , PureCloud_Ramp_Up_Period__c
                               FROM zqu__Quote__c 
                               WHERE Id = :context.ZQuote.Id LIMIT 1];

        //System.assertEquals(2000, quote.PureCloud_Monthly_Minimum__c, 'PureCloud Monthly Minimum was not initialized');

        System.assertEquals(quote.zqu__TermStartDate__c, quote.zqu__StartDate__c.addMonths(Integer.valueOf(quote.PureCloud_Ramp_Up_Period__c)), 'Term Start Date did not automatically adjust for ramp up period');

        // Update Ramp, ensure start date changes
        quote.PureCloud_Ramp_Up_Period__c = 4;
        update quote;

        quote = getQuote(quote.Id);

        System.assertEquals(quote.zqu__TermStartDate__c, quote.zqu__StartDate__c.addMonths(Integer.valueOf(quote.PureCloud_Ramp_Up_Period__c)), 'Term Start Date did not automatically adjust for ramp up period');

        Test.stopTest();
    }

    static testMethod void testQuoteFieldInitializationPCTrial()
    {
        insert GeneralCustomSettingFactory.CreateZuoraCustomSettings();
        //insert AxLegalEntityFactory.CreateDefaultEntity();
    
        Test.startTest();

        Account account = AccountFactory.CreateProspectAccount('PCAccount');
        insert account;

        Opportunity opp = OpportunityFactory.CreatePureCloudTrialOpportunity('PCTrialOpp');
        opp.AccountId = account.Id;
        insert opp;

        zqu__Quote__c quote = TestZQuoteContext.createQuote(true, account.Id, opp, true);

        quote = [SELECT Id
                 , PureCloud_Monthly_Minimum__c
                 , PureCloud_Ramp_Up_Period__c
                 FROM zqu__Quote__c 
                 WHERE Id = :quote.Id LIMIT 1];

        System.assertEquals(quote.PureCloud_Monthly_Minimum__c, 0, 'PureCloud Monthly Minimum was not set to 0 for PC Trial');

        System.assertEquals(quote.PureCloud_Ramp_Up_Period__c, 0, 'PureCloud Ramp Up Period was not set to 0 for PC Trial');

        Test.stopTest();
    }
    /*
        static testMethod void testOpportunityFieldUpdation() {
                //creating test data
            Account acc = TestUtilityHelper.createAccount('Test Account', null);
            insert acc;
            
            Opportunity opp = TestUtilityHelper.createOpportunity('Test Opportunity', acc.id); 
            insert opp;
            
            Quote__c quote = TestUtilityHelper.createQuote(opp.id);
            
            Test.startTest();
            insert quote;
            Test.stopTest();
            //assert
            Quote__c testQuote = [select opportunity__r.owner.email, Opportunity_Owner_Email__c
                                    from Quote__c where id = : quote.id];
            
            System.assertEquals(testQuote.opportunity__r.owner.email, testQuote.Opportunity_Owner_Email__c);
        }
    */
}