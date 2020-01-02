/************************************************************************************
Purpose : Unit test class for SubscriptionUtil
Written By : Ranjith Punneli
Test Classes : N/A
*************************************************************************************/
@isTest
private class SubscriptionUtilTest {
    @isTest(seealldata=true)
    static void intialTest() {
        //Skipping all triggers as we do not need any updates from triggers for the purposes of this unit test
        Util.Bypass_Trigger_Chk = true;
        
        //Create account, opp and quote
        List<Account> list_NewAccts = TestDataFactoryForQuoteTool.createAccounts(1);
        System.assertEquals(list_NewAccts.size(), 1);
        List<Opportunity> list_NewOpps = TestDataFactoryForQuoteTool.createOpportunties(list_NewAccts[0].Id, 1);
        System.assertEquals(list_NewOpps.size(), 1);
        List<BigMachines__Quote__c> list_NewQuotes = TestDataFactoryForQuoteTool.createPCQuotes(list_NewOpps[0].Id, list_NewAccts[0].Id, 2);        
        System.assertEquals(list_NewQuotes.size(), 2);
        list_NewQuotes[1].Offering_Type__c = 'PureConnect Subscription';
        update list_NewQuotes[1];
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
        SubscriptionUtil.invokeSendSubscriptionIds(new List<Subscription__c> { objNewSubscription }); 
        SubscriptionUtil.getSubscriptionCount(list_NewAccts[0].Id, 'PureCloud');
        SubscriptionUtil.getSubscriptionInfo(list_NewAccts[0].Id, 'PureCloud');
        SubscriptionUtil.getSubscriptionInfoWithoutBundleLines(list_NewAccts[0].Id, 'PureCloud');
        SubscriptionUtil.getSubscriptionsForAutoRenewal(System.today());
        SubscriptionUtil.getSubscription(objNewSubscription.Id);
        SubscriptionUtil.getQuotes(new List<Id> { list_NewQuotes[0].Id });
        SubscriptionUtil.getSubscriptionProducts(objNewSubscription.Id);
        SubscriptionUtil.getSubscriptionProductForSubscrps(new Set<Id> { objNewSubscription.Id });
        
        
        SubscriptionUtil.buildQuoteProdFromSubscrProd(objNewSubscription.Id, list_NewSubscriptionProds[0]);
        SubscriptionUtil.buildSubscrProdFromQuoteProd(list_NewQuoteProds[0]);
        SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);
        SubscriptionUtil.buildQuoteFromSubscr(objNewSubscription, list_NewQuotes[0]);
        
        objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[1]);
        SubscriptionUtil.buildQuoteFromSubscr(objNewSubscription, list_NewQuotes[1]);
        
        SubscriptionUtil.getRemovedProductsFromAmendedQuote(new Set<Id> { list_NewSubscriptionProds[0].Product__c }, objNewSubscription);
        Map<String, Service_Token_Definition__c> map_TokDefs = SubscriptionUtil.loadServiceTokenDefinition();
        SubscriptionUtil.createServiceTokens(list_SubscriptionProds, map_TokDefs);
        SubscriptionUtil.updateAccountSupportOptions(new Map<Id, Account> { list_NewAccts[0].Id => list_NewAccts[0] }, new Map<Id, List<Subscription_Product__c>> { list_NewAccts[0].Id => list_SubscriptionProds });
        
        
              
        SubscriptionUtil.buildQryForRenewOppAndQuoteFromSubscrs('');
        
        list_NewQuotes[1].Offering_Type__c = 'PureConnect Cloud';
        list_NewQuotes[1].Annual_Price_Escalation_Other__c = 3.0;
        list_NewQuotes[1].Price_Escalation__c = '3%';
        list_NewQuotes[1].Overage_Allowance__c='25%';
        update list_NewQuotes[1];
        objNewSubscription = SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[1]);
        SubscriptionUtil.buildQuoteFromSubscr(objNewSubscription, list_NewQuotes[1]);
        upsert objNewSubscription;
        SubscriptionUtil.cloneSubscriptionAndProducts(objNewSubscription.id);
        
        list_NewQuotes[1].Offering_Type__c = 'Business Edition';
        update list_NewQuotes[1];
        SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[1]);
        
        List<Order__c> objOrders = TestDataFactoryForQuoteTool.createOrders(list_NewQuotes[1].id,list_NewQuotes[1].BigMachines__Opportunity__c,1);
        Set<ID> set_OrderIDs = new Set<ID>();
        for(Account_Order_Address__c objAddress : list_NewQtAddrs)
        {
            objAddress.Order__c = objOrders[0].id;
        }
        update list_NewQtAddrs;
        
        for(Order__c objOrder : objOrders)
        {
            set_OrderIDs.add(objOrder.id);
        }
        SubscriptionUtil.setOrderBillToEmailsMap(set_OrderIDs);
        SubscriptionUtil.updateSubscriptionFlagOnOrder(set_OrderIDs);
        //Id cloudRenewalRecTypeId  = Schema.SObjectType.Subscription__c.getRecordTypeInfosByName().get('Cloud').getRecordTypeId();
        //Subscription__c objSub = new Subscription__c();
        Test.setMock(HttpCalloutMock.class, new TestWebService_MockSetUp()); 
        SubscriptionUtil.sendSubscriptionsToBilling(objNewSubscription.Id,'cloudDeploymentId','PureConnect Subscription');
        SubscriptionUtil.cloneSubscriptionAndProductsForTrial(objNewSubscription.Id,'PureConnect Subscription');
        //map<Id,string> subMap = new map<Id,string>{objNewSubscription.Id =>''};
        objNewSubscription.order__c = objOrders[0].id;
        map<Id,string> subMap = new map<Id,string>();
        subMap.put(objNewSubscription.Id,'');
        SubscriptionUtil.copyAccountOrderAddrtoCCDB(subMap);
        objNewSubscription.Offering_Type__c='PureEngage Cloud';
        Util.Bypass_Trigger_Chk = false;
        update objNewSubscription;
        list_NewQuotes[0].Offering_Type__c='PureEngage Cloud';
        update list_NewQuotes;
        SubscriptionUtil.buildSubscrFromQuote(list_NewQuotes[0]);

    }
            
}