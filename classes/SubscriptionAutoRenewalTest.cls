/************************************************************************************
Purpose : Unit test class for SubscriptionAutoRenewal, SubscriptionAutoRenewalScheduler
Written By : Ranjith Punneli
Test Classes : N/A
*************************************************************************************/
@isTest
private class SubscriptionAutoRenewalTest {
    @isTest(seealldata=true)
    static void intialTest() {
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
        List<Subscription__c> list_NewSubscriptions = new List<Subscription__c>();
        Subscription__c objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);  
        objNewSubscription.CMRR__c = objNewSubscription.ACV__c = objNewSubscription.TCV__c = 0;
        objNewSubscription.Subscription_End_Date__c = Date.today();
        objNewSubscription.Sale_Type__c = 'Indirect';
        objNewSubscription.Business_Partner__c = [SELECT Id FROM Account WHERE Name = 'Atea AS' AND Legacy_Account_ID__c = '102351' LIMIT 1].Id;
        list_NewSubscriptions.add(objNewSubscription);
        insert list_NewSubscriptions;
        for(BigMachines__Quote_Product__c objQtProd: list_NewQuoteProds) {                    
            Subscription_Product__c objNewSubscriptionProd = SubscriptionUtil.buildSubscrProdFromQuoteProd(objQtProd);             
            objNewSubscriptionProd.Subscription__c = objNewSubscription.Id;
            list_NewSubscriptionProds.add(objNewSubscriptionProd);
        }  
        insert list_NewSubscriptionProds;
        
        Test.StartTest();    
            SubscriptionAutoRenewalScheduler objSubscriptionAutoRenewalScheduler = new SubscriptionAutoRenewalScheduler();
            String strSchd = '0 48 * * * ?'; 
            System.schedule('Schedule to auto renew subscriptions', strSchd, objSubscriptionAutoRenewalScheduler);
          //SubscriptionAutoRenewal objSubscriptionAutoRenewal = new SubscriptionAutoRenewal(Date.today());   
        Test.stopTest();
    }
}