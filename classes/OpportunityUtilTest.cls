/************************************************************************************
Purpose : Unit test class for OpportunityUtil
Written By : Ranjith Punneli
Test Classes : N/A
*************************************************************************************/
@isTest(seealldata=true)
private class OpportunityUtilTest {
    
    static testMethod void intialTest() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewQuotes.size(), 1);
        list_NewOpps[0].Primary_Quote__c=list_NewQuotes[0].Id;
        update list_NewOpps[0];
        //Add quote line items         
        List<BigMachines__Quote_Product__c> list_NewQuoteProds = TestDataFactoryForQuoteTool.createPCQuoteProducts(list_NewQuotes[0].Id);
        
        List<Account_Order_Address__c> list_NewQtAddrs = TestDataFactoryForQuoteTool.createAOAs(list_NewQuotes[0].Id);
        System.assertEquals(list_NewQtAddrs.size(), 4); 
        
        //Create subscription & products        
        List<Subscription_Product__c> list_NewSubscriptionProds = new List<Subscription_Product__c>();
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);  
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = 0;
        insert objNewSubscription;
        for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds) {                    
            Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);             
            objNewSubscriptionProd.Subscription__c = objNewSubscription.Id;
            list_NewSubscriptionProds.add(objNewSubscriptionProd);
        }  
        insert list_NewSubscriptionProds;
        
        List<Subscription_Product__c> list_SubscriptionProds = [SELECT Id, Product__r.APN_Number__c, Product__c,Subscription__r.Account__c,
                                                                       Subscription__r.Subscription_Start_Date__c, Quantity__c,
                                                                       Subscription__r.Start_Date__c, Subscription__r.Name, Subscription__c
                                                                FROM Subscription_Product__c 
                                                                WHERE Subscription__c =: objNewSubscription.Id];
        
        Set<ID> set_AccountIds = new Set<ID>();
        for(Account acc : list_NewAccts)
            set_AccountIds.add(acc.id);
        
        Set<ID> set_OpptyIds = new Set<ID>();
        for(Opportunity opp : list_NewOpps)
            set_OpptyIds.add(opp.id);
            
        OpportunityUtil.FetchGSRelationship(set_AccountIds);  
        
        Cloud_Forecast_Quarter__c objCloudForecast = new Cloud_Forecast_Quarter__c(Current_Week__c = True, Active__c = True);
        insert objCloudForecast;
        
        Account_Revenue_Forecast__c objAccountRevenue = new Account_Revenue_Forecast__c(Account__c = list_NewAccts[0].id,Cloud_Forecast_Quarter__c = objCloudForecast.id, LOB__c = 'A - In-Force Subscription'); 
        insert objAccountRevenue;
          
        //OpportunityUtil.UpdateRunRate(set_OpptyIds); 
    }
    
    static testMethod void testUpdatePlatformAndOfferingType() {
        Account testAccount = TestUtil.createAccounts(1, true)[0];
        Opportunity testOpp = TestUtil.createOpportunities(1, testAccount.id, false)[0];
        testOpp.Lead_Offer__c = 'PureConnect Cloud';
        insert testOpp;        
        testOpp.Lead_Offer__c = 'PureConnect Premise';
        update testOpp;
        
        testOpp.Lead_Offer__c = 'PureConnect Premise Subscription';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'PureConnect Premise Rental';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'Outbound Engagement Cloud';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'PureEngage Premise';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'PureEngage Premise Subscription';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'PureEngage Premise Rental';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'PureEngage Cloud Partner PPU';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
         testOpp.Lead_Offer__c = 'PureConnect Cloud Partner PPU';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'PureCloud';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'PureEngage Cloud';
        testOpp.Primary_Solution__c = null;
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'PureEngage Cloud';
        testOpp.Primary_Solution__c = 'Test';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'PureEngage Cloud';
        testOpp.Primary_Solution__c = 'Outbound';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'PureEngage Cloud Partner PPU';
        testOpp.Primary_Solution__c = 'test';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'PureEngage Cloud Partner PPU';
        testOpp.Primary_Solution__c = null;
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'PureEngage Cloud Partner PPU';
        testOpp.Primary_Solution__c = 'Outbound';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'Premier Edition Cloud';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);        
        testOpp.Lead_Offer__c = 'Outbound Engagement Cloud';
        testOpp.Primary_Solution__c = 'test';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        testOpp.Lead_Offer__c = 'Outbound Engagement Cloud';
        testOpp.Primary_Solution__c = 'Outbound';
        OpportunityUtil.updateOpportunityWithOfferingAndPlatformType(testOpp);
        
    }
}